import 'package:get/get.dart';

import 'billing_service.dart';

class PremiumService extends GetxService {
  PremiumService({BillingService? billingService})
      : billingService = billingService ?? BillingService();

  /// برای تست لوکال (یادت نره قبل ریلیز false باشه)
  static const bool _forcePremiumForTesting = false;

  final BillingService billingService;
  final RxBool isPremium = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAsync(); // 👈 بدون await – غیرمسدودکننده
  }

  Future<void> _initAsync() async {
    if (_forcePremiumForTesting) {
      isPremium.value = true;
      return;
    }

    await billingService.init();
    isPremium.value = await billingService.hasPremium();
  }

  Future<void> buyPremium() async {
    await billingService.buyPremium();
    isPremium.value = await billingService.hasPremium();
  }

  /// اختیاری: دکمه "بازیابی خرید" اگر داشته باشی
  Future<void> restorePremium() async {
    await billingService.init(); // دوباره اتصال + ریکاوری
    isPremium.value = await billingService.hasPremium();
  }
}
