# Motion Alarm Pocket 앱 이름 권장안

이 문서는 기기 표시명과 Google Play Console 등록명을 정리한다.
반영할 때는 Android 리소스, iOS 표시명, 인앱 번역(`lib/app/translate/translate.dart`), Google Play Console 등록값을 함께 맞춘다.

## 기기에 표시되는 앱 이름

```json
{
  "app_name": {
    "en": "Motion Alarm Pocket",
    "ko": "모션 알람 포켓",
    "ja": "モーションアラーム",
    "de": "Motion Alarm Pocket",
    "ru": "Сигнал движения",
    "fr": "Motion Alarm Pocket",
    "es": "Motion Alarm Pocket",
    "pt": "Motion Alarm Pocket",
    "id": "Motion Alarm Pocket",
    "zh": "口袋移动警报",
    "ar": "منبه حركة الجيب"
  }
}
```

## Google Play 스토어 제목 (30자 이내 권장)

```json
{
  "google_play_store_title": {
    "en": "Motion Alarm Pocket - Guard",
    "ko": "모션 알람 포켓 - 움직임 경보",
    "ja": "モーションアラーム - 見守り",
    "de": "Motion Alarm - Tasche",
    "ru": "Сигнал движения - Карман",
    "fr": "Motion Alarm - Poche",
    "es": "Motion Alarm - Bolsillo",
    "pt": "Motion Alarm - Bolso",
    "id": "Motion Alarm Pocket - Jaga",
    "zh": "口袋移动警报 - 守护",
    "ar": "منبه حركة الجيب"
  }
}
```

## Google Play Console 로케일 매핑

Play Console store listing 언어 코드는 앱 내부 `Locale(languageCode)`와 1:1이 아닐 수 있다.

| 앱 로케일 | Play Console listing 언어 | 스토어 제목 |
| --- | --- | --- |
| `en` | English (United States) — `en-US` | `Motion Alarm Pocket - Guard` |
| `ko` | Korean — `ko-KR` | `모션 알람 포켓 - 움직임 경보` |
| `ja` | Japanese — `ja-JP` | `モーションアラーム - 見守り` |
| `de` | German — `de-DE` | `Motion Alarm - Tasche` |
| `ru` | Russian — `ru-RU` | `Сигнал движения - Карман` |
| `fr` | French — `fr-FR` | `Motion Alarm - Poche` |
| `es` | Spanish — `es-ES` 또는 `es-419` | `Motion Alarm - Bolsillo` |
| `pt` | Portuguese — `pt-BR` 또는 `pt-PT` | `Motion Alarm - Bolso` |
| `id` | Indonesian — `id` | `Motion Alarm Pocket - Jaga` |
| `zh` | Chinese (Simplified) — `zh-CN` | `口袋移动警报 - 守护` |
| `ar` | Arabic — `ar` | `منبه حركة الجيب` |

## 메모

- Google Play 제목 글자 수 제한은 30자 기준으로 관리한다. 공백과 특수문자를 포함해 콘솔 등록 전에 다시 확인한다.
- 앱 서랍 이름은 `Motion`, `Alarm`, `Pocket` 또는 각 언어의 움직임/경보 핵심어가 보이도록 유지한다.
- Android `app_name`, iOS `CFBundleDisplayName`, GetX `translate.dart`의 `app_title`, 스토어 앱 이름을 같은 기준으로 맞춘다.
- 현재 인앱 번역은 11개 로케일(`en`/`ko`/`ja`/`de`/`ru`/`fr`/`es`/`pt`/`id`/`zh`/`ar`)을 지원한다.
- `100% 감지`, `완벽 보안`, `도난 방지 보장`, `guaranteed detection`처럼 읽히는 표현은 앱 이름, 부제, 설명에 사용하지 않는다.

## 참고

- Google Play Console Help: https://support.google.com/googleplay/android-developer/answer/9844778
