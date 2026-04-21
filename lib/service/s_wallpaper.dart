import 'dart:io';

import 's_native.dart';

class WallpaperService {
  static final WallpaperService i = WallpaperService._();

  WallpaperService._();

  Future<void> set(File? file) async {
    if (file == null || !await file.exists()) return;
    NativeService.i.setWallpaper(file);
  }
}
