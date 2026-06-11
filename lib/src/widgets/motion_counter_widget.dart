import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../types.dart';
import '../number_decomposer.dart';
import 'digit_widget.dart';
import 'separator_widget.dart';

/// Animates numeric value changes with beautiful digit transitions.
///
/// Each digit is an independent animated entity. Only digits that change
/// animate — unchanged digits remain perfectly still.
///
/// ```dart
/// MotionCounter(value: 1234)
/// MotionCounter.odometer(value: 1234)
/// MotionCounter.flip(value: 1234)
/// MotionCounter.spring(value: 1234)
/// MotionCounter.slot(value: 1234)
/// MotionCounter.mechanical(value: 1234)
/// MotionCounter.currency(value: 1234.56)
/// MotionCounter.percent(value: 97.4)
/// MotionCounter.compact(value: 1500000)
/// ```
class MotionCounter extends StatefulWidget {
  final num value;
  final AnimationType animationType;
  final Duration duration;
  final Curve curve;
  final Duration stagger;
  final TextStyle? style;
  final NumberFormat? numberFormat;
  final bool grouping;
  final String prefix;
  final String suffix;
  final int? minDigits;

  const MotionCounter({
    super.key,
    required this.value,
    this.animationType = AnimationType.odometer,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
    this.stagger = Duration.zero,
    this.style,
    this.numberFormat,
    this.grouping = false,
    this.prefix = '',
    this.suffix = '',
    this.minDigits,
  });

  /// Odometer — mechanical rolling digits.
  const MotionCounter.odometer({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
    this.stagger = const Duration(milliseconds: 30),
    this.style,
    this.numberFormat,
    this.grouping = false,
    this.prefix = '',
    this.suffix = '',
    this.minDigits,
  }) : animationType = AnimationType.odometer;

  /// Spring — elastic overshoot and bounce.
  const MotionCounter.spring({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.elasticOut,
    this.stagger = Duration.zero,
    this.style,
    this.numberFormat,
    this.grouping = false,
    this.prefix = '',
    this.suffix = '',
    this.minDigits,
  }) : animationType = AnimationType.spring;

  /// Slot — rapid multi-revolution spinning.
  const MotionCounter.slot({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    this.stagger = const Duration(milliseconds: 100),
    this.style,
    this.numberFormat,
    this.grouping = false,
    this.prefix = '',
    this.suffix = '',
    this.minDigits,
  }) : animationType = AnimationType.slot;

  /// Mechanical — industrial snapping counter.
  const MotionCounter.mechanical({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    this.stagger = const Duration(milliseconds: 20),
    this.style,
    this.numberFormat,
    this.grouping = false,
    this.prefix = '',
    this.suffix = '',
    this.minDigits,
  }) : animationType = AnimationType.mechanical;

  /// Currency formatted counter (e.g. $1,234.56).
  factory MotionCounter.currency({
    Key? key,
    required num value,
    AnimationType animationType = AnimationType.odometer,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOutCubic,
    Duration stagger = Duration.zero,
    TextStyle? style,
    String symbol = '\$',
    int decimalDigits = 2,
    int? minDigits,
  }) {
    return MotionCounter(
      key: key,
      value: value,
      animationType: animationType,
      duration: duration,
      curve: curve,
      stagger: stagger,
      style: style,
      numberFormat: NumberFormat('#,##0.${'0' * decimalDigits}'),
      prefix: symbol,
      minDigits: minDigits,
    );
  }

  /// Percentage counter (e.g. 97.4%).
  factory MotionCounter.percent({
    Key? key,
    required num value,
    AnimationType animationType = AnimationType.odometer,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOutCubic,
    Duration stagger = Duration.zero,
    TextStyle? style,
    int decimalDigits = 1,
    int? minDigits,
  }) {
    return MotionCounter(
      key: key,
      value: value,
      animationType: animationType,
      duration: duration,
      curve: curve,
      stagger: stagger,
      style: style,
      numberFormat: NumberFormat('#,##0.${'0' * decimalDigits}'),
      suffix: '%',
      minDigits: minDigits,
    );
  }

  /// Compact counter (e.g. 1.5M, 2.3K).
  factory MotionCounter.compact({
    Key? key,
    required num value,
    AnimationType animationType = AnimationType.odometer,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOutCubic,
    Duration stagger = Duration.zero,
    TextStyle? style,
    int? minDigits,
  }) {
    return MotionCounter(
      key: key,
      value: value,
      animationType: animationType,
      duration: duration,
      curve: curve,
      stagger: stagger,
      style: style,
      numberFormat: NumberFormat.compact(),
      minDigits: minDigits,
    );
  }

  @override
  State<MotionCounter> createState() => _MotionCounterState();
}

class _MotionCounterState extends State<MotionCounter> {
  num _previousValue = 0;
  double _digitWidth = 0;
  double _digitHeight = 0;
  TextStyle? _lastMeasuredStyle;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant MotionCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
    }
  }

  NumberFormat? get _effectiveFormat {
    if (widget.numberFormat != null) return widget.numberFormat;
    if (widget.grouping) return NumberFormat('#,##0.##');
    return null;
  }

  void _updateMetrics(TextStyle style) {
    if (style == _lastMeasuredStyle) return;
    _lastMeasuredStyle = style;
    double maxWidth = 0;
    for (int i = 0; i <= 9; i++) {
      final painter = TextPainter(
        text: TextSpan(text: i.toString(), style: style),
        textDirection: ui.TextDirection.ltr,
        maxLines: 1,
      )..layout();
      if (painter.width > maxWidth) maxWidth = painter.width;
      painter.dispose();
    }
    _digitWidth = maxWidth;
    _digitHeight = (style.fontSize ?? 32) * (style.height ?? 1.2);
  }

  @override
  Widget build(BuildContext context) {
    final style =
        widget.style ??
        DefaultTextStyle.of(context).style.copyWith(fontSize: 32);
    _updateMetrics(style);

    final parts = NumberDecomposer.decompose(
      widget.value,
      format: _effectiveFormat,
      prefix: widget.prefix,
      suffix: widget.suffix,
      minDigits: widget.minDigits,
    );

    final scrollUp = widget.value >= _previousValue;
    final digitCount = parts.where((p) => p.isDigit).length;
    int digitIndex = 0;

    final children = <Widget>[];
    for (final part in parts) {
      if (part.isDigit) {
        final staggerIdx = digitCount - 1 - digitIndex;
        children.add(
          DigitWidget(
            key: ValueKey(part.semanticKey),
            digit: int.parse(part.character),
            animationType: widget.animationType,
            duration: widget.duration,
            curve: widget.curve,
            staggerDelay: widget.stagger * staggerIdx,
            style: style,
            digitHeight: _digitHeight,
            digitWidth: _digitWidth,
            scrollUp: scrollUp,
          ),
        );
        digitIndex++;
      } else {
        children.add(
          SeparatorWidget(
            key: ValueKey(part.semanticKey),
            character: part.character,
            style: style,
          ),
        );
      }
    }

    return AnimatedSize(
      duration: widget.duration,
      curve: Curves.easeInOut,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
