import 'dart:async';

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
      // timeout or error — keep cached status
    } finally {
      _silentRestore = false;
      _restoreCompleter = null;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      await _handlePurchase(purchase);
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
        Get.snackbar('premium_unlocked'.tr, '',
            duration: const Duration(seconds: 3));
        Get.offAllNamed('/');
      }
    } else if (purchase.status == PurchaseStatus.pending) {
      isLoading.value = true;
    } else if (purchase.status == PurchaseStatus.error ||
        purchase.status == PurchaseStatus.canceled) {
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
    } catch (_) {
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
      // keep existing status on failure
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
