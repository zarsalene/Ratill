import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/quran/riwaya.dart';
import 'package:rattil/core/quran/translation.dart';
import 'package:rattil/core/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads the asset paths straight from the project folder.
class _FileBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final b = File(key).readAsBytesSync();
    return ByteData.sublistView(Uint8List.fromList(b));
  }
}

void main() {
  late Settings settings;
  Future<void> setUpWith(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    settings = Settings(await SharedPreferences.getInstance());
  }

  Future<TranslationStore> store() async {
    final s = TranslationStore(settings, bundle: _FileBundle());
    for (var i = 0; i < 50 && settings.translation != null && s.of(1, 1) == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return s;
  }

  test('English when chosen', () async {
    await setUpWith({'translation': 'en'});
    final s = await store();
    expect(s.of(1, 1), 'In the name of Allah, the Entirely Merciful, the Especially Merciful.');
    expect(s.of(1, 2), '[All] praise is [due] to Allah, Lord of the worlds -');
  });

  test('French when chosen', () async {
    await setUpWith({'translation': 'fr'});
    final s = await store();
    expect(s.of(1, 1), 'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux.');
  });

  test('nothing when turned off', () async {
    await setUpWith({'translation': 'off'});
    expect((await store()).of(1, 1), isNull);
  });

  test('nothing for a riwaya other than Hafs (the ayah numbers differ)', () async {
    await setUpWith({'translation': 'en', 'riwaya': 'warsh'});
    expect(settings.riwaya, Riwaya.warsh);
    expect((await store()).of(1, 2), isNull);
  });

  test('changing the choice loads the other translation and tells the listeners', () async {
    await setUpWith({'translation': 'en'});
    final s = await store();
    var told = 0;
    s.addListener(() => told++);
    settings.translation = Translation.fr;
    for (var i = 0; i < 50 && told == 0; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(told, greaterThan(0));
    expect(s.of(1, 1), startsWith('Au nom d'));
  });
}
