import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/sound/sfx.dart';

void main() {
  var enabled = true;
  var now = DateTime(2026, 11, 1, 9);
  final played = <String>[];
  late Sfx sfx;
  setUp(() {
    enabled = true;
    now = DateTime(2026, 11, 1, 9);
    played.clear();
    sfx = Sfx(enabled: () => enabled, player: (asset) async => played.add(asset), clock: () => now);
  });

  test('each effect plays its own small file', () async {
    for (final k in SfxKind.values) {
      await sfx.play(k);
    }
    expect(played, ['assets/sfx/tap.wav', 'assets/sfx/right.wav', 'assets/sfx/wrong.wav', 'assets/sfx/chime.wav']);
  });

  test('one switch mutes all effects', () async {
    enabled = false;
    for (final k in SfxKind.values) {
      await sfx.play(k);
    }
    expect(played, isEmpty);
  });

  test('the "right" tone is not repeated faster than every 300 ms', () async {
    await sfx.play(SfxKind.right);
    now = now.add(const Duration(milliseconds: 100));
    await sfx.play(SfxKind.right);
    expect(played, hasLength(1));
    now = now.add(const Duration(milliseconds: 250));
    await sfx.play(SfxKind.right);
    expect(played, hasLength(2));
  });

  test('a sound that fails to play never throws', () async {
    final broken = Sfx(enabled: () => true, player: (_) async => throw StateError('no audio device'));
    await broken.play(SfxKind.tap);
  });

  test('every effect file exists and is small', () {
    for (final k in SfxKind.values) {
      final f = File(k.asset);
      expect(f.existsSync(), isTrue, reason: k.asset);
      expect(f.lengthSync(), lessThan(40 * 1024), reason: k.asset);
    }
  });
}
