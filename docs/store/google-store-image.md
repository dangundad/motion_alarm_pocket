# Google Play 스크린샷 가이드

## 스크린샷 개요

- **목표**: Motion Alarm Pocket이 "폰을 주머니나 가방에 두면 움직임을 감지해 경보를 울리는 간단한 도구"라는 점을 첫 이미지에서 이해시키기
- **핵심 메시지**: 움직임 감지 알람 / 딜레이·감도 설정 / 사이렌+진동 경보 / 감지 기록 / 기기 내 처리(on-device)
- **지원 언어**: `en`, `ko`, `ja`, `de`, `ru`, `fr`, `es`, `pt`, `id`, `zh`, `ar`
- **톤**: 미니멀, 클린, 차분한 실용 도구. 앱 테마(Red M3) 액센트를 살린 라이트/다크 일관 톤
- **주의**: 전문 보안 장비, 도난 방지 보장, 100% 감지, 원격 알림, 위치 추적, 카메라 감시를 암시하지 않음. 엔터테인먼트·일상 유틸리티 톤을 유지

---

## 스크린샷 구성 (5장)

### 1장: 대표 이미지 - 한눈에 보는 알람

**캡처 화면**
- 홈(`HomePage`)의 상태 원형 인디케이터(Ready/idle 상태)와 Start 버튼이 보이는 상태.
- 앱 정체성(움직임 알람)이 드러나도록 상태 원형 + 메인 액션 버튼을 중심으로 촬영한다.
- 하단 배너 광고가 보이지 않도록 프리미엄/광고 미로드 상태에서 촬영하거나 배너 영역을 제외한다.

| Locale | Title | Subtitle |
| --- | --- | --- |
| `en` | Motion Alarm | Place it, it watches |
| `ko` | 움직임 알람 | 두면 감지, 움직이면 경보 |
| `ja` | 動きアラーム | 置くだけで見守り |
| `de` | Bewegungsalarm | Hinlegen, überwachen |
| `ru` | Сигнал движения | Положите, он следит |
| `fr` | Alarme mouvement | Posez, il surveille |
| `es` | Alarma de movimiento | Déjalo, vigila |
| `pt` | Alarme de movimento | Coloque, ele vigia |
| `id` | Alarm Gerak | Letakkan, ia menjaga |
| `zh` | 移动警报 | 放下即可监测 |
| `ar` | منبه الحركة | ضعه، فيراقب |

### 2장: 설정 - 딜레이와 감도

**캡처 화면**
- 홈의 설정 카드(`_SettingsCard`) — 딜레이 슬라이더 + 감도 `SegmentedButton`(낮음/중간/높음)이 보이는 상태.
- 세션 비활성(설정 가능) 상태로 촬영한다.

| Locale | Title | Subtitle |
| --- | --- | --- |
| `en` | Delay & Sensitivity | Adjust to fit your situation |
| `ko` | 딜레이·감도 | 상황에 맞춰 조절 |
| `ja` | 遅延と感度 | 状況に合わせて調整 |
| `de` | Verzögerung & Gefühl | An deine Situation anpassen |
| `ru` | Задержка и чувствительность | Настройте под ситуацию |
| `fr` | Délai & sensibilité | Adaptez à la situation |
| `es` | Retraso y sensibilidad | Ajusta a tu situación |
| `pt` | Atraso e sensibilidade | Ajuste ao seu uso |
| `id` | Jeda & Sensitivitas | Sesuaikan dengan kondisi |
| `zh` | 延迟与灵敏度 | 按场景调整 |
| `ar` | التأخير والحساسية | اضبطها حسب الموقف |

### 3장: 감시 중 - 움직임을 지켜보는 상태

**캡처 화면**
- 홈의 상태 원형이 armed 상태(원형 progress + 보호 아이콘)인 화면.
- 상태 텍스트("감시 중 - 움직임을 감지합니다")와 변화량(delta) 표시가 함께 보이는 상태.

| Locale | Title | Subtitle |
| --- | --- | --- |
| `en` | Armed | Watching for motion |
| `ko` | 감시 중 | 움직임을 지켜봅니다 |
| `ja` | 監視中 | 動きを見守ります |
| `de` | Scharf | Überwacht Bewegung |
| `ru` | Охрана включена | Следит за движением |
| `fr` | Armé | Surveille les mouvements |
| `es` | Activada | Vigilando movimiento |
| `pt` | Armado | Monitorando movimento |
| `id` | Aktif | Memantau gerakan |
| `zh` | 已布防 | 正在监测移动 |
| `ar` | مفعّل | يراقب الحركة |

### 4장: 경보와 기록

**캡처 화면**
- 알람 발생 상태(`alarm_active`, 빨강 원형 + "경보 중지" 버튼) 또는 감지 기록 리스트(`_HistoryTile`) 화면.
- 기록 컷은 1~5개 항목이 시각/날짜와 함께 채워진 상태에서 촬영한다.

| Locale | Title | Subtitle |
| --- | --- | --- |
| `en` | Motion Detected | Siren, vibration, local history |
| `ko` | 움직임 감지 | 사이렌·진동·로컬 기록 |
| `ja` | 動きを検知 | サイレン・振動・履歴 |
| `de` | Bewegung erkannt | Sirene, Vibration, Verlauf |
| `ru` | Движение обнаружено | Сирена, вибрация, история |
| `fr` | Mouvement détecté | Sirène, vibration, historique |
| `es` | Movimiento detectado | Sirena, vibración, historial |
| `pt` | Movimento detectado | Sirene, vibração, histórico |
| `id` | Gerakan Terdeteksi | Sirene, getaran, riwayat |
| `zh` | 检测到移动 | 警笛、振动、本地历史 |
| `ar` | تم اكتشاف حركة | صفارة، اهتزاز، سجل محلي |

### 5장: Premium - 광고 제거 후원

**캡처 화면**
- Premium 화면(`PremiumPage`).
- Small / Medium / Large 3단 일회성 후원 옵션, 광고 제거 혜택, 하단 구매 버튼이 보이는 상태.
- 구독처럼 보이는 문구를 쓰지 않는다. 모든 옵션은 동일하게 광고를 제거한다.

| Locale | Title | Subtitle |
| --- | --- | --- |
| `en` | Premium Support | One-time, ad-free |
| `ko` | 프리미엄 후원 | 일회성 후원, 광고 제거 |
| `ja` | プレミアム応援 | 買い切りで広告なし |
| `de` | Premium-Support | Einmalig, werbefrei |
| `ru` | Поддержка Премиум | Разово, без рекламы |
| `fr` | Soutien Premium | Achat unique, sans pubs |
| `es` | Apoyo Premium | Pago único, sin anuncios |
| `pt` | Apoio Premium | Compra única, sem anúncios |
| `id` | Dukungan Premium | Sekali bayar, tanpa iklan |
| `zh` | 高级版支持 | 一次购买，无广告 |
| `ar` | دعم بريميوم | مرة واحدة، بلا إعلانات |

### 선택 컷

- **온보딩**: `OnboardingPage` 첫 스텝 — 알람 아이콘 + "주머니 속 움직임 알람" 가치 소개. 첫인상 강조용.
- **사용 방법 카드**: 홈의 `_HowToUseCard` — 3단계 사용 안내. 사용 흐름 설명용.

---

## 구글 스토어 검색어 추천

| Locale | Primary | Secondary | Long-tail |
| --- | --- | --- | --- |
| `en` | motion alarm, pocket alarm, phone alarm | bag alarm, movement detector, anti theft alarm | motion alarm for phone, pocket motion detector |
| `ko` | 모션 알람, 움직임 감지 알람, 주머니 알람 | 가방 알람, 폰 알람, 움직임 감지 | 폰 움직임 알람, 가방 움직임 경보 |
| `ja` | 動きアラーム, モーションアラーム, スマホ警報 | バッグ警報, 振動アラーム, 盗難防止アラーム | スマホ動き検知, バッグの動きアラーム |
| `de` | Bewegungsalarm, Handy Alarm, Taschenalarm | Bewegungssensor, Handy sichern, Alarm App | Bewegungsalarm fürs Handy, Taschen Bewegungsmelder |
| `ru` | сигнал движения, сигнал телефона, карманная сигнализация | датчик движения, сигнал сумки, защита телефона | сигнал движения телефона, сигнал для сумки |
| `fr` | alarme mouvement, alarme téléphone, alarme poche | détecteur mouvement, alarme sac, anti vol téléphone | alarme mouvement téléphone, alarme sac poche |
| `es` | alarma movimiento, alarma móvil, alarma bolsillo | detector movimiento, alarma bolso, antirrobo móvil | alarma movimiento para móvil, detector bolsillo |
| `pt` | alarme movimento, alarme celular, alarme bolso | detector movimento, alarme mochila, anti furto celular | alarme de movimento para celular, detector no bolso |
| `id` | alarm gerak, alarm ponsel, alarm saku | detektor gerak, alarm tas, anti maling ponsel | alarm gerak ponsel, alarm tas bergerak |
| `zh` | 移动警报, 手机警报, 口袋警报 | 移动检测, 包包警报, 防盗警报 | 手机移动警报, 包内移动检测 |
| `ar` | منبه حركة, منبه الهاتف, منبه الجيب | كاشف حركة, منبه الحقيبة, تنبيه الهاتف | منبه حركة للهاتف, كاشف حركة الحقيبة |

### 사용 팁

- 제목에는 각 언어의 `motion`, `alarm`, `pocket`에 해당하는 핵심어를 우선 배치한다.
- 설명 첫 문단에 움직임 감지, 사이렌, 진동, on-device, sensitivity 계열 표현을 자연스럽게 포함한다.
- `100% accurate`, `guaranteed`, 도난 방지 보장 표현, 미보유 기능(원격 알림, 위치 추적, 카메라 감시) 검색어는 사용하지 않는다.

---

## 캡처 팁

- 해상도: 세로 1080x1920 이상 권장
- 형식: PNG 권장
- 디바이스: 실제 Android 기기 캡처 권장
- Android edge-to-edge 상태에서 상단/하단 여백이 깨지지 않는지 확인
- 광고가 보이는 컷은 피한다. 프리미엄 컷은 구매 전 화면만 사용한다
- 스토어 이미지에 들어가는 큰 문구는 2줄 이내로 유지한다
- 디버그 표시, 테스트 문구, 실제 개인 메모가 노출되지 않게 확인한다
- 밝은 테마와 좁은 모바일 폭에서 텍스트 겹침이 없는지 확인한다

## 강조할 요소

- 상태 원형 인디케이터의 idle / arming / armed / alarm 색상 계층
- 딜레이 슬라이더와 감도 `SegmentedButton`
- 사이렌+진동 경보와 "경보 중지" 액션
- 최근 감지 기록(시각 포함)
- 움직임 감지가 기기 안에서만 처리된다는 점

## 체크리스트

- [ ] 실제 앱 화면만 사용
- [ ] 과장된 보안·감지 보장 문구 제외
- [ ] 광고 지점은 사용 흐름이 끝난 화면 기준으로만 표현
- [ ] 11개 언어 오버레이 텍스트가 2줄 이내로 들어가는지 확인
- [ ] `ar` 스크린샷은 RTL 방향과 정렬을 별도 확인
