import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../app_scope.dart';
import '../../core/prayer/compass.dart';
import '../../core/prayer/prayer_times.dart';
import '../../l10n/app_localizations.dart';

/// A compass arrow towards the Qibla, from the phone's sensors and the saved
/// place. Works offline. Without a compass sensor it still shows the bearing.
class QiblaTab extends StatefulWidget {
  const QiblaTab({super.key});

  @override
  State<QiblaTab> createState() => _QiblaTabState();
}

class _QiblaTabState extends State<QiblaTab> {
  final List<StreamSubscription<Object?>> _subs = [];
  Timer? _wait;
  Vec? _accel, _mag;
  double? _heading;
  bool _noSensor = false;

  static const _alpha = 0.2; // low-pass: 1 = no smoothing

  Vec _smooth(Vec? old, Vec v) => old == null
      ? v
      : (old.$1 + _alpha * (v.$1 - old.$1), old.$2 + _alpha * (v.$2 - old.$2), old.$3 + _alpha * (v.$3 - old.$3));

  void _fail() {
    if (mounted) setState(() => _noSensor = true);
  }

  @override
  void initState() {
    super.initState();
    try {
      _subs.add(accelerometerEventStream().listen((e) => _accel = _smooth(_accel, (e.x, e.y, e.z)), onError: (_) => _fail()));
      _subs.add(magnetometerEventStream().listen((e) {
        _mag = _smooth(_mag, (e.x, e.y, e.z));
        final a = _accel;
        if (a == null || !mounted) return;
        setState(() => _heading = headingDegrees(a, _mag!));
      }, onError: (_) => _fail()));
    } catch (_) {
      _noSensor = true;
    }
    // No reading after a few seconds: this phone has no compass sensor.
    _wait = Timer(const Duration(seconds: 3), () {
      if (mounted && _heading == null) setState(() => _noSensor = true);
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final place = AppScope.of(context).settings.place;
    if (place == null) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(t.qiblaNeedsPlace, textAlign: TextAlign.center)));
    }
    final bearing = qiblaBearing(place);
    final heading = _noSensor ? null : _heading;
    final angle = heading == null ? 0.0 : arrowAngle(heading: heading, bearing: bearing);
    final facing = heading != null && (angle < 3 || angle > 357);
    final mag = _mag;
    final color = facing ? Colors.green : theme.colorScheme.primary;
    return ListView(padding: const EdgeInsets.all(24), children: [
      Text(t.qiblaBearing(bearing.round().toString()), textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
      const SizedBox(height: 24),
      if (heading != null)
        Semantics(
          label: t.qiblaBearing(bearing.round().toString()),
          child: Center(
            child: Transform.rotate(angle: angle * math.pi / 180, child: Icon(Icons.navigation_rounded, size: 200, color: color)),
          ),
        ),
      const SizedBox(height: 16),
      if (facing) Text(t.qiblaFacing, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: color)),
      if (_noSensor) Text(t.qiblaNoSensor, textAlign: TextAlign.center),
      if (!_noSensor && heading == null) const Center(child: CircularProgressIndicator()),
      if (!_noSensor && mag != null && fieldNeedsCalibration(mag))
        Padding(padding: const EdgeInsets.only(top: 12), child: Text(t.qiblaCalibrate, textAlign: TextAlign.center)),
      if (!_noSensor) Padding(padding: const EdgeInsets.only(top: 12), child: Text(t.qiblaHold, textAlign: TextAlign.center)),
    ]);
  }
}
