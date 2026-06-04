# 모션 알람 포켓 - 움직임 경보

시작 지연과 감도를 고르는 주머니 모션 알람.

Android 우선 Flutter 앱이며 DangunDad(com.dangundad) 포트폴리오의 호기심 훅 기반 유틸리티입니다. 현재 README는 docs/store 문서와 같은 구현 기준으로 유지합니다.

> 움직임 감지는 기기 가속도계에 의존하는 로컬 기능이며 보안을 보장하지 않습니다.

## 현재 상태

- **버전**: 1.0.0+1 (pubspec.yaml)
- **앱 ID**: com.dangundad.motion.alarm.pocket
- **앱 표시 이름**: 모션 알람 포켓 / Motion Alarm Pocket
- **Store title**: 모션 알람 포켓 - 움직임 경보 / Motion Alarm Pocket - Guard
- **지원 로케일**: en, ko, ja, de, ru, fr, es, pt, id, zh, ar
- **입력/신호 기준**: accelerometer motion readings during an armed local session
- **수익화**: 무료 + 광고 + 3단 일회성 Premium

## 주요 기능

- 눈에 보이는 시작 지연 후 켜지는 가속도계 세션
- 낮음, 보통, 높음 감도 선택
- 사용 전 사이렌/비프 경보음 미리듣기
- 알람 세션 후 남는 최근 로컬 기록

## 개인정보와 한계

- 앱 기능은 사용자가 시작한 로컬 세션을 기준으로 동작한다.
- 앱이 사용하는 센서, 마이크, 배터리, 알림 신호는 기기 상태와 OS 환경에 따라 달라질 수 있다.
- 실제 보안, 실제 회수, 실제 통신, 긴급 대응, 실제 금속/보물 탐지를 보장하지 않는다.
- 광고 SDK와 결제 SDK 사용 사실은 Play Console Data safety와 개인정보처리방침에 반영한다.

## 기술 스택

| 영역 | 사용 |
| --- | --- |
| 프레임워크 | Flutter / Dart SDK ^3.12.0 |
| 상태 관리 / 라우팅 | GetX |
| 로컬 저장 | Hive CE, 앱별 SharedPreferences |
| UI | flutter_screenutil, flex_color_scheme, google_fonts, lucide_icons_flutter |
| 광고 | google_mobile_ads + AppLovin / Pangle / Unity mediation |
| 결제 | in_app_purchase 3-tier one-time supporter products |

정확한 패키지 버전은 항상 pubspec.yaml을 기준으로 확인합니다.

## 프로젝트 구조

~~~text
lib/
  main.dart
  app/
    admob/
    bindings/
    controllers/
    domain/
    pages/
    routes/
    services/
    theme/
    translate/
docs/
  store/
~~~

## 시작하기

~~~powershell
flutter pub get
flutter run
~~~

릴리스 빌드는 자동화하지 않습니다. flutter build apk, flutter build appbundle, 서명 설정은 배포 직전에 별도 확인합니다.

## 개발 명령어

~~~powershell
flutter pub outdated --no-transitive
flutter analyze
flutter test
flutter build apk --debug
~~~

## 수익화

- **모델**: 무료 + 광고 + 3단 일회성 후원형 Premium
- **Premium 혜택**: 모든 광고 제거. 감지 성능이나 보안 수준 차등 없음.
- **광고 지점**:
- 홈 하단 배너
- 알람 해제 또는 세션 종료 후 전면 광고
- 보상형 광고 클래스는 있으나 보상 흐름 연결 전 스토어 노출 금지

| Tier | Android product ID | iOS product ID | 기준 가격 |
| --- | --- | --- | --- |
| Small | motion_alarm_pocket_premium_small | - | $0.99 |
| Medium | motion_alarm_pocket_premium_medium | - | $2.99 |
| Large | motion_alarm_pocket_premium_large | - | $4.99 |

어떤 Premium 상품을 구매해도 단일 Premium 상태로 매핑하며, 기능 보장/보안 보장/감지 성능 차등처럼 설명하지 않는다.

## Android 권한

현재 android/app/src/main/AndroidManifest.xml에 선언된 권한입니다.

- android.permission.INTERNET
- android.permission.VIBRATE
- com.google.android.gms.permission.AD_ID

## 주요 문서

- 에이전트 지침: AGENTS.md / CLAUDE.md
- Google Play 스토어 메타: docs/store/google-store.md
- Google Play 앱 이름: docs/store/google-app-name.md
- 스크린샷 가이드: docs/store/google-store-image.md
- 광고/IAP 설정: docs/store/google-ads-subscription.md
- Play 심사 메모: docs/store/play-review-notes.md

## 출시 전 체크리스트

- [ ] AdMob app id와 ad unit id를 테스트 ID에서 실제 ID로 교체
- [ ] Premium 앱은 Play Console 상품 ID와 코드의 PurchaseConstants 값을 대조
- [ ] Manifest 권한과 Play Console Data safety 답변을 대조
- [ ] docs/store의 title, short description, full description 제한을 재확인
- [ ] 실제 화면 캡처가 현재 구현 기능만 보여주는지 확인

## 라이선스

DangunDad 포트폴리오 비공개 프로젝트입니다.
