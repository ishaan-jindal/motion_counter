import 'package:flutter/material.dart';
import 'animation_strategy.dart';

/// Slot machine animation. Spins through multiple full revolutions
/// before landing on the target digit.
///
/// When scrolling up, spins upward. When scrolling down, spins downward.
/// Always takes the shortest-path direction for the final landing.
class SlotStrategy extends AnimationStrategy {
  final int extraRevolutions;
  SlotStrategy({this.extraRevolutions = 3});

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

    // Compute shortest-path direction and distance
    final upDist = (newDigit - oldDigit + 10) % 10;
    final downDist = (oldDigit - newDigit + 10) % 10;
    final spinUp = upDist <= downDist;
    final directDist = spinUp ? upDist : downDist;
    final totalDist = (extraRevolutions * 10 + directDist).toDouble();
    final pos = t * totalDist;

    if (spinUp) {
      // Spinning upward: digits scroll UP
      final currentDigit = (oldDigit + pos.floor()) % 10;
      final nextDigit = (currentDigit + 1) % 10;
      final fraction = pos - pos.floor();

      return SizedBox(
        height: digitHeight,
        width: digitWidth,
        child: ClipRect(
          child: Stack(
            children: [
              // Current digit slides up (exits top)
              Transform.translate(
                offset: Offset(0, -fraction * digitHeight),
                child: buildDigitCell(
                  currentDigit,
                  style,
                  digitHeight,
                  digitWidth,
                ),
              ),
              // Next digit enters from bottom
              Transform.translate(
                offset: Offset(0, (1 - fraction) * digitHeight),
                child: buildDigitCell(
                  nextDigit,
                  style,
                  digitHeight,
                  digitWidth,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Spinning downward: digits scroll DOWN
      final currentDigit = (oldDigit - pos.floor() + 100) % 10;
      final nextDigit = (currentDigit - 1 + 10) % 10;
      final fraction = pos - pos.floor();

      return SizedBox(
        height: digitHeight,
        width: digitWidth,
        child: ClipRect(
          child: Stack(
            children: [
              // Current digit slides down (exits bottom)
              Transform.translate(
                offset: Offset(0, fraction * digitHeight),
                child: buildDigitCell(
                  currentDigit,
                  style,
                  digitHeight,
                  digitWidth,
                ),
              ),
              // Next digit enters from top
              Transform.translate(
                offset: Offset(0, -(1 - fraction) * digitHeight),
                child: buildDigitCell(
                  nextDigit,
                  style,
                  digitHeight,
                  digitWidth,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
