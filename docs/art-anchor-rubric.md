# Art Anchor Rubric — Week 1 + M1 게이트 평가 표 (modern mobile casual, ChatGPT)

> 버전: **v1.13 (2026-05-28, M1 환경 BG-01~05 v4 image edit — v1.2 base + 지붕만 교체 + frontal view + 5가게 구조 일관성 + G_env_v4 8 요소 게이트 신설) — supersedes v1.12**
> 작성자: art-director
> 상위 문서: [`art-style-guide.md` v1.2 §10](art-style-guide.md), [`ai-session-kit.md` v1.3 §M1](ai-session-kit.md), [`prompts-library.md` v1.13 §2.2 §4](prompts-library.md)
> 본 문서 범위:
>   - **Week 1**: 캐릭터 5 + 환경 5 + Step 0 후보 2 = 12세트 (§1~§4) — **환경 5장은 v4 image edit (v1.2 base + 지붕만 교체 + frontal view + 5가게 구조 일관성)로 갱신 (§5.6 G_env_v4)**
>   - **M1 음식 12**: F-01~F-12 plated dish hero shot (§5.5 v1.3 신설)
>   - **M1 환경 5 V4 (v1.13 신설)**: BG-01~05 v1.2 base image + gpt-image-1 image edit API + 지붕만 교체 + frontal view (§5.6 G_env_v4 8 요소, G_env_v3 5 요소 deprecated)
> 본 게이트 통과 = 각 sprint 진입 prerequisite.

> **v1.13 변경 (2026-05-28, M1 환경 BG-01~05 v4 image edit — v1.2 base + 지붕만 교체 + frontal view + 5가게 구조 일관성, supersedes v1.12)**: 사용자가 v1.12 v3 결과 (5장 batch prompt-only generation, slight 7/8 perspective, structurally inconsistent across 5 shops) 시각 확인 후 폐기 + verbatim **"각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."** 명시. main thread 해석 3건 fix: (1) **5가게 구조 정확 일관성** — 지붕/기둥/카운터/frame 5가게 모두 정확히 동일, 카테고리별 display goods + signage icon만 다름 (v3 prompt-only batch generation의 generation noise로 5가게 carpenter 작업이 다르게 생성됨) / (2) **v1.2 base 정확 유지 + 지붕만 교체** — prompt-only는 v1.2 정확 재현 어려움, **gpt-image-1 image edit API** 도입 (`client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_EDIT_PROMPT + category, size, quality, n=1)`) / (3) **frontal view** — slight 7/8 perspective 폐기, v1.2 base가 frontal이었음. **§3.2 환경 평가 표 갱신** — v1.12 v3 BG-01~05 5 row "v3 deprecated 2026-05-28 (5가게 구조 inconsistent + 7/8 perspective)" 추가 + v4 BG-01~05 5 row "v4 pending image edit (G_env_v4 8 요소)" 신설. **§5.6.2 G_env_v4 8 요소 게이트 신설** (G_env_v3 5 요소 deprecated → §5.6.4 archive note): G_env_v3 5 요소 (검정 기와 지붕 단일 / v1.2 base 카테고리 시그니처 / icon+영어 minimal signage / Cool Sage bg + modern saturated / v2 한옥 풀세트 추가 요소 0건) + **v4 추가 3 요소**: G_env_v4_6 **5가게 구조 정확 일관성** (지붕/기둥/카운터/frame 5가게 정확 동일, 카테고리별 display goods + signage icon만 다름) / G_env_v4_7 **frontal elevation view** (slight 7/8 perspective 0건, 정면 명확) / G_env_v4_8 **v1.2 base 시각 시그니처 정확 유지** (base image의 frame/카운터/products/signage/bg가 image edit 후에도 ABSOLUTELY IDENTICAL). **LOCK 조건 = 5/5 anchors × 8 요소 = 40/40 PASS**. prompts-library v1.13로 §4 BG-01~05 본문 v4 image edit approach 전면 재작성 (§4.0 공통 COMMON_EDIT_PROMPT + §4.1 shop-specific 카테고리 한 줄 표 + §4.2 G_env_v4 8 요소 게이트 link + §4.3 driver script `tools/edit_bg_anchors_v4.py` + §4.4 사용자 v3 폐기 verbatim + §4.5 v3 vs v4 5 요소 핵심 diff). v3 prompt-only 본문 5건은 §4-LEGACY archive로 deprecated. **새 driver `tools/edit_bg_anchors_v4.py` 신설** — base image dimensions 사전 검증 + (필요 시) gpt-image-1 edit supported size (1024x1024 / 1536x1024 / 1024x1536)로 PIL resize fallback + b64_json 응답 처리. §0 anchor 표 BG-01~05 v4 row status 추가 (`v3 deprecated → v4 pending image edit`). **§6.12 Decisions Log 신설** — 환경 v4 trigger 행 + 사용자 R2 v3 verbatim + main thread 해석 3건 fix + v3 → v4 5 핵심 diff 표 + v3 invalidation 기록 (5장만, 캐릭터 무영향 명시) + 사용자 시각 의도 진화 timeline (v1.2 → v2 → v3 → v4) + main thread 실행 명령 (`py tools/edit_bg_anchors_v4.py --only BG-01` test → `py tools/edit_bg_anchors_v4.py` 5장 batch, gpt-image-1 medium, 5장 × $0.042 ≈ $0.21, ~2-3분, v4 출력 경로 `assets-raw/bg_anchors_m1/BG-XX_<name>_v4.png` v1/v2/v3와 공존). §6.11 v3 trigger 행에 v4 supersede note 추가. 음식 12 평가 (§5.5) 무변경 (F-12 v1.10 R7 plated white plate LOCK candidate 유지). 캐릭터 5 평가 (§3.1) 무변경 (v1.2 lock candidate 유지).

> **v1.12 변경 (2026-05-28, M1 환경 BG-01~05 v3 minimal — v1.2 base + 천막→기와 지붕 단일 fix, supersedes v1.11)** (archived; v4 image edit으로 supersede; 사유 — 5가게 prompt-only generation의 구조 inconsistency + slight 7/8 perspective + v1.2 base 정확 재현 한계): 사용자가 v1.11 v2 (한옥 풀세트) 결과 시각 확인 후 **"너무 많음"** 진단 + verbatim "**기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고**" 명시 → v2 전면 폐기. v1.2 base (commit 7a6cffb)의 minimal feel 회복 + **천막(red/green striped awning) → 검정 기와 곡선 지붕 단일 fix만 적용**. v2의 추가 요소 (옹기 5가게 prominent + lantern 5가게 양쪽 + 목조 한옥 frame + 깊은 처마 풀세트) **모두 폐기**. v1.2 LOCK 유지 = 카테고리 시그니처 (채소/meat/fish/곡식/sauce) / 작은 가게 카운터 / icon+영어 minimal signage / Cool Sage `#C8D5C0` bg / modern saturated 톤 / slim outline 2-3px. prompts-library v1.12로 §2.2 STYLE_SUFFIX_BG_V3 전면 재작성 + §4 BG-01~05 본문 v3 전면 재작성 + §4.7 v1.11 v2 archive 절 신설 + §4.6 v1.2 archive 절 무변경 + `tools/gen_bg_anchors_m1.py` v3 sync (BG-01~05 v1.12 v3 prompt inline + STYLE_SUFFIX_BG_V3). **§5.6 환경 평가 기준 G_env_v3 신설** (G_env_v2 6 요소 폐기): G_env_v3_1 검정 기와 지붕 단일 layer visible (천막 0건) / G_env_v3_2 v1.2 base 카테고리 시그니처 visible (채소/meat/fish/곡식/sauce) / G_env_v3_3 icon+영어 minimal signage (한글 0건) / G_env_v3_4 Cool Sage bg + modern saturated 톤 (베이지 0건) / G_env_v3_5 v2 한옥 풀세트 추가 요소 0건 (옹기 BG-01 좌측 2개만 / lantern 0건 / 목조 frame 0건 / 깊은 처마 0건). **LOCK 조건 = 5/5 anchors PASS G_env_v3 5 요소** (5가게 모두 5 요소 만족 시 환경 v3 sprint LOCK). §0 anchor 표 BG-01~05 v3 row status 추가 (`v1.11 v2 deprecated → v3 pending`). **§6.11 Decisions Log 신설** — v2 한옥 풀세트 폐기 사유 verbatim + v3 minimal fix 명시 + main thread 실행 명령 (gpt-image-1 medium, 5장 × $0.042 ≈ $0.21, ~2-3분, v3 출력 경로). **§7 변경 이력 v1.12 entry 신설**. 음식 12 평가 (§5.5) 무변경. 캐릭터 5 평가 (§3.1) 무변경 (v1.2 lock candidate 유지).

> **v1.11 변경 (2026-05-28, M1 환경 BG-01~05 v2 갱신 — 한옥 + 기와 + 처마 + 옹기 + lantern + icon+영어 signage 5건 fix, supersedes v1.10)** (archived; v3 minimal로 supersede): 사용자가 정통 한식 가게 reference image (참기름 방앗간 한옥 양식, 1963년) 제공 + 명시 "한식 정통 요소만 차용 + 기존 lock 유지". main thread 시각 분석으로 차용 5건 + 회피 3건 추출. Week 1 anchor candidate (commit 7a6cffb)의 BG 5장 invalidate. **(2026-05-28 v1.12 추기: v2 결과 시각 확인 후 사용자가 "너무 많음" + verbatim "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고" 명시 → v1.11 v2 전면 폐기. v1.12 v3 minimal로 supersede. v2 G_env 6 요소 게이트 → v3 G_env_v3 5 요소로 재정의)**

> **v1.10 변경 (2026-05-28, M1 음식 F-12 R7 reroll trigger, supersedes v1.9)** (archived): R6 v6 결과 시각 확인 후 사용자가 **또 다른 reference image** (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length)를 제시하며 verbatim "이걸로 해줘" 명시 + 5건 추가 fix 요청 — (1) **form 전면 교체**: small square pieces grid (3-4cm × 3-4cm, 12-16 pieces in 3-4 rows × 4 columns) → 4-6 large rectangular LA-style meat strips (18-25cm × 8-12cm × 0.5-0.8cm thick) parallel side by side. 정통 LA-cut cross-cut form 회귀 / (2) **bone form 완전 재정의 (CRITICAL signature)**: single LONG WHITE RIB BONE (12-15cm) at SHORT EDGE side → 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS (each ~1.5-2cm diameter) along each strip's LENGTH (evenly spaced ~3-5cm apart). LA-style cross-cut bones (ribs cut perpendicular to original direction). R3에서 시도됐다가 폐기됐던 패턴이 R7 reference의 정확한 패턴 (사용자 시각 의도 진화) / (3) **garnish 변경**: chopped minced garlic dots (yellowish-white granules) → chopped green scallion rounds (송송 sliced 대파, 1-3mm thick discs, bright green color)로 hero garnish 변경. 깨는 minor accent / (4) **plate/grill context 변경**: black cast iron grill plate / copper grate / 흰 plate → ROUND METALLIC WIRE MESH GRILL GRATE (silver-gray wire pattern visible) + optional hot coals glow atmosphere / (5) **view angle 변경**: top-down view → slight 7/8 perspective view (mostly top-down but slightly angled to show meat thickness side profile + grate depth). v6의 LOCK 유지 4건 (well-grilled brown + glaze / char marks / thin 0.5-0.8cm thickness / cross-cultural negative + NOT v6 grid form) 무변경. **칼집 (knife score marks)은 optional로 격하** — LA-cut form에서는 cross-cut bones이 dominant signature이고 char marks가 dominant surface texture, score marks는 reference에 명확히 보이지 않음. **F-12 단독 R7 reroll trigger**. 다른 11장 (F-01~F-11) status 무변경. prompts-library v1.9로 §5.2 F-12 본문 v7 패치 + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. **§5.5.4 평가 표 F-12 status `R6 reroll pending` → `R7 reroll pending` 갱신**. **§5.5.8 F-12 R7 평가 기준 표 신설 (R4/R5/R6 기준 deprecated)** — R7 = 7 요소 점검표: 행 1 LA-cut long strip form (4-6 strips, 18-25cm × 8-12cm) / 행 2 multiple strips parallel side by side / 행 3 thin 0.5-0.8cm thick (LOCK 유지) / 행 4 **3-4 bone cross-section discs along each strip's length (CRITICAL — LA cross-cut signature)** / 행 5 well-grilled brown + glaze + char marks (LOCK 유지) / 행 6 chopped green scallion rounds garnish (신설) / 행 7 round wire mesh grill grate context (신설). 칼집은 옵션 게이트로 격하. **§6.9 Decisions Log 신설** — R7 trigger 행 + 사용자 verbatim "이걸로 해줘" + main thread 새 reference image 시각 분석 7 요소 + R6 vs R7 5건 diff 표 + 사용자 시각 의도 진화 timeline v3→v4→v5→v6→v7 요약 표. **§7 변경 이력 v1.10 entry 신설**.

> **v1.9 변경 (2026-05-28, M1 음식 F-12 R6 reroll trigger, supersedes v1.8)** (archived; F-12는 R7 v1.10로 supersede): R5 v5 결과 시각 확인 후 사용자가 **새 reference image** (정통 한식 갈비구이 — 가위로 자른 후의 eating-style state)를 제시하며 **4건 추가 fix 요청** — (1) **form 전면 교체**: long elongated strips (12-15cm × 3cm × 0.7-1cm) → small square pieces (3-4cm × 3-4cm × 0.5-0.8cm thick, 12-16 pieces) in grid pattern (3-4 rows × 4 columns). 사용자 verbatim "가위로 자르고 난후의 갈비구이" / (2) **thickness 더 얇게**: 0.7-1cm → 0.5-0.8cm (5-8mm). 사용자 "고기 자체도 훨씬 얇게" / (3) **bone 위치 완전 재정의**: bone discs along TOP LONG EDGE of each strip → SINGLE LONG WHITE RIB BONE (12-15cm) laid alongside meat grid on ONE SHORT EDGE. 사용자 "Short Edge쪽에 뼈가 길게 있잖어" / (4) **garnish 잘게 다진 마늘**: 1-2 thin garlic slices → finely chopped minced garlic bits scattered all over (small yellowish-white granules). v5의 다른 5 LOCK 요소 (칼집 maintained on each piece / strictly parallel-aligned arrangement / well-grilled brown + glaze / plate context / cross-cultural negative) 무변경. **F-12 단독 R6 reroll trigger**. 다른 11장 (F-01~F-11) status 무변경. prompts-library v1.8로 §5.2 F-12 본문 v6 패치 + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. **§5.5.4 평가 표 F-12 status `R5 reroll pending` → `R6 reroll pending` 갱신**. **§5.5.8 F-12 R6 평가 기준 표 신설 (R4/R5 기준 deprecated)** — R6 = 7 요소 점검표: square form (3-4cm × 3-4cm, 12-16 pieces) / thin 0.5-0.8cm (5-8mm) / grid pattern (3-4 rows × 4 columns) / long bone at short edge (single long piece 12-15cm) / 칼집 maintained on each piece / caramelized brown + glaze / chopped minced garlic dots. **§6.8 Decisions Log 신설** — R6 trigger 행 + 사용자 R5 v5 피드백 verbatim + main thread 새 reference image 분석 + R5 vs R6 4 요소 diff 표 + v5 vs v6 LOCK 유지 요소 5건 무변경 확인 표. **§7 변경 이력 v1.9 entry 신설**.

> **v1.8 변경 (2026-05-28, M1 음식 F-12 R5 reroll trigger, supersedes v1.7)** (archived; F-12는 R6 v1.9로 supersede): R4 v4 결과 시각 확인 후 사용자 **2건 추가 fix 요청** — (1) "고기가 일단 더 얇아야 함" thickness 1-1.5cm → 0.7-1cm (very thin slice, 6-8mm) / (2) "긴쪽의 밑쪽이 아니라 윗부분의 사이드로 보여야함" bone 위치 = v4 "between strips at plate edges" → v5 "along the TOP LONG EDGE of each meat strip, partially embedded into the upper long edge". v4의 다른 6 LOCK 요소 (칼집 / strictly parallel / 길이 12-15cm / well-grilled brown / garnish / plate context) 무변경. **F-12 단독 R5 reroll trigger**. 다른 11장 (F-01~F-11) status 무변경. prompts-library v1.7로 §5.2 F-12 본문 v5 패치 + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. **§5.5.4 평가 표 F-12 status `R4 reroll pending` → `R5 reroll pending` 갱신**. **§5.5.8 F-12 R4 평가 기준 표 재정의** — 행 4번 (bone 위치) + 행 6번 (strip 두께) v5 기준으로 갱신, 행 2번 (parallel) + 행 5번 (길이) 무변경, 행 1번 (칼집) + 행 3번 (구운 색) 무변경. **§6.7 Decisions Log 신설** — R5 trigger 행 + 사용자 R4 v4 피드백 verbatim + bone 위치 해석 main thread 분석 인용 + v4 vs v5 2 요소 diff 표. **§7 변경 이력 v1.8 entry 신설**.

> **v1.7 변경 (2026-05-28, M1 음식 F-12 R4 reroll trigger, supersedes v1.6)** (archived; F-12는 R5 v1.8로 supersede): R3 v3 결과 시각 확인 후 사용자가 정통 한식 갈비구이 reference image를 직접 보여주며 시각 의도 명확화 → R3 v3 = "끝에 single bone protrudes" 묘사가 사용자 reference와 어긋남 진단. **F-12 단독 R4 reroll trigger**. 다른 11장 (F-01~F-11) status 무변경 (R3 LOCK candidate 5건 / R2 LOCK candidate 4건 / R1 LOCK 2건). R4 fix 핵심 = 사용자 reference image 6 시각 요소 1:1 매칭 prompt 전면 재작성: (1) **칼집 (knife score marks across meat surface)** — 가장 중요한 시그니처, R3에는 0건이었음 / (2) **thin elongated parallel meat strips** (4 strips × 12-15cm × 3cm × 1-1.5cm, strictly parallel NOT overlapping) / (3) **small white round bone cross-section discs nestled between strips at plate edges** (R3 "single bone at one end" 묘사 폐기) / (4) **well-grilled caramelized brown + glossy soy-pear-garlic glaze sheen** (raw red-pink NOT) / (5) **grill marks along score lines + edges** / (6) **plating context = clean black cast iron grill plate 또는 white plate**. prompts-library v1.6로 본문 패치 + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. **§5.5.4 평가 표 F-12 status `R3 reroll pending` → `R4 reroll pending` 갱신**. **§5.5.8 F-12 R4 평가 기준 신설** — G_user_visual_detail 게이트 항목별 점검 표 (칼집 / parallel / 구운 색 / small bone discs / 길이 12-15cm / strip 두께 1-1.5cm 6 요소, 1개라도 누락 시 FAIL). **§6.6 Decisions Log 신설** — R4 trigger 행 + 사용자 reference image 시각 분석 verbatim + R3 single-bone-at-end 폐기 사유 + main thread 실행 명령.

> **v1.6 변경 (2026-05-27, M1 음식 R3 reroll 6건 trigger, supersedes v1.5)** (archived; F-12는 R4 v1.7로 supersede): R2 v2 결과 시각 확인 후 사용자가 **selective 시각 피드백 6건 raise** (F-01/F-02/F-03/F-05/F-06/F-12). **F-07/F-08/F-10/F-11 4장은 사용자 silent ACK → R2 LOCK candidate 갱신**, **F-04/F-09 2장은 R1 LOCK 유지**. R3 fix 핵심 = (1) v1 base 회복 (F-01/F-03/F-05 — v2가 너무 보수적으로 식욕 자극 ↓, 사용자 "원래 버전이 더 먹음직스러움") + (2) F-02 topping syrup drizzle 추가 (contained filling + 표면 토핑) + (3) F-06 cross-section 4요소 명확 (sausage core 보이게 + cheese stretch + panko + ketchup/mustard) + (4) F-12 **전면 재작성** (LA-cut 폐기, 정통 한식 = thin meat strip 5-7cm × 1-1.5cm + 한쪽 끝 SHORT WHITE BONE 1-2cm 노출 — 사용자 "갈비구이는 끝에 뼈가 좀 있어야 됨"). prompts-library v1.5로 본문 패치 + `tools/gen_food_anchors_m1.py` FOODS sync 완료. **§5.5.4 평가 표 status 갱신** — 6건 `R3 reroll pending`, F-07/F-08/F-10/F-11 `R2 LOCK candidate (사용자 silent ACK)`, F-04/F-09 `LOCK (R1 유지)`. **§6 Decisions Log §6.5 신설** (R3 reroll trigger + 사용자 피드백 6건 verbatim + 패치 본문 fix 핵심 + main thread 실행 명령). **§5.5.7 G_user_visual_detail R3 평가 기준 갱신** (F-06 sausage core visible / F-12 단일 끝 bone 1-2cm).

> **v1.5 변경 (2026-05-27, M1 음식 R2 reroll 10건 trigger)** (archived; R3로 부분 supersede): R1 v1 결과 12장 시각 확인 후 사용자가 **구체적 시각 피드백 10건 raise** (F-04 떡볶이 / F-09 김치찌개는 R1 LOCK 유지). R1 v1 12/12 LOCK은 G_food cross-cultural 누수 측면에서는 유효하나, **사용자 시각 디테일 게이트 (rice grain 크기, noodle 두께, syrup 흘러나오는 양, paper wrapper, scallion 위치, tofu 모양, bone shape)에서 10건 FAIL** → R2 reroll 트리거. prompts-library v1.4로 본문 패치 + `tools/gen_food_anchors_m1.py` FOODS sync 완료. **§5.5.4 평가 표 — 10건 status `LOCK` → `R2 reroll pending` 갱신** (F-04/F-09는 LOCK 유지). **§6 Decisions Log §6.4 신설** (R2 reroll trigger 기록 + 사용자 피드백 10건 verbatim + F-04/F-09 LOCK 유지 명시). **§5.5.7 G_user_visual_detail (신설)** — 사용자 시각 디테일 게이트. G_food와 별도 critical 게이트로 다룸. R2 평가 시 10건 fix가 1:1 적용됐는지 추가 게이트로 점검.

> **v1.4 변경 (2026-05-27, M1 음식 12 R1 평가 완료)** (archived; R2 reroll로 부분 supersede): prompts-library v1.3 / `tools/gen_food_anchors_m1.py` (gpt-image-1 medium, 1024×1024) R1 실행 결과 — **12/12 LOCK 달성** (G_food cross-cultural 누수 0건 across all 12). risk top 5 (F-12/F-03/F-06/F-11/F-09) **5/5 LOCK** (예측 default % 50~80% 누수 risk 모두 회피 성공 — prompt VERY HIGH explicit negative + visible signature feature 강조 전략 검증). §5.5.4 평가 표 pending → 12행 PASS로 채움. §6 Decisions Log §6.2에 M1 R1 라운드 행 LOCK 결과 기록. **M1 후반 sprint 진입 신호 = Yes** (ingredient 24장 + UI illustration + VFX 다음 단계). minor finding = bg 2종 (cool sage `#C8D5C0` 7장 + cream-white `#FAFAFA` 5장) mixed — STYLE_SUFFIX_FOOD "choose one consistently" 위반이나 둘 다 허용 cool tone이고 cross-cultural 식별 영향 0 → CONDITIONAL note만 (M1 후반 cut anim/ingredient 시 bg 통일 1개 선택 권고). **(2026-05-27 v1.5 추기: 사용자 시각 디테일 게이트 10건 FAIL 발생 → R2 reroll 트리거. v1.4 R1 LOCK은 cross-cultural 누수 측면에서만 유효, F-04/F-09 2장만 R2에서도 LOCK 유지)**

> **v1.3 변경 (2026-05-27, M1 음식 12 평가 가이드 추가)** (archived): prompts-library v1.3 / ai-session-kit v1.3 음식 12 anchor sync. **§5.5 음식 12 평가 가이드 신설** — 음식 anchor는 캐릭터/환경과 다른 평가 특성: G_food 신설 (한식↔타국식 누수 평가, G6의 음식 특화 분기) + G6 W5/W6 가중치 ↑ (음식 cross-cultural 누수가 핵심 risk) + G2 chibi 비율 N/A (음식 카드는 캐릭터 없음) + G_new modernity는 plate/bowl 톤으로 측정. LOCK 조건: 12 중 **10/12 PASS** 제안 (T1 7 LOCK + T2 3 LOCK 최소). Tier 1/2 시각 구분 단서 = abundance (T1 1인분 단순 / T2 풍성 6+ section, 3+ pieces). §3 평가 표에 F-01~F-12 행 추가 (G_food 컬럼). §5 cut anim mini-게이트 무변경. §6 Decisions Log에 M1 음식 라운드 행 추가 (pending).

> **v1.2 변경 (2026-05-27, modern mobile casual sync)** (archived): G3/G5 modern saturated/clean criteria 갱신, G_new 신설.

> **v1.0 reset 배경 (2026-05-27)**: 사용자 art-style lock = Subway Surfers / Crossy Road / Stack 계열 flat. v0.1 mascot 7항 게이트(G1~G7)을 flat 톤 기준으로 재구성. G5는 "mitten/eye/blush 마스코트 시그니처"에서 **"단순성 (디테일 최소)"**로, G7은 "조명·시점 통일"에서 **"모바일 가독성"**으로 항목 의미 변경.

---

## 0. 한 줄 목적

> **"10 anchor 각각이 7 게이트 모두 통과하면 LOCK. LOCK이 모이면 M1 시작."**
> flat 톤은 mascot 대비 detail 적어 일관성 lock 안정성 ↑ 기대. ChatGPT는 sref 부재로 캐릭터 일관성 lock이 MJ 대비 약한 trade-off가 있으나, reference image upload + subject anchor 문장 + 같은 채팅 세션 3축 운영으로 보완.

---

## 1. 평가 단위 & 라벨

### 1.1 평가 단위
- **10 anchor** = CH-01~05 (5) + BG-01~05 (5)
- **2 subject anchor 후보** = Step 0a (캐릭터 anchor) + Step 0b (환경 anchor) — subject anchor 자체 PASS 별도 평가 (M1 sprint reference image upload 시드로 적합한가)
- 합계 **12세트**

### 1.2 셀 라벨

| 라벨 | 의미 | 후속 액션 |
|------|------|----------|
| **PASS** | 게이트 기준 충족, 그대로 사용 가능 | 다음 게이트로 진행 |
| **CONDITIONAL** | 60~80% 충족, Photoshop 보정 또는 minor reroll로 회수 가능 | art-director가 보정 vs reroll 결정 |
| **FAIL** | 60% 미만, 해당 anchor 재생성 필요 | `mj-session-kit.md` §6 reroll 트리거 적용 |

### 1.3 종합 판정 (anchor 단위)

- 7 게이트 모두 PASS → **LOCK** (anchor 확정)
- 1~2 CONDITIONAL + 나머지 PASS → **CONDITIONAL LOCK** (보정 후 LOCK)
- 1 FAIL 또는 3+ CONDITIONAL → **REROLL** (재생성)
- 2+ FAIL → **REWRITE** (prompt 재설계)

---

## 2. G1~G7 게이트 정의 & PASS 기준 (flat 톤)

### G1 — flat 일관성
- **정의**: 캐릭터 5장이 한 시트 위에서 "같은 IP"로 인식. 환경 5장이 한 시장 안 옆가게로 인식. ChatGPT는 sref 부재로 가장 취약한 항목 → reference image upload + subject anchor 문장 + 같은 채팅 세션 follow-up 3축 운영 필수.
- **PASS 기준**:
  - 캐릭터: 5장 모두 같은 outline 두께(2~4px) + 같은 features 톤(점 눈/호 입) + 같은 컬러 톤(saturated 75~85%)
  - 환경: 5장 모두 같은 천막 shape + 같은 outline 두께 + 같은 컬러 톤
  - **시각 측정**: contact sheet 2×5 → 외부인 5초 안에 "한 IP/한 시장" 답
- **FAIL 시 액션**: reference image 재첨부 + follow-up "이 reference image와 같은 outline·features·컬러 톤으로 일관성 강화" + 같은 채팅 세션에서 재생성. 안 되면 새 세션에서 anchor file을 직접 보여주며 step-by-step style transfer 요청.

### G2 — chibi 비율 + flat 단순성
- **정의**: 캐릭터의 머리:몸 1:1.5~2, mitten/nub 손, 점 눈, 호 입. 환경의 가게당 shape 1~2 (over-detail FAIL).
- **PASS 기준**:
  - 캐릭터: 머리 폭 vs 몸 길이 측정 → 1.5~2 범위. 손가락 5개 또렷이 보이면 FAIL. 눈에 반짝/홍채/속눈썹 있으면 FAIL (점만 PASS). 입 vertices 3개 초과 FAIL.
  - 환경: 가게당 시그니처 shape 2개 초과 시 CONDITIONAL, 5개 이상 시 FAIL.
- **FAIL 시 액션**: `oversized head chibi 1:1.7, mitten hands no fingers, simple dot eyes, small arc smile` 강화 / 환경은 `only 1-2 signature icons, minimal detail`

### G3 — modern saturated 컬러 (v1.2 갱신)
- **정의**: art-style-guide §6 베이스 + 가게 시그니처 안에 머묾. **채도 80~90% 범위** (v1.1 75~85% → 상향). **warm/cool 균형** (v1.2 cool tone 1+ 사용 필수 — bg 또는 accent).
- **PASS 기준**:
  - 모든 색이 §6.1 v1.2 베이스(Persimmon Vivid `#FF8A1F`, Gochu Red Vivid `#F23E3E`, Cabbage Green Vivid `#52C160`, Soft Mint `#9BE0D2`, Pastel Teal `#5FB8C4`, Cool Sage `#C8D5C0` 등) 인접 톤(±15% HSL)
  - 가게 BG는 시그니처 컬러(§3.4)가 천막/간판/주요 진열에 명확
  - 채도 spot 5개 검사 → **채도 100% 또는 70% 미만 영역 없음** (modern saturated 강조, neon 금지 + 무광 금지)
  - **cool tone 1종 이상 사용** (bg 또는 accent에 Soft Mint/Pastel Teal/Cool Sage/Accent Sea 중 1+)
  - **slim outline 2~3px** (v1.1 2~4px → 2~3px 상향 — modern Royal Match style)
- **FAIL 시 액션**: LUT 1장 일괄 color-grade. LUT 못 잡으면 `vibrant saturated 80-90 percent saturation, warm/cool balance, cool mint background` 강화 → reroll

### G4 — K-touch 명료
- **정의**: 외부인 0.5초 안에 "한국"으로 식별. 일본·중국 누수 0건.
- **PASS 기준**:
  - 캐릭터: 한복 모티프(jeogori V-collar) 또는 평범 캐주얼 — 기모노·치파오·하카마 형태 없음
  - 환경: 천막/간판/소품이 한국 재래시장 (Namdaemun/Gwangjang) — 일본 노렌·중국 등롱·후지산 없음
  - 옹기(BG-05)는 한국 onggi (dark brown earthen, round bottom) — 청화백자/매끈 흰 도자기 시 FAIL
  - 간판 글리프가 한글 닮은 placeholder block (가타카나·한자 단독 FAIL)
- **FAIL 시 액션**: `Korean traditional market (Namdaemun, Gwangjang), Korean onggi pottery, NOT Japanese, NOT Chinese` 강화

### G5 — 단순성 (modern clean, v1.2 갱신)
- **정의**: **"Royal Match 옆에 놓아도 어색하지 않은가?"** fail-test. clean modern flat + **soft 1-layer cel shading 1단 허용** (v1.2 변경). 다층 cel-shading / scrapbook / storybook / texture 누수 0. **베이지/크림/kraft paper 배경 즉시 FAIL (v1.2 LOCK)**.
- **PASS 기준** (모두 충족 시):
  - 의상/소품에 패턴/무늬 없음 (single color fill + soft 1-layer cel shading만)
  - 다층 shading layer 보이지 않음 (multi-layer cel-shading FAIL)
  - texture/noise/grain 보이지 않음 (canvas/paper/kraft texture FAIL)
  - **scrapbook/storybook/vintage 톤 0** (v1.2 신설)
  - **베이지/크림/kraft paper 배경 0** (v1.2 LOCK)
  - 캐릭터: 점 눈 + 호 입 + nub/mitten 손 3종 모두 단순
  - 환경: 가게당 시그니처 shape 1~2개만 (5개 이상 = clutter FAIL)
- **자체 question**: "이 anchor를 Royal Match screenshot 옆에 두면 같은 시대로 보이는가?" → "아니오"면 CONDITIONAL/FAIL
- **FAIL 시 액션**: `modern mobile casual game art, Royal Match aesthetic, clean modern flat, NO scrapbook, NO storybook, NO beige background, soft 1-layer shading only` 강화. negative에 `scrapbook, storybook, kraft paper, vintage, beige, cream paper, multi-layer shading` 추가.

### G6 — ChatGPT 약점 회피 (flat 특화 세분화, 10항)
- **정의**: art-style-guide §7 약점 10항(W1~W10) 중 본 anchor에서 발생 0건. ChatGPT는 MJ와 약점 분포 다름 — **한글 텍스트 깨짐(W1, Very High)**, photoreal(W2), painterly(W3), 캐릭터 일관성 lock 실패(W9, Very High) 4종이 high freq.
- **세분화 (즉시 follow-up reroll 트리거)**:

| # | 약점 (ChatGPT 특화) | PASS 기준 | 발생 시 |
|---|-------------------|----------|--------|
| W1 | **한글 텍스트 깨짐** (간판/가격표) | blank cream block placeholder, no readable text | Very High 빈도 — **후보정 default**. CONDITIONAL (Photoshop overlay). prompt에 placeholder block만 명시. |
| W2 | **photoreal / 3D render 누수** (default) | flat 2D illustration 톤, photoreal/3D render 톤 없음 | 즉시 follow-up: "이 이미지를 더 flat한 2D illustration으로, 3D render, octane, unreal, gradient mesh 제거." |
| W3 | **digital painting / painterly / storybook 누수 (v1.2)** | clean modern flat with soft 1-layer shading, painterly/hand-painted/watercolor/scrapbook/storybook 톤 없음 | 즉시 follow-up: "이 이미지를 더 clean한 modern Royal Match style로, painterly/watercolor/storybook/scrapbook 제거, single color fill + soft 1-layer shading만." |
| W4 | **손가락 detail 누수** | mitten/nub 또는 손 숨김 | 즉시 follow-up: "이 이미지를 다시 그려줘. 손을 mitten으로, no individual fingers." |
| W5 | **한식 → 일본 누수** | 기모노·노렌·후지산·sushi 없음 | 즉시 follow-up: "Korean style로 명확히, NOT Japanese, NOT kimono, NOT tokyo, NOT sushi." |
| W6 | **한식 → 중국 누수** | 청화백자·중국 등롱·치파오 없음 | 즉시 follow-up: "Korean onggi/한국 시장 톤으로, NOT Chinese, NOT chinatown, NOT qipao, NOT blue-and-white porcelain." |
| W7 | **복잡한 composition 약함 (multi-character scene)** | single subject per image | 즉시 follow-up: "single subject만 그려줘, 캐릭터/가게 따로." Multi-character는 본 sprint 범위 X (Godot 레이어 합성). |
| W8 | **자연어 prompt 길이 한계** (modifier 무시) | 핵심 modifier 모두 반영 | 즉시 follow-up 분할 — 한 번에 1~2 modifier만 강조 "이 이미지에서 X 요소만 강조해서 다시 그려줘." |
| W9 | **reference 없이 캐릭터 일관성 lock 실패** (sref 부재) | reference 캐릭터와 같은 outline·features·컬러 | 즉시 follow-up: reference image 재첨부 + "reference 캐릭터의 outline 두께·features·컬러 톤 정확히 유지." 안 되면 새 세션에서 step-by-step style transfer. |
| W10 | **anime girl / 정면 over-detail 누수** | 점 눈 + 호 입 (홍채/속눈썹/반짝 0) | 즉시 follow-up: "simple two black dot eyes, minimal facial features, NO sparkle eyes, NO school uniform." |

- **PASS 기준**: W1~W10 모두 0건
- **CONDITIONAL**: W1 한글 텍스트 깨짐 1건만 발생 + Photoshop/엔진 UI overlay 후보정 가능 (~100% 발생하므로 본 anchor 단계에서는 default CONDITIONAL 처리)
- **FAIL**: W2/W3/W4/W5/W6/W7/W9/W10 중 1건이라도 발생 (follow-up reroll 필요)

### G7 — 모바일 가독성
- **정의**: 1024×1024 anchor를 256×256으로 축소 시 캐릭터/가게/음식 식별 가능 (모바일 small screen test).
- **PASS 기준**:
  - 캐릭터: 256px 축소 시 features(점 눈/호 입) 식별 가능, 의상 컬러 block 식별
  - 환경: 256px 축소 시 가게 시그니처 컬러 + 시그니처 icon 1~2개 식별
  - outline 두께가 256px에서 보이지 않으면 FAIL (너무 얇은 1px outline)
  - 컬러 충돌(인접 색 contrast 부족) 시 CONDITIONAL
- **FAIL 시 액션**: `bold 3-4px outline, high contrast colors, mobile small screen readability` 강화 → 또는 anchor 1장에 outline 두께 보정 (Photoshop)

> **v0.1과의 차이**: v0.1 G7은 "조명·시점 통일"이었음. flat 톤은 조명 표현 거의 없어(§art-style-guide §3.2) 게이트 의미 ↓ → G7을 **모바일 가독성**으로 재배치. 시점 통일은 G1(일관성)로 흡수.

### G_new — modern mobile casual 인상 (v1.2 신설)
- **정의**: "이 anchor를 **Royal Match (Dream Games 2021) / Subway Surfers screenshot 옆에 두면 같은 시대/같은 카테고리로 보이는가?**" 외부인 5초 평가에서 "modern mobile casual" 카테고리 일치.
- **PASS 기준** (모두 충족 시):
  - **dynamic action pose** (캐릭터, 정적 standing FAIL — iter1/iter2 학습 보존)
  - **cool tone bg** (Soft Mint / Pastel Teal / Cool Sage / Cream-white 중 1, 베이지 FAIL)
  - **80~90% 채도** (muted FAIL)
  - **slim outline 2~3px** (heavy 4px+ FAIL)
  - 4종 동시 한 시트 안에 충족
  - **Cookie Run 2021 / Toca Boca / Toon Blast / scrapbook / storybook 톤 0** (즉시 FAIL)
- **FAIL 시 액션**: 즉시 follow-up: "이 이미지를 더 modern Royal Match (Dream Games 2021) style로 다시 그려줘. 베이지/scrapbook/Cookie Run 톤 완전 제거, cool mint background + dynamic action pose + 80-90% vibrant saturation + slim 2-3px outline 4종 동시 충족."
- **art-director note**: G_new는 G1과 함께 **critical** — G_new FAIL이면 다른 게이트 PASS여도 종합 FAIL (v1.2 reset 트리거 사유).

---

## 3. 평가 표 (10 anchor × 7 게이트)

> 본 표는 사용자가 결과 인계 직후 art-director가 채움.
> 빈 칸은 PASS/CONDITIONAL(C)/FAIL. N/A는 캐릭터-only 게이트에서 환경 anchor 해당 안 될 때.

### 3.1 캐릭터 anchor 평가 (v1.2 G_new 컬럼 추가)

| Anchor | G1 일관성 | G2 비율·dynamic pose | G3 modern saturated | G4 K-touch | G5 modern clean | G6 약점 회피 | G7 모바일 가독성 | G_new modernity | 종합 |
|--------|----------|---------------------|--------------------|-----------|----------------|------------|----------------|----------------|------|
| CH-01 주인공 | pending | pending | pending | pending | pending | pending | pending | pending | pending |
| CH-02 어머니 | pending | pending | pending | pending | pending | pending | pending | pending | pending |
| CH-03 아버지 | pending | pending | pending | pending | pending | pending | pending | pending | pending |
| CH-04 주인공 Happy | pending | pending | pending | pending | pending | pending | pending | pending | pending |
| CH-05 주인공 Subtle | pending | pending | pending | pending | pending | pending | pending | pending | pending |

### 3.2 환경 anchor 평가 (v1.13 v4 G_env_v4 컬럼, v3 G_env_v3 deprecated, v2 G_env deprecated, v1.2 G_new 유지)

| Anchor | G1 일관성 | G2 비율·단순 | G3 modern saturated | G4 K-touch | G5 modern clean | G6 약점 회피 | G7 모바일 가독성 | G_new modernity | **G_env_v4 (v1.13 신설, 8 요소)** | 종합 |
|--------|----------|-------------|--------------------|-----------|----------------|------------|----------------|----------------|------------------------------|------|
| BG-01 청과상 (v1.2 lock candidate, **invalidated**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.2 invalidated 2026-05-28** |
| BG-02 정육점 (v1.2 lock candidate, **invalidated**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.2 invalidated 2026-05-28** |
| BG-03 어물전 (v1.2 lock candidate, **invalidated**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.2 invalidated 2026-05-28** |
| BG-04 곡물상 (v1.2 lock candidate, **invalidated**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.2 invalidated 2026-05-28** |
| BG-05 잡화점 (v1.2 lock candidate, **invalidated**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.2 invalidated 2026-05-28** |
| BG-01 청과상 v2 한옥 풀세트 (**deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A (v3 G_env_v3 사용) | **v1.11 v2 deprecated 2026-05-28 (한옥 풀세트 너무 많음)** |
| BG-02 정육점 v2 한옥 풀세트 (**deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.11 v2 deprecated 2026-05-28** |
| BG-03 어물전 v2 한옥 풀세트 (**deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.11 v2 deprecated 2026-05-28** |
| BG-04 곡물상 v2 한옥 풀세트 (**deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.11 v2 deprecated 2026-05-28** |
| BG-05 잡화점 v2 한옥 풀세트 (**deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.11 v2 deprecated 2026-05-28** |
| BG-01 청과상 v3 (v1.12 prompt-only, **deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A (v4 G_env_v4 사용) | **v1.12 v3 deprecated 2026-05-28 (5가게 구조 inconsistent + 7/8 perspective)** |
| BG-02 정육점 v3 (v1.12 prompt-only, **deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.12 v3 deprecated 2026-05-28** |
| BG-03 어물전 v3 (v1.12 prompt-only, **deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.12 v3 deprecated 2026-05-28** |
| BG-04 곡물상 v3 (v1.12 prompt-only, **deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.12 v3 deprecated 2026-05-28** |
| BG-05 잡화점 v3 (v1.12 prompt-only, **deprecated 2026-05-28**) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | (deprecated) | N/A | **v1.12 v3 deprecated 2026-05-28** |
| **BG-01 청과상 v4 (v1.13 image edit, anchor seed, base=BG-01_produce_v2.png)** | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | **pending (G_env_v4 8 요소)** | **v4 pending** |
| **BG-02 정육점 v4 (v1.13 image edit, base=BG-02_butcher_v2.png)** | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | **pending** | **v4 pending** |
| **BG-03 어물전 v4 (v1.13 image edit, base=BG-03_seafood_v2.png)** | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | **pending** | **v4 pending** |
| **BG-04 곡물상 v4 (v1.13 image edit, base=BG-04_grain_v2.png)** | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | **pending** | **v4 pending** |
| **BG-05 잡화점 v4 (v1.13 image edit, base=BG-05_sundry_v2.png, sauces 시그니처)** | pending | N/A(비율) | pending | pending | pending | pending | pending | pending | **pending** | **v4 pending** |

> G2의 chibi 비율 부분은 환경 N/A, 단순성(shape 1~2) 부분은 BG에도 적용 — 평가 시 단순성 측면만 채점.
> **v1.13 v4**: BG-01~05 v1.12 v3 prompt-only generation 5장은 **deprecated** (사용자 v3 verbatim "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."로 폐기). v4 image edit patch는 **gpt-image-1 image edit API** + Week 1 commit 7a6cffb base image (`BG-XX_<name>_v2.png` 5장) 직접 입력 + 지붕만 교체 + frontal view. v4 평가는 §5.6.2 G_env_v4 8 요소 게이트로 진행 (G_env_v3 5 요소 §5.6.4 archive). 캐릭터 5장은 무영향 (§3.1 표 v1.2 lock candidate 유지).

### 3.3 Subject anchor 후보 평가 (Step 0)

> sref URL 대체 — reference image upload + subject anchor 문장의 일관성 시드 적합성 평가.

| anchor | 평가 기준 | 결과 |
|--------|----------|------|
| Step 0a (캐릭터, CH-01 base) | reference image style transfer test 1 PASS (CH-02~05에 upload 시 같은 IP 인식 강제 가능). subject anchor 문장이 4 variant prompt에서 그대로 복사 가능한가. | pending |
| Step 0b (환경, BG-01 base) | reference image style transfer test 1 PASS (BG-02~05에 upload 시 같은 시장 인식 강제 가능). 시그니처 컬러 + 천막 shape이 환경 anchor 시드로 적합. | pending |

---

## 4. Anchor Lock 종합 게이트

### 4.1 Week 1 PASS 조건 (v1.2 G_new 추가, 모두 충족 시 LOCK)

1. **10 anchor 중 최소 8 LOCK** (개별 anchor 8 게이트 모두 PASS — G1~G7 + G_new, W1 한글 텍스트 깨짐은 CONDITIONAL default 허용)
2. **캐릭터 anchor reference image style transfer test 1 PASS** (Step 0a) — CH-02·CH-03 같은 family 인식 가능 확인
3. **환경 anchor reference image style transfer test 1 PASS** (Step 0b) — BG-02·BG-03 같은 시장 인식 가능 확인
4. **G_new modernity 8/10 anchor 충족 (v1.2 신설 critical)** — G_new FAIL이 3 anchor 이상이면 전체 FAIL → v1.2 reset 재실행 또는 pm 에스컬레이션 (iter2의 학습 — G_new가 무너지면 다른 게이트 PASS여도 사용자 reject 위험 높음).

> 8 LOCK + subject anchor 2 PASS = Week 1 게이트 통과 → M1 sprint kick-off.

### 4.2 부분 통과 정책

| 상황 | 정책 |
|------|------|
| 9~10 LOCK + subject anchor 2 PASS | 완전 통과, 즉시 M1 진입 |
| 8 LOCK + subject anchor 2 PASS | 통과, FAIL/CONDITIONAL 2 anchor는 M1 첫 주 reroll 병행 |
| 6~7 LOCK + subject anchor 2 PASS | **CONDITIONAL** — 부족한 anchor에 1 라운드 follow-up reroll 집중 (3~5일) |
| subject anchor 1 FAIL | **FAIL** — anchor 재생성 우선, 모든 파생 anchor 재생성 |
| 5 이하 LOCK | **FAIL** — pm 에스컬레이션, prompt/스타일 재논의 |

> flat 톤은 mascot 대비 reroll 빈도 ↓ 기대 → R1에서 8 LOCK 달성 확률 향상. ChatGPT sref 부재로 G1 캐릭터 일관성 lock이 가장 큰 risk — Step 0a anchor 품질이 G1 통과 핵심.

### 4.3 Lock 후 의무

- PASS된 subject anchor 파일 경로 2 + 10 anchor 파일 경로/subject anchor 문장을 `prompts-library.md` §0에 영구 기록
- `art-style-guide.md` §11 anchor 표 placeholder → 실제 파일 경로/ChatGPT 세션 URL 갱신
- M1 sprint 모든 자산은 본 anchor file을 reference image upload + subject anchor 문장 동일 복사 의무 사용 (변경 시 pm 승인)

### 4.4 라운드 예산

- **R1 (1차 시도)**: 사용자 ~1~1.5h ChatGPT 세션, art-director 평가 0.5h
- **R2 (follow-up reroll)**: 부족 anchor 집중, 사용자 +15~30분
- **R3 (재시도)**: R2 후에도 FAIL이면 → pm 에스컬레이션

---

## 5. ADR-005 cut anim 추가 anchor 게이트 (M1 후반 진입 시) — placeholder

> 본 sprint(Week 1 + M1 음식 hero)는 cut anim 평가 범위 외. M1 후반 진입 후 별도 mini-게이트.
> ChatGPT는 frame sequence를 같은 채팅 세션 안 follow-up으로 일관성 lock (1 image per request 워크플로).

| 항목 | M1 후반 PASS 기준 (placeholder, ChatGPT) |
|------|------------------------------------|
| 칼/도마 anchor | flat 톤 일관성 (CH/BG anchor file과 같은 outline 톤), 단순 silhouette. 1 image 생성 후 reference로 cut anim sequence에 upload. |
| Cut style 6종 frame 일관성 | 6종 모두 같은 ingredient base + cut state만 차이. 같은 채팅 세션에서 frame 1 → frame 2 follow-up "앞 frame과 동일 ingredient base, cut state만 변경"로 sequence 일관성 lock. frame 2~3개 안정. |
| ingredient cut variation 24장 | 음식 12 hero ingredient × whole+cut 2장. 같은 음식 anchor file을 reference upload하여 각 ingredient에 적용. |

---

## 5.5 M1 음식 12 평가 가이드 (v1.3 신설)

### 5.5.1 음식 anchor가 캐릭터/환경과 다른 점

> 음식 카드는 plated hero shot으로 캐릭터 없음 + bg solid + cooking action 없음. G2 chibi 비율 / G5 dynamic pose는 N/A. 대신 **G6 W5/W6 (한식↔일/중식 누수)이 가장 critical** — 음식 cross-cultural 누수가 핵심 risk.

| 게이트 | 캐릭터/환경 기준 | 음식 12 기준 (조정) |
|--------|----------------|-------------------|
| **G1 일관성** | 5장 같은 IP | 12장 같은 plate/bowl style + 같은 bg tone + 같은 outline 두께 + 같은 saturation. F-01 reference upload 기반. |
| **G2 chibi 비율 + dynamic pose** | 머리:몸 1:1.5~2 + 정적 standing FAIL | **N/A** (음식 카드는 캐릭터 없음). 대신 **plate/bowl 비율 hero shot** (그릇이 image 70%+ 차지) 측정. |
| **G3 modern saturated** | 80~90% + warm/cool 균형 | 동일. 음식 = warm (red gochujang/orange broth/golden brown) dominant + plate = cool (white baekja/pale celadon/cool sage bg) balance. |
| **G4 K-touch** | jeogori / onggi / 시장 | **음식 핵심 식별 시각 요소 (§prompts-library.md 5.2 각 음식 항목 "식별 핵심 시각 요소") 100% 충족** + 일본/중국/미국 누수 0건. **G_food (음식 특화) 신설로 분기**. |
| **G5 modern clean** | Royal Match 옆 fail-test | 동일. plated dish가 Royal Match food card screenshot 옆에 두면 같은 시대로 보이는가. 베이지/scrapbook bg 즉시 FAIL. |
| **G6 ChatGPT 약점** | W1~W10 0건 | 동일하나 **W5 (일본) + W6 (중국) + Western 누수**가 음식 특화로 critical. 가중치 ↑. |
| **G7 모바일 가독성** | 256px 축소 시 features 식별 | 동일. 256px 축소 시 음식 핵심 시각 요소 (Kimbap 컬러 dot section / Bibimbap radial 6 section / Galbi 뼈 / Tteokbokki 빨간 cylinder) 식별 가능. |
| **G_new modernity** | Royal Match side-by-side | 동일. food card도 Royal Match candy 옆에 두면 modern 인상 일치. |
| **G_food (신설, 음식 특화)** | — | **한식 vs 타국식 cross-cultural 누수 평가**. PASS = 0건 누수. 음식별 risk top 5 (F-12/F-03/F-06/F-11/F-09) 특화 검증. |

### 5.5.2 G_food (음식 특화) PASS 기준

- **F-01 Ramyeon**: Japanese ramen 누수 0. 흰 백자 bowl + 꼬불꼬불 curly yellow noodles + bright orange-red gochugaru broth + 노른자 중앙. narutomaki/nori/chashu 0건.
- **F-02 Hotteok**: Western pancake stack 누수 0. single flat disc + dark molten brown sugar filling oozing.
- **F-03 Kimbap**: Japanese maki sushi 누수 0. THICK 3cm + matte gim + cooked vegetables (yellow danmuji + orange carrot + green spinach + red ham) + NO raw fish/wasabi/gari.
- **F-04 Tteokbokki**: Chinese nian gao 누수 0. WHITE THICK CYLINDRICAL rice cakes (finger-shape) + bright vibrant red gochujang sauce + fish cake slices.
- **F-05 Kimchi Fried Rice**: Chinese egg fried rice 누수 0. red-orange kimchi dominant + chopped red kimchi 조각 + sunny-side-up whole egg on top. NO green peas/diced carrots Western mirepoix.
- **F-06 Korean Corn Dog**: American corn dog 누수 0. mozzarella cheese stretch (2~3 strands) + crispy panko crumb coating + ketchup AND mustard zigzag. NO smooth yellow cornmeal batter.
- **F-07 Haemul Pajeon**: Japanese okonomiyaki 누수 0. long thick green scallions (대파) dominant + 새우 + 오징어 ring. NO mayo squiggle/bonito flakes/aonori/brown okonomiyaki sauce.
- **F-08 Bibimbap**: Western Buddha bowl 누수 0. radial 5~6 vegetable section (한식 6종) + center egg yolk + gochujang dollop. NO avocado/quinoa/Western superfoods.
- **F-09 Kimchi Jjigae**: Chinese hot pot 누수 0. 검정 ttukbaegi (rounded thick rim, individual portion) + bright red-orange gochugaru broth + 흰 두부 blocks. NO raw thin-sliced meat around/Sichuan mala peppercorns.
- **F-10 Sundubu Jjigae**: Chinese mapo tofu 누수 0. 검정 ttukbaegi + fluffy cloud-like soft tofu (NOT firm block) + cracked raw egg yolk 중앙. NO brown Sichuan sauce.
- **F-11 Japchae**: Chinese lo mein 누수 0. translucent brown-amber sweet potato glass noodles (dangmyeon, see-through) + 6+ vegetable colors + 깨 generous sprinkle. NO yellow egg noodles/wok hei char marks.
- **F-12 Galbi-gui**: Japanese yakiniku + American BBQ 누수 0. **VISIBLE WHITE RIB BONE running through each meat piece** + shiny brown soy-pear-garlic marinade + 깨 sprinkle + 상추 ssam side. NO American red BBQ sauce/thick slab/Japanese thin slice no-bone.

### 5.5.3 Tier 1/2 시각 구분 단서 (abundance)

| Tier | 시각 단서 (한 image에서 식별) | 음식 예 |
|------|-----------------------------|--------|
| **T1 (1인분 단순)** | bowl/plate 1개 + garnish 2~3종 + side dish 없음 또는 1종 | F-01 Ramyeon (bowl + 노른자 + 파 + 고추 slice 1) / F-02 Hotteok (disc 1~2 + 깨) / F-04 Tteokbokki (떡 6~10 + fish cake + 파) |
| **T2 (2인분 풍성)** | bowl/plate 큼 + garnish 4+ 종 또는 6+ vegetable color 또는 3+ rib pieces + festive 느낌 | F-08 Bibimbap (6 vegetable section + 노른자 + dollop) / F-11 Japchae (6+ vegetable color + 면 풍성) / F-12 Galbi-gui (3~4 rib pieces + 깨 + 상추) |

> T1 → "single bowl, 2-3 garnish" / T2 → "Tier 2 abundance, generously filled" prompt 키워드로 구분. 시각 평가 시 abundance 단서로 판정.

### 5.5.4 음식 12 평가 표 (R3 reroll trigger 후 status, v1.6 갱신)

> 2026-05-27 R1 평가 완료 (12/12 LOCK on G_food cross-cultural). **R2 v2 결과 사용자 selective 피드백 6건 raise → R3 reroll trigger**. F-07/F-08/F-10/F-11 4장은 사용자 silent ACK → R2 LOCK candidate 갱신. F-04 떡볶이 / F-09 김치찌개 2장은 R1 LOCK 유지. 6건은 prompts-library v1.5 본문 패치 후 v3 실행 대기.

| Anchor | food_id | Tier | bg | G1 일관성 | G3 saturated | G4 K-touch | G5 modern clean | **G6 (W5/W6)** | G7 가독성 | G_new modernity | **G_food 누수 0건** | **G_user_visual_detail (v1.5 신설, v1.6 R3 갱신)** | 종합 |
|--------|---------|------|-----|----------|--------------|-----------|-----------------|---------------|----------|----------------|---------------------|------------------------------------------------|------|
| F-01 Ramyeon | t1_002 | T1 | CW | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 | **FAIL R2** (사용자: 원래 v1이 더 먹음직스러움. v2가 너무 보수적/축소 → v1 base 회복 + 면만 thin) | **R3 reroll pending (v1 base 회복)** |
| F-02 Hotteok | t1_001 | T1 | CW | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 | **FAIL R2** (사용자: 위에 시럽을 좀 뿌려주는걸로 → contained filling 유지 + 표면 syrup drizzle 추가) | **R3 reroll pending** |
| F-03 Kimbap | t1_004 | T1 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 (Japanese maki 누수 0) | **FAIL R2** (사용자: 원래 v1이 더 나음, 단 밥알만 더 작게 → v1 base 회복 + rice FINE small fix) | **R3 reroll pending (v1 base 회복)** |
| F-04 Tteokbokki | t1_003 | T1 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1 | **PASS R1** (사용자 피드백 없음) | **LOCK (R1 유지)** |
| F-05 Kimchi Fried Rice | t1_005 | T1 | CW | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 | **FAIL R2** (사용자: v1에서 밥알만 더 작게 → v1 base 회복 + rice FINE small fix) | **R3 reroll pending (v1 base 회복)** |
| F-06 Korean Corn Dog | t1_007 | T1 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 (American corn dog 누수 0) | **FAIL R2** (사용자: 원래 소세지가 안에 있는데, v2는 cheese인지 뭔지 모르겠음 → cross-section 4요소 명확: sausage core + cheese stretch + panko + ketchup/mustard zigzag) | **R3 reroll pending (cross-section 4요소 강화)** |
| F-07 Haemul Pajeon | t1_006 | T1 | CW | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 | **PASS R2** (사용자 silent ACK — 반죽 안 embedded fix v2 적용 OK) | **R2 LOCK candidate (사용자 silent ACK)** |
| F-08 Bibimbap | t2_008 | T2 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 | **PASS R2** (사용자 silent ACK — rice FINE small fix v2 적용 OK) | **R2 LOCK candidate (사용자 silent ACK)** |
| F-09 Kimchi Jjigae | t2_009 | T2 | CW | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1 (Chinese hot pot 누수 0) | **PASS R1** (사용자 피드백 없음) | **LOCK (R1 유지)** |
| F-10 Sundubu Jjigae | t2_013 | T2 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 | **PASS R2** (사용자 silent ACK — fluffy cloud-like curds fix v2 적용 OK) | **R2 LOCK candidate (사용자 silent ACK)** |
| F-11 Japchae | t2_010 | T2 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 (Chinese lo mein 누수 0) | **PASS R2** (사용자 silent ACK — dangmyeon THIN delicate fix v2 적용 OK) | **R2 LOCK candidate (사용자 silent ACK)** |
| F-12 Galbi-gui | t2_012 | T2 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2/R3/R4/R5/R6 (Japanese yakiniku + American BBQ 누수 0) | **FAIL R6** (사용자 v6 시각 확인 후 또 다른 reference image 제시 + verbatim "이걸로 해줘" + 5건 추가 fix 요청: (1) form 전면 교체: small square pieces grid (3-4cm × 3-4cm, 12-16 pieces in 3-4 rows × 4 columns) → 4-6 large rectangular LA-style strips (18-25cm × 8-12cm × 0.5-0.8cm) parallel side by side. 정통 LA-cut form 회귀 / (2) bone form 완전 재정의 (CRITICAL): single LONG WHITE RIB BONE at SHORT EDGE → 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS (each ~1.5-2cm diameter) along each strip's LENGTH (evenly spaced ~3-5cm apart). LA-style cross-cut bones — ribs cut perpendicular to original direction. R3에서 시도됐다가 폐기됐던 패턴이 R7 reference의 정확한 패턴 / (3) garnish 변경: chopped minced garlic dots → chopped GREEN SCALLION rounds (송송 sliced 대파, 1-3mm thick discs, bright green) + 깨 minor accent / (4) plate context 변경: cast iron plate → ROUND METALLIC WIRE MESH GRILL GRATE + optional hot coals glow / (5) view angle 변경: top-down → slight 7/8 perspective. v6의 LOCK 4 요소 (well-grilled brown + glaze / char marks / thin 0.5-0.8cm / cross-cultural negative + NOT v6 grid form) 무변경. 칼집은 optional로 격하. R6 v6 deprecated → R7 v7 5건 fix patch) | **R7 reroll pending (LA-cut long strips + cross-section bone discs along length + green scallion rounds + wire mesh grate + 7/8 perspective 5건 fix)** |

#### R1 minor findings (CONDITIONAL note, M1 후반 sprint 시 통일)
- **bg mixed (cool sage 7장 + cream-white 5장)**: STYLE_SUFFIX_FOOD §2.4 "choose one consistently" 위반이나 둘 다 허용된 cool tone bg + cross-cultural 식별 영향 0. M1 후반 ingredient/cut anim 시 1개 bg로 통일 권고 (cool sage `#C8D5C0` 권장 — 식판/접시 흰색과 contrast ↑).
- **F-08 Bibimbap gochujang dollop 별도 분리 안 보임**: 빨간 섹션과 통합. 시그니처 식별에 critical 영향은 없으나 M1 ingredient 분리 시 별도 prompt 가능.
- bg cool sage = F-03/F-04/F-06/F-08/F-10/F-11/F-12 (7장)
- bg cream-white = F-01/F-02/F-05/F-07/F-09 (5장)

### 5.5.5 음식 12 종합 LOCK 조건

> 음식 12 평가 LOCK 기준 (캐릭터/환경 8/10보다 약간 완화 — 음식 cross-cultural 누수 risk 본질적으로 높음):

1. **12 중 최소 10 LOCK** (개별 음식 G1~G7 + G_new + G_food 9 게이트 모두 PASS, G_food는 CONDITIONAL 불허 — 누수 1건이라도 있으면 FAIL)
2. **T1 7장 중 최소 6 LOCK** (T1은 한식 식별 단순, 누수 risk 낮은 음식 다수)
3. **T2 5장 중 최소 4 LOCK** (T2는 어려움, F-12 Galbi-gui FAIL 1장은 허용)
4. **risk top 5 음식 (F-03/F-06/F-11/F-12/F-09) 중 최소 4 LOCK** — 가장 critical, 4 LOCK 미만이면 전체 FAIL
5. **F-01 Ramyeon anchor 시드 PASS 필수** — F-01 FAIL이면 11장 reference upload 일관성 무너짐 → 전체 reroll

#### 부분 통과 정책

| 상황 | 정책 |
|------|------|
| 11~12 LOCK + F-01 PASS + risk top 5 중 5 LOCK | 완전 통과, 즉시 M1 ingredient/UI sprint 진입 |
| 10 LOCK + F-01 PASS + risk top 5 중 4 LOCK | 통과, FAIL 2장은 ingredient sprint 첫 주 reroll 병행 |
| 8~9 LOCK + F-01 PASS | **CONDITIONAL** — FAIL 음식에 1 라운드 follow-up reroll 집중 (1~3일) |
| F-01 FAIL 또는 risk top 5 중 3 이하 LOCK | **FAIL** — F-01 재생성 우선 + risk top 5 prompt 재설계 / pm 에스컬레이션 |
| 7 이하 LOCK | **FAIL** — pm 에스컬레이션, prompt/스타일 재논의 |

### 5.5.6 음식 12 라운드 예산

- **R1 (1차 시도)**: 사용자 ~1.5~2.5h ChatGPT 세션 (F-01 anchor + T1 6장 + T2 5장), art-director 평가 0.5h
- **R2 (follow-up reroll)**: risk top 5 음식 집중, 사용자 +30~60분 (F-12가 가장 무거움)
- **R3 (재시도)**: R2 후에도 FAIL 4+ 음식이면 → pm 에스컬레이션

### 5.5.7 G_user_visual_detail (v1.5 신설, 사용자 시각 디테일 게이트)

> **배경**: M1 R1 결과 G_food cross-cultural 누수는 12/12 회피 (LOCK), 그러나 사용자 시각 확인 후 **음식 디테일 측면에서 10건 FAIL** 발생 (rice grain 크기, noodle 두께, syrup overflow, paper wrapper, scallion 위치, tofu shape, bone shape). G_food와 별도의 critical 게이트로 신설.

- **정의**: 사용자가 음식 디테일 관점에서 "현실의 한식과 일치하는가? 어색/엉터리 요소 0건"을 평가. G_food (cross-cultural 누수)와 직교 — G_food PASS여도 G_user_visual_detail FAIL 가능 (R1 결과로 검증됨).

- **PASS 기준**:
  - 재료 크기·두께·비율이 실제 한식과 일치 (rice grain FINE, noodle THIN delicate, dangmyeon delicate, rib piece LA cross-cut)
  - 재료 위치·배치가 실제 조리법과 일치 (파전 파/새우 = 반죽 안 embedded, 호떡 시럽 = 안에 contained)
  - 보조 element (paper wrapper, garnish 배치)가 어색하지 않음
  - 음식 핵심 형태 (뚝배기 두부 = fluffy cloud-like irregular curds, 갈비 = LA cross-cut 2-3 bone discs)가 자연스러움

- **FAIL 시 액션**: prompts-library 본문에 fix 추가 (THIN/FINE 같은 강도 단어 + negative 명시 + 필요 시 전면 재작성) → reroll v2.

- **art-director note**: G_user_visual_detail은 G_food와 동등한 critical. R2 평가 시 사용자 피드백 10건 fix가 1:1 적용됐는지 항목별 점검 필수. R2 평가에서 G_user_visual_detail 기준 (v1.5):
  - **F-01**: 면이 visibly THIN delicate strand (chunky 아님)
  - **F-02**: syrup 표면 slit에서 tiny hint만 (pool/flooding 아님)
  - **F-03/F-05/F-08**: rice grain 작고 조밀 (chunky 아님)
  - **F-06**: paper wrapper/holder 0건 (stick 만으로 깨끗하게 holding)
  - **F-07**: scallion + shrimp가 batter 안 embedded (위에 laid 아님)
  - **F-10**: tofu가 fluffy cloud-like irregular curds (smooth/firm/single block 아님)
  - **F-11**: dangmyeon이 THIN delicate translucent (chunky 아님)
  - **F-12**: LA cross-cut strip + 2-3 small round bone discs along length (single giant bone / 한쪽 옆 뼈 / thick slab 아님, natural overlapping plating)

- **R3 평가 기준 갱신 (v1.6, 2026-05-27)**: R2 v2 결과 6건 추가 FAIL → R3 v3 평가 시 적용. F-07/F-08/F-10/F-11 4건은 v2 LOCK candidate로 R3 평가 범위 외 (사용자 silent ACK 후 LOCK 확정 또는 follow-up). F-04/F-09 R1 LOCK 유지로 R3 평가 범위 외. R3 평가 대상 6건:
  - **F-01 (R3)**: v1 base 회복 — broth/noodle/egg/garnish 전반이 v1처럼 식욕 자극, 면만 visibly THIN delicate strand. v2의 보수적 축소 톤 회피 확인.
  - **F-02 (R3)**: contained filling (안에서 안 흐름) + 표면에 **별도 topping syrup drizzle** (small glossy ribbon, pancake topping 느낌). 두 layer가 시각적으로 명확히 구분되는가 (filling = contained inside, drizzle = on top decoration).
  - **F-03 (R3)**: v1 base 회복 — 김밥 단면 컬러 5종 + matte gim + thick roll 모두 v1 톤 유지, 밥알만 FINE small grains.
  - **F-05 (R3)**: v1 base 회복 — 김치 빨강 + 노른자 hero + 가니쉬 모두 v1 톤, 밥알만 FINE small grains.
  - **F-06 (R3)**: 베어 문 단면에 **4요소 모두 명확 visible**: (1) brown cooked sausage 본체 cylindrical 가운데 보임 (NOT cheese-only filling, sausage core MUST be visible as distinct brown shape) / (2) yellow mozzarella cheese 2-3 stretchy strands / (3) golden panko crust slightly bumpy outside (distinct layer) / (4) ketchup red + mustard yellow zigzag on top.
  - **F-12 (R3)**: **정통 한식 갈비구이** (LA-cut 폐기 — multiple bone discs along length 시 FAIL). 각 piece = **thin elongated meat strip 5-7cm long × 1-1.5cm thick** + **한쪽 끝(ONE END only)에 SHORT WHITE BONE 1-2cm 노출** (가운데 cross-section bone disc 없음, NOT thick steak slab, NOT bone-less yakiniku slice, NOT American rack of ribs). 3-4 piece overlapping naturally + soy-pear-garlic glaze + grill marks + 깨 + 마늘 slice + 상추 ssam side. **(v1.7 deprecated — R3 v3 결과 사용자 reference image와 어긋남 발견, §5.5.8 F-12 R4 평가 기준으로 supersede)**

### 5.5.8 F-12 R7 평가 기준 (v1.10 신설, R4/R5/R6 기준 deprecated, 사용자 또 다른 reference image 7 요소 점검표)

> **배경**: R6 v6 결과 시각 확인 후 사용자가 **또 다른 reference image** (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length)를 제시하며 verbatim "이걸로 해줘" 명시 + 5건 추가 fix 요청 — (1) form 전면 교체 (small square pieces grid → 4-6 large LA-style rectangular strips parallel) / (2) bone form 완전 재정의 (single long bone at short edge → 3-4 cross-section discs along each strip's length, CRITICAL LA cross-cut signature) / (3) garnish 변경 (chopped minced garlic dots → chopped green scallion rounds) / (4) plate/grill context 변경 (cast iron plate → round metallic wire mesh grill grate) / (5) view angle 변경 (top-down → slight 7/8 perspective). v6의 LOCK 4 요소 (well-grilled brown + glaze / char marks / thin 0.5-0.8cm / cross-cultural negative + NOT v6 grid form) 무변경. **칼집 (knife score marks)은 optional로 격하** — LA-cut form에서는 cross-cut bones이 dominant signature이고 char marks가 dominant surface texture, score marks는 reference에 명확히 보이지 않음. R4 v4 / R5 v5 / R6 v6 평가 기준 = **deprecated**, R7 v7 평가 = 사용자 또 다른 reference 7 요소 1:1 점검표로 재정의.

#### F-12 R7 G_user_visual_detail PASS 게이트 (7 요소 점검표, v1.10 신설)

> **R7 PASS = 7 요소 ALL 충족. 1개라도 누락 시 FAIL → R8 reroll 또는 pm 에스컬레이션. CRITICAL = 행 4 (3-4 bone cross-section discs along length, LA cross-cut signature).**

| # | 요소 | 사용자 또 다른 reference 시각 명세 | PASS 판정 기준 | FAIL 사례 (즉시 reroll) |
|---|------|------------------------------|----------------|----------------------|
| 1 | **LA-cut long strip form (v1.10 신설 — form 전면 교체)** | 4-6 large rectangular LA-style meat strips, 각 strip approximately 18-25cm long × 8-12cm wide × 0.5-0.8cm thick. 정통 LA갈비 cross-cut form. R6의 small square pieces grid form 완전 폐기. | 4-6개의 large rectangular LA-style strips visible (각 길이 18-25cm × 폭 8-12cm). strip 자체가 큼 (R5 strip 12-15cm × 3cm보다 더 큼). 길이:너비 비율 ≈ 2-3:1. | small square pieces grid form (R6 사례) / 너무 작은 strips (10cm 이하 길이) / 너무 좁은 strips (5cm 이하 너비) / strip 수 3개 이하 또는 8개 이상 / 정사각형 piece 형태 (길이:너비 ≈ 1:1) |
| 2 | **multiple strips parallel arrangement (v1.10 신설)** | 4-6 large rectangular strips arranged side by side parallel on the grill grate (slight natural overlap or aligned, NOT perfectly geometric grid). 자연스러운 BBQ 배치. | strips가 옆으로 나란히 (parallel side by side), 일부 strips slightly overlap or sit side by side. 자연스러운 BBQ 배치 인상. | random scatter / strict geometric grid (R6 사례) / strips 방향 제각각 / strips 따로 분리 |
| 3 | **thin slice 0.5-0.8cm (5-8mm) (v1.10 LOCK 유지)** | 각 strip 두께 매우 얇음, 5-8mm thick, paper-thin appearance. 7/8 perspective angle에서 side profile visibly thin. | 각 strip이 visibly THIN slice 인상 (5-8mm로 인식 가능, paper-thin appearance), 7/8 angle에서 side profile에서 명확히 얇음. | thick slab (1cm+) / steak thickness / 두께 인식 불가 평면 / 너무 두꺼워 chunk처럼 보임 |
| 4 | **CRITICAL: 3-4 bone cross-section discs along each strip's LENGTH (v1.10 신설 — LA cross-cut signature)** | 각 meat strip의 LENGTH 방향을 따라 3-4 small round white bone cross-section discs (각 disc ~1.5-2cm diameter, cream-white color)가 evenly spaced (~3-5cm apart). 이건 LA갈비의 정통 cross-cut 손질법 — 갈비뼈를 가로질러 자른 cross-section의 작은 둥근 흰 뼈 disc 여러 개가 strip 따라 나타남. | 각 strip의 길이 방향을 따라 ≥3 small round white bone discs (각 ~1.5-2cm 지름) visible, evenly spaced. cream-white color. LA cross-cut signature 인상. | single long bone alongside grid (R6 사례) / bone discs partially embedded along TOP LONG EDGE only (R5 사례) / one big bone at strip tip (R3 사례) / bone 0건 / disc 수 2 이하 또는 6 이상 per strip / bones 모양이 disc가 아닌 chunk |
| 5 | **well-grilled caramelized brown + glaze sheen + char marks (v1.10 LOCK 유지)** | rich caramelized dark brown + glossy soy-pear-garlic marinade glaze + visible dark char marks/burned lines on surface from grill (LA-cut form에서 char marks가 dominant surface feature). | 전체 strips 색이 dark brown (well-cooked) + glaze sheen 표면 윤기 + visible dark char marks/burned lines on surface. char marks가 dominant surface texture. | raw red-pink / pale uncooked / 회색 burned / 색 generic 평이 / char marks 0건 / glaze sheen 없는 dry 표면 |
| 6 | **chopped green scallion rounds garnish (v1.10 신설 — garnish 재정의)** | 잘게 썬 green scallion rounds (송송 sliced 대파, 1-3mm thick discs, bright green color) scattered across meat strips as hero garnish + 깨 sprinkle minor accent. | 모든 meat strips 위에 small bright green disc-shaped slices (1-3mm 두께, 송송 sliced 대파) scattered. green scallion rounds가 hero garnish로 인식 가능. 깨는 minor accent. | chopped minced garlic dots (R6 사례) / thin garlic slices / whole garlic cloves / 깨만 sprinkled (green scallion 없음) / green scallion이 long chopped (송송 sliced 아님) / garnish 0건 |
| 7 | **round metallic wire mesh grill grate context (v1.10 신설 — plate context 재정의)** | 둥근 metallic wire mesh grill grate (silver-gray wire pattern visible) 위에서 굽고 있는 상태. wire mesh pattern is visible underneath/around the meat strips. optional subtle hint of red-orange glow underneath (hot coals atmosphere). | round metallic wire mesh grill grate (silver-gray wire pattern) 명확히 visible 아래 strips. wire mesh 시그니처 인상. optional hot coals glow OK. | flat solid plate (v6 사례) / white ceramic plate / black cast iron flat pan (v4/v5/v6 사례) / 검정 grill plate / 마대 cooking surface / grate 0건 (just meat on plain bg) |

#### F-12 R7 (옵션 게이트) — 칼집 (knife score marks)

> **R7에서 칼집은 optional 게이트로 격하**. LA-cut form에서는 cross-cut bones이 dominant signature이고 char marks가 dominant surface texture. R7 reference image에서 score marks는 명확히 보이지 않음.
> - **PASS**: 표면에 horizontal score marks visible 또는 not visible (둘 다 OK)
> - **FAIL 없음**: 칼집 없어도 R7 PASS 가능 (단 R7 7 요소 중 1-7번 모두 충족 필수)

#### F-12 R7 R8 escalation 정책

- **R7 PASS (7/7 충족)**: F-12 R7 LOCK → §0 anchor 표 기록 + M1 음식 12 종합 LOCK 완료
- **R7 1-2 요소 FAIL**: art-director가 항목별 reroll trigger follow-up 1 라운드 (§5.2 F-12 §1.9 R7 reroll 트리거 7종 사용 — form 잘못 (small square pieces grid 회귀 CRITICAL) / bone form 잘못 (single long bone at short edge 회귀 CRITICAL) / garnish 잘못 (minced garlic / garlic slice 누수) / plate context 잘못 (flat plate / cast iron 누수) / view angle 잘못 (top-down 회귀) / thickness 두꺼움 / raw·steak 색)
- **R7 3+ 요소 FAIL**: pm 에스컬레이션 — prompt 재설계 또는 reference image inline upload 전략 검토 필요. 또한 사용자 시각 의도 진화 (v3→v4→v5→v6→v7)가 5번째 round이므로, 본 round에서 LOCK 실패 시 사용자 의도 재확인 필요 (chain-of-references 누적 시 prompt가 누적 복잡도로 self-conflict 가능성)

#### F-12 사용자 시각 의도 진화 timeline (v3 → v4 → v5 → v6 → v7)

> 각 round에서 사용자 reject 사유 + 최종 R7 settle 형태:

| Round | 본문 핵심 | 사용자 reject 사유 (verbatim) | 다음 round fix 방향 |
|-------|----------|---------------------------|------------------|
| **R3 v3** | 3-4 thin elongated meat strips (5-7cm) + 한쪽 끝(ONE END only)에 SHORT WHITE BONE 1-2cm protruding | "그냥 steak 같음. 갈비구이는 끝에 뼈가 좀 있어야 됨" (LA-cut 폐기 사유) — bone form이 single bone at end이지 reference (사용자 직접 reference image 제시)와 어긋남 | R4: 칼집 + parallel strips + small bone discs at edges (LA cross-cut + 칼집 결합) + well-grilled brown |
| **R4 v4** | 4 thin elongated parallel strips (12-15cm × 3cm × 1-1.5cm) + 칼집 3-5 cuts + small bone discs nestled between strips at plate edges + well-grilled brown | "고기가 일단 더 얇아야 함. 긴쪽의 밑쪽이 아니라 윗부분의 사이드로 보여야함" (thickness 두꺼움 + bone 위치 잘못) | R5: thickness 0.7-1cm thin + bone TOP LONG EDGE partially embedded |
| **R5 v5** | 4 strips (12-15cm × 3cm × 0.7-1cm thin) + 칼집 + bone discs along TOP LONG EDGE of each strip + well-grilled brown + sesame + 1-2 thin garlic slices | "가위로 자르고 난후의 갈비구이....Short Edge쪽에 뼈가 길게 있잖어....그리고 고기 자체도 훨씬 얇게 되어 있고...." (form/thickness/bone/garnish 모두 어긋남) — 사용자 새 reference (가위로 자른 후의 eating-style state) 제시 | R6: form 전면 교체 (long strips → small square pieces grid) + thickness 0.5-0.8cm + bone SHORT EDGE long single bone + chopped minced garlic dots |
| **R6 v6** | 12-16 small square pieces (3-4cm × 3-4cm × 0.5-0.8cm thin) in grid pattern (3-4 rows × 4 columns) + 칼집 maintained on each piece + single LONG WHITE RIB BONE at ONE SHORT EDGE side + chopped minced garlic dots scattered + black cast iron grill plate + top-down view | "이걸로 해줘" (사용자 또 다른 reference image 제시 — 정통 LA갈비 wire mesh grill grate 위 large rectangular strips with cross-section bone discs along length) — R6 form/bone/garnish/plate/view 모두 어긋남 | R7: LA-cut large strips (18-25cm × 8-12cm × 0.5-0.8cm) + 3-4 cross-section bone discs along each strip's length (LA signature) + green scallion rounds + wire mesh grill grate + 7/8 perspective. 칼집 optional |
| **R7 v7 (current settle)** | 4-6 large LA-style rectangular strips (18-25cm × 8-12cm × 0.5-0.8cm thin) parallel side by side on wire mesh grill grate + 3-4 small round white bone cross-section discs along each strip's length (evenly spaced ~3-5cm apart, LA-style cross-cut signature) + well-grilled caramelized brown + glaze + char marks + chopped GREEN SCALLION ROUNDS as hero garnish + 깨 minor + slight 7/8 perspective view. 칼집은 optional. | (R7 pending) | 사용자 R7 v7 시각 확인 후 추가 fix request 여부 결정 |

#### F-12 R6 v6 평가 기준 (deprecated, v1.10에서 R7 7 요소 점검표로 supersede)

> R6 v6 평가 기준 (v1.9 §5.5.8 7 요소 점검표: square piece form / grid pattern / thin 5-8mm / long bone at short edge / 칼집 maintained / well-grilled brown / chopped minced garlic dots) = **deprecated**. 사용자 또 다른 reference image (정통 LA갈비 wire mesh grill grate 위 large rectangular strips with cross-section bone discs along length)와 어긋남 → R7 7 요소 점검표로 supersede. 자세한 R6 평가 기준은 git history (art-anchor-rubric v1.9 §5.5.8) 참조.

#### F-12 R5 v5 평가 기준 (deprecated, v1.9에서 R6 7 요소 점검표로 supersede, v1.10에서도 deprecated 유지)

> R5 v5 평가 기준 (v1.8 §5.5.8 6 요소 점검표: 칼집 / strictly parallel strips / well-grilled brown / bone TOP LONG EDGE / 길이 12-15cm / 두께 0.7-1cm) = **deprecated**. 자세한 R5 평가 기준은 git history (art-anchor-rubric v1.8 §5.5.8) 참조.

---

## 5.6 M1 환경 5 V4 평가 가이드 (v1.13 신설, image edit v1.2 base + 지붕만 교체 + frontal view + 5가게 구조 일관성)

### 5.6.1 배경 — Week 1 환경 v1.12 v3 deprecation + v4 image edit

> 2026-05-28 R2 (v1.12 v3 minimal 5장 prompt-only batch generation) 결과 시각 확인 후 사용자가 verbatim **"각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."** 명시 → v1.12 v3 전면 폐기. v1.13 v4 = **gpt-image-1 image edit API + Week 1 commit 7a6cffb base image (`assets-raw/week1-anchors/BG-XX_<name>_v2.png` 5장) 직접 입력 + 지붕만 교체 + frontal view**. v3의 prompt-only batch generation 한계 (5가게 carpenter 작업 generation noise + slight 7/8 perspective + v1.2 base 정확 재현 불가능) 모두 해결.
>
> 시각 의도 진화 timeline: v1.2 lock candidate (modern Western storefront base + 천막) → **사용자 reject "올드함 + 천막 stripe ↔ 한식 정통 X"** → v1.11 v2 한옥 풀세트 (한옥 + 옹기 + lantern + 처마 + 와당 풀세트) → **사용자 reject "너무 많음 + 다른거 그대로 + 기와 지붕만"** → v1.12 v3 minimal prompt-only generation (v1.2 base + 기와 지붕 단일 fix) → **사용자 reject "각 가게 디자인 조금씩 다름 + 지붕 기둥 똑같아야 + 원래 버젼에서 지붕만 + 정면이 더 낫지 않나"** → v1.13 v4 image edit (base PNG 직접 입력 + 지붕만 교체 + frontal view). v4에서 settle 기대.

### 5.6.2 G_env_v4 (환경 v4 image edit 게이트, v1.13 신설; G_env_v3 5 요소 §5.6.4 deprecated)

> **정의**: 환경 v4 anchor가 사용자 R2 v3 verbatim "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..." 명시를 **5+3 = 8 게이트 항목**으로 점검. G_env_v3 5 요소 (기와 지붕 단일 / v1.2 base 카테고리 시그니처 / icon+영어 minimal signage / Cool Sage bg + modern saturated / v2 한옥 풀세트 추가 요소 0건)은 그대로 보존하되, **v4 추가 3 요소** (5가게 구조 정확 일관성 / frontal view / v1.2 base 시각 시그니처 정확 유지)로 사용자 의도 3건 fix 점검. G_new (modernity) + G3 (saturated) + G5 (modern clean)과 직교 critical 게이트.

#### G_env_v4 8 요소 PASS 기준 (5/5 anchors × 8 요소 = 40/40 PASS 시 환경 v4 sprint LOCK)

> v3 → v4 변경 핵심: 기존 G_env_v3 5 요소 (#1~#5)는 그대로 점검 + **#6 5가게 구조 정확 일관성**, **#7 frontal view**, **#8 v1.2 base 시각 시그니처 정확 유지** 3건 신설.

| # | 요소 | 사용자 의도 시각 명세 | PASS 판정 기준 | FAIL 사례 (즉시 reroll) |
|---|------|------------------------------|----------------|----------------------|
| 1 | **검정 기와 곡선 지붕 단일 layer visible (천막 0건, CRITICAL)** | curved black ceramic tile roof (Korean hanok 기와 eave roof) — dark slate gray to black curved eave tile, 처마 곡선 corners gently upward, optional 와당 2-3개 accent. **SINGLE simple layer** sitting on top of shop front as topmost band. base image의 천막 자리에 기와 지붕 swap. | 검정 기와 곡선 지붕 단일 layer 명확 visible. dark slate/black curved eave tile + 처마 곡선 corners upward. roof는 storefront 위에 slim band (image 상단 ~20-25%). 천막 0건. | 천막 회귀 (red/green striped awning 재출현) / flat roof (곡선 없음) / 기와 X / Chinese pagoda multi-tier sharp upturned / Japanese irimoya hip-and-gable / 한옥 frame 풀세트 (vertical posts on both sides 추가) / 깊은 처마 overhang (heavy shadow band) |
| 2 | **v1.2 base 카테고리 시그니처 visible (BG별 1-2 icons + signature color)** | base image v1.2의 가게 카테고리 시그니처 그대로 유지: BG-01 채소 stack (cabbage hero + 배추 + apples + 오이 + 대파) + 좌측 옹기 2개 + 우측 onion hanging / BG-02 meat slab hanging 2-3개 + 도마 + butcher knife / BG-03 fish hanging 2개 + 흰 ice block / BG-04 곡식 자루 3종 (tan + warm brown + red bean) / BG-05 sauce 항아리 4개 row + 우측 dried red chili 고추 hanging | 5가게 카테고리 식별 가능 (외부인 0.5초 안에 가게 카테고리 답). 각 가게 v1.2 base 시그니처 그대로 (BG-01 채소 stack + 좌측 옹기 2개 / BG-05 sauce 4개 + 고추 등). image edit으로 base image와 ABSOLUTELY IDENTICAL. | 카테고리 시그니처 누락 / v1.2 base 시그니처 변경 (BG-01 좌측 옹기 2개 → 0개 / BG-05 sauce 4개 → 2개) / 다른 가게로 추론 (정육점에 채소) |
| 3 | **icon+영어 minimal signage (한글 0건, CRITICAL)** | 작은 wooden signboard at top of shop front (below tile roof). icon-first (~60-70%) + SHORT English minimal text label (~20-25%) below. 5가게 영어 v1.2 base = PRODUCE / BUTCHER / SEAFOOD / GRAIN / SAUCES. base image 그대로 유지 (image edit으로 텍스트/icon 변경 없음). | wooden signboard visible + 카테고리 icon (~60-70%) + English minimal text below (legible). 한글/한자/카타카나 0건. v1.2 base 영어 그대로. | 한글/한자/카타카나 누수 (1글자라도) / 영어 text 없이 icon만 / signboard 자체 누락 / sub-text 추가 / image edit이 텍스트 영역 손상 |
| 4 | **Cool Sage bg + modern saturated 톤 (베이지 0건, CRITICAL)** | Cool Sage #C8D5C0 solid background + 채도 80-90% + warm/cool 균형 + bold outline 2-3px + modern flat clean. base image의 bg 그대로 유지 (또는 image edit prompt에 따라 Cool Sage로 환원). | bg = solid Cool Sage #C8D5C0. 채도 80-90%. slim outline 2-3px. modern flat clean. 베이지/cream/scrapbook 0건. | 베이지/cream/vintage paper bg / scrapbook/storybook / golden hour / 채도 70% 이하 muted / 채도 100% neon / heavy outline 4px+ |
| 5 | **v2 한옥 풀세트 추가 요소 0건 (minimal LOCK, CRITICAL)** | 옹기: BG-01 좌측 2개만 (v1.2 base 그대로). 나머지 BG-02/03/04는 옹기 0건, BG-05는 sauce 항아리 4개 카운터 진열만. lantern 0건 + 목조 frame 추가 0건 + 깊은 처마 overhang shadow band 0건. | 옹기: BG-01 좌측 2개만. 나머지 BG-02~05 옹기 0건. lantern 0건. 목조 frame vertical posts 0건 (base image의 기존 frame은 OK). 깊은 처마 shadow band 0건. | 옹기 추가 누수 (BG-02/03/04에 옹기 / BG-05 ground prominent 옹기 1+개) / lantern 1+개 / 목조 한옥 frame vertical posts 추가 / 깊은 처마 overhang / 와당 풀세트 (3+개 풀 line) |
| 6 | **CRITICAL v4 신설 — 5가게 구조 정확 일관성** | 5가게 모두 carpenter 작업 (지붕/기둥/카운터/frame proportion) 정확 동일. 카테고리별로 다른 것은 (a) display goods (채소/meat/fish/곡식/sauce) + (b) signage icon + (c) signage text 3건만. 나머지 (지붕 곡률/와당 위치/기둥 폭/카운터 높이/signboard 위치) 모두 5가게 정확 동일. | 5장을 나란히 보았을 때 (a) 지붕 같은 곡률 + 같은 와당 패턴 / (b) 기둥/frame 같은 폭 + 같은 색 / (c) 카운터 같은 높이/형태 / (d) signboard 위치 같음. 카테고리 display goods + signage만 다름. | 5가게마다 지붕 곡률 다름 / 기둥 폭 다름 / 카운터 형태 다름 / signboard 위치 다름 / frame 색 다름 — v3 prompt-only batch의 generation noise 회귀 |
| 7 | **CRITICAL v4 신설 — frontal elevation view** | base image와 동일 frontal elevation view (정면). slight 7/8 perspective 0건. base image가 원래 frontal이었음. | image가 frontal elevation (정면에서 평면처럼 본 view). 깊이 perspective 0건 (storefront 평면이 화면에 평행). | slight 7/8 perspective / 깊은 isometric / 가게 측면 visible / 비스듬한 각도 — v3 폐기 사유 회귀 |
| 8 | **CRITICAL v4 신설 — v1.2 base 시각 시그니처 정확 유지** | image edit 후에도 base image v1.2의 frame/카운터/products/signage/bg가 ABSOLUTELY IDENTICAL. 지붕만 swap된 결과. | base v2 PNG와 v4 output을 side-by-side 비교 시 (지붕 영역 제외) 모든 요소가 정확히 동일 (color/position/proportion). | base의 frame 위치 변경 / products 배치 변경 / signboard 텍스트 변경 / 색 톤 손실 / image edit이 base image 전체를 다시 그려버림 (edit이 아닌 generation) |

#### G_env_v4 LOCK 조건 (v1.13)

> **LOCK = 5/5 anchors × 8 요소 = 40/40 PASS**. 1 anchor라도 1 요소 FAIL이면 환경 v4 sprint REROLL. **5장 동시 LOCK** 정책 유지 (5가게 cross-shop one-market identity + 구조 정확 일관성 critical).

#### 부분 통과 정책

| 상황 | 정책 |
|------|------|
| 5 anchors × 8 요소 = 40/40 PASS | 완전 통과, 즉시 환경 v4 LOCK → §0 anchor 표 BG-01~05 v4 status 갱신 + M1 ingredient/UI sprint 진입 |
| 4 anchors LOCK + 1 anchor 1-2 요소 FAIL | **CONDITIONAL** — FAIL anchor 단일 image edit reroll (`--only BG-XX`). prompt 일부 강화 또는 base image 다시 입력. |
| 3 anchors LOCK + 2 anchors 1-2 요소 FAIL | **CONDITIONAL** — 2 FAIL anchors에 reroll. |
| 2 anchors 이하 LOCK 또는 1 anchor 3+ 요소 FAIL | **FAIL** — pm 에스컬레이션 / image edit prompt 재설계 (지붕 영역 명세 강화) / 사용자 의도 재확인 |
| BG-01 (anchor seed) FAIL | **FAIL** — BG-01 재생성 우선. BG-01 v4 anchor가 5가게 cross-shop 일관성 시드. |
| 5가게 구조 일관성 (#6) 일부 FAIL | **CONDITIONAL** — base image 자체가 v1.2 base에서 일관됐는지 재확인. base가 일관됐는데 edit이 일관성을 깨뜨렸으면 image edit prompt에 "keep frame/counter/proportion ABSOLUTELY IDENTICAL" 강화. |

### 5.6.3 환경 v4 라운드 예산

- **R1 (v4 1차 시도, BG-01 test 권장)**: `py tools/edit_bg_anchors_v4.py --only BG-01`. 1장 × $0.042 ≈ $0.05, ~30초. 사용자 시각 확인 ~5분, art-director 평가 ~10분.
- **R1 (BG-01 PASS 후 5장 batch)**: `py tools/edit_bg_anchors_v4.py`. 5장 × $0.042 ≈ $0.21, ~2-3분.
- **R2 (follow-up reroll)**: FAIL anchor 집중, `--only BG-XX`. +5-10분.
- **R3 (재시도)**: R2 후에도 FAIL 2+ anchors이면 → pm 에스컬레이션 (image edit prompt 재설계 또는 base image 검토).

#### G_env_v3 (deprecated, v1.13 폐기) — 이하 §5.6.2 deprecated archive

> v1.12 §5.6.2 G_env_v3 5 요소 게이트 (검정 기와 지붕 단일 / v1.2 base 카테고리 시그니처 / icon+영어 minimal signage / Cool Sage bg + modern saturated / v2 한옥 풀세트 추가 요소 0건) = **deprecated**. 사용자가 v3 5장 결과 시각 확인 후 verbatim "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..." 명시 → v4 G_env_v4 8 요소 (v3 5 요소 + 5가게 구조 일관성 + frontal view + v1.2 base 정확 유지 3 신설)로 supersede. v3 G_env 기준은 git history (art-anchor-rubric v1.12 §5.6.2) 참조.

### 5.6.LEGACY G_env_v3 (deprecated, 이하 v1.12 본문 보존)

> 이하 §5.6.LEGACY 본문은 v1.12 G_env_v3 5 요소 게이트 본문. v1.13 v4에서 G_env_v4 8 요소로 supersede. 본 sprint 환경 v4 작업에는 사용하지 않음.

#### G_env_v3 5 요소 PASS 기준 (deprecated, v1.13 폐기 — 5/5 anchors 모두 충족 시 환경 v3 sprint LOCK 이었음)

| # | 요소 | 사용자 의도 시각 명세 | PASS 판정 기준 | FAIL 사례 (즉시 reroll) |
|---|------|------------------------------|----------------|----------------------|
| 1 | **검정 기와 곡선 지붕 단일 layer visible (천막 0건, CRITICAL)** | curved black ceramic tile roof (Korean hanok 기와 eave roof) — dark slate gray to black curved eave tile, 처마 곡선 corners gently upward, optional 와당 2-3개 accent. **SINGLE simple layer** sitting on top of shop front as topmost band. 천막 (striped awning) 자리에 기와 지붕 swap. | 검정 기와 곡선 지붕 단일 layer 명확 visible. dark slate/black curved eave tile + 처마 곡선 corners upward. roof는 storefront 위에 slim band (image 상단 ~20-25%). 천막 0건. | 천막 회귀 (red/green striped awning 재출현) / flat roof (곡선 없음) / 기와 X / Chinese pagoda multi-tier sharp upturned / Japanese irimoya hip-and-gable / 한옥 frame 풀세트 (vertical posts on both sides 추가) / 깊은 처마 overhang (heavy shadow band) |
| 2 | **v1.2 base 카테고리 시그니처 visible (BG별 1-2 icons + signature color)** | v1.2 base의 가게 카테고리 시그니처 그대로 유지: BG-01 채소 stack (cabbage hero + 배추 + apples + 오이 + 대파) on wooden crates + 좌측 옹기 2개 + 우측 onion hanging / BG-02 meat slab hanging 2-3개 + 도마 + butcher knife on counter / BG-03 fish hanging 2개 + 흰 ice block on counter / BG-04 곡식 자루 3종 (tan + warm brown + red bean) on counter/display box / BG-05 sauce 항아리 4개 row + 우측 dried red chili 고추 hanging | 5가게 카테고리 식별 가능 (외부인 0.5초 안에 가게 카테고리 답). 각 가게 v1.2 base 시그니처 그대로 (BG-01의 채소 stack + 좌측 옹기 2개 / BG-05의 sauce 4개 + 고추 등) | 카테고리 시그니처 누락 (기와 지붕만 있고 채소/meat/fish/곡식/sauce X) / v1.2 base 시그니처 변경 (BG-01의 좌측 옹기 2개 → 0개 / BG-05의 sauce 4개 → 2개) / 다른 가게로 추론 (정육점에 채소) |
| 3 | **icon+영어 minimal signage (한글 0건, CRITICAL)** | 작은 wooden signboard at top of shop front (below tile roof). icon-first (~60-70% area) + SHORT English minimal text label (~20-25%) below. 5가게 영어 v1.2 base 환원 = PRODUCE / BUTCHER / SEAFOOD / GRAIN / SAUCES. simple sans-serif, all-caps, legible. | wooden signboard visible + 카테고리 icon (~60-70%) + English minimal text below (legible, simple sans-serif). 한글/한자/카타카나 0건. v1.2 base 영어 v3 환원 (PRODUCE/BUTCHER/SEAFOOD/GRAIN/SAUCES). | 한글/한자/카타카나 누수 (1글자라도) / 영어 text 없이 icon만 / English text가 dominant (icon이 작음) / signboard 자체 누락 / sub-text 추가 (any non-English) / v2 영어 사용 (GREENGROCER/FISHMONGER/GRAIN SHOP/GENERAL GOODS) — v1.2 base 영어로 환원 필요 |
| 4 | **Cool Sage bg + modern saturated 톤 (베이지 0건, CRITICAL)** | Cool Sage #C8D5C0 solid background + 채도 80-90% + warm/cool 균형 + bold outline 2-3px + modern flat clean (vintage storybook 0) | bg = solid Cool Sage #C8D5C0 (cool tone). 채도 80-90%. slim outline 2-3px. modern flat clean tone. 베이지/cream/scrapbook/storybook 0건. | 베이지/cream/vintage paper bg / scrapbook/storybook tone / golden hour sunset / 채도 70% 이하 muted / 채도 100% neon / heavy outline 4px+ / multi-layer shading |
| 5 | **v2 한옥 풀세트 추가 요소 0건 (minimal LOCK, CRITICAL)** | 사용자 R2 verbatim "기존버젼에서 다른거는 다 그대로" 명시. v2의 추가 요소 (옹기 5가게 ground prominent / lantern 5가게 양쪽 / 목조 한옥 frame vertical posts on both sides / 깊은 처마 overhang) **모두 폐기**. v1.2 base 옹기는 BG-01 좌측 2개만 유지, 나머지 BG-02/03/04는 옹기 0건, BG-05는 sauce 항아리 4개 카운터 진열만 (ground prominent 옹기 추가 X). | 옹기: BG-01 좌측 2개만 (v1.2 base 그대로). 나머지 BG-02~05 옹기 0건 (BG-05 ground prominent 옹기 0건). lantern: 5가게 모두 0건. 목조 frame: 5가게 모두 vertical posts 0건. 깊은 처마 shadow band: 5가게 모두 0건. | 옹기 추가 누수 (BG-02/03/04에 옹기 추가 / BG-05 ground prominent 옹기 1+개) / lantern 1+개 누수 / 목조 한옥 frame vertical posts 누수 / 깊은 처마 overhang shadow band 누수 / 와당 풀세트 (3+개 풀 line) — 와당은 minimal 2-3개 accent OK |

#### G_env_v3 LOCK 조건 (v1.12)

> **LOCK = 5/5 anchors 모두 5 요소 ALL 충족 (즉 5 × 5 = 25 게이트 모두 PASS)**. 1 anchor라도 1 요소 FAIL이면 환경 v3 sprint REROLL. **5장 동시 LOCK** 정책 유지 (이유: 5가게 cross-shop one-market identity 일관성 critical).

#### 부분 통과 정책

| 상황 | 정책 |
|------|------|
| 5 anchors × 5 요소 = 25/25 PASS | 완전 통과, 즉시 환경 v3 LOCK → §0 anchor 표 BG-01~05 v3 status 갱신 + M1 ingredient/UI sprint 진입 |
| 4 anchors LOCK + 1 anchor 1-2 요소 FAIL | **CONDITIONAL** — FAIL anchor에 follow-up reroll 1 라운드 (§4 BG-XX reroll trigger 5종 사용) |
| 3 anchors LOCK + 2 anchors 1-2 요소 FAIL | **CONDITIONAL** — 2 FAIL anchors에 reroll 1 라운드 |
| 2 anchors 이하 LOCK 또는 1 anchor 3+ 요소 FAIL | **FAIL** — pm 에스컬레이션 / prompt 재설계 / 사용자 의도 재확인 |
| BG-01 (anchor seed) FAIL | **FAIL** — BG-01 재생성 우선, BG-02~05는 BG-01 reference upload 불가 시 일관성 무너짐 |

### 5.6.3 환경 v3 라운드 예산

- **R1 (v3 1차 시도)**: art-director가 `tools/gen_bg_anchors_m1.py --version v3 --model gpt-image-1 --quality medium` batch 실행 (5장 × $0.042 ≈ $0.21, ~2-3분). 사용자 시각 확인 ~10분, art-director 평가 0.5h.
- **R2 (follow-up reroll)**: FAIL anchor 집중, batch 또는 단일 (e.g., `--only BG-01 --version v3.1`). +10-15분.
- **R3 (재시도)**: R2 후에도 FAIL 2+ anchors이면 → pm 에스컬레이션.

### 5.6.4 G_env_v2 (deprecated, v1.12 폐기)

> v1.11 §5.6.2 G_env_v2 6 요소 (한옥 양식 visible / 카테고리 시그니처 / 옹기 visible / lantern visible / icon+영어 signage / Cool Sage + modern saturated) = **deprecated**. 사용자가 v1.11 v2 결과 "너무 많음" 진단 + verbatim "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고" 명시 → v1.12 v3 G_env_v3 5 요소로 supersede. v2 G_env 기준은 git history (art-anchor-rubric v1.11 §5.6.2) 참조.

---

## 6. Decisions Log

### 6.1 Week 1 (캐릭터 + 환경 10 anchor)

| 라운드 | 날짜 | LOCK 수 | CONDITIONAL | FAIL | subject anchor PASS | G_new PASS 수 | 종합 | art-director 메모 | pm 승인 |
|-------|------|--------|-------------|------|--------------------|---------------|------|------------------|--------|
| iter2 | 2026-05-27 | 0 | — | 10 (G5/G_new FAIL) | FAIL | 0/10 | **FAIL** | iter2 사용자 진단 "올드함" (베이지/절구/Cookie Run 2021) → v1.2 reset 트리거 | superseded |
| iter3 | TBD | pending | pending | pending | pending | pending | pending | v1.2 prompt 검증 | pending |

### 6.2 M1 음식 12 (F-01~F-12 plated dish hero shot, v1.3 신설)

| 라운드 | 날짜 | LOCK 수 (T1) | LOCK 수 (T2) | F-01 anchor PASS | risk top 5 LOCK 수 | G_food FAIL 음식 | 종합 | art-director 메모 | pm 승인 |
|-------|------|------------|-------------|------------------|--------------------|------------------|------|------------------|--------|
| M1 R1 | 2026-05-27 | **7/7** | **5/5** | **PASS** | **5/5** | **0** | **LOCK 12/12 (G_food)** | `tools/gen_food_anchors_m1.py` (gpt-image-1 medium 1024×1024) batch 결과. prompts-library v1.3 §5.2 F-01~F-12 prompt LOCK 12/12 (G_food cross-cultural 누수 측면). risk top 5 (Galbi-gui/Kimbap/Corn Dog/Japchae/Kimchi Jjigae) 모두 회피 — 특히 F-06 American corn dog 80% default 누수 회피 (모짜렐라 cheese stretch + panko crumb + ketchup/mustard zigzag 3박자 충족), F-12 Japanese yakiniku 60% default 누수 회피 (VISIBLE WHITE RIB BONE 강조 prompt 효과), F-11 Chinese lo mein 70% default 누수 회피 (translucent brown-amber dangmyeon shine). minor finding = bg 2종 mixed (cool sage 7장 + cream-white 5장) — STYLE_SUFFIX_FOOD "choose one consistently" 위반이나 cross-cultural 식별 영향 0, M1 후반 ingredient sprint 시 cool sage `#C8D5C0`로 통일 권고. F-01 Ramyeon = food anchor 시드 LOCK → §0 표 `FOOD_ANCHOR_FILE` = `C:\Projects\kfood-game\assets-raw\food_anchors_m1\F-01_ramyeon_v1.png` 기록 (M1 후반 ingredient/UI 자산 reference upload 시드). **이후 사용자 시각 디테일 게이트에서 10건 FAIL → R2 reroll 트리거 (§6.4 참조). G_food 측면 LOCK은 v1.5에서도 유효, F-04/F-09 2장만 R2에서도 LOCK 유지**. | pending pm |

### 6.4 M1 음식 12 R2 reroll trigger (v1.5 신설, 2026-05-27)

> 2026-05-27 사용자가 R1 v1 결과 12장 시각 확인 후 **구체적 시각 피드백 10건 raise**. F-04 떡볶이 / F-09 김치찌개 2장은 사용자 피드백 없음 → R1 LOCK 유지. G_user_visual_detail (§5.5.7) 신설 게이트.

| 라운드 | 날짜 | trigger 사유 | 영향 음식 | LOCK 유지 음식 | art-director 메모 | pm 승인 |
|-------|------|------------|----------|----------------|------------------|--------|
| M1 R2 trigger | 2026-05-27 | 사용자 시각 디테일 게이트 10건 FAIL (G_food cross-cultural은 모두 PASS 유지, 그러나 음식 디테일에서 어색 발견) | F-01/F-02/F-03/F-05/F-06/F-07/F-08/F-10/F-11/F-12 (10건) | **F-04 떡볶이 (t1_003) / F-09 김치찌개 (t2_009) 2장 R1 LOCK 유지** | prompts-library v1.4로 본문 패치 + `tools/gen_food_anchors_m1.py` FOODS sync 완료. R2 실행 명령: `py tools/gen_food_anchors_m1.py --only F-01,F-02,F-03,F-05,F-06,F-07,F-08,F-10,F-11,F-12 --version v2 --model gpt-image-1 --quality medium`. 예상 비용 ~$0.42 (10장 × $0.042). 예상 시간 ~3~5분. v2 출력 경로: `assets-raw/food_anchors_m1/F-XX_<name>_v2.png` (R1 v1과 공존). | pending |

#### R2 사용자 피드백 (verbatim, 2026-05-27)

1. **F-01 라면**: 면발이 너무 두꺼움 → 좀더 얇게
2. **F-02 호떡**: 가운데 sweet 한 액체 부분은 실제로 저렇게 밖으로 많이 나오지 않음 → 흘러나오는 양 대폭 줄이기
3. **F-03 김밥**: 밥알이 너무 큼
4. **F-05 김치볶음밥**: 밥알이 너무 큼
5. **F-06 핫도그**: 밑의 무슨 종이 받침이 있는데 이상함 → 종이 받침 제거 또는 자연스럽게
6. **F-07 해물파전**: 파와 새우가 튀김반죽 위에 있음 → 반죽에 섞여야 함 (embedded WITHIN batter)
7. **F-08 비빔밥**: 밥알이 너무 큼
8. **F-10 순두부찌개**: 순두부가 좀 이상함 → fluffy cloud-like broken curds 강조 재정의
9. **F-11 잡채**: 당면이 너무 두꺼움 → 좀더 얇게
10. **F-12 갈비구이**: 엉터리 — 뼈가 이상하게 보이고 어색함 → 전면 재작성. 한식 갈비 정확 묘사 (LA cross-cut strip + 2-3 small round white bone cross-sections along length)

#### 패치된 본문 fix 핵심

| 음식 | 본문 fix 핵심 |
|------|--------------|
| F-01 | "Yellow wavy curly egg noodles" → "**THIN delicate** yellow wavy curly egg noodles" + negative "NOT thick chunky udon-style strands" |
| F-02 | "filling oozes out, creating a single small swirl" → "**a tiny hint barely peeks through a small slit**, mostly contained inside the disc" + negative "NO excessive syrup overflow, NO molten lava-like outpour" |
| F-03 | rice "**FINE small rice grains** (Korean short-grain, barely visible)" + negative "NOT chunky oversized rice grains" |
| F-05 | F-03와 동일 fix (rice grain) |
| F-06 | "Wrapped at the bottom in a paper cup" 제거 → "**held cleanly by the stick with no paper wrapper, clean composition**" + negative "NO awkward paper plate" |
| F-07 | "scallions ... clearly visible across" → "scallions and shrimp **mixed into and partially submerged within the golden batter** (BAKED INTO the pancake, partially visible above the surface but mostly embedded)" |
| F-08 | F-03와 동일 fix (rice grain) |
| F-10 | "fluffy white soft tofu mound (broken into cloud-like curds)" → "**mound of soft tofu broken into irregular cloud-like fluffy white curds (like soft cottage cheese clumps or torn fluffy clouds, organic uneven shapes), NOT smooth puree, NOT firm cubes, NOT mashed paste, NOT a single solid white block**" + reroll trigger "두부 모양 어색" 신설 |
| F-11 | "thick and shiny translucent strands" → "**THIN delicate translucent** strands" + negative "NOT thick chunky strands" |
| F-12 | **전면 재작성** — LA-style cross-cut strip (3-4cm × 8-10cm) + **2-3 small round white bone cross-sections along its length (iconic LA Galbi cut signature)** + natural overlapping plating + negative "NOT a single thick rib slab, NOT one giant bone, NOT bone-on-side American-style ribs" + reroll trigger "갈비뼈 모양 어색" 신설 |

### 6.5 M1 음식 12 R3 reroll trigger (v1.6 신설, 2026-05-27)

> 2026-05-27 R2 v2 결과 사용자 시각 확인 후 **selective 시각 피드백 6건 raise**. F-07/F-08/F-10/F-11 4장은 silent ACK → R2 LOCK candidate. F-04/F-09 2장은 R1 LOCK 유지. R2 patch가 일부 음식에서는 "보수적 축소"가 되어 식욕 자극 ↓했고 (F-01/F-03/F-05 → v1 base 회복), F-12는 LA cross-cut 묘사 자체가 정통 한식과 다른 ChatGPT 추론을 유도해 전면 재작성 필요.

| 라운드 | 날짜 | trigger 사유 | 영향 음식 | LOCK candidate / 유지 음식 | art-director 메모 | pm 승인 |
|-------|------|------------|----------|--------------------------|------------------|--------|
| M1 R3 trigger | 2026-05-27 | R2 v2 보수적 축소 + LA-cut 추론 어색 (G_user_visual_detail 6건 추가 FAIL) | F-01/F-02/F-03/F-05/F-06/F-12 (6건) | **R2 LOCK candidate**: F-07/F-08/F-10/F-11 (4건, 사용자 silent ACK) / **R1 LOCK 유지**: F-04 떡볶이 (t1_003) / F-09 김치찌개 (t2_009) | prompts-library v1.5로 본문 패치 + `tools/gen_food_anchors_m1.py` FOODS sync 완료. R3 실행 명령: `py tools/gen_food_anchors_m1.py --only F-01,F-02,F-03,F-05,F-06,F-12 --version v3 --model gpt-image-1 --quality medium`. 예상 비용 ~$0.25 (6장 × $0.042). 예상 시간 ~2분. v3 출력 경로: `assets-raw/food_anchors_m1/F-XX_<name>_v3.png` (v1/v2와 공존). | pending |

#### R3 사용자 피드백 (verbatim, 2026-05-27)

1. **F-01 라면**: 원래 버젼(v1)이 더 먹음직스러움. 똑같이 하되 면발만 얇게
2. **F-02 호떡**: 위에 시럽을 좀 뿌려주는걸로 (filling 안에 contained 유지 + 표면에 brown sugar syrup drizzle 추가)
3. **F-03 김밥**: 원래 버젼(v1)이 더 나음. 단, 밥알만 더 작게
4. **F-05 김치볶음밥**: 원래 버젼(v1)에서 밥알만 더 작게
5. **F-06 콘도그**: 원래 소세지가 안에 있는데, v2는 cheese인지 뭔지 모르겠음. 베어 문 단면에서 sausage 본체가 명확히 보이고 + cheese stretch + ketchup/mustard zigzag 셋 다 표현
6. **F-12 갈비구이**: v2는 그냥 stake 같음. 갈비구이는 끝에 뼈가 좀 있어야 됨 + 고기가 좀 얇았으면 좋겠음 → 정통 한식 갈비구이 (LA-cut 폐기) — thin meat strip with bone exposed at one end of each piece

#### R3 패치된 본문 fix 핵심 (v1.5)

| 음식 | R2 v2 → R3 v3 본문 fix 핵심 |
|------|----------------------------|
| F-01 | v1 base 회복 — v2 "Korean instant ramyeon noodle thickness, slim individual strands" 보수적 수식 제거, 단순 "THIN delicate yellow wavy curly egg noodles" 통일. v2의 NOT thick chunky udon negative 한 줄만 보존. broth/egg/garnish 본문은 v1 톤으로 회복 (식욕 자극 ↑) |
| F-02 | v2 contained filling 유지 (안에서 안 흐름) + 신규 라인 추가: "**On the golden-brown surface of the disc, a small drizzle of glossy dark brown sugar syrup is gently swirled on top as a finishing touch** (light decorative drizzle, like syrup on a pancake, thin glossy ribbon resting on the surface, NOT a flood, NOT pouring from inside, NOT a large pool, just a delicate topping accent)" + negative 명시 "the small syrup drizzle on top is okay as a separate topping accent (visually distinct from the contained filling)" |
| F-03 | v1 base 회복 — v2의 다른 변경 제거. rice 묘사만 "white rice with **FINE small grains** (Korean short-grain, tight uniform field)" + negative "NOT chunky oversized beads" |
| F-05 | F-03와 동일 패턴 (v1 base 회복 + rice FINE small fix) |
| F-06 | v2 base + 단면 cross-section **4요소 명확 visible** 강화 — (1) brown cooked sausage at core/center cylindrical visible / (2) bright yellow mozzarella cheese filling SURROUNDING the sausage with 2-3 stretchy strands / (3) golden-brown crispy panko crumb coating WRAPPING the outside (slightly bumpy, distinct from cheese layer) / (4) red ketchup + yellow mustard zigzag drizzle on top crispy surface. negative 추가 "**NO missing sausage core, NO cheese-only filling without sausage, NO ambiguous interior where layers blend together** — the cross-section MUST show distinct sausage + cheese + panko coating layers" |
| F-12 | **전면 재작성** — v1.4 LA-style cross-cut + 2-3 bone discs along length 묘사 폐기. v1.5 정통 한식 재정의 = 3-4 thin elongated meat strips (각 **5-7cm long, 1-1.5cm thick, slightly tapered at one end**) + **at ONE END of each meat strip, a SHORT WHITE RIB BONE protrudes about 1-2cm** (traditional Korean galbi cut, bone-in at one end only, NOT cross-cut with multiple bone discs, NOT massive bone, NOT bone-less yakiniku slice, NOT American slab) + natural overlapping plating with bones pointing in slightly different directions + soy-pear-garlic glaze + grill marks + sesame + 마늘 slice + 상추/깻잎 ssam side. negative 강화 "NOT LA-style cross-cut with multiple small round bone discs along the strip length", "NOT thick boneless steak", "NOT a rack of ribs with one huge bone". reroll trigger "steak처럼 보임 / LA cross-cut 누수" 2건 신설. **(v1.7 deprecated — R3 v3 결과 사용자 reference image와 어긋남, §6.6 R4 trigger로 supersede)** |

### 6.6 M1 음식 F-12 R4 reroll trigger (v1.7 신설, 2026-05-28)

> 2026-05-28 R3 v3 결과 시각 확인 후 사용자가 정통 한식 갈비구이 reference image를 직접 보여주며 시각 의도 명확화 → R3 "끝에 single bone protrudes" 묘사가 reference와 어긋남 발견. R3 v3 = **deprecated**. F-12 단독 R4 reroll. 다른 11장 (F-01~F-11) status 무변경.

| 라운드 | 날짜 | trigger 사유 | 영향 음식 | LOCK candidate / 유지 음식 | art-director 메모 | pm 승인 |
|-------|------|------------|----------|--------------------------|------------------|--------|
| M1 R4 trigger (F-12 only) | 2026-05-28 | R3 v3 사용자 reference image 시각 분석 → 6 요소 어긋남 (G_user_visual_detail F-12 추가 FAIL) | F-12 (1건 only) | **R3 LOCK candidate**: F-01/F-02/F-03/F-05/F-06 (5건) / **R2 LOCK candidate**: F-07/F-08/F-10/F-11 (4건) / **R1 LOCK 유지**: F-04 떡볶이 (t1_003) / F-09 김치찌개 (t2_009) | prompts-library v1.6로 F-12 §5.2 본문 전면 교체 + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. R4 실행 명령: `py tools/gen_food_anchors_m1.py --only F-12 --version v4 --model gpt-image-1 --quality medium`. 예상 비용 ~$0.04 (1장 × $0.042). 예상 시간 ~30초. v4 출력 경로: `assets-raw/food_anchors_m1/F-12_galbi_gui_v4.png` (v1/v2/v3과 공존). | pending |

#### R4 사용자 reference image 시각 분석 (verbatim, 2026-05-28)

> 사용자가 인터넷에서 직접 가져온 정통 한식 갈비구이 reference image (둥근 grill grate 위 굽는 장면). main thread 직접 시각 확인 결과 6 시각 요소 추출:

1. **칼집 (cross-cut knife score marks across the meat surface)** — **가장 중요한 시그니처**. 각 strip 표면 가로방향으로 여러 깊은 칼자국 (3~6 cuts per strip). 한국 갈비구이의 정통 손질 기법 (균일한 구이 + 양념 흡수 + 식감). R3 v3에는 이 디테일 0건.
2. **thin elongated parallel meat strips** — 4 strips, 각 strip ~12~15cm long × ~3cm wide × ~1~1.5cm thick. 정확히 평행 배열. R3 v3의 1-1.5cm thick은 OK이나 strip 모양/배열이 다름.
3. **작은 흰 bone cross-section discs** — strip 사이 edge에 small round white bone discs 보임. **R3 v3의 single bone at one end 패턴과 완전히 다름** — reference는 LA갈비 cross-cut에 가까우나 칼집과 결합된 형식. **R3 single-bone-at-end 묘사 폐기**.
4. **색깔**: 사용자 명시 **"색깔은 좀 구웠을때의 색으로 바꿔야 하고"** — reference는 raw red-pink이지만 결과물은 **well-grilled brown char + caramelized soy-pear-garlic marinade glaze sheen** 명시.
5. **grill marks**: 표면에 dark char lines (cooked from grill grate).
6. **plating context**: 음식 카드는 plated hero shot이라 grill grate 자체는 표현 안 하고 **plate context** (검정 cast iron 그릴 plate 또는 clean white plate).

#### R3 v3 vs R4 v4 핵심 diff 표 (6 요소 × before/after)

| 요소 | R3 v3 (deprecated) | R4 v4 (사용자 reference 기준) | fix 방향 |
|------|-------------------|---------------------------|---------|
| 1. 칼집 (knife score marks) | **묘사 0건** (R3에 없음) | 각 strip 3-5 deep horizontal knife cuts, perpendicular to strip length, dark recessed grooves, "without these score marks, it is NOT Korean Galbi" CRITICAL 강조 | **칼집 신설** — 가장 중요한 시그니처 prompt에 명시 |
| 2. strip 배열 | "natural overlapping at relaxed angles" | **strictly parallel row** (side by side, NOT overlapping, NOT angled — each strip oriented in the same direction) | overlapping → strictly parallel |
| 3. bone 위치 | "SHORT WHITE RIB BONE protrudes 1-2cm at ONE END of each meat strip" | **small white round bone cross-section discs (1-2 small bones, ~1-1.5cm diameter) visible nestled between the strips at the plate edges** | single bone at end → small bone discs at edges (LA cross-cut + 칼집 결합 형식) |
| 4. 색깔 | "shiny dark brown sweet-savory Korean soy-pear-garlic marinade" (generic) | **rich caramelized dark brown + glossy glaze sheen + well-cooked + NOT raw red-pink, NOT pale uncooked** 명시 강조 | generic → well-grilled caramelized brown 강조 |
| 5. strip 길이 | "5-7cm long" | **12-15cm long** elongated rectangular shape | 5-7cm → 12-15cm (사용자 reference는 더 길고 elongated) |
| 6. strip 두께 | "1-1.5cm thick" | **1-1.5cm thick** (동일 유지) | 무변경 (R3 OK) |

#### R3 v3 single-bone-at-end 폐기 사유 (verbatim)

R3 v3 prompt 라인 "SHORT WHITE RIB BONE protrudes about 1-2cm at ONE END of each meat strip" → 사용자 reference image에서 bone은 strip 끝에서 노출되는 게 아니라 **여러 작은 round bone discs가 strip edge 사이에 visible** 형태. R3 v3 묘사는 ChatGPT가 "Korean galbi bone-in" 키워드로 추론한 잘못된 패턴이며, 사용자 reference (LA갈비 cross-cut + 칼집 결합)과 어긋남. R4에서 "single bone protrude at one end" 묘사 완전 폐기 + "small bone discs at plate edges between strips" 명확화 + "NOT one giant single bone protruding from the end of a single piece (the previous R3 v3 interpretation was wrong)" explicit negative 명시.

### 6.7 M1 음식 F-12 R5 reroll trigger (v1.8 신설, 2026-05-28)

> 2026-05-28 R4 v4 결과 시각 확인 후 사용자 2건 추가 fix 요청 — (1) thickness 더 얇게 / (2) bone 위치 = 윗부분 사이드. v4의 다른 LOCK 6 요소 무변경. F-12 단독 R5 reroll. 다른 11장 (F-01~F-11) status 무변경.

| 라운드 | 날짜 | trigger 사유 | 영향 음식 | LOCK candidate / 유지 음식 | art-director 메모 | pm 승인 |
|-------|------|------------|----------|--------------------------|------------------|--------|
| M1 R5 trigger (F-12 only) | 2026-05-28 | R4 v4 사용자 추가 fix 2건 (G_user_visual_detail F-12 행 4번 bone 위치 + 행 6번 thickness FAIL) | F-12 (1건 only) | **R4 LOCK candidate가 v5 fix 후 LOCK 예정**: F-12 v5 / **R3 LOCK candidate**: F-01/F-02/F-03/F-05/F-06 (5건) / **R2 LOCK candidate**: F-07/F-08/F-10/F-11 (4건) / **R1 LOCK 유지**: F-04 떡볶이 (t1_003) / F-09 김치찌개 (t2_009) | prompts-library v1.7로 F-12 §5.2 본문 v5 패치 (2 line fix + ESSENTIAL features 문장 + Bone position is CRITICAL 절 신설) + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. R5 실행 명령: `py tools/gen_food_anchors_m1.py --only F-12 --version v5 --model gpt-image-1 --quality medium`. 예상 비용 ~$0.04 (1장 × $0.042). 예상 시간 ~30초. v5 출력 경로: `assets-raw/food_anchors_m1/F-12_galbi_gui_v5.png` (v1/v2/v3/v4와 공존). | pending |

#### R5 사용자 R4 v4 피드백 (verbatim, 2026-05-28)

1. **고기가 일단 더 얇아야 함** — v4 1-1.5cm thick → 더 얇게
2. **뼈 위치 재정의**: "긴쪽의 밑쪽이 아니라 윗부분의 사이드로 보여야함"

#### R5 사용자 의도 해석 (main thread 분석 verbatim, 2026-05-28)

> reference image (사용자가 R4 전에 보여준 정통 갈비구이 굽는 사진) 재해석:
> - 각 strip이 가로로 누워있을 때 (long axis 가로)
> - **"긴쪽의 밑쪽"** = strip의 long axis 기준 아래쪽 edge / 또는 strip 양 끝 (short end) — v4가 어긋난 위치
> - **"윗부분의 사이드"** = strip의 long axis 기준 **윗쪽 long edge** — bone discs가 여기 visible해야 함
>
> 즉 reference에서 bone discs는 strip의 **위쪽 길이 방향 가장자리에 부분적으로 끼어있는 형태** (partially embedded into the upper long edge of each strip). v4는 bone을 strip의 short end (양 끝)에 둠 → 사용자 의도와 어긋남.
>
> reference 시각 패턴: strip이 long axis 따라 누워있고, 그 strip의 **윗쪽 long edge를 따라** 1-2개의 small round white bone discs가 partially 노출. 마치 bone에 붙어 있는 고기가 bone에서 살짝 떨어진 채 grill에 누워있는 형태 — 정통 한식 갈비 손질에서 bone이 strip의 한 long side에 attached 형태.

#### R4 v4 vs R5 v5 핵심 diff 표 (2 요소 × before/after)

| 요소 | R4 v4 (deprecated) | R5 v5 (사용자 R4 추가 fix 반영) | fix 방향 |
|------|-------------------|---------------------------|---------|
| Fix 1: strip 두께 | "approximately 12-15cm long × 3cm wide × **1-1.5cm thick** (long thin rectangular shape, the traditional Korean galbi cut after preparation)" | "approximately 12-15cm long × 3cm wide × **0.7-1cm thick** (very thin slice, like **6-8mm** thickness — significantly thinner than a steak, the traditional Korean galbi-gui properly butchered cut, **THIN slice appearance NOT a thick steak slab**)" + negative `NOT a thick 1.5cm+ slab, NOT steak thickness — the strips are visibly THIN slices (0.7-1cm, about 6-8mm thick), significantly thinner than a steak` | 1-1.5cm → 0.7-1cm (very thin slice 6-8mm). v4가 thick steak 누수했던 사용자 reject 사유 1:1 fix |
| Fix 2: bone 위치 | "Small white round rib bone cross-section discs (1-2 small bones, approximately 1-1.5cm diameter) are visible **nestled between the strips at the plate edges** (the bones are the small round white circles peeking out where the meat strips meet the plate surface — this is the traditional Korean galbi bone-in cut pattern)" | "Small round white rib bone cross-section discs (1-2 small bones per strip, approximately 1-1.5cm diameter, white-cream color) are visible **along the TOP LONG EDGE of each meat strip** — the small round white bone discs peek out from the upper side of the strip, **partially embedded into the upper long edge of the meat** (the bone is naturally attached to one long side of the meat strip, this is the traditional Korean galbi bone-in cut where each meat strip is sliced with the bone remaining attached at one long edge). The bones are visibly on the upper long side of each strip, NOT at the short ends (NOT at the tips of the strips), NOT at the bottom long edge (NOT below the strips), NOT in the gaps between strips on the plate." + **"Bone position is CRITICAL"** 절 신설 (negative `NOT bones at the short ends of strips, NOT bones at the bottom long edge, NOT bones between strips at the plate gaps — the bones MUST be on the upper long edge of each meat strip`) | strip 끝/plate edge gaps → strip의 TOP LONG EDGE (윗쪽 long edge) partially embedded. 사용자 "긴쪽의 밑쪽이 아니라 윗부분의 사이드" 명시 1:1 fix |

#### v4 vs v5 LOCK 유지 요소 6건 (변경 금지)

| # | LOCK 요소 | v4 = v5 본문 (무변경 확인) |
|---|----------|--------------------------|
| 1 | 칼집 | "Each meat strip has 3-5 deep horizontal knife cuts/incisions across its top surface, perpendicular to the length of the strip ... without these score marks, it is NOT Korean Galbi" |
| 2 | strictly parallel arrangement | "4 thin elongated rectangular meat strips are arranged in a strictly parallel row (side by side, NOT overlapping, NOT angled — each strip oriented in the same direction)" |
| 3 | well-grilled caramelized brown + glaze sheen, NOT raw | "The meat surface is a rich caramelized dark brown with a glossy soy-pear-garlic marinade glaze ... well-cooked and glazed, NOT raw red-pink, NOT pale uncooked" |
| 4 | strip 길이 12-15cm | "approximately 12-15cm long × 3cm wide" |
| 5 | garnish (깨 + 마늘 + 상추 ssam) | "Generous sprinkle of white sesame seeds across the strips. 1-2 thin garlic slices placed on top or beside the meat as accent. Optional: a small bunch of fresh green lettuce or perilla (kkaennip) leaves on the side of the plate (Korean ssam wrapping style)" |
| 6 | plate context (black cast iron grill plate or white plate) | "On a clean black cast iron grill plate (or alternatively a clean white plate with dark grill texture)" |

#### v4 본문 deprecated 사유 (verbatim, 2026-05-28)

R4 v4 prompt 라인 "× 1-1.5cm thick" + "nestled between the strips at the plate edges" → 사용자 v4 시각 확인 후 2건 reject: (1) thickness 1-1.5cm은 ChatGPT가 thick steak slab 추론을 유도해 사용자 "고기가 일단 더 얇아야 함" 명시 / (2) "between strips at plate edges" 묘사는 strip 양 끝/short end로 추론되어 사용자 "긴쪽의 밑쪽이 아니라 윗부분의 사이드로 보여야함" reject. v5에서 두께 0.7-1cm 6-8mm thin + bone 위치 = strip의 TOP LONG EDGE partially embedded 명확화. 다른 LOCK 6 요소는 무변경 유지.

### 6.8 M1 음식 F-12 R6 reroll trigger (v1.9 신설, 2026-05-28)

> 2026-05-28 R5 v5 결과 시각 확인 후 사용자가 **새 reference image** (정통 한식 갈비구이 — 가위로 자른 후의 eating-style state)를 제시하며 4건 추가 fix 요청. R5 v5의 long elongated strips + bone TOP LONG EDGE 패턴이 새 reference와 어긋남 진단 → R5 v5 = **deprecated**. F-12 단독 R6 reroll. 다른 11장 (F-01~F-11) status 무변경.

| 라운드 | 날짜 | trigger 사유 | 영향 음식 | LOCK candidate / 유지 음식 | art-director 메모 | pm 승인 |
|-------|------|------------|----------|--------------------------|------------------|--------|
| M1 R6 trigger (F-12 only) | 2026-05-28 | R5 v5 사용자 새 reference image 제시 + 4건 추가 fix (G_user_visual_detail F-12 행 1 form / 행 2 grid / 행 3 thickness / 행 4 bone 위치 / 행 7 garnish 5건 FAIL) | F-12 (1건 only) | **R6 LOCK candidate가 v6 fix 후 LOCK 예정**: F-12 v6 / **R3 LOCK candidate**: F-01/F-02/F-03/F-05/F-06 (5건) / **R2 LOCK candidate**: F-07/F-08/F-10/F-11 (4건) / **R1 LOCK 유지**: F-04 떡볶이 (t1_003) / F-09 김치찌개 (t2_009) | prompts-library v1.8로 F-12 §5.2 본문 v6 전면 교체 (form + thickness + bone 위치 + garnish 4건 fix + 식별 핵심 시각 요소 7개 갱신 + reroll trigger 7종 신설 + R5 v5 archive 절 보존) + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. R6 실행 명령: `py tools/gen_food_anchors_m1.py --only F-12 --version v6 --model gpt-image-1 --quality medium`. 예상 비용 ~$0.04 (1장 × $0.042). 예상 시간 ~30초. v6 출력 경로: `assets-raw/food_anchors_m1/F-12_galbi_gui_v6.png` (v1/v2/v3/v4/v5와 공존). | pending |

#### R6 사용자 R5 v5 피드백 (verbatim, 2026-05-28)

> 사용자가 R5 v5 결과 시각 확인 후 새 reference image (정통 한식 갈비구이 — 가위로 자른 후의 eating-style state)를 제시하며 명시:
>
> "가위로 자르고 난후의 갈비구이....Short Edge쪽에 뼈가 길게 있잖어....그리고 고기 자체도 훨씬 얇게 되어 있고...."

#### R6 main thread 새 reference image 시각 분석 (verbatim, 2026-05-28)

> 사용자가 R6 trigger와 함께 제시한 새 reference image (정통 한식 갈비구이 eating-style state — 가위로 자른 후) main thread 직접 시각 분석. 7 핵심 시각 요소 추출:

1. **square/rectangular meat pieces (가위로 자른 후)** — 각 piece approximately 3-4cm × 3-4cm, 거의 정사각형. R5의 long elongated strips와 완전히 다른 form. 한식 갈비구이의 eating-style state = 가위로 자른 후의 모양.
2. **매우 얇은 두께 (사용자 명시 강조)** — approximately 0.5-0.8cm thick (5-8mm), R5의 0.7-1cm보다 더 얇게. paper-thin은 아니지만 매우 thin slice.
3. **grid pattern arrangement** — multiple pieces (보통 16~20개) arranged in rows × columns (3~4 rows × 4~5 columns), strictly parallel/aligned, sitting flat on the grill or plate.
4. **bone at SHORT EDGE (CRITICAL signature)** — reference의 한 row 옆 (short edge side)에 **하나의 길고 흰 뼈** (approximately 12-15cm long × 1-1.5cm wide)가 가로로 누워 있음. 이건 원래 strip이 가위로 잘리기 전 strip 끝에 attached됐던 bone이 절단 후에도 short edge에 남아 있는 형태. R5 v5의 "bone partially embedded along top long edge" 패턴은 완전히 폐기.
5. **표면 칼집 (knife score marks)** — 각 small piece에도 여전히 horizontal score marks visible (원래 strip 형태일 때 칼집이 들어갔으므로). LOCK 유지 요소.
6. **dark brown well-grilled caramelized color + glaze sheen** — R4/R5 LOCK 유지.
7. **garnish — 잘게 다진 마늘 sprinkle** — chopped minced garlic bits scattered on the meat surface (small yellowish-white dots throughout). 깨 sprinkle는 optional.

#### R5 v5 vs R6 v6 핵심 diff 표 (4 fix × before/after)

| 요소 | R5 v5 (deprecated) | R6 v6 (사용자 새 reference 기준) | fix 방향 |
|------|-------------------|---------------------------|---------|
| Fix 1: meat form (form 전면 교체) | "4 thin elongated rectangular meat strips are arranged in a strictly parallel row (side by side, NOT overlapping). Each strip dimensions: approximately 12-15cm long × 3cm wide × 0.7-1cm thick" | "multiple small square-shaped grilled meat pieces (12~16 pieces total, each approximately 3-4cm × 3-4cm square, very thin 0.5-0.8cm thick) are arranged in a grid pattern (3-4 rows × 4 columns) on the plate. This is the Korean galbi-gui EATING STYLE state — the original long meat strip with bone has been CUT WITH KITCHEN SCISSORS at the table into smaller square pieces for eating" + negative `NOT uncut long strips (v3/v5 form obsolete)` | 4 long elongated strips → 12-16 small square pieces in grid pattern (eating-style state 명확화) |
| Fix 2: thickness 더 얇게 | "0.7-1cm thick (very thin slice, like 6-8mm thickness — significantly thinner than a steak)" | "0.5-0.8cm thick (5-8mm, very thin slice — significantly thinner than v5, paper-thin appearance but still substantial enough to recognize as meat — much thinner than a typical steak cut, almost paper-thin)" | 0.7-1cm → 0.5-0.8cm (5-8mm). 사용자 "고기 자체도 훨씬 얇게" 명시 1:1 fix |
| Fix 3: bone 위치 완전 재정의 (TOP LONG EDGE → SHORT EDGE long bone) | "Small round white rib bone cross-section discs (1-2 small bones per strip, approximately 1-1.5cm diameter, white-cream color) are visible along the TOP LONG EDGE of each meat strip — partially embedded into the upper long edge of the meat" | "On ONE SHORT EDGE SIDE of the meat grid (the side edge of the plate, perpendicular to the rows of meat pieces), a single LONG WHITE RIB BONE is laid horizontally (approximately 12-15cm long × 1-1.5cm wide × 1-1.5cm tall, cream-white color). This bone was originally attached to the meat strip BEFORE it was cut with scissors — after cutting the strip into smaller square pieces, the bone remains laying alongside the grid of meat pieces on the short edge side. The bone is a SINGLE LONG PIECE laying flat alongside the grid (perpendicular to the rows of meat pieces), NOT multiple small discs scattered, NOT embedded into any individual meat piece's edge" + negative `NOT bone discs along the top edge of each piece (v5 deprecated), NOT bone at the end of strips (v3 deprecated), NOT bones between pieces` | bone discs per strip → SINGLE LONG BONE alongside grid on SHORT EDGE. 사용자 "Short Edge쪽에 뼈가 길게 있잖어" 명시 1:1 fix |
| Fix 4: garnish 잘게 다진 마늘 dots (slice → minced) | "Generous sprinkle of white sesame seeds across the strips. 1-2 thin garlic slices placed on top or beside the meat as accent. Optional: a small bunch of fresh green lettuce or perilla (kkaennip) leaves on the side of the plate" | "Generous sprinkle of finely CHOPPED MINCED GARLIC bits scattered all over the meat pieces (small yellowish-white garlic granules visible on top of each meat piece, a signature Korean galbi-gui garnish after grilling — the chopped garlic dots are the hero garnish, scattered as small yellowish-white granules throughout the grid of pieces). Optional: a light sprinkle of white sesame seeds as additional accent" + negative `NOT thin garlic slices on top, NOT whole garlic cloves` | 깨 + 1-2 garlic slices → 잘게 다진 마늘 granules scattered all over (hero garnish). 깨는 optional |

#### v5 vs v6 LOCK 유지 요소 5건 (변경 금지)

| # | LOCK 요소 | v5 = v6 본문 (무변경 확인) |
|---|----------|--------------------------|
| 1 | 칼집 (knife score marks maintained on each cut piece) | "Each small square meat piece has horizontal score marks visible on its top surface (the original strip's knife cuts/incisions remain visible on each cut piece after scissor-cutting) ... without these score marks visible on each piece, it is NOT Korean Galbi" — v5 strip 단위 칼집 → v6 piece 단위 maintained, 원칙은 동일 |
| 2 | strictly parallel/aligned arrangement (grid pattern) | "arranged in a strictly parallel/aligned grid pattern (same direction oriented, rows × columns, NOT overlapping, NOT angled — pieces sitting flat on the grill or plate in a neat grid)" — v5 strips strictly parallel → v6 pieces grid pattern strictly parallel, 원칙 LOCK 유지 |
| 3 | well-grilled caramelized brown + glaze sheen, NOT raw | "rich caramelized dark brown with a glossy soy-pear-garlic marinade glaze ... well-cooked and glazed, NOT raw red-pink, NOT pale uncooked" — v4/v5 동일 |
| 4 | plate context (black cast iron grill plate or white plate) | "On a clean black cast iron grill plate (or alternatively a copper grill grate or a clean white plate with dark grill texture)" — v5에 copper grill grate 옵션 추가 |
| 5 | cross-cultural negative (yakiniku/American BBQ/char siu/steak/raw/LA-cut) | "NOT Japanese yakiniku ... NOT American BBQ ribs ... NOT Chinese char siu ... NOT a steak ... NOT LA-style cross-cut" — v4/v5 동일 + 추가 `NOT uncut long strips (v3/v5 form obsolete)` |

#### v5 본문 deprecated 사유 (verbatim, 2026-05-28)

R5 v5 prompt 라인 "4 thin elongated rectangular meat strips arranged in a strictly parallel row, each strip 12-15cm long × 3cm wide × 0.7-1cm thick" + "bone discs visible along the TOP LONG EDGE of each meat strip" + "1-2 thin garlic slices placed on top or beside the meat as accent" → 사용자 v5 시각 확인 후 새 reference image (정통 한식 갈비구이 — 가위로 자른 후의 eating-style state) 제시 + 4건 reject: (1) long elongated strips form은 가위로 자르기 전의 raw/marinated state이며 사용자 의도는 **eating-style state** (가위로 cut 후 small square pieces in grid pattern) → form 전면 교체 / (2) thickness 0.7-1cm은 여전히 두꺼움, 사용자 "고기 자체도 훨씬 얇게" → 0.5-0.8cm (5-8mm) / (3) bone 위치 = strip의 TOP LONG EDGE bone discs는 reference에 없는 패턴, reference는 **short edge side에 single long bone** 가로로 누워있는 형태, 사용자 "Short Edge쪽에 뼈가 길게 있잖어" → bone 위치 완전 재정의 (TOP LONG EDGE bone discs per strip → SHORT EDGE single long bone alongside grid) / (4) 1-2 thin garlic slices는 reference에 없음, reference는 **잘게 다진 마늘 dots** scattered all over → garnish 재정의 (slice → minced). v5의 다른 LOCK 5 요소 (칼집 maintained / strictly parallel-aligned arrangement / well-grilled brown + glaze / plate context / cross-cultural negative) 무변경 유지.

### 6.9 M1 음식 F-12 R7 reroll trigger (v1.10 신설, 2026-05-28)

> 2026-05-28 R6 v6 결과 시각 확인 후 사용자가 **또 다른 reference image** (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length)를 제시하며 verbatim "이걸로 해줘" 명시 + 5건 추가 fix 요청. R6 v6의 small square pieces grid form + SHORT EDGE long single bone + chopped minced garlic dots + black cast iron plate + top-down view 패턴이 새 reference와 어긋남 진단 → R6 v6 = **deprecated**. F-12 단독 R7 reroll. 다른 11장 (F-01~F-11) status 무변경.

| 라운드 | 날짜 | trigger 사유 | 영향 음식 | LOCK candidate / 유지 음식 | art-director 메모 | pm 승인 |
|-------|------|------------|----------|--------------------------|------------------|--------|
| M1 R7 trigger (F-12 only) | 2026-05-28 | R6 v6 사용자 또 다른 reference image 제시 + verbatim "이걸로 해줘" + 5건 추가 fix (G_user_visual_detail F-12 행 1 form / 행 2 grid → parallel / 행 4 bone form / 행 7 garnish / 새 행 plate context + view angle 6건 FAIL) | F-12 (1건 only) | **R7 LOCK candidate가 v7 fix 후 LOCK 예정**: F-12 v7 / **R3 LOCK candidate**: F-01/F-02/F-03/F-05/F-06 (5건) / **R2 LOCK candidate**: F-07/F-08/F-10/F-11 (4건) / **R1 LOCK 유지**: F-04 떡볶이 (t1_003) / F-09 김치찌개 (t2_009) | prompts-library v1.9로 F-12 §5.2 본문 v7 전면 교체 (form + bone form + garnish + plate context + view angle 5건 fix + 식별 핵심 시각 요소 7개 갱신 + reroll trigger 7종 갱신 + R6 v6 archive 절 보존 + R3/R4/R5 archive 절 유지) + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. R7 실행 명령: `py tools/gen_food_anchors_m1.py --only F-12 --version v7 --model gpt-image-1 --quality medium`. 예상 비용 ~$0.04 (1장 × $0.042). 예상 시간 ~30초. v7 출력 경로: `assets-raw/food_anchors_m1/F-12_galbi_gui_v7.png` (v1/v2/v3/v4/v5/v6와 공존). | pending |

#### R7 사용자 R6 v6 피드백 (verbatim, 2026-05-28)

> 사용자가 R6 v6 결과 시각 확인 후 또 다른 reference image (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length)를 제시하며 verbatim:
>
> "이걸로 해줘"
>
> 새 reference image = 정통 LA-style 갈비구이 (LA-cut cross-cut form). 사용자의 시각 의도가 R3~R5의 strip form → R6의 square pieces grid → **R7의 LA-cut large strips with cross-section bones** 로 진화 (사용자 시각 의도 timeline §5.5.8 참조).

#### R7 main thread 새 reference image 시각 분석 (verbatim, 2026-05-28)

> 사용자가 R7 trigger와 함께 제시한 새 reference image (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length) main thread 직접 시각 분석. 7 핵심 시각 요소 추출 (CRITICAL = 행 3 bone discs along length):

1. **LA-style long elongated strip form** — 4-6 large rectangular meat strips, 각 strip approximately 18-25cm long × 8-12cm wide × 0.5-0.8cm thick (paper-thin appearance). R6의 small square pieces grid form 완전 폐기. R5의 strip form과 비슷하지만 strip 자체가 더 큼 (single bone at TOP LONG EDGE 아님, cross-cut LA-style으로 회귀).
2. **multiple strips parallel arrangement** — 4-6 large rectangular strips arranged in a row (서로 옆으로 나란히), strips slightly overlap or sit side by side. NOT perfectly aligned grid (R6 폐기), 자연스러운 BBQ 배치.
3. **LA cross-cut bone discs along each strip's length (CRITICAL signature)** — 각 strip의 길이 방향을 따라 3-4 small round white bone cross-section discs (각 disc ~1.5-2cm diameter, cream-white color). 이건 LA갈비의 정통 cross-cut 손질법 — 갈비뼈를 가로질러 자른 cross-section의 작은 둥근 흰 뼈 disc 여러 개가 strip 따라 나타남. **R3에서 한 번 시도됐다가 사용자가 폐기했지만, 이번 R7 reference는 정확히 그 패턴**. 즉 cross-cut LA-galbi pattern으로 settle.
4. **고기 두께 매우 얇음 (paper-thin)** — 0.5-0.8cm thick (~5-8mm), R5/R6와 동일하게 얇음. paper-thin appearance (정통 LA갈비 butchery).
5. **표면 색깔 + char marks** — dark brown caramelized + glossy soy-pear-garlic marinade glaze + 표면에 dark char marks/burned lines from grill (구운 자국). 칼집 (score marks)은 reference에 명확히 보이지 않음 — char marks가 dominant. R6의 칼집 강조는 deprioritize 가능 (LA-cut form에서는 cross-cut bones이 시그니처).
6. **garnish — 잘게 다진 green scallion (대파/송송) rounds scattered** — small round green spring onion slices (송송 sliced 대파 형태, 1-3mm 두께 disc) scattered across meat surface. plus 깨 sprinkle (minor accent). R6의 chopped minced garlic dots 폐기 — green scallion rounds로 변경.
7. **둥근 metallic wire mesh grill grate context** — round wire grate (회색/은색 metallic mesh) 위에서 굽고 있는 상태. 일부 reference에 hot coals (빨간 불꽃) under grate visible. plate context = round metallic wire grill grate (R4/R5/R6의 black cast iron plate → round wire mesh grate 우선).

#### R6 v6 vs R7 v7 핵심 diff 표 (5 fix × before/after)

| 요소 | R6 v6 (deprecated) | R7 v7 (사용자 또 다른 reference 기준) | fix 방향 |
|------|-------------------|---------------------------|---------|
| Fix 1: meat form (form 전면 교체) | "multiple small square-shaped grilled meat pieces (12~16 pieces total, each approximately 3-4cm × 3-4cm × 0.5-0.8cm thick) arranged in a grid pattern (3-4 rows × 4 columns)" | "4-6 large rectangular LA-style meat strips (each approximately 18-25cm long × 8-12cm wide × 0.5-0.8cm thick) arranged side by side parallel on the grill grate (slight natural overlap or aligned, NOT perfectly geometric grid)" + negative `NOT v6 small square pieces grid form (deprecated for this LA-galbi reference)` | small square pieces grid → LA-cut large rectangular strips parallel. 정통 LA갈비 cross-cut form 회귀 |
| Fix 2: bone form (CRITICAL, long bone at short edge → 3-4 cross-section discs along each strip's length) | "On ONE SHORT EDGE SIDE of the meat grid ... a single LONG WHITE RIB BONE is laid horizontally (approximately 12-15cm long × 1-1.5cm wide × 1-1.5cm tall, cream-white color) ... SINGLE LONG PIECE laying flat alongside the grid (perpendicular to the rows of meat pieces), NOT multiple small discs" | "Each meat strip has 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS visible along its LENGTH (each disc approximately 1.5-2cm diameter, cream-white color). LA-style cross-cut bones — the rib bones have been cut PERPENDICULAR to their original direction (cross-cut butchery), so each bone cross-section appears as a small round white disc along the strip's length. The bones are EVENLY SPACED along the length of each strip (approximately 3-5cm apart between discs). This is the LA-Galbi traditional cut signature" + negative `NOT a single long bone alongside the meat (R6 deprecated), NOT bone discs partially embedded along TOP LONG EDGE only (R5 deprecated), NOT one big bone at one end (R3 deprecated)` | single long bone alongside grid → multiple cross-section bone discs along each strip's length. LA cross-cut signature (R3에서 시도됐다가 폐기됐던 패턴이 R7 reference의 정확한 패턴) |
| Fix 3: garnish (chopped minced garlic → chopped green scallion rounds) | "Generous sprinkle of finely CHOPPED MINCED GARLIC bits scattered all over the meat pieces (small yellowish-white garlic granules)" | "Generous scattering of CHOPPED GREEN SCALLION ROUNDS (송송 sliced spring onion / 대파, each round approximately 1-3mm thick disc, bright green color) scattered across the meat strips as the hero garnish. Plus a light sprinkle of white sesame seeds as additional accent" + negative `NOT chopped minced garlic dots (R6 deprecated), NOT thin garlic slices, NOT whole garlic cloves, NOT only sesame seeds` | chopped minced garlic dots (yellowish-white) → chopped green scallion rounds (bright green) hero garnish |
| Fix 4: plate/grill context (cast iron plate → round metallic wire mesh grill grate) | "On a clean black cast iron grill plate (or alternatively a copper grill grate or a clean white plate with dark grill texture)" | "Sitting on a ROUND METALLIC WIRE MESH GRILL GRATE (silver-gray wire grate, the traditional Korean BBQ tabletop grill) — the wire mesh pattern is visible underneath and around the meat strips. Optional: subtle hint of red-orange glow underneath the grate suggesting hot coals (a touch of warm fire atmosphere, not dominant)" + negative `NOT a flat solid plate (v4/v5/v6 polished but deprecated for this LA-galbi form), NOT a white ceramic plate, NOT a black cast iron flat pan` | black cast iron grill plate → round metallic wire mesh grill grate (정통 한식 BBQ tabletop grill) + optional hot coals glow |
| Fix 5: view angle (top-down → slight 7/8 perspective) | "top-down view of plated cooked meat" | "slight 7/8 perspective view (mostly top-down but slightly angled to show meat thickness side profile + grill grate depth) — the slight 7/8 angle reveals the THIN slice thickness (0.5-0.8cm) from the side, confirming the paper-thin slice appearance" + negative `NOT a top-down view (R6 deprecated)` | top-down view → slight 7/8 perspective view. side profile에서 paper-thin 확인 가능 |

#### v6 vs v7 LOCK 유지 요소 4건 (변경 금지)

| # | LOCK 요소 | v6 = v7 본문 (무변경 확인) |
|---|----------|--------------------------|
| 1 | well-grilled caramelized brown + glossy glaze sheen, NOT raw | "rich caramelized dark brown with a glossy soy-pear-garlic marinade glaze ... well-cooked and glazed, NOT raw red-pink, NOT pale uncooked" — v4/v5/v6/v7 동일 |
| 2 | char marks visible on surface from grill (LA-cut form에서 dominant) | "Visible dark char marks / burned lines on the surface from cooking on the grill grate (the char marks are the dominant surface feature in LA-galbi, where the cross-cut bones are the signature rather than knife score marks)" — v6의 "darker grill char marks along the score lines and edges from cooking on the grill grate"가 v7에서 "dominant surface feature"로 강화 (LA-cut form 적합) |
| 3 | thin slice 0.5-0.8cm thickness | "0.5-0.8cm thick (5-8mm, very thin slice, paper-thin appearance — the characteristic LA-galbi properly butchered cut, much thinner than a typical steak cut)" — v6/v7 동일 |
| 4 | cross-cultural negative (yakiniku/American BBQ/char siu/steak/raw) + 추가 NOT v6 grid form | "NOT Japanese yakiniku ... NOT American BBQ ribs ... NOT Chinese char siu ... NOT a steak ... NOT v6 small square pieces grid form (deprecated for this LA-galbi reference)" — v6 cross-cultural 5종 + v7 NOT v6 grid form 추가 |

#### v6 본문 deprecated 사유 (verbatim, 2026-05-28)

R6 v6 prompt 라인 "multiple small square-shaped grilled meat pieces (12~16 pieces, each 3-4cm × 3-4cm × 0.5-0.8cm thick) arranged in a grid pattern (3-4 rows × 4 columns)" + "single LONG WHITE RIB BONE laid horizontally on ONE SHORT EDGE SIDE of the meat grid" + "finely CHOPPED MINCED GARLIC bits scattered all over the meat pieces" + "black cast iron grill plate" + "top-down view" → 사용자 v6 시각 확인 후 또 다른 reference image (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length) 제시 + verbatim "이걸로 해줘" + 5건 reject: (1) small square pieces grid form은 reference의 LA-cut large rectangular strips form과 어긋남, 정통 LA갈비는 large strips 형태이지 small square pieces가 아님 → form 전면 교체 / (2) single long bone at SHORT EDGE는 reference의 cross-cut bone discs along length 패턴과 완전히 다름, reference는 LA-style cross-cut (rib bones cut perpendicular to original direction) → bone form 완전 재정의 (CRITICAL — R3에서 시도됐다가 폐기됐던 패턴이 R7 reference의 정확한 패턴, 사용자 시각 의도 진화) / (3) chopped minced garlic dots (yellowish-white granules)는 reference에 없는 garnish, reference는 chopped green scallion rounds (송송 sliced 대파, bright green color) → garnish 변경 / (4) black cast iron grill plate는 reference의 round wire mesh grill grate와 다름, reference는 정통 한식 BBQ tabletop grill (wire mesh + optional hot coals) → plate context 변경 / (5) top-down view는 reference의 slight 7/8 perspective view와 다름, side profile에서 paper-thin thickness 확인 불가 → view angle 변경. v6의 LOCK 4 요소 (well-grilled brown + glaze / char marks / thin 0.5-0.8cm / cross-cultural negative) 무변경. **칼집 (knife score marks)은 optional로 격하** — LA-cut form에서는 cross-cut bones이 dominant signature이고 char marks가 dominant surface texture, score marks는 reference에 명확히 보이지 않음. 즉 v3~v6의 칼집 강조 LOCK은 LA-cut form에서는 시그니처 우선순위에서 밀려나 optional gate로 격하.

### 6.10 M1 환경 BG-01~05 v2 trigger (v1.11 신설, 2026-05-28)

> 2026-05-28 사용자가 정통 한식 가게 reference image (참기름 방앗간 한옥 양식, 1963년 since 1963)를 제공하며 명시: "**한식 정통 요소만 차용 + 기존 lock 유지**". main thread 시각 분석으로 차용 5건 + 회피 3건 추출 → Week 1 commit 7a6cffb 환경 anchor candidate 5장 (BG-01 청과상 / BG-02 정육점 / BG-03 어물전 / BG-04 곡물상 / BG-05 잡화점)이 한식 정통 5 요소를 누락한 modern Western-style storefront base임이 명확해짐. **BG-01~05 v1.2 lock candidate = invalidated**. 캐릭터 5장 CH-01~05는 무영향 (v1.2 lock candidate 유지). 환경 v2 sprint 진입.

| 라운드 | 날짜 | trigger 사유 | 영향 anchor | LOCK 유지 anchor | art-director 메모 | pm 승인 |
|-------|------|------------|------------|----------------|------------------|--------|
| M1 환경 v2 trigger (BG-01~05) | 2026-05-28 | 사용자 reference (참기름 방앗간) 시각 분석 후 한식 정통 5 요소 누락 진단 + 명시 "한식 정통 요소만 차용 + 기존 lock 유지" → v1.2 BG 5장 invalidate, v2 sprint trigger | BG-01/BG-02/BG-03/BG-04/BG-05 (5건 — 환경 anchor 전부) | **캐릭터 5장 CH-01~05 v1.2 lock candidate 무영향 유지** (commit 7a6cffb 캐릭터 부분만 유효) | prompts-library v1.11로 §2.2 STYLE_SUFFIX_BG_V2 전면 재작성 + §4 BG-01~05 본문 v2.0 전면 재작성 + §4.6 v1.2 archive 절 보존 + `tools/gen_bg_anchors_m1.py` 신설 (BG-01~05 v1.11 V2 prompt inline + STYLE_SUFFIX_BG_V2). **§5.6 G_env 6 요소 게이트 신설** (한옥 양식 / 카테고리 시그니처 / 옹기 / lantern / icon+영어 minimal signage / Cool Sage bg). **LOCK 조건 = 5/5 anchors × 6 요소 = 30/30 PASS**. 환경 v2 실행 명령: `py tools/gen_bg_anchors_m1.py --model gpt-image-1 --quality medium`. 예상 비용 ~$0.21 (5장 × $0.042). 예상 시간 ~2-3분. v1 출력 경로: `assets-raw/bg_anchors_m1/BG-XX_<name>_v1.png` (음식 12장 anchor (food_anchors_m1)과 별도 디렉터리). | pending |

#### 사용자 reference 시각 분석 (verbatim, 2026-05-28)

> 사용자가 제공한 reference image (정통 한식 가게 = 경주 참기름 방앗간 한옥 양식, since 1963, 전면 elevation view). main thread 직접 시각 확인 후 차용/회피 8 요소 추출:

**차용 5건 (한식 정통 요소)**:
1. **한옥 양식 외관** — 목조 frame (warm brown wood beams), 정통 한국 건축
2. **검정 기와 지붕** — curved eave tiles (처마 곡선), 처마 끝 흰 와당 patterns
3. **나무 간판** — 큰 나무 직사각 frame + 가게명 (단 v2는 icon+영어 minimal로 변환, 한글 prompt 회피)
4. **옹기 항아리** — 갈색 traditional Korean pottery 항아리 (1-2개 외부 배치)
5. **Hanging lantern** — 양쪽 warm yellow glow lantern

**회피 3건 (LOCK 유지)**:
1. **베이지 배경** — reference의 cream/베이지 storybook tone 회피, art-style v1.1 modern saturated Cool Sage `#C8D5C0` 유지
2. **한글 dominant signage** — reference의 "경주 참기름 방앗간", "기름", "직접 짠 고소한 참기름", "100% 국산품 참기름" 4건 한글, v2는 [feedback_i18n_icon_first] 2026-05-27 lock 유지 → icon + 영어 minimal로 변환. 한글 prompt 절대 회피
3. **Warm storybook tone** — illustrated/vintage 느낌, modern saturated/clean hyper-casual flat 톤 유지

#### v1.2 (Week 1 anchor candidate, commit 7a6cffb) vs v1.11 V2 핵심 diff 요약

| 요소 | v1.2 (deprecated 2026-05-28) | v1.11 V2 (사용자 reference 차용) |
|------|-------------------|---------------------------|
| 시점 | front-facing or slight three-quarter, eye-level | slight 7/8 isometric three-quarter (game environment depth) |
| 외관 | 단순 wooden stall rectangle + awning + cool sky bg | 한옥 wooden post-and-beam frame + 검정 기와 곡선 지붕 + 처마 + 와당 accent |
| 천막 (awning) | 가게당 솔리드 시그니처 색 + 1 accent trim band (이탈리아 회피) | **deprecated** (천막 없음). 대신 한옥 검정 기와 지붕이 시그니처 architectural element |
| 간판 | small price tag solid block placeholder | **큰 wooden signboard** centered above shop opening + icon-first English minimal (GREENGROCER / BUTCHER / FISHMONGER / GRAIN SHOP / GENERAL GOODS) |
| 옹기 항아리 | BG-05 잡화점에만 1개 | **5가게 모두 ground level 1-2개** (BG-04/BG-05는 2-3개 prominent) |
| Hanging lantern | 0건 | **5가게 모두 입구 양쪽 2개** (warm yellow glow) |
| 배경 | cool tone sky (soft mint / pastel teal / cool gradient) | Cool Sage `#C8D5C0` solid LOCK (5가게 통일) |
| 카테고리 시그니처 | 1-2 large simple category icons | **유지** (5가게 카테고리 시그니처 모두 v1.2 LOCK 그대로) |
| 회피 LOCK | 베이지/scrapbook/Italian flag awning/mortar/Cookie Run | **유지** + 추가 (한글/한자/카타카나, Chinese pagoda, Japanese irimoya, 베이지 reference의 cream/vintage 누수) |

#### Week 1 anchor candidate (commit 7a6cffb) invalidation 기록 (BG 5장만)

> commit 7a6cffb (2026-05-27 "feat: Week 1 art anchor 10장 lock candidate (v1.2 modern + icon+English i18n)") 10 anchor 중 **환경 5장 (BG-01~05) invalidate**. 캐릭터 5장 (CH-01~05 v1.2 lock candidate) 무영향 유지. invalidation 사유 = v1.2 BG 본문이 한식 정통 5 요소 (한옥 / 기와 / 처마 / 옹기 / lantern) 누락. v1.11 V2에서 한식 정통 요소 통합 + Cool Sage bg LOCK + icon+영어 signage LOCK 유지. 본 invalidation 기록은 §3.2 평가 표 BG-01~05 v1.2 row "invalidated 2026-05-28" status로 sync.

> **(2026-05-28 v1.12 v3 추기)**: v1.11 v2 한옥 풀세트 → 사용자 R2 reject "너무 많음" → v1.12 v3 minimal로 supersede. v1.2 BG invalidation은 여전히 유효 (천막 stripe + modern Western base 폐기). v3 minimal patch는 v1.2 base의 **카테고리 시그니처 + 가게 카운터 + signage + bg + outline + saturation**만 회복하고 **천막 → 기와 지붕 단일 fix만 추가** (한옥 frame 풀세트 / lantern / extra 옹기 모두 폐기). 자세한 사유는 §6.11 참조.

### 6.11 M1 환경 BG-01~05 v3 trigger (v1.12 신설, 2026-05-28)

> 2026-05-28 사용자가 v1.11 v2 (한옥 풀세트) 결과 5장 시각 확인 후 **"너무 많음"** 진단 + verbatim **"기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고"** 명시 → v1.11 v2 전면 폐기. v1.12 v3 = v1.2 base 회복 + **천막→검정 기와 곡선 지붕 단일 fix만 적용**. v2의 추가 요소 (옹기 5가게 prominent + lantern 5가게 양쪽 + 목조 한옥 frame + 깊은 처마 풀세트 + 와당 풀세트) **모두 폐기**. v1.2 LOCK 유지 = 카테고리 시그니처 / 작은 가게 카운터 / icon+영어 minimal signage / Cool Sage bg / modern saturated / slim outline 2-3px / no people / mortar 회피. 캐릭터 5장 CH-01~05는 무영향 (v1.2 lock candidate 유지). 환경 v3 sprint 진입.

| 라운드 | 날짜 | trigger 사유 | 영향 anchor | LOCK 유지 anchor | art-director 메모 | pm 승인 |
|-------|------|------------|------------|----------------|------------------|--------|
| M1 환경 v3 trigger (BG-01~05) | 2026-05-28 | 사용자 v1.11 v2 결과 5장 시각 확인 후 "너무 많음" + verbatim "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고" → v2 전면 폐기, v3 minimal trigger | BG-01/BG-02/BG-03/BG-04/BG-05 (5건 — 환경 anchor 전부) | **캐릭터 5장 CH-01~05 v1.2 lock candidate 무영향 유지** | prompts-library v1.12로 §2.2 STYLE_SUFFIX_BG_V3 전면 재작성 (v1.2 base 회복 + 기와 지붕 단일 layer + v2 한옥 풀세트 추가 요소 명시 회피) + §4 BG-01~05 본문 v3 전면 재작성 (각 anchor: v1.2 base 카테고리 시그니처 그대로 + 천막 자리에 기와 지붕만) + §4.7 v1.11 v2 archive 절 신설 (deprecated, 2026-05-28) + §4.6 v1.2 archive 절 무변경 + `tools/gen_bg_anchors_m1.py` v3 sync (BGS body 5개 v3 갱신, STYLE_SUFFIX_BG_V3 inline, default version "v3"). **§5.6 G_env_v3 5 요소 게이트 신설** (G_env_v2 6 요소 deprecated): 1. 검정 기와 지붕 단일 layer visible (천막 0건 CRITICAL) / 2. v1.2 base 카테고리 시그니처 visible / 3. icon+영어 minimal signage (한글 0건 CRITICAL) / 4. Cool Sage bg + modern saturated (베이지 0건 CRITICAL) / 5. v2 한옥 풀세트 추가 요소 0건 (minimal LOCK CRITICAL — 옹기 BG-01 좌측 2개만 / lantern 0건 / 목조 frame 0건 / 깊은 처마 0건). **LOCK 조건 = 5/5 anchors × 5 요소 = 25/25 PASS**. 환경 v3 실행 명령: `py tools/gen_bg_anchors_m1.py --version v3 --model gpt-image-1 --quality medium`. 예상 비용 ~$0.21 (5장 × $0.042). 예상 시간 ~2~3분. v3 출력 경로: `assets-raw/bg_anchors_m1/BG-XX_<name>_v3.png` (v1 한옥 풀세트와 공존). | pending |

#### 사용자 R2 v3 minimal trigger 피드백 (verbatim, 2026-05-28)

> 사용자가 v1.11 v2 결과 5장 시각 확인 후 verbatim 명시:
>
> "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고"

main thread 해석:
- "기존버젼" = v1.2 base (commit 7a6cffb, Week 1 BG-01~05 lock candidate). v1.11 v2가 한옥 풀세트로 너무 많이 추가했으므로 v1.2 base의 minimal feel로 환원.
- "다른거는 다 그대로" = v1.2 base의 카테고리 시그니처 (채소/meat/fish/곡식/sauce) + 작은 가게 카운터 + signage + Cool Sage bg + modern saturated + slim outline 모두 유지.
- "기와 지붕으로만 바꾸자" = 단일 fix = 검정 기와 곡선 지붕 (Korean hanok 기와 eave) 단일 layer만 추가. 한옥 frame 풀세트 / lantern / extra 옹기 / 깊은 처마 등 v2 추가 요소 모두 **포함하지 말 것**.
- "천막 없애고" = v1.2 base의 red/green striped awning은 제거 (그 자리에 기와 지붕 swap).

#### v1.11 v2 → v1.12 v3 핵심 diff 요약 (9 요소)

| 요소 | v1.11 v2 (deprecated 2026-05-28) | v1.12 v3 (사용자 R2 minimal fix) |
|------|----------------------|-------------------------------|
| 천막/지붕 | 검정 기와 + 처마 + 목조 한옥 frame 풀세트 (한옥 양식 전면 도입) | **검정 기와 곡선 지붕만** (단일 layer, 한옥 frame 없음, 깊은 처마 없음) |
| 옹기 항아리 | **5가게 모두에 추가** (ground level 1-2개, BG-04/BG-05는 2-3개 prominent) | **v1.2 base 그대로 유지** (BG-01만 좌측 2개, 나머지 BG-02/03/04는 옹기 0건, BG-05는 sauce 항아리 4개 카운터 진열만 — ground prominent 옹기 0건) |
| Hanging lantern | 양쪽 2개 5가게 모두 추가 (warm yellow glow) | **추가 안 함** (v1.2 그대로, lantern 0건) |
| 한옥 목조 frame | 양쪽 vertical wooden posts + horizontal beam 풀세트 | **추가 안 함** (v1.2 그대로) |
| 깊은 처마 (eave overhang) | the roof overhangs the shop opening, creating a subtle shadow band | **추가 안 함** (단순 기와 layer만, image 상단 ~20-25% slim band) |
| 와당 (eave-end tile cap) | 풀세트 명시 (line 풀) | **optional 2-3개만** (minimal accent) |
| 시점 | slight 7/8 isometric three-quarter (game environment depth) | **slight three-quarter angle만** (NOT 7/8 strict isometric, NOT 깊은 perspective — v1.2 base 시점 회복) |
| 카테고리 시그니처 (채소/meat/fish/곡식/sauce) | 명확 visible (유지) | **v1.2 base 그대로 유지** (BG-01 채소 stack + 좌측 옹기 2개 + 우측 hanging / BG-02 meat hanging + cutting board / BG-03 fish hanging + ice / BG-04 grain sacks 3종 / BG-05 sauce 항아리 4개 + 고추 hanging) |
| 영어 signage | GREENGROCER / BUTCHER / FISHMONGER / GRAIN SHOP / GENERAL GOODS | **v1.2 base 환원**: PRODUCE / BUTCHER / SEAFOOD / GRAIN / SAUCES |
| Cool Sage bg + modern saturated + slim outline 2-3px | LOCK | LOCK 무변경 |
| icon+영어 minimal signage | LOCK | LOCK 무변경 |
| mortar 회피 (art-style-guide §5) | LOCK | LOCK 무변경 |

#### v1.11 v2 invalidation 기록 (BG 5장만)

> v1.11 v2 BG-01~05 (2026-05-28 한옥 풀세트, output: `assets-raw/bg_anchors_m1/BG-XX_<name>_v1.png` 5장)는 **invalidate**. 사용자 R2 verbatim "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고"로 한옥 풀세트 추가 요소 (옹기 5가게 / lantern 5가게 / 목조 frame / 깊은 처마) 전면 폐기. v1.12 v3에서 v1.2 base 회복 + 기와 지붕 단일 fix로 supersede. v1.11 v2 출력 파일 (BG-XX_<name>_v1.png 5장)은 git history reference로 보존 (재실행 시 v3 출력은 별도 파일명 BG-XX_<name>_v3.png로 공존). 캐릭터 5장 CH-01~05는 여전히 무영향 (v1.2 lock candidate 유지).

#### 사용자 시각 의도 진화 timeline (BG 환경 5장)

| Round | 본문 핵심 | 사용자 reject 사유 (verbatim 또는 진단) | 다음 round fix 방향 |
|-------|----------|---------------------------|------------------|
| **v1.2 lock candidate (commit 7a6cffb)** | modern Western storefront base + red/green striped awning (이탈리아 회피) + 카테고리 시그니처 + 작은 가게 카운터 + icon+영어 signage + Cool Sage bg | 사용자 reference 제공 (참기름 방앗간 한옥 양식) + 명시 "한식 정통 요소만 차용 + 기존 lock 유지" — 한옥 정통 요소 누락 + 천막 stripe 한식 X | v1.11 v2: 한식 정통 5 요소 통합 (한옥 frame + 검정 기와 + 처마 + 옹기 5가게 + lantern 5가게) |
| **v1.11 v2** | 한옥 풀세트 (warm brown 목조 frame vertical posts + horizontal beam + 검정 기와 곡선 지붕 + 깊은 처마 overhang + 와당 풀 + 옹기 5가게 ground prominent + lantern 5가게 양쪽 warm yellow glow + 큰 wooden signboard with icon+영어) | "너무 많음" + verbatim "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고" — 한옥 풀세트 추가 요소 (옹기/lantern/frame/처마) 모두 폐기 + v1.2 minimal feel 회복 | v1.12 v3: v1.2 base 회복 + 천막→기와 지붕 단일 fix만 |
| **v1.12 v3 (deprecated 2026-05-28)** | v1.2 base minimal (카테고리 시그니처 / 작은 가게 카운터 / icon+영어 signage PRODUCE/BUTCHER/SEAFOOD/GRAIN/SAUCES / Cool Sage bg) + 검정 기와 곡선 지붕 단일 layer (천막 자리 swap, 와당 minimal 2-3개 accent) — prompt-only batch generation | 사용자 verbatim "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..." — 5가게 구조 inconsistent (prompt-only generation noise) + slight 7/8 perspective + v1.2 base 정확 재현 불가 | v1.13 v4 image edit (gpt-image-1 image edit API + v1.2 base PNG 직접 입력 + 지붕만 swap + frontal view) |
| **v1.13 v4 (current settle)** | gpt-image-1 image edit API + `assets-raw/week1-anchors/BG-XX_<name>_v2.png` 5장 직접 입력 + COMMON_EDIT_PROMPT (지붕 교체 + 다른 요소 ABSOLUTELY IDENTICAL 명시) + shop-specific 카테고리 한 줄. frontal view, 5가게 구조 정확 일관성 | (v4 pending) | 사용자 v4 시각 확인 후 추가 fix request 여부 결정. 첫 시도 BG-01 test 후 5장 batch 진행 (`py tools/edit_bg_anchors_v4.py`) |

### 6.12 M1 환경 BG-01~05 v4 trigger (v1.13 신설, 2026-05-28)

> 2026-05-28 사용자가 v1.12 v3 (minimal prompt-only batch generation) 결과 5장 시각 확인 후 verbatim **"각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."** 명시 → v1.12 v3 전면 폐기. v1.13 v4 = **gpt-image-1 image edit API + Week 1 commit 7a6cffb base image 5장 (`assets-raw/week1-anchors/BG-XX_<name>_v2.png`) 직접 입력 + 지붕만 교체 + frontal view**. main thread 해석 3건 fix: (1) **5가게 구조 정확 일관성** (지붕/기둥/카운터/frame 정확 동일, 카테고리별 display goods + signage icon만 다름) / (2) **v1.2 base 정확 유지 + 지붕만 교체** (image edit API 도입) / (3) **frontal view** (slight 7/8 perspective 폐기). 캐릭터 5장 CH-01~05는 무영향 (v1.2 lock candidate 유지). 환경 v4 sprint 진입.

| 라운드 | 날짜 | trigger 사유 | 영향 anchor | LOCK 유지 anchor | art-director 메모 | pm 승인 |
|-------|------|------------|------------|----------------|------------------|--------|
| M1 환경 v4 trigger (BG-01~05) | 2026-05-28 | 사용자 v1.12 v3 결과 5장 시각 확인 후 verbatim "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..." → v3 전면 폐기, v4 image edit trigger | BG-01/BG-02/BG-03/BG-04/BG-05 (5건 — 환경 anchor 전부) | **캐릭터 5장 CH-01~05 v1.2 lock candidate 무영향 유지** | prompts-library v1.13으로 §4 BG-01~05 본문 v4 image edit approach 전면 재작성 (§4.0 공통 COMMON_EDIT_PROMPT + §4.1 shop-specific 카테고리 한 줄 표 + §4.2 G_env_v4 8 요소 게이트 link + §4.3 driver script + §4.4 사용자 v3 폐기 verbatim + §4.5 v3 vs v4 5 요소 핵심 diff). v3 prompt-only 본문 5건은 §4-LEGACY archive로 deprecated. **새 driver `tools/edit_bg_anchors_v4.py` 신설** — gpt-image-1 image edit API + base image dimensions 사전 검증 + (필요 시) gpt-image-1 edit supported size (1024×1024 / 1536×1024 / 1024×1536)로 PIL resize fallback + b64_json 응답 처리. **§5.6.2 G_env_v4 8 요소 게이트 신설** (G_env_v3 5 요소 §5.6.4 deprecated archive): G_env_v3 5 요소 (검정 기와 지붕 단일 / v1.2 base 카테고리 시그니처 / icon+영어 minimal signage / Cool Sage bg + modern saturated / v2 한옥 풀세트 추가 요소 0건) + v4 추가 3 요소 (5가게 구조 정확 일관성 / frontal view / v1.2 base 시각 시그니처 정확 유지). **LOCK 조건 = 5/5 anchors × 8 요소 = 40/40 PASS**. 환경 v4 실행 명령: 1차 BG-01 test `py tools/edit_bg_anchors_v4.py --only BG-01` (1장 × $0.042 ≈ $0.05, ~30초) → 5장 batch `py tools/edit_bg_anchors_v4.py` (5장 × $0.042 ≈ $0.21, ~2-3분). v4 출력 경로: `assets-raw/bg_anchors_m1/BG-XX_<name>_v4.png` (v1/v2/v3와 공존). | pending |

#### 사용자 R2 v3 폐기 피드백 (verbatim, 2026-05-28)

> 사용자가 v1.12 v3 결과 5장 시각 확인 후 verbatim 명시:
>
> "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."

main thread 해석 (3건 fix):
1. **"각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나"** = 5가게 구조적 일관성 미달. carpenter 작업 (지붕 곡률 / 기둥 폭 / 카운터 형태 / frame 위치) 5가게 모두 정확 동일해야 함. v3는 prompt-only batch generation으로 5가게마다 generation noise로 다르게 생성됨. 카테고리별 다름은 display goods + signage icon + signage text 3건만이어야 함.
2. **"원래 버젼에서 지붕만 바꾸는게 어떨까"** = "원래 버젼" = v1.2 base (commit 7a6cffb anchor candidate, `assets-raw/week1-anchors/BG-XX_<name>_v2.png` 5장). prompt-only generation은 v1.2 정확 재현 불가능 → **gpt-image-1 image edit API**로 base image PNG를 직접 입력하고 지붕 부분만 교체 (다른 모든 요소 IDENTICAL 유지).
3. **"정면이 더 낫지 않나"** = frontal elevation view 명시. v1.2 base 5장이 원래 frontal이었음. v3의 slight 7/8 perspective는 STYLE_SUFFIX_BG_V3 prompt의 "slight three-quarter angle" 키워드가 DALL-E에 7/8 perspective로 추론된 결과. frontal view 회귀.

#### v1.12 v3 → v1.13 v4 핵심 diff 요약 (5 요소)

| 요소 | v1.12 v3 (deprecated 2026-05-28) | v1.13 v4 (사용자 R2 image edit fix) |
|------|-------------------------------|--------------------------------|
| API approach | `client.images.generate(model="gpt-image-1", prompt=...)` — prompt-only generation (5장 batch, 매번 다른 추론) | **`client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_EDIT_PROMPT + category, size, quality, n=1)` — image edit API (base PNG 직접 입력)** |
| Base image input | None (prompt only) | **`assets-raw/week1-anchors/BG-XX_<name>_v2.png` 5장 직접 입력** (Week 1 commit 7a6cffb anchor candidate) |
| 5가게 구조 일관성 | inconsistent (지붕 곡률/기둥 폭/카운터 형태/frame 위치 5가게마다 generation noise로 다르게 생성) | **정확 동일** (base image 5장 자체가 이미 v1.2 base에서 일관된 carpenter 작업, image edit은 지붕만 교체 → 5가게 구조 자동 일관) |
| 시점 | slight three-quarter angle (실제 결과는 slight 7/8 perspective — prompt 키워드의 DALL-E 추론) | **frontal elevation** (base image의 view 그대로 유지 — image edit이 view 변경 불가) |
| Prompt 본문 | §4 BG-01~05 long body prompt 5건 (각각 카테고리 시그니처 + 한옥 회피 + 옹기 추가 회피 등 long form text) + §2.2 STYLE_SUFFIX_BG_V3 (large suffix) | **단일 COMMON_EDIT_PROMPT** (지붕 교체 + 다른 요소 ABSOLUTELY IDENTICAL 명시) + shop-specific 카테고리 한 줄 (예: "Shop category: Korean greengrocer / produce shop (PRODUCE signage with cabbage icon).") |
| driver script | `tools/gen_bg_anchors_m1.py --version v3` (gen_image.py의 `generate_image` 호출) | **`tools/edit_bg_anchors_v4.py` 신설** (gpt-image-1 image edit API + base image dimensions 검증 + (필요 시) PIL resize fallback) |

#### v1.12 v3 invalidation 기록 (BG 5장만)

> v1.12 v3 BG-01~05 (2026-05-28 minimal prompt-only generation, output: `assets-raw/bg_anchors_m1/BG-XX_<name>_v3.png` 5장 추정)는 **invalidate**. 사용자 R2 verbatim "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."로 5가게 구조 inconsistent + slight 7/8 perspective + v1.2 base 정확 재현 불가 3건 사유. v1.13 v4에서 gpt-image-1 image edit API로 v1.2 base PNG 직접 입력 + 지붕만 교체 + frontal view로 supersede. v1.12 v3 출력 파일 (BG-XX_<name>_v3.png 5장)은 git history reference로 보존 (재실행 시 v4 출력은 별도 파일명 BG-XX_<name>_v4.png로 공존). 캐릭터 5장 CH-01~05는 여전히 무영향 (v1.2 lock candidate 유지).

#### 도구 변경 사유 — prompt-only generation의 v1.2 base 재현 한계

> v1.12 v3 sprint에서 학습한 점: prompt-only generation은 v1.2 base 본문 prompt를 그대로 다시 사용해도 매번 다른 결과를 생성한다 (DALL-E 추론 noise). 5가게 batch generation은 더 심각 — 각 가게의 carpenter 작업이 generation noise로 다르게 그려져 cross-shop 구조 일관성 깨짐. **해결**: gpt-image-1 image edit API로 base image PNG를 직접 입력하면, base의 구조 (frame/카운터/proportion/view)는 보존하고 prompt가 지정한 부분만 교체. 5가게 base가 이미 v1.2 lock candidate (commit 7a6cffb)에서 cross-shop 일관성을 가졌으므로 (Week 1 단일 ChatGPT 세션에서 일관성 lock 완료), image edit으로 지붕만 swap하면 5가게 구조 자동 일관 + v1.2 base 정확 유지 + frontal view (base가 frontal이었음) 3건 동시 충족.

---

## 7. 변경 이력

- **2026-05-28 v1.13** (M1 환경 BG-01~05 v4 image edit — v1.2 base + 지붕만 교체 + frontal view + 5가게 구조 일관성 + G_env_v4 8 요소 게이트 신설 + gpt-image-1 image edit API 도입, supersedes v1.12) — 사용자가 v1.12 v3 (minimal prompt-only batch generation) 결과 5장 시각 확인 후 verbatim **"각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."** 명시 → v1.12 v3 전면 폐기. v1.13 v4 = **gpt-image-1 image edit API** (`client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_EDIT_PROMPT + category, size, quality, n=1)`) + Week 1 commit 7a6cffb base image 5장 (`assets-raw/week1-anchors/BG-XX_<name>_v2.png`) 직접 입력 + 지붕만 교체 + frontal view. main thread 해석 3건 fix: (1) **5가게 구조 정확 일관성** — 지붕/기둥/카운터/frame 5가게 모두 정확 동일, 카테고리별 display goods + signage icon만 다름 (v3 prompt-only batch generation의 generation noise로 5가게 carpenter 작업이 다르게 생성됨) / (2) **v1.2 base 정확 유지 + 지붕만 교체** — prompt-only는 v1.2 정확 재현 어려움, gpt-image-1 image edit API 도입으로 base image PNG 직접 입력 + 지붕 부분만 교체 / (3) **frontal view** — slight 7/8 perspective 폐기, v1.2 base가 frontal이었음. prompts-library v1.13으로 §4 BG-01~05 본문 v4 image edit approach 전면 재작성 (§4.0 공통 COMMON_EDIT_PROMPT + §4.1 shop-specific 카테고리 한 줄 표 + §4.2 G_env_v4 8 요소 게이트 link + §4.3 driver script `tools/edit_bg_anchors_v4.py` + §4.4 사용자 v3 폐기 verbatim + §4.5 v3 vs v4 5 요소 핵심 diff). v3 prompt-only 본문 5건은 §4-LEGACY archive로 deprecated (재활용 가능한 reroll trigger 문장은 보존). **새 driver `tools/edit_bg_anchors_v4.py` 신설** — gpt-image-1 image edit API + base image dimensions 사전 검증 + (필요 시) gpt-image-1 edit supported size (1024×1024 / 1536×1024 / 1024×1536)로 PIL resize fallback + b64_json 응답 처리. **§3.2 환경 anchor 평가 표 갱신** — v1.12 v3 BG-01~05 5 row "v1.12 v3 deprecated 2026-05-28 (5가게 구조 inconsistent + 7/8 perspective)" 추가 + v4 BG-01~05 5 row "v4 pending image edit (G_env_v4 8 요소)" 신설. **§5.6.2 G_env_v4 8 요소 게이트 신설** (G_env_v3 5 요소 §5.6.LEGACY deprecated): G_env_v3 5 요소 (검정 기와 지붕 단일 / v1.2 base 카테고리 시그니처 / icon+영어 minimal signage / Cool Sage bg + modern saturated / v2 한옥 풀세트 추가 요소 0건) + **v4 추가 3 요소**: G_env_v4_6 **5가게 구조 정확 일관성** (지붕/기둥/카운터/frame 5가게 정확 동일, 카테고리별 display goods + signage icon만 다름) / G_env_v4_7 **frontal elevation view** (slight 7/8 perspective 0건) / G_env_v4_8 **v1.2 base 시각 시그니처 정확 유지** (base image의 frame/카운터/products/signage/bg가 image edit 후에도 ABSOLUTELY IDENTICAL). **LOCK 조건 = 5/5 anchors × 8 요소 = 40/40 PASS**. 부분 통과 정책 (4 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only BG-XX` reroll / 3+ anchors FAIL = FAIL / BG-01 anchor seed FAIL = FAIL / 5가게 구조 일관성 #6 일부 FAIL은 base image 자체가 일관됐는지 재확인 후 prompt 강화). §5.6.3 환경 v4 라운드 예산 (R1 BG-01 test ~30초 $0.05 → 5장 batch ~2-3분 $0.21 / R2 follow-up). §5.6.LEGACY G_env_v3 5 요소 deprecated archive 보존. **§6.12 Decisions Log 신설** — 환경 v4 trigger 행 + 사용자 R2 v3 verbatim "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..." + main thread 해석 3건 fix + v1.12 v3 → v1.13 v4 5 핵심 diff 표 + v1.12 v3 invalidation 기록 (BG 5장만, 캐릭터 무영향 명시) + 도구 변경 사유 (prompt-only generation의 v1.2 base 재현 한계 + image edit으로 5가게 구조 자동 일관 달성) + main thread 실행 명령 (`py tools/edit_bg_anchors_v4.py --only BG-01` test 먼저 → `py tools/edit_bg_anchors_v4.py` 5장 batch, gpt-image-1 medium, 5장 × $0.042 ≈ $0.21, ~2-3분, v4 출력 경로 `assets-raw/bg_anchors_m1/BG-XX_<name>_v4.png` v1/v2/v3와 공존). §6.11 v3 trigger 행은 timeline 표 마지막 row에 v3 deprecated 명시 + v4 row 신설로 supersede note. 음식 12 평가 (§5.5) 무변경 (F-12 v1.10 R7 plated white plate LOCK candidate 유지). 캐릭터 5 평가 (§3.1) 무변경 (v1.2 lock candidate 유지).
- **2026-05-28 v1.12** (M1 환경 BG-01~05 v3 minimal — v1.2 base 회복 + 천막→기와 지붕 단일 fix + G_env_v3 5 요소 게이트 신설, supersedes v1.11) — 사용자가 v1.11 v2 (한옥 풀세트) 결과 5장 시각 확인 후 **"너무 많음"** 진단 + verbatim **"기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고"** 명시 → v1.11 v2 전면 폐기. v1.12 v3 = v1.2 base (commit 7a6cffb) 회복 + **천막(red/green striped awning) → 검정 기와 곡선 지붕 단일 fix만 적용**. v2의 추가 요소 (옹기 5가게 prominent + lantern 5가게 양쪽 + 목조 한옥 frame + 깊은 처마 풀세트 + 와당 풀세트) **모두 폐기**. v1.2 LOCK 유지 = 카테고리 시그니처 (채소/meat/fish/곡식/sauce) / 작은 가게 카운터 / icon+영어 minimal signage (PRODUCE/BUTCHER/SEAFOOD/GRAIN/SAUCES v1.2 base 환원) / Cool Sage `#C8D5C0` bg / modern saturated / slim outline 2-3px / no people / mortar 회피. prompts-library v1.12로 §2.2 STYLE_SUFFIX_BG_V3 전면 재작성 + §4 BG-01~05 본문 v3 전면 재작성 + §4.7 v1.11 v2 archive 절 신설 (deprecated, 2026-05-28) + §4.6 v1.2 archive 절 무변경 + `tools/gen_bg_anchors_m1.py` v3 sync (BGS body 5개 v3 갱신, STYLE_SUFFIX_BG_V3 inline, default version "v3"). **§3.2 환경 anchor 평가 표 갱신** — v1.11 v2 BG-01~05 5 row "v1.11 v2 deprecated 2026-05-28 (한옥 풀세트 너무 많음)" 추가 + v3 BG-01~05 5 row "v3 pending (G_env_v3 5 요소)" 신설. **§5.6 M1 환경 5 V3 평가 가이드 신설 (G_env_v2 6 요소 deprecated)** — §5.6.1 v1.11 v2 deprecation 배경 + v3 minimal 진화 timeline (v1.2 → v2 한옥 풀세트 → v3 minimal). §5.6.2 **G_env_v3 5 요소 점검표 신설**: 1. 검정 기와 지붕 단일 layer visible (천막 0건 CRITICAL) / 2. v1.2 base 카테고리 시그니처 visible (BG별 1-2 icons + signature color) / 3. icon+영어 minimal signage (한글 0건 CRITICAL) / 4. Cool Sage bg + modern saturated 톤 (베이지 0건 CRITICAL) / 5. v2 한옥 풀세트 추가 요소 0건 (minimal LOCK CRITICAL — 옹기 BG-01 좌측 2개만 / lantern 0건 / 목조 frame 0건 / 깊은 처마 0건). **LOCK 조건 = 5/5 anchors × 5 요소 = 25/25 PASS**. 부분 통과 정책 (4 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL / 3+ anchors FAIL = FAIL / BG-01 anchor seed FAIL = FAIL). §5.6.3 환경 v3 라운드 예산 (R1 v3 batch ~2-3분 $0.21 / R2 follow-up). §5.6.4 G_env_v2 deprecated archive note. **§6.11 Decisions Log 신설** — 환경 v3 trigger 행 + 사용자 R2 verbatim "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고" + main thread 해석 + v1.11 v2 → v1.12 v3 9 요소 핵심 diff 표 + v1.11 v2 invalidation 기록 (BG 5장만, 캐릭터 무영향 명시) + 사용자 시각 의도 진화 timeline (v1.2 → v2 → v3) + main thread 실행 명령 (`py tools/gen_bg_anchors_m1.py --version v3 --model gpt-image-1 --quality medium`, 5장 × $0.042 ≈ $0.21, ~2-3분, v3 출력 경로 `assets-raw/bg_anchors_m1/BG-XX_<name>_v3.png` v1 한옥 풀세트와 공존). §6.10 v1.11 v2 trigger 행에 v3 supersede note 추가. 음식 12 평가 (§5.5) 무변경 (F-12 v1.10 R7 plated white plate LOCK candidate 유지). 캐릭터 5 평가 (§3.1) 무변경 (v1.2 lock candidate 유지).
- **2026-05-28 v1.11** (M1 환경 BG-01~05 v2 갱신 — 한옥 양식 + 검정 기와 + 처마 + 옹기 + lantern + icon+영어 minimal signage 6 요소 G_env 게이트 신설, supersedes v1.10) — 사용자가 정통 한식 가게 reference image (참기름 방앗간 한옥 양식, 1963년) 제공 + 명시 "**한식 정통 요소만 차용 + 기존 lock 유지**". main thread 시각 분석으로 차용 5건 (한옥 frame / 검정 기와 곡선 지붕 + 처마 / 큰 나무 간판 / 옹기 / hanging lantern) + 회피 3건 (베이지 / 한글 dominant signage / vintage storybook tone) 추출. **Week 1 commit 7a6cffb 환경 anchor candidate 5장 (BG-01~05) invalidate** (캐릭터 5장 CH-01~05는 무영향, v1.2 lock candidate 유지). prompts-library v1.11로 §2.2 STYLE_SUFFIX_BG_V2 전면 재작성 + §4 BG-01~05 본문 v2.0 전면 재작성 + §4.6 v1.2 archive 절 보존 + `tools/gen_bg_anchors_m1.py` 신설 (BG-01~05 v1.11 V2 prompt inline + STYLE_SUFFIX_BG_V2). **§3.2 환경 anchor 평가 표 갱신** — v1.2 BG-01~05 5 row "invalidated 2026-05-28" + v2 BG-01~05 5 row "v2 pending (G_env)" 추가. **§5.6 M1 환경 5 V2 평가 가이드 신설** — §5.6.1 v1.2 invalidation 배경 + §5.6.2 **G_env 6 요소 점검표 신설**: 1. 한옥 양식 visible (기와 지붕 + 처마 + 목조 frame) / 2. 가게 카테고리 시그니처 visible (1-2 icons) / 3. 옹기 항아리 visible (1-2개, BG-04/BG-05는 2-3개 prominent) / 4. Hanging lantern visible (2개, 양쪽) / 5. icon+영어 minimal signage (한글 0건 CRITICAL) / 6. modern saturated 톤 + Cool Sage bg (베이지 0건 CRITICAL). **LOCK 조건 = 5/5 anchors × 6 요소 = 30/30 PASS**. 부분 통과 정책 (4 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL / 3+ anchors FAIL = FAIL / BG-01 anchor seed FAIL = FAIL). §5.6.3 환경 v2 라운드 예산 (R1 batch ~2-3분 $0.21 / R2 follow-up). **§6.10 Decisions Log 신설** — 환경 v2 trigger 행 + 사용자 reference 시각 분석 5+3 요소 verbatim + v1.2 vs v1.11 V2 9 요소 핵심 diff 표 + Week 1 commit 7a6cffb BG 5장 invalidation 기록 (캐릭터 5장 무영향 명시) + main thread 실행 명령 (`py tools/gen_bg_anchors_m1.py --model gpt-image-1 --quality medium`, 5장 × $0.042 ≈ $0.21, ~2-3분, v1 출력 경로 `assets-raw/bg_anchors_m1/`). 음식 12 평가 (§5.5) 무변경 (F-12 v1.10 R7 plated white plate LOCK candidate 유지). 캐릭터 5 평가 (§3.1) 무변경 (v1.2 lock candidate 유지).
- **2026-05-28 v1.10** (M1 음식 F-12 R7 reroll trigger, LA-cut long strip form + multiple cross-section bone discs along length + green scallion rounds + wire mesh grill grate + 7/8 perspective 5건 fix, supersedes v1.9) — R6 v6 결과 시각 확인 후 사용자가 **또 다른 reference image** (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length)를 제시하며 verbatim "이걸로 해줘" 명시 + 5건 추가 fix 요청. R6 v6의 small square pieces grid form + SHORT EDGE long single bone + chopped minced garlic dots + black cast iron plate + top-down view 패턴이 새 reference와 어긋남 진단 → R6 v6 = **deprecated**. F-12 단독 R7 reroll trigger. 다른 11장 (F-01~F-11) status 무변경. R7 fix 핵심 = (1) **form 전면 교체**: small square pieces grid (3-4cm × 3-4cm, 12-16 pieces in 3-4 rows × 4 columns) → 4-6 large rectangular LA-style meat strips (18-25cm × 8-12cm × 0.5-0.8cm) parallel side by side. 정통 LA-cut form 회귀 / (2) **bone form 완전 재정의 (CRITICAL signature)**: single LONG WHITE RIB BONE (12-15cm) at SHORT EDGE → 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS (each ~1.5-2cm diameter) along each strip's LENGTH (evenly spaced ~3-5cm apart). LA-style cross-cut bones (ribs cut perpendicular to original direction). R3에서 시도됐다가 폐기됐던 패턴이 R7 reference의 정확한 패턴 (사용자 시각 의도 진화) / (3) **garnish 변경**: chopped minced garlic dots → chopped GREEN SCALLION rounds (송송 sliced 대파, 1-3mm thick discs, bright green) hero garnish + 깨 minor accent / (4) **plate/grill context 변경**: black cast iron grill plate → ROUND METALLIC WIRE MESH GRILL GRATE (silver-gray wire pattern + optional hot coals glow). 정통 한식 BBQ tabletop grill / (5) **view angle 변경**: top-down view → slight 7/8 perspective view (mostly top-down but slightly angled to show meat thickness side profile + grate depth). v6의 LOCK 4 요소 (well-grilled brown + glaze / char marks / thin 0.5-0.8cm / cross-cultural negative + NOT v6 grid form) 무변경. **부분 폐기 — 칼집 (knife score marks) optional**: v3~v6 핵심 LOCK 시그니처였으나 R7 reference에서는 cross-cut bones이 dominant signature이고 char marks가 dominant surface texture, score marks는 reference에 명확히 보이지 않음. 칼집은 optional로 격하 (visible면 OK, 없어도 PASS). prompts-library v1.9로 F-12 §5.2 본문 v7 전면 교체 (5건 fix + 식별 핵심 시각 요소 7개 갱신 + reroll trigger 7종 갱신 + R6 v6 archive 절 보존) + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. **§5.5.4 평가 표 F-12 status `R6 reroll pending` → `R7 reroll pending` 갱신** (G_food PASS R1~R6 확장 + G_user_visual_detail FAIL R6 사유 + R7 fix 의도 명시). **§5.5.8 R6 평가 기준 7 요소 점검표 → R7 7 요소 점검표 신설 (R4/R5/R6 deprecated)**: 행 1 LA-cut long strip form (신설) / 행 2 multiple strips parallel arrangement (신설) / 행 3 thin slice 0.5-0.8cm (LOCK 유지) / 행 4 **CRITICAL: 3-4 bone cross-section discs along each strip's LENGTH (LA cross-cut signature, 신설)** / 행 5 well-grilled brown + glaze + char marks (LOCK 유지) / 행 6 chopped green scallion rounds garnish (신설) / 행 7 round metallic wire mesh grill grate context (신설). **칼집은 optional 게이트로 격하**. R7 escalation 정책 (R7 PASS 7/7 = LOCK / 1-2 FAIL = reroll trigger 7종 사용 / 3+ FAIL = pm + chain-of-references 누적 검토). **사용자 시각 의도 진화 timeline v3→v4→v5→v6→v7 요약 표 신설** (각 round 본문 핵심 + 사용자 reject verbatim + 다음 round fix 방향). R6 v6 평가 기준은 deprecated archive note만 보존. R5 v5 평가 기준은 deprecated archive note 유지. **§6.9 Decisions Log 신설** — R7 trigger 행 + 사용자 R6 v6 피드백 verbatim "이걸로 해줘" + main thread 새 reference image 시각 분석 7 요소 verbatim (CRITICAL = 3-4 bone discs along length) + R6 vs R7 5 핵심 fix diff 표 + v6 vs v7 LOCK 유지 요소 4건 무변경 확인 표 + v6 본문 deprecated 사유 verbatim + main thread 실행 명령 (gpt-image-1 medium, 1장 × ~$0.042 = ~$0.04, ~30초, v7 출력 경로 v1/v2/v3/v4/v5/v6와 공존).
- **2026-05-28 v1.9** (M1 음식 F-12 R6 reroll trigger, form 전면 교체 + thickness 더 얇게 + bone short edge + 마늘 dots 4건 fix, supersedes v1.8) — R5 v5 결과 시각 확인 후 사용자가 **새 reference image** (정통 한식 갈비구이 — 가위로 자른 후의 eating-style state)를 제시하며 4건 추가 fix 요청 + verbatim "가위로 자르고 난후의 갈비구이....Short Edge쪽에 뼈가 길게 있잖어....그리고 고기 자체도 훨씬 얇게 되어 있고....". R5 v5의 long elongated strips + bone TOP LONG EDGE 패턴이 새 reference와 어긋남 진단 → R5 v5 = **deprecated**. F-12 단독 R6 reroll trigger. 다른 11장 (F-01~F-11) status 무변경. R6 fix 핵심 = (1) **form 전면 교체**: 4 long elongated strips (12-15cm × 3cm × 0.7-1cm) → 12-16 small square pieces (3-4cm × 3-4cm × 0.5-0.8cm thick) in grid pattern (3-4 rows × 4 columns) — 한식 갈비구이의 eating-style state (가위로 자른 후) / (2) **thickness 더 얇게**: 0.7-1cm → 0.5-0.8cm (5-8mm) / (3) **bone 위치 완전 재정의**: bone discs along TOP LONG EDGE of each strip → SINGLE LONG WHITE RIB BONE (12-15cm) laid alongside meat grid on ONE SHORT EDGE / (4) **garnish 잘게 다진 마늘 dots**: 1-2 thin garlic slices → finely chopped minced garlic granules scattered all over. v5의 다른 LOCK 5 요소 (칼집 maintained on each piece / strictly parallel-aligned arrangement / well-grilled brown + glaze / plate context / cross-cultural negative + 추가 NOT uncut long strips) 무변경. prompts-library v1.8로 F-12 §5.2 본문 v6 전면 교체 (식별 핵심 시각 요소 6→7개 갱신 / reroll trigger 7종 신설 / R5 v5 archive 절 보존) + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. **§5.5.4 평가 표 F-12 status `R5 reroll pending` → `R6 reroll pending` 갱신** (G_food PASS R1~R5 확장 + G_user_visual_detail FAIL R5 사유 + R6 fix 의도 명시). **§5.5.8 R5 평가 기준 6 요소 점검표 → R6 7 요소 점검표 신설 (R4/R5 deprecated)**: 행 1 square piece form (신설) / 행 2 grid pattern arrangement (신설) / 행 3 thin slice 0.5-0.8cm (재정의) / 행 4 long bone at SHORT EDGE (재정의) / 행 5 칼집 maintained on each piece (LOCK 유지) / 행 6 well-grilled caramelized brown (LOCK 유지) / 행 7 chopped minced garlic dots (신설). R6 escalation 정책 (R6 PASS 7/7 = LOCK / 1-2 FAIL = reroll trigger 7종 사용 / 3+ FAIL = pm). R5 v5 평가 기준은 deprecated archive note만 보존. **§6.8 Decisions Log 신설** — R6 trigger 행 + 사용자 R5 v5 피드백 verbatim + main thread 새 reference image 시각 분석 7 요소 verbatim + R5 vs R6 4 핵심 fix diff 표 + v5 vs v6 LOCK 유지 요소 5건 무변경 확인 표 + v5 본문 deprecated 사유 verbatim + main thread 실행 명령 (gpt-image-1 medium, 1장 × ~$0.042 = ~$0.04, ~30초, v6 출력 경로 v1/v2/v3/v4/v5와 공존).
- **2026-05-28 v1.8** (M1 음식 F-12 R5 reroll trigger, thickness 0.7-1cm thin + bone TOP LONG EDGE 2건 fix, supersedes v1.7) — R4 v4 결과 시각 확인 후 사용자 2건 추가 fix 요청: (1) "고기가 일단 더 얇아야 함" thickness 1-1.5cm → 0.7-1cm (very thin slice, 6-8mm) / (2) "긴쪽의 밑쪽이 아니라 윗부분의 사이드로 보여야함" bone 위치 = v4 "between strips at plate edges" 폐기 → v5 "along the TOP LONG EDGE of each meat strip, partially embedded into the upper long edge" 명확화. v4의 다른 LOCK 6 요소 (칼집 / strictly parallel / 길이 12-15cm / well-grilled brown + glaze / grill marks / plate context) 무변경. R4 v4 = **deprecated**. F-12 단독 R5 reroll trigger. 다른 11장 (F-01~F-11) status 무변경. prompts-library v1.7로 F-12 §5.2 본문 v5 패치 (2 line fix + ESSENTIAL features 문장 + Bone position is CRITICAL 절 신설 + v4 archive 절 보존) + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. **§5.5.4 평가 표 F-12 status `R4 reroll pending` → `R5 reroll pending` 갱신** (G_food PASS R1/R2/R3/R4 확장 + G_user_visual_detail FAIL R4 사유 + R5 reroll fix 의도 명시). **§5.5.8 F-12 R4 평가 기준 표 → R5 기준으로 재정의** — 행 4번 (bone 위치) v4 "between strips at plate edges" → v5 "strip의 TOP LONG EDGE에 partially embedded" / 행 6번 (strip 두께) v4 "1-1.5cm thick" → v5 "0.7-1cm thin slice 6-8mm" 갱신. 행 1번 (칼집) / 행 2번 (strictly parallel) / 행 3번 (well-grilled brown) / 행 5번 (길이 12-15cm) 무변경. R5 escalation 정책 (R5 PASS 6/6 = LOCK / 1-2 FAIL = reroll trigger 6종 사용 / 3+ FAIL = pm). **§6.7 Decisions Log 신설** — R5 trigger 행 + 사용자 R4 v4 피드백 verbatim 2건 + main thread bone 위치 해석 분석 verbatim + v4 vs v5 2 요소 핵심 diff 표 + v4 vs v5 LOCK 유지 요소 6건 무변경 확인 표 + v4 deprecated 사유 verbatim + main thread 실행 명령 (gpt-image-1 medium, 1장 × ~$0.042 = ~$0.04, ~30초, v5 출력 경로 v1/v2/v3/v4와 공존).
- **2026-05-28 v1.7** (M1 음식 F-12 R4 reroll trigger, 사용자 reference image 6 시각 요소 1:1 매칭 기준, supersedes v1.6) — R3 v3 결과 시각 확인 후 사용자가 정통 한식 갈비구이 reference image를 직접 보여주며 시각 의도 명확화. R3 v3 "끝에 single bone protrudes" 묘사가 reference와 어긋남 발견 → R3 v3 **deprecated**. F-12 단독 R4 reroll trigger. 다른 11장 (F-01~F-11) status 무변경. R4 fix 핵심 = 사용자 reference image 6 시각 요소 1:1 매칭: (1) **칼집 (knife score marks)** — 가장 중요한 시그니처, R3에는 0건이었음, 각 strip 표면 3-5 deep horizontal knife cuts perpendicular to length / (2) **thin elongated parallel meat strips** (4 strips × 12-15cm × 3cm × 1-1.5cm, strictly parallel NOT overlapping) / (3) **small white round bone cross-section discs nestled between strips at plate edges** (R3 single bone at one end 묘사 폐기) / (4) **well-grilled caramelized brown + glossy soy-pear-garlic glaze sheen** (raw red-pink NOT) / (5) **grill marks along score lines + edges** / (6) **plating context = clean black cast iron grill plate 또는 white plate**. prompts-library v1.6로 F-12 §5.2 본문 전면 교체 + R3 v3 archive 절 보존 + `tools/gen_food_anchors_m1.py` FOODS F-12 sync 완료. **§5.5.4 평가 표 F-12 status `R4 reroll pending` 갱신**. **§5.5.7 R3 평가 기준 F-12 deprecated note 추가**. **§5.5.8 F-12 R4 평가 기준 신설** — G_user_visual_detail 6 요소 PASS 게이트 점검표 (칼집 / strictly parallel / 구운 색 + glaze sheen / small bone discs at edges / 길이 12-15cm / 두께 1-1.5cm), 1개라도 누락 시 FAIL, R4 1-2 요소 FAIL = follow-up reroll, 3+ 요소 FAIL = pm 에스컬레이션. **§6.5 Decisions Log F-12 R3 fix 행 deprecated note 추가**. **§6.6 Decisions Log 신설** — R4 trigger 행 + 사용자 reference image 시각 분석 6 요소 verbatim + R3 v3 vs R4 v4 6 요소 diff 표 + R3 single-bone-at-end 폐기 사유 verbatim + main thread 실행 명령 (gpt-image-1 medium, 1장 × ~$0.042 = ~$0.04, ~30초, v4 출력 경로 v1/v2/v3과 공존).
- **2026-05-27 v1.6** (M1 음식 R3 reroll 6건 trigger, F-07/F-08/F-10/F-11 R2 LOCK candidate, F-04/F-09 R1 LOCK 유지, supersedes v1.5) — R2 v2 결과 사용자 시각 확인 후 **selective 시각 피드백 6건 raise** (F-01/F-02/F-03/F-05/F-06/F-12). F-07/F-08/F-10/F-11 4장은 사용자 silent ACK → R2 LOCK candidate 갱신. F-04/F-09는 R1 LOCK 유지. R3 fix 핵심 = (1) **v1 base 회복** (F-01/F-03/F-05 — v2가 너무 보수적/축소로 식욕 자극 ↓, 사용자 "원래 버전이 더 먹음직스러움") + (2) **F-02 topping syrup drizzle** (contained filling 유지 + 표면 별도 토핑 drizzle) + (3) **F-06 cross-section 4요소 명확** (sausage core 본체 visible + cheese stretch + panko + ketchup/mustard zigzag) + (4) **F-12 전면 재작성** (LA-cut 폐기, 정통 한식 = thin meat strip 5-7cm × 1-1.5cm + 한쪽 끝 SHORT WHITE BONE 1-2cm 노출 — 사용자 "갈비구이는 끝에 뼈가 좀 있어야 됨"). **§5.5.4 평가 표 status 갱신** — 6건 `R3 reroll pending`, F-07/F-08/F-10/F-11 `R2 LOCK candidate (사용자 silent ACK)`, F-04/F-09 `LOCK (R1 유지)`. G_user_visual_detail 컬럼 행별 R2 결과/R3 fix 의도 명시. **§5.5.7 R3 평가 기준 갱신** (F-01 v1 base + 면 THIN / F-02 contained + topping drizzle 2 layer 구분 / F-03·F-05 v1 base + rice FINE / F-06 4요소 visible / F-12 정통 한식 단일 끝 bone 1-2cm). **§6.5 Decisions Log 신설** — R3 reroll trigger 행 + 사용자 피드백 6건 verbatim + R3 패치 본문 fix 핵심 표 + main thread 실행 명령 (gpt-image-1 medium, 6장 × ~$0.042 = ~$0.25, ~2분, v3 출력 경로 v1/v2와 공존). v1.6는 prompts-library v1.5 / `tools/gen_food_anchors_m1.py` FOODS sync 완료 상태 전제.
- **2026-05-27 v1.5** (M1 음식 R2 reroll 10건 trigger, F-04/F-09 R1 LOCK 유지, supersedes v1.4) — R1 v1 결과 사용자 시각 확인 후 **구체 시각 피드백 10건 raise** (F-04 떡볶이 / F-09 김치찌개 LOCK 유지). G_food cross-cultural은 R1에서 12/12 PASS였으나 G_user_visual_detail (음식 디테일) 측면에서 10건 FAIL. **§5.5.4 평가 표** R1 LOCK 갱신 → 10건 status `R2 reroll pending` + F-04/F-09 `LOCK (R1 유지)`. G_user_visual_detail 컬럼 추가. **§5.5.7 G_user_visual_detail 신설** — 사용자 시각 디테일 게이트 (rice grain FINE / noodle THIN / syrup contained / no paper wrapper / scallion+shrimp embedded WITHIN batter / tofu fluffy irregular curds / LA cross-cut bone). G_food와 직교 critical 게이트, R2 평가 시 1:1 점검. **§6.4 Decisions Log 신설** — R2 reroll trigger 행 + 사용자 피드백 10건 verbatim + 패치 본문 fix 핵심 표 + main thread 실행 명령 (gpt-image-1 medium, 10장 × ~$0.042 = ~$0.42, ~3~5분, v2 출력 경로 R1 v1과 공존). v1.5는 prompts-library v1.4 / `tools/gen_food_anchors_m1.py` FOODS sync 완료 상태 전제.
- **2026-05-27 v1.4** (M1 음식 12 R1 평가 완료, supersedes v1.3) — `tools/gen_food_anchors_m1.py` (gpt-image-1 medium 1024×1024) batch 실행 결과 R1 평가 완료. **12/12 LOCK** 달성. §5.5.4 평가 표 pending → 12행 PASS로 모두 채움 (G1/G3/G4/G5/G6/G7/G_new/G_food 8 게이트 × 12 음식 = 96 셀 모두 PASS). risk top 5 (F-12/F-03/F-06/F-11/F-09) **5/5 LOCK** — prompts-library v1.3 §5.4 default 누수 % (Galbi 60%/Kimbap 70%/Corn Dog 80%/Japchae 70%/Kimchi Jjigae 50%) 모두 회피 검증. 부차 risk (F-05/F-07/F-10) 3/3 LOCK. §6.2 Decisions Log M1 R1 행 LOCK 12/12 결과 기록 + F-01 Ramyeon `FOOD_ANCHOR_FILE` 경로 기록 (M1 후반 ingredient/UI reference upload 시드). minor finding = bg 2종 mixed (cool sage 7장 + cream-white 5장) CONDITIONAL note. **M1 후반 sprint 진입 신호 = Yes**.
- **2026-05-27 v1.3** (M1 음식 12 평가 가이드 추가, supersedes v1.2) — prompts-library v1.3 / ai-session-kit v1.3 음식 12 anchor sync. **§5.5 음식 12 평가 가이드 신설** — 음식 anchor가 캐릭터/환경과 다른 점 (G2 chibi 비율 N/A / G6 W5·W6 가중치 ↑ / G_food 신설) 명시. §5.5.2 G_food PASS 기준 12 음식 각각 명세 (Japanese/Chinese/Western 누수 0건 + 한식 핵심 식별 시각 요소 100%). §5.5.3 Tier 1/2 시각 구분 단서 (T1 abundance 단순 / T2 abundance 풍성). §5.5.4 12 음식 평가 표 신설 (G_food 컬럼 추가, food_id 매핑). **§5.5.5 LOCK 조건**: 12 중 10 LOCK + F-01 anchor 시드 PASS + risk top 5 중 4 LOCK + T1 6 + T2 4 최소. F-01 FAIL 또는 risk top 5 중 3 이하 LOCK = FAIL/pm 에스컬레이션. §5.5.6 라운드 예산 사용자 R1 ~1.5~2.5h / R2 +30~60분 / R3 pm. §6 Decisions Log 분리 (§6.1 Week 1 / §6.2 M1 음식 12). §5 cut anim mini-게이트 M1 후반 placeholder로 위치 변경 (text 무변경).
- **2026-05-27 v1.2** (modern mobile casual sync, supersedes v1.1) — iter2 사용자 진단 "올드함" 반영, art-style-guide v1.2 sync. §1 평가 단위 무변경 (10 anchor + Step 0 후보 2). §2 G3 컬러 criteria 갱신 — 채도 75~85% → **80~90%** 상향 + warm/cool 균형 + slim outline 2~3px 명시. §2 G5 단순성 criteria 갱신 — Crossy Road fail-test → **Royal Match fail-test**, 베이지/scrapbook/storybook/kraft paper 배경 즉시 FAIL LOCK, soft 1-layer cel shading 허용 명시. §2 G6 W3 painterly 정의에 storybook/scrapbook 누수 추가. §2 **G_new 신설** = modern mobile casual 인상 평가 (dynamic pose + cool tone bg + 80~90% saturation + slim outline 4종 동시 충족 / Royal Match side-by-side test / Cookie Run 2021/Toca Boca/Toon Blast 톤 0). G_new는 G1과 함께 critical (G_new FAIL이면 종합 FAIL). §3 캐릭터/환경 평가 표에 G_new 컬럼 추가. §4 종합 LOCK 조건에 G_new 8/10 anchor 충족 조건 추가 (FAIL 3+ anchor면 전체 FAIL). §5 ADR-005 cut anim mini-게이트 무변경. §6 Decisions Log에 iter2 라운드 추가 (G5/G_new FAIL → v1.2 reset 트리거 superseded 표시 + iter3 pending).
- **2026-05-27 v1.1** (ChatGPT 영구 sync from MJ, supersedes v1.0) — art 도구 영구 변경 (사용자 confirm 2026-05-27). §1 평가 단위 "sref 후보 2" → **"subject anchor 후보 2"** 명칭 sync. §2 G1 PASS 기준 ChatGPT sref 부재 대비책 명시 (reference image upload + subject anchor 문장 + 같은 채팅 세션 follow-up 3축). §2 G6 약점 세분화 mascot 6항 / flat 10항(6a~6j) → **ChatGPT 약점 10항(W1~W10) 재구성**: W1 한글 텍스트 깨짐 Very High (CONDITIONAL default 후보정 default), W2 photoreal, W3 painterly, W4 손가락, W5 일본, W6 중국, W7 복잡 composition multi-character 신규, W8 자연어 prompt 길이 한계 신규, W9 reference 없이 캐릭터 일관성 lock 실패 Very High 신규 (sref 부재 대체), W10 anime girl + 정면 over-detail. CONDITIONAL/FAIL 정책 갱신 — W1만 CONDITIONAL default. §3 sref URL 컬럼 제거 → 파일 경로 + subject anchor 문장 + ChatGPT 세션 URL 컬럼 보강. §3.3 평가 표제 "sref 후보 평가" → **"Subject anchor 후보 평가"** 명칭 sync, "G1 일관성 시드로 적합" → "reference image style transfer test 1 PASS"로 평가 기준 재정의. §4 종합 LOCK 조건 "sref 2 PASS" → **"subject anchor reference image style transfer test 2 PASS"**. §4.3 Lock 후 의무 sref URL → 파일 경로 sync. §4.4 라운드 예산 사용자 R1 1.5~2.5h → ~1~1.5h sync (ai-session-kit v1.1 §7). §5 ADR-005 cut anim mini-게이트 ChatGPT 1 image per request 워크플로 + 같은 채팅 세션 follow-up sequence 일관성 lock 방식 추가. §6 Decisions Log 컬럼 "sref PASS" → "subject anchor PASS" sync.
- **2026-05-27 v1.0** (archived; MJ 기반) — scratch rewrite, hyper-casual flat. mascot 7항 게이트 → flat 톤 기준 재구성. **G5**: "mitten/eye/blush 마스코트 시그니처" → **"단순성 (디테일 최소, Crossy Road fail-test)"**. **G7**: "조명·시점 통일" → **"모바일 가독성 (256px 축소 test)"** (flat은 조명 표현 거의 없어 G7 의미 변경, 시점 통일은 G1로 흡수). **G6**: 약점 세분화를 mascot 6항(손가락/정면/텍스트/일본/중국/3D) → **flat 10항** (photoreal/painterly/texture/손가락/정면 over-detail/텍스트/일본/중국/anime/shape complex)로 확장 — flat 톤에서 가장 빈번한 누수 photoreal/painterly/texture 3종(6a/6b/6c)을 high freq로 표시. §4 종합 게이트(8 LOCK + sref 2 PASS) 무변경. §5 ADR-005 cut anim 추가 anchor 게이트 placeholder 신설 (M1 진입 시 정식화).
- **2026-05-24 v0.1** (archived; mascot 톤) — 초안. art-style-guide §10 게이트 7항을 anchor별 rubric 셀로 분해.
