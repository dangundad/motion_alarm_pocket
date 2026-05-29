import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_helper.dart';

class RewardedAdManager extends GetxController {
  RewardedAd? _ad;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    await RewardedAd.load(
      adUnitId: AdHelper.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _ad = ad,
        onAdFailedToLoad: (error) => debugPrint('Rewarded load: $error'),
      ),
    );
  }

  Future<void> show({required VoidCallback onRewarded}) async {
    final ad = _ad;
    if (ad == null) {
      onRewarded();
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
        debugPrint('Rewarded show: $error');
        ad.dispose();
        onRewarded();
        load();
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => onRewarded());
  }

  @override
  void onClose() {
    _ad?.dispose();
    super.onClose();
  }
}
