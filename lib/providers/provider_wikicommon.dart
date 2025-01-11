import 'package:elbe/elbe.dart';
import 'package:html/parser.dart';
import 'package:wallpaper_a_day/model/m_image.dart';
import 'package:wallpaper_a_day/model/m_provider.dart';
import 'package:wallpaper_a_day/util/util.dart';

const _baseUrl = "https://commons.wikimedia.org";
const _queryUrl =
    "$_baseUrl/w/api.php?action=featuredfeed&feed=potd&feedformat=atom&language=";

final ProviderModel wikiCommonsProvider = ProviderModel(
    id: "wiki_commons",
    label: "Wikimedia",
    description: "Wikimedia Commons picture of the day",
    series: [
      ProviderSeries("en", "English"),
      ProviderSeries("ar", "Arabic"),
      ProviderSeries("zh", "Chinese"),
      ProviderSeries("nl", "Dutch"),
      ProviderSeries("fr", "French"),
      ProviderSeries("de", "German"),
      ProviderSeries("it", "Italian"),
      ProviderSeries("ja", "Japanese"),
      ProviderSeries("pl", "Polish"),
      ProviderSeries("pt", "Portuguese"),
      ProviderSeries("ru", "Russian"),
      ProviderSeries("es", "Spanish"),
      ProviderSeries("tr", "Turkish"),
      ProviderSeries("uk", "Ukrainian"),
    ],
    fetch: (self, series) async {
      final feed =
          parse((await fetch(_queryUrl + series)).replaceAll("-<", "<"));
      final html = unescapeHtml(feed
          .querySelectorAll("entry")[2] //.last
          .querySelector("summary")!
          .innerHtml);
      final entry = parse('<html><body>$html</body></html>');
      final title = entry.querySelector(".description")!.text.trim();
      final srcRaw = entry.querySelector("img")!.attributes["src"]!.split("/");
      srcRaw.removeAt(srcRaw.length - 1);
      final src = srcRaw.join("/").replaceAll("/thumb/", "/");

      final url =
          entry.querySelector(".mw-file-description")!.attributes["href"]!;

      return ImageModel(
          id: url.hashCode.toString(),
          date: DateTime.now().asUnixMs,
          provider: self.id,
          series: series,
          url: src,
          link: _baseUrl + url,
          title: title,
          fileType: src.split(".").last);
    });

String unescapeHtml(String html) {
  return html
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&nbsp;', ' ');
}
