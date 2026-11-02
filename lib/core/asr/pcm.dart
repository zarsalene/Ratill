import 'dart:math' as math;
import 'dart:typed_data';

/// Converts little-endian 16-bit PCM bytes from the mic to samples in [-1, 1].
/// An odd trailing byte is ignored.
Float32List pcm16ToFloat(Uint8List bytes) {
  final n = bytes.length ~/ 2;
  final data = ByteData.sublistView(bytes, 0, n * 2);
  final out = Float32List(n);
  for (var i = 0; i < n; i++) {
    out[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
  }
  return out;
}

/// Root-mean-square level of [samples] in dBFS (0 is full scale).
double rmsDbfs(Float32List samples) {
  if (samples.isEmpty) return -120;
  var sum = 0.0;
  for (final s in samples) {
    sum += s * s;
  }
  final rms = math.sqrt(sum / samples.length);
  return rms <= 1e-6 ? -120 : 20 * math.log(rms) / math.ln10;
}

/// Tracks the background noise level from audio the VAD marks as silence, and
/// the speech level from audio it marks as speech.
///
/// The teacher must not judge a recitation it cannot hear well, so [isNoisy]
/// is true when the background is loud or speech is not clearly above it.
/// The limits are loose on purpose: a quiet room must not trigger the warning
/// (the mic's auto gain raises the floor). The values need a check on a real
/// phone; tool/eval can tune them.
class NoiseMeter {
  NoiseMeter({this.maxNoiseDbfs = -30, this.minSnrDb = 8, this.smoothing = 0.1, this.minNoisyMs = 3000});

  final double maxNoiseDbfs;
  final double minSnrDb;

  /// Weight of each new frame in the running averages.
  final double smoothing;

  /// How long the audio must stay bad, without a break, before [isNoisy].
  final int minNoisyMs;

  double? _noise;
  double? _speech;
  int _badMs = 0;

  double? get noiseDbfs => _noise;
  double? get speechDbfs => _speech;

  /// Adds one frame of 16 kHz audio.
  void add(Float32List frame, {required bool speech}) {
    final level = rmsDbfs(frame);
    if (speech) {
      _speech = _speech == null ? level : _speech! + smoothing * (level - _speech!);
    } else {
      _noise = _noise == null ? level : _noise! + smoothing * (level - _noise!);
    }
    _badMs = _isBad ? _badMs + frame.length * 1000 ~/ 16000 : 0;
  }

  bool get _isBad {
    final noise = _noise;
    if (noise == null) return false;
    if (noise > maxNoiseDbfs) return true;
    final speech = _speech;
    return speech != null && speech - noise < minSnrDb;
  }

  bool get isNoisy => _badMs >= minNoisyMs;

  void reset() {
    _noise = null;
    _speech = null;
    _badMs = 0;
  }
}
