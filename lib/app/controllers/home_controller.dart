import 'dart:async';

import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../admob/ads_interstitial.dart';
import '../domain/motion_alarm_logic.dart';
import '../services/alert_service.dart';
import '../services/hive_service.dart';

class HomeController extends GetxController {
  final isSessionActive = false.obs;
  final isAlarmActive = false.obs;
  final isArmed = false.obs;
  final sensitivity = MotionSensitivity.medium.obs;
  final delaySeconds = 5.obs;
  final lastDelta = 0.0.obs;
  final history = <Map<String, dynamic>>[].obs;

  DateTime? _startedAt;
  AccelerationSample? _lastSample;
  StreamSubscription<AccelerometerEvent>? _subscription;

  @override
  void onInit() {
    super.onInit();
    history.assignAll(HiveService.to.getHistory());
  }

  void setDelay(double value) => delaySeconds.value = value.round();
  void setSensitivity(MotionSensitivity value) => sensitivity.value = value;

  void startSession() {
    if (isSessionActive.value) return;
    _startedAt = DateTime.now();
    _lastSample = null;
    isSessionActive.value = true;
    isAlarmActive.value = false;
    isArmed.value = false;
    _subscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 80),
    ).listen(_onSensorData, onError: (_) => stopSession());
  }

  void _onSensorData(AccelerometerEvent event) {
    final sample = AccelerationSample(x: event.x, y: event.y, z: event.z);
    final startedAt = _startedAt;
    if (startedAt == null) return;
    isArmed.value = MotionAlarmLogic.isArmed(
      startedAt: startedAt,
      now: DateTime.now(),
      delay: Duration(seconds: delaySeconds.value),
    );
    final previous = _lastSample;
    _lastSample = sample;
    if (previous == null || !isArmed.value || isAlarmActive.value) return;
    final delta = MotionAlarmLogic.delta(previous, sample);
    lastDelta.value = delta;
    if (MotionAlarmLogic.shouldTrigger(
      delta: delta,
      sensitivity: sensitivity.value,
    )) {
      triggerAlarm(delta);
    }
  }

  Future<void> triggerAlarm(double delta) async {
    isAlarmActive.value = true;
    await AlertService.to.start();
    await HiveService.to.addHistory({
      'title': 'Motion detected',
      'detail': 'Delta ${delta.toStringAsFixed(1)}',
    });
    history.assignAll(HiveService.to.getHistory());
  }

  Future<void> stopAlarm() async {
    isAlarmActive.value = false;
    await AlertService.to.stop();
    await Get.find<InterstitialAdManager>().showAfterNaturalBreak();
  }

  Future<void> stopSession() async {
    await _subscription?.cancel();
    _subscription = null;
    isSessionActive.value = false;
    isArmed.value = false;
    await stopAlarm();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
