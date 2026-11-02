import 'dart:async';

import 'package:just_audio/just_audio.dart';

enum SfxKind {
  tap('assets/sfx/tap.wav'),
  right('assets/sfx/right.wav'),
  wrong('assets/sfx/wrong.wav'),
  chime('assets/sfx/chime.wav');

  const SfxKind(this.asset);
  final String asset;
}

/// Soft sound effects (made by tool/make_sounds.py, no outside license). One
/// switch mutes all of them. A sound that cannot play is ignored: a sound is
/// never worth a crash.
class Sfx {
  Sfx({required bool Function() enabled, Future<void> Function(String asset)? player, DateTime Function()? clock})
      : _enabled = enabled,
        _play = player ?? _justAudio,
        _clock = clock ?? DateTime.now;

  final bool Function() _enabled;
  final Future<void> Function(String asset) _play;
  final DateTime Function() _clock;
  DateTime? _lastRight;

  static final Map<String, Future<AudioPlayer>> _players = {};

  static Future<AudioPlayer> _open(String asset) async {
    final p = AudioPlayer(handleAudioSessionActivation: false);
    await p.setAsset(asset);
    return p;
  }

  /// One player per file. It does not take the audio focus, so a recitation
  /// that is playing goes on. A player that failed to load is dropped, so the
  /// next call tries again.
  static Future<void> _justAudio(String asset) async {
    final loading = _players[asset] ??= _open(asset);
    final AudioPlayer p;
    try {
      p = await loading;
    } catch (_) {
      _players.remove(asset);
      rethrow;
    }
    await p.seek(Duration.zero);
    unawaited(p.play());
  }

  Future<void> play(SfxKind kind) async {
    if (!_enabled()) return;
    if (kind == SfxKind.right) {
      final now = _clock();
      final last = _lastRight;
      if (last != null && now.difference(last).inMilliseconds < 300) return;
      _lastRight = now;
    }
    try {
      await _play(kind.asset);
    } catch (_) {
      // No audio device, or the file did not load.
    }
  }
}
