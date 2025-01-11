import 'dart:io';

import 'package:flutter/services.dart';

class WallpaperService {
  static const MethodChannel _channel = MethodChannel('in.robbb.wad');

  static final WallpaperService i = WallpaperService._();

  WallpaperService._();

  Future<void> set(File? file) async {
    if (file == null || !await file.exists()) return;

    try {
      await _channel.invokeMethod('setWallpaper', {'path': file.absolute.path});
    } on PlatformException catch (e) {
      print("Failed to set wallpaper: '${e.message}'.");
    }
  }
}
