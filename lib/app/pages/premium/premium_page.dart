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
  (icon: LucideIcons.tvMinimalPlay, titleKey: 'premium_benefit_no_ads',     descKey: 'premium_benefit_no_ads_desc'),
  (icon: LucideIcons.infinity,      titleKey: 'premium_benefit_lifetime',   descKey: 'premium_benefit_lifetime_desc'),
  (icon: LucideIcons.heart,         titleKey: 'premium_benefit_support',    descKey: 'premium_benefit_support_desc'),
  (icon: LucideIcons.shieldCheck,   titleKey: 'premium_benefit_peace',      descKey: 'premium_benefit_peace_desc'),
];

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  int _selectedIndex = 1; // Medium이 기본 선택 (Popular)

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
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                children: [
                  _Header(isPremium: isPremium),
                  SizedBox(height: 20.h),
                  if (!isPremium) ...[
                    for (int i = 0; i < _tiers.length; i++) ...[
                      _TierCard(
                        tier: _tiers[i],
                        price: _priceFor(_tiers[i]),
                        selected: _selectedIndex == i,
                        onTap: () => setState(() => _selectedIndex = i),
                      ),
                      SizedBox(height: 10.h),
                    ],
                    SizedBox(height: 8.h),
                  ] else ...[
                    _PremiumUnlockedCard(),
                    SizedBox(height: 8.h),
                  ],
                  _BenefitsList(),
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

// ── 헤더 ──────────────────────────────────────────────────────────────
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
                blurRadius: 24,
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.h),
        Text(
          'premium_subtitle'.tr,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (!isPremium) ...[
          SizedBox(height: 10.h),
          // 일회성 구매 강조 뱃지
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.check, size: 13.r, color: cs.onSecondaryContainer),
                SizedBox(width: 4.w),
                Text(
                  'premium_one_time_note'.tr,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── 구매 완료 상태 카드 ───────────────────────────────────────────────
class _PremiumUnlockedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: cs.tertiaryContainer,
        border: Border.all(color: cs.tertiary.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.shieldCheck, size: 32.r, color: cs.onTertiaryContainer),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'premium_unlocked'.tr,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: cs.onTertiaryContainer,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'premium_one_time_note'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onTertiaryContainer.withAlpha(180),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 티어 카드 ─────────────────────────────────────────────────────────
class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final _TierMeta tier;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
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
              width: selected ? 2.0 : 1.0,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 16.r),
              child: Row(
                children: [
                  // 선택 인디케이터
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? cs.primary
                          : cs.primaryContainer.withAlpha(178),
                    ),
                    child: Center(
                      child: selected
                          ? Icon(LucideIcons.check, size: 20.r, color: cs.onPrimary)
                          : Text(tier.emoji, style: TextStyle(fontSize: 18.sp)),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.titleKey.tr,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          tier.descKey.tr,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: selected ? cs.primary : cs.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Popular 뱃지 — tertiary 색상 (긍정적)
        if (tier.popular)
          Positioned(
            top: -10.h,
            right: 14.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: cs.tertiary,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: cs.tertiary.withAlpha(80),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'popular'.tr,
                style: TextStyle(
                  color: cs.onTertiary,
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

// ── 혜택 리스트 (그리드 대신 리스트) ─────────────────────────────────
class _BenefitsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'premium_benefits_title'.tr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: cs.surfaceContainerLow,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _benefits.length; i++) ...[
                _BenefitRow(benefit: _benefits[i]),
                if (i < _benefits.length - 1)
                  Divider(
                    height: 1,
                    indent: 54.w,
                    color: cs.outlineVariant.withAlpha(120),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit});
  final ({IconData icon, String titleKey, String descKey}) benefit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: Icon(benefit.icon, size: 18.r, color: cs.onPrimaryContainer),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.titleKey.tr,
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  benefit.descKey.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(LucideIcons.check, size: 16.r, color: cs.primary),
        ],
      ),
    );
  }
}

// ── 하단 구매 버튼 ────────────────────────────────────────────────────
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
          Icon(LucideIcons.shieldCheck, size: 20.r),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              'premium_unlocked'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
          Flexible(
            child: Text(
              'premium_loading'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shoppingCart, size: 20.r),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              isAvailable
                  ? 'premium_purchase'.tr
                  : 'premium_store_unavailable'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: canBuy ? onTap : null,
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
                backgroundColor: isPremium ? cs.tertiary : null,
              ),
              child: content,
            ),
            // 일회성 구매 명시 — 구독 아님
            if (!isPremium) ...[
              SizedBox(height: 6.h),
              Text(
                'premium_one_time_note'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
