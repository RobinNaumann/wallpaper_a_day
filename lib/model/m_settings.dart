import 'package:elbe/elbe.dart';

import '../providers/providers.dart';
import 'm_provider.dart';

enum ImgDarkness {
  all,
  light,
  dark,
  veryDark;

  const ImgDarkness();

  factory ImgDarkness.parse(String str) {
    return ImgDarkness.values.firstWhereOrNull((e) => e.name == str) ??
        ImgDarkness.all;
  }
}

class Settings extends JsonModel {
  final ProviderModel provider;
  final ProviderSeries series;
  final String? imgId;
  final ImgDarkness imgDarkness;

  const Settings(
      {required this.provider,
      required this.series,
      this.imgId,
      this.imgDarkness = ImgDarkness.all});

  factory Settings.fromMap(JsonMap map) {
    final prov = providers.firstWhere((e) => e.id == map.asCast('provider'));
    return Settings(
        provider: prov,
        series: prov.series.firstWhere((e) => e.id == map.asCast('series')),
        imgId: map.maybeCast('img_id'),
        imgDarkness: ImgDarkness.parse(map.asCast('img_darkness')));
  }

  Settings copyWith(
          {ProviderModel? provider,
          ProviderSeries? series,
          Opt<String> imgId,
          ImgDarkness? imgDarkness}) =>
      Settings(
          provider: provider ?? this.provider,
          series: series ?? this.series,
          imgId: optEval(imgId, this.imgId),
          imgDarkness: imgDarkness ?? this.imgDarkness);

  @override
  get map => {
        'provider': provider.id,
        'series': series.id,
        'img_id': imgId,
        'img_darkness': imgDarkness.name
      };
}
