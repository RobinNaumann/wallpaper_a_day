import 'dart:math';

import 'package:elbe/elbe.dart';
import 'package:http/http.dart' as http;
import 'package:wad/service/s_native.dart';

Future<String> fetch(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw ElbeError.http(response.statusCode, details: response.body);
  }
}

/// Extracts the file type from a URL.
String fileType(String url) {
  final parts = Uri.parse(url).path.split('/').last.split('.');
  return parts.last;
}

extension ReplaceString on String {
  String replaceMulti(List<String> from, String to) {
    var result = this;
    for (final f in from) {
      result = result.replaceAll(f, to);
    }
    return result;
  }
}

extension WithTranslucency on Color {
  /// Returns a copy of this color with the given translucency applied.
  /// Only applies translucency when the platform supports it (e.g. macOS).
  Color withTranslucency(double amount) => NativeService.i.config.translucent
      ? this.withAlpha((255 * amount).toInt())
      : this;
}

String uniqueId() {
  const String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  String randomId = "";
  for (int i = 0; i < 16; i++) {
    randomId += chars.split("")[Random().nextInt(chars.length)];
  }
  return randomId;
}
