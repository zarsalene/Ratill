import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rattil/ui/reward.dart';

void main() {
  Widget app({required bool reduceMotion}) => MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(body: Center(child: TextButton(onPressed: () => showReward(context), child: const Text('go')))),
          ),
        ),
      );

  testWidgets('a goal shows a short star burst that removes itself', (tester) async {
    await tester.pumpWidget(app(reduceMotion: false));
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.byKey(rewardBurstKey), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(rewardBurstKey), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(rewardBurstKey), findsNothing);
  });

  testWidgets('with "reduce motion" there is no moving effect', (tester) async {
    await tester.pumpWidget(app(reduceMotion: true));
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.byKey(rewardBurstKey), findsNothing);
  });
}
