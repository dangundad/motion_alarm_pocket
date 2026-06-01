# Motion Alarm Pocket 앱 이름 권장안

이 문서는 기기 표시명과 Google Play 스토어 제목 권장안을 정리한다.
반영할 때는 Android 리소스, 인앱 번역(`translate.dart`의 `app_title`), Google Play Console 등록값을 함께 맞춘다.

## 기기에 표시되는 앱 이름
```json
{
  "app_name": {
    "en": "Motion Alarm Pocket",
    "ko": "모션 알람 포켓"
  }
}
```

## Google Play 스토어 제목 (30자 이내 권장)
```json
{
  "google_play_store_title": {
    "en": "Motion Alarm Pocket - Guard",
    "ko": "모션 알람 포켓 - 움직임 경보"
  }
}
```

## Google Play Console 로케일 매핑

| 앱 로케일 | Play Console listing 언어 | 스토어 제목 |
| --- | --- | --- |
| `en` | English (United States) — `en-US` | `Motion Alarm Pocket - Guard` |
| `ko` | Korean — `ko-KR` | `모션 알람 포켓 - 움직임 경보` |

### 추가 확인 후보

- 무슬림권/유럽권 등 타깃 확장 시 `ja`, `es`, `pt`, `de` 등을 후보로 검토할 수 있다. 다만 현재 앱 UI 로케일에는 en/ko만 있으므로, 스토어 제목만 먼저 추가하면 설치 후 인앱 언어와 불일치할 수 있다. 다음 번 앱 로케일 확장 후보로 관리한다.

## 메모
- Google Play 제목 글자 수 제한은 30자 기준으로 관리한다. 공백과 특수문자를 포함해 콘솔 등록 전에 다시 확인한다.
- 앱 서랍 이름은 `Motion`/`Alarm` 키워드가 보이도록 유지한다. 로케일별로 너무 길면 `Motion Alarm`, `모션 알람` 중심의 축약형을 사용한다.
- Android `app_name`(AndroidManifest `android:label`), GetX `translate.dart`의 `app_title`, 스토어 앱 이름을 같은 기준으로 맞춘다.
- 현재 인앱 번역은 2개 로케일(en/ko)을 지원한다. 스토어 등록명도 같은 언어 기준으로 관리한다.
- `100% 감지`, `완벽 보안`, `도난 방지 보장`처럼 읽히는 표현은 앱 이름, 부제, 설명에 사용하지 않는다.

## 참고

- Google Play Console Help: https://support.google.com/googleplay/android-developer/answer/9844778/translate-and-localize-your-app
