import 'package:elbe/elbe.dart';
import 'package:html/parser.dart';
import 'package:wallpaper_a_day/model/m_image.dart';
import 'package:wallpaper_a_day/model/m_provider.dart';
import 'package:wallpaper_a_day/util/util.dart';

final _baseUrl = "https://apod.nasa.gov/apod/";

final ProviderModel apodProvider = ProviderModel(
    id: "apod",
    label: "NASA APOD",
    description: "NASA's Astronomy Picture of the Day",
    series: [
      ProviderSeries("en", "English"),
    ],
    fetch: (self, series) async {
      final body = parse(await fetch(_baseUrl)).body!;
      final img = body.querySelector("body img");
      final src = img!.attributes["src"]!;

      // title is the second <center> tag
      final title = body.querySelectorAll("center")[1].text.trim();

      return ImageModel(
          id: src.replaceMulti(["/", ".", " ", ":", "\\"], "-"),
          date: DateTime.now().asUnixMs,
          provider: self.id,
          series: series,
          url: _baseUrl + src,
          link: _baseUrl,
          title: title.split("\n").first,
          copyright: title
              .substring(title.indexOf("\n") + 1)
              .replaceAll("\n", " ")
              .trim(),
          fileType: src.split(".").last);
    });
