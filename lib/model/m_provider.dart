import 'package:elbe/util/m_data.dart';

import 'm_image.dart';

class ProviderSeries {
  final String id;
  final String label;
  ProviderSeries(this.id, [String? label]) : label = label ?? id;
}

class ProviderModel extends JsonModel {
  final String id;
  final String label;
  final String description;
  final List<ProviderSeries> series;
  final Future<ImageModel> Function(ProviderModel provider, String series)
      fetch;

  const ProviderModel({
    required this.id,
    required this.label,
    required this.description,
    required this.series,
    required this.fetch,
  });

  get map => {
        'id': id,
        'label': label,
        'description': description,
        'series': series.map((e) => e.id).toList(),
      };
}
