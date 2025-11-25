import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/lang/en_US.dart';
import 'app/lang/fa_IR.dart';
import 'app/routes/app_pages.dart';
import 'app/services/premium_service.dart';
import 'app/theme/dark_theme.dart';
import 'app/theme/light_theme.dart';
import 'app/theme/theme_controller.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'fa_IR': faIR,
      };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ThemeController themeController = Get.put(ThemeController());
  await themeController.loadTheme();

  final PremiumService premiumService =
      Get.put(PremiumService(), permanent: true);
  unawaited(premiumService.init());

  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'ResumeYar',
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeController.themeMode,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
