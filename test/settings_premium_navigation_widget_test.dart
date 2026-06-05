import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:motion_alarm_pocket/app/controllers/home_controller.dart';
import 'package:motion_alarm_pocket/app/controllers/settings_controller.dart';
import 'package:motion_alarm_pocket/app/pages/settings/settings_page.dart';
import 'package:motion_alarm_pocket/app/routes/app_pages.dart';
import 'package:motion_alarm_pocket/app/services/purchase_service.dart';
import 'package:motion_alarm_pocket/app/translate/translate.dart';

class TestHomeController extends HomeController {
  // Test double: avoid Hive/sensor initialization during widget tests.
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  // ignore: must_call_super
  void onClose() {}
}

class TestSettingsController extends SettingsController {
  // Test double: avoid AlertService access when the test resets GetX.
  @override
  // ignore: must_call_super
  void onClose() {}
}

class TestPurchaseService extends PurchaseService {
  // Test double: avoid initializing the platform store during widget tests.
  @override
  // ignore: must_call_super
  Future<void> onInit() async {}

  @override
  Future<void> restorePurchases() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('settings premium entry opens the premium route', (tester) async {
    Get.testMode = true;
    Get.put<HomeController>(TestHomeController());
    Get.put<SettingsController>(TestSettingsController());
    Get.put<PurchaseService>(TestPurchaseService(), tag: 'purchase_service');

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          getPages: [
            GetPage(
              name: Routes.premium,
              page: () => const Scaffold(body: Text('premium-route-marker')),
            ),
          ],
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('settings_premium_entry')));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, Routes.premium);
    expect(find.text('premium-route-marker'), findsOneWidget);
  });
}
