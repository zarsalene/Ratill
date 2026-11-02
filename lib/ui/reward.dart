import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

/// Identifies the burst on screen (for tests).
const rewardBurstKey = ValueKey('reward-burst');

/// A small reward when a goal is done: stars fly out of the middle of the
/// screen for about a second, with a light vibration. With the system setting
/// "reduce motion" only the vibration stays.
void showReward(BuildContext context) {
  HapticFeedback.mediumImpact();
  if (MediaQuery.disableAnimationsOf(context)) return;
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => _Burst(onDone: () => entry.remove()));
  overlay.insert(entry);
}

class _Burst extends StatefulWidget {
  const _Burst({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_Burst> createState() => _BurstState();
}

class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
    ..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, _) => CustomPaint(key: rewardBurstKey, size: Size.infinite, painter: _StarsPainter(_c.value)),
          ),
        ),
      );
}

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.t);
  final double t;

  static const _count = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final fade = (1 - t).clamp(0.0, 1.0);
    final reach = Curves.easeOutCubic.transform(t) * size.shortestSide * 0.45;
    for (var i = 0; i < _count; i++) {
      final a = 2 * math.pi * i / _count;
      final p = center + Offset(math.cos(a), math.sin(a)) * reach;
      final paint = Paint()..color = (i.isEven ? RattilColors.gold : RattilColors.emeraldLight).withValues(alpha: fade);
      canvas.drawPath(_star(p, 10 + 6 * fade, a + t * 2), paint);
    }
  }

  Path _star(Offset c, double r, double turn) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * 0.45;
      final a = turn + math.pi * i / 5;
      final p = c + Offset(math.cos(a), math.sin(a)) * rad;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.t != t;
}
