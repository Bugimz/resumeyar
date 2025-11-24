import 'package:get/get.dart';

import 'billing_service.dart';

class PremiumService extends GetxService {
  PremiumService({BillingService? billingService})
      : billingService = billingService ?? BillingService();

  /// Set to `true` when you need to bypass paywalls for local testing.
  /// Delete this line (or set it to `false`) to restore normal premium checks.
  static const bool _forcePremiumForTesting = false;

  final BillingService billingService;
  final RxBool isPremium = false.obs;

  Future<PremiumService> init() async {
    if (_forcePremiumForTesting) {
      isPremium.value = true;
      return this;
    }

    await billingService.init();
    isPremium.value = await billingService.hasPremium();

    return this;
  }

  Future<void> buyPremium() async {
    await billingService.buyPremium();
    isPremium.value = await billingService.hasPremium();
  }
}
