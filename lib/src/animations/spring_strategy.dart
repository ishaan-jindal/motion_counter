import 'package:flutter/material.dart';
import 'animation_strategy.dart';

/// Spring animation with elastic overshoot. The spring feel comes from
/// [Curves.elasticOut] applied at the controller level.
class SpringStrategy extends AnimationStrategy {
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

    final t = animation.value;
    final direction = scrollUp ? -1.0 : 1.0;
    final oldOffset = t * direction * digitHeight;
    final newOffset = oldOffset - direction * digitHeight;

    return SizedBox(
      height: digitHeight,
      width: digitWidth,
      child: ClipRect(
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(0, oldOffset),
              child: buildDigitCell(oldDigit, style, digitHeight, digitWidth),
            ),
            Transform.translate(
              offset: Offset(0, newOffset),
              child: buildDigitCell(newDigit, style, digitHeight, digitWidth),
            ),
          ],
        ),
      ),
    );
  }
}
