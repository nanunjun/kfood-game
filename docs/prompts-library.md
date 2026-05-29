# Prompts Library — K-Food Master MVP

> 버전: **v1.13 (2026-05-28, M1 환경 BG-01~05 v4 image edit — v1.2 base + 지붕만 교체, frontal view, 5가게 구조 일관성, gpt-image-1 edit API 도입) — supersedes v1.12**
> 작성자: art-director
> 상위 문서: [`art-style-guide.md` v1.2](art-style-guide.md), [`ai-session-kit.md` v1.2](ai-session-kit.md), [`art-anchor-rubric.md` v1.13](art-anchor-rubric.md), [`decisions.md` ADR-003](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002), [`decisions.md` ADR-005](decisions.md#adr-005), [`art-workload-estimate.md` v4.1](art-workload-estimate.md)
> 본 문서 범위: Week 1 anchor lock 10장 (캐릭터 5 v1.2 lock candidate + **환경 5 v4 BG-01~05 image edit — v1.2 base PNG 입력 + 지붕만 교체, frontal view, 5가게 구조 일관성**) + **M1 sprint 음식 12 anchor (§5.1 full prompts, v1.3 신설~v1.10 R7 F-12 plated white plate)**. cut anim / 양친 reaction 6컷 / 재료 / UI / VFX는 M1 후반 / M2 (§5.5~§5.7 placeholder).
> 도구: **ChatGPT (GPT-4o image / DALL-E)** 영구 lock. **환경 5장 v4부터는 gpt-image-1 image edit API** (`client.images.edit(model="gpt-image-1", image=...)`) 도입 — prompt-only generation으로 v1.2 base 정확 재현 불가능했던 한계 극복.

> **v1.13 변경 (2026-05-28, M1 환경 BG-01~05 v4 image edit — v1.2 base + 지붕만 교체 + frontal view + 5가게 구조 일관성, supersedes v1.12)**: 사용자가 v1.12 v3 결과 (5장 batch generation, slight 7/8 perspective, 5가게 구조 inconsistent across shops) 시각 확인 후 폐기 + 새 접근 명시. 사용자 verbatim "**각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나...**". main thread 해석 = 3건 fix: (1) **5가게 구조 정확 일관성** — 지붕/기둥/카운터/frame 5가게 모두 정확히 동일, 카테고리별 display goods + signage icon만 다름 (v3는 prompt-only batch generation으로 carpenter 작업이 5가게마다 다르게 생성됨) / (2) **v1.2 base 정확 유지 + 지붕만 교체** — prompt-only generation은 v1.2 정확 재현 어려움, **gpt-image-1 image edit API**로 base image의 천막 부분만 교체 (다른 모든 요소 유지) / (3) **frontal view (frontal elevation)** — slight 7/8 perspective 폐기, v1.2 base가 frontal이었음. **§2.2 STYLE_SUFFIX_BG 무변경** (v3 STYLE_SUFFIX_BG_V3 유지) — v4는 STYLE_SUFFIX_BG suffix를 사용하지 않고 **image edit API용 별도 COMMON_EDIT_PROMPT**를 사용 (지붕 교체 단일 fix prompt). **§4 BG-01~05 본문 전면 재작성** — v3 prompt-only generation 본문은 §4.8 v1.12 v3 archive로 deprecated (사유: 5가게 구조 inconsistent + slight 7/8 perspective + 사용자 v3 폐기 verbatim). v4 본문은 image edit API approach 명시 (base image 경로 `assets-raw/week1-anchors/BG-XX_<name>_v2.png` + 공통 fix prompt + shop-specific 카테고리 명시 한 줄). **새 driver script `tools/edit_bg_anchors_v4.py` 신설** — `client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_EDIT_PROMPT + category, size="1024x1024", quality="medium", n=1)`. base image dimensions 사전 검증 + (필요 시) gpt-image-1 edit supported size (1024x1024 / 1536x1024 / 1024x1536)로 PIL resize fallback 포함. §0 anchor 표 BG-01~05 row v4 status 갱신 (v1.12 v3 deprecated → v4 pending image edit). 음식 12장 F-01~F-12 본문 무변경 (F-12는 v1.10 R7 plated white plate LOCK candidate 유지). 캐릭터 5장 CH-01~05 본문 무변경 (v1.2 lock candidate 유지).

> **v1.12 변경 (2026-05-28, M1 환경 BG-01~05 v3 minimal — v1.2 base 회복 + 천막→기와 지붕 단일 fix, supersedes v1.11)** (archived; v4 image edit로 supersede; 사유 — 5가게 구조 inconsistent + slight 7/8 perspective + prompt-only generation의 v1.2 base 재현 한계): 사용자가 v1.11 v2 (한옥 양식 풀세트 — 옹기 + lantern + 목조 한옥 frame + 처마 풀세트) 결과 시각 확인 후 **너무 많음** 진단 → v2 전면 폐기. 사용자 verbatim "**기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고**". 즉 v1.2 base (commit 7a6cffb 환경 5장)의 minimal feel 회복 + **천막(red/green striped awning) → 검정 기와 곡선 지붕 (curved black ceramic tile roof, 한옥 기와 eave 곡선)** 단일 fix만 적용. v1.2 base의 다른 모든 요소 (채소/meat/fish/곡식/sauce 카테고리 시그니처 + 작은 가게 카운터 + BG-01의 좌측 옹기 2개 + BG-05의 sauce 항아리 4개 + 고추 hanging + icon+영어 minimal signage + Cool Sage `#C8D5C0` bg + modern saturated 톤 + slim outline 2-3px) **무변경 유지**. v2의 추가 요소 (5가게 공통 옹기 prominent + 5가게 공통 hanging lantern + 목조 한옥 frame 양쪽 기둥 + 처마 깊은 overhang + 와당 풀세트) **모두 폐기**. **§2.2 STYLE_SUFFIX_BG 전면 재작성** = v1.12 STYLE_SUFFIX_BG_V3 (기와 지붕 단일 layer + v1.2 base 가게 카운터 + icon-first 영어 minimal + Cool Sage `#C8D5C0` solid bg + 추가 한옥 풀세트/lantern/extra onggi 명시 회피). 5가게 영어 signage v1.2 base 회복 = "PRODUCE" / "BUTCHER" / "SEAFOOD" / "GRAIN" / "SAUCES". §4 BG-01~05 본문 v3로 전면 재작성. 기존 v1.11 v2 본문은 §4.7 v1.11 v2 archive 절 (deprecated, 2026-05-28)에 보존. 기존 v1.2 archive (§4.6) 무변경. §0 anchor 표 BG-01~05 row v3 status 갱신 (v1.11 v2 deprecated → v3 pending). 음식 12장 F-01~F-12 본문 무변경 (F-12는 v1.10 R7 plated white plate LOCK candidate 유지). 캐릭터 5장 CH-01~05 본문 무변경 (v1.2 lock candidate 유지).

> **v1.11 변경 (2026-05-28, M1 환경 BG-01~05 v2 갱신 — 한옥 양식 + 기와 지붕 + 처마 + 옹기 + lantern + icon+영어 minimal signage 5건 fix, supersedes v1.10)** (archived; v3 minimal로 supersede): 사용자가 정통 한식 가게 reference image (경주 참기름 방앗간 한옥 양식, 1963년) 제공 + 명시: "**한식 정통 요소만 차용 + 기존 lock 유지**". main thread 시각 분석으로 차용할 5건 (한옥 양식 / 검정 기와 지붕 + 처마 / 큰 나무 간판 / 옹기 항아리 / hanging lantern) + 회피할 3건 (베이지 배경 / 한글 dominant signage / warm storybook tone) 추출 → 기존 V2 환경 anchor (v1.2 lock candidate, 2026-05-27 commit 7a6cffb) **5장 전부 invalidate** (캐릭터 5장은 무영향). BG-01~05 본문 v2.0으로 전면 재작성: 한식 정통 요소 5건 (한옥 frame + 검정 기와 + 처마 + 옹기 + lantern) 통합. **(2026-05-28 v1.12 추기: v2 결과 시각 확인 후 사용자가 "너무 많음" 진단 + verbatim "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고" 명시 → v1.11 v2 전면 폐기. v1.12 v3 minimal로 supersede)**

> **v1.9 변경 (2026-05-28, M1 음식 F-12 R7 reroll LA-cut form + cross-section bones + green scallion + wire mesh + 7/8 perspective 5건 fix, supersedes v1.8)** (archived): R6 v6 결과 시각 확인 후 사용자가 **또 다른 reference image** (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length) 제시 + verbatim "이걸로 해줘" 명시. R6 v6의 small square pieces grid form + SHORT EDGE long single bone + chopped minced garlic dots 패턴이 새 reference와 어긋남 진단 → R6 v6 = **deprecated**. R7 v7 = **사용자 새 reference image 시각 요소 1:1 매칭으로 5건 전면 fix**:
> - **Fix 1 — meat form 전면 교체 (small square pieces grid → LA-cut long strips)**: v6 `multiple small square-shaped meat pieces (12~16 pieces, each 3-4cm × 3-4cm × 0.5-0.8cm thick) arranged in grid pattern (3-4 rows × 4 columns)` 폐기 → v7 `4-6 large rectangular LA-style meat strips (each approximately 18-25cm long × 8-12cm wide × 0.5-0.8cm thick) arranged side by side parallel on the grill grate (slight natural overlap or aligned, NOT perfectly geometric grid)`. 정통 LA갈비 cross-cut form 회귀.
> - **Fix 2 — bone form 완전 재정의 (long bone at short edge → 3-4 cross-section discs along each strip's length, CRITICAL signature)**: v6 `SINGLE LONG WHITE RIB BONE (12-15cm) laid horizontally alongside meat grid on ONE SHORT EDGE side` 폐기 → v7 `Each meat strip has 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS (each ~1.5-2cm diameter, cream-white color) visible along its LENGTH — these are LA-style cross-cut bones (the bones are cut perpendicular to their original direction, so each cross-section appears as a small round white disc along the strip). The bones are EVENLY SPACED along the length of each strip (approximately 3-5cm apart). This is the LA-Galbi traditional cut signature.` negative 강화 `NOT a single long bone alongside the meat (R6 deprecated), NOT bone discs partially embedded along TOP LONG EDGE only (R5 deprecated), NOT one big bone at one end (R3 deprecated) — the bones are MULTIPLE SMALL ROUND DISCS appearing across each strip's length, evenly spaced, the LA cross-cut signature`.
> - **Fix 3 — garnish 변경 (chopped minced garlic → chopped green scallion rounds)**: v6 `finely CHOPPED MINCED GARLIC bits scattered all over meat pieces (small yellowish-white garlic granules)` 폐기 → v7 `Generous scattering of CHOPPED GREEN SCALLION ROUNDS (송송 sliced spring onion / 대파, each round ~1-3mm thick disc, bright green color) scattered across the meat strips as the hero garnish. Plus a light sprinkle of white sesame seeds as additional accent.` negative `NOT chopped minced garlic dots (R6 deprecated), NOT thin garlic slices, NOT whole garlic cloves, NOT only sesame seeds — chopped green scallion rounds are the hero garnish`.
> - **Fix 4 — plate/grill context 변경 (cast iron plate → round metallic wire mesh grill grate)**: v6 `On a clean black cast iron grill plate (or copper grill grate or white plate)` 폐기 → v7 `Sitting on a ROUND METALLIC WIRE MESH GRILL GRATE (silver-gray wire grate, the traditional Korean BBQ tabletop grill) — the wire mesh pattern is visible underneath/around the meat strips. Optional: subtle hint of red-orange glow underneath the grate suggesting hot coals (a touch of warm fire atmosphere, not dominant).` negative `NOT a flat solid plate (v4/v5/v6 polished but deprecated for this LA-galbi form), NOT a white ceramic plate, NOT a black cast iron flat pan — the grill grate (wire mesh) is the proper context for LA-galbi`.
> - **Fix 5 — view angle 변경 (top-down → slight 7/8 perspective)**: v6 `top-down view` 폐기 → v7 `slight 7/8 perspective view (mostly top-down but slightly angled to show meat thickness side profile + grill grate depth) — the slight 7/8 angle reveals the THIN slice thickness (0.5-0.8cm) from the side, confirming the paper-thin slice appearance`.
>
> v6 LOCK 유지 요소 4건 (변경 금지): (1) **well-grilled caramelized dark brown + glossy glaze sheen** — LOCK / (2) **char marks visible on surface from grill** — LOCK (LA-cut form에서는 score marks가 아닌 char marks dominant) / (3) **thin slice 0.5-0.8cm thickness** — LOCK / (4) **cross-cultural negative** (yakiniku/American BBQ/char siu/steak/raw) — LOCK + 추가 `NOT v6 small square pieces grid form (deprecated for this LA-galbi reference)`.
>
> **부분 폐기 — 칼집 (knife score marks)**: v3~v6 핵심 LOCK 시그니처였으나, R7 reference에서는 cross-cut bones이 dominant signature이고 score marks는 reference에 명확히 보이지 않음. **칼집은 optional로 격하** (만약 표면에 보이면 OK, 없어도 PASS). LA-cut form의 시그니처는 cross-cut bones이지 score marks가 아님.
>
> F-01~F-11 본문 무변경 (각 LOCK status 유지). §5.2 F-12 본문만 v7로 전면 교체. v6 본문은 §5.2 F-12 archive `R6 v6 (deprecated, 2026-05-28)`에 보존 (R3/R4/R5/R6 모두 archive 보존 — 사용자 시각 의도 진화 기록). 식별 핵심 시각 요소 7개 갱신 (LA-cut long strip / parallel strips / **3-4 bone discs along length CRITICAL** / thin / well-grilled brown + char marks / green scallion rounds / wire mesh grate). reroll trigger 7종 갱신.

> **v1.8 변경 (2026-05-28, M1 음식 F-12 R6 reroll form 전면 교체 + thickness 더 얇게 + bone short edge + 마늘 dots 4건 fix, supersedes v1.7)** (archived; F-12는 R7 v1.9로 supersede): R5 v5 결과 시각 확인 후 사용자가 **새 reference image** (정통 한식 갈비구이 — 가위로 자른 후의 eating-style 상태)를 제시하며 시각 의도 재정의 → R5 v5의 4 long elongated strip + bone along TOP LONG EDGE 패턴이 **새 reference와 어긋남** 진단. R5 v5 = **deprecated**. R6 v6 = **사용자 새 reference image 시각 요소 1:1 매칭으로 4건 전면 fix**:
> - **Fix 1 — meat form 전면 교체 (long strips → square pieces)**: v5 `4 thin elongated rectangular meat strips arranged in a strictly parallel row, each strip ~12-15cm long × 3cm wide × 0.7-1cm thick` 묘사 폐기 → v6 `multiple small square-shaped grilled meat pieces (12~16 pieces total, each approximately 3-4cm × 3-4cm square, very thin 0.5-0.8cm thick) arranged in a grid pattern (3-4 rows × 4 columns) on the plate — this is the Korean galbi-gui eating style where the original long meat strip with bone has been CUT WITH KITCHEN SCISSORS at the table into smaller square pieces for eating`. 한식 갈비구이의 eating-style state (가위 cut 후) 명확화.
> - **Fix 2 — thickness 더 얇게**: v5 `0.7-1cm thick (very thin slice, like 6-8mm)` → v6 `0.5-0.8cm thick (5-8mm, very thin slice — significantly thinner than v5, paper-thin appearance but still substantial enough to recognize as meat)`. 사용자 명시 "고기 자체도 훨씬 얇게 되어 있고".
> - **Fix 3 — bone 위치 완전 재정의 (TOP LONG EDGE → SHORT EDGE long bone)**: v5 "bone discs visible along the TOP LONG EDGE of each meat strip" (각 strip마다 small bone discs partially embedded) 묘사 폐기 → v6 `On ONE SHORT EDGE SIDE of the meat grid (the side edge of the plate, perpendicular to the rows of meat pieces), a single LONG WHITE RIB BONE is laid horizontally (approximately 12-15cm long × 1-1.5cm wide × 1-1.5cm tall, cream-white color). This bone was originally attached to the meat strip BEFORE it was cut with scissors — after cutting the strip into smaller square pieces, the bone remains laying alongside the grid of meat pieces on the short edge side. The bone is a long single piece, NOT multiple small discs, NOT embedded into any meat piece's edge.` 사용자 명시 "Short Edge쪽에 뼈가 길게 있잖어". negative `NOT bone discs along the top edge of each piece (v5 deprecated), NOT bone at the end of strips (v3 deprecated), NOT bones between pieces — the bone is a SINGLE long piece laying alongside the meat grid on ONE SHORT EDGE side of the arrangement`.
> - **Fix 4 — garnish 잘게 다진 마늘 강조**: v5 `Generous sprinkle of white sesame seeds across the strips. 1-2 thin garlic slices placed on top or beside the meat as accent` → v6 `Generous sprinkle of finely CHOPPED MINCED GARLIC bits scattered all over the meat pieces (small yellowish-white garlic granules visible on top of each meat piece, a signature Korean galbi-gui garnish after grilling). Optional: a light sesame seed sprinkle`. 사용자 새 reference 시각 시그니처 = 잘게 다진 마늘 dots.
>
> v5 유지 요소 5건 (변경 금지): (1) **칼집 (3-5 horizontal score marks)** — 각 small piece에도 horizontal score marks visible (원래 strip의 score marks가 cut 후에도 남음) — LOCK 시그니처 / (2) **strictly parallel/aligned arrangement** — pieces가 grid pattern으로 같은 방향 정렬 — LOCK / (3) **well-grilled caramelized dark brown + glossy glaze sheen** — LOCK (raw 누수 회피) / (4) **plate context** (검정 cast iron grill plate or copper grill grate or 흰 plate) — LOCK / (5) **cross-cultural negative** (yakiniku/American BBQ/char siu/steak/raw/LA-cut) — LOCK 유지 + 추가 `NOT uncut long strips (v3/v5 form polished but obsolete)`.
>
> F-01~F-11 본문 무변경 (각 LOCK status 유지). §5.2 F-12 본문만 v6로 전면 교체 (form + thickness + bone 위치 + garnish 4건 fix). v5 본문은 §5.2 F-12 archive `R5 v5 (deprecated, 2026-05-28)`에 보존. 식별 핵심 시각 요소 6→7개로 갱신 (square form + grid pattern + thin 5-8mm + long bone at short edge + 칼집 maintained + caramelized brown + 마늘 dots). reroll trigger 7종 신설 (form 폐기 / thickness 0.5-0.8cm / bone short edge long piece / 마늘 dots / grid pattern / 칼집 maintained / 구운 색). §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.

> **v1.7 변경 (2026-05-28, M1 음식 F-12 R5 reroll thickness + bone 위치 2건 fix, supersedes v1.6)** (archived; F-12는 R6 v1.8로 supersede): R4 v4 결과 시각 확인 후 사용자가 **2건 추가 fix 요청**:
> - **Fix 1 — thickness 더 얇게**: v4 `1-1.5cm thick` → v5 `0.7-1cm thick (very thin slice, like 6-8mm)`. 사용자 명시 "고기가 일단 더 얇아야 함". `THIN slice appearance — significantly thinner than a steak, like a Korean galbi-gui properly butchered cut` 강조 + negative `NOT a thick 1.5cm+ slab, NOT steak thickness`.
> - **Fix 2 — bone 위치 재정의**: 사용자 명시 "긴쪽의 밑쪽이 아니라 윗부분의 사이드로 보여야함" → v4 "small bone discs nestled between the strips at the plate edges" (strip 양 끝/short end) 묘사를 폐기. v5는 **bone discs visible along the TOP LONG EDGE of each meat strip** (partially embedded into the upper long side of the meat strip — 정통 한식 갈비 손질에서 bone이 strip의 한 long side에 attached 형태). negative `NOT bones at the short ends of strips, NOT bones at the bottom long edge, NOT bones between strips at the plate gaps`.
>
> v4 유지 요소 6건 (변경 금지): (1) 칼집 (3-5 deep horizontal knife cuts perpendicular to length) — LOCK 시그니처 / (2) strictly parallel arrangement (4 strips side by side, NOT overlapping) — LOCK / (3) well-grilled caramelized brown + glaze sheen, NOT raw — LOCK / (4) strip 길이 12-15cm — LOCK / (5) garnish (깨 sprinkle + 마늘 slice + 상추 ssam side) — LOCK / (6) plate context (black cast iron grill plate or white plate) — LOCK. 4 strips count + cross-cultural negative (yakiniku/American BBQ/char siu/steak/raw/LA-cut) 무변경.
>
> F-01~F-11 본문 무변경 (각 LOCK status 유지). §5.2 F-12 본문만 v5로 교체 (thickness/bone 위치 2 line 패치). v4 본문은 §5.2 F-12 archive `R4 v4 (deprecated)`에 보존. reroll trigger 갱신 (thickness 0.7-1cm thin / bone TOP LONG EDGE 명확 항목 추가). §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.

> **v1.6 변경 (2026-05-28, M1 음식 F-12 R4 reroll 본문 전면 재작성, supersedes v1.5)** (archived; F-12는 R5 v1.7로 supersede): R3 v3 결과 시각 확인 후 사용자가 정통 한식 갈비구이 reference image를 직접 보여주며 시각 의도 명확화 → **R3 "끝에 single bone protrudes" 묘사가 사용자 reference와 어긋남** 진단. R3 v3 = **deprecated**. R4 v4 = **사용자 reference image 6 시각 요소 1:1 매칭 prompt 전면 재작성**:
> - **칼집 (knife score marks across meat surface)** — 가장 중요한 시그니처. 각 strip 표면에 가로방향 3-5 deep horizontal knife cuts (한국 갈비구이 정통 손질 기법, 균일 구이 + 양념 흡수 + 식감). R3에는 0건이었음.
> - **thin elongated parallel meat strips** — 4 strips × ~12-15cm long × ~3cm wide × ~1-1.5cm thick, **strictly parallel arrangement** (서로 나란히, NOT overlapping, NOT angled).
> - **작은 흰 bone cross-section discs** — strip edge 사이에 small round white bone discs visible (LA갈비 + 칼집 결합 형식). R3의 "single bone at one end" 묘사 완전 폐기.
> - **well-grilled brown char + caramelized glaze sheen** — raw red-pink 아닌 구워진 색 (rich caramelized dark brown + soy-pear-garlic marinade glossy glaze).
> - **grill marks** — 표면에 dark char lines (cooked from grill grate).
> - **plating context** — clean black cast iron grill plate 또는 white plate (grill grate 자체는 표현 안 함, plated hero shot).
>
> F-01~F-11 본문 무변경 (각 LOCK status 유지). §5.2 F-12 본문만 v4로 전면 교체. R3 v3 본문은 §5.2 F-12 내부 archive 절(`R3 v3 (deprecated)`)로 이동 보존. reroll trigger 절 갱신 (칼집 / parallel / 구운 색 / small bone discs 점검 항목). §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.

> **v1.5 변경 (2026-05-27, M1 음식 R3 reroll 6건 본문 패치, supersedes v1.4)** (archived; F-12는 R4 v1.6로 supersede): R2 v2 결과 시각 확인 후 사용자 selective 피드백 6건 raise → 본문 fix. **F-07/F-08/F-10/F-11 4장은 R2 LOCK candidate 유지 (사용자 silent ACK), F-04/F-09 2장은 R1 LOCK 유지**. R3 패치 대상 6건:
> - **F-01 Ramyeon**: **v1 base 회복** — v1 prompt 본문 그대로 복원 + 면 묘사만 `THIN delicate yellow wavy curly egg noodles`로 통일 (v2의 "Korean instant ramyeon noodle thickness" 수식 제거). negative `NOT thick chunky udon-style strands` 한 줄만 보존.
> - **F-02 Hotteok**: v2 base 유지 (contained filling) + **표면 syrup drizzle 추가** (small drizzle of glossy dark brown sugar syrup gently swirled on top as a finishing touch, like pancake topping, NOT a flood, NOT pouring from inside). negative에 `syrup on top is okay as a topping drizzle (separate from contained filling)` 명시.
> - **F-03 Kimbap**: **v1 base 회복** — v1 prompt 본문 복원 + 밥 묘사만 `white rice with FINE small grains (Korean short-grain, tight uniform field, NOT chunky oversized beads)` fix.
> - **F-05 Kimchi Fried Rice**: **v1 base 회복** — v1 prompt 본문 복원 + 동일 rice grain fix.
> - **F-06 Korean Corn Dog**: v2 base + 베어 문 단면 cross-section 강화 (4요소 명확 visible): (1) brown sausage core at center, (2) yellow mozzarella cheese filling with 2-3 stretchy strands, (3) golden panko crumb crust outside, (4) ketchup+mustard zigzag on top. negative 추가 `NO missing sausage core, NO cheese-only filling without sausage, NO ambiguous interior`.
> - **F-12 Galbi-gui**: **전면 재작성 (정통 한식, LA-cut 폐기)** — 3-4 thin elongated meat strips (5-7cm long, 1-1.5cm thick), **SHORT WHITE RIB BONE protrudes 1-2cm at ONE END of each strip** (traditional Korean galbi cut, bone-in at one end, NOT LA cross-cut with multiple bone discs, NOT American slab). natural overlapping plating + soy-pear-garlic glaze + grill marks + sesame + 상추 ssam.
>
> 본 v1.5는 §5.2 F-01/F-02/F-03/F-05/F-06/F-12 본문(```...```)만 패치. F-07/F-08/F-10/F-11 v2 본문 유지 (R2 LOCK candidate). F-04/F-09 R1 본문 유지 (R1 LOCK). §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.

> **v1.4 변경 (2026-05-27, M1 음식 R2 reroll 10건 본문 패치)** (archived; R3로 부분 supersede): R1 v1 결과 12장 시각 확인 후 사용자 구체 피드백 10건 raise → 본문 fix. **F-04 떡볶이 / F-09 김치찌개 2장은 R1 LOCK 유지** (본문 무변경). 패치 대상 10건:
> - **F-01 Ramyeon**: 면 두께 `THIN delicate` + negative "NOT thick chunky udon-style strands"
> - **F-02 Hotteok**: 시럽 흘러나오는 양 대폭 축소 → `a tiny hint barely peeks through a small slit, mostly contained inside the disc` + negative "NO excessive syrup overflow, NO molten lava-like outpour"
> - **F-03 Kimbap**: 밥알 크기 축소 → `FINE small rice grains (Korean short-grain, individual grains barely visible)` + negative
> - **F-05 Kimchi Fried Rice**: 밥알 크기 축소 (동일 fix)
> - **F-06 Korean Corn Dog**: 종이 받침 제거 → `held cleanly by the stick with no paper wrapper, clean composition` + negative "NO awkward paper plate"
> - **F-07 Haemul Pajeon**: 파/새우가 반죽 위가 아닌 반죽 안에 섞임 → `mixed into and partially submerged within the golden batter, BAKED INTO the pancake, partially visible above the surface but mostly embedded`
> - **F-08 Bibimbap**: 밥알 크기 축소 (동일 fix)
> - **F-10 Sundubu Jjigae**: 두부 모양 재정의 → `mound of soft tofu broken into irregular cloud-like fluffy white curds (like soft cottage cheese clumps or torn fluffy clouds, organic uneven shapes), NOT smooth puree, NOT firm cubes, NOT mashed paste`
> - **F-11 Japchae**: 당면 두께 `THIN delicate translucent` + negative "NOT thick chunky strands"
> - **F-12 Galbi-gui**: **전면 재작성** — LA-style cross-cut strip (3~4cm thick × 8~10cm long) + 각 piece에 **2-3 small round white bone cross-sections along its length** (the iconic LA Galbi cut signature) + natural plating arrangement + negative "NOT a single thick rib slab, NOT one giant bone, NOT bone-on-side American-style ribs"
>
> 본 v1.4는 §5.2 본문(```...```)만 패치. §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.

> **v1.3 변경 (2026-05-27, M1 음식 12 anchor 추가)** (archived): M1 sprint 진입. §5.1 음식 12 placeholder → **full prompts**로 확장 (F-01~F-12). 각 음식 prompt = English title (icon-first English minimal i18n LOCK) + DALL-E 3 자연어 visual breakdown + 식별 핵심 시각 요소 + DALL-E 3 약점 회피 노트 (한식↔일/중식 risk 별도 명시) + Tier 1/2 시각 구분 단서 (1인분 단순 / 2인분 풍성) + reroll 트리거. **§2.5 STYLE_SUFFIX_FOOD 신설** — 음식 카드 공통 suffix (square 1:1, top-down or 7/8, cool sage `#C8D5C0` 또는 cream-white `#FAFAFA` bg, modern flat clean, plated dish hero shot, no characters). 생성 순서 = Tier 1 단순한 것부터 (라면 → 김치찌개 ... 갈비구이 마지막). anchor cross-호환 = §0/§0.1 캐릭터·환경 anchor와 동일 ChatGPT 도구 + style suffix 정합. §0 anchor 표에 F-01~F-12 행 추가 (pending). 캐릭터 5 + 환경 5 prompt 무변경 (§3·§4 v1.2 lock 유지).

> **v1.2 변경 (2026-05-27, modern mobile casual reset)** (archived): iter2 사용자 진단 "올드함" 반영. §2 STYLE_SUFFIX_BG / STYLE_SUFFIX_CHAR 전면 재작성. §3·§4 캐릭터/환경 prompts v1.2 modern saturated/clean으로 갱신.

> **v1.1 변경 (2026-05-27)** (archived): MJ → ChatGPT 영구 변경. 자연어 prompt + "Important: avoid ..." negative + follow-up 대화형 reroll로 통일.

---

## 0. Anchor Lock 표 (게이트 통과 후 채움)

> Week 1 게이트 PASS 후 **모든 M1 sprint 자산은 본 표의 anchor image 파일을 reference upload + subject anchor 문장 동일 복사**로 운영.

| ID | Subject | 파일 경로 | ChatGPT 세션 URL | subject anchor 문장 | Status |
|----|---------|----------|------------------|---------------------|--------|
| CH-01 | 주인공 (base) | TBD | TBD | TBD | pending |
| CH-02 | 어머니 | TBD | TBD | TBD | pending |
| CH-03 | 아버지 | TBD | TBD | TBD | pending |
| CH-04 | 주인공 Happy (★3 reaction) | TBD | TBD | TBD | pending |
| CH-05 | 주인공 Subtle (★1·★2 reaction) | TBD | TBD | TBD | pending |
| BG-01 | 청과상 🥬 (v4 image edit, v1.2 base + 지붕만 교체) | `assets-raw/week1-anchors/BG-01_produce_v2.png` (base) | gpt-image-1 edit API (no chat session) | image edit COMMON_EDIT_PROMPT + "Korean greengrocer / produce shop (PRODUCE signage with cabbage icon)" | **v1.2 invalidated → v2 deprecated → v3 deprecated (5가게 구조 inconsistent + 7/8 perspective) → v4 pending (gpt-image-1 image edit + frontal view)** |
| BG-02 | 정육점 🥩 (v4 image edit) | `assets-raw/week1-anchors/BG-02_butcher_v2.png` (base) | gpt-image-1 edit API | image edit COMMON_EDIT_PROMPT + "Korean butcher shop (BUTCHER signage with meat icon)" | **v1.2 invalidated → v2 deprecated → v3 deprecated → v4 pending (image edit)** |
| BG-03 | 어물전 🐟 (v4 image edit) | `assets-raw/week1-anchors/BG-03_seafood_v2.png` (base) | gpt-image-1 edit API | image edit COMMON_EDIT_PROMPT + "Korean seafood shop (SEAFOOD signage with fish icon)" | **v1.2 invalidated → v2 deprecated → v3 deprecated → v4 pending (image edit)** |
| BG-04 | 곡물상 🌾 (v4 image edit) | `assets-raw/week1-anchors/BG-04_grain_v2.png` (base) | gpt-image-1 edit API | image edit COMMON_EDIT_PROMPT + "Korean grain shop (GRAIN signage with grain sack icon)" | **v1.2 invalidated → v2 deprecated → v3 deprecated → v4 pending (image edit)** |
| BG-05 | 잡화점 🫙 (v4 image edit, sauces 시그니처) | `assets-raw/week1-anchors/BG-05_sundry_v2.png` (base) | gpt-image-1 edit API | image edit COMMON_EDIT_PROMPT + "Korean sauces/seasoning shop (SAUCES signage with bottle/jar icon)" | **v1.2 invalidated → v2 deprecated → v3 deprecated → v4 pending (image edit)** |
| F-01 | Ramyeon (라면, T1) | TBD | TBD | TBD | pending M1 |
| F-02 | Hotteok (호떡, T1) | TBD | TBD | TBD | pending M1 |
| F-03 | Kimbap (김밥, T1) | TBD | TBD | TBD | pending M1 |
| F-04 | Tteokbokki (떡볶이, T1) | TBD | TBD | TBD | pending M1 |
| F-05 | Kimchi Fried Rice (김치볶음밥, T1) | TBD | TBD | TBD | pending M1 |
| F-06 | Korean Corn Dog (한국식 콘도그, T1) | TBD | TBD | TBD | pending M1 |
| F-07 | Haemul Pajeon (해물파전, T1) | TBD | TBD | TBD | pending M1 |
| F-08 | Bibimbap (비빔밥, T2) | TBD | TBD | TBD | pending M1 |
| F-09 | Kimchi Jjigae (김치찌개, T2) | TBD | TBD | TBD | pending M1 |
| F-10 | Sundubu Jjigae (순두부찌개, T2) | TBD | TBD | TBD | pending M1 |
| F-11 | Japchae (잡채, T2) | TBD | TBD | TBD | pending M1 |
| F-12 | Galbi-gui (갈비구이, T2) | TBD | TBD | TBD | pending M1 |

### 0.1 ChatGPT subject anchor 운영 (sref 대체 메커니즘)

> ChatGPT는 MJ `--sref`/`--cref` 같은 explicit lock 메커니즘이 없다. 대신 **3축 운영**으로 일관성 lock:
>
> 1. **Subject anchor 단어 동일 유지** (필수): 캐릭터/환경 핵심 description을 4 variant prompt에서 **동일 단어 sentence로 그대로 복사**. 예: 주인공은 모든 prompt에 `"young Korean cooking character wearing beige apron over orange hoodie, two small black dot eyes, small arc smile, mitten hands"` 한 문장 동일 복사.
> 2. **Reference image upload** (선택, 강력): Step 0 lock anchor를 ChatGPT에 첨부 → "이 이미지와 같은 스타일·outline·features로 [새 subject]를 그려줘" 명령. style transfer 정확도가 MJ sref 대비 약간 낮으나 충분.
> 3. **같은 채팅 세션 안 follow-up** (보조): CH-01 생성 직후 같은 세션에서 CH-02~05 follow-up. ChatGPT는 세션 context로 직전 image 스타일을 일부 기억한다 (세션 전환 시 손실).

| Anchor 시드 | 결정 위치 (Step 0) | 적용 대상 anchor | 운영 방식 |
|------------|------------------|----------------|---------|
| `CHAR_ANCHOR_FILE` | Step 0a — 주인공 best image | CH-01, CH-02, CH-03, CH-04, CH-05 | (1) subject anchor 문장 동일 + (2) Step 0a image reference upload + (3) 같은 채팅 세션 follow-up |
| `BG_ANCHOR_FILE` | Step 0b — 청과상 best image | BG-01, BG-02, BG-03, BG-04, BG-05 | 동일 |

**원칙**:
- 한 번 lock한 anchor file은 sprint 종료까지 변경 금지 (변경 시 pm 승인 필수)
- 모델 선택 param 없음 (ChatGPT 단일 model 내부 자동)
- M1 sprint 모든 파생 자산(cut anim, 음식 카드, reaction variant)도 본 anchor file reference upload + subject anchor 문장 의무 사용

### 0.2 사용자 결과 인계 schema

> 사용자가 ChatGPT 세션 종료 후 art-director에게 결과를 들고 올 때 본 schema로 묶어 전달.

```
Anchor ID: <CH-01 | CH-02 | ... | BG-05 | STEP-0a | STEP-0b>
ChatGPT 세션 URL: <chat.openai.com/c/... 또는 share link>
이미지 파일 경로: <C:\Projects\kfood-game\assets-raw\2026-05-2x_CH-01_v1.png>
subject anchor 문장 (실제 prompt에 사용한 한 줄): <"young Korean cooking character wearing beige apron over orange hoodie, ...">
Reference image upload 사용 여부: <yes (Step 0a 파일 첨부) | no (text-only prompt)>
Round: <R1 | R2 | R3>
follow-up 횟수 (reroll): <0 | 1 | 2>
사용자 1차 평가 메모 (선택): <자유 메모>
```

art-director는 위 schema를 받아 [`art-anchor-rubric.md`](art-anchor-rubric.md) §3 표를 채워 LOCK/CONDITIONAL/FAIL 판정.

---

## 1. Model 선택 정책 (ChatGPT 단일 model)

### 1.1 결론

- **캐릭터 5장 (CH-01~05)**: ChatGPT (GPT-4o image / DALL-E)
- **환경 5장 (BG-01~05)**: ChatGPT (GPT-4o image / DALL-E)

> ChatGPT는 내부 모델 선택 param 없음 (자동). MJ v1.0의 v6.1 vs niji 6 dual model 운영 → ChatGPT 단일 model 통일로 sref cross-호환·합성 톤 차이 risk 0 (도구 특성상 자동 달성).

### 1.2 ChatGPT default 누수 차단 (필수 negative)

모든 prompt 끝에 다음 "Important: avoid ..." 필수:

```
Important: avoid realistic or photorealistic rendering, 3D render, octane or unreal engine,
any texture, noise, grain, painterly or hand-painted feel, watercolor,
gradient mesh, complex multi-layer cel shading, hyperdetailed elements,
cinematic or gritty tones, golden hour or dramatic lighting,
anime girl, manga, big sparkly eyes, school uniform, fanservice or sexy elements,
Japanese (kimono, tokyo, sushi, fuji, noren), Chinese (qipao, blue-and-white porcelain, chinese lantern).
```

---

## 2. 공통 프롬프트 구조 & Suffix

### 2.1 프롬프트 구조 (모든 anchor 공통, ChatGPT 자연어)

```
[Subject 자연어 description]
+ [Style 자연어 단어 (flat 2D illustration, hyper-casual ...)]
+ [Composition (square 1:1 format / wide 16:9 landscape)]
+ [Surface (single color fill, bold outline ...)]
+ [Important: avoid ...]
```

### 2.2 공통 Suffix — **환경 5장 (BG-01~05, v1.12 v3 minimal: v1.2 base + 기와 지붕)**

모든 환경 prompt 끝에 동일하게 부착. **v1.12 v3 변경 핵심**: v1.11 v2의 한옥 풀세트 (옹기 5가게 prominent + lantern 5가게 양쪽 + 목조 한옥 frame + 깊은 처마) 전면 폐기. **v1.2 base (commit 7a6cffb)의 minimal feel 회복** + **천막 → 검정 기와 곡선 지붕 단일 fix만 적용**. v1.2 LOCK 유지 = Cool Sage `#C8D5C0` bg / icon+영어 minimal signage / 카테고리 시그니처 / modern saturated 톤 / slim outline 2-3px / no people.

```
[STYLE_SUFFIX_BG]
Format: wide 16:9 landscape.
View: slight three-quarter angle (just a touch of perspective for a game environment feel,
NOT strict isometric, NOT a flat front elevation — keep the storefront friendly and approachable).
Style: modern mobile casual game art, clean 2D illustration in Royal Match (Dream Games 2021)
aesthetic applied to a friendly Korean traditional market shop interpreted with modern flat clean tone.

ROOF (single fix from v1.2 base):
- The shop has a CURVED BLACK CERAMIC TILE ROOF above the shop front (Korean traditional hanok
  기와 eave roof) — a short, simple curved tile pattern roof, dark slate gray to black single fill
  (#2D2D33 or similar dark slate), with the signature gently upward-curving eave silhouette at the
  corners (classic Korean hanok 처마 곡선). Optional: 2-3 small white circular eave-end tile caps
  (와당) along the eave tips as subtle accent.
- The roof is a SINGLE simple layer sitting on top of the shop front (NOT a full hanok structure
  with vertical wooden posts on both sides, NOT a deep eave overhang, NOT a full traditional
  architectural frame — just the tile roof itself as the topmost band of the shop front).
- ABSOLUTELY NO striped awning, NO tarp canopy, NO red and green stripes, NO tent canopy,
  NO Italian flag stripes, NO market awning of any kind. The roof completely REPLACES any awning.
- NOT a Chinese pagoda multi-tier sharp upturned corner roof, NOT a Japanese irimoya hip-and-gable.

SHOP FRONT (v1.2 base, unchanged):
- A simple wooden shop counter / small storefront stall with warm brown wood (#A67049 single fill,
  slim grain line accent 1-2 only — NO heavy realistic wood texture). The shop front is small and
  approachable, like a friendly stall in a traditional Korean market.
- A small rectangular wooden signboard sits at the top of the shop front (below the tile roof,
  or integrated into the counter top). ICON-FIRST signage: a LARGE simple flat shop-category icon
  (~60-70% of signboard area, single color, flat geometric shape) + below the icon, a SHORT English
  minimal text label (1-2 words, ~20-25% area, simple sans-serif, all-caps, legible). Absolutely
  NO Korean text (한글), NO Chinese characters (한자), NO Japanese characters (kana/kanji),
  NO sub-text in any non-English language.

CATEGORY SIGNATURE (per shop, see §4 BG-XX detail):
- Each of the 5 shops keeps its v1.2 base category signature (1-2 large simple icons, signature
  color: Cabbage Green / Gochu Red / Sea Blue / Grain Tan / Jang Brown). Displayed at the counter
  or front display area, clearly identifying the shop category.

SHOP FRAMING:
- The shop is empty (NO people in foreground, NO customers, NO shop owner — game environment ready
  for character layer compositing in Godot).
- Composition: tile roof fills the upper ~20-25% of the image as a slim band, shop front + counter
  + category display fills the middle 50-60%, ground level baseline visible at the bottom edge.

LIGHTING + SHADING:
- Single ambient light from upper-left (modern flat interpretation, NOT directional realistic lighting).
- Single subtle ambient ellipse shadow under the shop base (#000 ~25% alpha).
- Optional soft 1-layer cel shading on the wooden counter + signboard (base color × 0.85 multiply,
  small area only — keep modern flat clean tone dominant).

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (consistent across all 5 shops, for cross-shop one-market
  identity).
- NO beige background (#FAEFD8, #FFF1D6 warm-cream tones FAIL), NO cream paper, NO scrapbook,
  NO vintage texture, NO golden hour sunset warm lighting, NO atmospheric haze.

COLOR + OUTLINE:
- Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
  soft 1-layer cel shading.
- Vibrant saturated colors at 80-90 percent saturation, warm/cool palette balance.
- The black tile roof (dark) + warm brown counter (warm) + Cool Sage bg (cool) + per-shop signature
  color creates the warm/cool balance.

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper,
vintage texture, golden hour, sunset warm lighting, atmospheric haze,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine, heavy wood grain texture,
heavy clay tile texture, any texture, noise, grain, painterly or hand-painted feel, watercolor,
gradient mesh, multi-layer complex shading, hyperdetailed elements, cinematic, gritty,
striped awning, red and green stripes, red-green-white stripes, Italian flag awning, tarp canopy,
tent canopy, market awning, fabric canopy of any kind,
full hanok architectural frame with vertical wooden posts on both sides,
deep eave overhang creating heavy shadow band, traditional Korean lantern hanging from the eave,
extra onggi pottery jars added beyond what the v1.2 base shop already has,
Chinese pagoda multi-tier sharp upturned corner roof, Japanese irimoya hip-and-gable roof,
Chinese architecture (qipao, blue-and-white porcelain, red Chinese paper lantern, chinatown gate),
Japanese architecture (kanji signage, noren curtain, Tokyo, Tsukiji, kimono, sushi, Fuji,
Japanese paper lantern with kanji),
any Korean text (한글) legibly readable, any Chinese characters (한자) on signboard,
any Japanese characters (kana, kanji) on signboard,
sub-text under the English label in any non-English language,
traditional Korean mortar, mortar and pestle,
anime girl, manga, cluttered composition, people, customers, shop owner,
flat front elevation view (use slight three-quarter angle instead), photographic depth of field,
modern Western storefront (American shopfront with metal frame, European boutique with wrought iron).
```

> "Minimal stylization": ChatGPT는 stylize 숫자 param 없음 → 자연어 단어로 톤 강도 유도 ("minimal / moderate / highly stylized").
> **v1.12 v3 minimal patch**: v1.2 base + 천막→기와 지붕 단일 fix. v1.11 v2의 한옥 풀세트 (옹기 prominent / lantern 양쪽 / 목조 frame / 깊은 처마) 폐기. 사용자 verbatim "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고" 명시. 자세한 v2 폐기 사유는 §4.7 v1.11 v2 archive 절 참조.

### 2.3 공통 Suffix — **캐릭터 5장 (CH-01~05)**

```
[STYLE_SUFFIX_CHAR]
Format: square 1:1.
Style: modern mobile casual game character, clean 2D illustration in Royal Match (Dream Games 2021)
modern saturated palette + Subway Surfers chibi energy. Chibi mascot proportions,
head to body ratio approximately 1 to 1.7 (big head, small body), dynamic energetic action pose
(not static standing) with 1-2 motion line streaks.
Single color fill on clothing (2-3 color blocks max) with optional soft 1-layer cel shading.
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), geometric rounded shapes.
Simple facial features: two small black dot eyes, small arc smile, no nose,
optional LIGHT pink (#FFCFCF) cheek blush (NOT deep Cookie Run pink).
Mitten or nub hands (no individual fingers visible).
Three-quarter view, full body, plain soft mint (#9BE0D2) cool tone background
(NO beige, NO cream paper background).
Vibrant saturated colors at 80-90 percent saturation, warm/cool balance.
Single ambient ellipse shadow under feet.

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper, vintage texture, golden hour,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
deep dark pink cheek, heavy blush,
anime girl, manga style, big sparkly eyes, school uniform, fanservice or sexy elements,
realistic or photorealistic rendering, 3D render, octane or unreal engine,
any texture, noise, painterly or hand-painted feel, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed elements, individual finger detail, nose detail,
traditional Korean mortar, mortar and pestle, stirring with mortar,
Japanese (kimono, geisha), Chinese (qipao),
dark, gritty, cinematic, golden hour or dramatic lighting,
sleeping, eyes closed peaceful, sad, crying.
```

> **Anchor lock 후 운영**: CH-01의 best image를 `CHAR_ANCHOR_FILE`로 §0 표에 기록 → CH-02~05 생성 시 같은 채팅 세션에서 reference image upload + "이 이미지와 같은 outline·features·컬러 톤으로" follow-up. BG도 동일.

### 2.4 공통 Suffix — **음식 12장 (F-01~12, v1.3 신설)**

모든 음식 prompt 끝에 동일하게 부착:

```
[STYLE_SUFFIX_FOOD]
Format: square 1:1.
View: top-down (overhead) or slight 7/8 top-down (Royal Match food card aesthetic).
Style: modern mobile casual game food card, clean 2D illustration in Royal Match (Dream Games 2021)
plated dish aesthetic. Hero shot of a finished plated Korean dish, ready to serve.
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill
with optional soft 1-layer cel shading and ONE small specular highlight per food element (juicy appetite).
Vibrant saturated colors at 80-90 percent saturation, warm food + cool plate/bowl balance.
Background is solid Cool Sage (#C8D5C0) OR Cream-white (#FAFAFA) — choose one consistently.
Single subtle ambient ellipse shadow directly under the bowl/plate (#000 ~25% alpha).
Bowls/plates are clean white or pale celadon with bold outline, NO ornamental pattern, NO text on rim.

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper,
vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine, food photography,
any texture, noise, grain, painterly or hand-painted feel, watercolor, gradient mesh,
multi-layer complex shading, hyperdetailed elements, cinematic, gritty,
Japanese (sushi maki tightly compressed, nori shiny seaweed style, ramen Japanese bowl with bamboo,
miso ramen, tonkotsu, narutomaki pink spiral fish cake, Japanese ceramic decoration, hashioki chopstick rest),
Chinese (hot pot, Sichuan, mapo tofu, lo mein noodles, fried rice with peas/carrots Western style,
red Chinese lantern as garnish, chinese soup spoon flat-bottom, blue-and-white porcelain),
Western (American corn dog with stick handle as deep-fried hot dog, hamburger, BBQ skewer Western style,
Italian pasta swirl, ratatouille, French plating with sauce drizzle),
human characters, hands holding the food, cooking action, kitchen environment background,
any English or Korean text legibly readable on the dish (use solid block placeholders only if labels needed).
```

> 음식 카드는 **plated hero shot** (Stage 3 식탁 완성형) 중심 — Stage 2A cut variation / Stage 2B cooking action은 본 sprint 범위 외 (M1 후반 / M2).
> bowl/plate 컬러는 **white 또는 pale celadon (#E8F0E8)** 통일 — 한식 백자/분청 톤. 일본식 검정 라멘 그릇 회피.

### 2.5 anchor consistency 운영 규칙 (sref 대체)

> 운영 매핑 표는 §0.1, 결과 인계 schema는 §0.2 참조.

1. **Round 1 (탐색)**: subject anchor 문장만으로 1 image 생성. 만족 시 다음 anchor로.
2. **Round 2 (Lock)**: Round 1 best를 ChatGPT에 reference upload → 같은 prompt + "이 이미지와 동일한 스타일·outline·features 유지" follow-up → 일관성 강화 확인.
3. **Round 3 (Anchor 확정)**: Round 2 best를 anchor로 §0 표 기록. M1 모든 자산의 anchor file.
4. **금지**: 한 번 lock한 anchor file은 sprint 종료까지 변경 금지.
5. **Style transfer 강도 조정**: ChatGPT는 sw 숫자 param 없음 → follow-up에서 "더 reference image와 비슷하게" 또는 "reference 톤 약간만 차용하고 더 단순하게" 자연어로 조정.
6. **세션 분기**: CH-01·CH-02·CH-03 (캐릭터) 한 세션 / CH-04·CH-05 (reaction variant) 한 세션 / BG-01~05 (환경) 한 세션 권장. ChatGPT는 세션 안에서만 context 일관성 유지하므로.

---

## 3. 캐릭터 Anchor Prompts (5장)

> Step 0a 생성 후 같은 채팅 세션 안에서 CH-02~05 follow-up 권장. 또는 새 세션 시작 시 Step 0a image를 reference upload.

### CH-01 — 주인공 (base, v1.2 dynamic stirring + bowl-cut)

**의도**: Tier 1 혼밥 시점 주인공. CH-04/05 표정 variant의 base. 캐릭터 anchor 시드.

**Prompt** (ChatGPT 채팅창에 그대로 붙여넣기):
```
A modern mobile casual game illustration of a young Korean cooking character in chibi mascot proportions.
The character has a signature bowl-cut black hair (rounded helmet shape), a neutral-friendly excited expression,
two small black dot eyes, a small arc smile, light pink soft cheek blush, no nose.
The character wears a soft white apron over a vibrant orange hoodie and brown shorts.
Dynamic energetic action pose: one foot forward, body slightly tilted, holding a modern enameled frying pan
in the left mitten hand and a small spatula in the right mitten hand, actively stirring food in the pan
with 1-2 motion line streaks indicating movement.
Three-quarter view, full body.
Background is solid soft mint color (#9BE0D2), cool tone, no beige.

[STYLE_SUFFIX_CHAR]

Important also: the character must hold a FRYING PAN with spatula (NOT a mortar and pestle, NOT a 절구).
Hair must be bowl-cut style (rounded black helmet shape).
```

**Expected output 특징**: bowl-cut hair, dynamic stirring pose with pan+spatula, soft mint cool bg, light pink cheek, slim 2-3px outline, 80-90% saturation.

**Reroll 트리거** (follow-up 대화 형식):
- G_new modernity FAIL (베이지/scrapbook 누수): "이 이미지를 더 modern Royal Match style로 다시 그려줘. 베이지 배경을 soft mint cool tone (#9BE0D2)로 교체, scrapbook/storybook 느낌 완전 제거."
- 절구(mortar) 누수: "이 이미지를 다시 그려줘. 절구(mortar and pestle)를 modern enameled frying pan + spatula로 교체, dynamic stirring pose 유지."
- G2 dynamic pose FAIL (정적 standing): "이 이미지를 다시 그려줘. dynamic action stirring pose로 강조 — 한 발 앞으로, 몸 기울임, motion line 1-2개 추가."
- G3 채도 FAIL (muted): "이 이미지를 다시 그려줘. vibrant saturated 80-90% 채도로 강조, warm/cool 균형 (cool mint bg + warm orange hoodie)."
- G6 (W3 painterly/storybook 누수) FAIL: "이 이미지를 더 clean modern mobile casual로 다시 그려줘. storybook, scrapbook, painterly 톤 완전 제거, Royal Match style clean 2D."

### CH-02 — 어머니 (Tier 2 가족, base, v1.2)

**의도**: Tier 2 가족 식탁. 한복 jeogori 실루엣만 (자수/디테일 X). 주인공과 페어 일관성.

**Prompt**:
```
A modern mobile casual game illustration of a gentle Korean mother character in chibi mascot proportions, early 50s.
She wears a simple V-collar jeogori top in vivid persimmon color (#FF8A1F) over wide-leg cool teal pants,
with a round bun hairstyle rendered as a simple dark circle shape on top (no ornament detail).
Warm closed-arc smile, two small black dot eyes, no nose, LIGHT pink (#FFCFCF) soft cheek blush.
Dynamic friendly pose: holding a small white rice bowl with both mitten hands, slight body tilt,
showing warmth (not static standing). Full body, three-quarter view.
Background is solid soft mint (#9BE0D2) cool tone (NO beige, NO cream paper).
Slim bold dark outline 2-3px, single color fill with optional soft 1-layer cel shading.

This character is in the same modern mobile casual Royal Match + Subway Surfers style as the main character anchor
(young Korean cooking character with bowl-cut hair, soft white apron, vibrant orange hoodie), as the same family IP.

[STYLE_SUFFIX_CHAR]

Important also: avoid Japanese kimono, geisha, Chinese qipao, embroidery or pattern on jeogori (plain solid color),
mortar and pestle, beige background, scrapbook tone.
```

**Reference image upload 권장**: Step 0a CH-01 best image 첨부 → "이 reference와 같은 outline 두께·features·flat 톤·컬러 saturation으로 어머니 캐릭터를 같은 family IP로 그려줘."

**Reroll 트리거** (follow-up):
- G4 일본 기모노 누수: "이 이미지를 다시 그려줘. 옷섶이 오른쪽으로 여며진 Korean hanbok jeogori V-collar로 명확히 만들고, kimono 요소를 완전히 제거해줘."
- G1 주인공 페어 깨짐: "이 이미지를 다시 그려줘. reference image와 같은 outline 두께, 같은 점 눈/호 입 스타일, 같은 단색 fill 톤으로 family 일관성을 강화해줘."
- G5 jeogori 자수 폭주: "이 이미지를 다시 그려줘. jeogori를 완전 단색 solid fill로, 자수·무늬·패턴 모두 제거, plain fabric flat으로."

### CH-03 — 아버지 (Tier 2 가족, base, v1.2)

**의도**: Tier 2 가족 식탁. 어머니와 페어 일관성.

**Prompt**:
```
A modern mobile casual game illustration of a kind Korean father character in chibi mascot proportions, early 50s.
He wears a solid warm brown cardigan over a plain white shirt and a soft white apron (NOT beige apron),
with short salt-and-pepper hair rendered as a simple gray-and-black solid shape (no individual strands).
Warm closed-arc smile, two small black dot eyes, no nose, optional LIGHT pink (#FFCFCF) cheek blush.
Dynamic friendly pose: holding modern wooden chopsticks in one mitten hand, the other hand near chin
in a thoughtful "tasting" gesture, slight body tilt. Full body, three-quarter view.
Background is solid soft mint (#9BE0D2) cool tone (NO beige, NO cream paper).
Slim bold dark outline 2-3px, single color fill with optional soft 1-layer cel shading.

This character is paired with the mother character in the same family,
in the same modern mobile casual Royal Match + Subway Surfers style as the main character anchor.

[STYLE_SUFFIX_CHAR]

Important also: avoid young anime boy or teenager look (this is a mature 50s mascot character),
thick beard or heavy mustache, school student look,
mortar and pestle, beige background, scrapbook tone.
```

**Reference image upload 권장**: Step 0a CH-01 best + CH-02 best 모두 첨부 → "두 reference와 같은 family IP로, 아버지 캐릭터를."

**Reroll 트리거** (follow-up):
- young anime boy로 빠짐: "이 이미지를 다시 그려줘. 50대 mature father로 강조, salt-and-pepper hair, 절대 teenager/school boy 아님."
- G1 어머니 페어 깨짐: "이 이미지를 다시 그려줘. 어머니 reference와 같은 family flat art style, 같은 outline 두께."
- G5 머리카락 strand 폭주: "이 이미지를 다시 그려줘. 머리카락을 simple solid color shape 하나로, 개별 strand 모두 제거."

### CH-04 — 주인공 Happy (★3 reaction, v1.2)

**의도**: Scene 3 ★3 시식 reaction. CH-01과 동일 캐릭터 인식 필수.

**Prompt**:
```
A modern mobile casual game illustration of the same young Korean cooking character (same bowl-cut black hair,
soft white apron over vibrant orange hoodie), showing a joyful "wow delicious" expression.
Mouth open in a delighted O-shape, two upward curved happy arc eyes (smiling, not closed-sad),
LIGHT pink (#FFCFCF) cheek blush (NOT deep dark Cookie Run pink).
Small simple flat geometric heart and star icons around the head as accent (single color, not detailed sparkle).
Both mitten hands raised near cheeks in delight, dynamic energetic pose.
Three-quarter view, bust-up portrait (head and shoulders).
Background is solid soft mint (#9BE0D2) cool tone (NO beige).
Slim bold dark outline 2-3px, single color fill with soft 1-layer cel shading.

[STYLE_SUFFIX_CHAR]

Important also: the eyes are upward curved happy arcs (smiling), NOT closed sleeping or sad eyes.
Avoid sleeping, drowsy, sad closed eyes, crying tears, deep dark pink cheek,
mortar and pestle, beige background, scrapbook tone, Cookie Run frosting style.
The hearts and stars must be simple flat geometric icons in single color (not detailed sparkle effects).
```

**Reference image upload 강력 권장**: Step 0a CH-01 best 첨부 → "이 reference 캐릭터와 정확히 같은 의상·outline·features 유지, 단 표정만 happy reaction으로 변경."

**Reroll 트리거** (follow-up):
- G1 CH-01과 다른 캐릭터: "이 이미지를 다시 그려줘. reference 캐릭터 의상(beige apron + orange hoodie)을 정확히 일치시키고, 같은 outline 두께·features."
- sleeping/eyes closed로 빠짐: "이 이미지를 다시 그려줘. 눈을 upward curved happy arc (웃는 호)로, 절대 sleeping이나 sad closed 아니게."
- G5 sparkle hearts detail 폭주: "이 이미지를 다시 그려줘. hearts와 stars를 simple flat geometric single color icon으로 단순화."

### CH-05 — 주인공 Subtle (★1·★2 공통, v1.2)

**의도**: ★1·★2 공통 차분한 만족 reaction.

**Prompt**:
```
A modern mobile casual game illustration of the same young Korean cooking character (same bowl-cut black hair,
soft white apron over vibrant orange hoodie), showing a soft satisfied small arc smile with a slight head tilt.
Two small black dot eyes (open, looking forward, alert), optional LIGHT pink (#FFCFCF) cheek blush.
No stars, no hearts.
One mitten hand near chin in a "hmm tasty" gesture, slight body tilt for warmth (not static).
Bust-up portrait, three-quarter view.
Background is solid soft mint (#9BE0D2) cool tone (NO beige).
Slim bold dark outline 2-3px, single color fill with soft 1-layer cel shading.

[STYLE_SUFFIX_CHAR]

Important also: the eyes are open as two small black dots, looking forward and alert.
Avoid sleeping, eyes closed peaceful, sad, crying tears, deep dark pink cheek,
mortar and pestle, beige background, scrapbook tone, Cookie Run frosting style.
```

**Reference image upload 강력 권장**: Step 0a CH-01 best 첨부.

**Reroll 트리거** (follow-up):
- sleeping 누수: "이 이미지를 다시 그려줘. 눈을 open 상태로, 두 개의 검정 점, alert content expression, 절대 sleeping/closed eyes 아님."
- 슬픔 표정으로 빠짐: "이 이미지를 다시 그려줘. gentle satisfied smile, mildly positive, content expression."

---

## 4. 환경 Anchor Prompts (5장 — v1.13 v4 image edit: v1.2 base + 지붕만 교체, frontal view, 5가게 구조 일관성)

> 5장은 **같은 시장 안 옆가게**로 인식되어야 함 (G1) — v4에서는 v1.2 base 5장 (Week 1 commit 7a6cffb anchor candidate, `assets-raw/week1-anchors/BG-XX_<name>_v2.png` 5장)을 **gpt-image-1 image edit API의 base image 직접 입력으로 사용**하여 천막 부분만 검정 기와 곡선 지붕으로 교체. 다른 모든 요소 (지붕 외 모든 frame/카운터/products/signage/bg)는 base image와 ABSOLUTELY IDENTICAL 유지. 이렇게 하면 5가게 구조적 일관성 (지붕/기둥/카운터 동일) + frontal view + v1.2 base 정확 보존이 모두 한 번에 해결된다.
>
> **도구 변경 (v1.13)**: `client.images.edit(model="gpt-image-1", image=open(base_path, "rb"), prompt=COMMON_EDIT_PROMPT + shop_category, size="1024x1024", quality="medium", n=1)`. base image dimensions 자동 검증 + gpt-image-1 edit supported size (1024×1024 / 1536×1024 / 1024×1536) 자동 resize. driver script = `tools/edit_bg_anchors_v4.py`.
> 모든 BG는 **빈 가게 (no people)** — 캐릭터는 Godot 레이어 합성.

> **v1.13 v4 변경 요약 (사용자 v3 폐기 + image edit 도입)**: 사용자가 v1.12 v3 결과 (5장 batch prompt-only generation, slight 7/8 perspective, structurally inconsistent across 5 shops) 시각 확인 후 verbatim "**각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나...**" 명시. main thread 해석 3건 fix: (1) 5가게 구조 정확 일관성 (지붕/기둥/카운터 5가게 모두 정확 동일, 카테고리별 display goods + signage icon만 다름) / (2) v1.2 base 정확 유지 + 지붕만 교체 (prompt-only 한계 → image edit API 도입) / (3) frontal view (slight 7/8 perspective 폐기). v3 prompt-only 본문 5건은 §4.8 archive로 deprecated, v4 image edit approach는 본 §4 §4.0~§4.5에서 새로 명시.

### 4.0 v4 image edit 공통 fix prompt (5가게 동일)

> 모든 5가게에 공통 적용. shop-specific 카테고리 명시 한 줄만 끝에 추가. driver script `tools/edit_bg_anchors_v4.py`의 `COMMON_EDIT_PROMPT` 상수와 1:1 sync.

```
Replace ONLY the striped awning at the top of the shop with a curved black ceramic tile roof
in the Korean traditional hanok 기와 style. The new roof should be a short simple curved tile
pattern, dark slate gray to black single fill, with the signature gently upward-curving eave
silhouette at the corners (Korean hanok 처마 곡선). Optional: 2-3 small white circular eave-end
tile caps (와당) along the eave tips as subtle accent.

Keep ABSOLUTELY ALL other elements of the shop IDENTICAL to the base image:
- The wooden shop frame (warm brown wood color, two vertical posts on left and right, exact same
  width and proportions)
- The wooden shop counter / display structure (exact same shape, color, signage board position)
- The signboard text and icon (exact same English text and icon)
- All displayed products in the wooden crates / counter
- All hanging items on the side
- All ground-level props (jars, etc.)
- The frontal elevation view (no perspective change)
- The Cool Sage #C8D5C0 solid background (or change background to Cool Sage if currently different)
- The slim bold dark outline (warm dark #2D1D14, 2-3px)
- The modern saturated colors (80-90% saturation, NOT muted, NOT washed out)

DO NOT add any new elements (NO additional lanterns, NO additional onggi jars beyond what's already
there, NO wooden vertical posts beyond the existing frame, NO bunting, NO deeper eaves).

DO NOT change the frontal elevation view, the shop structure, the counter, the products, the
signage text, or any other element. ONLY the awning is replaced with the tile roof.

NOT a Chinese pagoda multi-tier sharp upturned corner roof, NOT a Japanese irimoya hip-and-gable.
NOT a striped awning, NOT a tarp canopy.

Shop category: <SHOP_CATEGORY>.
```

### 4.1 v4 image edit shop-specific 카테고리 명시 (공통 prompt 끝에 추가)

| ID | Base image (`assets-raw/week1-anchors/`) | `Shop category` 한 줄 |
|----|-----------------------------------------|--------------------|
| BG-01 | `BG-01_produce_v2.png` | Korean greengrocer / produce shop (PRODUCE signage with cabbage icon) |
| BG-02 | `BG-02_butcher_v2.png` | Korean butcher shop (BUTCHER signage with meat icon) |
| BG-03 | `BG-03_seafood_v2.png` | Korean seafood shop (SEAFOOD signage with fish icon) |
| BG-04 | `BG-04_grain_v2.png` | Korean grain shop (GRAIN signage with grain sack icon) |
| BG-05 | `BG-05_sundry_v2.png` | Korean sauces/seasoning shop (SAUCES signage with bottle/jar icon) |

### 4.2 v4 평가 게이트 (G_env_v4 8 요소)

> 평가 기준 풀세트는 [`art-anchor-rubric.md` v1.13 §5.6.2 G_env_v4 5+3 요소 점검표](art-anchor-rubric.md#562-g_env_v4-환경-v4-image-edit-게이트-v113-신설-g_env_v3-5-요소-deprecated) 참조.
> 요약 = G_env_v3 5 요소 (검정 기와 지붕 단일 / 카테고리 시그니처 v1.2 base / icon+영어 minimal signage / Cool Sage bg + modern saturated / v2 한옥 풀세트 추가 요소 0건) + **v4 추가 3 요소**: G_env_v4_6 **5가게 구조 정확 일관성** (지붕/기둥/카운터/frame 5가게 모두 정확히 동일, 카테고리별 display goods + signage icon만 다름) / G_env_v4_7 **frontal elevation view** (slight 7/8 perspective 0건, 정면 elevation 명확) / G_env_v4_8 **v1.2 base 시각 시그니처 정확 유지** (base image의 frame/카운터/products/signage/bg가 image edit 후에도 ABSOLUTELY IDENTICAL).

### 4.3 v4 driver script + 실행 명령

- 신규 driver: `tools/edit_bg_anchors_v4.py`
- 첫 시도 (BG-01 test 권장, ~30초 / ~$0.05): `py tools/edit_bg_anchors_v4.py --only BG-01`
- 5장 batch (BG-01 결과 평가 후 진행, ~2-3분 / ~$0.21): `py tools/edit_bg_anchors_v4.py`
- 출력 경로: `assets-raw/bg_anchors_m1/BG-XX_<name>_v4.png` (v1/v2/v3 deprecated 파일과 공존)

### 4.4 사용자 v3 폐기 verbatim + 의도 해석

> 사용자 R2 v3 verbatim (2026-05-28): "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."

main thread 해석 (3건):
1. **5가게 구조적 일관성** — "지붕, 기둥, 이런것들은 똑같아야" = 5가게 carpenter 작업 (지붕/기둥/카운터/frame) 정확 동일. 카테고리 (display goods + signage icon)만 다름. v3는 prompt-only batch generation으로 5가게마다 carpenter 작업이 다르게 생성됨 (DALL-E generation noise).
2. **v1.2 base 정확 유지 + 지붕만 교체** — "원래 버젼에서 지붕만 바꾸는게" = v1.2 base (Week 1 commit 7a6cffb anchor candidate) 정확 재현 + 지붕 단일 swap. prompt-only로는 매번 다른 해석 → **gpt-image-1 image edit API** 도입 (base image 직접 입력).
3. **frontal view** — "정면이 더 낫지 않나" = slight 7/8 perspective 폐기, frontal elevation. v1.2 base가 원래 frontal이었음.

### 4.5 v3 → v4 핵심 diff 요약 (5 요소)

| 요소 | v1.12 v3 (deprecated 2026-05-28) | v1.13 v4 (사용자 R2 image edit fix) |
|------|-------------------------------|--------------------------------|
| API approach | gpt-image-1 prompt-only generation (5장 batch, 매번 다른 추론) | **gpt-image-1 image edit** (`client.images.edit`, base image PNG 직접 입력) |
| Base image input | None (prompt only) | **`assets-raw/week1-anchors/BG-XX_<name>_v2.png` 5장 직접 입력** |
| 5가게 구조 일관성 | inconsistent (지붕/기둥/카운터 5가게마다 generation noise로 다르게 생성) | **정확 동일** (base image 5장 자체가 이미 v1.2 base에서 일관된 구조, image edit은 지붕만 교체) |
| 시점 | slight three-quarter angle (실제 결과는 slight 7/8 perspective) | **frontal elevation** (base image의 view 그대로 유지) |
| Prompt 본문 | §4 BG-01~05 long body prompt 5건 (각각 카테고리 시그니처 + 한옥 회피 + 옹기 추가 회피 등 long form) | **단일 COMMON_EDIT_PROMPT** (지붕 교체 + 다른 요소 ABSOLUTELY IDENTICAL 명시) + shop-specific 카테고리 한 줄 |
| driver script | `tools/gen_bg_anchors_m1.py --version v3` | **`tools/edit_bg_anchors_v4.py` 신설** (gpt-image-1 edit API + base image dimensions 검증 + PIL resize fallback) |

---

### 4.6 v1.2 archive (deprecated, 2026-05-28) — 이하 v3 prompt-only 본문 (deprecated)

> 이하 §4.6 v1.2 archive ~ §4.7 v1.11 v2 archive ~ §4.8 v1.12 v3 archive는 모두 deprecated 본문. 본 sprint M1 환경 5장 작업에는 **§4.0~§4.5 v4 image edit approach만 사용**. v3 prompt-only 본문은 §4.6 직후 (이하 BG-01~BG-05 v3 long body prompt 5건)을 참고용으로 보존하나 실행하지 않는다.

> 아래 §4.6 v1.2 archive 본문은 무변경 유지.

### 4.6.x v1.2 archive 본문 (deprecated, 2026-05-28)

> v1.2 archive 본문은 git history (prompts-library.md v1.10 §4 BG-01~05) 참조. v1.11 v2에서 invalidate, v1.12 v3에서 v1.2 base 회복 시도, v1.13 v4 image edit으로 정확 보존 달성.

### (이하 §4.6/§4.7/§4.8 archive 절은 본 문서 하단 v3 prompt-only 본문 5건과 동일 — v4 sprint 진입 후 무참조)

---

## 4-LEGACY. (이하 deprecated) v1.12 v3 prompt-only 본문 (BG-01~05 5건)

> **DEPRECATED (2026-05-28, v1.13 v4 image edit로 supersede)**. 아래 BG-01~05 5건 본문은 v1.12 v3 prompt-only generation 본문이다. 사용자 v3 폐기 verbatim "각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."로 폐기됨. **v4 sprint에서는 §4.0~§4.5 image edit approach만 사용** (driver: `tools/edit_bg_anchors_v4.py`). 본 §4-LEGACY 본문은 reroll trigger 참고용으로 보존 (v4 결과 평가 시 "지붕 / signage / 카테고리 시그니처" 항목 reroll trigger 문장은 재활용 가능).

> 5장은 **같은 시장 안 옆가게**로 인식되어야 함 (G1) — v3에서는 v1.2 base의 minimal 가게 카운터 + 카테고리 시그니처 + **검정 기와 곡선 지붕** 단일 layer가 5가게 cross-shop 일관성의 핵심 시그니처가 된다.
> 모든 BG는 **빈 가게 (no people)** — 캐릭터는 Godot 레이어 합성.
> 각 BG는 **가게당 카테고리 시그니처 shape 1~2개 + 기와 지붕 단일 layer** (단순성 유지). 한옥 frame 풀세트 / lantern / extra onggi 등 v2 추가 요소는 본 v3에서 **모두 폐기**.
> Step 0b BG-01 (청과상) v3 lock → BG-02~05 v3는 BG-01 reference image upload + 동일 기와 지붕 + minimal 톤 일관성 유지 권장.

> **v1.12 v3 변경 요약 (사용자 v2 폐기 + minimal 회복) (deprecated, v4 image edit로 supersede)**: 사용자가 v1.11 v2 결과 시각 확인 후 verbatim "**기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고**" 명시. v2의 한옥 풀세트 (옹기 5가게 prominent + lantern 5가게 양쪽 + 목조 한옥 frame + 깊은 처마 풀세트) **전면 폐기**. v1.2 base (commit 7a6cffb)의 minimal feel 회복 + **천막(red/green striped awning) → 검정 기와 곡선 지붕 단일 fix만 적용**. v1.2 LOCK 유지 = 카테고리 시그니처 (채소/meat/fish/곡식/sauce) / 작은 가게 카운터 / icon+영어 minimal signage / Cool Sage `#C8D5C0` bg / modern saturated 톤 / slim outline 2-3px / no people / mortar 회피. **v1.2 본문은 §4.6 archive 절에 보존, v1.11 v2 본문은 §4.7 archive 절에 보존**.

### BG-01 — 청과상 🥬 (v1.12 v3 v1.2 base + 기와 지붕, 환경 anchor seed)

**시그니처 (카테고리)**: Cabbage Green Vivid `#52C160` + 채소 stack (양배추 hero + 배추 + 사과 + 오이 + 대파) + 좌측 옹기 항아리 2개 + 우측 양파/마늘 hanging (v1.2 base signature 전체 유지)
**v3 단일 fix**: 천막 (red/green striped awning) → 검정 기와 곡선 지붕 (curved black ceramic tile roof, 한옥 기와 eave)

**식별 핵심 시각 요소 (v1.12 v3, 6개)**:
1. **검정 기와 곡선 지붕 (단일 layer)** — dark slate-gray/black curved eave tile, 처마 곡선 corners upward, optional 와당 accent 2-3개. NOT 한옥 frame 풀세트, NOT 깊은 처마, just the tile roof itself as the topmost band.
2. **카테고리 시그니처 진열 (v1.2 base 유지)** — 채소 stack on wooden crates: round green cabbage (hero, `#52C160`) + 배추 + red apple + 오이 + 대파 bundle
3. **좌측 옹기 항아리 2개 (v1.2 base 유지)** — 2 brown traditional Korean onggi (장아찌 항아리) on the LEFT side, 그대로
4. **우측 양파/마늘 hanging (v1.2 base 유지)** — small bundle hanging from simple hook on the right
5. **작은 가게 카운터 + signboard** — wooden counter + small wooden signboard: cabbage icon + "PRODUCE" English text minimal
6. **Cool Sage `#C8D5C0` solid bg** — modern flat clean tone

**Prompt** (v1.12 v3):
```
A modern mobile casual game illustration of a small Korean traditional market vegetable shop
storefront (Korean greengrocer / 청과상), slight three-quarter view. The shop is a small friendly
stall with a simple wooden counter at the front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of a round green
cabbage (cabbage green vivid #52C160 single fill, ~60-70% of signboard area) + a SHORT English
minimal text label "PRODUCE" below the icon (simple sans-serif, all-caps, ~20-25% area, legible).

At the shop front display area: a stack of fresh vegetables and fruits arranged on simple wooden
display crates / open boxes (warm brown #A67049 single fill, slim grain line accent 1-2 only).
The vegetable stack includes: a round green cabbage (vivid cabbage green #52C160) as the hero,
a stack of napa cabbage leaves (배추, lighter green), a few red apples (#F23E3E), 1-2 cucumbers
(deeper green), and a small bundle of green onions / scallions (대파, bright green tops). The
signature category color is cabbage green (dominant), with red apple as warm accent.

On the LEFT side of the shop, 2 large brown traditional Korean onggi pottery jars (dark warm
brown #7A5238 single fill with bold outline, rounded earthen shape with narrow neck + wide round
body, classic Korean fermentation pot silhouette) stand on the ground — these are 장아찌 (pickled
vegetable) jars fitting the greengrocer context (v1.2 base signature retained).

On the RIGHT side, a small bundle of onions or garlic hangs from a simple hook (just a small
accent prop, optional).

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty,
waiting for a customer (NO people, NO shop owner, NO customers, NO market lanterns hanging from
the roof).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading on the wooden counter + signboard. Vibrant saturated colors at 80-90
percent saturation, warm/cool palette balance (warm brown wood + warm category accent balanced by
cool sage bg + dark black tile roof).

[STYLE_SUFFIX_BG]

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (vegetable stack signature, wooden
crates, 2 onggi jars on left, onion/garlic hanging right, PRODUCE signage, Cool Sage bg) are
RETAINED EXACTLY as in v1.2. Do NOT add extra elements: NO hanging lanterns, NO full hanok side
posts, NO additional onggi beyond the existing 2 on the left side, NO deep eave overhang shadow
band, NO extra traditional Korean props. Just the v1.2 base + tile roof swap. The signboard text
is English only ("PRODUCE"), absolutely NO Korean text (한글), NO Chinese characters (한자),
NO Japanese kana/kanji. Background MUST be solid Cool Sage #C8D5C0, NO beige, NO cream,
NO scrapbook, NO vintage paper texture, NO golden hour.
```

**Expected output 특징**: v1.2 base의 채소 stack + 좌측 옹기 2개 + 우측 hanging + PRODUCE signage + Cool Sage bg + slim outline 2-3px 그대로 + **천막 자리에 검정 기와 곡선 지붕 단일 layer만** 추가. lantern / 한옥 풀세트 / extra onggi 없음.

**DALL-E 약점 회피 노트 (v1.12 v3)**:
- **risk HIGH — v2 한옥 풀세트 재누수 (lantern/extra onggi/side posts 추가)**: ChatGPT가 "Korean hanok eave tile" → 한옥 frame 풀세트 추론 가능. → "the roof is a SINGLE simple layer, NOT a full hanok structure with side posts, NO hanging lanterns, NO additional onggi beyond v1.2 base" explicit 강조.
- **risk HIGH — 천막 회귀 (striped awning regenerate)**: v1.2 base prompt에 있던 awning 키워드가 다시 추론될 수 있음. → "ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy" explicit 강조.
- **risk HIGH — 한글 누수**: ChatGPT는 "Korean shop" → 한글 추론 기본. → "English minimal text only 'PRODUCE'", "absolutely NO Korean text" 강제.
- **risk MED — Chinese pagoda / Japanese irimoya 누수**: "Korean hanok eave tile" → Chinese pagoda 추론 가능. → "Korean hanok 기와 curved eave, NOT Chinese pagoda multi-tier, NOT Japanese irimoya" 강제.
- **risk MED — 베이지 누수, vintage storybook 누수**: v1.2 base LOCK 유지.

**Reroll 트리거** (follow-up, v1.12 v3 — 5종):
- 천막 회귀 (striped awning regenerate): "이 이미지를 다시 그려줘. 천막 (striped awning, red and green stripes) 완전 제거하고 그 자리에 검정 기와 곡선 지붕 (curved black ceramic tile roof, 한옥 기와 eave)만 두기. tile roof는 단일 layer로 storefront 위에 slim band."
- 한옥 풀세트 재누수 (lantern / side posts / extra onggi 추가): "이 이미지를 다시 그려줘. 기와 지붕 단일 layer만 추가. 한옥 frame (양쪽 wooden posts), hanging lantern, 추가 옹기 (v1.2 base의 좌측 2개 외) 모두 제거. v1.2 base 그대로 + 기와 지붕만."
- 한글/한자 누수: "이 이미지를 다시 그려줘. signboard 텍스트를 English 'PRODUCE' minimal only로 — 한글/한자/카타카나 절대 없음. cabbage icon + English text 두 요소만."
- 카테고리 시그니처 누락 (채소 stack X): "이 이미지를 다시 그려줘. 청과상 카테고리 시그니처 (vegetable stack: cabbage hero + 배추 + apples + cucumbers + 대파 on wooden crates + 좌측 옹기 2개 + 우측 onion hanging)를 front display에 v1.2 base 그대로 표시."
- 베이지/cream 배경 누수: "이 이미지를 다시 그려줘. 배경을 solid Cool Sage #C8D5C0 (cool tone)으로 명확히, 베이지/cream/vintage paper/golden hour 톤 완전 제거."

### BG-02 — 정육점 🥩 (v1.12 v3 v1.2 base + 기와 지붕)

**시그니처 (카테고리)**: Gochu Red Vivid `#F23E3E` + meat slab hanging 2-3개 + 도마 + 가게 카운터 (v1.2 base signature 전체 유지)
**v3 단일 fix**: 천막 → 검정 기와 곡선 지붕

**식별 핵심 시각 요소 (v1.12 v3, 5개)**:
1. **검정 기와 곡선 지붕 (단일 layer)** — dark slate/black curved eave tile, 와당 옵션. NOT 한옥 frame 풀세트.
2. **카테고리 시그니처 진열 (v1.2 base 유지)** — 2-3 meat slab silhouettes hanging from horizontal hook bar (gochu red `#F23E3E`, family-friendly stylized, NO blood/gore) + 도마 + butcher's knife on the wooden counter
3. **작은 가게 카운터 + signboard** — wooden counter + signboard: meat icon + "BUTCHER" English text minimal
4. **Cool Sage `#C8D5C0` solid bg**
5. **No extras** — NO 옹기 (v1.2 정육점에는 옹기 없음), NO lantern, NO 한옥 풀세트

**Prompt** (v1.12 v3):
```
A modern mobile casual game illustration of a small Korean traditional market butcher shop
storefront (Korean 정육점), slight three-quarter view. The shop is a small friendly stall with a
simple wooden counter at the front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of a meat slab
silhouette (gochu red vivid #F23E3E single fill, flat geometric shape, ~60-70% of signboard area)
+ a SHORT English minimal text label "BUTCHER" below the icon (simple sans-serif, all-caps,
~20-25% area, legible).

At the shop front: 2-3 simple meat slab silhouettes hang from a horizontal hook bar mounted at
the top of the shop opening (modern flat meat slab silhouette, gochu red #F23E3E single fill with
bold outline, family-friendly stylized — clearly identifiable as meat but NO blood, NO carcass,
NO raw meat closeup, NO gore). Below on the wooden shop counter, a modern clean wooden cutting
board sits (warm brown #A67049 single fill, slim grain line accent 1-2 only, slightly worn corner)
with a simple flat butcher's knife resting on it. The signature category color is gochu red.

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty
(NO people, NO shop owner, NO customers, NO market lanterns hanging from the roof, NO onggi
pottery jars added).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading on the wooden counter + signboard. Vibrant saturated colors at 80-90
percent saturation (gochu red 80-90% saturated, NOT neon 100%), warm/cool palette balance.

[STYLE_SUFFIX_BG]

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (meat slab hanging signature, cutting
board on counter, BUTCHER signage, small shop counter, Cool Sage bg) are RETAINED EXACTLY as in
v1.2. Do NOT add extra elements: NO hanging lanterns, NO full hanok side posts, NO onggi pottery
jars (v1.2 butcher had none), NO deep eave overhang shadow band, NO extra traditional Korean
props. Just the v1.2 base + tile roof swap. This is a Korean 정육점 (butcher shop) interpreted
as a clean family-friendly modern mobile game art — NO blood, NO carcass, NO raw meat closeup,
NO gore, NO realistic butchering scene. The signboard text is English only ("BUTCHER"),
absolutely NO Korean text (한글), NO Chinese characters (한자), NO Japanese kana/kanji.
Background MUST be solid Cool Sage #C8D5C0, NO beige, NO cream, NO scrapbook, NO vintage texture.
```

**Reference image upload 권장**: BG-01 v3 best 첨부 → "이 reference (BG-01 청과상 v3)와 같은 minimal feel + 검정 기와 곡선 지붕 단일 layer + 작은 가게 카운터 + icon+영어 signage 일관성으로 정육점을 그려줘."

**DALL-E 약점 회피 노트 (v1.12 v3)**:
- **risk HIGH — v2 한옥 풀세트 재누수 + 옹기 추가 누수**: v1.2 정육점은 옹기 없음. ChatGPT가 한옥 → 옹기 추론할 수 있음. → "NO onggi pottery jars (v1.2 butcher had none)" explicit 강제.
- **risk HIGH — 천막 회귀**: "ABSOLUTELY NO striped awning" 강제.
- **risk HIGH — 한글 누수**: "BUTCHER" English only 강제.
- **risk MED — 잔혹 묘사 누수**: "stylized meat slab silhouette, NO blood, NO carcass, NO gore, family-friendly" 강제.
- **risk MED — 빨강 neon 누수**: "80-90 percent saturation, NOT neon 100%" 강제.
- **risk MED — Chinese/Japanese architecture / 베이지 누수**: BG-01과 동일.

**Reroll 트리거** (follow-up, v1.12 v3):
- 천막 회귀 / 한옥 풀세트 재누수 / 한글 누수 / 베이지 누수: BG-01과 동일 reroll trigger
- 잔혹 묘사: "이 이미지를 다시 그려줘. family-friendly stylized meat slab icon only, NO blood, NO carcass, NO gore. 카테고리 식별 가능하되 잔혹 묘사 절대 없음."
- 빨강 neon 누수: "이 이미지를 다시 그려줘. gochu red를 80-85 percent saturation으로 (not neon 100%)."
- 옹기 추가 누수 (v1.2 정육점에는 옹기 X): "이 이미지를 다시 그려줘. 옹기 항아리 완전 제거. 정육점은 v1.2 base에서 옹기가 없는 가게."
- 카테고리 시그니처 누락: "이 이미지를 다시 그려줘. 정육점 카테고리 시그니처 (meat slab hanging 2-3개 + cutting board on counter)를 명확히 표시."

### BG-03 — 어물전 🐟 (v1.12 v3 v1.2 base + 기와 지붕)

**시그니처 (카테고리)**: Accent Sea `#2E8AC4` + fish hanging 2개 + 얼음 block + 가게 카운터 (v1.2 base signature 전체 유지)
**v3 단일 fix**: 천막 → 검정 기와 곡선 지붕

**식별 핵심 시각 요소 (v1.12 v3, 5개)**:
1. **검정 기와 곡선 지붕 (단일 layer)** — dark slate/black curved eave tile, 와당 옵션. NOT 한옥 풀세트.
2. **카테고리 시그니처 진열 (v1.2 base 유지)** — 2 simple stylized fish silhouettes hanging from horizontal hook bar (accent sea blue `#2E8AC4`, friendly cute geometric) + white ice block on the counter with optional 1-2 smaller fish/shells on top
3. **작은 가게 카운터 + signboard** — wooden counter + signboard: fish icon + "SEAFOOD" English text minimal
4. **Cool Sage `#C8D5C0` solid bg**
5. **No extras** — NO 옹기 (v1.2 어물전에는 옹기 없음), NO lantern, NO 한옥 풀세트

**Prompt** (v1.12 v3):
```
A modern mobile casual game illustration of a small Korean traditional market seafood shop
storefront (Korean 어물전), slight three-quarter view. The shop is a small friendly stall with a
simple wooden counter at the front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of a stylized cute
fish silhouette (accent sea blue #2E8AC4 single fill, friendly geometric shape, ~60-70% of
signboard area) + a SHORT English minimal text label "SEAFOOD" below the icon (simple sans-serif,
all-caps, ~20-25% area, legible).

At the shop front: 2 simple stylized fish silhouettes hang from a horizontal hook bar at the top
of the shop opening (Korean traditional 어물전 style — fish hanging from hooks, modern flat
interpretation, NOT realistic dead-eye fish, NOT bloody — simplified cute geometric fish shape,
accent sea blue #2E8AC4 single fill with bold outline). Below on the wooden shop counter, a white
ice block (clean flat white #FAFAFA single fill with slight cool sage cel shading, simple
geometric block shape suggesting crushed ice display) sits with optional 1-2 smaller fish or
shells resting on top of the ice. The signature category color is accent sea blue + white ice
(cool tone dominant, balancing the warm wood counter).

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty
(NO people, NO shop owner, NO customers, NO market lanterns hanging from the roof, NO onggi
pottery jars added).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading. Vibrant saturated colors at 80-90 percent saturation, warm/cool palette
balance (warm wood counter balanced by cool sage bg + cool sea blue category accent + white ice).

[STYLE_SUFFIX_BG]

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (fish hanging signature, ice block
display, SEAFOOD signage, small shop counter, Cool Sage bg) are RETAINED EXACTLY as in v1.2.
Do NOT add extra elements: NO hanging lanterns, NO full hanok side posts, NO onggi pottery jars
(v1.2 fishmonger had none), NO deep eave overhang shadow band, NO extra traditional Korean props.
Just the v1.2 base + tile roof swap. This is a Korean 어물전 (seafood market shop), NOT Japanese
sushi shop, NOT Tsukiji fish market, NOT Chinese seafood restaurant. The fish silhouettes are
friendly modern mobile casual game style (simplified cute geometric shape), NOT realistic
dead-eye fish, NOT bloody fish, NOT raw sashimi. The signboard text is English only ("SEAFOOD"),
absolutely NO Korean text (한글), NO Chinese characters (한자), NO Japanese kana/kanji.
Background MUST be solid Cool Sage #C8D5C0, NO beige, NO cream, NO scrapbook, NO vintage texture.
```

**Reference image upload 권장**: BG-01 v3 best 첨부 → "이 reference와 같은 minimal feel + 기와 지붕 + 가게 카운터 일관성으로 어물전을."

**DALL-E 약점 회피 노트 (v1.12 v3)**:
- **risk VERY HIGH — Japanese sushi shop 누수**: "seafood + Korean" → ChatGPT default 일본 sushi shop 또는 Tsukiji 추론. → "Korean 어물전 traditional hanging fish style, NOT Japanese sushi shop, NOT Tsukiji" 강조.
- **risk HIGH — v2 한옥 풀세트 재누수 / 천막 회귀 / 한글 누수 / 베이지 누수**: BG-01/BG-02 동일 risk.
- **risk MED — 비린 사실적 묘사**: "stylized cute geometric fish, NOT realistic dead-eye, NOT bloody" 강조.
- **risk MED — 옹기 추가 누수 (v1.2 어물전 옹기 X)**: explicit 강제.

**Reroll 트리거** (follow-up, v1.12 v3):
- 일본 sushi shop 누수: "이 이미지를 다시 그려줘. Korean 어물전 (한식 어물전) 분위기로 — Korean traditional hanging fish style + 검정 기와 곡선 지붕. NOT Japanese sushi shop, NOT Tsukiji."
- 비린 사실적 묘사: "이 이미지를 다시 그려줘. fish를 simplified cute geometric icon (friendly modern mobile casual)으로, realistic dead-eye/bloody fish 절대 아님."
- 천막 회귀 / 한옥 풀세트 재누수 / 한글/한자 / 베이지 / 카테고리 시그니처 누락: BG-01과 동일 reroll trigger

### BG-04 — 곡물상 🌾 (v1.12 v3 v1.2 base + 기와 지붕)

**시그니처 (카테고리)**: Grain Tan `#D8A86A` + 곡식 자루 3종 (쌀/곡물/팥) + 나무 박스 + 가게 카운터 (v1.2 base signature 전체 유지)
**v3 단일 fix**: 천막 → 검정 기와 곡선 지붕

**식별 핵심 시각 요소 (v1.12 v3, 5개)**:
1. **검정 기와 곡선 지붕 (단일 layer)** — dark slate/black curved eave tile, 와당 옵션. NOT 한옥 풀세트.
2. **카테고리 시그니처 진열 (v1.2 base 유지)** — 3 burlap-style grain sacks (trapezoid shape, tan/warm brown/red bean color variants) on the wooden counter and in a simple wooden display box at the front. optional wooden scoop accent.
3. **작은 가게 카운터 + signboard** — wooden counter + signboard: grain sack icon + "GRAIN" English text minimal
4. **Cool Sage `#C8D5C0` solid bg**
5. **No extras** — NO 옹기 (v1.2 곡물상에는 옹기 없음 — v2의 옹기 2-3개 prominent + 작은 plant 모두 폐기), NO lantern, NO 한옥 풀세트

**Prompt** (v1.12 v3):
```
A modern mobile casual game illustration of a small Korean traditional market grain shop
storefront (Korean 곡물상), slight three-quarter view. The shop is a small friendly stall with a
simple wooden counter at the front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of a grain sack
silhouette (grain tan #D8A86A single fill, trapezoid shape, ~60-70% of signboard area) + a SHORT
English minimal text label "GRAIN" below the icon (simple sans-serif, all-caps, ~20-25% area,
legible).

At the shop front: 3 simple burlap-style grain sacks arranged on the wooden shop counter and in
a simple wooden display box at the front (trapezoid silhouette shapes, modern flat clean — NO
burlap weave texture, NO heavy detail). Vary the tones: one grain tan #D8A86A sack (rice / 쌀),
one warm brown #A67049 sack (mixed grain / 곡물), and a small accent red bean sack (#A8413A,
red bean / 팥). Optional: a wooden scoop or measure resting on top of one sack. The signature
category color is grain tan with warm brown + red bean accent for tonal variety.

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty
(NO people, NO shop owner, NO customers, NO market lanterns hanging from the roof, NO onggi
pottery jars added).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading. Vibrant saturated colors at 80-90 percent saturation, warm/cool palette
balance (warm wood counter + warm grain tan balanced by cool sage bg + dark black tile roof).

[STYLE_SUFFIX_BG]

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (grain sacks signature in 3 tones,
wooden display box, GRAIN signage, small shop counter, Cool Sage bg) are RETAINED EXACTLY as in
v1.2. Do NOT add extra elements: NO hanging lanterns, NO full hanok side posts, NO onggi pottery
jars (v1.2 grain shop had none — do not add multiple onggi jars), NO deep eave overhang shadow
band, NO extra traditional Korean props. Just the v1.2 base + tile roof swap. Vary the grain
sack tones with tan, warm brown and a small red bean sack accent to avoid an all-tan flat look.
Burlap sacks are simple geometric trapezoid shapes with minimal detail (NO burlap weave texture,
NO vintage scrapbook). The signboard text is English only ("GRAIN"), absolutely NO Korean text
(한글), NO Chinese characters (한자), NO Japanese kana/kanji. Background MUST be solid Cool
Sage #C8D5C0, NO beige, NO cream, NO scrapbook, NO vintage paper texture, NO golden hour.
```

**Reference image upload 권장**: BG-01 v3 best 첨부 → "이 reference와 같은 minimal feel + 기와 지붕 일관성으로 곡물상을. v1.2 base 그대로 + 기와 지붕만."

**DALL-E 약점 회피 노트 (v1.12 v3)**:
- **risk HIGH — v2 옹기 prominent 재누수**: v2에서 옹기 2-3개 prominent 추가됐었으므로 ChatGPT가 학습 효과로 옹기 재추가 가능. → "NO onggi pottery jars (v1.2 grain shop had none — do not add multiple onggi jars)" explicit 강제.
- **risk HIGH — 전체 tan 단조**: 곡물상은 grain tan dominant → 시각적 단조. → "vary the tones with tan, warm brown, red bean accent" 강제.
- **risk HIGH — 마대 weave detail 폭주**: "modern flat clean, simple geometric trapezoid, NO burlap weave texture" 강제.
- **risk HIGH — 천막 회귀 / 한글 누수 / 베이지 누수**: BG-01 동일.

**Reroll 트리거** (follow-up, v1.12 v3):
- 옹기 추가 누수 (v1.2 곡물상 옹기 X): "이 이미지를 다시 그려줘. 옹기 항아리 완전 제거. 곡물상은 v1.2 base에서 옹기가 없는 가게 — 곡식 자루 3종만 카테고리 시그니처."
- 전체 tan 단조: "이 이미지를 다시 그려줘. tan, warm brown, red bean의 다양한 톤으로 grain sack 컬러 variety."
- 마대 weave detail 폭주: "이 이미지를 다시 그려줘. burlap sack을 simple geometric trapezoid shape, modern flat clean, weave texture 완전 제거."
- 천막 회귀 / 한옥 풀세트 재누수 / 한글/한자 / 베이지 / 카테고리 시그니처 누락: BG-01과 동일 reroll trigger

### BG-05 — 잡화점 🫙 (v1.12 v3 v1.2 base + 기와 지붕, sauces 시그니처)

**시그니처 (카테고리)**: Jang Brown `#7A5238` + sauce 항아리/병 4개 진열 + 고추 hanging 우측 + 가게 카운터 (v1.2 base signature 전체 유지)
**v3 단일 fix**: 천막 → 검정 기와 곡선 지붕

**식별 핵심 시각 요소 (v1.12 v3, 5개)**:
1. **검정 기와 곡선 지붕 (단일 layer)** — dark slate/black curved eave tile, 와당 옵션. NOT 한옥 풀세트.
2. **카테고리 시그니처 진열 (v1.2 base 유지)** — 4 Korean sauce jars/pots displayed in a row on the wooden counter or shelf (간장/된장/고추장/참기름 silhouette, jang brown `#7A5238` dominant + 1 gochu red 고추장 + 1 amber 참기름 for tonal variety) + 우측 dried red chili peppers (고추) bundle hanging from simple hook (v1.2 base signature)
3. **작은 가게 카운터 + signboard** — wooden counter + signboard: amber sauce jar icon + "SAUCES" English text minimal
4. **Cool Sage `#C8D5C0` solid bg**
5. **No extras** — NO 큰 prominent 옹기 ground level (v1.2 잡화점은 sauce 항아리 진열이 시그니처이지 옹기 prominent 아님), NO 한옥 풀세트, NO lantern, NO wooden stool prop, NO 절구

**Prompt** (v1.12 v3):
```
A modern mobile casual game illustration of a small Korean traditional market sauce / seasoning
shop storefront (Korean 잡화점 / 양념가게 — selling Korean fermented sauces and seasonings),
slight three-quarter view. The shop is a small friendly stall with a simple wooden counter at the
front.

Above the shop front, a CURVED BLACK CERAMIC TILE ROOF (Korean traditional hanok 기와 eave roof,
dark slate gray to black single fill, gently upward-curving eave silhouette at the corners with
2-3 small white circular eave-end tile caps 와당 along the tips) sits as a slim topmost band.
The roof is a SINGLE simple layer — NOT a full hanok structure with side posts, NOT a deep eave
overhang. ABSOLUTELY NO striped awning, NO red and green stripes, NO tarp canopy, NO tent canopy.

Just below the tile roof, a small rectangular wooden signboard (warm brown #A67049) is mounted
at the top of the shop front. The signboard shows a LARGE simple flat icon of an amber/brown
sauce jar or bottle silhouette (jang brown #7A5238 single fill, ~60-70% of signboard area) + a
SHORT English minimal text label "SAUCES" below the icon (simple sans-serif, all-caps, ~20-25%
area, legible).

At the shop front: 4 Korean sauce jars / pots displayed in a clean row on the wooden shop counter
or a small wooden display shelf (modern flat geometric jar/pot silhouettes, varying sizes,
representing 간장 soy sauce / 된장 fermented soybean paste / 고추장 red chili paste / 참기름
sesame oil). Color the jars with jang brown #7A5238 dominant + 1 accent gochu red #F23E3E pot
(고추장) + 1 amber/golden #C8923C pot (sesame oil) for tonal variety. Each jar has a bold outline
and a small lid silhouette on top.

On the right or above the counter, a small bundle of dried red chili peppers (고추) hangs as a
simple silhouette accent (gochu red #F23E3E, modern flat shape, slim string holding them
together — v1.2 base signature).

A small price tag appears as a solid block placeholder (NO readable text). The shop is empty
(NO people, NO shop owner, NO customers, NO market lanterns hanging from the roof).

Background is solid Cool Sage #C8D5C0 (cool tone solid bg, modern flat clean).

Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading on the wooden counter + signboard + jars. Vibrant saturated colors at
80-90 percent saturation, warm/cool palette balance (warm wood counter + warm amber jars + warm
red chili balanced by cool sage bg + dark black tile roof). The jang brown signature category
color dominates with red accent.

[STYLE_SUFFIX_BG]

Important also: the only NEW element added from v1.2 base is the CURVED BLACK CERAMIC TILE ROOF
replacing the striped awning. All other v1.2 base elements (4 sauce jars row signature, dried
chili pepper bundle hanging accent, SAUCES signage, small shop counter, Cool Sage bg) are
RETAINED EXACTLY as in v1.2. Do NOT add extra elements: NO hanging lanterns, NO full hanok side
posts, NO additional huge onggi pottery jars on the ground beyond what v1.2 already had (v1.2
base sauces shop signature was the 4 small jars on the counter, NOT giant prominent ground onggi),
NO deep eave overhang shadow band, NO wooden stool prop, NO extra traditional Korean décor.
Just the v1.2 base + tile roof swap. The sauce jars are simple modern flat silhouettes, NOT
realistic glass bottle photography. The signboard text is English only ("SAUCES"), absolutely
NO Korean text (한글), NO Chinese characters (한자), NO Japanese kana/kanji. NO mortar and pestle
(절구) anywhere — this is LOCK from art-style-guide §5. Background MUST be solid Cool Sage
#C8D5C0 (cool tone), absolutely NO beige sky, NO cream warm sky, NO scrapbook, NO vintage paper
texture, NO storybook tone, NO golden hour sunset warm lighting.
```

**Reference image upload 강력 권장**: BG-01 v3 best 첨부 → "이 reference와 같은 minimal feel + 기와 지붕 + 가게 카운터 일관성으로 잡화점을. sauce 항아리 4개 + 고추 hanging이 시그니처, v2의 옹기 prominent + lantern은 절대 추가하지 않음."

**DALL-E 약점 회피 노트 (v1.12 v3)**:
- **risk CRITICAL — v2 옹기 prominent 재누수**: v2에서 BG-05 옹기 1-2개 prominent ground placement 추가 + wooden stool 추가됐었으므로 ChatGPT 학습 효과로 재추가 가능. → "NO additional huge onggi pottery jars on the ground beyond what v1.2 already had", "NO wooden stool prop" explicit 강제. v1.2 base 잡화점 시그니처는 **카운터 위 sauce 항아리 4개** + **고추 hanging**이지 ground 옹기 prominent 아님.
- **risk CRITICAL — 베이지/vintage 누수**: 잡화점은 reference 참기름 방앗간 톤 누수 risk 여전히 가장 높음. → "Cool Sage #C8D5C0 background, absolutely NO beige sky, NO cream warm sky, NO scrapbook, NO vintage paper, NO storybook" 강제.
- **risk HIGH — 절구 (mortar) 누수**: art-style-guide §5 LOCK. ChatGPT가 한식 양념가게 → 절구 추론. → "NO mortar and pestle (절구) anywhere" 강제.
- **risk HIGH — 한글 누수, 천막 회귀, 한옥 풀세트 재누수**: BG-01 동일.
- **risk MED — Chinese/Japanese ceramic 누수 (sauce jars)**: → "modern flat geometric jar silhouette, NOT realistic glass bottle photography, NOT Chinese vase, NOT blue-and-white porcelain" 강제.

**Reroll 트리거** (follow-up, v1.12 v3):
- 옹기 prominent 재누수 (v1.2 잡화점 ground 옹기 X): "이 이미지를 다시 그려줘. ground level prominent 옹기 항아리 완전 제거. 잡화점 v1.2 base 시그니처는 카운터 위 sauce 항아리 4개 진열 + 우측 고추 hanging — 큰 ground 옹기 없음."
- wooden stool 누수: "이 이미지를 다시 그려줘. wooden stool prop 완전 제거. v1.2 base에는 stool 없음."
- 베이지/vintage 누수 (CRITICAL): "이 이미지를 다시 그려줘. 배경을 solid Cool Sage #C8D5C0 (cool tone)으로 명확히. 베이지/cream/vintage paper/storybook/golden hour 톤 완전 제거."
- 절구 누수: "이 이미지를 다시 그려줘. 절구 (mortar and pestle) 완전 제거, sauce 항아리 4개 진열만 카테고리 시그니처로."
- 천막 회귀 / 한옥 풀세트 재누수 / 한글/한자 / 카테고리 시그니처 누락: BG-01과 동일 reroll trigger

---

### 4.6 v1.2 archive (deprecated, 2026-05-28)

> v1.2 BG-01~05 본문 (2026-05-27 commit 7a6cffb lock candidate)은 사용자 정통 한식 가게 reference (참기름 방앗간) 시각 분석 후 **invalidate**. 한옥 양식 / 검정 기와 / 처마 / 옹기 / lantern 5건의 한식 정통 요소가 누락된 modern Western-style storefront base였음 → v1.11 V2에서 한식 정통 요소 통합. v1.2 본문 핵심 = (1) 가게당 awning solid 시그니처 색 + 1 accent trim band (이탈리아 회피) / (2) 단순 wooden stall rectangle (slim grain) / (3) cool tone sky bg / (4) 1-2 large simple category icons / (5) no people. v1.11 V2가 (1) awning → 검정 기와 곡선 지붕으로 대체 / (2) wooden stall → 한옥 frame으로 확장 / (3) Cool Sage bg LOCK 유지 / (4) category icons + 한옥 정통 4 요소 추가 / (5) no people LOCK 유지. v1.2 본문 전체는 git history (prompts-library.md v1.10 §4 BG-01~05) 참조.

#### v1.2 → v1.11 V2 핵심 diff 요약

| 요소 | v1.2 (deprecated) | v1.11 V2 (사용자 reference 차용) |
|------|-------------------|---------------------------|
| 시점 | front-facing or slight three-quarter, eye-level | slight 7/8 isometric three-quarter (game environment depth) |
| 외관 | 단순 wooden stall rectangle + awning + cool sky bg | 한옥 wooden post-and-beam frame + 검정 기와 곡선 지붕 + 처마 + 와당 accent |
| 천막 (awning) | 가게당 솔리드 시그니처 색 + 1 accent trim band (이탈리아 회피) | **deprecated** (천막 없음). 대신 한옥 검정 기와 지붕이 시그니처 architectural element |
| 간판 | small price tag solid block placeholder | **큰 wooden signboard** centered above shop opening + icon-first English minimal (GREENGROCER / BUTCHER / FISHMONGER / GRAIN SHOP / GENERAL GOODS) |
| 옹기 항아리 | BG-05 잡화점에만 1개 | **5가게 모두 ground level 1-2개** (BG-04/BG-05는 2-3개 prominent) |
| Hanging lantern | 0건 | **5가게 모두 입구 양쪽 2개** (warm yellow glow) |
| 배경 | cool tone sky (soft mint / pastel teal / cool gradient) | Cool Sage `#C8D5C0` solid LOCK (5가게 통일, cross-shop one-market identity) |
| 카테고리 시그니처 | 1-2 large simple category icons | **유지** (5가게 카테고리 시그니처 모두 v1.2 LOCK 그대로 — 청과 cabbage/apple, 정육 meat/cutting board, 어물 fish/ice, 곡물 grain sack, 잡화 seasoning bottles) |
| 회피 LOCK | 베이지/scrapbook/Italian flag awning/mortar/Cookie Run | **유지** + 추가 (한글/한자/카타카나, Chinese pagoda, Japanese irimoya, 베이지 reference의 cream/vintage 누수) |

---

### 4.7 v1.11 v2 archive (deprecated, 2026-05-28)

> v1.11 v2 BG-01~05 본문 (2026-05-28 한옥 풀세트 — 한옥 frame + 검정 기와 + 깊은 처마 + 옹기 5가게 prominent + lantern 5가게 양쪽 + 와당 풀세트)은 사용자가 결과 시각 확인 후 **"너무 많음"** 진단 + verbatim "**기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고**" 명시 → **invalidate**. v1.12 v3 minimal에서 v1.2 base 회복 + 천막→기와 지붕 단일 fix로 supersede.
>
> v1.11 v2 본문 핵심 = (1) 한옥 양식 외관 (warm brown 목조 vertical posts 양쪽 + horizontal beam) / (2) 검정 기와 곡선 지붕 + 깊은 처마 overhang / (3) 큰 wooden signboard with icon-first 영어 minimal / (4) 옹기 항아리 5가게 공통 ground level (BG-04/BG-05는 2-3개 prominent) / (5) hanging lantern 2개 양쪽 (warm yellow #FFC81F glow) / (6) Cool Sage `#C8D5C0` solid bg / (7) signage = "GREENGROCER" / "BUTCHER" / "FISHMONGER" / "GRAIN SHOP" / "GENERAL GOODS". v1.12 v3에서 (1)/(2)/(4)/(5) 폐기, (3)/(6)/(7) 유지하되 signage 영어를 v1.2 base인 PRODUCE/BUTCHER/SEAFOOD/GRAIN/SAUCES로 환원. v1.11 v2 본문 전체는 git history (prompts-library.md v1.11 §4 BG-01~05) 참조.

#### v1.11 v2 폐기 사유 (verbatim, 2026-05-28)

사용자가 v1.11 v2 결과 5장 시각 확인 후 verbatim 명시:

> "기존버젼에서 다른거는 다 그대로 하고 기와 지붕으로만 바꾸자 천막 없애고"

main thread 해석: v2의 한옥 풀세트 (옹기 + lantern + 목조 한옥 frame + 처마 풀세트)는 **너무 많음**. 사용자는 **v1.2 base의 minimal feel을 유지**하면서 **천막 → 검정 기와 지붕** 단일 fix만 원함. 따라서 v3 minimal patch에서:
- v2 추가 요소 (옹기 5가게 / lantern 5가게 / 목조 frame / 깊은 처마 풀세트) **모두 폐기**
- v1.2 base 회복 (채소/meat/fish/곡식/sauce 카테고리 시그니처 + 작은 가게 카운터 + icon+영어 signage + Cool Sage bg)
- **천막 → 검정 기와 곡선 지붕 단일 layer만** 추가 (한옥 frame 풀세트는 포함하지 않음)

#### v1.11 v2 → v1.12 v3 핵심 diff 요약

| 요소 | v1.11 v2 (deprecated) | v1.12 v3 (사용자 R2 minimal fix) |
|------|----------------------|-------------------------------|
| 천막/지붕 | 검정 기와 + 처마 + 목조 한옥 frame 풀세트 (한옥 양식 전면 도입) | **검정 기와 곡선 지붕만** (단일 layer, 한옥 frame 없음) |
| 옹기 항아리 | **5가게 모두에 추가** (ground level 1-2개, BG-04/BG-05는 2-3개 prominent) | **v1.2 그대로 유지** (BG-01만 좌측 2개, 나머지 BG-02~05는 추가 안 함) |
| Hanging lantern | 양쪽 2개 5가게 모두 추가 (warm yellow glow) | **추가 안 함** (v1.2 그대로) |
| 한옥 목조 frame | 양쪽 vertical wooden posts + horizontal beam 풀세트 | **추가 안 함** (v1.2 그대로) |
| 깊은 처마 (eave overhang) | the roof overhangs the shop opening, creating a subtle shadow band | **추가 안 함** (단순 기와 layer만) |
| 와당 (eave-end tile cap) | 풀세트 명시 | **optional 2-3개만** (시그니처 accent로 minimal) |
| 시점 | slight 7/8 isometric three-quarter (game environment depth) | **slight three-quarter angle만** (NOT 7/8 strict isometric, NOT 깊은 perspective) |
| 카테고리 시그니처 (채소/meat/fish/곡식/sauce) | 명확 visible (유지) | **v1.2 그대로 유지** (BG-01 채소 stack + 좌측 옹기 2개 + 우측 hanging, BG-02 meat hanging + cutting board, BG-03 fish hanging + ice, BG-04 grain sacks 3종, BG-05 sauce 항아리 4개 + 고추 hanging) |
| 영어 signage | GREENGROCER / BUTCHER / FISHMONGER / GRAIN SHOP / GENERAL GOODS | **v1.2 base 환원**: PRODUCE / BUTCHER / SEAFOOD / GRAIN / SAUCES |
| Cool Sage bg + modern saturated | LOCK | LOCK 무변경 |
| icon+영어 minimal signage | LOCK | LOCK 무변경 |
| mortar 회피 | LOCK | LOCK 무변경 |

---

## 5. M1 Sprint — 음식 12 Anchor Prompts (v1.3 신설)

### 5.1 개요

> **범위**: Final 12 음식 × hero shot plated dish 1장 = 12장. Stage 3 식탁 완성형 중심.
> **공유 anchor**: F-01 (Ramyeon, FTUE 2순위) 또는 F-02 (Hotteok, FTUE 1순위) 중 하나를 **음식 anchor 시드**로 lock → 나머지 11장 prompt에 reference image upload.
> **도구**: ChatGPT (캐릭터·환경 anchor와 동일 — style suffix 정합으로 cross-호환).
> **공통 suffix**: §2.4 STYLE_SUFFIX_FOOD 모든 prompt 끝에 부착.
> **i18n**: 모든 prompt는 **icon-first English minimal** 원칙 — 음식 이름 영어 표기, 한글 prompt 회피 (DALL-E Korean weakness + global UX).

### 5.1.1 생성 순서 권장

> **원칙**: 단순한 음식 / 한식 식별 risk 낮은 음식부터 → 어려운 음식 / risk 높은 음식 후순위. 첫 anchor lock 후 reference upload로 일관성 ↑.

| 순서 | 슬롯 | 음식 (English) | Tier | 난도 | 권장 사유 |
|-----|------|---------------|------|------|----------|
| 1 | F-01 | Ramyeon | T1 | 쉬움 | 시각 단순 (그릇 + 면 + 국물 + 노른자), **anchor 시드 1순위** (글로벌 SS 인지도) |
| 2 | F-02 | Hotteok | T1 | 쉬움 | 단순 disc + 흑설탕 dot, 한식 단독 카테고리 (FTUE 1순위, 일/중식 누수 risk 낮음) |
| 3 | F-04 | Tteokbokki | T1 | 중간 | 빨간 사각 + 흰 떡 cylinder — K-food 글로벌 시그니처 |
| 4 | F-05 | Kimchi Fried Rice | T1 | 중간 | 김치 빨강 + 노른자 hero — **중식 fried rice 누수 risk 주의** |
| 5 | F-07 | Haemul Pajeon | T1 | 중간 | 둥근 disc + 녹색 파 + 새우 1마리 — 일본식 오코노미야키 누수 risk 주의 |
| 6 | F-09 | Kimchi Jjigae | T2 | 중간 | 검정 뚝배기 + 빨간 국물 + 두부 — **중식 hot pot 누수 risk 주의** |
| 7 | F-10 | Sundubu Jjigae | T2 | 중간 | 검정 뚝배기 + 순두부 + 노른자 — 김치찌개와 페어 |
| 8 | F-03 | Kimbap | T1 | 어려움 | **일본 maki sushi 누수 risk HIGH** — 김밥 단면 컬러 5종 + 검정 김 cylinder |
| 9 | F-08 | Bibimbap | T2 | 어려움 | 5~6 컬러 section 방사형 + 노른자 — composition 복잡 |
| 10 | F-11 | Japchae | T2 | 어려움 | **중식 lo mein 누수 risk HIGH** — 당면 swirl + 컬러 채소 dot |
| 11 | F-06 | Korean Corn Dog | T1 | 어려움 | **미국 corn dog 누수 risk HIGH** — 모짜렐라 stretch + 케첩 zigzag로 한국화 강조 |
| 12 | F-12 | Galbi-gui | T2 | 가장 어려움 | **일본 야키니쿠 누수 risk HIGH** — 갈비뼈 형태 + 양념 윤기 + 한국식 그릴/접시 |

> **anchor 시드 채택**: F-01 (Ramyeon) lock 후 그 image를 11장 prompt에 reference upload + "이 reference 음식 카드와 같은 plate/bowl 스타일, outline, bg, saturation 톤" follow-up.

---

### 5.2 음식 12 Anchor Prompts (F-01~F-12)

#### F-01 — Ramyeon (라면, T1, anchor 시드 1순위)

**English title**: Korean Ramyeon (Spicy Noodle Soup)

**식별 핵심 시각 요소**:
- 흰 둥근 broth bowl (한식 백자, NOT 일본식 검정 ramen 그릇)
- 노란 wavy egg noodles 면 (꼬불꼬불, NOT 일본 라멘 직선 면)
- 빨간 spicy gochugaru broth 국물 (오렌지-레드 톤, NOT miso 갈색 / NOT 돈코츠 흰색)
- 중앙 노른자 1개 (sunny-side-up egg 또는 raw yolk)
- 녹색 spring onion (파) 송송 dot 3~5개
- accent: 빨간 고추 slice 1~2개 (선택)

**Tier 1 단서 (1인분 단순)**: bowl 1개, garnish 2~3종만, side dish 없음.

**Prompt** (v1.5 = v1 base 회복 + 면만 THIN delicate):
```
A modern mobile casual game food card illustration of Korean Ramyeon (spicy noodle soup), top-down view.
A white round porcelain bowl (Korean baekja style, clean white, NOT black Japanese ramen bowl) is filled
with vibrant orange-red spicy gochugaru broth. THIN delicate yellow wavy curly egg noodles
emerge from the broth in a soft swirl (Korean instant ramyeon style,
NOT straight Japanese ramen noodles).
A single sunny-side-up egg with a bright yellow yolk sits in the center.
3-5 small green spring onion (pa) chopped dots float on the surface as garnish.
One small red chili pepper slice as accent (optional).
Single subtle ambient ellipse shadow under the bowl.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Ramyeon (spicy instant noodle soup), NOT Japanese ramen,
NOT miso ramen, NOT tonkotsu, NOT shoyu. The broth is bright vibrant orange-red (gochugaru spicy),
NOT brown miso, NOT pale white tonkotsu. The noodles are visibly curly wavy yellow,
NOT straight thin Japanese ramen noodles, NOT thick chunky udon-style strands.
The bowl is clean white Korean baekja, NOT a black Japanese donburi bowl with bamboo accents.
NO narutomaki pink spiral fish cake, NO nori seaweed sheet on top, NO chashu pork slices.
```

**DALL-E 3 약점 회피 노트**:
- **risk H — Japanese ramen 누수** (가장 큰 risk): bowl 검정 + 직선 면 + miso/tonkotsu broth + narutomaki/chashu 추가 경향. → 본문에 "Korean Ramyeon", "curly wavy yellow noodles", "white baekja bowl", "vibrant orange-red gochugaru broth" 강제 + negative에 narutomaki/nori/chashu/Japanese bowl 명시.
- broth 색 누수: ChatGPT default가 miso 갈색 또는 tonkotsu 흰색으로 빠짐. "bright vibrant orange-red" 반복 강조.

**Reroll 트리거** (follow-up):
- 일본 ramen 누수: "이 이미지를 다시 그려줘. Korean Ramyeon으로 명확히 — 흰 백자 bowl + 꼬불꼬불 curly yellow noodles + 빨간 spicy gochugaru broth. NOT Japanese ramen, NOT miso, NOT tonkotsu, NOT narutomaki, NOT chashu, NOT nori sheet."
- 면 직선 누수: "이 이미지를 다시 그려줘. 면을 visibly curly wavy (꼬불꼬불 Korean instant ramyeon style)로, 절대 직선 thin noodles 아님."
- broth 갈색/흰색 누수: "이 이미지를 다시 그려줘. broth를 bright vibrant orange-red (gochugaru spicy)로 강조."

---

#### F-02 — Hotteok (호떡, T1, FTUE 1순위)

**English title**: Hotteok (Korean Sweet Pancake with Brown Sugar Filling)

**식별 핵심 시각 요소**:
- 갈색 golden-brown round disc 1~2개 (pan-grilled flat circle)
- 중앙 brown sugar/cinnamon filling 흘러나오는 dark dot/swirl
- 살짝 fluffy 부드러운 edge (구운 자국 일부)
- 흰 작은 접시 또는 종이 cup (한식 시장 호떡 종이 컵)
- accent: 깨/견과류 dot 1~2개 (선택)

**Tier 1 단서**: disc 1~2개만, 접시 단순.

**Prompt** (v1.5 = v2 contained filling + 표면 topping syrup drizzle 추가):
```
A modern mobile casual game food card illustration of Korean Hotteok (sweet pancake), 7/8 top-down view.
A golden-brown round flat disc (one or two stacked) sits on a small white plate or a simple paper cup
(Korean street market style). The disc has a slightly chewy edge with subtle grill marks.
In the center top, a tiny hint of dark brown sugar filling barely peeks through a small slit
in the surface — the filling is mostly contained INSIDE the disc, only a small dark dot or thin sliver
of brown sugar visible at the slit (realistic Hotteok appearance — the filling is enclosed, not pouring out).
On the golden-brown surface of the disc, a small drizzle of glossy dark brown sugar syrup
is gently swirled on top as a finishing touch (a light decorative drizzle, like syrup on a pancake,
a thin glossy ribbon resting on the surface, NOT a flood, NOT pouring out from inside,
NOT a large pool, just a delicate topping accent).
Optional: 1-2 small chopped peanut or sesame dots scattered on top as accent.
Single subtle ambient ellipse shadow under the plate.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Hotteok (street market sweet pancake with brown sugar filling),
NOT a Western pancake stack with maple syrup, NOT a Chinese cong you bing (scallion pancake),
NOT a Japanese dorayaki (red bean filled). The brown sugar filling is mostly CONTAINED INSIDE the disc,
with only a tiny hint peeking through a small slit — NO excessive syrup overflow from the slit,
NO molten lava-like outpour from inside, NO large pool of syrup pooled on the plate,
NO sauce flooding out of the disc interior.
The small syrup drizzle on top is okay as a separate topping accent (like pancake syrup decoration,
visually distinct from the contained filling — the topping drizzle rests on the surface,
the filling stays enclosed inside).
The filling is brown molten sugar (barely visible at the slit), NOT chocolate, NOT cream.
The disc has a chewy fried golden-brown surface, NOT fluffy soufflé style.
```

**DALL-E 3 약점 회피 노트**:
- **risk L** — 한식 단독 카테고리, 누수 risk 낮음.
- minor risk: Western pancake stack로 빠질 수 있음 (높게 쌓인 형태). "single flat disc" 강조.
- minor risk: Chinese cong you bing (파전 회피)으로 빠질 수 있음. "sweet brown sugar filling" 강조.

**Reroll 트리거** (follow-up):
- Western pancake stack 누수: "이 이미지를 다시 그려줘. single flat disc (or 2 stacked max)로, 절대 높게 쌓인 American pancake stack with maple syrup 아님."
- 단맛 filling 안 보임: "이 이미지를 다시 그려줘. 중앙에 dark molten brown sugar filling을 oozing 형태로 명확히 보이게."

---

#### F-03 — Kimbap (김밥, T1, 일본 maki 누수 risk HIGH)

**English title**: Kimbap (Korean Seaweed Rice Roll)

**식별 핵심 시각 요소**:
- 검정 dried seaweed (gim) 외피 cylinder
- 단면 4~6개 컬러 dot section: 노란 단무지 + 주황 당근 + 녹색 시금치/오이 + 빨강 햄/소고기 + 흰 밥
- **김밥은 sushi maki보다 굵음** (지름 ~3cm vs maki ~2cm)
- 흰 작은 접시 또는 도마, 단순 plating
- accent: 깨 sprinkle dot 몇 개 + 흰 밥 외곽 일부 보이게

**Tier 1 단서**: roll 4~5개 단면 노출 (전체 cylinder 1개 분량), side 없음.

**Prompt** (v1.5 = v1 base 회복 + 밥알 FINE small fix):
```
A modern mobile casual game food card illustration of Korean Kimbap (seaweed rice roll), top-down view.
4-5 thick round slices of Kimbap arranged in a single row on a white plate or wooden board.
Each slice has a black seaweed (gim) outer ring with white rice with FINE small grains underneath
(Korean short-grain rice, tight uniform white field, individual grains barely visible,
NOT chunky oversized beads),
and a colorful cross-section center showing distinct ingredient blocks: yellow pickled radish (danmuji), orange carrot,
green spinach or cucumber, red ham or beef strips, and yellow egg strips.
The slices are THICK and ROUND (Korean Kimbap style, approximately 3cm diameter,
NOT thin compact Japanese maki sushi). A few sesame seed dots are sprinkled on top.
The plate or wooden board is clean and simple.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Kimbap (street market style with cooked vegetables and ham/beef),
NOT Japanese maki sushi (which uses raw fish and tightly compressed rice), NOT futomaki, NOT California roll.
Kimbap is THICKER and has more colorful vegetable cross-sections.
The rice grains are FINE and small (Korean short-grain, tight uniform field),
NOT chunky oversized rice grains, NOT lumpy clumpy rice, NOT visible giant rice beads.
The seaweed (gim) is matte dark green-black, NOT glossy shiny nori. NO raw salmon, NO raw tuna,
NO wasabi green paste, NO pink pickled ginger (gari), NO Japanese soy sauce dish with hashioki chopstick rest.
The rice is white short-grain Korean style, lightly seasoned with sesame oil (NOT vinegar sushi rice).
```

**DALL-E 3 약점 회피 노트**:
- **risk VERY HIGH — Japanese maki sushi 누수** (가장 큰 risk, ~70% default): ChatGPT는 "seaweed rice roll" → 100% Japanese sushi 추론. → 매우 명시적인 negative 필요: "NOT maki sushi, NOT futomaki, NOT California roll, NO raw fish, NO wasabi, NO gari" + 본문에 "Korean Kimbap thick (3cm diameter)", "matte gim", "cooked vegetables and ham" 강제.
- glossy nori 누수: "matte dark green-black gim" 명시.
- 단무지 노랑 빼먹기: "yellow pickled radish (danmuji)" 명시 — Kimbap 핵심 식별 요소.

**Reroll 트리거** (follow-up):
- Japanese maki sushi 누수: "이 이미지를 다시 그려줘. Korean Kimbap으로 명확히 — THICK roll (3cm 지름), matte gim (NOT glossy nori), cooked vegetables (NOT raw fish), yellow danmuji + orange carrot + green spinach + red ham 단면 명확. NO wasabi, NO gari, NO Japanese soy sauce dish."
- roll 너무 얇음: "이 이미지를 다시 그려줘. roll 지름을 더 THICK하게 (Korean Kimbap style ~3cm), 일본 thin maki 아님."

---

#### F-04 — Tteokbokki (떡볶이, T1, K-food 시그니처)

**English title**: Tteokbokki (Korean Spicy Rice Cakes)

**식별 핵심 시각 요소**:
- 흰 cylinder rice cakes (가래떡 잘린 형태, 통통한 손가락 굵기, 6~10개)
- 빨간 spicy gochujang sauce 진하게 코팅 (sauce가 떡 사이 흐름)
- 갈색 fish cake (어묵) 사각 slice 2~3개 추가 (선택)
- 녹색 spring onion dot 몇 개
- 흰 접시 또는 검정/빨간 분식점 plate
- 삶은 계란 1/2 또는 1개 (선택)

**Tier 1 단서**: 접시 1개, 떡 6~10개, garnish 2~3종.

**Prompt**:
```
A modern mobile casual game food card illustration of Korean Tteokbokki (spicy rice cakes), 7/8 top-down view.
On a clean white or pale celadon plate, 6-10 thick cylindrical white rice cakes (garaetteok, finger-thickness,
2-3cm long each) are coated generously in vibrant spicy red gochujang sauce.
The red sauce is thick and glossy, pooling around the rice cakes.
2-3 brown fish cake (eomuk) flat triangular slices are mixed in.
A few green spring onion chopped dots scattered as garnish.
Optional: one halved boiled egg as accent on the side.
Single subtle ambient ellipse shadow under the plate.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Tteokbokki (street market spicy rice cake stew),
NOT Chinese rice cake stir-fry (nian gao), NOT Japanese mochi.
The rice cakes are WHITE, THICK CYLINDRICAL (finger-shape, NOT flat oval Chinese nian gao,
NOT round mochi balls). The sauce is bright vibrant red gochujang (Korean chili paste),
glossy and thick (NOT brown soy-based, NOT clear broth).
NO Chinese chopsticks on a plate-side, NO Japanese bento box compartments.
```

**DALL-E 3 약점 회피 노트**:
- **risk M** — Chinese nian gao (flat oval rice cake) 누수 가능. "thick cylindrical finger-shape" 강조.
- sauce 묽음/갈색 누수: "thick glossy bright red gochujang sauce" 강조.
- 어묵 누락: "brown fish cake (eomuk) flat triangular slices" 명시.

**Reroll 트리거** (follow-up):
- 떡 모양 누수: "이 이미지를 다시 그려줘. rice cakes를 THICK CYLINDRICAL finger-shape (가래떡 잘린 형태)로, flat oval/round mochi 아님."
- sauce 색 누수: "이 이미지를 다시 그려줘. sauce를 bright vibrant red gochujang (Korean chili paste) thick glossy로 강조, brown soy-based 아님."

---

#### F-05 — Kimchi Fried Rice (김치볶음밥, T1, 중식 fried rice 누수 risk)

**English title**: Kimchi Bokkeumbap (Kimchi Fried Rice)

**식별 핵심 시각 요소**:
- 둥근 흰 밥 mound (위에 노른자 hero)
- 빨간 김치 조각 보이게 (작은 segment 4~6개)
- 중앙 sunny-side-up egg (노른자 노랑 강조)
- 녹색 spring onion sprinkle dot
- 검정 김 가루 (gim flakes) 살짝 sprinkle (선택)
- 흰 접시 또는 검정 cast iron pan (서빙 plate)

**Tier 1 단서**: 접시/팬 1개, 1인분 mound.

**Prompt** (v1.5 = v1 base 회복 + 밥알 FINE small fix):
```
A modern mobile casual game food card illustration of Korean Kimchi Fried Rice (Kimchi Bokkeumbap),
7/8 top-down view. A rounded mound of white rice with FINE small grains
(Korean short-grain rice, tight uniform field, individual grains barely visible,
NOT chunky oversized beads)
stained slightly orange-red from kimchi sauce sits on a white plate or in a small black cast iron pan.
Visible chopped red kimchi pieces (4-6 small segments) are mixed throughout the rice.
A bright sunny-side-up egg with a vivid yellow yolk sits on top of the rice as the hero element.
A scattering of green chopped spring onion dots and a light sprinkle of black gim (Korean seaweed) flakes as garnish.
Single subtle ambient ellipse shadow under the plate.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Kimchi Bokkeumbap (Kimchi Fried Rice),
NOT Chinese egg fried rice (which has green peas, diced carrots, tiny shrimp Western style),
NOT Japanese chahan, NOT Spanish paella.
The dominant flavor color is red-orange from kimchi (NOT brown soy fried rice).
The rice grains are FINE and small (Korean short-grain, tight uniform field),
NOT chunky oversized rice grains, NOT lumpy clumpy rice, NOT visible giant rice beads.
NO green peas, NO diced carrots in Western mirepoix style, NO Chinese soup spoon on the side,
NO bamboo plate, NO wok char-marks on the rice. The egg is sunny-side-up whole egg on top
(NOT scrambled mixed-in Chinese style).
```

**DALL-E 3 약점 회피 노트**:
- **risk HIGH — Chinese egg fried rice 누수**: ChatGPT default "fried rice" → 100% Chinese 추론. → 빨간 김치 색 + 노른자 + "red-orange dominant", "NOT Chinese fried rice", "NO peas/carrots Western style" 강제.
- 스크램블 egg mixed-in 누수: "sunny-side-up whole egg on top" 명시 (한식 hero placement).

**Reroll 트리거** (follow-up):
- 중식 fried rice 누수: "이 이미지를 다시 그려줘. Korean Kimchi Bokkeumbap으로 명확히 — red-orange kimchi 색 dominant + chopped red kimchi 조각 보이게, NO green peas, NO diced carrots Western style, NO Chinese soup spoon."
- egg 누수: "이 이미지를 다시 그려줘. egg를 sunny-side-up whole egg를 rice 위에 올리는 hero placement로 (한식 김치볶음밥 시그니처), 절대 scrambled mixed-in 아님."

---

#### F-06 — Korean Corn Dog (한국식 콘도그, T1, 미국 corn dog 누수 risk HIGH)

**English title**: Korean Corn Dog (Hot Dog with Cheese, Crispy Coated)

**식별 핵심 시각 요소**:
- 갈색 deep-fried 외피 (panko crumb texture 또는 sugar coating)
- 나무 막대 stick 1개 (아래로 손잡이)
- **모짜렐라 cheese stretch** (베어 문 자국 + 늘어나는 cheese strand 2~3 stretch line — 한국 콘도그 시그니처)
- 빨간 ketchup zigzag drizzle + 노랑 mustard zigzag drizzle (위 표면)
- 깨/설탕 sprinkle dot 일부 (선택)
- 작은 종이 cup 또는 종이 wrapper (street food style)

**Tier 1 단서**: corn dog 1개, garnish 2~3종.

**Prompt** (v1.5 = v2 base + cross-section 4요소 명확):
```
A modern mobile casual game food card illustration of Korean Corn Dog (Hot Dog), 7/8 view with stick visible.
A golden-brown deep-fried corn dog on a wooden stick is held cleanly by the stick with no paper wrapper,
displayed in a clean composition against the background (the stick handle is the only support, NO paper cup,
NO paper holder, NO awkward paper plate underneath).
The coating has visible crispy panko crumb texture (Korean corn dog style, NOT smooth American cornmeal batter).
A bite has been taken from the top, revealing a clear CROSS-SECTION showing all four signature elements:
(1) a brown cooked sausage (hot dog) at the core/center of the corn dog (the sausage body is clearly visible
as a distinct cylindrical brown shape in the middle),
(2) bright yellow mozzarella cheese filling surrounding the sausage with 2-3 stretchy cheese strands
pulling visibly upward from the bite mark (the signature Korean corn dog cheese pull),
(3) a golden-brown crispy panko crumb coating wrapping the outside (slightly bumpy texture, clearly distinct
from the cheese layer underneath),
(4) red ketchup zigzag drizzle and yellow mustard zigzag drizzle on top of the crispy outer surface.
Optional: a light sprinkle of sugar grains or sesame seeds as accent.

[STYLE_SUFFIX_FOOD]

Important also: this is KOREAN Corn Dog (street market style with sausage core + mozzarella cheese pull
+ crispy panko coating + ketchup/mustard zigzag), NOT American corn dog (which is smooth yellow cornmeal
batter wrapped around a plain hot dog, no cheese stretch). The visible cross-section showing distinct
sausage + cheese + panko coating layers is the ESSENTIAL identifying feature of Korean Corn Dog —
NO missing sausage core, NO cheese-only filling without sausage, NO ambiguous interior where
the layers blend together. The sausage must read as a clearly cooked brown hot dog cylinder at the center,
the mozzarella as a yellow stretchy layer around it, the panko as a bumpy golden-brown crust outside.
The coating is golden-brown panko crumb texture (slightly bumpy), NOT smooth yellow cornmeal.
NO awkward paper plate or paper holder underneath, NO weird paper wrapping at the base of the stick,
NO American county fair fairground basket, NO yellow batter dripping, NO Japanese kushiyaki skewer.
The composition is clean — only the corn dog and its wooden stick are visible against the solid background.
```

**DALL-E 3 약점 회피 노트**:
- **risk VERY HIGH — American corn dog 누수** (~80% default): "corn dog" 키워드 → 100% American cornmeal 추론. → "Korean Corn Dog with mozzarella cheese stretch", "crispy panko crumb coating", "ketchup AND mustard zigzag" 강제 + American cornmeal/county fair negative 명시.
- 치즈 stretch 누락: 한국 콘도그의 핵심 식별 요소. "visible mozzarella cheese pulled into 2-3 stretchy strands" 강조.

**Reroll 트리거** (follow-up):
- 미국 corn dog 누수: "이 이미지를 다시 그려줘. Korean Corn Dog으로 명확히 — visible mozzarella cheese stretch (2-3 stretchy strands) + crispy panko crumb coating + ketchup AND mustard zigzag drizzle. NOT American smooth cornmeal batter, NOT county fair style."
- 치즈 stretch 누락: "이 이미지를 다시 그려줘. 베어 문 자국 + 늘어나는 mozzarella cheese strand 2-3개를 명확히 보이게 (한국 콘도그 시그니처)."

---

#### F-07 — Haemul Pajeon (해물파전, T1, 일본 오코노미야키 누수 risk)

**English title**: Haemul Pajeon (Korean Seafood Scallion Pancake)

**식별 핵심 시각 요소**:
- 둥근 golden-brown 부침개 disc (큰 pancake, 접시 채우는 크기)
- 녹색 spring onion (대파) 길고 두꺼운 strip 다수가 위로 보임 (한식 파전 시그니처)
- 빨간 새우 (shrimp) 1마리 + 흰 오징어 ring 1~2개 (해물 시그니처)
- 살짝 crispy 갈색 edge
- 단순 접시 (백자 또는 분청 흰색)
- accent: 작은 dipping sauce 종지 (선택)

**Tier 1 단서**: pancake 1개 (8 cuts wedge로 나뉜 표현 OK), side 단순.

**Prompt**:
```
A modern mobile casual game food card illustration of Korean Haemul Pajeon (seafood scallion pancake),
top-down view. A large round golden-brown pan-fried pancake fills a clean white round plate.
Long thick green scallions (대파 daepa, Korean scallions, finger-length, multiple strips) AND red-pink shrimp
are MIXED INTO AND PARTIALLY SUBMERGED WITHIN the golden batter — the batter is the body of the pancake,
and the scallions and shrimp are integrated ingredients BAKED INTO the pancake itself (NOT laid on top after cooking).
The scallions and shrimp are partially visible above the surface but mostly embedded in the batter,
with batter visibly surrounding and covering parts of each ingredient (fully integrated as one cohesive pancake,
NOT a flat batter disc with separate toppings sitting on top).
1-2 white squid ring slices are also embedded similarly in the pancake.
The pancake edges are slightly crispy golden-brown (pan-fried texture, not deep-fried).
Optional: a small side dipping sauce dish (soy sauce with chili) on the corner.
Single subtle ambient ellipse shadow under the plate.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Haemul Pajeon (scallion-dominant savory pancake with seafood),
NOT Japanese okonomiyaki (which has shredded cabbage as dominant filling, mayo + bonito flakes + brown sauce on top),
NOT Chinese cong you bing (which is a layered flatbread with no seafood).
The scallions and shrimp are BAKED INTO the pancake batter (partially visible above the surface
but mostly embedded), NOT laid on top of a finished batter disc as separate toppings.
The visible green scallions integrated within the batter are the ESSENTIAL identifying feature.
NO mayo squiggle drizzle, NO bonito katsuobushi flakes dancing on top, NO brown okonomiyaki sauce,
NO Japanese aonori green seaweed powder, NO ingredients sitting on top of the pancake as separate toppings.
The pancake batter is light golden-brown, NOT dark brown American buttermilk pancake.
```

**DALL-E 3 약점 회피 노트**:
- **risk HIGH — Japanese okonomiyaki 누수**: ChatGPT default "Korean pancake with seafood" → okonomiyaki 추론 빈번. → "long green scallions dominant" 강조 + okonomiyaki negative (mayo/bonito flakes/brown sauce/aonori) 명시.
- 파(대파) 안 보임: 파전 핵심. "long thick green scallions visible across the entire pancake" 강조.

**Reroll 트리거** (follow-up):
- 일본 오코노미야키 누수: "이 이미지를 다시 그려줘. Korean Haemul Pajeon으로 명확히 — long thick green scallions (대파) 다수가 dominant 시각 요소로 보이게 + 새우 + 오징어 ring. NO mayo squiggle, NO bonito flakes, NO brown okonomiyaki sauce."
- 파 누락: "이 이미지를 다시 그려줘. 길고 두꺼운 green scallions (대파)를 pancake 전체에 가로지르는 dominant element로 명확히 보이게."

---

#### F-08 — Bibimbap (비빔밥, T2, composition 복잡)

**English title**: Bibimbap (Mixed Rice Bowl)

**식별 핵심 시각 요소**:
- 흰 stone/dolsot bowl 또는 백자 큰 그릇 (한식 큰 mixing bowl)
- 중앙 흰 밥 base
- 방사형 5~6 컬러 section: 노란 콩나물 + 녹색 시금치 + 주황 당근 채 + 갈색 고사리 + 빨간 김치 또는 양념고기 + 흰 무생채
- **중앙 노른자 1개** (raw 또는 sunny-side-up — Bibimbap hero)
- 빨간 gochujang 한 dollop 옆 (선택, 비비기 전)
- 깨 sprinkle

**Tier 2 단서 (2인분 풍성)**: 큰 bowl, 6 section 풍성, 노른자 + gochujang dollop 모두 표현.

**Prompt**:
```
A modern mobile casual game food card illustration of Korean Bibimbap (mixed rice bowl), top-down view.
A large clean white ceramic bowl (Korean baekja or pale celadon style) is filled with FINE small rice grains
in the center base (Korean short-grain rice, individual grains barely visible as a tight uniform white field,
NOT chunky oversized grains).
On top, 5-6 colorful vegetable sections are arranged in a beautiful radial pattern around the rice:
yellow soybean sprouts (kongnamul), bright green spinach (sigeumchi),
orange julienned carrot, brown braised fernbrake (gosari) or shiitake mushroom strips,
bright red kimchi or seasoned beef bulgogi, white pickled radish (musaengchae).
A single bright orange-yellow egg yolk (raw or sunny-side-up style) sits in the EXACT CENTER as the hero element.
A small dollop of bright red gochujang (Korean chili paste) on the side of the bowl rim.
A light sprinkle of sesame seeds. Single subtle ambient ellipse shadow under the bowl.
Tier 2 abundance: the 6 vegetable sections are generously portioned, bowl looks full and festive.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Bibimbap (mixed rice bowl with radial vegetable arrangement + center egg yolk),
NOT a Buddha bowl (Western health food), NOT a Chinese rice bowl (which has fewer vegetable sections),
NOT a Japanese donburi (which is a single topping on rice).
The rice grains are FINE and small (Korean short-grain, individual grains barely visible),
NOT chunky oversized rice grains, NOT lumpy clumpy rice, NOT visible giant rice beads.
The 6 colorful vegetable sections in radial arrangement + center egg yolk + gochujang dollop are the
ESSENTIAL identifying features of Bibimbap.
NO avocado slices, NO quinoa, NO Buddha bowl Western superfoods,
NO Japanese pickled umeboshi plum, NO bamboo chopsticks placed on top.
```

**DALL-E 3 약점 회피 노트**:
- **risk M — Western Buddha bowl 누수**: avocado/quinoa 추가 경향. → negative 명시.
- composition 복잡 — radial 6 section + 노른자 + dollop을 한 image에 다 표현 어려움. → "exact center", "radial pattern around the rice", "Tier 2 abundance" 명시.
- 노른자 누락 또는 mixed-in: "single bright orange-yellow egg yolk sits in the EXACT CENTER" 강조.

**Reroll 트리거** (follow-up):
- composition 부족: "이 이미지를 다시 그려줘. 5-6 vegetable section을 white rice 중앙 주위에 radial pattern (방사형)으로 명확히 분리해서 배치, 중앙에 노른자 hero."
- Western Buddha bowl 누수: "이 이미지를 다시 그려줘. Korean Bibimbap으로 명확히 — 노란 kongnamul + 녹색 spinach + 주황 carrot + 갈색 gosari + 빨간 kimchi/bulgogi + 흰 musaengchae 6 Korean section. NO avocado, NO quinoa, NO Western superfoods."

---

#### F-09 — Kimchi Jjigae (김치찌개, T2, 중식 hot pot 누수 risk)

**English title**: Kimchi Jjigae (Kimchi Stew)

**식별 핵심 시각 요소**:
- **검정 ttukbaegi (뚝배기) 한식 stone pot** — 한식 stew의 핵심 식별 (NOT 중식 hot pot)
- 빨간 spicy kimchi broth (진한 red-orange)
- 흰 두부 (tofu) 사각 block 2~3개 (위에 보이게)
- 김치 잎 chunks 2~3개 (빨간 김치 잎 형태)
- 갈색 pork belly slice 또는 흰 띠 (선택)
- 녹색 spring onion sprinkle
- 김 위로 살짝 (steam swirl 1~2 line, 선택)
- 검정 wooden trivet 또는 단순 base

**Tier 2 단서 (2인분 풍성)**: 큰 ttukbaegi, 두부 3개 + 김치 chunks 3개 + pork.

**Prompt**:
```
A modern mobile casual game food card illustration of Korean Kimchi Jjigae (kimchi stew), 7/8 top-down view.
A black Korean stone pot (ttukbaegi 뚝배기, the signature Korean stew vessel, rounded with a thick rim,
NOT a wide Chinese hot pot, NOT a Japanese donabe) is filled with bubbling vibrant red-orange spicy kimchi broth.
Inside the pot: 2-3 white tofu (dubu) square blocks visible at the surface,
2-3 red kimchi leaf chunks, optional 1-2 brown pork belly slices, scattered green spring onion dots on top.
1-2 subtle steam swirl lines rising from the surface (optional).
The pot sits on a simple dark wooden trivet or directly on the surface.
Tier 2 abundance: tofu 3 blocks + kimchi 3 chunks + pork visible, pot looks generously filled.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Kimchi Jjigae (kimchi stew in ttukbaegi stone pot),
NOT a Chinese hot pot (huoguo, which is a wide shallow pan with raw ingredients around),
NOT Sichuan mala soup, NOT Japanese nabe, NOT shabu-shabu.
The black ttukbaegi pot (rounded, thick rim, individual portion size) is the ESSENTIAL identifying feature.
The broth is bright vibrant red-orange (kimchi + gochugaru), NOT brown soy-based dashi,
NOT clear Sichuan mala oil layer. NO raw thin-sliced meat slices around the pot,
NO Chinese mala peppercorns floating, NO chopstick-held raw vegetables on the side.
```

**DALL-E 3 약점 회피 노트**:
- **risk HIGH — Chinese hot pot 누수**: ChatGPT default "Korean spicy stew" → 중식 hot pot 추론 빈번 (특히 raw ingredients around 추가). → "black ttukbaegi (rounded thick rim, individual portion)" 강제 + hot pot/mala/raw meat negative.
- 뚝배기 누락 (wide pan으로): "rounded thick rim, individual portion size" 명시.
- broth 색 누수 (간장 갈색): "bright vibrant red-orange (kimchi + gochugaru)" 강조.

**Reroll 트리거** (follow-up):
- 중식 hot pot 누수: "이 이미지를 다시 그려줘. Korean Kimchi Jjigae로 명확히 — 검정 ttukbaegi (rounded thick rim, individual portion size) 한식 stone pot + bright red-orange kimchi broth + 흰 두부 blocks. NOT Chinese hot pot, NO raw thin-sliced meat around, NO Sichuan mala peppercorns."
- ttukbaegi 모양 누수: "이 이미지를 다시 그려줘. pot을 black ttukbaegi (rounded shape, thick rim, deep bowl, individual portion)로 명확히, wide shallow hot pot 아님."

---

#### F-10 — Sundubu Jjigae (순두부찌개, T2, 김치찌개 페어)

**English title**: Sundubu Jjigae (Soft Tofu Stew)

**식별 핵심 시각 요소**:
- **검정 ttukbaegi (뚝배기) 한식 stone pot** (F-09와 페어 일관성)
- 빨간 spicy broth (gochugaru 기름 layer 표면 윤기)
- **흰 fluffy soft tofu mound** (sundubu — broken soft cloud-like, NOT firm block)
- 중앙 노른자 1개 (raw egg cracked, sundubu jjigae 시그니처)
- 작은 해산물 (조개 또는 새우) 1~2개 (선택)
- 녹색 spring onion sprinkle
- steam swirl 1~2 line

**Tier 2 단서 (2인분 풍성)**: 큰 ttukbaegi, soft tofu 풍성 + 노른자 + 해산물.

**Prompt**:
```
A modern mobile casual game food card illustration of Korean Sundubu Jjigae (soft tofu stew),
7/8 top-down view. A black Korean stone pot (ttukbaegi 뚝배기, same vessel style as Kimchi Jjigae,
rounded thick rim, individual portion) is filled with bubbling vibrant red-orange spicy gochugaru broth.
A generous mound of soft tofu broken into irregular cloud-like fluffy white curds
(sundubu signature appearance — like soft cottage cheese clumps or torn fluffy clouds,
organic uneven shapes with random soft edges and crevices, multiple small irregular white tofu fragments
floating and clumping together at the broth surface, NOT smooth puree, NOT firm cubes,
NOT mashed paste, NOT a single solid white block) dominates the center.
A bright orange-yellow raw egg yolk cracked on top (the signature sundubu jjigae feature).
1-2 small seafood pieces (a clam or shrimp) visible on the surface.
Green spring onion chopped dots scattered. 1-2 subtle steam swirl lines rising.
Tier 2 abundance: tofu mound is generously filled, egg yolk hero + seafood visible.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Sundubu Jjigae (soft tofu stew in ttukbaegi),
paired with Kimchi Jjigae as Korean stew family (use the same black ttukbaegi vessel style).
NOT Chinese mapo tofu (which uses firm tofu cubes in brown Sichuan sauce on a flat plate),
NOT Japanese yudofu (clear broth boiled tofu).
The tofu must appear as fluffy cloud-like irregular broken curds (like torn soft clouds or soft cottage cheese
clumps, organic uneven shapes), NOT smooth puree, NOT firm cubes, NOT mashed paste, NOT a single solid white block,
NOT geometric tofu pieces. The fluffy SOFT cloud-like tofu and the cracked raw egg yolk on top
are the ESSENTIAL identifying features.
The broth is bright vibrant red-orange (Korean gochugaru), NOT brown Sichuan mapo sauce.
NO Sichuan mala peppercorns, NO thick brown bean paste sauce, NO Chinese chili oil layer.
```

**DALL-E 3 약점 회피 노트**:
- **risk M — Chinese mapo tofu 누수**: ChatGPT default "Korean tofu stew" → mapo tofu 추론. → "fluffy cloud-like soft tofu (NOT firm block cube)" + "bright red-orange gochugaru (NOT brown Sichuan)" 강제.
- 노른자 누락: sundubu jjigae 시그니처. "cracked raw egg yolk on top" 강조.
- F-09 페어 일관성: 같은 ttukbaegi 사용. 같은 reference image upload 강력 권장.

**Reroll 트리거** (follow-up):
- 중식 mapo tofu 누수: "이 이미지를 다시 그려줘. Korean Sundubu Jjigae로 명확히 — 검정 ttukbaegi + fluffy cloud-like SOFT tofu (NOT firm block) + cracked raw egg yolk 중앙. NOT Chinese mapo tofu, NO brown Sichuan sauce."
- 두부 firm block 누수: "이 이미지를 다시 그려줘. tofu를 fluffy cloud-like broken soft curds (sundubu)로, 절대 firm block cube 아님."
- **두부 모양 어색 (v1.4 신설)**: "이 이미지를 다시 그려줘. tofu를 fluffy cloud-like irregular broken curds (like torn soft clouds or soft cottage cheese clumps, organic uneven shapes with random soft edges) 형태로 재작성, 절대 smooth puree나 firm cube나 mashed paste나 single solid block 아님. 여러 개의 작은 불규칙 fluffy 흰 두부 조각이 broth 표면에 떠 있고 뭉쳐있는 모양."

---

#### F-11 — Japchae (잡채, T2, 중식 lo mein 누수 risk HIGH)

**English title**: Japchae (Korean Glass Noodles)

**식별 핵심 시각 요소**:
- **갈색/투명 sweet potato glass noodles** (당면, dangmyeon) — 굵고 투명한 면 (Korean 잡채의 핵심 식별)
- 다채로운 컬러 채소 strips: 녹색 시금치 + 주황 당근 채 + 빨강 빨간 파프리카 + 흰 양파
- 갈색 양념고기 (소고기 strip, 선택)
- 검정 mushroom slice (목이/표고)
- 깨 sprinkle 강조 (Korean garnish)
- 흰 또는 분청 접시 (large plate, festive)

**Tier 2 단서 (2인분 풍성)**: 큰 접시, 면 풍성, 6+ vegetable color.

**Prompt**:
```
A modern mobile casual game food card illustration of Korean Japchae (sweet potato glass noodles),
top-down view. A large clean white or pale celadon plate is generously filled with THIN delicate translucent
brown-amber sweet potato glass noodles (dangmyeon 당면, slim shiny translucent strands like delicate threads,
NOT thick chunky strands, NOT thin yellow Chinese egg noodles, NOT white Italian pasta).
The noodles are mixed with vibrant colorful vegetable strips:
bright green spinach, orange julienned carrot, red bell pepper strips,
white onion strips, dark brown shiitake or wood ear mushroom slices.
2-3 brown seasoned beef bulgogi strips mixed in. A generous sprinkle of white sesame seeds on top
(Korean garnish signature). Single subtle ambient ellipse shadow under the plate.
Tier 2 abundance: plate is generously full, 6+ vegetable colors visible, festive holiday dish appearance.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Japchae (sweet potato glass noodles, holiday/festive Korean dish),
NOT Chinese lo mein (which uses yellow egg wheat noodles, brown soy sauce dominant),
NOT chow mein (crispy fried noodles), NOT Italian pasta (white wheat), NOT Pad Thai (orange-pink Thai sauce).
The translucent brown-amber GLASS NOODLES (dangmyeon, made from sweet potato starch) are the
ESSENTIAL identifying feature — they are THIN delicate, shiny, and see-through, unlike opaque wheat noodles.
The dangmyeon strands are slim and delicate (Korean japchae signature thickness),
NOT thick chunky strands, NOT rope-like noodles, NOT udon-style fat noodles.
The seasoning is light sesame oil + soy sauce (NOT thick brown Chinese sauce, NOT Thai tamarind).
NO Chinese chopsticks resting in the noodles, NO wok hei char marks, NO sriracha drizzle.
```

**DALL-E 3 약점 회피 노트**:
- **risk VERY HIGH — Chinese lo mein 누수** (~70% default): "stir-fried noodles with vegetables" → 100% 중식 lo mein/chow mein 추론. → "translucent brown-amber sweet potato glass noodles (dangmyeon)", "thick shiny see-through" 강제 + Chinese lo mein/wok hei negative 명시.
- 면 색 누수 (노란 wheat): "translucent brown-amber, NOT thin yellow egg noodles" 강조.
- 깨 garnish 누락: Korean japchae 시그니처. "generous sprinkle of white sesame seeds" 강조.

**Reroll 트리거** (follow-up):
- 중식 lo mein 누수: "이 이미지를 다시 그려줘. Korean Japchae로 명확히 — translucent brown-amber sweet potato GLASS noodles (dangmyeon, see-through 투명) + 6+ Korean vegetable colors + 흰 깨 generous sprinkle. NOT Chinese lo mein, NOT yellow egg noodles, NO wok hei char marks."
- 면 누수: "이 이미지를 다시 그려줘. 면을 translucent brown-amber see-through dangmyeon (sweet potato glass noodles)으로 thick shiny shape, 절대 opaque yellow wheat egg noodles 아님."

---

#### F-12 — Galbi-gui (갈비구이, T2, 정통 LA-style, v1.9 R7 LA-cut long strip + multiple cross-section bone discs + green scallion rounds + wire mesh grill grate + 7/8 perspective 5건 fix)

**English title**: Galbi-gui (Korean LA-style Grilled Short Ribs, Traditional LA-cut on Wire Mesh Grill Grate)

**식별 핵심 시각 요소** (v1.9 R7, 사용자 또 다른 reference image 기준 7 요소):
1. **LA-style long elongated strip form (v7 form 전면 교체)** — 4-6 large rectangular meat strips, 각 strip approximately **18-25cm long × 8-12cm wide × 0.5-0.8cm thick** (paper-thin appearance). R6 v6의 small square pieces grid form 완전히 폐기. R5 v5의 strip form과 비슷하지만 strip 자체가 더 큼 (single bone at TOP LONG EDGE 아님, cross-cut LA-style으로 회귀).
2. **multiple strips parallel arrangement (v7)** — 4-6 large rectangular strips arranged in a row (서로 옆으로 나란히), strips slightly overlap or sit side by side. NOT perfectly aligned grid (R6 폐기), 자연스러운 BBQ 배치.
3. **LA cross-cut bone discs along each strip's length (CRITICAL v7 signature)** — 각 strip의 길이 방향을 따라 **3-4 small round white bone cross-section discs** (각 disc ~1.5-2cm diameter, cream-white color). 이건 LA갈비의 정통 cross-cut 손질법 — 갈비뼈를 가로질러 자른 cross-section의 작은 둥근 흰 뼈 disc 여러 개가 strip 따라 evenly spaced (~3-5cm apart). R3 v3에서 한 번 시도됐다가 사용자가 폐기했지만, 이번 R7 reference는 정확히 그 패턴.
4. **매우 얇은 두께 (v6/v7 LOCK 유지)** — approximately **0.5-0.8cm thick (5-8mm)**, paper-thin appearance. R5/R6와 동일하게 얇음 (정통 LA갈비 butchery).
5. **표면 색깔 + char marks (v6/v7 LOCK 유지)** — dark brown caramelized + glossy soy-pear-garlic marinade glaze + 표면에 dark char marks/burned lines from grill (구운 자국). 칼집 (score marks)은 R7 reference에 명확히 보이지 않음 — char marks가 dominant. **칼집 (knife score marks)은 optional로 격하** (LA-cut form에서는 cross-cut bones이 시그니처이지 score marks가 아님 — 만약 표면에 보이면 OK, 없어도 PASS).
6. **garnish — 잘게 다진 green scallion rounds scattered (v7 fix)** — small round green spring onion slices (송송 sliced 대파 형태, 1-3mm 두께 disc, bright green color) scattered across meat surface. plus 깨 sprinkle (minor accent). R6의 chopped minced garlic dots 폐기 — green scallion rounds로 변경.
7. **둥근 metallic wire mesh grill grate context (v7 fix)** — round wire grate (회색/은색 metallic mesh) 위에서 굽고 있는 상태. 일부 reference에 hot coals (빨간 불꽃) under grate visible. plate context = **round metallic wire grill grate** (R4/R5/R6의 black cast iron plate → round wire mesh grate 우선).

**view angle (v7 fix)**: slight 7/8 perspective view (mostly top-down but slightly angled to show meat thickness side profile + grill grate depth). R6의 top-down view 폐기.

**Tier 2 단서 (2인분 풍성)**: 큰 wire mesh grate, 4-6 large LA-style strips parallel, 3-4 cross-section bone discs per strip, green scallion rounds scattered + 깨 sprinkle, char marks visible.

**Prompt** (v1.9 R7 = v6 base + form 전면 교체 (square pieces grid → LA-cut long strips) + bone form 재정의 (single long bone at short edge → 3-4 cross-section discs along each strip) + garnish 변경 (minced garlic → green scallion rounds) + plate 변경 (cast iron plate → wire mesh grill grate) + view angle 변경 (top-down → 7/8 perspective) 5건 fix):
```
A modern mobile casual game food card illustration of Korean LA-style Galbi-gui (traditional LA-cut
grilled short ribs on a Korean BBQ wire mesh grill grate), slight 7/8 perspective view (mostly
top-down but slightly angled to show meat thickness side profile + grill grate depth — the slight
7/8 angle reveals the THIN slice thickness (0.5-0.8cm) from the side, confirming the paper-thin
slice appearance).

Sitting on a ROUND METALLIC WIRE MESH GRILL GRATE (silver-gray wire grate, the traditional Korean
BBQ tabletop grill) — the wire mesh pattern is visible underneath and around the meat strips.
Optional: subtle hint of red-orange glow underneath the grate suggesting hot coals (a touch of
warm fire atmosphere, not dominant). NOT a flat solid plate, NOT a white ceramic plate, NOT a
black cast iron flat pan — the wire mesh grate is the proper context for LA-galbi.

4-6 large rectangular LA-style meat strips are arranged side by side parallel on the grill grate.
Each strip dimensions: approximately 18-25cm long × 8-12cm wide × 0.5-0.8cm thick (paper-thin
appearance). The strips slightly overlap or sit side by side (natural BBQ arrangement, NOT
perfectly geometric grid — some strips lay lengthwise, some may sit slightly turned, just like
how meat sits on a real BBQ grate).

CRITICAL signature feature — LA CROSS-CUT BONE DISCS along each strip's LENGTH:
Each meat strip has 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS visible along its LENGTH
(each disc approximately 1.5-2cm diameter, cream-white color). These are LA-style cross-cut bones
— the rib bones have been cut PERPENDICULAR to their original direction (cross-cut butchery), so
each bone cross-section appears as a small round white disc along the strip's length. The bones
are EVENLY SPACED along the length of each strip (approximately 3-5cm apart between discs). This
is the LA-Galbi traditional cut signature — multiple small round white bone discs appearing
across each strip's length, evenly spaced.

Each meat piece thickness: 0.5-0.8cm thick (5-8mm, very thin slice, paper-thin appearance — the
characteristic LA-galbi properly butchered cut, much thinner than a typical steak cut). The
slight 7/8 perspective angle reveals this thin thickness from the side profile.

COLOR — well-grilled appearance (cooked, NOT raw):
- Each meat strip surface is a rich caramelized dark brown with a glossy soy-pear-garlic marinade
  glaze (Korean galbi marinade — soy sauce + pear + garlic + sugar + sesame oil).
- Visible dark char marks / burned lines on the surface from cooking on the grill grate (the char
  marks are the dominant surface feature in LA-galbi, where the cross-cut bones are the signature
  rather than knife score marks).
- The meat appears well-cooked and glazed, NOT raw red-pink, NOT pale uncooked.
- A subtle sheen on the surface from the glaze (juicy appetite, single specular highlight per strip).

Garnish (v7 — chopped green scallion rounds as hero garnish):
- Generous scattering of CHOPPED GREEN SCALLION ROUNDS (송송 sliced spring onion / 대파, each
  round approximately 1-3mm thick disc, bright green color) scattered across the meat strips as
  the hero garnish (small bright green disc-shaped slices, the signature Korean LA-galbi finishing
  garnish).
- Plus a light sprinkle of white sesame seeds as additional accent (minor garnish).

%s

Important also: this is Korean LA-style Galbi-gui (정통 LA갈비, the LA-cut cross-cut style of
Korean BBQ short ribs) cooking on a round wire mesh grill grate.

NOT Japanese yakiniku (which uses thin bone-less slices with salt-only sear, no cross-cut bone discs).
NOT American BBQ ribs (which uses a single thick slab with bone on the side, red tomato BBQ sauce).
NOT Chinese char siu (which is pork shoulder with red coloring, no bones).
NOT a steak (which is a single thick boneless meat slab).
NOT v6 small square pieces grid form (deprecated for this LA-galbi reference — the R6 grid of
3-4cm square pieces is replaced by 4-6 large rectangular LA-style strips, the proper LA-galbi form).
NOT a single long bone alongside the meat (R6 deprecated pattern).
NOT bone discs partially embedded along TOP LONG EDGE only (R5 deprecated pattern).
NOT one big bone at one end of a strip (R3 deprecated pattern).
The bones are MULTIPLE SMALL ROUND DISCS appearing across each strip's length, evenly spaced —
the LA cross-cut signature where the ribs have been cut perpendicular to their original direction.

NOT a flat solid plate (v4/v5/v6 polished but deprecated for this LA-galbi form). NOT a white
ceramic plate. NOT a black cast iron flat pan — the round wire mesh grill grate is the proper
context for LA-galbi.

NOT chopped minced garlic dots (R6 deprecated garnish). NOT thin garlic slices on top. NOT whole
garlic cloves. NOT only sesame seeds — the chopped green scallion rounds (송송 sliced 대파,
bright green round discs) are the hero garnish.

NOT a top-down view (R6 deprecated). The slight 7/8 perspective is needed to show the meat
thickness side profile + grill grate depth.

Form is CRITICAL — the meat is 4-6 large rectangular LA-style strips (each 18-25cm long × 8-12cm
wide × 0.5-0.8cm thick) arranged side by side parallel on the grill grate, NOT small square pieces
in grid pattern. This is the classic LA-galbi cross-cut form.

Bone form is CRITICAL — each strip has 3-4 small round white bone cross-section discs visible
along its length (evenly spaced ~3-5cm apart), NOT a single long bone alongside the meat, NOT
bones at the strip edge only, NOT bones at the tips. This is the LA-Galbi cross-cut signature
where the ribs are cut perpendicular to their original direction.

Grill context is CRITICAL — round metallic wire mesh grill grate (silver-gray wire pattern visible
underneath/around the strips), NOT a flat plate, NOT a cast iron pan.

The LA-cut form (large strips) + cross-section bone discs along each strip's length (LA signature)
+ thin slice 0.5-0.8cm + caramelized brown + char marks + chopped green scallion rounds garnish
+ wire mesh grill grate context + slight 7/8 perspective view are the ESSENTIAL identifying
features. NO raw red-pink uncooked meat, NO thick slab, NO bone-less yakiniku slices, NO red BBQ
sauce, NO small square pieces grid form, NO single long bone alongside, NO minced garlic dots,
NO flat solid plate, NO top-down view.

(Optional: knife score marks (칼집) on the meat surface are OK if naturally visible, but they are
NOT a required signature for the LA-cut form — the cross-cut bone discs are the LA-galbi signature,
not the score marks. Score marks are deprioritized to optional for R7 v7.)
```

**DALL-E 3 약점 회피 노트** (v1.9 R7 사용자 또 다른 reference image 기반 — LA-style on wire mesh):
- **risk CRITICAL — form 잘못 추론 (small square pieces grid로 회귀)**: v6에서 grid pattern으로 ChatGPT가 명시 추론. v7는 "4-6 large rectangular LA-style meat strips", "18-25cm long × 8-12cm wide", "side by side parallel on the grill grate (slight natural overlap, NOT perfectly geometric grid)" explicit 반복 강조 + negative "NOT v6 small square pieces grid form (deprecated for this LA-galbi reference)". v6 grid pattern → v7 large LA strips 전환 critical.
- **risk CRITICAL — bone form 잘못 (single long bone at short edge로 회귀)**: v6에서 single LONG WHITE RIB BONE alongside grid로 명시. v7는 "Each meat strip has 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS visible along its LENGTH", "evenly spaced ~3-5cm apart", "LA-style cross-cut bones perpendicular to original direction" 강조 + negative "NOT a single long bone alongside the meat (R6 deprecated), NOT bone discs partially embedded along TOP LONG EDGE only (R5 deprecated), NOT one big bone at one end (R3 deprecated)". multiple round discs along each strip's length 패턴은 R3에서 한 번 시도됐다가 폐기됐지만 R7 reference가 정확히 그 패턴.
- **risk HIGH — garnish 잘못 (minced garlic dots / thin garlic slices로 회귀)**: v6의 "finely CHOPPED MINCED GARLIC bits" 묘사 → v7는 "CHOPPED GREEN SCALLION ROUNDS (송송 sliced 대파, 1-3mm thick discs, bright green color)" 강조 + negative "NOT chopped minced garlic dots (R6 deprecated), NOT thin garlic slices, NOT whole garlic cloves". green color 시그니처.
- **risk HIGH — plate context 잘못 (flat plate / cast iron pan으로 회귀)**: v4~v6의 cast iron grill plate / 흰 plate → v7는 "ROUND METALLIC WIRE MESH GRILL GRATE (silver-gray wire grate)", "wire mesh pattern visible underneath/around the meat strips" 명시 + negative "NOT a flat solid plate, NOT a white ceramic plate, NOT a black cast iron flat pan". optional hot coals glow 추가 atmosphere.
- **risk M — view angle 잘못 (top-down으로 회귀)**: v6 top-down view → v7 "slight 7/8 perspective view" 명시 + "the slight 7/8 angle reveals the THIN slice thickness from the side". side profile에서 paper-thin 확인 가능.
- **risk HIGH — Japanese yakiniku 누수** (~60% default): 정통 LA갈비 form은 yakiniku와 시각적으로 가까울 수 있음. cross-section bone discs along length가 LA-galbi vs yakiniku 결정적 차이.
- **risk M — raw red-pink color 누수**: well-grilled char marks + caramelized brown LOCK 유지.
- **note — 칼집 (knife score marks) optional**: v3~v6 LOCK 요소였으나 R7 reference에서는 cross-cut bones이 dominant signature이고 char marks가 dominant surface texture. score marks는 optional로 격하 (visible면 OK, 없어도 PASS). LA-cut form에서 score marks는 필수 시그니처 아님.

**Reroll 트리거** (follow-up, v1.9 R7 — 7종):
- **form 잘못 (small square pieces grid로 회귀, CRITICAL)**: "이 이미지를 다시 그려줘. v6의 12-16개 square pieces grid pattern 폐기 → 4-6개 large rectangular LA-style meat strips (각 18-25cm long × 8-12cm wide × 0.5-0.8cm thick)로 wire mesh grill grate 위에 side by side parallel 배치 (slight natural overlap or aligned, NOT perfectly geometric grid). 정통 LA갈비 cross-cut form."
- **bone form 잘못 (single long bone at short edge로 회귀, CRITICAL)**: "이 이미지를 다시 그려줘. v6의 single long bone alongside grid 패턴 폐기 → 각 meat strip의 LENGTH 방향을 따라 3-4개의 small ROUND WHITE BONE CROSS-SECTION DISCS (각 disc 1.5-2cm diameter, cream-white)가 evenly spaced (3-5cm apart) 표현. LA-style cross-cut bones (rib bones cut perpendicular to original direction). 절대 single long bone 아님, 절대 strip 끝의 one bone 아님."
- **garnish 잘못 (minced garlic / garlic slice 누수)**: "이 이미지를 다시 그려줘. v6의 chopped minced garlic dots 폐기 → CHOPPED GREEN SCALLION ROUNDS (송송 sliced 대파, 1-3mm thick disc, bright green color)을 hero garnish로 meat strips 위에 generously scattered. 깨 sprinkle은 minor accent. 절대 garlic 아님, 절대 yellowish-white granules 아님."
- **plate context 잘못 (flat plate / cast iron 누수)**: "이 이미지를 다시 그려줘. v4~v6의 cast iron grill plate / white plate 폐기 → ROUND METALLIC WIRE MESH GRILL GRATE (silver-gray wire pattern visible)로 표현. 절대 flat solid plate 아님. optional subtle red-orange glow underneath grate (hot coals atmosphere)."
- **view angle 잘못 (top-down 회귀)**: "이 이미지를 다시 그려줘. v6 top-down view 폐기 → slight 7/8 perspective view (mostly top-down but slightly angled). 측면에서 meat thickness (0.5-0.8cm thin slice) 확인 가능해야 함."
- **thickness 두꺼움 (v5/v6 thin 회귀)**: "이 이미지를 다시 그려줘. 각 strip 두께를 0.5-0.8cm (5-8mm, paper-thin appearance)로 명확히 얇게. 7/8 perspective에서 side profile visibly thin. 절대 thick slab 아님, 절대 steak thickness 아님."
- **raw / steak 색 누수**: "이 이미지를 다시 그려줘. 색깔을 rich caramelized dark brown (well-cooked grilled appearance + soy-pear-garlic glossy glaze) + visible dark char marks/burned lines on surface — 절대 raw red-pink 아님, 절대 pale uncooked 아님. LA-cut bones 시그니처 + char marks + green scallion rounds + wire mesh grate 동시 충족."

---

##### F-12 — R6 v6 archive (deprecated, 2026-05-28)

> R6 v6 본문 = "multiple small square-shaped meat pieces (12~16 pieces, each 3-4cm × 3-4cm × 0.5-0.8cm) in grid pattern (3-4 rows × 4 columns) + SINGLE LONG WHITE RIB BONE laid alongside meat grid on ONE SHORT EDGE side + finely chopped minced garlic bits scattered" 묘사로 작성됐으나, 2026-05-28 사용자가 v6 결과 시각 확인 후 **또 다른 reference image** (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length)를 제시하며 verbatim "이걸로 해줘" 명시. R6 v6 = **deprecated**, R7 v7 = 사용자 새 reference 시각 요소 1:1 매칭으로 5건 전면 fix (form 전면 교체 / bone form 완전 재정의 / garnish 변경 / plate context 변경 / view angle 변경).

```
[R6 v6 deprecated — 보존 archive 목적, small square pieces grid + single long bone at short edge + minced garlic dots 묘사]
On a clean black cast iron grill plate (or alternatively a copper grill grate or a clean white plate),
multiple small square-shaped grilled meat pieces (12~16 pieces total, each approximately 3-4cm × 3-4cm
square, very thin 0.5-0.8cm thick) are arranged in a grid pattern (3-4 rows × 4 columns) on the plate.
On ONE SHORT EDGE SIDE of the meat grid, a single LONG WHITE RIB BONE is laid horizontally
(approximately 12-15cm long × 1-1.5cm wide × 1-1.5cm tall, cream-white color).
Garnish: Generous sprinkle of finely CHOPPED MINCED GARLIC bits scattered all over the meat pieces
(small yellowish-white garlic granules).
... [중략 — 전체 v6 본문은 prompts-library v1.8 §5.2 F-12 git history 참조]
```

**R6 v6 deprecated 사유 (verbatim, 2026-05-28)**: 사용자 v6 시각 확인 후 또 다른 reference image 제시 (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length) + verbatim "이걸로 해줘". 5건 추가 fix 요청 — (1) **form 전면 교체**: small square pieces grid (3-4cm × 3-4cm, 12-16 pieces in 3-4 rows × 4 columns) → 4-6 large rectangular LA-style strips (18-25cm × 8-12cm × 0.5-0.8cm thick) parallel side by side. 정통 LA-cut cross-cut 회귀. / (2) **bone form 완전 재정의**: single LONG WHITE RIB BONE (12-15cm) at SHORT EDGE side → 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS (each ~1.5-2cm diameter) along each strip's LENGTH (evenly spaced ~3-5cm apart). LA-style cross-cut bones — ribs cut perpendicular to original direction. R3에서 시도됐다가 폐기됐던 패턴이 R7 reference의 정확한 패턴. / (3) **garnish 변경**: chopped minced garlic dots (yellowish-white granules) → chopped green scallion rounds (송송 sliced 대파, 1-3mm thick discs, bright green color)로 hero garnish 변경. 깨는 minor accent. / (4) **plate context 변경**: black cast iron grill plate / copper grate / 흰 plate → ROUND METALLIC WIRE MESH GRILL GRATE (silver-gray wire pattern visible) — 정통 한식 BBQ tabletop grill. optional hot coals glow atmosphere. / (5) **view angle 변경**: top-down view → slight 7/8 perspective view (mostly top-down but slightly angled to show meat thickness side profile + grate depth). v6 LOCK 유지 4건 (well-grilled brown + glaze / char marks / thin 0.5-0.8cm thickness / cross-cultural negative) 무변경. **칼집 (knife score marks)은 optional로 격하** — LA-cut form에서는 cross-cut bones이 dominant signature이고 char marks가 dominant surface texture, score marks는 reference에 명확히 보이지 않음.

---

##### F-12 — R5 v5 archive (deprecated, 2026-05-28)

> R5 v5 본문 = "4 thin elongated rectangular meat strips arranged in a strictly parallel row, each strip ~12-15cm long × 3cm wide × 0.7-1cm thick, bone discs along TOP LONG EDGE of each strip" 묘사로 작성됐으나, 2026-05-28 사용자가 v5 결과 시각 확인 후 새 reference image (정통 한식 갈비구이 — 가위로 자른 후의 eating-style state)를 제시하며 4건 추가 fix 요청 (form 전면 교체 + thickness 더 얇게 + bone short edge long piece + 마늘 dots). R5 v5 = **deprecated**, R6 v6 = 사용자 새 reference 시각 요소 1:1 매칭으로 4건 전면 fix.

```
[R5 v5 deprecated — 보존 archive 목적, long elongated strips + bone TOP LONG EDGE 묘사]
On a clean black cast iron grill plate, 4 thin elongated rectangular meat strips are arranged in a
strictly parallel row (side by side, NOT overlapping). Each strip dimensions: 12-15cm long × 3cm wide
× 0.7-1cm thick.
Small round white rib bone cross-section discs (1-2 small bones per strip, ~1-1.5cm diameter) are
visible along the TOP LONG EDGE of each meat strip — partially embedded into the upper long edge.
Garnish: generous sprinkle of white sesame seeds. 1-2 thin garlic slices on top or beside meat.
Optional: kkaennip leaves on side.
... [중략 — 전체 v5 본문은 prompts-library v1.7 §5.2 F-12 git history 참조]
```

**R5 v5 deprecated 사유 (verbatim, 2026-05-28)**: 사용자 v5 시각 확인 후 새 reference image 제시 + verbatim "가위로 자르고 난후의 갈비구이....Short Edge쪽에 뼈가 길게 있잖어....그리고 고기 자체도 훨씬 얇게 되어 있고....". 4건 추가 fix 요청 — (1) **form 전면 교체**: long elongated strips → small square pieces (3-4cm × 3-4cm, 12-16 pieces in grid pattern). 한식 갈비구이의 eating-style state (가위로 자른 후) / (2) **thickness 더 얇게**: 0.7-1cm → 0.5-0.8cm (5-8mm, much thinner than v5) / (3) **bone 위치 완전 재정의**: bone discs along TOP LONG EDGE of each strip 폐기 → SINGLE LONG WHITE RIB BONE (12-15cm) laid alongside meat grid on ONE SHORT EDGE side. v5의 bone-per-strip 패턴 → v6의 single long bone alongside grid 패턴 / (4) **garnish 잘게 다진 마늘 dots**: 1-2 thin garlic slices → finely chopped minced garlic bits scattered all over (small yellowish-white granules). v5의 다른 LOCK 5 요소 (칼집 maintained / strictly parallel-aligned arrangement / well-grilled brown + glaze / plate context / cross-cultural negative) 무변경 유지.

---

##### F-12 — R4 v4 archive (deprecated, 2026-05-28)

> R4 v4 본문 = "4 strips × 1-1.5cm thick + small bone discs nestled between the strips at the plate edges" 묘사로 작성됐으나, 2026-05-28 사용자가 v4 결과 시각 확인 후 2건 fix 요청 (thickness 더 얇게 + bone 위치 = 윗부분 사이드). R4 v4 **deprecated**, R5 v5 = thickness/bone 위치 2건 fix (다른 LOCK 요소 6건 무변경 유지).

```
[R4 v4 deprecated — 보존 archive 목적, thickness 1-1.5cm + bone "between strips at plate edges" 묘사]
Each strip dimensions: approximately 12-15cm long × 3cm wide × 1-1.5cm thick.
...
Small white round rib bone cross-section discs (1-2 small bones, approximately 1-1.5cm diameter) are
visible nestled between the strips at the plate edges (the bones are the small round white circles peeking
out where the meat strips meet the plate surface — this is the traditional Korean galbi bone-in cut pattern).
... [중략 — 전체 v4 본문은 prompts-library v1.6 §5.2 F-12 git history 참조]
```

**R4 v4 deprecated 사유 (verbatim, 2026-05-28)**: 사용자 v4 시각 확인 후 2건 추가 fix 요청 — (1) "고기가 일단 더 얇아야 함" → thickness 1-1.5cm → 0.7-1cm (very thin slice 6-8mm) / (2) "긴쪽의 밑쪽이 아니라 윗부분의 사이드로 보여야함" → bone 위치 = strip의 short end/edge "between strips at plate edges" 묘사 폐기 → bone discs는 strip의 TOP LONG EDGE (윗쪽 long edge)에 partially embedded 형태로 재정의 (정통 한식 갈비 손질 = bone이 strip의 한 long side에 attached). 다른 LOCK 요소 6건 (칼집 / parallel 배열 / 길이 12-15cm / 색깔 well-grilled brown + glaze / grill marks / plate context) 무변경 유지.

---

##### F-12 — R3 v3 archive (deprecated, 2026-05-27)

> R3 v3 본문 = "각 piece에 한쪽 끝(ONE END)에 SHORT WHITE RIB BONE 1-2cm 노출" 묘사로 작성됐으나, 2026-05-28 사용자가 정통 한식 갈비구이 reference image를 직접 보여주며 시각 의도 명확화 → R3 묘사와 어긋남 발견 (사용자 reference는 칼집 + parallel strips + small bone discs at edges 패턴). R3 v3 **deprecated**, R4 v4 = 전면 재작성.

```
[R3 v3 deprecated — 보존 archive 목적]
A modern mobile casual game food card illustration of Korean Galbi-gui (traditional Korean grilled short ribs,
소갈비, 왕갈비 style), 7/8 top-down view. On a clean white large plate or a black cast iron grill plate,
3-4 pieces of traditional Korean bone-in galbi are arranged in a natural overlapping plating arrangement
with meat pieces slightly overlapping at relaxed angles, bones pointing in slightly different directions.
EACH PIECE is a THIN ELONGATED MARINATED MEAT STRIP (5-7cm long, 1-1.5cm thick), and at ONE END of each
meat strip, a SHORT WHITE RIB BONE protrudes about 1-2cm. ... [중략 — 전체 본문은 prompts-library v1.5 §5.2 F-12 참조]
```

**R3 v3 deprecated 사유 (verbatim, 2026-05-28)**: 사용자 reference image와 1:1 비교 시 6 시각 요소 어긋남 — (1) 칼집 묘사 0건 vs reference 가장 중요한 시그니처 / (2) "끝 single bone protrude" vs reference small round bone discs at plate edges between strips / (3) "overlapping at relaxed angles" vs reference strictly parallel / (4) strip 길이 5-7cm vs reference 12-15cm elongated / (5) 색깔 generic vs reference well-grilled caramelized brown + glaze sheen 명시 필요 / (6) LA cross-cut 부정 negative가 small bone discs 시그니처까지 차단했음.

---

### 5.3 음식 12 cross-호환 운영 (subject anchor 일치 전략)

- **Stage 1 (F-01 anchor 시드 lock)**: F-01 (Ramyeon) 1차 생성 → 적합 시 §0 표에 `FOOD_ANCHOR_FILE` 기록.
- **Stage 2 (F-02~F-07 T1, F-08~F-12 T2 follow-up)**: 각 prompt에 `FOOD_ANCHOR_FILE` reference upload + 본문 prompt + "이 reference 음식 카드와 같은 plate/bowl 스타일, outline 두께, bg 톤, saturation 80~90%로 일관성 유지" 명시.
- **세션 분기 권장**: T1 (F-01~F-07) 한 세션 / T2 (F-08~F-12) 한 세션. 캐릭터/환경 anchor와 다른 새 세션.
- **subject anchor 단어 공통 부분**: "modern mobile casual game food card illustration of Korean [음식명], [시점], [signature feature], single subtle ambient ellipse shadow under [bowl/plate]"

### 5.4 음식 12 ChatGPT 약점 risk top 5 (G6 세분화)

> 한식 anchor만의 음식 cross-cultural 누수 risk top 5. 본 sprint M1 ChatGPT 세션에서 가장 빈번 발생 예상.

| Rank | 음식 | 누수 risk | default % | 회피 전략 |
|------|------|----------|-----------|----------|
| 1 | F-12 Galbi-gui | 일본 야키니쿠 + 미국 BBQ ribs | ~60% | VISIBLE WHITE RIB BONE 강조 + soy-pear marinade + 상추 ssam |
| 2 | F-03 Kimbap | 일본 maki sushi | ~70% | THICK 3cm + matte gim + cooked vegetables + danmuji yellow |
| 3 | F-06 Korean Corn Dog | 미국 corn dog | ~80% | mozzarella cheese stretch + panko crumb + ketchup/mustard zigzag |
| 4 | F-11 Japchae | 중식 lo mein/chow mein | ~70% | translucent brown-amber dangmyeon (sweet potato glass noodles, 투명) + 깨 sprinkle |
| 5 | F-09 Kimchi Jjigae | 중식 hot pot | ~50% | 검정 ttukbaegi (rounded thick rim, individual portion) + red-orange gochugaru |

> 부차 risk (P2): F-05 Kimchi Fried Rice (Chinese fried rice), F-07 Haemul Pajeon (Japanese okonomiyaki), F-10 Sundubu Jjigae (Chinese mapo tofu).

---

### 5.5 ADR-005 칼/도마 + Cut Style 6종 (M1 후반 sprint — 음식 12 hero shot 완료 후)

> art-style-guide §5 가이드 기반. 본 sprint는 prompt frame만 placeholder.

**칼/도마 base prompt** (ChatGPT 자연어):
```
A flat 2D illustration of a knife and wooden cutting board, top-down view.
Simple knife silhouette (gray blade + brown handle), bold 3px black outline.
Brown rectangular cutting board with 2-3 horizontal grain lines, rounded corners.
Hyper-casual mobile game style, single color fill, no shading.
Plain warm cream background. Format: square 1:1. Minimal stylization.

Important: avoid realistic, photorealistic, 3D render, texture, painterly,
hyperdetailed, gore, blood, raw meat.
```

**Cut style 6종 frame placeholder** (각 frame 1: whole / frame 2: cutting / frame 3: cut):

| Cut style | Frame 수 | Prompt 핵심 변수 (자연어) |
|-----------|---------|--------------------------|
| 다지기 (mince) | 2 (whole → minced dots) | "ingredient minced into many small dots, scattered evenly" |
| 채썰기 (julienne) | 2 (whole → thin sticks) | "ingredient julienned into thin parallel sticks" |
| 어슷썰기 (diagonal slice) | 3 (whole → mid → done) | "ingredient diagonally sliced into parallelogram pieces" |
| 통썰기 (round slice) | 2 (whole → rounds) | "ingredient round-sliced into evenly spaced discs" |
| 송송썰기 (small chop) | 2 (whole → segments) | "scallion chopped into small segments" |
| 깍둑썰기 (cube) | 3 (whole → mid → cubes) | "ingredient cubed into small dice pieces" |

> ChatGPT는 frame sequence를 같은 채팅 세션 안에서 "앞 frame과 동일 ingredient base, cut state만 변경" follow-up으로 일관성 lock.

**ingredient cut variation**: 음식 12 × hero ingredient 1~2 = ~24 sprite. 각 "whole + cut" 2장만.

### 5.6 양친 reaction 6컷 (U-2 동시 unlock, M1 후반 / M2)

| ID | Subject | 상속 anchor |
|----|---------|------------|
| CH-02-S | 어머니 Subtle (★1·★2) | CH-02 lock image |
| CH-02-H | 어머니 Happy (★3) | CH-02 lock image |
| CH-03-S | 아버지 Subtle (★1·★2) | CH-03 lock image |
| CH-03-H | 아버지 Happy (★3) | CH-03 lock image |
| (CH-04, CH-05) | 주인공 본 sprint에서 lock | — |

> 6컷 합계 = (어머니 S+H) + (아버지 S+H) + (주인공 본 sprint CH-04·05) = 6컷.
> 모든 reaction prompt에 "Important: avoid sleeping, eyes closed peaceful, sad, crying" 필수 (tier-1-2-flow §3.3.1 sync).
> 각 prompt에 CH-02 / CH-03 lock image를 reference upload하여 일관성 lock.

### 5.7 재료 카드 / UI / VFX (M1 후반 / M2)

- 재료 ~20개: 음식 anchor의 hero ingredient crop으로 시작 → 부족 재료만 별도 prompt
- UI 일러스트 ~7개: 장바구니, 메모지, 간판 5종 등 — flat 톤 단순 icon (간판 텍스트는 W1으로 placeholder block만, 한글 후보정)
- VFX ~4~5개: 픽업 빛, shake, 타이머 펄스, ★ 등급 — flat 톤이라 simple shape 변화로 충분

---

## 6. 변경 이력

- **2026-05-28 v1.11** (M1 환경 BG-01~05 v2 갱신 — 한옥 양식 + 검정 기와 곡선 지붕 + 처마 + 큰 나무 간판 + 옹기 + hanging lantern + icon+영어 minimal signage 5건 fix, supersedes v1.10) — 사용자가 정통 한식 가게 reference image (경주 참기름 방앗간 한옥 양식, 1963년 since 1963) 제공 + 명시 "**한식 정통 요소만 차용 + 기존 lock 유지**". main thread 시각 분석으로 차용할 5건 추출: (1) **한옥 양식 외관** — 목조 frame (warm brown wood beams 정통 한국 건축) / (2) **검정 기와 지붕** — curved eave tiles (처마 곡선 + 처마 끝 흰 와당 patterns) / (3) **큰 나무 간판** — 가게명 wooden rectangular signboard (단 v2는 icon+영어 minimal로 변환 — [feedback_i18n_icon_first] 2026-05-27 lock 유지, 한글 prompt 회피) / (4) **옹기 항아리** — 갈색 traditional Korean pottery 1-2개 (외부 배치) / (5) **Hanging lantern** — 양쪽 warm yellow glow. 회피 3건 (LOCK 유지): (a) **베이지 배경** — reference의 cream/베이지 storybook tone 회피, art-style v1.1 modern saturated Cool Sage `#C8D5C0` 유지 / (b) **한글 dominant signage** — reference의 "경주 참기름 방앗간", "기름", "직접 짠 고소한 참기름", "100% 국산품 참기름" 4건 한글, v2는 icon + 영어 minimal로 변환. 한글 prompt 절대 회피 / (c) **Warm storybook tone** — illustrated/vintage 느낌, modern saturated/clean hyper-casual flat 톤 유지. **§2.2 STYLE_SUFFIX_BG 전면 재작성** = v1.11 STYLE_SUFFIX_BG_V2 (한옥 양식 LOCK + 검정 기와 곡선 지붕 + 처마 깊이 + 큰 나무 간판 + 옹기 + lantern + icon-first 영어 minimal signage + slight 7/8 isometric view + Cool Sage `#C8D5C0` solid bg + cross-shop one-market identity 위한 공통 한식 정통 5 요소). DALL-E 약점 회피 신규 4건 = 한글 누수 (한자/카타카나) / Chinese/Japanese architecture 누수 (Chinese pagoda 곡선/Japanese irimoya hip-and-gable) / 베이지 누수 (reference cream tone) / vintage storybook 누수. **§4 BG-01~05 본문 v2.0 전면 재작성** (5장 각각 한옥 + 기와 + 처마 + 옹기 + lantern + icon+영어 signage + 카테고리 시그니처 통합): BG-01 청과상 (cabbage+apple, GREENGROCER 영어) / BG-02 정육점 (meat slab+cutting board, BUTCHER) / BG-03 어물전 (fish+ice, FISHMONGER) / BG-04 곡물상 (grain sacks+옹기 prominent 2-3개+plant, GRAIN SHOP) / BG-05 잡화점 (참기름 방앗간 직접 inspired, seasoning bottles+옹기 prominent+wooden stool accent, GENERAL GOODS — vintage tone 회피 critical). 각 BG-XX마다: 식별 핵심 시각 요소 7개 / Prompt body 전면 / DALL-E 약점 회피 노트 (한글/한자, Chinese/Japanese architecture, 베이지, 카테고리별 risk 음식 시각 디테일 등) / Reroll trigger 6종 (한옥 양식 누락 / 기와 지붕 X / 한글·한자 누수 / 베이지 / 일본·중국 양식 / 카테고리 시그니처 누락). **§4.6 v1.2 archive 절 신설** (v1.2 BG-01~05 본문 deprecated archive + v1.2 → v1.11 V2 핵심 diff 요약 표: 시점 / 외관 / awning→기와 지붕 / signboard → wooden signboard + icon+영어 / 옹기 / lantern / 배경 / 카테고리 시그니처 / 회피 LOCK). §0 anchor 표 BG-01~05 row 5장 status `pending` → **`v1.2 invalidated, v2 pending (anchor seed BG-01 / reference upload BG-02~05)`** 갱신. **Week 1 anchor candidate (commit 7a6cffb)의 BG 5장은 invalidate** (캐릭터 5장 CH-01~05는 무영향, v1.2 lock candidate 유지). 음식 12장 F-01~F-12 본문 무변경 (F-12는 v1.10 R7 plated white plate LOCK candidate 유지). 캐릭터 5장 CH-01~05 본문 무변경.
- **2026-05-28 v1.9** (M1 음식 F-12 R7 reroll LA-cut long strip form + multiple cross-section bone discs along length + green scallion rounds + wire mesh grill grate + 7/8 perspective 5건 fix, supersedes v1.8) — R6 v6 결과 시각 확인 후 사용자가 **또 다른 reference image** (정통 LA갈비 — round wire mesh grill grate 위에서 굽고 있는 large rectangular strips with cross-section bone discs along length)를 제시하며 verbatim "이걸로 해줘" 명시. R6 v6의 small square pieces grid form + SHORT EDGE long single bone + chopped minced garlic dots + black cast iron plate + top-down view 패턴이 새 reference와 어긋남 진단 → R6 v6 = **deprecated**, R7 v7 = 사용자 새 reference 시각 요소 1:1 매칭으로 5건 전면 fix: (1) **Fix 1 form 전면 교체 (small square pieces grid → LA-cut long strips)**: v6 `multiple small square-shaped meat pieces (12~16 pieces, each 3-4cm × 3-4cm × 0.5-0.8cm thick) in grid pattern (3-4 rows × 4 columns)` 폐기 → v7 `4-6 large rectangular LA-style meat strips (each ~18-25cm long × 8-12cm wide × 0.5-0.8cm thick) arranged side by side parallel on the grill grate (slight natural overlap or aligned, NOT perfectly geometric grid)`. 정통 LA갈비 cross-cut form 회귀. / (2) **Fix 2 bone form 완전 재정의 (long bone at short edge → 3-4 cross-section discs along each strip's length, CRITICAL signature)**: v6 `SINGLE LONG WHITE RIB BONE (12-15cm) laid horizontally alongside meat grid on ONE SHORT EDGE side` 폐기 → v7 `Each meat strip has 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS (each ~1.5-2cm diameter, cream-white color) visible along its LENGTH — LA-style cross-cut bones (ribs cut perpendicular to original direction), EVENLY SPACED along the length of each strip (approximately 3-5cm apart). The LA-Galbi traditional cut signature.` R3에서 시도됐다가 폐기됐던 패턴이 R7 reference의 정확한 패턴 (사용자 시각 의도 진화). negative `NOT a single long bone alongside the meat (R6 deprecated), NOT bone discs partially embedded along TOP LONG EDGE only (R5 deprecated), NOT one big bone at one end (R3 deprecated)`. / (3) **Fix 3 garnish 변경 (chopped minced garlic → chopped green scallion rounds)**: v6 `finely CHOPPED MINCED GARLIC bits scattered all over meat pieces (small yellowish-white garlic granules)` 폐기 → v7 `Generous scattering of CHOPPED GREEN SCALLION ROUNDS (송송 sliced spring onion / 대파, each round ~1-3mm thick disc, bright green color) scattered across the meat strips as the hero garnish. Plus a light sprinkle of white sesame seeds as additional accent.` negative `NOT chopped minced garlic dots (R6 deprecated), NOT thin garlic slices, NOT whole garlic cloves, NOT only sesame seeds`. / (4) **Fix 4 plate/grill context 변경 (cast iron plate → round metallic wire mesh grill grate)**: v6 `On a clean black cast iron grill plate (or copper grill grate or white plate)` 폐기 → v7 `Sitting on a ROUND METALLIC WIRE MESH GRILL GRATE (silver-gray wire grate, the traditional Korean BBQ tabletop grill) — the wire mesh pattern is visible underneath/around the meat strips. Optional: subtle hint of red-orange glow underneath the grate suggesting hot coals (a touch of warm fire atmosphere, not dominant).` negative `NOT a flat solid plate (v4/v5/v6 polished but deprecated for this LA-galbi form), NOT a white ceramic plate, NOT a black cast iron flat pan`. / (5) **Fix 5 view angle 변경 (top-down → slight 7/8 perspective)**: v6 `top-down view` 폐기 → v7 `slight 7/8 perspective view (mostly top-down but slightly angled to show meat thickness side profile + grill grate depth) — the slight 7/8 angle reveals the THIN slice thickness (0.5-0.8cm) from the side, confirming the paper-thin slice appearance`. **v6 유지 요소 4건 (LOCK, 무변경)**: well-grilled caramelized dark brown + glossy glaze sheen / char marks visible on surface from grill (LA-cut form에서 char marks가 dominant) / thin slice 0.5-0.8cm thickness / cross-cultural negative (yakiniku/American BBQ/char siu/steak/raw) + 추가 `NOT v6 small square pieces grid form (deprecated for this LA-galbi reference)`. **부분 폐기 — 칼집 (knife score marks)**: v3~v6 핵심 LOCK 시그니처였으나 R7 reference에서는 cross-cut bones이 dominant signature이고 score marks는 reference에 명확히 보이지 않음. **칼집은 optional로 격하** (만약 표면에 보이면 OK, 없어도 PASS). LA-cut form의 시그니처는 cross-cut bones이지 score marks가 아님. F-01~F-11 본문 무변경 (각 LOCK status 유지). §5.2 F-12 본문만 v7로 전면 교체 (5건 fix). v6 본문은 §5.2 F-12 archive 절 `R6 v6 (deprecated, 2026-05-28)`에 보존 (R3/R4/R5/R6 모두 archive 보존 — 사용자 시각 의도 진화 기록). 식별 핵심 시각 요소 7개 갱신 (LA-cut long strip / multiple parallel strips / **3-4 bone discs along length CRITICAL LA cross-cut signature** / thin 0.5-0.8cm / well-grilled brown + char marks + 칼집 optional / green scallion rounds garnish / round wire mesh grill grate context). reroll trigger 7종 갱신 — (a) form 잘못 (small square pieces grid로 회귀 CRITICAL) / (b) bone form 잘못 (single long bone at short edge로 회귀 CRITICAL) / (c) garnish 잘못 (minced garlic / garlic slice 누수) / (d) plate context 잘못 (flat plate / cast iron 누수) / (e) view angle 잘못 (top-down 회귀) / (f) thickness 두꺼움 / (g) raw / steak 색 누수. §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.
- **2026-05-28 v1.8** (M1 음식 F-12 R6 reroll form 전면 교체 + thickness 더 얇게 + bone short edge + 마늘 dots 4건 fix, supersedes v1.7) — R5 v5 결과 시각 확인 후 사용자가 새 reference image (정통 한식 갈비구이 — 가위로 자른 후의 eating-style state)를 제시하며 시각 의도 재정의 + verbatim "가위로 자르고 난후의 갈비구이....Short Edge쪽에 뼈가 길게 있잖어....그리고 고기 자체도 훨씬 얇게 되어 있고....". R5 v5의 4 long elongated strip + bone along TOP LONG EDGE 패턴이 새 reference와 어긋남 진단 → R5 v5 = **deprecated**, R6 v6 = 사용자 새 reference 시각 요소 1:1 매칭으로 4건 전면 fix: (1) **Fix 1 form 전면 교체**: v5 `4 thin elongated rectangular meat strips arranged in a strictly parallel row, 12-15cm × 3cm × 0.7-1cm` 묘사 폐기 → v6 `multiple small square-shaped grilled meat pieces (12~16 pieces, each 3-4cm × 3-4cm square, very thin 0.5-0.8cm thick) arranged in a grid pattern (3-4 rows × 4 columns) — the Korean galbi-gui eating style AFTER kitchen scissors cut the strips into smaller pieces`. 한식 갈비구이의 eating-style state 명확화 + negative `NOT uncut long strips (v3/v5 form obsolete)`. / (2) **Fix 2 thickness 더 얇게**: v5 `0.7-1cm thick (6-8mm)` → v6 `0.5-0.8cm thick (5-8mm, much thinner than v5, paper-thin appearance but still substantial enough to recognize as meat)`. 사용자 명시 "고기 자체도 훨씬 얇게". / (3) **Fix 3 bone 위치 완전 재정의 (TOP LONG EDGE → SHORT EDGE long bone)**: v5 `bone discs visible along the TOP LONG EDGE of each meat strip (각 strip마다 small bone discs partially embedded)` 폐기 → v6 `On ONE SHORT EDGE SIDE of the meat grid, a single LONG WHITE RIB BONE (12-15cm × 1-1.5cm × 1-1.5cm cream-white color) is laid horizontally alongside the grid — original strip의 bone이 cut 후에도 short edge에 남아 있는 형태. The bone is a SINGLE LONG PIECE laid alongside the grid (perpendicular to the rows of meat pieces), NOT multiple small discs, NOT embedded into individual pieces`. 사용자 명시 "Short Edge쪽에 뼈가 길게 있잖어". negative `NOT bone discs along the top edge of each piece (v5 deprecated), NOT bone at the end of strips (v3 deprecated), NOT bones between pieces`. / (4) **Fix 4 garnish 잘게 다진 마늘 dots 강조**: v5 `Generous sprinkle of white sesame seeds across the strips. 1-2 thin garlic slices placed on top or beside the meat as accent` → v6 `Generous sprinkle of finely CHOPPED MINCED GARLIC bits scattered all over the meat pieces (small yellowish-white garlic granules visible on top of each meat piece, a signature Korean galbi-gui garnish after grilling). Optional: a light sesame seed sprinkle`. 사용자 새 reference 시각 시그니처 = 잘게 다진 마늘 dots. negative `NOT thin garlic slices on top, NOT whole garlic cloves`. **v5 유지 요소 5건 (LOCK, 무변경)**: 칼집 (3-5 horizontal score marks maintained on each cut piece) / strictly parallel/aligned arrangement (grid pattern, NOT random scatter) / well-grilled caramelized brown + glossy glaze sheen / plate context (검정 cast iron grill plate or 흰 plate) / cross-cultural negative (yakiniku/American BBQ/char siu/steak/raw/LA-cut + 추가 `NOT uncut long strips`). F-01~F-11 본문 무변경 (각 LOCK status 유지). §5.2 F-12 본문만 v6로 전면 교체 (form + thickness + bone 위치 + garnish 4건 fix). v5 본문 archive 절(§5.2 F-12 deprecated archive R5) 추가 보존 + R4 v4 / R3 v3 archive 절 유지. 식별 핵심 시각 요소 6→7개 갱신 (square form / grid pattern / thin 5-8mm / long bone at short edge / 칼집 maintained / caramelized brown / 마늘 dots). reroll trigger 7종 신설 — (a) form 잘못 (long strips로 회귀 CRITICAL) / (b) thickness 두꺼움 (v5 thin 회귀) / (c) bone 위치 잘못 (TOP LONG EDGE 또는 multiple discs로 회귀 CRITICAL) / (d) garnish 잘못 (slice/whole garlic 누수) / (e) grid pattern 흐트러짐 (random scatter) / (f) 칼집 maintained 누락 (각 small piece score marks 없음) / (g) raw/steak 색 누수. §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.
- **2026-05-28 v1.7** (M1 음식 F-12 R5 reroll thickness + bone 위치 2건 fix, supersedes v1.6) — R4 v4 결과 시각 확인 후 사용자 2건 추가 fix 요청: (1) **thickness 더 얇게** "고기가 일단 더 얇아야 함" → v4 1-1.5cm thick → **v5 0.7-1cm thick (very thin slice, like 6-8mm)** 강조 + `THIN slice appearance — significantly thinner than a steak, like a Korean galbi-gui properly butchered cut` + negative `NOT a thick 1.5cm+ slab, NOT steak thickness`. v4 결과 시각 확인 시 사용자 reject 사유. / (2) **bone 위치 재정의** "긴쪽의 밑쪽이 아니라 윗부분의 사이드로 보여야함" → v4 "small bone discs nestled between the strips at the plate edges" (strip 양 끝 short end / plate edge gaps) 묘사 폐기 → **v5 "bone discs visible along the TOP LONG EDGE of each meat strip" (partially embedded into the upper long edge of the meat strip)** 명확화. 정통 한식 갈비 손질에서 bone이 strip의 한 long side에 attached 형태 (bone에 붙어 있는 고기가 bone에서 살짝 떨어진 채 grill에 누워있는 형태). negative `NOT bones at the short ends of strips, NOT bones at the bottom long edge, NOT bones between strips at the plate gaps`. **v4 유지 요소 6건 (LOCK, 무변경)**: 칼집 (3-5 deep horizontal knife cuts perpendicular to length) / strictly parallel arrangement (4 strips side by side, NOT overlapping) / well-grilled caramelized brown + glaze sheen NOT raw / strip 길이 12-15cm / garnish (깨 sprinkle + 마늘 slice + 상추 ssam side) / plate context (black cast iron grill plate or white plate). 4 strips count + cross-cultural negative (yakiniku/American BBQ/char siu/steak/raw/LA-cut) 무변경. F-01~F-11 본문 무변경 (각 LOCK status 유지). §5.2 F-12 본문만 v5로 교체 (thickness/bone 위치 2 line 패치 + ESSENTIAL features 문장 + Bone position is CRITICAL 절 신설). v4 본문 archive 절(§5.2 F-12 deprecated archive R4) 추가 보존 + R3 v3 archive 절 유지. reroll trigger 갱신 — v4 5종에서 "single bone at one end 누수 R3 잔재" 제거 + **신규 2종 추가**: (a) "strip 두께 두꺼움 (v5 신설 — v4 reject 사유)" thickness 0.7-1cm reroll trigger / (b) "bone 위치 어긋남 (v5 신설 — strip 끝/밑쪽 누수)" TOP LONG EDGE reroll trigger. §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.
- **2026-05-28 v1.6** (M1 음식 F-12 R4 reroll 본문 전면 재작성, supersedes v1.5) — R3 v3 결과 시각 확인 후 사용자가 정통 한식 갈비구이 reference image를 직접 보여주며 시각 의도 명확화. R3 v3 = "끝에 single bone protrudes" 묘사가 사용자 reference와 어긋남 진단 → **R3 v3 deprecated**, R4 v4 전면 재작성. R4 v4 핵심 변경 (사용자 reference image 6 시각 요소 1:1 매칭): (1) **칼집 (knife score marks across meat surface)** — 가장 중요한 시그니처, 각 strip 표면에 3-5 deep horizontal knife cuts perpendicular to length, "without these score marks, it is NOT Korean Galbi" CRITICAL 강조. R3는 이 디테일 0건이었음. / (2) **thin elongated parallel meat strips** — 4 strips × 12-15cm long × 3cm wide × 1-1.5cm thick, **strictly parallel row** (서로 나란히 같은 방향, NOT overlapping). R3 "natural overlapping at relaxed angles" 폐기. / (3) **small white round bone cross-section discs** — strip 사이 edge에 1-2개 small bone discs visible (LA갈비 + 칼집 결합 형식). R3 "single bone at one end" 묘사 완전 폐기. / (4) **well-grilled caramelized brown color + glossy soy-pear-garlic glaze sheen** — raw red-pink 아닌 well-cooked 색 명시. / (5) **grill marks** along score lines + edges (cooked from grill grate). / (6) **plating context** = clean black cast iron grill plate 또는 white plate. R3 v3 archive 절(§5.2 F-12 deprecated archive) 추가 보존 (전체 R3 본문은 v1.5 §5.2 F-12 참조). reroll trigger 5종 신설 — 칼집 누락 CRITICAL / parallel 배열 누수 / steak/raw 색 / single bone at end 누수 R3 잔재 / strip 두께·길이 어긋남. F-01~F-11 본문 무변경 (각 LOCK status 유지). §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 (F-12 default % ~60% → 칼집 + small bone discs 시그니처 회피 전략 갱신 권고, 본 sprint에서는 무변경) / 캐릭터 5 + 환경 5 prompt 무변경.
- **2026-05-27 v1.5** (M1 음식 R3 reroll 6건 본문 패치, supersedes v1.4) — R2 v2 결과 시각 확인 후 사용자 selective 피드백 6건 raise → §5.2 본문(```...```) 패치. **F-07/F-08/F-10/F-11 4장은 R2 v2 LOCK candidate 유지 (사용자 silent ACK), F-04/F-09 2장은 R1 LOCK 유지**. R3 패치 내용: **F-01** v1 base 회복 (v2의 "Korean instant ramyeon noodle thickness, slim individual strands" 수식 제거, 단순 "THIN delicate yellow wavy curly egg noodles" 통일) + negative "NOT thick chunky udon-style strands" 한 줄 보존. v2에서 "원래 버전이 더 먹음직스러움" 피드백 반영 — v2 보수적 축소가 식욕 자극 ↓했던 점 회수. / **F-02** v2 contained filling 유지 + **표면 topping syrup drizzle 추가** ("On the golden-brown surface of the disc, a small drizzle of glossy dark brown sugar syrup is gently swirled on top as a finishing touch, like syrup on a pancake, NOT a flood, NOT pouring from inside"). filling이 contained면서 topping drizzle은 별도 accent — negative에 "the small syrup drizzle on top is okay as a separate topping accent (visually distinct from the contained filling)" 명시. / **F-03** v1 base 회복 + 밥 묘사만 "white rice with FINE small grains (Korean short-grain, tight uniform field, NOT chunky oversized beads)" fix. v2의 다른 보수적 변경 제거. / **F-05** v1 base 회복 + 동일 rice grain fix. / **F-06** v2 base + 베어 문 단면 **cross-section 4요소 명확 visible** 강화 — (1) brown cooked sausage core at center cylindrical visible / (2) bright yellow mozzarella cheese surrounding sausage with 2-3 stretchy strands pulling visibly / (3) golden-brown crispy panko crumb coating wrapping outside (slightly bumpy, distinct from cheese layer) / (4) red ketchup + yellow mustard zigzag drizzle on top. negative 추가 "NO missing sausage core, NO cheese-only filling without sausage, NO ambiguous interior where layers blend together — the cross-section MUST show distinct sausage + cheese + panko coating layers". v2에서 cheese만 보이고 sausage가 안 보였던 사용자 피드백 1:1 fix. / **F-12** **전면 재작성** — v1.4 LA-style cross-cut + 2-3 small bone discs along length 묘사 **전면 폐기** (사용자 피드백 "그냥 steak 같음", "갈비구이는 끝에 뼈가 좀 있어야 됨"). v1.5 정통 한식 재정의 = 3-4 thin elongated meat strips (각 piece **5-7cm long, 1-1.5cm thick**, slightly tapered at one end) + **at ONE END of each strip, a SHORT WHITE RIB BONE protrudes about 1-2cm** (traditional Korean galbi cut, bone-in at one end, NOT cross-cut with multiple bone discs along length, NOT American slab, NOT bone-less yakiniku slice) + natural overlapping plating with bones pointing in slightly different directions + soy-pear-garlic glaze + grill marks + sesame + 마늘 slice + 상추/깻잎 ssam side. negative 강화 "NOT LA-style cross-cut with multiple small round bone discs along the strip length", "NOT thick boneless steak", "NOT a rack of ribs with one huge bone", "NOT meat without any visible bone". reroll 트리거 "steak처럼 보임 / LA cross-cut 누수" 2건 신설. §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 운영 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.
- **2026-05-27 v1.4** (M1 음식 R2 reroll 10건 본문 패치, supersedes v1.3) — R1 v1 결과 12장 시각 확인 후 사용자 구체 피드백 10건 raise → §5.2 본문(```...```) 패치. F-04 떡볶이 / F-09 김치찌개 2장은 R1 LOCK 유지 (본문 무변경). 패치 내용: **F-01** 면 두께 THIN delicate + negative "NOT thick chunky udon-style strands" / **F-02** 시럽 흘러나오는 양 대폭 축소 (tiny hint peeks through small slit, mostly contained inside) + negative "NO excessive syrup overflow, NO molten lava-like outpour" / **F-03** 밥알 FINE small grains (Korean short-grain, barely visible) + negative "NOT chunky oversized rice grains" / **F-05** 동일 fix (밥알) / **F-06** 종이 wrapper 제거 → "held cleanly by the stick with no paper wrapper" + negative "NO awkward paper plate" / **F-07** 파/새우 위에서 → 반죽 안에 섞임 (mixed into and partially submerged within the golden batter, BAKED INTO the pancake) + negative "NO ingredients sitting on top as separate toppings" / **F-08** 동일 fix (밥알) / **F-10** 두부 재정의 (mound of soft tofu broken into irregular cloud-like fluffy white curds like soft cottage cheese clumps or torn fluffy clouds, organic uneven shapes) + reroll 트리거 신설 "두부 모양 어색" / **F-11** 당면 두께 THIN delicate translucent + negative "NOT thick chunky strands" / **F-12** **전면 재작성** — LA-style cross-cut strip (3-4cm × 8-10cm) + 각 strip에 2-3 small round white bone cross-sections along its length (the iconic LA Galbi cut signature) + natural overlapping plating + negative 강화 "NOT a single thick rib slab, NOT one giant bone, NOT bone-on-side American-style ribs" + reroll 트리거 "갈비뼈 모양 어색" 신설. §2.4 STYLE_SUFFIX_FOOD / §5.1 개요 / §5.3 cross-호환 / §5.4 risk top 5 / 캐릭터 5 + 환경 5 prompt 무변경.
- **2026-05-27 v1.3** (M1 음식 12 anchor 추가, supersedes v1.2) — M1 sprint 진입. §0 anchor 표에 F-01~F-12 12행 추가 (pending). **§2.4 STYLE_SUFFIX_FOOD 신설** — 음식 카드 공통 suffix (square 1:1, top-down or 7/8, Cool Sage `#C8D5C0` 또는 Cream-white `#FAFAFA` bg, modern flat clean plated dish hero shot, white baekja 또는 pale celadon bowl/plate, slim 2-3px outline, saturation 80-90%, soft 1-layer cel shading + 1 specular highlight 허용, no characters/hands/cooking action). negative 확장: 일/중/미국 음식 cross-cultural 누수 항목 명시 (sushi maki, lo mein, American corn dog 등). 이전 §2.4 anchor consistency 운영 규칙은 §2.5로 번호 shift. **§5.1~§5.4 음식 12 anchor 전체 prompts 작성** (F-01 Ramyeon, F-02 Hotteok, F-03 Kimbap, F-04 Tteokbokki, F-05 Kimchi Fried Rice, F-06 Korean Corn Dog, F-07 Haemul Pajeon, F-08 Bibimbap, F-09 Kimchi Jjigae, F-10 Sundubu Jjigae, F-11 Japchae, F-12 Galbi-gui). 각 음식별 = English title (icon-first English minimal) + 식별 핵심 시각 요소 + Tier 1/2 단서 (abundance) + DALL-E 3 자연어 prompt + DALL-E 3 약점 회피 노트 (한식↔일/중/미국 cross-cultural 누수 risk 별도 명시) + reroll 트리거. §5.1.1 생성 순서 추천 (난도 오름차순 + risk 후순위, F-01 anchor 시드 → F-02 → ... → F-12 가장 까다로움). §5.3 cross-호환 운영 (F-01 reference upload + style 일관성 instruction). §5.4 ChatGPT 약점 risk top 5 (F-12 Galbi-gui 60%/F-03 Kimbap 70%/F-06 Corn Dog 80%/F-11 Japchae 70%/F-09 Kimchi Jjigae 50%). §5.5~§5.7 (이전 cut anim / reaction / 재료/UI/VFX) 번호 shift + M1 후반/M2로 격리 명시. 캐릭터 5 (§3) + 환경 5 (§4) prompt 무변경.
- **2026-05-27 v1.2** (modern mobile casual reset, supersedes v1.1) — iter2 사용자 진단 "올드함" 반영. §0/§0.1/§0.2 anchor 표 운영 무변경 (v1.1 sync 유지). §1 모델 선택 무변경. **§2.2 STYLE_SUFFIX_BG 재작성** — Royal Match modern saturated 80~90% + cool tone bg (soft mint / pastel teal) + slim outline 2~3px + awning solid + accent trim (이탈리아 회피) + soft 1-layer cel shading 허용. 회피 negative 확장: beige/cream paper/scrapbook/storybook/kraft paper/vintage texture/golden hour/Cookie Run/Toca Boca/Toon Blast/Italian flag awning/mortar and pestle/shop owner. **§2.3 STYLE_SUFFIX_CHAR 재작성** — Royal Match + Subway Surfers chibi energy + dynamic action pose with motion lines + light pink cheek (#FFCFCF, Cookie Run 진한 분홍 회피) + soft mint cool bg + slim outline 2~3px + 80~90% saturation. **§3 캐릭터 5종 prompts 전면 재작성** — CH-01 bowl-cut hair LOCK + 프라이팬+spatula dynamic stirring (절구 회피 명시) + soft mint bg + light pink cheek + warm orange hoodie + cool teal pants(CH-02) 등 warm/cool 균형. CH-02~05 family IP reference inheritance 갱신 (anchor file = CH-01 bowl-cut + 소프트 흰 앞치마 + 비비드 오렌지 후드 기준). 각 prompt에 v1.2 신규 reroll 트리거 (G_new modernity FAIL / 절구 누수 / G2 dynamic pose FAIL / G3 채도 FAIL / G6 painterly+storybook 누수 / 베이지 누수 / 이탈리아 awning 누수 / 사람 누수 / 손맛 texture 누수) 추가. **§4 환경 5종 prompts 전면 재작성** — Royal Match modern flat clean, awning v1.2 sync (이탈리아 회피, solid + 1 trim), cool tone sky (soft mint or pastel teal light variant), no people LOCK 명시 강화, "재래시장 손맛" texture 제거 LOCK, 채도 80~90% 상향. §5 도구 매핑 sync (절구 회피 + 프라이팬+spatula 9/12 + 냄비+국자 3~4/12 + 도마+칼 ADR-005 + 김밥말이 1/12). format은 v1.1 자연어 + Important: avoid 동일 유지. M1 placeholder 음식 12 / cut anim / 양친 reaction 6컷 / 재료 / UI / VFX 무변경 (본 sprint 범위 외).
- **2026-05-27 v1.1** (ChatGPT 영구 sync from MJ, supersedes v1.0) — art 도구 영구 변경 (사용자 confirm 2026-05-27). MJ 전용 param/구문(`--ar 1:1`, `--ar 16:9`, `--stylize 100`, `--sref`, `--sw`, `--v 6.1`, `--niji 6`, `--no X, Y`) 모두 제거. ChatGPT 자연어 형식 ("square 1:1 format" / "wide 16:9 landscape" / "minimal/moderate/highly stylized" / "Important: avoid ...")으로 전면 재작성. §0 anchor 표 컬럼 변경 (MJ Job ID/sref URL/seed → ChatGPT 세션 URL/파일 경로/subject anchor 문장). §0.1 **sref 운영 → subject anchor 운영** 재작성 — sref URL 대체 메커니즘 3축: (1) subject anchor 단어 4 variant prompt에서 동일 sentence 복사 + (2) reference image upload (선택, 강력) + (3) 같은 채팅 세션 안 follow-up. §0.2 결과 인계 schema 갱신 (4-grid 선택 칸 제거, ChatGPT 세션 URL + reference image 사용 여부 + follow-up 횟수 컬럼 추가). §1 모델 선택 정책 — ChatGPT 단일 model (내부 자동, dual model 운영 개념 제거). §2 STYLE_SUFFIX_BG / STYLE_SUFFIX_CHAR ChatGPT 자연어 재작성 (Format/Style/Important: avoid 구조). §2.4 anchor consistency 운영 규칙 (sref 대체) — Round 1·2·3 follow-up 대화로 lock, sw 숫자 대체로 "더 reference와 비슷하게" 자연어, 세션 분기 권장. §3 캐릭터 5종 prompt ChatGPT 자연어로 전면 재작성 — 각 prompt에 Expected output 특징 + Reference image upload 권장 + Reroll 트리거 follow-up 대화 형식. §4 환경 5종 prompt 동일 재작성. §5 M1 placeholder ChatGPT 형식 — 칼/도마 base prompt 자연어, cut anim frame은 같은 채팅 세션 follow-up으로 일관성 lock, 양친 reaction은 CH-02/CH-03 lock image reference upload.
- **2026-05-27 v1.0** (archived; MJ 기반) — scratch rewrite, hyper-casual flat, v6.1 single model. MJ comma+--param 형식 prompts.
- **2026-05-24 v0.3** (archived; mascot 톤) — 주인공 선택형 남/여 분리. CH-01 → CH-01a + CH-01b.
- **2026-05-24 v0.2** (archived; mascot 톤) — Week 1 anchor lock 키트 연동.
- **2026-05-23 v0.1** (archived; mascot 톤) — 초안.
