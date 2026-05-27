# Art Workload Estimate — K-Food Master MVP

> 버전: **v3.1 (2026-05-26, supersedes v3.0)** — [ADR-005](decisions.md#adr-005) 4-stage 메커닉 추가 영향 반영 (placeholder).
> 작성: 2026-05-23 · 최종 개정: 2026-05-26 (ADR-005 영향 placeholder; art-style reset 보류 중이라 정확 산정은 lock 후)
> 근거: [`decisions.md` ADR-003](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002), [`decisions.md` ADR-005](decisions.md#adr-005) / [`GDD.md`](GDD.md) §9 §10 / [`systems/cooking-mechanics.md`](systems/cooking-mechanics.md) §2.2 §2A
> 작성자: art-director (메인 스레드 대행) · 대상: pm, godot-dev, game-designer

---

## 0. Executive Summary

> 🎯 **방침 (ADR-003 채택)**: ADR-002 결정 #1·2·3·5 유지 + **MVP-first 전환** (음식 10~15개, Tier 1~2, 친구 1~2명, Scene 3 2종)
> 🆕 **ADR-005 (2026-05-26)**: 4-stage 메커닉 추가 — 칼/도마 + cut style 애니메이션(6종) + hero ingredient cut variation 신규 발주 필요. **+20~25h (사용자 추정) / +25~35h (pm reality check)** placeholder. **art-director 작업은 art-style reset 보류 중이라 BLOCKED — lock 후 정확 산정**.
>
> **순 art 작업 시간 ~80h (M1 sprint) + ADR-005 추가 ~25~35h (pm) → ~100~115h MVP (pm 추정)**. 사용자 추정 시 ~100~105h.

| 항목 | 추정 |
|------|------|
| **M1 art sprint (v3.0 baseline)** | **~80h** (범위 ~75~110h, §4.2 리스크 케이스) |
| **ADR-005 추가 (v3.1, placeholder)** | **+25~35h (pm) / +20~25h (사용자)** — art-style lock 후 정확 산정 |
| **M1 art sprint (v3.1 total, pm)** | **~100~115h** |
| **M0 사전 작업 (anchor lock)** | ~10~16h |
| **M1 sprint 일정** | **3~4주** (v3.0) + **+1~3주** (ADR-005, 사용자 1주 / pm 2~3주) = **4~7주** |
| **현금 예산** | MJ Standard $30/월 × 4개월(MVP) = ~$120 + engine-agnostic asset 소스(Flaticon/Pond5/Freesound 등) ~$50~150 = **~$170~270** (ADR-005 영향 미미 — MJ 비용은 anchor 재활용으로 흡수) |
| **외주 비용** | $0 |
| **사운드** | M2~M3로 deferred (Suno Pro 결제 보류) — **ADR-005 영향: M2에 minimum 1~2주 sound 작업 추가 (BPM 메트로놈 + 칼질 SFX). 전체 사운드 deferred는 유지.** |

### 0.1 ADR-005 추가 작업 항목 (v3.1 placeholder, art-style lock 후 정확 산정)

| 항목 | 수량 | 단위 시간 (pm 추정) | 소계 |
|------|------|--------------------|------|
| 칼/도마 art 1 set (raw + slicing 모션 base) | 1 set | ~3~4h | ~3~4h |
| Cut style별 애니메이션 (3~4 frames × 6 cut style) | 18~24 frames | ~0.5~0.7h | ~9~17h |
| Hero ingredient cut variation (raw + cut 2종, 12 음식 × 1~2 hero) | ~24 sprites | ~0.4h | ~10h |
| 마스코트 simpler style 재작업 가능성 (cut 모션 호환) | placeholder | ~3~4h | ~3~4h |
| **ADR-005 추가 합계 (pm)** | | | **~25~35h** |
| **ADR-005 추가 합계 (사용자)** | | | **~20~25h** |

> ⚠️ **art-director 작업은 R-A14 BLOCKED on art-style reset**. 현재 reference 결정 보류 중. 정확 산정은 art-style lock 후 진입. 위 수치는 ADR-005 사용자 명시 추정 + pm cross-check 결과 placeholder.

---

## 1. MVP Asset Inventory (ADR-003 scope)

### 1.1 Scene 1 — 재래시장 다점포 (변경 없음, 핵심 차별점)
| 항목 | 수량 | 비고 |
|------|------|------|
| 재래시장 입구 배경 | 1 | |
| 가게 5종 외관 | 5 | 청과/정육/어물/곡물/잡화 |
| 가게 5종 내부 매대 | 5 | |
| **Scene 1 배경 소계** | **11** | **MVP 유지 (깎지 않음)** |

### 1.2 Scene 2 — 키친
| 항목 | 수량 | 비고 |
|------|------|------|
| 키친 배경 | 1 | tier 무관 단일 |
| 조리도구 일러스트 | 4~5 | 가스레인지/오븐/찜기/팬 |

### 1.3 Scene 3 — 식탁 (Tier 1·2만 = ADR-003)
| 항목 | 수량 | 비고 |
|------|------|------|
| Tier 1 식탁 (혼밥) | 1 | |
| Tier 2 식탁 (가족) | 1 | |
| **소계** | **2** | (이전 v2.0: 5종) |

### 1.4 친구 캐릭터 (마스코트, 1~2명)
| 항목 | 수량 | 비고 |
|------|------|------|
| 친구 캐릭터 디자인 (정면 + 측면 + 표정) | 2 | 가족 단위 — 어머니/아버지 등 |
| ★ Reaction 애니메이션 컷 | 2명 × ★3 = **6** | (이전 v2.0: 15컷) |

### 1.5 콘텐츠 일러스트
| 항목 | 수량 | 비고 |
|------|------|------|
| 음식 일러스트 (요리 카드) | **12** | game-designer 권고 후 확정 (10~15 범위) |
| 재료 카드 일러스트 | ~20 | 음식 12개 등장 재료 (재사용률 ~3:1) |

### 1.6 UI / VFX / 트랜지션
| 항목 | 수량 | 비고 |
|------|------|------|
| UI 일러스트 (장바구니, 메모지, 간판 5종) | 7 | |
| VFX (픽업 빛, 빨간 shake, 타이머 펄스) | 4~5 | 간소화 |
| 트랜지션 시퀀스 | 3 | 입구→가게, 시장→키친, 키친→식탁 |

### 1.7 사운드 — M2~M3로 deferred
| 항목 | 수량 | M1 시점 |
|------|------|---------|
| BGM 트랙 | 1~2 (Suno) | ⏸ M2~M3 |
| SFX 라이브러리 | 15~20 | ⏸ M2~M3 (engine-agnostic 소스 일괄 구매 — Pond5 / Freesound / Zapsplat 등) |

### 1.8 총합 (M1 sprint 기준, 사운드 제외)

| 카테고리 | item 수 |
|---------|---------|
| Scene 1 배경 | 11 |
| Scene 2 (배경 + 조리도구) | 5~6 |
| Scene 3 식탁 (Tier 1·2) | 2 |
| 친구 캐릭터 + reaction | 2 + 6 = 8 |
| 음식 + 재료 카드 | 12 + 20 = 32 |
| UI + VFX + 트랜지션 | 14~15 |
| **MVP M1 총 item** | **~72~74** |

---

## 2. Tier 변화 정책 (ADR-003 반영)

| Scene | MVP Tier 변화 | Post-launch |
|-------|--------------|-------------|
| Scene 1 (재래시장) | **단일** (5가게 유지) | 변경 없음 |
| Scene 2 (키친) | **단일** | 변경 없음 |
| Scene 3 (식탁) | **2종** (Tier 1·2) | +3종 (Tier 3·4·5) 추가 |

---

## 3. Midjourney Consistency 전략 (v2.0과 동일, scope만 축소)

ADR-003은 **art 스타일 결정에 영향 없음**. 마스코트 + 재래시장 듀얼 anchor 운영 유지.

### 3.1 Anchor 2종 (v2.0과 동일)
- **Anchor A — 캐릭터 마스코트** (Chibi / Cookie Run 풍) → 친구 1~2명 일관성
- **Anchor B — 재래시장·키친·식탁 환경** (따뜻한 일러스트 + K-touch) → BG 일관성

> v2.0의 [§3.2 Prompt Template](#) 그대로 사용. 변수만 MVP scope로 좁힘.

### 3.2 MVP 적용 시 변경점
- 캐릭터 prompt 적용 횟수: 5명 → 2명 (작업량 감소)
- 식탁 scene prompt 적용 횟수: 5 tier → 2 tier (Tier 1·2만)
- 음식 prompt 적용 횟수: 50 → 12

---

## 4. Production 시간 추정 (자체 제작, ADR-003)

### 4.1 카테고리별 시간

| 카테고리 | item 수 | 단위 시간 | 소계 | 비고 |
|---------|--------|----------|------|------|
| Scene 1 배경 (11컷) | 11 | ~3h | **~33h** | 템플릿/anchor 적극 재사용, MVP 압축 |
| Scene 2 (배경 + 조리도구) | 6 | ~1.5h | **~9h** | |
| Scene 3 식탁 Tier 1·2 | 2 | ~2h | **~4h** | |
| 친구 캐릭터 2 + reaction 6 (마스코트) | 8 | ~1.5h | **~12h** | 마스코트는 시트 후 reaction 변형 빠름 |
| 음식 일러스트 12개 | 12 | ~0.5h | **~6h** | |
| 재료 카드 ~20개 | 20 | ~0.4h | **~8h** | |
| UI / VFX / 트랜지션 | 14~15 | ~0.4h | **~6h** | 간소화 |
| **M1 sprint 소계** | | | **~78h ≈ ~80h** | 사운드 제외 |
| 사전 (anchor lock M0) | — | flat | ~10~16h | M0에 별도 계산 |
| 사운드 (M2~M3 deferred) | — | flat | ~10h | M1 외 |
| **총 art 시간 (M1 + 사전)** | | | **~88~96h** | |

### 4.2 일정 — M1 sprint (3~4주)

병행 환산: 주 20~25h art 작업 가정 (MVP 단축으로 art 비중 일시 ↑) → **78h ÷ 22h/주 ≈ 3.5주**.

```
M0 (3~4주) — 기획·디자인 finalize
  Week 1: Style anchor 2종 lock 게이트
  Week 2: 친구 1~2명 personality 확정 (game-designer)
  Week 3: MVP 음식 12개 선정 합의 (game-designer)
  Week 4: 일정·범위 reality check 게이트

M1 (3~4주) — Art sprint
  Week 1: Scene 1 외관 5컷 + 입구 1컷 (6컷)
  Week 2: Scene 1 내부 5컷 + Scene 2 키친
  Week 3: Scene 3 식탁 2종 + 친구 2명 캐릭터 시트
  Week 4: 친구 reaction 6컷 + 음식 12 + 재료 20 + UI/VFX/트랜지션

M2 (4~6주) — 코드 구현 + 사운드 시작
M3 (2~4주) — QA + soft launch
```

### 4.3 리스크 케이스 (Scene 1 시간 초과)
Scene 1 BG는 게임 첫 인상이라 polish 부담이 큼. 만약 컷당 3h가 부족하면:
- **현실적 범위**: ~80h (낙관) → ~110h (Scene 1 컷당 5h로 폭증 시)
- 폭증 시 sprint 4주 → 5주 연장 또는 Scene 2/3 polish 단순화로 흡수

---

## 5. Risk Register (ADR-003 반영)

| # | 리스크 | 영향 | 가능성 | 완화안 |
|---|--------|------|-------|--------|
| R-A1 | ~~1인 장기 제작 burnout~~ — **ADR-003 채택으로 완화** | Low | Low | 3~4주 sprint로 burnout 압력 ↓ |
| R-A2 | 시장 변화 (~~8~12개월~~ → **3~4개월**) | **Low** | Low | sprint 단축으로 자연 완화 |
| R-A3 | Style anchor lock 실패 (M0 게이트) | Critical | Med | M0 Week 1~2 게이트, 캐릭터+환경 5장씩 토너먼트 |
| R-A4 | MJ 캐릭터 일관성 — 친구 2명만이라 부담 ↓ | Med | Med | 캐릭터 시트 1장 reference + Photoshop 후보정 |
| R-A5 | MJ 한국적 디테일 (한글 간판, 한복) | High | High | 모든 텍스트 Photoshop 후보정, 1.5배 버퍼 |
| R-A6 | 음식 12개 일관성 — v2.0(50개) 대비 부담 ↓ | Low | Low | 12개를 1개 배치로 동시 생성 |
| R-A7 | 마스코트 정서 표현 한계 (Scene 3 reaction 6컷) | Med | Med | ★3 reaction에 VFX(별, 하트) 결합 |
| R-A8 | MJ Standard Plan 상업 라이선스 | Critical | Low | 즉시 결제, 약관 스크린샷 |
| R-A9 | 자산 export 파이프라인 | Med | Med | M0 Week 1에 1컷 end-to-end 검증 |
| R-A10 | ~~Suno BGM 라이선스~~ — **M2~M3 deferred로 일시 비활성** | Low | Low | M2 시작 시 재평가 |
| **R-A11** | **신규: post-launch 콘텐츠 production 지속력** | High | High | **dual-track**: M2~M3 동안 Tier 3 자산 40% pre-production. LiveOps cadence 사전 합의 |
| **R-A12** | **신규: MVP 콘텐츠 빈약 인상** (음식 12개, Tier 2까지) | Med | Med | ASO 키워드 / 스토어 스크린샷 강화. "지속 업데이트" 메시징 |

### 5.1 Engine-agnostic Asset 소스 권장 리스트 (M1 시점)

> [ADR-004](decisions.md#adr-004) 채택으로 Godot 엔진 전환. paid marketplace 의존 아니라 **engine-agnostic 무료/저가 asset 소스 + Godot Asset Library 무료 항목** 활용. ADR-002 §Decision #2의 "Asset Store" 의미 재정의.

| 항목 | 권장 처리 | 예상 비용 |
|------|----------|----------|
| UI 아이콘 셋 (장바구니, 타이머, 별 등 20~30개) | Flaticon Premium / Iconscout / Kenney(무료) | $10~30 |
| 한국어 폰트 (Pretendard, 본고딕) | **무료 (OFL)** | $0 |
| **M2~M3 deferred** | | |
| SFX 라이브러리 | Pond5 / Freesound / Zapsplat (M2 시작 시) | $30~80 |
| BGM 1~2 트랙 | Suno Pro 시작 (M2) | $10~20 |
| 가게별 ambient (5종) | Freesound / OpenGameArt (M2) | $0~30 |
| **합계 (MVP 전체)** | | **$50~160** |

### 5.2 Production Blocker 순위
1. **Style anchor 2종 lock** (M0 게이트) — 통과 못 하면 M1 시작 불가
2. **MVP 음식 12개 확정** (game-designer 권고 후 pm 승인) — 캐릭터·재료·식탁 디자인 prerequisite
3. **친구 1~2명 personality 확정** — 캐릭터 디자인 prerequisite

---

## 6. 최종 결론 + 즉시 액션 (ADR-003)

### 결론
- **MVP-first**: ~80h M1 sprint (3~4주) + 사전 10~16h (M0)
- 현금 예산 **~$170~270** (MVP 4개월 운영)
- 사운드는 M2~M3로 deferred → Suno Pro 결제 **보류**

### 이번 주 즉시 액션 (변경분)
- [ ] **pm**: MJ Standard Plan 결제 ($30/월) — **변경 없음**
- [ ] **pm**: Suno Pro 결제 **보류** (M2~M3 시작 시 재평가)
- [ ] **art-director**: 캐릭터 + 환경 anchor 각 5장 생성 — **변경 없음** (스타일 결정은 MVP scope와 무관)
- [ ] **game-designer**: **1순위 변경** — `balance-config.md`가 아니라 **MVP 음식 12개 선정 권고** 우선 작성
- [ ] **pm**: M0 일정 확정 (3~4주) + 주간 진척 리뷰 cadence

### M0 게이트 (anchor + scope lock)
- 캐릭터 anchor 1장 + 환경 anchor 1장 확정
- **MVP 음식 12개 확정** (game-designer 권고 → pm 승인)
- 친구 1~2명 personality 확정
- 게이트 통과 = M1 sprint 시작 신호

### 병렬 진행 (M0 동안)
- **game-designer**: 음식 12개 선정 권고서 → balance-config.md → 친구 personality
- **ui-designer**: 다점포 screen-flow (Tier 1·2 한정)
- **art-director**: anchor 생성 + `art-style-guide.md` + `prompts-library.md`

---

## 7. Post-Launch Backlog (확장 production 계획)

ADR-003 §10.2 로드맵에 맞춰 launch 후 추가될 art workload. **dual-track으로 40%는 M2~M3 동안 pre-production 권장** (R-A11 완화).

### 7.1 Month 1~2 (음식 +5~10, Tier 3 자산 준비)
| 항목 | 수량 | 예상 시간 |
|------|------|----------|
| 음식 일러스트 추가 | +5~10 | ~3~5h |
| 재료 카드 추가 | +10~15 | ~4~6h |
| Tier 3 자산 (Scene 3 식탁 1종, 친구 2~3명 미리) | 3 BG + 6 캐릭터 | ~20~25h (pre-prod 40%) |
| **소계** | | **~30~35h** |

### 7.2 Month 3~4 (Tier 3 출시 + 친구 +3~5명)
| 항목 | 수량 | 예상 시간 |
|------|------|----------|
| Tier 3 Scene 3 식탁 (친구 초대) | 1 | ~3h |
| 친구 캐릭터 +3~5명 + reaction | 3~5명 × 6컷 = 18~30 | ~30~45h |
| Korean Food Pack DLC 1차 (음식 8~10) | 10 | ~5h |
| **소계** | | **~38~53h** |

### 7.3 Month 5~6 (Tier 4~5 출시)
| 항목 | 수량 | 예상 시간 |
|------|------|----------|
| Tier 4·5 Scene 3 식탁 | 2 | ~6h |
| 음식 추가 (잔칫상·명절상) | 10~15 | ~6~8h |
| 멀티 요리 메커닉용 추가 UI | 5~7 | ~4h |
| **소계** | | **~16~18h** |

### 7.4 Month 7~12
| 항목 | 비고 |
|------|------|
| 시즌 이벤트 art (추석/설날) | 분기별 8~12h |
| Brand sponsored 통합 art (배너 템플릿) | ~10h |
| iOS 출시 UI 추가 | ~5h |
| 콘텐츠 누적 (음식 +30, 친구 +10) | ~50~70h (분산) |

### 7.5 Post-launch 총 예상
| 시점 | 누적 art 시간 |
|------|--------------|
| MVP launch | ~80h |
| +6개월 (Tier 5까지) | +84~106h = **~165~190h 누적** |
| +12개월 (콘텐츠 풀) | +80~120h = **~245~310h 누적** |

> 누적 추정이 v2.0(228h, full feature MVP) 수준에 12개월 시점에 수렴 — 차이는 **시장 검증 + 단계적 투자**라는 ADR-003의 핵심 가치.

---

## 부록: 버전 변경 요약

| 항목 | v1.0 | v2.0 (ADR-002) | v3.0 (ADR-003) |
|------|------|---------------|----------------|
| MVP scope | Tier 1~3, 음식 30 | Tier 1~5 full, 음식 50 | **Tier 1~2, 음식 12** |
| 친구 수 | 5 | 5 | **1~2** |
| Scene 3 식탁 | 단일 | 5종 | **2종** |
| 외주 권장 | $1.5k~4k | $0 | $0 |
| 캐릭터 스타일 | Ghibli-ish | 마스코트 | 마스코트 |
| Art 시간 (MVP) | ~70h | ~228h | **~80h** |
| MVP 일정 | 4~5주 | 8~12개월 | **3~4주 sprint (M1)** |
| 사운드 | M1 포함 | M1 포함 | **M2~M3 deferred** |

## 변경 이력
- **2026-05-26 v3.1** (supersedes v3.0) — [ADR-005](decisions.md#adr-005) 영향 반영. 4-stage 메커닉 추가 → 칼/도마 1 set + cut style 애니메이션 (3~4 frames × 6 cut style) + hero ingredient cut variation (~24 sprites). **+25~35h (pm reality check) / +20~25h (사용자 추정) placeholder**. Total: ~80h → **~100~115h MVP (pm)**. art-director 작업은 art-style reset 보류 중이라 **BLOCKED — lock 후 정확 산정**. Post-Launch Backlog (§7) 무변경 (rhythm은 MVP). 사운드: M2에 minimum 1~2주 BPM 메트로놈 + 칼질 SFX 추가, 전체 사운드 deferred는 유지.
- **2026-05-23 v3.0** — ADR-003 반영. MVP-first 전환. 음식 50→12, 친구 5→2, Scene 3 5→2종. Art ~228h → ~80h (M1 sprint). 사운드 M2~M3 deferred. Post-launch backlog 섹션(§7) 신설.
- **2026-05-23 v2.0** — ADR-002 반영. 외주 제거, MVP full feature, 마스코트 캐릭터, 일정 8~12개월. 워크로드 ~228h.
- **2026-05-23 v1.0** — 초안. Option A/B/C 비교, 외주 권장.
