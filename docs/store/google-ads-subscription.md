## Google Play Console 인앱 상품 설정 (Motion Alarm Pocket - 무료 + 3단 후원형 프리미엄)

> 2026-05-30 현재 구현(`lib/app/admob/` + `services/purchase_service.dart`) 기준의 출시 준비 가이드입니다. 전면 광고는 세션 종료/알람 해제 같은 자연스러운 흐름 전환 지점에서만 노출하고, 경보가 울리는 도중에는 호출하지 않습니다.

### 앱 수익 모델
- **기본: 무료**: 핵심 기능을 무료로 제공합니다.
  - 가속도계 기반 모션 감지 알람
  - 딜레이(3–15초) 및 감도(Low / Medium / High) 설정
  - 사이렌 + 진동 경보
  - 로컬 감지 히스토리 최대 50건 보관
- **광고 포함**: 무료 버전에는 광고가 표시됩니다.
  - 홈 화면 하단 배너 (`BannerAdWidget` — 프리미엄 사용자 미노출)
  - 세션 종료 또는 알람 해제 후 전면 광고 (`InterstitialAdManager.showAfterNaturalBreak()` — 3회마다 1회)
  - 보상형 광고 (`RewardedAdManager`) — 현재 UI 연결 전, 스토어 기능으로 노출 금지
  - 광고 단위 ID와 빈도 정책은 `lib/app/admob/ads_helper.dart`에서 통합 제어
- **핵심 흐름 광고 제한**:
  - 경보가 활성화된 상태(알람 울리는 도중)에는 광고를 호출하지 않습니다.
  - 알람 해제(`stopAlarm`) 시에만 광고 카운터가 증가합니다.
  - 프리미엄 사용자는 배너·전면·보상형 광고를 모두 보지 않습니다 (`_shouldShowAd()`로 분기).
- **프리미엄 구매(3단 후원)**: 일회성 관리형 상품(Non-Consumable) 3개를 제공합니다.
  - Small / Medium / Large 중 어떤 옵션을 구매해도 동일한 혜택 제공
  - 모든 광고 제거
  - `PurchaseService.to.isPremium.value`로 광고/UI 분기

### 프리미엄 상품

| 옵션   | Android ID                                   | 권장 가격 | 설명                           |
| ------ | -------------------------------------------- | --------- | ------------------------------ |
| Small  | `motion_alarm_pocket_premium_small`          | $0.99     | 작은 후원, 광고 제거           |
| Medium | `motion_alarm_pocket_premium_medium`         | $2.99     | 인기 옵션, 광고 제거와 추가 후원 |
| Large  | `motion_alarm_pocket_premium_large`          | $4.99     | 광고 제거와 든든한 후원        |

### 구글 플레이 콘솔 상품 등록

1. 구글 플레이 콘솔 → 앱 → 수익 창출 → 제품 → 인앱 상품
2. "일회성 상품 만들기" 선택 (Non-consumable)
3. 아래 3개 상품을 등록한 뒤 활성화

**상품 1: Small Premium (커피 한 잔)**
- 상품 ID: `motion_alarm_pocket_premium_small`
- 태그: `premium`
- 이름 (영어): `A cup of coffee`
- 설명 (한국어): 광고 제거와 커피 한 잔 후원
- 설명 (영어): `Remove ads and support Motion Alarm Pocket`
- 구매 옵션 ID: `motion-alarm-pocket-premium-small`
- 가격: 콘솔에서 국가별 최종 설정 (권장 $0.99)
- 상태: 활성화

**상품 2: Medium Premium (점심 한 끼)** - 인기/추천
- 상품 ID: `motion_alarm_pocket_premium_medium`
- 태그: `premium`
- 이름 (영어): `A lunch treat`
- 설명 (한국어): 광고 제거와 추가 후원
- 설명 (영어): `Remove ads and add extra support`
- 구매 옵션 ID: `motion-alarm-pocket-premium-medium`
- 가격: 콘솔에서 국가별 최종 설정 (권장 $2.99)
- 상태: 활성화

**상품 3: Large Premium (든든한 후원)**
- 상품 ID: `motion_alarm_pocket_premium_large`
- 태그: `premium`
- 이름 (영어): `Full support`
- 설명 (한국어): 광고 제거와 든든한 후원
- 설명 (영어): `Remove ads and fully support development`
- 구매 옵션 ID: `motion-alarm-pocket-premium-large`
- 가격: 콘솔에서 국가별 최종 설정 (권장 $4.99)
- 상태: 활성화

### PurchaseConstants (lib/app/services/purchase_service.dart)
```dart
abstract final class PurchaseConstants {
  static const List<String> productIds = [
    'motion_alarm_pocket_premium_small',
    'motion_alarm_pocket_premium_medium',
    'motion_alarm_pocket_premium_large',
  ];
}
```

### 프리미엄 권한 정책
- Small / Medium / Large 중 어떤 상품이든 1개 구매가 확인되면 `isPremium = true`
- 앱 내부 권한은 단일 프리미엄 플래그로 통일 (옵션별 차등 없음)
- 구매 상태는 앱 시작 시 스토어 기준으로 자동 재검증 (`PurchaseService` silent reconciliation)
- 명시적 복원에서 entitlement가 없고 복원이 완료된 경우에만 premium 해제
- 복원 timeout 또는 스토어 응답 지연 시 cached premium은 보수적으로 유지
- 프리미엄 기능은 실제 구현된 기능만 스토어 상세 설명과 스크린샷에 노출

### 광고 정책 (현재 구현 기준)
| 광고 유형           | 적용 여부   | 구현 클래스 / 위치                                                                     |
| ------------------- | ----------- | -------------------------------------------------------------------------------------- |
| 배너                | 적용        | `HomePage` bottomNavigationBar → `BannerAdWidget` — 프리미엄 미노출                   |
| 전면 광고           | 제한 적용   | `InterstitialAdManager.showAfterNaturalBreak()` — 알람 해제/세션 종료 후 3회마다 1회, 프리미엄 미노출 |
| 보상형 광고         | 구현 대기   | `RewardedAdManager` — 실제 보상 흐름 연결 전에는 스토어 기능으로 노출 금지             |

### 미디에이션 네트워크
| 네트워크 | 패키지                   |
| -------- | ------------------------ |
| AppLovin | `gma_mediation_applovin` |
| Unity    | `gma_mediation_unity`    |
| Pangle   | `gma_mediation_pangle`   |

### 가격 정책
| 상품           | 권장 가격 | 설명                           |
| -------------- | --------- | ------------------------------ |
| Small Premium  | $0.99     | 광고 제거 (커피 한 잔)         |
| Medium Premium | $2.99     | 광고 제거와 추가 후원 - 인기   |
| Large Premium  | $4.99     | 광고 제거와 든든한 후원        |

### UI 노출 정책
- 프리미엄 페이지에 3개 옵션을 카드 형태로 동시 노출
- Medium 옵션에는 "Popular" 뱃지 표시, Medium이 기본 선택
- 사용자가 카드를 선택한 뒤 하단 고정 CTA에서 결제 진입
- 한 번 구매하면 옵션과 무관하게 모든 광고 제거 혜택이 동일하게 활성화됨
- 프리미엄은 구독이 아니라 일회성 구매임을 화면과 스토어 문구에서 일관되게 표시
- 모션 감지 정확도 보장을 프리미엄 혜택처럼 표현하지 않음 (하드웨어 한계 면책)
