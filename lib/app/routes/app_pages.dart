import 'package:get/get.dart';

import '../bindings/app_binding.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/settings_controller.dart';
import '../pages/home/home_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/premium/premium_page.dart';
import '../pages/settings/settings_page.dart';

part 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut<OnboardingController>(() => OnboardingController()),
      ),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: AppBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
      // HomeController is the source of truth for settings; SettingsController
      // is a thin facade over it. AppBinding guarantees HomeController exists.
      binding: BindingsBuilder(
        () => Get.lazyPut<SettingsController>(() => SettingsController()),
      ),
    ),
    GetPage(
      name: Routes.premium,
      page: () => const PremiumPage(),
    ),
  ];
}
