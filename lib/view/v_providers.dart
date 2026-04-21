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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in providers)
                  ProviderSnippet(
                      provider: p,
                      selected: settings.provider.id == p.id,
                      selectedSeries:
                          settings.provider.id == p.id ? settings.series : null,
                      onSelect: (p, s) => bit.setProvider(p, s))
              ].spaced(),
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
    final flat = context.theme.color.activeKinds.flat;
    final pressedC = flat.active.back;

    final accent = ColorTheme.of(context).activeSchemes.accent.back;
    return GestureDetector(
      onTap: () => selected ? null : onSelect(provider, provider.series.first),
      child: Container(
          decoration: BoxDecoration(
            border: WBorder.all(color: selected ? accent : pressedC, width: 2),
            borderRadius: GeometryTheme.of(context).border.borderRadius,
            color: selected ? accent.withOpacity(.125) : Colors.transparent,
          ),
          padding: const RemInsets.all(1).toPixel(context),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      provider.label,
                      variant: TypeVariants.bold,
                    ),
                    Spaced.vertical(.5),
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
                                      child: Text(s.label), value: s)
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
                color: selected ? accent : pressedC,
              )
            ].spaced(),
          )),
    );
  }
}
