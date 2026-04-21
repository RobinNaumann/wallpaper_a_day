import 'dart:io';

import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:moewe/moewe.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../bit/b_autostart.dart';
import '../service/s_storage.dart';
import '../util/wad_button.dart';
import 'v_providers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const RemInsets.all(1).toPixel(context),
      child: Column(gap: 0, cross: CrossAxisAlignment.stretch, children: [
        Row(
          gap: 1,
          main: MainAxisAlignment.spaceBetween,
          children: [
            WADButton.icon(
                icon: Icons.x,
                tooltip: "back",
                onTap: Navigator.of(context).pop),
            const Text.h4("settings"),
            WADButton.icon(
              icon: ApfelIcons.exclamationmark_bubble,
              tooltip: "send feedback",
              onTap: () => MoeweFeedbackPage.show(
                context,
                labels: const FeedbackLabels(
                    header: "send feedback",
                    description:
                        "Hey ☺️ Thanks for using this App!\nIf you have any feedback, questions or suggestions, please let me know. I'm always happy to hear from you.",
                    contactDescription:
                        "if you want me to respond to you, please provide your email address or social media handle",
                    contactHint: "contact info (optional)"),
                theme: MoeweTheme(
                    darkTheme:
                        MacosTheme.brightnessOf(context) == Brightness.dark),
              ),
            ),
          ],
        ),
        const Spacer.vertical(2),
        const Text.h6("image provider"),
        const Spacer.vertical(1),
        const ProvidersView(),
        const Spacer.vertical(2),
        const DeleteAllButton(),
        const Spacer.vertical(1),
        const AutostartButton(),
        const Spacer.vertical(1),
        WADButton.text(
            label: "quit", tooltip: "quit the app", onTap: () => exit(0)),
        const Spacer.vertical(),
        Column(
          gap: .125,
          cross: CrossAxisAlignment.stretch,
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
            GestureDetector(
                onTap: () => launchUrlString("https://robbb.in/donate"),
                child:
                    const Text.bodyS("donate ❤️", textAlign: TextAlign.center)),
          ],
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
        onData: (bit, start) => WADButton.text(
            icon: start ?? false
                ? ApfelIcons.checkmark_circle_fill
                : ApfelIcons.circle,
            label: "start on login",
            tooltip: "start the app on login",
            onTap: context.bit<AutostartBit>().toggle));
  }
}

class DeleteAllButton extends StatelessWidget {
  const DeleteAllButton({super.key});

  @override
  Widget build(BuildContext context) {
    return WADButton.text(
        icon: ApfelIcons.trash,
        label: "delete all data",
        kind: ColorKinds.error,
        tooltip: "delete all data",
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
