import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  // MobileAds is initialized after the first frame, so the first load can run
  // before the SDK is ready. Retry with a capped backoff to recover from that
  // window (and from transient no-fill) without hammering the network.
  Timer? _retryTimer;
  int _retryCount = 0;
  static const _maxRetries = 4;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _retryCount = 0;
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _ad = null;
          if (mounted) setState(() => _loaded = false);
          _scheduleRetry();
        },
      ),
    )..load();
  }

  void _scheduleRetry() {
    if (_retryCount >= _maxRetries) return;
    _retryCount++;
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: _retryCount * 2), () {
      if (mounted) _loadAd();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) {
      return const SizedBox(height: 52);
    }
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
