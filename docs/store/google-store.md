# Google Play Store Listing Copy

> Source of truth: `lib/app/translate/translate.dart`의 지원 로케일(en/ko), `lib/app/pages/*`, `lib/app/controllers/home_controller.dart`, `lib/app/domain/motion_alarm_logic.dart`, `android/app/src/main/AndroidManifest.xml`, `pubspec.yaml`.

Google Play 기본 제한은 앱 이름 30자, 간단한 설명 80자, 전체 설명 4000자다. 이 문서는 간단한 설명을 60자 이내로 더 짧게 관리한다. 제목에는 이모지, 순위/가격/프로모션 문구, 과장된 감지 보장 표현(100% 감지 등)을 넣지 않는다.

---

### 1. 영어 (en)

#### 앱 제목 (30자 이내)
Motion Alarm Pocket - Guard

#### 앱 간략한 설명 (60자 이내)
Motion-triggered alarm for a phone in your pocket or bag.

#### 앱 설명 (4000자 이내)
🔔 Turn your phone into a pocket motion alarm.
Motion Alarm Pocket sounds a siren and vibration when your phone or bag is moved, so you get a heads-up if someone touches it.
Set it, place the phone, and go.

⏱️ Simple to arm
• Set an arming delay so you have time to put the phone away
• Pick low, medium, or high motion sensitivity
• Tap Start — the phone watches for movement on its own

🚨 Clear alerts
• A siren sound plus vibration when motion is detected
• Stop the alarm yourself with a single tap
• A local history shows your recent detections

🔒 On-device and private
• Works fully on your device using the motion sensor
• No location, no account, no special permissions
• For entertainment and everyday utility; detection depends on your device and is not guaranteed

Remove ads anytime with a one-time Premium support purchase.

Privacy policy: https://dangundad.github.io/privacy/motion-alarm-pocket

---

### 2. 한국어 (ko)

#### 앱 제목 (30자 이내)
모션 알람 포켓 - 움직임 경보

#### 앱 간략한 설명 (60자 이내)
주머니·가방 속 폰의 움직임을 감지해 경보를 울리는 알람.

#### 앱 설명 (4000자 이내)
🔔 폰을 주머니 속 움직임 알람으로.
모션 알람 포켓은 폰이나 가방이 움직이면 사이렌과 진동으로 알려, 누군가 손대는 순간을 알아챌 수 있게 합니다.
설정하고, 폰을 두고, 자리를 비우세요.

⏱️ 간단한 감시 시작
• 폰을 둘 시간을 주는 감시 시작 딜레이 설정
• 낮음·중간·높음 감도 선택
• 시작을 누르면 폰이 스스로 움직임을 감시

🚨 분명한 경보
• 움직임 감지 시 사이렌 소리와 진동
• 한 번의 탭으로 직접 경보 중지
• 최근 감지 기록을 로컬에서 확인

🔒 기기 내 처리, 프라이버시
• 움직임 센서를 이용해 모든 동작을 기기 안에서 처리
• 위치·계정·별도 권한 불필요
• 엔터테인먼트 및 일상 유틸리티용이며, 감지는 기기에 따라 달라지고 보장되지 않습니다

일회성 프리미엄 후원으로 언제든 광고를 제거할 수 있습니다.

개인정보처리방침: https://dangundad.github.io/privacy/motion-alarm-pocket

---

## Google Play Console 로케일 메모

- 현재 인앱 번역은 2개 로케일(en/ko)을 지원한다. 스토어 등록 문구도 같은 언어 기준으로 관리한다.
- Play Console listing 언어: English (United States) — `en-US`, Korean — `ko-KR`.
- 추가 로케일로 확장할 때는 먼저 `translate.dart`에 인앱 번역을 추가한 뒤 스토어 문구를 등록해 설치 후 언어 불일치를 막는다.

## 금지 표현 점검 기준

- `100% 감지`, `완벽한 보안`, `절대 안전`, `guaranteed`, `never fails` 같은 감지·보안 보장 표현을 쓰지 않는다.
- 전문 보안 장비, 도난 방지 보장, 긴급 대응 기능으로 오인될 표현을 쓰지 않는다.
- 움직임 감지는 기기 센서와 환경에 따라 달라질 수 있음을 정직하게 표현한다.
- 앱이 실제로 제공하지 않는 기능(클라우드 동기화, 원격 알림, 위치 추적, 카메라 감시)을 넣지 않는다.
