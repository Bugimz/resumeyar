import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_bazaar/in_app_purchase_bazaar.dart';
import 'package:in_app_purchase_bazaar/in_app_purchase_bazaar_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService {
  BillingService({InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase ?? InAppPurchaseBazaar.instance;

  static const String premiumSku = 'resumeyar_premium';
  static const String _premiumKey = 'premium_unlocked';

  final InAppPurchase _inAppPurchase;

  Stream<List<PurchaseDetails>> get purchaseUpdates =>
      _inAppPurchase.purchaseStream;

  Future<void> init() async {
    await InAppPurchaseBazaarPlatform.registerPlatform();
    await _inAppPurchase.isAvailable();
  }

  Future<List<ProductDetails>> queryProducts() async {
    final response =
        await _inAppPurchase.queryProductDetails({premiumSku});
    return response.productDetails;
  }

  Future<void> buyPremium(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      await _markPremiumUnlocked();
    }
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
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
