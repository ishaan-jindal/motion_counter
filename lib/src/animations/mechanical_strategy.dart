import 'package:flutter/material.dart';
import 'animation_strategy.dart';

/// Industrial mechanical counter with a snapping transition.
/// Features delayed start, decisive snap, and subtle scale effects.
class MechanicalStrategy extends AnimationStrategy {
  @override
  Widget buildTransition({
    required int oldDigit,
    required int newDigit,
    required Animation<double> animation,
    required TextStyle style,
    required double digitHeight,
    required double digitWidth,
    required bool scrollUp,
  }) {
    if (oldDigit == newDigit) {
      return buildStatic(
        digit: newDigit,
        style: style,
        digitHeight: digitHeight,
        digitWidth: digitWidth,
      );
    }

    final t = animation.value.clamp(0.0, 1.0);
    final snapT = _mechanicalCurve(t);
    final direction = scrollUp ? -1.0 : 1.0;
    final oldOffset = snapT * direction * digitHeight;
    final newOffset = oldOffset - direction * digitHeight;

    final oldScale = 1.0 - (snapT * 0.08).clamp(0.0, 0.08);
    final newScale = 0.92 + (snapT * 0.08).clamp(0.0, 0.08);
    final oldOpacity = (1.0 - snapT * 1.5).clamp(0.0, 1.0);
    final newOpacity = (snapT * 1.5 - 0.2).clamp(0.0, 1.0);

    return SizedBox(
      height: digitHeight,
      width: digitWidth,
      child: ClipRect(
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(0, oldOffset),
              child: Opacity(
                opacity: oldOpacity,
                child: Transform.scale(
                  scale: oldScale,
                  child: buildDigitCell(
                    oldDigit,
                    style,
                    digitHeight,
                    digitWidth,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, newOffset),
              child: Opacity(
                opacity: newOpacity,
                child: Transform.scale(
                  scale: newScale,
                  child: buildDigitCell(
                    newDigit,
                    style,
                    digitHeight,
                    digitWidth,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _mechanicalCurve(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    final remapped = ((t - 0.15) / 0.7).clamp(0.0, 1.0);
    return remapped * remapped * (3.0 - 2.0 * remapped);
  }
}
