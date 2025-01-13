import 'dart:convert';
import 'dart:io';

import 'package:wallpaper_a_day/model/m_image.dart';
import 'package:wallpaper_a_day/model/m_provider.dart';
import 'package:wallpaper_a_day/model/m_settings.dart';

import '../providers/providers.dart';

const String baseDir = 'wallpaper_a_day';
const String settingsFile = '$baseDir/settings.json';

class StorageService {
  static const StorageService i = StorageService._();

  const StorageService._();

  Future<Settings> loadSettings() async {
    try {
      final file = File(settingsFile);
      if (!await file.exists()) await file.writeAsString('{}');
      final map = json.decode(await file.readAsString());
      return Settings.fromMap(map);
    } catch (e) {
      return Settings(
        provider: providers.first,
        series: providers.first.series.first,
      );
    }
  }

  Future<void> saveSettings(Settings settings) async {
    final file = File(settingsFile);
    await file.writeAsString(json.encode(settings.map));
  }

  Future<void> save(ImageModel img) async {
    final index = await _index(img.provider, img.series);
    final dir = index.parent.path;

    // fetch the image from the URL
    final url = img.url;
    final response = await HttpClient().getUrl(Uri.parse(url));
    final imageFile = await response.close();
    final file = img.file;
    await imageFile.pipe(file.openWrite());

    await _addToIndex(index, img);
  }

  Future<List<ImageModel>> list(String provider, String series) async {
    return await _loadIndex(await _index(provider, series));
  }

  Future<void> refresh(ProviderModel provider, String series) async {
    final List<ImageModel> existing = await list(provider.id, series);
    final ImageModel latest = await provider.fetch(provider, series);

    if (existing.isEmpty || existing.last.id != latest.id) {
      await save(latest);
      print("Saved new image: ${latest.id}");
    }
  }

  Future<void> deleteAll([String? provider, String? series]) async {
    final dir = Directory(provider == null
        ? baseDir
        : series == null
            ? '$baseDir/$provider'
            : '$baseDir/$provider/$series');
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  // ================== internals ==================

  Future<List<ImageModel>> _loadIndex(File index) async {
    List f = json.decode(await (index).readAsString());
    return f.map((m) => ImageModel.fromMap(m)).toList();
  }

  Future<File> _index(String provider, String series) async {
    final dir = Directory('$baseDir/$provider/$series');
    if (!await dir.exists()) await dir.create(recursive: true);

    final file = File('${dir.path}/index.json');
    if (!await file.exists()) await file.writeAsString('[]');

    return file;
  }

  Future<void> _addToIndex(File index, ImageModel img) async {
    List<ImageModel> imgs = await _loadIndex(index);
    index.writeAsString(json.encode([...imgs, img].map((i) => i.map).toList()));
  }
}
