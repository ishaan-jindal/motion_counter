import 'package:intl/intl.dart';

/// Represents a single character in a decomposed number.
class CharPart {
  final String character;
  final bool isDigit;
  final String semanticKey;

  const CharPart({
    required this.character,
    required this.isDigit,
    required this.semanticKey,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharPart &&
          character == other.character &&
          isDigit == other.isDigit &&
          semanticKey == other.semanticKey;

  @override
  int get hashCode => Object.hash(character, isDigit, semanticKey);

  @override
  String toString() => 'CharPart($character, key: $semanticKey)';
}

/// Decomposes numeric values into [CharPart] lists with stable semantic keys.
///
/// Semantic keys ensure digits at the same positional significance
/// (ones, tens, hundreds) maintain widget identity across value changes.
class NumberDecomposer {
  NumberDecomposer._();

  static bool _isAsciiDigit(String c) =>
      c.isNotEmpty && c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  /// Decomposes [value] into a list of [CharPart] objects.
  static List<CharPart> decompose(
    num value, {
    NumberFormat? format,
    String prefix = '',
    String suffix = '',
    int? minDigits,
  }) {
    final formatted = format?.format(value) ?? value.toString();
    final parts = <CharPart>[];

    for (int i = 0; i < prefix.length; i++) {
      parts.add(
        CharPart(character: prefix[i], isDigit: false, semanticKey: 'px$i'),
      );
    }

    _decomposeFormatted(formatted, parts, minDigits: minDigits);

    for (int i = 0; i < suffix.length; i++) {
      parts.add(
        CharPart(character: suffix[i], isDigit: false, semanticKey: 'sx$i'),
      );
    }

    return parts;
  }

  static void _decomposeFormatted(
    String formatted,
    List<CharPart> parts, {
    int? minDigits,
  }) {
    final chars = formatted.split('');
    final dotIndex = chars.indexOf('.');
    int integerEnd = dotIndex >= 0 ? dotIndex : chars.length;

    // Count integer digits to check if padding is needed
    int intDigitCount = 0;
    int firstDigitIdx = -1;
    for (int i = 0; i < integerEnd; i++) {
      if (_isAsciiDigit(chars[i])) {
        intDigitCount++;
        if (firstDigitIdx == -1) {
          firstDigitIdx = i;
        }
      }
    }

    if (minDigits != null && intDigitCount < minDigits) {
      final padCount = minDigits - intDigitCount;
      final padZeros = List<String>.filled(padCount, '0');
      if (firstDigitIdx == -1) {
        chars.insertAll(integerEnd, padZeros);
      } else {
        chars.insertAll(firstDigitIdx, padZeros);
      }
      integerEnd += padCount;
    }

    // Recount integer digits and group separators
    intDigitCount = 0;
    int groupSepCount = 0;
    bool seenDigit = false;
    for (int i = 0; i < integerEnd; i++) {
      if (_isAsciiDigit(chars[i])) {
        intDigitCount++;
        seenDigit = true;
      } else if (seenDigit) {
        groupSepCount++;
      }
    }

    bool reachedFirstDigit = false;
    bool pastDecimal = false;
    int intDigitIdx = 0;
    int decDigitIdx = 0;
    int groupSepIdx = 0;
    int fmtPrefixIdx = 0;
    int fmtSuffixIdx = 0;

    for (int i = 0; i < chars.length; i++) {
      final c = chars[i];

      if (c == '.' && !pastDecimal) {
        pastDecimal = true;
        parts.add(CharPart(character: c, isDigit: false, semanticKey: 'dot'));
        continue;
      }

      if (_isAsciiDigit(c)) {
        reachedFirstDigit = true;
        if (pastDecimal) {
          parts.add(
            CharPart(character: c, isDigit: true, semanticKey: 'd$decDigitIdx'),
          );
          decDigitIdx++;
        } else {
          final posFromRight = intDigitCount - 1 - intDigitIdx;
          parts.add(
            CharPart(
              character: c,
              isDigit: true,
              semanticKey: 'i$posFromRight',
            ),
          );
          intDigitIdx++;
        }
      } else if (!reachedFirstDigit) {
        parts.add(
          CharPart(
            character: c,
            isDigit: false,
            semanticKey: 'fp$fmtPrefixIdx',
          ),
        );
        fmtPrefixIdx++;
      } else if (!pastDecimal) {
        final keyFromRight = groupSepCount - 1 - groupSepIdx;
        parts.add(
          CharPart(character: c, isDigit: false, semanticKey: 'g$keyFromRight'),
        );
        groupSepIdx++;
      } else {
        parts.add(
          CharPart(
            character: c,
            isDigit: false,
            semanticKey: 'fs$fmtSuffixIdx',
          ),
        );
        fmtSuffixIdx++;
      }
    }
  }
}
