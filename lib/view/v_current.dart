import 'package:elbe/elbe.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallpaper_a_day/model/m_image.dart';
import 'package:wallpaper_a_day/util/img_brightness.dart';

import '../util/icon_btn.dart';

class CurrentImage extends StatelessWidget {
  final ImageModel model;
  const CurrentImage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder(
            future: getImgLuminance(model.file.path),
            builder: (_, luminance) =>
                Card(child: Text(luminance.data.toString()))),
        ClipRRect(
          borderRadius: GeometryTheme.of(context).border.borderRadius ??
              BorderRadius.zero,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.file(
                model.file,
                fit: BoxFit.cover,
              )),
        ),
        Text.h6(
          model.title ?? "--",
          textAlign: TextAlign.center,
        ),
        if (model.copyright != null)
          Text.bodyM(
            model.copyright ?? "--",
            textAlign: TextAlign.center,
          ),
        if (model.link != null)
          ATextButton(
            icon: ApfelIcons.link,
            label: "learn more",
            onTap: () => launchUrlString(model.link ?? "https://bing.com"),
          ),
      ].spaced(),
    );
  }
}
