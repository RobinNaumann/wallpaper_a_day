import 'dart:async';
import 'dart:math';

import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:wallpaper_a_day/model/m_provider.dart';

class _NextRefresh {
  final UnixMs time;
  final int failCount;

  _NextRefresh(this.time, this.failCount);
}

class RefreshScheduler {
  static final JsonMap<_NextRefresh> _next = {};
  static RefreshScheduler? _instance;

  final ProviderModel provider;
  final String series;
  final Future Function() worker;
  late final Timer _timer;
  RefreshScheduler({
    required this.provider,
    required this.series,
    required this.worker,
    Duration interval = const Duration(minutes: 4),
  }) {
    _instance?.dispose();
    _instance = this;
    _timer = Timer.periodic(interval, (_) {
      if ((_next[_key]?.time ?? 0) > DateTime.now().asUnixMs) force();
    });
  }

  String get _key => '${provider.id}.$series';

  Future<void> force() async {
    final next = _next[_key];
    final now = DateTime.now().asUnixMs;
    final tomorrow = _tomorrow();
    try {
      await worker();
      _next[_key] = _NextRefresh(tomorrow, 0);
    } catch (e) {
      final nextFail = (next?.failCount ?? 0) + 1;
      _next[_key] = _NextRefresh(
          Math.min(tomorrow, now + 1000 * 60 * 2 * nextFail), nextFail);
      throw ElbeError("REF_01", "could not refresh", cause: e);
    }
  }

  void dispose() {
    _timer.cancel();
  }

  int _tomorrow() {
    final rdmDelay = Random().nextInt(2 * 60) + 60;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 0, rdmDelay);
    return tomorrow.asUnixMs;
  }
}
