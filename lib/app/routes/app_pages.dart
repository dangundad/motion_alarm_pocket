import 'package:get/get.dart';

import '../bindings/app_binding.dart';
import '../pages/home/home_page.dart';

part 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: AppBinding(),
    ),
  ];
}
