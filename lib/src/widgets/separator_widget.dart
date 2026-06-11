import 'package:flutter/material.dart';

/// Renders a non-digit character (comma, decimal point, currency symbol, etc.).
class SeparatorWidget extends StatelessWidget {
  /// The static non-digit character to display.
  final String character;

  /// The text style applied to the character.
  final TextStyle style;

  /// Creates a static [SeparatorWidget] for [character].
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
