import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../admob/ads_banner.dart';
import '../../admob/ads_helper.dart';
import '../../controllers/home_controller.dart';
import '../../domain/motion_alarm_logic.dart';
import '../../routes/app_pages.dart';
import '../../services/purchase_service.dart';
import 'widgets/arm_dial.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            tooltip: 'settings'.tr,
            onPressed: () => Get.toNamed(Routes.settings),
          ),
          Obx(() {
            final premium = PurchaseService.premiumActive;
            return IconButton(
              icon: Icon(
                premium ? LucideIcons.shieldCheck : LucideIcons.crown,
                color: premium
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'premium'.tr,
              onPressed: premium ? null : () => Get.toNamed(Routes.premium),
            );
          }),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (PurchaseService.premiumActive) return const SizedBox.shrink();
        return const SafeArea(
          child: BannerAdWidget(adUnitId: AdHelper.bannerUnitId),
        );
      }),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            SizedBox(height: 8.h),
            Center(
              child: Obx(() => ArmDial(
                    state: _dialState(),
                    armingProgress: controller.armingProgress.value,
                    // Normalize live delta against the high-sensitivity ceiling.
                    motion: (controller.lastDelta.value / 12.0).clamp(0.0, 1.0),
                    onTap: controller.toggleSession,
                  )),
            ),
            SizedBox(height: 20.h),
            Obx(() => _PrimaryButton(
                  isSessionActive: controller.isSessionActive.value,
                  isAlarmActive: controller.isAlarmActive.value,
                  onToggle: controller.toggleSession,
                  onDismiss: controller.stopAlarm,
                )),
            SizedBox(height: 8.h),
            Obx(() => controller.sensorError.value
                ? _SensorErrorBanner(onRetry: controller.startSession)
                : const SizedBox.shrink()),
            SizedBox(height: 8.h),
            Obx(() => _QuickSettings(
                  delaySeconds: controller.delaySeconds.value,
                  sensitivity: controller.sensitivity.value,
                  alarmSound: controller.alarmSound.value,
                  enabled: !controller.isSessionActive.value,
                  onDelayChanged: controller.setDelay,
                  onSensitivityChanged: controller.setSensitivity,
                  onSoundChanged: controller.setAlarmSound,
                )),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(LucideIcons.history,
                    size: 18.r,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 8.w),
                Text('history'.tr,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 8.h),
            Obx(() => controller.history.isEmpty
                ? _EmptyState(
                    icon: LucideIcons.history, text: 'no_history'.tr)
                : Column(
                    children: controller.history
                        .take(5)
                        .map((e) => _HistoryTile(entry: e))
                        .toList(),
                  )),
            SizedBox(height: 12.h),
            Obx(() {
              if (PurchaseService.premiumActive) return const SizedBox.shrink();
              return _RemoveAdsCta();
            }),
            SizedBox(height: 12.h),
            Text(
              'policy_note'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  ArmDialState _dialState() {
    if (controller.isAlarmActive.value) return ArmDialState.alarm;
    if (controller.isArmed.value) return ArmDialState.armed;
    if (controller.isSessionActive.value) return ArmDialState.arming;
    return ArmDialState.disarmed;
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.isSessionActive,
    required this.isAlarmActive,
    required this.onToggle,
    required this.onDismiss,
  });

  final bool isSessionActive;
  final bool isAlarmActive;
  final VoidCallback onToggle;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Alarm state: an unmistakable full-width crimson DISMISS affordance.
    // Always clearly app UI — never an OS-style lock screen.
    if (isAlarmActive) {
      return FilledButton.icon(
        onPressed: onDismiss,
        style: FilledButton.styleFrom(
          minimumSize: Size(double.infinity, 64.h),
          backgroundColor: cs.error,
          foregroundColor: cs.onError,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        icon: const Icon(LucideIcons.bellOff),
        label: Text('dismiss_alarm'.tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
      );
    }
    return FilledButton.icon(
      onPressed: onToggle,
      style: FilledButton.styleFrom(
        minimumSize: Size(double.infinity, 60.h),
        backgroundColor: isSessionActive ? cs.surfaceContainerHighest : null,
        foregroundColor: isSessionActive ? cs.onSurface : null,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      icon: Icon(isSessionActive ? LucideIcons.square : LucideIcons.power),
      label: Text(
        isSessionActive ? 'disarm'.tr : 'arm'.tr,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SensorErrorBanner extends StatelessWidget {
  const _SensorErrorBanner({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.triangleAlert,
              size: 20.r, color: cs.onErrorContainer),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'sensor_unavailable'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onErrorContainer,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: onRetry,
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }
}

class _QuickSettings extends StatelessWidget {
  const _QuickSettings({
    required this.delaySeconds,
    required this.sensitivity,
    required this.alarmSound,
    required this.enabled,
    required this.onDelayChanged,
    required this.onSensitivityChanged,
    required this.onSoundChanged,
  });

  final int delaySeconds;
  final MotionSensitivity sensitivity;
  final AlarmSound alarmSound;
  final bool enabled;
  final ValueChanged<double> onDelayChanged;
  final ValueChanged<MotionSensitivity> onSensitivityChanged;
  final ValueChanged<AlarmSound> onSoundChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.slidersHorizontal,
                    size: 18.r, color: cs.onSurfaceVariant),
                SizedBox(width: 8.w),
                Text('settings'.tr,
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Get.toNamed(Routes.settings),
                  icon: Icon(LucideIcons.chevronRight, size: 16.r),
                  label: Text('more_settings'.tr,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(LucideIcons.timer, size: 18.r, color: cs.onSurfaceVariant),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'delay_label'.trParams({'n': '$delaySeconds'}),
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Slider(
              value: delaySeconds.toDouble(),
              min: 3,
              max: 15,
              divisions: 12,
              label: '${delaySeconds}s',
              onChanged: enabled ? onDelayChanged : null,
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(LucideIcons.activity,
                    size: 18.r, color: cs.onSurfaceVariant),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text('sensitivity'.tr,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SegmentedButton<MotionSensitivity>(
              segments: [
                ButtonSegment(
                  value: MotionSensitivity.low,
                  label: Text('sensitivity_low'.tr),
                  icon: const Icon(LucideIcons.minus),
                ),
                ButtonSegment(
                  value: MotionSensitivity.medium,
                  label: Text('sensitivity_medium'.tr),
                  icon: const Icon(LucideIcons.equal),
                ),
                ButtonSegment(
                  value: MotionSensitivity.high,
                  label: Text('sensitivity_high'.tr),
                  icon: const Icon(LucideIcons.plus),
                ),
              ],
              selected: {sensitivity},
              onSelectionChanged:
                  enabled ? (s) => onSensitivityChanged(s.first) : null,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(LucideIcons.volume2,
                    size: 18.r, color: cs.onSurfaceVariant),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text('alarm_sound'.tr,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SegmentedButton<AlarmSound>(
              segments: [
                ButtonSegment(
                  value: AlarmSound.siren,
                  label: Text('sound_siren'.tr),
                  icon: const Icon(LucideIcons.siren),
                ),
                ButtonSegment(
                  value: AlarmSound.beep,
                  label: Text('sound_beep'.tr),
                  icon: const Icon(LucideIcons.bellRing),
                ),
              ],
              selected: {alarmSound},
              onSelectionChanged:
                  enabled ? (s) => onSoundChanged(s.first) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});
  final Map<String, dynamic> entry;

  String _formatTime() {
    final raw = entry['createdAt']?.toString() ?? '';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '$h:$m';
    }
    return '${dt.month}/${dt.day} $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: ListTile(
        leading: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.errorContainer,
          ),
          child: Icon(LucideIcons.activity,
              size: 20.r, color: cs.onErrorContainer),
        ),
        title: Text(
          entry['title']?.toString() ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          entry['detail']?.toString() ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatTime(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        dense: true,
      ),
    );
  }
}

class _RemoveAdsCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Get.toNamed(Routes.premium),
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.heart, size: 16.r, color: cs.primary),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                'remove_ads_cta'.tr,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(LucideIcons.chevronRight, size: 14.r, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: cs.onSurfaceVariant),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
