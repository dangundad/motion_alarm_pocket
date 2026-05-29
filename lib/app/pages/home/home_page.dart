import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../admob/ads_banner.dart';
import '../../admob/ads_helper.dart';
import '../../controllers/home_controller.dart';
import '../../domain/motion_alarm_logic.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('app_title'.tr)),
      bottomNavigationBar: const SafeArea(
        child: BannerAdWidget(adUnitId: AdHelper.bannerUnitId),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            Obx(() => Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              controller.isAlarmActive.value
                                  ? LucideIcons.siren
                                  : LucideIcons.shield,
                              size: 34.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                controller.isAlarmActive.value
                                    ? 'Alarm sounding'
                                    : controller.isArmed.value
                                        ? 'Armed and watching'
                                        : 'Start delay active',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text('Last movement delta: ${controller.lastDelta.value.toStringAsFixed(1)}'),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 12.h),
            Obx(() => Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('settings'.tr, style: Theme.of(context).textTheme.titleMedium),
                        Slider(
                          value: controller.delaySeconds.value.toDouble(),
                          min: 3,
                          max: 15,
                          divisions: 12,
                          label: '${controller.delaySeconds.value}s delay',
                          onChanged: controller.isSessionActive.value ? null : controller.setDelay,
                        ),
                        SegmentedButton<MotionSensitivity>(
                          segments: const [
                            ButtonSegment(value: MotionSensitivity.low, label: Text('Low')),
                            ButtonSegment(value: MotionSensitivity.medium, label: Text('Med')),
                            ButtonSegment(value: MotionSensitivity.high, label: Text('High')),
                          ],
                          selected: {controller.sensitivity.value},
                          onSelectionChanged: controller.isSessionActive.value
                              ? null
                              : (values) => controller.setSensitivity(values.first),
                        ),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 12.h),
            Obx(() => FilledButton.icon(
                  onPressed: controller.isAlarmActive.value
                      ? controller.stopAlarm
                      : controller.isSessionActive.value
                          ? controller.stopSession
                          : controller.startSession,
                  icon: Icon(controller.isSessionActive.value ? LucideIcons.square : LucideIcons.play),
                  label: Text(controller.isSessionActive.value ? 'stop'.tr : 'start'.tr),
                )),
            SizedBox(height: 18.h),
            Text('history'.tr, style: Theme.of(context).textTheme.titleMedium),
            Obx(() => controller.history.isEmpty
                ? _Notice(text: 'no_history'.tr)
                : Column(
                    children: controller.history
                        .take(5)
                        .map((entry) => ListTile(
                              leading: const Icon(LucideIcons.activity),
                              title: Text(entry['title']?.toString() ?? ''),
                              subtitle: Text(entry['detail']?.toString() ?? ''),
                            ))
                        .toList(),
                  )),
            _Notice(text: 'ad_hint'.tr),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Text(text),
        ),
      );
}
