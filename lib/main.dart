import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/theme/dark_theme.dart';
import 'app/theme/light_theme.dart';
import 'app/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ThemeController themeController = Get.put(ThemeController());
  await themeController.loadTheme();

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
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeController.themeMode,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
