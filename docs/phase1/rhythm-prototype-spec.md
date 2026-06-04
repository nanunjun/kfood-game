# Rhythm Prototype Spec — Phase 1 손맛 (구현 수준)

> 목적: 다음 sprint에서 **Godot 4.x로 즉시 프로토타입 빌드** 가능하도록 손맛의 기술·디자인·튜닝 파라미터를 구현 수준으로 고정.
> 상위: `phase1/production-priorities.md §1`(손맛 최우선), `scoring-v2`(판정·양념), `audio-pipeline-v1`(박자 정렬), `sound-guide §0.5`(layering).
> 단위: 시간 ms, 각도 deg, 색 HSL/HEX. 좌표 = Godot 2D(원점 좌상단, y↓). 기준 해상도 1080×1920(세로).

---

## 1. 노트 타입 분류 (Phase 1)
| 타입 | 시각 모티프 | 입력 조건 | 채점 기준점 | 사용 페이즈 |
|---|---|---|---|---|
| **Single Tap** | 둥근 노트, 페이즈색 테두리 | touch **down**이 판정선 도달 시각 | down 타임 | 칼질(개별 컷)·플레이팅 confirm |
| **Double Tap** | 노트에 작은 "×2" + 두 겹 링 | 짧은 간격 2회 down(간격 ≤180ms) | 두 down 각각 판정(평균) | 빠른 칼질·연타 볶기 |
| **Hold** | 길쭉한 바(머리+꼬리), 채워지는 트랙 | down 유지 → 목표 길이서 up | down(시작) + up(릴리스) 2점 | 양념 양·끓이기·재우기 |
| **Slide**(optional) | 화살표 꼬리 달린 노트 | down→방향 드래그(거리 ≥120px) | down + 드래그 완료 시각 | 휘젓기·볶기·말기(김밥) |
> Phase 1 필수 = Single·Double·Hold. Slide는 라면/잔치국수 프로토타입엔 미포함(여유 시 볶기 표현). 양념 양 입력은 **Hold(시간=양)** 또는 **Single 연타(횟수=양)** 둘 중 음식별 택1(`scoring-v2 §1.5`).

### 1.1 노트 상태 머신
`SPAWNED → APPROACHING → IN_WINDOW(판정가능) → (HIT|MISSED) → RESOLVED(피드백 후 free)`. Hold는 `HEAD_HIT → HOLDING → TAIL_RESOLVED`.

---

## 2. 채점 윈도우 (음식·레벨별 정확값)
판정선(JudgmentZone) 중심 기준 **half-window**(±ms). Perfect ⊂ Good, 그 밖 = Miss.
| Lv | Perfect ±ms | Good ±ms | 비고 |
|---|---|---|---|
| L1 | 90 | 200 | 입문 매우 관대 |
| L2 | 80 | 175 | |
| L3 | 70 | 150 | |
| L4 | 55 | 120 | |
| L5 | 50 | 110 | |
| L6 | 45 | 100 | |
| L7 | 40 | 90 | |
| L8 | 36 | 80 | Golden Spoon 톤 |
- **판정 우선순위**: |Δt| ≤ Perfect → Perfect / ≤ Good → Good / > Good(또는 미입력) → Miss.
- **Double Tap**: 두 down 각 판정 후 등급 = 둘 중 낮은 쪽(보수적). 간격 >180ms면 두 번째는 Miss 취급.
- **Hold**: head는 위 표대로, **tail(릴리스)** 은 ±(Good×1.25) 관용. 길이 오차 비율로 부분점수(아래 §2.2).
- **Slide**: down은 위 표, 드래그 완료는 ±(Good×1.5) + 거리·방향 충족 필요.

### 2.1 도구 효과(윈도우 확장) 계산식
```
eff_window = base_window × tool_mult × difficulty_assist
```
- `tool_mult`: Basic 칼 1.0 / **Pro 칼 1.3** / (Phase2 Master 1.6). Perfect·Good 동시 적용.
- `difficulty_assist`: 접근성 옵션(기본 1.0, "관대" 1.15). 누적 상한 1.6.
- 예: L4 Perfect 55ms + Pro 칼 → 55×1.3 = **71.5ms**. Good 120×1.3 = 156ms.

### 2.2 Hold 길이 부분점수 (양념·끓이기)
목표 길이 `T`, 실제 `t`. `e = |t−T|/T`.
```
hold_score = clamp(1 − (e / tol)², 0, 1)   # tol: L1 0.35 → L8 0.12 (편차 곡선과 동조)
```
양념 Hold는 이 score가 `scoring-v2`의 slot_score로 직결.

---

## 3. 히트 피드백 5중 자극 (판정별 정밀 명세)
모든 레이어 **동시 트리거**(같은 프레임). 좌표 = 노트 명중 지점.

### 3.1 시각 1 — 노트 폭발 파티클 (GPUParticles2D, one-shot)
| 판정 | 색(HSL) | 파티클 수 | 방출 반경 | 초기속도 | 수명 | 형태 |
|---|---|---|---|---|---|---|
| Perfect | 금색 H45 S90 L60 + 흰 코어 | 18 | 8px | 220px/s | 420ms | 별+원형 혼합, 중력0, 페이드아웃 |
| Good | 페이즈색 S70 L60 | 10 | 6px | 150px/s | 320ms | 원형, 부드러운 페이드 |
| Miss | 회색 H0 S0 L55 | 4 | 4px | 80px/s | 220ms | 작은 점, 즉시 페이드 |
> Perfect는 추가 "광륜"(스프라이트 scale 0.6→1.6, alpha 1→0, 300ms, ease_out).

### 3.2 시각 2 — 색상 글로우 (대상별)
| 대상 | Perfect | Good | Miss |
|---|---|---|---|
| 노트 | 금색 글로우 flash(alpha 0→0.9→0, 180ms) | 페이즈색 soft pulse(0→0.5→0, 200ms) | 없음(회색 dim 1프레임) |
| 판정선 | 금색 라인 bloom 1.5px→4px, 200ms | 옅은 pulse | — |
| 게이지(양념 시) | 해당 칸 금테 1프레임 | 칸 채움만 | — |
| 화면 비네트 | 따뜻한 금 6% 1프레임 | — | 모서리 회색 2% |
페이드 곡선: flash = ease_out_quad, pulse = ease_in_out_sine.

### 3.3 시각 3 — 점수 팝업 (Label + Tween)
| 판정 | 텍스트 | 폰트px | 색 | 모션 |
|---|---|---|---|---|
| Perfect | "PERFECT" | 64 | 금 #F2B705 + 흰 외곽 | scale 0.7→1.15→1.0(180ms back), y −60px translate, alpha 1→0(600ms 끝 200ms) |
| Good | "GOOD" | 48 | 크림 #FBF3E4 | scale 0.8→1.0, y −40px, alpha out 500ms |
| Miss | "MISS" | 40 | 회색 #9A938C | y −20px 살짝, alpha out 400ms, 미세 흔들림 X |
> 숫자 점수는 화면 비노출(정체성). 등급 단어 + 게이지/표정으로 표현.

### 3.4 청각 — SFX layering (§7 상세)
| 판정 | primary | secondary | 믹스 |
|---|---|---|---|
| Perfect | 액션 SFX(목제 톡 등) full | + 고역 "팅"(벨) + 짧은 리버브 | full mix, +0dB |
| Good | 액션 SFX | (없음) | mid, −3dB, 리버브 off |
| Miss | 둔탁 "툭"(저역) | + 짧은 노이즈 + 1 dissonant note(단2도) | low, −6dB |

### 3.5 촉각 — 햅틱 (§8 상세)
Perfect=짧고 단단 / Good=부드럽고 짧음 / Miss=가벼운 buzz. 양념 탭=마이크로. 표 §8.

### 3.6 통합 매트릭스 (한눈에)
| 레이어 | Perfect | Good | Miss |
|---|---|---|---|
| 파티클 | 금 18개+광륜 | 페이즈색 10개 | 회색 4개 |
| 글로우 | 금 flash 전대상 | soft pulse | dim only |
| 팝업 | PERFECT 64px back-scale | GOOD 48px | MISS 40px |
| SFX | full+벨+reverb | 액션만 | 툭+불협 |
| 햅틱 | 20ms sharp | 30ms soft | 50ms light buzz |
| 화면셰이크 | 없음(글로우로 충분) | 없음 | 모서리 2px 80ms |
> Perfect에 화면 셰이크는 **안 줌**(잦은 Perfect에 멀미). Miss만 미세 모서리 셰이크.

---

## 4. 양념 게이지 UI 명세
- **위치/크기**: 화면 하단 safe-area 위, 가로 중앙. 게이지 1개당 폭 120px·높이 280px, 양념 2~3종 가로 배열(간격 32px). 하단 마진 180px(엄지 도달 + 노트 트랙 비간섭).
- **구성**: 세로 칸형(예 6칸). 칸 채움 = 아래→위. 칸 위 작은 카운트 점(숫자 대신 pip; 결과 화면서만 숫자 자연어).
- **양념별 색·아이콘·재질**:
  | 양념 | 색 HEX | 아이콘 | 재질감 |
  |---|---|---|---|
  | 고춧가루 | #D34836 | 가루 통 | 거친 입자 텍스처 |
  | 간장 | #6B3D1F | 액체 병 | 광택 액체 |
  | 소금 | #F5F5F0 | 소금통 | 결정 반짝 |
  | 설탕 | #FBEAD2 | 설탕 스푼 | 흰 결정 |
  | 마늘 | #C9D67E | 마늘 | 연두 무광 |
  | 멸치육수 | #E0A82E | 국자 | 황금 액체 |
- **탭당 증분**: 칸 +1 — 칸이 아래에서 "딸깍" 솟아 채워짐(scale_y 0→1, 90ms, ease_out_back 살짝) + 칸 테두리 1프레임 글로우 + 양념별 SFX(고춧가루=사르륵, 간장=또르륵).
- **Hold 방식**: 채움이 연속 상승(시간=양), 목표 구간 도달 시 칸 색 진해짐.
- **Over(최대) 처리**: max 도달 시 **차분히** "MAX" 작은 라벨 + 칸 상단 옅은 금테(반짝임·경고색 X). 추가 입력은 무시(증가 안 함).
- **결과 화면 자연어**: `"고춧가루 4단위 · 간장 6단위 넣었어요"` → 손님 발화("조금 더 매콤하게")와 연결. (수치는 결과 복기용만.)

---

## 5. 노트 강하 곡선·렌더링
- **Trajectory**: 디폴트 = **위→아래 직선 낙하**(주방 "위에서 떨어지는 재료" 은유, §14 A/B). 판정선은 화면 하단 ~78% y. 곡선/슬라이드인은 옵션.
- **속도**: 노트는 spawn→판정선까지 **고정 approach time** `T_approach`(디폴트 1100ms, 튜닝 0.7~1.6s). 속도 = 거리/T_approach, **등속 + 마지막 120ms ease 없음**(타이밍 왜곡 방지 — 리듬게임은 등속 필수).
- **60fps 보장**:
  - 노트는 오브젝트 풀(pre-instanced 32개) 재사용, spawn 시 free 금지.
  - 파티클은 GPUParticles2D one-shot + `emitting` 토글(재생성 X).
  - 텍스트 팝업도 풀(8개).
  - 정적 BG는 단일 텍스처(시차·셰이더 루프 최소). draw call 최소화(아틀라스).
- **미세 흔들림 방지**: 노트 위치 = `round(pos)`(서브픽셀 정렬) 또는 `texture_filter = NEAREST`로 떨림 제거 / `snap_2d_transforms_to_pixel = true`(project setting). 카메라 정수 좌표 유지.
- **Godot 노드 구조**:
  ```
  RhythmRound (Node2D)
  ├─ BeatClock (autoload 참조)        # 정확 시간 소스
  ├─ NoteSpawner (Node2D)             # 차트 읽어 노트 풀에서 spawn
  │   └─ NotePool (Node2D, 32 Note)
  ├─ JudgmentZone (Area2D + Line2D)   # 판정선·윈도우
  ├─ HitFeedback (Node2D)             # 파티클풀·팝업풀·글로우
  ├─ SeasoningGauge (CanvasLayer/Control)
  └─ InputRouter (Node)               # 터치/마우스 → 판정 호출
  ```

---

## 6. 입력 처리·레이턴시 가이드
- **목표**: 입력 down → 판정 → 피드백 첫 프레임 **trip time ≤ 16ms**(1프레임 @60fps).
- **시간 소스**: 프레임 시간(`delta` 누적) 대신 **오디오 클럭** 사용 — `AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()`로 보정한 곡 위치를 BeatClock이 제공(아래 §13 스니펫). 비주얼은 이 시간에 동기.
- **audio-leading offset**: 출력 지연만큼 노트 판정 시각을 보정. 디바이스별 `audio_offset_ms`(±) 캘리브레이션.
- **입력 처리**: `_input()`에서 `InputEventScreenTouch`(모바일)·`InputEventMouseButton`(데스크탑) down 즉시 타임스탬프 캡처(프레임 끝까지 미루지 않음). 멀티터치 index 추적(양손).
- **calibration UI**: 설정에 "박자 보정" — 메트로놈 click에 맞춰 N회 탭 → 평균 오프셋 측정 → `audio_offset_ms` 저장. 시각 보정(노트 vs 판정선)도 별도 슬라이더.
- **input prediction**(옵션): 모바일 터치 지연 큰 기기용, 직전 프레임 입력 예측 보정(기본 off).

---

## 7. SFX layering 상세 (audio-pipeline-v1 정합)
- **노트 타입별 primary**: Single=목제 "톡"(짧은 transient) / Double=빠른 "톡톡"(클릭 2연) / Hold=낮은 드론(지속, 길이 따라 sustain) / Slide=쓸리는 "스윽".
- **행동별 secondary**(페이즈): 칼질=도마 울림 / 휘젓기·볶기=기름 "촤르" / 양념=가루 사르륵·액체 또르륵 / 끓이기=보글 / 플레이팅=그릇 "짤랑"+안착 "차르륵".
- **ambient layer**(페이즈 배경 루프): 끓이기 보글 백그라운드, 시장은 미세 잡음 루프(저음량).
- **완성 sting 3등급**: 보통(놋종 1타) / 잘함(놋종+화음) / 명품(놋종+화음+글로우 reverb).
- **BPM 정렬**: 모든 액션 SFX attack = 노트 판정 0ms(=비트). 레벨 BPM(L1~80→L8~160)에 노트·SFX·음악 3중 정렬(`audio-pipeline-v1 §1.5`).
- **믹스 버스**: `SFX`(액션)·`SFX_judge`(판정 벨/불협)·`Ambient`·`Music` 4버스. 판정 벨은 ducking 없이 짧게.

---

## 8. 햅틱 디자인
| 이벤트 | duration | 파형/세기 | iOS | Android |
|---|---|---|---|---|
| Perfect | 20ms | sharp impulse(단단) | `UIImpactFeedbackGenerator(.rigid)` 또는 heavy | `VibrationEffect.createOneShot(20, 255)` / `EFFECT_CLICK` |
| Good | 30ms | soft | `.light`/`.soft` | `createOneShot(30, 140)` |
| Miss | 50ms | light continuous buzz | `.medium` 1회(짧게) 또는 selection | `createOneShot(50, 90)` |
| 양념 탭 | 10ms | micro | `UISelectionFeedbackGenerator` | `EFFECT_TICK` / `createOneShot(10, 80)` |
| 완성 reveal | 40ms | warm double | `.success`(notification) | `createWaveform([0,30,40,40],-1)` |
- **구현**: Godot은 `Input.vibrate_handheld(ms)`(Android 기본) — 세기 제어 위해 **GodotHaptics 류 플러그인** 또는 JNI/Objective-C 브리지 필요. autoload `HapticManager`가 추상화(아래 §13). 데스크탑은 no-op 또는 게임패드 rumble.
- **설정**: 햅틱 ON/OFF + 강도 슬라이더(0~100%). 디폴트 ON(§14 A/B).

---

## 9. 프로토타입 빌드 범위 (1주 sprint)
- **1 음식 라운드**: 라면 or 잔치국수(둘 다 끓이기 기반, 친숙).
- **4페이즈 압축**: 칼질(파 송송 Single×4) → 양념(고춧가루 Hold or 연타 + 간장) → 끓이기(Hold 타이밍 1~2) → 플레이팅(그릇 1 Single confirm + garnish).
- **판정 시스템 + 5중 피드백 전체** 적용.
- **양념 게이지 UI 완성**(2종: 고춧가루·간장).
- **모바일(Android) + 데스크탑** 빌드 둘 다.
- **자체 metrics 로깅**(파일/콘솔): 판정 분포(P/G/M %), 평균 |Δt|, 세션 길이, 라운드 재시도 횟수, FPS 평균/최저, 입력 trip time 샘플.
- **제외**: 경제·해제·손님 AI·여러 음식·세이브. (손맛 검증 전용 슬라이스.)

---

## 10. 튜닝 다이얼 (런타임 조정, DebugPanel)
| 파라미터 | 디폴트 | 범위 | UI |
|---|---|---|---|
| approach_time | 1100ms | 700~1600 | 슬라이더 |
| perfect_window_scale | 1.0 | 0.5~2.0 | 슬라이더(표 §2에 곱) |
| good_window_scale | 1.0 | 0.5~2.0 | 슬라이더 |
| feedback_particle_intensity | 1.0 | 0~2.0 | 슬라이더(개수·반경 배수) |
| glow_intensity | 1.0 | 0~2.0 | 슬라이더 |
| screen_shake_miss | 2px | 0~6 | 슬라이더 |
| haptic_strength | 0.8 | 0~1.0 | 슬라이더 |
| sfx_volume / judge_volume / ambient | 0/−3/−12 dB | −24~+6 | 슬라이더 |
| seasoning_increment | 1칸/탭 | 0.5~2 | 슬라이더 |
| audio_offset_ms | 0 | −150~+150 | 캘리브레이션 |
| visual_offset_ms | 0 | −150~+150 | 슬라이더 |
> DebugPanel은 `~`키/3손가락 탭 토글. 값은 `user://tuning.cfg`에 저장, 빌드에서 핫리로드.

---

## 11. 레퍼런스 분석 (차용 포인트)
| 게임 | 차용/재해석 |
|---|---|
| **Beat Saber** | Perfect 시 단단한 햅틱 + 베임 파티클의 "쾌감" → 우리 칼질 Perfect 햅틱(20ms sharp)+금 파티클로 재해석 |
| **Cooking Mama** | 가벼운 "톡" 인터랙션 + 음식 reveal의 만족감 → 플레이팅 안착 SFX·reveal 한 박자 |
| **Rhythm Heaven** | 만화적 과장·코믹 SFX·캐릭터 반응 → 손님 표정/자연어 반응, 과장된 PERFECT 팝업 |
| **Cytus II / Lanota** | Hold·Slide 노트의 매끈한 trail·릴리스 폴리시 → Hold 트랙 채움·tail 관용 |
| **(KR) DJMAX / 한국 리듬게임** | 정확 BPM 처리·노트 가독성·judge line bloom → 판정선 bloom, 등속 강하 |
> 핵심 차용 = "Perfect의 다층 보상(시청촉)" + "음식 게임 특유의 따뜻한 톡". 과장은 Rhythm Heaven 쪽, 정밀은 Cytus 쪽 절충.

---

## 12. QA 체크리스트 ("손맛 좋다" 검증)
- [ ] **60fps 유지**: FPS 카운터, 최저 ≥55(중급 모바일). 파티클 다발 시에도.
- [ ] **입력 레이턴시 ≤16ms**: trip time 자동 측정(입력 타임스탬프→피드백 프레임).
- [ ] **5중 자극 전 레이어 작동**: Perfect/Good/Miss 각각 파티클·글로우·팝업·SFX·햅틱 모두 트리거(스크린 캡처 diff + 오디오 스펙트럼 + 진동 로그).
- [ ] **판정 분포 적정**: 일반 플레이 Perfect 30~40%·Good 45~55%·Miss <20%(L1~3 기준). 너무 쉬우면 윈도우 축소.
- [ ] **오디오 동기**: SFX attack이 노트 판정과 ±15ms 이내(녹음 분석).
- [ ] **흔들림 없음**: 노트 강하 서브픽셀 떨림 0(고프레임 캡처 확인).
- [ ] **정성 인터뷰**(5분 세션 후): "다시 하고 싶나?" "어느 순간이 제일 기분 좋았나?" "헷갈린 입력 있었나?" "손맛 1~5점". 5명 중 4명 ≥4점 목표.

---

## 13. Godot 구현 힌트
- **노드/리소스**: `AudioStreamPlayer`(SFX 버스별), `GPUParticles2D`(one-shot), `Tween`(팝업·글로우), `Line2D`(판정선), `Control`(게이지).
- **AutoLoad**: `BeatClock`(시간 소스), `HapticManager`(진동 추상화), `FeedbackBus`(파티클·팝업·SFX·햅틱 통합 호출), `Tuning`(다이얼 값).
- **Resource(.tres)**: `NoteData`(type·time_ms·phase·lane), `FeedbackProfile`(판정별 파티클/글로우/팝업/SFX/햅틱 파라미터), `JudgmentWindow`(레벨별 perfect/good ms).
- **BeatClock 정확 시간**(핵심):
  ```gdscript
  extends Node
  var _song_start_usec := 0
  var output_latency := 0.0
  func start() -> void:
      output_latency = AudioServer.get_output_latency()
      _song_start_usec = Time.get_ticks_usec()
  ## 현재 곡 위치(ms), 오디오 출력 지연 보정
  func now_ms() -> float:
      var t := (Time.get_ticks_usec() - _song_start_usec) / 1000.0
      return t - output_latency * 1000.0 + Tuning.audio_offset_ms
  ```
- **판정 함수**:
  ```gdscript
  func judge(note_time_ms: float, input_time_ms: float, win: JudgmentWindow) -> int:
      var d : float = abs(input_time_ms - note_time_ms)
      if d <= win.perfect: return JUDGE_PERFECT
      elif d <= win.good:  return JUDGE_GOOD
      else:                return JUDGE_MISS   # 윈도우 밖 입력 or 미입력 timeout
  ```
- **피드백 호출**(통합):
  ```gdscript
  func on_judge(result:int, pos:Vector2) -> void:
      FeedbackBus.particles(result, pos)
      FeedbackBus.glow(result, pos)
      FeedbackBus.popup(result, pos)
      FeedbackBus.sfx(result, current_phase)
      HapticManager.play(result)   # Perfect/Good/Miss 매핑
  ```
- **풀링**: 노트·파티클·팝업 모두 `_ready`에서 N개 인스턴스 후 `visible`/`emitting` 토글. `queue_free` 금지.
- **햅틱 브리지**: Android는 `OS.has_feature("mobile")` 시 플러그인 호출, 미지원 시 `Input.vibrate_handheld(ms)` fallback. iOS는 플러그인 필요(미지원 시 no-op).

---

## 14. 미결 결정 (A/B)
| # | 항목 | A (디폴트) | B | 트레이드오프 한 줄 |
|---|---|---|---|---|
| 1 | 노트 강하 방향 | **위→아래 직선 낙하** | 옆에서 슬라이드인 / 카드 뒤집기 | 위→아래 = 주방 "재료 떨어짐" 은유·가독 best / 슬라이드인은 조리대 옆 느낌이나 가독↓ |
| 2 | 양념 게이지 위치 | **하단 고정** | 양념 페이즈 진입 시 중앙 강조 | 하단 고정 = 일관·엄지 도달 / 중앙은 주목도↑이나 노트와 충돌 |
| 3 | 햅틱 디폴트 | **ON** | OFF | ON = 손맛 강화 / 일부 기기 과한 진동·배터리 → 강도 슬라이더로 완충 |
| 4 | 우선 플랫폼 | **모바일 우선**(터치·세로·햅틱) | 데스크탑 우선 | 모바일 = 타깃 일치 / 데스크탑은 개발·튜닝 편함 → 둘 다 빌드하되 모바일 기준 디자인 |
> 전부 디폴트 A로 프로토타입 시작, 빌드 후 튜닝 다이얼로 재평가.

---

## ✅ Self-check — 다음 sprint 즉시 빌드 시작 가능
노트 타입·판정 ms 매트릭스·5중 피드백 수치·게이지 색/증분·강하 등속·레이턴시 목표·SFX/햅틱 매핑·Godot 노드구조/스니펫·튜닝 다이얼·QA 기준이 모두 구체값으로 고정됨 → **본 문서만으로 1주 프로토타입 빌드 착수 가능.** 미해결은 §14 A/B 4건(전부 디폴트 채택 가능).
