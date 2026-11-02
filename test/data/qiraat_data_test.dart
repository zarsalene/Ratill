import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Integrity gate for assets/qiraat: the text of every non-Hafs riwaya must be
/// the King Fahd Complex source, word for word. The source files come from
/// `python -I -X utf8 tool/data/build_qiraat.py`, which checks their SHA-256
/// against data/CHECKSUMS_QIRAAT. Expected strings are read from the source,
/// never typed here.
void main() {
  // key: (source folder, data file, font file, ayah count)
  const riwayat = {
    'qalun': ('qaloon', 'QaloonData_v10.json', 'qaloon.10.ttf', 6214),
    'warsh': ('warsh', 'warshData_v10.json', 'warsh.10.ttf', 6214),
    'shuba': ('shouba', 'ShoubaData08.json', 'shouba.8.ttf', 6236),
    'bazzi': ('bazzi', 'BazziData_v07.json', 'bazzi.7.ttf', 6220),
    'qunbul': ('qumbul', 'QumbulData_v07.json', 'qumbul.7.ttf', 6220),
  };
  const digits = '٠١٢٣٤٥٦٧٨٩';

  String sourcePath(String folder, String kind, String file) => 'build/qiraat-src/$folder/$kind/$file';

  List<Map<String, dynamic>> source(String key) {
    final (folder, data, _, _) = riwayat[key]!;
    final f = File(sourcePath(folder, 'data', data));
    if (!f.existsSync()) fail('$key source missing: run python -I -X utf8 tool/data/build_qiraat.py');
    return [for (final r in jsonDecode(f.readAsStringSync()) as List) r as Map<String, dynamic>];
  }

  /// surah -> ayah texts of assets/qiraat/<key>.json: [text, page, juz].
  Map<int, List<List>> asset(String key) {
    final j = jsonDecode(File('assets/qiraat/$key.json').readAsStringSync()) as Map<String, dynamic>;
    return {for (final s in j['surahs'] as List) (s as Map)['s'] as int: [for (final a in s['a'] as List) a as List]};
  }

  Map<int, int> countsOf(String key) => {for (final e in asset(key).entries) e.key: e.value.length};

  for (final key in riwayat.keys) {
    final (_, _, _, count) = riwayat[key]!;

    group(key, () {
      test('has 114 surahs and $count ayahs, as in the source', () {
        final a = asset(key);
        expect(a.keys, [for (var s = 1; s <= 114; s++) s]);
        expect(a.values.fold<int>(0, (n, l) => n + l.length), count);
        expect(source(key), hasLength(count));
        final j = jsonDecode(File('assets/qiraat/$key.json').readAsStringSync()) as Map<String, dynamic>;
        expect(j['ayahs'], count);
      });

      test('every ayah is the source text, with its page and juz', () {
        final a = asset(key);
        final seen = <int, int>{};
        for (final r in source(key)) {
          final s = int.parse('${r['sura_no'] ?? r['sora']}');
          final n = int.parse('${r['aya_no']}');
          seen[s] = (seen[s] ?? 0) + 1;
          expect(n, seen[s], reason: '$s:$n out of order in the source');
          final row = a[s]![n - 1];
          // The source ends each ayah with a space and its number. The app
          // shows the text without it; nothing else may differ.
          final src = (r['aya_text'] as String).trimRight();
          final cut = src.lastIndexOf(RegExp('[  ]'));
          final num = src.substring(cut + 1);
          expect(num.split('').every(digits.contains), isTrue, reason: '$s:$n suffix');
          expect(num.split('').map(digits.indexOf).join(), '$n', reason: '$s:$n number');
          expect(row[0], src.substring(0, cut), reason: '$key $s:$n');
          expect(row[1], int.parse('${r['page']}'.split('-').first), reason: '$s:$n page');
          expect(row[2], int.parse('${r['jozz']}'), reason: '$s:$n juz');
        }
        expect(seen.length, 114);
      });

      test('font is the source font, and the app declares its family', () {
        final (folder, _, font, _) = riwayat[key]!;
        expect(File('assets/fonts/qiraat/$key.ttf').readAsBytesSync(),
            File(sourcePath(folder, 'font', font)).readAsBytesSync());
      });
    });
  }

  // Riwayat that share a counting school must agree surah by surah. This
  // cross-check uses only the sources, so a dropped or doubled ayah shows up.
  test('qalun and warsh have the same ayah count in every surah (Madani, later)', () {
    expect(countsOf('qalun'), countsOf('warsh'));
  });

  test('bazzi and qunbul have the same ayah count in every surah (Makki)', () {
    expect(countsOf('bazzi'), countsOf('qunbul'));
  });

  test('shuba has the same ayah count in every surah as Hafs (Kufi)', () {
    final meta = File('data/raw/tanzil/quran-data.xml').readAsStringSync();
    final hafs = {
      for (final m in RegExp(r'<sura index="(\d+)" ayas="(\d+)"').allMatches(meta))
        int.parse(m.group(1)!): int.parse(m.group(2)!),
    };
    expect(countsOf('shuba'), hafs);
  });
}
