import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService {
  BillingService({Poolakey? poolakey}) : _poolakey = poolakey ?? Poolakey();

  static const String premiumSku = 'resumeyar_premium';
  static const String _premiumKey = 'premium_unlocked';
  static const String rsaPublicKey = 'REPLACE_WITH_YOUR_RSA_PUBLIC_KEY';

  final dynamic _poolakey;
  dynamic _connection;

  Future<void> init() async {
    final config = const PaymentConfiguration(rsaPublicKey: rsaPublicKey);
    _connection = await _poolakey.connect(config);
    await _restorePurchases();
  }

  Future<void> buyPremium() async {
    final purchaseResult = await (_connection?.purchase?.call(
          productId: premiumSku,
          skuType: SkuType.inApp,
        )) ??
        await (_connection?.purchaseProduct?.call(
          productId: premiumSku,
          skuType: SkuType.inApp,
        ));

    if (purchaseResult != null) {
      await _markPremiumUnlocked();
    }
  }

  Future<void> _restorePurchases() async {
    final purchases = await (_connection?.getPurchasedProducts?.call(
          skuType: SkuType.inApp,
        )) ??
        await (_connection?.getPurchases?.call(
          SkuType.inApp,
        ));

    final hasPremiumPurchase = (purchases as List?)?.any((purchase) {
          final productId = (purchase as dynamic).productId as String?;
          return productId == premiumSku;
        }) ??
        false;

    if (hasPremiumPurchase) {
      await _markPremiumUnlocked();
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
}
