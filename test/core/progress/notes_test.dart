import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/progress/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('a note is saved for one ayah, trimmed, and survives a restart', () {
    final p = ProgressStore(prefs);
    expect(p.noteFor(2, 255), isNull);
    p.setNote(2, 255, '  Ayat al-Kursi, learn on Friday  ');
    expect(p.noteFor(2, 255), 'Ayat al-Kursi, learn on Friday');
    expect(p.noteFor(2, 256), isNull);
    expect(ProgressStore(prefs).noteFor(2, 255), 'Ayat al-Kursi, learn on Friday');
  });

  test('an empty note removes it', () {
    final p = ProgressStore(prefs);
    p.setNote(1, 2, 'x');
    p.setNote(1, 2, '   ');
    expect(p.noteFor(1, 2), isNull);
    expect(ProgressStore(prefs).noteFor(1, 2), isNull);
  });

  test('saved ayahs: bookmarks and notes together, once each, in Quran order', () {
    final p = ProgressStore(prefs);
    p.toggleBookmark(3, 1);
    p.setNote(2, 5, 'a');
    p.toggleBookmark(2, 5);
    p.setNote(114, 1, 'b');
    expect([for (final r in p.savedList()) '${r.surah}:${r.ayah}'], ['2:5', '3:1', '114:1']);
  });

  test('listeners hear a note', () {
    final p = ProgressStore(prefs);
    var n = 0;
    p.addListener(() => n++);
    p.setNote(1, 1, 'x');
    expect(n, 1);
  });

  test('old saved data without notes still loads', () {
    prefs.setString('progress.v1', '{"bm":["1:1"]}');
    final p = ProgressStore(prefs);
    expect(p.isBookmarked(1, 1), isTrue);
    expect(p.noteFor(1, 1), isNull);
  });
}
