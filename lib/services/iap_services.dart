import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IAPService {
  static const String _removeAllAdsId = 'remove_all_ads';
  static const String _removeRewardedAdsId = 'remove_rewarded_ads';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final ValueNotifier<bool> allAdsRemovedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> rewardedAdsRemovedNotifier = ValueNotifier<bool>(false);

  bool get isAllAdsRemoved => allAdsRemovedNotifier.value;
  bool get isRewardedAdsRemoved => rewardedAdsRemovedNotifier.value;

  bool get areAdsFullyRemoved => isAllAdsRemoved;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    allAdsRemovedNotifier.value = prefs.getBool('isAllAdsRemoved') ?? false;
    rewardedAdsRemovedNotifier.value = prefs.getBool('isRewardedAdsRemoved') ?? false;

    final bool isAvailable = await _iap.isAvailable();

    if (!isAvailable) {
      debugPrint('In-App Purchase is not available');
      return;
    }

    final productDetailsResponse = await _iap.queryProductDetails({_removeAllAdsId, _removeRewardedAdsId});
    if (productDetailsResponse.productDetails.isEmpty) {
      debugPrint('No products found');
      return;
    }

    // Listen for purchase updates
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );

    // Restore previous purchases
    await _iap.restorePurchases();
  }

  Future<void> purchaseProduct(String productId) async {
    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) {
      debugPrint('Product $productId not found');
      return;
    }

    final param = PurchaseParam(
      productDetails: response.productDetails.first,
    );
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> detailsList) async {
    final prefs = await SharedPreferences.getInstance();

    for (final purchase in detailsList) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == _removeAllAdsId) {
          await prefs.setBool('isAllAdsRemoved', true);
          allAdsRemovedNotifier.value = true;
        } else if (purchase.productID == _removeRewardedAdsId) {
          await prefs.setBool('isRewardedAdsRemoved', true);
          rewardedAdsRemovedNotifier.value = true;
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> restorePurchases() async => await _iap.restorePurchases();

  void dispose() {
    _subscription?.cancel();
    allAdsRemovedNotifier.dispose();
    rewardedAdsRemovedNotifier.dispose();
  }
}
