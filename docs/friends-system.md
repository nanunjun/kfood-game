# Friends System — MVP

> 버전: **v0.2 (2026-05-24, supersedes v0.1)** · 작성자: game-designer
> Scope: **MVP — 가족 단위 1~2명** ([ADR-003](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002)).
> 상위 문서: [`GDD.md` §4·§6.3](GDD.md), [`systems/cooking-mechanics.md` §5.1](systems/cooking-mechanics.md), [`systems/mvp-food-selection.md` v2.1](systems/mvp-food-selection.md), [`art-style-guide.md` §3](art-style-guide.md), [`balance-config.md` v0.2 §2 §5.1](balance-config.md), [`ui/ftue.md` §7](ui/ftue.md), [`ui/tier-1-2-flow.md`](ui/tier-1-2-flow.md)
>
> **v0.2 변경**: C-2 lock 적용 — t2_011 양념치킨 → **t2_013 순두부찌개** 호불호 axis 치환. 매운 카테고리(고춧가루) 유지로 어머니 dislike 일관성 보존.

---

## 0. 핵심 결정

| # | 결정 |
|---|------|
| F-1 | **가족 단위 2명 = 어머니 + 아버지** (어머니 단독은 정서 arc 미흡, 2명이 호불호 매트릭스에 충분한 다양성 부여) |
| F-2 | **어머니 unlock = L11** (Tier 2 진입 시 동시). 아버지 unlock = **L11에서 어머니와 동시 등장** (§U-2 결정 참조) |
| F-3 | **호불호는 Round 점수 ±5%** (★ 임계 불변). `friends.preference_affect_stars = false` |
| F-4 | **호불호 axis 5종** (매운/단/짠/기름진/담백). 음식 1개는 1~3개 axis 태그 |
| F-5 | post-launch 친구 3~5명 추가 시 axis 5종은 유지, 새 친구는 같은 axis 위 다른 가중치 — **interface 호환** (§6) |

---

## 1. U-2 결정: 어머니/아버지 unlock 시점

**결정: L11 동시 unlock (양친 동시 등장).**

### 1.1 후보 비교

| 후보 | 어머니 | 아버지 | 정서 arc | 메커닉 학습 |
|------|:-----:|:------:|---------|------------|
| A (ui-designer 권고) | L11 | L15 | 부드러운 ramp; 가족이 점진 형성 | 호불호 시스템 학습이 L11~L14는 1명만 → 2명 확장에서 재학습 |
| **B (game-designer 권고)** | **L11** | **L11** | "Tier 2 진입 = 가족 식탁 풀 등장" 단일 임팩트 | 호불호 매트릭스 풀 첫 노출 = 한 번에 학습 |
| C | L11 | L20 | T2 후반 임팩트 | 아버지 등장 너무 늦음, T2 중 4개 음식 어머니 단독 |

### 1.2 결정 사유 (B)
- **정서적 임팩트**: L10 → L11 전환은 GDD §4의 가장 큰 정서 경계 (혼밥 → 가족). 어머니만 등장하면 "한 부모 가정" 인상 또는 약한 식탁 → "가족 식탁" 이미지가 절반.
- **호불호 시스템 명료성**: 2명 호불호가 동시 등장하면 첫 round에서 "어머니는 좋아하지만 아버지는 싫어해요" 같은 trade-off가 메커닉 의도(다양성 선택) 즉시 전달.
- **art-director sync**: art-style-guide §3.5 reaction anchor "친구 2명 × 3 표정 = 6컷" 전제와 일치. L15 분리 시 6컷 중 3컷이 L15까지 sleeping asset.
- **단점 완화**: 풀 노출의 학습 부담은 L11 컷씬에서 "두 분이 식탁에 앉아요" 명시 + 첫 1~2 round는 호불호 영향 없는 음식(비빔밥 = 양친 공통 like)로 ramp.

### 1.3 unlock 컷씬 흐름 (ui-designer sync 필요)
```
[L10 종료]
  └─ 별 누적 달성 → "Tier 2 열림!" 모달
[L11 진입 직전]
  └─ 컷씬 (skippable):
     "혼자 먹던 식탁에 어머니, 아버지가 함께 앉으셨어요."
     (어머니 + 아버지 dual portrait, Subtle 표정)
  └─ "비빔밥 한 그릇 어떠세요?" → L11 Round 1 시작 (비빔밥)
```

> ⚙️ **ui-designer reconfirm 필요**: `tier-1-2-flow.md` §3.4 어머니 unlock 컷씬을 양친 dual로 갱신.

---

## 2. 친구 Personality

### 2.1 어머니 (friend_id: `mother_01`)

**Personality**: 따뜻한 가정주부형. 양념·국물·정성 들인 음식을 좋아한다. 늦오후 골든아워에 부엌에서 국을 끓이는 모습이 어울리는 캐릭터.

**시각 표현** (art-style §3.3 sync):
- 단순화한 한복 저고리 (분홍 또는 옅은 베이지) + 모던한 통 바지
- 머리: 단정히 묶은 머리 + 옆머리 한 가닥
- 볼터치: Persimmon `#F4A261` 원형 (공통 시그니처)
- Happy 표정: 입꼬리 활짝 + 눈 반달, 손은 입가에 살짝
- Subtle 표정: 미소 + 끄덕임

**Voice (UI 카피 톤)**:
- ★3: "와, 우리 아이가 다 했네!"
- ★1·2: "잘했어요."
- like 음식: "엄마가 좋아하는 거 만들었네!"
- dislike 음식: (조용히 한 입만)

### 2.2 아버지 (friend_id: `father_01`)

**Personality**: 호방한 회사원형. 매콤하고 기름진 음식(소주 안주 톤)을 좋아한다. 출근 전·후 식탁에서 큰 반응을 보이는 캐릭터.

**시각 표현**:
- 베이지 카디건 + 흰 셔츠 + 앞치마 (요리 도와주는 가장)
- 머리: 살짝 정돈된 흑발, 옆머리 짧음
- 안경 옵션 (디테일 너무 많으면 AI image generation 약점 → §art-style §3.4 단순 라인) <!-- ADR-006 (2026-05-27): MJ → ChatGPT pivot. 디테일 일관성 우려는 도구 무관 일반 가이드로 유지. -->
- Happy 표정: 입 활짝 + "음!" 엄지척 (한 손)
- Subtle 표정: 끄덕임 + 입을 다물고 살짝 미소

**Voice**:
- ★3: "이야~ 우리 아들/딸 솜씨가!"
- ★1·2: "수고했다."
- like 음식: "오~ 이거 좋다!"
- dislike 음식: "음... 다음엔 좀 더 매콤하게."

> 본 voice 카피는 placeholder. ui-designer/사용자 톤 검토 후 확정.

### 2.3 양친 공통 안전구역
- 두 명 모두 마스코트 chibi 비율 1:1.5~2.0.
- 양친 키 비율: 아버지 1.05 / 어머니 1.0 (art-style §3.1).
- 정면 얼굴 회피 (3/4 시점 anchor).
- 식탁 reaction 시 동시 등장 가능 (Scene 3 식탁 카메라가 두 명 모두 보이도록 7/8 top-down).

---

## 3. 호불호 시스템 (Preference Axis)

### 3.1 Axis 5종

| Axis | 한국어 라벨 | 대표 자극 |
|------|------------|----------|
| spicy | 매운 | 고추장·고춧가루 |
| sweet | 단 | 설탕·꿀·견과류 |
| salty | 짠 | 간장·소금·젓갈 |
| oily | 기름진 | 튀김·구이·기름 |
| mild | 담백 | 무양념·국·찜 |

> 5 axis는 한식 카테고리 변별에 충분 + post-launch 확장 시 binary tag로 anchor lock. axis 신설은 schema 마이그레이션이 필요하므로 MVP에서 5종 fix.

### 3.2 음식별 axis 태그 (MVP 12)

| food_id | 음식 | spicy | sweet | salty | oily | mild |
|---------|------|:-----:|:-----:|:-----:|:----:|:----:|
| t1_001 | 호떡 | | ✅ | | ✅ | |
| t1_002 | 라면 | ✅ | | ✅ | | |
| t1_003 | 떡볶이 | ✅ | ✅ | | | |
| t1_004 | 김밥 | | | ✅ | | ✅ |
| t1_005 | 김치볶음밥 | ✅ | | ✅ | ✅ | |
| t1_006 | 해물파전 | | | ✅ | ✅ | |
| t1_007 | 콘도그 | | ✅ | ✅ | ✅ | |
| t2_008 | 비빔밥 | ✅ | | | | ✅ |
| t2_009 | 김치찌개 | ✅ | | ✅ | | |
| t2_010 | 잡채 | | ✅ | ✅ | | ✅ |
| t2_012 | 갈비구이 | | ✅ | ✅ | ✅ | |
| t2_013 | 순두부찌개 | ✅ | | ✅ | | ✅ |

### 3.3 친구별 preference 매트릭스

각 친구는 axis별로 `like` / `neutral` / `dislike` 중 하나를 갖는다. 음식 1개가 친구의 like axis와 매치되면 like 트리거, dislike axis와 매치되면 dislike 트리거.

| Axis | 어머니 (mother_01) | 아버지 (father_01) |
|------|:-----------------:|:-----------------:|
| spicy | dislike | **like** |
| sweet | like | neutral |
| salty | neutral | like |
| oily | dislike | like |
| mild | **like** | neutral |

### 3.4 사용자 명시 trait 반영

사용자 힌트: **"매운 거 못 먹는 친구는 호떡/갈비구이/김밥/잡채 좋아함"** (유지).

→ **어머니의 trait**:
- spicy `dislike`
- 호떡(sweet+oily): sweet `like` 트리거 → ✅ 좋아함 (oily dislike 있으나 sweet like가 우선; §3.5 우선순위 룰)
- 갈비구이(sweet+salty+oily): sweet `like` 트리거 → ✅ 좋아함
- 김밥(salty+mild): mild `like` → ✅ 좋아함
- 잡채(sweet+salty+mild): mild + sweet `like` → ✅ 좋아함

**v0.2 추가 (C-2 lock)**:
- **순두부찌개(spicy+salty+mild)** = 어머니 dislike 후보: spicy(D=-1) + salty(N=0) + mild(L=+1) → net 0 (matrix balanced)
- 매운 카테고리 일관성 유지: 양념치킨이 어머니 dislike axis(spicy+oily)였던 것과 달리, 순두부찌개는 mild(L)가 상쇄 → "어머니가 매운 게 부담스럽지만 두부라서 한 입은 먹음" 정서.
- 양념치킨 dislike axis 매핑(spicy+oily 동시 dislike) 삭제, 순두부찌개로 치환.

사용자 trait 정확히 매핑 완료 (v0.2).

### 3.5 우선순위 룰 (한 음식이 like + dislike 동시 트리거)

각 친구별로 한 음식이 like axis와 dislike axis 양쪽에 걸리면 **like 우선** (정서 톤 친화):
- 어머니가 호떡(sweet=like, oily=dislike) 먹을 때 → **like 1, dislike 0** (단맛 우선)
- 어머니가 콘도그(sweet+salty+oily) 먹을 때 → sweet=like, oily=dislike → **like 1, dislike 1 동시** (서로 상쇄, 점수 영향 0)

**최종 효과**:
- net_likes = max(0, like_axis_count - dislike_axis_count)
- net_dislikes = max(0, dislike_axis_count - like_axis_count)

### 3.6 어머니 / 아버지 음식별 net 효과

| food_id | 음식 | 어머니 axis | 어머니 net | 아버지 axis | 아버지 net | 합산 |
|---------|------|-------------|:---------:|-------------|:---------:|:----:|
| t1_001 | 호떡 | sweet(L)+oily(D) | +1·-1 → 0 | (none) | 0 | 0 |
| t1_002 | 라면 | spicy(D)+salty(N) | -1 | spicy(L)+salty(L) | +2 | net +1 |
| t1_003 | 떡볶이 | spicy(D)+sweet(L) | 0 | spicy(L) | +1 | +1 |
| t1_004 | 김밥 | salty(N)+mild(L) | +1 | salty(L)+mild(N) | +1 | +2 |
| t1_005 | 김치볶음밥 | spicy(D)+salty(N)+oily(D) | -2 | spicy(L)+salty(L)+oily(L) | +3 | +1 |
| t1_006 | 해물파전 | salty(N)+oily(D) | -1 | salty(L)+oily(L) | +2 | +1 |
| t1_007 | 콘도그 | sweet(L)+salty(N)+oily(D) | 0 | salty(L)+oily(L) | +2 | +2 |
| t2_008 | 비빔밥 | spicy(D)+mild(L) | 0 | spicy(L) | +1 | +1 |
| t2_009 | 김치찌개 | spicy(D)+salty(N) | -1 | spicy(L)+salty(L) | +2 | +1 |
| t2_010 | 잡채 | sweet(L)+salty(N)+mild(L) | +2 | salty(L) | +1 | +3 |
| t2_012 | 갈비구이 | sweet(L)+salty(N)+oily(D) | 0 | salty(L)+oily(L) | +2 | +2 |
| t2_013 | 순두부찌개 | spicy(D)+salty(N)+mild(L) | 0 | spicy(L)+salty(L)+mild(N) | +2 | +2 |

**관찰 (v0.2 갱신)**:
- **아버지는 거의 모든 음식 like** (T1·T2 12음식 중 11개 net positive). → "아빠는 가리지 않음" 캐릭터 성격 일치. 순두부찌개도 spicy+salty 둘 다 like → +2.
- **어머니는 호불호 명확**. 사용자 명시 4음식(호떡/갈비/김밥/잡채) 중 김밥·잡채가 net positive, 호떡·갈비는 0 (oily 상쇄). 순두부찌개도 net 0 (spicy dislike + mild like 상쇄) → "엄마는 매운 거 부담스럽지만 두부니까 한 입은" 정서 카피 hook.
- **양친 합산 음식 차이**: 김밥·잡채·콘도그·갈비·**순두부찌개** = +2 (가족 최고 선호 그룹), 라면·떡볶이·해물파전·비빔밥·김찌 = +1 (적정), 호떡 = 0 (어머니 단독 음식 선호 메뉴 후보).
- **v0.1 대비 변동**: 양념치킨(+1) 제거 → 순두부찌개(+2) 등장. T2 가족 최고 선호 음식이 1개 늘어남(갈비·순두부 페어 = "가족 식탁 어머니의 끓이기 + 아버지의 굽기" 정서 arc).

⚙️ **alpha 조정 후보**: 어머니 oily dislike를 neutral로 완화하면 호떡·갈비가 +1로 상승. 의도된 trait 강도 유지 vs 정서 톤 부드러움 trade-off.
> v0.2 추가 후보: 어머니 mild like를 strong-like(+2 weight)로 부스트 시 순두부찌개·김밥·잡채가 강화. balance-config v0.2 C-4 lock(Stage 3 부드러움)과 정합.

### 3.7 점수 영향 공식

`balance-config.md` §5.1 sync:

```
preference_modifier = (net_likes_total × friends.like_bonus_pct)
                    - (net_dislikes_total × friends.dislike_penalty_pct)

// 기본 ±5% per net point. 양친 net 합산.
// score_pre + preference_modifier (clamp01) × 100 → score_final
```

예: 김밥 Round, base score 80 → preference_modifier = (2 × 0.05) - 0 = +0.10 → 90점 → **★3 진입 가능**.
예: 호떡 Round, base score 80 → +0 → 80점 유지.

> ★ 임계는 변하지 않음. 점수만 영향. (`friends.preference_affect_stars = false`)

### 3.8 Scene 3 식탁 reaction 표현

호불호는 **점수 영향 + 시각 reaction 강화** 두 가지로 표현.

| 상태 | 어머니 reaction | 아버지 reaction |
|------|----------------|----------------|
| net_likes ≥ 1 (좋아함) | Happy 표정 + 하트 particle | Happy + 엄지척 |
| net_dislikes ≥ 1 (싫어함) | Subtle (살짝 끄덕, 표정 어두움) | Subtle + "음..." |
| net = 0 (중립) | Subtle (default) | Subtle (default) |

> art-style §3.5 표정 anchor 3종(Neutral/Happy/Subtle)으로 cover 가능. dislike 전용 추가 표정 anchor는 MVP 배제 (Subtle 재사용).

---

## 4. 음식 정렬을 활용한 retention hook

### 4.1 Daily "오늘의 메뉴" 제안

호불호 시스템 기반 LiveOps hook:
- 매일 1 음식에 대해 "어머니가 좋아하는 음식이에요" 또는 "아버지가 오늘 매운 게 당기시대요" 메시지.
- 해당 음식 Round에서 net_likes_total 영구 +1 보너스 (1회 한정).
- Daily login retention 신호.

> MVP 직후 LiveOps에 추가 권고. 본 sprint 범위 외 (스펙만 기록).

---

## 5. Friend ScriptableObject schema (unity-dev sync)

```csharp
// (개념적 정의 — 실제 코드는 unity-dev 책임)
public class FriendDefinition : ScriptableObject {
    public string friendId;            // "mother_01" / "father_01"
    public string nameKo;
    public string nameEn;
    public int unlockLevel;            // 11 (양친 동시)
    public FriendPersonality personality;
    public PreferenceAxisMatrix preferences; // 5 axis × {like,neutral,dislike}
    public Sprite portraitNeutral;
    public Sprite portraitHappy;
    public Sprite portraitSubtle;
    public LocalizedString voiceStar3;
    public LocalizedString voiceLikeReaction;
    public LocalizedString voiceDislikeReaction;
}

public enum PreferenceState { Like, Neutral, Dislike }
public class PreferenceAxisMatrix {
    public PreferenceState spicy, sweet, salty, oily, mild;
}
```

> 본 schema는 GDD §6.3 `Friend.preferences` (FoodTag[])를 axis 매트릭스로 구체화. unity-dev에 다음 sprint에서 위임.

---

## 6. Post-Launch Hook (interface 호환 보장)

ADR-003 post-launch Month 3~4에 친구 +3~5명 추가 예정. 본 MVP 설계가 호환되는지 점검.

### 6.1 axis 5종 유지 + 가중치 확장
- 5 axis 자체는 유지 (마이그레이션 X).
- 새 친구는 같은 5 axis 위 다른 like/dislike 조합. 예시:
  - **친구 A (분식 매니아)**: spicy=like, oily=like, mild=dislike → 떡볶이·콘도그 강선호
  - **친구 B (어린 동생)**: sweet=like, spicy=dislike → 호떡·잡채 강선호
  - **친구 C (해외 친구)**: mild=neutral, K-food 모든 음식 +0.5 base bonus axis (post-launch axis 1종 추가 검토)

### 6.2 친구 슬롯 확장 schema
- ScriptableObject `friendId` 만 추가, preference 매트릭스 재사용.
- Scene 3 식탁 인원 동적 (현재 2명 → Tier 3는 1~3명, Tier 4 4~6명).
- `preference_modifier` 합산 공식은 친구 N명까지 그대로 작동 (clamp01로 폭주 방지).

### 6.3 호불호 axis post-launch 확장 후보 (interface hook만)
- **regional**: 전라/경상/제주 등 지역 음식 axis (Korean Food Pack DLC 출시 시).
- **temperature**: 뜨거운 / 차가운 (냉면 vs 찌개) — Tier 3+ 음식 추가 시 검토.
- 새 axis는 schema migration 필요 — pm 검토.

### 6.4 친구 unlock 메커닉 확장
- Tier 3 = 친구 초대 (Friend C/D/E unlock).
- Tier 4 = 친구 모임 (전원 식탁 등장).
- Tier 5 = 명절 잔칫상 (양친 + 친구 + 친척).
- 모든 unlock은 `unlock_level` int field로 cover.

---

## 7. 변경 이력
- **2026-05-24 v0.2** (supersedes v0.1) — C-2 lock 적용. §3.2 axis 매트릭스에서 t2_011 양념치킨 행 → t2_013 순두부찌개 행 치환 (axis: spicy+salty+mild). §3.4 어머니 trait에 순두부찌개 dislike(spicy) + mild(L) 상쇄 일관성 명시. §3.6 net effect 표 갱신 — 순두부찌개 어머니 net 0 / 아버지 +2 / 합산 +2 (가족 최고 선호 그룹 +1). post-launch 친구 axis 확장 hook 무변경. 사용자 trait("매운 거 못 먹는 친구") 매핑 유지.
- **2026-05-23 v0.1 (superseded)** — 초안. 양친(어머니+아버지) 2명 채택. L11 동시 unlock 결정(U-2). 호불호 5 axis. 음식 12개 axis 태깅. 친구별 preference 매트릭스. 사용자 명시 trait 어머니에 반영. 점수 ±5% per net point. Scene 3 reaction Subtle/Happy 매핑.
