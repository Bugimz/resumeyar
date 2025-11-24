import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_service.dart';

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class PremiumService extends GetxService {
  PremiumService({BillingService? billingService})
      : billingService = billingService ?? BillingService();

  /// Set to `true` when you need to bypass paywalls for local testing.
  /// Delete this line (or set it to `false`) to restore normal premium checks.
  static const bool _forcePremiumForTesting = false;

  final BillingService billingService;
  final RxBool isPremium = false.obs;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<PremiumService> init() async {
    if (_forcePremiumForTesting) {
      isPremium.value = true;
      return this;
    }

    await billingService.init();
    isPremium.value = await billingService.hasPremium();

    products.value = await billingService.queryProducts();

    _subscription = billingService.purchaseUpdates.listen((purchases) async {
      for (final purchase in purchases) {
        await billingService.handlePurchase(purchase);
      }
      isPremium.value = await billingService.hasPremium();
    });

    return this;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> buyPremium() async {
    final product = products.firstWhereOrNull(
      (item) => item.id == BillingService.premiumSku,
    );
    if (product != null) {
      await billingService.buyPremium(product);
    }
  }
}
