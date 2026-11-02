import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_scope.dart';
import '../../core/prayer/tasbih_store.dart';
import '../../core/sound/sfx.dart';
import '../../ui/reward.dart';
import '../../l10n/app_localizations.dart';
import 'labels.dart';
import 'reminders.dart';

/// A tap counter with a daily goal for each of the three tasbih.
class TasbihTab extends StatefulWidget {
  const TasbihTab({super.key});

  @override
  State<TasbihTab> createState() => _TasbihTabState();
}

class _TasbihTabState extends State<TasbihTab> {
  Dhikr _d = Dhikr.subhanAllah;
  bool _pulse = false;

  Future<void> _tap(AppServices s, AppLocalizations t) async {
    final store = s.tasbih;
    store.tap(_d);
    setState(() => _pulse = !_pulse); // a short press pulse on the button
    if (store.count(_d) == _d.goal) {
      s.sfx.play(SfxKind.chime);
      showReward(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.tasbihGoalDone)));
      // Today's tasbih reminder is not needed once all goals are done.
      if (store.allGoalsReached) await refreshReminders(s, t);
    } else {
      s.sfx.play(SfxKind.tap);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final s = AppScope.of(context);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: s.tasbih,
      builder: (context, _) {
        final count = s.tasbih.count(_d);
        final done = s.tasbih.goalReached(_d);
        return ListView(padding: const EdgeInsets.all(16), children: [
          SegmentedButton<Dhikr>(
            segments: [
              for (final d in Dhikr.values)
                ButtonSegment(value: d, label: Text(dhikrLabel(t, d)), icon: s.tasbih.goalReached(d) ? const Icon(Icons.check) : null),
            ],
            selected: {_d},
            onSelectionChanged: (v) => setState(() => _d = v.first),
          ),
          const SizedBox(height: 24),
          Center(
            child: Semantics(
              button: true,
              label: '${dhikrLabel(t, _d)}, ${t.tasbihCount('$count', '${_d.goal}')}',
              child: SizedBox.square(
                dimension: 240,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: math.min(1, count / _d.goal),
                      strokeWidth: 10,
                      color: done ? Colors.green : theme.colorScheme.primary,
                    ),
                  ),
                  // A press makes the button pulse (not with "reduce motion").
                  TweenAnimationBuilder<double>(
                    key: ValueKey(_pulse),
                    tween: Tween(begin: MediaQuery.disableAnimationsOf(context) ? 1 : 0.94, end: 1),
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                    child: Material(
                      shape: const CircleBorder(),
                      color: theme.colorScheme.primaryContainer,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _tap(s, t),
                        child: SizedBox.square(
                          dimension: 200,
                          child: Center(child: Text('$count', style: theme.textTheme.displayLarge)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(t.tasbihCount('$count', '${_d.goal}'), textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(done ? t.tasbihGoalDone : t.tasbihTapHint, textAlign: TextAlign.center),
          if (s.tasbih.allGoalsReached)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(t.tasbihAllDone, textAlign: TextAlign.center, style: theme.textTheme.titleSmall?.copyWith(color: Colors.green)),
            ),
          const SizedBox(height: 8),
          Center(child: TextButton.icon(onPressed: () => s.tasbih.reset(_d), icon: const Icon(Icons.restart_alt), label: Text(t.tasbihReset))),
        ]);
      },
    );
  }
}
