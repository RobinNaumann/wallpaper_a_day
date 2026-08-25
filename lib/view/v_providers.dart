import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:wad/util/util.dart';
import 'package:wad/util/wad_button.dart';

import '../bit/b_settings.dart';
import '../model/m_provider.dart';
import '../providers/providers.dart';

class ProvidersView extends StatelessWidget {
  const ProvidersView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsBit.builder(
        onData: (bit, settings) => Column(
              gap: .15,
              cross: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < providers.length; i++)
                  ProviderSnippet(
                      provider: providers[i],
                      selected: settings.provider.id == providers[i].id,
                      selectedSeries: settings.provider.id == providers[i].id
                          ? settings.series
                          : null,
                      onSelect: (p, s) => bit.setProvider(p, s),
                      first: i == 0,
                      last: i == providers.length - 1)
              ],
            ));
  }
}

class ProviderSnippet extends StatelessWidget {
  final ProviderModel provider;
  final ProviderSeries? selectedSeries;
  final bool selected;
  final Function(ProviderModel p, ProviderSeries s) onSelect;
  final bool first;
  final bool last;

  const ProviderSnippet(
      {super.key,
      required this.provider,
      required this.selected,
      required this.selectedSeries,
      required this.onSelect,
      required this.first,
      required this.last});

  @override
  Widget build(BuildContext context) {
    final selColor = context.theme.color.resolve(
      kind: ColorKinds.accent,
      manner: ColorManners.plain,
    );

    return GestureDetector(
      onTap: () => selected ? null : onSelect(provider, provider.series.first),
      child: Card(
          kind: ColorKinds.accent,
          manner: ColorManners.plain,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(this.first ? RADIUS_LARGE : RADIUS_SMALL),
              bottom: Radius.circular(this.last ? RADIUS_LARGE : RADIUS_SMALL)),
          border: Border(opacity: selected ? 0 : 0),
          padding: const RemInsets.all(1),
          color: selColor.back.withTranslucency(selected ? 0.4 : BTN_ALPHA),
          child: Row(
            gap: 1,
            children: [
              Expanded(
                child: Column(
                  gap: 0,
                  cross: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      provider.label,
                      variant: TypeVariants.bold,
                    ),
                    Spacer.vertical(.5),
                    Text(provider.description),
                    if (provider.series.length > 1)
                      Padded.only(
                        top: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: MacosPopupButton<ProviderSeries>(
                              value: selectedSeries ?? provider.series.first,
                              items: [
                                for (final s in provider.series)
                                  MacosPopupMenuItem(
                                      child: Text(s.label,
                                          color: context
                                              .theme.color.selected.front),
                                      value: s)
                              ],
                              onChanged: (s) =>
                                  s != null ? onSelect(provider, s) : null),
                        ),
                      )
                  ],
                ),
              ),
              Icon(
                selected
                    ? ApfelIcons.checkmark_alt_circle_fill
                    : ApfelIcons.circle,
              )
            ],
          )),
    );
  }
}
