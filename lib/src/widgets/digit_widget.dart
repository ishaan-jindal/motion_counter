import 'dart:async';
import 'package:flutter/material.dart';
import '../types.dart';
import '../animations/animation_strategy.dart';
import '../animations/odometer_strategy.dart';
import '../animations/spring_strategy.dart';
import '../animations/slot_strategy.dart';
import '../animations/mechanical_strategy.dart';

/// A single animated digit cell.
///
/// Tracks its own old/new digit state internally. When [digit] changes,
/// it animates from the previous value to the new value.
class DigitWidget extends StatefulWidget {
  final int digit;
  final AnimationType animationType;
  final Duration duration;
  final Curve curve;
  final Duration staggerDelay;
  final TextStyle style;
  final double digitHeight;
  final double digitWidth;
  final bool scrollUp;

  const DigitWidget({
    super.key,
    required this.digit,
    required this.animationType,
    required this.duration,
    required this.curve,
    required this.staggerDelay,
    required this.style,
    required this.digitHeight,
    required this.digitWidth,
    required this.scrollUp,
  });

  @override
  State<DigitWidget> createState() => _DigitWidgetState();
}

class _DigitWidgetState extends State<DigitWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curvedAnimation;
  late AnimationStrategy _strategy;

  int _oldDigit = 0;
  int _newDigit = 0;
  bool _scrollUp = true;
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    _oldDigit = widget.digit;
    _newDigit = widget.digit;
    _scrollUp = widget.scrollUp;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _strategy = _createStrategy(widget.animationType);
  }

  @override
  void didUpdateWidget(covariant DigitWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.curve != widget.curve) {
      _curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      );
    }
    if (oldWidget.animationType != widget.animationType) {
      _strategy = _createStrategy(widget.animationType);
    }

    if (oldWidget.digit != widget.digit) {
      _staggerTimer?.cancel();
      _oldDigit = oldWidget.digit;
      _newDigit = widget.digit;
      _scrollUp = widget.scrollUp;

      if (_oldDigit != _newDigit) {
        _controller.reset();
        _scheduleAnimation();
      } else {
        _controller.reset();
      }
    }
  }

  void _scheduleAnimation() {
    if (widget.staggerDelay > Duration.zero) {
      _staggerTimer = Timer(widget.staggerDelay, () {
        if (mounted) _controller.forward(from: 0.0);
      });
    } else {
      _controller.forward(from: 0.0);
    }
  }

  AnimationStrategy _createStrategy(AnimationType type) {
    switch (type) {
      case AnimationType.odometer:
        return OdometerStrategy();
      case AnimationType.spring:
        return SpringStrategy();
      case AnimationType.slot:
        return SlotStrategy();
      case AnimationType.mechanical:
        return MechanicalStrategy();
    }
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (context, _) {
        if (_oldDigit == _newDigit) {
          return _strategy.buildStatic(
            digit: _newDigit,
            style: widget.style,
            digitHeight: widget.digitHeight,
            digitWidth: widget.digitWidth,
          );
        }
        return _strategy.buildTransition(
          oldDigit: _oldDigit,
          newDigit: _newDigit,
          animation: _curvedAnimation,
          style: widget.style,
          digitHeight: widget.digitHeight,
          digitWidth: widget.digitWidth,
          scrollUp: _scrollUp,
        );
      },
    );
  }
}
