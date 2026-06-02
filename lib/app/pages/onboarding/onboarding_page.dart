import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../controllers/onboarding_controller.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip — hidden on the last step.
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 8.w, top: 4.h),
                child: Obx(() => controller.isLastPage
                    ? SizedBox(height: 40.h)
                    : TextButton(
                        onPressed: controller.skip,
                        child: Text('onboarding_skip'.tr,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      )),
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: controller.onPageChanged,
                children: [
                  _OnboardingStep(
                    icon: LucideIcons.bellRing,
                    titleKey: 'onboarding_intro_title',
                    descKey: 'onboarding_intro_desc',
                  ),
                  _OnboardingStep(
                    icon: LucideIcons.slidersHorizontal,
                    titleKey: 'onboarding_how_title',
                    descKey: 'onboarding_how_desc',
                    child: const _SensitivityDemo(),
                  ),
                  _OnboardingStep(
                    icon: LucideIcons.shieldCheck,
                    titleKey: 'onboarding_ready_title',
                    descKey: 'onboarding_ready_desc',
                    child: const _PrivacyPill(),
                  ),
                ],
              ),
            ),
            Obx(() => _PageIndicator(
                  currentPage: controller.currentPage.value,
                  total: OnboardingController.totalPages,
                )),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: Size(double.infinity, 54.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r)),
                      ),
                      onPressed: controller.isLastPage
                          ? controller.complete
                          : controller.nextPage,
                      child: Text(
                        controller.isLastPage
                            ? 'onboarding_get_started'.tr
                            : 'onboarding_next'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 17.sp, fontWeight: FontWeight.w700),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    this.child,
  });

  final IconData icon;
  final String titleKey;
  final String descKey;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 120.r,
            height: 120.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: Icon(icon, size: 56.r, color: cs.onPrimaryContainer),
          ),
          SizedBox(height: 28.h),
          Text(
            titleKey.tr,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Text(
            descKey.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          if (child != null) ...[
            SizedBox(height: 24.h),
            child!,
          ],
        ],
      ),
    );
  }
}

/// A lightweight, non-interactive demo of the three sensitivity levels so a
/// new user understands the trade-off before reaching the home screen.
class _SensitivityDemo extends StatelessWidget {
  const _SensitivityDemo();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            _SensitivityRow(
              filled: 1,
              labelKey: 'sensitivity_low',
              descKey: 'sensitivity_low_desc',
            ),
            SizedBox(height: 12.h),
            _SensitivityRow(
              filled: 2,
              labelKey: 'sensitivity_medium',
              descKey: 'sensitivity_medium_desc',
            ),
            SizedBox(height: 12.h),
            _SensitivityRow(
              filled: 3,
              labelKey: 'sensitivity_high',
              descKey: 'sensitivity_high_desc',
            ),
          ],
        ),
      ),
    );
  }
}

class _SensitivityRow extends StatelessWidget {
  const _SensitivityRow({
    required this.filled,
    required this.labelKey,
    required this.descKey,
  });
  final int filled;
  final String labelKey;
  final String descKey;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Three bars indicating relative sensitivity.
        Row(
          children: List.generate(3, (i) {
            final on = i < filled;
            return Container(
              width: 8.w,
              height: 18.h,
              margin: EdgeInsets.only(right: 3.w),
              decoration: BoxDecoration(
                color: on ? cs.primary : cs.outlineVariant,
                borderRadius: BorderRadius.circular(2.r),
              ),
            );
          }),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelKey.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                descKey.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrivacyPill extends StatelessWidget {
  const _PrivacyPill();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.lock, size: 15.r, color: cs.onSecondaryContainer),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'onboarding_privacy_note'.tr,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
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

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.total});
  final int currentPage;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: active ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.outlineVariant,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
