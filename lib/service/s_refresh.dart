import 'dart:async';
import 'dart:math';

import 'package:elbe/elbe.dart';
import 'package:moewe/moewe.dart' hide JsonMap;

import '../model/m_provider.dart';

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
  final Duration interval;
  late final Timer _timer;

  RefreshScheduler({
    required this.provider,
    required this.series,
    required this.worker,
    this.interval = const Duration(minutes: 4),
  }) {
    _instance?.dispose();
    _instance = this;
    _timer = Timer.periodic(interval, (_) {_refresh();});
    _refresh();
  }

  void _refresh() async {
    try {
    if ((_next[_key]?.time ?? UnixMs.zero) < UnixMs.now) await force();
    } catch (e) {
      log.w(this, "error during scheduled refresh: $e");
    }
  }

  String get _key => '${provider.id}.$series';

  Future<void> force() async {
    final now = UnixMs.now;
    final tomorrow = _tomorrow();
    try {
      await worker();
      _next[_key] = _NextRefresh(tomorrow, 0);
    } catch (e) {
      final int nextFail = (_next[_key]?.failCount ?? 0) + 1;
      _next[_key] = _NextRefresh(
          UnixMs(Math.min(
            now + interval.inMilliseconds - 100 // a bit of buffer for execution
            ,now + 1000 * 60 * 2 * nextFail)), nextFail);
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
