# CHANGELOG / Working Memory

> 이 파일은 K-Food Master 프로젝트의 **작업 로그 + working memory**.
> 새 작업/결정/이슈가 발생할 때마다 최상단에 항목 추가.
> 날짜는 절대 표기 (`YYYY-MM-DD`), 필요 시 작성자 명시.

---

## 형식
```
## [YYYY-MM-DD] 짧은 제목
- **무엇**: 한 줄 요약
- **왜**: 의사결정 배경 / 트리거
- **결과/다음 단계**: 산출물, 후속 작업
```

---

## [2026-05-26] ADR-005 confirm 3건 lock — 번호 005 유지, Perfect ±80ms, Skip 0.9
- **무엇**:
  - **ADR 번호 = 005 유지** (사용자 confirm, typo 수용. 006 rename X). 구조적 인덱스 일관 — hole 없음.
  - **Perfect window = ±80ms LOCKED** (사용자 confirm, pm 권고 채택, 사용자 원안 ±100ms override). alpha fail rate 검증 후 필요 시 Remote Config로 ±100ms 완화 옵션.
  - **Skip `accuracy_prep` = 0.9 LOCKED** (사용자 confirm, pm 권고 채택, 사용자 원안 1.0 auto-perfect override). skill bonus 명분 유지 (engage 시 +10% 추가 점수 상승 여지) + cut style anim art workload(+25~35h) 대비 engage ROI 확보.
  - **갱신 파일 3종**:
    - `docs/balance-config.md` v0.3 → **v0.3.1** (§6 dual-column 단일화 ±80ms LOCKED / §8 Skip default 1.0→0.9 LOCKED / §11 open question #10·#11 resolved / §2 컨텍스트 표 ADR-005-B / ADR-005-D LOCKED 라벨)
    - `docs/decisions.md` ADR-005 — Context §Perfect window 수치 충돌 → LOCKED + Skip 항목 신규 LOCKED 추가 / Scoring 룰 §Perfect 라벨 / Mobile Latency Handling sync
    - `CHANGELOG.md` — 본 항목
- **왜**: ADR-005 채택 직후 pm raise한 3건 confirm을 한 라운드에 lock. alpha 데이터 기다리기 전 디자인 의도 명확히 → 후속 game-designer / godot-dev sprint가 placeholder 양자 병기 X 단일 값으로 진행.
- **결과/다음 단계**:
  - **개방 confirm 0건** (ADR-005 관련). 다음 잔여 confirm: 직전 sprint (Tier 2 카피 톤 / 튜토리얼 다시 보기 / 양념치킨 부활 / 잡채 ramp 보강) — 모두 alpha 이후 검토 또는 low-priority.
  - **alpha 후 재검토 hook**: Perfect window fail rate 분포(±80ms로 30%+ Miss면 ±100ms 완화 검토) / Skip rate (>60%면 0.9→0.85 또는 +ad freq 강화) — data-analyst Phase 2 모니터링 항목.
  - **잔여 ADR-005 후속 sprint**: game-designer (foods CSV prep_* lock + cooking-mechanics §X 본격) / ui-designer (도마 + Knife indicator + FTUE 6-step) / godot-dev M2 진입 시 / art-director (art-style lock 후).

---

## [2026-05-26] ADR-005: 4-stage 메커닉 추가 — 재료 준비 (rhythm tap, knife indicator). Option C (optional skill bonus). +1~3주 일정 영향.
- **무엇**:
  - **ADR-005 Accepted** — 3-stage → 4-stage 확장. Stage 2 sub-stage 분할 (2A 재료 준비 / 2B 조리 방법 / 2C 조리 시간). Scene 변경 없음 (Scene 2 키친 내 sub-flow).
  - **Option C — optional skill bonus rhythm tap** 채택. Skip 가능 (📺 Rewarded Video → auto-perfect, Stream A 자연 트리거).
  - **Knife indicator visual cue** — 칼이 자동 위아래 움직임, 도마 닿기 직전 = perfect tap. 별도 rhythm UI 없이 게임 비주얼 통합.
  - **Cut Styles 6종 (한식)**: 다지기 / 채썰기 / 어슷썰기 / 통썰기 / 송송썰기 / 깍둑썰기.
  - **Total Score 가중 평균 공식** (cooking-mechanics §3 곱셈 모델 supersede): 재료 25% × 준비 20% × 방법 20% × 시간 35%. ★1 30%+, ★2 60%+, ★3 90%+.
  - **Per-Food BPM Design**: Tier 1 BPM 70~110 (3~6 taps) / Tier 2 BPM 90~140 (5~8 taps). 다지기 가장 빠름(140), 통썰기 가장 느림(70), 양념 재우기 60 BPM (마사지 식).
  - **Perfect window**: Perfect ±80ms (pm 권고) vs ±100ms (사용자 명시) — balance-config v0.3 placeholder, alpha 후 lock.
  - **Tutorial 확장**: FTUE 5-step → 6-step (Round 1 BPM 60 + 2 taps + 시각 가이드 full → Round 4+ 정상 BPM).
  - **갱신 파일 7종**:
    - `docs/decisions.md` — ADR-005 본문 신설, 인덱스 ADR-005 행 추가, ADR-003 §Decision 옆 한 줄 註
    - `CHANGELOG.md` — 본 항목
    - `docs/systems/cooking-mechanics.md` v0.4 → **v0.5** (헤더 + §2 4-stage + §3 가중 평균 supersede + §X 재료 준비 placeholder)
    - `docs/balance-config.md` v0.2 → **v0.3** (§5 4-factor weights / §6 Prep Rhythm window / §7 BPM by Tier / §8 Skip Bonus 신규)
    - `docs/art-workload-estimate.md` v3.0 → **v3.1** (+25~35h pm reality check placeholder)
    - `docs/GDD.md` v2.1 → **v2.2** (§2 Core Loop 4-stage sync / §6.3 prep_* + cut_variations / §13 R-A13~R-A16 4건)
    - `docs/agent-roster.md` — sound-designer 신설 X, art-director sound 겸직 결정 명시
- **왜**:
  - 사용자 메이저 decision (2026-05-26) — 기존 Stage 2 단일 카드 선택의 메커닉 빈약함 재평가, 한식 cutting 기법(다지기/채썰기 등)이 게임 표현 기회로 미활용.
  - rhythm tap + Knife indicator visual cue로 메커닉 깊이 추가 + K-stylistic touch 강화.
  - Skip 옵션이 Rewarded Video 자연 트리거 → Stream A CTR ↑.
  - Optional 설계로 캐주얼 진입장벽 유지 (어려우면 Skip → auto-perfect).
- **결과/다음 단계**:
  - **ADR 번호 확인 필요 (사용자 confirm)**: 사용자가 "ADR-006" 지정했으나 ADR-005가 비어있어 **ADR-005로 작성**. 의도가 다르면 알려주세요.
  - **일정 reality check (둘 다 명시)**:
    - 사용자 추정: +1주
    - **pm 평가: +2~3주** — 근거 = audio engine (BPM 메트로놈 + latency calibration) + UI (Knife indicator + 도마 화면 + FTUE 확장) + art (칼/도마 1 set + cut style anim 3~4 frames × 6 + hero ingredient cut variation) + balance (4-factor 가중치 검증 + BPM/tap 음식별 매핑) + tutorial 확장. 5개 영역 cross-cutting.
    - 결과: ADR-003 일정 3~4개월 → **3.5~4.5개월** (buffer 초과 가능성). M0 reality check 게이트에서 재평가.
  - **신규 Risk 4건**:
    - **R-A13** Mobile audio latency (기기별 ±100ms 차이) — 영향 중 / 가능성 중. 완화: visual cue 우선 + post-launch calibration UI.
    - **R-A14** Art-style reset 의존 (현재 보류 상태) — 영향 중 / 가능성 고. 완화: art-director 작업 BLOCKED on art-style lock.
    - **R-A15** Sound deferral 충돌 (ADR-003 M2~M3 deferred ↔ ADR-005 BPM 메트로놈 강의존) — 영향 중 / 가능성 중. 완화: M2 minimum 1~2주 sound 작업만 추가, 전체 사운드 deferred는 유지.
    - **R-A16** 일정 +1~3주 out-of-bound — 영향 고 / 가능성 중. 완화: M0 reality check 게이트.
  - **art-director BLOCKED**: 직전(2026-05-24) art-style reset 선언 + 새 reference 결정 보류. ADR-005 art 작업(칼/도마 + cut anim) 진입 불가, art-style lock 후로 격리.
  - **Sound-designer 결정**: 신규 agent 신설 X. **art-director가 sound 겸직** (Phase 2 통합). 근거: 1~2주 sound 작업량, 별도 agent 오버헤드 불필요. agent-roster.md art-director 행에 "+ Phase 2 sound (BGM/SFX/rhythm) 겸직" 추가.
  - **후속 sub-agent 우선순위**:
    1. **game-designer**: foods-database.csv prep_* 4 컬럼 + ingredients-database.csv cut_variations 컬럼 + balance-config v0.3 정확 수치(BPM 음식별 / perfect window lock) + cooking-mechanics v0.5 본격 sprint (§X 재료 준비 룰 상세)
    2. **ui-designer**: screen-flow v0.3 (도마 화면 + Knife indicator) + components.md CP-18/CP-19 신설 + ftue.md 6-step
    3. **godot-dev** (M2 진입 시): Stage 2A rhythm tap 구현 + Knife indicator AnimationPlayer + Skip → Rewarded Video wire + 4-factor 가중 평균 채점
    4. **art-director** (art-style lock 후): 칼/도마 art + cut style 애니메이션 + hero 재료 cut variation
  - **사용자 confirm 필요**:
    - ADR 번호 (006 vs 005) 의도 확인
    - Perfect window 80ms vs 100ms 최종 lock 시점 (alpha 후 가능)

---

## [2026-05-25] Godot env install — AAB smoke PASS, GitHub repo push, AppLovin signup gated
- **무엇**:
  - **Godot 4.6.3 stable 설치 + 프로젝트 import** (사용자가 4.5.2 LTS 대신 4.6.3 stable 선택, ADR-004 범위 안). `project.godot` 4.5 → 4.6 feature 갱신, deprecated `[physics] enable_pause_aware_picking` 제거, header 주석 sync.
  - **JDK 17 (Temurin) + Android Studio + SDK API 34 + Build-Tools 34.0.0 + NDK 25.2.9519653 설치 완료** (사용자).
  - **Godot Editor**: Editor Settings에 Android SDK Path 등록, Export Templates 4.6.3 다운로드(수동/Online 모드), Install Android Build Template 완료, Debug keystore 생성 + 등록.
  - **첫 AAB smoke build PASS**: `build/kfoodmaster-0.1.0.aab` 생성. Godot 4.6.3 + custom gradle build 파이프라인 검증 완료.
  - **scenes/main.tscn** placeholder 신설 (Editor가 missing scene 에러 raise → 빈 Node2D placeholder, M2에서 실 main 화면으로 교체).
  - **`.gitignore` Godot 섹션 추가** (.godot/, .import/, *.translation, gradle 캐시, google-services.json).
  - **Git init + 첫 commit (root-commit f5b05a1, 83 파일, 7148+ lines)**. 사용자 정보 globally configured (JS Park / fwlooking@gmail.com).
  - **GitHub repo public 생성**: https://github.com/nanunjun/kfood-game (gh CLI 통한 한 줄 create+push).
- **왜**: ADR-004 follow-up. M2 sprint gameplay 진입 prerequisite로 engine 환경 검증.
- **결과/다음 단계**:
  - **AppLovin MAX signup gated** — AppLovin이 dev signup 단계에서도 Play Store published app 요구. account-approval@applovin.com 이메일 회신: "publish 후 link 재신청". **결정: Option A (defer)** — AppLovin은 M2~M3 sprint(Play Console Internal Testing 트랙 등록 시점)로 이월. Stream A 수익 ADR 변경 없음, 단순 일정 슬립.
  - **다음 plugin 작업** (이번 세션): Google Play Billing + Godotx Firebase. 둘 다 Play Console gate 없음 (Billing은 IAP **테스트**만 Play Console 필요, install/wire는 가능).
  - **Play Console 셋업**은 M2 후반 또는 M3 초반 task. $25 일회 + Internal Testing 트랙 + AppLovin 재신청 (1~3 영업일 검토).
  - **godot-setup-guide.md** 갱신 권고: 4.5.2 LTS → 4.6.x stable 라벨 sync (low priority, next sprint).

---

## [2026-05-24] godot-dev sprint — Godot 4.5.2 LTS 환경 구축 + 프로젝트 bootstrap + 설치 가이드
- **무엇**:
  - **godot-project/ bootstrap (31 파일)**:
    - `project.godot` (4.5.2 LTS, 1080×1920 mobile, portrait, etc2_astc 텍스처, 6 autoload 등록)
    - `export_presets.cfg` (Android AAB preset, gradle build, min_sdk=24 / target_sdk=34, version_code/name placeholder, secret 분리)
    - `.gitignore` (Godot 표준 + secret 격리)
    - `icons/icon.svg` placeholder
    - `README.md` (직전 ADR-004 sprint 산출 유지)
    - 폴더 트리: `addons/ / scenes/ / resources/ / art/{sprites,ui,animations}/ / audio/{sfx,bgm}/ / scripts/{ads,iap,save,analytics,ui,gameplay}/` (.gitkeep)
  - **Resource 스키마 6종** (`godot-project/scripts/resources/*.gd`):
    - `food_definition.gd` (foods-database.csv 15 컬럼 1:1)
    - `ingredient_definition.gd` (ingredients-database.csv 8 컬럼, `used_in_foods: Array[StringName]`)
    - `store_definition.gd` (5가게 id/color/icon/ambient_sound)
    - `character_definition.gd` (주인공/양친 공통, role enum, reaction_anchor_paths Dict)
    - `cooking_method_definition.gd` (7+ 조리법, default cook_time / perfect_window)
    - `timing_definition.gd` (Stage 3 band, C-4 lock 45/45/10 default)
  - **autoload skeleton 6종** (`godot-project/scripts/autoload/*.gd`, 등록 순서):
    - RemoteConfigManager (balance-config v0.2 §2 20+ 키 상수 catalog)
    - SaveManager (ConfigFile 기반, mid-game 캐릭터 swap 데이터 보존 hook 주석)
    - AdsManager (AppLovin MAX wrapper placeholder)
    - IapManager (Google Play Billing wrapper placeholder)
    - AnalyticsManager (Godotx Firebase Analytics, 이벤트 5종 enum placeholder)
    - GameManager (세션 lifecycle hook)
    - 각 `func _ready()` 빈 + `# TODO: M2 sprint 구현` 주석
  - **`docs/godot-setup-guide.md` v1.0 신설** (302줄, Step 0~10):
    - Step 1 Godot 4.5.2 LTS install / Step 2 JDK17 (Temurin/MS OpenJDK) / Step 3 Android SDK (commandlinetools 권장, `sdkmanager` 명령) / Step 4 Android export template / Step 5 Debug keystore / Step 6 공식 plugin 3종 (AppLovin MAX v1.2.0 + Google Play Billing + Godotx Firebase) / Step 7 첫 AAB smoke test / Step 8 검증 체크리스트 / Step 9 알려진 함정 (JDK 버전 mismatch / NDK 미설치 / AppLovin SDK Key silent fail / Gradle 메모리 / Firebase google-services.json) / Step 10 Mac/Linux 노트
- **왜**: ADR-004 (Godot 채택) 후속 사전 작업. Art-direction이 reset 중이지만 engine env는 art와 독립이라 병행 진행 가능. M2 gameplay sprint 진입 prerequisite 확보.
- **결과/다음 단계**:
  - **사용자 다음 액션**: `docs/godot-setup-guide.md` Step 1부터 순차 수행 (Godot 4.5.2 install → import `godot-project/project.godot`). 예상 소요 **~3~5시간** (Godot 20분 + JDK 20분 + Android SDK ~1.5h NDK dominant + plugin 3종 ~1h + AAB smoke ~30분).
  - **알려진 함정 우선순위**: ① JDK 17 강제(11/21 비호환) ② Android NDK `ndk;25.2.9519653` 필수 ③ AppLovin SDK Key 미발급 시 silent fail.
  - **M2 sprint 이월**:
    - gameplay 코드 (Stage 1/2/3 메커닉, scoring, distractor)
    - main 씬 → main menu 교체
    - .tres 인스턴스 일괄 생성 (12 음식 + 42 재료 + 5가게)
    - AppLovin MAX / Billing / Firebase 실 wiring (autoload TODO 해제)
    - U-2 양친 0.6s 시차 unlock 컷씬 AnimationPlayer 구현
    - Firebase Remote Config Console 키 등록 (balance-config v0.2 §2)
    - Hint 버튼 → Rewarded Ad 연결
  - **art-direction reset**은 별도 트랙 — godot-dev에 영향 없음 (asset path는 모두 placeholder).

---

## [2026-05-24] art-director Week 1 anchor 실행 키트 + 평가 rubric — 사용자 MJ 세션 핸드오프
- **무엇**:
  - `docs/mj-session-kit.md` v0.1 **신설** — 사용자 MJ Discord/web copy-paste용. Step 0(sref anchor 후보) / Step 1(캐릭터 5) / Step 2(환경 5) / Step 3(결과 인계) 순서. 10 anchor 각각 모델/파라미터/sref placeholder/reroll 트리거 매핑 ready.
  - `docs/art-anchor-rubric.md` v0.1 **신설** — 10 anchor × G1~G7 평가 표. G6 MJ 약점 6항 세분화 (손가락/정면 얼굴 대칭/텍스트 누수/일본·중국 인상 누수/3D 누수). 종합 LOCK 조건 = **10 중 8 LOCK + 캐릭터 sref 1 PASS + 환경 sref 1 PASS**.
  - `docs/prompts-library.md` v0.1 → **v0.2** — §0.1 sref 매핑 표(`--sw` 권장값 포함) + §0.2 사용자 결과 schema 신설.
  - `docs/art-style-guide.md` v0.1 → **v0.2** — §10.1 rubric 참조 한 줄 + §3.5 U-2 sync (양친 reaction 6컷 sleeping 회피 원칙).
- **왜**: MJ Standard 결제 완료 + 직전 sprint 산출(prompts-library v0.1, style-guide v0.1)이 anchor 게이트 prerequisite. 사용자가 1회 세션으로 MJ 실행할 수 있도록 copy-paste·평가 rubric·인계 schema 일체 packaging. Week 1 anchor lock = M1 art sprint kick-off prerequisite.
- **결과/다음 단계**:
  - **Step 0 sref 후보**:
    - 캐릭터 sref = **CH-01 주인공** (Tier 1 L1부터 항상 등장, 모든 캐릭터 anchor base).
    - 환경 sref = **BG-01 청과상** (한식 시각 요소 풍부, Cabbage Green 베이스 팔레트 자연스러움).
  - **사전 경고 (까다로울 3건)**:
    - CH-03 아버지 — niji 6가 "50대"를 "20대 anime boy"로 그릴 확률 ≥ 50%. salt-and-pepper 머리·눈가 주름 강조 필수.
    - CH-02 어머니 — 한복이 일본 기모노로 빠질 확률 ≥ 40%. 옷섶 방향·오비 두께 즉시 체크.
    - BG-05 잡화점 — v6.1이 옹기를 중국 청화백자로 그릴 확률 ≥ 35%. `NOT Chinese vase` 강제.
  - **예상 소요 시간**: 1차 시도 1.5~2시간, reroll 3~4장 포함 현실 **2~3시간**. MJ Standard fast 15h/월 대비 충분.
  - **사용자 인계 형식**: `mj-session-kit.md` §5.1 schema (Anchor ID / URL / sref / seed / 4-grid 선택 칸 / Round / 메모) 12세트.
  - **사용자 액션**: MJ 세션 실행 → 결과 schema로 정리 → 다음 turn에 art-director가 G1~G7 rubric으로 PASS/FAIL 판정 → 8/10 LOCK + sref 2 PASS이면 M1 art sprint kick-off.
  - **M1 sprint 이월 (anchor LOCK 후)**: reaction 6컷(어머니/아버지 ★1/2/3), 음식 12개 anchor, 재료/UI/VFX prompt.

---

## [2026-05-24] C-1~C-4 결정 적용 — 양념치킨 → 순두부 회귀, flip 미도입, Stage 3 45/45/10 lock + UI 후속 sync
- **무엇**: 직전 sprint에서 game-designer/ui-designer가 raise한 confirm 항목 6건(C-1~C-4 + U-1 + U-2) 일괄 결정 및 적용. 두 agent 병렬 실행.
  - **사용자 결정 (2026-05-24)**: C-1 콘도그 **유지** (no-op) / **C-2 양념치킨 → 순두부찌개 회귀** (구조적, T2 어물전 floor 보강) / **C-3 해물파전 flip 미도입** (MVP-first) / **C-4 Stage 3 good/miss/perfect = 45/45/10** (마스코트+가족 정서 부드러움) / **U-1 FTUE 첫 음식 호떡 lock** / **U-2 어머니/아버지 L11 동시 unlock**.
  - **game-designer 갱신 6종**:
    - `docs/systems/mvp-food-selection.md` v2.0 → **v2.1** (C-2 lock, Tier 2: 비빔밥/갈비구이/김치찌개/잡채/순두부찌개)
    - `docs/foods-database.csv` (양념치킨 t2_011 삭제 → 순두부찌개 t2_013 추가, ID gap 의도적)
    - `docs/ingredients-database.csv` 40 → 42행 (닭·감자전분 제거, 호박/멸치/순두부/고춧가루 신규, used_in_foods sync)
    - `docs/store-distribution.md` v1.0 → **v1.1** — **어물전 floor 4 → 5** (T2 어물전 음식 1개 확보, T2 다점포 메커니즘 회복). 5×12 합계: 청과 10 / 정육 7 / 어물 **5** / 곡물 9 / 잡화 12.
    - `docs/balance-config.md` v0.1 → **v0.2** — §3.1 C-4 lock(Remote Config `cooking.stage3.band_distribution = {perfect:0.10, good:0.45, miss:0.45}`), §4 C-3 lock(해물파전 flip 미도입 + post-launch 사양 §4.2 격리), 순두부찌개 cook_time 14s / perfect_window 950ms / perfect_width 0.07.
    - `docs/friends-system.md` v0.1 → **v0.2** — 호불호 axis 양념치킨(spicy+sweet+oily) → 순두부찌개(spicy+salty+mild) 치환. 어머니 net 0, 아버지 net +2, 합산 +2 가족 최고 선호 그룹.
  - **ui-designer 갱신 3종**:
    - `docs/ui/ftue.md` v0.1 → **v0.2** — U-1 호떡 LOCK. Step 1 곡물상 단독 + Step 2 곡물+잡화 풀 활성 (호떡이 2가게 SKU와 fit, 음식 swap 불필요).
    - `docs/ui/tier-1-2-flow.md` v0.1 → **v0.2** — U-2 적용. 어머니/아버지 0.6s 시차 fade-in 단일 컷씬, reaction anchor 6컷 즉시 active(sleeping 회피), §3.3.1 L11~15 reaction 단계 흐름 신설(L11~12 Subtle / L13~14 어머니 우선 / L15+ 양친 동시).
    - `docs/ui/components.md` v0.1 → **v0.2** — Godot 전환 sync (ADR-004). 15종 컴포넌트 모두 "Godot 매핑" 행 신규, §0 컨벤션 블록(.tscn/.tres/.gd + godot-project/ 경로), AppLovin MAX Godot plugin 참조 1건(§10 Hint).
- **왜**: 직전 sprint 후속 confirm 누적 6건이 의사결정 적체 위험 → 한 라운드에 일괄 처리. C-2는 구조적(T2 어물전 0회 → 다점포 메커니즘 가치 약화) 이유로 사용자가 game-designer 권고 채택. C-3/C-4는 ADR-003 MVP-first + 마스코트 톤 정합. U-1/U-2는 음식 reshuffle/정서 임팩트로 자연 도출.
- **결과/다음 단계**:
  - **사용자 추가 confirm 필요 신규** (낮은 우선순위):
    - Tier 2 카피 톤 placeholder 검토 cadence (pm)
    - 튜토리얼 다시 보기 옵션 노출 여부 (pm)
  - **다음 sprint 이월 (game-designer 또는 godot-dev)**:
    - `cooking-mechanics.md` §4.4 outdated reconciliation — v0.4 본문 30/60 → balance-config v0.2의 45/45/10으로 sync (game-designer #7)
    - **잡채 단독 T2 중반 리스크** — 난이도 ramp L15~L19 공백, ui-designer Tier 1~2 flow 재검토 권고 (game-designer #4)
    - 양념치킨 post-launch M1 1순위 부활 후보 — soft launch alpha 데이터로 검증 (pm)
    - food_id gap (t2_011 결번 + t2_013) — Resource(.tres) 매핑 시 무영향, 디자이너 가독성만 영향 (godot-dev noted)
    - balance-config sync 항목 — 호떡 부분집합 재료 분배 / L11~15 reaction 정확 레벨 / FTUE Stage 3 PERFECT 20% 확대 수치 (game-designer)
    - Godot Resource(.tres) 6종 스키마 lock — Ingredient/Store/Food/Character/Timing/CookingMethod (godot-dev)
    - 양친 unlock 컷씬 0.6s 시차 AnimationPlayer 구현 (godot-dev)
    - AppLovin MAX Godot plugin Hint 버튼 wiring (godot-dev)

---

## [2026-05-23] ADR-004: PM 우려 사항 fact check 후 Godot 채택 확정 (AppLovin 공식 plugin, Foundation mobile 인프라 성숙)
- **무엇**:
  - **ADR-004 Accepted** — Engine = Godot 4.6 (또는 4.5.2 LTS), Language = **GDScript only** (C#/.NET 미사용), Ads = AppLovin MAX 공식 Godot plugin, IAP = Godot Foundation Google Play Billing plugin, Analytics/Crashlytics = Godotx Firebase. ADR-002/003 supersede 하지 않음 — 엔진/언어만 lock.
  - `docs/decisions.md` 갱신 (인덱스 + ADR-004 본문 + ADR-002 §Decision #2 옆 註: "Asset Store 의미 재정의 — paid marketplace 아닌 engine-agnostic 무료 소스(Kenney/OpenGameArt/Itch/Freesound) + Godot Asset Library 무료 항목").
  - `CLAUDE.md` 갱신 (엔진/언어/네이밍/빌드/폴더구조/Claude 작업 가이드/Sub-Agent Team `unity-dev` → `godot-dev`).
  - `docs/GDD.md` §8 Tech Stack / §6.3 데이터 형식(SO → Resource[.tres]) / §12.3 / §13 R10 갱신, 버전 v2.1.
  - `docs/agent-roster.md` `unity-dev` 행 → `godot-dev`, 위임 가이드 코드 권한 재라벨.
  - `.claude/agents/godot-dev.md` 신설 (unity-dev.md 동일 frontmatter/tool 권한 패턴).
  - `docs/art-workload-estimate.md` Asset Store 표현 3건만 engine-agnostic 소스로 재라벨, **워크로드 ~80h 무변경 / v3.0 유지**.
  - **Main thread Bash 처리**: `.claude/agents/unity-dev.md` 삭제, `unity-project/` → `godot-project/` rename (내부 README.md 1개), 새 `godot-project/README.md` 작성 (Godot 4.6 셋업 체크리스트 + 공식 plugin 3종 + 폴더 구조 + `.tscn`/`.tres` 편집 가이드).
- **왜**: 사용자 "Unity → Godot 교체" 1줄 요청 → main thread가 3가지 우려(AppLovin/Asset Store/컨벤션) raise → 사용자가 fact pack으로 우려 반박 (AppLovin 공식 Godot plugin 존재 + Asset Store 영향 overstated + 컨벤션 변경 trivial). Main thread `AppLovin/AppLovin-MAX-Godot` v1.2.0 (2025-04-24, AppLovin org 소유) 검증 → fact 확정. pm이 ADR-004 작성 및 follow-up 일괄.
- **결과/다음 단계**:
  - **사용자 confirm 필요 없음** — fact pack 기반 모든 결정 처리 완료.
  - **후속 sprint 이월**:
    - **ui-designer**: `docs/ui/components.md` "Unity prefab" 표현 → Godot "Scene/Node(.tscn)" 일괄 갱신.
    - **game-designer**: `docs/balance-config.md` Remote Config 구현 전략 — Firebase Remote Config로 통일 권고(Godotx Firebase Remote Config 모듈 검증 포함).
    - **godot-dev**: Godot 4.x export 환경 셋업 (Android export template / JDK17 / Android SDK / AAB 빌드 검증).
    - **godot-dev**: Godotx Firebase plugin 의존 추가 + Analytics/Crashlytics 부트스트랩.
    - **godot-dev**: AppLovin MAX Godot plugin Asset Library 설치 절차 검증 + Android API 24+ 요구사항 v1.2.0 기준 재확인.
    - **pm**: GDD §12.3 Godot 4.5.2 LTS / 4.6 라이프사이클 추적 (분기별 release note 모니터링).
  - **ADR 추론 흐름**: 사용자 1줄 → 우려 raise → fact pack → URL 검증 → ADR-004 Accept. ADR-002/003 reversal 같은 same-day 패턴이지만 검증 단계가 들어가서 정당화됨.

---

## [2026-05-23] MVP 음식 Final 12 lock + DB/balance/friends spec 일괄 신설 (mvp-food-selection v2.0)
- **무엇**: 사용자 지정 Final 12를 canonical로 lock. `mvp-food-selection.md` v1.0 → **v2.0 supersede**. 변경 표면적으로 "두 가지 조정"(김치전→해물파전 / 불고기→갈비구이)으로 라벨됐으나 **실제 5건** 변경 (계란말이→콘도그 / 떡국→호떡 / 김치전→해물파전 / 제육볶음→잡채 / 갈비찜→갈비구이 / 순두부→양념치킨 — 사용자 표기 "불고기"는 v1.0 미존재, 실 대체 대상은 갈비찜). game-designer가 5건 모두 재검증.
  - **신설 5종**: `docs/foods-database.csv` (12행), `docs/ingredients-database.csv` (40행), `docs/store-distribution.md`, `docs/balance-config.md` v0.1, `docs/friends-system.md` v0.1.
  - **갱신 1종**: `docs/systems/mvp-food-selection.md` v2.0 — v1.0 supersede, D-1/D-2 자연 해소, 제거 음식 5종(계란말이/떡국/김치전/제육/갈비찜/순두부)은 post-launch M1~M2 후보로 격리.
- **왜**: ADR-003 MVP scope 안에서 사용자가 인지도·글로벌 어필·다점포 메커닉 활용도 기준으로 reshuffle. 어물전 floor(해물파전), 시각 임팩트(갈비구이), 글로벌 viral(콘도그·양념치킨) 우선.
- **결과/다음 단계**:
  - **5건 재검증 결과** (game-designer): 3건 STRONG ACCEPT (호떡 / 해물파전 / 갈비구이), 1건 ACCEPT (잡채), **2건 ACCEPT WITH CONCERN**:
    - **C-1 콘도그**: viral 강함, 단 분식·길거리 비중 4/7로 전통 한식 톤 약화. Alt = 계란찜(잡화 중심).
    - **C-2 양념치킨**: 글로벌 KFC 강점, 단 T2 어물전 부재(T2 음식 5개 모두 어물전 0). Alt = 순두부찌개 회귀.
  - **가게별 등장 분포 최종**: 청과 10 / 정육 8 / **어물 4 (floor 마지노선)** / 곡물 10 / 잡화 12. 해물파전 단독이 어물전 SKU 다양성의 50% 책임 → post-launch M1 어물 음식(된장찌개·순두부) 1순위.
  - **5가게 풀 순회 음식 축소** (떡국 제거로 김밥 단독) → post-launch M1 떡국 부활 권고.
  - **U-1 재권고 (FTUE 첫 음식)**: 계란말이 삭제로 **호떡** 1순위 (곡물+잡화 2가게 / 굽기 단순 / 시각 5/5). 라면 2순위. → ui-designer `ftue.md` 갱신 필요.
  - **U-2 결정 (가족 unlock)**: **어머니/아버지 L11 동시 unlock** 권고 (정서 임팩트 + reaction anchor 6컷 sleeping 회피). → ui-designer `tier-1-2-flow.md` 양친 동시 컷씬으로 갱신 필요.
  - **사용자 confirm 필요 신규 4건**: C-1 콘도그 vs 계란찜 / C-2 양념치킨 vs 순두부찌개 회귀 / C-3 해물파전 flip mechanic 도입 여부 / C-4 Stage 3 good/miss 30/60 vs 45/45.
  - **다음 sprint 이월**: 갈비구이 PERFECT window alpha 튜닝(0.04→0.05~0.08), 친구 호불호 ±5% 가중치 alpha 튜닝, ui-designer FTUE/Tier flow 갱신, unity-dev `FriendDefinition` SO schema 구현, pm ADR-004 후보(양친 가족 단위 + 호불호 5 axis lock).

---

## [2026-05-23] M0 ui-designer sprint — screen-flow / Tier 1~2 flow / FTUE / components
- **무엇**: `docs/ui/` 4종 신설.
  - `screen-flow.md` — 부트 → Round 3-Scene(시장→키친→식탁) 전이도, Scene 1 다점포 sub-flow(2×3 부채꼴 그리드), Scene 2 키친, Scene 3 식탁(T1 혼밥 / T2 가족), 광고·사운드 hook overlay, Decisions 6항.
  - `tier-1-2-flow.md` — Tier 1 vs Tier 2 비교 매트릭스(인분·식탁·광고 빈도·카피 톤), 어머니/아버지 unlock 타이밍 권고.
  - `ftue.md` — 4-step (단일 가게 → 2가게 → 키친 → 식탁), 다점포 안내 반복 정책(FTUE Step 2 강제 1회 + Round 2 미세 hint 1회 + 5가게 풀 순회 음식 첫 등장 시 ⓘ), Skip 정책, 친구 unlock과 FTUE 분리.
  - `components.md` — 15종 컴포넌트 카탈로그(재료카드·가게선반·시장입구·키친도구슬롯·식탁캐릭터영역·★rating·타이머·HUD·Hint 등), 상태별 spec + art-style 톤 매핑 + sound hook 위치.
- **왜**: ADR-003 M0 작업 3건(screen-flow + Tier 1~2 + FTUE)을 한 sprint로 묶어 art/음식 trace와 독립 진행. `components.md`는 screen-flow/tier/ftue가 참조하는 SSOT + Unity prefab 1:1 매핑 의도로 분리.
- **결과/다음 단계**:
  - **사용자/pm/game-designer confirm 필요** (ui-designer flag):
    - **U-1 (game-designer)**: **FTUE 첫 음식 계란말이 vs 라면** — 권고 계란말이(2가게 최소 + 시각 매력 + 굽기 단일 메타포). 라면은 3가게라 Step 2/Round 2 후순위.
    - **U-2 (game-designer)**: **아버지 unlock 시점 L11 동시 vs L15 분리** — 권고 L15 분리(Tier 2 중반 신선도 갱신).
    - **U-3 (pm)**: **라이프 시스템 사용 여부** — HUD 컴포넌트 영향. 결정 시 components.md 갱신.
    - U-4 (사용자, 보조): Tier 2 식탁 카피 톤 placeholder 검토.
  - **다음 sprint 이월**: 정확한 px/dp 수치(unity-dev sync), balance-config.md 수치(타이머/PERFECT 폭) 후 컴포넌트 재검토, sound hook 정식 ID 명명(sound-guide.md M2~M3), Tier 2 카피 톤 lock, FTUE Round 2 미세 hint 횟수 확정, Settings "튜토리얼 다시 보기" 옵션 노출 여부.

---

## [2026-05-23] M0 sprint 착수 — MJ Standard 결제 완료 + art-director / game-designer 병렬 1차 산출
- **무엇**:
  - **MJ Standard Plan 결제 완료** (사용자 확인). Suno Pro 보류 유지(M2~M3).
  - **art-director** v0.1 산출 2종 신설:
    - `docs/art-style-guide.md` — 마스코트 톤 정의("라인프렌즈 친근함 + Cookie Run 식감 + 재래시장 손맛"), 비율 1:1.5~2 / mitten 손 / 점 눈 / 분홍 볼터치, 늦오후 골든아워 단일 조명 lock, 가게 5종 시그니처 컬러, MJ 약점 회피 규칙, **Week 1 anchor lock 게이트 체크리스트(7항)** 포함.
    - `docs/prompts-library.md` — **캐릭터 5 + 환경 5 anchor 프롬프트 세트**. **캐릭터=niji 6** (chibi 안전구역), **환경=v6.1** (한국 재래시장 텍스처), 공유 `--sref` 운영 규칙. 음식·재료·UI·VFX 프롬프트는 §5~6에 placeholder만(다음 sprint).
  - **game-designer** v1.0 산출 신설:
    - `docs/systems/mvp-food-selection.md` — **MVP 음식 12개 권고**: Tier 1 7개(라면/계란말이/김밥/떡볶이/떡국/김치볶음밥/김치전), Tier 2 5개(비빔밥/김치찌개/제육볶음/갈비찜/순두부찌개). 5가게 등장 매트릭스(청과 12 / 정육 7 / 어물 4 floor / 곡물 7 / 잡화 11), 난이도 4-step 곡선, post-launch 대안 후보(잡채·불고기·된장찌개·잔치국수→M1~M2 / 닭볶음탕·삼겹살→M3~M4).
- **왜**: ADR-003 즉시 액션 2종(art anchor + 음식 권고)을 병렬 실행. 두 작업이 독립적이고 M0 게이트의 prerequisite.
- **결과/다음 단계**:
  - **사용자 결정 필요 2건** (game-designer flag):
    - **D-1**: Tier 1에서 **김치전 유지 vs 된장찌개 교체** — 권고 유지, 단 된장찌개로 가면 어물전 floor 4→5로 메커닉 안정도 ↑.
    - **D-2**: Tier 2 **순두부찌개 유지 vs 부대찌개 교체** — 권고 유지. 부대찌개는 어물전 0회라 다점포 메커닉 깨짐 → 부대찌개는 Tier 3 친구 초대(post-launch)로 자연 이동 권고.
  - **Week 1 anchor lock 게이트 운영 필요** — art-director가 정의한 7항 체크리스트로 anchor 후보 평가. 게이트 통과 전까지 파생 자산 작업 금지.
  - **다음 sprint 이월**: 음식 12개 anchor 프롬프트(art, food 확정 후), 재료/UI/VFX 프롬프트, `balance-config.md`(수치), `foods-database.csv` + `ingredients-database.csv` 실데이터, 친구 1~2명 personality(가족 단위), FTUE 첫 음식(ui-designer 협업), `screen-flow.md`(ui-designer M0).

---

## [2026-05-23] ADR-003: MVP-first 전환 (supersedes ADR-002). 음식 10~15개, Tier 1~2, 친구 1~2명. 3~4개월 출시 후 점진 확대.
- **무엇**:
  - `docs/decisions.md` — ADR-002 상태 → **Superseded by ADR-003**. ADR-003 (Accepted) 신규 기록. ADR-002의 결정 #1·2·3·5(외주 X / Asset Store / AI / 마스코트)는 유지, #4(full feature 8~12개월)만 반전.
  - `docs/GDD.md` §4 — Tier 표에 "MVP 포함?" 열 추가 (Tier 1·2 MVP, 3~5 post-launch M3~M6). §9 — full feature → MVP scope(음식 10~15, Tier 1~2, 친구 1~2, 식탁 2종, 다점포 5가게 유지, 광고 Affiliate만, IAP Remove+Coin). §10 — Roadmap을 3~4개월 pre-launch + 12개월 LiveOps로 재작성.
  - `docs/art-workload-estimate.md` v2.0 → **v3.0**: ~228h → **~80h M1 sprint** (3~4주). 카테고리별 재계산 (Scene 1 33h / Scene 2 9h / Scene 3 4h / 캐릭터 12h / 음식 6h / 재료 8h / UI·VFX 6h). 사운드 M2~M3 deferred. §7 Post-Launch Backlog 신설(Month 1~12 누적 ~310h).
  - `docs/systems/cooking-mechanics.md` v0.3 → **v0.4**: §0에 MVP Scope callout. 5-tier 디자인 비전·다점포 5가게 메커닉 정의는 변경 없음, 콘텐츠 양만 축소.
- **왜**: ADR-002 채택 직후 사용자 재평가 — 8~12개월 1인 sprint의 burnout 리스크 + 시장 검증 없는 장기 투자 회피. MVP-first로 실데이터 기반 점진 확대. 같은 날 reversal이지만 flip-flop이 아닌 reality check.
- **결과/다음 단계**:
  - **즉시 액션 변경분**: Suno Pro 결제 **보류**(M2~M3로 이동), game-designer 1순위 **MVP 음식 12개 선정 권고**(balance-config.md 아님), art-director는 변경 없음(anchor 작업 그대로).
  - **신규 리스크 R-A11**: post-launch 콘텐츠 production 지속력 → **dual-track 권장** (M2~M3 동안 Tier 3 자산 40% pre-production).
  - **신규 리스크 R-A12**: MVP 콘텐츠 빈약 인상 → ASO/스크린샷 강화 + "지속 업데이트" 메시징.
  - **현금 예산 절감**: $340~540 → **$170~270** (MVP 4개월).

---

## [2026-05-23] ADR-002 채택: 자체 제작 + Asset Store/AI 도구 + full feature + 마스코트 스타일. MVP 일정 8~12개월.
- **무엇**:
  - `docs/decisions.md` 신설 + **ADR-002 기록** (Status: Accepted). ADR-001은 재래시장 다점포 결정 backfill 후보로만 표시.
  - `docs/GDD.md` §9 MVP Scope 전면 확대 (Tier 1~5 full, 음식 50개, 친구 5명 full, Scene 3 tier 5종, 파티 모드 포함). §10 Roadmap을 M0~M3 milestone 구조로 재작성 (8~12개월).
  - `docs/art-workload-estimate.md` v1.0 → **v2.0**: 외주 제거, 자체 제작 + 마스코트 캐릭터, 워크로드 ~70h → ~200~260h 재계산, MJ anchor 2종(캐릭터+환경) 듀얼 운영, Suno BGM + Asset Store 구매 리스트, 10 risk register, M0 anchor lock 게이트.
- **왜**: 사용자가 v1.0 권장(외주 $1.5k~4k) 대안으로 5가지 제약·선호 제시 — 외주 X, AI/Asset Store O, full feature 유지, 일정 연장 수용, 마스코트 스타일. 비가역·고비용 결정이라 ADR로 정식 기록.
- **결과/다음 단계**:
  - **즉시**: MJ Standard Plan + Suno Pro 결제, 캐릭터/환경 anchor 각 5장 생성, M0 Week 1~2 anchor lock 게이트 운영.
  - **병렬 진행 (M0)**: game-designer가 친구 5명 personality + 호불호 시스템 디자인 (캐릭터 anchor 작업 prerequisite). ui-designer가 다점포 screen-flow 작성 (art와 독립).
  - **art-director 후속 문서**: `docs/art-style-guide.md`, `docs/prompts-library.md` 신설 필요.
  - **balance-config.md 미존재** — 친구 호불호 시스템 디자인이 마스코트 스타일과 맞물려야 하므로 game-designer 호출 시 1순위로 작성.
  - **M0 종료 시 reality check 게이트** — 일정 ±20% 초과 시 ADR 신규 작성 + scope 재조정.

---

## [2026-05-23] Art workload estimate v1.0 — Scene 1 재래시장
- **무엇**: `docs/art-workload-estimate.md` 신설 (art-director 대행). Scene 1 워크로드 정량화(BG 11 + 숨은 ~50 item), tier 변화 옵션 A/B/C 비교, Midjourney consistency 전략 (style anchor + `--sref`/`--niji 6`/prompt template), 비주얼 톤 결정(따뜻한 일러스트 Ghibli-ish + K-touch), 옵션별 production 시간(A: ~70h, B: ~80h, C: ~145h), 8 risk + 외주/구매 권장 분리($1.5k~4k).
- **왜**: 직전 다점포 메커닉 결정으로 art 워크로드 6배 증가 flag — pm 의사결정·일정 산정 위해 정량 근거 필요. 사용자의 "11컷"이 백그라운드만임을 명확히 하여 재료 카드/UI/VFX 등 숨은 워크로드 노출.
- **결과/다음 단계**:
  - **권장: Option A (단일 비주얼) + 4-5주 sprint**.
  - **즉시 액션**: MJ Standard Plan 결제, 친구 캐릭터 외주 발주(3-4주 리드타임), style anchor 후보 3~5장 생성, Week 1 anchor 게이트 통과 필수.
  - **외주 분리 명시**: 친구 5명 캐릭터 + reaction은 MJ 약점 → 외주($1.5k~4k).
  - prompts-library.md, art-style-guide.md, sound-guide.md 후속 생성 필요 (art-director 1순위).

---

## [2026-05-23] open question 12개 일괄 resolve + 재래시장 다점포 메커닉 확정
- **무엇**:
  - `docs/systems/cooking-mechanics.md` v0.2 → **v0.3**: §10 12개 open question 일괄 결정 — game-designer 권장 default 그대로 채택.
  - #9 수퍼마켓 톤 → **재래시장 + 다점포 순회**로 확정. Scene 1을 가게 5종(🥬 청과 / 🥩 정육 / 🐟 어물 / 🌾 곡물 / 🫙 잡화) 순회 메커닉으로 §2 전면 재작성.
  - §8에 `Ingredient.category → store_type` 매핑 + 다점포 디스트랙터 알고리즘 의사코드.
  - §9 Remote Config 키 `distractor_count_by_tier` → `distractor_per_store_by_tier` 변경 (가게당 카운트).
  - §10.2에 다점포 파생 follow-up 7항 신설 (간판 시인성, 빈 가게 페널티, 튜토리얼 안내, 사운드 hook 등).
  - `docs/GDD.md` §2 Stage 2 sync (🛒 수퍼마켓 → 🏪 재래시장 + 가게 5종 명시).
- **왜**: 12개 결정을 게임플레이/아트/UX 영역으로 분류해 일괄 처리 — 컨텍스트 분산 방지. 재래시장 다점포는 K-stylistic 차별화 + 공간 기억 학습이라는 자연 progression 메커닉을 추가로 확보.
- **결과/다음 단계**:
  - **아트 워크로드 6배 flag**: Scene 1 = 가게 5컷 + 입구 1컷 (이전 단일 수퍼 1컷 대비). art-director Phase 2 최우선 가늠 대상.
  - **사운드 hook 확장**: 가게별 ambient(정육 칼질/어물 얼음/청과 인사) sound-guide.md 신설 시 반영.
  - **ftue.md 신설 필요**: 튜토리얼 4-step + 다점포 안내 횟수 → ui-designer 호출 시 1순위.
  - 잡화점 post-launch 분할(양념가게+잡화점) 마이그레이션 시 Remote Config 기반 store_type 재맵핑 가능하도록 설계 권장.

---

## [2026-05-23] Round 3-scene 구조 확정 — 수퍼마켓 → 키친 → 식탁
- **무엇**:
  - `docs/systems/cooking-mechanics.md` v0.1 → **v0.2**: Round 다이어그램을 3-scene로 재작성, Stage 1(수퍼마켓)/Stage 2·3(키친) UI에 scene 컨텍스트와 메타포(매대·장바구니·도마·가스레인지) 명시, §5.1 식탁 화면 신설(캐릭터 시식 연출, tier별 식탁 = GDD §4 progression과 1:1 매핑, 친구 선호도 시각 반응). open questions 6항 추가.
  - `docs/GDD.md` §2 Core Loop 한 줄로 sync (scene 이모지 + cooking-mechanics 참조).
- **왜**: 사용자가 각 Stage의 공간 컨텍스트(수퍼마켓/키친/식탁) 결정. GDD §4 사회적 progression(혼밥→파티)이 Scene 3 식탁 인원 변화로 비주얼 표현되는 자연스러운 연결고리 확보 — 정서적 arc가 매 Round마다 발화.
- **결과/다음 단계**:
  - **아트 워크로드 증가** flag: Scene 3 식탁 5종(tier) × 캐릭터 시식 reaction(★1/2/3 × 친구 5명) — art-director 호출 시 최우선 가늠 필요.
  - Scene 1·2 tier별 일러스트 변화는 미정(워크로드 vs 효용).
  - Scene 트랜지션 사양(애니메이션·스킵 옵션)은 ui-designer territory.
  - 수퍼마켓 디자인 톤(모던 마트 vs 재래시장) 미정 — art-director 결정 사항.

---

## [2026-05-23] GDD v2.0 — pm 관점 4개 섹션 신설
- **무엇**: `docs/GDD.md` v1.0 → **v2.0** 증분 개정. §11 Success Metrics/KPI(D1/D7/D30, ARPDAU, FTUE, gameplay health, 필수 분석 이벤트), §12 Dependencies(외부 계정 6종 + 라이선스 + 기술 스택), §13 Risks 10개(영향·가능성·완화안 매트릭스), §14 Go/No-Go 판정 기준(품질/수익화/법무 hard gates + conditional). 부록에 변경 이력 추가.
- **왜**: 사용자가 pm role 위임. 기존 GDD는 디자인 중심이라 pm이 출시 판정·리스크 관리·KPI 추적을 할 근거가 없었음. 메인 스레드가 pm mandate에 따라 대행 (다음 세션부터 pm sub-agent로 이관).
- **결과/다음 단계**: KPI 목표 수치는 캐주얼 모바일 게임 벤치마크 기반 — 실제 출시 후 1~2주 데이터로 재보정 필요. Go/No-Go gates를 release checklist로 분리 운영 권장(`docs/release-checklist.md` 후보).

---

## [2026-05-23] game-designer 소유 경로 정정 — cooking-mechanics.md
- **무엇**: `.claude/agents/game-designer.md`와 `docs/agent-roster.md`에서 game-designer가 소유하는 mechanics 문서 경로를 가상의 `docs/mechanics-spec.md`에서 **실제 존재하는 `docs/systems/cooking-mechanics.md`**로 정정.
- **왜**: PM 검증에서 명명 충돌 발견. 정정하지 않으면 다음 세션에서 game-designer 첫 호출 시 기존 cooking-mechanics.md를 무시하고 mechanics-spec.md를 새로 만들 위험.
- **결과/다음 단계**: 정식 GO. 세션 재시작 시 실제 sub-agent 위임 가능.

---

## [2026-05-23] Sub-agent 팀 구조 도입 — 9 agents
- **무엇**: `.claude/agents/` 폴더에 9개 agent 정의 (pm, game-designer, unity-dev, backend-dev, ui-designer, qa-tester / Phase 2: art-director, marketing, data-analyst). `docs/agent-roster.md` 요약표 + 위임 가이드 작성. `CLAUDE.md`에 Sub-Agent Team 섹션 추가.
- **왜**: 작업 책임 분리 및 위임 규칙 명문화. MVP 6 agents + Post-MVP 3 agents로 phase별 활성화.
- **결과/다음 단계**: 이후 모든 작업은 agent-roster.md 위임 가이드 기준으로 분배. 각 agent의 본문은 현재 1줄 요약 수준 — 운영 중 실제 워크플로우 확정되면 상세화 필요.

---

## [2026-05-23] 프로젝트명 "K-Food Master" 확정 + 잔존 "merge" 정리
- **무엇**:
  - 프로젝트명을 가칭 "K-Food Merge" → **"K-Food Master"** 로 확정.
  - `CLAUDE.md` 헤더·프로젝트명·번들 ID(`com.{studio}.kfoodmaster`).
  - `docs/GDD.md` 헤더 ("내부 코드네임" 표기 제거).
  - `build/README.md` 파일명 규칙 (`kfoodmerge-*` → `kfoodmaster-*`, 3건).
  - `unity-project/README.md` Gameplay 설명 (`merge 로직, 보드, 아이템` → `cooking 3단계 루프(재료/방법/타이밍), 채점`).
  - `CHANGELOG.md` 헤더 문구.
- **왜**: 디자인이 merge가 아닌 cooking matching으로 확정됨에 따라 명명 일관성 확보. 향후 빌드/스토어 등록/번들 ID 발급 전에 정리해야 변경 비용 최소.
- **결과/다음 단계**:
  - 잔존 "merge" 의도적으로 유지: `research/README.md` 경쟁작명(Merge Mansion 등 실제 게임), CHANGELOG 과거 항목(historical).
  - 스튜디오 결정 시 번들 ID `com.{studio}.kfoodmaster`에서 `{studio}` 부분 확정 필요.
  - 폴더명 `kfood-game`은 OS 경로라 유지.

---

## [2026-05-23] cooking-mechanics.md v0.1 + "merge" 표현 정정
- **무엇**: `docs/systems/cooking-mechanics.md` v0.1 작성 — Stage 1/2/3 룰, 채점 공식(곱셈 모델), 디스트랙터 알고리즘, Stage 3 PERFECT 구간 너비, Hint 트리거, Remote Config 키 7종, edge case 7개.
  - 부수 정정: `CLAUDE.md` 컨셉/장르 ("merge" → "cooking matching"), `docs/README.md` 예시 ("merge 시스템" / "merge-mechanics.md" → "cooking matching" / "cooking-mechanics.md").
- **왜**: 초기 부트스트랩 시 사용된 "merge" 명명이 이후 GDD에서 정의된 cooking matching 메커닉과 충돌. 신규 문서 작성 전 명명 정합성 확보.
- **결과/다음 단계**:
  - 미정정 잔존 "merge" — 손대지 않음: 프로젝트명 `K-Food Merge (가칭)` (이미 가칭으로 표시됨), `unity-project/README.md`의 "merge 로직" 예시 (사용자 확인 후), `build/` 번들 ID `kfoodmerge` (프로젝트명 derive), `research/README.md`의 경쟁작명 (Merge Mansion 등 실제 게임명), CHANGELOG 과거 항목 (historical).
  - 프로젝트명 자체를 "K-Food Master"로 확정할지 결정 필요 (GDD는 이미 내부 코드네임으로 사용 중).

---

## [2026-05-23] GDD 정합성 sync — Section 1·8 + 부록 follow-up
- **무엇**:
  - Section 1 Concept 한 줄을 "3-stream 수익 모델" 표현으로 갱신, §5 참조 추가.
  - Section 8 Tech Stack에 Firebase **Cloud Functions** (Stream B 백엔드), **Google Places API**, **카카오맵 API**(검토), **Amazon Associates / 쿠팡 Partners**(affiliate) 추가. 기존 항목은 Stream A/B/C 라벨링.
  - 부록 follow-up을 게임플레이 / Stream A / Stream B / Stream C 4개 그룹으로 재정렬. Store Ads 관련 6개 항목 신규 추가 (Amazon·쿠팡 계정, Cloud Functions 스펙, Places 쿼터, 카카오맵 결정, Privacy Policy, Disclosure UX).
- **왜**: 직전 Monetization 재구조화로 다른 섹션과 어긋남 발생. 누락 시 향후 작업이 outdated 컨셉/스택 기준으로 진행될 위험.
- **결과/다음 단계**: GDD 전체 일관성 회복. Stream B 신규 follow-up은 별도 작업 큐로 분리 가능.

---

## [2026-05-23] Monetization 듀얼 광고 stream 추가 — Store Ads (affiliate + sponsored)
- **무엇**: GDD Section 5 재구조화. 단일 "광고+IAP" → **3 streams** (A: AppLovin 프로그래매틱 / B: 한식 매장 affiliate·sponsored / C: IAP). Firebase Functions 백엔드 기반 동적 affiliate 링크 아키텍처.
- **왜**: 게임 테마(한식)와 직접 연관된 affiliate/sponsored 수익원 확보. UX 친화적이며 long-tail 수익 잠재력 (성숙기 +$3K/월).
- **결과/다음 단계**: Section 1·8 사용자 확인 후 sync 필요 (Concept 문구·Tech Stack에 Firebase Functions). Amazon Associates / 쿠팡 Partners 계정 신청, 매장 매칭 백엔드 스펙 작성 필요.

---

## [2026-05-23] GDD Section 4 progression 표 확정
- **무엇**: Section 4 5-tier 표를 확정본으로 교체 (레벨 범위/인분/음식 예시/사회적 컨텍스트/광고 트리거 컬럼). tier 진입 시 친구 1명 unlock 규칙 및 Tier 5 post-launch 분리 명시.
- **왜**: GDD v1.0 작성 시 누락됐던 사용자 원본 표 수신.
- **결과/다음 단계**: 부록 follow-up에서 "원본 표 교체 필요" 항목 제거. Tier별 친구 5명 캐스팅 follow-up 신규 추가.

---

## [2026-05-23] GDD v1.0 작성
- **무엇**: `docs/GDD.md` 작성 — concept, core loop, scoring, 5-tier progression, monetization(광고+IAP), data structure, tech stack, MVP scope, 6개월 로드맵
- **왜**: 핵심 기획 합의 및 향후 모든 시스템 작업의 기준점 확보
- **결과/다음 단계**: Section 4 progression 표는 사용자 원본 표 누락 → 컨셉 기반 초안 삽입, 확정본 들어오면 교체. 부록 follow-up 항목 5개 별도 추적.

---

## [2026-05-23] 프로젝트 부트스트랩
- **무엇**: 리포지토리 초기 구조 생성
  - `CLAUDE.md` — 프로젝트 헌법(컨셉, 수익모델, 컨벤션, 빌드 정책)
  - 폴더 7종: `docs/`, `unity-project/`, `assets-raw/`, `assets-processed/`, `marketing/`, `research/`, `build/`
  - 각 폴더 `README.md` 작성
  - `.gitignore` — Unity 표준 + Windows OS + 주요 IDE(Visual Studio, Rider, VS Code) + 시크릿
  - `CHANGELOG.md` (이 파일)
- **왜**: 한식 테마 캐주얼 merge 게임 프로젝트 시작. Claude가 향후 일관된 컨텍스트로 작업하도록 헌법/구조 선제 정의.
- **결과/다음 단계**:
  - [ ] Unity Hub로 `unity-project/`에 Unity 2022 LTS 2D 템플릿 생성
  - [ ] git 저장소 초기화 + 첫 커밋 (`git init && git add . && git commit -m "chore: bootstrap project structure"`)
  - [ ] `docs/gdd.md` 초안 작성 (핵심 루프, merge tier 정의, 한식 아이템 트리)
  - [ ] AppLovin MAX 계정 생성 + Android SDK 키 발급
  - [ ] 경쟁작 1차 분석 (Merge Mansion, Travel Town) → `research/competitors/`

---

<!-- 아래 형식 예시 (지우지 말 것)
## [2026-MM-DD] 예: merge 코어 로직 1차 구현
- **무엇**: 같은 tier 두 아이템 드래그 시 다음 tier 생성, 보드 9칸 그리드
- **왜**: 핵심 루프 검증 (clickability + 만족감)
- **결과/다음 단계**: `Assets/Scripts/Gameplay/MergeBoard.cs` 추가, 다음은 SO 기반 아이템 데이터 분리
-->
