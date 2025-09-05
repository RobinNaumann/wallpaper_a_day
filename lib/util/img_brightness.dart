import "package:elbe/elbe.dart";
import "package:image/image.dart" as img;

class ImgLuminance {
  final double top;
  final double full;
  ImgLuminance(this.top, this.full);
}

/// MacOS only looks at the top of the image to determine brightness
/// so, this function will only determine the average brightness of the
/// top [topFrac]% of the image as an approximation
Future<ImgLuminance> getImgLuminance(String filePath,
    [double topFrac = 1]) async {
  final cmd = await img.Command()
    ..decodeImageFile(filePath)
    ..copyResize(width: 50, maintainAspect: true);

  final image = (await cmd.executeThread()).outputImage!;
  // calculate offset on how much to crop at top/bottom for 16:10 aspect ratio
  final aspectRatio = 16 / 10;
  final visHeight = (image.width / aspectRatio).round();
  final yCrop = (image.height - visHeight) ~/ 2;
  // only look at the top [top]% of the image for brightness

  final yMin = Math.max(0, yCrop);
  final yMax = Math.min(yCrop + visHeight, image.height);
  final pixelCount = image.width * (yMax - yMin);
  final int yTopMax =
      Math.min(yCrop + (visHeight * topFrac).round(), image.height);
  final pixelTopCount = image.width * (yTopMax - yMin);

  // calculate full image brightness
  double topBrightness = 0;
  double fullBrightness = 0;
  for (int y = yMin; y < yMax; y++) {
    for (int x = 0; x < image.width; x++) {
      final lum = image.getPixel(x, y).luminanceNormalized;
      fullBrightness += lum;
      topBrightness += (y < yTopMax) ? lum : 0;
    }
  }

  return ImgLuminance(
    topBrightness / Math.max(1, pixelTopCount),
    fullBrightness / Math.max(1, pixelCount),
  );
}
