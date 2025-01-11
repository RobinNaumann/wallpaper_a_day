import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';

import '../providers/providers.dart';
import 'm_provider.dart';

class Settings extends JsonModel {
  final ProviderModel provider;
  final ProviderSeries series;
  final String? imgId;

  const Settings({required this.provider, required this.series, this.imgId});

  factory Settings.fromMap(JsonMap map) {
    final prov = providers.firstWhere((e) => e.id == map.asCast('provider'));
    return Settings(
        provider: prov,
        series: prov.series.firstWhere((e) => e.id == map.asCast('series')),
        imgId: map.maybeCast('img_id'));
  }

  Settings copyWith(
          {ProviderModel? provider,
          ProviderSeries? series,
          Opt<String> imgId}) =>
      Settings(
          provider: provider ?? this.provider,
          series: series ?? this.series,
          imgId: optEval(imgId, this.imgId));

  @override
  get map => {
        'provider': provider.id,
        'series': series.id,
        'img_id': imgId,
      };
}
