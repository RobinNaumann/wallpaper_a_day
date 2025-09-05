import 'package:elbe/elbe.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:moewe/moewe.dart';
import 'package:wallpaper_a_day/bit/b_autostart.dart';
import 'package:wallpaper_a_day/bit/b_settings.dart';
import 'package:wallpaper_a_day/service/s_native.dart';
import 'package:wallpaper_a_day/util/brightness_observer.dart';
import 'package:wallpaper_a_day/view/v_settings.dart';

import 'view/v_home.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfoService.init();
  final pI = await tryCatchAsync(() => PackageInfo.fromPlatform());

  await Moewe(
          host: "open.moewe.app",
          project: "c92ae426d776ea34",
          app: "521fa540a9639f67",
          appVersion: pI?.version,
          buildNumber: int.tryParse(pI?.buildNumber ?? ""))
      .init();

  await NativeService.i.setupWindow();

  moewe.events.appOpen();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => Theme(
      data: ThemeData.preset(
          remSize: 14,
          titleFont: "Helvetica Neue",
          titleVariant: TypeVariants.bold),
      child: BrightnessObserver(
          child: BitProvider(
              create: (_) => SettingsBit(),
              child: BitProvider(
                  create: (_) => AutostartBit(),
                  child:  MacosApp(
                      title: 'Wallpaper',
                      builder: (c, __) => NativeService.i.base(c, Navigator(
                            initialRoute: "/",
                            onGenerateRoute: (settings) => PageRouteBuilder(
                                pageBuilder: (c,_,__) => NativeService.i.pageBase(c,settings.name == "/"
                                    ? const HomeView()
                                    : const SettingsPage()),
                                settings: settings),
                          )))))));
}


