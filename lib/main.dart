import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/admob/ads_helper.dart';
import 'app/bindings/app_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/services/hive_service.dart';
import 'app/theme/app_theme.dart';
import 'app/translate/translate.dart';

// Boot sequence: orientation lock -> Hive (startup-critical) -> system UI ->
// runApp -> post-first-frame MobileAds init.
//
// Startup speed: the ad SDK touches a platform channel and the network, so it
// is deferred past the first frame to paint the UI sooner. Hive stays on the
// critical path because controllers read their boxes in onInit.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Boxes must be open before the first frame: HomeController/HiveService read
  // them synchronously during initial route resolution and onInit.
  await HiveService.init();

  // Draw under the status/navigation bars. Every page wraps its content in
  // SafeArea, so the content stays clear of the system insets.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const CuriosityApp());

  // MobileAds (and the bundled mediation adapters) init after the first frame.
  // Banner and interstitial loaders retry on their own, so this brief delay
  // never permanently drops an ad.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(AdHelper.initialize());
  });
}

class CuriosityApp extends StatelessWidget {
  const CuriosityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          onGenerateTitle: (_) => 'app_title'.tr,
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: Get.deviceLocale ?? const Locale('en'),
          fallbackLocale: const Locale('en'),
          supportedLocales: AppTranslations.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          defaultTransition: Transition.fadeIn,
          initialBinding: AppBinding(),
          initialRoute:
              HiveService.isFirstRun() ? Routes.onboarding : Routes.home,
          getPages: AppPages.pages,
          builder: (context, child) {
            // Clamp text scaling so an extreme system font size can't break the
            // status text, sliders, or segmented buttons.
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: mediaQuery.textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.5,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
