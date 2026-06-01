import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motion_alarm_pocket/app/translate/translate.dart';

void main() {
  const expectedLanguageCodes = [
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

  group('AppTranslations', () {
    test('supports the same 11 language codes as the mirror app', () {
      final actualLanguageCodes = AppTranslations.supportedLocales
          .map((locale) => locale.languageCode)
          .toList();

      expect(actualLanguageCodes, expectedLanguageCodes);
      expect(AppTranslations().keys.keys.toList(), expectedLanguageCodes);
    });

    test('defines the same translation keys for every supported locale', () {
      final translations = AppTranslations().keys;
      final expectedKeySet = translations['en']!.keys.toSet();

      expect(translations.keys.toSet(), expectedLanguageCodes.toSet());

      for (final languageCode in expectedLanguageCodes) {
        final localeTranslations = translations[languageCode];

        expect(
          localeTranslations,
          isNotNull,
          reason: '$languageCode translations must exist.',
        );
        expect(
          localeTranslations!.keys.toSet(),
          expectedKeySet,
          reason: '$languageCode must contain every base translation key.',
        );
        expect(
          localeTranslations.values.every((value) => value.trim().isNotEmpty),
          isTrue,
          reason: '$languageCode must not contain empty translations.',
        );
      }
    });

    test('contains every translation key referenced in lib', () {
      final translations = AppTranslations().keys;
      final expectedKeySet = translations['en']!.keys.toSet();
      final usedKeys = _findReferencedTranslationKeys(Directory('lib'));

      expect(usedKeys, isNotEmpty);
      expect(
        expectedKeySet.containsAll(usedKeys),
        isTrue,
        reason: 'Base locale must contain every key used by the app.',
      );

      for (final languageCode in expectedLanguageCodes) {
        final missingKeys = usedKeys.difference(
          translations[languageCode]!.keys.toSet(),
        );

        expect(
          missingKeys,
          isEmpty,
          reason: '$languageCode is missing keys used by the app.',
        );
      }
    });
  });
}

Set<String> _findReferencedTranslationKeys(Directory root) {
  final literalTrPattern = RegExp(
    r"'([a-z][a-z0-9_]*)'\s*\.\s*(?:tr|trParams)",
    multiLine: true,
  );
  final declaredKeyPattern = RegExp(
    r"(?:titleKey|descKey|textKey)\s*:\s*'([a-z][a-z0-9_]*)'",
    multiLine: true,
  );

  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('translate.dart'))
      .expand((file) {
        final source = file.readAsStringSync();
        return [
          ...literalTrPattern.allMatches(source),
          ...declaredKeyPattern.allMatches(source),
        ].map((match) => match.group(1)!);
      })
      .toSet();
}
