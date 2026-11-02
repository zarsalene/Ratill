import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../settings.dart';
import 'riwaya.dart';

/// The translations the app can show under each ayah: Tanzil.net files, kept
/// byte for byte as pinned in data/CHECKSUMS (data/raw/tanzil/trans).
enum Translation {
  en('data/raw/tanzil/trans/en.sahih.txt', 'Saheeh International'),
  fr('data/raw/tanzil/trans/fr.hamidullah.txt', 'Muhammad Hamidullah');

  const Translation(this.asset, this.translator);
  final String asset;
  final String translator;

  /// Where the text comes from (shown in the credits).
  String get source => 'Tanzil.net';
}

/// One translation: [surah] 1..114, [ayah] 1..n, in the numbering of the
/// Hafs text (the Basmala is ayah 1 of Al-Fatiha).
class TranslationText {
  TranslationText._(this._ayahs);

  final List<List<String>> _ayahs;

  int ayahCount(int surah) => _ayahs[surah - 1].length;
  String of(int surah, int ayah) => _ayahs[surah - 1][ayah - 1];
}

/// Reads a Tanzil translation file: lines `surah|ayah|text`, comments start
/// with `#`. The text is kept as it is. Throws [FormatException] unless the file
/// has 114 surahs and every ayah once, in order.
TranslationText parseTanzilTranslation(String raw) {
  final surahs = <List<String>>[];
  for (final line in raw.split('\n')) {
    final l = line.trimRight();
    if (l.isEmpty || l.startsWith('#')) continue;
    final a = l.indexOf('|'), b = l.indexOf('|', a + 1);
    final s = a < 0 || b < 0 ? null : int.tryParse(l.substring(0, a));
    final n = s == null ? null : int.tryParse(l.substring(a + 1, b));
    if (s == null || n == null) throw FormatException('bad translation line', l);
    if (s == surahs.length + 1) {
      surahs.add([]);
    } else if (s != surahs.length) {
      throw FormatException('surah out of order', l);
    }
    if (n != surahs.last.length + 1) throw FormatException('ayah out of order', l);
    surahs.last.add(l.substring(b + 1));
  }
  if (surahs.length != 114) throw FormatException('expected 114 surahs, found ${surahs.length}');
  return TranslationText._(surahs);
}

/// The translation the reader chose, loaded on demand. Shown for the Hafs text
/// only: ayah numbers of the other riwayat differ.
class TranslationStore extends ChangeNotifier {
  TranslationStore(this._settings, {AssetBundle? bundle}) : _bundle = bundle ?? rootBundle {
    _settings.addListener(_load);
    _load();
  }

  final Settings _settings;
  final AssetBundle _bundle;
  final Map<Translation, TranslationText> _loaded = {};

  /// The translation of ayah [ayah] of [surah], or null when none is chosen
  /// (or it is not loaded yet).
  String? of(int surah, int ayah) {
    final t = _settings.translation;
    if (t == null || _settings.riwaya != Riwaya.hafs) return null;
    return _loaded[t]?.of(surah, ayah);
  }

  Future<void> _load() async {
    final t = _settings.translation;
    if (t == null || _loaded.containsKey(t)) return;
    try {
      _loaded[t] = parseTanzilTranslation(await _bundle.loadString(t.asset));
      notifyListeners();
    } catch (_) {
      // A translation is a help: the Arabic text still shows.
    }
  }
}
