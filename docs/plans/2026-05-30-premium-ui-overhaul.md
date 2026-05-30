# Premium + UI Overhaul Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 앱을 상용 배포 수준으로 고도화 — 경쟁앱 수준의 UI/UX 재설계 + AdMob 광고 전용에서 3-tier 1회성 IAP로 수익 모델 전환.

**Architecture:** qibla_compass 프로젝트의 PurchaseService + PremiumGatedAdMixin 패턴을 모방해 `in_app_purchase` 패키지로 IAP를 처리하고 `shared_preferences`로 로컬 캐시한다. 홈 화면은 경쟁앱 분석을 바탕으로 원형 상태 인디케이터 + 대형 CTA 버튼 중심으로 전면 재설계한다.

**Tech Stack:** Flutter/GetX, in_app_purchase 3.x, shared_preferences, flutter_screenutil, lucide_icons_flutter, google_mobile_ads (기존 유지)

---

## Task 1: 패키지 추가

**Files:**
- Modify: `pubspec.yaml`

**Step 1: pubspec.yaml에 in_app_purchase, shared_preferences 추가**

`dependencies:` 블록에 아래 두 줄을 추가:
```yaml
  in_app_purchase: ^3.2.3
  shared_preferences: ^2.5.5
```

**Step 2: 패키지 설치**

```
flutter pub get
```
Expected: 오류 없이 완료

**Step 3: AndroidManifest 확인**

`android/app/src/main/AndroidManifest.xml`에 이미 `INTERNET` 권한이 있는지 확인. 없으면 `<uses-permission android:name="android.permission.INTERNET" />`를 추가.

**Step 4: Commit**

```
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml
git commit -m "chore: add in_app_purchase and shared_preferences packages"
```

---

## Task 2: PremiumGatedAdMixin 생성

**Files:**
- Create: `lib/app/admob/premium_gated_ad.dart`

**Step 1: mixin 파일 작성**

```dart
import 'package:get/get.dart';

/// 광고 매니저가 isPurchaseStatusLoaded 확인 전에 광고를 로드하지 않도록 막는 믹스인.
/// PurchaseService가 등록된 후 사용 가능.
mixin PremiumGatedAdMixin {
  bool get isPremiumGated {
    try {
      final svc = Get.find<dynamic>(tag: 'purchase_service');
      // ignore: avoid_dynamic_calls
      return svc.isPremium.value == true;
    } catch (_) {
      return false;
    }
  }

  bool get isPurchaseStatusLoaded {
    try {
      final svc = Get.find<dynamic>(tag: 'purchase_service');
      // ignore: avoid_dynamic_calls
      return svc.isPurchaseStatusLoaded.value == true;
    } catch (_) {
      return true; // PurchaseService 없으면 광고 허용
    }
  }

  bool get canLoadAd => isPurchaseStatusLoaded && !isPremiumGated;
}
```

**Step 2: Commit**

```
git add lib/app/admob/premium_gated_ad.dart
git commit -m "feat: add PremiumGatedAdMixin for premium-aware ad loading"
```

---

## Task 3: PurchaseService 생성

**Files:**
- Create: `lib/app/services/purchase_service.dart`

**Step 1: PurchaseConstants 정의 포함하여 서비스 작성**

```dart
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class PurchaseConstants {
  static const List<String> productIds = [
    'motion_alarm_pocket_premium_small',
    'motion_alarm_pocket_premium_medium',
    'motion_alarm_pocket_premium_large',
  ];
}

class PurchaseService extends GetxService {
  static PurchaseService get to => Get.find(tag: 'purchase_service');

  final isPremium = false.obs;
  final isLoading = false.obs;
  final available = false.obs;
  final isProductsLoaded = false.obs;
  final isPurchaseStatusLoaded = false.obs;
  final products = <ProductDetails>[].obs;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _silentRestore = false;
  Completer<void>? _restoreCompleter;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadPurchaseStatus();
    isPurchaseStatusLoaded.value = true;
    await _initializeStore();
  }

  Future<void> _loadPurchaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isPremium.value = prefs.getBool('is_premium') ?? false;
  }

  Future<void> _savePurchaseStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', value);
    isPremium.value = value;
  }

  Future<void> _initializeStore() async {
    final isAvailable = await InAppPurchase.instance.isAvailable();
    available.value = isAvailable;
    if (!isAvailable) return;

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    await _queryProducts();
    await _reconcileEntitlementsSilently();
  }

  Future<void> _queryProducts() async {
    final response = await InAppPurchase.instance.queryProductDetails(
      Set<String>.from(PurchaseConstants.productIds),
    );
    products.assignAll(response.productDetails);
    isProductsLoaded.value = true;
  }

  Future<void> _reconcileEntitlementsSilently() async {
    if (isPremium.value) return;
    _silentRestore = true;
    _restoreCompleter = Completer<void>();
    try {
      await InAppPurchase.instance.restorePurchases();
      await _restoreCompleter!.future.timeout(const Duration(seconds: 8));
    } catch (_) {
      // 타임아웃 또는 오류 시 캐시된 상태 유지
    } finally {
      _silentRestore = false;
      _restoreCompleter = null;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
    if (_silentRestore) {
      _restoreCompleter?.complete();
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      await _savePurchaseStatus(true);
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
      if (!_silentRestore && purchase.status == PurchaseStatus.purchased) {
        Get.snackbar('premium_unlocked'.tr, '', duration: const Duration(seconds: 3));
        Get.offAllNamed('/');
      }
    } else if (purchase.status == PurchaseStatus.pending) {
      isLoading.value = true;
    } else if (purchase.status == PurchaseStatus.error) {
      isLoading.value = false;
    } else if (purchase.status == PurchaseStatus.canceled) {
      isLoading.value = false;
    }
  }

  bool get canPurchase =>
      !isPremium.value && !isLoading.value && available.value;

  Future<void> purchaseProduct(String productId) async {
    if (!canPurchase) return;
    final match = products.where((p) => p.id == productId).toList();
    if (match.isEmpty) return;
    final param = PurchaseParam(productDetails: match.first);
    isLoading.value = true;
    try {
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    } on PlatformException {
      isLoading.value = false;
    }
  }

  Future<void> restorePurchases() async {
    isLoading.value = true;
    _restoreCompleter = Completer<void>();
    try {
      await InAppPurchase.instance.restorePurchases();
      await _restoreCompleter!.future.timeout(const Duration(seconds: 8));
    } catch (_) {
      // 실패 시 기존 상태 유지
    } finally {
      isLoading.value = false;
      _restoreCompleter = null;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
```

**Step 2: Commit**

```
git add lib/app/services/purchase_service.dart
git commit -m "feat: add PurchaseService with 3-tier one-time IAP"
```

---

## Task 4: AppBinding + Routes 업데이트

**Files:**
- Modify: `lib/app/bindings/app_binding.dart`
- Modify: `lib/app/routes/app_routes.dart`
- Modify: `lib/app/routes/app_pages.dart`

**Step 1: AppBinding에 PurchaseService 등록**

`app_binding.dart`의 `dependencies()` 메서드 첫 줄에 추가:
```dart
import '../services/purchase_service.dart';
// ...
Get.put(PurchaseService(), permanent: true, tag: 'purchase_service');
```

**Step 2: app_routes.dart에 premium 경로 추가**

```dart
part of 'app_pages.dart';

abstract final class Routes {
  static const home = '/';
  static const premium = '/premium';
}
```

**Step 3: app_pages.dart에 PremiumPage 라우트 추가**

```dart
import '../pages/premium/premium_page.dart';
// pages 리스트에 추가:
GetPage(
  name: Routes.premium,
  page: () => const PremiumPage(),
),
```

**Step 4: Commit**

```
git add lib/app/bindings/app_binding.dart lib/app/routes/app_routes.dart lib/app/routes/app_pages.dart
git commit -m "feat: register PurchaseService and add premium route"
```

---

## Task 5: 번역 문자열 확장

**Files:**
- Modify: `lib/app/translate/translate.dart`

**Step 1: 영문 + 한국어 키 추가**

기존 맵에 아래 키들을 병합:
```dart
// en_US 추가:
'armed': 'Armed – watching for motion',
'arming': 'Arming… stay still',
'alarm_active': 'Motion Detected!',
'idle': 'Ready to arm',
'stop_alarm': 'Stop Alarm',
'delta': 'Delta',
'mode': 'Mode',
'alert': 'Alert',
'active': 'Active',
'siren_vibration': 'Siren + Vibration',
'delay_label': 'Delay: {n}s',
'sensitivity_low': 'Low',
'sensitivity_medium': 'Medium',
'sensitivity_high': 'High',
'how_to_use': 'How to Use',
'step_settings': 'Set delay and sensitivity',
'step_place': 'Tap Start, keep the phone still',
'step_stop': 'Stop the session yourself to silence',
'premium': 'Premium',
'premium_title': 'Support the App',
'premium_subtitle': 'Remove ads with a one-time tip',
'premium_unlocked': 'Premium active. Thank you!',
'premium_purchase': 'Get Premium',
'premium_restore': 'Restore purchase',
'premium_loading': 'Loading…',
'premium_store_unavailable': 'Store unavailable',
'premium_option_small_title': 'Coffee Tip',
'premium_option_small_desc': 'Remove ads',
'premium_option_medium_title': 'Lunch Treat',
'premium_option_medium_desc': 'Remove ads (most popular)',
'premium_option_large_title': 'Full Support',
'premium_option_large_desc': 'Remove ads + thank you!',
'premium_benefit_no_ads': 'No Ads',
'premium_benefit_no_ads_desc': 'Enjoy an ad-free experience',
'premium_benefit_lifetime': 'Lifetime',
'premium_benefit_lifetime_desc': 'One-time, no subscriptions',
'premium_benefit_support': 'Support Dev',
'premium_benefit_support_desc': 'Help keep the app alive',
'premium_benefit_peace': 'Peace of Mind',
'premium_benefit_peace_desc': 'Focus on what matters',
'remove_ads_cta': 'Remove ads · Support developer',

// ko_KR 추가:
'armed': '감시 중 – 움직임을 감지합니다',
'arming': '준비 중… 폰을 가만히 두세요',
'alarm_active': '움직임 감지됨!',
'idle': '시작할 준비 완료',
'stop_alarm': '경보 중지',
'delta': '변화량',
'mode': '상태',
'alert': '알림',
'active': '활성',
'siren_vibration': '사이렌 + 진동',
'delay_label': '딜레이: {n}초',
'sensitivity_low': '낮음',
'sensitivity_medium': '중간',
'sensitivity_high': '높음',
'how_to_use': '사용 방법',
'step_settings': '딜레이와 감도를 설정하세요',
'step_place': '시작을 탭한 후 폰을 가만히 두세요',
'step_stop': '세션을 직접 중지해야 경보가 꺼집니다',
'premium': '프리미엄',
'premium_title': '앱 후원하기',
'premium_subtitle': '일회성 후원으로 광고를 제거하세요',
'premium_unlocked': '프리미엄 활성화. 감사합니다!',
'premium_purchase': '프리미엄 구매',
'premium_restore': '구매 복원',
'premium_loading': '로딩 중…',
'premium_store_unavailable': '스토어를 사용할 수 없습니다',
'premium_option_small_title': '커피 한 잔',
'premium_option_small_desc': '광고 제거',
'premium_option_medium_title': '점심 한 끼',
'premium_option_medium_desc': '광고 제거 (인기)',
'premium_option_large_title': '풀 서포트',
'premium_option_large_desc': '광고 제거 + 감사 인사!',
'premium_benefit_no_ads': '광고 없음',
'premium_benefit_no_ads_desc': '광고 없는 경험',
'premium_benefit_lifetime': '평생 이용',
'premium_benefit_lifetime_desc': '일회성, 구독 없음',
'premium_benefit_support': '개발자 후원',
'premium_benefit_support_desc': '앱 유지에 도움',
'premium_benefit_peace': '안심 사용',
'premium_benefit_peace_desc': '중요한 것에 집중',
'remove_ads_cta': '광고 제거 · 개발자 후원',
```

**Step 2: Commit**

```
git add lib/app/translate/translate.dart
git commit -m "feat: add premium and UI translation strings (en/ko)"
```

---

## Task 6: PremiumPage UI 생성

**Files:**
- Create: `lib/app/pages/premium/premium_page.dart`

**Step 1: premium_page.dart 전체 작성**

qibla_compass PremiumPage 구조를 motion_alarm_pocket에 맞게 재구성:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/purchase_service.dart';

// 제품별 메타 데이터
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
    usdFallback: '\$0.99',
  ),
  _TierMeta(
    id: 'motion_alarm_pocket_premium_medium',
    emoji: '🛡️',
    titleKey: 'premium_option_medium_title',
    descKey: 'premium_option_medium_desc',
    usdFallback: '\$2.99',
    popular: true,
  ),
  _TierMeta(
    id: 'motion_alarm_pocket_premium_large',
    emoji: '💪',
    titleKey: 'premium_option_large_title',
    descKey: 'premium_option_large_desc',
    usdFallback: '\$4.99',
  ),
];

const _benefits = [
  (icon: LucideIcons.tvMinimalPlay, titleKey: 'premium_benefit_no_ads', descKey: 'premium_benefit_no_ads_desc'),
  (icon: LucideIcons.infinity, titleKey: 'premium_benefit_lifetime', descKey: 'premium_benefit_lifetime_desc'),
  (icon: LucideIcons.heart, titleKey: 'premium_benefit_support', descKey: 'premium_benefit_support_desc'),
  (icon: LucideIcons.shieldCheck, titleKey: 'premium_benefit_peace', descKey: 'premium_benefit_peace_desc'),
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
    final tt = Theme.of(context).textTheme;

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
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 96.h),
                children: [
                  _Header(isPremium: isPremium),
                  SizedBox(height: 20.h),
                  // 3-tier 카드
                  for (int i = 0; i < _tiers.length; i++) ...[
                    _TierCard(
                      tier: _tiers[i],
                      price: _priceFor(_tiers[i]),
                      selected: _selectedIndex == i,
                      isPremium: isPremium,
                      onTap: isPremium ? null : () => setState(() => _selectedIndex = i),
                    ),
                    SizedBox(height: 10.h),
                  ],
                  SizedBox(height: 16.h),
                  _BenefitsGrid(),
                  SizedBox(height: 16.h),
                  if (!isPremium)
                    Center(
                      child: TextButton(
                        onPressed: _svc.isLoading.value ? null : _svc.restorePurchases,
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
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            color: selected ? cs.primaryContainer.withAlpha(71) : cs.surfaceContainerLow,
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
                  // 선택 인디케이터
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? cs.primary : cs.primaryContainer.withAlpha(178),
                    ),
                    child: Center(
                      child: selected
                          ? Icon(LucideIcons.check, size: 18.r, color: cs.onPrimary)
                          : Text(tier.emoji, style: TextStyle(fontSize: 16.sp)),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isPremium ? '✓' : price,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
              ),
              child: Text(
                'Popular',
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
      children: _benefits.map((b) {
        return Container(
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
              Text(b.titleKey.tr, style: Theme.of(context).textTheme.labelLarge),
              Text(
                b.descKey.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                maxLines: 2,
              ),
            ],
          ),
        );
      }).toList(),
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
          SizedBox(width: 20.r, height: 20.r, child: const CircularProgressIndicator(strokeWidth: 2)),
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
          Text(isAvailable ? 'premium_purchase'.tr : 'premium_store_unavailable'.tr),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            backgroundColor: isPremium ? cs.tertiary : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```
git add lib/app/pages/premium/premium_page.dart
git commit -m "feat: add PremiumPage with 3-tier one-time purchase UI"
```

---

## Task 7: 홈 화면 전면 재설계

**Files:**
- Modify: `lib/app/pages/home/home_page.dart`

경쟁앱 패턴 기반으로 완전히 재작성. 핵심:
- 원형 상태 인디케이터 (AnimatedContainer 색상 전환)
- 큰 START/STOP/STOP ALARM 버튼
- 상단 AppBar에 프리미엄 왕관 아이콘
- 하단 광고 배너 (비프리미엄 시)
- 설정 카드 더 간결하게 (딜레이 칩 + 감도 세그먼트)

**Step 1: home_page.dart 전체 교체**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../admob/ads_banner.dart';
import '../../admob/ads_helper.dart';
import '../../controllers/home_controller.dart';
import '../../domain/motion_alarm_logic.dart';
import '../../routes/app_routes.dart';
import '../../services/purchase_service.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
        actions: [
          Obx(() {
            final isPremium = _isPremiumAvailable &&
                PurchaseService.to.isPremium.value;
            return IconButton(
              icon: Icon(
                isPremium ? LucideIcons.shieldCheck : LucideIcons.crown,
                color: isPremium
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'premium'.tr,
              onPressed: isPremium ? null : () => Get.toNamed(Routes.premium),
            );
          }),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (_isPremiumAvailable && PurchaseService.to.isPremium.value) {
          return const SizedBox.shrink();
        }
        return const SafeArea(
          child: BannerAdWidget(adUnitId: AdHelper.bannerUnitId),
        );
      }),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            // 원형 상태 인디케이터
            Obx(() => _StatusCircle(
                  isSessionActive: controller.isSessionActive.value,
                  isArmed: controller.isArmed.value,
                  isAlarmActive: controller.isAlarmActive.value,
                  lastDelta: controller.lastDelta.value,
                )),
            SizedBox(height: 20.h),
            // 메인 CTA 버튼
            Obx(() => _MainActionButton(
                  isSessionActive: controller.isSessionActive.value,
                  isAlarmActive: controller.isAlarmActive.value,
                  onStart: controller.startSession,
                  onStop: controller.stopSession,
                  onStopAlarm: controller.stopAlarm,
                )),
            SizedBox(height: 16.h),
            // 설정 카드
            Obx(() => _SettingsCard(
                  delaySeconds: controller.delaySeconds.value,
                  sensitivity: controller.sensitivity.value,
                  enabled: !controller.isSessionActive.value,
                  onDelayChanged: controller.setDelay,
                  onSensitivityChanged: controller.setSensitivity,
                )),
            SizedBox(height: 16.h),
            // 사용 방법
            const _HowToUseCard(),
            SizedBox(height: 16.h),
            // 히스토리
            Text('history'.tr, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8.h),
            Obx(() => controller.history.isEmpty
                ? _EmptyState(icon: LucideIcons.history, text: 'no_history'.tr)
                : Column(
                    children: controller.history
                        .take(5)
                        .map((e) => _HistoryTile(entry: e))
                        .toList(),
                  )),
            SizedBox(height: 12.h),
            // 광고 제거 인라인 링크 (비프리미엄)
            Obx(() {
              if (_isPremiumAvailable && PurchaseService.to.isPremium.value) {
                return const SizedBox.shrink();
              }
              return _RemoveAdsCta();
            }),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  bool get _isPremiumAvailable {
    try {
      PurchaseService.to;
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ── 원형 상태 인디케이터 ─────────────────────────────────────────────
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

  String _statusText(BuildContext context) {
    if (isAlarmActive) return 'alarm_active'.tr;
    if (isArmed) return 'armed'.tr;
    if (isSessionActive) return 'arming'.tr;
    return 'idle'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (lastDelta / 18.0).clamp(0.0, 1.0);
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 외부 진행 링
              SizedBox(
                width: 160.r,
                height: 160.r,
                child: CircularProgressIndicator(
                  value: isArmed ? progress : null,
                  strokeWidth: 6,
                  backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAlarmActive
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              // 내부 원형
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleColor(context),
                  boxShadow: isAlarmActive || isArmed
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
          _statusText(context),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        if (isArmed && lastDelta > 0)
          Text(
            '${'delta'.tr}: ${lastDelta.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

// ── 메인 액션 버튼 ────────────────────────────────────────────────────
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
    if (isAlarmActive) {
      return FilledButton.icon(
        onPressed: onStopAlarm,
        style: FilledButton.styleFrom(
          minimumSize: Size(double.infinity, 60.h),
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        icon: const Icon(LucideIcons.bellOff),
        label: Text('stop_alarm'.tr, style: TextStyle(fontSize: 18.sp)),
      );
    }
    return FilledButton.icon(
      onPressed: isSessionActive ? onStop : onStart,
      style: FilledButton.styleFrom(
        minimumSize: Size(double.infinity, 60.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      icon: Icon(isSessionActive ? LucideIcons.square : LucideIcons.play),
      label: Text(
        isSessionActive ? 'stop'.tr : 'start'.tr,
        style: TextStyle(fontSize: 18.sp),
      ),
    );
  }
}

// ── 설정 카드 ─────────────────────────────────────────────────────────
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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('settings'.tr, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(LucideIcons.timer, size: 18.r,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 8.w),
                Text(
                  'delay_label'.trParams({'n': '$delaySeconds'}),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
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
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(LucideIcons.activity, size: 18.r,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 8.w),
                Text('sensitivity'.tr.isEmpty ? 'Sensitivity' : 'settings'.tr,
                    style: Theme.of(context).textTheme.bodyMedium),
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

// ── 사용 방법 카드 ────────────────────────────────────────────────────
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
            Text('how_to_use'.tr, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10.h),
            _Step(num: 1, icon: LucideIcons.slidersHorizontal, textKey: 'step_settings'),
            _Step(num: 2, icon: LucideIcons.smartphone, textKey: 'step_place'),
            _Step(num: 3, icon: LucideIcons.bellOff, textKey: 'step_stop'),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.num, required this.icon, required this.textKey});
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
          Expanded(child: Text(textKey.tr)),
        ],
      ),
    );
  }
}

// ── 히스토리 타일 ──────────────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});
  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: ListTile(
        leading: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.errorContainer,
          ),
          child: Icon(
            LucideIcons.activity,
            size: 20.r,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        title: Text(entry['title']?.toString() ?? ''),
        subtitle: Text(entry['detail']?.toString() ?? ''),
        dense: true,
      ),
    );
  }
}

// ── 광고 제거 CTA ─────────────────────────────────────────────────────
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
            Text(
              'remove_ads_cta'.tr,
              style: TextStyle(
                color: cs.primary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
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

// ── 빈 상태 ───────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: Theme.of(context).colorScheme.onSurfaceVariant),
          SizedBox(width: 8.w),
          Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```
git add lib/app/pages/home/home_page.dart
git commit -m "feat: redesign home page with circular status indicator and premium CTA"
```

---

## Task 8: InterstitialAdManager 프리미엄 인식 업데이트

**Files:**
- Modify: `lib/app/admob/ads_interstitial.dart`

**Step 1: stopAlarm 전에 프리미엄 체크 추가**

`home_controller.dart`의 `stopAlarm()` 메서드에서 인터스티셜 표시 전 프리미엄 여부 확인:

```dart
Future<void> stopAlarm() async {
  isAlarmActive.value = false;
  await AlertService.to.stop();
  // 프리미엄이면 광고 스킵
  try {
    if (!PurchaseService.to.isPremium.value) {
      await Get.find<InterstitialAdManager>().showAfterNaturalBreak();
    }
  } catch (_) {
    await Get.find<InterstitialAdManager>().showAfterNaturalBreak();
  }
}
```

`home_controller.dart` import 추가:
```dart
import '../services/purchase_service.dart';
```

**Step 2: Commit**

```
git add lib/app/controllers/home_controller.dart
git commit -m "feat: skip interstitial ads for premium users"
```

---

## Task 9: flutter analyze + build 검증

**Step 1: flutter analyze 실행**

```
flutter analyze
```
Expected: No issues (또는 warning만)

**Step 2: 오류 수정**

analyze 결과에서 error만 수정. warning은 무시.

**Step 3: flutter build apk --debug**

```
flutter build apk --debug
```
Expected: `Build successful!`

**Step 4: 최종 commit + git push**

```
git add -A
git commit -m "chore: fix analyze issues and verify debug build"
git push origin master
```

---

## 주의사항

- **Play Console IAP 등록 필수**: 배포 전 Google Play Console에서 3개 제품 ID를 등록해야 실제 구매 테스트 가능.
  - `motion_alarm_pocket_premium_small` → $0.99
  - `motion_alarm_pocket_premium_medium` → $2.99
  - `motion_alarm_pocket_premium_large` → $4.99
- **AdMob 실제 ID 교체 필요**: `lib/app/admob/ads_helper.dart`의 테스트 ID를 실제 AdMob 단위 ID로 교체.
- **앱 서명 설정 필요**: 릴리즈 빌드 전 `key.properties` 및 keystore 설정.
