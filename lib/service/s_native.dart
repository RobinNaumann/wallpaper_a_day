import 'dart:io';

import 'package:elbe/elbe.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

abstract class NativeService {
  Future<void> setWallpaper(File file);
  Future<void> setAutostart(bool onLogin);
  Future<bool?> getAutostart();
  Future<void> setupWindow();
  Widget base(BuildContext context, Widget child) => child;
  Widget pageBase(BuildContext context, Widget child) => child;

  static NativeService? _i = null;
  static NativeService get i {
    if (_i == null) {
      if (runPlatform.isMacos) return MacosNativeService();
      if (runPlatform.isWindows) return WindowsNativeService();
      throw UnimplementedError("platform unsupported");
    }
    return _i!;
  }
}

class WindowsNativeService extends NativeService {
  static const MethodChannel _c = MethodChannel('in.robbb.wad');

  Future<void> setAutostart(bool onLogin) =>
      _invoke(_c, 'setAutostart', {'on_login': onLogin});

  Future<bool?> getAutostart() => _invoke(_c, 'getAutostart', {});

  @override
  Future<void> setWallpaper(File file) async {
    return await _invoke(_c, 'setWallpaper', {'path': file.absolute.path});
  }

  @override
  Future<void> setupWindow() async {
    final size = Size(350, 400);
    await windowManager.ensureInitialized();
    await windowManager.hide();

    WindowOptions windowOptions = WindowOptions(
      size: size,
      backgroundColor: Colors.transparent,
      alwaysOnTop: true,
      skipTaskbar: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAsFrameless();
      await windowManager.setResizable(false);
      await windowManager.setAlignment(Alignment.bottomRight);
      await Window.initialize();
      await Window.setEffect(effect: WindowEffect.transparent);
      await windowManager.show();
      await windowManager.focus();
    });

    await trayManager.setIcon("assets/icon_windows.ico");
    //await trayManager.setIcon("resources\\app_icon.ico");
    trayManager.addListener(_WindowsTrayHandler());
    windowManager.addListener(_WindowsTrayHandler());
  }

  @override
  Widget base(BuildContext context, Widget child) => Padded.all(
        value: .5,
        child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child),
      );

  @override
  Widget pageBase(BuildContext context, Widget child) => Container(
      color: context.theme.color.mode == ColorModes.light
          ? const Color(0xFFF0F0F0)
          : const Color(0xFF202020),
      child: child);
}

class MacosNativeService extends NativeService {
  static const MethodChannel _c = MethodChannel('in.robbb.wad');
  Future<void> setWallpaper(File file) =>
      _invoke(_c, 'setWallpaper', {'path': file.path});

  Future<void> setAutostart(bool onLogin) =>
      _invoke(_c, 'setAutostart', {'on_login': onLogin});

  Future<bool?> getAutostart() => _invoke(_c, 'getAutostart', {});

  @override
  Future<void> setupWindow() async {
    await Window.initialize();
    await Window.setEffect(effect: WindowEffect.transparent, dark: false);
  }
}

Future<T?> _invoke<T>(
    MethodChannel channel, String method, Map<String, dynamic> args) async {
  try {
    return await channel.invokeMethod(method, args);
  } on PlatformException catch (e) {
    print("Failed to invoke $method: '${e.message}'.");
    return null;
  } catch (e) {
    print("Failed to invoke $method: '$e'.");
    return null;
  }
}

class _WindowsTrayHandler with TrayListener, WindowListener {
  @override
  void onTrayIconMouseDown() async {
    final isVisible = await windowManager.isVisible();
    isVisible ? windowManager.hide() : windowManager.show();
  }

  @override
  void onWindowBlur() async {
    final isVisible = await windowManager.isVisible();
    if (isVisible) windowManager.hide();
  }
}
