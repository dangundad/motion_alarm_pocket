import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract final class AdHelper {
  static const String appId = 'ca-app-pub-3940256099942544~3347511713';
  static const String bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
    } catch (error) {
      debugPrint('MobileAds initialize failed: $error');
    }
  }
}
