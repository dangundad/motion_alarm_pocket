# Motion Alarm Pocket

Android-first Flutter app (상용 배포 준비 완료). DangunDad 포트폴리오.

## Package ID

`com.dangundad.motion_alarm_pocket` — 변경 금지.

## Architecture

- **패턴**: GetX MVC (`lib/app/` 하위 구조 유지)
- **상태관리**: GetX Observables (`.obs`)
- **로컬 저장**: Hive CE (`hive_service.dart`) — 설정·히스토리
- **설정 영속 키**: `delay_seconds` (int), `sensitivity` (String), `alarm_sound` (String = siren/beep), `haptics_enabled` (bool)
- **히스토리**: 최대 50개 자동 캡

## Design & Audio (2026-06-03 고도화)

- **아이덴티티 "Sentry"**: 다크 우선(`ThemeMode.dark`). 스톡 FlexScheme 대신 `app_theme.dart`에서 직접 지정한 크림슨/앰버/슬레이트 팔레트 + 헤딩 `GoogleFonts.rajdhani`. 시맨틱 색 `AppTheme.alarm/armed/arming/disarmed`.
- **시그니처**: `pages/home/widgets/arm_dial.dart` — 탭하면 무장/해제되는 커스텀 페인트 파워 다이얼(무장 카운트다운 채움 → 무장 시 앰버 브리딩 → 알람 시 크림슨 플래시 + 실시간 모션 반응 아크).
- **실제 알람음**: `AlertService`가 `audioplayers`로 `assets/sounds/{siren,beep_alarm}.wav`를 풀 볼륨 루프 재생(+진동, 실패 시 진동 폴백) — 무음 모드에서도 가청(기존 `SystemSound` 대체). Siren/Beep 선택은 영속 저장되고 Settings의 "테스트"로 미리듣기.
- 미사용 Firebase/google-services gradle 설정 제거. `flutter analyze`/`test`/`build apk --debug` 통과(워크스페이스 AGP 8.13.2 기준).

## Monetization

- **3-tier 1회성 IAP** (`purchase_service.dart`, tag: `'purchase_service'`)
  - `motion_alarm_pocket_premium_small` / `_medium` / `_large`
  - 어느 티어든 `isPremium = true` 동일 혜택 (광고 제거)
- **광고**: Google AdMob + AppLovin·Pangle·Unity 미디에이션
  - ⚠️ `ads_helper.dart`의 테스트 ID를 실제 ID로 교체 후 배포

## Routes

- `/onboarding` — `OnboardingPage` (첫 실행)
- `/` — `HomePage`
- `/settings` — `SettingsPage` (지연·민감도·알림음·테스트·햅틱)
- `/premium` — `PremiumPage`

## i18n

- `lib/app/translate/translate.dart` — en / ko / ja / de / ru / fr / es / pt / id / zh / ar
- 모든 UI 문자열 `.tr` 또는 `.trParams()` 사용
- 히스토리 저장 시 `.tr` 적용 (저장 시점 로케일 반영)

## Rules

- 하드웨어 입력은 로컬 한정, 100% 감지를 보장하는 표현 사용 금지
- `PurchaseService`는 반드시 `tag: 'purchase_service'`로 등록
- `stopAlarm()`은 `_shouldShowAd()`로 광고 여부 판단 후 인터스티셜 표시

## Commands

```
flutter analyze
flutter test
flutter build apk --debug
```

## Pre-release Checklist

- [ ] `ads_helper.dart` 테스트 ID → 실제 AdMob 단위 ID 교체
- [ ] Google Play Console에서 3개 IAP 제품 등록 및 가격 설정
- [ ] 릴리즈 keystore 서명 설정 (`key.properties`)
- [ ] `AndroidManifest.xml` 앱 메타데이터 확인
