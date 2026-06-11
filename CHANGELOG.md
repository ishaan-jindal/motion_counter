# Changelog

## 1.0.0

- **Initial Stable Release** of `motion_counter`.
- **Per-Digit Animators**: Each digit is controlled by an independent animator. Only modified digits trigger animations, while others remain still.
- **Multiple Animation Options**:
  - `odometer`: Classic rolling digit wheels.
  - `spring`: Elastic overshoot and bouncy sliding digit transitions.
  - `slot`: Casino slot-machine style multi-revolution spins.
  - `mechanical`: Snapping industrial numbers.
- **Built-in Formatters**:
  - `MotionCounter.currency`: Format dollar/currency counts easily.
  - `MotionCounter.percent`: Format percentage figures.
  - `MotionCounter.compact`: Formats large numbers compactly (e.g. 1.5M, 2.3K).
- **Stagger cascade**: Added staggering effects that propagate animations across digits (from right-to-left).
- **Fixed Width Padding (`minDigits`)**: Added support for zero-padding the integer part of values, keeping digit counts uniform for countdowns, clocks, or scoreboards.
