import 'dart:math';

class AccelerationSample {
  const AccelerationSample({required this.x, required this.y, required this.z});

  final double x;
  final double y;
  final double z;
}

enum MotionSensitivity {
  low(8),
  medium(4),
  high(2.5);

  const MotionSensitivity(this.threshold);
  final double threshold;
}

abstract final class MotionAlarmLogic {
  static double delta(AccelerationSample previous, AccelerationSample current) {
    final dx = current.x - previous.x;
    final dy = current.y - previous.y;
    final dz = current.z - previous.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }

  static bool isArmed({
    required DateTime startedAt,
    required DateTime now,
    required Duration delay,
  }) {
    return !now.difference(startedAt).isNegative &&
        now.difference(startedAt) >= delay;
  }

  static bool shouldTrigger({
    required double delta,
    required MotionSensitivity sensitivity,
  }) {
    return delta >= sensitivity.threshold;
  }
}
