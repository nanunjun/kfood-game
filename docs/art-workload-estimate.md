# Art Workload Estimate — K-Food Master MVP

> 버전: **v4.1 (2026-05-27, ChatGPT 영구 sync from MJ, supersedes v4.0)** — art 도구 영구 변경 반영. 시간 ±10% 미세 변동, 비용 ~70% 절감.
> 작성: 2026-05-23 · 최종 개정: 2026-05-27
> 근거: [`decisions.md` ADR-003](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002), [`decisions.md` ADR-005](decisions.md#adr-005) / [`GDD.md`](GDD.md) §9 §10 / [`systems/cooking-mechanics.md`](systems/cooking-mechanics.md) §2 §X / [`art-style-guide.md` v1.1](art-style-guide.md) / [`ai-session-kit.md` v1.1](ai-session-kit.md)
> 작성자: art-director · 대상: pm, godot-dev, game-designer

---

## 0. Executive Summary

> 🎯 **방침 (ADR-003 채택)**: ADR-002 결정 #1·2·3·5 유지 + **MVP-first** (음식 12개, Tier 1~2, 친구 1~2명, Scene 3 2종)
> 🆕 **ADR-005 (2026-05-26)**: 4-stage 메커닉 — 칼/도마 + cut style 6종 + hero ingredient cut variation
> 🆕 **art-style lock (2026-05-27)**: 하이퍼캐주얼 flat (Subway Surfers / Crossy Road / Stack 계열).
> 🆕 **art 도구 영구 변경 (2026-05-27)**: Midjourney → **ChatGPT (GPT-4o image / DALL-E)**. 비용 **~70% 절감** (MJ Standard $30/월 → ChatGPT Plus $20/월 + DALL-E 무제한 한계 비용 0), 시간 **±10% 미세 변동** (4-grid 손실 vs 자연어 iteration 속도 + 1 image 생성 속도 빠름 상쇄).
>
> **순 art 작업 시간 (v4.1 flat 톤 + ChatGPT)**: M1 sprint **~50~55h** + ADR-005 cut anim **~12~18h** → **MVP total ~62~73h**. v4.0 대비 시간 무변동 (도구 변경이 평가/제작 시간에 큰 영향 없음).
> mascot v3.1 ~100~115h 대비 **-37~46% 감소** 유지.

| 항목 | v3.1 (mascot baseline, pm) | v4.0 (flat 톤 + MJ) | **v4.1 (flat 톤 + ChatGPT)** | v3.1 대비 감소율 |
|------|---------------------------|--------------------|------------------------------|----------------|
| M1 art sprint (base, mascot 80h) | ~80h | ~50~55h | **~50~55h** | -31~38% |
| ADR-005 추가 (pm 25~35h) | ~25~35h | ~12~18h | **~12~18h** | -48~52% |
| **M1 total (MVP)** | **~100~115h** | ~62~73h | **~62~73h** | **-37~46%** |
| M0 사전 (anchor lock) | ~10~16h | ~8~12h | **~8~12h** | -25% (flat 단순화) |
| **총 art 시간 (M1 + 사전)** | ~110~131h | ~70~85h | **~70~85h** | **-35~36%** |
| MVP sprint 일정 | 4~7주 | 3~5주 | **3~5주** | -1~2주 |
| **art 도구 비용** | MJ $30/월 × 4개월 = ~$120 | MJ ~$60~90 (fast hour 소비 감소) | **ChatGPT Plus $20/월 × MVP 4~5주 ≈ ~$20~25** | **-79~83%** vs v3.1 / **-67~78%** vs v4.0 |
| 외주 비용 | $0 | $0 | **$0** (변경 없음) | |
| 사운드 | M2~M3 deferred | M2~M3 deferred | **M2~M3 deferred** (art 톤·도구 무관) | |

### 0.X 도구 변경 영향 (한 줄)

> **도구 영구 변경: MJ Standard → ChatGPT Plus, 비용 ~70% 절감 (MVP 기간 ~$60~90 → ~$20~25), 시간 ~±10% 미세 변동 (4-grid 손실 vs 자연어 iteration 속도 상쇄 — net 무변동). ChatGPT sref 부재로 캐릭터 일관성 lock이 MJ 대비 약한 trade-off가 있으나, reference image upload + subject anchor 문장 + 같은 채팅 세션 follow-up 3축 운영으로 보완.**

### 0.1 ADR-005 추가 작업 항목 (v4.1 flat 톤 + ChatGPT 재산정)

| 항목 | 수량 | v3.1 단위 시간 (mascot, pm) | **v4.1 단위 시간 (flat + ChatGPT)** | v4.1 소계 |
|------|------|---------------------------|------------------------------------|-----------|
| 칼/도마 art 1 set | 1 set | ~3~4h | **~1.5~2h** (simple silhouette, ChatGPT 1 image per request) | **~1.5~2h** |
| Cut style별 애니메이션 frames | 12~18 frames (v3.1 18~24 대비 -25~33%) | ~0.5~0.7h | **~0.3~0.4h** (simple shape 변환, 같은 채팅 세션 follow-up sequence) | **~4~7h** |
| Hero ingredient cut variation | ~24 sprite | ~0.4h | **~0.2h** (whole+cut 2장만, anchor file reference upload) | **~5h** |
| 마스코트 재작업 가능성 | placeholder | ~3~4h | **~1~2h** (flat 톤 cut 모션 호환 기본) | **~1~2h** |
| **ADR-005 추가 합계 (v4.1 flat + ChatGPT)** | | | | **~12~18h** |

> **v3.1 pm 25~35h 대비 -48~52% 감소** 유지. v4.0 대비 도구 변경이 cut anim 시간에 큰 영향 없음 (frame 수·단순 shape 변환 효과 동일).

---

## 1. MVP Asset Inventory (ADR-003 scope, v4.1 flat 톤 + ChatGPT)

### 1.1 Scene 1 — 재래시장 다점포

| 항목 | 수량 | 비고 |
|------|------|------|
| 재래시장 입구 배경 | 1 | flat 톤이라 단순 |
| 가게 5종 외관 | 5 | 청과/정육/어물/곡물/잡화 — 가게당 시그니처 컬러 + icon 1~2 |
| 가게 5종 내부 매대 | 5 | flat 톤이라 perspective 최소화 |
| **Scene 1 배경 소계** | **11** | |

### 1.2 Scene 2 — 키친
| 항목 | 수량 |
|------|------|
| 키친 배경 | 1 |
| 조리도구 일러스트 (가스레인지/팬/도마/뚝배기/오븐) | 4~5 |

### 1.3 Scene 3 — 식탁 (Tier 1·2)
| 항목 | 수량 |
|------|------|
| Tier 1 식탁 (혼밥) | 1 |
| Tier 2 식탁 (가족) | 1 |
| **소계** | **2** |

### 1.4 친구 캐릭터 (양친, U-2 동시 unlock)
| 항목 | 수량 |
|------|------|
| 캐릭터 base (어머니 + 아버지) | 2 |
| Reaction 6컷 (어머니 ★1/2/3 + 아버지 ★1/2/3) | 6 |
| 주인공 base + reaction 2 (Happy/Subtle) | 3 |

### 1.5 콘텐츠 일러스트
| 항목 | 수량 |
|------|------|
| 음식 일러스트 (Final 12) | **12** |
| 재료 카드 (음식 12 등장 재료) | ~20 |

### 1.6 ADR-005 신규
| 항목 | 수량 |
|------|------|
| 칼/도마 base | 1 set |
| Cut style 6종 frames (2~3 frame/style) | 12~18 |
| Hero ingredient cut variation (whole+cut) | ~24 |

### 1.7 UI / VFX / 트랜지션
| 항목 | 수량 |
|------|------|
| UI 일러스트 (장바구니, 메모지, 간판 5, 타이머 등) | 7 |
| VFX (픽업, shake, 타이머 펄스, ★) | 4~5 |
| 트랜지션 시퀀스 | 3 |

### 1.8 사운드 — M2~M3 deferred (art 톤 무관)
| 항목 | M1 시점 |
|------|---------|
| BGM 1~2 (Suno) | M2~M3 |
| SFX 15~20 (Pond5/Freesound) | M2~M3 |
| BPM 메트로놈 + 칼질 SFX (ADR-005) | M2 minimum 1~2주 |

### 1.9 총합 (M1 sprint 기준, 사운드 제외)

| 카테고리 | item 수 |
|---------|---------|
| Scene 1 배경 | 11 |
| Scene 2 (배경 + 조리도구) | 5~6 |
| Scene 3 식탁 | 2 |
| 캐릭터 base 3 (주인공+양친) + reaction 6+2 | 11 |
| 음식 12 + 재료 20 | 32 |
| ADR-005 (칼/도마 1 + cut anim 12~18 + ingredient variation 24) | ~37~43 |
| UI + VFX + 트랜지션 | 14~15 |
| **MVP M1 총 item** | **~112~120** (v3.1 ~72~74 대비 +50% — ADR-005 추가분, item 단위 시간은 flat 톤이라 ↓) |

---

## 2. Tier 변화 정책 (변경 없음)

| Scene | MVP Tier 변화 | Post-launch |
|-------|--------------|-------------|
| Scene 1 (재래시장) | 단일 (5가게 유지) | 변경 없음 |
| Scene 2 (키친) | 단일 | 변경 없음 |
| Scene 3 (식탁) | 2종 (Tier 1·2) | +3종 (Tier 3·4·5) |

---

## 3. ChatGPT Consistency 전략 (v4.1 flat 톤)

### 3.1 Anchor 2종 (v4.1 flat + ChatGPT)

- **Anchor A — 캐릭터** (flat chibi mascot, ChatGPT) → 주인공/양친 일관성. reference image upload + subject anchor 문장 + 같은 채팅 세션 follow-up 3축 운영.
- **Anchor B — 환경** (flat geometric 재래시장, ChatGPT) → 5가게 BG 일관성. 동일 3축 운영.

> v4.0 MJ v6.1 single model → **v4.1 ChatGPT 단일 model 통일** (내부 자동, 모델 선택 param 없음). sref 부재 trade-off는 reference image upload로 보완.

### 3.2 MVP 적용 변경점

- 캐릭터 prompt 적용: 주인공 1 + 양친 2 + reaction 8 = 11컷
- 식탁 scene: 2 tier
- 음식 prompt: 12개 (5.1 음식 카드 anchor file 공유 — reference upload)
- 칼/도마/cut anim: ADR-005 신규 ~37~43 item (같은 채팅 세션 follow-up sequence)

---

## 4. Production 시간 추정 (v4.1 flat 톤 + ChatGPT)

### 4.1 카테고리별 시간

| 카테고리 | item 수 | v3.1 단위 시간 (mascot) | **v4.1 단위 시간 (flat + ChatGPT)** | v4.1 소계 |
|---------|--------|----------------------|------------------------------------|----------|
| Scene 1 배경 (11컷) | 11 | ~3h | **~2h** (flat 단순화, 도구 무관) | **~22h** |
| Scene 2 (6컷) | 6 | ~1.5h | **~1h** | **~6h** |
| Scene 3 식탁 Tier 1·2 | 2 | ~2h | **~1.5h** (flat 톤 top-down 자연) | **~3h** |
| 캐릭터 3 base + reaction 8 (마스코트→flat) | 11 | ~1.5h | **~0.8h** (flat feature만 변경, ChatGPT reference upload 시간 미미) | **~9h** |
| 음식 일러스트 12 | 12 | ~0.5h | **~0.4h** | **~5h** |
| 재료 카드 ~20 | 20 | ~0.4h | **~0.3h** | **~6h** |
| UI / VFX / 트랜지션 | 14~15 | ~0.4h | **~0.3h** | **~4~5h** |
| **M1 sprint base 소계 (v4.1)** | | | | **~55~56h ≈ ~55h** |
| | | | | |
| ADR-005 칼/도마 + cut anim + ingredient variation | ~37~43 | (§0.1 표) | (§0.1 표) | **~12~18h** |
| **M1 sprint total (v4.1)** | | | | **~67~73h** |
| | | | | |
| 사전 (anchor lock M0) | — | ~10~16h | **~8~12h** (flat 단순, ChatGPT 1 image per request 자연어 reroll) | **~8~12h** |
| 사운드 (M2~M3 deferred) | — | — | — | — |
| **총 art 시간 (M1 + 사전, v4.1)** | | | | **~75~85h** |

> **v3.1 mascot 110~131h 대비 -35~36% 감소** 유지. v4.0 대비 시간 무변동 — ChatGPT 4-grid 손실 (reroll 1~2회 trade-off, +~5~10%) vs 자연어 iteration 속도 + 1 image 생성 속도 빠름 (~-5~10%)이 net으로 상쇄. ±10% 범위 내 미세 변동.

### 4.2 일정 — M1 sprint (3~5주, v4.1)

병행 환산: 주 20~25h art 작업 가정 → **~67~73h ÷ 22h/주 ≈ 3~3.5주** (v3.1 4~7주 대비 단축, v4.0 대비 무변동).

```
M0 (2~3주, v4.0) — 기획·디자인 finalize + flat 톤 anchor lock
  Week 1: flat 톤 anchor 10장 lock 게이트 (사용자 MJ 1.5~2.5h + art-director 평가 0.5h)
  Week 2~3: ADR-005 4-stage 디자인 finalize + cut style 6종 anchor 선행

M1 (3~5주, v4.0) — Art sprint
  Week 1: Scene 1 외관 5 + 입구 1 (6컷)
  Week 2: Scene 1 내부 5 + Scene 2 키친
  Week 3: Scene 3 식탁 2 + 캐릭터 base 3 + 양친 reaction 6
  Week 4: 음식 12 + 재료 20 + ADR-005 칼/도마+cut anim+ingredient variation
  Week 5: UI/VFX/트랜지션 + buffer

M2 (3~5주) — 코드 구현 + 사운드 시작 (ADR-005 BPM/SFX 포함)
M3 (2~4주) — QA + soft launch
```

### 4.3 리스크 케이스 (Scene 1 시간 초과)

flat 톤은 Scene 1 BG polish 부담이 mascot보다 ↓ (디테일이 적어 한계 부담 ↓). 단:
- **현실적 범위**: ~55h (낙관) → ~75h (Scene 1 컷당 3h로 폭증 시 — v3.1 110h 폭증보다 완만)
- 폭증 시 sprint 3.5주 → 5주 연장 또는 Scene 2/3 단순화로 흡수

---

## 5. Risk Register (v4.1 flat 톤 + ChatGPT 반영)

| # | 리스크 | 영향 | 가능성 | 완화안 |
|---|--------|------|-------|--------|
| R-A1 | 1인 장기 제작 burnout — ADR-003 채택으로 완화 + flat 톤으로 추가 완화 | Low | Low | 3~5주 sprint |
| R-A2 | 시장 변화 (3~5주 sprint) | **Low** | Low | sprint 단축 |
| R-A3 | flat 톤 anchor lock 실패 (M0 게이트) | Critical | **Low~Med** (mascot Med보다 ↓ — flat 단순성) | Week 1 게이트, 캐릭터+환경 5장씩 |
| R-A4 | **ChatGPT 캐릭터 일관성 lock (sref 부재)** — v4.0 MJ는 sref 강력했으나 ChatGPT 영구 변경으로 risk ↑ | **Med~High** (v4.0 Low보다 ↑) | Med | reference image upload + subject anchor 문장 동일 복사 + 같은 채팅 세션 follow-up 3축 운영, Step 0a 품질 핵심 |
| R-A5 | ChatGPT 한국적 디테일 (옹기/한복/시장) | High | **Med~High** (mascot/MJ flat과 유사) | K-touch 자연어 강화 + Important: avoid 명시 |
| R-A6 | 음식 12개 일관성 — flat 톤이라 부담 ↓ | Low | Low | 12개 첫 음식 anchor file reference upload로 통일 |
| R-A7 | 양친 reaction 6컷 정서 표현 (flat은 호 입/색 변화로만) | **Med** | Med | 표정 = features 형태 변화 + 분홍 볼 + flat 호 눈, CH-02/CH-03 reference upload |
| R-A8 | **ChatGPT Plus 상업 라이선스** — DALL-E 생성물 상업 사용 정책 확인 필수 | Critical | Low | 즉시 약관 스크린샷, OpenAI Terms 확인 (현재 DALL-E 3 출력물 상업 사용 허용) |
| R-A9 | 자산 export 파이프라인 | Med | Med | M0 Week 1 1컷 end-to-end 검증 |
| R-A10 | Suno BGM 라이선스 — M2~M3 deferred 일시 비활성 | Low | Low | M2 재평가 |
| R-A11 | post-launch 콘텐츠 production 지속력 | High | High | dual-track, Tier 3 40% pre-prod |
| R-A12 | MVP 콘텐츠 빈약 인상 | Med | Med | ASO 강화, "지속 업데이트" 메시징 |
| **R-A13** | **flat 톤 photoreal/painterly/texture 누수** (ChatGPT default) | Med | **Med~High** | 강력한 "Important: avoid ..." negative + R1에서 1~2장 follow-up reroll 예산 반영 |
| **R-A14** | ~~art-style reset BLOCKED~~ — **2026-05-27 RESOLVED** (Subway Surfers/Crossy Road/Stack lock) | Resolved | — | — |
| **R-A15** | **ADR-005 cut anim frame이 over-render 빠짐** (ChatGPT가 simple shape를 detailed로 표현) | Med | Med | cut anim 별도 mini-키트, frame 단위 prompt, 같은 채팅 세션 follow-up sequence + "only shape change, minimal detail" 강제 |
| **R-A16** | **ChatGPT 한글 텍스트 ~100% 깨짐** (간판/가격표) | Low (영향) | **Very High** (빈도) | 모든 텍스트 placeholder block + Photoshop/엔진 UI overlay 후보정 default. anchor 단계 평가에서 W1 CONDITIONAL default 허용. |
| **R-A17** | **MJ → ChatGPT 영구 변경 transition** (학습 곡선) | Low | Low | session kit + prompts library v1.1 사용자 가이드 충분, MJ Standard 결제는 main thread가 다음 billing 전 취소 권고 |

### 5.1 Engine-agnostic Asset 소스 (M1 시점)

| 항목 | 권장 처리 | 예상 비용 |
|------|----------|----------|
| UI 아이콘 셋 (장바구니, 타이머, ★ 등 20~30) | Flaticon Premium / Iconscout / Kenney(무료) | $10~30 |
| 한국어 폰트 (Pretendard, 본고딕) | 무료 (OFL) | $0 |
| **M2~M3 deferred** | | |
| SFX 라이브러리 | Pond5 / Freesound / Zapsplat | $30~80 |
| BGM 1~2 (Suno Pro) | M2 시작 | $10~20 |
| 가게별 ambient 5종 | Freesound / OpenGameArt | $0~30 |
| **합계 (MVP 전체)** | | **$50~160** |

### 5.2 Production Blocker 순위

1. **flat 톤 anchor 2종 lock** (M0 게이트) — 통과 못 하면 M1 시작 불가. flat 톤은 mascot보다 통과 확률 ↑
2. **MVP 음식 12개 확정** (mvp-food-selection v2.1 — canonical lock 완료 2026-05-24)
3. **양친 personality 확정** — U-2 동시 unlock (game-designer + ui-designer sync)

---

## 6. 최종 결론 + 즉시 액션

### 결론 (v4.1 flat 톤 + ChatGPT)
- **MVP-first + flat 톤 + ChatGPT**: **~67~73h M1 sprint (3~5주)** + 사전 ~8~12h (M0). v3.1 mascot ~100~115h 대비 **-37~46% 감소** 유지.
- 현금 예산 **~$70~185** (MVP 4개월; ChatGPT Plus ~$20~25 + asset $50~160) — v4.0 대비 도구 비용 ~$40~65 추가 절감.
- 사운드는 M2~M3 deferred → Suno Pro 보류 (ADR-005 BPM/SFX는 M2 추가)

### 이번 주 즉시 액션 (2026-05-27 기준)
- [x] **사용자**: art-style reset lock (Subway Surfers/Crossy Road/Stack) — 2026-05-27 완료
- [x] **사용자**: art 도구 영구 변경 confirm (MJ → ChatGPT) — 2026-05-27 완료
- [x] **art-director**: art-style-guide v1.0 + prompts-library v1.0 + art-anchor-rubric v1.0 + mj-session-kit v1.0 scratch 재작성 — 2026-05-27 완료
- [x] **art-director**: art-style-guide v1.1 + prompts-library v1.1 + ai-session-kit v1.1 + art-anchor-rubric v1.1 + art-workload-estimate v4.1 ChatGPT 영구 sync — 2026-05-27 완료
- [ ] **사용자**: ChatGPT Plus $20/월 결제 + Week 1 ChatGPT session 진입 (~1~1.5h 예상)
- [ ] **main thread**: MJ Standard 다음 billing 전 결제 취소 권고
- [ ] **art-director**: 사용자 ChatGPT session 결과 수령 후 G1~G7 rubric 평가 (0.5h)
- [ ] **pm**: ADR-002 §Decision #5 정합성 — 본 v4.1 보고서 §A 참조하여 amendment 여부 결정
- [ ] **pm**: art-workload v4.1 sign-off + M0 → M1 일정 확정 (3~5주)

### M0 게이트 (anchor + scope lock)

- flat 톤 캐릭터 anchor 1장 + 환경 anchor 1장 (sref) 확정
- 10 anchor 중 최소 8 LOCK
- 음식 12개 확정 (v2.1 lock 완료)
- 양친 personality 확정
- 게이트 통과 = M1 sprint 시작 신호

---

## 7. Post-Launch Backlog (변경 없음 — art style·도구 무관)

> ADR-003 §10.2 로드맵. dual-track 40% pre-production 권장.
> **flat 톤은 post-launch에서도 동일 톤 유지** (Subway Surfers / Crossy Road처럼 launch 톤 lock 후 콘텐츠 cadence).
> **도구는 ChatGPT 영구 lock** — post-launch에도 동일. ChatGPT Plus $20/월 지속, 무제한 한계 비용 0.

### 7.1 Month 1~2

| 항목 | 수량 | flat 톤 예상 시간 |
|------|------|-----------------|
| 음식 일러스트 추가 | +5~10 | ~2~4h |
| 재료 카드 추가 | +10~15 | ~3~5h |
| Tier 3 자산 pre-prod (식탁 1 + 친구 2~3) | 3 BG + 6 캐릭터 | ~15~20h |
| **소계** | | **~20~29h** |

### 7.2 Month 3~4

| 항목 | 수량 | flat 톤 예상 시간 |
|------|------|-----------------|
| Tier 3 Scene 3 식탁 (친구 초대) | 1 | ~2h |
| 친구 캐릭터 +3~5 + reaction (★1/2/3) | 3~5명 × 6 = 18~30 | ~20~30h |
| Korean Food Pack DLC 1차 (음식 8~10) | 10 | ~4h |
| **소계** | | **~26~36h** |

### 7.3 Month 5~6

| 항목 | 수량 | flat 톤 예상 시간 |
|------|------|-----------------|
| Tier 4·5 Scene 3 식탁 | 2 | ~4h |
| 음식 추가 (잔칫상/명절상) | 10~15 | ~4~6h |
| 멀티 요리 UI | 5~7 | ~3h |
| **소계** | | **~11~13h** |

### 7.4 Month 7~12

| 항목 | 비고 |
|------|------|
| 시즌 이벤트 (추석/설날) | 분기별 6~8h |
| Brand sponsored | ~7h |
| iOS UI | ~3h |
| 콘텐츠 누적 (음식 +30, 친구 +10) | ~35~50h (분산) |

### 7.5 Post-launch 총 예상 (v4.1 flat + ChatGPT)

| 시점 | 누적 art 시간 | 누적 도구 비용 (ChatGPT Plus $20/월) |
|------|--------------|------------------------------------|
| MVP launch | ~67~73h | ~$20~25 |
| +6개월 (Tier 5까지) | +57~78h = **~124~151h 누적** | ~$120 (6개월) |
| +12개월 (콘텐츠 풀) | +50~80h = **~174~231h 누적** | ~$240 (12개월) |

> v3.1 mascot 누적(245~310h 12개월) 대비 -25~30% 감소 → flat 톤의 운영 효율성.
> v4.0 MJ Standard $30/월 × 12개월 = ~$360 대비 ChatGPT Plus $240 → 도구 비용 ~$120 추가 절감 (-33%).

---

## 부록: 버전 변경 요약

| 항목 | v1.0 | v2.0 (ADR-002) | v3.0 (ADR-003) | v3.1 (ADR-005) | v4.0 (flat lock) | **v4.1 (ChatGPT 영구 lock)** |
|------|------|---------------|----------------|----------------|------------------|------------------------------|
| MVP scope | Tier 1~3, 음식 30 | Tier 1~5, 음식 50 | Tier 1~2, 음식 12 | Tier 1~2, 음식 12 (+칼/cut anim) | Tier 1~2, 음식 12 (+cut anim) | **Tier 1~2, 음식 12 (+cut anim)** |
| 친구 수 | 5 | 5 | 1~2 | 1~2 (양친 U-2) | 2 (양친 U-2) | 2 (양친 U-2) |
| Scene 3 식탁 | 단일 | 5종 | 2종 | 2종 | 2종 | 2종 |
| 외주 권장 | $1.5k~4k | $0 | $0 | $0 | $0 | $0 |
| 캐릭터 스타일 | Ghibli-ish | 마스코트 | 마스코트 | 마스코트 | 하이퍼캐주얼 flat (Subway Surfers/Crossy Road) | **하이퍼캐주얼 flat (유지)** |
| **art 도구** | MJ | MJ | MJ | MJ | MJ v6.1 single model | **ChatGPT (GPT-4o image / DALL-E)** |
| **도구 비용 (MVP)** | ~$120 | ~$120 | ~$120 | ~$120 | ~$60~90 | **~$20~25** |
| Art 시간 (MVP) | ~70h | ~228h | ~80h | ~100~115h | ~67~73h | **~67~73h** |
| MVP 일정 | 4~5주 | 8~12개월 | 3~4주 | 4~7주 | 3~5주 | **3~5주** |
| 사운드 | M1 포함 | M1 포함 | M2~M3 | M2~M3 (+BPM/cut SFX) | M2~M3 (+BPM/cut SFX) | M2~M3 (+BPM/cut SFX) |

## 변경 이력

- **2026-05-27 v4.1** (ChatGPT 영구 sync from MJ, supersedes v4.0) — art 도구 영구 변경 (사용자 confirm 2026-05-27). MJ Standard $30/월 → **ChatGPT Plus $20/월** (DALL-E 무제한 한계 비용 0). 비용 v4.0 ~$60~90 → **~$20~25** (-67~78%, v3.1 ~$120 대비 -79~83%). 시간 ±10% 미세 변동 (4-grid 손실 vs 자연어 iteration 속도 net 상쇄) — M1 sprint ~67~73h / 총 ~75~85h 무변동. §0.X 도구 변경 영향 한 줄 § 신규 추가. §3 MJ Consistency 전략 → ChatGPT Consistency 전략 (reference image upload + subject anchor 문장 + 같은 채팅 세션 follow-up 3축). §4 카테고리별 시간 v4.0 무변동 (도구 변경 영향 미미). §5 Risk Register 갱신 — **R-A4 ChatGPT 캐릭터 일관성 lock (sref 부재)** v4.0 Low → Med~High 상향 (가장 큰 trade-off), **R-A8 ChatGPT Plus 상업 라이선스** 갱신 (DALL-E 3 상업 사용 허용), **R-A16 ChatGPT 한글 텍스트 ~100% 깨짐** 신규 (Very High 빈도, Low 영향 — placeholder + 후보정 default), **R-A17 도구 변경 transition** 신규 Low. §6 즉시 액션 갱신 — 사용자 ChatGPT Plus 결제 액션 + main thread MJ Standard 취소 액션 추가. §7 Post-launch 도구 비용 컬럼 추가. 부록 v4.1 컬럼 추가.
- **2026-05-27 v4.0** (supersedes v3.1) — 사용자 art-style lock (Subway Surfers / Crossy Road / Stack 계열 하이퍼캐주얼 flat). mascot baseline v3.1 → flat 톤 재산정. **M1 sprint ~80h(mascot) → ~50~55h(flat) -31~38%**. **ADR-005 cut anim ~25~35h(mascot pm) → ~12~18h(flat) -48~52%** (frame 수 18~24 → 12~18 -25~33%, 단위 시간 0.5~0.7h → 0.3~0.4h -40~50%). **MVP total ~100~115h → ~62~73h -37~46%**. 캐릭터·환경 모델 통일 (niji 6 + v6.1 dual → v6.1 single). MJ 비용 -25~50% (reroll 빈도 ↓ + fast hours 적게). Sprint 일정 4~7주 → 3~5주. R-A13(flat photoreal 누수) / R-A14(art-style reset, RESOLVED) / R-A15(cut anim over-render) 신규/갱신. Post-Launch Backlog 톤 무변경, 단위 시간 -25~30% 반영. ADR-002 §Decision #5 정합성 판정은 v4.0 §A(보고)에서 art-director 의견 명시 — pm sign-off 필요.
- **2026-05-26 v3.1** (archived) — [ADR-005](decisions.md#adr-005) 영향 placeholder. 칼/도마 + cut anim + ingredient variation +25~35h (pm) / +20~25h (사용자). Total ~80h → ~100~115h MVP. art-director 작업은 art-style reset 보류로 BLOCKED.
- **2026-05-23 v3.0** (archived) — ADR-003. MVP-first. 음식 50→12, 친구 5→2, Scene 3 5→2. Art ~228h → ~80h. M2~M3 사운드 deferred.
- **2026-05-23 v2.0** (archived) — ADR-002. 외주 제거, full feature MVP, 마스코트. ~228h.
- **2026-05-23 v1.0** (archived) — 초안.
