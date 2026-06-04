# Motion Alarm Pocket - Guard - Play Review Notes

> 최신화: 2026-06-04
> 패키지명: com.dangundad.motion.alarm.pocket
> 목적: Google Play Console의 메타데이터, 광고, 결제, 권한, Data safety 검토 대응

## 문제 요약

Google Play Console 제출 전 아래 항목을 같은 기준으로 맞춘다.

- 스토어 설명이 현재 구현 기능만 설명하는지 확인
- 앱 제목, 간략 설명, 전체 설명이 Google Play 제한과 Metadata 정책에 맞는지 확인
- 권한 사용 목적과 실제 Manifest 선언이 일치하는지 확인
- 광고와 Premium 설명이 기능 보장처럼 읽히지 않는지 확인
- 리뷰용 스크린샷/영상이 실제 앱 화면과 현재 구현 흐름만 보여주는지 확인

## 앱 동작 요약

모션 알람 포켓 - 움직임 경보 앱은 사용자가 직접 시작하는 로컬 유틸리티입니다.

- 눈에 보이는 시작 지연 후 켜지는 가속도계 세션
- 낮음, 보통, 높음 감도 선택
- 사용 전 사이렌/비프 경보음 미리듣기
- 알람 세션 후 남는 최근 로컬 기록

### 한계 고지

- 움직임 감지는 기기 가속도계에 의존하는 로컬 기능이며 보안을 보장하지 않습니다.
- 앱이 사용하는 센서, 마이크, 배터리, 알림 신호와 OS 상태에 따라 결과가 달라질 수 있다.
- 실제 보안, 회수, 긴급 대응, 실제 통신, 실제 탐지 보장 표현을 사용하지 않는다.

## Manifest 권한

현재 android/app/src/main/AndroidManifest.xml 기준입니다.

- android.permission.INTERNET
- android.permission.VIBRATE
- com.google.android.gms.permission.AD_ID

권한 설명은 앱 화면의 사용자 시작 흐름과 연결해 작성한다. Manifest에 없는 위치, 연락처, SMS, 전화 권한을 사용한다고 설명하지 않는다.

## 데이터 처리 명세

| 데이터 | 저장/사용 위치 | 외부 전송 | 사용자 제어 |
| --- | --- | --- | --- |
| accelerometer motion readings during an armed local session | 앱 내 로컬 세션 | 없음 | 시작/중지/해제 UI |
| 앱 설정과 기록 | Hive CE 또는 SharedPreferences | 없음 | 앱 내 설정/기록 관리 |
| 광고 ID와 광고 요청 | Google Mobile Ads SDK | SDK 정책에 따름 | Android 광고 ID 설정 및 UMP/광고 동의 |
| 결제 상태 | Google Play Billing / 로컬 Premium 상태 | Google 결제 시스템 | 구매/복원 |

## 광고/IAP 제출 기준

- 광고 포함 여부: 광고 포함
- 광고 위치:
- 홈 하단 배너
- 알람 해제 또는 세션 종료 후 전면 광고
- 보상형 광고 클래스는 있으나 보상 흐름 연결 전 스토어 노출 금지
- Premium/IAP: 3단 일회성 관리형 상품을 등록하고, 어떤 상품이든 동일한 Premium 상태로 매핑한다.

~~~text
The app offers three one-time non-consumable supporter products. Any successful purchase or restore enables one Premium state that removes ads. It does not change detection accuracy, security level, or real-world capability.
~~~

## 제출용 영어 답변

~~~text
Motion Alarm Pocket - Guard is a local Android utility. The app processes accelerometer motion readings during an armed local session only for the user-started app session. It does not upload this signal data to a custom server.

The app may use Google Mobile Ads and mediation SDKs for ads. Ad requests do not include raw sensor, microphone, battery, notification, or fake-call content beyond normal SDK behavior.

The app offers three one-time non-consumable supporter products. Any successful purchase or restore enables one Premium state that removes ads. It does not change detection accuracy, security level, or real-world capability.

The app does not guarantee security, recovery, emergency response, real phone network behavior, or real-world detection results. Hardware and OS signals can vary by device and environment.
~~~

## 리뷰어 재현 경로

1. 대표 이미지 - 한눈에 보는 모션 알람 - home.png: 시작 버튼, delay, sensitivity, banner 위치
2. 시작 지연 - 준비 후 감시 - 홈의 countdown/arming 진행 상태
3. 감시 중 - armed 상태 - armed.png: start delay 이후 armed 상태
4. 경보와 해제 - alarm active와 stop/disarm 조작 흐름
5. 사운드와 감도 설정 - settings: siren/beep, Low/Med/High
6. Premium - 광고 제거 후원 - premium page: 3단 일회성 후원

## 메타데이터 작성 규칙

- 앱 제목은 30자 이내로 유지한다.
- 간략 설명은 Play Console 제한 안에서 핵심 기능만 적는다.
- 전체 설명은 현재 구현 기능, 로컬 처리, 한계를 분리해서 쓴다.
- 순위, 가격, 할인, "No Ads", "Free", 보장 표현, 실제 통신/탐지/보안 오해 표현을 제목이나 스크린샷 문구에 넣지 않는다.
- 모든 번역 스토어 등록정보에도 같은 Metadata 정책을 적용한다.

## 제출 전 체크리스트

- [ ] google-store.md의 앱 제목/간략 설명/전체 설명을 Play Console 로케일별로 반영
- [ ] google-app-name.md의 런처명과 store title을 실제 strings.xml/Manifest와 대조
- [ ] google-store-image.md의 스크린샷 흐름이 실제 앱 화면과 일치
- [ ] google-ads-subscription.md의 AdMob/IAP ID와 코드 상수가 일치
- [ ] 테스트 광고 ID와 실제 AdMob ID 교체 상태 확인
- [ ] Data safety 답변과 개인정보처리방침에 광고/결제/로컬 저장 설명 반영
- [ ] 개인 정보, 테스트 계정, 디버그 배너, 테스트 광고 ID가 스크린샷/영상에 노출되지 않음

## 공식 참고

- Google Play Metadata policy: https://support.google.com/googleplay/android-developer/answer/9898842
- Google Play store listing fields: https://support.google.com/googleplay/android-developer/answer/9859152
- Google Play store listing best practices: https://support.google.com/googleplay/android-developer/answer/13393723
