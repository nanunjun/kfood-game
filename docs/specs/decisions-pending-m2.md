# Pending Decisions — M2 착수 전 미결 확인 12건

> 버전: **v0.1** · 작성일: 2026-05-31 · 작성자: pm
> 목적: M2(게임플레이 코드) sprint 착수 전, 누적된 사용자 확인 대기 항목 12건을 한 곳에 모아 의사결정을 쉽게 한다.
> 출처: [`ui/scene-2-kitchen-layout.md` §6](../ui/scene-2-kitchen-layout.md) 8건 + 2026-05-31 design sprint CHANGELOG confirm 4건
> 권고 작성: game-designer(메커닉/밸런스 9건) + ui-designer(UI/비주얼 3건), pm 통합

> **🔔 2026-05-31 사용자 결정 반영 완료**:
> - **B1 승인** → foods CSV에 `correct_method_id` + `method_options` 컬럼 신설 + 12음식 lock (적용 완료).
> - **B2 승인 (확장)** → 콘도그 `CUT-00`→`DIP-00`, **불고기 `CUT-00`→`MAR-00`** 토큰 분리. `CUT-00`은 실제 칼질(도마) 전용으로 정리 (적용 완료). *불고기도 자체 토큰을 갖도록 원안보다 확장.*
> - **C3 승인** → CH-01 chibi **default OFF** 확정.
> - 나머지 9건(A1~A6, C1, C2)은 권고대로 "현행 확정/placeholder unblock" — M2 비차단, 별도 액션 불요.

---

## 0. TL;DR — 빠른 결정 체크리스트

대부분 항목은 **현재 가이드를 그대로 확정(confirm)** 하면 되고, 실제로 M2 착수를 막는 건 **단 1건**입니다.

| # | 항목 | 권고 | 결정자 | M2 영향 |
|---|------|------|--------|---------|
| **B1 (구 #3)** | Stage 2B 조리법 카드 후보(`method_options`) 데이터 부재 | ✅ **승인·적용 완료** (컬럼+12행 lock) | game-designer | 🔴→✅ 해소 |
| **B2 (구 D3)** | 콘도그 dip + 불고기 marinade `CUT-00` 토큰 충돌 | ✅ **승인·적용 완료** (콘도그 `DIP-00` / 불고기 `MAR-00`) | game-designer | 🟡→✅ 해소 |
| **B3 (구 #7)** | Scene 2→3 서빙 transition 타이밍 | **0.5s overlap 확정 + "빠른"=instant** | godot-dev sync | 🟡 soft (transition 작성 직전) |
| C1 (구 #2) | 양념재우기 손 sprite | art 미니 sprint($0.04), 미납 시 칼 fallback | art-director/pm | 🟢 W3 전 |
| C2 (구 #6) | Kitchen rack 옹기 5종 sprite | placeholder로 진행, Post-M1 swap | art-director | 🟢 unblocked |
| C3 (구 #1) | CH-01 주인공 chibi 표시 | ✅ **default OFF 확정** (토글로 alpha 후 ON) | pm | 🟢 결정됨 |
| A1 (구 #4) | Stage 2C `cook_time_sec` | **이미 lock 완료** — cross-ref 문구만 정정 | — | 🟢 해소됨 |
| A2 (구 #5) | Stage 2A miss tap 처리 | 현행 유지(progress 진행, accuracy만 감소) | game-designer | 🟢 alpha 후 |
| A3 (구 #8) | Stage 2B 오답 자동 배치 | 현행 유지 + 정답 0.3s highlight 추가 | pm | 🟢 alpha 후 |
| A4 (구 D1) | 잔치국수 hero 재료 | 대파 송송 110·4 유지 | 사용자 취향 | 🟢 swap 언제든 |
| A5 (구 D2) | 불고기 multi-cut | 양념재우기 단독 유지 | game-designer | 🟢 alpha 후 |
| A6 (구 D4) | Stage 2C 보조 rhythm | MVP 단일 탭 유지 | game-designer | 🟢 alpha 후 |

**사용자가 지금 결정할 것은 사실상 3개뿐**: B1(컬럼 신설 승인), B2(dip 토큰 분리 승인), C3(CH-01 기본값 OFF 동의). 나머지 9건은 "현행 확정"에 동의만 하면 닫힙니다.

---

## 1. 🔴 진성 M2 Blocker — 착수 전 반드시 닫기

### B1 (구 #3) — Stage 2B 조리법 카드 후보 데이터 부재
- **맥락**: `scene-2-kitchen-layout.md` §2.2는 카드 구성을 foods CSV `method_options` 컬럼에서 읽는다고 전제. **실제 확인 결과 그 컬럼이 없다.** 현재 foods CSV에는 `primary_cooking_method`(정답)와 `secondary_method`(잡채·불고기 2개만 채워짐)만 존재. godot Resource 스키마(scene-2 §7.2)는 `method_options`/`correct_method_id`를 요구. 즉 W1 라면 end-to-end 구현 시 데이터가 없어 하드코딩에 의존하게 됨.
- **선택지**:
  - (A) tier 규칙 + 런타임 랜덤 distractor — CSV 변경 0, 그러나 음식과 무관한 오답(라면에 굽기)이 튀어 변별 품질 불안정.
  - (B) **`method_options` 컬럼 신설** (세미콜론 구분, 정답 포함 후보군) + 카드 수 T1=3/T2=4 유지.
- **권고: (B)**. 음식별로 오답 후보를 고정해야 "같은 음식 = 같은 후보군" 학습 보상이 작동(공간 기억 디자인 철학과 정합). 12음식 권고값(정답 굵게):
  - 라면 **boil**/stirfry/panfry · 떡볶이 **boil**/stirfry/grill · 김밥 **roll**/mix/boil · 김치볶음밥 **stirfry**/boil/panfry · 해물파전 **panfry**/deepfry/stirfry · 콘도그 **deepfry**/panfry/grill · 잔치국수 **boil**/stirfry/mix
  - 비빔밥 **mix**/boil/stirfry/grill · 잡채 **stirfry**/boil/mix/panfry · 갈비구이 **grill**/panfry/deepfry/boil · 순두부찌개 **boil**/stirfry/panfry/grill · 불고기 **stirfry**/grill/boil/panfry (marinate는 Stage 2A에서 소화)
- **영향**: `foods-database.csv`(컬럼+12행), `balance-config.md`(카드 수 규칙 명문화), `cooking-mechanics.md` §3.1 sync, godot `food.tres` 스키마.
- **결정 필요**: 컬럼 신설 + 위 12행 값 승인 여부 (이견 있으면 음식별 후보 조정).

---

## 2. 🟡 Soft Blocker — 해당 sprint 진입 전 닫기

### B2 (구 D3) — 콘도그 dip 메커닉 + CUT-00 토큰 충돌
- **맥락**: foods CSV t1_007 콘도그 = `prep_cut_style=CUT-00`, 80 BPM·3 taps, "칼 cut 대신 batter dip". motion-spec §3.10에 dip keyframe 이미 lock. 문제는 **불고기 양념재우기도 `CUT-00`을 써서** 런타임에 둘을 구분하려면 "부침가루면 dip, 아니면 marinade" 식 우회 분기가 필요.
- **권고**: 80·3 dip 메커닉 확정 + 콘도그는 `prep_cut_style`을 **`DIP-00`** 별도 토큰으로 분리(불고기 marinade와 혼동 방지). corndog_batter_bowl.png 미니 sprite 1건($0.04) 필요.
- **M2 영향**: godot dip 분기는 W5라 착수는 안 막음. 단 토큰 분리는 W5 전 정리 권고.
- **영향**: `foods-database.csv` t1_007 토큰, `motion-spec.md` §4·§5.1, art-director task 1건.

### B3 (구 #7) — Scene 2 → Scene 3 서빙 transition 타이밍
- **맥락**: §3.3·§4·screen-flow §4.3·§7 네 곳에서 이미 "총 1.5s, swap 0.5s overlap"으로 일관 명시. §6 #7만 "godot-dev sync (0.5s 제안)"으로 열려 있음.
- **권고**: **0.5s overlap을 SSOT로 확정** + screen-flow가 이미 약속한 "빠른 트랜지션" 모드에서는 instant(0.0~0.1s) swap. 추가 결정 불필요, 문구만 lock.
- **M2 영향**: `scene2_transition.gd`의 `transition_2c_to_scene3()` 작성 직전 sync. 값은 이미 박혀 있어 "0.5s 확인"으로 즉시 해소.
- **영향**: scene-2 §6 #7 문구, screen-flow §7 "빠른" 정의 정합.

---

## 3. 🟢 자산/플래그 — placeholder로 unblock (Post-M1 swap)

### C1 (구 #2) — 양념재우기 손 sprite
- 권고: art-director 미니 sprint로 `hand_marinade.png` 1건($0.04). motion-spec §3.3 keyframe 이미 lock이라 납품만 되면 즉시 binding. **W3(불고기) 전까지** 납품되면 충분, 미납 시 칼 motion fallback으로 W3도 진행 가능. → 칼 재사용은 "양념 마사지"를 써는 시각이라 의미 부조화, 비용 0인 sprite 생성 권고.

### C2 (구 #6) — Kitchen rack 옹기 5종 sprite
- 권고: CP-22는 interactive 아니고 동작(fade/dim/arc)이 sprite와 분리되어 **placeholder 5 sprite로 M2 전부 구현·검증 가능**. Post-M1 LOCK 시 `basic_pantry.tres` texture path만 swap. 단 양념재우기 arc 목적지인 **marinade bowl placeholder 1개를 함께** 둘 것(옹기만 있으면 도착점이 빔).

### C3 (구 #1) — CH-01 주인공 chibi 표시 default
- 맥락: CH-01은 interactive 아님(Z=40, 뒤에 깔림). Stage 2C는 burner glow·steam particle이 dominant하고 캐릭터와 우측 하단 공간 경합.
- **권고: default OFF**. 문서가 우려한 조건(VFX dominant + 뒤 layer + non-interactive)이 모두 OFF를 가리킴. 토글이므로 alpha 데이터 보고 ON 전환은 안전(반대 방향은 noise 컴플레인 후행). godot는 `CharacterArea`를 `visible=false` placeholder로 두고 진행.
- **결정 필요**: 기본값 OFF 동의 여부.

---

## 4. 🟢 현행 확정(confirm)만 하면 닫히는 항목 — alpha 이후 재검토

### A1 (구 #4) — Stage 2C cook_time_sec
- **이미 lock 완료.** foods CSV `cook_time_sec` 12/12 채워짐 + balance-config §3.2 perfect_width와 1:1 sync. 값(초): 라면9·떡볶이13·김밥4·김치볶음밥10·해물파전14·콘도그8·잔치국수12·비빔밥5·잡채16·갈비구이18·순두부찌개14·불고기16. → §6 #4의 "balance §7 후속" 문구가 cross-ref 오해. **데이터 변경 없음, §3.2 lock 완료로 문구만 정정.**

### A2 (구 #5) — Stage 2A miss tap 처리
- 현행: miss여도 progress 진행, 마지막 tap 후 ICUT cross-fade, accuracy_prep(가중치 0.20)만 하락. 가중평균 + 캐주얼 정서에 정합. **현행 유지**, alpha에서 tap 동기 데이터 보고 재검토.

### A3 (구 #8) — Stage 2B 오답 자동 배치
- 현행: 오답 시 정답 도구 자동 dock + 점수 0(시각 일관성). **현행 유지 + 오답 시 정답 카드 0.3s highlight** 추가 권고(art 비용 0, 학습 cue 보강). pm 확정 사항.

### A4 (구 D1) — 잔치국수 hero 재료
- **대파 송송 110 BPM·4 taps 유지** 권고. CSV·balance·motion 3문서가 모두 대파로 locked-placeholder이고, 70 BPM은 이미 김밥(입문)에 배정됨. 정통성(애호박 고명)이 우선이면 ing_p_012가 준비돼 있어 **CSV 1행 swap으로 alpha 중에도 변경 가능**.

### A5 (구 D2) — 불고기 multi-cut
- **양념재우기 단독 유지**. 3문서 모두 단독 lock, MVP-first + Stage 2A 인지부담 최소 원칙 정합. 양파 채썰기 sequential 추가는 alpha 데이터 후 별도 sprint.

### A6 (구 D4) — Stage 2C 보조 rhythm
- **MVP는 단일 탭 유지**(도구 motion은 시각 ambient). Stage 2A가 이미 rhythm을 담당 → Stage 2C까지 rhythm이면 메커닉 다양성·학습부담 악화. 보조 rhythm은 retention 데이터 후 high-tier에 선택 도입.

---

## 5. 다음 액션

1. **사용자 결정 3건**: B1(컬럼+12행 승인), B2(`DIP-00` 분리 승인), C3(CH-01 OFF 동의). 나머지 9건은 "현행 확정" 일괄 동의.
2. 결정되면 **game-designer**: `foods-database.csv` `method_options` 컬럼+12행, 콘도그 `DIP-00` 토큰 반영.
3. **ui-designer/pm**: scene-2 §6 각 항목에 결정 결과 반영, §6 #4 cross-ref 문구 정정.
4. **art-director**(미니 sprint): `hand_marinade.png` + `corndog_batter_bowl.png` ($0.08).
5. 이후 **godot-dev W1**(라면 end-to-end) 착수 unblock.

---

## 6. 변경 이력
- **2026-05-31 v0.1** — 초안. 미결 12건(scene-2 §6 8건 + design sprint 4건) 수집·권고·통합. 진성 blocker 1건(method_options 컬럼 부재) 식별.
