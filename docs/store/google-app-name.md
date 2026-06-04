# 핸드폰에 표시될 앱 이름
# 현재 프로젝트: motion_alarm_pocket / 패키지 com.dangundad.motion.alarm.pocket.
# 런처 라벨은 좁은 홈 화면에서 잘리지 않도록 짧게 유지하고, 스토어 제목에서 핵심 기능을 보강한다.
# 실제 리소스 반영 위치: AndroidManifest.xml android:label 또는 android/app/src/main/res/values*/strings.xml.
{
  "app_name": {
    "en": "Motion Alarm Pocket",
    "ko": "모션 알람 포켓",
    "ja": "モーションアラーム",
    "de": "Motion Alarm Pocket",
    "ru": "Сигнал движения",
    "fr": "Alarme de mouvement",
    "es": "Alarma de movimiento",
    "pt": "Alarme de movimento",
    "id": "Alarm Gerak",
    "zh": "移动警报",
    "ar": "منبه الحركة"
  }
}

# 구글 스토어 타이틀 (최대 30자)
# Google Play Console 입력용 제목. google-store.md의 각 로케일 앱 제목과 같은 문구를 사용한다.
# 공식 기준: 앱 이름은 30자 이내. 순위/가격/프로모션성 표현은 쓰지 않는다.
{
  "google_play_store_title": {
    "en": "Motion Alarm Pocket - Guard",
    "ko": "모션 알람 포켓 - 움직임 경보",
    "ja": "モーションアラーム - 見守り",
    "de": "Bewegungsalarm Tasche",
    "ru": "Карманный сигнал движения",
    "fr": "Alarme mouvement poche",
    "es": "Alarma movimiento bolsillo",
    "pt": "Alarme de movimento",
    "id": "Alarm Gerak Saku",
    "zh": "口袋移动警报",
    "ar": "منبه حركة الجيب"
  }
}

# Google Play Console 로케일 매핑

| 앱 로케일 | Play Console listing 언어 | 스토어 제목 |
| --- | --- | --- |
| `en` | English (United States) - en-US | `Motion Alarm Pocket - Guard` |
| `ko` | Korean - ko-KR | `모션 알람 포켓 - 움직임 경보` |
| `ja` | Japanese - ja-JP | `モーションアラーム - 見守り` |
| `de` | German - de-DE | `Bewegungsalarm Tasche` |
| `ru` | Russian - ru-RU | `Карманный сигнал движения` |
| `fr` | French - fr-FR | `Alarme mouvement poche` |
| `es` | Spanish - es-ES / es-419 | `Alarma movimiento bolsillo` |
| `pt` | Portuguese - pt-BR / pt-PT | `Alarme de movimento` |
| `id` | Indonesian - id | `Alarm Gerak Saku` |
| `zh` | Chinese (Simplified) - zh-CN | `口袋移动警报` |
| `ar` | Arabic - ar | `منبه حركة الجيب` |

# 정책 출처
# - Google Play Metadata 정책: https://support.google.com/googleplay/android-developer/answer/9898842
# - Google Play store listing 필드 제한: https://support.google.com/googleplay/android-developer/answer/9859152

# 보조 후보 (상황별 대체안)

| 용도 | 한국어 | English | 메모 |
| --- | --- | --- | --- |
| 간결형 | 모션 알람 포켓 | Motion Alarm Pocket | 런처명/검색 진입 최단형 |
| 기능 강조형 | 모션 알람 포켓 - 움직임 경보 | Motion Alarm Pocket - Guard | 현재 권장 스토어 제목 |

# 네이밍 규칙
# - 실제 구현되지 않은 기능, 보장 표현, 순위/가격/프로모션성 표현을 제목에 넣지 않는다.
# - 스토어 제목은 각 언어의 핵심 기능어를 앞쪽에 배치하되 30자 제한을 다시 확인한다.
# - Store title에 기능명을 넣기 전에 실제 앱 접근 경로와 권한 흐름을 확인한다.
# - google-store.md의 앱 제목과 이 문서의 google_play_store_title을 같은 기준으로 유지한다.
