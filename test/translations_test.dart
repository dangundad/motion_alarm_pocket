import 'package:flutter_test/flutter_test.dart';
import 'package:motion_alarm_pocket/app/translate/translate.dart';

void main() {
  group('AppTranslations', () {
    test('supports the same 11 languages as the mirror app', () {
      const expectedLocaleCodes = [
        'en',
        'ko',
        'ja',
        'de',
        'ru',
        'fr',
        'es',
        'pt',
        'id',
        'zh',
        'ar',
      ];

      expect(AppTranslations().keys.keys.toList(), expectedLocaleCodes);
    });

    test('defines the same translation keys for every language', () {
      final translations = AppTranslations().keys;
      final baseKeys = translations['en']!.keys.toSet();

      for (final entry in translations.entries) {
        expect(entry.value.keys.toSet(), baseKeys, reason: entry.key);
        expect(
          entry.value.values.every((value) => value.trim().isNotEmpty),
          isTrue,
          reason: entry.key,
        );
      }
    });
  });
}
