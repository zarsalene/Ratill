import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app_scope.dart';
import 'package:rattil/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Locale locale, {Map<String, Object> prefs = const {}}) async {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'onboarded': true, ...prefs});
    final services = (await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('rattil_test');
      return AppServices.create(storageDir: () async => dir);
    }))!;
    await tester.pumpWidget(RattilApp(services: services));
    await tester.pumpAndSettle();
  }

  // The times tab redraws every second, so these tests use pump, not pumpAndSettle.
  Future<void> tapAndPump(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await tester.pump(); // starts the animation
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> openPrayer(WidgetTester tester) => tapAndPump(tester, find.text('Prayer'));

  testWidgets('Prayer tab without a place asks for it once', (tester) async {
    await pumpApp(tester, const Locale('en'));
    await openPrayer(tester);
    expect(find.text('Use my location'), findsOneWidget);
    expect(find.textContaining('never sent anywhere'), findsOneWidget);
  });

  testWidgets('Prayer tab with a place: next prayer and the five times', (tester) async {
    await pumpApp(tester, const Locale('en'), prefs: {'place.lat': 36.81, 'place.lon': 10.18, 'prayerMethod': 'tunisia'});
    await openPrayer(tester);
    expect(find.textContaining('Next:'), findsOneWidget);
    for (final name in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      expect(find.text(name), findsWidgets);
    }
    expect(find.text('Tunisia (Ministry of Religious Affairs)'), findsOneWidget);
  });

  testWidgets('Tasbih counts taps, shows the goal, and reaches it at 33', (tester) async {
    await pumpApp(tester, const Locale('en'));
    await openPrayer(tester);
    await tapAndPump(tester, find.text('Tasbih').last);
    expect(find.text('0 of 33'), findsOneWidget);
    for (var i = 0; i < 33; i++) {
      await tester.tap(find.text('${i == 0 ? 0 : i}').last);
      await tester.pump();
    }
    expect(find.text('33 of 33'), findsOneWidget);
    expect(find.text('Goal reached'), findsWidgets);
  });

  testWidgets('Qibla tab shows the bearing for the saved place', (tester) async {
    await pumpApp(tester, const Locale('en'), prefs: {'place.lat': 36.81, 'place.lon': 10.18});
    await openPrayer(tester);
    await tapAndPump(tester, find.text('Qibla').last);
    expect(find.text('Qibla: 113° from north'), findsOneWidget);
    // No sensor in the test: after 3 s the screen says so.
    await tester.pump(const Duration(seconds: 4));
    expect(find.textContaining('no compass sensor'), findsOneWidget);
  });

  testWidgets('Arabic: prayer names and Tasbih labels are translated', (tester) async {
    await pumpApp(tester, const Locale('ar'), prefs: {'place.lat': 36.81, 'place.lon': 10.18});
    await tapAndPump(tester, find.text('الصلاة'));
    expect(find.text('الفجر'), findsWidgets);
    expect(find.text('العشاء'), findsWidgets);
  });
}
