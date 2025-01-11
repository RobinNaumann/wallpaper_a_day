import 'dart:io';

import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:wallpaper_a_day/service/s_storage.dart';

class ImageModel extends JsonModel {
  final String id;
  final UnixMs date;
  final String provider;
  final String series;
  final String url;
  final String fileType;
  final String? title;
  final String? link;

  final String? copyright;
  final String? copyrightLink;

  File get file => File('$baseDir/$provider/$series/$id.$fileType');

  const ImageModel({
    required this.id,
    required this.date,
    required this.provider,
    required this.series,
    required this.url,
    required this.fileType,
    this.title,
    this.link,
    this.copyrightLink,
    this.copyright,
  });

  factory ImageModel.fromMap(JsonMap map) => ImageModel(
        id: map.asCast('id'),
        date: map.asCast('date'),
        provider: map.asCast('provider'),
        series: map.asCast('series'),
        fileType: map.asCast('file_type'),
        url: map.asCast('url'),
        title: map.maybeCast('title'),
        link: map.maybeCast('link'),
        copyright: map.maybeCast('copyright'),
        copyrightLink: map.maybeCast('copyright_link'),
      );

  @override
  get map => {
        'id': id,
        'date': date,
        'provider': provider,
        'series': series,
        'file_type': fileType,
        'url': url,
        'title': title,
        'link': link,
        'copyright': copyright,
        'copyright_link': copyrightLink,
      };
}
