import 'package:flutter/foundation.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService {
  BillingService({Poolakey? poolakey}) : _poolakey = poolakey ?? Poolakey();

  static const String premiumSku = 'resumeyar_premium';
  static const String _premiumKey = 'premium_unlocked';
  static const String rsaPublicKey = 'REPLACE_WITH_YOUR_RSA_PUBLIC_KEY';

  final Poolakey _poolakey;
  dynamic _connection;

  Future<void> init() async {
    final config = const PaymentConfiguration(rsaPublicKey: rsaPublicKey);

    try {
      _connection = await _poolakey.connect(config);
      await _restorePurchases();
    } catch (error, stackTrace) {
      debugPrint('Poolakey connection failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> buyPremium() async {
    await _ensureConnected();

    try {
      final purchaseResult = await (_connection?.purchase?.call(
            productId: premiumSku,
            skuType: SkuType.inApp,
          )) ??
          await (_connection?.purchaseProduct?.call(
            productId: premiumSku,
            skuType: SkuType.inApp,
          ));

      if (_isSuccessfulPurchase(purchaseResult)) {
        await _markPremiumUnlocked();
      }
    } catch (error, stackTrace) {
      debugPrint('Premium purchase failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final purchases = await (_connection?.getPurchasedProducts?.call(
            skuType: SkuType.inApp,
          )) ??
          await (_connection?.getPurchases?.call(
            SkuType.inApp,
          ));

      final hasPremiumPurchase = (purchases as List?)?.any((purchase) {
            final productId = (purchase as dynamic).productId as String?;
            return productId == premiumSku && _isSuccessfulPurchase(purchase);
          }) ??
          false;

      if (hasPremiumPurchase) {
        await _markPremiumUnlocked();
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to restore purchases: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _markPremiumUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
  }

  Future<bool> hasPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  bool _isSuccessfulPurchase(dynamic purchase) {
    if (purchase == null) {
      return false;
    }

    if (purchase is bool) {
      return purchase;
    }

    final purchaseState = _readPurchaseState(purchase);
    if (purchaseState == null) {
      return true;
    }

    return purchaseState == 'purchased' || purchaseState == 'completed';
  }

  String? _readPurchaseState(dynamic purchase) {
    try {
      final state = (purchase as dynamic).purchaseState;
      if (state == null) {
        return null;
      }

      final stateName = state.toString().toLowerCase();
      if (stateName.contains('purchased')) {
        return 'purchased';
      }

      if (stateName.contains('complete')) {
        return 'completed';
      }

      return stateName;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureConnected() async {
    if (_connection != null) {
      return;
    }

    await init();
  }
}
