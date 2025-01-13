import 'dart:async';
import 'dart:math';

import 'package:elbe/elbe.dart';
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
    _timer = Timer.periodic(interval, (_) => _refresh());
    _refresh();
  }

  void _refresh() {
    if ((_next[_key]?.time ?? UnixMs.zero) < UnixMs.now) force();
  }

  String get _key => '${provider.id}.$series';

  Future<void> force() async {
    final now = UnixMs.now;
    final tomorrow = _tomorrow();
    try {
      await worker();
      _next[_key] = _NextRefresh(tomorrow, 0);
    } catch (e) {
      final nextFail = (_next[_key]?.failCount ?? 0) + 1;
      _next[_key] = _NextRefresh(
          Math.min(tomorrow, UnixMs(now + 1000 * 60 * 2 * nextFail)), nextFail);
      throw ElbeError("REF_01", "could not refresh", cause: e);
    }
  }

  void dispose() {
    _timer.cancel();
  }

  UnixMs _tomorrow() {
    final rdmDelay = Random().nextInt(2 * 60) + 60;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 0, rdmDelay);
    return tomorrow.asUnixMs;
  }
}
