import 'dart:convert';

import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:wallpaper_a_day/util/util.dart';

import '../model/m_image.dart';
import '../model/m_provider.dart';

final ProviderModel bingProvider = ProviderModel(
    id: "bing",
    label: "Bing",
    description: "the home page image of bing.com",
    series: [
      /// all the supported Seriess of Bing Wallpaper
      ProviderSeries("en-GB", "United Kingdom"),
      ProviderSeries("ar-SA", "Saudi Arabia"),
      ProviderSeries("cs-CZ", "Czech Republic"),
      ProviderSeries("da-DK", "Denmark"),
      ProviderSeries("de-DE", "Germany"),
      ProviderSeries("en-AU", "Australia"),
      ProviderSeries("en-CA", "Canada"),
      ProviderSeries("en-HK", "Hong Kong"),
      ProviderSeries("en-IE", "Ireland"),
      ProviderSeries("en-IN", "India (English)"),
      ProviderSeries("en-NZ", "New Zealand"),
      ProviderSeries("en-PH", "Philippines"),
      ProviderSeries("en-SG", "Singapore"),
      ProviderSeries("en-US", "United States"),
      ProviderSeries("en-ZA", "South Africa"),
      ProviderSeries("es-ES", "Spain"),
      ProviderSeries("es-MX", "Mexico"),
      ProviderSeries("fi-FI", "Finland"),
      ProviderSeries("fr-CA", "Canada (French)"),
      ProviderSeries("fr-FR", "France"),
      ProviderSeries("he-IL", "Israel"),
      ProviderSeries("hi-IN", "India"),
      ProviderSeries("id-ID", "Indonesia"),
      ProviderSeries("it-IT", "Italy"),
      ProviderSeries("ja-JP", "Japan"),
      ProviderSeries("ko-KR", "Korea"),
      ProviderSeries("ms-MY", "Malaysia"),
      ProviderSeries("nb-NO", "Norway"),
      ProviderSeries("nl-NL", "Netherlands"),
      ProviderSeries("pl-PL", "Poland"),
      ProviderSeries("pt-BR", "Brazil"),
      ProviderSeries("ru-RU", "Russia"),
      ProviderSeries("sv-SE", "Sweden"),
      ProviderSeries("th-TH", "Thailand"),
      ProviderSeries("tr-TR", "Turkey"),
      ProviderSeries("vi-VN", "Vietnam"),
      ProviderSeries("zh-CN", "China"),
      ProviderSeries("zh-TW", "Taiwan")
    ],
    fetch: (self, series) async {
      final url =
          "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=$series";
      JsonMap d = json.decode(await fetch(url))["images"][0];

      final iurl = "https://www.bing.com${d.asCast("url")}";
      final type =
          Uri.parse(iurl).queryParameters["id"]?.split(".").lastOrNull ?? "jpg";
      return ImageModel(
        id: d.asCast("hsh"),
        date: DateTime.now().asUnixMs,
        provider: self.id,
        series: series,
        url: iurl,
        fileType: type,
        title: d.maybeCast("title"),
        link:
            d.maybeCast("copyrightlink"), // "https://www.bing.com${d["quiz"]}",
        copyright:
            d.maybeCast("copyright").toString().replaceFirst("(©", "\n(©"),
        copyrightLink: d.maybeCast("copyrightlink"),
      );
    });
