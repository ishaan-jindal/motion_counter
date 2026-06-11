import 'dart:async';
import 'package:flutter/material.dart';
import 'package:motion_counter/motion_counter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motion Counter Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1), // Indigo
          secondary: Color(0xFF10B981), // Emerald
          surface: Color(0xFF151D30),
          onSurface: Color(0xFFF8FAFC),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Main counter value
  num _mainValue = 1234;
  AnimationType _selectedType = AnimationType.odometer;
  Duration _stagger = const Duration(milliseconds: 30);

  // Scoreboard value (fixed 6-digit width)
  num _score = 850;

  // Countdown timer values
  int _timerSeconds = 95; // 1 min 35 seconds
  Timer? _timer;
  bool _timerRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_timerRunning) {
      _timer?.cancel();
      setState(() => _timerRunning = false);
    } else {
      setState(() => _timerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_timerSeconds > 0) {
            _timerSeconds--;
          } else {
            _timer?.cancel();
            _timerRunning = false;
          }
        });
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 95;
      _timerRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 950;
          final isMedium = constraints.maxWidth > 600 && constraints.maxWidth <= 950;
          final isCompact = constraints.maxWidth <= 480;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 1200 ? 64.0 : 24.0,
                vertical: 40.0,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      const SizedBox(height: 32),

                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column (Showcase + Formatting)
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Interactive Showcase'),
                                  const SizedBox(height: 12),
                                  _buildInteractiveShowcase(isCompact: false),
                                  const SizedBox(height: 32),
                                  _buildSectionTitle('Formatting Presets'),
                                  const SizedBox(height: 12),
                                  _buildFormattingPresets(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Right Column (Presets + Countdowns)
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Countdown & Padding (minDigits)'),
                                  const SizedBox(height: 12),
                                  _buildCountdownAndPadding(),
                                  const SizedBox(height: 32),
                                  _buildSectionTitle('Animation Presets'),
                                  const SizedBox(height: 12),
                                  _buildAnimationPresetsGrid(isWide: true),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        // Medium/Small Single Column Layout
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Interactive Showcase'),
                            const SizedBox(height: 12),
                            _buildInteractiveShowcase(isCompact: isCompact),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Countdown & Padding (minDigits)'),
                            const SizedBox(height: 12),
                            _buildCountdownAndPadding(),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Animation Presets'),
                            const SizedBox(height: 12),
                            _buildAnimationPresetsGrid(isWide: isMedium),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Formatting Presets'),
                            const SizedBox(height: 12),
                            _buildFormattingPresets(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Motion Counter',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            color: Color(0xFFF8FAFC),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Physics-driven animated numeric transitions for Flutter',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildInteractiveShowcase({required bool isCompact}) {
    return _buildCard(
      child: Column(
        children: [
          // The Counter Display
          Container(
            height: 120,
            alignment: Alignment.center,
            child: MotionCounter(
              value: _mainValue,
              animationType: _selectedType,
              stagger: _stagger,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const Divider(color: Color(0xFF1E293B)),
          const SizedBox(height: 16),

          // Controls (wrap in responsive buttons row/column)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildButton(
                onPressed: () => setState(() => _mainValue -= 150),
                icon: Icons.remove,
                label: '150',
              ),
              _buildButton(
                onPressed: () => setState(() => _mainValue -= 1),
                icon: Icons.remove,
                label: '1',
              ),
              _buildButton(
                onPressed: () => setState(() => _mainValue += 1),
                icon: Icons.add,
                label: '1',
              ),
              _buildButton(
                onPressed: () => setState(() => _mainValue += 150),
                icon: Icons.add,
                label: '150',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Configuration Options
          _buildShowcaseDropdowns(isCompact: isCompact),
        ],
      ),
    );
  }

  Widget _buildShowcaseDropdowns({required bool isCompact}) {
    final styleDropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Animation Style', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<AnimationType>(
          initialValue: _selectedType,
          decoration: _inputDecoration(),
          items: AnimationType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedType = val);
            }
          },
        ),
      ],
    );

    final staggerDropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stagger Delay', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _stagger.inMilliseconds,
          decoration: _inputDecoration(),
          items: const [
            DropdownMenuItem(value: 0, child: Text('No Stagger (0ms)')),
            DropdownMenuItem(value: 30, child: Text('Fast (30ms)')),
            DropdownMenuItem(value: 80, child: Text('Medium (80ms)')),
            DropdownMenuItem(value: 150, child: Text('Slow (150ms)')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() => _stagger = Duration(milliseconds: val));
            }
          },
        ),
      ],
    );

    if (isCompact) {
      return Column(
        children: [
          styleDropdown,
          const SizedBox(height: 16),
          staggerDropdown,
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: styleDropdown),
          const SizedBox(width: 16),
          Expanded(child: staggerDropdown),
        ],
      );
    }
  }

  Widget _buildAnimationPresetsGrid({required bool isWide}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isWide 
            ? (constraints.maxWidth - 16) / 2 
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildPresetCard(
              width: cardWidth,
              title: 'Odometer (Rolling)',
              subtitle: 'Simulates mechanical wheel cylinders rolling up/down.',
              counter: MotionCounter.odometer(
                value: _mainValue,
                stagger: const Duration(milliseconds: 30),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
              ),
            ),
            _buildPresetCard(
              width: cardWidth,
              title: 'Spring (Physics)',
              subtitle: 'Translates digits with overshoot and elastic bounces.',
              counter: MotionCounter.spring(
                value: _mainValue,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
              ),
            ),
            _buildPresetCard(
              width: cardWidth,
              title: 'Slot (Spinning)',
              subtitle: 'Spins multiple full loops before aligning to target.',
              counter: MotionCounter.slot(
                value: _mainValue,
                stagger: const Duration(milliseconds: 60),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
              ),
            ),
            _buildPresetCard(
              width: cardWidth,
              title: 'Mechanical (Snapping)',
              subtitle: 'Snaps instantly with fade and scale effects.',
              counter: MotionCounter.mechanical(
                value: _mainValue,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCountdownAndPadding() {
    final timerMinutes = _timerSeconds ~/ 60;
    final timerSecs = _timerSeconds % 60;

    final scoreboardWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fixed 6-Digit Scoreboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            MotionCounter.odometer(
              value: _score,
              minDigits: 6,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const Spacer(),
            _buildMiniButton(
              icon: Icons.add,
              onPressed: () => setState(() => _score += 123),
            ),
            const SizedBox(width: 8),
            _buildMiniButton(
              icon: Icons.refresh,
              onPressed: () => setState(() => _score = 850),
            ),
          ],
        ),
      ],
    );

    final timerWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MM:SS Countdown Timer',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerCell(timerMinutes),
            const Text(
              ':',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            _buildTimerCell(timerSecs),
            const SizedBox(width: 16),
            _buildMiniButton(
              icon: _timerRunning ? Icons.pause : Icons.play_arrow,
              onPressed: _toggleTimer,
            ),
            const SizedBox(width: 8),
            _buildMiniButton(
              icon: Icons.refresh,
              onPressed: _resetTimer,
            ),
          ],
        ),
      ],
    );

    return _buildCard(
      child: Column(
        children: [
          scoreboardWidget,
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Color(0xFF1E293B)),
          ),
          timerWidget,
        ],
      ),
    );
  }

  Widget _buildFormattingPresets() {
    return _buildCard(
      child: Column(
        children: [
          _buildFormatRow(
            label: 'Currency',
            code: 'MotionCounter.currency(value: 9945.50)',
            counter: MotionCounter.currency(
              value: 9945.50,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 24),
          _buildFormatRow(
            label: 'Percentage',
            code: 'MotionCounter.percent(value: 84.7)',
            counter: MotionCounter.percent(
              value: 84.7,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 24),
          _buildFormatRow(
            label: 'Compact',
            code: 'MotionCounter.compact(value: 2350000)',
            counter: MotionCounter.compact(
              value: 2350000,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildPresetCard({
    required double width,
    required String title,
    required String subtitle,
    required Widget counter,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 16),
          Container(
            height: 60,
            alignment: Alignment.centerLeft,
            child: counter,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTimerCell(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MotionCounter.odometer(
        value: value,
        minDigits: 2,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF38BDF8), // Cyan
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _buildFormatRow({
    required String label,
    required String code,
    required Widget counter,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        counter,
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
