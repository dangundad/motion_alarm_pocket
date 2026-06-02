import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

import '../domain/motion_alarm_logic.dart';

/// Plays the real anti-theft alarm: a bundled tone looped at full volume plus
/// a vibration pulse. A quiet [SystemSound] is useless when the ringer is off,
/// so this loops an asset through [AudioPlayer] and falls back to vibration if
/// audio cannot start. Reference: anti_theft_charger_alarm/AlertService.
class AlertService extends GetxService {
  static AlertService get to => Get.find<AlertService>();

  final isActive = false.obs;
  final AudioPlayer _player = AudioPlayer();
  Timer? _vibrationTimer;

  /// Starts the alarm with [sound]. Audio loops at full volume regardless of
  /// the media volume slider; vibration runs alongside unless [vibrate] is off.
  Future<void> start({
    AlarmSound sound = AlarmSound.siren,
    bool vibrate = true,
  }) async {
    if (isActive.value) return;
    isActive.value = true;
    final audioStarted = await _playLoop(sound);
    // If audio failed (no codec, locked output), vibration is the only signal
    // left, so force it on regardless of the caller's preference.
    if (vibrate || !audioStarted) _startVibration();
  }

  /// Plays [sound] briefly for a settings "Test alarm" preview, then stops.
  /// No vibration loop — this is a quick audibility check, not an alarm.
  Future<void> playPreview(
    AlarmSound sound, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    if (isActive.value) return;
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);
      await _player.play(AssetSource(sound.asset));
    } catch (error) {
      debugPrint('Alarm preview failed: $error');
      return;
    }
    Future<void>.delayed(duration, () async {
      try {
        await _player.stop();
      } catch (_) {}
    });
  }

  Future<bool> _playLoop(AlarmSound sound) async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      await _player.play(AssetSource(sound.asset));
      return true;
    } catch (error) {
      debugPrint('Alarm sound failed: $error');
      return false;
    }
  }

  void _startVibration() {
    unawaited(_pulseVibration());
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      unawaited(_pulseVibration());
    });
  }

  Future<void> _pulseVibration() async {
    try {
      await Vibration.vibrate(duration: 700);
    } catch (_) {
      // Some devices or emulators do not expose a vibrator.
    }
  }

  Future<void> stop() async {
    isActive.value = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    try {
      await _player.stop();
    } catch (_) {
      // Ignore if nothing is playing.
    }
    try {
      await Vibration.cancel();
    } catch (_) {
      // Ignore unsupported vibration cancellation.
    }
  }

  @override
  void onClose() {
    _vibrationTimer?.cancel();
    _player.dispose();
    unawaited(Vibration.cancel());
    super.onClose();
  }
}
