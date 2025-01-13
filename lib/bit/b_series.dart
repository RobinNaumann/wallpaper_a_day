import 'dart:async';
import 'dart:math';

import 'package:elbe/elbe.dart';
import 'package:moewe/moewe.dart';
import 'package:wallpaper_a_day/bit/b_settings.dart';
import 'package:wallpaper_a_day/model/m_image.dart';
import 'package:wallpaper_a_day/model/m_provider.dart';
import 'package:wallpaper_a_day/service/s_refresh.dart';
import 'package:wallpaper_a_day/service/s_storage.dart';
import 'package:wallpaper_a_day/service/s_wallpaper.dart';

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
    _wallTimer = Timer.periodic(const Duration(seconds: 1), (_) => _set());

    _scheduler = RefreshScheduler(
      provider: provider,
      series: series.id,
      worker: () async {
        _logLoading(provider.id, series.id);
        await StorageService.i.refresh(provider, series.id);
        reload();
      },
    );
  }

  void _set() =>
      state.whenOrNull(onData: (d) => WallpaperService.i.set(d.current?.file));

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
    _scheduler.dispose();
    super.dispose();
  }
}

Future<void> _logLoading(String provider, String series) async {
  await Future.delayed(Duration(milliseconds: Random().nextInt(60 * 1000)));
  moewe.event("fetching", data: {"provider": provider, "series": series});
}

String _day(UnixMs d) {
  final date = DateTime.fromMillisecondsSinceEpoch(d);
  return "${date.year}-${date.month}-${date.day}";
}
