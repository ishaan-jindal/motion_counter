/// Animation types available for digit transitions in [MotionCounter].
enum AnimationType {
  /// Mechanical rolling digits, like a car odometer.
  odometer,

  /// Physics-based spring animation with overshoot and bounce.
  spring,

  /// Rapid spinning slot machine style.
  slot,

  /// Industrial mechanical counter with snapping transitions.
  mechanical,
}
