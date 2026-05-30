# Motion Alarm Pocket

Android-first Flutter app (상용 배포 준비 완료). DangunDad 포트폴리오.

## Package ID

`com.dangundad.motion_alarm_pocket` — 변경 금지.

## Architecture

- **패턴**: GetX MVC (`lib/app/` 하위 구조 유지)
- **상태관리**: GetX Observables (`.obs`)
- **로컬 저장**: Hive CE (`hive_service.dart`) — 설정·히스토리
- **설정 영속 키**: `delay_seconds` (int), `sensitivity` (String = enum name)
- **히스토리**: 최대 50개 자동 캡

## Monetization

- **3-tier 1회성 IAP** (`purchase_service.dart`, tag: `'purchase_service'`)
  - `motion_alarm_pocket_premium_small` / `_medium` / `_large`
  - 어느 티어든 `isPremium = true` 동일 혜택 (광고 제거)
- **광고**: Google AdMob + AppLovin·Pangle·Unity 미디에이션
  - ⚠️ `ads_helper.dart`의 테스트 ID를 실제 ID로 교체 후 배포

## Routes

- `/` — `HomePage`
- `/premium` — `PremiumPage`

## i18n

- `lib/app/translate/translate.dart` — en\_US / ko\_KR
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
