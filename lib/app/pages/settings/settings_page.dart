import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../controllers/settings_controller.dart';
import '../../domain/motion_alarm_logic.dart';
import '../../services/purchase_service.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: Get.back,
        ),
        title: Text('settings'.tr),
      ),
      body: SafeArea(
        child: Obx(() {
          final locked = controller.isSessionActive;
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            children: [
              if (locked) ...[
                _LockedBanner(),
                SizedBox(height: 12.h),
              ],
              _SectionCard(
                title: 'detection_section'.tr,
                icon: LucideIcons.radar,
                children: [
                  _DelayControl(
                    delaySeconds: controller.delaySeconds.value,
                    enabled: !locked,
                    onChanged: controller.setDelay,
                  ),
                  SizedBox(height: 16.h),
                  _SensitivityControl(
                    sensitivity: controller.sensitivity.value,
                    enabled: !locked,
                    onChanged: controller.setSensitivity,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _SectionCard(
                title: 'alarm_section'.tr,
                icon: LucideIcons.volume2,
                children: [
                  _SoundControl(
                    alarmSound: controller.alarmSound.value,
                    enabled: !locked,
                    onChanged: controller.setAlarmSound,
                    onTest: controller.testAlarm,
                  ),
                  SizedBox(height: 8.h),
                  Divider(
                      height: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withAlpha(120)),
                  SizedBox(height: 4.h),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(LucideIcons.vibrate,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    title: Text('haptics'.tr),
                    subtitle: Text('haptics_desc'.tr,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    value: controller.hapticsEnabled.value,
                    onChanged: controller.setHaptics,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _SectionCard(
                title: 'about_section'.tr,
                icon: LucideIcons.info,
                children: [
                  Obx(() {
                    if (PurchaseService.premiumActive) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(LucideIcons.shieldCheck,
                            color: Theme.of(context).colorScheme.tertiary),
                        title: Text('premium_unlocked'.tr,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      );
                    }
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(LucideIcons.rotateCcw),
                      title: Text('premium_restore'.tr,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: PurchaseService.to.restorePurchases,
                    );
                  }),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.tag),
                    title: Text('version'.tr,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Text('1.0.0'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      'policy_note'.tr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          );
        }),
      ),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.lock, size: 18.r, color: cs.onSecondaryContainer),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'settings_locked'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSecondaryContainer,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

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
                Icon(icon, size: 18.r, color: cs.primary),
                SizedBox(width: 8.w),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 12.h),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DelayControl extends StatelessWidget {
  const _DelayControl({
    required this.delaySeconds,
    required this.enabled,
    required this.onChanged,
  });
  final int delaySeconds;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('delay_label'.trParams({'n': '$delaySeconds'}),
            style: Theme.of(context).textTheme.bodyLarge),
        Text(
          'delay_desc'.tr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Slider(
          value: delaySeconds.toDouble(),
          min: 3,
          max: 15,
          divisions: 12,
          label: '${delaySeconds}s',
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class _SensitivityControl extends StatelessWidget {
  const _SensitivityControl({
    required this.sensitivity,
    required this.enabled,
    required this.onChanged,
  });
  final MotionSensitivity sensitivity;
  final bool enabled;
  final ValueChanged<MotionSensitivity> onChanged;

  String _explanation() {
    switch (sensitivity) {
      case MotionSensitivity.low:
        return 'sensitivity_low_desc'.tr;
      case MotionSensitivity.medium:
        return 'sensitivity_medium_desc'.tr;
      case MotionSensitivity.high:
        return 'sensitivity_high_desc'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('sensitivity'.tr,
            style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<MotionSensitivity>(
            segments: [
              ButtonSegment(
                value: MotionSensitivity.low,
                label: Text('sensitivity_low'.tr),
              ),
              ButtonSegment(
                value: MotionSensitivity.medium,
                label: Text('sensitivity_medium'.tr),
              ),
              ButtonSegment(
                value: MotionSensitivity.high,
                label: Text('sensitivity_high'.tr),
              ),
            ],
            selected: {sensitivity},
            onSelectionChanged:
                enabled ? (s) => onChanged(s.first) : null,
          ),
        ),
        SizedBox(height: 8.h),
        // One-line explanation of the currently selected level.
        Text(
          _explanation(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SoundControl extends StatelessWidget {
  const _SoundControl({
    required this.alarmSound,
    required this.enabled,
    required this.onChanged,
    required this.onTest,
  });
  final AlarmSound alarmSound;
  final bool enabled;
  final ValueChanged<AlarmSound> onChanged;
  final Future<void> Function() onTest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('alarm_sound'.tr,
            style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AlarmSound>(
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
            onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
          ),
        ),
        SizedBox(height: 10.h),
        OutlinedButton.icon(
          onPressed: () => onTest(),
          icon: Icon(LucideIcons.play, size: 18.r),
          label: Text('test_alarm'.tr,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 46.h),
          ),
        ),
      ],
    );
  }
}
