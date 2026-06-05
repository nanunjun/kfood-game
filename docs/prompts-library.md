# Prompts Library — K-Food Master MVP

> 버전: **v1.24 (2026-06-04, Phase B + C guest avatar 5 + 15 = 20장 prompt set §5.15 신설, 친구 NPC 시스템 art LOCK 진입 — 5 guest [junho/mina/riley/mrs_lee/seoyeon] × 4 emotion [neutral/happy/excited/disappointed], 가정용 family IP CH-02/CH-03 + R-01~06와 명확 차별, ChatGPT image edit API 2-pass [Phase B neutral generation → Phase C 3 emotion variant via image edit lock]) — supersedes v1.23**

> **v1.24 변경 (2026-06-04, Phase B + C guest avatar 5 + 15 = 20장 prompt set 신설 §5.15, supersedes v1.23)**: 친구 NPC 시스템의 5 guest avatar art LOCK 진입. 현재 `godot-project/scripts/ui/components/guest_card_v2.gd`는 AVATAR_TINT placeholder (단색 채움 + 첫 글자 Label)만 사용 중 — 실제 캐릭터 art 0건. Phase B (5 guest neutral) + Phase C (15 emotion variant, neutral overlap 제외) = 총 20 PNG 생성. 5 guest 시각 identity (guests.csv v3.0 + game-designer notes 매핑): junho = 호방 매콤 매니아 (short messy dark brown hair + bold red graphic t-shirt #E04848 + 작은 flame/chili icon accent) / mina = 단맛 발랄 (warm chestnut brown side ponytail + 작은 pastel pink hair clip + 소프트 pastel pink sweater #F8C4D0 + 작은 heart/strawberry icon accent) / riley = 외국인 산뜻함 (warm honey blonde wavy hair + 작은 freckle accent + 작은 mint green/light yellow hoodie #B4E4C4 또는 #F4E48C — **유일하게 비-Korean 외국인 identity, 디자인 의도**) / mrs_lee = 멘토 따뜻한 집밥파 (short permed wavy salt-and-pepper hair + 작은 round reading glasses + dusty mauve top + 작은 beige cardigan — **CH-02 mother 가정 어머니와 명확 차별 CRITICAL: 머리 형태 round-bun 아닌 permed wavy + glasses signature + persimmon red jeogori 아닌 mauve+beige 의상 family**) / seoyeon = 집밥파 따뜻 (medium-length straight dark brown hair + 소프트 oat-beige turtleneck #E8D8C4 + 작은 gold stud earring accent). 4 emotion = neutral (정상 dot eyes + 살짝 arc smile, R-02/R-05 톤 anchor seed default) / happy (closed crescent ^_^ + medium open smile + 1-2 sparkle, R-02 base intensification) / excited (GIANT closed-arc + WIDE open with teeth/tongue hint + 양손 raised + 3-5 sparkle + 1-2 star + 2-3 motion line, R-03/R-06 코믹 톤 reference) / disappointed (LOWERED EYEBROWS HERO cue + SUBTLE DOWNTURNED closed mouth + slight head tilt down-away + optional 1 sweat drop or "..." icon — **subtle mature adult disappointment, NOT sad sobbing crying, NOT teardrop falling — R-01/R-04 v1 deprecated sad teardrop 명시적 회피, 친구 disappointment 톤 분리**). v1.24 = (a) **§5.15 신설 Phase B + C guest avatar 20장 full prompts** (5 guest identity_prompt × 4 emotion expression_prompt — Phase B = guest identity + neutral expression + STYLE_SUFFIX_GUEST_AVATAR를 build_prompt_phase_b로 합성 / Phase C = COMMON_FRAME image edit (family IP lock) + emotion expression_prompt change + STYLE_SUFFIX_GUEST_AVATAR를 build_prompt_phase_c로 합성, edit API base = Phase B neutral output) / (b) **§2.6에 STYLE_SUFFIX_GUEST_AVATAR 명시** = bust-up portrait + chibi 1:1.7 + Cool Sage `#C8D5C0` bg + slim outline 2-3px + modern saturated 80-90% + sad teardrop crying 회피 (disappointed는 subtle eyebrow+frown) + anime girl big sparkly pupils 회피 + 가정 family IP CH-02/CH-03 명시적 누수 회피 (guest는 가정 mother/father 아님, 친구 NPC) + cross-cultural negative (Japanese kimono / Chinese qipao / Western lederhosen — Riley 예외 = 외국인 identity 명시) / (c) **§0 anchor 표 5 row × 4 emotion = 20 row 추가** (junho_neutral / junho_happy / junho_excited / junho_disappointed / mina_neutral / ... / seoyeon_disappointed, 모두 pending Phase B + C) / (d) **새 driver script `tools/gen_guest_avatars.py` 신설** — `tools/edit_reaction_anchors_v3.py` template 기반 + 2-pass 패턴 (Phase B `client.images.generate()` prompt-only + Phase C `client.images.edit(model="gpt-image-1", image=open(neutral_base, "rb"), prompt=COMMON_FRAME + emotion + suffix, size, quality, n=1)`) + GUESTS list 5개 inline (id / display_name / personality / identity_prompt) + EMOTIONS_PHASE_B / EMOTIONS_PHASE_C 2개 list inline + STYLE_SUFFIX_GUEST_AVATAR 상수 inline + CLI args (`--phase B|C|ALL` `--only junho,mina` `--emotion happy|excited|disappointed` `--quality` `--version` `--out-dir`) + gpt-image-1 medium 1024×1024 default + 출력 default `assets-raw/guest_avatars_m1/` + 파일명 패턴 `{guest_id}_{emotion}_{version}.png` (예: junho_neutral_v1.png). 2-pass 이유 = Phase B prompt-only neutral은 anchor seed 역할 (각 guest의 identity 시각 정착) + Phase C image edit = neutral base에서 표정만 변경하여 family IP (hair / outfit / face proportions) 정확 재현 (R-01~06 v3 image edit 패턴 입증 동일 방식). main thread 실행 명령: (1) Phase B test (1 guest neutral 우선): `py tools/gen_guest_avatars.py --phase B --only junho --quality medium` (1장 × $0.042 ≈ $0.05, ~30초) → 시각 확인 후 (2) Phase B 5장 batch: `py tools/gen_guest_avatars.py --phase B --quality medium` (5장 × $0.042 ≈ $0.21, ~2-3분) → 5장 시각 확인 + LOCK 후 (3) Phase C 15장 batch: `py tools/gen_guest_avatars.py --phase C --quality medium` (15장 × $0.042 ≈ $0.63, ~5-7분) — 또는 (4) 전체 ALL 20장: `py tools/gen_guest_avatars.py --phase ALL --quality medium` (20장 × $0.042 ≈ $0.84, ~7-10분, 출력 `assets-raw/guest_avatars_m1/{guest_id}_{emotion}_v1.png`). ChatGPT 약점 risk top 3 = (a) **한식↔Japanese chibi guest 누수 ~40%** (특히 mina pastel pink sweater + side ponytail이 Japanese anime girl 학생 톤으로 누수 risk → STYLE_SUFFIX_GUEST_AVATAR에 "anime girl, manga style, school uniform" 명시 강제 + identity_prompt에 "Korean young adult female in her 20s, NOT student" 명시 + 별 sparkly pupils 회피) / (b) **Western character 누수 ~35% Riley 제외** (junho/mina/mrs_lee/seoyeon 4 guest는 Korean identity 강제, ChatGPT default가 글로벌 cartoon character로 누수 risk → identity_prompt에 "Korean" 명시 + dark brown hair tone 명시 + Korean modern casual streetwear 명시. Riley는 예외 = "non-Korean foreign 외국인" 명시적 OK, 그래도 cosmopolitan 친구 톤 유지 NOT cowboy/Western caricature) / (c) **anime girl big sparkly eyes 누수 ~30%** (excited emotion에서 ★3 sparkle eyes alternative가 enlarged shoujo pupils로 누수 risk → STYLE_SUFFIX_GUEST_AVATAR에 "sparkle accents stay SEPARATE floating geometric icons OUTSIDE the eye, NOT enlarged shoujo pupils inside" 명시 강제, R-03/R-06 v3 image edit 결과와 동일 톤 유지). **부차 risk (P2)**: mrs_lee가 CH-02 mother와 시각 confused ~30% (둘 다 50s+ Korean 여성 → identity_prompt CRITICAL 절 "Mrs Lee must look CLEARLY DIFFERENT from CH-02 family mother — permed wavy NOT round-bun + glasses + mauve+beige NOT persimmon red jeogori" 강제) / disappointed emotion sad teardrop 누수 ~25% (ChatGPT default가 disappointed → crying으로 추론 risk → emotion prompt CRITICAL 절 "subtle eyebrow + downturned closed mouth + NO tears NOT crying" 명시 강제) / excited emotion goofy Looney Tunes 누수 ~25% (★3 explosive peak이 폭주 risk → "Royal Match aesthetic + K-drama reaction tone, NOT slapstick" 명시 강제). **G_guest_avatar 평가 게이트** = art-anchor-rubric v1.23 §5.15에서 정의 (G_guest_avatar 5 요소 = family IP consistency 5 guest 일관 + emotion gradient 4 단계 명확 + bust-up portrait chibi 1:1.7 + Cool Sage bg cross-asset + cross-cultural 누수 0건). **godot-dev 후속 swap spec** = (i) guest_card_v2.gd L27-32 `AVATAR_TINT` dict는 보존 (fallback) + L109-124 avatar_panel 구간에 `load("res://assets-processed/guest_avatars/{guest_id}_{emotion}.png")` 동적 load 추가, emotion은 game state context 따라 결정 (selection screen = neutral / result screen = happy or excited or disappointed by compat tier) / (ii) `_avatar_panel`을 TextureRect로 변경 또는 Panel + child TextureRect 추가 / (iii) `assets-processed/guest_avatars/` 디렉터리 신설 + Phase B/C 20 PNG를 240×240 또는 180×180 game size로 crop + rembg transparent post-process (ADR-007 호환). 음식 12 / 환경 5 v4 / 캐릭터 5 / cut 7 / ingredient whole 12 / reaction 6 / ingredient cut 12 / 조리도구 12 / UI 7 / VFX 5 / mini extra 2 본문 무변경 (Phase B+C는 추가 art only).

> v1.23 (2026-05-31, M1 후반 art sprint mini extra — game-designer motion-spec 후속 gap 2건 [hand_marinade 손바닥 marinade press anchor + corndog_batter_bowl 콘도그 batter dip 그릇 anchor] §5.14 신설, ADR-005 Stage 2A 양념재우기 / dip substitute mechanic 매핑 prerequisite) — supersedes v1.22

> **v1.23 변경 (2026-05-31, M1 후반 art sprint mini extra — game-designer motion-spec 후속 asset gap 2건 §5.14 신설, supersedes v1.22)**: game-designer motion-spec 후속에서 (a) F-09 불고기 Stage 2A 양념재우기 mechanic은 손바닥 press motion (위→아래 tap)이 dominant action이나 hand sprite anchor 부재 / (b) F-06 콘도그 Stage 2A는 dip substitute (콘도그 stick을 batter에 담그기) mechanic이 dominant이나 batter bowl anchor 부재 — 두 gap 발견. **§5.14 신설 mini extra 2장 prompt set** (hand_marinade + corndog_batter_bowl). 각 mini extra prompt = 단독 sprite + chibi friendly tone + slim outline 2-3px + Cool Sage `#C8D5C0` bg + ambient ellipse shadow 유지 (diegetic prop이라 UI/VFX와 차별점 — UI/VFX는 HUD overlay이라 shadow 없음, mini extra는 in-scene prop이라 shadow 있음) + TOOL/CUT/INGREDIENT/FOOD cluster 일관성 (49+ → 51 anchor cluster 합류). **§2.5에 STYLE_SUFFIX_MINI 명시** = 단독 sprite + Cool Sage bg + 7/8 perspective + Cookingo-inspired flat clean + chibi friendly tone + realistic human anatomy 회피 (NO detailed knuckles / veins / fingerprints / nail beds / palm creases / hand hair / age spots / jewelry — keep simple chibi mitten-friendly silhouette) + character body 회피 (hand sprites = hand + minimal wrist stub only, no arm/elbow/shoulder/body/face). **§0 anchor 표 EX-01/EX-02 2 row 추가** (pending M1 후반 mini extra). **새 driver script `tools/gen_mini_extra_m1.py` 신설** — `tools/gen_tool_anchors_m1.py` template 기반 + EXTRAS list 2개 inline (id=slug / name=slug / usage=game-designer motion-spec mapping / body) + STYLE_SUFFIX_MINI inline append via `.replace("%s", STYLE_SUFFIX_MINI, 1)` (gen_food/gen_ingredient/gen_reaction/gen_tool/gen_ui_vfx에서 발생했던 `body % SUFFIX` Python old-style ValueError fix 적용) + CLI args (`--only` `--version` `--quality` `--out-dir`) + gpt-image-1 medium 1024×1024 default + 출력 default `assets-raw/mini_extra_m1/`. 2장 prompt body 핵심 (각 한 줄 시그니처): **hand_marinade** = single open palm hand 7/8 perspective palm-down + warm peachy skin #F5C9A2 + 4 fingers close-together ready-to-press + short wrist stub at upper edge + 1-2 subtle downward motion lines + slim warm dark outline + ambient ellipse shadow underneath + NOT realistic hand (no detailed knuckles/veins/fingernails/palm creases/hair/jewelry) + NOT full arm (hand + wrist stub only, NO elbow/shoulder/body) + NOT clenched fist / thumbs-up / pointing finger / pinch grip / hand-shake / hand-holding-utensil / glove / character portrait / **corndog_batter_bowl** = clean matte white round ceramic mixing bowl ~26-30cm × 11-13cm + NO handles + filled with viscous light tan/golden cornmeal-wheat batter #E8C58A 65-75% depth + elliptical batter pool surface in 7/8 view + subtle slim batter meniscus at inner rim + ONE specular highlight (glossy wet batter sheen) + slim warm dark outline + ambient ellipse shadow + NO corn dog stick dipping (food layer runtime composited) + NOT TOOL-11 silver-gray bibimbap mixing bowl (TOOL-11 is stainless larger 28-32cm empty — this is matte white ceramic smaller filled with batter) / NOT TOOL-02 yangun pot (yangun has 2 ear handles + empty — this has no handles + filled with batter) / NOT TOOL-04 deep fryer (deep fryer has 2 ear handles + golden oil — this has no handles + viscous batter) / NOT soup bowl / NOT pancake batter (corndog is thicker viscous, pancake is runnier) / NOT cake batter with whisk inside / NOT dough kneading bowl with solid dough / NOT Japanese donburi / NOT Chinese decorative ceramic. main thread 실행 명령: (1) test (가장 risk 높은 hand_marinade 우선): `py tools/gen_mini_extra_m1.py --only hand_marinade --quality medium` (1장 × $0.042 ≈ $0.04, ~30초) → 시각 확인 후 (2) 2장 batch: `py tools/gen_mini_extra_m1.py --quality medium` (2장 × $0.042 ≈ $0.08, ~1-2분, 출력 `assets-raw/mini_extra_m1/hand_marinade_v1.png` + `corndog_batter_bowl_v1.png`). ChatGPT 약점 risk top 3 = (a) **hand_marinade realistic hand anatomy 누수 ~50%** (ChatGPT default가 detailed knuckle wrinkles + visible veins + fingernail bed detail + palm crease lines 로 추론 → COMMON_FRAME + body prompt에 "friendly chibi-style", "NO detailed knuckles", "NO veins", "NO fingerprint detail", "NO realistic fingernails", "NO palm crease lines", "NO hair on hand" explicit 강제로 회피) / (b) **hand_marinade full arm 누수 ~40%** (단순 손바닥만 요청해도 elbow/upper arm/shoulder/character body까지 그릴 risk → "short wrist stub at upper edge only, NO elbow / NO upper arm / NO shoulder / NO character body / NO face" explicit 강제) / (c) **corndog_batter_bowl TOOL-11 mixing bowl과 시각 동일 누수 ~40%** (둘 다 mixing bowl이라 ChatGPT가 silver-gray stainless로 추론할 risk → "clean matte white OR light cream CERAMIC, NOT silver-gray stainless, NOT TOOL-11 bibimbap mixing bowl" explicit 강제 + 색상 #FAFAFA fill + filled with viscous batter 65-75% depth 명시 [TOOL-11은 empty라 시각 분리]). **부차 risk (P2)**: hand_marinade thumb-up 누수 ~25% (R-05 아버지 ★2 thumb-up gesture cross-asset 영향) / corndog_batter_bowl pancake batter pourable runny 누수 ~25% (얇은 액체 batter로 추론, 강제 viscous thick) / corndog_batter_bowl 흰 그릇 ceramic 보다 검정 cast-iron 누수 ~20% (corndog 깊은 튀김 연상으로 cast-iron 추론, 강제 matte white) / corndog_batter_bowl batter 색이 chocolate brown으로 누수 ~20% (gravy/brown sauce 추론, 강제 light tan/golden #E8C58A). **driver 옵션 결정 사유** = 옵션 1 (별도 driver `gen_mini_extra_m1.py` 신설) 채택 vs 옵션 2 (`gen_tool_anchors_m1.py` extend TOOL-13/14 추가). 옵션 1 선택 사유 = (i) 카테고리 분리 명확 (TOOL은 조리도구 cluster, mini extra는 hand/specialty container cluster — 의미적으로 다름), (ii) 이후 추가 mini asset (small one-off prop / hand pose / specialty container 등 game-designer motion-spec 후속에서 추가 발생 시) 확장 자연스러움, (iii) STYLE_SUFFIX_MINI 차별점 (hand sprite의 realistic anatomy 회피 negative + chibi mitten-friendly tone은 TOOL의 industrial 회피 negative와 의미적으로 다름). 음식 12 / 환경 5 v4 / 캐릭터 5 / cut 7 / ingredient whole 12 / reaction 6 / ingredient cut 12 / 조리도구 12 / UI 7 / VFX 5 본문 무변경.

> v1.22 (2026-05-31, M1 후반 art sprint 마지막 6번째 — UI 7장 + VFX 5장 = 12 anchor prompt set 신설 §5.12 UI + §5.13 VFX, ADR-005 Stage 2A/B/C HUD + PASS feedback prerequisite, ADR-007 rembg transparent 표준 호환 [단순 형태 + outline + 충분한 padding], icon+영어 minimal lock 유지) — supersedes v1.21**
> 작성자: art-director
> 상위 문서: [`art-style-guide.md` v1.2](art-style-guide.md), [`ai-session-kit.md` v1.2](ai-session-kit.md), [`art-anchor-rubric.md` v1.22](art-anchor-rubric.md), [`decisions.md` ADR-003](decisions.md#adr-003-mvp-first-전환--34개월-출시--점진-확대-supersedes-adr-002), [`decisions.md` ADR-005](decisions.md#adr-005), [`art-workload-estimate.md` v4.1](art-workload-estimate.md)
> 본 문서 범위: Week 1 anchor lock 10장 (캐릭터 5 v1.2 lock candidate + **환경 5 v4 BG-01~05 image edit — v1.2 base PNG 입력 + 지붕만 교체, frontal view, 5가게 구조 일관성**) + **M1 sprint 음식 12 anchor (§5.2 full prompts, v1.3 신설~v1.10 R7, v1.17 F-02/F-09 mvp v2.2 sync)** + **M1 후반 sprint 칼/도마 base + cut style 6종 (§5.5 full prompts, v1.14 신설, ADR-005 Stage 2A rhythm tap prerequisite)** + **M1 후반 sprint 음식 12 × hero ingredient whole 12장 (§5.6 full prompts, v1.15 신설, v1.17 ING-02/ING-09 mvp v2.2 sync)** + **M1 후반 sprint 양친 reaction 6컷 (§5.7 v1.21 v3 image edit — CH-02/CH-03 base + 표정만 변경 + 코믹 amplification 3축 [눈/입/body+icons], family IP consistency lock v2 유지, supersedes v1.18 v2 점잖은 톤)** + **M1 후반 sprint 음식 12 × hero ingredient CUT 12장 (§5.10 full prompts, v1.19 신설, ADR-005 Stage 2B/2C "after"-cut pair, 사용자 verbatim "손질하고 나서의 ingredient 이미지" trigger)** + **M1 후반 sprint 조리도구 12종 (§5.11 full prompts, v1.20 신설, 각각 별도 sprite + 애니메이션 prerequisite, Cookingo: Perfect Meal reference, ADR-005 Stage 2B/2C 조리 mechanic prerequisite)** + **M1 후반 sprint 마지막 UI 7장 + VFX 5장 = 12 anchor (§5.12 UI + §5.13 VFX full prompts, v1.22 신설, ADR-005 Stage 2A/B/C HUD + PASS feedback prerequisite, ADR-007 rembg transparent 표준 호환)**.

> **v1.22 변경 (2026-05-31, M1 후반 art sprint 마지막 6번째 — UI 7장 + VFX 5장 = 총 12 anchor prompt set 신설 §5.12 UI + §5.13 VFX, ADR-005 Stage 2A/B/C HUD + PASS feedback prerequisite, ADR-007 rembg transparent 호환, supersedes v1.21)**: M1 후반 art sprint 71 anchor LOCK 완료 (commit 4ed91b9 pushed: 음식 12 + 환경 5 + 캐릭터 5 + cut 7 + ingredient whole 12 + ingredient cut 12 + reaction 6 + 조리도구 12 = 71) 후 **M1 마지막 sub-sprint** 진입. UI/VFX는 §5.8 placeholder에서 v1.22에서 §5.12 UI + §5.13 VFX로 정식 분리·확장 (§5.8은 deprecated placeholder note만 남김). ADR-005 4-stage rhythm tap의 HUD 시각 요소 (tap target / star rating / heart life / coin / timer bar / settings gear / back arrow) + PASS feedback VFX (perfect glow / star burst / steam swirl / heart float / sparkle multi) 12장 동시 생성. **UI 7장** = UI-01 tap_target_ring (Stage 2A rhythm tap perfect zone concentric ring) / UI-02 star_rating (Stage 3 ★1/★2/★3 golden 5-point star, single sprite for HUD 3개 instantiation) / UI-03 heart_life (HUD life count, 라이프 시스템, 코랄 #FF5C5C rounded heart) / UI-04 coin_currency (HUD coin, golden round coin + center star pentagram symbol matching UI-02 cross-asset) / UI-05 timer_bar (Stage 2C 조리 시간 horizontal pill progress bar, 60-65% green fill on cream track) / UI-06 settings_gear (8-tooth gray cogwheel + center transparent hole) / UI-07 back_arrow (left-chevron + horizontal shaft, optional cream rounded button bg). **VFX 5장** = VFX-01 perfect_glow_ring (Stage 2A perfect tap PASS feedback, yellow radial burst ring + 8-12 spike rays + optional "PERFECT!" English caps label) / VFX-02 star_burst (Stage 3 ★1/2/3 earn moment, central golden 5-point star + 6-8 radiating rays + 5-7 scattered white sparkles) / VFX-03 steam_swirl (Stage 2C 조리 active feedback, 2-3 rising white S-curve wisps with tapered top curl, looping animation overlay) / VFX-04 heart_float (Stage 3 ★3 family reaction 어머니, 3-5 coral hearts at varying sizes + slight rotations ascending cluster) / VFX-05 sparkle_multi (general bonus/combo celebration, 6-9 four-point white+gold sparkle crosses organic scatter). v1.22 = (a) **§5.12 UI 7장 full prompts 신설** + **§5.13 VFX 5장 full prompts 신설** (§5.8 placeholder → deprecated note, §5.12/§5.13 정식 분리. 각 UI/VFX prompt = 단독 sprite + simple geometric 형태 + slim outline 2-3px + Cool Sage `#C8D5C0` bg + 충분한 padding rembg-safe + icon-first 영어 minimal text + cross-asset 49+ cluster 합류). (b) **§2.5에 STYLE_SUFFIX_UI 명시** = 단독 sprite isolation + flat front-facing view + Cool Sage bg + simple geometric flat Cookingo-inspired + slim outline + 영어 minimal text policy (한글/일본어/중국어 0건) + ambient ground shadow 회피 (UI/VFX는 HUD overlay layer로 diegetic 지면 X — 음식/도구 anchor와 차별점) + photoreal 효과 회피 (light bloom / lens flare / chromatic aberration / motion blur / depth of field 0건, VFX는 flat geometric stylized). (c) **§0 anchor 표 UI-01~07 + VFX-01~05 12 row 추가** (pending M1 후반 6번째 마지막 sprint). (d) **새 driver script `tools/gen_ui_vfx_anchors_m1.py` 신설** — `tools/gen_tool_anchors_m1.py` template 기반 + UIS list 12개 inline (UI 7 + VFX 5) (id=UI-XX/VFX-XX / name=slug / kind=ui|vfx / usage=게임 context / body) + STYLE_SUFFIX_UI inline append via `.replace("%s", STYLE_SUFFIX_UI, 1)` (gen_food/gen_ingredient/gen_reaction/gen_tool에서 발생했던 `body % SUFFIX` Python old-style ValueError fix 적용) + CLI args (`--only` `--version` `--quality` `--out-dir`) + gpt-image-1 medium 1024×1024 default + 출력 default `assets-raw/ui_vfx_anchors_m1/`. main thread 실행 명령: (1) test (가장 risk 높은 UI-01 tap target 우선): `py tools/gen_ui_vfx_anchors_m1.py --only UI-01 --quality medium` (1장 × $0.042 ≈ $0.05, ~30초) → 시각 확인 후 (2) 12장 batch: `py tools/gen_ui_vfx_anchors_m1.py --quality medium` (12장 × $0.042 ≈ $0.50, ~5분, 출력 `assets-raw/ui_vfx_anchors_m1/UI-XX_<name>_v1.png` + `VFX-XX_<name>_v1.png`). 또는 UI만 7장: `--only UI-01,UI-02,UI-03,UI-04,UI-05,UI-06,UI-07` / VFX만 5장: `--only VFX-01,VFX-02,VFX-03,VFX-04,VFX-05`. **ADR-007 rembg transparent 호환** = 12장 모두 처음부터 transparent 후처리 안전하게 설계 — (i) 단순 형태 + slim outline 2-3px (rembg edge detection 강화) / (ii) 충분한 bg padding (element가 frame edge에 닿지 않음, 모든 변 ~15-25% margin) / (iii) ambient shadow 회피 (UI/VFX는 diegetic 지면 X) / (iv) UI-06 settings_gear의 center hole은 Cool Sage 동일 bg fill로 명시 (rembg 후 진짜 transparent hole로 보존). **icon+영어 minimal lock 유지** (feedback_i18n_icon_first.md 2026-05-27) = 12장 모두 한글 0건, 영어 caps text는 VFX-01 "PERFECT!" 1장만 (player 즉시 PASS feedback semantics 강화). 다른 11장은 icon-only (text 0건). ChatGPT 약점 risk top 3 = (a) **UI-06 settings_gear center hole이 hole로 인식 안 되고 Cool Sage 색으로 채워진 disc로 생성될 risk ~40%** (rembg 후 hole이 사라지면 단순 동그라미 gear로 보임 → COMMON_FRAME에 "round transparent hole rendered as Cool Sage bg fill to suggest true hole through gear, critical for rembg transparent post-process" 명시 강제로 회피, R3 fallback = 사용자가 GIMP/Photoshop으로 hole 영역 수동 erase) / (b) **VFX-01 "PERFECT!" English label이 잘못된 글자로 corrupt / 한글이나 unrecognizable script로 생성될 risk ~35%** (DALL-E text generation 약점 — gpt-image-1 text rendering도 100% 정확하지 않음, "PERFECT!" 같은 짧은 단어조차 "PEPFECT" "PERFFCT" 등 typo 가능 → R2 fallback = `--only VFX-01 --version v2` reroll, R3 fallback = text 없는 base reroll 후 사용자 Figma/Inkscape로 PERFECT! 텍스트 overlay 직접 합성) / (c) **VFX-03 steam_swirl이 stark white로 처리되어 Cool Sage bg와 contrast 너무 낮아 rembg가 edge 인식 실패 risk ~30%** (steam wisp의 soft off-white #F8F4EC fill이 sage bg와 너무 가까우면 rembg가 분리 못함 → COMMON_FRAME에 "slim warm dark outline 2-3px wrapping each wisp silhouette for clean rembg edge detection" 명시 강제, R3 fallback = `--only VFX-03 --version v2` reroll with "더 진한 outline + 좀 더 contrast" 추가 instruction). **G_ui / G_vfx 평가 게이트** = art-anchor-rubric v1.22 §5.12 / §5.13에서 정의 (G_ui 5 요소 = 형태 식별 + 단독 sprite isolation + transparent-friendly padding + cross-asset 49+ cluster + 영어 minimal text policy / G_vfx 5 요소 = feedback 의도 명확 + 단독 sprite isolation + transparent-friendly padding + cross-asset cluster + photoreal effect 0건). 음식 12 / 환경 5 v4 / 캐릭터 5 / cut 7 / ingredient whole 12 / reaction 6 / ingredient cut 12 / 조리도구 12 본문 무변경. **§5.8 deprecated note**: 본 v1.22 이전 §5.8 placeholder ("UI/VFX는 M2 sprint placeholder")는 v1.22에서 §5.12 UI + §5.13 VFX로 정식 분리·승격되어 deprecated, 본 §5.8은 위치 reference 보존만 (실제 본문은 §5.12 / §5.13 참조).
> 도구: **ChatGPT (GPT-4o image / DALL-E)** 영구 lock. **환경 5장 v4 + 양친 reaction 6컷 v2는 gpt-image-1 image edit API** (`client.images.edit(model="gpt-image-1", image=...)`) 도입 — prompt-only generation으로 base 정확 재현 불가능했던 한계 극복 (환경 = v1.2 base 카게 구조 재현 / reaction = CH-02/CH-03 family IP 재현). **cut anchor 7장 + ingredient whole 12장 + ingredient cut 12장 + 조리도구 12종은 gpt-image-1 medium prompt-only generation** (cut shape / whole ingredient / cut 결과 / tool silhouette 식별이 우선이라 image edit 불필요, fresh generation으로 충분 — 각 도구는 단독 sprite이라 base reference 없음).

> **v1.21 변경 (2026-05-31, M1 후반 reaction 6컷 v3 image edit — CH-02/CH-03 base + 표정 코믹 amplification 3축, 사용자 v2 "심심함" 피드백 trigger, supersedes v1.20 §5.7 reaction 부분만 — §5.11 조리도구 등 다른 항목 무변경)**: 사용자가 v2 (image edit, family IP consistency LOCK) 결과 시각 확인 후 verbatim **"reaction을 코믹하게 만드는게 어때? 지금 reaction 이미지는 너무 심심해"** 피드백 raise. main thread 해석: v2는 family IP consistency 우수하여 LOCK 유지하나, 표정 amplification 부족 → v2 subtle smile / big smile / single-double thumb-up gradient는 점잖아서 player가 ★1/★2/★3 차이를 즉시 체감 못함, "Korean variety show / K-drama exaggerated reaction" 톤 부재. **v2 LOCK 유지 사항** = family IP consistency (어머니 round-bun simple / 아버지 darker salt-and-pepper + darker teal-green) + bust-up crop + Cool Sage `#C8D5C0` bg + chibi mascot proportions + image edit API 패턴 (CH-02/CH-03 base 직접 입력). **v3 추가 변경 (코믹 amplification 3축)**: (a) **눈 exaggeration** — ★1 정상 dot + 한 눈 up-left 사고하는 gaze + 한 eyebrow raised asymmetric / ★2 closed crescent ^_^ 더 pronounced / ★3 GIANT closed-arc ^___^ + optional 별 sparkle ✨ accent 외부 floating (NOT 안면 내부 anime shoujo pupils) / (b) **입 exaggeration** — ★1 wavy thinking line "~" 또는 narrow tight-lipped smirk / ★2 medium open smile 또는 O-shape "오~" / ★3 GIANT wide open with teeth (white flat fill) + optional tongue hint / (c) **body + emotion icons** — ★1 chin hand 사고 pose + question mark icon "?" (mother) 또는 sweat drop teardrop (father) + optional "..." 또는 thinking motion lines / ★2 한 손 cheek + 1-2 sparkle (mother) 또는 **DOUBLE thumb-up chest level** + 1-2 sparkle (father, v3 KEY CHANGE: v2 single → v3 double) / ★3 양손 raised cheek/over head + **3-5 hearts (mother)** + 3-5 sparkles + 2-3 motion lines + optional 1-2 star (mother) / **양손 fist 또는 fist+thumb-up over head** (father, ★2 chest level보다 더 높음) + **3-5 stars (father, mother와 차별)** + 4-6 sparkles + 3-4 motion lines. **어머니 vs 아버지 톤 차이 유지 + 강화**: 어머니 = warm motherly + heart icons dominant cluster (★3 explosive) / 아버지 = reserved masculine + star icons dominant cluster + raised fists (★3 explosive). v1.21 = (a) **§5.7 본문 전면 재작성 v3** (v1.18 v2 본문은 §5.7.archive v2 deprecated 절로 이동 보존; v1.16 v1 prompt-only archive는 §5.7.archive v1으로 그대로 유지). v3 approach = `client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_FRAME_V3 + expression_prompt_V3, size="1024x1024", quality="medium", n=1)` (v2와 API 패턴 동일). COMMON_FRAME_V3 핵심 추가 강제 사항 = (i) **TONE TARGET 절 신설** — "cartoon-style EXAGGERATED reaction faces in the spirit of Korean variety show or K-drama, ★1/★2/★3 = mild thinking → clearly happy → EXPLOSIVE excitement, NOT subtle progression" / (ii) **CRITICAL BOUNDARIES 5건** = sad/sleeping/crying 회피 (기존 v2 유지) + **anime girl big sparkly pupils 회피 새로 추가** (sparkle accent는 SEPARATE floating geometric icon OUTSIDE the eye, NOT enlarged anime shoujo pupils 내부) + **over-exaggerated goofy 회피 새로 추가** (eyes bulging out / tongue lolling 5x / x-eyes / swirl-eyes / Looney Tunes 톤 OUT — Royal Match + K-drama 톤 유지) + Japanese kimono/Cookie Run/3D/베이지 회피 (기존 v2 유지) + 다중 character 회피 (기존 v2 유지) + text legible 회피 (기존 v2 유지 + emotion icons는 순수 visual geometric symbols 명시). (b) **§0 anchor 표 R-01~R-06 row 6장 status 갱신** (v1.18 v2 image edit LOCK 2026-05-30 → v3 image edit pending 2026-05-31, v2 status는 family IP consistency PASS 하나 표정 amplification CONDITIONAL이라는 사유 명시). (c) **새 driver `tools/edit_reaction_anchors_v3.py` 신설** — `tools/edit_reaction_anchors_v2.py` 기반 (image edit API + base image dimensions 검증 + PIL resize fallback + b64_json 응답 처리 그대로). 구조 = COMMON_FRAME_V3 상수 inline (v2 frame + TONE TARGET + 추가 CRITICAL BOUNDARIES) / REACTIONS list 6개 inline (id / name / character / star / base / expression_prompt_v3 — 각 ★N에 EYES/MOUTH/BODY+ICONS 3축 명세) / base image 사전 검증 / CLI args (`--only` `--version` `--quality` `--out-dir`) / gpt-image-1 medium 1024×1024 default, version v3 default. v2 driver (`tools/edit_reaction_anchors_v2.py`)는 보존 (git history). v1/v2 output (R-XX_<character>_star<N>_v1.png / _v2.png 12장)도 보존 — v3와 공존 (R-XX_<character>_star<N>_v3.png), 사용자 직접 비교 가능. main thread 실행 명령: (1) test (★3 peak 강도 우선 확인 권장): `py tools/edit_reaction_anchors_v3.py --only R-03,R-06 --quality medium` (2장 × $0.042 ≈ $0.08, ~1분) → 시각 확인 후 (2) 6장 batch: `py tools/edit_reaction_anchors_v3.py --quality medium` (6장 × $0.042 ≈ $0.25, ~2-3분, 출력 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v3.png`). 또는 어머니만: `--only R-01,R-02,R-03` / 아버지만: `--only R-04,R-05,R-06`. v3 risk top 3 = (a) **anime girl big sparkly eyes 오해 ~35%** (★3 sparkle eyes alternative 옵션을 ChatGPT가 enlarged shoujo pupils 내부 sparkle로 해석할 수 있음 → COMMON_FRAME_V3 "SEPARATE floating geometric icon OUTSIDE the eye, NOT enlarged anime shoujo sparkly pupils" 명시 강제로 회피) / (b) **sad/crying 오해 ~25%** (★1 question mark + sweat drop 같은 comic 사고 icon이 sad/distress로 해석될 risk → COMMON_FRAME_V3 "MILD POSITIVE evaluation, NOT sad / NOT distress / NOT embarrassment, comic anime/manga thinking symbol" 명시 강제) / (c) **over-exaggeration goofy ~30%** (★3 EXPLOSIVE peak이 Looney Tunes goofy / x-eyes / tongue lolling 5x로 폭주할 risk → COMMON_FRAME_V3 "Royal Match aesthetic + K-drama tone, NOT slapstick" + boundary list explicit 강제). **R3 fallback (사용자 ChatGPT 웹 UI 수동 chain-of-references 워크플로)**: v3 결과가 여전히 amplification 부족 (★3가 점잖) 또는 over-shoot (goofy)이면 사용자 수동 (a) CH-02 upload + R-02 v3 generate → 어머니 seed / (b) seed + R-01/R-03 (★3 explicit "WAY MORE EXPRESSIVE" 추가) / (c) 새 세션 + CH-03 + R-05 v3 generate → 아버지 seed / (d) seed + R-04/R-06 (★3 "BIGGER FIST RAISE + MORE STARS" 추가). 음식 12장 / 환경 5장 v4 / cut anchor 7장 / ingredient whole 12장 / ingredient cut 12장 / 조리도구 12종 본문 무변경. 캐릭터 5장 본문 무변경.

> **v1.20 변경 (2026-05-31, M1 후반 art sprint 5번째 — 조리도구 12종 anchor prompt set 신설 §5.11 full prompts, 사용자 verbatim trigger, supersedes v1.19)**: 사용자 verbatim **"조리도구 디자인은 안하나? 냄비, 가스레인지, 국자 등등 각기 따로 해서 움직임을 나중에 만들어야 할거 같음. Cookingo 게임의 요리방법이 내가 구현하고 싶은거와 상당히 비슷해"** trigger로 M1 후반 art sprint 5번째 진입. **Cookingo: Perfect Meal (relaxing cooking game, Asian mobile 2025-2026)** reference — slicing/mixing/whisking/garnishing 도구별 specific action + 정확도 매칭 게임 메커니즘과 ADR-005 4-stage rhythm tap의 도구별 action mapping 정합. cut anchor 7 / ingredient whole 12 / ingredient cut 12장은 모두 도마+칼 중심 (CUT mechanic 1종) — 본 sprint는 **나머지 11종 mechanic 도구 + 1 base substrate** = **총 12 도구 sprite 각각 별도 생성** (애니메이션 prerequisite — 각 도구가 단독 sprite여야 godot-dev가 AnimationPlayer로 위치 이동/flip/scoop/mix 등 motion 독립 구현 가능). 12 도구 list (음식 매핑): TOOL-01 가스레인지 (base, all hot 조리) / TOOL-02 냄비 (boil, F-01/F-02/F-10) / TOOL-03 후라이팬 (stir-fry/pan-fry, F-05/F-07/F-09) / TOOL-04 깊은 튀김냄비 (deep-fry, F-06) / TOOL-05 그릴/석쇠 (grill, F-12) / TOOL-06 국자 (scoop broth, F-01/F-02/F-10) / TOOL-07 주걱 wok spatula (stir-fry stirring, F-05/F-09/F-11) / TOOL-08 뒤집개 turner (flip pancake, F-07) / TOOL-09 집게 tongs (grip, F-06/F-12) / TOOL-10 김발 bamboo mat (roll kimbap, F-03) / TOOL-11 mixing 큰 그릇 (mix bibimbap, F-08) / TOOL-12 한식 가위 (cut grilled meat, F-12 eating-style). v1.20 = (a) **§5.11 신설** (조리도구 12종 full prompts, 각 도구 prompt = 단독 sprite + 도구 형태 정확 + 한식 정통 + 일본/중국/서구 cross-cultural negative + 사용 hint visual + 7/8 perspective view [또는 김발/그릴 등 평면 도구 top-down]) / (b) **§2.5에 STYLE_SUFFIX_TOOL 명시** = 단독 sprite isolation + Cool Sage `#C8D5C0` bg + 7/8 perspective + Cookingo-inspired simple geometric flat clean + 한식 homestyle 가정용 (industrial X) + 일본/중국/서구 cooking tool 회피 negative + 다른 도구/food/character/hand 누수 0건 / (c) **§0 anchor 표 TOOL-01~12 row 12장 추가** (pending M1 후반 5번째 sprint) / (d) **새 driver script `tools/gen_tool_anchors_m1.py` 신설** — `tools/gen_cut_anchors_m1.py` template 기반 + TOOLS list 12개 inline (id=TOOL-XX / name=tool_slug / action=mechanic / mapping=음식 ID / body) + STYLE_SUFFIX_TOOL inline append via `.replace("%s", STYLE_SUFFIX_TOOL, 1)` (gen_food/gen_ingredient에서 발생했던 `body % SUFFIX` Python old-style ValueError fix 적용) + CLI args (`--only` `--version` `--quality` `--out-dir`) + gpt-image-1 medium 1024×1024 default + 출력 default `assets-raw/tool_anchors_m1/`. 12장 prompt body 핵심 (각 도구 한 줄 시그니처): TOOL-01 가스레인지 = 한식 가정 4구 silver-gray rectangular stovetop + 4 black 그레이트 grid + 4 front knobs + 1 front-left active blue flame ring + NOT 일본 induction / NOT 미국 electric coil / NOT Chinese restaurant wok burner / TOOL-02 냄비 = 한식 양은냄비 silver-gray rounded cylindrical pot 22-25cm × 12-15cm + 2 ear handles opposite sides + open top + 1-2 white steam swirl lines + NOT 일본 tetsunabe black cast iron / NOT 일본 donabe clay / NOT Chinese wok / NOT Western saucepan single side handle / TOOL-03 후라이팬 = 한식 가정 silver-gray shallow round pan 26-28cm × 4-5cm + single long straight side handle (matte black or wood) + NOT Western Teflon black-coated / NOT Chinese wok round-bottom / NOT Japanese tamagoyaki rectangular / NOT cast iron skillet / TOOL-04 깊은 튀김냄비 = 한식 가정 silver-gray DEEPER cylindrical pot 24-26cm × **18-22cm tall** (vs TOOL-02 12-15cm) + 2 ear handles + open top + golden 60-70% oil pool inside + optional subtle heat wave + NOT 일본 tetsunabe / NOT 일본 donabe / NOT Chinese wok / NOT electric appliance (no buttons/cord) / TOOL-05 그릴/석쇠 = round metallic wire mesh grill grate 28-30cm diameter + 8×8 cross-hatched silver-gray wires + thicker outer rim ring + optional subtle red-orange hot coal glow underneath + NOT solid flat plate / NOT 일본 yakitori 사각 / NOT 미국 BBQ 사각 / NOT cast iron grill pan solid plate (F-12 갈비 anchor의 wire mesh와 cross-asset consistency) / TOOL-06 국자 = 한식 가정 silver-gray single-piece ladle + deep round half-sphere bowl 8-10cm × 5-6cm deep + long straight slim handle 25-28cm + small hanging hole top + 30deg angled + NOT wooden handle Western / NOT 일본 otama / NOT Chinese soup spoon / TOOL-07 주걱 wok spatula = wide flat angled silver-gray metal paddle 8-10cm × 10-12cm × ~20deg angle + long warm brown wood handle 25-30cm + NOT TOOL-08 turner narrower / NOT Chinese wok chuan longer curved / NOT 일본 shamoji wood-only / NOT silicone scraper / TOOL-08 뒤집개 turner = NARROWER LONGER VERY THIN silver-gray metal paddle 6-8cm × 12-14cm × 0.2cm + SHARP front edge + 2-3 optional drainage slots + matte black or wood handle + ~10deg angle (less than TOOL-07) + optional subtle flip motion line + NOT TOOL-07 wider / NOT fish spatula slotted flexible / NOT 미국 pizza peel / TOOL-09 집게 tongs = 한식 가정 silver-gray scissor-style two-piece tool + spring-loaded hinge + 2 long arms 25-28cm + 2 slightly-flared gripping ends + slightly-open tips + optional matte black rubber grip coating + NOT TOOL-12 scissors blades / NOT chopsticks unconnected / NOT pliers gear teeth / NOT tweezers small / TOOL-10 김발 bamboo mat = light natural bamboo tan flat rectangular mat 24-26cm × 22-24cm + 20-25 parallel horizontal bamboo strips + 2 white cotton string weaving lines perpendicular + near top-down view + NOT 일본 makisu colored decorative thread / NOT Chinese bamboo steamer 3D basket / NOT wooden cutting board solid slab / NOT yoga mat rubber / TOOL-11 mixing 큰 그릇 = 한식 가정 silver-gray stainless steel large mixing bowl 28-32cm × 12-14cm wide deep + flared top opening + NO handles + NOT TOOL-02 cooking pot 2 ear handles / NOT 한식 dolsot stone bowl black / NOT 일본 donburi small ceramic / NOT colander holes / TOOL-12 한식 가위 = 한식 BBQ kitchen scissors total 22-25cm + 2 long sharp silver-gray metal blades 10-12cm + 2 looped warm brown wood/plastic finger handles 5-6cm rings + central pivot screw + slightly-closed tips + NOT 미국 office scissors smaller plastic / NOT poultry shears curved notch / NOT hair scissors thin slim / NOT kids craft rounded tips / NOT TOOL-09 tongs no blades. main thread 실행 명령: (1) test: `py tools/gen_tool_anchors_m1.py --only TOOL-01 --quality medium` (1장 × $0.042 ≈ $0.05, ~30초) → 시각 확인 후 (2) 12장 batch: `py tools/gen_tool_anchors_m1.py --quality medium` (12장 × $0.042 ≈ $0.50, ~5분, 출력 `assets-raw/tool_anchors_m1/TOOL-XX_<tool_slug>_v1.png`). 음식 12 / 환경 5 v4 / 캐릭터 5 / cut anchor 7 / ingredient whole 12 / reaction 6 / ingredient cut 12 본문 무변경. ChatGPT 약점 risk top 5 신설 (TOOL-02 냄비 → 일본 tetsunabe 검정 cast iron 누수 ~50% [ChatGPT default가 deeper iron pot으로 인식] / TOOL-03 후라이팬 → Western Teflon 검정 non-stick coating 누수 ~50% [silver-gray bare stainless 강제 필요] / TOOL-05 그릴/석쇠 → 솔리드 cast iron grill pan 누수 ~40% [wire MESH gap visible 강제] / TOOL-10 김발 → 일본 makisu pink/colored thread 누수 ~40% [plain white cotton 강제] / TOOL-12 한식 가위 → Western office scissors smaller plastic 누수 ~40% [robust LARGE size + warm wood handles 강제]). **ADR-005 조리법-도구 매핑 game-designer 후속 sync 필요 사항** = (a) 각 음식 F-XX의 정확한 도구 사용 sequence 확정 (예: F-12 갈비 = TOOL-01 stovetop 위 TOOL-05 grill 올림 + TOOL-09 tongs로 굽기 진행 + TOOL-12 scissors로 가위 cut 후 eating-style) / (b) Stage 2B 조리 mechanic의 도구별 rhythm tap BPM 매핑 (boil pot stirring BPM / pan-fry sizzle BPM / deep-fry timing BPM / grill flip BPM 등) / (c) 도구 transition timing (가스 stovetop 가열 → 냄비 올림 → 끓이기 시작) / (d) UI에서 도구 sprite 호출 layer (foreground 도구 활성 동안 background 도구는 fade 또는 hide).

> **v1.19 변경 (2026-05-30, M1 후반 art sprint 4번째 — 음식 12 × hero ingredient CUT 12장 prompt set 신설 §5.10 full prompts, ADR-005 Stage 2B/2C "after"-cut pair, supersedes v1.18)**: 사용자 verbatim **"손질하고 나서의 ingredient 이미지가 있어야 할 거 같고"** trigger로 M1 후반 art sprint 4번째 진입. ingredient whole 12장 (§5.6 ING-01~12)은 자르기 전 "before" state이고, cut anchor 7장 (§5.5 CUT-00~06)은 generic cut style 시연. 두 anchor 사이 누락된 asset = 각 음식의 hero ingredient를 그 음식 특유의 cut 결과로 specific 시각화한 anchor. 음식별 cut된 결과는 generic CUT-01~06 anchor와 미세 차이 있음 — 예: F-02 애호박은 잔치국수용 thin disc 5-8개 (generic CUT-04 통썰기 anchor의 김밥 cylinder cross-section과 다름) / F-04 어묵은 떡볶이용 medium 6-8cm oval 5-7개 (generic CUT-03 어슷썰기 anchor의 어묵+대파 mixed cluster와 다름) / F-07 daepa는 pajeon용 large 5-7cm oval 5-7개 (generic CUT-03과 mixed) — 음식 시그니처 강화 가치 있음. **옵션 C 채택** (12장 specific 모두 생성, F-11 carrot은 F-08과 동일 ingredient이나 slight visual variation으로 별도 생성, game-designer foods CSV `prep_*` 후속 확정 시 F-08 재사용 결정되면 archive). v1.19 = (a) **§5.10 신설** (ingredient cut 12장 full prompts, §5.6 ingredient whole template 기반 + STYLE_SUFFIX_INGREDIENT_CUT 변형 [whole → cut된 결과 cluster placement 절 변경, 다른 통일 무변경]) / (b) **§0 anchor 표 ICUT-01~12 row 12장 추가** (pending M1 후반 4번째 sprint) / (c) **새 driver script `tools/gen_ingredient_cut_anchors_m1.py` 신설** — `tools/gen_ingredient_anchors_m1.py` template 기반 + INGREDIENT_CUTS list 12개 inline (id=food_id / name=ingredient_cut_slug / food=food_name_en / cut_style=cut_style_id / body) + STYLE_SUFFIX_INGREDIENT_CUT inline append via `.replace("%s", STYLE_SUFFIX_INGREDIENT_CUT, 1)` (gen_food/gen_ingredient에서 발생했던 `body % SUFFIX` Python old-style ValueError fix 적용) + CLI args (`--only` `--version` `--quality` `--out-dir`) + gpt-image-1 medium 1024×1024 default + 출력 default `assets-raw/ingredient_cut_anchors_m1/`. 12장 specific 본문 핵심: F-01 송송 small green discs 20-30개 / F-02 통썰기 round zucchini discs 5-8개 (bright green rim + pale flesh + minimal seed dots) / F-03 채썰기 yellow matchstick 15-20개 (8-10cm kimbap-length) / F-04 어슷썰기 golden-brown oval 5-7개 (6-8cm medium) / F-05 다지기 fine red kimchi bits / F-06 cheese whole (no cut, ING-06과 동일 image) / F-07 어슷썰기 large bright green daepa oval 5-7개 (5-7cm × 1.5-2.5cm dominant green, F-04와 시각 분리) / F-08 채썰기 orange matchstick 15-20개 (5-7cm bibimbap-length) / F-09 marinade coated brown glaze (no cut, F-12 갈비 차별화 CRITICAL: NO bone visible NOT grilled char marks) / F-10 broken cloud-like white curds (no cut, fluffy irregular fragments) / F-11 채썰기 orange matchstick 15-20개 (6-8cm slight diagonal pile, F-08과 시각 variation) / F-12 다지기 fine yellowish-white garlic granules 1-3mm. main thread 실행 명령: (1) test: `py tools/gen_ingredient_cut_anchors_m1.py --only F-01 --quality medium` (1장 × $0.042 ≈ $0.05, ~30초) → 시각 확인 후 (2) 12장 batch: `py tools/gen_ingredient_cut_anchors_m1.py --quality medium` (12장 × $0.042 ≈ $0.50, ~4-5분, 출력 `assets-raw/ingredient_cut_anchors_m1/F-XX_<ingredient_cut_slug>_v1.png`). 음식 12 / 환경 5 v4 / 캐릭터 5 / cut anchor 7 / ingredient whole 12 / reaction 6 본문 무변경. ChatGPT 약점 risk top 5 신설 (F-02 zucchini → cucumber 누수 ~50% [더 darker skin + larger seed cavity으로 ChatGPT default 추론] / F-04 어묵 oval → Japanese naruto pink spiral cross-section 누수 ~50% / F-07 daepa oval → F-04 어묵 oval로 색 누수 ~40% [golden-brown 누수, 강제 dominant green] / F-09 marinade beef → raw red 또는 cooked char marks 누수 ~40% [brown glaze coating state 강제] / F-10 broken tofu → firm cube 누수 ~40% [organic irregular fragments 강제]).

> **v1.18 변경 (2026-05-30, M1 후반 reaction 6컷 v2 image edit — CH-02/CH-03 base + 표정만 변경, 사용자 R1 v1 피드백 2건 fix, supersedes v1.17)** (archived): 사용자가 v1 (`tools/gen_reaction_anchors_m1.py` prompt-only generation, gpt-image-1 medium 1024×1024 6장 batch) 결과 시각 확인 후 verbatim **"reaction 에서 R-01, R-03가 원래 이미지와 좀 다름, 그리고, R-04, R-05, R-06가 이미지가 좀 일관성이 없음"** 2건 피드백 raise. main thread 시각 분석으로 (a) **R-01/R-03 어머니 hair shape mismatch**: v1에서 round-bun **+ side-puff** variant로 생성, CH-02 base의 round-bun **simple**과 다름 + (b) **R-04 vs R-05/R-06 아버지 family IP inconsistency**: R-04는 CH-03 base의 darker salt-and-pepper hair + darker teal-green shirt에 일치, R-05/R-06는 lighter hair tone + lighter shirt tone으로 셋 사이 family IP inconsistency. prompt-only approach가 base의 family IP를 정확 재현 못함을 확인 → **gpt-image-1 image edit API** (BG sprint v4에서 효과 입증된 패턴) 도입. v1.18 = **§5.7 본문 전면 재작성** (v1.16 prompt-only 본문은 §5.7.archive v1 deprecated 절로 이동 보존). v2 approach = `client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_FRAME + expression_prompt, size="1024x1024", quality="medium", n=1)`로 (a) CH-02_mother.png base 직접 입력 (R-01/R-02/R-03) / (b) CH-03_father.png base 직접 입력 (R-04/R-05/R-06) + COMMON_FRAME (family IP IDENTICAL 강제 + bust-up crop + Cool Sage bg + 표정만 변경 명시 + sad/sleeping/Japanese kimono/anime girl 회피 negative) + 6 expression_prompt (★1/★2/★3 어머니 + 아버지 각각 specific). COMMON_FRAME 핵심 강제 사항 = 어머니 hair = round-bun **simple** (side-puff 추가 명시적 회피) / 아버지 hair tone (salt-and-pepper darker) + shirt tone (teal-green darker) base와 EXACTLY 일치 (NOT lighter 명시) — 사용자 v1 피드백 2건 1:1 fix. **§0 anchor 표 R-01~R-06 row 6장 status 갱신** (v1 prompt-only deprecated 2026-05-30 → v2 image edit pending). **새 driver `tools/edit_reaction_anchors_v2.py` 신설** — `tools/edit_bg_anchors_v4.py` template 기반 (image edit API + base image dimensions 검증 + PIL resize fallback + b64_json 응답 처리). 구조 = (1) COMMON_FRAME 상수 inline (single source) / (2) REACTIONS list 6개 inline (id / name / character / star / base / expression_prompt — 5개 항목별 description) / (3) base image 사전 검증 (CH-02_mother.png / CH-03_father.png 2장만 사용) / (4) CLI args (`--only` `--version` `--quality` `--out-dir`) / (5) gpt-image-1 medium 1024×1024 default, version v2 default. v1 prompt-only driver (`tools/gen_reaction_anchors_m1.py`)는 보존 (git history). v1 output (R-XX_<character>_star<N>_v1.png 6장)도 보존 — v2와 공존 (R-XX_<character>_star<N>_v2.png). main thread 실행 명령: (1) test: `py tools/edit_reaction_anchors_v2.py --only R-01 --quality medium` (1장 × $0.042 ≈ $0.05, ~30초) → 시각 확인 후 (2) 6장 batch: `py tools/edit_reaction_anchors_v2.py --quality medium` (6장 × $0.042 ≈ $0.25, ~2-3분, 출력 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v2.png`). 또는 어머니 mismatch만: `--only R-01,R-03` / 아버지 inconsistency만: `--only R-04,R-05,R-06`. v2 risk top 3 = (a) base의 default expression 유지 risk ~25% (★1/★2/★3 gradient 무너짐 → EXPRESSION CHANGE explicit 명시로 회피) / (b) base의 bowl/물건 prop carry over risk ~20% (R-03 ★3 손이 cheeks 옆으로 가야 함 → hand position 명시) / (c) base의 thumb-up carry over risk ~30% (R-04 ★1 영향, CH-03 base thumb-up → R-04 ★1 prompt에서 "NO thumb-up" 명시 강제). **R3 fallback (사용자 ChatGPT 웹 UI 수동 chain-of-references 워크플로)**: v2 결과가 여전히 family IP/gradient 부족하면 사용자 수동 (a) CH-02 upload + R-02 generate → 어머니 seed / (b) seed + R-01/R-03 / (c) 새 세션 + CH-03 + R-05 generate → 아버지 seed / (d) seed + (R-06만 추가 CH-05_father_star3.png reference) + R-04/R-06. 음식 12장 / 환경 5장 v4 / cut anchor 7장 / ingredient whole 12장 본문 무변경. 캐릭터 5장 본문 무변경.

> **v1.17 변경 (2026-05-30, mvp-food-selection v2.2 sync — F-02 호떡 → 잔치국수 + F-09 김치찌개 → 불고기 음식 anchor 2장 + ING-02/ING-09 ingredient anchor 2장 전면 교체, supersedes v1.16)**: game-designer가 2026-05-28 mvp-food-selection v2.1 → v2.2 갱신 완료 (F-02 호떡 → 잔치국수 T1, 4가게 순회 곡물+잡화+어물+청과 / F-09 김치찌개 → 불고기 T2, 정육+청과+잡화). art-director는 본 v1.17에서 (a) **§5.2 F-02 본문 전면 교체** (호떡 → 잔치국수 Janchi-guksu, hero = 소면 white wheat thin noodles + 멸치 dashi clear broth + 계란 지단 yellow ribbon + 김 strips + 애호박 zucchini garnish + 멸치 dried anchovy minor accent; cross-cultural negative critical — NOT Japanese somen tsuyu cold dipping / NOT Japanese udon thick / NOT Japanese ramen curly yellow + miso/tonkotsu / NOT Vietnamese pho cinnamon-clove broth + lime/sprouts/herbs / NOT Chinese egg noodle soup. 호떡 본문은 deprecated archive 보존) / (b) **§5.2 F-09 본문 전면 교체** (김치찌개 → 불고기 Bulgogi, hero = 얇은 marbled 소고기 thin-sliced sirloin fanned + soy-pear-garlic marinade pool + 양파/대파/당근/표고/optional 당면 mixed in same dark cast-iron Korean BBQ pan + 깨/송송 대파 garnish; **CRITICAL F-12 갈비 차별화** — NO bone-in LA cut, NO visible white rib bone, NOT grilled on wire mesh grate over hot coals, NOT large 18-25cm LA strips; cross-cultural negative — NOT Japanese sukiyaki raw egg dipping bowl + 다른 vegetable set / NOT shabu-shabu clear broth pot / NOT yakiniku grilled boneless / NOT Chinese beef stir-fry wok hei + cornstarch sauce / NOT American BBQ red sauce + rib bone. 김치찌개 본문은 deprecated archive 보존) / (c) **§5.6 ING-02 본문 전면 교체** (흑설탕 → 소면 somen whole bundled dry white wheat noodles, ~18-22cm × 4-5cm bundle tied at center with plain white/cream paper band, off-white #F5F0E0-#FAFAFA, 15-25 individual slim ~1-2mm strands; cross-cultural negative — NOT Japanese somen pink-and-white decorative paper band / NOT yellow Chinese egg noodles / NOT Italian spaghetti thicker rigid / NOT udon fat chunky / NOT Korean ramyeon curly yellow egg. 흑설탕 본문은 deprecated archive 보존; peanut R1 already deprecated archive 유지) / (d) **§5.6 ING-09 본문 전면 교체** (두부 firm → 얇은 raw 소고기 thin-sliced marbled beef stack/fan, 5-7 slices each ~8-12cm × 5-7cm × 2-3mm THIN paper-thin, pink-red raw #C44545-#B82F2F + visible white marbled fat veins scattered organic irregular ~3-5 marbling lines per slice; **CRITICAL F-12 갈비 차별화 적용 (ING-12 마늘과는 다른 ingredient)** — NO bone visible, RAW state NOT cooked/grilled with char marks, NOT thick 1cm+ steak slab; cross-cultural negative — NOT Japanese wagyu A5 extreme marbling + premium plating / NOT sukiyaki beef on decorative platter + raw egg dipping + 다른 vegetable / NOT bacon parallel striped / NOT salami cured uniform / NOT 삼겹살 thick alternating layered stripes. 두부 firm 본문은 deprecated archive 보존). **§0 anchor 표 row 4 갱신**: F-02 row (Hotteok → Janchi-guksu, T1) / F-09 row (Kimchi Jjigae → Bulgogi, T2) / ING-02 row (peanut R1 archive / brown_sugar R2 archive → somen pending v1) / ING-09 row (firm tofu R1 archive → thin marbled beef pending v1). 다른 8 음식 anchor + 10 ingredient anchor + cut 7 + 환경 5 + 캐릭터 5 + reaction 6 본문 **전면 무변경** (LOCK status 유지). **driver script `tools/gen_food_anchors_m1.py` FOODS list F-02/F-09 body inline 갱신 + docstring v1.17 sync** + **driver script `tools/gen_ingredient_anchors_m1.py` INGREDIENTS list F-02/F-09 item name+food+cut_style+body inline 갱신 + docstring v1.17 sync**. main thread 실행 명령 = (1) `py tools/gen_food_anchors_m1.py --only F-02,F-09 --version v9 --model gpt-image-1 --quality medium` (음식 anchor 2장 × $0.042 ≈ $0.08, ~30-60초, 출력 `assets-raw/food_anchors_m1/F-02_janchi_guksu_v9.png` + `F-09_bulgogi_v9.png` — version v9 = previous F-01~F-11 R1~R7 version과 충돌 회피, F-02/F-09 신규 첫 generation) / (2) `py tools/gen_ingredient_anchors_m1.py --only F-02,F-09 --version v3 --model gpt-image-1 --quality medium` (ingredient anchor 2장 × $0.042 ≈ $0.08, ~30-60초, 출력 `assets-raw/ingredient_anchors_m1/F-02_somen_whole_v3.png` + `F-09_thin_beef_whole_v3.png` — version v3 = previous v1 brown_sugar/firm_tofu / v2 (있다면) 회피, F-02/F-09 신규 generation). 총 4장 × $0.042 ≈ $0.17, ~2분. ChatGPT 약점 risk top 5 갱신 (잔치국수 Japanese somen 누수 ~50% + Vietnamese pho 누수 ~30% / 불고기 Japanese sukiyaki 누수 ~50% + F-12 갈비 cross-contamination ~40% / 소면 Japanese pink-band 누수 ~40% / 얇은 소고기 wagyu 누수 ~40% / 얇은 소고기 cooked brown 누수 ~30%). 음식 12 평가 표 §0 + §5.4 risk top 5 부분 갱신.

> **v1.16 변경 (2026-05-30, M1 후반 art sprint 3번째 — 양친 reaction 6컷 anchor prompt set 신설 §5.7 full prompts, Scene 3 식탁 ★1/★2/★3 gradient, ingredient 12장 sprint와 fully parallel, supersedes v1.15)** (archived): M1 후반 art sprint 2번째 (ingredient whole 12장) sprint와 **병렬로 동시 진행**. ADR-005 Total Score 가중 평균 (재료 25% × 준비 20% × 방법 20% × 시간 35%) → ★1 30%+ / ★2 60%+ / ★3 90%+ gradient. 친구 가족 단위 (project_adr003 2026-05-23 lock): 어머니 + 아버지 L11 동시 unlock (0.6s 시차 fade-in). Scene 3 식탁 reaction = 음식 완성 후 가족이 식탁에서 먹는 reaction (Tier 2 가족 식탁). friends-system 호불호 axis (project_adr003 v0.2): 음식별 호불호 (spicy/sweet/oily/salty/mild) → Total Score + 호불호 보너스 = 최종 reaction. art-director는 Week 1 base 4장 시각 확인: (a) **CH-02_mother.png** = 어머니 base = round-bun short black hair + red top + soft white apron + 음식 그릇 들고 + warm motherly subtle smile (default expression ≈ ★1-★2 boundary) / (b) **CH-03_father.png** = 아버지 base = short salt-and-pepper hair + teal-green button-up shirt + dark pants + thumb-up gesture + slim smile (default expression ≈ ★1-★2 boundary 가까움, thumb-up 때문에 약간 ★2 쪽) / (c) **CH-04_mother_star1.png** = Week 1 어머니 ★1 variant = **sad/teardrop expression** (한 손이 chin 쪽 어색한 worried 자세) → 본 sprint 재해석에서는 ★1 = "mild satisfaction acceptable" (subtle smile + 정상 open eyes) 으로 교체 (Week 1 sad teardrop은 부정 reaction이지 mild satisfaction 아님) / (d) **CH-05_father_star3.png** = Week 1 아버지 ★3 variant = excited eyes-closed-arc happy + 4개 sparkle accents + 양손 (one thumb-up + one fist raised) + wide open mouth smile → **본 sprint settle 형태에 가장 가까움**, Week 1 variant를 ★3 reference로 차용. **§5.7 placeholder → full prompts 확장**: 6 prompt = 어머니 × {★1 subtle smile / ★2 bigger smile + eye crescent arcs / ★3 big wide smile + closed-arc + heart accent} + 아버지 × {★1 slim reserved smile / ★2 fuller relaxed smile + casual thumb-up / ★3 big wide smile + closed-arc + double thumb-up + sparkle (Week 1 CH-05 variant 톤)}. 어머니 vs 아버지 표정 톤 차이: **어머니** = warm motherly nurturing tone, subtle ↔ 부드러운 호 ↔ big delighted + heart / **아버지** = reserved masculine tone, slim closed ↔ relaxed open + casual thumb-up ↔ excited + double thumb-up + sparkle. 각 reaction = (a) **single character bust-up portrait** (어깨까지, NOT full body — Scene 3 식탁 seated context) / (b) Week 1 base와 동일 family IP (hair/outfit/face features 그대로) / (c) 표정만 ★1/★2/★3 gradient에 따라 다름 / (d) **background: Cool Sage `#C8D5C0` solid** (음식/cut/ingredient cross-asset 일관성 — Scene 3 식탁 context의 25-asset cluster 합류 결정; 캐릭터 5장 CH-01~05의 soft mint `#9BE0D2`와는 다름, 추후 어색하면 V2 revert 가능) / (e) modern saturated + slim outline 2-3px + chibi mascot proportions (Royal Match aesthetic) / (f) optional Scene 3 cue (젓가락 한 손 또는 입가 한 조각, minor accent only). **§2.5에 STYLE_SUFFIX_REACTION 명시** = bust-up portrait + chibi mascot + Family IP consistency (어머니/아버지 Week 1 base 명세) + EXPRESSION GRADIENT (★1/★2/★3 메타 정의) + Cool Sage bg + slim outline + 표정 negative (sad/sleeping/crying 0건). **§0 anchor 표 R-01~R-06 row 추가** (어머니 ★1/★2/★3 + 아버지 ★1/★2/★3, pending M1 후반 3번째). **새 driver script `tools/gen_reaction_anchors_m1.py` 신설** — `tools/gen_cut_anchors_m1.py` template 기반, REACTIONS 6개 항목 inline (id=R-XX / name=character_starN_slug / character=mother|father / star=1|2|3 / body), STYLE_SUFFIX_REACTION inline append via `.replace("%s", STYLE_SUFFIX_REACTION, 1)` (gen_food/gen_ingredient에서 발생했던 `body의 % character ↔ Python %s formatting` ValueError fix 적용), gpt-image-1 medium 1024×1024 default. M1 후반 reaction 6컷 main thread 실행 명령: `py tools/gen_reaction_anchors_m1.py --model gpt-image-1 --quality medium` (6장 × $0.042 ≈ $0.25, ~2-3분, 출력 경로 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v1.png`). 음식 12장 / 환경 5장 v4 / cut anchor 7장 / ingredient whole 12장 본문 무변경. 캐릭터 5장 본문 무변경. **§5.8 UI/VFX는 M2 sprint placeholder 유지** (양친 reaction 6컷은 §5.7로 위치 변경, 이전 v1.15의 "§5.7~§5.8 UI/VFX/양친 reaction" 분류에서 양친 reaction 분리).

> **v1.15 변경 (2026-05-30, M1 후반 art sprint 2번째 — 음식 12 × hero ingredient whole anchor 12장 prompt set 신설 §5.6 full prompts + §5.5 음식↔cut 매핑 표 추가, ADR-005 Stage 2A "before"-cut pair, supersedes v1.14)** (archived): M1 후반 art sprint 1번째 (cut anchor 7장 LOCK 완료) 후 2번째 sprint 진입. **ADR-005 Stage 2A 재료 준비 = rhythm tap + Knife indicator** 미니게임은 각 음식별로 hero ingredient를 적절한 cut style로 자르는 형태 → 음식 12 × hero ingredient 매핑 + whole(자르기 전) state asset이 필요. **§5.5에 음식 12 × hero ingredient × cut style 매핑 표 추가** (임시; game-designer foods CSV prep_* 후속 확정 시 일부 reroll 가능): F-01 라면→대파/CUT-05 송송썰기 · F-02 호떡→견과류/CUT-01 다지기 · F-03 김밥→단무지/CUT-02 채썰기 · F-04 떡볶이→어묵/CUT-03 어슷썰기 · F-05 김치볶음밥→김치/CUT-01 다지기 · F-06 콘도그→모짜렐라/(no cut) · F-07 해물파전→대파 daepa/CUT-03 어슷썰기 · F-08 비빔밥→당근/CUT-02 채썰기 · F-09 김치찌개→두부 firm/CUT-06 깍둑썰기 · F-10 순두부→두부 soft/(no cut, broken curds) · F-11 잡채→당근/CUT-02 채썰기(F-08 재사용 가능) · F-12 갈비→마늘/CUT-01 다지기. **§5.6 신설 — ingredient whole 12장 prompt set**: 각 음식의 hero ingredient를 도마 위에 whole(자르기 전) 상태로 placement. cut된 상태(CUT-01~06)는 재사용 — 본 sprint는 whole 12장만 추가. **§2.5에 STYLE_SUFFIX_INGREDIENT 명시** = STYLE_SUFFIX_CUT 재활용 + INGREDIENT PLACEMENT 절 추가 (center-right whole ingredient + knife left static + 도마/bg/outline 통일). **§0 anchor 표 ING-01~12 row 추가** (F-01~F-12 hero ingredient whole, pending M1 후반). **새 driver script `tools/gen_ingredient_anchors_m1.py` 신설** — `tools/gen_cut_anchors_m1.py` template 기반, INGREDIENTS 12개 항목 inline (id=food_id / name=ingredient_slug / food=food_name_en / cut_style=cut_style_id / body), STYLE_SUFFIX_INGREDIENT inline append, gpt-image-1 medium 1024×1024 default. M1 후반 ingredient whole 12장 main thread 실행 명령: `py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium` (12장 × $0.042 ≈ $0.50, ~4-5분, 출력 경로 `assets-raw/ingredient_anchors_m1/<food_id>_<ingredient_name>_whole_v1.png`). 음식 12장 F-01~F-12 본문 무변경. 캐릭터 5장 / 환경 5장 v4 / cut anchor 7장 본문 무변경. **§5.7~§5.8 UI/VFX/양친 reaction은 M2 sprint placeholder 유지**.

> **v1.14 변경 (2026-05-29, M1 후반 sprint 진입 — 칼/도마 base anchor 1장 + cut style 6종 prompt set 신설 §5.5 full prompts, ADR-005 Stage 2A rhythm tap prerequisite, supersedes v1.13)** (archived): M1 anchor 22/22 LOCK 완료 (음식 12 + 환경 5 + 캐릭터 5, commit dfb141e) 후 M1 후반 art sprint 진입. **ADR-005 Stage 2A 재료 준비 = rhythm tap + Knife indicator** prerequisite로 칼/도마 base + cut style 6종 anchor가 필요. **§2.5 STYLE_SUFFIX_CUT 신설** — 모든 cut anchor 공통 suffix (square 1:1, top-down view, Korean cutting board + knife 통일 silhouette, Cool Sage `#C8D5C0` bg, modern saturated, slim outline 2-3px, 한식 anchor 일관성). **§5.5 placeholder → full prompts 확장** (cutting_board base 1장 + cut_style_mince/julienne/diagonal/whole/sliced_rounds/cube 6장 = 총 7장). 각 cut style은 **cutting RESULT state** (cut된 결과 상태, NOT cutting action mid-motion) — 게임 asset으로 도마 + cut된 재료 + 칼 옆에 놓임 형태. cut style 6종 시그니처 재료 매핑 = mince (다지기) → 마늘 (F-12 갈비/F-09 김치찌개, 가장 빠른 BPM 140) / julienne (채썰기) → 당근 (F-08 비빔밥/F-11 잡채) / diagonal (어슷썰기) → 어묵+대파 (F-04 떡볶이/모든 국물) / whole (통썰기) → 김밥 cylinder 단면 (F-03, BPM 70 가장 느림) / sliced_rounds (송송썰기) → 대파 (F-12 갈비/모든 가니쉬) / cube (깍둑썰기) → 두부 (F-09 김치찌개/F-10 순두부). **§0 anchor 표 cut anchor 7장 row 추가** (CUT-00 cutting_board ~ CUT-06 cube). **새 driver script `tools/gen_cut_anchors_m1.py` 신설** — `tools/gen_food_anchors_m1.py` template 기반, CUTS 7개 항목 inline, STYLE_SUFFIX_CUT inline append, gpt-image-1 medium 1024×1024 default. M1 후반 cut anchor 7장 main thread 실행 명령: `py tools/gen_cut_anchors_m1.py --model gpt-image-1 --quality medium` (7장 × $0.042 ≈ $0.29, ~3-4분, 출력 경로 `assets-raw/cut_anchors_m1/<name>_v1.png`). 음식 12장 F-01~F-12 본문 무변경 (각 LOCK status 유지). 캐릭터 5장 CH-01~05 본문 무변경 (v1.2 lock candidate 유지). 환경 5장 BG-01~05 v4 image edit approach 무변경. **§5.6~§5.7 양친 reaction/UI/VFX는 M2 sprint placeholder 유지**.

> **v1.13 변경 (2026-05-28, M1 환경 BG-01~05 v4 image edit — v1.2 base + 지붕만 교체 + frontal view + 5가게 구조 일관성, supersedes v1.12)** (archived): 사용자가 v1.12 v3 결과 (5장 batch generation, slight 7/8 perspective, 5가게 구조 inconsistent across shops) 시각 확인 후 폐기 + 새 접근 명시. 사용자 verbatim "**각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나...**". main thread 해석 = 3건 fix: (1) **5가게 구조 정확 일관성** — 지붕/기둥/카운터/frame 5가게 모두 정확히 동일, 카테고리별 display goods + signage icon만 다름 (v3는 prompt-only batch generation으로 carpenter 작업이 5가게마다 다르게 생성됨) / (2) **v1.2 base 정확 유지 + 지붕만 교체** — prompt-only generation은 v1.2 정확 재현 어려움, **gpt-image-1 image edit API**로 base image의 천막 부분만 교체 (다른 모든 요소 유지) / (3) **frontal view (frontal elevation)** — slight 7/8 perspective 폐기, v1.2 base가 frontal이었음. **§2.2 STYLE_SUFFIX_BG 무변경** (v3 STYLE_SUFFIX_BG_V3 유지) — v4는 STYLE_SUFFIX_BG suffix를 사용하지 않고 **image edit API용 별도 COMMON_EDIT_PROMPT**를 사용 (지붕 교체 단일 fix prompt). **§4 BG-01~05 본문 전면 재작성** — v3 prompt-only generation 본문은 §4.8 v1.12 v3 archive로 deprecated (사유: 5가게 구조 inconsistent + slight 7/8 perspective + 사용자 v3 폐기 verbatim). v4 본문은 image edit API approach 명시 (base image 경로 `assets-raw/week1-anchors/BG-XX_<name>_v2.png` + 공통 fix prompt + shop-specific 카테고리 명시 한 줄). **새 driver script `tools/edit_bg_anchors_v4.py` 신설** — `client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_EDIT_PROMPT + category, size="1024x1024", quality="medium", n=1)`. base image dimensions 사전 검증 + (필요 시) gpt-image-1 edit supported size (1024x1024 / 1536x1024 / 1024x1536)로 PIL resize fallback 포함. §0 anchor 표 BG-01~05 row v4 status 갱신 (v1.12 v3 deprecated → v4 pending image edit). 음식 12장 F-01~F-12 본문 무변경 (F-12는 v1.10 R7 plated white plate LOCK candidate 유지). 캐릭터 5장 CH-01~05 본문 무변경 (v1.2 lock candidate 유지).

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
| F-02 | Janchi-guksu (잔치국수, T1, v1.17 mvp v2.2 신규 — 호떡 deprecated) | TBD | TBD | TBD | **v1.17 pending v9 — 호떡 deprecated 2026-05-30 (mvp v2.2 trigger)** |
| F-03 | Kimbap (김밥, T1) | TBD | TBD | TBD | pending M1 |
| F-04 | Tteokbokki (떡볶이, T1) | TBD | TBD | TBD | pending M1 |
| F-05 | Kimchi Fried Rice (김치볶음밥, T1) | TBD | TBD | TBD | pending M1 |
| F-06 | Korean Corn Dog (한국식 콘도그, T1) | TBD | TBD | TBD | pending M1 |
| F-07 | Haemul Pajeon (해물파전, T1) | TBD | TBD | TBD | pending M1 |
| F-08 | Bibimbap (비빔밥, T2) | TBD | TBD | TBD | pending M1 |
| F-09 | Bulgogi (불고기, T2, v1.17 mvp v2.2 신규 — 김치찌개 deprecated) | TBD | TBD | TBD | **v1.17 pending v9 — 김치찌개 deprecated 2026-05-30 (mvp v2.2 trigger, F-12 갈비 차별화 CRITICAL: NO bone-in LA cut)** |
| F-10 | Sundubu Jjigae (순두부찌개, T2) | TBD | TBD | TBD | pending M1 |
| F-11 | Japchae (잡채, T2) | TBD | TBD | TBD | pending M1 |
| F-12 | Galbi-gui (갈비구이, T2) | TBD | TBD | TBD | pending M1 |
| CUT-00 | Cutting Board base (칼+도마 정적 baseline, v1.14 신설) | TBD | TBD | TBD | **pending M1 후반** |
| CUT-01 | Mince — 다지기 (마늘, BPM 140 가장 빠름, F-12/F-09) | TBD | TBD | TBD | **pending M1 후반** |
| CUT-02 | Julienne — 채썰기 (당근, F-08/F-11) | TBD | TBD | TBD | **pending M1 후반** |
| CUT-03 | Diagonal Slice — 어슷썰기 (어묵+대파, F-04/모든 국물) | TBD | TBD | TBD | **pending M1 후반** |
| CUT-04 | Whole Slice — 통썰기 (김밥 cylinder 단면, F-03, BPM 70 가장 느림) | TBD | TBD | TBD | **pending M1 후반** |
| CUT-05 | Sliced Thin Rounds — 송송썰기 (대파, F-12/모든 가니쉬) | TBD | TBD | TBD | **pending M1 후반** |
| CUT-06 | Cube Dice — 깍둑썰기 (두부, F-09/F-10) | TBD | TBD | TBD | **pending M1 후반** |
| ING-01 | F-01 Ramyeon hero — 대파 (spring onion) whole, pair=CUT-05 송송썰기 (v1.15 신설) | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** |
| ING-02 | F-02 Janchi-guksu hero — 소면 (somen white wheat noodles bundled whole), pair=(no cut, sprinkle/serve), v1.17 mvp v2.2 신규 | TBD | TBD | TBD | **v1.17 pending v3 — peanut R1 / brown_sugar R2 deprecated 2026-05-30 (mvp v2.2 trigger, 호떡 → 잔치국수)** |
| ING-03 | F-03 Kimbap hero — 단무지 (pickled radish) whole, pair=CUT-02 채썰기 | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** |
| ING-04 | F-04 Tteokbokki hero — 어묵 (fish cake sheet) whole, pair=CUT-03 어슷썰기 | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** |
| ING-05 | F-05 Kimchi Fried Rice hero — 김치 (napa cabbage kimchi leaf) whole, pair=CUT-01 다지기 | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** |
| ING-06 | F-06 Corn Dog hero — 모짜렐라 (cheese stick) whole, pair=(no cut, whole) | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** |
| ING-07 | F-07 Haemul Pajeon hero — 대파 daepa (large scallion) whole, pair=CUT-03 어슷썰기 | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** |
| ING-08 | F-08 Bibimbap hero — 당근 (carrot) whole, pair=CUT-02 채썰기 | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** |
| ING-09 | F-09 Bulgogi hero — 얇은 소고기 (raw thin-sliced marbled beef stack/fan) whole, pair=(no cut, marinade prep state), v1.17 mvp v2.2 신규 | TBD | TBD | TBD | **v1.17 pending v3 — firm tofu R1 deprecated 2026-05-30 (mvp v2.2 trigger, 김치찌개 → 불고기, F-12 갈비 차별화 CRITICAL: NO bone visible + RAW NOT cooked)** |
| ING-10 | F-10 Sundubu hero — 두부 soft (soft tofu tube) whole, pair=(no cut, broken curds) | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** |
| ING-11 | F-11 Japchae hero — 당근 (carrot, F-08 variation) whole, pair=CUT-02 채썰기 | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** (game-designer F-08 재사용 확정 시 archive) |
| ING-12 | F-12 Galbi-gui hero — 마늘 (garlic cloves) whole, pair=CUT-01 다지기 | TBD | TBD | TBD | **pending M1 후반 2번째 sprint** |
| ICUT-01 | F-01 Ramyeon cut — 대파 송송 thin green discs 20-30개, ING-01 whole의 "after" pair (v1.19 신설) | TBD | TBD | TBD | **pending M1 후반 4번째 sprint** |
| ICUT-02 | F-02 Janchi-guksu cut — 애호박 통썰기 round green discs 5-8개 (medium 4-5cm), ING-02 whole의 "after" pair | TBD | TBD | TBD | **pending M1 후반 4번째 sprint** |
| ICUT-03 | F-03 Kimbap cut — 단무지 채썰기 yellow matchstick 15-20개 (8-10cm kimbap-length), ING-03 whole의 "after" pair | TBD | TBD | TBD | **pending M1 후반 4번째 sprint** |
| ICUT-04 | F-04 Tteokbokki cut — 어묵 어슷썰기 golden-brown oval 5-7개 (6-8cm medium), ING-04 whole의 "after" pair | TBD | TBD | TBD | **pending M1 후반 4번째 sprint** |
| ICUT-05 | F-05 Kimchi Fried Rice cut — 김치 다지기 fine red minced bits scattered, ING-05 whole의 "after" pair | TBD | TBD | TBD | **pending M1 후반 4번째 sprint** |
| ICUT-06 | F-06 Corn Dog cut — 모짜렐라 whole (no cut, ING-06과 동일 image — cheese는 whole 그대로 corn dog 안 insertion) | TBD | TBD | TBD | **pending M1 후반 4번째 sprint (ING-06과 동일 결과)** |
| ICUT-07 | F-07 Haemul Pajeon cut — 대파 daepa 어슷썰기 large dominant green oval 5-7개 (5-7cm × 1.5-2.5cm, F-04와 시각 분리), ING-07 whole의 "after" pair | TBD | TBD | TBD | **pending M1 후반 4번째 sprint (F-04와 색 분리 CRITICAL: dominant green NOT golden-brown)** |
| ICUT-08 | F-08 Bibimbap cut — 당근 채썰기 orange matchstick 15-20개 (5-7cm bibimbap-length), ING-08 whole의 "after" pair | TBD | TBD | TBD | **pending M1 후반 4번째 sprint** |
| ICUT-09 | F-09 Bulgogi cut — 얇은 소고기 marinade coated brown glaze (no cut, 양념재우기 prep state), ING-09 raw whole의 "after" marinated pair, **F-12 갈비 차별화 CRITICAL: NO bone visible + NOT grilled char marks (brown from marinade NOT grill)** | TBD | TBD | TBD | **pending M1 후반 4번째 sprint (F-12 차별화 CRITICAL)** |
| ICUT-10 | F-10 Sundubu cut — 두부 soft broken cloud-like white curds (no cut, scooped from tube state), ING-10 whole tube의 "after" broken pair | TBD | TBD | TBD | **pending M1 후반 4번째 sprint (organic irregular fragments NOT firm cube)** |
| ICUT-11 | F-11 Japchae cut — 당근 채썰기 orange matchstick 15-20개 (6-8cm slight diagonal pile, F-08과 시각 variation), ING-11 whole의 "after" pair | TBD | TBD | TBD | **pending M1 후반 4번째 sprint (game-designer F-08 재사용 확정 시 archive)** |
| ICUT-12 | F-12 Galbi-gui cut — 마늘 다지기 fine yellowish-white minced granules 1-3mm scattered, ING-12 whole의 "after" pair | TBD | TBD | TBD | **pending M1 후반 4번째 sprint** |
| R-01 | 어머니 ★1 mild satisfaction (subtle warm smile, normal open dot eyes) — v1.18 v2 image edit base=CH-02_mother.png | `assets-raw/week1-anchors/CH-02_mother.png` (base) | gpt-image-1 edit API (no chat session) | image edit COMMON_FRAME + R-01 expression_prompt (★1 mild satisfaction) | **v1 prompt-only deprecated 2026-05-30 (어머니 hair round-bun+side-puff mismatch vs CH-02 base round-bun simple) → v2 image edit pending** |
| R-02 | 어머니 ★2 happy/pleased (bigger smile + soft upward crescent arc) — **anchor seed** (base default와 가장 가까움) | `assets-raw/week1-anchors/CH-02_mother.png` (base) | gpt-image-1 edit API | image edit COMMON_FRAME + R-02 expression_prompt (★2 happy) | **v1 prompt-only candidate (사용자 silent ACK이나 통일 위해 v2 재생성) → v2 image edit pending (anchor seed)** |
| R-03 | 어머니 ★3 very happy (big wide smile + closed-arc happy eyes + heart accent) — v1.18 v2 image edit base=CH-02_mother.png | `assets-raw/week1-anchors/CH-02_mother.png` (base) | gpt-image-1 edit API | image edit COMMON_FRAME + R-03 expression_prompt (★3 very happy) | **v1 prompt-only deprecated 2026-05-30 (어머니 hair mismatch CH-02 base와 다름) → v2 image edit pending** |
| R-04 | 아버지 ★1 reserved (slim closed smile + NO thumb-up, normal open dot eyes) — v1.18 v2 image edit base=CH-03_father.png | `assets-raw/week1-anchors/CH-03_father.png` (base) | gpt-image-1 edit API | image edit COMMON_FRAME + R-04 expression_prompt (★1 reserved, NO thumb-up) | **v1 prompt-only deprecated 2026-05-30 (R-05/R-06와 family IP inconsistency — R-04 darker tone vs R-05/R-06 lighter tone) → v2 image edit pending (family IP lock)** |
| R-05 | 아버지 ★2 relaxed (fuller open smile + single casual thumb-up + crescent arc) — **anchor seed** | `assets-raw/week1-anchors/CH-03_father.png` (base) | gpt-image-1 edit API | image edit COMMON_FRAME + R-05 expression_prompt (★2 relaxed enjoyment) | **v1 prompt-only deprecated 2026-05-30 (lighter tone vs R-04 darker — family IP inconsistency) → v2 image edit pending (anchor seed, hair+shirt tone CH-03 base와 EXACTLY 일치 강제)** |
| R-06 | 아버지 ★3 very excited (big wide smile + closed-arc + DOUBLE thumb-up + 2-4 sparkle accent) — v1.18 v2 image edit base=CH-03_father.png | `assets-raw/week1-anchors/CH-03_father.png` (base) | gpt-image-1 edit API | image edit COMMON_FRAME + R-06 expression_prompt (★3 very excited, double thumb-up) | **v1 prompt-only deprecated 2026-05-30 (lighter tone vs R-04 darker — family IP inconsistency) → v2 image edit pending (사용자 ChatGPT 웹 UI fallback 시 CH-05_father_star3.png 추가 reference 권장)** |
| EX-01 | hand_marinade — 손바닥 marinade press anchor (F-09 불고기 Stage 2A 양념재우기 위→아래 palm press motion, v1.23 신설) | TBD | TBD | TBD | **pending M1 후반 mini extra** |
| EX-02 | corndog_batter_bowl — 콘도그 batter dip 그릇 anchor (F-06 콘도그 Stage 2A dip substitute, matte white round ceramic bowl + viscous light tan/golden cornmeal-wheat batter pool, v1.23 신설) | TBD | TBD | TBD | **pending M1 후반 mini extra** |
| GUEST-junho-neutral | junho (호방 매콤 매니아) neutral — bust-up portrait, dot eyes + subtle arc smile, anchor seed for Phase C (v1.24 신설) | `assets-raw/guest_avatars_m1/junho_neutral_v1.png` (pending) | gpt-image-1 generate API (Phase B) | build_prompt_phase_b(junho, neutral) | **pending Phase B** |
| GUEST-junho-happy | junho happy — closed crescent ^_^ + open smile + 1-2 sparkle (v1.24 신설) | `assets-raw/guest_avatars_m1/junho_happy_v1.png` (pending, image edit base = junho_neutral_v1.png) | gpt-image-1 edit API (Phase C) | build_prompt_phase_c(junho, happy) | **pending Phase C** |
| GUEST-junho-excited | junho excited — GIANT closed-arc + WIDE open with teeth + 양손 raised + 3-5 sparkle + 1-2 star + motion lines (v1.24 신설) | `assets-raw/guest_avatars_m1/junho_excited_v1.png` (pending, base = junho_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(junho, excited) | **pending Phase C** |
| GUEST-junho-disappointed | junho disappointed — LOWERED EYEBROWS + DOWNTURNED closed mouth + head tilt down-away + optional sweat drop (subtle mature, NOT crying, v1.24 신설) | `assets-raw/guest_avatars_m1/junho_disappointed_v1.png` (pending, base = junho_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(junho, disappointed) | **pending Phase C** |
| GUEST-mina-neutral | mina (단맛 발랄) neutral — chestnut brown side ponytail + pastel pink sweater + dot eyes + subtle arc smile (v1.24 신설) | `assets-raw/guest_avatars_m1/mina_neutral_v1.png` (pending) | gpt-image-1 generate API | build_prompt_phase_b(mina, neutral) | **pending Phase B** |
| GUEST-mina-happy | mina happy — closed crescent + open smile + 1-2 sparkle (v1.24 신설) | `assets-raw/guest_avatars_m1/mina_happy_v1.png` (pending, base = mina_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(mina, happy) | **pending Phase C** |
| GUEST-mina-excited | mina excited — GIANT closed-arc + WIDE open + 양손 raised + sparkle/star burst (v1.24 신설) | `assets-raw/guest_avatars_m1/mina_excited_v1.png` (pending, base = mina_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(mina, excited) | **pending Phase C** |
| GUEST-mina-disappointed | mina disappointed — LOWERED EYEBROWS + DOWNTURNED closed mouth (subtle mature, NOT crying, v1.24 신설) | `assets-raw/guest_avatars_m1/mina_disappointed_v1.png` (pending, base = mina_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(mina, disappointed) | **pending Phase C** |
| GUEST-riley-neutral | riley (외국인 산뜻함) neutral — non-Korean foreign 외국인 honey-blonde wavy hair + mint/yellow hoodie + dot eyes + subtle arc smile, **유일하게 비-Korean identity 디자인 의도** (v1.24 신설) | `assets-raw/guest_avatars_m1/riley_neutral_v1.png` (pending) | gpt-image-1 generate API | build_prompt_phase_b(riley, neutral) | **pending Phase B (foreign identity CRITICAL: Korean dark hair convention 의도적 break)** |
| GUEST-riley-happy | riley happy — closed crescent + open smile + 1-2 sparkle (v1.24 신설) | `assets-raw/guest_avatars_m1/riley_happy_v1.png` (pending, base = riley_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(riley, happy) | **pending Phase C** |
| GUEST-riley-excited | riley excited — GIANT closed-arc + WIDE open + 양손 raised + sparkle burst (v1.24 신설) | `assets-raw/guest_avatars_m1/riley_excited_v1.png` (pending, base = riley_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(riley, excited) | **pending Phase C** |
| GUEST-riley-disappointed | riley disappointed — LOWERED EYEBROWS + DOWNTURNED closed mouth (subtle mature, NOT crying, v1.24 신설) | `assets-raw/guest_avatars_m1/riley_disappointed_v1.png` (pending, base = riley_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(riley, disappointed) | **pending Phase C** |
| GUEST-mrs_lee-neutral | mrs_lee (멘토 따뜻한 집밥파) neutral — permed wavy salt-and-pepper hair + round reading glasses + dusty mauve+beige cardigan + dot eyes + subtle arc smile, **CH-02 mother와 차별 CRITICAL: NOT round-bun + glasses signature + NOT persimmon red jeogori** (v1.24 신설) | `assets-raw/guest_avatars_m1/mrs_lee_neutral_v1.png` (pending) | gpt-image-1 generate API | build_prompt_phase_b(mrs_lee, neutral) | **pending Phase B (CH-02 mother 차별 CRITICAL)** |
| GUEST-mrs_lee-happy | mrs_lee happy — closed crescent + open smile + 1-2 sparkle (v1.24 신설) | `assets-raw/guest_avatars_m1/mrs_lee_happy_v1.png` (pending, base = mrs_lee_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(mrs_lee, happy) | **pending Phase C** |
| GUEST-mrs_lee-excited | mrs_lee excited — GIANT closed-arc + WIDE open + raised hands + sparkle burst (mentor warmth peak, v1.24 신설) | `assets-raw/guest_avatars_m1/mrs_lee_excited_v1.png` (pending, base = mrs_lee_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(mrs_lee, excited) | **pending Phase C** |
| GUEST-mrs_lee-disappointed | mrs_lee disappointed — LOWERED EYEBROWS + DOWNTURNED closed mouth (subtle motherly mature, NOT crying, v1.24 신설) | `assets-raw/guest_avatars_m1/mrs_lee_disappointed_v1.png` (pending, base = mrs_lee_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(mrs_lee, disappointed) | **pending Phase C** |
| GUEST-seoyeon-neutral | seoyeon (집밥파 따뜻) neutral — medium-length straight dark brown shoulder hair + oat-beige turtleneck + dot eyes + subtle arc smile (v1.24 신설) | `assets-raw/guest_avatars_m1/seoyeon_neutral_v1.png` (pending) | gpt-image-1 generate API | build_prompt_phase_b(seoyeon, neutral) | **pending Phase B** |
| GUEST-seoyeon-happy | seoyeon happy — closed crescent + open smile + 1-2 sparkle (v1.24 신설) | `assets-raw/guest_avatars_m1/seoyeon_happy_v1.png` (pending, base = seoyeon_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(seoyeon, happy) | **pending Phase C** |
| GUEST-seoyeon-excited | seoyeon excited — GIANT closed-arc + WIDE open + 양손 raised + sparkle burst (v1.24 신설) | `assets-raw/guest_avatars_m1/seoyeon_excited_v1.png` (pending, base = seoyeon_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(seoyeon, excited) | **pending Phase C** |
| GUEST-seoyeon-disappointed | seoyeon disappointed — LOWERED EYEBROWS + DOWNTURNED closed mouth (subtle mature, NOT crying, v1.24 신설) | `assets-raw/guest_avatars_m1/seoyeon_disappointed_v1.png` (pending, base = seoyeon_neutral_v1.png) | gpt-image-1 edit API | build_prompt_phase_c(seoyeon, disappointed) | **pending Phase C** |

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

### 2.5 공통 Suffix — **칼/도마 + cut anchor 7장 (CUT-00~CUT-06, v1.14 신설)**

모든 cut anchor prompt 끝에 동일하게 부착. M1 후반 sprint ADR-005 Stage 2A rhythm tap prerequisite.
**핵심**: cut anchor 7장은 (a) 한식 도마 + 한식 칼 silhouette을 통일 유지하고 (b) 각 cut style은 cutting RESULT state (cut된 결과 상태, NOT cutting action)로 표현하며 (c) 음식 12장 anchor + 환경 5장 anchor와 동일한 Cool Sage `#C8D5C0` bg + modern saturated 톤 + slim outline 2-3px로 cross-asset 일관성 lock.

```
[STYLE_SUFFIX_CUT]
Format: square 1:1.
View: top-down (overhead view, looking straight down at the cutting board surface).
Style: modern mobile casual game asset, clean 2D illustration in Royal Match (Dream Games 2021)
aesthetic. Hero shot of a Korean kitchen cutting board with ingredients prepared for cooking.
Slim bold dark outline 2-3px (warm dark #2D1D14, not pure black), single color fill with optional
soft 1-layer cel shading and ONE small specular highlight per element (juicy/freshness appetite).
Vibrant saturated colors at 80-90 percent saturation, warm food + cool background balance.

CUTTING BOARD (consistent across all 7 cut anchors):
- A Korean kitchen wooden cutting board (도마) in warm brown wood color (#A67049 single fill,
  slim grain line accent 1-2 only, NOT heavy realistic wood texture), rectangular shape with
  rounded corners (approximately 16:9 horizontal proportion, filling most of the image).
- The board has a slight darker rim outline (warm dark #2D1D14, 2-3px), clean modern flat appearance.

KNIFE (consistent silhouette across all 7 cut anchors):
- A modern Korean kitchen knife (식칼) — warm brown wood handle (#A67049 matching the board) +
  silver-gray steel blade (#C8C8C8 single fill with subtle slim cel shading), slim simple geometric
  shape, slightly elongated rectangular blade with a subtle pointed tip.
- The knife sits on or beside the cutting board (placement varies per anchor — see body prompt).

BACKGROUND:
- Solid Cool Sage #C8D5C0 background (consistent across all 7 cut anchors, matches food + environment
  anchor base for cross-asset one-game-world identity).
- Single subtle ambient ellipse shadow directly under the cutting board (#000 ~25% alpha).

Important: avoid beige background, cream paper background, scrapbook, storybook, kraft paper,
vintage texture, golden hour, sunset warm lighting,
Cookie Run, Cookie Run Kingdom frosting style, Toca Boca, Toon Blast over-cartoony,
realistic or photorealistic rendering, 3D render, octane or unreal engine, food photography,
heavy wood grain texture, heavy steel reflection, any texture, noise, grain,
painterly or hand-painted feel, watercolor, gradient mesh, multi-layer complex shading,
hyperdetailed elements, cinematic, gritty, blood, gore,
Japanese kitchen knife (santoku/deba/yanagiba with distinct single-bevel asymmetric blade,
black resin or octagonal magnolia wood handle, kanji engraving on blade),
Chinese cleaver (rectangular tall blade much wider than Korean knife),
Western chef knife (large triangular blade with bolster, German/French style),
mortar and pestle (절구), traditional Korean stone tools (replaced by knife + cutting board as the
direct gameplay mechanic mapping for ADR-005 Stage 2A rhythm tap),
human characters, hands holding the knife, cooking action mid-motion, kitchen environment background,
multiple cutting boards, multiple knives, any English or Korean text legibly readable on the board.
```

> **v1.14 도구 선택 사유**: cut anchor 7장은 cut shape 식별이 우선이므로 prompt-only generation으로 충분 (환경 5장 v4 image edit과 달리 base image의 정확 재현이 필수 요건 아님). gpt-image-1 medium 1024×1024 = $0.042/장. 한식 도마 + 한식 칼 silhouette 통일은 STYLE_SUFFIX_CUT의 explicit description으로 lock.
> **anchor seed 후보**: CUT-00 cutting_board base가 lock 후 CUT-01~06 cut style 6장의 reference image upload seed로 사용 권장 (음식 anchor F-01 / 환경 anchor BG-01과 동일 패턴).

> **v1.15 STYLE_SUFFIX_INGREDIENT (§5.6 신설용)**: ingredient whole 12장도 동일 STYLE_SUFFIX_CUT 본문을 재활용 + **INGREDIENT PLACEMENT 절 추가** (center-right whole ingredient + knife static left placement + cutting RESULT state 대신 WHOLE/UNCUT state 명시 + cut pieces scattered 회피 negative 추가). 도구는 cut anchor와 동일하게 gpt-image-1 medium prompt-only generation. 12장 × $0.042 ≈ $0.50. STYLE_SUFFIX_INGREDIENT 전체 본문은 `tools/gen_ingredient_anchors_m1.py` 상수 참조 (driver script가 single source of truth, 본 §2.5 cut suffix 본문에 INGREDIENT PLACEMENT 절을 추가하면 cut anchor 7장에도 invasive하게 영향 → driver inline 분리 유지).

> **v1.16 STYLE_SUFFIX_REACTION (§5.7 신설용)**: 양친 reaction 6컷은 §2.3 STYLE_SUFFIX_CHAR (캐릭터 5장 공통 suffix)에서 (a) Format은 square 1:1 유지 / (b) View를 **bust-up portrait (head and shoulders only)**로 명시 (캐릭터 5장 full body와 다름) / (c) Background를 **Cool Sage `#C8D5C0` solid**로 전환 (캐릭터 5장 soft mint `#9BE0D2`와 다름 — Scene 3 식탁 reaction context에서 음식/cut/ingredient cross-asset cluster에 합류시키는 결정; 추후 어색하면 V2에서 soft mint revert 가능) / (d) **CHARACTER CONSISTENCY 절 추가** (어머니 Week 1 CH-02_mother base = round-bun + 빨간 jeogori top + soft white apron + warm motherly tone / 아버지 Week 1 CH-03_father base = salt-and-pepper hair + teal-green button-up shirt + kind reserved fatherly tone) / (e) **EXPRESSION GRADIENT 절 신설** (★1/★2/★3 메타 정의 — ★1 subtle smile + 정상 dot eyes / ★2 bigger smile + soft eye crescent arcs / ★3 big wide smile + closed-arc happy eyes + optional sparkle) / (f) **OPTIONAL SCENE 3 CONTEXT CUE 절** (젓가락 한 손 또는 입가 한 조각 minor accent only) / (g) negative에 `sleeping / sad closed eyes / crying tears` (Week 1 CH-04_mother_star1 sad teardrop variant 누수 회피 위해 필수) + `full body / lower body / legs / feet` (bust-up portrait 강제) + `multiple characters in one image` (single subject per anchor, 어머니/아버지 결합 0건) + `speech bubbles / captions` 추가. 도구는 cut/ingredient anchor와 동일하게 gpt-image-1 medium prompt-only generation. 6장 × $0.042 ≈ $0.25. STYLE_SUFFIX_REACTION 전체 본문은 `tools/gen_reaction_anchors_m1.py` 상수 참조 (driver script가 single source of truth, 본 §2.5 cut suffix 본문에 REACTION 변형 절을 추가하면 cut/ingredient anchor 19장에도 invasive하게 영향 → driver inline 분리 유지). **Week 1 reference image upload 권장**: CH-02_mother.png를 R-01~R-03 어머니 3컷 생성 시 reference upload, CH-03_father.png를 R-04~R-06 아버지 3컷 생성 시 reference upload — family IP consistency lock (sref 부재 대체). Week 1 CH-05_father_star3.png는 R-06 아버지 ★3 생성 시 추가 reference로 upload 가능 (★3 expression 형태 reference, 거의 settle 형태).

### 2.6 anchor consistency 운영 규칙 (sref 대체)

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

## 5.7 M1 후반 Sprint — 양친 reaction 6컷 Anchor Prompts (v1.16 신설, Scene 3 식탁 ★1/★2/★3 gradient)

### 5.7.1 개요

> **범위**: 어머니 × {★1, ★2, ★3} + 아버지 × {★1, ★2, ★3} = 총 6장 reaction portrait. Scene 3 식탁 (음식 완성 후 양친이 식탁에서 먹는 reaction) 중심.
> **친구 가족 단위** (project_adr003 2026-05-23 lock): 어머니 + 아버지 L11 동시 unlock (0.6s 시차 fade-in).
> **ADR-005 Total Score 가중 평균** (재료 25% × 준비 20% × 방법 20% × 시간 35%): ★1 30%+ / ★2 60%+ / ★3 90%+.
> **friends-system 호불호 axis** (project_adr003 v0.2): 음식별 호불호 (spicy/sweet/oily/salty/mild) → Total Score + 호불호 보너스 = 최종 reaction.
> **공유 anchor**: Week 1 CH-02_mother.png (어머니 base) + Week 1 CH-03_father.png (아버지 base) + 선택 Week 1 CH-05_father_star3.png (아버지 ★3 reference). reference image upload로 family IP consistency lock (sref 부재 대체).
> **도구**: ChatGPT gpt-image-1 medium 1024×1024 prompt-only generation + reference image upload. 6장 × $0.042 ≈ $0.25.
> **공통 suffix**: §2.5 STYLE_SUFFIX_REACTION (driver script `tools/gen_reaction_anchors_m1.py` 상수 inline) — bust-up portrait + Cool Sage bg + chibi mascot + Family IP consistency + EXPRESSION GRADIENT 메타 정의.
> **i18n**: 모든 prompt는 **icon-first English minimal** 원칙 — 한글 prompt 회피 (DALL-E Korean weakness + global UX). 본문에 `(어머니, early 50s, ...)` 같은 한국어 캐릭터 참조는 family IP context 명세이므로 허용.

### 5.7.2 Week 1 base 시각 확인 결과 (art-director 2026-05-30)

> art-director가 Week 1 commit 7a6cffb base 4장을 Read tool로 시각 확인한 결과 (`assets-raw/week1-anchors/`):

| 파일 | 캐릭터 | Week 1 표정/포즈 | reaction sprint 활용 |
|------|--------|----------------|---------------------|
| **CH-02_mother.png** | 어머니 base | round-bun short black hair (simple dark shape) + 빨간 V-collar jeogori top (#F23E3E 톤) + soft white apron + 양손으로 음식 그릇 (작은 갈색 단지) 들고 + warm motherly subtle smile + 정상 dot eyes + light pink blush. **default expression ≈ ★1-★2 경계** (subtle warm smile 이지만 mouth closed, 약간 ★1 쪽) | R-01~R-03 어머니 3컷 family IP base reference. R-02 ★2가 CH-02 base와 가장 가까운 expression intensity (단 R-02는 bust-up + 음식 그릇 prop 빼고 chopsticks/bowl optional). |
| **CH-03_father.png** | 아버지 base | short salt-and-pepper hair (gray-and-black simple shape) + solid teal-green button-up shirt (#2A8A6C 톤) + dark navy pants + LEFT 손 thumb-up gesture + RIGHT 손 hip 옆 + slim smile + 정상 dot eyes + 매우 light pink blush. **default expression ≈ ★2 경계** (thumb-up 때문에 ★1보다 한 단계 위, 하지만 mouth closed에 slim smile이라 ★2 lower end) | R-04~R-06 아버지 3컷 family IP base reference. R-05 ★2가 CH-03 base와 가장 가까운 expression intensity (단 R-05는 bust-up + thumb-up 약화 small casual gesture). |
| **CH-04_mother_star1.png** | 어머니 Week 1 ★1 variant | round-bun + 빨간 sweater (apron 없음) + **sad teardrop expression** (한 눈에 작은 파란 teardrop visible) + downturned 입 + 한 손이 chin 쪽 어색한 worried 자세 + 정상 dot eyes + light pink blush | **본 sprint 재해석에서 폐기 — Week 1 sad teardrop은 부정 reaction이지 mild satisfaction (★1) 아님**. ADR-005 Total Score gradient 정의에 따르면 ★1 = "30%+ acceptable but not exciting" = mild positive acceptance ↔ Week 1 ★1 sad teardrop은 아예 0-29% 영역의 부정 reaction에 해당. R-01 어머니 ★1 prompt는 subtle warm smile + 정상 open dot eyes (Week 1 CH-04 sad variant 폐기)로 새로 작성. CH-04 file 자체는 보존 (향후 score 0-29% 또는 호불호 penalty 깊은 음식 reaction asset으로 재활용 가능). |
| **CH-05_father_star3.png** | 아버지 Week 1 ★3 variant | salt-and-pepper hair + **파란** button-up shirt (CH-03 base teal-green과 살짝 다른 톤, 시각 디테일 inconsistency) + **excited eyes-closed-arc happy** (upward crescent smile-strokes) + **wide open mouth smile** (clear "wow!" delight) + LEFT 손 thumb-up + RIGHT 손 fist raised + **4개 simple flat orange sparkle accents** (얼굴 주변, single color, NOT detailed anime sparkle) + light pink blush | **본 sprint settle 형태에 가장 가까움**. R-06 아버지 ★3 prompt는 CH-05 variant를 거의 그대로 재현 (단 shirt 톤만 CH-03 base teal-green과 정확 매칭 + bust-up framing). CH-05 image 자체를 R-06 생성 시 추가 reference로 upload 권장 (★3 expression 형태 reference). |

### 5.7.3 ★1/★2/★3 Expression Gradient 정의 (어머니 column + 아버지 column)

> ADR-005 Total Score gradient (★1 30%+ / ★2 60%+ / ★3 90%+)에 맞춘 표정 진화. 어머니 (warm motherly nurturing tone) vs 아버지 (reserved masculine tone) 표정 톤 차이 명확.

| 단계 | Score | 어머니 (warm motherly) | 아버지 (reserved masculine) |
|------|-------|----------------------|--------------------------|
| **★1 mild satisfaction (acceptable but not exciting)** | 30-59% | Eyes: 정상 open dot 2개 / Mouth: SUBTLE small arc (mouth closed, 입꼬리 살짝 up) / Cheek: light pink soft blush / Head: 살짝 tilt (gentle contemplative warmth) / Hand (optional): 한 mitten 손 near chin 또는 chopsticks (minor accent) / **Tone**: 폴라이트 motherly nurturing "this is okay, I appreciate it" | Eyes: 정상 open dot 2개 / Mouth: SLIM RESERVED small arc (mouth closed, 입꼬리 slight 약간만 up) / Cheek: very light pink (mother보다 살짝 약함, 남성적 reserved) / Head: 정상 upright (slumped 아님) / Hand (optional): 한 mitten 손 near chin (thoughtful evaluation) — **thumb-up 없음** (CH-03 base의 thumb-up은 ★2 이상에서만 등장) / **Tone**: stoic acceptance "this is okay" (mother보다 reserved) |
| **★2 happy / pleased (solidly satisfied)** | 60-89% | Eyes: GENTLE UPWARD CRESCENT ARCS (soft crinkle 시작, ★1 dot ↔ ★3 closed-arc 사이 in-between) / Mouth: BIGGER warm smile, slightly OPEN small open-arc (gentle "oh, this is really good!") / Cheek: light pink 살짝 더 visible (warmth glow) / Head: 정상 upright relaxed / Hand (optional): rice bowl 또는 chopsticks 들고 happily eating gesture / **Tone**: genuine warm motherly happiness | Eyes: slight UPWARD CRESCENT ARCS (mother보다 살짝 less pronounced, 남성적) / Mouth: FULLER more open smile (★1 closed-arc보다 살짝 open, "contented this is good") / Cheek: light pink slightly more visible / Head: 정상 upright relaxed (한 어깨 살짝 relaxed) / Hand (optional): SMALL CASUAL thumb-up (CH-03 base와 비슷한 톤, single thumb, ★3보다 toned-down) / **Tone**: reserved posture가 drop하여 genuine relaxed enjoyment |
| **★3 very happy / excited (wow, delicious!)** | 90-100% | Eyes: CLOSED-ARC HAPPY (upward crescent smile-strokes 2개, NOT sad/sleeping closed). Alternative: small simple flat geometric sparkle accents (single color, NOT detailed anime sparkle) / Mouth: BIG WIDE OPEN delighted "wow!" smile (★2 small open ↔ clearly larger and more open, small hint of teeth/mouth-interior OK) / Cheek: light pink clearly visible warm glow (NOT deep dark Cookie Run pink) / Head/Body: joyful, 양 mitten 손 raised near cheeks in delight OR clasped near chest in motherly pride / Optional accent: 1-2 small simple flat geometric heart icons (single color red, NOT detailed) / **Tone**: pure motherly delight, warmest most amplified | Eyes: CLOSED-ARC HAPPY (Week 1 CH-05_father_star3 변형 — upward crescent smile-strokes) / Mouth: BIG WIDE OPEN delighted "wow, son/daughter, this is GREAT!" grin (★2 small open ↔ clearly larger, small hint of teeth OK) / Cheek: light pink clearly visible / Head/Body: energetic excited, body slightly tilted forward in excitement, **one or BOTH mitten 손 enthusiastic thumb-up gesture** (Week 1 CH-05 variant = double thumb-up with one fist raised = settle pose for ★3) / Optional accent: 2-4 small simple flat geometric sparkle accents (single color yellow/orange, Week 1 CH-05 sparkle pattern reference) / **Tone**: peak fatherly excitement breaking through usual reserved posture |

> **Cross-asset tone consistency**: 어머니/아버지 모두 ★1 → ★2 → ★3 gradient는 (1) eye shape 진화 (정상 dot → soft crescent arc → fully closed happy arc) + (2) mouth 진화 (subtle closed arc → small open → big wide open) + (3) body language 진화 (reserved → relaxed → energetic) 3축 동시 amplification. 어머니는 warm motherly nurturing tone amplification, 아버지는 reserved masculine tone breaking into excitement amplification — 같은 gradient 방향이지만 톤 starting point가 다름.

### 5.7.4 6 prompt body 핵심 (한 줄 요약)

| ID | name | character | star | body 핵심 (한 줄) |
|----|------|-----------|------|-----------------|
| **R-01** | mother_star1 | mother | ★1 | 어머니 Week 1 base family IP + bust-up portrait + SUBTLE warm small arc smile (mouth closed, 살짝 up) + 정상 open dot eyes + 살짝 head tilt + Cool Sage bg. **Week 1 CH-04 sad teardrop variant 폐기** — ★1 = mild positive acceptance (NOT sad). |
| **R-02** | mother_star2 | mother | ★2 | 어머니 Week 1 base family IP + bust-up portrait + BIGGER warm smile mouth slightly OPEN + soft UPWARD CRESCENT ARC eyes (★1 ↔ ★3 in-between) + light pink blush more visible + Cool Sage bg. CH-02 base default expression과 가장 가까움. |
| **R-03** | mother_star3 | mother | ★3 | 어머니 Week 1 base family IP + bust-up portrait + BIG WIDE OPEN delighted smile + CLOSED-ARC HAPPY eyes (upward crescent) + 양손 raised near cheeks in delight + optional 1-2 simple flat geometric heart icons + Cool Sage bg. |
| **R-04** | father_star1 | father | ★1 | 아버지 Week 1 base family IP + bust-up portrait + SLIM RESERVED small arc smile (mouth closed, very slight lift) + 정상 open dot eyes + **thumb-up 없음** (★1은 reserved) + Cool Sage bg. |
| **R-05** | father_star2 | father | ★2 | 아버지 Week 1 base family IP + bust-up portrait + FULLER more open smile (small open arc) + slight UPWARD CRESCENT ARC eyes + SMALL CASUAL single thumb-up (CH-03 base 톤) + Cool Sage bg. CH-03 base default expression과 가장 가까움. |
| **R-06** | father_star3 | father | ★3 | 아버지 Week 1 base family IP + bust-up portrait + BIG WIDE OPEN delighted smile + CLOSED-ARC HAPPY eyes (Week 1 CH-05 reference) + **DOUBLE thumb-up + one fist raised** (Week 1 CH-05 settle pose) + 2-4 small simple flat geometric sparkle accents (Week 1 CH-05 sparkle pattern) + Cool Sage bg. Week 1 CH-05 거의 그대로 재현 (단 shirt teal-green CH-03 base 정확 매칭 + bust-up framing). |

> 6 prompt 전체 본문 (각 약 30 line block)은 driver script `tools/gen_reaction_anchors_m1.py`의 REACTIONS 리스트 inline 보존 — single source of truth. 본 §5.7.4는 한 줄 요약만 인용. body 변경 시 driver 와 본 §5.7.4 표 동시 갱신.

### 5.7.5 anchor seed 채택 + reference image upload 워크플로

> sref URL 부재 대체 → reference image upload + subject anchor 문장의 3축 운영:

1. **Round 1 (어머니 anchor seed)**: R-02 어머니 ★2 (가장 CH-02 base default와 가까움)을 anchor seed로 lock. ChatGPT 채팅 세션에 **CH-02_mother.png upload + R-02 prompt** 같이 전송 → "이 reference 어머니 캐릭터와 동일한 family IP (hair / outfit / face features)를 유지하면서 ★2 happy/pleased reaction expression bust-up portrait" follow-up.
2. **Round 2 (어머니 ★1/★3 generation)**: R-02 best result를 같은 채팅 세션 안에서 reference로 사용 → R-01 어머니 ★1 (subtle warm smile) / R-03 어머니 ★3 (big wide open + closed-arc + heart) generation. "앞서 생성한 어머니 ★2 image와 같은 family IP 유지, 단 표정만 ★1 subtle smile 또는 ★3 big delighted로 변경" follow-up.
3. **Round 3 (아버지 anchor seed)**: R-05 아버지 ★2 (가장 CH-03 base default와 가까움)을 anchor seed로 lock. **새 채팅 세션** (어머니/아버지 세션 분리 권장 — 캐릭터 cross-contamination 회피)에 **CH-03_father.png upload + R-05 prompt** 같이 전송 → "이 reference 아버지 캐릭터와 동일한 family IP 유지하면서 ★2 happy/relaxed reaction expression bust-up portrait" follow-up.
4. **Round 4 (아버지 ★1/★3 generation)**: R-05 best result를 같은 채팅 세션 안에서 reference로 사용 → R-04 아버지 ★1 (slim reserved) / R-06 아버지 ★3 (big wide open + double thumb-up + sparkle) generation. R-06 생성 시 **Week 1 CH-05_father_star3.png 추가 reference upload** 권장 — "이 reference image의 ★3 expression intensity (closed-arc happy eyes + double thumb-up + sparkle accents)를 정확히 매칭, 단 shirt teal-green tone과 bust-up framing은 CH-03 base와 정확 매칭" follow-up.

> driver script (`py tools/gen_reaction_anchors_m1.py`)는 ChatGPT API direct call (reference image upload 자동화 X) — 즉 fresh generation으로 6장 batch 생성. reference image upload + chain-of-references 워크플로는 사용자 ChatGPT 웹 UI에서 수동 실행 권장. **driver 6장 batch 결과의 family IP consistency가 약하면 (G1 일관성 FAIL)** 사용자 ChatGPT 웹 UI reference upload 워크플로 사용 권장.

### 5.7.6 reroll trigger (follow-up 대화 형식)

> 어머니/아버지 reaction anchor 공통 reroll trigger:

| Trigger 유형 | follow-up prompt 패턴 |
|-------------|---------------------|
| **G1 family IP 일관성 FAIL** (Week 1 base와 다른 캐릭터) | "이 이미지를 다시 그려줘. Week 1 reference image와 같은 family IP (hair / outfit / face features) 정확히 매칭, 같은 outline 두께·features·컬러 saturation 유지." |
| **표정 gradient FAIL — ★1이 너무 expressive / ★3이 너무 reserved** | "이 이미지를 다시 그려줘. ★N expression intensity를 [더 subtle/더 expressive]로 — ★1 = subtle small arc mouth closed, ★2 = bigger open arc, ★3 = wide open delighted + closed-arc happy eyes 3 단계 gradient 정확 매칭." |
| **sad/sleeping closed eyes 누수** (Week 1 CH-04 sad teardrop 패턴) | "이 이미지를 다시 그려줘. 눈을 [정상 open dot 2개 OR 위로 향한 happy upward crescent arc]로, 절대 sad/sleeping/crying closed eyes 아님. 표정은 [mild satisfaction / happy / very happy] 긍정 reaction." |
| **full body / lower body 누수** (bust-up 위반) | "이 이미지를 다시 그려줘. bust-up portrait (head and shoulders only)로 — 다리/하반신/full body 절대 안 보이게. Scene 3 식탁 seated 형태." |
| **bg cool sage 누수 → 베이지/cream/캐릭터 5장 soft mint 누수** | "이 이미지를 다시 그려줘. 배경을 solid Cool Sage #C8D5C0 (cool tone)으로 명확히, 베이지/cream/soft mint #9BE0D2 톤 모두 제거. Scene 3 식탁 cross-asset 일관성." |
| **multiple characters 누수** (어머니/아버지 결합) | "이 이미지를 다시 그려줘. single subject만 ([어머니 OR 아버지]) 그리기 — 다른 가족 멤버 절대 없음. portrait composition." |
| **deep dark pink cheek / Cookie Run frosting 누수** | "이 이미지를 다시 그려줘. cheek blush를 LIGHT pink #FFCFCF soft 로, deep dark Cookie Run frosting pink 절대 안 됨." |
| **sparkle/heart icon 폭주 detail** (★3에서만 발생) | "이 이미지를 다시 그려줘. sparkle/heart 아이콘을 simple flat geometric (single color, NOT detailed anime sparkle effect)로 단순화, 1-4개만 minor accent로." |
| **남성적 톤 누수 (아버지)** — anime boy / teenager 누수 | "이 이미지를 다시 그려줘. 50대 mature father로 강조 — salt-and-pepper hair + 다 자란 성인, 절대 teenager/anime boy/school boy 아님." |

### 5.7.7 driver script + 실행 명령

- 신규 driver: `tools/gen_reaction_anchors_m1.py`
- 6장 batch 실행: `py tools/gen_reaction_anchors_m1.py --model gpt-image-1 --quality medium`
- 1장 test 실행 (R-02 어머니 ★2 anchor seed 권장): `py tools/gen_reaction_anchors_m1.py --only R-02`
- 일부 실행 (어머니/아버지 ★1만): `py tools/gen_reaction_anchors_m1.py --only R-01,R-04`
- 출력 경로: `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v1.png` (v1 default, --version v2 plate 가능)
- 비용 예상: 6장 × $0.042 ≈ $0.25
- 시간 예상: ~2-3분 (6장 batch)

### 5.7.8 ChatGPT 약점 risk top 5

| Rank | reaction anchor | 누수 risk | default % | 회피 전략 |
|------|----------------|----------|-----------|----------|
| 1 | R-01 mother_star1 | sad teardrop / crying / disappointed expression 누수 (Week 1 CH-04 sad pattern + ChatGPT의 "low rating reaction" → sad 자동 추론) | ~60% | "MILD POSITIVE acceptance, subtle warm smile + 정상 OPEN dot eyes, NOT sad, NOT crying, NOT disappointed" explicit 강제 + ★1 = "30%+ acceptable but not exciting" gradient 정의 명시 |
| 2 | R-06 father_star3 | sparkle detail 폭주 (anime sparkle effect 누수) + double thumb-up이 single thumb-up로 단순화 | ~40% | "small simple flat geometric sparkle (single color, NOT detailed anime sparkle)" + "BOTH mitten hands enthusiastic thumb-up gesture (Week 1 CH-05_father_star3 settle pose)" 명시 + Week 1 CH-05 reference upload 권장 |
| 3 | R-03 mother_star3 | heart icon detail 폭주 + closed-arc eyes가 sad closed eyes로 잘못 추론 | ~35% | "HAPPY UPWARD ARC closed-arc (smiling eyes, NOT sad/sleeping)" + "small simple flat geometric heart icons (single color, NOT detailed)" 명시 |
| 4 | R-02 / R-05 ★2 in-between | ★2의 in-between expression이 ★1 또는 ★3로 collapse (gradient flat화) | ~30% | "GENTLE UPWARD CRESCENT ARCS (★1 dot ↔ ★3 fully closed-arc 사이 in-between)" + "BIGGER than ★1, SMALLER than ★3" 양방향 비교 명시 |
| 5 | R-04 father_star1 | thumb-up 누수 (CH-03 base의 thumb-up이 ★1에 carry over) | ~25% | "thumb-up 없음 (★1은 reserved, thumb-up은 ★2 이상에서만)" explicit 명시 |

> 부차 risk (P2): 모든 reaction에서 full body 누수 (~25%), bg 캐릭터 5장 soft mint 누수 (~20%), multiple characters 결합 누수 (~15%).


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

#### F-02 — Janchi-guksu (잔치국수, T1, v1.17 mvp v2.2 신규 — 호떡 deprecated 2026-05-30)

**English title**: Janchi-guksu (Korean Celebration Noodle Soup with Anchovy Broth)

**식별 핵심 시각 요소**:
- 넓고 얕은 흰 baekja shallow bowl (한식 백자, sloped wide rim, NOT 깊은 일본 ramen 뚝)
- 맑은 light golden-amber 멸치 dashi broth (warm pale brown-yellow, NOT 진한 spicy red, NOT 짙은 miso brown, NOT clear Vietnamese pho)
- THIN delicate 흰 wheat noodles (소면 white wheat thin strands, swirled mound at center, hero element)
- garnish 5종 (fanned arrangement, separated strips): 노란 계란 지단 strips (julienned yellow egg crepe) + 검정 김 strips (gim, julienned rectangular) + 녹색 애호박 (zucchini disc/julienne) + optional 멸치 (dried anchovy 1-2 minor accent) + optional 빨간 고추 slice
- single subtle ambient ellipse shadow

**Tier 1 단서**: bowl 1개, 1인분, garnish 4-5종 단순 fanned.

**Prompt** (v1.17 mvp v2.2 신설, ChatGPT 자연어):
```
A modern mobile casual game food card illustration of Korean Janchi-guksu (잔치국수,
Korean celebration noodle soup with anchovy broth), top-down view.
A wide clean white round shallow bowl (Korean baekja porcelain, gently sloped wide rim, large enough
for noodles + clear broth + garnish, NOT a deep narrow Japanese ramen donburi, NOT a Vietnamese pho
deep wide soup plate) is filled with light golden-amber clear anchovy dashi broth (멸치 육수,
warm pale brown-yellow gentle tone — the gentle clear broth made from dried anchovies + dried kelp,
NOT a thick brown miso, NOT a pale white tonkotsu, NOT a vibrant spicy red gochugaru, NOT a
dark soy-based broth, NOT a vivid Vietnamese pho cinnamon-clove tinted broth).
THIN delicate white wheat noodles (소면 somen-style Korean white thin wheat noodles, fine slim strands)
emerge in a soft swirled nest at the center of the bowl, the noodles forming a gentle rounded mound
that rises just above the broth surface (the noodles are clearly visible as the hero element, the
broth pools around the noodle mound).
GARNISH on top of the noodle mound (Korean janchi-guksu signature, arranged in clean separated
strips fanning out from the center):
(1) bright YELLOW EGG RIBBON strips (지단 julienned egg crepe, thin yellow rectangular strips
~3-5cm long × ~3mm wide, 5-7 strips fanning across one side of the noodle mound, a hero garnish),
(2) dark green-black GIM SEAWEED STRIPS (얇게 자른 김, thin rectangular black-green seaweed strips
~3-5cm long × ~3mm wide, 5-7 strips on the opposite side of the egg ribbon, matte NOT glossy),
(3) thin GREEN ZUCCHINI ROUNDS or julienned light-green zucchini (애호박, 3-4 thin pale green
diagonal slices ~2cm long × ~1cm wide × very thin, scattered as accent),
(4) optional 1-2 small DRIED ANCHOVY (멸치) garnish on the rim or beside the bowl as a hint of the
broth ingredient (small slim silver-gray fish ~2-3cm long, OPTIONAL minor accent),
(5) optional 1 RED CHILI PEPPER SLICE (small thin red diagonal slice as color accent, OPTIONAL).
Single subtle ambient ellipse shadow under the bowl.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Janchi-guksu (잔치국수, celebration noodle soup with clear anchovy
dashi broth), NOT Japanese somen (Japanese somen is served cold with tsuyu dipping sauce in a
separate cup + ice cubes + green onion garnish, NOT in a hot anchovy broth bowl with egg ribbon +
gim + zucchini), NOT Japanese udon (udon noodles are THICK chunky white strands, janchi-guksu is
THIN delicate strands), NOT Japanese ramen (ramen has curly yellow egg noodles + miso/tonkotsu/shoyu
broth + narutomaki/chashu/nori sheet, NOT clear anchovy broth + egg ribbon/gim/zucchini garnish),
NOT Japanese soba (soba is buckwheat brown-gray noodles, janchi-guksu is white wheat noodles).
NOT Vietnamese pho (pho has clear cinnamon-clove beef broth + raw beef slices + lime wedge + bean
sprouts + Thai basil + cilantro + hoisin/sriracha side, janchi-guksu has anchovy broth + egg ribbon
+ gim + zucchini, NO lime, NO bean sprouts, NO basil/cilantro herbs, NO sliced beef).
NOT Chinese egg noodle soup or wonton soup (those use yellow egg noodles + char siu pork / wontons,
NOT thin white wheat noodles + Korean garnish set).
NOT Korean instant Ramyeon (F-01 with vibrant orange-red gochugaru spicy broth + curly yellow
noodles + sunny-side-up egg + spring onion — janchi-guksu is the OPPOSITE: clear gentle anchovy
broth + thin white wheat noodles + egg ribbon strips + gim strips, gentle vs spicy, white vs yellow,
clear vs red).
The ESSENTIAL signature features are: (a) wide clean white Korean baekja shallow bowl + (b) LIGHT
GOLDEN-AMBER clear anchovy broth + (c) THIN delicate WHITE wheat noodles swirled mound + (d) bright
YELLOW EGG RIBBON STRIPS as hero garnish + (e) dark GIM SEAWEED STRIPS contrast garnish + (f) thin
green zucchini accent. The combination of clear anchovy broth + thin white wheat noodles + yellow
egg ribbon + dark gim strips is the unmistakable Korean janchi-guksu signature.
NO Japanese ceramic pink spiral narutomaki, NO chashu pork, NO seaweed sheet on top (gim is in
JULIENNED STRIPS, not a sheet), NO wasabi, NO gari, NO bonito flakes, NO mayo, NO lime wedge,
NO bean sprouts, NO herbs (basil/cilantro), NO sliced raw beef.
```

**ChatGPT 약점 회피 노트**:
- **risk H — Japanese somen 누수** (~50% default): "noodle soup with thin white wheat noodles" → ChatGPT default가 Japanese cold somen 추론 빈번. "hot anchovy broth + egg ribbon + gim + zucchini garnish" 강제 + Japanese cold tsuyu/separate cup/ice 명시 회피.
- **risk M — Vietnamese pho 누수** (~30%): "clear noodle soup" → ChatGPT가 pho 추론 가능. "anchovy broth", "egg ribbon + gim strips garnish" + "NO lime, NO bean sprouts, NO basil/cilantro" 명시.
- broth 색 누수: 맑은 한식 멸치 broth가 ChatGPT default로 miso brown 또는 spicy red로 빠지기 쉬움. "LIGHT GOLDEN-AMBER clear anchovy broth" 반복 강조.
- F-01 라면과 혼동: 둘 다 noodle soup이지만 F-01 라면은 spicy red + curly yellow, F-02 잔치국수는 clear amber + thin white. 본문 "OPPOSITE of F-01 Ramyeon" 명시.

**Reroll 트리거** (follow-up):
- Japanese somen 누수: "이 이미지를 다시 그려줘. Korean Janchi-guksu로 명확히 — 넓고 얕은 흰 baekja bowl + 따뜻한 light golden-amber clear anchovy dashi broth + 흰 thin wheat noodles swirled mound + 노란 egg ribbon strips + 검정 gim strips + 녹색 애호박 garnish. NOT Japanese cold somen with tsuyu, NO separate dipping cup, NO ice cubes."
- Vietnamese pho 누수: "이 이미지를 다시 그려줘. NOT Vietnamese pho — anchovy broth (NOT cinnamon-clove beef broth), Korean garnish (egg ribbon + gim + zucchini), NO lime wedge, NO bean sprouts, NO Thai basil, NO cilantro, NO sliced raw beef."
- broth 색 누수 (brown miso로 추론): "이 이미지를 다시 그려줘. broth를 LIGHT GOLDEN-AMBER clear (warm pale yellow-amber)로 강조, 멸치 dashi 시그니처 — NOT brown miso, NOT dark soy, NOT red spicy."
- garnish 누수 (egg ribbon 또는 gim strips 누락): "이 이미지를 다시 그려줘. garnish 4종 명확 — (1) 노란 egg ribbon julienned strips 5-7개 fanned + (2) 검정 gim julienned strips 5-7개 opposite side + (3) 녹색 애호박 slices 3-4개 + (4) optional dried anchovy 1-2개."

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

#### F-09 — Bulgogi (불고기, T2, v1.17 mvp v2.2 신규 — 김치찌개 deprecated 2026-05-30, F-12 갈비 차별화 CRITICAL)

**English title**: Bulgogi (Korean Marinated Thin-sliced Beef with Vegetables)

**식별 핵심 시각 요소**:
- **검정 cast-iron Korean BBQ pan (전골 jeongol-style)** — shallow round black cast-iron, slightly curved rim ~22-28cm, rustic dark iron (NOT 깊은 Chinese wok, NOT copper sukiyaki pan, NOT white ceramic plate)
- **GLOSSY BROWN soy-pear-garlic marinade pool** (간장+배+마늘+설탕+참기름 양념, dark caramel-brown glossy sauce, 단짠 umami coating everything)
- **5-7 THIN MARBLED BEEF slices fanned** (얇게 썬 차돌박이/등심, each ~6-10cm × ~4-6cm × ~2-3mm paper-thin, marbled fat veins visible across cooked rich brown surface, naturally curled at edges)
- **MIXED VEGETABLES in SAME PAN**: 양파 white onion half-moon slices + 대파 green scallion 3-4cm segments + 당근 orange carrot julienne + 표고/느타리 brown mushroom slices + optional 당면 brown glass noodle strands
- garnish: 깨 generous sprinkle + 송송 sliced 대파 chopped rounds
- single subtle ambient ellipse shadow under cast-iron pan

**Tier 2 단서 (2인분 풍성)**: 큰 cast-iron pan + 5-7 beef slices generously + 4-6 vegetable types mixed together + 깨/대파 garnish.

**F-12 갈비구이 차별화 CRITICAL** (불고기 ≠ 갈비 절대 구분):
- NO bone-in LA cut, NO visible white rib bone, NO cross-section bone discs along strips
- NOT grilled on wire mesh grill grate over hot coals
- NOT large 18-25cm LA strips (불고기는 작은 ~6-10cm 자연 curled slices)
- 불고기는 IN A PAN with marinade pool + mixed vegetables together (갈비는 plated on ceramic plate or grill grate)

**Prompt** (v1.17 mvp v2.2 신설, ChatGPT 자연어):
```
A modern mobile casual game food card illustration of Korean Bulgogi (불고기, marinated
thin-sliced beef hot pot dish with vegetables), 7/8 top-down view.
The dish is served on/in a DARK CAST-IRON KOREAN BBQ PAN (전골 jeongol-style shallow round black
cast-iron pan with a slightly curved rim, ~22-28cm diameter, rustic dark iron color #2D2D33, NOT a
glossy Chinese wok with rounded deep bowl, NOT a Japanese sukiyaki copper pan, NOT a white ceramic
plate — Korean cast-iron bulgogi pan is dark, flat-ish, shallow, slightly curved rim).
The pan is filled with the rich BROWN SOY-PEAR-GARLIC MARINADE POOL (간장+배+마늘+설탕+참기름 양념,
glossy dark caramel-brown sauce, generously coating everything, gentle bubbling sheen — NOT a deep
sukiyaki broth bath, NOT a clear shabu-shabu broth, NOT a vibrant red gochujang sauce, NOT a green
salsa — just a glossy umami brown soy-pear-garlic marinade coating).
HERO: 5-7 THIN SLICED MARBLED BEEF pieces (얇게 썬 차돌박이 / 등심 marinated bulgogi beef slices,
each slice ~6-10cm long × ~4-6cm wide × ~2-3mm THIN paper-thin slice, soft marbled fat veins
visible in pale white pattern across the dark cooked rich brown surface, FANNED arrangement curling
naturally as cooked beef does — some slices slightly curled at edges, others laying flat, all
coated with the glossy soy-pear-garlic marinade glaze with a slight brown sheen specular highlight).
The beef slices are CLEARLY VISIBLE as the hero element, generously filling ~50-60% of the pan area.
COOKED VEGETABLES mixed together with the beef in the SAME PAN (NOT on the side, NOT separated):
- 4-6 WHITE ONION SLICES (양파, thin half-moon slices ~3-5cm long × ~1.5cm wide, slightly
  translucent caramelized pale white-gold, mixed in among the beef),
- 3-5 GREEN SCALLION SEGMENTS (대파 chunks, ~3-4cm long diagonal-cut bright green stalks, scattered
  across the pan),
- 2-3 ORANGE CARROT JULIENNE strips (당근 채, thin matchstick ~4-5cm long × ~3mm wide, bright orange
  accent visible among brown beef),
- 2-3 BROWN SHIITAKE OR OYSTER MUSHROOM slices (표고 or 느타리 버섯, dark brown cap slices ~3-4cm wide,
  cooked tender),
- optional 1-2 TRANSLUCENT BROWN GLASS NOODLE (당면 dangmyeon) strands mixed in as accent (slim
  shiny translucent amber strands, optional minor element — Korean bulgogi often includes a small
  portion of dangmyeon mixed in).
GARNISH on top of the bulgogi:
- generous sprinkle of WHITE SESAME SEEDS (깨, scattered all over the beef + vegetables as a hero
  Korean garnish),
- CHOPPED GREEN SCALLION ROUNDS (송송 sliced 대파, small bright green disc-shaped slices ~1-2mm thick,
  scattered as additional accent — these are SMALL CHOPPED ROUNDS, NOT the larger 3-4cm scallion
  SEGMENTS mixed into the beef above).
Single subtle ambient ellipse shadow under the cast-iron pan.

[STYLE_SUFFIX_FOOD]

Important also: this is Korean Bulgogi (불고기, thin-sliced marinated beef cooked together with
vegetables in a Korean cast-iron pan). The ESSENTIAL signature features are: (a) DARK CAST-IRON
KOREAN BBQ PAN (NOT plate, NOT bowl, NOT grill grate) + (b) GLOSSY BROWN soy-pear-garlic marinade
pool coating everything + (c) THIN SLICED marbled beef (paper-thin 2-3mm slices, FANNED naturally,
marbled fat visible) + (d) MIXED VEGETABLES IN THE SAME PAN (onion + scallion + carrot + mushroom)
+ (e) sesame seeds + chopped scallion garnish.

CRITICAL — F-12 갈비구이 차별화 (이 요리는 불고기 NOT 갈비):
- NO BONE-IN LA CUT — bulgogi uses BONELESS thin-sliced beef, ABSOLUTELY NO visible white rib bone,
  NO bone cross-section discs along strips, NO single long bone alongside meat. Any rib bone =
  immediate FAIL (that's F-12 Galbi-gui, this is F-09 Bulgogi).
- NOT GRILLED ON METAL GRATE — bulgogi is cooked IN A PAN with marinade pool, NOT on a wire mesh
  grill grate over hot coals (that's F-12). NO hot coals glow underneath, NO wire mesh grate
  pattern.
- NOT SEPARATED MEAT STRIPS — bulgogi has thin marbled slices fanned naturally curling, NOT
  perfectly parallel rectangular strips spaced evenly (that's F-12 LA-galbi form).
- NOT LARGE 18-25cm LA STRIPS — bulgogi slices are smaller ~6-10cm × 4-6cm and natural curled
  shapes, NOT large rectangular cross-cut strips.

NOT Japanese SUKIYAKI (sukiyaki has deeper broth bath in a square iron pan + raw egg dipping bowl
on the side + tofu cubes + 다른 vegetable set + napa cabbage dominant — bulgogi is shallow
marinade-coated, NO raw egg dipping bowl, NO deep broth bath).
NOT Japanese SHABU-SHABU (shabu-shabu uses clear simmering broth pot with thin meat slices dipped
mid-cooking + ponzu/sesame dipping sauce — bulgogi is already coated with marinade in the pan, no
clear broth, no dipping sauce setup).
NOT Japanese YAKINIKU (yakiniku is grilled boneless thin beef on tabletop grill grate with salt or
soy dipping sauce, NO marinade pool coating in a pan, NO mixed vegetables cooked together).
NOT Chinese BEEF STIR-FRY (stir-fry has wok hei char marks + dark soy + glossy thick cornstarch
sauce + Chinese cabbage / bok choy / bean sprouts vegetable set, bulgogi has soy-pear-garlic
marinade + Korean vegetable set + cast-iron pan, NOT wok).
NOT American BBQ RIBS (red BBQ sauce + thick slab + bone-on-side, completely different category).
NOT Korean Kimchi Jjigae F-09 deprecated (was vibrant red-orange gochugaru broth + ttukbaegi stone
pot + tofu cubes + kimchi chunks — this is the NEW F-09 Bulgogi, completely different visual:
brown marinade NOT red broth, cast-iron pan NOT ttukbaegi, thin beef slices NOT tofu cubes).

The combination of dark cast-iron Korean pan + glossy brown soy-pear-garlic marinade pool +
fanned thin marbled beef slices + mixed vegetables (onion/scallion/carrot/mushroom) in the SAME
pan + sesame + chopped scallion garnish is the unmistakable Korean bulgogi signature.
```

**ChatGPT 약점 회피 노트**:
- **risk HIGH — Japanese sukiyaki 누수** (~50% default): "thin marbled beef + dark cast-iron pan + soy sauce + vegetables" → ChatGPT default가 sukiyaki 추론 빈번. raw egg dipping bowl 추가 회피 critical. "NO raw egg dipping bowl, NO deep broth bath" 명시.
- **risk HIGH — F-12 갈비구이 cross-contamination** (~40%): 동일 한식 BBQ 카테고리이므로 ChatGPT가 bone-in LA cut 누수 가능. "NO BONE-IN LA CUT, NO visible white rib bone, NOT grilled on wire mesh grate" 반복 강조. F-12와 시각 분리 critical.
- pan 누락 (plate로 추론): "dark cast-iron Korean BBQ pan" 명시, ceramic plate 회피.
- 양념 누수 (red gochujang으로 추론, 김치찌개 잔재): "GLOSSY BROWN soy-pear-garlic marinade, NOT vibrant red gochujang" 명시.
- vegetables 분리 (side dish로 추론): "mixed in SAME PAN, NOT on the side, NOT separated" 명시.

**Reroll 트리거** (follow-up):
- Japanese sukiyaki 누수: "이 이미지를 다시 그려줘. Korean Bulgogi로 명확히 — 검정 cast-iron Korean BBQ pan + glossy brown soy-pear-garlic marinade pool + thin fanned marbled beef + mixed vegetables. NOT Japanese sukiyaki, NO raw egg dipping bowl, NO deep broth bath."
- F-12 갈비 cross-contamination: "이 이미지를 다시 그려줘. NOT F-12 갈비 — BONELESS thin-sliced beef (~2-3mm), NO visible white rib bone, NO bone cross-section discs, NOT on wire mesh grill grate over hot coals. 불고기 = pan with marinade pool + mixed vegetables."
- pan 누수 (white plate로): "이 이미지를 다시 그려줘. pan을 DARK CAST-IRON Korean BBQ pan (shallow round black, slightly curved rim ~22-28cm)으로 명확히, NOT a ceramic plate, NOT a glossy wok."
- vegetables 누락 또는 분리: "이 이미지를 다시 그려줘. 양파/대파/당근/표고 mixed IN THE SAME PAN with beef (NOT on the side, NOT a separate plate). 5-7 thin beef slices + 4 vegetable types mixed together in the marinade pool."
- marinade 색 누수 (red로): "이 이미지를 다시 그려줘. marinade를 GLOSSY BROWN soy-pear-garlic (간장+배+마늘 단짠 갈색)으로, NOT vibrant red gochujang (이건 김치찌개 잔재), NOT clear broth."

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

### 5.5 ADR-005 Stage 2A 칼/도마 + Cut Style 6종 (v1.14 신설, M1 후반 sprint — full prompts)

> **ADR-005 Stage 2A prerequisite**: 재료 준비 = rhythm tap + Knife indicator. 칼이 자동 위아래 움직임 (AnimationPlayer), 도마 닿기 직전 = perfect tap. 각 cut style은 BPM 다름 (다지기 140 가장 빠름 / 통썰기 70 가장 느림).
> **범위**: 칼/도마 base 1장 + cut style 6장 = **총 7장**. 각 cut style은 cutting RESULT state (cut된 결과 상태, NOT cutting action mid-motion) — 게임 asset으로 도마 + cut된 재료 + 칼 옆에 놓임 형태.
> **공유 anchor**: CUT-00 cutting_board base가 anchor seed → CUT-01~06 cut style 6장 prompt에 reference upload + "같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 outline 두께로 일관성 유지" follow-up. 음식 anchor F-01 / 환경 anchor BG-01과 동일 패턴.
> **도구**: ChatGPT (GPT-4o image / gpt-image-1 medium). prompt-only generation (cut shape 식별 우선, image edit 불필요).
> **공통 suffix**: §2.5 STYLE_SUFFIX_CUT 모든 prompt 끝에 부착.

#### 5.5.0 음식 12 × hero ingredient × cut style 매핑 표 (v1.15 신설)

> **출처**: ADR-005 Stage 2A 재료 준비 미니게임은 음식별 hero ingredient를 적절한 cut style로 자르는 형태. 본 매핑은 art-director **임시 직관 매핑** — game-designer foods CSV `prep_*` 컬럼 후속 확정 시 일부 reroll/재매핑 가능. 매핑이 변경되면 §5.6 ingredient whole anchor도 같이 reroll.
> **F-06 / F-10 예외**: 콘도그 cheese / 순두부 soft tofu는 cut 없이 whole(또는 broken curds) 형태로 사용 — 본 매핑 표에서 cut style = (no cut).

| food_id | 음식 | hero ingredient | cut style anchor | BPM | 비고 |
|---------|------|----------------|------------------|-----|------|
| F-01 | Ramyeon (라면) | 대파 (spring onion) | CUT-05 송송썰기 | ~90 | 라면 가니쉬 시그니처 thin 송송 sliced rounds |
| F-02 | Hotteok (호떡) | 견과류 (peanut) | CUT-01 다지기 | ~140 | 호떡 filling 토핑 finely chopped 견과류 |
| F-03 | Kimbap (김밥) | 단무지 (pickled radish) | CUT-02 채썰기 | ~100 | 김밥 단면 hero julienne strip |
| F-04 | Tteokbokki (떡볶이) | 어묵 (fish cake sheet) | CUT-03 어슷썰기 | ~80 | 떡볶이 시그니처 diagonal oval slices |
| F-05 | Kimchi Fried Rice (김치볶음밥) | 김치 (napa cabbage kimchi leaf) | CUT-01 다지기 | ~140 | 볶음밥용 chopped 김치 base |
| F-06 | Korean Corn Dog (콘도그) | 모짜렐라 (cheese stick) | **(no cut, whole)** | N/A | 콘도그 내부 cheese stretch — whole 그대로 insert |
| F-07 | Haemul Pajeon (해물파전) | 대파 daepa (large scallion) | CUT-03 어슷썰기 | ~80 | 파전 시그니처 diagonal-sliced 대파 (F-01 spring onion보다 thicker variety) |
| F-08 | Bibimbap (비빔밥) | 당근 (carrot) | CUT-02 채썰기 | ~100 | 비빔밥 6 section 중 orange hero julienne |
| F-09 | Kimchi Jjigae (김치찌개) | 두부 firm (firm tofu) | CUT-06 깍둑썰기 | ~70 | 김치찌개 시그니처 흰 cube dice 두부 |
| F-10 | Sundubu Jjigae (순두부) | 두부 soft (soft tofu tube) | **(no cut, broken curds)** | N/A | 순두부는 cut 없이 squeezed/scooped soft curds |
| F-11 | Japchae (잡채) | 당근 (carrot) | CUT-02 채썰기 | ~100 | 잡채 시그니처 — F-08과 동일 ingredient (asset 재사용 가능) |
| F-12 | Galbi-gui (갈비구이) | 마늘 (garlic cloves) | CUT-01 다지기 | ~140 | 갈비 양념 finely minced garlic base |

> **cut style 분포 통계** (음식 12 → cut style 5 + 2 no-cut):
> - CUT-01 다지기 (mince) — F-02 호떡 견과류 / F-05 김치볶음밥 김치 / F-12 갈비 마늘 = 3 음식
> - CUT-02 채썰기 (julienne) — F-03 김밥 단무지 / F-08 비빔밥 당근 / F-11 잡채 당근 = 3 음식 (당근 2회)
> - CUT-03 어슷썰기 (diagonal) — F-04 떡볶이 어묵 / F-07 해물파전 대파 daepa = 2 음식
> - CUT-04 통썰기 (whole disc) — 본 매핑에서 hero ingredient 없음 (김밥 cylinder 단면은 김밥 자체 service form, hero ingredient cut prep 아님)
> - CUT-05 송송썰기 (sliced rounds) — F-01 라면 대파 spring onion = 1 음식
> - CUT-06 깍둑썰기 (cube) — F-09 김치찌개 두부 firm = 1 음식
> - **no cut** — F-06 콘도그 모짜렐라 / F-10 순두부 soft tofu = 2 음식
>
> CUT-04 통썰기는 hero ingredient cut prep 매핑이 없음 → game-designer 후속 검증 시 (a) 김밥 자체 cylinder slice를 Stage 2C "plating" 단계 cut으로 분리 매핑하거나 (b) 다른 음식에 통썰기 추가 매핑 (예: F-04 떡볶이 떡 cylinder도 송송/통썰기 가능)을 고려.

#### 5.5.1 CUT-00 — Cutting Board base (칼+도마 정적 baseline, anchor seed)

**의도**: Scene 2 (Kitchen) 도마 화면 background asset. 칼 + 도마 정적 baseline (NO food, NO cut state). cut style 6종 anchor seed.

**식별 핵심 시각 요소**:
- 한식 도마 — warm brown wood (#A67049) + slim grain accent 1-2개 + rounded corners + ~16:9 가로비례 (square 1:1 frame 내)
- 한식 칼 (식칼) — warm brown wood handle + silver-gray steel blade + slim simple geometric shape, slightly elongated rectangular blade with subtle pointed tip
- 칼은 도마 위에 비스듬히 (~45도, handle = 하단 좌측 또는 우측 corner / blade tip = 대각선 상단 corner) — 정적 baseline placement, NOT mid-swing
- bg = solid Cool Sage `#C8D5C0` + ambient ellipse shadow

**Prompt** (v1.14 신설):
```
A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with a kitchen knife resting on top, top-down view, static baseline state (NO food on the board,
NO cut ingredients, NO cutting action in progress — this is the empty cutting board + knife
baseline used as the Scene 2 (Kitchen) background asset in the K-Food Master mobile game).

The wooden cutting board fills most of the image (approximately 16:9 horizontal proportion within
the square frame), centered with a small margin around it. The board is warm brown wood (#A67049
single fill) with 1-2 subtle slim grain lines as accent (NOT heavy realistic wood grain texture).
The board has a slim bold dark outline (warm dark #2D1D14, 2-3px) and rounded corners (modern
friendly mobile game shape).

The Korean kitchen knife sits on the cutting board surface, placed diagonally at approximately
a 45-degree angle (handle in the lower-left or lower-right corner of the board, blade pointing
toward the opposite upper corner — a natural relaxed placement, NOT mid-swing motion). The knife
has a warm brown wood handle (#A67049 matching the board) and a silver-gray steel blade (#C8C8C8
single fill with subtle slim cel shading), simple geometric slim silhouette.

[STYLE_SUFFIX_CUT]

Important also: this is the EMPTY cutting board + knife baseline state — NO food ingredients on
the board, NO cut pieces, NO vegetables, NO meat, NO fish, NO garlic, NO scallions, NO tofu, NO
sauce, NO mortar and pestle, NO traditional Korean stone tools (this is the modern direct-mechanic
mapping per ADR-005 Stage 2A rhythm tap requirement). The knife is at a relaxed diagonal placement
(not raised mid-swing, not chopping in motion). This is the static baseline cutting board scene
used as the foundation for all 6 cut style variants.
```

**Expected output 특징**: empty Korean cutting board + diagonal knife placement + Cool Sage bg + slim outline 2-3px + no food.

**Reroll 트리거** (follow-up):
- 음식이 추가됨: "이 이미지를 다시 그려줘. 도마 위에 음식/재료 완전 제거. 칼만 도마 위에 비스듬히 놓여있는 정적 baseline 상태."
- 절구 누수: "이 이미지를 다시 그려줘. mortar and pestle (절구) 완전 제거. 한식 도마 + 한식 칼만."
- Japanese 식칼 누수 (santoku/deba): "이 이미지를 다시 그려줘. modern Korean kitchen knife (식칼)로 — 직사각 slim blade + warm brown wood handle. NOT Japanese santoku/deba single-bevel asymmetric blade, NOT kanji engraving."
- 칼 mid-swing motion: "이 이미지를 다시 그려줘. 칼을 도마 위에 비스듬히 (~45도) 정적 placement, NOT raised mid-chop, NOT in motion."

#### 5.5.2 CUT-01 — Mince (다지기, 마늘, BPM 140 가장 빠름)

**의도**: F-12 갈비 양념 / F-09 김치찌개 시그니처. 가장 빠른 BPM rhythm tap cut style.

**식별 핵심 시각 요소**:
- 마늘 minced bits scattered — 작은 yellowish-white 불규칙 granules (각 1-3mm, irregular angular shapes, NOT round perfect discs)
- 도마 center-right portion에 generous 클러스터로 scattered (loose cluster, "just been minced" 인상)
- optional 1-2 whole garlic cloves (small rounded teardrop, off-white) — LEFT side에 시각 reference
- 칼은 LEFT side에 set down, blade flat against board, handle lower-left corner

**Tier**: BPM 140 — 가장 fine/granular cut, 시각적으로 가장 분산된 fine texture

**Prompt** (v1.14 신설):
```
A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with MINCED GARLIC (다진 마늘) scattered on top, top-down view, cutting RESULT state (the garlic
has just been finely minced — many tiny irregular fine bits scattered across the board surface,
NOT cutting in progress). The signature ingredient mapping = 마늘 (Korean garlic, the fastest BPM
~140 cut style, used in F-12 galbi marinade and F-09 kimchi jjigae).

On the cutting board surface: a generous pile of FINELY MINCED GARLIC bits — many small irregular
yellowish-white granules (each tiny bit approximately 1-3mm, irregular angular shapes since they
are finely chopped, NOT round perfect discs, NOT large chunks). The minced garlic is scattered in
a loose cluster covering roughly the center-right portion of the board, with a few bits scattered
slightly wider to give a natural "just been minced" appearance. Optional: 1-2 unminced whole garlic
cloves (small rounded teardrop shape, off-white color) sit on the board as visual anchors for
"before mince" context — these are partial reference shapes, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board, blade flat against the board
surface, handle pointing toward the lower-left corner, slightly angled (the knife is set down
after mincing, NOT in motion mid-chop). The knife blade has subtle hints of garlic juice sheen on
its edge (very minimal accent).

[STYLE_SUFFIX_CUT]

Important also: this is the MINCE (다지기) cut style result — the garlic must read as MANY TINY
FINE IRREGULAR BITS (1-3mm each, finely chopped texture), NOT round disc-shaped slices, NOT large
chunks, NOT julienne strips, NOT cube dice. The signature ingredient is Korean garlic (마늘) —
small yellowish-white minced granules scattered across the board as the hero element. This is the
cutting RESULT state (just finished mincing), NOT cutting action mid-chop. The mapping is mince
(다지기) = fastest BPM ~140 for ADR-005 Stage 2A rhythm tap — visually identifiable as the most
granular/fine cut texture among the 6 cut styles.
```

**Reroll 트리거**:
- 큰 chunks로 추론: "이 이미지를 다시 그려줘. garlic을 finely minced (1-3mm tiny irregular bits)로, NOT chunks, NOT slices."
- disc/slice 추론: "이 이미지를 다시 그려줘. round disc slices 폐기 → irregular fine bits (다지기, finely chopped texture)."
- 마늘 색 누수: "이 이미지를 다시 그려줘. garlic을 yellowish-white으로 (Korean 마늘 색), NOT pure white, NOT brown."

#### 5.5.3 CUT-02 — Julienne (채썰기, 당근)

**의도**: F-08 비빔밥 (radial 채소 section) / F-11 잡채 (당면 mixed-in 채소 strip). 한식 julienne 시그니처.

**식별 핵심 시각 요소**:
- 당근 julienned strips — 주황 (#FF9933) thin elongated parallel matchstick (각 4-6cm long × 2-3mm wide × 2-3mm thick, ~15-20 strips)
- 도마 center-right portion에 relaxed natural pile (slightly overlapping, NOT perfectly stacked geometric)
- optional 1-2 whole carrots (cylindrical orange + green leafy top) — LEFT side
- 칼은 LEFT side, blade flat, handle lower-left corner

**Prompt** (v1.14 신설):
```
A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with JULIENNED CARROT (채썬 당근) on top, top-down view, cutting RESULT state. The signature
ingredient mapping = 당근 (Korean julienned carrot, used in F-08 bibimbap and F-11 japchae as the
classic julienne signature vegetable).

On the cutting board surface: a generous pile of JULIENNED CARROT STRIPS — many thin elongated
orange (#FF9933 single fill, bright vibrant saturated) strips, each strip approximately 4-6cm long
× 2-3mm wide × 2-3mm thick (thin matchstick-like elongated strips, all parallel-ish aligned and
slightly overlapping in a relaxed natural pile, NOT perfectly stacked geometric, NOT cube cubes,
NOT round discs). The julienne strips are arranged in the center-right portion of the board,
suggesting a "just been julienned" pile. Approximately 15-20 visible strips. Optional: 1-2 unsliced
whole carrots (cylindrical orange shape with a green leafy top) sit on the LEFT side of the board
as visual reference for "before julienne" — these are partial anchors, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board next to the whole carrots, blade
flat against the board surface, handle pointing toward the lower-left corner (the knife is set
down after julienning, NOT in motion).

[STYLE_SUFFIX_CUT]

Important also: this is the JULIENNE (채썰기) cut style result — the carrots must read as MANY
THIN ELONGATED MATCHSTICK STRIPS (4-6cm long × 2-3mm wide × 2-3mm thick, thin elongated parallel
shapes), NOT mince bits, NOT round disc slices, NOT cube dice, NOT large chunks. The signature
ingredient is Korean julienned carrot (당근 채) — bright orange elongated thin strips as the hero
element. This is the cutting RESULT state, NOT cutting action mid-slice. The mapping is julienne
(채썰기) for ADR-005 Stage 2A rhythm tap — visually identifiable as the thinnest elongated strip
shape among the 6 cut styles (NOT short oval like diagonal slice, NOT thin round like sliced
rounds).
```

**Reroll 트리거**:
- 당근 두꺼움 (cube로 추론): "이 이미지를 다시 그려줘. carrots을 THIN matchstick strips (2-3mm wide × 2-3mm thick × 4-6cm long)으로, NOT cube cubes, NOT thick chunks."
- 길이 짧음: "이 이미지를 다시 그려줘. 채 strips를 4-6cm 길이의 elongated parallel matchsticks으로."
- 다른 채소 (양파/시금치)로 추론: "이 이미지를 다시 그려줘. 당근(carrot, orange #FF9933)만 — 다른 채소 완전 제거."

#### 5.5.4 CUT-03 — Diagonal Slice (어슷썰기, 어묵+대파)

**의도**: F-04 떡볶이 어묵 + 모든 국물의 어슷썬 대파. 한식 diagonal slice 시그니처.

**식별 핵심 시각 요소**:
- 어묵 diagonal oval slices — 4-5 flat elongated oval (각 5-7cm long diagonal × 2-3cm wide, light golden-brown `#C8923C`, slightly translucent)
- 대파 diagonal oval slices — 6-8 smaller oval (각 3-4cm long diagonal × 1-1.5cm wide, white base fading to green tip)
- 두 ingredient 모두 명확한 diagonal angle (elongated oval shape, NOT round perfect circle which would be 통썰기)
- optional whole fish cake stick + whole scallion — LEFT side
- 칼은 LEFT side, blade flat, handle lower-left corner

**Prompt** (v1.14 신설):
```
A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with DIAGONAL-SLICED FISHCAKE AND SCALLION (어슷썬 어묵 + 대파) on top, top-down view, cutting
RESULT state. The signature ingredient mapping = 어묵 + 대파 (Korean diagonal-sliced fish cake and
scallion, used in F-04 tteokbokki and all Korean soup/stew dishes).

On the cutting board surface: a mix of DIAGONAL OVAL FISH CAKE SLICES and DIAGONAL OVAL SCALLION
SLICES. The fish cake (어묵) slices are flat oval-elongated shapes (each approximately 5-7cm long
diagonal × 2-3cm wide, light golden-brown #C8923C single fill, slightly translucent appearance,
4-5 slices arranged in a relaxed overlapping pile in the center-right of the board). The scallion
(대파) diagonal slices are smaller oval shapes (each approximately 3-4cm long diagonal × 1-1.5cm
wide, white base fading to bright green tip, 6-8 slices scattered around the fish cake slices).

Both ingredient types are cut at a clear diagonal angle (어슷썰기 = the knife cuts the cylindrical
ingredient at a slanted angle, producing elongated OVAL slices that are visibly longer in one
dimension than the cross-section would be — the elongated oval shape IS the diagonal slice
signature, NOT round perfect circles which would be 통썰기). Optional: 1 unsliced whole fish cake
stick (cylindrical light golden shape, ~10cm long) and 1 unsliced whole scallion (cylindrical
white-to-green shape, ~12cm long) sit on the LEFT side of the board as visual reference for
"before diagonal slice".

The kitchen knife rests on the LEFT side of the cutting board, blade flat against the board
surface, handle pointing toward the lower-left corner (the knife is set down after slicing, NOT
in motion).

[STYLE_SUFFIX_CUT]

Important also: this is the DIAGONAL SLICE (어슷썰기) cut style result — the slices must read as
ELONGATED OVAL SHAPES (longer in one dimension than the natural cross-section diameter, the
diagonal cut signature), NOT round perfect circles (those would be 통썰기), NOT thin strips (those
would be 채썰기), NOT cube dice. The signature ingredients are Korean fish cake (어묵) AND Korean
scallion (대파) — both diagonal-sliced as the hero elements. The elongated oval shape is the
critical visual identifier — the more elongated the oval, the steeper the diagonal angle. This is
the cutting RESULT state, NOT cutting action mid-slice. The mapping is diagonal slice (어슷썰기)
for ADR-005 Stage 2A rhythm tap — visually distinct from whole slice (round) and sliced rounds
(thin round).
```

**Reroll 트리거**:
- 둥근 disc로 추론 (통썰기 누수): "이 이미지를 다시 그려줘. 어슷썰기 = elongated OVAL shape (longer in one dimension), NOT round perfect circles. 칼이 cylindrical ingredient를 slanted angle로 cut."
- 어묵 색 누수: "이 이미지를 다시 그려줘. 어묵을 light golden-brown #C8923C로, NOT white, NOT pink-orange."
- 대파 색 누수: "이 이미지를 다시 그려줘. 대파 slices를 white base fading to bright green tip으로."

#### 5.5.5 CUT-04 — Whole Slice (통썰기, 김밥 cylinder 단면, BPM 70 가장 느림)

**의도**: F-03 김밥 serving form (cylinder 단면). BPM 70 가장 느린 cut style — 가장 stable round disc.

**식별 핵심 시각 요소**:
- 김밥 round disc slices — 4-5 perfect 둥근 disc (각 ~3cm 지름 × 1.5-2cm thick)
- 각 disc는 김밥 cross-section: 검정 김 outer ring + 흰 short-grain rice + colorful cross-section center (yellow danmuji + orange carrot + green spinach + red ham + yellow egg)
- center-right portion에 relaxed row arrangement, slightly overlapping, all round-face-up
- optional whole uncut kimbap cylinder (~12-15cm) — LEFT side
- 깨 sprinkle on top
- 칼은 LEFT side, blade flat, handle lower-left corner

**Prompt** (v1.14 신설):
```
A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with WHOLE-SLICED KIMBAP DISCS (통썬 김밥) on top, top-down view, cutting RESULT state. The
signature ingredient mapping = 김밥 cylinder 단면 (Korean kimbap whole slices, used in F-03 kimbap
service form, the slowest BPM ~70 cut style — the most stable round disc shape).

On the cutting board surface: 4-5 ROUND DISC KIMBAP SLICES arranged in a relaxed row across the
center-right portion of the board. Each slice is a perfect round disc (approximately 3cm diameter
× 1.5-2cm thick, the classic Korean kimbap cylindrical cross-section). Each disc shows the kimbap
signature cross-section: a black seaweed (gim) outer ring + white rice with FINE small grains
underneath + a colorful cross-section center showing distinct ingredient blocks: yellow pickled
radish (danmuji), orange carrot, green spinach or cucumber, red ham or beef strips, and yellow
egg strips. The slices are slightly overlapping in the relaxed row, all oriented round-face-up to
show the cross-section. A few sesame seed dots are sprinkled on top.

Optional: 1 unsliced whole kimbap cylinder (uncut roll, ~12-15cm long cylinder with black gim
exterior) sits on the LEFT side of the board as visual reference for "before whole slice" — this
is a partial anchor, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board next to the unsliced kimbap roll,
blade flat against the board surface, handle pointing toward the lower-left corner (the knife is
set down after slicing, NOT in motion).

[STYLE_SUFFIX_CUT]

Important also: this is the WHOLE SLICE (통썰기) cut style result — the kimbap slices must read
as PERFECT ROUND DISCS (cylindrical cross-sections, the round-face-up disc shape, ~3cm diameter ×
1.5-2cm thick), NOT elongated oval (those would be 어슷썰기 diagonal slice), NOT thin matchstick
strips (those would be 채썰기), NOT mince bits, NOT cube dice. The signature ingredient is Korean
kimbap (김밥) whole slices — the round disc shape with visible colorful cross-section is the hero.
The whole slice (통썰기) maps to the slowest BPM ~70 cut style for ADR-005 Stage 2A rhythm tap —
the most stable easiest cut shape, visually identifiable as the largest most regular round disc
among the 6 cut styles. NOT Japanese maki sushi (those use raw fish + tight compressed rice + thin
seaweed) — this is Korean kimbap (thicker disc, cooked vegetables, matte gim).
```

**Reroll 트리거**:
- Japanese maki sushi 누수: "이 이미지를 다시 그려줘. Korean 김밥으로 명확히 — thicker disc + cooked vegetables (danmuji yellow + carrot orange + spinach green + ham red) + matte gim. NOT Japanese maki sushi, NOT raw fish."
- elongated oval로 추론 (어슷썰기 누수): "이 이미지를 다시 그려줘. 통썰기 = perfect ROUND DISC (round-face-up cylindrical cross-section), NOT elongated oval."

#### 5.5.6 CUT-05 — Sliced Thin Rounds (송송썰기, 대파)

**의도**: F-12 갈비구이 hero garnish + 모든 한식 finishing 가니쉬. 송송 sliced 대파 시그니처.

**식별 핵심 시각 요소**:
- 대파 thin round slices — 20-30 small bright green disc (각 1-1.5cm 지름 × 1-3mm thick)
- 각 slice는 scallion ring pattern: 작은 흰 center circle (scallion 줄기 hollow cross-section) + bright green outer ring
- center-right portion에 generous loose pile scattered ("just been 송송 sliced" 인상)
- optional 1-2 whole scallion stems (white-to-green) — LEFT side
- 칼은 LEFT side, blade flat, handle lower-left corner

**Tier comparison**: 통썰기 (CUT-04)와 비교 시 SAME round shape이지만 distinctly THINNER + SMALLER. rapid repeated thin slicing.

**Prompt** (v1.14 신설):
```
A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with SLICED THIN ROUND SCALLIONS (송송 썬 대파) scattered on top, top-down view, cutting RESULT
state. The signature ingredient mapping = 대파 (Korean scallion / spring onion thinly sliced into
small round discs, used in F-12 galbi-gui as the hero garnish and across all Korean dishes as the
finishing garnish).

On the cutting board surface: many SMALL THIN ROUND SCALLION SLICES — bright green small disc
shapes (each approximately 1-1.5cm diameter × 1-3mm thick, very thin round discs from cross-cutting
the cylindrical scallion stem). Each slice shows the characteristic scallion ring pattern: a small
white circle in the center (the hollow scallion stem cross-section interior) surrounded by a bright
green ring (the outer scallion stem wall). Approximately 20-30 visible thin round slices scattered
across the center-right portion of the board in a generous loose pile, suggesting a "just been
송송-sliced" abundant garnish ready for sprinkling.

Optional: 1-2 unsliced whole scallion stems (cylindrical white-base-to-green-tip shape, ~12cm
long) sit on the LEFT side of the board as visual reference for "before sliced rounds" — these
are partial anchors, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board next to the unsliced scallions,
blade flat against the board surface, handle pointing toward the lower-left corner (the knife is
set down after slicing, NOT in motion).

[STYLE_SUFFIX_CUT]

Important also: this is the SLICED THIN ROUNDS (송송썰기) cut style result — the scallion slices
must read as MANY SMALL THIN ROUND DISCS (1-1.5cm diameter × 1-3mm thick, very thin round shape
with the characteristic small white center ring + bright green outer ring), NOT elongated oval
(those would be 어슷썰기 diagonal slice), NOT thicker large round disc (those would be 통썰기
whole slice — 송송 is distinctly thinner and smaller), NOT thin matchstick strips (those would be
채썰기), NOT mince bits, NOT cube dice. The signature ingredient is Korean scallion (대파) 송송
sliced — the small thin bright green round discs scattered abundantly are the hero. Compared to
통썰기 (large stable round disc), 송송썰기 is the SAME round shape but distinctly THINNER and
SMALLER (rapid repeated thin slicing). The mapping is sliced rounds (송송썰기) for ADR-005 Stage
2A rhythm tap.
```

**Reroll 트리거**:
- 통썰기와 동일 크기로 추론: "이 이미지를 다시 그려줘. 송송썰기 = THIN SMALL round discs (1-1.5cm 지름 × 1-3mm 두께)로, 통썰기 (3cm 지름 × 1.5-2cm thick)보다 distinctly thinner + smaller."
- diagonal oval로 추론: "이 이미지를 다시 그려줘. perfect round disc (NOT oval) — straight perpendicular cut across cylindrical scallion."
- scallion ring pattern 누락: "이 이미지를 다시 그려줘. 각 disc에 small white center ring + bright green outer ring (scallion 줄기 cross-section signature) 명확."

#### 5.5.7 CUT-06 — Cube Dice (깍둑썰기, 두부)

**의도**: F-09 김치찌개 squarish 흰 두부 블록 + F-10 순두부 contrast. 한식 깍둑썰기 두부 시그니처.

**식별 핵심 시각 요소**:
- 두부 cubes — 8-12 small equal-sided 흰 cube (각 2-2.5cm × 2-2.5cm × 2-2.5cm, `#FAFAFA` + very slight cool sage cel shading on one corner)
- clean geometric square edges + slim outline 2-3px + top-face highlight + side-face slight shadow (3D cube volume hint in top-down view)
- center-right portion에 relaxed loose cluster (not perfect grid, slight natural overlap, "just been cubed")
- optional 1 uncut tofu block (larger rectangular slab ~10cm × 6cm × 3cm) — LEFT side
- 칼은 LEFT side, blade flat, handle lower-left corner

**Prompt** (v1.14 신설):
```
A modern mobile casual game asset illustration of a Korean kitchen cutting board (도마)
with CUBE-DICED TOFU (깍둑 썬 두부) on top, top-down view, cutting RESULT state. The signature
ingredient mapping = 두부 (Korean firm tofu cubed, used in F-09 kimchi jjigae as the signature
squarish white tofu blocks).

On the cutting board surface: 8-12 SMALL TOFU CUBES — each cube approximately 2-2.5cm × 2-2.5cm ×
2-2.5cm (roughly equal-sided cubes, clean white (#FAFAFA single fill with very slight cool sage
cel shading on one corner) with bold outline 2-3px and clean geometric square edges). The cubes
are arranged in a relaxed loose cluster (not perfect grid, slight natural overlap, suggesting
"just been cubed"). Approximately 8-12 visible cubes scattered across the center-right portion of
the board, all clearly readable as 3D cube shapes (slight top-face highlight + side-face slight
shadow indicates the cube volume even in top-down view).

Optional: 1 uncut tofu block (larger rectangular slab, ~10cm × 6cm × 3cm, same white color) sits
on the LEFT side of the board as visual reference for "before cube dice" — this is a partial
anchor, NOT the hero element.

The kitchen knife rests on the LEFT side of the cutting board next to the uncut tofu block, blade
flat against the board surface, handle pointing toward the lower-left corner (the knife is set
down after dicing, NOT in motion).

[STYLE_SUFFIX_CUT]

Important also: this is the CUBE DICE (깍둑썰기) cut style result — the tofu must read as MANY
SMALL EQUAL-SIDED CUBES (2-2.5cm × 2-2.5cm × 2-2.5cm, clearly cubic 3D shapes with visible top
and side faces), NOT thin slices, NOT mince bits, NOT elongated strips, NOT round discs, NOT
oval diagonal slices. The signature ingredient is Korean firm tofu (두부) — white squarish cube
blocks as the hero. The cube shape with visible 3D volume (top face + side face shading hint) is
the critical visual identifier for 깍둑썰기. This is the cutting RESULT state, NOT cutting action.
The mapping is cube dice (깍둑썰기) for ADR-005 Stage 2A rhythm tap — visually identifiable as
the most volumetric cube shape among the 6 cut styles. NOT Chinese mapo tofu (uses firm tofu in
brown Sichuan sauce on a flat plate — different context), this is the raw cubed tofu prep state
on the cutting board.
```

**Reroll 트리거**:
- 두부 너무 얇음 (slice로 추론): "이 이미지를 다시 그려줘. tofu를 small equal-sided CUBES (2-2.5cm × 2-2.5cm × 2-2.5cm, 3D cube volume)로, NOT thin slices, NOT flat squares."
- Chinese mapo tofu 누수 (sauce 추가): "이 이미지를 다시 그려줘. raw cubed tofu prep state (도마 위)만 — sauce/broth 완전 제거. clean white tofu cubes on bare cutting board."
- 3D volume 누락 (flat square로 추론): "이 이미지를 다시 그려줘. tofu cube의 top face highlight + side face slight shadow로 3D volume 인상 명확화 (top-down view에서도 cube 모양 인식)."

#### 5.5.8 Cut anchor 7장 cross-호환 운영

- **Stage 1 (CUT-00 anchor seed lock)**: CUT-00 cutting_board base 1차 생성 → 적합 시 §0 표 `CUT_ANCHOR_FILE` 기록.
- **Stage 2 (CUT-01~06 cut style 6종 follow-up)**: 각 prompt에 `CUT_ANCHOR_FILE` reference upload + 본문 prompt + "이 reference cutting board + knife와 같은 wood color, blade silhouette, outline 두께, Cool Sage bg 톤으로 일관성 유지" 명시.
- **세션 분기 권장**: cut anchor 7장 한 세션 권장 (음식/환경/캐릭터 anchor와 다른 새 세션).
- **subject anchor 단어 공통 부분**: "modern mobile casual game asset illustration of a Korean kitchen cutting board (도마) with [cut state], top-down view, cutting RESULT state"

#### 5.5.9 Cut anchor 7장 ChatGPT 약점 risk top 3 (G6 세분화)

| Rank | Cut style | 누수 risk | default % | 회피 전략 |
|------|-----------|----------|-----------|----------|
| 1 | CUT-04 통썰기 | Japanese maki sushi (김밥 cylinder 단면 → maki 추론) | ~50% | matte gim + cooked vegetables (danmuji yellow + carrot + spinach + ham) + Korean short-grain rice 명시 |
| 2 | CUT-06 깍둑썰기 | Chinese mapo tofu (sauce 추가) | ~40% | raw cubed tofu prep state on bare cutting board, NO sauce/broth 명시 |
| 3 | CUT-00/01-06 | Japanese kitchen knife (santoku/deba single-bevel) | ~30% | modern Korean kitchen knife (식칼) — slim rectangular blade + warm brown wood handle, NOT santoku asymmetric blade, NOT kanji engraving |

#### 5.5.10 ingredient cut variation (v1.15 → §5.6 ingredient whole 12장 신설로 supersede)

> v1.14에서는 "M2 sprint placeholder"였으나 v1.15에서 **M1 후반 2번째 sprint로 격상** — §5.5.0 음식 12 × hero ingredient 매핑 표 + §5.6 ingredient whole 12장 prompt set 신설. cut된 상태(CUT-01~06)는 재사용, whole 12장만 추가 생성.

### 5.6 음식 12 × hero ingredient whole anchor 12장 (v1.15 신설, M1 후반 2번째 sprint — full prompts)

> **ADR-005 Stage 2A "before"-cut pair**: §5.5 cut anchor 7장이 "after cut" state라면, §5.6 ingredient whole 12장은 각 음식의 hero ingredient "before cut" state. 게임 미니게임에서 whole→cut 2-frame transition으로 사용.
> **범위**: 음식 12 × hero ingredient × whole state = **총 12장**. cut된 결과 12장은 §5.5 cut anchor 7장 재사용 (한 cut style이 여러 음식에 매핑되므로 12 ≠ 7).
> **F-06 / F-10 예외**: 모짜렐라 / soft tofu는 cut 없는 형태로 게임에서 사용 — whole anchor만 생성, 대응 cut anchor 없음.
> **F-08 / F-11 중복 가능성**: 둘 다 당근 hero, game-designer foods CSV `prep_*` 후속 확정 시 F-11을 F-08 anchor 재사용으로 결정하면 ING-11 archive. v1.15는 일단 12장 모두 별도 prompt + slight visual variation (F-11 carrot은 slight diagonal angle + larger leafy crown)로 생성.
> **공유 anchor**: §5.5 CUT-00 cutting_board base가 동일 anchor seed로 작동 — ING-01~12 prompt에 CUT-00 image reference upload + "같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 outline 두께로 일관성 유지" follow-up.
> **도구**: ChatGPT (GPT-4o image / gpt-image-1 medium). prompt-only generation. STYLE_SUFFIX_INGREDIENT는 cut anchor와 동일 base + INGREDIENT PLACEMENT 절 추가 (driver script `tools/gen_ingredient_anchors_m1.py` `STYLE_SUFFIX_INGREDIENT` 상수가 single source of truth, 본 문서는 요약만).

#### 5.6.0 prompt body single source of truth = driver script

> ingredient whole 12장 본문 prompt는 `tools/gen_ingredient_anchors_m1.py`의 `INGREDIENTS` list 12개 항목 inline body가 single source. 본 문서 §5.6.1~§5.6.12는 (a) hero ingredient + cut style 매핑 / (b) 식별 핵심 시각 요소 / (c) reroll trigger / (d) DALL-E 약점 회피 노트만 요약. 본문 prompt 변경 시 driver script body를 수정 (본 문서가 아닌 driver script가 ground truth) + 본 문서 요약을 sync.

#### 5.6.1 ING-01 — F-01 Ramyeon hero / 대파 spring onion whole (pair = CUT-05 송송썰기)

**식별 핵심 시각 요소**:
- single whole green spring onion stalk, ~18-22cm long × 1-1.5cm thick at white root end
- white root end (~6-8cm, off-white #F5F5E8 + 2-3 wispy white root strands at tip) + bright green leaf end (~8-10cm, #52C160)
- center transition zone (~3-4cm pale yellow-green)
- knife on LEFT side static, intact uncut stalk on center-right

**Reroll trigger 핵심**: cut된 형태로 추론 / 부추 (garlic chives, 얇은 flat leaves)로 추론 / leek (overlapping flat layers)로 추론 / Japanese negi 누수.

#### 5.6.2 ING-02 — F-02 Janchi-guksu hero / 소면 somen whole (no cut, sprinkle/serve) — v1.17 mvp v2.2 신규

**식별 핵심 시각 요소** (v1.17 신규, peanut R1 + brown_sugar R2 모두 deprecated archive):
- single small BUNDLE of dry SOMEN-STYLE white wheat noodles (~18-22cm × 4-5cm bundle, single-serving portion)
- clean off-white #F5F0E0 to #FAFAFA color (pale warm-white wheat tone, NOT pure bright white, NOT yellow, NOT brown)
- 15-25 fine parallel slim strands (~1-2mm per strand) clearly visible running lengthwise
- PLAIN white or pale cream paper/string BAND tied at center (~2cm wide, solid color block placeholder, NO printed text)
- two ends show cut noodle strand tips fanning slightly (showing thickness ~1-2mm)
- optional 2-3 stray loose strands beside bundle as freshness accent
- 칼 LEFT side static (somen 자체는 cut 없음, knife = cross-asset 19+ anchor consistency convention)

**Reroll trigger 핵심**:
- Japanese pink-and-white decorative paper band 누수 (Korean homestyle plain band 명시) — 가장 critical
- 노란 Chinese egg noodles 추론 (소면은 pale off-white wheat, NOT yellow)
- Italian spaghetti 추론 (소면은 더 얇음 ~1-2mm, spaghetti는 ~2-3mm rigid)
- 일본 udon thick chunky 추론 (소면은 thin delicate)
- Korean ramyeon curly yellow egg noodles 추론 (소면은 straight thin white wheat)
- cooked floppy 또는 broken pieces로 cut/cooked 상태 누수 (이 anchor는 dry bundle 전 상태)

**deprecation 기록**:
- **peanut whole (R1)** = ING-02 v1 호떡 hero 보조 토핑 (peanut 6-8 whole shells) → R2 deprecated 2026-05-28 (사용자 명시 흑설탕 dominant filling으로 교체)
- **brown_sugar whole (R2)** = ING-02 v2 호떡 hero filling (흑설탕 mound 5-6cm + cinnamon sticks) → v1.17 deprecated 2026-05-30 (mvp v2.2 trigger, 호떡 → 잔치국수 음식 자체 교체)
- **somen whole (v1.17)** = ING-02 v3 잔치국수 hero noodle bundle. 현재 settle 형태.

#### 5.6.3 ING-03 — F-03 Kimbap hero / 단무지 pickled radish whole (pair = CUT-02 채썰기)

**식별 핵심 시각 요소**:
- single whole danmuji cylinder, ~12-15cm long × 3-3.5cm diameter, fat cylinder shape with rounded end caps
- VIBRANT YELLOW #F5D43E single fill (signature pickled radish bright yellow, NOT pale beige NOT dull mustard)
- glossy slightly translucent surface + ONE specular highlight along top
- end caps slightly more pale #F5E58A

**Reroll trigger 핵심**: 신선 백색 daikon 누수 (이건 pickled yellow form) / 바나나 누수 (banana는 curved-tapered + stem, danmuji는 flat end caps) / pickle gherkin 누수 (bumpy green) / 당근으로 추론 / julienne strips로 cut 상태 누수.

#### 5.6.4 ING-04 — F-04 Tteokbokki hero / 어묵 fish cake sheet whole (pair = CUT-03 어슷썰기)

**식별 핵심 시각 요소**:
- single whole flat rectangular fish cake sheet, ~14-18cm long × 6-8cm wide × 1-1.5cm thick (FLAT slab, NOT cylindrical, NOT stick)
- light golden-brown #C8923C single fill, slightly translucent
- mostly smooth surface (1-2 subtle slim shading lines suggesting fish paste grain, NO heavy noise)
- slightly rounded corners (natural manufactured fish cake shape)

**Reroll trigger 핵심**: Japanese naruto (pink spiral cross-section) 누수 / Japanese chikuwa (hollow tube cylinder) 누수 / 소시지 (cylindrical pink/red) 누수 / 토스트 빵 누수 / diagonal slices cut 상태 누수.

#### 5.6.5 ING-05 — F-05 Kimchi Fried Rice hero / 김치 napa cabbage leaf whole (pair = CUT-01 다지기)

**식별 핵심 시각 요소**:
- single whole napa cabbage kimchi leaf loosely folded, ~12-15cm long × 7-9cm wide when folded
- thick WHITE-PALE rib at one end (~3-4cm wide, off-white #F0EBD8)
- VIBRANT GOCHU RED kimchi seasoning paste #E84540 smeared across the green leaf surface (light green base #C8D88A)
- subtle cabbage leaf wrinkle/fold lines + ONE specular highlight on red-coated surface

**Reroll trigger 핵심**: whole kimchi jar / bulk 누수 (single leaf 필요) / Chinese pickled cabbage 누수 / Japanese tsukemono 누수 / chopped bits cut 상태 누수.

#### 5.6.6 ING-06 — F-06 Korean Corn Dog hero / 모짜렐라 cheese stick whole (no cut, whole)

**식별 핵심 시각 요소**:
- single whole mozzarella cheese stick, ~10-12cm long × 2-2.5cm diameter, fat cylinder with flat end caps
- CLEAN MILKY WHITE #FAFAFA single fill + very subtle cool sage shading underside
- smooth slightly glossy surface + ONE specular highlight
- creamier end caps #F5F0E8

**Reroll trigger 핵심**: 치즈 누수 (cheddar yellow/orange, mozzarella는 milky white) / 페타 (crumbly) / 소시지 (pink/red) / 두부 (matte sharp square edges, mozzarella는 glossy cylindrical) / sliced rounds cut 상태 누수 (이 anchor는 cut 없음).

#### 5.6.7 ING-07 — F-07 Haemul Pajeon hero / 대파 daepa large scallion whole (pair = CUT-03 어슷썰기)

**식별 핵심 시각 요소**:
- TWO whole large Korean daepa scallion stalks side by side (THICKER + LONGER than F-01 ING-01 spring onion)
- 각 stalk ~22-26cm long × 2-2.5cm thick at white root end
- white root end (~8-10cm) + transition (~4-5cm) + bright green leaf end (~10-12cm)
- two stalks aligned parallel, slight overlap at center, knife on LEFT side

**Reroll trigger 핵심**: F-01 spring onion 변종으로 추론 (daepa는 thicker/longer variety) / 부추 누수 / leek 누수 / Japanese negi 누수 / diagonal slices cut 상태 누수.

#### 5.6.8 ING-08 — F-08 Bibimbap hero / 당근 carrot whole (pair = CUT-02 채썰기)

**식별 핵심 시각 요소**:
- single whole fresh carrot, ~15-18cm long, tapered cone (3-3.5cm diameter top → 0.5cm pointed tip)
- VIBRANT ORANGE #FF9933 single fill
- small green leafy crown at top (3-5 short leaf stubs, ~2-3cm, vivid green #52C160)
- 2-3 subtle slim cel shading horizontal ridge lines (carrot ring texture) + ONE specular highlight

**Reroll trigger 핵심**: baby carrot 누수 (tiny round-ended) / sweet potato (fatter dark red-purple) / parsnip (cream-white) 누수 / julienne strips cut 상태 누수.

#### 5.6.9 ING-09 — F-09 Bulgogi hero / 얇은 raw 소고기 thin-sliced marbled beef whole (no cut, marinade prep state) — v1.17 mvp v2.2 신규

**식별 핵심 시각 요소** (v1.17 신규, firm tofu R1 deprecated archive):
- STACK or FANNED arrangement of 5-7 THIN sliced raw marbled beef sheets
- 각 slice ~8-12cm × 5-7cm × 2-3mm THIN paper-thin (Korean bulgogi-cut butcher pre-sliced thickness)
- 색: PINK-RED RAW BEEF base #C44545 to #B82F2F (deep pink-red raw meat tone, NOT brown cooked, NOT bright red fresh blood, NOT pale pink)
- VISIBLE WHITE MARBLED FAT VEINS (pale cream-white #F0E8D8) scattered ~3-5 organic irregular marbling lines per slice (signature marbled sirloin)
- slight diagonal FAN or STACK at slight overlap (top 2-3 slices slightly offset, showing cross-section edges underneath like a slightly fanned deck of cards)
- ~2-3mm THIN slice cross-section visible on slightly-visible side
- subtle slim cel shading on slice edges + ONE specular highlight along top slice (fresh moist raw beef sheen)
- 칼 LEFT side static (beef already pre-sliced at butcher; knife = cross-asset 19+ anchor consistency convention, game prep mechanic = 양념재우기 marinade application not cutting)

**F-12 갈비구이 차별화 CRITICAL** (ING-09 ≠ ING-12 마늘과는 ingredient 별도; 단 F-12 plated meat과 비교):
- NO BONE-IN LA CUT — bulgogi beef is BONELESS thin-sliced sirloin, ABSOLUTELY NO visible white rib bone, NO bone cross-section discs, NO single long bone alongside
- NOT GRILLED OR COOKED — bulgogi ingredient is RAW pink-red before marinade state, NOT brown cooked grilled (cooked state = F-12 plated), NOT marinade-coated brown
- NOT THICK STEAK SLAB — bulgogi beef is THIN paper-thin slices ~2-3mm, NOT a thick 1cm+ slab, NOT a butcher's whole roast

**Reroll trigger 핵심**:
- Japanese wagyu A5 extreme marbling 누수 (wagyu는 intricate marbling + premium plating, bulgogi는 subtle natural marbling on kitchen board)
- Japanese sukiyaki beef on decorative platter + raw egg dipping bowl 누수 (이 anchor는 단순 도마 prep state, NOT plated)
- bacon parallel striped 누수 (bacon은 alternating white-pink bands, 이 anchor는 scattered marbling)
- salami / pepperoni cured uniform 누수 (이 anchor는 fresh raw marbled beef)
- 삼겹살 thick alternating layered stripes 누수 (이 anchor는 marbled sirloin not pork belly)
- F-12 갈비 bone visible 누수 CRITICAL (bone 추론되면 즉시 FAIL)
- cooked brown 추론 (이 anchor는 RAW pink-red, NOT cooked grilled state)
- firm tofu rectangular block 누수 (firm tofu R1 잔재, white block 추론되면 즉시 FAIL — 이건 pink-red marbled beef)

**deprecation 기록**:
- **firm_tofu_whole (R1)** = ING-09 v1 김치찌개 hero (clean matte white rectangular block 12×9×3.5cm) → v1.17 deprecated 2026-05-30 (mvp v2.2 trigger, 김치찌개 → 불고기 음식 자체 교체)
- **thin_beef_whole (v1.17)** = ING-09 v3 불고기 hero raw thin-sliced marbled beef stack/fan. 현재 settle 형태.

#### 5.6.10 ING-10 — F-10 Sundubu hero / 두부 soft tofu tube whole (no cut, broken curds)

**식별 핵심 시각 요소**:
- single whole soft tofu tube in clear plastic packaging, ~18-20cm long × 5-6cm diameter (cylindrical clear plastic sausage shape)
- visible CLOUD-LIKE WHITE soft tofu inside #FAFAFA (NOT firm sharp-edged like F-09)
- sealed plastic tube ends (small flat tabs, light cream/clear)
- optional small label band (solid color block placeholder, NO readable text)
- subtle cylindrical 3D volume shading + ONE specular highlight on glossy plastic

**Reroll trigger 핵심**: F-09 firm tofu rectangular block 누수 (이건 cylindrical tube package) / 소시지 (pink/red) / F-06 모짜렐라 (이건 fully white solid cylindrical, this는 clear plastic wrapping with white contents inside) / scooped curds cut 상태 누수 (이 anchor는 cut 없음).

#### 5.6.11 ING-11 — F-11 Japchae hero / 당근 carrot whole, F-08 variation (pair = CUT-02 채썰기)

**식별 핵심 시각 요소** (F-08과 동일 ingredient species, slight visual variation):
- single whole fresh carrot lying flat at SLIGHT DIAGONAL ANGLE (~15도, F-08의 perfectly horizontal과 구분)
- ~16-19cm long (F-08보다 slightly longer for variation)
- same VIBRANT ORANGE #FF9933
- slightly LARGER green leafy crown (4-6 leaf stubs, ~3-4cm, more leafy than F-08)
- 2-3 ridge lines + ONE specular highlight

**Reroll trigger 핵심**: F-08 ING-08과 완전 동일하게 추론 (slight variation 차별 안 됨) / baby carrot 누수 / sweet potato 누수 / julienne cut 상태 누수.

**game-designer 후속 확정 사안**: F-11이 F-08 anchor를 재사용하는 것으로 결정되면 ING-11 archive (assets-raw 파일은 보존, §0 anchor 표 status `재사용 결정 archived`로 갱신).

#### 5.6.12 ING-12 — F-12 Galbi-gui hero / 마늘 garlic cloves whole (pair = CUT-01 다지기)

**식별 핵심 시각 요소**:
- loose cluster 5-7 whole INDIVIDUAL PEELED garlic cloves (Korean 통마늘, NOT the whole bulb with all cloves attached)
- each clove ~2-3cm long × 1.5-2cm wide, classic teardrop / small almond-oval shape
- off-white to pale cream #F5F0E0 single fill with bold outline
- slightly pointed root end (small tan stem tip) + rounded broad end
- subtle 3D shading + ONE specular highlight per clove

**Reroll trigger 핵심**: whole garlic bulb (single round bulb with papery skin) 누수 — peeled individual clove state 명시 / 양파 (larger rounded layered structure) 누수 / 생강 ginger (knobbly irregular) 누수 / 샬롯 shallot (reddish-purple) 누수 / minced bits cut 상태 누수.

#### 5.6.13 ingredient whole 12장 cross-호환 운영

- **Stage 1 (anchor seed inheritance)**: CUT-00 cutting_board base가 anchor seed로 작동 (cut anchor 7장 + ingredient whole 12장 = 총 19장이 공유 anchor seed).
- **Stage 2 (12 ingredient follow-up)**: 각 prompt에 CUT-00 image reference upload + 본문 prompt + "이 reference cutting board + knife와 같은 wood color, blade silhouette, outline 두께, Cool Sage bg 톤으로 일관성 유지" 명시.
- **세션 분기 권장**: ingredient whole 12장 한 세션 권장 (cut anchor 7장 직후 같은 세션 안에서 follow-up 진행하면 cut anchor anchor seed 재활용 + 세션 context 일관성 강화 가능).
- **subject anchor 단어 공통 부분**: "modern mobile casual game asset illustration of a Korean kitchen cutting board (도마) with a WHOLE (uncut) [hero ingredient] placed on top, top-down view, ready-to-cut state"

#### 5.6.14 ingredient whole 12장 ChatGPT 약점 risk top 5 (G6 세분화)

| Rank | Ingredient | 누수 risk | default % | 회피 전략 |
|------|-----------|----------|-----------|----------|
| 1 | ING-03 단무지 | 신선 백색 daikon 또는 banana 누수 | ~50% | VIBRANT YELLOW #F5D43E + fat cylinder + flat end caps 명시, "pickled radish" 키워드 강제 |
| 2 | ING-04 어묵 | Japanese naruto (pink spiral) 또는 chikuwa (hollow tube) 누수 | ~50% | FLAT rectangular sheet + light golden-brown 명시, NOT cylindrical NOT pink spiral |
| 3 | ING-07 대파 daepa | F-01 spring onion 변종으로 추론 (thinner shorter) | ~40% | THICKER + LONGER variety (~22-26cm × 2-2.5cm) + 2 stalks 명시 |
| 4 | ING-06 모짜렐라 | cheddar yellow 또는 두부 (matte square) 누수 | ~40% | CLEAN MILKY WHITE + GLOSSY cylindrical + 명확한 cheese stick 카테고리 |
| 5 | ING-12 마늘 | whole bulb (papery skin) 또는 양파 누수 | ~35% | PEELED INDIVIDUAL CLOVES + teardrop shape + 5-7 cluster 명시 |

> 부차 risk (P2): ING-01 spring onion (Japanese negi 누수), ING-09 firm tofu (silken tofu 누수), ING-10 soft tofu (F-09 firm tofu rectangular 누수).

#### 5.6.15 driver script + 실행 명령

- 신규 driver: `tools/gen_ingredient_anchors_m1.py` (`tools/gen_cut_anchors_m1.py` template 기반)
- 첫 시도 (ING-01 test 권장, ~30초 / ~$0.05): `py tools/gen_ingredient_anchors_m1.py --only F-01`
- 12장 batch (~4-5분 / ~$0.50): `py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium`
- 출력 경로: `assets-raw/ingredient_anchors_m1/<food_id>_<ingredient_name>_v1.png` (예: `F-01_spring_onion_whole_v1.png`)
- F-11 carrot variation reroll (game-designer 재사용 결정 시 archive): `py tools/gen_ingredient_anchors_m1.py --only F-11`

#### 5.6.16 game-designer 후속 confirm 사안 (foods CSV `prep_*` 컬럼)

> 본 v1.15 음식 12 × hero ingredient × cut style 매핑은 art-director 임시 직관 매핑. game-designer가 foods CSV `prep_*` 컬럼으로 정식 매핑을 lock 시 (a) 일부 hero ingredient 변경 / (b) cut style 변경 가능. 검증 필요 사안:

| food | art-director 매핑 | game-designer 검증 사안 |
|------|------------------|----------------------|
| F-01 라면 | 대파 / CUT-05 송송 | 계란 또는 김 추가 hero 후보 검토 필요? |
| F-02 호떡 | 견과류 / CUT-01 다지기 | 견과류 외 흑설탕 filling도 prep mechanic 있는가? |
| F-03 김밥 | 단무지 / CUT-02 채썰기 | 단무지 외 5색 ingredient (계란/시금치/햄/당근) 중 어떤 게 Stage 2A hero? |
| F-04 떡볶이 | 어묵 / CUT-03 어슷썰기 | 떡 자체 prep (cylinder 송송 또는 통썰기)는 별도 mini-game인가? |
| F-05 김치볶음밥 | 김치 / CUT-01 다지기 | 김치 외 햄/계란도 prep mechanic 있는가? |
| F-06 콘도그 | 모짜렐라 / no cut | 소시지 자체 prep mechanic 있는가? 모짜렐라는 whole insertion만? |
| F-07 해물파전 | 대파 daepa / CUT-03 어슷썰기 | 새우/오징어/조개 해물 3종 중 어떤 게 Stage 2A hero? (대파가 dominant 시각이지만 해물도 후보) |
| F-08 비빔밥 | 당근 / CUT-02 채썰기 | 6 section 중 당근 외 시금치/콩나물/표고도 prep 후보? (당근이 가장 visible signature) |
| F-09 김치찌개 | 두부 firm / CUT-06 깍둑썰기 | 김치 다지기도 hero 후보? (두부는 두번째 mechanic으로 분할?) |
| F-10 순두부 | 두부 soft / no cut | 멸치/김치/계란 풀기 별도 mini-game 있는가? |
| F-11 잡채 | 당근 / CUT-02 (F-08 재사용) | F-08과 carrot anchor 재사용? 또는 시금치/표고가 잡채 hero? |
| F-12 갈비구이 | 마늘 / CUT-01 다지기 | 마늘 외 LA갈비 자체 prep (재우기/굽기)이 dominant mini-game인가? |

> game-designer 확정 후 art-director는 (a) 본 §5.5.0 매핑 표 갱신 / (b) §5.6 ingredient whole prompt 일부 reroll / (c) driver script INGREDIENTS list sync 작업 진행.

---

### 5.10 음식 12 × hero ingredient CUT 12장 (v1.19 신설, ADR-005 Stage 2B/2C "after"-cut pair)

> **v1.19 트리거 (2026-05-30)**: 사용자 verbatim "**손질하고 나서의 ingredient 이미지가 있어야 할 거 같고**" — ingredient whole 12장 (§5.6 ING-01~12)은 "before" state, cut anchor 7장 (§5.5 CUT-00~06)은 generic cut style 시연. 그 사이 누락된 asset = 각 음식의 hero ingredient를 그 음식 특유 cut 결과로 specific 시각화 (음식 시그니처 강화 + Stage 2B/2C 사용). **옵션 C 채택** (12장 specific 모두 생성, F-06 cheese는 ING-06과 동일 image이나 카탈로그 완전성 위해 별도 anchor).

#### 5.10.0 음식 × hero ingredient cut 매핑 표 (12장)

| ID | food | hero ingredient cut 결과 | pair cut style | 시각 핵심 (한 줄) |
|----|------|------------------------|---------------|----------------|
| ICUT-01 | F-01 Ramyeon | spring onion 송송 sliced thin rounds | CUT-05 송송썰기 | 20-30 small bright green disc rounds 1-1.5cm × 1-3mm + white center ring |
| ICUT-02 | F-02 Janchi-guksu | Korean zucchini 통썰기 round discs | CUT-04 통썰기 | 5-8 round green-rim + pale flesh discs 4-5cm × 3-5mm |
| ICUT-03 | F-03 Kimbap | danmuji 채썰기 yellow matchstick | CUT-02 채썰기 | 15-20 thin elongated bright yellow strips 8-10cm × 4-5mm |
| ICUT-04 | F-04 Tteokbokki | fish cake 어슷썰기 oval slices | CUT-03 어슷썰기 | 5-7 elongated golden-brown oval pieces 6-8cm × 3-4cm × 1-1.5cm |
| ICUT-05 | F-05 Kimchi Bokkeumbap | kimchi 다지기 minced bits | CUT-01 다지기 | scattered fine red-coated 5-10mm irregular bits |
| ICUT-06 | F-06 Corn Dog | mozzarella whole (no cut) | (no cut, same as ING-06) | single milky-white cylindrical cheese stick 10-12cm × 2-2.5cm |
| ICUT-07 | F-07 Haemul Pajeon | daepa 어슷썰기 large green ovals | CUT-03 어슷썰기 | 5-7 elongated DOMINANT bright green oval pieces 5-7cm × 1.5-2.5cm + hollow center ring |
| ICUT-08 | F-08 Bibimbap | carrot 채썰기 orange matchstick | CUT-02 채썰기 | 15-20 thin elongated bright orange strips 5-7cm × 2-3mm |
| ICUT-09 | F-09 Bulgogi | thin beef marinade coated brown glaze | (no cut, marinade prep) | 5-7 thin brown-glaze-coated marbled beef slices fanned + small marinade pool at base |
| ICUT-10 | F-10 Sundubu | soft tofu broken cloud-like curds | (no cut, broken curds) | mound of irregular fluffy white tofu fragments 2-4cm organic shapes |
| ICUT-11 | F-11 Japchae | carrot 채썰기 orange matchstick (F-08 variation) | CUT-02 채썰기 | 15-20 thin orange strips 6-8cm slight diagonal pile angle ~15도 |
| ICUT-12 | F-12 Galbi-gui | garlic 다지기 minced granules | CUT-01 다지기 | scattered fine yellowish-white 1-3mm granules |

#### 5.10.1 STYLE_SUFFIX_INGREDIENT_CUT (모든 ingredient cut 12장 공통 suffix)

> §5.6 STYLE_SUFFIX_INGREDIENT (whole)와 cross-asset 31+ anchor (cut 7 + whole 12 + cut 12) 일관성 통일 (도마 + 칼 LEFT static + Cool Sage bg + slim outline 2-3px + top-down). 본 suffix는 driver script `tools/gen_ingredient_cut_anchors_m1.py`의 `STYLE_SUFFIX_INGREDIENT_CUT` 상수 inline single source. **변경 시 driver script가 ground truth**. §5.6 whole suffix와 핵심 차이 = INGREDIENT PLACEMENT 절: whole "single intact whole + NO cut pieces" → cut "cut/prepared result cluster + NO whole intact ingredient (whole은 ING-XX whole anchor 영역)".

#### 5.10.2 ~ 5.10.13 — ingredient cut 12장 본문 prompt

> 12장 prompt body는 driver script `tools/gen_ingredient_cut_anchors_m1.py`의 `INGREDIENT_CUTS` list 12개 항목 inline body가 single source. 본 문서 §5.10.2~5.10.13는 (a) 음식 매핑 + (b) cut 결과 시각 핵심 + (c) reroll trigger 핵심만 명시. 본문 prompt 변경 시 driver script가 ground truth (gen_ingredient_anchors_m1.py와 동일 single-source 정책).

##### 5.10.2 ICUT-01 — F-01 Ramyeon cut / spring onion 송송 (pair = CUT-05)

**식별 핵심 시각 요소**:
- 20-30 small thin round spring onion discs scattered (relaxed cluster, just-finished-cutting)
- each disc ~1-1.5cm diameter × 1-3mm thick (very thin)
- bright vivid green ring outer #52C160 + small white inner ring (scallion hollow center)
- subtle 3D shading hint + ONE specular highlight per cluster
- optional: 1-2cm partial unsliced root tip remnant on LEFT as "before" reference

**Reroll trigger 핵심**: F-07 daepa 어슷썰기 large oval로 추론 (이건 small thin round) / 통썰기 large round disc 누수 (송송은 distinctly smaller+thinner) / julienne matchstick 누수 / 단순한 green disc (scallion center ring 누락) / 30+ 너무 많아 mince처럼 보임 / WHOLE intact spring onion 누수.

##### 5.10.3 ICUT-02 — F-02 Janchi-guksu cut / Korean zucchini 통썰기 (pair = CUT-04)

**식별 핵심 시각 요소**:
- 5-8 round zucchini discs in slightly fanned row (just-finished, NOT geometric grid)
- each disc ~4-5cm diameter × 3-5mm thick
- BRIGHT MEDIUM GREEN outer rim #5FA060 + PALE GREEN-WHITE inner flesh #D8E8B8
- subtle inner seed pattern (3-5 tiny pale dots center, very minimal)
- ONE specular highlight + optional 1-2cm partial unsliced end tip on LEFT

**Reroll trigger 핵심 (risk top 1)**: **cucumber 누수 ~50%** (darker green + bumpy skin + larger seed cavity) — "Korean zucchini bright medium green + smooth skin + minimal seed dots" 강제 / Italian zucchini darker forest green 누수 / yellow summer squash 누수 / 김밥 cylinder cross-section 누수 (이건 zucchini, NOT 김밥) / WHOLE intact zucchini 누수.

##### 5.10.4 ICUT-03 — F-03 Kimbap cut / danmuji 채썰기 (pair = CUT-02)

**식별 핵심 시각 요소**:
- 15-20 thin elongated yellow matchstick strips parallel-aligned cluster (slightly fanned)
- each strip ~8-10cm long × 4-5mm wide × 4-5mm thick (kimbap-length, LONGER than F-08/F-11)
- VIBRANT YELLOW #F5D43E pickled radish color
- smooth glossy slightly translucent + ONE specular highlight along top length
- end cuts slightly paler #F5E58A
- optional: 2-3cm partial unsliced danmuji cylinder end on LEFT

**Reroll trigger 핵심**: fresh white daikon (raw, NOT pickled) 누수 / short matchsticks 3-4cm (NOT kimbap-length 8-10cm) / thick chunky 1cm+ (NOT thin 4-5mm) / banana 누수 (pale beige round) / WHOLE intact danmuji cylinder 누수.

##### 5.10.5 ICUT-04 — F-04 Tteokbokki cut / 어묵 어슷썰기 (pair = CUT-03)

**식별 핵심 시각 요소**:
- 5-7 elongated oval fish cake pieces in relaxed overlapping cluster
- each piece ~6-8cm long diagonal × 3-4cm wide × 1-1.5cm thick (medium oval, NOT small NOT large)
- LIGHT GOLDEN-BROWN #C8923C with slim shading edge + subtle fish paste grain (1-2 lines)
- rounded oval corners + ONE specular highlight
- optional: 2-3cm partial unsliced flat sheet end on LEFT

**Reroll trigger 핵심 (risk top 2)**: **Japanese naruto pink spiral cross-section 누수 ~50%** / chikuwa hollow tube 누수 / 통썰기 round perfect circle 누수 (어슷썰기 = ELONGATED OVAL) / 깍둑썰기 cube 누수 / 채썰기 strip 누수 / WHOLE intact flat sheet 누수.

##### 5.10.6 ICUT-05 — F-05 Kimchi Fried Rice cut / 김치 다지기 (pair = CUT-01)

**식별 핵심 시각 요소**:
- generous scatter of fine minced kimchi bits in ~6-8cm oval area (just-finished, loose pile)
- each bit ~5-10mm irregular angular shape (NOT round, finely chopped)
- VIBRANT GOCHU RED #E84540 dominant (red kimchi paste coating each bit)
- hint of pale green-white cabbage base ~10-20% per bit visible under red coating
- few tiny red chili flake specks + ONE specular highlight (wet sheen)
- optional: 2-3cm partial unminced folded leaf with white rib on LEFT

**Reroll trigger 핵심**: large chunks 2-3cm (NOT fine 5-10mm) / Chinese pickled cabbage (different red paste) / Japanese tsukemono (color/texture) / round disc 슬라이스 누수 / WHOLE intact folded kimchi leaf 누수.

##### 5.10.7 ICUT-06 — F-06 Corn Dog cut / 모짜렐라 whole (no cut, ING-06과 동일)

**식별 핵심 시각 요소** (ING-06와 동일):
- single whole mozzarella cheese stick lying flat ~10-12cm × 2-2.5cm
- CLEAN MILKY WHITE #FAFAFA + subtle cylindrical shading + ONE specular highlight
- creamier end caps #F5F0E8

> F-06 cheese는 cut prep mechanic 없음 (whole 그대로 corn dog 안 insertion). ICUT-06 anchor는 카탈로그 완전성 위해 별도 생성하나 결과는 ING-06과 시각 동일. game-designer 후속 확정 시 ICUT-06 archive 가능 (ING-06 재사용).

**Reroll trigger 핵심**: cheddar yellow 누수 / 두부 matte square edges 누수 / 소시지 pink/red 누수 / 시각 cut (sliced rounds / cubes / shreds) 누수 (이건 whole 그대로).

##### 5.10.8 ICUT-07 — F-07 Haemul Pajeon cut / 대파 daepa 어슷썰기 (pair = CUT-03)

**식별 핵심 시각 요소 (CRITICAL — F-04 어묵 oval과 시각 분리)**:
- 5-7 elongated DOMINANT BRIGHT GREEN daepa oval pieces in relaxed overlapping cluster
- each piece ~5-7cm long diagonal × 1.5-2.5cm wide × 1-1.5cm thick (LARGE oval, dominant green)
- DOMINANT VIVID GREEN #52C160 outer ring (thick daepa stem wall ~5-8mm thickness)
- WHITE-PALE inner center hollow ~3-5mm (scallion stem hollow cross-section pattern)
- elongated oval shape (diagonal cut signature) + ONE specular highlight
- optional: 2-3cm partial unsliced daepa cylinder end with white root on LEFT

**Reroll trigger 핵심 (risk top 3)**: **F-04 어묵 oval로 색 누수 ~40%** (golden-brown 누수 — 강제 dominant green) / F-01 spring onion small thin round 누수 (이건 large daepa 5-7cm × 1.5-2.5cm) / Japanese negi 누수 (thinner variety) / round perfect circle 누수 (어슷썰기 = ELONGATED OVAL) / WHOLE intact daepa stalks 누수.

##### 5.10.9 ICUT-08 — F-08 Bibimbap cut / 당근 채썰기 (pair = CUT-02)

**식별 핵심 시각 요소**:
- 15-20 thin elongated orange matchstick strips parallel-aligned cluster (just-finished julienne)
- each strip ~5-7cm long × 2-3mm wide × 2-3mm thick (bibimbap-length, SHORTER than F-03/F-11)
- VIBRANT ORANGE #FF9933 + smooth + slim edge shading + ONE specular highlight
- end cuts slightly paler #FFB060
- optional: 2-3cm partial unsliced carrot tip with small green leafy stub on LEFT

**Reroll trigger 핵심**: F-03 단무지 길이 8-10cm 또는 F-11 6-8cm 누수 (F-08은 5-7cm 가장 짧음) / thick chunky 5mm+ strip 누수 / baby carrot 누수 / diagonal oval 누수 / WHOLE intact carrot 누수.

##### 5.10.10 ICUT-09 — F-09 Bulgogi cut / 얇은 소고기 marinade coated (no cut, marinade prep)

**식별 핵심 시각 요소 (CRITICAL — F-12 갈비 차별화)**:
- stack/fan of 5-7 thin marbled beef slices coated with GLOSSY DARK BROWN soy-pear-garlic marinade
- each slice ~8-12cm × 5-7cm × 2-3mm THIN (same as ING-09 raw whole dimensions)
- GLOSSY DARK BROWN MARINADE COATING #5A3015-#6B3A1A dominant (sticky brown glaze)
- ~30-40% original pink-red beef + white marbling 보이게 (under glaze)
- small POOL of extra marinade ~2-3cm at stack base (glossy brown puddle)
- optional: 송송 green scallion rounds 5-8 dots + 2-3 sesame seed dots on top (minimal accent)
- slim edge shading + ONE specular highlight (glossy wet marinade sheen)

**Reroll trigger 핵심 (risk top 4)**: **raw red 또는 cooked char marks 누수 ~40%** (marinade brown glaze coating 강제 — brown comes from marinade NOT grilling) / **F-12 갈비 bone visible 누수 CRITICAL** (NO bone, NO bone discs, NO cross-section discs along strips) / Japanese sukiyaki raw egg dipping plating 누수 / 삼겹살 thick layered stripes 누수 / 베이컨 parallel banded 누수 / thick steak slab 1cm+ 누수 (paper-thin 2-3mm 강제) / RAW unmarinated pink-red 누수 (이건 ING-09 whole, F-09 cut은 AFTER marinade).

##### 5.10.11 ICUT-10 — F-10 Sundubu cut / 두부 soft broken curds (no cut, broken)

**식별 핵심 시각 요소**:
- generous mound of broken soft tofu curds ~10-12cm × 5-7cm domed pile
- many small IRREGULAR CLOUD-LIKE white fragments (each ~2-4cm organic uneven shape)
- CLEAN MATTE WHITE #FAFAFA (NOT yellowish, NOT cream)
- subtle softer crevices between fragments + slim cel shading under mound
- ONE specular highlight (moist fresh tofu surface)
- optional: small empty open soft tofu tube remnant on LEFT (squeezed-out plastic packaging)

**Reroll trigger 핵심 (risk top 5)**: **firm tofu cube 누수 ~40%** (sharp-edged white rectangular cube — 이건 SOFT broken irregular fragments) / smooth puree 누수 (mashed paste NOT broken into fragments) / single solid block 누수 (multiple fragments 강제) / geometric square pieces 누수 (organic uneven irregular) / mozzarella cylindrical solid 누수 / 흑백 cottage cheese 색 누수 / WHOLE intact tube 누수.

##### 5.10.12 ICUT-11 — F-11 Japchae cut / 당근 채썰기 (F-08 variation, pair = CUT-02)

**식별 핵심 시각 요소 (F-08과 slight variation)**:
- 15-20 thin elongated orange matchstick strips SLIGHTLY DIAGONAL pile ~15도 (F-08은 perfectly horizontal)
- each strip ~6-8cm long × 2-3mm wide × 2-3mm thick (SLIGHTLY LONGER than F-08 5-7cm)
- same VIBRANT ORANGE #FF9933 as F-08
- slightly LARGER green leafy stub partial remnant on LEFT (visual variation)
- same smooth + slim edge shading + specular highlight as F-08

**Reroll trigger 핵심**: F-08과 완전 동일 (slight variation 차별 안 됨) — diagonal pile angle + length 6-8cm로 차별 / longer than 8cm noodle-like 누수 (medium julienne) / thick chunky strip 누수 / WHOLE intact carrot 누수.

> **game-designer 후속 확정**: F-11이 F-08 carrot cut anchor를 재사용하는 것으로 결정되면 ICUT-11 archive (assets-raw 파일은 보존, §0 anchor 표 status `재사용 결정 archived`로 갱신).

##### 5.10.13 ICUT-12 — F-12 Galbi-gui cut / 마늘 다지기 (pair = CUT-01)

**식별 핵심 시각 요소**:
- generous scatter of fine minced garlic granules in ~6-8cm oval area (just-finished mince)
- each granule ~1-3mm irregular angular shape (very fine granular, NOT round disc, NOT chunk)
- YELLOWISH-WHITE #F5F0E0-#F8F2D8 (peeled garlic color, NOT pure white NOT yellow)
- mix of more substantial bits 2-3mm + finer particles 1mm (natural mincing variation)
- slim cluster underside shading + ONE specular highlight (moist garlic surface)
- optional: 1.5-2cm partial unminced clove with pointed root tip on LEFT
- optional: knife blade minor garlic juice sheen on edge (very minimal)

**Reroll trigger 핵심**: thin garlic slices 5mm flat round disc 누수 (mince = 1-3mm granules) / whole garlic cloves intact 누수 (이건 ING-12 whole) / large chunks 5mm+ 누수 / onion mince 누수 (larger irregular + layered structure visible) / ginger mince 누수 (light tan + fiber strands) / WHOLE intact garlic cloves 누수.

#### 5.10.14 ingredient cut 12장 cross-호환 운영

- **Stage 1 (anchor seed inheritance)**: CUT-00 cutting_board base가 anchor seed로 작동 (cut anchor 7장 + ingredient whole 12장 + ingredient cut 12장 = 총 **31장**이 공유 anchor seed).
- **Stage 2 (12 ingredient cut follow-up)**: 각 prompt에 CUT-00 image reference upload + 본문 prompt + "이 reference cutting board + knife와 같은 wood color, blade silhouette, outline 두께, Cool Sage bg 톤으로 일관성 유지" 명시. 추가 권장 = 페어 ING-XX whole image도 reference upload (cut "before-after" pair 시각 일관성 강화).
- **세션 분기 권장**: ingredient cut 12장 한 세션 권장 (ingredient whole 12장 직후 같은 세션에서 follow-up 진행하면 anchor seed 재활용 + before-after pair 일관성 강화 가능). 또는 cut anchor 7장 + whole 12장 + cut 12장 = 31장을 chunk별 (cut 7 → whole 12 → cut 12) 세션 분기.
- **subject anchor 단어 공통 부분**: "modern mobile casual game asset illustration of a Korean kitchen cutting board (도마) with [CUT/PREPARED hero ingredient result] arranged on top, top-down view, cutting/prep RESULT state (the visual 'after' pair of the ING-XX whole anchor's 'before' state)"

#### 5.10.15 ingredient cut 12장 ChatGPT 약점 risk top 5 (G6 세분화)

| Rank | Ingredient cut | 누수 risk | default % | 회피 전략 |
|------|---------------|----------|-----------|----------|
| 1 | ICUT-02 애호박 통썰기 | cucumber 누수 (darker green + bumpy skin + larger seed cavity) | ~50% | "Korean zucchini bright medium green #5FA060 + smooth skin + minimal seed dots (3-5 tiny center)" 강제 + "NOT cucumber" negative |
| 2 | ICUT-04 어묵 어슷썰기 | Japanese naruto pink spiral cross-section 누수 | ~50% | "plain Korean 어묵 light golden-brown #C8923C oval, NO pink spiral, NO hollow tube" 강제 |
| 3 | ICUT-07 daepa 어슷썰기 | F-04 어묵 oval로 색 누수 (golden-brown 누수) | ~40% | **CRITICAL — DOMINANT BRIGHT GREEN #52C160 강제** + F-04 분리 명시 "NOT F-04 fish cake golden-brown oval, this is daepa bright green hollow scallion cross-section" |
| 4 | ICUT-09 marinade beef | raw red 또는 cooked char marks 누수 | ~40% | "GLOSSY DARK BROWN soy-pear-garlic marinade COATING (brown comes from marinade NOT grilling), NO char marks, NO bone visible (F-12 차별화 CRITICAL)" 강제 |
| 5 | ICUT-10 broken tofu | firm cube 누수 | ~40% | "SOFT broken into IRREGULAR CLOUD-LIKE FLUFFY WHITE FRAGMENTS organic uneven shapes 2-4cm, NOT firm sharp cube, NOT smooth puree, NOT single block" 강제 |

> 부차 risk (P2): ICUT-01 spring onion (송송 → 통썰기 large round 누수 ~25%) / ICUT-03 단무지 (kimbap-length 8-10cm → bibimbap-length 5-7cm 누수 ~25%) / ICUT-05 김치 (large chunk 2-3cm 누수 ~20%) / ICUT-11 carrot (F-08과 완전 동일하게 추론, slight variation 차별 안 됨 ~30%) / ICUT-12 garlic (slice 5mm 누수, mince는 1-3mm 강제 ~20%).

#### 5.10.16 driver script + 실행 명령

- 신규 driver: `tools/gen_ingredient_cut_anchors_m1.py` (`tools/gen_ingredient_anchors_m1.py` template 기반)
- 첫 시도 (ICUT-01 test 권장, ~30초 / ~$0.05): `py tools/gen_ingredient_cut_anchors_m1.py --only F-01`
- 12장 batch (~4-5분 / ~$0.50): `py tools/gen_ingredient_cut_anchors_m1.py --model gpt-image-1 --quality medium`
- 출력 경로: `assets-raw/ingredient_cut_anchors_m1/<food_id>_<ingredient_cut_name>_v1.png` (예: `F-01_spring_onion_cut_v1.png`)
- F-11 carrot variation 또는 F-06 cheese 재사용 결정 시 archive: `py tools/gen_ingredient_cut_anchors_m1.py --only F-11` 또는 `--only F-06`
- build_prompt: `body.replace("%s", STYLE_SUFFIX_INGREDIENT_CUT, 1)` (Python old-style `body % SUFFIX` ValueError fix — gen_food/gen_ingredient에서 발생했던 패턴 회피)

#### 5.10.17 game-designer 후속 confirm 사안 (ingredient cut 12장)

> 본 v1.19 ingredient cut 12장 매핑은 §5.6 ingredient whole 12장 매핑 직접 follow-through. game-designer foods CSV `prep_*` 컬럼 lock 결과:

| ICUT 매핑 | 검증 사안 | 영향 |
|----------|----------|------|
| ICUT-06 F-06 cheese whole (no cut) | F-06 prep mechanic이 cheese 외 sausage 자체 cut 있는가? | 있으면 ICUT-06이 sausage cut으로 swap, cheese는 ING-06 그대로 재사용 |
| ICUT-09 F-09 marinade prep (no cut) | F-09 prep mechanic이 marinade 외 양파/대파 cut 있는가? | 있으면 ICUT-09는 양파/대파 cut로 swap, beef marinade는 별도 |
| ICUT-10 F-10 broken curds (no cut) | F-10 prep mechanic이 broken curds 외 멸치/김치 cut 있는가? | 있으면 ICUT-10는 멸치/김치 cut로 swap, soft tofu는 별도 |
| ICUT-11 F-11 carrot (F-08 variation) | F-11이 F-08 carrot cut anchor 재사용 결정 시 ICUT-11 archive | 재사용 시 assets-raw 보존 + §0 status `재사용 결정 archived` |

> game-designer 확정 후 art-director는 (a) 본 §5.10 매핑 표 갱신 / (b) §5.10 ingredient cut prompt 일부 reroll / (c) driver script INGREDIENT_CUTS list sync 작업 진행.

---

### 5.14 mini extra 2장 (v1.23 신설, game-designer motion-spec 후속 gap fix)

> **v1.23 트리거 (2026-05-31)**: game-designer motion-spec 후속에서 (a) F-09 불고기 Stage 2A 양념재우기 mechanic은 손바닥 press motion (위→아래 tap)이 dominant action이나 hand sprite anchor 부재 / (b) F-06 콘도그 Stage 2A는 dip substitute (콘도그 stick을 batter에 담그기) mechanic이 dominant이나 batter bowl anchor 부재 — 두 gap 발견. cut/tool/ingredient/UI/VFX 6 cluster (49 anchor) 외 누락된 mini extra 2장으로 cluster 합류 (49 → 51).

#### 5.14.0 mini extra 2장 매핑 표

| ID | name | usage | 시각 핵심 (한 줄) |
|----|------|-------|----------------|
| EX-01 | hand_marinade | F-09 불고기 Stage 2A 양념재우기 (palm press motion anchor) | single open palm 7/8 view palm-down + warm peachy skin #F5C9A2 + 4 fingers close-together ready-to-press + short wrist stub + 1-2 subtle downward motion lines |
| EX-02 | corndog_batter_bowl | F-06 콘도그 Stage 2A dip substitute (batter mixing bowl anchor) | matte white round ceramic bowl ~26-30cm × 11-13cm + NO handles + viscous light tan/golden cornmeal-wheat batter #E8C58A 65-75% depth + elliptical surface pool + slim batter meniscus at inner rim |

#### 5.14.1 STYLE_SUFFIX_MINI (모든 mini extra 공통 suffix)

> driver script `tools/gen_mini_extra_m1.py`의 `STYLE_SUFFIX_MINI` 상수 inline single source. **변경 시 driver script가 ground truth**. TOOL suffix와 핵심 차이 = (a) ambient ellipse shadow 유지 (mini extra는 diegetic in-scene prop이라 shadow OK — UI/VFX와 차별점, UI/VFX는 HUD overlay이라 shadow 없음) / (b) chibi friendly hand anatomy 회피 절 추가 (realistic knuckles / veins / fingerprints / nail beds / palm creases / hand hair / age spots / jewelry 0건 강제) / (c) character body 회피 절 추가 (hand sprite는 hand + wrist stub only, NO elbow/shoulder/face).

#### 5.14.2 EX-01 — hand_marinade (F-09 불고기 Stage 2A 양념재우기)

**식별 핵심 시각 요소**:
- single open human palm hand, 7/8 perspective palm-down orientation
- ~55-65% image width × 50-60% height, generous center padding
- warm peachy skin tone #F5C9A2 single fill + slim deeper warm peach #E8B189 cel shading on bottom-right + ONE small white #FFFFFF specular highlight on upper-left knuckle
- 4 fingers held close-together palm-down ready-to-press (NOT spread wide, NOT clenched fist)
- soft rounded fingertips (NO sharp fingernail detail, NO cuticle, optional very subtle slim arc hint per fingertip)
- thumb tucked along the side (NOT extended outward thumbs-up)
- short wrist stub at upper edge (~10-15% hand height, cut off cleanly at frame edge suggesting arm off-frame)
- slim warm dark #2D1D14 outline 2-3px + 3 hairline finger separation grooves
- 1-2 short downward motion lines near upper edge (slim warm dark hairline arcs ~10-15px each, subtle accent for "descending press motion")
- ambient ellipse shadow underneath (#000 ~25% alpha — diegetic prop)

**Reroll trigger 핵심 (risk top 3)**:
- **realistic hand anatomy 누수 ~50%** (detailed knuckle wrinkles + visible veins + fingernail beds + palm creases + hand hair + age spots + jewelry → "friendly chibi-style, NO detailed knuckles, NO veins, NO fingerprint detail, NO realistic fingernails" explicit 강제)
- **full arm 누수 ~40%** (elbow/upper arm/shoulder/character body까지 그릴 risk → "short wrist stub at upper edge only, NO elbow / NO upper arm / NO shoulder / NO character body / NO face" explicit 강제)
- **thumbs-up gesture 누수 ~25%** (R-05/R-06 아버지 thumb-up cross-asset 영향 → "thumb tucked along side, NOT thumbs-up, NOT pointing finger, NOT high-five waving" explicit 강제)

#### 5.14.3 EX-02 — corndog_batter_bowl (F-06 콘도그 Stage 2A dip substitute)

**식별 핵심 시각 요소**:
- single round CERAMIC MATTE WHITE OR LIGHT CREAM mixing bowl, 7/8 perspective view
- ~26-30cm diameter top × 11-13cm deep, NO HANDLES (TOOL-11 stainless mixing bowl과 시각 분리)
- bowl color: clean matte white #FAFAFA (or alternatively light cream #F5F0E8) single fill + subtle slim cel shading on outer lower curve + ONE small specular highlight strip along upper outer rim
- filled with VISCOUS LIGHT TAN/GOLDEN cornmeal-wheat batter #E8C58A single fill at ~65-75% bowl depth
- batter surface = ELLIPTICAL POOL (7/8 perspective) with subtle slim cel shading hint suggesting viscous thick texture + ONE small specular highlight on batter surface (glossy wet sheen)
- optional 1-2 very small bubbles or surface dimples (~3-5mm circular hints) suggesting freshly-mixed viscous state
- subtle BATTER MENISCUS at inner bowl rim (slim curved hint suggesting sticky thick consistency)
- batter does NOT overflow rim (well below)
- slim warm dark #2D1D14 outline 2-3px + slim hairline for batter surface ellipse edge
- ambient ellipse shadow underneath (diegetic prop)
- optional very subtle 1 small batter drip on outer bowl rim (~3-5mm single drop accent, NOT messy splash)

**Reroll trigger 핵심 (risk top 4)**:
- **TOOL-11 mixing bowl과 시각 동일 누수 ~40%** (silver-gray stainless로 추론할 risk → "clean matte white OR light cream CERAMIC, NOT silver-gray stainless, NOT TOOL-11 bibimbap mixing bowl" explicit 강제 + 색상 #FAFAFA fill + filled with viscous batter 명시 [TOOL-11은 empty라 시각 분리])
- **pancake batter pourable runny 누수 ~25%** (얇은 액체 batter로 추론 → "VISCOUS THICK pancake-batter consistency, NOT thin pourable runny pancake batter, NOT clear liquid soup" explicit 강제)
- **검정 cast-iron 누수 ~20%** (corndog 깊은 튀김 연상으로 cast-iron 추론 → "clean MATTE WHITE ceramic, NOT black cast iron, NOT silver-gray metallic" explicit 강제)
- **batter 색 chocolate brown 누수 ~20%** (gravy/brown sauce 추론 → "LIGHT TAN/GOLDEN #E8C58A warm golden cornmeal tone, NOT chocolate brown, NOT dark gravy" explicit 강제)

#### 5.14.4 mini extra 2장 cross-호환 운영

- **cluster 합류**: 49 anchor cluster (food 12 + 환경 5 + 캐릭터 5 + cut 7 + ingredient whole 12 + ingredient cut 12 + reaction 6 + 조리도구 12 + UI 7 + VFX 5)에 mini extra 2장 추가 = **51 anchor cluster**.
- **anchor seed**: TOOL-11 mixing_bowl이 EX-02 corndog_batter_bowl의 seed 후보 (둘 다 round mixing vessel, 시각 차별점은 color + handles + filled state). EX-01 hand_marinade는 CH-01 base의 mitten hand silhouette을 chibi tone reference로 사용 가능 (단 hand sprite는 standalone이라 base가 character full body여서 직접 reference 강도는 낮음).
- **subject anchor 단어 공통 부분**: "modern mobile casual game asset illustration of a single [mini extra element] for motion-spec animation, 7/8 perspective view, standalone sprite on Cool Sage background, friendly chibi tone consistent with 51 anchor cluster"

#### 5.14.5 ChatGPT 약점 risk top 5 (G6 세분화)

| Rank | Mini extra | 누수 risk | default % | 회피 전략 |
|------|-----------|----------|-----------|----------|
| 1 | EX-01 hand realistic anatomy | detailed knuckle/veins/fingernails/palm creases/hair/jewelry 누수 | ~50% | "friendly chibi-style, soft rounded fingertips, NO detailed knuckles, NO veins, NO fingerprint detail, NO palm crease lines, NO hand hair, NO age spots, NO jewelry rings, NO watch" 강제 |
| 2 | EX-01 full arm | elbow/upper arm/shoulder/character body까지 그릴 누수 | ~40% | "short wrist stub at upper edge ONLY, NO elbow, NO upper arm, NO shoulder, NO character body, NO face — character body implied off-frame" 강제 |
| 3 | EX-02 TOOL-11 mixing bowl과 동일 추론 | silver-gray stainless 누수 (둘 다 mixing bowl) | ~40% | "clean MATTE WHITE OR LIGHT CREAM CERAMIC #FAFAFA, NOT silver-gray stainless, NOT TOOL-11" + filled with batter (TOOL-11은 empty) |
| 4 | EX-01 thumbs-up | R-05/R-06 thumb-up cross-asset 영향 | ~25% | "thumb tucked along side, palm OPEN ready to press flat, NOT thumbs-up, NOT pointing finger, NOT clenched fist, NOT high-five waving" 강제 |
| 5 | EX-02 pancake batter runny | thin pourable liquid batter 누수 | ~25% | "VISCOUS THICK sticky pancake-batter consistency, NOT thin pourable runny, NOT clear liquid soup, NOT cake batter with whisk inside" 강제 |

> 부차 risk (P2): EX-02 검정 cast-iron 누수 ~20% / EX-02 chocolate brown gravy 누수 ~20% / EX-02 with corndog stick already inside ~15% (food layer runtime composited).

#### 5.14.6 driver script + 실행 명령

- 신규 driver: `tools/gen_mini_extra_m1.py` (`tools/gen_tool_anchors_m1.py` template 기반)
- 첫 시도 (가장 risk 높은 EX-01 hand_marinade test 권장, ~30초 / ~$0.04): `py tools/gen_mini_extra_m1.py --only hand_marinade --quality medium`
- 2장 batch (~1-2분 / ~$0.08): `py tools/gen_mini_extra_m1.py --quality medium`
- 출력 경로: `assets-raw/mini_extra_m1/<name>_v1.png` (예: `hand_marinade_v1.png`, `corndog_batter_bowl_v1.png`)
- build_prompt: `body.replace("%s", STYLE_SUFFIX_MINI, 1)` (Python old-style `body % SUFFIX` ValueError fix — gen_food/gen_ingredient/gen_reaction/gen_tool/gen_ui_vfx에서 발생했던 패턴 회피)

#### 5.14.7 game-designer 후속 confirm 사안 (mini extra 2장)

> 본 v1.23 mini extra 2장 매핑은 game-designer motion-spec 후속 raise. game-designer motion-spec lock 결과:

| EX 매핑 | 검증 사안 | 영향 |
|---------|----------|------|
| EX-01 hand_marinade (F-09 양념재우기) | F-09 prep motion이 palm press 외 chopstick stir 또는 spoon mix 등 다른 motion 있는가? | 있으면 EX-01 외 추가 hand pose 또는 utensil-in-hand sprite 필요 (mini extra 추가 row) |
| EX-02 corndog_batter_bowl (F-06 dip substitute) | F-06 prep motion이 dip 외 batter mixing 또는 stick spear 등 다른 motion 있는가? | 있으면 EX-02 외 추가 specialty container 또는 stick sprite 필요 |

> game-designer 확정 후 art-director는 (a) 본 §5.14 매핑 표 갱신 / (b) §5.14 mini extra prompt 일부 reroll / (c) driver script EXTRAS list sync 작업 진행. 추가 mini extra 항목은 본 driver의 EXTRAS list에 append 방식으로 확장 (별도 driver 신설 X — sprint 종료 시까지 한 driver 안에 누적).

---

### 5.7 양친 reaction 6컷 (v1.18 v2 image edit, supersedes v1.16 v1 prompt-only)

> **v1.18 v2 image edit patch (2026-05-30)**: 사용자가 v1 (prompt-only, gpt-image-1 medium 1024×1024 6장 batch) 결과 시각 확인 후 2건 피드백 raise → v1 = **deprecated** for R-01/R-03/R-04/R-05/R-06 (R-02 어머니 ★2 anchor seed는 base와 가장 가까워 v1 결과 시각이 가장 안정적이었으나 통일성 위해 v2에서 함께 재생성):
> - **R-01/R-03 어머니 hair mismatch**: 사용자 verbatim "reaction 에서 R-01, R-03가 원래 이미지와 좀 다름". v1에서 round-bun **+ side-puff** variant로 생성되어 CH-02 base의 round-bun **simple**과 다름.
> - **R-04 vs R-05/R-06 아버지 family IP inconsistency**: 사용자 verbatim "R-04, R-05, R-06가 이미지가 좀 일관성이 없음". R-04는 darker hair/shirt (CH-03 base와 일치), R-05/R-06는 lighter tone으로 셋 사이 inconsistency.
>
> **해결 — image edit API 도입** (BG sprint v4에서 효과 입증된 패턴): prompt-only generation은 base의 family IP를 정확 재현 못함. `client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_FRAME + expression_prompt, size="1024x1024", quality="medium", n=1)`로 base PNG를 직접 입력 + 표정만 변경. 캐릭터 5장 anchor file을 직접 input으로 사용 → family IP 정확 보존.
>
> **Base image 2장** (Week 1 commit 7a6cffb 무영향):
> - `assets-raw/week1-anchors/CH-02_mother.png` → R-01/R-02/R-03 어머니 3컷 base
> - `assets-raw/week1-anchors/CH-03_father.png` → R-04/R-05/R-06 아버지 3컷 base
>
> **v2 single source of truth**: 6 reaction prompt body (COMMON_FRAME + expression_prompt)는 `tools/edit_reaction_anchors_v2.py` `COMMON_FRAME` 상수 + `REACTIONS` list 6개 항목 inline body가 single source. 본 문서 §5.7는 (a) trigger 사유 + (b) base image mapping + (c) approach 요약 + (d) 실행 명령만 명시 (본문 prompt 변경 시 driver script가 ground truth).
>
> **v1 prompt-only approach (deprecated archive)**: v1.16 §5.7 본문 (`tools/gen_reaction_anchors_m1.py`의 STYLE_SUFFIX_REACTION + REACTIONS 6 prompt-only body)는 deprecated 보존. v1 output (R-XX_<character>_star<N>_v1.png 6장)도 보존 — v2 (R-XX_<character>_star<N>_v2.png)와 공존, git history reference.
>
> **6 reaction × base 매핑**:
>
> | ID | character | star | base file | gradient 단계 |
> |----|-----------|------|-----------|--------------|
> | R-01 | mother | ★1 | CH-02_mother.png | mild satisfaction (subtle warm smile + 정상 open dot eyes, 30-59%) |
> | R-02 | mother | ★2 | CH-02_mother.png | happy/pleased (bigger smile + soft upward crescent arc, 60-89%) — anchor seed (base default와 가장 가까움) |
> | R-03 | mother | ★3 | CH-02_mother.png | very happy (big wide smile + closed-arc + heart accent, 90-100%) |
> | R-04 | father | ★1 | CH-03_father.png | reserved (slim closed smile + NO thumb-up, 30-59%) |
> | R-05 | father | ★2 | CH-03_father.png | relaxed (fuller open smile + single casual thumb-up, 60-89%) — anchor seed |
> | R-06 | father | ★3 | CH-03_father.png | very excited (big wide smile + closed-arc + double thumb-up + sparkle, 90-100%) |
>
> **COMMON_FRAME 핵심 (driver script COMMON_FRAME 상수)** — 6 reaction 공통:
> - **EXACT SAME family IP 강제**: hair shape (round-bun simple for mother / salt-and-pepper darker for father) / hair color / face proportions / outfit color (red jeogori + apron / teal-green shirt) / chibi 1:1.7 / outline 2-3px / saturation 80-90%. 어머니 hair는 round-bun + side-puff 추가 명시적 회피. 아버지 hair tone + shirt tone은 base와 EXACTLY 일치 명시 (NOT lighter).
> - **bust-up portrait crop** (head and shoulders only, NO full body / lower body / legs / feet).
> - **background replace with solid Cool Sage #C8D5C0** (cross-asset cluster 합류).
> - **표정만 변경 명시** (everything else IDENTICAL).
> - **negative**: sad teardrop / crying / sleeping closed peaceful eyes / disappointed cold / Japanese kimono / Chinese qipao / anime girl big sparkly eyes / school uniform / Cookie Run frosting / scrapbook / beige bg / multiple characters / readable text.
>
> **6 reaction expression_prompt 핵심** (driver script REACTIONS list 6 항목 body):
> - **R-01 mother ★1**: SUBTLE small arc smile (mouth closed, slightly upturned) + normal OPEN dot eyes + slight head tilt + optional chin hand or chopsticks. Warm motherly nurturing acceptance.
> - **R-02 mother ★2**: BIGGER warm smile (mouth slightly OPEN) + soft UPWARD CRESCENT ARC eyes + holding bowl/chopsticks. Warm motherly pleased amplification.
> - **R-03 mother ★3**: BIG WIDE delighted smile + CLOSED-ARC HAPPY eyes + both hands near cheeks + optional 1-2 simple flat heart icons + optional sparkle. Motherly delight peak.
> - **R-04 father ★1**: SLIM RESERVED small arc smile (mouth closed) + normal OPEN dot eyes + upright posture + **NO thumb-up** (★1 = reserved, NOT enthusiastic) + optional chin hand. Reserved masculine acceptance.
> - **R-05 father ★2**: FULLER open smile (mouth slightly open) + soft UPWARD CRESCENT ARC eyes + **SMALL CASUAL SINGLE THUMB-UP** (like CH-03 base default pose). Reserved masculine breaking into pleasure.
> - **R-06 father ★3**: BIG WIDE delighted smile + CLOSED-ARC HAPPY eyes + body tilted forward + **DOUBLE THUMB-UP gesture** (both hands thumb-up near chest) + 2-4 simple flat sparkle accents. Reserved masculine peak excitement.
>
> **driver script 실행 명령**:
> ```
> py tools/edit_reaction_anchors_v2.py --only R-01     # test 1 (어머니 mismatch)
> py tools/edit_reaction_anchors_v2.py --only R-01,R-03  # 어머니 mismatch 2장
> py tools/edit_reaction_anchors_v2.py --only R-04,R-05,R-06  # 아버지 inconsistency 3장
> py tools/edit_reaction_anchors_v2.py                  # 6장 batch (권장)
> py tools/edit_reaction_anchors_v2.py --quality high   # 더 높은 품질 (~5x cost)
> ```
> Default: gpt-image-1 image edit, medium quality, 1024×1024. 6장 × $0.042 ≈ $0.25, ~2-3분. v2 출력 경로: `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v2.png` (v1과 공존).
>
> **v2 G_reaction 평가** = art-anchor-rubric v1.18 §5.9 G_reaction 5 요소 게이트 사용. v2 PASS critical 요소 = (1) family IP 식별 명확 (CH-02/CH-03 base와 hair/outfit/face features 일치 — v1에서 FAIL했던 핵심 게이트) / (2) ★1/★2/★3 expression gradient 명확 / (3) Cool Sage bg + cross-asset 일관성 / (4) bust-up + chibi proportions / (5) sad/sleeping/negative 누수 0건. **LOCK = 6/6 anchors × 5 요소 = 30/30 PASS** (변경 없음).
>
> **risk for v2** (image edit이 prompt-only 대비 family IP 더 잘 보존하나 새로운 risk):
> - **base image의 default expression 유지 risk** (~25%): image edit이 표정 변경을 충분히 강하게 적용 안 하면 6장 모두 base의 default 표정 (subtle smile + thumb-up)에 가까워 ★1/★2/★3 gradient 무너짐. EXPRESSION CHANGE 절이 prompt 시작부에 명시 + ★N 차이 explicit description으로 회피.
> - **base의 bowl/물건 prop 유지 risk** (~20%): CH-02 base는 양손으로 그릇 들고 있는데 ★3은 손이 cheeks 옆으로 가야 함. 이 prop이 carry over되면 ★3 prompt와 conflict. prompt에서 hand position을 명확히 명시.
> - **base의 thumb-up 유지 risk** (~30%, R-04 ★1 영향): CH-03 base의 thumb-up이 R-04 ★1에서 carry over되면 ★1 reserved 의도와 conflict. prompt에서 "NO thumb-up" 명시.
>
> **R3 fallback (사용자 ChatGPT 웹 UI 수동 워크플로)**: v2 image edit 결과가 여전히 family IP consistency 부족하거나 expression gradient 불명확하면, 사용자가 ChatGPT 웹 UI에서 수동 chain-of-references 워크플로 실행. (a) CH-02_mother.png upload + R-02 ★2 prompt → 어머니 anchor seed lock / (b) seed image를 reference로 R-01 ★1 / R-03 ★3 generation / (c) 새 세션 + CH-03_father.png upload + R-05 ★2 prompt → 아버지 anchor seed lock / (d) seed image + (R-06만) CH-05_father_star3.png 추가 reference로 R-04 ★1 / R-06 ★3 generation.

#### 5.7.archive v1 (deprecated 2026-05-30, prompt-only approach, family IP consistency 부족)

> v1.16 §5.7 본문은 `tools/gen_reaction_anchors_m1.py` STYLE_SUFFIX_REACTION + REACTIONS 6 prompt-only body 형태. 사용자 R1 v1 시각 확인 후 어머니 hair mismatch (R-01/R-03) + 아버지 family IP inconsistency (R-04/R-05/R-06) 2건 FAIL → v2 image edit approach (`tools/edit_reaction_anchors_v2.py`)로 supersede. v1 output (R-XX_<character>_star<N>_v1.png 6장)은 보존 (v2 비교 reference).

### 5.8 재료 카드 / UI / VFX (M2)

- 재료 ~20개: 음식 anchor의 hero ingredient crop으로 시작 → 부족 재료만 별도 prompt
- UI 일러스트 ~7개: 장바구니, 메모지, 간판 5종 등 — flat 톤 단순 icon (간판 텍스트는 W1으로 placeholder block만, 한글 후보정)
- VFX ~4~5개: 픽업 빛, shake, 타이머 펄스, ★ 등급 — flat 톤이라 simple shape 변화로 충분

> **§5.9~§5.14 본문은 별도 driver script + inline prompt가 single source** — 본 markdown은 docstring 인덱스 역할만 한다. driver script 위치:
> - §5.9 양친 reaction 6컷 v3 image edit = `tools/edit_reaction_anchors_v3.py` (COMMON_FRAME + REACTIONS list 6개 inline)
> - §5.10 ingredient cut 12장 = `tools/gen_ingredient_cut_anchors_m1.py`
> - §5.11 조리도구 12종 = `tools/gen_tool_anchors_m1.py`
> - §5.12 UI 7장 + §5.13 VFX 5장 = `tools/gen_ui_vfx_anchors_m1.py`
> - §5.14 mini extra 2장 (hand_marinade + corndog_batter_bowl) = `tools/gen_mini_extra_m1.py`

### 5.15 Phase B + C guest avatar 20장 (5 guest × 4 emotion, v1.24 신설)

> **single source of truth** = `tools/gen_guest_avatars.py` (STYLE_SUFFIX_GUEST_AVATAR + GUESTS 5개 inline + EMOTIONS_PHASE_B/PHASE_C 4개 emotion inline + build_prompt_phase_b/build_prompt_phase_c 2-pass 합성 함수). 본 markdown은 가이드/인덱스 역할만 한다.

#### 5.15.1 매핑 표 (5 guest × 4 emotion = 20 anchor)

| Guest ID | Display Name | Personality | Phase B (neutral) | Phase C (happy / excited / disappointed) | Driver flag 예시 |
|----------|--------------|-------------|-------------------|-------------------------------------------|------------------|
| junho    | Junho        | 호방 매콤 매니아 (bold spicy) — male 20s-30s, energetic, "Make it nice and spicy today!", fav=spicy/salty/hearty | 1 anchor | 3 anchor | `--only junho` |
| mina     | Mina         | 단맛 발랄 (cheerful sweet) — female 20s, bubbly, "I've got a serious sweet tooth!", fav=sweet/savory/oily | 1 anchor | 3 anchor | `--only mina` |
| riley    | Riley        | 외국인 산뜻함 (foreign fresh-tangy) — non-Korean 외국인 20s, gender-neutral, "Give me something tangy!", fav=sour/fresh/umami | 1 anchor | 3 anchor | `--only riley` |
| mrs_lee  | Mrs Lee      | 멘토 따뜻한 집밥파 (warm motherly mentor) — female 50s-60s, "Keep it clean with it.", fav=mild/umami/fermented/hearty | 1 anchor | 3 anchor | `--only mrs_lee` |
| seoyeon  | Seoyeon      | 집밥파 따뜻 (friendly homestyle homebody) — female 30s, "Give me something cozy!", fav=hearty/salty/umami/sweet | 1 anchor | 3 anchor | `--only seoyeon` |

#### 5.15.2 STYLE_SUFFIX_GUEST_AVATAR 핵심 시그니처

bust-up portrait + chibi 1:1.7 + Cool Sage `#C8D5C0` solid bg + slim outline 2-3px (warm dark #2D1D14) + modern saturated 80-90% + light pink cheek #FFCFCF (R-01~06 reaction과 동일 톤) + 안정적 dot eyes + ambient ground shadow + cross-cultural negative (Japanese kimono / Chinese qipao / Western lederhosen — Riley = 외국인 identity explicit 예외) + 가정 family IP CH-02/CH-03/CH-01 누수 회피 명시 (guest는 가정 family 아닌 친구 NPC) + anime girl big sparkly pupils 회피 + over-exaggerated goofy 회피.

#### 5.15.3 5 guest identity 한 줄 요약 (prompt body 핵심)

- **junho**: Korean young adult male 20s-30s + short messy dark brown spiky/tousled hair + bold red graphic t-shirt #E04848 + optional flame/chili icon graphic chest accent + optional thin gray hoodie cord neckline + energetic confident vibe.
- **mina**: Korean young adult female 20s + medium-length warm chestnut brown side ponytail + small pastel pink hair clip/band #F4B4C9 + soft pastel pink pullover sweater #F8C4D0 + optional heart/strawberry icon chest accent + cheerful bubbly vibe.
- **riley**: non-Korean foreign 외국인 young adult 20s gender-neutral + short modern wavy warm honey-blonde/strawberry-blonde/light brown hair + optional 3-5 small flat freckle accents + fresh mint-green or light yellow casual hoodie/pullover #B4E4C4 or #F4E48C + optional lemon slice/leaf icon chest accent + bright fresh cosmopolitan vibe.
- **mrs_lee**: Korean middle-aged female 50s-60s + short modern permed wavy salt-and-pepper medium-length hair (CRITICAL: NOT CH-02 round-bun simple, MUST be wavy permed and grayer) + small simple flat round reading glasses (warm brown frame, signature accessory) + dusty mauve collar shirt #D8B4A4 + soft warm beige knit cardigan #E4D4B8 (NOT persimmon red jeogori, NOT teal-green button-up) + warm kindly mentoring vibe.
- **seoyeon**: Korean adult female early 30s + medium-length straight dark brown shoulder-length hair (NOT side-ponytail Mina, NOT wavy permed Mrs Lee) + soft warm cream or oat-beige turtleneck sweater #E8D8C4 + optional small flat gold stud earring accent + friendly cozy homebody vibe.

#### 5.15.4 4 emotion 한 줄 요약 (expression_prompt 핵심)

- **neutral (Phase B)**: dot eyes open normal forward + subtle small closed arc smile + NO emotion icon + relaxed friendly default attentive pose. Anchor seed for all 4 emotions of this guest.
- **happy (Phase C)**: eyes closed crescent ^_^ + medium open smile or O-shape "오~" mouth + 1-2 sparkle icons floating near head + shoulders slightly raised. R-02 mother ★2 v3 tone.
- **excited (Phase C)**: eyes GIANT closed-arc ^___^ (optional sparkle accent OUTSIDE eye, NOT inside pupil) + WIDE open delighted smile with teeth/tongue hint + both raised hands near cheeks or over head + 3-5 sparkle + 1-2 star + 2-3 motion lines + body slightly raised mid-jump posture. R-03/R-06 ★3 v3 코믹 amplification tone.
- **disappointed (Phase C)**: dot eyes slight droop downward-or-aside + LOWERED EYEBROWS angled inward-down (HERO cue) + SUBTLE DOWNTURNED CLOSED MOUTH small arc + head tilted down-and-away ~10-15° + shoulders slumped + optional ONE sweat drop or "..." icon. CRITICAL = subtle mature adult disappointment, NOT crying tears, NOT teardrop falling, NOT sad sobbing open mouth (R-01/R-04 v1 deprecated sad teardrop 명시적 회피).

#### 5.15.5 2-pass driver pattern

```
Phase B (5 guest neutral generation, prompt-only):
    prompt = build_prompt_phase_b(guest, neutral) =
        "A modern mobile casual game character bust-up portrait. " +
        guest.identity_prompt + "\n\n" +
        neutral.expression_prompt + "\n\n" +
        STYLE_SUFFIX_GUEST_AVATAR
    client.images.generate(model="gpt-image-1", prompt, size="1024x1024", quality="medium", n=1)
    output → assets-raw/guest_avatars_m1/{guest_id}_neutral_v1.png

Phase C (15 emotion variants, image edit, base = Phase B neutral output):
    prompt = build_prompt_phase_c(guest, emotion) =
        COMMON_FRAME (family IP IDENTICAL lock + bust-up crop + Cool Sage bg) +
        emotion.expression_prompt +
        STYLE_SUFFIX_GUEST_AVATAR
    client.images.edit(model="gpt-image-1", image=open(neutral_base, "rb"), prompt, size, quality, n=1)
    output → assets-raw/guest_avatars_m1/{guest_id}_{emotion}_v1.png
```

#### 5.15.6 cross-호환 운영 (anchor seed + reference upload)

- **anchor seed** = junho neutral 첫 generation 후 시각 확인 → LOCK이면 5 guest neutral batch 진행. junho가 risk top guest (bold red shirt + 한식↔Japanese chibi 누수 가능성 높음)이라 anchor seed 역할.
- **Phase C base = Phase B output** = `client.images.edit(image=open(base, "rb"))`로 base 직접 입력 → family IP (hair/outfit/face) 자동 lock. R-01~06 v3 image edit 패턴 입증 동일 방식.
- **rembg post-process** = Phase B+C 20 PNG 모두 `assets-raw/guest_avatars_m1/` → ADR-007 rembg transparent 후처리 후 `assets-processed/guest_avatars/{guest_id}_{emotion}.png` (game size 240×240 또는 180×180 crop).

#### 5.15.7 ChatGPT 약점 risk top 3 (driver script docstring 참조)

1. 한식↔Japanese chibi 누수 ~40% (특히 mina pastel pink sweater + side ponytail이 Japanese anime girl 학생 톤으로 누수 risk → STYLE_SUFFIX_GUEST_AVATAR + identity_prompt에 explicit 강제)
2. Western character 누수 ~35% (Riley 제외, junho/mina/mrs_lee/seoyeon 4 guest는 Korean identity 강제. Riley는 explicit 외국인 OK)
3. anime girl big sparkly eyes 누수 ~30% (excited emotion에서 sparkle eyes alternative가 enlarged shoujo pupils로 누수 risk → "SEPARATE floating geometric icons OUTSIDE the eye" 강제)

#### 5.15.8 main thread 실행 명령

```
# Phase B test (junho anchor seed 우선)
py tools/gen_guest_avatars.py --phase B --only junho --quality medium
    # 1장 × $0.042 ≈ $0.05, ~30초 → 시각 확인

# Phase B 5장 batch
py tools/gen_guest_avatars.py --phase B --quality medium
    # 5장 × $0.042 ≈ $0.21, ~2-3분 → 시각 확인 + LOCK

# Phase C 15장 batch (Phase B neutral output prerequisite)
py tools/gen_guest_avatars.py --phase C --quality medium
    # 15장 × $0.042 ≈ $0.63, ~5-7분

# 또는 전체 ALL 20장 (Phase B + Phase C 순차)
py tools/gen_guest_avatars.py --phase ALL --quality medium
    # 20장 × $0.042 ≈ $0.84, ~7-10분

# 특정 emotion만 Phase C
py tools/gen_guest_avatars.py --phase C --emotion happy
    # 5 guest × happy = 5장 ~$0.21

# 특정 guest Phase C
py tools/gen_guest_avatars.py --phase C --only junho
    # 1 guest × 3 emotion = 3장 ~$0.13
```

#### 5.15.9 godot-dev 후속 swap spec (guest_card_v2.gd AVATAR_TINT → load() 교체)

`godot-project/scripts/ui/components/guest_card_v2.gd` L27-32 `AVATAR_TINT` dict + L109-124 avatar_panel 단색 fill placeholder를 다음으로 교체:

1. **assets-processed/guest_avatars/ 디렉터리 신설** + Phase B+C 20 PNG를 240×240 또는 180×180 game size로 crop + rembg transparent post-process (ADR-007 호환).
2. **L27-32 AVATAR_TINT dict는 fallback으로 보존** (texture load 실패 시 단색 fill 폴백).
3. **L109-124 `_avatar_panel` 구간 수정**: Panel 자체는 frame/border/shadow 유지하되, 내부에 신규 TextureRect 추가 — `var avatar_tex := TextureRect.new()` + `avatar_tex.texture = load("res://assets-processed/guest_avatars/%s_%s.png" % [gid, emotion_id])` + `avatar_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE` + `avatar_tex.stretch_mode = TextureRect.STRETCH_SCALE` + `avatar_tex.set_anchors_preset(Control.PRESET_FULL_RECT)` + `_avatar_panel.add_child(avatar_tex)`.
4. **emotion 결정 규칙** (game state context):
   - Selection screen (`guest_card_v2.gd` 현재 위치) = `emotion = "neutral"` 고정
   - Result screen (compat tier 따라) = `compat >= 90 ? "excited" : compat >= 60 ? "happy" : compat >= 30 ? "neutral" : "disappointed"`
   - friend reaction overlay (game-designer 후속 확정 시) = trigger 따라 happy/excited/disappointed
5. **L143-154 initial Label은 fallback으로 유지** (texture load 실패 시만 표시).

---

## 6. 변경 이력

- **2026-06-04 v1.24** (Phase B + C guest avatar 5 + 15 = 20장 prompt set §5.15 신설 — 친구 NPC 시스템 art LOCK 진입, supersedes v1.23) — `godot-project/scripts/ui/components/guest_card_v2.gd`가 AVATAR_TINT 단색 placeholder만 사용 중인 상태에서 5 guest art LOCK 진입. Phase B = 5 guest neutral generation (prompt-only, anchor seed) + Phase C = 5 guest × 3 emotion (happy/excited/disappointed) image edit variants (Phase B neutral output base lock). 5 guest = junho 호방 매콤 매니아 / mina 단맛 발랄 / riley 외국인 산뜻함 (유일하게 비-Korean identity 디자인 의도) / mrs_lee 멘토 따뜻한 집밥파 (CH-02 mother와 명확 차별 CRITICAL: permed wavy hair + reading glasses signature + mauve+beige NOT persimmon red jeogori) / seoyeon 집밥파 따뜻. 4 emotion = neutral (정상 dot eyes + 살짝 arc smile, anchor seed) / happy (closed crescent + 1-2 sparkle, R-02/R-05 톤) / excited (GIANT closed-arc + WIDE open with teeth/tongue hint + 양손 raised + 3-5 sparkle + 1-2 star + 2-3 motion line, R-03/R-06 코믹 톤) / disappointed (LOWERED EYEBROWS HERO cue + SUBTLE DOWNTURNED closed mouth + slight head tilt down-away + optional 1 sweat drop or "..." icon — subtle mature adult, NOT crying tears, NOT teardrop falling, R-01/R-04 v1 deprecated sad teardrop 명시적 회피). v1.24 = (a) **§5.15 신설 Phase B + C guest avatar 20장 prompt set** (§5.15.1 매핑 표 + §5.15.2 STYLE_SUFFIX_GUEST_AVATAR 핵심 시그니처 + §5.15.3 5 guest identity 한 줄 요약 + §5.15.4 4 emotion 한 줄 요약 + §5.15.5 2-pass driver pattern + §5.15.6 cross-호환 운영 + §5.15.7 risk top 3 + §5.15.8 main thread 실행 명령 + §5.15.9 godot-dev 후속 swap spec). (b) **§2.6에 STYLE_SUFFIX_GUEST_AVATAR 명시** = bust-up portrait + chibi 1:1.7 + Cool Sage `#C8D5C0` solid bg + slim outline 2-3px + modern saturated 80-90% + light pink cheek #FFCFCF (R-01~06 동일 톤) + 가정 family IP CH-01/CH-02/CH-03 누수 회피 명시 (guest는 family 아닌 친구 NPC) + cross-cultural negative (Japanese kimono / Chinese qipao / Western lederhosen — Riley 예외 = 외국인 identity 명시) + anime girl big sparkly pupils 회피 + sad teardrop/crying 회피 (disappointed는 subtle eyebrow+frown). (c) **§0 anchor 표 GUEST-* 20 row 추가** (5 guest × 4 emotion = 20 row, 모두 pending Phase B or Phase C). (d) **새 driver script `tools/gen_guest_avatars.py` 신설** — `tools/edit_reaction_anchors_v3.py` template 기반 + 2-pass 패턴 (Phase B `client.images.generate()` prompt-only + Phase C `client.images.edit(model="gpt-image-1", image=open(neutral_base, "rb"), prompt=COMMON_FRAME + emotion_expression + STYLE_SUFFIX_GUEST_AVATAR, size, quality, n=1)`) + GUESTS list 5개 inline (id / display_name / personality / identity_prompt) + EMOTIONS_PHASE_B list 1개 + EMOTIONS_PHASE_C list 3개 inline + STYLE_SUFFIX_GUEST_AVATAR 상수 inline + build_prompt_phase_b / build_prompt_phase_c 2 합성 함수 + ensure_edit_compatible_size + inspect_base_image + edit_image (edit_reaction_anchors_v3 동일 패턴) + run_phase_b + run_phase_c + CLI args (`--phase B|C|ALL` `--only guest_id` `--emotion happy|excited|disappointed` `--quality` `--version` `--out-dir`) + gpt-image-1 medium 1024×1024 default + 출력 default `assets-raw/guest_avatars_m1/{guest_id}_{emotion}_v1.png`. main thread 실행 명령: (1) Phase B test `--phase B --only junho --quality medium` (1장 ~$0.05, ~30초, junho = anchor seed for risk top guest) → 시각 확인 후 (2) Phase B 5장 batch `--phase B --quality medium` (5장 ~$0.21, ~2-3분) → LOCK 후 (3) Phase C 15장 batch `--phase C --quality medium` (15장 ~$0.63, ~5-7분) — 또는 (4) 전체 ALL 20장 `--phase ALL --quality medium` (20장 ~$0.84, ~7-10분, 출력 `assets-raw/guest_avatars_m1/{guest_id}_{emotion}_v1.png`). 2-pass 이유 = Phase B prompt-only neutral은 anchor seed 역할 (각 guest identity 시각 정착) + Phase C image edit = neutral base에서 표정만 변경하여 family IP (hair/outfit/face proportions) 정확 재현 (R-01~06 v3 image edit 패턴 입증). ChatGPT 약점 risk top 3 = (1) 한식↔Japanese chibi 누수 ~40% (특히 mina pastel pink sweater + side ponytail이 Japanese anime girl 학생 톤으로 누수 risk → STYLE_SUFFIX_GUEST_AVATAR에 "anime girl, manga style, school uniform" 명시 강제 + identity_prompt에 "Korean young adult female in her 20s, NOT student" 명시) / (2) Western character 누수 ~35% Riley 제외 (junho/mina/mrs_lee/seoyeon 4 guest는 Korean identity 강제, ChatGPT default가 글로벌 cartoon character로 누수 risk → identity_prompt에 "Korean" 명시 + dark brown hair tone 명시 + Korean modern casual streetwear 명시. Riley는 예외 = "non-Korean foreign 외국인" 명시적 OK, 그래도 cosmopolitan 친구 톤 유지 NOT cowboy/Western caricature) / (3) anime girl big sparkly eyes 누수 ~30% (excited emotion에서 sparkle eyes alternative가 enlarged shoujo pupils로 누수 risk → "sparkle accents stay SEPARATE floating geometric icons OUTSIDE the eye, NOT enlarged shoujo pupils inside" 명시 강제). 부차 risk = mrs_lee가 CH-02 mother와 시각 confused ~30% (identity_prompt CRITICAL 절 "Mrs Lee must look CLEARLY DIFFERENT from CH-02 family mother — permed wavy NOT round-bun + glasses + mauve+beige NOT persimmon red jeogori" 강제) / disappointed emotion sad teardrop 누수 ~25% (ChatGPT default가 disappointed → crying으로 추론 risk → emotion prompt CRITICAL 절 "subtle eyebrow + downturned closed mouth + NO tears NOT crying" 명시 강제) / excited emotion goofy Looney Tunes 누수 ~25% (★3 explosive peak이 폭주 risk → "Royal Match aesthetic + K-drama reaction tone, NOT slapstick" 명시 강제). **G_guest_avatar 평가 게이트** = art-anchor-rubric v1.23 §5.15에서 정의 (G_guest_avatar 5 요소 = family IP consistency 5 guest 일관 + emotion gradient 4 단계 명확 + bust-up portrait chibi 1:1.7 + Cool Sage bg cross-asset + cross-cultural 누수 0건). **godot-dev 후속 swap spec** = guest_card_v2.gd L27-32 `AVATAR_TINT` dict는 fallback 보존 + L109-124 avatar_panel 내부에 TextureRect 신규 추가 + `load("res://assets-processed/guest_avatars/%s_%s.png" % [gid, emotion_id])` 동적 load + emotion 결정 (selection screen = neutral / result screen = compat tier 따라 happy/excited/neutral/disappointed) + assets-processed/guest_avatars/ 디렉터리 신설 + 240×240 또는 180×180 game size crop + rembg transparent post-process (ADR-007). 음식 12 / 환경 5 v4 / 캐릭터 5 / cut 7 / ingredient whole 12 / reaction 6 / ingredient cut 12 / 조리도구 12 / UI 7 / VFX 5 / mini extra 2 본문 무변경 (Phase B+C는 추가 art only, 기존 LOCK status 무영향).
- **2026-05-31 v1.23** (M1 후반 art sprint mini extra — game-designer motion-spec 후속 asset gap 2건 [hand_marinade + corndog_batter_bowl] §5.14 신설, supersedes v1.22) — game-designer motion-spec 후속에서 (a) F-09 불고기 Stage 2A 양념재우기 mechanic은 손바닥 press motion (위→아래 tap)이 dominant action이나 hand sprite anchor 부재 / (b) F-06 콘도그 Stage 2A는 dip substitute (콘도그 stick을 batter에 담그기) mechanic이 dominant이나 batter bowl anchor 부재 — 두 gap 발견. cut/tool/ingredient/UI/VFX 6 cluster (49 anchor) 외 누락된 mini extra 2장 추가 (49 → 51 anchor cluster). **§5.14 신설 mini extra 2장 prompt set** (§5.14.0 매핑 표 + §5.14.1 STYLE_SUFFIX_MINI driver note + §5.14.2 EX-01 hand_marinade + §5.14.3 EX-02 corndog_batter_bowl + §5.14.4 cross-호환 운영 + §5.14.5 약점 risk top 5 + §5.14.6 driver script 실행 명령 + §5.14.7 game-designer 후속 confirm 사안). 각 mini extra prompt = 단독 sprite + chibi friendly tone + slim outline 2-3px + Cool Sage `#C8D5C0` bg + ambient ellipse shadow 유지 (diegetic prop이라 UI/VFX와 차별점 — UI/VFX는 HUD overlay이라 shadow 없음, mini extra는 in-scene prop이라 shadow 있음) + TOOL/CUT/INGREDIENT/FOOD cluster 일관성. **§2.5에 STYLE_SUFFIX_MINI 명시** = 단독 sprite + Cool Sage bg + 7/8 perspective + Cookingo-inspired flat clean + chibi friendly tone + realistic human anatomy 회피 (NO detailed knuckles / veins / fingerprints / nail beds / palm creases / hand hair / age spots / jewelry — keep simple chibi mitten-friendly silhouette) + character body 회피 (hand sprites = hand + minimal wrist stub only, NO arm/elbow/shoulder/body/face). **§0 anchor 표 EX-01/EX-02 2 row 추가** (pending M1 후반 mini extra). **새 driver script `tools/gen_mini_extra_m1.py` 신설** — `tools/gen_tool_anchors_m1.py` template 기반. 구조 = (1) STYLE_SUFFIX_MINI inline (chibi friendly tone + Cool Sage bg + ambient shadow 유지 + realistic anatomy 회피 + character body 회피 + Japanese/Chinese/Western cultural cookware 회피) / (2) EXTRAS list 2개 항목 inline (id=slug / name=slug / usage=game-designer motion-spec mapping / body) / (3) build_prompt body `.replace("%s", STYLE_SUFFIX_MINI, 1)` (gen_food/gen_ingredient/gen_reaction/gen_tool/gen_ui_vfx에서 발생했던 `body % SUFFIX` Python old-style ValueError fix 적용) / (4) CLI args `--only` `--version` `--model` `--quality` `--out-dir` / (5) gpt-image-1 medium 1024×1024 default, dall-e-3 option 보존 / (6) 출력 default `assets-raw/mini_extra_m1/<name>_v1.png`. 2장 prompt body 핵심 (각 한 줄 시그니처): **hand_marinade** = single open palm 7/8 view palm-down + warm peachy skin #F5C9A2 + 4 fingers close-together ready-to-press + short wrist stub + 1-2 subtle downward motion lines + slim warm dark outline + ambient ellipse shadow + NOT realistic hand (NO knuckle wrinkles/veins/fingernails/palm creases/hair/jewelry) + NOT full arm (hand + wrist stub only, NO elbow/shoulder/body/face) + NOT clenched fist / thumbs-up / pointing finger / pinch grip / hand-shake / hand-holding-utensil / glove / character portrait. **corndog_batter_bowl** = clean matte white round ceramic mixing bowl ~26-30cm × 11-13cm + NO handles + filled with viscous light tan/golden cornmeal-wheat batter #E8C58A 65-75% depth + elliptical batter pool surface in 7/8 view + subtle slim batter meniscus at inner rim + ONE specular highlight (glossy wet batter sheen) + slim warm dark outline + ambient ellipse shadow + NO corn dog stick dipping (food layer runtime composited) + NOT TOOL-11 silver-gray bibimbap mixing bowl (TOOL-11 is stainless larger 28-32cm empty — this is matte white ceramic smaller filled with batter) / NOT TOOL-02 yangun pot (yangun has 2 ear handles + empty — this has no handles + filled with batter) / NOT TOOL-04 deep fryer (deep fryer has 2 ear handles + golden oil — this has no handles + viscous batter) / NOT soup bowl / NOT pancake batter (corndog is thicker viscous, pancake is runnier) / NOT cake batter with whisk inside / NOT dough kneading bowl with solid dough / NOT Japanese donburi / NOT Chinese decorative ceramic. main thread 실행 명령: (1) test (가장 risk 높은 hand_marinade 우선 권장): `py tools/gen_mini_extra_m1.py --only hand_marinade --quality medium` (1장 × $0.042 ≈ $0.04, ~30초) → 시각 확인 후 (2) 2장 batch: `py tools/gen_mini_extra_m1.py --quality medium` (2장 × $0.042 ≈ $0.08, ~1-2분, 출력 `assets-raw/mini_extra_m1/hand_marinade_v1.png` + `corndog_batter_bowl_v1.png`). 또는 batter bowl만: `--only corndog_batter_bowl`. ChatGPT 약점 risk top 5 = (1) hand_marinade realistic hand anatomy 누수 ~50% (knuckle wrinkles + veins + fingernail beds + palm creases + hair + jewelry → chibi friendly + explicit negative 강제) / (2) hand_marinade full arm 누수 ~40% (elbow/upper arm/shoulder/character body까지 → wrist stub only explicit 강제) / (3) corndog_batter_bowl TOOL-11 mixing bowl과 시각 동일 누수 ~40% (silver-gray stainless 추론 → matte white ceramic + filled with batter explicit 강제로 시각 분리) / (4) hand_marinade thumbs-up 누수 ~25% (R-05/R-06 cross-asset 영향 → thumb tucked along side + NOT thumbs-up explicit 강제) / (5) corndog_batter_bowl pancake batter pourable runny 누수 ~25% (얇은 액체 batter 추론 → viscous thick consistency explicit 강제). **driver 옵션 결정 사유** = 옵션 1 (별도 driver `gen_mini_extra_m1.py` 신설) 채택 vs 옵션 2 (`gen_tool_anchors_m1.py` extend TOOL-13/14 추가). 옵션 1 선택 사유 = (i) 카테고리 분리 명확 (TOOL은 조리도구 cluster, mini extra는 hand/specialty container cluster — 의미적으로 다름), (ii) 이후 추가 mini asset (small one-off prop / hand pose / specialty container 등 game-designer motion-spec 후속 raise) 확장 자연스러움 (sprint 종료까지 본 driver의 EXTRAS list에 append 방식 확장), (iii) STYLE_SUFFIX_MINI 차별점 (hand sprite의 realistic anatomy 회피 negative + chibi mitten-friendly tone은 TOOL의 industrial restaurant gear 회피 negative와 의미적으로 다름). 음식 12 / 환경 5 v4 / 캐릭터 5 / cut 7 / ingredient whole 12 / reaction 6 / ingredient cut 12 / 조리도구 12 / UI 7 / VFX 5 본문 무변경.
- **2026-05-30 v1.18** (M1 후반 reaction 6컷 v2 image edit — CH-02/CH-03 base + 표정만 변경, 사용자 R1 v1 피드백 2건 fix [어머니 R-01/R-03 hair mismatch + 아버지 R-04/R-05/R-06 family IP inconsistency], supersedes v1.17) — 사용자가 v1 (`tools/gen_reaction_anchors_m1.py` prompt-only generation, gpt-image-1 medium 1024×1024 6장 batch) 결과 시각 확인 후 verbatim "reaction 에서 R-01, R-03가 원래 이미지와 좀 다름, 그리고, R-04, R-05, R-06가 이미지가 좀 일관성이 없음" 2건 피드백 raise. main thread 시각 분석: (a) R-01/R-03 어머니 hair shape mismatch (v1 round-bun + side-puff vs CH-02 base round-bun simple) / (b) R-04 vs R-05/R-06 아버지 family IP inconsistency (R-04 darker hair+shirt vs R-05/R-06 lighter tone). prompt-only가 base의 family IP를 정확 재현 못함을 확인 → **gpt-image-1 image edit API** (BG sprint v4에서 효과 입증된 패턴) 도입. **§5.7 본문 전면 재작성** (v1.16 prompt-only 본문은 §5.7.archive v1 deprecated 절로 이동 보존). v2 approach = `client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_FRAME + expression_prompt, size="1024x1024", quality="medium", n=1)`: (a) CH-02_mother.png base 직접 입력 (R-01/R-02/R-03) / (b) CH-03_father.png base 직접 입력 (R-04/R-05/R-06) + COMMON_FRAME (family IP IDENTICAL 강제 + 어머니 hair = round-bun simple 명시 + 아버지 hair tone + shirt tone base와 EXACTLY 일치 NOT lighter 명시 + bust-up crop + Cool Sage bg + 표정만 변경 명시 + sad/sleeping/Japanese kimono/anime girl 회피 negative) + 6 expression_prompt (★1/★2/★3 어머니 + 아버지 각각 specific). 사용자 v1 피드백 2건 1:1 fix. **§0 anchor 표 R-01~R-06 row 6장 status 갱신** (v1 prompt-only deprecated 2026-05-30 → v2 image edit pending). **새 driver `tools/edit_reaction_anchors_v2.py` 신설** — `tools/edit_bg_anchors_v4.py` template 기반 (image edit API + base image dimensions 검증 + PIL resize fallback + b64_json 응답 처리). 구조 = (1) COMMON_FRAME 상수 inline (single source) / (2) REACTIONS list 6개 inline (id / name / character / star / base / expression_prompt) / (3) base image 사전 검증 (CH-02/CH-03 2장만) / (4) CLI args (`--only` `--version` `--quality` `--out-dir`) / (5) gpt-image-1 medium 1024×1024 default, version v2 default. v1 prompt-only driver (`tools/gen_reaction_anchors_m1.py`)는 보존 (git history). v1 output 6장도 보존 (v2와 공존). main thread 실행 명령: (1) test `py tools/edit_reaction_anchors_v2.py --only R-01 --quality medium` (1장 ~$0.05, ~30초) → (2) batch `py tools/edit_reaction_anchors_v2.py --quality medium` (6장 × $0.042 ≈ $0.25, ~2-3분, 출력 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v2.png`). 또는 어머니만 `--only R-01,R-03` / 아버지만 `--only R-04,R-05,R-06`. v2 risk top 3 = base의 default expression 유지 ~25% / bowl prop carry over ~20% / R-04 ★1 thumb-up carry over ~30% (prompt explicit "NO thumb-up" 회피). **R3 fallback (사용자 ChatGPT 웹 UI 수동 chain-of-references)** = v2 결과가 여전히 family IP/gradient 부족하면 사용자 수동 워크플로 (CH-02/CH-03 upload + seed lock + ★1/★3 follow-up + CH-05 추가 reference for R-06). 음식 12장 / 환경 5장 v4 / cut anchor 7장 / ingredient whole 12장 / 캐릭터 5장 본문 무변경.
- **2026-05-30 v1.17** (mvp-food-selection v2.2 sync — F-02 호떡 → 잔치국수 + F-09 김치찌개 → 불고기 음식 anchor 2장 + ING-02/ING-09 ingredient anchor 2장 전면 교체, supersedes v1.16) — game-designer가 2026-05-28 mvp-food-selection v2.1 → v2.2 갱신 완료 (F-02 호떡 → 잔치국수 T1 — 곡물+잡화+어물+청과 4가게 순회 / F-09 김치찌개 → 불고기 T2 — 정육+청과+잡화). game-designer hero ingredient 매핑 = F-02 hero 소면 (white wheat thin noodle, 부 hero 멸치/김/애호박/대파) / F-09 hero 얇은 소고기 (thin-sliced marbled sirloin fanned, 부 hero 양파/대파/당근/표고). art-director는 본 v1.17에서 (a) **§5.2 F-02 본문 전면 교체** (호떡 → 잔치국수 Janchi-guksu, hero = 소면 white wheat thin noodles + 멸치 dashi clear LIGHT GOLDEN-AMBER broth + 계란 지단 yellow ribbon strips + 김 julienned strips + 애호박 zucchini garnish + 멸치 dried anchovy minor accent + optional 빨간 고추 slice; 넓고 얕은 흰 baekja shallow bowl; cross-cultural negative critical — NOT Japanese somen tsuyu cold dipping with ice + separate cup / NOT Japanese udon thick chunky / NOT Japanese ramen curly yellow + miso/tonkotsu/shoyu + narutomaki/chashu/nori sheet / NOT Japanese soba buckwheat brown-gray / NOT Vietnamese pho cinnamon-clove beef broth + lime/sprouts/basil/cilantro herbs + sliced beef / NOT Chinese egg noodle soup or wonton soup. **F-01 라면 vs F-02 잔치국수 차별화**: 둘 다 noodle soup이지만 F-01 spicy red gochugaru + curly yellow noodles + sunny-side-up egg + spring onion, F-02 OPPOSITE = clear gentle anchovy broth + thin white wheat noodles + egg ribbon strips + gim strips. 호떡 본문은 deprecated archive 보존) / (b) **§5.2 F-09 본문 전면 교체** (김치찌개 → 불고기 Bulgogi, hero = 얇은 marbled 소고기 thin-sliced sirloin 5-7 fanned slices each ~6-10cm × ~4-6cm × ~2-3mm paper-thin + GLOSSY BROWN soy-pear-garlic marinade pool 간장+배+마늘+설탕+참기름 양념 + 양파 onion half-moon slices + 대파 scallion segments + 당근 carrot julienne + 표고/느타리 mushroom slices + optional 당면 dangmyeon strands mixed in SAME dark cast-iron Korean BBQ pan; 깨 generous sprinkle + 송송 sliced 대파 chopped rounds garnish; **CRITICAL F-12 갈비 차별화** — NO BONE-IN LA CUT, NO visible white rib bone, NO bone cross-section discs along strips, NOT grilled on wire mesh grill grate over hot coals, NOT large 18-25cm LA strips, NOT separated meat strips. cross-cultural negative — NOT Japanese sukiyaki raw egg dipping bowl + deeper broth bath + square iron pan + napa cabbage dominant / NOT Japanese shabu-shabu clear simmering broth + dipping sauce setup / NOT Japanese yakiniku grilled boneless on tabletop grate / NOT Chinese beef stir-fry wok hei + cornstarch sauce + Chinese vegetable set / NOT American BBQ red sauce + thick slab + bone-on-side / NOT Korean Kimchi Jjigae F-09 deprecated (vibrant red-orange gochugaru + ttukbaegi + 두부 tofu cubes — 완전 다른 visual). 김치찌개 본문은 deprecated archive 보존) / (c) **§5.6.2 ING-02 본문 전면 교체** (peanut R1 archive + 흑설탕 brown_sugar R2 archive → 소면 somen v1.17 신규. 소면 = single small BUNDLE of dry SOMEN-STYLE white wheat noodles ~18-22cm × 4-5cm × 15-25 fine parallel slim ~1-2mm strands clean off-white #F5F0E0-#FAFAFA + PLAIN white/cream paper band tied at center NO printed text + two ends fanning slightly + optional 2-3 stray loose strands beside bundle; cross-cultural negative — NOT Japanese DECORATIVE PINK-AND-WHITE paper band / NOT 노란 Chinese egg noodles / NOT Italian spaghetti rigid 2-3mm / NOT 일본 udon thick chunky / NOT Korean ramyeon curly yellow egg; cut 없음, 칼 LEFT side static per cross-asset convention. peanut R1 본문 + brown_sugar R2 본문 모두 deprecated archive 보존) / (d) **§5.6.9 ING-09 본문 전면 교체** (firm tofu R1 archive → 얇은 raw 소고기 thin-sliced marbled beef v1.17 신규. 얇은 소고기 = STACK or FANNED arrangement of 5-7 THIN sliced raw marbled beef sheets each ~8-12cm × 5-7cm × 2-3mm paper-thin + PINK-RED RAW BEEF base #C44545-#B82F2F + VISIBLE WHITE MARBLED FAT VEINS #F0E8D8 scattered ~3-5 organic irregular marbling lines per slice + slight diagonal FAN slight overlap top 2-3 slices offset showing cross-section edges underneath + ~2-3mm THIN slice cross-section visible on side + subtle slim cel shading + ONE specular highlight (fresh moist raw beef sheen); **CRITICAL F-12 갈비 차별화** — NO BONE-IN LA CUT, NO bone visible, NO bone cross-section discs, NOT grilled or cooked brown (RAW pink-red state), NOT thick steak slab; cross-cultural negative — NOT Japanese wagyu A5 extreme intricate marbling + premium plating / NOT sukiyaki beef on decorative platter + raw egg dipping bowl + 다른 vegetable / NOT bacon parallel striped white-pink bands / NOT salami cured uniform / NOT 삼겹살 thick alternating layered stripes; cut 없음, 칼 LEFT side static per cross-asset convention; 게임 prep mechanic = 양념재우기 marinade application NOT chopping. firm tofu R1 본문 deprecated archive 보존). **§0 anchor 표 4 row 갱신**: F-02 row (Hotteok → Janchi-guksu T1 v1.17 pending v9, 호떡 deprecated 2026-05-30 mvp v2.2 trigger) / F-09 row (Kimchi Jjigae → Bulgogi T2 v1.17 pending v9, 김치찌개 deprecated 2026-05-30 mvp v2.2 trigger + F-12 갈비 차별화 CRITICAL NO bone-in LA cut) / ING-02 row (peanut R1 + brown_sugar R2 deprecated → somen pending v3 v1.17 mvp v2.2 trigger 호떡 → 잔치국수) / ING-09 row (firm tofu R1 deprecated → thin marbled beef pending v3 v1.17 mvp v2.2 trigger 김치찌개 → 불고기 + F-12 갈비 차별화 CRITICAL NO bone visible + RAW NOT cooked). 다른 8 음식 anchor (F-01/F-03/F-04/F-05/F-06/F-07/F-08/F-10/F-11/F-12) + 10 ingredient anchor (ING-01/ING-03/ING-04/ING-05/ING-06/ING-07/ING-08/ING-10/ING-11/ING-12) + cut anchor 7장 (CUT-00~06) + 환경 5장 (BG-01~05 v4) + 캐릭터 5장 (CH-01~05) + reaction 6컷 (R-01~06) 본문 **전면 무변경** (LOCK status 유지). **driver script `tools/gen_food_anchors_m1.py` FOODS list F-02 item name (hotteok → janchi_guksu) + F-09 item name (kimchi_jjigae → bulgogi) + body inline 전면 갱신 + docstring v1.17 sync** (v1.17 sync 절 신설). **driver script `tools/gen_ingredient_anchors_m1.py` INGREDIENTS list F-02 item name (brown_sugar_whole → somen_whole) + food (Hotteok → Janchi-guksu) + cut_style (no cut, sprinkle/scoop filling → no cut, noodle prep — sprinkle/serve) + body inline 전면 갱신 + F-09 item name (firm_tofu_whole → thin_beef_whole) + food (Kimchi Jjigae → Bulgogi) + cut_style (CUT-06 깍둑썰기 → no cut, 양념재우기 marinade prep mechanic — raw before marinade state) + body inline 전면 갱신 + docstring v1.17 sync** (v1.17 sync 절 신설). main thread 실행 명령 = (1) **음식 anchor 2장**: `py tools/gen_food_anchors_m1.py --only F-02,F-09 --version v9 --model gpt-image-1 --quality medium` (2장 × $0.042 ≈ $0.08, ~30-60초, 출력 `assets-raw/food_anchors_m1/F-02_janchi_guksu_v9.png` + `F-09_bulgogi_v9.png` — version v9 = previous F-01~F-11 R1~R7 / F-12 R7 version과 충돌 회피 + F-02/F-09 mvp v2.2 신규 첫 generation 명시 식별 가능) / (2) **ingredient anchor 2장**: `py tools/gen_ingredient_anchors_m1.py --only F-02,F-09 --version v3 --model gpt-image-1 --quality medium` (2장 × $0.042 ≈ $0.08, ~30-60초, 출력 `assets-raw/ingredient_anchors_m1/F-02_somen_whole_v3.png` + `F-09_thin_beef_whole_v3.png` — version v3 = previous v1 peanut/brown_sugar/firm_tofu / v2 (있다면) 회피 + F-02/F-09 mvp v2.2 신규 generation 식별 가능). **총 4장 × $0.042 ≈ $0.17, ~2분**. ChatGPT 약점 risk top 5 갱신 = (1) 잔치국수 Japanese somen tsuyu cold 누수 ~50% / (2) 잔치국수 Vietnamese pho 누수 ~30% / (3) 불고기 Japanese sukiyaki raw egg dipping 누수 ~50% / (4) 불고기 F-12 갈비 bone visible cross-contamination ~40% CRITICAL / (5) 소면 Japanese pink-white decorative band 누수 ~40% / (6) 얇은 소고기 Japanese wagyu extreme marbling 누수 ~40% / (7) 얇은 소고기 cooked brown 누수 ~30% (이 anchor는 RAW state). 음식 12 평가 표 §0 + §5.4 risk top 5 부분 갱신 (F-12 R7 LOCK candidate / F-04/F-01/F-03/F-05/F-06 LOCK 유지 status 무변경, F-02/F-09 신규 pending status).
- **2026-05-30 v1.15** (M1 후반 art sprint 2번째 — 음식 12 × hero ingredient whole anchor 12장 prompt set 신설 §5.6 full prompts + §5.5.0 음식↔cut 매핑 표 추가, ADR-005 Stage 2A "before"-cut pair, supersedes v1.14) — M1 후반 art sprint 1번째 (cut anchor 7장 LOCK 완료) 후 2번째 sprint 진입. ADR-005 Stage 2A 재료 준비 미니게임은 음식별 hero ingredient를 적절한 cut style로 자르는 형태 → 음식 12 × hero ingredient 매핑 + whole(자르기 전) state asset이 필요. **§5.5.0 음식 12 × hero ingredient × cut style 매핑 표 신설** (임시; game-designer foods CSV `prep_*` 후속 확정 시 일부 reroll 가능): F-01→대파/CUT-05, F-02→견과류/CUT-01, F-03→단무지/CUT-02, F-04→어묵/CUT-03, F-05→김치/CUT-01, F-06→모짜렐라/(no cut), F-07→대파 daepa/CUT-03, F-08→당근/CUT-02, F-09→두부 firm/CUT-06, F-10→두부 soft/(no cut), F-11→당근/CUT-02(F-08 재사용 가능), F-12→마늘/CUT-01. cut style 분포 = mince 3 / julienne 3 / diagonal 2 / sliced_rounds 1 / cube 1 / no cut 2 / whole-disc(통썰기) 0 — CUT-04는 hero ingredient cut prep 매핑 없음 (game-designer 검증 필요). **§5.6 신설 ingredient whole 12장 prompt set** (§5.6.0 single source = driver script note + §5.6.1~§5.6.12 12개 항목 식별 핵심 시각 요소/reroll trigger/약점 회피 요약 + §5.6.13 cross-호환 운영 + §5.6.14 약점 risk top 5 + §5.6.15 driver script 실행 명령 + §5.6.16 game-designer 후속 confirm 사안 12행 표). 각 ingredient는 도마 위 center-right placement + 칼 LEFT side static + WHOLE/UNCUT state (cut pieces scattered 회피). **§2.5에 STYLE_SUFFIX_INGREDIENT note 추가** = STYLE_SUFFIX_CUT 재활용 + INGREDIENT PLACEMENT 절 추가 (driver script `tools/gen_ingredient_anchors_m1.py` `STYLE_SUFFIX_INGREDIENT` 상수가 single source of truth). **§0 anchor 표 ING-01~12 row 12개 추가** (pending M1 후반 2번째 sprint, ING-11은 F-08 재사용 확정 시 archive note). **새 driver script `tools/gen_ingredient_anchors_m1.py` 신설** — `tools/gen_cut_anchors_m1.py` template 기반. 구조 = (1) STYLE_SUFFIX_INGREDIENT inline (cut suffix 재활용 + INGREDIENT PLACEMENT 절 추가 + cut pieces scattered 회피 negative) / (2) INGREDIENTS list 12개 항목 (id=food_id / name=ingredient_slug / food=food_name_en / cut_style=cut_style_id / body) inline / (3) build_prompt body % STYLE_SUFFIX_INGREDIENT 자동 append / (4) CLI args `--only` `--version` `--model` `--quality` `--out-dir` (cut anchor와 동일 패턴) / (5) gpt-image-1 medium 1024×1024 default, dall-e-3 option 보존 / (6) 출력 default `assets-raw/ingredient_anchors_m1/<food_id>_<ingredient_name>_v1.png`. main thread 실행 명령: `py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium` (12장 × $0.042 ≈ $0.50, ~4-5분, 출력 경로 `assets-raw/ingredient_anchors_m1/`). 시각 risk top 5 = ING-03 단무지 (백색 daikon/banana 누수 ~50%) / ING-04 어묵 (Japanese naruto/chikuwa ~50%) / ING-07 daepa (F-01 spring onion 변종으로 추론 ~40%) / ING-06 모짜렐라 (cheddar/두부 누수 ~40%) / ING-12 마늘 (whole bulb/양파 누수 ~35%). 음식 12장 F-01~F-12 본문 무변경 (LOCK status 유지). 캐릭터 5장 / 환경 5장 v4 / cut anchor 7장 본문 무변경. §5.5.10 placeholder는 §5.6 신설로 supersede note. §5.7 양친 reaction (이전 §5.6) 번호 shift / §5.8 UI/VFX (이전 §5.7) M2로 격리.
- **2026-05-29 v1.14** (M1 후반 sprint 진입 — 칼/도마 base anchor 1장 + cut style 6종 prompt set 신설 §5.5 full prompts, ADR-005 Stage 2A rhythm tap prerequisite, supersedes v1.13) — M1 anchor 22/22 LOCK 완료 (음식 12 + 환경 5 + 캐릭터 5, commit dfb141e) 후 M1 후반 art sprint 진입. **ADR-005 Stage 2A 재료 준비 = rhythm tap + Knife indicator** prerequisite로 칼/도마 base + cut style 6종 anchor가 필요. **§2.5 STYLE_SUFFIX_CUT 신설** — 모든 cut anchor 공통 suffix (square 1:1, top-down view, Korean cutting board + knife 통일 silhouette description, Cool Sage `#C8D5C0` bg, modern saturated 80-90%, slim outline 2-3px). negative = Japanese kitchen knife (santoku/deba/yanagiba single-bevel asymmetric blade + kanji), Chinese cleaver (rectangular tall blade), Western chef knife (large triangular blade with bolster), mortar and pestle (절구), traditional Korean stone tools (replaced by knife + cutting board per ADR-005 Stage 2A direct gameplay mechanic mapping). **이전 §2.5 anchor consistency 운영 규칙 → §2.6으로 번호 shift**. **§5.5 placeholder → full prompts 확장** (cutting_board base 1장 + cut_style_mince/julienne/diagonal/whole/sliced_rounds/cube 6장 = 총 7장). 각 cut style은 **cutting RESULT state** (cut된 결과 상태, NOT cutting action mid-motion) — 게임 asset 사용 형태로 도마 + cut된 재료 + 칼 옆에 놓임. 시그니처 재료 매핑 = (a) **mince (다지기) → 마늘** (F-12 갈비/F-09 김치찌개, BPM 140 가장 빠름, fine irregular bits 1-3mm) / (b) **julienne (채썰기) → 당근** (F-08 비빔밥/F-11 잡채, thin elongated matchstick strips 4-6cm × 2-3mm × 2-3mm) / (c) **diagonal (어슷썰기) → 어묵+대파** (F-04 떡볶이/모든 국물, elongated oval shapes — 어묵 5-7cm long diagonal × 2-3cm wide + 대파 3-4cm long diagonal × 1-1.5cm wide) / (d) **whole (통썰기) → 김밥 cylinder 단면** (F-03, BPM 70 가장 느림, perfect round disc 3cm 지름 × 1.5-2cm thick + 5색 cross-section) / (e) **sliced_rounds (송송썰기) → 대파** (F-12 갈비 hero garnish/모든 가니쉬, small thin round discs 1-1.5cm × 1-3mm + scallion ring pattern) / (f) **cube (깍둑썰기) → 두부** (F-09 김치찌개/F-10 순두부 contrast, small equal-sided cubes 2-2.5cm × 2-2.5cm × 2-2.5cm + 3D volume hint). 각 cut anchor prompt = 식별 핵심 시각 요소 (시그니처 재료 + cut shape + 두께 + 배치) + Tier comparison (다지기↔통썰기 / 통썰기↔송송썰기 spectrum) + 본문 prompt (cutting RESULT state + 도마 위 칼 LEFT side 통일) + reroll 트리거 3-5종 (cross-cut style 누수 + cross-cultural 누수 회피). §5.5.8 **cut anchor 7장 cross-호환 운영** (CUT-00 anchor seed → CUT-01~06 reference upload + 일관성 instruction). §5.5.9 **ChatGPT 약점 risk top 3** (CUT-04 통썰기 Japanese maki sushi ~50% / CUT-06 깍둑썰기 Chinese mapo tofu ~40% / CUT-00~06 Japanese kitchen knife santoku/deba ~30%). §5.5.10 ingredient cut variation M2 sprint placeholder. **§0 anchor 표 cut anchor 7장 row 추가** (CUT-00 ~ CUT-06, pending M1 후반 status). **새 driver script `tools/gen_cut_anchors_m1.py` 신설** — `tools/gen_food_anchors_m1.py` template 기반. 구조 = (1) STYLE_SUFFIX_CUT inline (도마 + 칼 통일 silhouette + Cool Sage bg + modern saturated + slim outline + 한식 negative) / (2) CUTS list 7개 항목 (cutting_board + cut_style_mince/julienne/diagonal/whole/sliced_rounds/cube) inline / (3) build_prompt body % STYLE_SUFFIX_CUT 자동 append / (4) CLI args `--only` `--version` `--model` `--quality` `--out-dir` / (5) gpt-image-1 medium 1024×1024 default, dall-e-3 option 보존 / (6) 출력 default `assets-raw/cut_anchors_m1/<name>_v1.png`. main thread 실행 명령: `py tools/gen_cut_anchors_m1.py --model gpt-image-1 --quality medium` (7장 × $0.042 ≈ $0.29, ~3-4분, 출력 경로 `assets-raw/cut_anchors_m1/`). 음식 12장 F-01~F-12 본문 무변경 (각 LOCK status 유지). 캐릭터 5장 CH-01~05 본문 무변경 (v1.2 lock candidate 유지). 환경 5장 BG-01~05 v4 image edit approach 무변경. **§5.6~§5.7 양친 reaction/UI/VFX는 M2 sprint placeholder 유지**.
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
