# Motion Spec — ADR-005 Stage 2A/2B/2C Tool Animation

> 버전: **v0.1 (2026-05-31)** — M2 prerequisite design sprint D1
> 작성자: game-designer
> 상위 문서: [`cooking-mechanics.md` v0.7](cooking-mechanics.md), [`../balance-config.md` v0.4](../balance-config.md), [ADR-005](../decisions.md#adr-005)
> 의존: M1 art sprint anchor 71 LOCK (조리도구 12 TOOL-01~12 + cut 7 CUT-00~06 + ingredient whole 12 + ingredient cut 12 + 음식 12).
>
> ⚠️ **Option 1 motion lock** (사용자 명시 2026-05-31): **Godot AnimationPlayer Transform animation only**. Single sprite 회전/이동/스케일 keyframe만, frame 추가 art 0건. 재료 변화 = whole sprite fade-out → cut sprite fade-in transition.

---

## 0. 목적

ADR-005 4-stage (Stage 2A 재료 준비 rhythm tap / Stage 2B 조리 방법 / Stage 2C 조리 시간) 메커닉에서 **각 음식 × 도구 × motion**을 godot-dev가 AnimationPlayer로 즉시 구현 가능한 수준으로 lock.

본 문서가 정의하는 것:
1. **12 음식 × 3 stage × 도구 sequence** (어떤 도구가 어느 stage에서 등장하는가)
2. **도구별 motion primitive** (rotation / translation / scale + duration)
3. **BPM 매핑** (motion 속도가 무엇과 sync되는가)
4. **AnimationPlayer keyframe spec** (rotation deg / translation px / duration ms 명시)

본 문서가 정의하지 않는 것:
- VFX (steam/스파크/물방울) — art-director M1 후반 VFX sprint 영역
- Sound (조리 SFX, BPM 메트로놈) — art-director sound 겸직 Phase 2
- UI (Knife indicator UI / Skip 버튼 / Hint UI) — ui-designer

---

## 1. 도구 Motion Primitive 카탈로그 (Option 1 Transform-only)

각 도구는 single sprite (M1 LOCK TOOL-01~12)이며, AnimationPlayer로 아래 Transform 변화만 수행.

> Asset path: `assets-processed/tools/tool_XX_<name>.png` (transparent PNG, M1 rembg 결과). Pivot은 도구별 자연스러운 회전 중심 (칼 = 칼끝 반대 손잡이 쪽 1/3 지점 / 가위 = 두 날 교차점 / 주걱 = 손잡이 끝 / 뒤집개 = 손잡이 끝).

### 1.1 칼 (CUT-00 단독 sprite, 도마와 페어로 Stage 2A 등장)

| Primitive | 값 | 비고 |
|-----------|---|------|
| **Type** | Y축 translation (위↕아래) | rotation 거의 없음 (자연스러운 down stroke만 ±3° optional) |
| **Range** | y: 0 px (rest, raised) → +60 px (cut, board contact) | 1024×1024 anchor 기준 |
| **Duration per cycle** | BPM-driven (§3.1 표 참조) | 1 cycle = down-stroke (raise→cut→raise back to rest) |
| **Perfect tap timing** | Down-stroke의 최저점 ±perfect_window_ms (default ±80ms) | 도마 닿기 직전 = perfect (사용자 시각 통합 cue, 별도 rhythm UI 불필요) |
| **Sprite** | TOOL-knife (M1 cut anchor CUT-00 base에서 칼만 분리) | 도마는 정적 background sprite |

### 1.2 가위 (TOOL-12 한식 가위, 김 / 면 자르기)

| Primitive | 값 | 비고 |
|-----------|---|------|
| **Type** | 회전 (open ↔ close, 두 날 사이 각도 변화) | 두 sprite (handle + blade) 또는 single sprite + 손잡이 pivot 회전 |
| **Range** | ±15° (총 30° angle, open=+15° / close=-15° / rest=0°) | open 상태 yellow handle 시인성 |
| **Duration per cycle** | BPM-driven | 1 cycle = open→close→open |
| **Perfect tap timing** | Close 최고점 (날 맞닿는 순간) | |
| **사용 음식** | 라면(파 컷, 보조) / 잔치국수(김 garnish, 보조) | 본 sprint MVP에서 가위는 Stage 2A 사용 X, post-launch 후보 (칼 송송썰기로 통일) |

> **MVP 결정**: 가위는 Stage 2A primary cut tool로 사용하지 않는다. M1 TOOL-12 가위 sprite는 시각 자산으로만 보존 (Stage 2B 조리 방법 선택 카드 thumbnail 등 정적 용도). 본 motion spec은 post-launch 확장 시 참조.

### 1.3 주걱 (TOOL-07 silver-gray paddle, stir motion)

| Primitive | 값 | 비고 |
|-----------|---|------|
| **Type** | 좌↔우 translation + slight rotation | circular stir 효과 |
| **Range** | x: -40 px ↔ +40 px (총 80 px) + rotation ±20° (좌측일 때 -20°, 우측일 때 +20°) | 냄비/팬 위 시각 |
| **Duration per cycle** | BPM-driven (Stage 2B/2C cook 행위) | 1 cycle = 좌→우→좌 (한 stir) |
| **Perfect tap timing** | 좌/우 양 끝 도달 순간 양쪽 모두 (1 cycle = 2 taps) | 또는 단일 끝점만 (BPM 절반) — §3.2 결정 |
| **사용** | Stage 2C 끓이기·볶기 stir 행위 |  |

### 1.4 뒤집개 (TOOL-08 spatula, flip motion)

| Primitive | 값 | 비고 |
|-----------|---|------|
| **Type** | Y축 180° flip (rotation_y 0° → 180°) + slight Y translation arc | 부치기 (해물파전·콘도그 등) |
| **Range** | rotation_y: 0° → 180° → 0° / y: 0 → -30 px arc → 0 | 2D Godot는 Sprite2D.flip_h 토글 + Tween scale.x 1→-1 simulate (또는 AnimationPlayer scale track) |
| **Duration per flip** | 0.4 ~ 0.5s (BPM 80) | 1 flip = 1 tap (single action, not continuous) |
| **Perfect tap timing** | Flip 중간 (90° = pancake mid-air apex) | |
| **사용** | Stage 2C 부치기 (해물파전 C-3 lock MVP는 단일 탭 + flip 미도입, post-launch flip mechanic 활성화) | 본 MVP는 spatula sprite 정적 표시만 (Stage 2B 카드 thumbnail) |

### 1.5 국자 (TOOL-06 ladle, scoop arc)

| Primitive | 값 | 비고 |
|-----------|---|------|
| **Type** | Arc translation (X+Y 동시) + rotation | 국물 음식 (라면·잔치국수·순두부찌개) Stage 2C 마무리 cue |
| **Range** | x: 0 → +60 px / y: +20 px → 0 (퍼 올리는 arc) + rotation: -15° → +15° (퍼 올림 동작) | |
| **Duration** | 1.0s (1 scoop, slow ceremony 정서) | BPM 무관 (Stage 2C 마무리 transition cue) |
| **Perfect tap timing** | 사용 X (Stage 2A rhythm tap 도구가 아님) | 시각 cue만 |

### 1.6 집게 (TOOL-09 tongs, grip + lift)

| Primitive | 값 | 비고 |
|-----------|---|------|
| **Type** | Open/close rotation (~20° angle, 가위와 유사) + Y lift translation | 굽기 (갈비구이) Stage 2C |
| **Range** | rotation: ±10° (총 20°) + y: 0 → -40 px (lift) | open=+10° / close=-10° |
| **Duration** | 0.6s (close + lift) per cycle | BPM-driven (갈비구이 stage 2C 70 BPM) |
| **Perfect tap timing** | Close + lift 정점 (고기 들어 올림 순간) | |
| **사용** | 갈비구이 (Stage 2C grip-and-lift 5회) | |

### 1.7 김발 (TOOL-10 bamboo mat, roll)

| Primitive | 값 | 비고 |
|-----------|---|------|
| **Type** | Roll motion (translation x + slight rotation) | 김밥 Stage 2C 말기 |
| **Range** | x: 0 → +80 px (좌→우 말기) + rotation: 0° → 360° (한 바퀴) | |
| **Duration** | 1.5s (no-cook 말기 ceremony) | BPM 무관 (Stage 2C 단일 인디케이터 tap, 김밥 cook_time 4s 짧음) |
| **Perfect tap timing** | Roll arc 중 perfect_width 구간 (cooking-mechanics §4.3) | |
| **사용** | 김밥 Stage 2C 단독 | |

### 1.8 그릇 + 주걱 (TOOL-11 mixing bowl + TOOL-07 paddle, bibim)

| Primitive | 값 | 비고 |
|-----------|---|------|
| **Type** | 주걱 circular motion (orbit) + 그릇 정적 | 비빔밥 Stage 2C 비비기 |
| **Range** | 주걱 orbit radius 50 px, 1 full circle = 360° | 그릇 = static bg sprite |
| **Duration per cycle** | BPM-driven (비비기 90 BPM = ~667ms per orbit) | 1 cycle = 1 orbit = 1 tap |
| **Perfect tap timing** | Orbit 12시 방향 정점 (또는 6시 — godot-dev 결정) | |
| **사용** | 비빔밥 Stage 2C 5회 (no-cook mix) | |

### 1.9 양념재우기 (marinade massage, hand sprite or 손바닥 icon)

| Primitive | 값 | 비고 |
|-----------|---|------|
| **Type** | 손바닥/손 sprite Y translation (위↕아래 누름) + slight scale (squish 0.95 ↔ 1.0) | 불고기 Stage 2A marinade rhythm |
| **Range** | y: 0 → +20 px (누름) + scale: 1.0 → (0.95, 1.05) anisotropic (가로 늘림 + 세로 줄임 = squish) | |
| **Duration** | BPM 60 driven (1 sec per press) | 1 press = 1 tap |
| **Perfect tap timing** | 최저점 (squish 정점) | 마사지 정서 강조 |
| **사용** | 불고기 (Stage 2A marinade-only) / 갈비구이는 양념 자동 + Stage 2C grip 메커닉이라 marinade rhythm 미적용 | M1 art sprint에 손바닥/hand sprite anchor 부재 → **art-director 후속 미니 sprint 권고** (단일 sprite, ~$0.04 generation, Cool Sage bg + 통일 톤) |

---

## 2. 12 음식 × Stage × 도구 × Motion 매핑 (D1 main 표)

> 약어: CUT = Stage 2A cut style anchor / TOOL = M1 조리도구 anchor.
> **Stage 2A는 rhythm tap (BPM × tap 수)** / **Stage 2B는 단일 선택 (5~10s, 도구는 정적 카드 thumbnail)** / **Stage 2C는 단일 탭 timing game (cook_time_sec)** — ADR-005 + cooking-mechanics v0.7.

| food_id | 음식 | Stage 2A 도구·motion (BPM·taps) | Stage 2B 도구 (카드) | Stage 2C 도구·motion |
|---------|------|-------------------------------|---------------------|---------------------|
| t1_002 | 라면 | 칼 + 도마 / 대파 송송 (CUT-05) / **100 BPM × 4 taps** / Y translate 60px down-stroke | TOOL-02 냄비 + TOOL-01 가스레인지 (끓이기 카드) | TOOL-02 냄비 + TOOL-06 국자 마무리 / cook 9s timing bar |
| t1_003 | 떡볶이 | 칼 + 도마 / 어묵 어슷썰기 (CUT-03) / **100 BPM × 5 taps** / Y translate 60px + slight diagonal | TOOL-02 냄비 (끓이기/조리기 카드) | TOOL-02 + TOOL-07 주걱 stir / cook 13s timing bar (perfect 0.10) |
| t1_004 | 김밥 | 칼 + 도마 / 단무지 통썰기 (CUT-04) / **70 BPM × 3 taps** / Y translate 60px slow down-stroke | TOOL-10 김발 (말기 카드, no-cook) | TOOL-10 김발 roll motion / cook 4s timing bar (perfect 0.19, 짧음 보정) |
| t1_005 | 김치볶음밥 | 칼 + 도마 / 김치 깍둑썰기 (CUT-06) / **90 BPM × 4 taps** / Y translate 60px + slight X (cube cut 변별) | TOOL-03 후라이팬 + TOOL-01 (볶기 카드) | TOOL-03 팬 + TOOL-07 주걱 stir orbit / cook 10s timing bar |
| t1_006 | 해물파전 | 칼 + 도마 / 쪽파 송송 (CUT-05) / **110 BPM × 5 taps** / Y translate 60px fine slice | TOOL-03 후라이팬 + TOOL-01 (부치기 카드) | TOOL-03 팬 + TOOL-08 뒤집개 (MVP 단일 탭 C-3 lock, flip motion 미도입) / cook 14s timing bar (perfect 0.09) |
| t1_007 | 한국식 콘도그 | 칼 + 도마 / 소시지 통썰기 X — **반죽 묻히기 substitute** (단일 탭 dip motion, BPM 80 × 3 taps, 콘도그를 반죽에 dip) | TOOL-04 튀김기 + TOOL-01 (튀기기 카드) | TOOL-04 튀김기 dip motion / cook 8s timing bar (perfect 0.13 관대) |
| t1_008 | 잔치국수 | 칼 + 도마 / 대파 송송 (CUT-05) / **110 BPM × 4 taps** / Y translate 60px (N-1 lock placeholder 유지) | TOOL-02 냄비 + TOOL-01 (끓이기 카드) | TOOL-02 냄비 + TOOL-06 국자 마무리 / cook 12s timing bar |
| t2_008 | 비빔밥 | 칼 + 도마 / 당근 채썰기 (CUT-02) / **115 BPM × 5 taps** / Y translate 60px + slight X drift (julienne 변별) | TOOL-11 mixing bowl + TOOL-07 주걱 (비비기 카드, no-cook) | TOOL-11 + TOOL-07 주걱 orbit (90 BPM 5 cycles, bibim) / cook 5s timing bar (perfect 0.13) |
| t2_010 | 잡채 | 칼 + 도마 / 당근 채썰기 (CUT-02) / **120 BPM × 6 taps** / Y translate 60px + slight X | TOOL-03 후라이팬 + TOOL-01 (볶기 카드) | TOOL-03 팬 + TOOL-07 주걱 stir + TOOL-09 집게 toss (이중 도구) / cook 16s timing bar (perfect 0.06) |
| t2_012 | 갈비구이 | 칼 + 도마 / 마늘 다지기 (CUT-01) / **140 BPM × 6 taps** / Y translate 60px rapid down-stroke (fastest cut, 사용자 명시 "타이밍 핵심" 정합) | TOOL-05 그릴 + TOOL-01 (굽기 카드) | TOOL-05 그릴 + TOOL-09 집게 grip-and-lift (70 BPM 5 cycles) / cook 18s timing bar (perfect 0.04 좁음) |
| t2_013 | 순두부찌개 | 칼 + 도마 / 호박 통썰기 (CUT-04) / **80 BPM × 4 taps** / Y translate 60px slow + slight X (round slice variance) | TOOL-02 냄비 (ttukbaegi 모방) + TOOL-01 (끓이기 카드) | TOOL-02 + TOOL-06 국자 마무리 (계란 풀기) / cook 14s timing bar (perfect 0.07) |
| t2_014 | 불고기 | **손바닥 + marinade bowl / 양념재우기 (CUT-00 marinade rhythm) / 60 BPM × 3 taps** / Y translate 20px press + scale squish (0.95↔1.05) | TOOL-03 후라이팬 + TOOL-01 (볶기 카드) | TOOL-03 팬 + TOOL-07 주걱 stir (100 BPM 8 cycles) / cook 16s timing bar (perfect 0.09) |

### 2.1 매핑 요약 통계

- **Stage 2A primary 도구**: 칼+도마 11/12, 손바닥+marinade bowl 1/12 (불고기 only)
- **Cut style 분포 (12음식)**: CUT-05 송송 3 (라면·해물파전·잔치국수) / CUT-02 채썰기 2 (비빔밥·잡채) / CUT-04 통썰기 2 (김밥·순두부찌개) / CUT-06 깍둑썰기 1 (김치볶음밥) / CUT-03 어슷썰기 1 (떡볶이) / CUT-01 다지기 1 (갈비구이) / CUT-00 marinade 1 (불고기) / dip substitute 1 (콘도그)
- **BPM 분포**: 60 (1) / 70 (1) / 80 (2) / 90 (1) / 100 (2) / 110 (2) / 115 (1) / 120 (1) / 140 (1) — Cut Style별 BPM (balance-config §7) 정합
- **Stage 2B 도구**: 끓이기 (TOOL-02 냄비) 5음식 / 볶기 (TOOL-03 팬) 4음식 / 부치기 (TOOL-03 팬 + TOOL-08 뒤집개) 1 / 튀기기 (TOOL-04 튀김기) 1 / 굽기 (TOOL-05 그릴) 1 / 말기 (TOOL-10 김발) 1 / 비비기 (TOOL-11 bowl) 1
- **Stage 2C 보조 도구**: TOOL-07 주걱 stir 5음식 / TOOL-06 국자 마무리 3음식 / TOOL-09 집게 2음식 (갈비·잡채) / TOOL-10 김발 1 (김밥) / TOOL-11+TOOL-07 비빔 1 (비빔밥) / TOOL-08 뒤집개 1 (해물파전, MVP 정적)
- **Stage 2A multi-cut sequence 후보** (open question, M2 alpha 후 결정): 불고기 (양념재우기 60 BPM × 3 → 양파 채썰기 CUT-02 115 BPM × 4 sequential) — 본 v0.1은 양념재우기 단독 lock.

### 2.2 사용자 confirm 필요 사안 (open)

1. **콘도그 Stage 2A** — 칼/도마 cut 메커닉이 의미적으로 어색 (소시지 절단 X, 반죽 묻히기/dip이 핵심). 본 v0.1은 "반죽 묻히기 dip motion 단일 탭 (BPM 80 × 3 taps)" lock. **art-director sync 필요**: 콘도그 dip motion에 별도 sprite 필요 여부 (M1 LOCK ingredient cut 안에 콘도그 dip 결과물 ICUT 매핑 검토). 사용자 confirm 또는 game-designer 후속 sprint.
2. **불고기 multi-cut sub-sequence** — Stage 2A에서 양념재우기 60 BPM × 3 taps 단독 vs 양념재우기 → 양파 채썰기 CUT-02 115 BPM × 4 taps sequential. 본 v0.1은 단독 lock (balance-config v0.3.2 §7.1 권고 유지). alpha 후 multi-cut sequence가 cooking matching 메커닉 풍부함 vs 학습 부담 trade-off 검증 → M2 후반 결정.
3. **잔치국수 hero ingredient 최종 lock** — 대파 송송 110 BPM × 4 taps (placeholder, balance-config v0.3.2 §7.1 권고) vs 애호박 통썰기 70 BPM × 3 taps (정통 잔치국수 시그니처). 본 v0.1은 placeholder 유지. 사용자 결정 대기.
4. **해물파전 flip mechanic post-launch 활성화 시점** — C-3 lock 2026-05-24 (MVP 미도입). 본 motion spec은 flip motion primitive(§1.4)를 사양만 정의, MVP 빌드에서 사용 X.

---

## 3. AnimationPlayer Keyframe Spec (godot-dev 후속 구현 prerequisite)

### 3.1 칼 down-stroke (Stage 2A primary, 11/12 음식)

**Godot AnimationPlayer track 구성** (per BPM):

```
Animation: knife_cut_loop
Length: 60.0 / BPM seconds (예: 100 BPM = 0.6s)
Loop: true

Track 1 (Sprite2D:position:y):
  Time 0.000s   → 0 px    (rest, raised)
  Time 0.45 × L → +60 px  (cut, board contact)
  Time 0.55 × L → +60 px  (hold 10% beat for perfect window)
  Time 1.000 × L → 0 px   (return to rest)

Track 2 (Sprite2D:rotation_degrees) [optional decoration]:
  Time 0.000s   → -3°
  Time 0.50 × L → 0°  (vertical at contact)
  Time 1.000 × L → -3°

Track 3 (Method call "_on_perfect_window") [logic]:
  Time 0.45 × L → emit "perfect_window_start" signal
  Time 0.55 × L → emit "perfect_window_end" signal
```

> BPM → cycle_length 변환: `cycle_length_sec = 60.0 / BPM`. 예시:
> - 60 BPM (양념재우기) → 1.000s per cycle
> - 70 BPM (통썰기) → 0.857s
> - 90 BPM (깍둑썰기) → 0.667s
> - 100 BPM (송송·어슷) → 0.600s
> - 110 BPM (송송 fast) → 0.545s
> - 115 BPM (채썰기) → 0.522s
> - 120 BPM (채썰기 fast) → 0.500s
> - 140 BPM (다지기) → 0.429s

> **Perfect window mapping**: balance-config §6 `cooking.prep.perfect_window_ms = 80` (LOCKED). cycle_length 1.0s 기준 perfect window = 0.16s (= 0.08s × 2) = cycle의 16%. cycle_length 0.429s (140 BPM) 기준 = 0.16s / 0.429s = **37% of cycle** (다지기는 perfect window가 cycle 대비 상대적으로 넓음 = 빠른 BPM 보상).

### 3.2 주걱 stir (Stage 2C, 5음식)

```
Animation: paddle_stir_loop
Length: 60.0 / BPM seconds
Loop: true

Track 1 (Sprite2D:position:x):
  Time 0.000s   → -40 px
  Time 0.500s × L → +40 px
  Time 1.000s × L → -40 px

Track 2 (Sprite2D:rotation_degrees):
  Time 0.000s   → -20°
  Time 0.500s × L → +20°
  Time 1.000s × L → -20°

Track 3 (Method call): per-end perfect_window (1 cycle = 2 taps)
  Time 0.50 × L → emit (right-end tap)
  Time 1.00 × L → emit (left-end tap)
```

### 3.3 손바닥 marinade press (Stage 2A 불고기 only)

```
Animation: hand_marinade_press_loop
Length: 1.0s (60 BPM)
Loop: true

Track 1 (Sprite2D:position:y):
  Time 0.000s → 0 px (raised)
  Time 0.450s → +20 px (press down, squish)
  Time 0.550s → +20 px (hold 10% beat)
  Time 1.000s → 0 px (raise)

Track 2 (Sprite2D:scale):
  Time 0.000s → (1.0, 1.0)
  Time 0.500s → (1.05, 0.95) (squish anisotropic)
  Time 1.000s → (1.0, 1.0)

Track 3 (Method call):
  Time 0.45s → emit "perfect_window_start"
  Time 0.55s → emit "perfect_window_end"
```

### 3.4 가위 open/close (post-launch, sprite 보존)

```
Animation: scissors_snip_loop  [POST-LAUNCH, MVP 미사용]
Length: 60.0 / BPM seconds
Loop: true

Track 1 (Sprite2D:rotation_degrees):
  Time 0.000s   → +15° (open)
  Time 0.500s × L → -15° (close, blades meet)
  Time 1.000s × L → +15° (open)

Track 2 (Method call):
  Time 0.500s × L → emit "perfect_window" (close apex)
```

### 3.5 뒤집개 flip (post-launch C-3, MVP 정적)

```
Animation: spatula_flip_single  [POST-LAUNCH, MVP 미사용]
Length: 0.5s
Loop: false (one-shot per tap)

Track 1 (Sprite2D:scale:x):
  Time 0.000s → 1.0
  Time 0.250s → 0.0 (edge-on, 90° apex)
  Time 0.500s → -1.0 (flipped, 180°)

Track 2 (Sprite2D:position:y):
  Time 0.000s → 0 px
  Time 0.250s → -30 px (arc apex)
  Time 0.500s → 0 px

Track 3 (Method call):
  Time 0.250s → emit "perfect_window" (apex)
```

### 3.6 국자 scoop (Stage 2C 마무리 cue, 3음식)

```
Animation: ladle_scoop_oneshot
Length: 1.0s
Loop: false (Stage 2C 종료 cue)

Track 1 (Sprite2D:position:x):
  Time 0.000s → 0 px
  Time 1.000s → +60 px

Track 2 (Sprite2D:position:y):
  Time 0.000s → +20 px (deep in pot)
  Time 0.500s → 0 px (lifted)
  Time 1.000s → -10 px (raised)

Track 3 (Sprite2D:rotation_degrees):
  Time 0.000s → -15°
  Time 0.500s → 0°
  Time 1.000s → +15°
```

### 3.7 집게 grip-and-lift (Stage 2C 갈비구이)

```
Animation: tongs_grip_lift_loop
Length: 60.0 / 70 = 0.857s (70 BPM 갈비구이 grip)
Loop: true (5 cycles for galbi)

Track 1 (Sprite2D:rotation_degrees) [open/close gesture]:
  Time 0.000s   → +10° (open)
  Time 0.300s × L → -10° (close, grip)
  Time 0.857s × L → +10° (open, release)

Track 2 (Sprite2D:position:y):
  Time 0.000s → 0 px (down)
  Time 0.500s × L → -40 px (lift apex)
  Time 0.857s × L → 0 px (down)

Track 3 (Method call):
  Time 0.500s × L → emit "perfect_window" (lift apex)
```

### 3.8 김발 roll (Stage 2C 김밥, single-shot)

```
Animation: bamboo_mat_roll_oneshot
Length: 1.5s
Loop: false

Track 1 (Sprite2D:position:x):
  Time 0.000s → 0 px
  Time 1.500s → +80 px (rolled right)

Track 2 (Sprite2D:rotation_degrees):
  Time 0.000s → 0°
  Time 1.500s → +360° (one full roll)

Track 3 (Method call):
  Time 0.65s ~ 0.85s → emit "perfect_window" (perfect_width 0.19 of cook_time 4s)
```

### 3.9 그릇+주걱 bibim orbit (Stage 2C 비빔밥)

```
Animation: bibim_orbit_loop
Length: 60.0 / 90 = 0.667s (90 BPM 비비기)
Loop: true (5 cycles for bibimbap)

Track 1 (Sprite2D[paddle]:position:x):
  Time 0.000s → 0 px
  Time 0.167s × L → +50 px (3시)
  Time 0.333s × L → 0 px (6시)
  Time 0.500s × L → -50 px (9시)
  Time 0.667s × L → 0 px (12시 = top, perfect tap)

Track 2 (Sprite2D[paddle]:position:y):
  Time 0.000s → -50 px (12시)
  Time 0.167s × L → 0 px (3시)
  Time 0.333s × L → +50 px (6시)
  Time 0.500s × L → 0 px (9시)
  Time 0.667s × L → -50 px (12시)

Track 3 (Sprite2D[paddle]:rotation_degrees):
  Time 0.000s   → 0°
  Time 0.667s × L → 360° (paddle rotates with orbit)

Track 4 (Method call):
  Time 0.667s × L → emit "perfect_window" (12시 top, beat-aligned)
```

### 3.10 콘도그 반죽 dip (Stage 2A 콘도그 substitute, 칼 메커닉 대체)

```
Animation: corndog_batter_dip_oneshot  [BPM 80 driven, 3 taps total = 3 oneshots]
Length: 60.0 / 80 = 0.75s per dip
Loop: false (3회 one-shot, godot-dev에서 SequentialAnimationPlayer로 chain)

Track 1 (Sprite2D[corndog]:position:y):
  Time 0.000s → 0 px (above batter)
  Time 0.375s → +40 px (submerged in batter bowl)
  Time 0.750s → 0 px (lifted, coated)

Track 2 (Method call):
  Time 0.375s → emit "perfect_window" (submerge apex)

Track 3 (Particles2D drip) [VFX placeholder, post art-director]:
  Time 0.500s → enable batter drip particles
```

---

## 4. BPM ↔ Cut Style ↔ Hero Ingredient Cross-Reference

balance-config v0.4 §7 표 (`cooking.prep.bpm_by_cut_style`) sync:

| Cut Style | BPM (한식) | 12음식 적용 | Stage 2A primary tool |
|-----------|:---------:|------------|----------------------|
| 다지기 (CUT-01 mince) | 140 | t2_012 갈비구이 (마늘) | 칼 + 도마 |
| 채썰기 (CUT-02 julienne) | 115~120 | t2_008 비빔밥 (당근 115) / t2_010 잡채 (당근 120) | 칼 + 도마 |
| 어슷썰기 (CUT-03 diagonal) | 100 | t1_003 떡볶이 (어묵) | 칼 + 도마 |
| 통썰기 (CUT-04 round slice) | 70~80 | t1_004 김밥 (단무지 70) / t2_013 순두부찌개 (호박 80) | 칼 + 도마 |
| 송송썰기 (CUT-05 fine slice) | 100~110 | t1_002 라면 (대파 100) / t1_006 해물파전 (쪽파 110) / t1_008 잔치국수 (대파 110) | 칼 + 도마 |
| 깍둑썰기 (CUT-06 cube) | 90 | t1_005 김치볶음밥 (김치) | 칼 + 도마 |
| 양념재우기 (CUT-00 marinade) | 60 | t2_014 불고기 (얇은 소고기) | 손바닥 + marinade bowl |
| (반죽 dip substitute) | 80 | t1_007 콘도그 (소시지+반죽) | 콘도그 + batter bowl |

**Cook 행위 BPM (Stage 2C)** — stir/grip 등 cook 메커닉 BPM (Stage 2A rhythm tap과 별도):

| Cook 행위 | BPM | 적용 음식 | 도구 motion |
|----------|:---:|----------|------------|
| 끓이기 stir (slow) | 60 | 라면 / 잔치국수 / 순두부찌개 (마무리 stir 단일 탭) | TOOL-06 국자 scoop oneshot |
| 볶기 stir (medium-fast) | 100 | 김치볶음밥 / 잡채 / 불고기 / (떡볶이 마무리) | TOOL-07 주걱 stir loop |
| 부치기 flip | 80 | 해물파전 (MVP 단일 탭, flip motion 미적용) | TOOL-08 뒤집개 정적 |
| 굽기 grip | 70 | 갈비구이 | TOOL-09 집게 grip-and-lift loop |
| 튀기기 dip | 90 | 콘도그 (Stage 2C dip 단일 탭) | TOOL-04 튀김기 정적 + corndog dip oneshot |
| 비비기 bibim | 90 | 비빔밥 (Stage 2C orbit 5 cycles) | TOOL-11 + TOOL-07 orbit loop |
| 말기 roll | 60 (slow) | 김밥 (Stage 2C oneshot) | TOOL-10 김발 roll oneshot |

> Stage 2C 도구 motion은 Stage 2A rhythm tap과 다르게 **단일 탭 timing game (cooking-mechanics §4)** 위주이며, 도구 motion은 timing bar inidicator와 별개로 시각 ambient. 일부 음식 (갈비·비빔밥·잡채)은 Stage 2C에 보조 rhythm 메커닉을 가질 수 있으나 본 v0.1은 cooking-mechanics §4의 단일 탭 모델 유지.

---

## 5. Godot 구현 의존성 (godot-dev 후속 sprint trigger)

### 5.1 Prerequisite asset (M1 LOCK 활용)

| 파일 path (assets-processed) | 용도 | 출처 (M1 anchor) |
|------------------------------|------|----------------|
| `cuts/cut_00_marinade_board.png` (TBD) | Stage 2A 양념재우기 bg | M1 CUT-00 base cutting_board (양념재우기 anchor 별도 작성 검토 — art-director open) |
| `cuts/cut_01_mince.png` ~ `cut_06_cube.png` | Stage 2A cut style 6 bg | M1 CUT-01~06 LOCK |
| `tools/tool_01_stove.png` ~ `tool_12_scissors.png` | Stage 2B/2C 도구 12종 | M1 TOOL-01~12 LOCK |
| `ingredients/ing_*_whole.png` | Stage 1 진열대 + Stage 2A pre-cut sprite | M1 ingredient_whole 12 LOCK |
| `ingredients/ing_*_cut.png` | Stage 2A post-cut transition target sprite | M1 ingredient_cut 12 LOCK |
| `hand_marinade.png` (TBD) | Stage 2A 불고기 손바닥 sprite | **art-director 미니 sprint 필요** (~$0.04, single sprite, Cool Sage bg, transparent) |
| `corndog_batter_bowl.png` (TBD) | Stage 2A 콘도그 batter bowl sprite | **art-director 미니 sprint 필요** OR M1 ingredient 안에 흡수 가능 |

### 5.2 godot-dev 구현 우선순위

1. **AnimationPlayer 9 sub-resource** (`.tres`) — §3.1~§3.10 keyframe spec 정확 transcribe. 단일 `tool_animations.tres` library file에 묶어 관리.
2. **Knife indicator 메인 노드** (`stage_2a_knife_indicator.tscn`) — 칼 sprite + 도마 bg + AnimationPlayer. signal `perfect_window_start/end` emit. Stage 2A round 시작 시 `play("knife_cut_loop")` + `speed_scale = (BPM / 100.0)` (또는 length 직접 set).
3. **Marinade indicator 노드** (`stage_2a_marinade_indicator.tscn`) — 손바닥 sprite + marinade bowl bg + AnimationPlayer. 불고기 only.
4. **Stage 2C 도구 motion 노드** — 음식별 SequentialAnimationPlayer (stir / grip / orbit / dip / roll). cooking-mechanics §4 timing bar와 sync.
5. **Rhythm tap input 처리** — `_unhandled_input` Tap 이벤트 시 현 시점 cycle 진행도 (`AnimationPlayer.current_animation_position`) 추출 → perfect_window_start/end 사이면 perfect 판정.
6. **BPM 데이터 binding** — `food.prep_bpm` (foods-database.csv) → AnimationPlayer length 계산 → 즉시 play. balance-config Remote Config `cooking.prep.bpm_by_cut_style` fallback.

### 5.3 단계적 구현 추천 순서 (M2 sprint plan)

1. **W1**: AnimationPlayer 칼 down-stroke (§3.1) + 라면 (100 BPM × 4 taps) round 단독 구현 → end-to-end Stage 2A 검증.
2. **W2**: Cut style 6 BPM 음식 11종 확장 + ingredient cut transition.
3. **W3**: 손바닥 marinade (§3.3) + 불고기 round.
4. **W4**: Stage 2C 도구 motion (stir / grip / orbit / dip / roll) 6종 — 단일 탭 timing bar와 통합.
5. **W5+**: 콘도그 batter dip (§3.10) + 김발 roll + 김밥 마무리 + alpha 검증.

---

## 6. 사용자 confirm 필요 사안 정리 (D1 산출물)

| # | 항목 | 권고 | 결정 |
|---|------|------|------|
| 1 | 콘도그 Stage 2A = dip motion substitute (칼 cut 메커닉 비적용) | 80 BPM × 3 taps batter dip oneshot chain | 사용자 confirm OR game-designer 후속 |
| 2 | 불고기 Stage 2A multi-cut sub-sequence (양념재우기 단독 vs + 양파 채썰기 sequential) | 단독 유지 (v0.3.2 §7.1 권고 sync, alpha 후 재검토) | open |
| 3 | 잔치국수 hero ingredient final lock (대파 송송 110 BPM vs 애호박 통썰기 70 BPM) | placeholder 유지 (대파 110) | 사용자 결정 대기 |
| 4 | 양념재우기 손바닥/hand sprite 추가 art (M1 anchor 부재) | art-director 미니 sprint (~$0.04 single sprite) | art-director 위임 |
| 5 | 콘도그 batter bowl sprite 추가 art | art-director 미니 sprint OR M1 ingredient 흡수 | art-director 위임 |
| 6 | CUT-00 base anchor 활용 — 양념재우기 시그니처 표현 (현재 base cutting_board anchor) | CUT-00 별도 marinade anchor 신규 검토 | art-director sync |
| 7 | 가위 (TOOL-12) MVP Stage 2A primary 도구 미사용 (post-launch 후보) | 정적 시각 자산만 활용 (Stage 2B 카드 thumbnail) | lock |
| 8 | 뒤집개 flip motion C-3 lock MVP 미도입 → 본 motion spec §3.5는 사양만 정의 | 단일 탭 fallback (해물파전) | C-3 lock 유지 |

---

## 7. 변경 이력

- **2026-05-31 v0.1**: M2 prerequisite D1 신설. 12 음식 × 3 stage × 도구 sequence 매핑 (§2). 9종 AnimationPlayer keyframe spec (§3). BPM ↔ cut style ↔ hero ingredient cross-reference (§4). godot-dev 후속 구현 의존성 + 단계적 sprint plan (§5). 사용자 confirm 8건 (§6). Option 1 motion lock 명시 (Transform-only, frame art 추가 0건).
