# Cooking FUN Redesign v1 — Brutally Honest Audit + 8-Module Redesign

> 버전: **v1.0 (2026-06-07)** · 작성자: game-designer
> Status: **Proposal** (design only — NO code, NO new systems, NO new dishes, NO monetization)
> 상위 문서: [`cooking-modules-v1.md` v1.2](cooking-modules-v1.md), [`cooking-modes-v1.md` v1.0](cooking-modes-v1.md), [`cooking-mechanics.md` v0.7](cooking-mechanics.md), [`balance-config.md`](../balance-config.md)
> 분석 대상 코드: `godot-project/scripts/cooking_modules/*.gd` (8 module, 현행 구현), `cooking_module_runner.gd`, `autoload/compatibility.gd`
>
> **사용자 mandate (verbatim)**: "The cooking gameplay is still not fun enough. Each module should feel like a real Korean cooking action and create a satisfying moment. Make gameplay fun first. Visuals support gameplay, not the other way around. Be brutally honest. If a module is boring, say so."
>
> **이 문서의 약속**: 솔직하다. 점수 잘 주려고 봐주지 않는다. scoring/progression/8-module/Casual+Immersive/Guest 2.0 제약은 전부 유지. **feel만 강화.**

---

## 0. 한 문장 진단 (먼저 결론)

> **지금 조리는 "입력은 다양한데 *결과가 안 느껴진다*"가 핵심 문제다.**
> 8 module 모두 gesture는 그럴듯하게 구현됐다. 그런데 **(1) 실패가 아프지 않고, (2) perfect가 짜릿하지 않고, (3) 손님이 내 조리를 보지도 평가하지도 않는다.** 플레이어는 "동작을 흉내냈다"는 느낌은 받지만 "내가 *요리를 망쳤다/살렸다*"는 느낌은 못 받는다. 재미는 **결과의 무게**에서 나온다. 지금은 모든 길이 무난한 점수로 수렴한다.

세 가지 구조적 결함 (코드로 확인):

1. **Stakes 없음 — 거의 모든 실패가 retry로 흡수된다.** Slice는 빗나가면 점수 미반영 + "Drag through ↓" (무한 재시도). Flip은 약하면 점수 미반영 + "Flick faster!". Roll은 슬롯 못 맞춰도 home 복귀 후 재시도. **실패가 점수에 안 박히고 그냥 "다시 하세요"가 된다.** 캐주얼 의도는 알지만, 이게 "긴장"을 통째로 죽인다. 잘해도 못해도 결국 비슷한 점수.
2. **가중 평균 + Skip이 점수를 평탄하게 만든다.** runner `_finish()`는 4-factor를 가중 평균(곱셈 아님)하고, Season default는 항상 90점 고정, Plate는 3지선다(100/70/20). 한 module을 완전히 망쳐도 round 점수는 ★2 근처에 안착한다. **"내 실력이 결과를 바꾼다"는 인과가 약하다.**
3. **손님(Guest 2.0)이 조리에 0% 관여한다.** `compatibility.gd`는 round *끝*에 dish flavor_tags ↔ guest favorite/disliked로 compat을 계산한다. 이건 *요리 선택* 단계의 메커닉이지 *조리* 메커닉이 아니다. **조리 중에는 guest가 bottom-left에서 "Hungry!" 말풍선만 띄우는 장식이다.** 어떤 module도 `_build_module_params`에서 guest 선호를 받지 않는다. → 손님은 "왜 이 요리를 고르나"에만 영향, "어떻게 조리하나"엔 영향 0. 가장 큰 낭비.

이 세 가지를 고치는 게 이 문서의 뼈대다. 나머지는 module별 손맛(juice/feedback) 디테일.

---

## 1. Fun Audit — 8 Module (brutally honest, 1~10)

> 점수 기준: **10 = 이거 하나만으로 게임이 됨. 5 = 작동하지만 잊혀짐. 1 = 게임이 아님(그냥 버튼).**
> 평가는 현행 `*.gd` 구현(Immersive gesture path) 기준. Casual은 더 단순하므로 대개 -1~-2.

| # | module | fun (1-10) | 한 줄 평결 |
|:-:|--------|:----------:|-----------|
| 1 | **Slice** | **6.5** | 8개 중 *가장 잠재력 큼*. drag로 재료가 갈라지고 조각이 쌓이는 건 만족스럽다. 그런데 "도마 가로지르기" 판정이 관대해서 아무렇게나 그어도 통과 — **균일함의 긴장이 없다.** |
| 2 | **Timing (Heat)** | **6.0** | heat dial로 불 조절 + overflow 차오름은 영리하다. 근데 **3.5초 동안 다이얼을 한 위치에 두고 멍때리면 끝.** 손이 바쁘지 않다. 끓어 넘칠 뻔한 "위기"가 거의 안 온다. |
| 3 | **Roll** | **6.0** | 김발 밀어올리기 + sweet zone에서 release는 좋은 콘셉트. 단 **한 번의 drag로 끝나서 너무 짧고, "터짐" 실패가 미지근하다.** 김밥 특유의 "단단히 조이는 압력"이 안 느껴진다. |
| 4 | **Flip** | **5.5** | flick으로 음식이 공중 회전 → 착지 texture swap은 비주얼 임팩트 1등. 근데 **약하면 점수 안 박히고 retry**라 "반뒤집 실패"의 코미디가 사라진다. 한 번 성공하면 끝 = 너무 짧음. |
| 5 | **Stir** | **5.0** | 연속 원형 swipe로 재료가 orbit churn = 손맛 후보였는데, **목표가 "3바퀴 채우기"라 그냥 빙빙 돌리면 됨.** "뭉개짐(너무 빠름)" 페널티가 약해서 빠르게 마구 돌려도 손해 거의 없음. 단조롭다. |
| 6 | **Arrange** | **4.5** | drag-to-slot + magnet glow는 깔끔. 그런데 **"색 맞추기"가 ghost 힌트로 다 보여서 퍼즐이 아님.** 그냥 옮기기. 오방색 미학을 "배운다"는 학습 가치는 있으나 *재미*는 약함. |
| 7 | **Season** | **4.0** | tilt해서 양념 붓기 + 음식 색 변화는 ASMR틱하게 괜찮음. 그런데 **default 음식은 무조건 90점 고정** (`_finalize_simple` → 90.0). 즉 **점수에 영향 0인 연출.** "짜다/싱겁다" 실패 상태가 코드에 없다. marinade(불고기)만 진짜 채점. |
| 8 | **Plate** | **2.5** | **거의 게임이 아니다.** 3지선다 tap (best/2nd/bad shuffled). 완성 음식은 이미 화면에 떠 있고, 그릇 카드 3개 중 하나 누르면 끝. 손맛 0, 긴장 0, skill 0. "universal terminal step"이라는 명분으로 12 음식 전부에 붙는데, **12번 반복되는 가장 지루한 단계.** |

**솔직한 종합**: 평균 **~5.0**. "못 만들었다"가 아니라 "**무난하다**". 무난한 캐주얼 게임은 retention이 안 나온다. 짜릿한 순간(Slice 완벽 균일, Flip 클린 1바퀴, Timing 넘치기 직전 살리기)이 *가끔* 있지만, 그 순간을 게임이 **증폭하지 않고**(화면이 안 터지고, 손님이 안 놀라고, 점수가 안 뛴다) 그냥 다음 단계로 넘어간다.

### 1.1 왜 안 재밌나 — 근본 원인 3가지 (audit 요약)

- **A. 결과가 안 무겁다.** retry로 실패를 흡수 + 가중평균으로 점수 평탄화 → "내가 잘하든 못하든 비슷"
- **B. perfect가 안 터진다.** `_safe_feedback(PERFECT)`는 작은 hit FX 하나. perfect 순간에 시간이 멈추거나, 화면이 번쩍하거나, 손님이 "와!" 하지 않는다.
- **C. 손님이 안 본다.** 조리 중 guest는 장식. 내 칼질을 보고 침 흘리거나, 양념 과하면 인상 쓰거나 하지 않는다.

---

## 2. Redesign Table — 8 Module × 8 Dimension

> 각 module: ① Core fantasy ② Input (Casual/Immersive) ③ Skill challenge ④ Perfect moment ⑤ Failure states ⑥ Guest interaction ⑦ Learning value ⑧ Replay value
> **scoring 무변경**: 모든 변경은 *입력→점수 변환의 feel*과 *연출*에만. output signal 도메인([0,100])·4-factor·★임계 그대로.
> **공통 신규 규칙 (8 module 전체 적용)**: 아래 §3 "3 Fixes" 가 모든 module에 깔린다 (실패가 점수에 박힘 / perfect가 터짐 / 손님이 반응).

### 2.1 SLICE — 균일하게 썰기

| dim | 설계 |
|-----|------|
| ① Core fantasy | "**칼이 재료를 정확히, 리드미컬하게, 균일하게** 가른다." 들쭉날쭉이 아니라 *일정한 간격*. |
| ② Input | **Casual**: 재료 위 화면에 등장하는 **cut guide line**(반투명 가로선)을 따라 짧은 swipe. line 위 ±tolerance면 perfect. **Immersive**: 현행 vertical drag 유지하되 **각 cut마다 목표 위치선이 이동** — 같은 간격으로 그어야 함. |
| ③ Skill challenge | (변경 핵심) "통과 여부"가 아니라 **"이전 cut과 같은 간격인가"**. 첫 cut이 기준이 되고 이후 cut은 *균일성*으로 채점. 빠른 cut 어휘(다지기 140)는 *리듬 유지*, 느린(통썰기 70)은 *정밀 위치*. |
| ④ Perfect moment | cut이 guide에 딱 맞으면 **"챠악" 칼날 섬광 + 조각이 튀어올라 pile에 정렬**. 5연속 perfect = "**균일 콤보!**" 텍스트 + 도마 전체 골든 글로우. (현행 slice_spark 재활용 + 강화) |
| ⑤ Failure states | 간격 들쭉날쭉 → 조각 크기가 **눈에 띄게 다르게** spawn(큰 덩어리/부스러기 섞임) + "Uneven!" + 그 cut 점수 박힘(retry 없음). 너무 빨라 over-mince → 부스러기 가루. |
| ⑥ Guest interaction | 손님이 **균일한 cut을 보면 mini-avatar가 눈 반짝(👀)**, 들쭉날쭉이면 갸웃(❓). guest의 `disliked_flavors`에 "spicy" 등은 무관하지만, **"꼼꼼한" 성격 guest(예: Mrs_Lee)는 uneven에 더 민감 = 균일 보너스 가중** (연출/소프트, 점수는 prep factor 안에서). |
| ⑦ Learning value | 6 cut 어휘(다지기/채썰기/어슷/통/송송/깍둑)를 **간격·속도 차이로 체감**. "채썰기는 가늘고 일정", "깍둑은 큐브". |
| ⑧ Replay value | 균일 콤보 = 자기 갱신 욕구. "이번엔 8연속 perfect" 도전. cut 어휘별 리듬이 달라 음식마다 손맛 다름. |

### 2.2 TIMING — 불 조절 / 끓이기

| dim | 설계 |
|-----|------|
| ① Core fantasy | "**불을 살린다.** 끓어 넘치기 직전에 줄이고, 약해지면 올린다. 면은 쫄깃, 찌개는 진하게." |
| ② Input | **Casual**: 현행 single-tap zone(게이지 perfect 통과 시 1탭) 유지. **Immersive**: heat dial 유지하되 **ideal zone이 *움직인다*** — cook 진행에 따라 적정 불이 강→약으로 2~3회 바뀜(끓이기→뜸들이기). 가만두면 못 따라감. |
| ③ Skill challenge | (변경 핵심) **정적 유지 → 동적 추종**. zone이 이동하므로 손을 계속 써야 함. overflow가 차오르면 *빠르게 불 내려 살리는* 위기 순간 1~2회 의도적 배치. |
| ④ Perfect moment | overflow 80%에서 불 확 내려 살리면 → **"휴—" 김 빠지는 SFX + 화면 살짝 줌인 + "Saved!"**. 끝까지 ideal 유지 → 면/찌개가 **반짝 윤기 cooked sprite로 swap + 손님 침 꼴깍**. |
| ⑤ Failure states | 방치(약불) → 면이 **불어터진(soggy) sprite** + "Undercooked / 설익음". 과열 → 넘쳐서 **국물 흘러내림 + 탄 자국** + "Boiled over!". 둘 다 점수 박힘(현행 overflow 페널티 강화). |
| ⑥ Guest interaction | **"hungry" mood guest는 zone이 더 빨리 이동**(빨리 익혀달라는 압박) / "picky"는 ideal 폭이 좁음(까다로움). 갈비(perfect 0.10 좁음)는 그대로 + guest 보정. |
| ⑦ Learning value | "라면은 9초 센 불, 찌개는 약불 오래" 같은 *한식 화력 감각*. zone 이동 = "처음엔 센 불, 나중엔 뜸". |
| ⑧ Replay value | 위기 살리기의 손맛 = "이번엔 안 넘치게". 음식별 zone 패턴이 달라 외워서 마스터하는 재미. |

### 2.3 ROLL — 김밥 말기

| dim | 설계 |
|-----|------|
| ① Core fantasy | "**단단히 조여 만다.** 느슨하면 풀리고, 급하면 터진다. 손목의 압력과 속도." |
| ② Input | **Casual**: 현행 tap-and-hold(자동 progressive roll, 끝에서 release) 유지. **Immersive**: forward drag 유지하되 **2단계** — ① 끝까지 밀어 만 뒤 ② 짧게 *되누르며 조이기*(squeeze) 동작 추가. release만이 아니라 *조임 압력*이 단단함 결정. |
| ③ Skill challenge | (변경 핵심) 한 번 drag로 끝 → **밀기(속도) + 조이기(압력) 2박자**. 너무 빠른 밀기 = 터짐, 약한 조임 = 헐거움. sweet zone에서 release + 적정 squeeze = tight roll. |
| ④ Perfect moment | tight roll 성공 → **김밥이 "뽁" 단단히 settle + 표면 윤기 + 김 가루 반짝**. 이어지는 Slice에서 *단면이 예쁘게* 드러남(roll 점수가 다음 cut 비주얼에 연동 = 인과 가시화). |
| ⑤ Failure states | 헐거움 → roll이 **풀려서 속 재료 비져나옴** + "Loose!". 터짐 → **김 찢어지고 밥 튀어나옴(코믹)** + "It burst!". 둘 다 점수 박힘. |
| ⑥ Guest interaction | 손님이 말기 과정을 **숨죽이고 지켜봄**(mini-avatar lean-in). tight roll이면 박수, 터지면 "헉". (소프트 연출, friendship delta는 round 점수에서 이미 처리.) |
| ⑦ Learning value | "김밥은 단단히 말아야 안 풀린다" = 실제 조리 팁. squeeze 동작이 그 감각. |
| ⑧ Replay value | 단면 미학 보상(roll→slice 연동) = "예쁜 단면" 욕구. 김밥은 Roll 단독 음식이라 정체성 강함. |

### 2.4 FLIP — 뒤집기

| dim | 설계 |
|-----|------|
| ① Core fantasy | "**한 번에 깔끔하게 뒤집는다.** 팬을 까딱 — 음식이 공중제비 돌아 반대면 착지." |
| ② Input | **Casual**: single tap perfect-window(현행) 유지. **Immersive**: directional flick 유지하되 **2~3회 연속 flip**(파전 한 판을 여러 번 뒤집어 양면 굽기). 마지막 flip의 클린함이 가중. |
| ③ Skill challenge | (변경 핵심) 1회 성공 후 끝 → **연속 flip + 매번 burn meter**. flip 사이 너무 늦으면 그 면이 탐(burn). 약한 flick은 **이제 retry 아님 — 반뒤집으로 점수 박힘**(코미디 + stakes). |
| ④ Perfect moment | 클린 1바퀴 → **음식이 "팟" 소리와 함께 정확히 안착 + 기름 튐 + 노릇한 면 swap**. 연속 perfect flip → "쉐프!" 텍스트. (현행 oil_splash + arc 재활용) |
| ⑤ Failure states | 반뒤집 → **반쯤 접힌 채 철퍼덕**(코믹) + "Flop!" + 점수 박힘. 과회전 → 팬 밖으로 날아가 "Oops!". 늦으면 탄 면. |
| ⑥ Guest interaction | flip은 **가장 구경거리** — guest가 매 flip마다 반응(성공=환호, flop=폭소). "happy" guest는 flop도 즐거워함(친밀도 유지), "grumpy"는 정색. |
| ⑦ Learning value | "파전은 한 번에 뒤집어야 안 부서진다", "콘도그는 굴려서 고루". flick 방향이 음식별로 다름. |
| ⑧ Replay value | flop의 코미디 = 공유 욕구(짤). 클린 연속 flip 마스터 = 실력 표현. |

### 2.5 STIR — 휘젓기 / 볶기

| dim | 설계 |
|-----|------|
| ① Core fantasy | "**고루 섞고, 눌어붙기 전에 계속 젓는다.** 양념이 재료에 입혀지고 윤기가 돈다." |
| ② Input | **Casual**: 짧은 좌우 swipe N회(현행) 유지. **Immersive**: 연속 원형 swipe 유지하되 **"눌어붙음 게이지"** 추가 — 손을 멈추면 가장자리부터 *탄다*. 계속 저어야 게이지가 안 참. |
| ③ Skill challenge | (변경 핵심) "3바퀴 채우기" → **"눌어붙기 전에 꾸준히 + 균일하게"**. 멈추면 탄 가장자리(burn ring) 생김. 너무 빠르면 재료 *뭉개짐*(현행 too_fast 강화). 적정 속도 *유지*가 핵심. |
| ④ Perfect moment | 균일 coating 완성 → **재료 전체가 양념색으로 "촤악" 물들며 윤기 sweep + 김 확 올라옴**. (현행 sheen/spread 강화 + 1회 큰 sweep 연출) |
| ⑤ Failure states | 멈칫 → **가장자리 탄 링 + 연기** + "Burning!". 과속 → 재료 뭉개져 죽처럼 + "Mushy!". 둘 다 점수 박힘. |
| ⑥ Guest interaction | 양념색이 짙어질수록 guest 침 꼴깍. **guest가 매운맛 싫어하면(disliked "spicy")** 고추장 stir 시 살짝 인상(연출). 떡볶이/비빔밥 고추장 강조 음식에서 의미. |
| ⑦ Learning value | "볶음밥은 강불에 빨리, 졸이기는 약불에 오래", "고추장은 골고루 입혀야". |
| ⑧ Replay value | 균일 coating의 시각 보상 + 안 태우기 긴장. wok/bibim/toss 3 variant로 손맛 다름. |

### 2.6 SEASON — 양념

| dim | 설계 |
|-----|------|
| ① Core fantasy | "**적당히** 친다. 싱거우면 밍밍, 짜면 망친다. 손맛으로 양 조절." |
| ② Input | **Casual**: 1-tap auto-pour 유지(ADR-007 정합) — *단, default 음식도 "양 맞추기" 미니 판정 추가*(아래). **Immersive**: tilt+hold 유지. |
| ③ Skill challenge | (변경 핵심 — **현행 default 90점 고정 폐기 의견**, §5 참조) **적정 양 윈도**. 너무 적게 부으면(under) 싱거움, 넘으면(over) 짬. tilt-hold로 *적정 구간에서 멈추기*. Casual은 1-tap이 자동으로 적정의 80~100% 안에 들어오되 *타이밍*으로 미세 차이. |
| ④ Perfect moment | 적정에서 손 떼면 → **음식 표면 윤기 + "딱 좋아!" + 양념 한 방울이 톡 떨어지며 동심원**. (현행 particle + tint 강화) |
| ⑤ Failure states | under → 음식 색 변화 거의 없음 + "Bland / 싱거움". over → **음식이 새빨갛게/시커멓게 + "Too salty! / 짜다"**. |
| ⑥ Guest interaction | **여기가 Guest 2.0 최대 활용 포인트.** guest의 `favorite_flavors`에 "spicy"면 **적정 윈도가 매운 쪽으로 이동**(더 쳐도 OK, 오히려 보너스). "mild" 선호면 윈도가 좁고 낮음(조금만). → **"이 손님은 맵게 먹어" 같은 정보가 조리 행동을 바꾼다.** (season factor 0.20~0.35 가중이라 점수 영향 실재.) |
| ⑦ Learning value | "고춧가루는 톡톡, 간장은 줄기, 참기름은 마지막 drizzle", "양념은 적당히". guest별 입맛 = 한식 "간 맞추기" 문화. |
| ⑧ Replay value | 손님마다 적정 양이 달라짐 = 같은 음식도 손님 따라 다르게 조리. "이 사람은 짜게, 저 사람은 슴슴하게". |

### 2.7 ARRANGE — 정렬

| dim | 설계 |
|-----|------|
| ① Core fantasy | "**아름답게, 균형 있게** 놓는다. 오방색이 조화롭게." |
| ② Input | **Casual**: tap-to-place(자동 슬롯) 유지. **Immersive**: press-drag-release 유지하되 **ghost 힌트 약화/제거** — 색·위치를 *플레이어가 판단*. |
| ③ Skill challenge | (변경 핵심) ghost가 다 알려주는 "옮기기" → **색 대비/대칭 판단**. 인접 슬롯에 *비슷한 색이 몰리면 감점*(오방색 = 분산). Casual은 자동 분산, Immersive는 직접 균형. |
| ④ Perfect moment | 색 균형 완성 → **그릇 전체가 "촥" 화사하게 채도 업 + 오방색 회전 sparkle + "Beautiful! / 색의 조화"**. |
| ⑤ Failure states | 색 몰림 → "Lopsided / 한쪽으로 쏠림" (대칭 깨짐 시각). 빈 슬롯 → 휑함. 점수 박힘. |
| ⑥ Guest interaction | guest가 완성 배치를 보고 **"예쁘다" 반응**. (Arrange는 미학이라 flavor보다 *정성* 신호 — friendship 쪽 연출.) |
| ⑦ Learning value | **오방색(五方色) 한식 미학** — 적/황/녹/백/흑의 균형. 잔치국수 고명, 비빔밥 6색. |
| ⑧ Replay value | "더 예쁘게" 욕구는 약함 — 그래서 §3에서 Arrange를 **2~3 음식으로 줄이는 것 고려**(과용 시 지루). |

### 2.8 PLATE — 담기

| dim | 설계 |
|-----|------|
| ① Core fantasy | "**완성한 요리를 그릇에 담아 손님에게 낸다.** 마지막 정성." |
| ② Input | **Casual**: 그릇 tap select 유지(현행). **Immersive**: 음식을 **그릇으로 drag해서 담기** + garnish(참깨/김가루) **뿌리기 swipe**. (현행은 그릇 tap만 — drag 미구현. 이걸 살리자.) |
| ③ Skill challenge | (변경 핵심 — 현행 3지선다 = skill 0) **담는 위치 + garnish 마무리**. 음식을 그릇 중앙에 잘 안착(off-center면 감점) + garnish를 골고루 뿌림(한쪽 몰림 감점). 그릇 *선택*은 유지하되, **선택 후 "담는 행위"를 추가**. |
| ④ Perfect moment | 중앙 안착 + garnish 고루 → **"짠!" 완성 sparkle + 접시 회전 쇼케이스 + 손님 식탁으로 슬라이드**. 한식 시그니처 그릇이 dish ID card. |
| ⑤ Failure states | off-center → 음식 한쪽 쏠림(시각). garnish 몰림 → 한 곳만 깨범벅. 잘못된 그릇 → 어색(현행 bad tier 유지). 점수 박힘. |
| ⑥ Guest interaction | **그릇 매칭에 guest 취향 반영** — 격식 차리는 guest(예: 가족 어른)는 *제대로 된 그릇*에 +, 캐주얼 guest(친구)는 분식 접시도 OK. (현행 dish_bonus 로직에 guest 가중 살짝.) |
| ⑦ Learning value | "순두부는 뚝배기, 비빔밥은 놋그릇, 떡볶이는 분식 접시" = 한식 그릇 문화. |
| ⑧ Replay value | garnish 뿌리기의 작은 손맛 + 완성 쇼케이스. **단 가장 약한 module이라 §5에서 "skill 추가 vs 간소화" 결정 필요.** |

---

## 3. 모든 Module에 깔리는 "3 Fixes" (이게 진짜 핵심)

> module별 redesign보다 **이 3개 공통 수술이 fun ROI 1등**이다. 8개를 다 안 바꿔도 이 3개만 깔면 전 module이 같이 재밌어진다.

### Fix 1 — 실패가 점수에 박힌다 (retry 흡수 제거)
- **현행 문제**: Slice/Flip/Roll/Arrange는 "빗나간 입력 = 점수 미반영 + 다시 하세요". stakes 증발.
- **수술**: 빗나간 입력도 **저점으로 채점**(0~40). 단 *완전 무입력(touch 없음)*만 retry 허용. "대충 하면 대충 점수가 나온다"를 보장. → 캐주얼 유저도 *나쁜 점수*는 받게 됨 = 긴장 복원. (scoring 도메인 무변경, 그냥 낮은 값이 실제로 emit됨.)
- **Casual 보호**: Casual은 입력이 쉬워 *실패 자체가 드물게* 설계 → retention 유지하되 "잘하면 더 잘 나옴" 인과는 산다.

### Fix 2 — Perfect가 터진다 (juice 증폭)
- **현행 문제**: perfect = 작은 hit FX 1개. 짜릿함 없음.
- **수술 (`cooking_fx.gd` 강화 영역, godot-dev)**: perfect 순간 = **(a) 80ms 미세 hit-stop(시간 멈칫) + (b) 화면 flash/줌 살짝 + (c) 굵은 SFX + (d) "Perfect!" 큰 텍스트 펀치 + (e) 손님 반응 1컷**. 콤보(연속 perfect)는 누적 글로우 + 콤보 카운터.
- 이건 **신규 system 아님** — 기존 `_safe_feedback` / `CookingFX` 호출 강화. 가장 싸고 가장 효과 큼.

### Fix 3 — 손님이 조리를 본다 (Guest 2.0를 조리에 끌어들임)
- **현행 문제**: guest는 round 끝 compat 계산에만 쓰임. 조리 중엔 장식.
- **수술**: `_build_module_params`에 **guest 선호 1~2개 키 추가**(`guest_likes_spicy`, `guest_mood` 등 — 이미 round에 로드된 `_guest` dict에서 추출, 신규 데이터 0).
  - **Season**: guest 선호로 *적정 양념 윈도 이동* (§2.6 ⑥) — 점수에 실제 영향.
  - **Timing**: guest mood로 *zone 이동 속도/폭* (§2.2 ⑥).
  - **전 module**: mini-avatar가 perfect/fail에 **실시간 반응 1컷**(👀/😋/❓/😱) — friendship delta는 기존 round 점수에서 처리하므로 *연출만*, 점수 중복 없음.
- **효과**: "손님 고르기"가 *조리 전략*까지 바꾼다. 게임에 *읽고 적응하는 층*이 생김 = 깊이.

---

## 4. Top 3 Modules to Prototype First (fun ROI 순)

> 기준: **(현재 boring 정도) × (잠재력) × (영향 음식 수)**. "고치면 게임 전체가 산다"가 1순위.

### 🥇 #1 — PLATE (현재 2.5, 영향 12/12)
**왜 1순위**: *가장 boring한데 가장 자주 나온다.* 12 음식 전부의 마지막 단계가 3지선다 tap이면, 플레이어는 **매 라운드 끝을 지루함으로 마무리**한다(최악의 위치 — 마지막 인상). drag-to-plate + garnish 뿌리기로 바꾸면 12 음식이 동시에 개선. 게다가 현행 코드가 *drag조차 안 함*(tap만) — Immersive 약속도 미이행. ROI 최고.

### 🥈 #2 — SLICE (현재 6.5, 영향 10/12)
**왜 2순위**: *가장 잠재력 큰데 한 끗이 부족.* 이미 "재료가 갈라지는" 만족이 있다. "균일성 판정 + 콤보"(§2.1)만 얹으면 **8개 중 단연 best가 될 수 있다.** 10/12 음식이 쓰는 핵심 module이라 polish가 곱해진다. 한식 cut 어휘 학습 가치도 1등. Fix 1(실패 박힘) + Fix 2(콤보 juice)의 쇼케이스로 이상적.

### 🥉 #3 — SEASON (현재 4.0, 영향 5/12 + 시각 12/12)
**왜 3순위**: *Guest 2.0를 조리에 끌어들이는 최적 진입점.* 현재 default 90점 고정 = "점수에 영향 없는 연출"이라 가장 아깝다. §2.6 + Fix 3(guest 선호 → 양념 윈도)을 여기서 프로토타입하면, **"손님 입맛 읽고 간 맞추기"라는 게임 전체의 새 축**을 가장 적은 코드로 검증. 성공하면 Timing/Stir로 패턴 확산.

> **이 3개는 Fix 1/2/3을 각각 대표한다**: Plate=재미없는 단계 살리기, Slice=perfect juice, Season=guest 통합. 셋을 프로토타입하면 3 Fixes 전체가 검증된다.

---

## 5. MVP Implementation Plan (phase별, design spec — godot-dev 영역)

> **원칙**: scoring/4-factor/★/Casual+Immersive/dish_modules.csv 전부 무변경. **입력→점수 변환의 feel + 연출 + guest param 주입**만. 신규 scene/module/currency 0.

| Phase | 범위 | 작업 (design spec) | 무변경 audit |
|:-:|------|------|------|
| **P0** | **3 Fixes 공통 인프라** | (1) `base_module._finish` 경로에 *저점 실패도 emit* 보장(retry는 무입력만). (2) `CookingFX`에 hit-stop/flash/punch-text/combo helper 추가. (3) `runner._build_module_params`에 `_guest` dict에서 `guest_likes[]`/`guest_dislikes[]`/`guest_mood` 추출해 모든 module params에 주입. | 점수 도메인 동일, 단지 *실제로 낮은 값이 나옴* |
| **P1** | **Plate redesign** (#1) | tap-select 후 **drag-food-to-plate + garnish swipe** 추가. 중앙 안착도 + garnish 분산도 → `plate_bonus`(현행 {1.0,0.6,0.2} 도메인 안에서 연속값으로). 그릇 매칭에 guest 격식 가중. | `plate_bonus` 도메인/`get_chosen_dish` contract 동일 |
| **P2** | **Slice redesign** (#2) | cut **균일성 판정**(이전 cut 간격 대비) + **콤보 시스템**(연속 perfect glow) + Fix2 juice 적용. 빗나간 cut = 저점 박힘. | `accuracy_prep` 도메인 동일 |
| **P3** | **Season redesign** (#3) | default 음식 **양념 양 윈도 판정** 도입(90 고정 폐기) + **guest 선호 → 윈도 이동**. marinade variant는 현행 유지. | `accuracy_season` 도메인 동일 (단 값이 실제로 변동) |
| **P4** | **Timing + Stir** | Timing: **이동하는 ideal zone** + overflow 위기 1~2회 + guest mood 보정. Stir: **눌어붙음 게이지**(멈추면 탐) + 균일 sweep 연출. | `accuracy_timing`/cook 도메인 동일 |
| **P5** | **Roll + Flip** | Roll: **squeeze 2박자** + roll→slice 단면 연동. Flip: **연속 flip + burn meter** + flop 코미디(저점 박힘). | 도메인 동일 |
| **P6** | **Arrange** | ghost 약화 + 색 분산 판정. **+ §6에서 Arrange 음식 수 축소 결정 반영.** | 도메인 동일 |

**핵심 순서 근거**: P0(3 Fixes)이 *모든 후속의 토대*. 그 다음 ROI 순(Plate→Slice→Season). Timing/Stir/Roll/Flip은 패턴 확산. Arrange는 마지막(가장 약하고 축소 후보).

**balance 주의**: Fix 1로 "실패가 진짜 점수에 박히면" 평균 점수가 내려간다 → ★ 임계(현행 star2 0.55 등)를 alpha에서 재튜닝 필요할 수 있음(임계 *값*은 balance-config 영역, 메커닉 무변경). Casual 입력 난이도로 신규 유저 보호.

---

## 6. What to Remove or Simplify (솔직히)

| 대상 | 진단 | 권고 |
|------|------|------|
| **Season default 90점 고정** | "점수에 영향 0인 연출". 플레이어가 뭘 해도 90. 가장 아까운 죽은 메커닉. | **제거** → §2.6 양념 양 윈도 + guest 선호로 *실제 채점*. (ADR-007 "양념 고르기 X"는 유지 — 양만 조절.) |
| **Plate 3지선다 tap (skill 0)** | "거의 게임이 아님". 12번 반복되는 가장 지루한 단계. | **간소화 아니라 강화** → drag+garnish (§2.8). *제거는 안 됨* (universal terminal, dish ID card). **단 Casual은 tap select 유지** 가능. |
| **retry 흡수 (Slice/Flip/Roll/Arrange 빗나감)** | stakes를 통째로 죽이는 주범. | **제거** → Fix 1 (저점 박힘). 무입력만 retry. |
| **Arrange 4 음식 (김밥/비빔밥/잡채/잔치국수)** | 재미 4.5로 가장 낮은 *코어 메커닉*. ghost 힌트로 퍼즐도 아님. 4 음식은 과용. | **축소 검토** → 비빔밥(6색=시그니처)·김밥만 Arrange 유지, 잡채/잔치국수는 Arrange step 빼고 Stir/Timing으로 흡수 고려. (dish_modules.csv sequence 조정 = 데이터 1~2행, 신규 module 0.) **신중히 — alpha playtest 후 결정.** |
| **Stir "3바퀴 채우기" 목표** | 빙빙 돌리면 됨 = 단조. | **제거** → 눌어붙음 게이지 (적정 유지가 목표). |
| **헷갈리는 것** | 8 module 모두 howto 텍스트가 화면 상단에 길게 뜸 + zone 라벨. | 텍스트 의존 줄이고 **visual cue로 대체**(cut guide line, 이동 zone band 등). i18n icon-first 정합. |

> **8 module 유지**: 제거 제안은 *Arrange 사용 음식 축소*뿐(module 자체는 유지). Plate도 유지(강화). 8개 구성은 안 건드림 — 제약 준수.

---

## 7. What to Test with Real Players (playtest list)

| # | module/대상 | 가설 | 측정 지표 | 성공 기준 |
|:-:|------|------|----------|----------|
| 1 | **3 Fixes (전체)** | 실패가 점수에 박히고 perfect가 터지면 "내 실력이 결과를 바꾼다"를 체감한다 | round당 점수 분산(전 vs 후), "내가 잘해서 별 받았다" 설문 5점척도 | 점수 분산 ↑ 유의, 설문 평균 ≥ 4.0 |
| 2 | **Plate (drag+garnish)** | drag/garnish가 tap 3지선다보다 만족스럽다 | A/B(tap vs drag), 마지막 단계 후 이탈률, "마무리가 즐거웠나" | drag군 만족 ↑, 이탈률 ↓ |
| 3 | **Slice (균일+콤보)** | 균일성 판정+콤보가 재플레이 욕구를 만든다 | 콤보 최고기록 재도전율, 같은 음식 반복 횟수 | 재도전율 측정값 baseline 대비 ↑ |
| 4 | **Season (guest 선호 윈도)** | guest 입맛에 맞춰 양념을 *바꾼다*(읽고 적응) | guest별 평균 양념 양 차이, "손님 입맛을 의식했나" 설문 | guest 그룹 간 양념 양 유의차 + 설문 ≥ 3.5 |
| 5 | **Timing (이동 zone)** | 이동 zone이 정적보다 손이 바쁘고 위기감 있다 | dial 조작 횟수/round, overflow 발생률, 지루함 설문(역) | 조작 횟수 ↑, 지루함 ↓ |
| 6 | **Casual vs Immersive** | Fix 적용 후에도 Casual이 retention 우위 유지(긴장↑이 캐주얼 이탈 안 만듦) | 모드별 D1 retention, 모드별 평균 ★ | Casual retention 유지 + ★ 분포 정상 |
| 7 | **Flip flop 코미디** | flop이 짜증이 아니라 *웃음*이다 | flop 후 즉시 이탈 vs 재시도, 표정/발화 관찰(대면) | flop 후 재시도율 높음(짜증 아님) |
| 8 | **Arrange 축소** | Arrange 4→2 음식이 지루함을 줄이고 sequence 다양성 체감 ↑ | Arrange 포함 음식 선호도, 전체 module 다양성 설문 | 축소 후 module 피로도 ↓ |

> **대면 playtest 우선순위**: #1(3 Fixes), #2(Plate), #4(Season guest). 이 셋이 핵심 가설. 나머지는 원격 telemetry로 보조.

---

## 8. 핵심 통찰 (왜 안 재밌었나 → 어떻게 재밌게)

### 왜 안 재밌었나 (한 문단)
8 module은 **"동작을 다양하게 만들었지만 결과를 무겁게 만들지 않았다."** ADR-012가 "input을 gesture로" 잘 바꿨고 ADR-013이 "Casual로 쉽게" 잘 완화했다. 그 과정에서 **stakes가 사라졌다** — 실패는 retry로 흡수되고, 점수는 가중평균으로 평탄해지고, perfect는 조용히 지나가고, 손님은 조리를 보지도 않는다. 그래서 "요리하는 흉내"는 나는데 "요리를 *해냈다/망쳤다*"는 카타르시스가 없다. **재미는 입력의 다양성이 아니라 *내 행동이 만든 결과의 무게*에서 온다.**

### 어떻게 재밌게 (한 문단)
**module을 8개 다 새로 만들 필요 없다. "3 Fixes"를 전부에 깔면 된다.** (1) **실패를 점수에 박아** stakes를 복원하고(잘하면 잘 나오고 못하면 못 나온다), (2) **perfect를 터뜨려**(hit-stop+flash+손님반응) 짜릿한 순간을 게임이 *증폭*하고, (3) **손님을 조리에 끌어들여**(Season 양념 윈도가 guest 입맛 따라 이동, Timing이 mood 따라) "읽고 적응하는 깊이"를 더한다. 그 위에 module별로 *한 끗*씩 — Slice 균일성+콤보, Plate drag+garnish, Roll squeeze, Flip 연속, Stir 눌어붙음, Timing 이동 zone — 을 얹으면 **각 module이 "진짜 한식 조리 동작 + 만족스러운 순간"**이 된다. 비주얼은 이 결과를 *전달*하는 역할(타는 가장자리, 윤기 sweep, 풀린 김밥)이지, 그 자체가 목적이 아니다.

> **한 줄 요약**: *입력은 이미 좋다. 결과를 무겁게, perfect를 시끄럽게, 손님을 조리 안으로.*

---

## 9. 제약 준수 audit

| 제약 | 준수 |
|------|------|
| NO new systems | ✅ 3 Fixes는 기존 `_finish`/`CookingFX`/`_build_module_params` 강화. 신규 system 0 |
| NO new dishes | ✅ 12 음식 그대로 |
| NO monetization | ✅ Skip(Rewarded) 언급 없음, 수익 변경 0 |
| 8 module 유지 | ✅ 8개 구성 무변경 (Arrange는 *사용 음식 수* 축소 검토만, module 유지) |
| scoring/progression 유지 | ✅ output signal 도메인·4-factor·★임계·dish_modules.csv 무변경. *값이 실제로 변동*하는 건 메커닉 아니라 입력→점수 변환 feel |
| Casual + Immersive 양 모드 | ✅ 각 module ②에 Casual/Immersive 둘 다 명시 |
| Guest 2.0 활용 | ✅ Fix 3 + Season/Timing/Plate에 guest 선호·mood 통합 (기존 `_guest` dict 재활용, 신규 데이터 0) |
| 코드 X | ✅ 설계 문서만. 구현은 godot-dev 영역 (P0~P6 spec) |
