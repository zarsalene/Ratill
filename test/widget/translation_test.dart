import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/app_scope.dart';
import 'package:rattil/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> openFatiha(WidgetTester tester, Locale locale, Map<String, Object> prefs) async {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'onboarded': true, ...prefs});
    final services = (await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('rattil_test');
      final s = await AppServices.create(storageDir: () async => dir);
      // The translation file loads in the background: wait for it.
      for (var i = 0; i < 50 && s.settings.translation != null && s.translations.of(1, 1) == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      return s;
    }))!;
    await tester.pumpWidget(RattilApp(services: services));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quran').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Al-Faatiha').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read & listen').first);
    // The reader loads the surah (real I/O) while a spinner turns: no pumpAndSettle.
    for (var i = 0; i < 50 && find.text('1:1').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('English phone: the Saheeh International text shows under the first ayah of Al-Fatiha', (tester) async {
    await openFatiha(tester, const Locale('en'), {});
    expect(find.text('In the name of Allah, the Entirely Merciful, the Especially Merciful.'), findsOneWidget);
  });
}
