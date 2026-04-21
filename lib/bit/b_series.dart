import 'dart:async';

import 'package:elbe/elbe.dart';
import 'package:moewe/moewe.dart';

import '../main.dart';
import '../model/m_image.dart';
import '../model/m_provider.dart';
import '../service/s_refresh.dart';
import '../service/s_storage.dart';
import '../service/s_wallpaper.dart';
import 'b_settings.dart';

class SeriesData extends JsonModel {
  final List<ImageModel> images;
  final int? index;

  ImageModel? get current => index != null ? images[index!] : null;

  SeriesData(this.images, this.index);

  get map => {'images': images, 'index': index};
}

class SeriesBit extends MapMsgBitControl<SeriesData> {
  static const builder = MapMsgBitBuilder<SeriesData, SeriesBit>.make;

  final ProviderModel provider;
  final ProviderSeries series;
  final String? id;

  late Timer _wallTimer;
  late Timer _recoverTimer;
  late RefreshScheduler _scheduler;

  SeriesBit(this.provider, this.series, this.id)
      : super.worker((_) async {
          final list = await StorageService.i.list(provider.id, series.id);
          final index = id == null
              ? (list.length - 1)
              : list.indexWhere((e) => e.id == id);

          return SeriesData(list,
              index == -1 ? (list.isNotEmpty ? list.length - 1 : null) : index);
        }) {
    _set();
    _wallTimer = Timer.periodic(const Duration(seconds: 2), (_) => _set());

    _recoverTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      this.state.whenOrNull(onError: (error) {
        log.w(this, "auto-recovering SeriesBit due to error: $error");
        reload();
      });
    });

    _scheduler = RefreshScheduler(
      provider: provider,
      series: series.id,
      worker: () async {
        moewe.event("fetch", data: {
          "provider": provider.id,
          "series": series.id,
          "session": sessionId
        });
        log.d(
            this, "refreshing series ${series.id} of provider ${provider.id}");
        await StorageService.i.refresh(provider, series.id);
        reload();
      },
    );
  }

  void _set() => state.whenOrNull(onData: (d) async {
        try {
          await WallpaperService.i.set(d.current?.file);
        } catch (e) {
          log.w(this, "error setting wallpaper: $e");
        }
      });

  refresh() => _scheduler.force();

  previous(BuildContext c) => _setOffset(c, -1);
  next(BuildContext c) => _setOffset(c, 1);
  current(BuildContext c) => _setOffset(c, null);

  _setOffset(BuildContext c, int? offset) => act((d) {
        if (d.index == null) return d;
        final index =
            offset == null ? (d.images.length - 1) : (d.index! + offset);
        if (index >= d.images.length || index < 0) return d;

        bool latest = index == d.images.length - 1;
        c.bit<SettingsBit>().preserveId(latest ? null : d.images[index].id);
        final n = SeriesData(d.images, index);
        WallpaperService.i.set(n.current?.file);
        return n;
      });

  @override
  void dispose() {
    _wallTimer.cancel();
    _recoverTimer.cancel();
    _scheduler.dispose();
    super.dispose();
  }
}
