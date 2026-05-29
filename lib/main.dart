import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/admob/ads_helper.dart';
import 'app/bindings/app_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/services/hive_service.dart';
import 'app/theme/app_theme.dart';
import 'app/translate/translate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await HiveService.init();
  await AdHelper.initialize();
  runApp(const CuriosityApp());
}

class CuriosityApp extends StatelessWidget {
  const CuriosityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: 'Motion Alarm Pocket',
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: Get.deviceLocale ?? const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          initialBinding: AppBinding(),
          initialRoute: Routes.home,
          getPages: AppPages.pages,
        );
      },
    );
  }
}
