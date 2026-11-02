import 'dart:math' as math;

/// A sensor reading in the phone's axes: x to the right, y to the top, z out of
/// the screen (the Android convention, also used by sensors_plus).
typedef Vec = (double x, double y, double z);

double _norm(Vec v) => math.sqrt(v.$1 * v.$1 + v.$2 * v.$2 + v.$3 * v.$3);

Vec _cross(Vec a, Vec b) => (a.$2 * b.$3 - a.$3 * b.$2, a.$3 * b.$1 - a.$1 * b.$3, a.$1 * b.$2 - a.$2 * b.$1);

Vec _unit(Vec v) {
  final n = _norm(v);
  return (v.$1 / n, v.$2 / n, v.$3 / n);
}

/// Magnetic heading of the top of the phone, 0 to 360 degrees clockwise from
/// magnetic north, corrected for tilt. [accel] must include gravity.
/// Same maths as Android's SensorManager.getRotationMatrix + getOrientation.
/// Null when there is no usable gravity or field (free fall, no sensor data).
/// This is magnetic north: the difference to true north (declination) is small
/// (a few degrees in most places) and is not corrected.
double? headingDegrees(Vec accel, Vec mag) {
  if (_norm(accel) < 1e-6 || _norm(mag) < 1e-6) return null;
  final h = _cross(mag, accel);
  if (_norm(h) < 1e-6) return null; // field parallel to gravity
  final east = _unit(h);
  final north = _cross(_unit(accel), east);
  final deg = math.atan2(east.$2, north.$2) * 180 / math.pi;
  return (deg + 360) % 360;
}

/// Where to draw the Qibla arrow, clockwise from the top of the phone.
double arrowAngle({required double heading, required double bearing}) => ((bearing - heading) % 360 + 360) % 360;

/// The Earth's field is about 25 to 65 microtesla. Far outside that range the
/// compass cannot be trusted: ask the reader to calibrate it (move the phone in
/// a figure 8) or move away from metal. The 20..80 limits are a rule of thumb.
bool fieldNeedsCalibration(Vec mag) {
  final n = _norm(mag);
  return n < 20 || n > 80;
}
