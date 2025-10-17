import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:snadders/services/shared_prefs_service.dart';

class IAPService {
  IAPService._privateConstructor();
  static final IAPService instance = IAPService._privateConstructor();

  // Consumable product IDs
  static const String _coins10kId = 'coins_10K';
  static const String _coins30kId = 'coins_30K';
  static const String _coins100kId = 'coins_100K';
  static const String _coins250kId = 'coins_250K';
  static const String _coins1MId = 'coins_1M';
  static const String _coins2MId = 'coins_2M';

  // Non-consumable product IDs
  static const String _removeAllAdsId = 'remove_all_ads';
  static const String _removeRewardedAdsId = 'remove_rewarded_ads';

  // Getters for Consumable product IDs
  static String get coins10kId => _coins10kId;
  static String get coins30kId => _coins30kId;
  static String get coins100kId => _coins100kId;
  static String get coins250kId => _coins250kId;
  static String get coins1MId => _coins1MId;
  static String get coins2MId => _coins2MId;

  // Getters for Non-consumable product IDs
  static String get removeAllAdsId => _removeAllAdsId;
  static String get removeRewardedAdsId => _removeRewardedAdsId;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final SharedPrefsService _prefsService = SharedPrefsService();

  // Notifiers for Consumer product
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);

  // Notifiers for Non-consumable products
  final ValueNotifier<bool> allAdsRemovedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> rewardedAdsRemovedNotifier = ValueNotifier<bool>(false);

  // Getters for Consumable and Non-consumable states
  int get currentCoins => coinsNotifier.value;
  bool get isAllAdsRemoved => allAdsRemovedNotifier.value;
  bool get isRewardedAdsRemoved => rewardedAdsRemovedNotifier.value;

  final Map<String, int> _coinMap = {
    _coins10kId: 10000,
    _coins30kId: 30000,
    _coins100kId: 100000,
    _coins250kId: 250000,
    _coins1MId: 1000000,
    _coins2MId: 2000000,
  };

  Future<void> initialize() async {
    coinsNotifier.value = await _prefsService.loadCoins();
    allAdsRemovedNotifier.value = await _prefsService.loadAllAdsRemoved();
    rewardedAdsRemovedNotifier.value = await _prefsService.loadRewardedAdsRemoved();

    final bool isAvailable = await _iap.isAvailable();

    if (!isAvailable) {
      debugPrint('In-App Purchase is not available');
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

  // Purchase Consumable Product
  Future<void> purchaseConsumable(String productId) async {
    try {
      final response = await _iap.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        debugPrint('Product $productId not found');
        return;
      }
      final param = PurchaseParam(
        productDetails: response.productDetails.first,
      );
      await _iap.buyConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('Error purchasing consumable $productId: $e');
    }
  }

  Future<void> purchaseNonConsumable(String productId) async {
    try {
      final response = await _iap.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        debugPrint('Product $productId not found');
        return;
      }

      final param = PurchaseParam(
        productDetails: response.productDetails.first,
      );
      await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('Error purchasing non-consumable $productId: $e');
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> detailsList) async {
    for (final purchase in detailsList) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        // Non-consumables
        if (purchase.productID == removeAllAdsId) {
          await _prefsService.setAllAdsRemoved(true);
          allAdsRemovedNotifier.value = true;
        } else if (purchase.productID == removeRewardedAdsId) {
          await _prefsService.setRewardedAdsRemoved(true);
          rewardedAdsRemovedNotifier.value = true;
        }

        // Consumables
        if (_coinMap.containsKey(purchase.productID)) {
          int coins = await _prefsService.loadCoins();
          coins += _coinMap[purchase.productID]!;
          await _prefsService.saveCoins(coins);
          coinsNotifier.value = coins;
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
    coinsNotifier.dispose();
    allAdsRemovedNotifier.dispose();
    rewardedAdsRemovedNotifier.dispose();
  }
}
