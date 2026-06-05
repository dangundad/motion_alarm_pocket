## 구글 플레이 콘솔 인앱 구매 설정 (Motion Alarm Pocket - Guard - 무료 + 3단 후원형 프리미엄)

### 중요: 기본 무료 앱

motion_alarm_pocket(com.dangundad.motion.alarm.pocket)는 핵심 기능을 무료로 제공하며, 사용자가 원할 경우 3단 일회성 후원 상품으로 Premium을 활성화할 수 있습니다.

### 앱 수익 모델

- **기본: 무료**: 핵심 흐름은 결제 없이 사용 가능
- **광고 포함**:
  - 홈 하단 배너
  - 알람 해제 또는 세션 종료 후 전면 광고
  - 보상형 광고 클래스는 있으나 보상 흐름 연결 전 스토어 노출 금지
- **프리미엄 구매(3단 후원)**:
  - 일회성 관리형 상품(Non-Consumable) 3개
  - 어떤 옵션을 구매해도 동일한 Premium 플래그 활성화
  - 혜택: 모든 광고 제거. 감지 성능이나 보안 수준 차등 없음.

### 현재 프리미엄 모델

✅ **3단 일회성 구매 (Non-Consumable) - 광고 제거 후원**

| 상품 | Android ID | iOS Product ID | 권장 가격 | 설명 |
| --- | --- | --- | --- | --- |
| Small | motion_alarm_pocket_premium_small | - | $2.99 | 작은 후원, 광고 제거 |
| Medium | motion_alarm_pocket_premium_medium | - | $5.99 | 인기 옵션, 광고 제거와 추가 후원 |
| Large | motion_alarm_pocket_premium_large | - | $9.99 | 광고 제거와 든든한 후원 |

> **상품 ID 기준**: Play Console / App Store Connect / 코드의 PurchaseConstants 값을 이 문서와 동일하게 맞춘다. 어떤 상품이든 구매 또는 복원 성공 시 단일 Premium 상태로 매핑한다.
>
> **가격 참고**: 실제 앱 화면에서는 스토어가 내려주는 현지 가격을 우선 표시한다. 문서의 권장 가격은 fallback 또는 등록 기준으로만 사용한다.

### 프리미엄 구매 시 혜택

- 광고 제거
- 일회성 구매, 구독 없음
- 구매 복원 지원
- 개발자 후원
- 감지 정확도, 보안, 실제 통신, 긴급 대응을 보장하는 혜택처럼 표현하지 않음

### 앱 내 프리미엄 페이지 구성

- Small / Medium / Large 후원 옵션을 카드로 제시
- 옵션별 기능 차등이 없음을 명확히 표시
- 스토어 가격이 있으면 해당 가격을 우선 표시
- 구매 복원 버튼 제공

---

## 구글 플레이 콘솔 인앱 구매 설정 가이드

### A. 앱 등록 시 선택사항

1. Google Play Console → 앱 → 가격 및 배포로 이동
2. 무료 선택
3. 광고 포함 여부 선택: 광고 포함 체크
4. 앱 내 구매 체크

### B. 인앱 구매 상품 등록 (Android)

1. Google Play Console → 앱 → 수익 창출 → 제품 → 인앱 상품
2. 관리형 제품 만들기 또는 일회성 상품 만들기 선택
3. 아래 3개 상품을 등록한 뒤 활성화

**상품: Small Premium**
- 상품 ID: motion_alarm_pocket_premium_small
- 유형: 관리형 제품 / Non-Consumable
- 설명: 작은 후원, 광고 제거
- 권장 가격: $2.99
- 상태: 출시 전 활성화 확인
**상품: Medium Premium**
- 상품 ID: motion_alarm_pocket_premium_medium
- 유형: 관리형 제품 / Non-Consumable
- 설명: 인기 옵션, 광고 제거와 추가 후원
- 권장 가격: $5.99
- 상태: 출시 전 활성화 확인
**상품: Large Premium**
- 상품 ID: motion_alarm_pocket_premium_large
- 유형: 관리형 제품 / Non-Consumable
- 설명: 광고 제거와 든든한 후원
- 권장 가격: $9.99
- 상태: 출시 전 활성화 확인

### C. 리뷰 관리

- 무료 앱이므로 초기 사용자 피드백 대응 속도가 중요
- 광고가 핵심 흐름을 막지 않는다는 점을 명확히 안내
- Premium 구매 후 기능 보장이 아니라 광고 제거/후원 성격임을 명확히 안내
- 구매 복원 문의에 빠르게 대응

### D. 구매 복원 기능

- 앱에 구매 복원 버튼 구현 필요
- 재설치 시 사용자가 구매 내역 복원 가능해야 함
- Android 우선, iOS 출시 시 App Store Connect 상품 상태를 별도 검증

---

## 광고 설정

### AdMob 앱

- Android 패키지는 com.dangundad.motion.alarm.pocket와 일치시킨다.
- 현재 AdHelper의 app id와 ad unit id는 Google 테스트 ID이며, 출시 전 실제 단위 ID로 교체한다.

### 광고 유닛 분리

- 홈 하단 배너
- 알람 해제 또는 세션 종료 후 전면 광고
- 보상형 광고 클래스는 있으나 보상 흐름 연결 전 스토어 노출 금지

### 미디에이션

- AppLovin
- Pangle
- Unity

### 테스트

- 테스트 중에는 Google test ad unit을 사용한다.
- 릴리스 전 실제 ad unit id와 AdHelper 값을 대조한다.
- Premium 상태에서 배너/전면/보상형 광고가 표시되지 않는지 확인한다.

---

## 코드 반영 체크리스트

- [ ] PurchaseConstants 상품 ID와 Play Console 상품 ID가 일치
- [ ] 어떤 상품을 사도 동일한 Premium 상태가 활성화
- [ ] PurchaseService 구매/복원/취소/오류 흐름 확인
- [ ] Premium 상태에서 광고 위젯과 전면 광고 매니저가 모두 차단
- [ ] 미구현 광고/보상 흐름을 스토어 기능으로 노출하지 않음
- [ ] 테스트 AdMob ID를 실제 단위 ID로 교체

## 출시 전 게이트

- Play Console 상품 ID와 코드 상수가 일치한다.
- 라이선스 테스터로 구매와 복원이 모두 성공한다.
- 무료 사용자의 핵심 기능은 막히지 않는다.
- Premium 설명에 보안/감지/실제 통신 보장 표현이 없다.
- Data safety와 개인정보 처리방침에 광고 SDK, 결제 SDK 사용이 반영되어 있다.
