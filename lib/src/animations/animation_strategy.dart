import 'package:flutter/material.dart';

/// Abstract base class for digit transition animations.
abstract class AnimationStrategy {
  Widget buildTransition({
    required int oldDigit,
    required int newDigit,
    required Animation<double> animation,
    required TextStyle style,
    required double digitHeight,
    required double digitWidth,
    required bool scrollUp,
  });

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
