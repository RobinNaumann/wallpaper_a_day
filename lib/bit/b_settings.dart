import 'package:elbe/elbe.dart';
import 'package:wallpaper_a_day/service/s_storage.dart';

import '../model/m_provider.dart';
import '../model/m_settings.dart';

class SettingsBit extends MapMsgBitControl<Settings> {
  static const builder = MapMsgBitBuilder<Settings, SettingsBit>.make;

  SettingsBit() : super.worker((_) async => StorageService.i.loadSettings());

  void setProvider(ProviderModel provider, ProviderSeries series) => act((s) {
        final n = s.copyWith(
          provider: provider,
          series: series,
          imgId: () => null,
        );
        StorageService.i.saveSettings(n);
        return n;
      });

  void deleteConfig() => state.whenOrNull(onData: (d) async {
        await StorageService.i.deleteAll(d.provider.id, d.series.id);
        reload();
      });

  void preserveId(String? imgId) => state.whenOrNull(
        onData: (d) =>
            StorageService.i.saveSettings(d.copyWith(imgId: () => imgId)),
      );
}
