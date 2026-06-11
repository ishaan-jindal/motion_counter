import 'package:flutter/material.dart';

/// Renders a non-digit character (comma, decimal point, currency symbol, etc.).
class SeparatorWidget extends StatelessWidget {
  final String character;
  final TextStyle style;

  const SeparatorWidget({
    super.key,
    required this.character,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(character, style: style, textAlign: TextAlign.center);
  }
}
