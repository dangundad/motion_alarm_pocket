import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

class AlertService extends GetxService {
  static AlertService get to => Get.find<AlertService>();

  final isActive = false.obs;
  Timer? _timer;

  Future<void> start({bool vibrate = true}) async {
    if (isActive.value) return;
    isActive.value = true;
    await _pulse(vibrate: vibrate);
    _timer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      unawaited(_pulse(vibrate: vibrate));
    });
  }

  Future<void> _pulse({required bool vibrate}) async {
    await SystemSound.play(SystemSoundType.alert);
    if (!vibrate) return;
    try {
      await Vibration.vibrate(duration: 300);
    } catch (_) {
      // Some devices or emulators do not expose a vibrator.
    }
  }

  Future<void> stop() async {
    isActive.value = false;
    _timer?.cancel();
    _timer = null;
    try {
      await Vibration.cancel();
    } catch (_) {
      // Ignore unsupported vibration cancellation.
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    unawaited(stop());
    super.onClose();
  }
}
