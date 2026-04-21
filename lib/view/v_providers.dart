import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';

import '../bit/b_settings.dart';
import '../model/m_provider.dart';
import '../providers/providers.dart';

class ProvidersView extends StatelessWidget {
  const ProvidersView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsBit.builder(
        onData: (bit, settings) => Column(
              gap: 1,
              cross: CrossAxisAlignment.stretch,
              children: [
                for (final p in providers)
                  ProviderSnippet(
                      provider: p,
                      selected: settings.provider.id == p.id,
                      selectedSeries:
                          settings.provider.id == p.id ? settings.series : null,
                      onSelect: (p, s) => bit.setProvider(p, s))
              ],
            ));
  }
}

class ProviderSnippet extends StatelessWidget {
  final ProviderModel provider;
  final ProviderSeries? selectedSeries;
  final bool selected;
  final Function(ProviderModel p, ProviderSeries s) onSelect;

  const ProviderSnippet(
      {super.key,
      required this.provider,
      required this.selected,
      required this.selectedSeries,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final selColor = context.theme.color.resolve(
      kind: ColorKinds.accent,
      manner: selected ? ColorManners.minor : ColorManners.plain,
    );

    return GestureDetector(
      onTap: () => selected ? null : onSelect(provider, provider.series.first),
      child: Card(
          kind: ColorKinds.accent,
          manner: selected ? ColorManners.minor : ColorManners.plain,
          border: Border(opacity: selected ? 1 : .3),
          padding: const RemInsets.all(1),
          color: selColor.back.withAlpha(70),
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
