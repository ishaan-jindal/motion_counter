import 'package:flutter/material.dart';
import 'animation_strategy.dart';

/// Odometer animation that scrolls through intermediate digits.
/// Always takes the shortest path around the 0-9 wheel.
class OdometerStrategy extends AnimationStrategy {
  /// Builds the digit strip in ascending order for the shortest path.
  ///
  /// For going UP (3→7): returns [3, 4, 5, 6, 7]
  /// For going DOWN (7→3): returns [3, 4, 5, 6, 7] (ascending, same strip)
  ///
  /// The caller controls scroll direction via the index traversal order.
  List<int> _buildAscendingStrip(int from, int to, bool goUp) {
    if (from == to) return [from];

    // Always build by stepping in the goUp direction from `from` to `to`
    final digits = <int>[from];
    int current = from;
    while (current != to) {
      current = goUp ? (current + 1) % 10 : (current - 1 + 10) % 10;
      digits.add(current);
    }
    return digits;
  }

  bool _isShortestPathUp(int from, int to) {
    return (to - from + 10) % 10 <= (from - to + 10) % 10;
  }

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

    final goingUp = _isShortestPathUp(oldDigit, newDigit);
    final strip = _buildAscendingStrip(oldDigit, newDigit, goingUp);
    final totalSteps = strip.length - 1;
    final t = animation.value.clamp(0.0, 1.0);

    // When going UP: old is at index 0, new is at last index.
    //   Scroll strip upward: currentIndex goes from 0 → totalSteps.
    // When going DOWN: old is at index 0, new is at last index.
    //   We need to scroll downward visually: reverse the strip so
    //   old is at the BOTTOM (last index) and new is at the TOP (index 0).
    //   Then currentIndex goes from totalSteps → 0.
    final List<int> renderStrip;
    final double currentIndex;

    if (goingUp) {
      // Strip: [old, ..., new], scroll UP
      renderStrip = strip;
      currentIndex = t * totalSteps;
    } else {
      // Reverse strip: [new, ..., old], scroll DOWN
      renderStrip = strip.reversed.toList();
      currentIndex = totalSteps * (1.0 - t);
    }

    return SizedBox(
      height: digitHeight,
      width: digitWidth,
      child: ClipRect(
        child: Stack(
          children: [
            for (int i = 0; i < renderStrip.length; i++)
              Positioned(
                top: (i - currentIndex) * digitHeight,
                left: 0,
                right: 0,
                height: digitHeight,
                child: Center(
                  child: Text(
                    renderStrip[i].toString(),
                    style: style,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
