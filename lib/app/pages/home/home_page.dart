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

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  bool get _isPremium {
    try {
      return PurchaseService.to.isPremium.value;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
        actions: [
          Obx(() {
            final premium = _isPremium;
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
        if (_isPremium) return const SizedBox.shrink();
        return const SafeArea(
          child: BannerAdWidget(adUnitId: AdHelper.bannerUnitId),
        );
      }),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            Obx(() => _StatusCircle(
                  isSessionActive: controller.isSessionActive.value,
                  isArmed: controller.isArmed.value,
                  isAlarmActive: controller.isAlarmActive.value,
                  lastDelta: controller.lastDelta.value,
                )),
            SizedBox(height: 20.h),
            Obx(() => _MainActionButton(
                  isSessionActive: controller.isSessionActive.value,
                  isAlarmActive: controller.isAlarmActive.value,
                  onStart: controller.startSession,
                  onStop: controller.stopSession,
                  onStopAlarm: controller.stopAlarm,
                )),
            SizedBox(height: 16.h),
            Obx(() => _SettingsCard(
                  delaySeconds: controller.delaySeconds.value,
                  sensitivity: controller.sensitivity.value,
                  enabled: !controller.isSessionActive.value,
                  onDelayChanged: controller.setDelay,
                  onSensitivityChanged: controller.setSensitivity,
                )),
            SizedBox(height: 16.h),
            const _HowToUseCard(),
            SizedBox(height: 16.h),
            Text('history'.tr,
                style: Theme.of(context).textTheme.titleMedium),
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
              if (_isPremium) return const SizedBox.shrink();
              return _RemoveAdsCta();
            }),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({
    required this.isSessionActive,
    required this.isArmed,
    required this.isAlarmActive,
    required this.lastDelta,
  });

  final bool isSessionActive;
  final bool isArmed;
  final bool isAlarmActive;
  final double lastDelta;

  Color _circleColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (isAlarmActive) return cs.error;
    if (isArmed) return cs.primary;
    if (isSessionActive) return cs.tertiary;
    return cs.surfaceContainerHighest;
  }

  Color _iconColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (isAlarmActive) return cs.onError;
    if (isArmed) return cs.onPrimary;
    if (isSessionActive) return cs.onTertiary;
    return cs.onSurfaceVariant;
  }

  IconData get _icon {
    if (isAlarmActive) return LucideIcons.siren;
    if (isArmed) return LucideIcons.shieldCheck;
    if (isSessionActive) return LucideIcons.timer;
    return LucideIcons.shield;
  }

  String _statusText() {
    if (isAlarmActive) return 'alarm_active'.tr;
    if (isArmed) return 'armed'.tr;
    if (isSessionActive) return 'arming'.tr;
    return 'idle'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (lastDelta / 18.0).clamp(0.0, 1.0);
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160.r,
                height: 160.r,
                child: CircularProgressIndicator(
                  value: isArmed ? progress : null,
                  strokeWidth: 6,
                  backgroundColor: cs.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAlarmActive ? cs.error : cs.primary,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleColor(context),
                  boxShadow: (isAlarmActive || isArmed)
                      ? [
                          BoxShadow(
                            color: _circleColor(context).withAlpha(100),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ]
                      : [],
                ),
                child: Icon(_icon, size: 52.r, color: _iconColor(context)),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          _statusText(),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (isArmed && lastDelta > 0)
          Text(
            '${'delta'.tr}: ${lastDelta.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
      ],
    );
  }
}

class _MainActionButton extends StatelessWidget {
  const _MainActionButton({
    required this.isSessionActive,
    required this.isAlarmActive,
    required this.onStart,
    required this.onStop,
    required this.onStopAlarm,
  });

  final bool isSessionActive;
  final bool isAlarmActive;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onStopAlarm;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (isAlarmActive) {
      return FilledButton.icon(
        onPressed: onStopAlarm,
        style: FilledButton.styleFrom(
          minimumSize: Size(double.infinity, 60.h),
          backgroundColor: cs.error,
          foregroundColor: cs.onError,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        icon: const Icon(LucideIcons.bellOff),
        label: Text('stop_alarm'.tr, style: TextStyle(fontSize: 18.sp)),
      );
    }
    return FilledButton.icon(
      onPressed: isSessionActive ? onStop : onStart,
      style: FilledButton.styleFrom(
        minimumSize: Size(double.infinity, 60.h),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      icon: Icon(isSessionActive ? LucideIcons.square : LucideIcons.play),
      label: Text(
        isSessionActive ? 'stop'.tr : 'start'.tr,
        style: TextStyle(fontSize: 18.sp),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.delaySeconds,
    required this.sensitivity,
    required this.enabled,
    required this.onDelayChanged,
    required this.onSensitivityChanged,
  });

  final int delaySeconds;
  final MotionSensitivity sensitivity;
  final bool enabled;
  final ValueChanged<double> onDelayChanged;
  final ValueChanged<MotionSensitivity> onSensitivityChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('settings'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(LucideIcons.timer,
                    size: 18.r, color: cs.onSurfaceVariant),
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
                  child: Text(
                    'sensitivity'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
          ],
        ),
      ),
    );
  }
}

class _HowToUseCard extends StatelessWidget {
  const _HowToUseCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('how_to_use'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10.h),
            _Step(
                num: 1,
                icon: LucideIcons.slidersHorizontal,
                textKey: 'step_settings'),
            _Step(
                num: 2,
                icon: LucideIcons.smartphone,
                textKey: 'step_place'),
            _Step(
                num: 3,
                icon: LucideIcons.bellOff,
                textKey: 'step_stop'),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(
      {required this.num, required this.icon, required this.textKey});
  final int num;
  final IconData icon;
  final String textKey;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Container(
            width: 26.r,
            height: 26.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: Center(
              child: Text(
                '$num',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(icon, size: 18.r, color: cs.onSurfaceVariant),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              textKey.tr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
