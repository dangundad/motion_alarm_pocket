import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  group('qibla-style premium/onboarding/settings contract', () {
    test('uses the requested three one-time support prices in UI and docs', () {
      final premiumPage = _read('lib/app/pages/premium/premium_page.dart');
      final storeDoc = _read('docs/store/google-ads-subscription.md');

      for (final price in const [r'$2.99', r'$5.99', r'$9.99']) {
        expect('$premiumPage\n$storeDoc', contains(price));
      }

      expect('$premiumPage\n$storeDoc', isNot(contains(r'$0.99')));
      expect('$premiumPage\n$storeDoc', isNot(contains(r'$4.99')));
    });

    test('premium page keeps Small default and Medium recommended tier', () {
      final premiumPage = _read('lib/app/pages/premium/premium_page.dart');

      expect(premiumPage, contains('int _selectedIndex = 0'));
      expect(premiumPage, contains('popular: true'));
      expect(premiumPage, contains('restorePurchases'));
    });

    test('settings screen has a direct premium entry route', () {
      final settingsPage = _read('lib/app/pages/settings/settings_page.dart');

      expect(settingsPage, contains('Get.toNamed(Routes.premium)'));
      expect(settingsPage, contains('premium_purchase'));
    });

    test('first run still routes through onboarding before home', () {
      final main = _read('lib/main.dart');
      final onboardingPage = _read(
        'lib/app/pages/onboarding/onboarding_page.dart',
      );

      expect(
        main,
        contains('HiveService.isFirstRun() ? Routes.onboarding : Routes.home'),
      );
      expect(onboardingPage, contains('PageView'));
      expect(onboardingPage, contains('onboarding_skip'));
    });
  });
}
