import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/purchase_service.dart';

class _TierMeta {
  const _TierMeta({
    required this.id,
    required this.emoji,
    required this.titleKey,
    required this.descKey,
    required this.usdFallback,
    this.popular = false,
  });
  final String id;
  final String emoji;
  final String titleKey;
  final String descKey;
  final String usdFallback;
  final bool popular;
}

const _tiers = [
  _TierMeta(
    id: 'motion_alarm_pocket_premium_small',
    emoji: '☕',
    titleKey: 'premium_option_small_title',
    descKey: 'premium_option_small_desc',
    usdFallback: r'$0.99',
  ),
  _TierMeta(
    id: 'motion_alarm_pocket_premium_medium',
    emoji: '🛡️',
    titleKey: 'premium_option_medium_title',
    descKey: 'premium_option_medium_desc',
    usdFallback: r'$2.99',
    popular: true,
  ),
  _TierMeta(
    id: 'motion_alarm_pocket_premium_large',
    emoji: '💪',
    titleKey: 'premium_option_large_title',
    descKey: 'premium_option_large_desc',
    usdFallback: r'$4.99',
  ),
];

const _benefits = [
  (
    icon: LucideIcons.tvMinimalPlay,
    titleKey: 'premium_benefit_no_ads',
    descKey: 'premium_benefit_no_ads_desc'
  ),
  (
    icon: LucideIcons.infinity,
    titleKey: 'premium_benefit_lifetime',
    descKey: 'premium_benefit_lifetime_desc'
  ),
  (
    icon: LucideIcons.heart,
    titleKey: 'premium_benefit_support',
    descKey: 'premium_benefit_support_desc'
  ),
  (
    icon: LucideIcons.shieldCheck,
    titleKey: 'premium_benefit_peace',
    descKey: 'premium_benefit_peace_desc'
  ),
];

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  int _selectedIndex = 1;

  PurchaseService get _svc => PurchaseService.to;

  String _priceFor(_TierMeta tier) {
    final match = _svc.products.where((p) => p.id == tier.id);
    if (match.isNotEmpty) return match.first.price;
    return tier.usdFallback;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: Get.back,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.crown, size: 20.r, color: cs.primary),
            SizedBox(width: 8.w),
            Text('premium'.tr),
          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final isPremium = _svc.isPremium.value;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 96.h),
                children: [
                  _Header(isPremium: isPremium),
                  SizedBox(height: 20.h),
                  for (int i = 0; i < _tiers.length; i++) ...[
                    _TierCard(
                      tier: _tiers[i],
                      price: _priceFor(_tiers[i]),
                      selected: _selectedIndex == i,
                      isPremium: isPremium,
                      onTap: isPremium
                          ? null
                          : () => setState(() => _selectedIndex = i),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  SizedBox(height: 16.h),
                  _BenefitsGrid(),
                  SizedBox(height: 16.h),
                  if (!isPremium)
                    Center(
                      child: TextButton(
                        onPressed: _svc.isLoading.value
                            ? null
                            : _svc.restorePurchases,
                        child: Text('premium_restore'.tr),
                      ),
                    ),
                ],
              ),
            ),
            _BottomPurchaseBar(
              isPremium: isPremium,
              isLoading: _svc.isLoading.value,
              isAvailable: _svc.available.value,
              onTap: () => _svc.purchaseProduct(_tiers[_selectedIndex].id),
            ),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isPremium});
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 88.r,
          height: 88.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: cs.primary.withAlpha(60),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isPremium ? LucideIcons.shieldCheck : LucideIcons.crown,
            size: 44.r,
            color: cs.primary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          isPremium ? 'premium_unlocked'.tr : 'premium_title'.tr,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
        Text(
          'premium_subtitle'.tr,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.price,
    required this.selected,
    required this.isPremium,
    required this.onTap,
  });

  final _TierMeta tier;
  final String price;
  final bool selected;
  final bool isPremium;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: selected
                ? cs.primaryContainer.withAlpha(71)
                : cs.surfaceContainerLow,
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
              width: selected ? 1.6 : 1.0,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? cs.primary
                          : cs.primaryContainer.withAlpha(178),
                    ),
                    child: Center(
                      child: selected
                          ? Icon(LucideIcons.check,
                              size: 18.r, color: cs.onPrimary)
                          : Text(tier.emoji,
                              style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.titleKey.tr,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          tier.descKey.tr,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isPremium ? '✓' : price,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (tier.popular)
          Positioned(
            top: -1,
            right: 12.w,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(8.r)),
              ),
              child: Text(
                'popular'.tr,
                style: TextStyle(
                  color: cs.onError,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BenefitsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _benefits
          .map(
            (b) => Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: cs.surfaceContainerLow,
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(b.icon, size: 22.r, color: cs.primary),
                  SizedBox(height: 6.h),
                  Text(b.titleKey.tr,
                      style: Theme.of(context).textTheme.labelLarge),
                  Text(
                    b.descKey.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BottomPurchaseBar extends StatelessWidget {
  const _BottomPurchaseBar({
    required this.isPremium,
    required this.isLoading,
    required this.isAvailable,
    required this.onTap,
  });

  final bool isPremium;
  final bool isLoading;
  final bool isAvailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canBuy = !isPremium && !isLoading && isAvailable;

    Widget content;
    if (isPremium) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.check, size: 20.r),
          SizedBox(width: 8.w),
          Text('premium_unlocked'.tr),
        ],
      );
    } else if (isLoading) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8.w),
          Text('premium_loading'.tr),
        ],
      );
    } else {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shoppingCart, size: 20.r),
          SizedBox(width: 8.w),
          Text(isAvailable
              ? 'premium_purchase'.tr
              : 'premium_store_unavailable'.tr),
        ],
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
        child: FilledButton(
          onPressed: canBuy ? onTap : null,
          style: FilledButton.styleFrom(
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            backgroundColor: isPremium ? cs.tertiary : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
