import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel('in.robbb.wad');
  static final NativeService i = NativeService._();
  NativeService._();

  Future<void> setWallpaper(String path) =>
      _invoke('setWallpaper', {'path': path});

  Future<void> setAutostart(bool onLogin) =>
      _invoke('setAutostart', {'on_login': onLogin});

  Future<bool?> getAutostart() => _invoke('getAutostart', {});

  Future<T?> _invoke<T>(String method, Map<String, dynamic> args) async {
    try {
      return await _channel.invokeMethod(method, args);
    } on PlatformException catch (e) {
      print("Failed to invoke $method: '${e.message}'.");
      return null;
    } catch (e) {
      print("Failed to invoke $method: '$e'.");
      return null;
    }
  }
}
