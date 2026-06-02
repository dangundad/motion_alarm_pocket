import 'package:flutter_test/flutter_test.dart';
import 'package:motion_alarm_pocket/app/domain/motion_alarm_logic.dart';

void main() {
  group('MotionAlarmLogic', () {
    test('calculates movement delta from acceleration samples', () {
      const previous = AccelerationSample(x: 0, y: 0, z: 9.8);
      const current = AccelerationSample(x: 6, y: 8, z: 9.8);

      expect(MotionAlarmLogic.delta(previous, current), 10);
    });

    test('waits for start delay before arming', () {
      final startedAt = DateTime(2026, 5, 30, 10);

      expect(
        MotionAlarmLogic.isArmed(
          startedAt: startedAt,
          now: startedAt.add(const Duration(seconds: 4)),
          delay: const Duration(seconds: 5),
        ),
        isFalse,
      );
      expect(
        MotionAlarmLogic.isArmed(
          startedAt: startedAt,
          now: startedAt.add(const Duration(seconds: 5)),
          delay: const Duration(seconds: 5),
        ),
        isTrue,
      );
    });

    test('uses sensitivity thresholds to trigger alarms', () {
      expect(
        MotionAlarmLogic.shouldTrigger(
          delta: 5.5,
          sensitivity: MotionSensitivity.medium,
        ),
        isTrue,
      );
      expect(
        MotionAlarmLogic.shouldTrigger(
          delta: 2.0,
          sensitivity: MotionSensitivity.medium,
        ),
        isFalse,
      );
    });

    test('exactly meeting the start delay arms (boundary)', () {
      final startedAt = DateTime(2026, 5, 30, 10);
      expect(
        MotionAlarmLogic.isArmed(
          startedAt: startedAt,
          now: startedAt,
          delay: Duration.zero,
        ),
        isTrue,
        reason: 'A zero delay should arm immediately.',
      );
    });
  });

  group('AlarmSound persistence mapping', () {
    test('round-trips through its persisted name', () {
      for (final sound in AlarmSound.values) {
        expect(AlarmSound.fromName(sound.name), sound);
      }
    });

    test('falls back to siren for unknown or null names', () {
      expect(AlarmSound.fromName(null), AlarmSound.siren);
      expect(AlarmSound.fromName('does_not_exist'), AlarmSound.siren);
      expect(AlarmSound.fromName(''), AlarmSound.siren);
    });

    test('each sound points at a bundled wav asset', () {
      expect(AlarmSound.siren.asset, 'sounds/siren.wav');
      expect(AlarmSound.beep.asset, 'sounds/beep_alarm.wav');
    });
  });
}
