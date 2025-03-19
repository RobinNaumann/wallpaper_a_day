import 'package:elbe/elbe.dart';
import 'package:wallpaper_a_day/service/s_native.dart';

class AutostartBit extends MapMsgBitControl<bool?> {
  static const builder = MapMsgBitBuilder<bool?, AutostartBit>.make;

  AutostartBit() : super.worker((_) async => NativeService.i.getAutostart());

  void toggle() => act((s) {
        final onLogin = !(s ?? false);
        NativeService.i.setAutostart(onLogin);
        return onLogin;
      });
}
