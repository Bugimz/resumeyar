import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService {
  static const String premiumSku = 'resumeyar_premium';
  static const String _premiumKey = 'premium_unlocked';
  static const String rsaPublicKey = 'REPLACE_WITH_YOUR_RSA_PUBLIC_KEY';

  bool _connected = false;

  Future<void> init() async {
    await _connect();
    if (_connected) {
      await _restorePurchases();
    }
  }

  Future<void> buyPremium() async {
    await _ensureConnected();
    if (!_connected) {
      return;
    }

    try {
      final purchase = await FlutterPoolakey.purchase(premiumSku);

      if (_isSuccessfulPurchase(purchase)) {
        await _markPremiumUnlocked();
      }
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Premium purchase failed: ${error.message}');
      debugPrint('$stackTrace');
    } catch (error, stackTrace) {
      debugPrint('Premium purchase failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _connect() async {
    try {
      await FlutterPoolakey.connect(
        rsaPublicKey,
        onDisconnected: _handleDisconnect,
      );
      _connected = true;
    } catch (error, stackTrace) {
      _connected = false;
      debugPrint('Poolakey connection failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final purchases = await FlutterPoolakey.getAllPurchasedProducts();

      final hasPremiumPurchase = purchases.any(
        (purchase) =>
            purchase.productId == premiumSku &&
            _isSuccessfulPurchase(purchase),
      );

      if (hasPremiumPurchase) {
        await _markPremiumUnlocked();
      }
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Failed to restore purchases: ${error.message}');
      debugPrint('$stackTrace');
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

  bool _isSuccessfulPurchase(PurchaseInfo purchase) {
    return purchase.purchaseState == PurchaseState.PURCHASED;
  }

  Future<void> _ensureConnected() async {
    if (_connected) {
      return;
    }

    await _connect();
  }

  void _handleDisconnect() {
    _connected = false;
  }
}
