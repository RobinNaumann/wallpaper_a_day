import 'dart:io';

import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:moewe/moewe.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallpaper_a_day/bit/b_autostart.dart';
import 'package:wallpaper_a_day/service/s_native.dart';
import 'package:wallpaper_a_day/service/s_storage.dart';
import 'package:wallpaper_a_day/util/icon_btn.dart';
import 'package:wallpaper_a_day/view/v_providers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

 
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
            padding: const RemInsets.all(1).toPixel(context),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AIconButton(
                          icon: Icons.x,
                          tooltip: "back",
                          onTap: Navigator.of(context).pop),
                      const Text.h4("Wallpaper a Day"),
                      AIconButton(
                        icon: ApfelIcons.exclamationmark_bubble,
                        tooltip: "send feedback",
                        onTap: () => MoeweFeedbackPage.show(
                          context,
                          labels: const FeedbackLabels(
                              header: "send feedback",
                              description:
                                  "Hey ☺️ Thanks for using Wallpaper a Day!\nIf you have any feedback, questions or suggestions, please let me know. I'm always happy to hear from you.",
                              contactDescription:
                                  "if you want me to respond to you, please provide your email address or social media handle",
                              contactHint: "contact info (optional)"),
                          theme: MoeweTheme(
                              darkTheme: MacosTheme.brightnessOf(context) ==
                                  Brightness.dark),
                        ),
                      ),
                    ].spaced(),
                  ),
                  const Spaced.vertical(2),
                  const Text.h6("image provider"),
                  const Spaced.vertical(1),
                  const ProvidersView(),
                  const Spaced.vertical(2),
                  const DeleteAllButton(),
                  const Spaced.vertical(1),
                  const AutostartButton(),
                  const Spaced.vertical(1),
                  ATextButton(label: "quit", onTap: () => exit(0)),
                  const Spaced.vertical(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                          onTap: () => launchUrlString("https://robbb.in"),
                          child: const Text.bodyS("developed by Robin",
                              textAlign: TextAlign.center)),
                      GestureDetector(
                          onTap: () => launchUrlString(
                              "https://www.gnu.org/licenses/gpl-3.0.en.html#license-text"),
                          child: Text.bodyS(
                              "v${moewe.appVersion ?? "?"}+${moewe.buildNumber ?? "?"}, available under GPL-3.0",
                              textAlign: TextAlign.center)),
                    ].spaced(amount: .125),
                  ),
                ]),
          );
        }
  
  
}

class AutostartButton extends StatelessWidget {
  const AutostartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AutostartBit.builder(
        onData: (bit, start) => ATextButton(
            icon: start ?? false
                ? ApfelIcons.checkmark_circle
                : ApfelIcons.circle,
            label: "start on login",
            onTap: context.bit<AutostartBit>().toggle));
  }
}

class DeleteAllButton extends StatelessWidget {
  const DeleteAllButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ATextButton(
        icon: ApfelIcons.trash,
        label: "delete all data",
        color: Colors.redAccent,
        onTap: () => showMacosAlertDialog(
            barrierDismissible: true,
            context: context,
            builder: (c) => MacosAlertDialog(
                appIcon: MacosIcon(ApfelIcons.exclamationmark_triangle),
                title: Text("delete all data?"),
                message: Text(
                    "are you sure you want to delete all images? This cannot be undone.",
                    textAlign: TextAlign.center),
                secondaryButton: PushButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("cancel"),
                    secondary: true,
                    controlSize: ControlSize.large),
                primaryButton: PushButton(
                    onPressed: () async {
                      await StorageService.i.deleteAll();
                      exit(0);
                    },
                    child: Text("delete & quit"),
                    controlSize: ControlSize.large))));
  }
}
