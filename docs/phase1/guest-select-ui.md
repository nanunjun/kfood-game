# Guest Select UI v1 — choose who you cook for (M1+)

> 메뉴 선택 후 손님 선택 화면 추가 → 내러티브 깊이. `guest_select.gd` + `scenes/guest_select.tscn`. English-first, 한국어 부제. 연동: `economy-save-v1`(친밀도), `round-system-v3`, `levels-v1`(evaluator).

## 1. 플로우
```
menu_select → (evaluator level? → 바로 round) / (else → guest_select) → round → result → menu_select
```
- 일반 레벨: 메뉴 카드 "Cook" → `guest_select`(손님 선택) → 라운드.
- evaluator 레벨(L3/5/8): 손님 선택 **건너뛰고** 바로 라운드(평가자 자동 등장).

## 2. UI
- 제목: "Who are you cooking {Menu} for?"
- 상단 바: **Auto Select ({default guest})** — 메뉴 디폴트 손님으로 즉시 진행. **‹ Back** — 그리드로.
- 손님 카드 그리드(2열, `MenuDB.selectable_guest_ids()` = 친구5 + 멘토1, evaluator 제외):
  - **아바타**(placeholder): 손님별 고정 톤 원형 + 이니셜(아트 들어오면 풀바디로 스왑).
  - 이름(EN, 한국식 이름 그대로 = 문화적 매력).
  - **동적 미각 힌트**: 손님 dominant axis 기반 자연어("They prefer bold spicy heat today." / 멘토는 "She prefers…"). 숫자 비노출.
  - **친밀도**: "Friendship ★★★☆☆"(floor(intimacy), 0~5). 숫자 X.
  - "Cook for {name}" 버튼 → `RhythmRound.pending_guest_id = gid`.

## 3. 라운드 통합
- 선택 손님의 vec·tol·대사로 라운드 진행(`pending_guest_id`, 라운드 시작 시 소비). evaluator 레벨이면 무시(평가자 우선).
- 결과 후 친밀도 변동(`economy-save-v1 §4`): 만족(S≥0.80) +1 / 보통 +0 / 불만 −0.5. (evaluator는 친밀도 미적용.)
- 친밀도 임계 효과(예: Junho max → "I'll bring my friends" 다인 디너 떡밥)는 **Phase 2**. Phase 1은 표시 + 누적까지.

## 4. 아트 (placeholder → 스왑)
- 현재: 톤 원형 + 이니셜. 목표: `image_prompts_phase1 §A`의 친구 5 + 멘서 풀바디/표정 3종.
- 인테이크 후 `art/.../npc`에서 로드하도록 카드 아바타 교체(파일명 규칙은 art ingest 가이드).
- 등장 모션(fade-in + 시그니처 입장 대사)은 라운드 request 페이즈에서 이미 처리(손님 발화). 선택 화면은 정적 카드.

## 5. 검증
- 일반 메뉴 → guest_select 표시 → 손님 선택/Auto/Back 동작.
- evaluator 레벨 메뉴 → guest_select 스킵, 평가자 등장.
- 결과 후 친밀도 ★ 갱신(재진입 시 반영).
- preflight PASS.

## A/B
- **[A/B] 손님 해금**: A=친구5 전원 Phase 1 개방(디폴트) / B=레벨별 점진 해금. 디폴트 A.
- **[A/B] 친밀도 표시**: A=★(디폴트, stars 재사용) / B=하트 아이콘(아트 필요). 디폴트 A.
