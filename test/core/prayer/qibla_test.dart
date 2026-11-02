import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/prayer/compass.dart';
import 'package:rattil/core/prayer/prayer_times.dart';

void main() {
  // Reference: AlAdhan API (api.aladhan.com/v1/qibla), fetched 2026-11-01.
  test('Qibla bearing: Tunis 112.67, London 118.99 degrees', () {
    expect(qiblaBearing(Place.rounded(36.8065, 10.1815)), closeTo(112.67, 0.3));
    expect(qiblaBearing(Place.rounded(51.5074, -0.1278)), closeTo(118.99, 0.3));
  });

  const g = 9.81;
  double? heading(Vec a, Vec m) => headingDegrees(a, m);

  test('phone flat: heading follows where the top points', () {
    const a = (0.0, 0.0, g);
    expect(heading(a, (0.0, 30.0, -40.0)), closeTo(0, 0.5)); // top to the north
    expect(heading(a, (-30.0, 0.0, -40.0)), closeTo(90, 0.5)); // east
    expect(heading(a, (0.0, -30.0, -40.0)), closeTo(180, 0.5)); // south
    expect(heading(a, (30.0, 0.0, -40.0)), closeTo(270, 0.5)); // west
  });

  test('phone tilted 45 degrees (top raised): heading does not change', () {
    final p = math.pi / 4;
    final a = (0.0, g * math.sin(p), g * math.cos(p));
    final m = (0.0, 30 * math.cos(p) - 40 * math.sin(p), -30 * math.sin(p) - 40 * math.cos(p));
    expect(heading(a, m), closeTo(0, 0.5));
  });

  test('arrow angle: the Qibla relative to where the top points', () {
    expect(arrowAngle(heading: 0, bearing: 110), closeTo(110, 1e-9));
    expect(arrowAngle(heading: 110, bearing: 110), closeTo(0, 1e-9));
    expect(arrowAngle(heading: 350, bearing: 10), closeTo(20, 1e-9));
    expect(arrowAngle(heading: 10, bearing: 350), closeTo(340, 1e-9));
  });

  test('a field outside the Earth range needs calibration', () {
    expect(fieldNeedsCalibration((0.0, 30.0, -40.0)), isFalse); // 50 uT
    expect(fieldNeedsCalibration((0.0, 5.0, -5.0)), isTrue); // 7 uT
    expect(fieldNeedsCalibration((0.0, 90.0, -90.0)), isTrue); // 127 uT: a magnet or metal
  });

  test('no heading when the phone is in free fall (no gravity)', () {
    expect(headingDegrees((0.0, 0.0, 0.0), (0.0, 30.0, -40.0)), isNull);
  });
}
