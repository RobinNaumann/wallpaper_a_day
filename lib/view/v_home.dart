import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:moewe/moewe.dart';
import 'package:wallpaper_a_day/bit/b_series.dart';
import 'package:wallpaper_a_day/bit/b_settings.dart';
import 'package:wallpaper_a_day/view/v_current.dart';
import 'package:wallpaper_a_day/view/v_settings.dart';

import '../util/icon_btn.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsBit.builder(onData: (sbit, settings) {
      print("UPDATING SETTINGS ${settings.series.label}");
      return BitProvider(
          key: Key(settings.toString()),
          create: (_) =>
              SeriesBit(settings.provider, settings.series, settings.imgId),
          child: SeriesBit.builder(
              onError: (bit, error) => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                          child: Icon(ApfelIcons.exclamationmark_triangle)),
                      const Text("data could not be read",
                          textAlign: TextAlign.center),
                      PushButton(
                          onPressed: () => sbit.deleteConfig(),
                          controlSize: ControlSize.large,
                          child:
                              Text("reset ${settings.provider.label} config")),
                      Padded.only(
                        top: 1,
                        child: TextButton(
                            onPressed: () => SettingsPage.routeTo(context),
                            child: const Text("open settings")),
                      )
                    ].spaced(),
                  ),
              onData: (bit, data) => Column(children: [
                    Padded.all(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AIconButton(
                              icon: ApfelIcons.settings,
                              tooltip: "previous",
                              onTap: () => SettingsPage.routeTo(context)),
                          AIconButton(
                              icon: ApfelIcons.chevron_left,
                              tooltip: "previous",
                              onTap: data.images.isEmpty || data.index == 0
                                  ? null
                                  : () => bit.previous(context)),
                          AIconButton(
                              icon: ApfelIcons.chevron_right,
                              tooltip: "next",
                              onTap: data.images.isEmpty ||
                                      data.index == data.images.length - 1
                                  ? null
                                  : () => bit.next(context)),
                          AIconButton(
                              icon: ApfelIcons.chevron_right_2,
                              tooltip: "current",
                              onTap: data.images.isEmpty ||
                                      data.index == data.images.length - 1
                                  ? null
                                  : () => bit.current(context)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const MoeweUpdateView(
                                url: "https://apps.robbb.in/wallpaper_a_day"),
                            Padded.symmetric(
                              horizontal: 1,
                              child: (data.current == null)
                                  ? Padded.symmetric(
                                      vertical: 4,
                                      child: Column(
                                        children: [
                                          const Center(
                                              child: Icon(
                                                  ApfelIcons.cloud_download)),
                                          const Text(
                                              "images will be loaded soon",
                                              textAlign: TextAlign.center),
                                        ].spaced(),
                                      ),
                                    )
                                  : CurrentImage(model: data.current!),
                            ),
                            Padded.all(
                              child: _ReloadBtn(
                                label:
                                    "${settings.provider.label} - ${settings.series.label}",
                                onTap: () => bit.refresh(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ])));
    });
  }
}

Widget iconButton({required IconData icon, required void Function() onTap}) =>
    GestureDetector(onTap: onTap, child: Icon(icon));

class _ReloadBtn extends StatefulWidget {
  final String label;
  final void Function() onTap;
  const _ReloadBtn({super.key, required this.label, required this.onTap});

  @override
  State<_ReloadBtn> createState() => __ReloadBtnState();
}

class __ReloadBtnState extends State<_ReloadBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padded.only(
              top: .25,
              child: RotationTransition(
                turns: _controller,
                child: Padded.only(
                  bottom: .25,
                  child: const Icon(ApfelIcons.refresh),
                ),
              )),
          Text(widget.label),
        ].spaced(amount: .5),
      ),
    );
  }
}
