import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/core/prayer/tasbih_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  var now = DateTime(2026, 11, 1, 9);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    now = DateTime(2026, 11, 1, 9);
  });

  TasbihStore store() => TasbihStore(prefs, now: () => now);

  test('daily goals are 33, 33 and 34', () {
    expect([for (final d in Dhikr.values) d.goal], [33, 33, 34]);
  });

  test('a tap counts for today and survives a restart', () {
    final s = store();
    expect(s.count(Dhikr.subhanAllah), 0);
    s.tap(Dhikr.subhanAllah);
    s.tap(Dhikr.subhanAllah);
    expect(s.count(Dhikr.subhanAllah), 2);
    expect(store().count(Dhikr.subhanAllah), 2);
    expect(s.count(Dhikr.alhamdulillah), 0);
  });

  test('the goal is reached at the goal count, and taps go on counting', () {
    final s = store();
    for (var i = 0; i < 32; i++) {
      s.tap(Dhikr.alhamdulillah);
    }
    expect(s.goalReached(Dhikr.alhamdulillah), isFalse);
    s.tap(Dhikr.alhamdulillah);
    expect(s.goalReached(Dhikr.alhamdulillah), isTrue);
    s.tap(Dhikr.alhamdulillah);
    expect(s.count(Dhikr.alhamdulillah), 34);
  });

  test('all goals done only when all three are reached', () {
    final s = store();
    for (final d in Dhikr.values) {
      for (var i = 0; i < d.goal; i++) {
        expect(s.allGoalsReached, isFalse);
        s.tap(d);
      }
    }
    expect(s.allGoalsReached, isTrue);
  });

  test('a new day starts from zero', () {
    final s = store();
    s.tap(Dhikr.allahuAkbar);
    now = DateTime(2026, 11, 2, 0, 1);
    expect(s.count(Dhikr.allahuAkbar), 0);
    s.tap(Dhikr.allahuAkbar);
    expect(s.count(Dhikr.allahuAkbar), 1);
  });

  test('reset sets today to zero for one dhikr', () {
    final s = store();
    s.tap(Dhikr.subhanAllah);
    s.tap(Dhikr.allahuAkbar);
    s.reset(Dhikr.subhanAllah);
    expect(s.count(Dhikr.subhanAllah), 0);
    expect(s.count(Dhikr.allahuAkbar), 1);
  });

  test('counts older than 60 days are removed on the first tap, newer ones stay', () async {
    prefs.setInt('tasbih.2026-8-1.subhanAllah', 20); // 92 days ago
    prefs.setInt('tasbih.2026-10-20.subhanAllah', 5); // 12 days ago
    prefs.setString('other.key', 'kept');
    final s = store();
    expect(prefs.containsKey('tasbih.2026-8-1.subhanAllah'), isTrue);
    s.tap(Dhikr.subhanAllah);
    expect(prefs.containsKey('tasbih.2026-8-1.subhanAllah'), isFalse);
    expect(prefs.getInt('tasbih.2026-10-20.subhanAllah'), 5);
    expect(prefs.getString('other.key'), 'kept');
  });

  test('listeners hear a tap', () {
    final s = store();
    var n = 0;
    s.addListener(() => n++);
    s.tap(Dhikr.subhanAllah);
    expect(n, 1);
  });
}
