import 'package:flutter/material.dart';

/// Abstract base class for digit transition animations.
abstract class AnimationStrategy {
  /// Builds the animated widget to transition from [oldDigit] to [newDigit].
  Widget buildTransition({
    required int oldDigit,
    required int newDigit,
    required Animation<double> animation,
    required TextStyle style,
    required double digitHeight,
    required double digitWidth,
    required bool scrollUp,
  });

  /// Builds a static, non-animating layout displaying [digit].
  Widget buildStatic({
    required int digit,
    required TextStyle style,
    required double digitHeight,
    required double digitWidth,
  }) {
    return SizedBox(
      height: digitHeight,
      width: digitWidth,
      child: Center(
        child: Text(
          digit.toString(),
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Helper to render a single, centered digit cell.
  @protected
  Widget buildDigitCell(
    int digit,
    TextStyle style,
    double height,
    double width,
  ) {
    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: Text(
          digit.toString(),
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
