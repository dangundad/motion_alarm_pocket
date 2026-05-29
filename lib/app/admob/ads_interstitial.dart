import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_helper.dart';

class InterstitialAdManager extends GetxController {
  InterstitialAd? _ad;
  int _eventCount = 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    await InterstitialAd.load(
      adUnitId: AdHelper.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _ad = ad,
        onAdFailedToLoad: (error) => debugPrint('Interstitial load: $error'),
      ),
    );
  }

  Future<void> showAfterNaturalBreak({int every = 3}) async {
    _eventCount++;
    if (_eventCount % every != 0) return;
    final ad = _ad;
    if (ad == null) {
      await load();
      return;
    }
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial show: $error');
        ad.dispose();
        load();
      },
    );
    await ad.show();
  }

  @override
  void onClose() {
    _ad?.dispose();
    super.onClose();
  }
}
