## Google Play Console 인앱 상품 설정 (Motion Alarm Pocket - 무료 + 3단 후원형 프리미엄)

> 기준일: 2026-06-01
> 현재 구현(`lib/app/admob/` + `lib/app/services/purchase_service.dart`) 기준의 출시 준비 가이드입니다. 전면 광고는 세션 종료/알람 해제 같은 자연스러운 흐름 전환 지점에서만 노출하고, 경보가 울리는 도중에는 호출하지 않습니다.

### 앱 수익 모델

- **기본: 무료**: 핵심 기능을 무료로 제공합니다.
  - 가속도계 기반 모션 감지 알람
  - 딜레이(3-15초) 및 감도(Low / Medium / High) 설정
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
  - 스토어 상세 설명과 스크린샷에는 실제 구현된 기능만 노출

### 프리미엄 상품

| 옵션 | Android ID | 권장 가격 | 설명 |
| --- | --- | --- | --- |
| Small | `motion_alarm_pocket_premium_small` | $0.99 | 작은 후원, 광고 제거 |
| Medium | `motion_alarm_pocket_premium_medium` | $2.99 | 인기 옵션, 광고 제거와 추가 후원 |
| Large | `motion_alarm_pocket_premium_large` | $4.99 | 광고 제거와 든든한 후원 |

### Google Play Console 상품 등록

1. Google Play Console → 앱 → 수익 창출 → 제품 → 인앱 상품
2. "일회성 상품 만들기" 선택 (Non-consumable)
3. 아래 3개 상품을 등록한 뒤 활성화

| 상품 | 상품 ID | 태그 | 구매 옵션 ID | 권장 가격 | 상태 |
| --- | --- | --- | --- | --- | --- |
| Small Premium | `motion_alarm_pocket_premium_small` | `premium` | `motion-alarm-pocket-premium-small` | $0.99 | 활성화 |
| Medium Premium | `motion_alarm_pocket_premium_medium` | `premium` | `motion-alarm-pocket-premium-medium` | $2.99 | 활성화 |
| Large Premium | `motion_alarm_pocket_premium_large` | `premium` | `motion-alarm-pocket-premium-large` | $4.99 | 활성화 |

---

## 상품명/설명 다국어 메타데이터

Play Console 인앱 상품의 이름과 설명에 입력할 localizable copy다. 모든 언어에서 "일회성 구매", "광고 제거", "옵션별 기능 차등 없음"을 일관되게 유지한다.

### Small Premium

| Locale | 이름 | 설명 |
| --- | --- | --- |
| `en` | Coffee Tip | Remove ads and support Motion Alarm Pocket |
| `ko` | 커피 한 잔 | 광고 제거와 작은 후원 |
| `ja` | コーヒー応援 | 広告を削除して Motion Alarm Pocket を応援 |
| `de` | Kaffee-Tipp | Werbung entfernen und Motion Alarm Pocket unterstützen |
| `ru` | Кофе | Уберите рекламу и поддержите Motion Alarm Pocket |
| `fr` | Café | Supprimez les pubs et soutenez Motion Alarm Pocket |
| `es` | Café | Quita anuncios y apoya Motion Alarm Pocket |
| `pt` | Café | Remova anúncios e apoie o Motion Alarm Pocket |
| `id` | Tip Kopi | Hapus iklan dan dukung Motion Alarm Pocket |
| `zh` | 咖啡支持 | 移除广告并支持 Motion Alarm Pocket |
| `ar` | قهوة | أزل الإعلانات وادعم Motion Alarm Pocket |

### Medium Premium

| Locale | 이름 | 설명 |
| --- | --- | --- |
| `en` | Lunch Treat | Remove ads and add extra support |
| `ko` | 점심 한 끼 | 광고 제거와 추가 후원 |
| `ja` | ランチ応援 | 広告を削除して追加で応援 |
| `de` | Mittagessen | Werbung entfernen und zusätzlich unterstützen |
| `ru` | Обед | Уберите рекламу и добавьте поддержку |
| `fr` | Déjeuner | Supprimez les pubs et ajoutez un soutien |
| `es` | Almuerzo | Quita anuncios y añade apoyo extra |
| `pt` | Almoço | Remova anúncios e ofereça apoio extra |
| `id` | Traktir Makan Siang | Hapus iklan dan beri dukungan ekstra |
| `zh` | 午餐支持 | 移除广告并提供更多支持 |
| `ar` | غداء | أزل الإعلانات وقدّم دعمًا إضافيًا |

### Large Premium

| Locale | 이름 | 설명 |
| --- | --- | --- |
| `en` | Full Support | Remove ads and fully support development |
| `ko` | 풀 서포트 | 광고 제거와 든든한 개발 후원 |
| `ja` | フルサポート | 広告を削除して開発をしっかり応援 |
| `de` | Volle Unterstützung | Werbung entfernen und die Entwicklung stark unterstützen |
| `ru` | Полная поддержка | Уберите рекламу и поддержите разработку |
| `fr` | Soutien complet | Supprimez les pubs et soutenez pleinement le développement |
| `es` | Apoyo completo | Quita anuncios y apoya plenamente el desarrollo |
| `pt` | Apoio completo | Remova anúncios e apoie totalmente o desenvolvimento |
| `id` | Dukungan Penuh | Hapus iklan dan dukung pengembangan sepenuhnya |
| `zh` | 全力支持 | 移除广告并全力支持开发 |
| `ar` | دعم كامل | أزل الإعلانات وادعم التطوير بالكامل |

---

## 프리미엄 화면/스토어 문구 다국어 기준

| Locale | Premium CTA | One-time note | Benefit summary |
| --- | --- | --- | --- |
| `en` | Get Premium | One-time purchase · No subscription | No ads, lifetime access, support development |
| `ko` | 프리미엄 구매 | 일회성 구매 · 구독 없음 | 광고 없음, 평생 이용, 개발자 후원 |
| `ja` | プレミアムを購入 | 買い切り · サブスクなし | 広告なし、永久利用、開発支援 |
| `de` | Premium kaufen | Einmaliger Kauf · Kein Abo | Keine Werbung, lebenslang, Entwicklung unterstützen |
| `ru` | Купить Премиум | Разовая покупка · Без подписки | Без рекламы, навсегда, поддержка автора |
| `fr` | Obtenir Premium | Achat unique · Sans abonnement | Sans pubs, accès à vie, soutien du dev |
| `es` | Obtener Premium | Compra única · Sin suscripción | Sin anuncios, de por vida, apoyo al dev |
| `pt` | Obter Premium | Compra única · Sem assinatura | Sem anúncios, vitalício, apoio ao dev |
| `id` | Dapatkan Premium | Pembelian satu kali · Tanpa langganan | Tanpa iklan, seumur hidup, dukung dev |
| `zh` | 获取高级版 | 一次性购买 · 无订阅 | 无广告、终身使用、支持开发 |
| `ar` | احصل على بريميوم | شراء لمرة واحدة · بلا اشتراك | بلا إعلانات، مدى الحياة، دعم المطور |

### PurchaseConstants (`lib/app/services/purchase_service.dart`)

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

| 광고 유형 | 적용 여부 | 구현 클래스 / 위치 |
| --- | --- | --- |
| 배너 | 적용 | `HomePage` bottomNavigationBar → `BannerAdWidget` — 프리미엄 미노출 |
| 전면 광고 | 제한 적용 | `InterstitialAdManager.showAfterNaturalBreak()` — 알람 해제/세션 종료 후 3회마다 1회, 프리미엄 미노출 |
| 보상형 광고 | 구현 대기 | `RewardedAdManager` — 실제 보상 흐름 연결 전에는 스토어 기능으로 노출 금지 |

### 미디에이션 네트워크

| 네트워크 | 패키지 |
| --- | --- |
| AppLovin | `gma_mediation_applovin` |
| Unity | `gma_mediation_unity` |
| Pangle | `gma_mediation_pangle` |

### UI 노출 정책

- 프리미엄 페이지에 3개 옵션을 카드 형태로 동시 노출
- Medium 옵션에는 "Popular" 뱃지 표시, Medium이 기본 선택
- 사용자가 카드를 선택한 뒤 하단 고정 CTA에서 결제 진입
- 한 번 구매하면 옵션과 무관하게 모든 광고 제거 혜택이 동일하게 활성화됨
- 프리미엄은 구독이 아니라 일회성 구매임을 화면과 스토어 문구에서 일관되게 표시
- 모션 감지 정확도 보장을 프리미엄 혜택처럼 표현하지 않음
