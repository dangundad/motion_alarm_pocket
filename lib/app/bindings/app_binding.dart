import 'package:get/get.dart';

import '../admob/ads_interstitial.dart';
import '../admob/ads_rewarded.dart';
import '../controllers/home_controller.dart';
import '../services/alert_service.dart';
import '../services/hive_service.dart';
import '../services/purchase_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PurchaseService>(tag: 'purchase_service')) {
      Get.put(PurchaseService(), permanent: true, tag: 'purchase_service');
    }
    if (!Get.isRegistered<HiveService>()) {
      Get.put(HiveService(), permanent: true);
    }
    if (!Get.isRegistered<AlertService>()) {
      Get.put(AlertService(), permanent: true);
    }
    if (!Get.isRegistered<InterstitialAdManager>()) {
      Get.put(InterstitialAdManager(), permanent: true);
    }
    if (!Get.isRegistered<RewardedAdManager>()) {
      Get.put(RewardedAdManager(), permanent: true);
    }
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
