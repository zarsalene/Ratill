import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/quran/translation.dart';

/// The translations are Tanzil files, pinned in data/CHECKSUMS, shown verbatim.
void main() {
  final meta = File('data/raw/tanzil/quran-data.xml').readAsStringSync();
  final ayas = {
    for (final m in RegExp(r'<sura index="(\d+)" ayas="(\d+)"').allMatches(meta)) int.parse(m.group(1)!): int.parse(m.group(2)!),
  };

  for (final tr in Translation.values) {
    group(tr.name, () {
      final raw = File(tr.asset).readAsStringSync();
      final text = parseTanzilTranslation(raw);

      test('has every ayah of the Quran text: 114 surahs, 6236 ayahs', () {
        var total = 0;
        for (var s = 1; s <= 114; s++) {
          expect(text.ayahCount(s), ayas[s], reason: 'surah $s');
          total += text.ayahCount(s);
        }
        expect(total, 6236);
      });

      test('every line of the source is shown unchanged', () {
        var seen = 0;
        for (final line in raw.split('\n')) {
          final m = RegExp(r'^(\d+)\|(\d+)\|(.*)$').firstMatch(line.trimRight());
          if (m == null) continue;
          expect(text.of(int.parse(m.group(1)!), int.parse(m.group(2)!)), m.group(3), reason: line);
          seen++;
        }
        expect(seen, 6236);
      });
    });
  }

  test('the credit of each translation names the translator and Tanzil', () {
    expect(Translation.en.translator, 'Saheeh International');
    expect(Translation.fr.translator, 'Muhammad Hamidullah');
    expect(Translation.values.every((t) => t.source == 'Tanzil.net'), isTrue);
  });

  test('a source with a missing or out-of-order ayah is rejected', () {
    expect(() => parseTanzilTranslation('1|1|a\n1|3|c\n'), throwsFormatException);
    expect(() => parseTanzilTranslation('2|1|a\n'), throwsFormatException);
    expect(() => parseTanzilTranslation('1|1|a\n'), throwsFormatException, reason: 'not 114 surahs');
  });
}
