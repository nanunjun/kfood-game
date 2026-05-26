# Art Anchor Rubric — Week 1 게이트 평가 표

> 버전: **v0.1** · 작성: 2026-05-24 · 작성자: art-director
> 상위 문서: [`art-style-guide.md`](art-style-guide.md) v0.2 §10 게이트, [`mj-session-kit.md`](mj-session-kit.md), [`prompts-library.md`](prompts-library.md) v0.2
> 본 문서 범위: 사용자가 MJ Session Kit으로 생성한 10 anchor(+ Step 0 sref 후보 2)를 art-director가 **G1~G7** 7개 게이트로 PASS/FAIL/CONDITIONAL 판정하는 rubric.
> 본 게이트 통과 = **M1 art sprint 진입 prerequisite**.

---

## 0. 한 줄 목적

> **"10 anchor 각각이 7 게이트 모두 통과하면 LOCK. LOCK이 모이면 M1 시작."**
> Rubric은 art-director 단독 평가 → pm 최종 승인. 사용자는 결과만 들고 오면 됨.

---

## 1. 평가 단위 & 라벨

### 1.1 평가 단위
- **10 anchor** = CH-01 ~ CH-05 (5) + BG-01 ~ BG-05 (5)
- **2 sref 후보** = Step 0a (캐릭터 sref) + Step 0b (환경 sref) — sref 자체의 PASS 여부도 별도 평가
- 합계 **12세트**를 본 rubric으로 채점

### 1.2 셀 라벨
| 라벨 | 의미 | 후속 액션 |
|------|------|----------|
| **PASS** | 게이트 기준 충족, 그대로 사용 가능 | 다음 게이트로 진행 |
| **CONDITIONAL** | 60~80% 충족, Photoshop 보정 또는 minor reroll로 회수 가능 | art-director가 보정 vs reroll 결정 |
| **FAIL** | 60% 미만, 해당 anchor 재생성 필요 | `mj-session-kit.md` §6 reroll 트리거 적용하여 재시도 |

### 1.3 종합 판정
- 7 게이트 모두 PASS → **LOCK** (anchor 확정)
- 1~2 CONDITIONAL + 나머지 PASS → **CONDITIONAL LOCK** (보정 후 LOCK)
- 1 FAIL 또는 3+ CONDITIONAL → **REROLL** (재생성)
- 2+ FAIL → **REWRITE** (prompt 재설계)

---

## 2. G1~G7 게이트 정의 & PASS 기준

### G1 — 스타일 일관성
- **정의**: 캐릭터 5장이 한 시트 위에 나란히 놓였을 때 "같은 IP 캐릭터"로 인식. 환경 5장이 한 시장 안의 옆가게로 인식.
- **PASS 기준**:
  - 캐릭터: 5장 모두 같은 라인 두께·같은 셰이딩 톤·같은 눈 형태·같은 비율
  - 환경: 5장 모두 같은 천막·간판·조명 톤·같은 perspective(3/4)
  - **시각 측정**: 5장을 한 페이지에 contact sheet로 배열 → 외부인이 5초 안에 "한 IP/한 시장"으로 답할 수 있어야 함
- **FAIL 시 액션**: `--sw` 200~250 상향, sref URL 재고정, 같은 prompt 재시도

### G2 — chibi 비율
- **정의**: 캐릭터의 머리:몸 = 1:1.5~2.0, 손은 mitten, 눈은 점/콩알.
- **PASS 기준**:
  - 캐릭터만 해당 (환경은 N/A 표기)
  - 머리 높이 측정 후 몸 길이가 머리의 1.5~2배 범위 (자 또는 픽셀 카운트)
  - 손가락이 또렷이 5개 보이면 FAIL
  - 눈에 반짝이 하이라이트·홍채 디테일 있으면 FAIL (점/콩알만 PASS)
- **FAIL 시 액션**: `oversized head, chibi 1:1.7` 강화, `mitten hands, hands hidden` 강화, `bean-shaped dot eyes` 강화

### G3 — 컬러 팔레트
- **정의**: 베이스 8색 안에 머무름. 가게는 시그니처 컬러 식별 가능. 채도 100% 영역 없음.
- **PASS 기준**:
  - 모든 색이 art-style-guide §2.1 (Persimmon `#F4A261`, Gochu Red `#E63946`, Rice Cream `#F8E9D2`, Cabbage Green `#6FB077`, Sesame Gold `#FFC857`, Market Wood `#8C6A4E`, Soy Dark `#3D2C1E`, Golden Hour Sky `#FFE9C4`) 인접 톤(±15% HSL)
  - 가게 BG는 시그니처 컬러(§2.2)가 천막/간판/주요 진열에 명확히 식별
  - Photoshop 컬러피커로 spot 5개 검사 → 채도 90% 초과 영역 없음
- **FAIL 시 액션**: LUT 1장으로 일괄 color-grade 후 재평가. LUT로 못 잡으면 `muted palette, low saturation 60-70` 강화하여 reroll

### G4 — K-touch
- **정의**: 외부인이 5초 안에 "한국 시장/한국 음식"으로 식별. 일본·중국 인상 없음.
- **PASS 기준**:
  - 캐릭터: 의상이 한국 모티프 (한복 단순화 / 평범 캐주얼) — 기모노·치파오·하카마 형태 없음
  - 환경: 천막·간판·소품이 한국 재래시장 (남대문/광장시장 톤) — 일본 노렌·중국 등롱·후지산 배경 없음
  - 간판 글리프가 한글 닮은 형태 (가타카나·한자 단독은 FAIL)
- **FAIL 시 액션**: `Korean traditional market (Namdaemun/Gwangjang style), NOT Japanese, NOT Chinese` 강화, `--no kimono, japanese, chinese qipao` 강화

### G5 — mitten/eye/blush (마스코트 시그니처)
- **정의**: 모든 캐릭터에 mitten 손 + 점/콩알 눈 + 분홍 볼터치 3종 시그니처 적용.
- **PASS 기준** (3종 모두 충족 시만 PASS):
  - mitten 손 (또는 손이 숨겨짐) — 5개 손가락 또렷하면 FAIL
  - 점/콩알 눈 (single highlight 1점 허용) — 큰 anime 반짝눈 FAIL
  - 분홍 원형 볼터치 — 없으면 CONDITIONAL (Photoshop 추가 가능)
- **N/A**: 환경 BG는 N/A
- **FAIL 시 액션**: `mitten hands four-finger`, `bean-shaped dot eyes`, `soft pink circular cheek blush` 3종 동시 강화

### G6 — MJ 약점 회피 (세분화)
- **정의**: art-style-guide §7 MJ 약점 10항 중 본 anchor에서 발생한 사례 0건.
- **세분화 (즉시 reroll 트리거)**:

| # | 약점 | PASS 기준 | 발생 시 |
|---|------|----------|--------|
| 6a | **손가락 개수 오류** | 손가락 5개가 또렷이 보이지 않음 (mitten 또는 숨김) | 즉시 reroll, `mitten hands` 강화 |
| 6b | **정면 얼굴 비대칭** | 3/4 또는 7/8 시점, 좌우 비대칭 없음 | 즉시 reroll, `three-quarter view` 강화 |
| 6c | **텍스트 누수** | 간판/가격표가 한글 닮은 placeholder 글리프 (영문/일본어 단어 누수 없음) | Photoshop 후보정 가능, 깨진 영문 단어면 CONDITIONAL |
| 6d | **일본 인상 누수** | 기모노·노렌·후지산·일본 가타카나 없음 | 즉시 reroll, `NOT Japanese` 강화 |
| 6e | **중국 인상 누수** | 청화백자·중국 등롱·치파오 없음 | 즉시 reroll, `NOT Chinese` 강화 |
| 6f | **3D 렌더 누수** | 2D illustration 톤, 매끈한 3D 셰이딩 없음 | 즉시 reroll, `2D hand-painted` 강화 |

- **PASS 기준**: 6a~6f 모두 0건
- **CONDITIONAL**: 1~2건 발생하고 Photoshop 후보정 가능 (예: 6c 텍스트 누수만)
- **FAIL**: 6a/6b/6d/6e/6f 중 1건이라도 발생 (후보정 불가)

### G7 — 조명·시점 통일
- **정의**: 환경 5장 모두 늦오후 골든아워 + 오른쪽 위 45도 주광. 캐릭터 시트는 3/4 또는 7/8 시점.
- **PASS 기준**:
  - 환경: 그림자 방향이 왼쪽 아래로 길게, 하늘이 따뜻한 크림 톤(`#FFE9C4` 인접)
  - 캐릭터: 3/4 또는 7/8 시점 (정면 금지)
  - 5장 환경의 조명 방향이 모두 일치 (한 장만 다른 방향이면 CONDITIONAL)
- **FAIL 시 액션**: `late afternoon golden hour 5pm, warm sunlight upper-right 45 degrees, long shadows lower-left` 강화

---

## 3. 평가 표 (10 anchor × 7 게이트)

> 본 표는 사용자가 결과를 들고 온 직후 art-director가 채움.
> 빈 칸은 PASS/CONDITIONAL(C)/FAIL로 채우고, N/A는 캐릭터-only 게이트에서 환경 anchor가 해당 안 될 때.

### 3.1 캐릭터 anchor 평가
| Anchor | G1 일관성 | G2 비율 | G3 컬러 | G4 K-touch | G5 mitten/eye/blush | G6 약점 회피 | G7 조명 | 종합 |
|--------|----------|--------|--------|-----------|--------------------|------------|--------|------|
| CH-01 주인공 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| CH-02 어머니 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| CH-03 아버지 | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| CH-04 주인공 Happy | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |
| CH-05 주인공 Subtle | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ |

### 3.2 환경 anchor 평가
| Anchor | G1 일관성 | G2 비율 | G3 컬러 | G4 K-touch | G5 mitten/eye/blush | G6 약점 회피 | G7 조명 | 종합 |
|--------|----------|--------|--------|-----------|--------------------|------------|--------|------|
| BG-01 청과상 | ⏳ | N/A | ⏳ | ⏳ | N/A | ⏳ | ⏳ | ⏳ |
| BG-02 정육점 | ⏳ | N/A | ⏳ | ⏳ | N/A | ⏳ | ⏳ | ⏳ |
| BG-03 어물전 | ⏳ | N/A | ⏳ | ⏳ | N/A | ⏳ | ⏳ | ⏳ |
| BG-04 곡물상 | ⏳ | N/A | ⏳ | ⏳ | N/A | ⏳ | ⏳ | ⏳ |
| BG-05 잡화점 | ⏳ | N/A | ⏳ | ⏳ | N/A | ⏳ | ⏳ | ⏳ |

### 3.3 sref 후보 평가 (Step 0)
| sref | 평가 기준 | 결과 |
|------|----------|------|
| Step 0a (캐릭터, CH-01 base) | G1 일관성 시드로 적합한가 (CH-02~05에 적용 시 같은 IP로 인식되는가) | ⏳ |
| Step 0b (환경, BG-01 base) | G1·G3·G7 시드로 적합한가 (BG-02~05에 적용 시 같은 시장으로 인식되는가) | ⏳ |

---

## 4. Anchor Lock 종합 게이트

### 4.1 Week 1 PASS 조건 (모두 충족 시 LOCK)
1. **10 anchor 중 최소 8 LOCK** (개별 anchor 7 게이트 모두 PASS)
2. **캐릭터 sref(Step 0a) PASS**
3. **환경 sref(Step 0b) PASS**

> 8 LOCK + sref 2 PASS = Week 1 게이트 통과 → M1 sprint kick-off 시그널.

### 4.2 부분 통과 시 정책
| 상황 | 정책 |
|------|------|
| 9~10 LOCK + sref 2 PASS | 완전 통과, 즉시 M1 진입 |
| 8 LOCK + sref 2 PASS | 통과, FAIL/CONDITIONAL 2 anchor는 M1 첫 주 reroll 병행 |
| 6~7 LOCK + sref 2 PASS | **CONDITIONAL** — 부족한 anchor에 1 라운드 reroll 집중 (3~5일) |
| sref 1 FAIL | **FAIL** — sref 재생성 우선, 모든 anchor 재생성 필요 (sref 변경 시 모든 파생 영향) |
| 5 이하 LOCK | **FAIL** — pm 에스컬레이션, prompt/스타일 재논의 |

### 4.3 Lock 후 의무
- PASS된 sref URL 2개 + 10 anchor URL을 `prompts-library.md` §0 표에 영구 기록
- `art-style-guide.md` §9 anchor 표를 placeholder에서 실제 URL로 갱신
- M1 sprint 모든 자산은 본 sref URL 의무 사용 (변경 시 pm 승인 필요)

### 4.4 라운드 예산
- **R1 (1차 시도)**: 사용자 1.5~2시간 세션, art-director 평가 0.5시간
- **R2 (reroll)**: 부족 anchor에만 집중, 사용자 +30~60분
- **R3 (재시도)**: R2 후에도 FAIL이면 → pm 에스컬레이션 + scope/스타일 재논의

---

## 5. Decisions Log (라운드별 결과 누적)

> art-director가 라운드마다 결과 기록. PM 승인 줄도 함께.

| 라운드 | 날짜 | LOCK 수 | CONDITIONAL | FAIL | sref PASS | 종합 | art-director 메모 | pm 승인 |
|-------|------|--------|-------------|------|-----------|------|------------------|--------|
| R1 | TBD | ⏳ | ⏳ | ⏳ | ⏳ | ⏳ | — | ⏳ |

---

## 6. 변경 이력
- **2026-05-24 v0.1** — 초안. art-style-guide §10 게이트 7항(G1~G7)을 anchor별 PASS/CONDITIONAL/FAIL 셀로 분해한 rubric 표 신설. G6 MJ 약점 세분화 6항(손가락·정면 비대칭·텍스트·일본·중국·3D). 종합 게이트 조건(10 중 8 LOCK + sref 2 PASS = M1 진입). U-2 어머니/아버지 base anchor 평가 행 추가, reaction 6컷은 후속 sprint.
