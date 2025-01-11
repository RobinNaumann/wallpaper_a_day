import 'package:elbe/elbe.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:moewe/moewe.dart';
import 'package:wallpaper_a_day/bit/b_settings.dart';
import 'package:wallpaper_a_day/util/brightness_observer.dart';

import 'view/v_home.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  final pI = await tryCatchAsync(() => PackageInfo.fromPlatform());

  print(pI?.version);

  await Moewe(
          host: "open.moewe.app",
          project: "c92ae426d776ea34",
          app: "521fa540a9639f67",
          appVersion: pI?.version,
          buildNumber: int.tryParse(pI?.buildNumber ?? ""))
      .init();

  await Window.setEffect(effect: WindowEffect.transparent, dark: false);
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
              child: MacosApp(
                  title: 'Wallpaper',
                  builder: (_, __) => Navigator(
                        initialRoute: "/",
                        onGenerateRoute: (settings) => MaterialPageRoute(
                            builder: (_) => const HomeView(),
                            settings: settings),
                      ))),
        ),
      );
}
