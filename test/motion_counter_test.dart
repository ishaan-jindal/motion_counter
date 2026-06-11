import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:motion_counter/motion_counter.dart';

void main() {
  // ─────────────────────────────────────────────────────────
  // NumberDecomposer unit tests
  // ─────────────────────────────────────────────────────────

  group('NumberDecomposer', () {
    test('decomposes plain integer', () {
      final parts = NumberDecomposer.decompose(1234);
      expect(parts.length, 4);
      expect(parts.map((p) => p.character).join(), '1234');
      expect(parts.every((p) => p.isDigit), true);
    });

    test('assigns right-aligned semantic keys to integer digits', () {
      final parts = NumberDecomposer.decompose(123);
      // i2=1, i1=2, i0=3 (hundreds, tens, ones)
      expect(parts[0].semanticKey, 'i2');
      expect(parts[1].semanticKey, 'i1');
      expect(parts[2].semanticKey, 'i0');
    });

    test('keys remain stable when digit count changes', () {
      final parts99 = NumberDecomposer.decompose(99);
      final parts100 = NumberDecomposer.decompose(100);

      // Ones digit in 99 has key 'i0', ones digit in 100 also has key 'i0'
      final ones99 = parts99.firstWhere((p) => p.semanticKey == 'i0');
      final ones100 = parts100.firstWhere((p) => p.semanticKey == 'i0');
      expect(ones99.character, '9');
      expect(ones100.character, '0');
    });

    test('decomposes decimal numbers', () {
      final parts = NumberDecomposer.decompose(12.34);
      final chars = parts.map((p) => p.character).join();
      expect(chars, '12.34');

      final dot = parts.firstWhere((p) => p.semanticKey == 'dot');
      expect(dot.character, '.');
      expect(dot.isDigit, false);

      final tenths = parts.firstWhere((p) => p.semanticKey == 'd0');
      expect(tenths.character, '3');

      final hundredths = parts.firstWhere((p) => p.semanticKey == 'd1');
      expect(hundredths.character, '4');
    });

    test('decomposes with NumberFormat grouping', () {
      final parts = NumberDecomposer.decompose(
        1234567,
        format: NumberFormat('#,##0'),
      );
      final chars = parts.map((p) => p.character).join();
      expect(chars, '1,234,567');

      // Group separators keyed from right
      final groupSeps = parts.where((p) => p.semanticKey.startsWith('g'));
      expect(groupSeps.length, 2);
    });

    test('handles prefix and suffix', () {
      final parts = NumberDecomposer.decompose(
        97.4,
        format: NumberFormat('#,##0.0'),
        prefix: r'$',
        suffix: '%',
      );
      final chars = parts.map((p) => p.character).join();
      expect(chars, r'$97.4%');

      expect(parts.first.semanticKey, 'px0');
      expect(parts.last.semanticKey, 'sx0');
    });

    test('handles negative numbers', () {
      final parts = NumberDecomposer.decompose(-42);
      final chars = parts.map((p) => p.character).join();
      expect(chars, '-42');

      final minus = parts.firstWhere((p) => p.character == '-');
      expect(minus.isDigit, false);
      expect(minus.semanticKey, 'fp0');
    });

    test('handles zero', () {
      final parts = NumberDecomposer.decompose(0);
      expect(parts.length, 1);
      expect(parts[0].character, '0');
      expect(parts[0].semanticKey, 'i0');
    });

    test('pads integer digits with minDigits', () {
      final parts = NumberDecomposer.decompose(42, minDigits: 5);
      final chars = parts.map((p) => p.character).join();
      expect(chars, '00042');
      expect(parts.every((p) => p.isDigit), true);
      // Semantic keys from right: i0='2', i1='4', i2='0', i3='0', i4='0'
      expect(parts[0].semanticKey, 'i4');
      expect(parts[4].semanticKey, 'i0');
    });

    test('pads decimal numbers correctly with minDigits', () {
      final parts = NumberDecomposer.decompose(12.34, minDigits: 5);
      final chars = parts.map((p) => p.character).join();
      expect(chars, '00012.34');
      final tenths = parts.firstWhere((p) => p.semanticKey == 'd0');
      expect(tenths.character, '3');
      final integerDigits = parts.where((p) => p.isDigit && p.semanticKey.startsWith('i'));
      expect(integerDigits.length, 5);
    });

    test('pads negative numbers correctly with minDigits', () {
      final parts = NumberDecomposer.decompose(-42, minDigits: 5);
      final chars = parts.map((p) => p.character).join();
      expect(chars, '-00042');
      // Prefix minus sign is still the first character
      expect(parts[0].character, '-');
      expect(parts[0].isDigit, false);
      expect(parts[1].character, '0');
      expect(parts[5].character, '2');
    });
  });

  // ─────────────────────────────────────────────────────────
  // MotionCounter widget tests
  // ─────────────────────────────────────────────────────────

  group('MotionCounter widget', () {
    testWidgets('renders initial value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MotionCounter(value: 42),
            ),
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders with grouping', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MotionCounter(value: 1234567, grouping: true),
            ),
          ),
        ),
      );

      // Should render commas as separators
      expect(find.text(','), findsNWidgets(2));
    });

    testWidgets('renders currency format', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MotionCounter.currency(value: 1234.56),
            ),
          ),
        ),
      );

      expect(find.text(r'$'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
    });

    testWidgets('renders percent format', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MotionCounter.percent(value: 97.4),
            ),
          ),
        ),
      );

      expect(find.text('%'), findsOneWidget);
    });

    testWidgets('all named constructors build without error', (tester) async {
      for (final widget in [
        const MotionCounter.odometer(value: 123),
        const MotionCounter.spring(value: 123),
        const MotionCounter.slot(value: 123),
        const MotionCounter.mechanical(value: 123),
      ]) {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: Center(child: widget))),
        );
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      }
    });

    testWidgets('animates on value change', (tester) async {
      int value = 5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return GestureDetector(
                    onTap: () => setState(() => value = 8),
                    child: MotionCounter(value: value),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);

      // Trigger value change
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // During animation, the animation controller is running
      // Pump a few frames
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // After full duration, should show new value
      await tester.pumpAndSettle();
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('handles value with prefix and suffix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MotionCounter(
                value: 42,
                prefix: '~',
                suffix: '!',
              ),
            ),
          ),
        ),
      );

      expect(find.text('~'), findsOneWidget);
      expect(find.text('!'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('handles decimal values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MotionCounter(value: 3.14),
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('renders with minDigits padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MotionCounter(value: 42, minDigits: 5),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNWidgets(3));
      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Animation strategy tests
  // ─────────────────────────────────────────────────────────

  group('AnimationStrategy', () {
    test('OdometerStrategy shortest path up', () {
      final strategy = OdometerStrategy();
      // 3 → 7 should go up (4 steps) not down (6 steps)
      final widget = strategy.buildTransition(
        oldDigit: 3,
        newDigit: 7,
        animation: const AlwaysStoppedAnimation(0.5),
        style: const TextStyle(fontSize: 32),
        digitHeight: 38.4,
        digitWidth: 20.0,
        scrollUp: true,
      );
      expect(widget, isA<Widget>());
    });

    test('OdometerStrategy handles same digit', () {
      final strategy = OdometerStrategy();
      final widget = strategy.buildTransition(
        oldDigit: 5,
        newDigit: 5,
        animation: const AlwaysStoppedAnimation(0.0),
        style: const TextStyle(fontSize: 32),
        digitHeight: 38.4,
        digitWidth: 20.0,
        scrollUp: true,
      );
      expect(widget, isA<SizedBox>());
    });

    test('SlotStrategy builds without error', () {
      final strategy = SlotStrategy();
      final widget = strategy.buildTransition(
        oldDigit: 0,
        newDigit: 5,
        animation: const AlwaysStoppedAnimation(0.5),
        style: const TextStyle(fontSize: 32),
        digitHeight: 38.4,
        digitWidth: 20.0,
        scrollUp: true,
      );
      expect(widget, isA<Widget>());
    });

    test('SpringStrategy builds without error', () {
      final strategy = SpringStrategy();
      // Test with overshoot value (> 1.0)
      final widget = strategy.buildTransition(
        oldDigit: 2,
        newDigit: 8,
        animation: const AlwaysStoppedAnimation(1.2),
        style: const TextStyle(fontSize: 32),
        digitHeight: 38.4,
        digitWidth: 20.0,
        scrollUp: true,
      );
      expect(widget, isA<Widget>());
    });

    test('MechanicalStrategy builds without error', () {
      final strategy = MechanicalStrategy();
      final widget = strategy.buildTransition(
        oldDigit: 4,
        newDigit: 6,
        animation: const AlwaysStoppedAnimation(0.5),
        style: const TextStyle(fontSize: 32),
        digitHeight: 38.4,
        digitWidth: 20.0,
        scrollUp: true,
      );
      expect(widget, isA<Widget>());
    });
  });
}
