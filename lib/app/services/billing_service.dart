import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService {
  static const String premiumSku = 'resumeyar_premium';
  static const String _premiumKey = 'premium_unlocked';

  /// حتما این را با RSA Public Key واقعی که از پنل کافه‌بازار می‌گیری
  /// جایگزین کن (همان کلید بلند base64).
  static const String rsaPublicKey = 'REPLACE_WITH_YOUR_RSA_PUBLIC_KEY';

  bool _connected = false;

  bool get isConnected => _connected;

  Future<void> init() async {
    await _connect();
    if (_connected) {
      await _restorePurchases();
    }
  }

  Future<void> buyPremium() async {
    await _ensureConnected();
    if (!_connected) {
      debugPrint('Poolakey is not connected, cannot buy premium.');
      return;
    }

    try {
      final purchase = await FlutterPoolakey.purchase(
        premiumSku,
        // payload اختیاری اما توصیه‌شده است
        payload: 'resumeyar_premium_payload',
        dynamicPriceToken: '',
      );

      if (purchase != null && _isSuccessfulPurchase(purchase)) {
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
    _connected = false;
    try {
      await FlutterPoolakey.connect(
        rsaPublicKey,
        onSucceed: () {
          _connected = true;
          debugPrint('Poolakey connected successfully.');
        },
        onFailed: () {
          _connected = false;
          debugPrint('Poolakey connection failed (onFailed callback).');
        },
        onDisconnected: _handleDisconnect,
      );
    } catch (error, stackTrace) {
      _connected = false;
      debugPrint('Poolakey connection threw an exception: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final purchasedInApps =
          await FlutterPoolakey.getAllPurchasedProducts() ?? <PurchaseInfo>[];
      final subscribed =
          await FlutterPoolakey.getAllSubscribedProducts() ?? <PurchaseInfo>[];

      final allPurchases = <PurchaseInfo>[
        ...purchasedInApps,
        ...subscribed,
      ];

      final hasPremiumPurchase = allPurchases.any(
        (purchase) =>
            purchase.productId == premiumSku && _isSuccessfulPurchase(purchase),
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
    debugPrint('Poolakey disconnected.');
  }
}
