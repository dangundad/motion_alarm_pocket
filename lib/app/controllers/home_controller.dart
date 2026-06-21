import 'dart:async';

import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../admob/ads_interstitial.dart';
import '../domain/motion_alarm_logic.dart';
import '../services/alert_service.dart';
import '../services/hive_service.dart';
import '../services/purchase_service.dart';

class HomeController extends GetxController {
  final isSessionActive = false.obs;
  final isAlarmActive = false.obs;
  final isArmed = false.obs;
  final sensitivity = MotionSensitivity.medium.obs;
  final delaySeconds = 5.obs;
  final alarmSound = AlarmSound.siren.obs;
  final hapticsEnabled = true.obs;
  final lastDelta = 0.0.obs;

  /// 0..1 progress of the arming countdown. Drives the hero dial ring while
  /// the session is counting down to ARMED.
  final armingProgress = 0.0.obs;

  /// True after a sensor stream error so the UI can offer a retry instead of
  /// silently dropping the session.
  final sensorError = false.obs;

  final history = <Map<String, dynamic>>[].obs;

  DateTime? _startedAt;
  AccelerationSample? _lastSample;
  StreamSubscription<AccelerometerEvent>? _subscription;
  Timer? _armingTicker;

  static const _kDelay = 'delay_seconds';
  static const _kSensitivity = 'sensitivity';
  static const _kSound = 'alarm_sound';
  static const _kHaptics = 'haptics_enabled';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    history.assignAll(HiveService.to.getHistory());
  }

  void _loadSettings() {
    final savedDelay = HiveService.to.getSetting<int>(_kDelay);
    if (savedDelay != null) delaySeconds.value = savedDelay;
    final savedSens = HiveService.to.getSetting<String>(_kSensitivity);
    if (savedSens != null) {
      sensitivity.value = MotionSensitivity.values.firstWhere(
        (e) => e.name == savedSens,
        orElse: () => MotionSensitivity.medium,
      );
    }
    alarmSound.value =
        AlarmSound.fromName(HiveService.to.getSetting<String>(_kSound));
    final savedHaptics = HiveService.to.getSetting<bool>(_kHaptics);
    if (savedHaptics != null) hapticsEnabled.value = savedHaptics;
  }

  void setDelay(double value) {
    delaySeconds.value = value.round();
    HiveService.to.setSetting(_kDelay, delaySeconds.value);
  }

  void setSensitivity(MotionSensitivity value) {
    sensitivity.value = value;
    HiveService.to.setSetting(_kSensitivity, value.name);
  }

  void setAlarmSound(AlarmSound value) {
    alarmSound.value = value;
    HiveService.to.setSetting(_kSound, value.name);
  }

  void setHaptics(bool value) {
    hapticsEnabled.value = value;
    HiveService.to.setSetting(_kHaptics, value);
  }

  /// Plays the currently selected sound for a couple of seconds so the user
  /// can confirm it is actually audible before relying on it.
  Future<void> testAlarm() async {
    await AlertService.to.playPreview(alarmSound.value);
  }

  Future<void> _onSensorError() async {
    await stopSession();
    sensorError.value = true;
    Get.snackbar(
      'sensor_unavailable'.tr,
      'sensor_retry_hint'.tr,
      duration: const Duration(seconds: 4),
    );
  }

  /// Primary action used by the hero dial and the explicit button: start a
  /// session when idle, otherwise tear it down (also silences any alarm).
  Future<void> toggleSession() async {
    if (isSessionActive.value) {
      await stopSession();
    } else {
      startSession();
    }
  }

  void startSession() {
    if (isSessionActive.value) return;
    sensorError.value = false;
    _startedAt = DateTime.now();
    _lastSample = null;
    isSessionActive.value = true;
    isAlarmActive.value = false;
    isArmed.value = false;
    armingProgress.value = 0.0;
    _startArmingTicker();
    _subscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 80),
    ).listen(_onSensorData, onError: (_) => _onSensorError());
  }

  // A lightweight UI ticker for the countdown ring — independent of the
  // accelerometer cadence so the ring fills smoothly even before the first
  // sensor sample arrives.
  void _startArmingTicker() {
    _armingTicker?.cancel();
    _armingTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final startedAt = _startedAt;
      if (startedAt == null || isArmed.value) return;
      final elapsed = DateTime.now().difference(startedAt).inMilliseconds;
      final total = delaySeconds.value * 1000;
      armingProgress.value =
          total <= 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0);
    });
  }

  void _onSensorData(AccelerometerEvent event) {
    final sample = AccelerationSample(x: event.x, y: event.y, z: event.z);
    final startedAt = _startedAt;
    if (startedAt == null) return;
    // isArmed only ever flips false→true within a session (time is monotonic
    // and the delay is locked while running), so stop recomputing once armed.
    if (!isArmed.value) {
      final nowArmed = MotionAlarmLogic.isArmed(
        startedAt: startedAt,
        now: DateTime.now(),
        delay: Duration(seconds: delaySeconds.value),
      );
      // While still arming, keep tracking the latest sample as the baseline.
      // On the tick that arms, reset the baseline to this sample and skip the
      // trigger check this cycle so residual placement movement from the
      // arming window can't fire the alarm the instant it goes live.
      _lastSample = sample;
      if (nowArmed) {
        isArmed.value = true;
        armingProgress.value = 1.0;
        _armingTicker?.cancel();
        _armingTicker = null;
      }
      return;
    }
    final previous = _lastSample;
    _lastSample = sample;
    if (previous == null || isAlarmActive.value) return;
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
    await AlertService.to.start(
      sound: alarmSound.value,
      vibrate: hapticsEnabled.value,
    );
    await HiveService.to.addHistory({
      'title': 'motion_detected'.tr,
      'detail': 'delta_value'.trParams({'n': delta.toStringAsFixed(1)}),
    });
    history.assignAll(HiveService.to.getHistory());
  }

  Future<void> stopAlarm() async {
    isAlarmActive.value = false;
    await AlertService.to.stop();
    final showAd = _shouldShowAd();
    if (showAd) {
      try {
        await Get.find<InterstitialAdManager>().showAfterNaturalBreak();
      } catch (_) {}
    }
  }

  bool _shouldShowAd() => !PurchaseService.premiumActive;

  Future<void> stopSession() async {
    await _subscription?.cancel();
    _subscription = null;
    _armingTicker?.cancel();
    _armingTicker = null;
    isSessionActive.value = false;
    isArmed.value = false;
    armingProgress.value = 0.0;
    lastDelta.value = 0.0;
    await stopAlarm();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _armingTicker?.cancel();
    super.onClose();
  }
}
