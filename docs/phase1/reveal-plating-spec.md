# Plating & Food-Reveal Spec — Phase 1 (구현 수준)

> 3대 폴리시 중 ②음식 완성 reveal · ③플레이팅(`production-priorities §2·§3`). 리듬 스펙(`rhythm-prototype-spec`)과 같은 구현 깊이. 다음 sprint M3에서 즉시 구현 가능.
> 라운드 흐름: **손질 → 조리 → 양념 → [플레이팅] → [음식 reveal] → 결과/만족**. 플레이팅과 reveal은 끊김 없이 한 흐름.
> 단위 ms·px(기준 1080×1920 세로). 좌표 Godot 2D. 정체성: 숫자 비노출(등급·표정·매칭 배지만).

---

## A. 플레이팅 페이즈 (그릇 + garnish, 5초)

### A1. 타임라인
| t(ms) | 이벤트 |
|---|---|
| 0 | 조리 완료 → 0.5s 트랜지션(조리 화면 dim, 완성 음식 베이스가 중앙으로 모임) |
| 500 | 플레이팅 UI 등장(그릇 캐러셀 하단 슬라이드인 220ms) + 5.0s 카운트다운 링 시작 |
| ~ | 유저: 그릇 좌우 스와이프 선택 → (선택) garnish 1슬롯 탭 |
| 선택 즉시 | 그릇 떠오름 + chime, garnish 톡 안착 |
| confirm or timeout(5s) | 음식이 그릇으로 담기 애니(아래 A4) → 매칭 판정 → **음식 reveal(B)로 연결** |
> 미선택 timeout = 마지막 사용 그릇 자동(디폴트). 빠른 결정 유도하되 처벌 약함.

### A2. 그릇 캐러셀 UX
- 보유 그릇 가로 캐러셀(중앙 1개 확대, 좌우 0.8 scale·alpha 0.6 프리뷰). 스와이프/드래그로 회전(snap, 180ms ease_out).
- 중앙 그릇 = 선택 후보. 탭 또는 confirm 버튼으로 확정.
- **선택 피드백**: 확정 시 그릇 y −24px 떠오름(220ms back) + soft chime(놋/유리 톤) + 옅은 금테 1프레임.
- 권장 그릇(menu.recommended_dishware)엔 작은 ✦ 힌트(과하지 않게; 정답 노출 X, "어울림" 암시).

### A3. garnish 슬롯 (Phase 1 = 1슬롯)
- 메뉴별 garnish 후보 1~3 중 1택(예: 송송 파 / 깨 / 고추). 탭 즉시 음식 위 해당 위치에 "톡" 안착(scale 0→1, 140ms back) + 미세 SFX + 마이크로 햅틱(10ms).
- garnish는 소량 점수 보정(미각 보조) 또는 순수 연출(디폴트=연출+미세 보정 ±0.02). 다인용 다슬롯은 Phase 2.

### A4. 음식 담기 애니메이션
- 완성 베이스가 위(또는 조리도구)에서 **부드럽게 떨어져 그릇에 안착**: y translate(−120→0, 320ms, ease_out_cubic) + 안착 순간 살짝 squash(scale 1.0→1.06→1.0, 120ms) + "스윽 차르륵" SFX + 그릇 미세 흔들림(1px, 80ms).
- 국물류는 찰랑(셰이더/스프라이트 2프레임), 부침류는 안착 후 윤기 flash.

### A5. 매칭 보너스 visual reward
| 매칭 | 비주얼 | SFX | 점수 |
|---|---|---|---|
| 권장 그릇 | 그릇 주변 금빛 번짐(radial, 0→1→0, 400ms) + **"+15% Match!" 배지**(scale 0.7→1.1→1.0 back, y −30, alpha out 700ms) | 상승 화음(3음 아르페지오) | dishwareBonus + (scoring §11) |
| 중립 | 안착만, 배지 없음 | 안착음만 | 0 |
| 미스매치 | 옅은 회색 1프레임 + 부드러운 1단 낮은 음 | low note | − (scoring §11) |
> "+15%"는 매칭 보너스 표기(만족도 숫자 아님). 미식가 레벨은 +25%까지(`scoring §11`).

### A6. 결과 연결
플레이팅 확정 후 **1.0s 카메라 정지**(담긴 그릇 hold) → 그대로 **음식 reveal(B)** 로 전환. 두 연출이 컷 없이 흐름(같은 카메라).

---

## B. 음식 완성 reveal (1.5~2.5초, SNS·광고 소스)

### B1. 타임라인 (총 ~2.0s, 등급별 ±)
| t(ms) | 이벤트 |
|---|---|
| 0 | 플레이팅된 그릇이 화면 중앙, 배경 살짝 dim(비네트 +10%) |
| 0~600 | **카메라 줌인**(scale 1.0→1.12) + 미세 기울기(rotation 0→−2°) ease_out_cubic |
| 250 | 황금 **림라이트 글로우** 음식 윤곽 따라 sweep(0→1, 350ms) |
| 300~ | 입자 모션 시작(메뉴별, B3) — 김/윤기/기름 |
| 600 | **한 박자 멈춤("타다~")** 150ms 정지(scale·rotation hold) |
| 650 | **완성 sting**(등급별 B4) + 빛 번짐 pop(radial flash 0→1→0, 300ms) |
| 750~ | 등급 연출(잘함/명품 시 추가 sparkle·금가루) |
| ~2000 | 결과 카드(만족 표정·자연어·별)로 전환(카메라 줌아웃 200ms) |
> 등급 낮으면 sting·sparkle 약하게(보통), 높을수록 글로우·입자·sparkle 강화.

### B2. 카메라·연출 (공통)
- **줌인 + 기울기**: Camera2D zoom 1.0→1.12, 미세 rotation −2°(영화적). 한 박자 멈춤 후 결과로 줌아웃.
- **글로우**: 음식 위 황금톤(H45) 림라이트 sweep. **특산품 재료·Pro 도구 사용 시 글로우 강도 ×1.3**(고급 사용 보상감).
- **비네트**: 주변 10% dim으로 음식 집중.
- 셰이크 없음(reveal은 정적 "감상" 순간).

### B3. 메뉴 12 reveal 입자·모션 (개별 디자인)
> 각 메뉴 reveal_profile(`data-schema-phase1` FoodDefinition.reveal_profile). 김(steam)은 VFX 레이어(그림 아님).
| 메뉴 | 입자/모션 프로파일 | 포인트 |
|---|---|---|
| 라면 | broth_steam + noodle_gloss | 면 윤기 흐름 + 모락 김 2~3가닥 |
| 김밥 | sheen_sweep(단면) | 단면 색대비 강조 sweep, 김 광택 |
| 떡볶이 | sauce_gloss_bubble | 빨간 소스 윤기 + 작은 보글 |
| 잔치국수 | clear_steam + light_gloss | 맑은 김 + 면 윤기(은은) |
| 김치찌개 | stew_steam + bubble_shake | 보글 김 + 옹기 미세 흔들림 |
| 비빔밥 | color_pop + dolsot_steam | 색채 팝(나물) + 돌솥 김·지글 |
| 된장찌개 | stew_steam(부드러운) | 구수한 김, 차분 |
| 잡채 | glass_noodle_gloss | 당면 반들 윤기 sweep |
| 불고기 | meat_glaze_gloss + sizzle | 윤기 글레이즈 + 지글 입자 |
| 해물파전 | oil_sheen_flash | 기름 광택 flash, 가장자리 바삭 |
| 매운탕 | stew_steam(강) + bubble | 얼큰 김 + 활발한 보글 |
| 순두부찌개 | stew_steam + soft_curd_jiggle | 김 + 순두부 몽글 흔들림 |

### B4. 완성 sting 3등급 (점수 연동)
| 등급 | 조건(만족 S) | sting | 추가 연출 |
|---|---|---|---|
| 보통 | 통과(θ~θ+0.05) | 놋종 1타 | 글로우 기본 |
| 잘함 | 우수(≥θ+0.05) | 놋종 + 화음 | sparkle 소량 |
| 명품 | 특산품 사용 + 우수 | 놋종 + 화음 + reverb glow | 금가루 흩날림 + 글로우 ×1.3 |
> 등급 = `scoring` 만족도 + 재료 티어. 완성 reveal sting과 결과 화면 표정/별이 한 흐름.

---

## C. Godot 구현 힌트
- **노드**: `PlatingPhase`(Control, 캐러셀·garnish·타이머), `FoodRevealCam`(Camera2D + Tween), `RevealVFX`(GPUParticles2D 풀, reveal_profile별 프리셋), `Dishware`(Sprite2D), `MatchBadge`(Label+Tween).
- **연결**: round_controller 흐름에 `await plating.finished` → `await reveal.finished` → result. 플레이팅 confirm 시그널 → 담기 애니 → 매칭 판정 → reveal 시작.
- **reveal_profile**: `FeedbackProfile`류 .tres로 메뉴별 입자 프리셋(emit 수·색·수명·중력) 매핑. `RevealVFX.play(profile, grade)`.
- **카메라**: `Tween`으로 zoom/rotation, 한 박자 멈춤 = `tween_interval(150)`.
- **풀링·60fps**: 입자 one-shot 풀, 배경 dim은 ColorRect alpha(셰이더 X). 결과 전환 시 VFX 정지.
- **사운드**: 안착·chime·sting을 `audio-pipeline`/`sound-guide §0.5` layering. sting 3등급 = AudioStream 3종 분기.

## D. 튜닝 다이얼 (DebugPanel 확장, rhythm §10과 공유)
| 파라미터 | 디폴트 | 범위 |
|---|---|---|
| plating_time | 5000ms | 3000~7000 |
| carousel_snap | 180ms | 100~300 |
| reveal_zoom | 1.12 | 1.0~1.3 |
| reveal_tilt | −2° | −6~0 |
| reveal_hold | 150ms | 0~400 |
| glow_intensity | 1.0 | 0~2.0 (특산품 ×1.3) |
| match_badge_scale | 1.1 | 1.0~1.4 |
| reveal_total | 2000ms | 1500~2500 |
> `user://tuning.cfg` 공유 저장.

## E. QA 체크리스트
- [ ] 플레이팅 → reveal → 결과가 **컷 없이** 매끄럽게 흐름(같은 카메라).
- [ ] 60fps 유지(reveal 입자 다발 포함).
- [ ] 매칭 3종(권장/중립/미스매치) 비주얼·SFX·점수 모두 차등 작동.
- [ ] 메뉴 12 각 reveal 프로파일 적용·구분 가능.
- [ ] sting 3등급 분기(보통/잘함/명품) 작동.
- [ ] **광고감 스크린샷**: reveal 정지 프레임이 SNS에 올릴 만한가(5명 중 4명 "예쁘다").
- [ ] 5초 플레이팅이 답답하지도 촉박하지도 않은가(타임 튜닝).

## F. 미결 (A/B)
| # | 항목 | A(디폴트) | B | 트레이드오프 |
|---|---|---|---|---|
| 1 | reveal 카메라 | **줌인+미세 기울기** | 정면 고정 줌만 | 기울기=영화적이나 일부 멀미 가능 → 각도 작게(−2°) |
| 2 | garnish | **1슬롯(연출+미세 보정)** | 순수 연출(점수 0) | 미세 보정=전략 한 스푼 / 순수 연출=단순 |
| 3 | 매칭 배지 문구 | **"+15% Match!"** | 별/아이콘만(숫자 X) | 숫자=명료하나 "숫자 비노출" 정체성과 약한 충돌 → 매칭 % 한정 허용 |
| 4 | plating 타임 | **5s** | 무제한(캐주얼) | 5s=긴장·snap / 무제한=스트레스↓·템포↓ |
> 디폴트 채택으로 M3 진행, 빌드 후 튜닝.

## ✅ Self-check
플레이팅 UX·담기 애니·매칭 reward·reveal 타임라인·메뉴 12 입자 프로파일·sting 3등급·카메라·Godot 노드·튜닝·QA가 구체값으로 고정 → **M3 폴리시 패스 즉시 구현 가능.** 3대 폴리시 스펙(리듬·reveal·플레이팅) 세트 완성.
