import 'package:elbe/elbe.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/m_image.dart';
import '../util/wad_button.dart';

class CurrentImage extends StatelessWidget {
  final ImageModel model;
  const CurrentImage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      gap: 1,
      cross: CrossAxisAlignment.stretch,
      children: [
        /*FutureBuilder(
            future: getImgLuminance(model.file.path),
            builder: (_, luminance) =>
                Card(child: Text(luminance.data.toString()))),*/
        ClipRRect(
          borderRadius: BorderRadius.circular(
              context.rem(context.theme.geometry.borderRadius)),
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
          WADButton.text(
            icon: ApfelIcons.link,
            label: "learn more",
            tooltip: "learn more about this image",
            onTap: () => launchUrlString(model.link ?? "https://bing.com"),
          ),
      ],
    );
  }
}
