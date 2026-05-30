import 'package:get/get.dart';

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
      return true;
    }
  }

  bool get canLoadAd => isPurchaseStatusLoaded && !isPremiumGated;
}
