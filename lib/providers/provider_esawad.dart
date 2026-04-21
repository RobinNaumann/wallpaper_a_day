import 'dart:convert';

import 'package:elbe/elbe.dart';
import 'package:moewe/moewe.dart' hide JsonMap;

import '../model/m_image.dart';
import '../model/m_provider.dart';
import '../util/util.dart';

ESAHost() =>
    moewe.config.flagString("host_img") ?? "http://earth.robin.go.esa.int";

final ProviderModel esawadProvider = ProviderModel(
    id: "esawad",
    label: "ESA Daily Earth Wallpaper",
    description:
        "satellite images from the European Space Agency. Only works within ESA",
    series: [ProviderSeries("en", "English")],
    fetch: (self, series) async {
      final host = ESAHost();
      JsonMap d = json.decode(await fetch("$host/api/selection"));

      final String file = d.asCast("filepath");
      final type = file.split(".").lastOrNull ?? "jpg";
      final author = d["_EXPANDED"]?["author"]?["name"];
      return ImageModel(
        id: d.asCast("id"),
        date: DateTime.now().asUnixMs,
        provider: self.id,
        series: series,
        url: "$host$file",
        fileType: type,
        title: d.maybeCast("description"),
        link: host,
        copyright: author != null ? "suggested by: $author" : null,
        copyrightLink: host,
      );
    });
