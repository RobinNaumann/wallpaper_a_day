import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:moewe/moewe.dart';
import 'package:wad/util/util.dart';

import 'bit/b_autostart.dart';
import 'bit/b_settings.dart';
import 'service/s_native.dart';
import 'util/brightness_observer.dart';
import 'view/v_home.dart';
import 'view/v_settings.dart';

String sessionId = uniqueId();

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfoService.init();
  LoggerService.init(ConsoleLoggerService());
  final pI = await tryCatchAsync(() => PackageInfo.fromPlatform());

  await Moewe(
          host: "open.moewe.app",
          project: "c92ae426d776ea34",
          app: "521fa540a9639f67",
          appVersion: pI?.version,
          buildNumber: int.tryParse(pI?.buildNumber ?? ""))
      .init();

  //await NativeService.i.setupWindow();
  WindowMainStateListener.instance.overrideIsMainWindow(true);

  // we want the popover to be translucent
  await NativeService.i.setupWindow();
  await NativeService.i.setAutostart(true);

  moewe.events.appOpen(data: {"session": sessionId});
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => Theme(
      data: ThemeData.preset(
          colorSeed:
              ColorSeed.make(accent: LayerColor.fromBack(Color(0xFF4f58c2))),
          remSize: 14,
          titleFont: "Inter",
          titleVariant: TypeVariants.bold),
      child: BrightnessObserver(
          child: BitProvider(
              create: (_) => SettingsBit(),
              child: BitProvider(
                  create: (_) => AutostartBit(),
                  child: MacosApp(
                      title: 'Wallpaper',
                      builder: (c, __) => NativeService.i.base(
                          c,
                          Box(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                //BrandingBar(),
                                Expanded(
                                  child: Navigator(
                                    initialRoute: "/",
                                    onGenerateRoute: (settings) =>
                                        PageRouteBuilder(
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration: Duration
                                                .zero,
                                            pageBuilder: (c, _,
                                                    __) =>
                                                NativeService.i.pageBase(
                                                    c,
                                                    settings.name == "/"
                                                        ? const HomeView()
                                                        : const SettingsPage()),
                                            settings: settings),
                                  ),
                                ),
                              ],
                            ),
                          )))))));
}
