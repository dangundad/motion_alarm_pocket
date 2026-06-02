import 'package:get/get.dart';

import '../domain/motion_alarm_logic.dart';
import '../services/alert_service.dart';
import 'home_controller.dart';

/// Thin facade over [HomeController] so the Settings screen edits the same
/// persisted state the home screen arms with — no duplicate source of truth.
/// Reactive fields are forwarded directly so Obx widgets on both screens
/// update together.
class SettingsController extends GetxController {
  HomeController get _home => Get.find<HomeController>();

  RxInt get delaySeconds => _home.delaySeconds;
  Rx<MotionSensitivity> get sensitivity => _home.sensitivity;
  Rx<AlarmSound> get alarmSound => _home.alarmSound;
  RxBool get hapticsEnabled => _home.hapticsEnabled;

  /// Editing settings while a session is armed would be confusing, so the
  /// session-bound controls are locked while running.
  bool get isSessionActive => _home.isSessionActive.value;

  void setDelay(double value) => _home.setDelay(value);
  void setSensitivity(MotionSensitivity value) => _home.setSensitivity(value);
  void setAlarmSound(AlarmSound value) => _home.setAlarmSound(value);
  void setHaptics(bool value) => _home.setHaptics(value);

  Future<void> testAlarm() => _home.testAlarm();

  /// Stops any preview if the user leaves the screen mid-test.
  @override
  void onClose() {
    if (!_home.isAlarmActive.value) {
      AlertService.to.stop();
    }
    super.onClose();
  }
}
