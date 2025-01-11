import 'package:elbe/elbe.dart';
import 'package:http/http.dart' as http;

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
