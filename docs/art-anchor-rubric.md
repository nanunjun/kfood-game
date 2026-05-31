# Art Anchor Rubric — Week 1 + M1 게이트 평가 표 (modern mobile casual, ChatGPT)

> 버전: **v1.21 (2026-05-31, M1 후반 reaction 6컷 v3 image edit 평가 게이트 §5.9 갱신 — G_reaction v3 5 요소에 코믹 amplification 3축 [눈/입/body+icons] 점검 추가, 사용자 verbatim "reaction을 코믹하게 만드는게 어때? 지금 reaction 이미지는 너무 심심해" trigger, v2 family IP consistency LOCK 유지 + 표정 amplification 평가 강화, §3.6 reaction 평가 표 6 row v3 status 갱신 + §6.20 Decisions Log 신설) — supersedes v1.20**
> 작성자: art-director
> 상위 문서: [`art-style-guide.md` v1.2 §10](art-style-guide.md), [`ai-session-kit.md` v1.3 §M1](ai-session-kit.md), [`prompts-library.md` v1.21 §5.2 §5.6 §5.7 §5.10 §5.11 §6](prompts-library.md)
> 본 문서 범위:
>   - **Week 1**: 캐릭터 5 + 환경 5 + Step 0 후보 2 = 12세트 (§1~§4) — **환경 5장은 v4 image edit (v1.2 base + 지붕만 교체 + frontal view + 5가게 구조 일관성)로 갱신 (§5.6 G_env_v4)**
>   - **M1 음식 12**: F-01~F-12 plated dish hero shot (§5.5 v1.3 신설)
>   - **M1 환경 5 V4 (v1.13 신설)**: BG-01~05 v1.2 base image + gpt-image-1 image edit API + 지붕만 교체 + frontal view (§5.6 G_env_v4 8 요소, G_env_v3 5 요소 deprecated)
>   - **M1 후반 cut anchor 7장 (v1.14 신설)**: CUT-00 cutting_board base + CUT-01~06 cut style 6종 (§5.7 G_cut 5 요소, ADR-005 Stage 2A rhythm tap prerequisite)
>   - **M1 후반 ingredient whole 12장 (v1.15 신설)**: ING-01~12 음식 12 × hero ingredient whole state (§5.8 G_ingredient_whole 5 요소, ADR-005 Stage 2A "before"-cut pair)
>   - **M1 후반 양친 reaction 6컷 (v1.16 신설, v1.18 v2 image edit, v1.21 v3 코믹 amplification)**: R-01~06 어머니/아버지 × ★1/★2/★3 expression gradient (§5.9 G_reaction_v3 5 요소 — v2 family IP LOCK 유지 + 코믹 amplification 3축 [눈/입/body+icons] PASS 기준 추가, Korean variety show / K-drama exaggerated reaction 톤)
>   - **M1 후반 ingredient CUT 12장 (v1.19 신설)**: ICUT-01~12 음식 12 × hero ingredient cut 결과 specific state (§5.10 G_ingredient_cut 5 요소, ADR-005 Stage 2B/2C "after"-cut pair, ingredient whole 12장의 cut 결과 specific)
>   - **M1 후반 조리도구 12종 (v1.20 신설)**: TOOL-01~12 조리도구 12종 (가스레인지/냄비/후라이팬/깊은 튀김냄비/그릴/국자/주걱/뒤집개/집게/김발/mixing 큰 그릇/한식 가위) 각각 별도 sprite (§5.11 G_tool 5 요소, Cookingo: Perfect Meal reference + ADR-005 Stage 2B/2C 조리 mechanic prerequisite + 애니메이션 prerequisite — godot-dev가 AnimationPlayer로 motion 독립 구현 가능하도록 도구별 단독 sprite)
> 본 게이트 통과 = 각 sprint 진입 prerequisite.

> **v1.21 변경 (2026-05-31, M1 후반 reaction 6컷 v3 image edit 평가 게이트 §5.9 갱신 — G_reaction v3 5 요소에 코믹 amplification 3축 점검 추가, 사용자 v2 "심심함" 피드백 trigger, supersedes v1.20 §5.9 reaction 부분만 — §5.11 조리도구 등 다른 항목 무변경)**: 사용자가 v2 (image edit, family IP consistency LOCK) 결과 시각 확인 후 verbatim **"reaction을 코믹하게 만드는게 어때? 지금 reaction 이미지는 너무 심심해"** 피드백. main thread 해석: v2 family IP consistency LOCK 유지하나 표정 amplification 부족 → "Korean variety show / K-drama exaggerated reaction" 톤 부재로 ★1/★2/★3 차이 즉시 체감 어려움. v3 = 코믹 amplification 3축 (눈/입/body+icons) 강화. prompts-library v1.21에서 §5.7 본문 전면 재작성 + 새 driver `tools/edit_reaction_anchors_v3.py` 신설 + COMMON_FRAME_V3 (TONE TARGET 절 신설 + CRITICAL BOUNDARIES 5건 — anime girl 큰 sparkly pupils 회피 + over-exaggerated goofy 회피 추가) 완료. 본 art-anchor-rubric v1.21에서 평가 가이드 갱신: **§5.9 G_reaction v3 5 요소 점검표 갱신** (v2 base 5 요소 + 코믹 amplification 3축 점검 추가): G_reaction_v3_1 **CRITICAL — 캐릭터 family IP 식별 명확** (v2 LOCK 유지 — Week 1 CH-02_mother / CH-03_father base와 동일 family IP — hair / outfit / face features / chibi 1:1.7 / outline 2-3px / saturation 톤, 어머니 round-bun simple / 아버지 darker salt-and-pepper + darker teal-green) / G_reaction_v3_2 **CRITICAL — ★1/★2/★3 expression gradient + 코믹 amplification 3축 명확** (v2 기존 + v3 강화): 3 단계 표정 진화가 v2 점잖은 톤보다 명백히 더 expressive, 외부인 0.5초 안에 gradient 순서 + emotion intensity 답 가능. **코믹 amplification 3축 PASS 기준** = (a) **눈 amplification PASS**: ★1 정상 dot + 비대칭 eyebrow 또는 ★1 narrowed evaluating gaze (mother는 up-left 사고, father는 양 눈 narrowed) / ★2 closed crescent ^_^ 명확 / ★3 GIANT closed-arc ^___^ 명확히 ★2보다 더 dramatic (선택 sparkle accent는 OUTSIDE eye floating) — 단계별 차이 외부인이 1초 안에 구별 / (b) **입 amplification PASS**: ★1 wavy/narrow thinking mouth (NOT 폴리 flat smile) / ★2 medium open smile 또는 O-shape (clearly open, ★1 closed보다 명백히 크다) / ★3 GIANT wide open with teeth visible (optional tongue hint) — ★2보다 명백히 크고 입 내부 visible / (c) **body + emotion icons amplification PASS**: ★1 chin hand thinking pose + 1 simple icon (mother "?" 또는 father sweat drop) / ★2 한 손 cheek (mother) 또는 **double thumb-up chest level** (father, v3 KEY) + 1-2 sparkle / ★3 양손 raised + 3-5 dominant icons (mother hearts / father stars) + 3-6 sparkle + 2-4 motion lines + raised fist over head (father) 또는 hands near cheeks raised (mother) — ★3는 ★2보다 명백히 더 많은 icon burst + 높은 자세 / G_reaction_v3_3 **anchor consistency** (Cool Sage `#C8D5C0` bg + slim outline 2-3px + 음식 12 + cut 7 + ingredient 12 + ingredient cut 12 + reaction 6 + 조리도구 12 = 49+ asset cross-asset cluster 합류 인식, v2와 동일) / G_reaction_v3_4 **chibi mascot proportions + bust-up portrait** (chibi 1:1.7 + bust-up 어깨까지만 — full body / lower body / legs / feet 누수 0건. 단 ★2/★3 hands/arms는 frame 안으로 raised gesture 허용) / G_reaction_v3_5 **CRITICAL — sad/sleeping/goofy 누수 0건 + 한식 family context 유지 + v3 추가 boundary 2건**: (i) sad/sleeping/crying/Japanese kimono/anime girl 누수 0건 (v2 유지) / (ii) **anime girl big sparkly pupils 누수 0건 신규** (★3 sparkle accent는 OUTSIDE eye floating geometric icon, NOT inside pupil 안에 들어가서 enlarged shoujo pupils 형태 되는 거 안 됨 — sparkle은 SEPARATE) / (iii) **over-exaggerated goofy Looney Tunes 톤 누수 0건 신규** (eyes bulging out / tongue lolling 5x / x-eyes / swirl-eyes / comic stink lines 0건 — Royal Match + K-drama 톤 유지, ★3 even at peak는 polished modern mobile casual frame 안에 있어야 함). **LOCK 조건 = 6/6 anchors × 5 요소 = 30/30 PASS**. **R-02 어머니 ★2 + R-05 아버지 ★2가 anchor seed** (v2와 동일 — 각 캐릭터 base default과 가장 가까움). 부분 통과 정책 (5 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only R-XX --version v3.1` reroll / 4 LOCK = CONDITIONAL batch reroll / 3 이하 LOCK = FAIL → pm 에스컬레이션 / G_reaction_v3 #2 expression gradient amplification FAIL = ★1/★2/★3 비교 강제 follow-up "★N expression amplification을 [더 EXPLOSIVE / 더 RESTRAINED]로 — 3 단계 amplification 차이를 1초 안에 구별 가능하도록" / G_reaction_v3 #5 anime girl sparkly pupils 누수 = "sparkle accents are SEPARATE floating geometric icons OUTSIDE the eye area, NOT inside pupil" explicit 강제 / G_reaction_v3 #5 goofy 누수 = "Royal Match aesthetic + K-drama tone, NOT slapstick Looney Tunes, eyes stay chibi small dot/crescent shape" explicit 강제). §5.9.3 reaction v3 6장 라운드 예산 (R1 ★3 peak test 2장 ~1분 $0.08 → R2 6장 batch ~2-3분 $0.25 / R3 follow-up FAIL anchor 집중). **§3.6 reaction 평가 표 R-01~R-06 6 row v3 status 갱신** — 모두 "v1.18 v2 image edit LOCK 2026-05-30, family IP PASS but 표정 amplification CONDITIONAL → v3 image edit pending 2026-05-31 v1.21 코믹 amplification 강화 trigger". §5.9.4 v3 ChatGPT 약점 risk top 3 신설 (anime girl big sparkly pupils 누수 ~35% [★3 sparkle eyes alternative 옵션 risk → "SEPARATE OUTSIDE the eye" 명시 회피] / sad/crying 오해 ~25% [★1 question mark + sweat drop comic 사고 icon이 sad로 해석 risk → "MILD POSITIVE evaluation, comic anime/manga thinking symbol" 명시 회피] / over-exaggeration goofy ~30% [★3 explosive peak이 Looney Tunes 폭주 risk → "Royal Match + K-drama tone, NOT slapstick" 명시 회피]). **§6.20 Decisions Log 신설** — M1 후반 reaction v3 trigger 행 + 사용자 v2 피드백 verbatim ("reaction을 코믹하게 만드는게 어때? 지금 reaction 이미지는 너무 심심해") + main thread 해석 (v2 family IP LOCK 유지 + 표정 amplification 부족 → 코믹 amplification 3축 강화) + v2 → v3 6 핵심 amplification diff 표 (3축 × 3 star = 9 cell + 6 reaction 별 핵심 변화 요약 행) + COMMON_FRAME_V3 TONE TARGET 절 + CRITICAL BOUNDARIES 5건 (anime sparkly pupils 회피 + over-exaggerated goofy 회피 추가 = 2 신규) + v3 fail-safe (Royal Match aesthetic + K-drama tone 유지 명시) + main thread 실행 명령 (test `--only R-03,R-06 --quality medium` 2장 $0.08 ~1분 ★3 peak amplification 우선 확인 → batch `py tools/edit_reaction_anchors_v3.py --quality medium` 6장 $0.25 ~2-3분, 출력 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v3.png` v1/v2와 공존) + R3 사용자 ChatGPT 웹 UI 수동 chain-of-references fallback (★3가 점잖하면 "WAY MORE EXPRESSIVE" / over-shoot이면 "less goofy, more polished" 명시) + v1/v2 invalidation 없음 (v2 family IP LOCK 유지하니 v3가 amplification 강화 layer로 추가). 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. ingredient whole 12장 평가 (§5.8) 무변경. ingredient cut 12장 평가 (§5.10) 무변경. 조리도구 12종 평가 (§5.11) 무변경.

> **v1.20 변경 (2026-05-31, M1 후반 art sprint 5번째 — 조리도구 12종 평가 가이드 §5.11 신설 + G_tool 5 요소 게이트, 사용자 verbatim trigger + Cookingo reference, supersedes v1.19)**: M1 후반 art sprint 5번째 진입. 사용자 verbatim **"조리도구 디자인은 안하나? 냄비, 가스레인지, 국자 등등 각기 따로 해서 움직임을 나중에 만들어야 할거 같음. Cookingo 게임의 요리방법이 내가 구현하고 싶은거와 상당히 비슷해"** trigger. cut anchor 7 / ingredient whole 12 / ingredient cut 12장은 모두 도마+칼 중심 (CUT mechanic 1종) — 본 sprint는 **나머지 11종 mechanic 도구 + 1 base substrate** = **총 12 도구 sprite 각각 별도 생성** (애니메이션 prerequisite). **Cookingo: Perfect Meal** (relaxing cooking game, Asian mobile 2025-2026) reference — 도구별 specific action + 정확도 매칭 게임 메커니즘과 ADR-005 4-stage rhythm tap의 도구별 action mapping 정합. prompts-library v1.20에서 §5.11 신설 + §0 anchor 표 TOOL-01~12 row 12장 추가 + 새 driver `tools/gen_tool_anchors_m1.py` 신설 완료. 본 art-anchor-rubric v1.20에서 평가 가이드 신설: **§5.11 G_tool 5 요소 점검표 신설** (tool anchor 12장 각각에 대해 평가): G_tool_1 **CRITICAL — 도구 형태 시각 식별 명확** (외부인 0.5초 안에 도구 정확 식별: TOOL-01 4-burner gas stovetop + active blue flame / TOOL-02 yangun pot 2 ear handles + open top + steam / TOOL-03 frying pan long single handle + shallow round / TOOL-04 deep fryer DEEPER pot + golden oil pool / TOOL-05 round wire mesh grill grate + optional coal glow / TOOL-06 ladle deep round bowl + long straight handle / TOOL-07 wok spatula wide angled paddle + wood handle / TOOL-08 turner narrower thinner paddle + sharp edge / TOOL-09 tongs scissor-style 2-arm + flared tips / TOOL-10 bamboo mat parallel horizontal strips + cotton string / TOOL-11 mixing bowl wide deep flared no handles / TOOL-12 BBQ scissors large robust + sharp blades + wood loops) / G_tool_2 **CRITICAL — 단독 sprite isolation (다른 도구 0건)** (single hero tool at center 60-70% area + NO other tools + NO food + NO ingredients + NO characters + NO hands + NO kitchen environment background — 애니메이션 prerequisite으로 각 도구가 단독 sprite여야 함) / G_tool_3 **Cool Sage `#C8D5C0` bg + cross-asset 43+ anchor cluster 합류** (음식 12 + 환경 5 + 캐릭터 5 + cut 7 + ingredient 12 + reaction 6 + ingredient cut 12 = 43+ anchor cumulative cluster 합류 인식, slim outline 2-3px + modern saturated 80-90% + ambient ellipse shadow #25% 통일) / G_tool_4 **Cookingo-inspired simple geometric flat clean** (Royal Match aesthetic + Cookingo simple shapes + soft rounded edges + 1-layer cel shading + ONE specular highlight + heavy realistic texture 0건 / heavy metallic reflection 0건 / 3D render 0건) / G_tool_5 **CRITICAL — 한식 정통 도구 + cross-cultural 누수 0건** (a) 도구별 특화 negative top 5 risk: TOOL-02 일본 tetsunabe 검정 cast iron 누수 0건 + TOOL-03 Western Teflon 검정 non-stick coating 누수 0건 (silver-gray bare stainless 강제) + TOOL-05 솔리드 cast iron grill pan 누수 0건 (wire MESH gap visible 강제) + TOOL-10 일본 makisu pink/colored thread 누수 0건 (plain white cotton 강제) + TOOL-12 Western office scissors 누수 0건 (robust LARGE + warm wood handles 강제) / (b) cross-anchor 공통 negative: Japanese cooking tools (tetsunabe / donabe / takoyaki maker / yakitori grill) 0건 + Chinese wok deep round-bottom 0건 + Western Le Creuset / KitchenAid / electric appliances 0건 + 절구 mortar pestle 0건 + 옹기 traditional stone jar 0건 + 인간 hand 0건 + multiple tools 0건. **LOCK 조건 = 12/12 anchors × 5 요소 = 60/60 PASS**. 부분 통과 정책 (11 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only TOOL-XX --version v2` reroll / 9-10 LOCK = CONDITIONAL batch reroll / 8 이하 = FAIL → pm 에스컬레이션 / G_tool #1 도구 형태 FAIL = 명세 강화 / G_tool #2 단독 sprite FAIL = "single hero tool / NO other tools / NO kitchen scene" explicit 강조 / G_tool #5 cross-cultural FAIL = 도구별 specific negative 강화 / TOOL-02 vs TOOL-04 deep fryer FAIL = "DEEPER 18-22cm vs 12-15cm + golden oil pool visible" 명세 강화 / TOOL-07 vs TOOL-08 paddle FAIL = "WIDER vs NARROWER + 20deg vs 10deg + sharp front edge" 명세 강화). §5.11.3 tool anchor 12장 라운드 예산 (R1 12장 batch ~5분 $0.50 / R2 follow-up FAIL anchor 집중). **§3.8 tool 평가 표 신설** (TOOL-01 ~ TOOL-12 12 row × G1/G3/G4/G5/G6/G7/G_new + G_tool 컬럼). §5.11.4 ChatGPT 약점 risk top 5 신설 (TOOL-02 냄비 → 일본 tetsunabe 검정 cast iron 누수 ~50% / TOOL-03 후라이팬 → Western Teflon 검정 non-stick coating 누수 ~50% / TOOL-05 그릴 → 솔리드 cast iron grill pan 누수 ~40% / TOOL-10 김발 → 일본 makisu colored thread 누수 ~40% / TOOL-12 한식 가위 → Western office scissors 누수 ~40%). **§6.19 Decisions Log 신설** — M1 후반 art sprint 5번째 시작 기록 + 사용자 verbatim trigger + Cookingo reference + 조리도구 12장 trigger 행 + main thread 실행 명령 + 각각 별도 sprite 채택 사유 (애니메이션 prerequisite, godot-dev가 AnimationPlayer로 motion 독립 구현 가능) + ADR-005 game-designer 후속 sync 필요 사안 4행 표 (음식 F-XX 도구 사용 sequence 확정 / Stage 2B 조리 mechanic 도구별 BPM 매핑 / 도구 transition timing / UI 도구 sprite layer 호출 규칙). 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. ingredient whole 12장 평가 (§5.8) 무변경. reaction 6컷 평가 (§5.9) 무변경. ingredient cut 12장 평가 (§5.10) 무변경.

> **v1.19 변경 (2026-05-30, M1 후반 art sprint 4번째 — 음식 12 × hero ingredient CUT 12장 평가 가이드 §5.10 신설 + G_ingredient_cut 5 요소 게이트, ADR-005 Stage 2B/2C "after"-cut pair, 사용자 verbatim "손질하고 나서의 ingredient 이미지" trigger, supersedes v1.18)**: M1 후반 art sprint 4번째 진입. 사용자 verbatim "**손질하고 나서의 ingredient 이미지가 있어야 할 거 같고**" — ingredient whole 12장 (§5.6 ING-01~12)은 "before" state, cut anchor 7장 (§5.5 CUT-00~06)은 generic cut style 시연. 두 anchor 사이 누락된 asset = 각 음식의 hero ingredient를 그 음식 특유 cut 결과로 specific 시각화 (음식 시그니처 강화 + Stage 2B/2C 사용). **옵션 C 채택** (12장 specific 모두 생성, F-06 cheese는 ING-06과 동일 image이나 카탈로그 완전성 위해 별도 anchor, F-11 carrot은 F-08과 slight visual variation으로 별도 생성하나 game-designer 후속 확정 시 재사용 결정되면 archive). prompts-library v1.19에서 §5.10 신설 + §0 anchor 표 ICUT-01~12 row 12장 추가 + 새 driver `tools/gen_ingredient_cut_anchors_m1.py` 신설 완료. 본 art-anchor-rubric v1.19에서 평가 가이드 신설: **§5.10 G_ingredient_cut 5 요소 점검표 신설** (ingredient cut anchor 12장 각각에 대해 평가): G_icut_1 **CRITICAL — hero ingredient cut 결과 시각 식별 명확** (외부인 0.5초 안에 ingredient + cut style + 음식 context 식별 — F-01 송송 small thin green discs / F-02 통썰기 medium round zucchini discs / F-03 채썰기 long yellow matchstick 8-10cm / F-04 어슷썰기 medium golden-brown oval / F-05 다지기 fine red kimchi bits / F-06 cheese whole / F-07 어슷썰기 large dominant green daepa oval / F-08 채썰기 short orange matchstick 5-7cm / F-09 marinade brown glaze coated thin beef / F-10 broken cloud-like white tofu curds / F-11 채썰기 medium orange matchstick 6-8cm slight diagonal pile / F-12 다지기 fine yellowish-white garlic granules) / G_icut_2 **CRITICAL — CUT/PREPARED RESULT state 명확** (cut/prep된 결과 cluster만 + WHOLE intact ingredient 0건 — whole은 ING-XX whole anchor 영역, cutting action mid-motion 0건) / G_icut_3 **Cool Sage `#C8D5C0` bg + 도마 + 칼 LEFT side static 통일 (cross-asset 31+ anchor 일관성)** (cut 7 + whole 12 + cut 12 = 31장 cross-asset cluster 합류 인식, CUT-00 anchor seed reference upload + 페어 ING-XX whole image 추가 reference upload 권장) / G_icut_4 **modern saturated 톤 + 단순화** (채도 80-90% / Royal Match aesthetic / heavy texture 0건) / G_icut_5 **CRITICAL — cross-cultural 누수 0건 + 음식 시그니처 시각 분리 (특히 F-04 vs F-07 daepa, F-09 vs F-12 갈비)** (a) ingredient별 특화 negative top 5 risk: ICUT-02 cucumber/Italian zucchini 누수 0건 + ICUT-04 Japanese naruto/chikuwa 0건 + ICUT-07 F-04 어묵 oval 색 누수 0건 (golden-brown 누수 → dominant green 강제) + ICUT-09 raw red/grilled char marks 0건 + F-12 갈비 bone visible 누수 0건 CRITICAL + ICUT-10 firm cube 누수 0건 / (b) cross-anchor 공통 negative: Japanese kitchen knife 0건 + Chinese cleaver 0건 + 절구 0건 + 인간 hand 0건. **LOCK 조건 = 12/12 anchors × 5 요소 = 60/60 PASS** (ICUT-06 cheese는 ING-06과 동일 image면 PASS / ICUT-11 carrot variation은 F-08과 slight 차별 visible 면 PASS, game-designer 재사용 확정 시 archive). 부분 통과 정책 (11 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only F-XX --version v2` reroll / 9-10 LOCK = CONDITIONAL batch reroll / 8 이하 = FAIL → pm 에스컬레이션 / G_icut #1 hero cut 식별 FAIL = 명세 강화 / G_icut #2 CUT RESULT state FAIL = "ready-to-cook prep result state, NO whole intact" explicit 강조 / G_icut #3 cross-asset FAIL = CUT-00 + 페어 ING-XX whole reference upload 재시도 / G_icut #5 F-04 vs F-07 색 누수 FAIL = "DOMINANT BRIGHT GREEN daepa NOT F-04 golden-brown oval" 명세 강화). §5.10.3 ingredient cut 12장 라운드 예산 (R1 12장 batch ~4-5분 $0.50 / R2 follow-up FAIL anchor 집중). **§3.7 ingredient cut 평가 표 신설** (ICUT-01 ~ ICUT-12 12 row × G1/G3/G4/G5/G6/G7/G_new + G_ingredient_cut 컬럼). §5.10.4 ChatGPT 약점 risk top 5 신설 (ICUT-02 cucumber 누수 ~50% / ICUT-04 naruto pink spiral ~50% / ICUT-07 F-04 어묵 색 누수 ~40% / ICUT-09 raw red/char marks ~40% / ICUT-10 firm cube ~40%). **§6.18 Decisions Log 신설** — M1 후반 art sprint 4번째 시작 기록 + 사용자 verbatim trigger + ingredient cut 12장 trigger 행 + main thread 실행 명령 + 옵션 C 채택 사유 + game-designer 후속 confirm 사안 4행 표. 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. ingredient whole 12장 평가 (§5.8) 무변경. reaction 6컷 평가 (§5.9) 무변경.

> **v1.18 변경 (2026-05-30, M1 후반 reaction 6컷 v2 image edit — CH-02/CH-03 base + 표정만 변경, 사용자 R1 v1 피드백 2건 fix, supersedes v1.17)** (archived): 사용자가 v1 (`tools/gen_reaction_anchors_m1.py` prompt-only generation, gpt-image-1 medium 1024×1024 6장 batch) 결과 시각 확인 후 verbatim **"reaction 에서 R-01, R-03가 원래 이미지와 좀 다름, 그리고, R-04, R-05, R-06가 이미지가 좀 일관성이 없음"** 2건 피드백 raise. main thread 시각 분석으로 (a) **R-01/R-03 어머니 hair shape mismatch** (v1 round-bun + side-puff variant로 생성, CH-02 base의 round-bun simple과 다름) / (b) **R-04 vs R-05/R-06 아버지 family IP inconsistency** (R-04 darker hair+shirt vs R-05/R-06 lighter tone, 셋 사이 inconsistency). prompt-only approach가 base의 family IP를 정확 재현 못함을 확인 → **gpt-image-1 image edit API** (환경 BG sprint v4에서 효과 입증된 패턴) 도입. v1.18 = (a) **§3.6 reaction 평가 표 R-01~R-06 6 row status 갱신** — 모두 v1 prompt-only deprecated 2026-05-30 → v2 image edit pending. R-01/R-03 행에 "어머니 hair round-bun simple base 일치 강제" / R-04/R-05/R-06 행에 "아버지 hair tone + shirt tone darker (CH-03 base와 EXACTLY 일치, NOT lighter) family IP lock 강제" 추가. R-02는 anchor seed로 base와 가장 가까워 v1 시각 결과 가장 안정적이었으나 통일성 위해 v2에서 함께 재생성. (b) **§5.9 G_reaction v2 image edit approach note 추가** — G_reaction 5 요소 기준 무변경 (LOCK = 30/30 PASS), 단 v2는 image edit API 사용으로 family IP consistency 게이트 (G_reaction #1) PASS 확률 ↑. v1 prompt-only approach의 한계 (base family IP 정확 재현 불가)를 image edit으로 극복. 새로운 v2 risk top 3 = base의 default expression 유지 ~25% (★1/★2/★3 gradient 무너짐) / bowl prop carry over ~20% / R-04 ★1 thumb-up carry over ~30% (CH-03 base thumb-up이 R-04 ★1로 carry over → prompt explicit "NO thumb-up" 회피). (c) **§6.17 Decisions Log 신설** — reaction v2 trigger 행 + 사용자 R1 v1 verbatim + main thread 시각 분석 2건 + R1 v1 vs v2 6 핵심 fix diff 표 + v1 invalidation 기록 (6장만, 다른 anchor 무영향 명시) + main thread 실행 명령 (test `--only R-01` → batch `py tools/edit_reaction_anchors_v2.py --quality medium`, 6장 × $0.042 ≈ $0.25, ~2-3분, 출력 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v2.png` v1과 공존) + R3 사용자 ChatGPT 웹 UI 수동 chain-of-references fallback 명시. **새 driver `tools/edit_reaction_anchors_v2.py` 신설** — `tools/edit_bg_anchors_v4.py` template 기반 (image edit API + base image dimensions 검증 + PIL resize fallback + b64_json 응답 처리). 구조 = (1) COMMON_FRAME 상수 inline (family IP IDENTICAL 강제 + 어머니 round-bun simple 명시 + 아버지 darker tone base와 EXACTLY 일치 명시 + bust-up + Cool Sage bg + 표정만 변경 + negative) / (2) REACTIONS list 6개 inline (id / name / character / star / base / expression_prompt) / (3) base image 사전 검증 (CH-02_mother.png + CH-03_father.png 2장만) / (4) CLI args (`--only` `--version` `--quality` `--out-dir`) / (5) gpt-image-1 medium 1024×1024 default, version v2 default. v1 prompt-only driver (`tools/gen_reaction_anchors_m1.py`)는 보존 (git history). v1 output 6장 (R-XX_<character>_star<N>_v1.png)도 보존 — v2와 공존 (R-XX_<character>_star<N>_v2.png). 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. ingredient whole 12장 평가 (§5.8) 무변경.

> **v1.17 변경 (2026-05-30, mvp-food-selection v2.2 sync — F-02 호떡 → 잔치국수 + F-09 김치찌개 → 불고기 음식 anchor 2장 + ING-02/ING-09 ingredient anchor 2장 status 갱신, supersedes v1.16)** (archived): game-designer가 2026-05-28 mvp-food-selection v2.1 → v2.2 갱신 완료 (F-02 호떡 → 잔치국수 T1 곡물+잡화+어물+청과 4가게 / F-09 김치찌개 → 불고기 T2 정육+청과+잡화). game-designer hero ingredient 매핑 = F-02 hero 소면 + 부 hero 멸치/김/애호박/대파 / F-09 hero 얇은 소고기 + 부 hero 양파/대파/당근/표고. prompts-library v1.17에서 §5.2 F-02/F-09 본문 전면 교체 + §5.6 ING-02/ING-09 본문 전면 교체 + §0 anchor 표 4 row 갱신 + driver script `gen_food_anchors_m1.py` / `gen_ingredient_anchors_m1.py` body inline + docstring v1.17 sync 완료. 본 art-anchor-rubric v1.17 = **§5.5.4 음식 평가 표 F-02 row + F-09 row status 갱신** (F-02 Hotteok → Janchi-guksu T1 v1.17 reroll pending, 호떡 deprecated 2026-05-30 mvp v2.2 trigger / F-09 Kimchi Jjigae → Bulgogi T2 v1.17 reroll pending, 김치찌개 deprecated + F-12 갈비 차별화 CRITICAL: NO bone-in LA cut + NOT grilled on wire mesh grate + NO large 18-25cm LA strips + NOT separated meat strips). **§3.5 ingredient whole 평가 표 ING-02 row + ING-09 row status 갱신** (ING-02 peanut R1 + brown_sugar R2 deprecated → somen pending v3 v1.17 mvp v2.2 / ING-09 firm tofu R1 deprecated → thin marbled beef pending v3 v1.17 mvp v2.2 trigger + F-12 갈비 차별화 CRITICAL: NO bone visible + RAW NOT cooked grilled brown). **§6.16 Decisions Log 신설** — mvp v2.2 trigger 행 + game-designer 매핑 인용 (F-02 hero 소면 + 부 hero 멸치/김/애호박/대파 / F-09 hero 얇은 소고기 + 부 hero 양파/대파/당근/표고) + F-02/F-09 음식 anchor 2장 + ING-02/ING-09 ingredient anchor 2장 reroll trigger + 변경 사유 ("기존 mvp v2.1 F-02 호떡 / F-09 김치찌개 → mvp v2.2 F-02 잔치국수 / F-09 불고기 game-designer 결정 trigger") + main thread 실행 명령 (음식 2장 `--only F-02,F-09 --version v9` + ingredient 2장 `--only F-02,F-09 --version v3`, 총 4장 × $0.042 ≈ $0.17, ~2분) + deprecation 기록 (호떡/김치찌개/peanut/흑설탕/firm tofu archive 보존) + F-12 갈비 차별화 CRITICAL 행 (불고기 F-09는 갈비 F-12와 시각 분리 critical, ChatGPT가 같은 한식 BBQ 카테고리로 cross-contamination 누수 ~40% risk). ChatGPT 약점 risk top 5/7 갱신 (잔치국수 Japanese somen tsuyu cold 누수 ~50% / 잔치국수 Vietnamese pho 누수 ~30% / 불고기 Japanese sukiyaki raw egg dipping 누수 ~50% / 불고기 F-12 갈비 bone visible cross-contamination ~40% CRITICAL / 소면 Japanese pink-white decorative band 누수 ~40% / 얇은 소고기 Japanese wagyu extreme marbling 누수 ~40% / 얇은 소고기 cooked brown 누수 ~30%). 음식 12 평가 표 다른 10 row 무변경 (F-01/F-03/F-04/F-05/F-06/F-07/F-08/F-10/F-11/F-12 LOCK status 유지). ingredient whole 12장 평가 표 다른 10 row 무변경 (ING-01/ING-03/ING-04/ING-05/ING-06/ING-07/ING-08/ING-10/ING-11/ING-12 status 유지). 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. reaction 6컷 평가 (§5.9) 무변경.

> **v1.16 변경 (2026-05-30, M1 후반 art sprint 3번째 — 양친 reaction 6컷 anchor 평가 가이드 §5.9 신설 + G_reaction 5 요소 게이트, Scene 3 식탁 ★1/★2/★3 gradient, ingredient 12장 sprint와 fully parallel, supersedes v1.15)** (archived): M1 후반 art sprint 3번째 = ingredient 12장 sprint와 **병렬로 동시 진행**. 친구 가족 단위 (project_adr003 2026-05-23 lock) 어머니 + 아버지 L11 동시 unlock + Scene 3 식탁 reaction context + ADR-005 Total Score gradient (★1 30%+ / ★2 60%+ / ★3 90%+) + friends-system 호불호 axis (project_adr003 v0.2) trigger로 양친 reaction 6컷 anchor 필요. art-director가 Week 1 base 4장 (`assets-raw/week1-anchors/CH-02_mother.png` / `CH-03_father.png` / `CH-04_mother_star1.png` / `CH-05_father_star3.png`) Read tool 시각 확인 완료 — (a) CH-02_mother base = round-bun + 빨간 jeogori top + soft white apron + warm motherly subtle smile (default ≈ ★1-★2 경계) / (b) CH-03_father base = salt-and-pepper hair + teal-green button-up shirt + LEFT thumb-up + slim smile (default ≈ ★2 lower end) / (c) **CH-04_mother_star1 Week 1 variant = sad/teardrop expression** (부정 reaction, NOT mild satisfaction → 본 sprint 재해석에서 폐기. R-01 어머니 ★1 prompt는 subtle warm smile + 정상 open dot eyes로 새로 작성. CH-04 file 자체는 보존, 향후 0-29% score 또는 호불호 penalty deep negative reaction asset으로 재활용 가능) / (d) **CH-05_father_star3 Week 1 variant = excited closed-arc + double thumb-up + 4 sparkle + wide open smile** (본 sprint settle 형태에 가장 가까움 — R-06 아버지 ★3 prompt는 CH-05 거의 그대로 재현 단 shirt teal-green CH-03 정확 매칭 + bust-up framing. CH-05 image를 R-06 생성 시 추가 reference upload 권장). prompts-library v1.16에서 §2.5 STYLE_SUFFIX_REACTION 명시 + §5.7 full prompts 확장 + 새 driver `tools/gen_reaction_anchors_m1.py` 신설 완료. 본 art-anchor-rubric v1.16에서 평가 가이드 신설: **§5.9 G_reaction 5 요소 점검표 신설** (reaction anchor 6장 각각에 대해 평가): G_reaction_1 **CRITICAL — 캐릭터 family IP 식별 명확** (Week 1 CH-02_mother / CH-03_father base와 동일한 family IP 인식 — hair / outfit / face features / chibi mascot proportions / Week 1 base와 같은 outline 두께·features·컬러 saturation 톤 유지) / G_reaction_2 **CRITICAL — ★1/★2/★3 expression gradient 명확** (3 단계 표정 진화 명확 visible — ★1 subtle smile 정상 open dot eyes / ★2 bigger smile soft eye crescent arcs / ★3 big wide open smile closed-arc happy eyes 외부인 0.5초 안에 gradient 순서 답 가능. 어머니/아버지 톤 차이 — 어머니 warm motherly nurturing amplification / 아버지 reserved masculine breaking into excitement amplification) / G_reaction_3 **anchor consistency (Cool Sage `#C8D5C0` bg + cross-asset cluster)** (6장 모두 Cool Sage solid bg + slim outline 2-3px + 음식 12 + cut 7 + ingredient 12 = 25-asset Scene 3 cross-asset cluster 합류 인식. 캐릭터 5장 soft mint `#9BE0D2` 누수 0건) / G_reaction_4 **chibi mascot proportions + bust-up portrait** (chibi 1:1.7 head-to-body ratio + bust-up 어깨까지만 visible — full body / lower body / legs / feet 누수 0건) / G_reaction_5 **CRITICAL — sad/sleeping/negative expression 누수 0건 + 한식 family context 유지** (Week 1 CH-04_mother_star1 sad teardrop pattern 누수 0건 / sleeping closed eyes 누수 0건 / crying tears 누수 0건 / multiple characters 결합 누수 0건 / Japanese 기모노 / 중국 치파오 / anime girl big sparkly eyes 누수 0건 / deep dark Cookie Run pink cheek 누수 0건). **LOCK 조건 = 6/6 anchors × 5 요소 = 30/30 PASS**. **R-02 어머니 ★2 + R-05 아버지 ★2가 anchor seed** (각 캐릭터의 base default expression과 가장 가까움 → seed lock 후 ★1/★3 variant generation시 reference image upload 시드). 부분 통과 정책 (5 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only R-XX --version v2` reroll / 4 LOCK = CONDITIONAL batch reroll / 3 이하 LOCK = FAIL → pm 에스컬레이션 / **R-02 또는 R-05 anchor seed FAIL = REROLL** seed 우선 / G_reaction #2 expression gradient FAIL = ★1/★2/★3 비교 강제 follow-up "★N expression intensity를 [더 subtle / 더 expressive]로 — 3 단계 gradient 정확 매칭" / G_reaction #5 sad/sleeping 누수 = "MILD POSITIVE acceptance / HAPPY UPWARD ARC closed-arc / NOT sad NOT crying NOT sleeping" explicit 강제). §5.9.3 reaction 6장 라운드 예산 (R1 6장 batch ~2-3분 $0.25 / R2 follow-up FAIL anchor 집중 또는 사용자 ChatGPT 웹 UI reference upload 워크플로 권장). §5.9.4 ChatGPT 약점 risk top 5 (R-01 mother_star1 sad teardrop 누수 ~60% / R-06 father_star3 sparkle detail 폭주 + double thumb-up 단순화 ~40% / R-03 mother_star3 heart icon detail 폭주 ~35% / R-02/R-05 ★2 in-between collapse ~30% / R-04 father_star1 thumb-up carry over ~25%). **§3.6 reaction 평가 표 신설** (R-01 ~ R-06 6 row × G1/G3/G4/G5/G6/G7/G_new + G_reaction 컬럼). **§6.15 Decisions Log 신설** — M1 후반 art sprint 3번째 시작 기록 + Week 1 base 4장 시각 확인 결과 + R-02/R-05 anchor seed 명시 + ingredient 12장 sprint와 병렬 동시 진행 명시 + reaction 6컷 trigger 행 + main thread 실행 명령 (`py tools/gen_reaction_anchors_m1.py --model gpt-image-1 --quality medium`, 6장 × $0.042 ≈ $0.25, ~2-3분, 출력 경로 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v1.png`) + Week 1 CH-04 sad variant 폐기/CH-05 settle 형태 명시. 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. ingredient whole 12장 평가 (§5.8) 무변경.

> **v1.15 변경 (2026-05-30, M1 후반 art sprint 2번째 — 음식 12 × hero ingredient whole anchor 12장 평가 가이드 §5.8 신설 + G_ingredient_whole 5 요소 게이트, ADR-005 Stage 2A "before"-cut pair, supersedes v1.14)** (archived): M1 후반 art sprint 1번째 (cut anchor 7장 LOCK 완료) 후 2번째 sprint 진입. ADR-005 Stage 2A 재료 준비 미니게임은 음식별 hero ingredient를 적절한 cut style로 자르는 형태 → 음식 12 × hero ingredient whole(자르기 전) anchor 12장이 필요 ("before" pair, cut된 결과 "after"는 CUT-01~06 anchor 재사용). prompts-library v1.15에서 §5.5.0 음식↔cut 매핑 표 신설 + §5.6 ingredient whole 12장 prompt set 신설 + 새 driver `tools/gen_ingredient_anchors_m1.py` 신설 완료. 본 art-anchor-rubric v1.15에서 평가 가이드 신설: **§5.8 G_ingredient_whole 5 요소 점검표 신설** (ingredient whole anchor 12장 각각에 대해 평가): G_ing_1 **hero ingredient 시각 식별 명확** (외부인 0.5초 안에 ingredient 카테고리 식별 — 대파 cylindrical white-to-green stalk / 견과류 lobed bumpy shell / 단무지 fat bright yellow cylinder / 어묵 flat golden-brown sheet / 김치 red-coated folded leaf / 모짜렐라 milky-white cylinder / 당근 orange tapered cone + green leafy top / 두부 firm white rectangular sharp-edge block / 두부 soft clear plastic tube with white contents / 마늘 5-7 peeled teardrop cloves) / G_ing_2 **WHOLE/UNCUT state 명확** (cut pieces scattered 0건 — minced bits / julienne strips / diagonal slices / round discs / cubes 모두 0건, single intact ingredient만) / G_ing_3 **Cool Sage `#C8D5C0` bg + 도마 + 칼 LEFT side static 통일** (cut anchor 7장 + 음식 12장 + 환경 5장 cross-asset 일관성 — 도마 warm brown #A67049 + 칼 silver-gray slim silhouette LEFT side + Cool Sage bg + slim outline 2-3px) / G_ing_4 **modern saturated 톤 + 단순화** (채도 80-90% / Royal Match aesthetic / 1-2 subtle shading lines + ONE specular highlight / heavy texture 0건 / Cookie Run 2021/scrapbook/storybook/베이지 0건) / G_ing_5 **cross-cultural 누수 0건** (각 ingredient 특화 negative: ING-03 banana/daikon 누수 0건, ING-04 Japanese naruto/chikuwa 0건, ING-07 Japanese negi 0건, ING-06 cheddar/두부 0건, ING-12 whole bulb/양파 0건, Japanese kitchen knife santoku/deba 0건 cross-anchor 공통, mortar 절구 0건 cross-anchor 공통). **LOCK 조건 = 12/12 anchors × 5 요소 = 60/60 PASS** (단 ING-11 carrot은 F-08 anchor 재사용 결정 시 archive — game-designer foods CSV `prep_*` 후속 검증 결과에 따라). game-designer 후속 확정 사안 (음식 12 × hero ingredient 매핑 검증, foods CSV `prep_*` 컬럼 lock) FAIL 시 일부 anchor reroll. §5.8.3 ingredient whole 12장 라운드 예산 (R1 12장 batch ~4-5분 $0.50 / R2 follow-up FAIL anchor 집중). **§3.4 ingredient whole 평가 표 신설** (ING-01 ~ ING-12 12 row × G1/G3/G4/G5/G6/G7/G_new + G_ingredient_whole 컬럼). **§6.14 Decisions Log 신설** — M1 후반 art sprint 2번째 시작 기록 + ADR-005 Stage 2A "before"-cut pair + ingredient whole 12장 trigger 행 + main thread 실행 명령 (`py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium`, 12장 × $0.042 ≈ $0.50, ~4-5분, 출력 경로 `assets-raw/ingredient_anchors_m1/<food_id>_<ingredient_name>_v1.png`) + game-designer 후속 confirm 사안 (foods CSV `prep_*` 컬럼 hero ingredient 매핑 검증, 12행 표). 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경.

> **v1.14 변경 (2026-05-29, M1 후반 sprint 진입 — 칼/도마 base + cut style 6종 cut anchor 7장 평가 가이드 §5.7 신설 + G_cut 5 요소 게이트, ADR-005 Stage 2A rhythm tap prerequisite, supersedes v1.13)** (archived): M1 anchor 22/22 LOCK 완료 (음식 12 + 환경 5 + 캐릭터 5, commit dfb141e) 후 M1 후반 art sprint 진입. **ADR-005 Stage 2A 재료 준비 = rhythm tap + Knife indicator** prerequisite로 칼/도마 base + cut style 6종 anchor 7장이 필요. prompts-library v1.14에서 §2.5 STYLE_SUFFIX_CUT 신설 + §5.5 full prompts 확장 완료 + 새 driver `tools/gen_cut_anchors_m1.py` 신설. 본 art-anchor-rubric v1.14에서 평가 가이드 신설: **§5.7 G_cut 5 요소 점검표 신설** (cut anchor 7장 각각에 대해 평가): G_cut_1 **cut style 시각 식별 명확** (시그니처 cut shape 외부인 0.5초 안에 식별 — mince fine bits / julienne thin matchstick / diagonal elongated oval / whole round disc / sliced_rounds thin small round / cube 3D cube volume) / G_cut_2 **hero ingredient 매칭** (mince→마늘 yellowish-white / julienne→당근 orange / diagonal→어묵+대파 / whole→김밥 5색 cross-section / sliced_rounds→대파 green + scallion ring pattern / cube→두부 흰 cube) / G_cut_3 **Cool Sage `#C8D5C0` bg + 도마 + 칼 통일** (음식 12 + 환경 5 cross-asset 일관성 — 도마 warm brown + 칼 silver-gray slim silhouette + Cool Sage bg + slim outline 2-3px) / G_cut_4 **modern saturated 톤** (채도 80-90% / Royal Match aesthetic / Cookie Run 2021/scrapbook/storybook/베이지 0건) / G_cut_5 **cutting RESULT state + cross-cultural negative** (cut 결과 상태이지 cutting action mid-motion 아님 / Japanese kitchen knife santoku/deba 0건 / mortar 절구 0건 / CUT-04 통썰기 Japanese maki sushi 누수 0건 / CUT-06 깍둑썰기 Chinese mapo tofu 누수 0건). **LOCK 조건 = 7/7 anchors × 5 요소 = 35/35 PASS**. CUT-00 anchor seed FAIL 시 전체 FAIL (CUT-01~06 reference upload 일관성 무너짐). §5.7.3 cut anchor 7장 라운드 예산 (R1 7장 batch ~3-4분 $0.29 / R2 follow-up FAIL anchor 집중). **§3.3 cut anchor 평가 표 신설** (CUT-00 ~ CUT-06 7 row × G1/G3/G4/G5/G6/G7/G_new + G_cut 컬럼). **§6.13 Decisions Log 신설** — M1 후반 art sprint 시작 기록 + ADR-005 Stage 2A prerequisite + cut anchor 7장 trigger 행 + main thread 실행 명령 (`py tools/gen_cut_anchors_m1.py --model gpt-image-1 --quality medium`, 7장 × $0.042 ≈ $0.29, ~3-4분, 출력 경로 `assets-raw/cut_anchors_m1/<name>_v1.png`). 음식 12 평가 (§5.5) 무변경 (F-12 v1.10 R7 LOCK candidate 유지). 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경.

> **v1.13 변경 (2026-05-28, M1 환경 BG-01~05 v4 image edit — v1.2 base + 지붕만 교체 + frontal view + 5가게 구조 일관성, supersedes v1.12)** (archived): 사용자가 v1.12 v3 결과 (5장 batch prompt-only generation, slight 7/8 perspective, structurally inconsistent across 5 shops) 시각 확인 후 폐기 + verbatim **"각 가겍의 디자인이 조금씩 다름...지붕, 기둥, 이런것들은 똑같아야 하지 않나.... 원래 버젼에서 지붕만 바꾸는게 어떨까...그리고 정면이 더 낫지 않나..."** 명시. main thread 해석 3건 fix: (1) **5가게 구조 정확 일관성** — 지붕/기둥/카운터/frame 5가게 모두 정확히 동일, 카테고리별 display goods + signage icon만 다름 (v3 prompt-only batch generation의 generation noise로 5가게 carpenter 작업이 다르게 생성됨) / (2) **v1.2 base 정확 유지 + 지붕만 교체** — prompt-only는 v1.2 정확 재현 어려움, **gpt-image-1 image edit API** 도입 (`client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_EDIT_PROMPT + category, size, quality, n=1)`) / (3) **frontal view** — slight 7/8 perspective 폐기, v1.2 base가 frontal이었음. **§3.2 환경 평가 표 갱신** — v1.12 v3 BG-01~05 5 row "v3 deprecated 2026-05-28 (5가게 구조 inconsistent + 7/8 perspective)" 추가 + v4 BG-01~05 5 row "v4 pending image edit (G_env_v4 8 요소)" 신설. **§5.6.2 G_env_v4 8 요소 게이트 신설** (G_env_v3 5 요소 deprecated → §5.6.4 archive note): G_env_v3 5 요소 (검정 기와 지붕 단일 / v1.2 base 카테고리 시그니처 / icon+영어 minimal signage / Cool Sage bg + modern saturated / v2 한옥 풀세트 추가 요소 0건) + **v4 추가 3 요소**: G_env_v4_6 **5가게 구조 정확 일관성** (지붕/기둥/카운터/frame 5가게 정확 동일, 카테고리별 display goods + signage icon만 다름) / G_env_v4_7 **frontal elevation view** (slight 7/8 perspective 0건, 정면 명확) / G_env_v4_8 **v1.2 base 시각 시그니처 정확 유지** (base image의 frame/카운터/products/signage/bg가 image edit 후에도 ABSOLUTELY IDENTICAL). **LOCK 조건 = 5/5 anchors × 8 요소 = 40/40 PASS**. prompts-library v1.13로 §4 BG-01~05 본문 v4 image edit approach 전면 재작성 (§4.0 공통 COMMON_EDIT_PROMPT + §4.1 shop-specific 카테고리 한 줄 표 + §4.2 G_env_v4 8 요소 게이트 link + §4.3 driver script `tools/edit_bg_anchors_v4.py` + §4.4 사용자 v3 폐기 verbatim + §4.5 v3 vs v4 5 요소 핵심 diff). v3 prompt-only 본문 5건은 §4-LEGACY archive로 deprecated. **새 driver `tools/edit_bg_anchors_v4.py` 신설** — base image dimensions 사전 검증 + (필요 시) gpt-image-1 edit supported size (1024x1024 / 1536x1024 / 1024x1536)로 PIL resize fallback + b64_json 응답 처리. §0 anchor 표 BG-01~05 v4 row status 추가 (`v3 deprecated → v4 pending image edit`). **§6.12 Decisions Log 신설** — 환경 v4 trigger 행 + 사용자 R2 v3 verbatim + main thread 해석 3건 fix + v3 → v4 5 핵심 diff 표 + v3 invalidation 기록 (5장만, 캐릭터 무영향 명시) + 사용자 시각 의도 진화 timeline (v1.2 → v2 → v3 → v4) + main thread 실행 명령 (`py tools/edit_bg_anchors_v4.py --only BG-01` test → `py tools/edit_bg_anchors_v4.py` 5장 batch, gpt-image-1 medium, 5장 × $0.042 ≈ $0.21, ~2-3분, v4 출력 경로 `assets-raw/bg_anchors_m1/BG-XX_<name>_v4.png` v1/v2/v3와 공존). §6.11 v3 trigger 행에 v4 supersede note 추가. 음식 12 평가 (§5.5) 무변경 (F-12 v1.10 R7 plated white plate LOCK candidate 유지). 캐릭터 5 평가 (§3.1) 무변경 (v1.2 lock candidate 유지).

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

### 3.4 Cut anchor 평가 (v1.14 신설, ADR-005 Stage 2A rhythm tap prerequisite)

> M1 후반 sprint cut anchor 7장 (CUT-00 cutting_board base + CUT-01~06 cut style 6종) 평가. G_cut 5 요소는 §5.7 참조.

| Anchor | G1 일관성 | G2 단순성 | G3 modern saturated | G4 K-touch | G5 modern clean | G6 약점 회피 | G7 모바일 가독성 | G_new modernity | **G_cut (v1.14, 5 요소)** | 종합 |
|--------|----------|----------|--------------------|-----------|----------------|------------|----------------|----------------|-----------------------|------|
| **CUT-00 cutting_board base (anchor seed)** | pending | pending | pending | pending | pending | pending | pending | pending | **pending (G_cut 5 요소)** | **pending M1 후반** |
| **CUT-01 mince — 다지기 (마늘)** | pending | pending | pending | pending | pending | pending | pending | pending | **pending** | **pending M1 후반** |
| **CUT-02 julienne — 채썰기 (당근)** | pending | pending | pending | pending | pending | pending | pending | pending | **pending** | **pending M1 후반** |
| **CUT-03 diagonal — 어슷썰기 (어묵+대파)** | pending | pending | pending | pending | pending | pending | pending | pending | **pending** | **pending M1 후반** |
| **CUT-04 whole — 통썰기 (김밥)** | pending | pending | pending | pending | pending | pending | pending | pending | **pending** | **pending M1 후반** |
| **CUT-05 sliced_rounds — 송송썰기 (대파)** | pending | pending | pending | pending | pending | pending | pending | pending | **pending** | **pending M1 후반** |
| **CUT-06 cube — 깍둑썰기 (두부)** | pending | pending | pending | pending | pending | pending | pending | pending | **pending** | **pending M1 후반** |

> G1 일관성 = 7장이 같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 outline 두께 인식. G2 단순성 = cutting board + knife + ingredient 외 군더더기 0건. G4 K-touch = 한식 도마/칼 (Japanese 0건). G_cut 5 요소는 §5.7 참조.

### 3.5 Ingredient whole 평가 (v1.15 신설, ADR-005 Stage 2A "before"-cut pair)

> M1 후반 art sprint 2번째 ingredient whole 12장 (음식 12 × hero ingredient whole state) 평가. G_ingredient_whole 5 요소는 §5.8 참조. cut anchor 7장과 동일 도마/칼/bg 일관성 (cross-asset, 19장 = cut 7 + ingredient whole 12 한 anchor seed CUT-00 공유).

| Anchor | food_id | hero ingredient | pair cut style | G1 일관성 | G2 단순성 | G3 modern saturated | G4 K-touch | G5 modern clean | G6 약점 회피 | G7 모바일 가독성 | G_new modernity | **G_ingredient_whole (v1.15, 5 요소)** | 종합 |
|--------|---------|----------------|---------------|----------|----------|--------------------|-----------|----------------|------------|----------------|----------------|-----------------------------------|------|
| **ING-01 spring onion (대파)** | F-01 | spring onion whole | CUT-05 송송 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (G_ing 5 요소)** | **pending M1 후반 2번째** |
| **ING-02 somen (소면, v1.17 mvp v2.2 신규 — peanut R1 + brown_sugar R2 deprecated)** | F-02 Janchi-guksu | somen whole bundled dry white wheat noodles | (no cut, sprinkle/serve) | pending | pending | pending | pending | pending | pending | pending | pending | **pending v3 (G_ing 5 요소, Japanese pink-white decorative band 누수 ~40% / Chinese yellow egg noodles / Italian spaghetti rigid / Korean ramyeon curly yellow risk)** | **v1.17 reroll pending v3 (mvp v2.2 trigger — peanut/흑설탕 모두 archive)** |
| **ING-03 danmuji (단무지)** | F-03 | pickled radish whole | CUT-02 채썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk top — banana/daikon 누수 ~50%)** | **pending M1 후반 2번째** |
| **ING-04 fish cake (어묵)** | F-04 | fish cake sheet whole | CUT-03 어슷썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk top — naruto/chikuwa 누수 ~50%)** | **pending M1 후반 2번째** |
| **ING-05 kimchi (김치)** | F-05 | napa cabbage leaf whole | CUT-01 다지기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending** | **pending M1 후반 2번째** |
| **ING-06 mozzarella (모짜렐라)** | F-06 | cheese stick whole | (no cut) | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk — cheddar/두부 누수 ~40%)** | **pending M1 후반 2번째** |
| **ING-07 daepa (대파 large)** | F-07 | large scallion whole | CUT-03 어슷썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk — F-01 spring onion 변종 누수 ~40%)** | **pending M1 후반 2번째** |
| **ING-08 carrot (당근, bibimbap)** | F-08 | carrot whole | CUT-02 채썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending** | **pending M1 후반 2번째** |
| **ING-09 thin marbled beef (얇은 소고기, v1.17 mvp v2.2 신규 — firm tofu R1 deprecated, F-12 갈비 차별화 CRITICAL)** | F-09 Bulgogi | thin-sliced raw marbled beef stack/fan whole | (no cut, 양념재우기 marinade prep state — raw before marinade) | pending | pending | pending | pending | pending | pending | pending | pending | **pending v3 (G_ing 5 요소, Japanese wagyu extreme marbling ~40% / cooked brown 누수 ~30% / F-12 갈비 bone visible 누수 CRITICAL — NO bone visible RAW state CRITICAL / bacon parallel striped / salami cured / 삼겹살 thick alternating layered risk)** | **v1.17 reroll pending v3 (mvp v2.2 trigger — firm tofu archive, F-12 갈비 차별화 CRITICAL: NO bone + RAW NOT cooked)** |
| **ING-10 soft tofu (순두부)** | F-10 | soft tofu tube whole | (no cut) | pending | pending | pending | pending | pending | pending | pending | pending | **pending** | **pending M1 후반 2번째** |
| **ING-11 carrot (당근, japchae)** | F-11 | carrot whole (F-08 variation) | CUT-02 채썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (game-designer 재사용 확정 시 archive)** | **pending M1 후반 2번째** |
| **ING-12 garlic (마늘)** | F-12 | garlic cloves whole | CUT-01 다지기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk — whole bulb/양파 누수 ~35%)** | **pending M1 후반 2번째** |

> G1 일관성 = 12장 + cut anchor 7장 = 19장 cross-asset 같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 outline 두께 인식. G2 단순성 = cutting board + knife + whole ingredient 외 군더더기 0건 (cut pieces scattered 0건 CRITICAL). G4 K-touch = 한식 도마/칼 + 한식 ingredient 카테고리 (Japanese/Chinese ingredient 누수 0건). G_ingredient_whole 5 요소는 §5.8 참조.

### 3.6 Reaction 평가 (v1.18 v2 image edit, Scene 3 식탁 ★1/★2/★3 gradient, supersedes v1.16 v1 prompt-only)

> M1 후반 art sprint 3번째 양친 reaction 6컷 (어머니 × ★1/★2/★3 + 아버지 × ★1/★2/★3) 평가. G_reaction 5 요소는 §5.9 참조. Week 1 CH-02/CH-03 base와 동일 family IP + Scene 3 식탁 Cool Sage bg cross-asset cluster 합류 (음식 12 + cut 7 + ingredient whole 12 + reaction 6 = 37-asset Scene 3 cluster).
>
> **v1.18 v2 patch**: v1 prompt-only generation 결과 (R-XX_<character>_star<N>_v1.png) 사용자 시각 확인 후 family IP 2건 FAIL (R-01/R-03 어머니 hair mismatch + R-04/R-05/R-06 아버지 family IP inconsistency) → v1 6장 deprecated, v2 image edit (CH-02_mother.png + CH-03_father.png base 직접 입력 + 표정만 변경) approach로 supersede. 본 표 6 row 모두 **v1 prompt-only deprecated → v2 image edit pending** status 갱신.

| Anchor | character | star | Week 1 base reference | G1 일관성 | G2 bust-up + chibi | G3 modern saturated | G4 K-touch | G5 modern clean | G6 약점 회피 | G7 모바일 가독성 | G_new modernity | **G_reaction (v1.16, 5 요소)** | 종합 |
|--------|-----------|------|--------------------|----------|-------------------|--------------------|-----------|----------------|------------|----------------|----------------|---------------------------|------|
| **R-01 mother_star1 (mild satisfaction) — v1 prompt-only deprecated 2026-05-30 (어머니 hair round-bun+side-puff mismatch vs CH-02 base round-bun simple) → v2 image edit pending** | mother | ★1 | CH-02_mother.png (base, image edit input) | pending | pending | pending | pending | pending | pending | pending | pending | **v2 pending (G_reaction 5 요소, v1 FAIL = G_reaction #1 family IP mismatch CRITICAL — round-bun simple 강제 / v2 risk — base default subtle smile carry over → ★1 의도와 conflict ~25%)** | **v2 pending image edit (어머니 hair simple lock)** |
| **R-02 mother_star2 (happy/pleased) — anchor seed, v1 candidate but v2 통일 재생성** | mother | ★2 | CH-02_mother.png (base default와 가장 가까움) | pending | pending | pending | pending | pending | pending | pending | pending | **v2 pending (anchor seed, base default와 가장 가까움이라 v1 시각 결과 가장 안정적이었으나 v2에서 통일 재생성. v2 risk — base default와 너무 가까워 ★2 gradient amplification 부족 ~20%)** | **v2 pending image edit (anchor seed)** |
| **R-03 mother_star3 (very happy + heart accent) — v1 prompt-only deprecated 2026-05-30 (어머니 hair mismatch) → v2 image edit pending** | mother | ★3 | CH-02_mother.png (base, image edit input) | pending | pending | pending | pending | pending | pending | pending | pending | **v2 pending (v1 FAIL = G_reaction #1 family IP mismatch CRITICAL + heart icon detail 폭주 risk ~35% / v2 risk — base bowl prop carry over → ★3 hands near cheeks와 conflict ~20%)** | **v2 pending image edit (어머니 hair simple lock + heart accent simple flat)** |
| **R-04 father_star1 (slim reserved) — v1 prompt-only deprecated 2026-05-30 (R-05/R-06와 family IP inconsistency — R-04 darker tone vs R-05/R-06 lighter tone) → v2 image edit pending** | father | ★1 | CH-03_father.png (base, image edit input) | pending | pending | pending | pending | pending | pending | pending | pending | **v2 pending (v1 FAIL = G_reaction #1 family IP inconsistency / v2 risk — base thumb-up carry over → ★1 reserved 의도와 conflict ~30% CRITICAL, prompt "NO thumb-up" explicit 강제)** | **v2 pending image edit (아버지 hair+shirt tone CH-03 base와 EXACTLY 일치 강제 + NO thumb-up)** |
| **R-05 father_star2 (relaxed enjoyment) — anchor seed, v1 prompt-only deprecated 2026-05-30 (lighter tone vs R-04 darker — family IP inconsistency) → v2 image edit pending** | father | ★2 | CH-03_father.png (base default와 가장 가까움) | pending | pending | pending | pending | pending | pending | pending | pending | **v2 pending (anchor seed, v1 FAIL = G_reaction #1 family IP inconsistency lighter tone / v2 fix = hair+shirt tone CH-03 base와 EXACTLY 일치 명시 강제)** | **v2 pending image edit (anchor seed, family IP darker tone lock)** |
| **R-06 father_star3 (excited + double thumb-up + sparkle) — v1 prompt-only deprecated 2026-05-30 (lighter tone vs R-04 darker — family IP inconsistency) → v2 image edit pending** | father | ★3 | CH-03_father.png (base, image edit input) + 사용자 ChatGPT 웹 UI fallback 시 CH-05_father_star3.png 추가 reference 권장 | pending | pending | pending | pending | pending | pending | pending | pending | **v2 pending (v1 FAIL = G_reaction #1 family IP inconsistency lighter tone + sparkle detail 폭주 anime 누수 risk ~40% + double thumb-up 단순화 ~30% / v2 risk — base의 single thumb-up이 double thumb-up 변경 명시적 강제 필요 ~25%)** | **v2 pending image edit (family IP darker tone lock + DOUBLE thumb-up + sparkle simple flat)** |

> G1 일관성 = 6장이 Week 1 CH-02/CH-03 base와 같은 family IP (hair / outfit / face features) + 같은 outline 두께 + 같은 컬러 saturation 인식. G2 bust-up + chibi = head and shoulders only (full body / lower body 누수 0건) + chibi 1:1.7 head-to-body. G4 K-touch = Korean family context (Japanese 기모노 / 중국 치파오 누수 0건). G_reaction 5 요소는 §5.9 참조.

### 3.7 Ingredient Cut 평가 (v1.19 신설, ADR-005 Stage 2B/2C "after"-cut pair)

> M1 후반 art sprint 4번째 ingredient cut 12장 (음식 12 × hero ingredient cut 결과 specific) 평가. G_ingredient_cut 5 요소는 §5.10 참조. ingredient whole 12장 (§3.5) + cut anchor 7장 (§3.4)와 동일 도마/칼/bg 일관성 (cross-asset 31장 = cut 7 + whole 12 + cut 12, 한 anchor seed CUT-00 공유).

| Anchor | food_id | hero ingredient cut 결과 | pair cut style | G1 일관성 | G2 단순성 | G3 modern saturated | G4 K-touch | G5 modern clean | G6 약점 회피 | G7 모바일 가독성 | G_new modernity | **G_ingredient_cut (v1.19, 5 요소)** | 종합 |
|--------|---------|------------------------|---------------|----------|----------|--------------------|-----------|----------------|------------|----------------|----------------|--------------------------------|------|
| **ICUT-01 spring onion 송송 (small green discs 20-30개)** | F-01 | 송송 sliced thin rounds | CUT-05 송송 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (G_icut 5 요소)** | **pending M1 후반 4번째** |
| **ICUT-02 Korean zucchini 통썰기 (round discs 5-8개)** | F-02 Janchi-guksu | 통썰기 round whole-slice | CUT-04 통썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk top 1 — cucumber/Italian zucchini 누수 ~50%)** | **pending M1 후반 4번째** |
| **ICUT-03 danmuji 채썰기 (yellow matchstick 15-20개, 8-10cm kimbap-length)** | F-03 | 채썰기 julienne strips | CUT-02 채썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (kimbap-length 8-10cm 강제, bibimbap 5-7cm와 시각 분리)** | **pending M1 후반 4번째** |
| **ICUT-04 fish cake 어슷썰기 (golden-brown oval 5-7개, 6-8cm medium)** | F-04 | 어슷썰기 diagonal oval | CUT-03 어슷썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk top 2 — Japanese naruto pink spiral / chikuwa 누수 ~50%)** | **pending M1 후반 4번째** |
| **ICUT-05 kimchi 다지기 (fine red minced bits scattered)** | F-05 | 다지기 fine mince | CUT-01 다지기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (large chunk 누수 회피, 5-10mm 강제)** | **pending M1 후반 4번째** |
| **ICUT-06 mozzarella whole (no cut, ING-06과 동일 image)** | F-06 | (no cut, whole 그대로 corn dog 안 insertion) | (no cut) | pending | pending | pending | pending | pending | pending | pending | pending | **pending (ING-06과 동일 결과, game-designer 재사용 결정 시 archive)** | **pending M1 후반 4번째 (ING-06 재사용 candidate)** |
| **ICUT-07 daepa 어슷썰기 (large dominant green oval 5-7개, 5-7cm × 1.5-2.5cm, F-04와 시각 분리 CRITICAL)** | F-07 Haemul Pajeon | 어슷썰기 diagonal large green oval | CUT-03 어슷썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk top 3 — F-04 어묵 oval 색 누수 ~40% golden-brown 누수, DOMINANT BRIGHT GREEN 강제)** | **pending M1 후반 4번째 (F-04와 색 분리 CRITICAL)** |
| **ICUT-08 carrot 채썰기 bibimbap (orange matchstick 15-20개, 5-7cm)** | F-08 Bibimbap | 채썰기 short julienne | CUT-02 채썰기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (bibimbap-length 5-7cm 강제, kimbap/japchae와 시각 분리)** | **pending M1 후반 4번째** |
| **ICUT-09 thin beef marinade coated (brown glaze, no cut, F-12 갈비 차별화 CRITICAL)** | F-09 Bulgogi | (no cut, 양념재우기 marinade prep) | (no cut, marinade) | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk top 4 — raw red 또는 cooked char marks ~40% + F-12 갈비 bone visible 누수 CRITICAL: NO bone + brown from MARINADE NOT grill)** | **pending M1 후반 4번째 (F-12 차별화 CRITICAL)** |
| **ICUT-10 soft tofu broken curds (cloud-like white fragments, no cut)** | F-10 Sundubu | (no cut, broken curds) | (no cut, broken) | pending | pending | pending | pending | pending | pending | pending | pending | **pending (risk top 5 — firm cube 누수 ~40%, organic irregular cloud-like fragments 강제)** | **pending M1 후반 4번째** |
| **ICUT-11 carrot 채썰기 japchae (orange matchstick 15-20개, 6-8cm slight diagonal pile, F-08 variation)** | F-11 Japchae | 채썰기 medium julienne (F-08 variation) | CUT-02 채썰기 (F-08 variation) | pending | pending | pending | pending | pending | pending | pending | pending | **pending (slight diagonal pile + 6-8cm length로 F-08과 차별, game-designer 재사용 확정 시 archive)** | **pending M1 후반 4번째 (F-08 재사용 candidate)** |
| **ICUT-12 garlic 다지기 (fine yellowish-white granules 1-3mm scattered)** | F-12 Galbi-gui | 다지기 fine mince granules | CUT-01 다지기 | pending | pending | pending | pending | pending | pending | pending | pending | **pending (slice 5mm 누수 회피, 1-3mm granule 강제)** | **pending M1 후반 4번째** |

> G1 일관성 = 12장 + cut anchor 7장 + ingredient whole 12장 = 31장 cross-asset 같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 outline 두께 인식. G2 단순성 = cutting board + knife + cut 결과 cluster 외 군더더기 0건 (WHOLE intact ingredient 0건 CRITICAL — whole은 ING-XX whole anchor 영역). G4 K-touch = 한식 도마/칼 + 한식 ingredient cut 결과. G_ingredient_cut 5 요소는 §5.10 참조.

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
| F-02 Janchi-guksu (v1.17 mvp v2.2 신규 — 호떡 deprecated 2026-05-30) | t1_001 (mvp v2.2) | T1 | CW | pending | pending | pending | pending | pending | pending | pending | **pending v1.17** (Japanese somen ~50% / Vietnamese pho ~30% / Korean instant ramyeon F-01 혼동 risk) | **pending v1.17** (mvp v2.2 game-designer 교체. hero = 소면 + 멸치 dashi broth + 계란 지단 + 김 strips + 애호박 garnish) | **v1.17 reroll pending v9 (mvp v2.2 trigger — 호떡 deprecated)** |
| F-03 Kimbap | t1_004 | T1 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 (Japanese maki 누수 0) | **FAIL R2** (사용자: 원래 v1이 더 나음, 단 밥알만 더 작게 → v1 base 회복 + rice FINE small fix) | **R3 reroll pending (v1 base 회복)** |
| F-04 Tteokbokki | t1_003 | T1 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1 | **PASS R1** (사용자 피드백 없음) | **LOCK (R1 유지)** |
| F-05 Kimchi Fried Rice | t1_005 | T1 | CW | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 | **FAIL R2** (사용자: v1에서 밥알만 더 작게 → v1 base 회복 + rice FINE small fix) | **R3 reroll pending (v1 base 회복)** |
| F-06 Korean Corn Dog | t1_007 | T1 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 (American corn dog 누수 0) | **FAIL R2** (사용자: 원래 소세지가 안에 있는데, v2는 cheese인지 뭔지 모르겠음 → cross-section 4요소 명확: sausage core + cheese stretch + panko + ketchup/mustard zigzag) | **R3 reroll pending (cross-section 4요소 강화)** |
| F-07 Haemul Pajeon | t1_006 | T1 | CW | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 | **PASS R2** (사용자 silent ACK — 반죽 안 embedded fix v2 적용 OK) | **R2 LOCK candidate (사용자 silent ACK)** |
| F-08 Bibimbap | t2_008 | T2 | CS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | **PASS** R1/R2 | **PASS R2** (사용자 silent ACK — rice FINE small fix v2 적용 OK) | **R2 LOCK candidate (사용자 silent ACK)** |
| F-09 Bulgogi (v1.17 mvp v2.2 신규 — 김치찌개 deprecated 2026-05-30, **F-12 갈비 차별화 CRITICAL**) | t2_009 (mvp v2.2) | T2 | CW | pending | pending | pending | pending | pending | pending | pending | **pending v1.17** (Japanese sukiyaki raw egg dipping ~50% / **F-12 갈비 bone visible cross-contamination ~40% CRITICAL** / Chinese beef stir-fry / American BBQ ribs risk) | **pending v1.17** (mvp v2.2 game-designer 교체. hero = 얇은 marbled 소고기 fanned + soy-pear-garlic marinade pool + 양파/대파/당근/표고 mixed in same cast-iron pan. F-12 갈비 차별화 CRITICAL: NO bone-in LA cut + NOT grilled on wire mesh grate + NO large 18-25cm LA strips + NOT separated meat strips) | **v1.17 reroll pending v9 (mvp v2.2 trigger — 김치찌개 deprecated, F-12 갈비 차별화 CRITICAL)** |
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

## 5.7 M1 후반 Cut Anchor 7장 평가 가이드 (v1.14 신설, ADR-005 Stage 2A rhythm tap prerequisite)

### 5.7.1 배경 — M1 anchor 22/22 LOCK 완료 후 M1 후반 art sprint 진입

> 2026-05-29 M1 anchor 22/22 LOCK 완료 (음식 12 + 환경 5 + 캐릭터 5, commit dfb141e) 후 M1 후반 art sprint 진입. **ADR-005 Stage 2A 재료 준비 = rhythm tap + Knife indicator** prerequisite로 칼/도마 base + cut style 6종 anchor 7장이 필요. prompts-library v1.14에서 §2.5 STYLE_SUFFIX_CUT 신설 + §5.5 full prompts 확장 완료 + 새 driver `tools/gen_cut_anchors_m1.py` 신설. cut anchor 7장 = (a) CUT-00 cutting_board base (anchor seed, 정적 baseline) / (b) CUT-01~06 cut style 6종 (mince/julienne/diagonal/whole/sliced_rounds/cube) cutting RESULT state.
>
> cut style 6종 시그니처 재료 매핑:
> | Cut style | 한식 명 | 시그니처 재료 | 음식 매핑 | BPM |
> |----------|--------|---------------|----------|-----|
> | CUT-01 mince | 다지기 | 마늘 (yellowish-white minced bits 1-3mm) | F-12 갈비 양념 / F-09 김치찌개 | **140 (가장 빠름)** |
> | CUT-02 julienne | 채썰기 | 당근 (orange thin matchstick 4-6cm × 2-3mm × 2-3mm) | F-08 비빔밥 / F-11 잡채 | 110 |
> | CUT-03 diagonal | 어슷썰기 | 어묵+대파 (elongated oval) | F-04 떡볶이 / 모든 국물 | 100 |
> | CUT-04 whole | 통썰기 | 김밥 cylinder 단면 (perfect round disc 3cm × 1.5-2cm + 5색 cross-section) | F-03 김밥 | **70 (가장 느림)** |
> | CUT-05 sliced_rounds | 송송썰기 | 대파 (small thin round 1-1.5cm × 1-3mm + scallion ring) | F-12 갈비 hero garnish / 모든 가니쉬 | 130 |
> | CUT-06 cube | 깍둑썰기 | 두부 (white equal-sided cube 2-2.5cm) | F-09 김치찌개 / F-10 순두부 | 90 |

### 5.7.2 G_cut (cut anchor 7장 게이트, v1.14 신설)

> **정의**: cut anchor 7장 각각이 (1) cut style 시각 식별 명확 (외부인 0.5초 안에 cut shape 답) + (2) hero ingredient 매칭 + (3) Cool Sage `#C8D5C0` bg + 도마/칼 통일 + (4) modern saturated 톤 + (5) cutting RESULT state + cross-cultural negative 5 요소를 모두 충족. G_new (modernity) + G3 (saturated) + G5 (modern clean)과 직교 critical 게이트.

#### G_cut 5 요소 PASS 기준 (7/7 anchors × 5 요소 = 35/35 PASS 시 cut anchor sprint LOCK)

| # | 요소 | 사용자 의도 시각 명세 | PASS 판정 기준 | FAIL 사례 (즉시 reroll) |
|---|------|------------------------------|----------------|----------------------|
| 1 | **CRITICAL — cut style 시각 식별 명확** | 각 cut anchor의 시그니처 cut shape이 외부인 0.5초 안에 식별. CUT-01 mince → many fine irregular bits 1-3mm / CUT-02 julienne → thin elongated parallel matchstick 4-6cm × 2-3mm / CUT-03 diagonal → elongated oval shapes (longer in one dimension) / CUT-04 whole → perfect round disc + 5색 cross-section / CUT-05 sliced_rounds → small thin round 1-1.5cm × 1-3mm + scallion ring pattern / CUT-06 cube → 3D cube volume 2-2.5cm + top/side face shading. CUT-00은 cut shape N/A (정적 baseline). | 각 cut anchor의 시그니처 cut shape이 명확 visible + 외부인 0.5초 안에 cut style 답 (e.g., "다지기" / "채썰기" / "어슷썰기" / "통썰기" / "송송썰기" / "깍둑썰기"). cut shape spectrum (fine ↔ chunk, thin ↔ thick, round ↔ oval) 정확 표현. | cut style 잘못 추론 (mince → chunks / julienne → cube / diagonal → round disc / whole → oval / sliced_rounds → 통썰기 크기 / cube → thin slice) / cut shape ambiguous / 다른 cut style과 혼동 |
| 2 | **hero ingredient 매칭** | 각 cut anchor의 시그니처 ingredient가 정확 매핑: CUT-01 → 마늘 (yellowish-white) / CUT-02 → 당근 (orange #FF9933) / CUT-03 → 어묵 (light golden-brown #C8923C) + 대파 (white-to-green) / CUT-04 → 김밥 (검정 gim + 흰 rice + 5색 cross-section) / CUT-05 → 대파 (bright green + scallion ring) / CUT-06 → 두부 (흰 #FAFAFA). CUT-00은 N/A (no ingredient). | hero ingredient 색 + 모양이 시그니처 매핑과 일치. 다른 ingredient로 잘못 추론 0건. | 다른 ingredient로 추론 (마늘 → 양파 / 당근 → 양파 / 어묵 → 햄 / 김밥 → maki sushi 라이크 / 대파 → 양파 / 두부 → 무) / 색 누수 (당근 yellow 추론 / 어묵 white 추론 / 대파 단순 흰색) |
| 3 | **CRITICAL — Cool Sage `#C8D5C0` bg + 도마/칼 통일 (cross-asset 일관성)** | 모든 7장 cut anchor가 같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 slim outline 2-3px. 음식 12 anchor + 환경 5 anchor와 cross-asset one-game-world identity 형성. 도마 = warm brown wood `#A67049` + slim grain accent 1-2개 + rounded corners + ~16:9 가로비례. 칼 = warm brown wood handle + silver-gray steel blade `#C8C8C8` + slim simple geometric. | 7장 contact sheet 보았을 때 같은 도마 + 같은 칼 + 같은 Cool Sage bg + 같은 outline 인식. CUT-00 anchor seed reference upload로 CUT-01~06 일관성 lock 달성. | 도마 색 변동 (different warm brown shade / 회색 추론) / 칼 silhouette 변동 (blade 모양 다름 / handle 색 다름) / bg 다름 (CUT-00 Cool Sage였는데 CUT-03만 cream-white 등) / outline 두께 7장 mixed (CUT-00 3px / CUT-05 4px 등) |
| 4 | **modern saturated 톤 (베이지/scrapbook 0건)** | 채도 80-90% / warm food + cool background balance / Royal Match aesthetic / 베이지·cream·scrapbook·storybook·Cookie Run 2021 톤 0건. | 채도 80-90% 명확. modern flat clean 톤. 베이지 bg 0건. | 채도 70% 이하 muted / 채도 100% neon / 베이지 bg / Cookie Run 2021 frosting / scrapbook/storybook tone / golden hour |
| 5 | **CRITICAL — cutting RESULT state + cross-cultural negative** | (a) **cutting RESULT state** — cut된 결과 상태 (재료가 도마 위에 놓여있음), NOT cutting action mid-motion (칼이 chopping 중). 칼은 LEFT side에 set down placement. / (b) **cross-cultural negative**: Japanese kitchen knife (santoku/deba/yanagiba single-bevel asymmetric blade + 검정 resin/octagonal magnolia wood handle + kanji engraving) 0건 / Chinese cleaver (rectangular tall blade much wider) 0건 / Western chef knife (large triangular blade with bolster) 0건 / mortar 절구 0건 / CUT-04 통썰기 Japanese maki sushi (raw fish + compressed rice + shiny nori) 누수 0건 / CUT-06 깍둑썰기 Chinese mapo tofu (sauce 추가) 누수 0건. | cutting RESULT state 명확 (재료 cut된 상태, 칼 정적 placement). Japanese/Chinese/Western knife silhouette 0건. 절구 0건. CUT-04 maki sushi 누수 0건. CUT-06 mapo tofu 누수 0건. | cutting action mid-motion (칼이 raised mid-chop) / Japanese santoku silhouette / kanji engraving / Chinese cleaver wide rectangular blade / Western chef knife with bolster / 절구 누수 / CUT-04 maki sushi 추론 / CUT-06 sauce 추가 / 인간 hand 추가 |

#### G_cut LOCK 조건 (v1.14)

> **LOCK = 7/7 anchors × 5 요소 = 35/35 PASS**. 1 anchor라도 1 요소 FAIL이면 cut anchor sprint REROLL. **CUT-00 anchor seed FAIL 시 전체 FAIL** (CUT-01~06 reference upload 일관성 무너짐).

#### 부분 통과 정책

| 상황 | 정책 |
|------|------|
| 7 anchors × 5 요소 = 35/35 PASS | 완전 통과, 즉시 cut anchor sprint LOCK → §0 anchor 표 CUT-00~06 status 갱신 + ADR-005 Stage 2A 구현 진입 |
| 6 anchors LOCK + 1 anchor 1-2 요소 FAIL | **CONDITIONAL** — FAIL anchor 단일 reroll (`--only CUT-XX --version v2`) |
| 5 anchors LOCK + 2 anchors 1-2 요소 FAIL | **CONDITIONAL** — 2 FAIL anchors에 reroll |
| 4 anchors 이하 LOCK 또는 1 anchor 3+ 요소 FAIL | **FAIL** — pm 에스컬레이션 / prompt 재설계 (cut shape 명세 강화) / 사용자 의도 재확인 |
| CUT-00 (anchor seed) FAIL | **FAIL** — CUT-00 재생성 우선. CUT-00 v1 anchor가 CUT-01~06 cross-cut 일관성 시드. |
| G_cut #1 cut style 시각 식별 (CRITICAL) FAIL | **REROLL** — cut shape 명세 강화 (e.g., julienne FAIL 시 "thin matchstick 4-6cm × 2-3mm × 2-3mm" 더 강조). 같은 cut anchor 다른 시그니처 ingredient로 swap도 검토 (예: CUT-02 julienne 당근 FAIL 시 무 julienne로 swap). |
| G_cut #3 cross-asset 일관성 FAIL | **CONDITIONAL** — CUT-00 reference upload 재시도 (음식 anchor F-01 / 환경 anchor BG-01과 동일 패턴). 도마/칼 silhouette description 강화. |

### 5.7.3 Cut anchor 7장 라운드 예산

- **R1 (1차 시도, 7장 batch)**: `py tools/gen_cut_anchors_m1.py --model gpt-image-1 --quality medium`. 7장 × $0.042 ≈ $0.29, ~3-4분. 사용자 시각 확인 ~10분, art-director 평가 0.5h.
- **R2 (follow-up reroll, FAIL anchor 집중)**: `--only CUT-XX --version v2`. +10-15분.
- **R3 (재시도)**: R2 후에도 FAIL 2+ anchors이면 → pm 에스컬레이션. cut shape 명세 재설계 또는 ingredient swap 검토.

### 5.7.4 cut anchor 7장 ChatGPT 약점 risk top 3 (prompts-library v1.14 §5.5.9 sync)

| Rank | Cut anchor | 누수 risk | default % | 회피 전략 |
|------|-----------|----------|-----------|----------|
| 1 | CUT-04 통썰기 | Japanese maki sushi (김밥 cylinder 단면 → maki 추론) | ~50% | matte gim + cooked vegetables (danmuji yellow + carrot + spinach + ham) + Korean short-grain rice 명시 + "NOT Japanese maki sushi, NOT raw fish" negative |
| 2 | CUT-06 깍둑썰기 | Chinese mapo tofu (sauce 추가) | ~40% | "raw cubed tofu prep state on bare cutting board, NO sauce/broth" 명시 |
| 3 | CUT-00/01-06 | Japanese kitchen knife (santoku/deba single-bevel) | ~30% | "modern Korean kitchen knife (식칼) — slim rectangular blade + warm brown wood handle" + "NOT santoku asymmetric blade, NOT kanji engraving" negative |

---

## 5.8 M1 후반 Ingredient Whole 12장 평가 가이드 (v1.15 신설, ADR-005 Stage 2A "before"-cut pair)

### 5.8.1 배경 — M1 후반 art sprint 2번째 진입 (cut anchor 7장 LOCK 완료 후)

> 2026-05-30 M1 후반 art sprint 1번째 (cut anchor 7장) LOCK 완료 후 2번째 sprint 진입. ADR-005 Stage 2A 재료 준비 미니게임은 음식별 hero ingredient를 적절한 cut style로 자르는 형태 → 음식 12 × hero ingredient whole(자르기 전) state asset이 필요. cut된 결과("after")는 §5.5 cut anchor 7장 재사용 (한 cut style이 여러 음식에 매핑되므로 12 ≠ 7), 본 sprint는 **whole 12장만 추가 생성** (ING-01~12). prompts-library v1.15에서 §5.5.0 음식↔cut 매핑 표 + §5.6 ingredient whole 12장 prompt set + 새 driver `tools/gen_ingredient_anchors_m1.py` 신설 완료.
>
> ingredient whole 12장 매핑:
> | ID | food | hero ingredient | pair cut style | visual key |
> |----|------|----------------|---------------|-----------|
> | ING-01 | F-01 Ramyeon | spring onion whole | CUT-05 송송 | white-to-green cylindrical stalk ~18-22cm |
> | ING-02 | F-02 Hotteok | peanut whole | CUT-01 다지기 | 6-8 whole peanut shells (tan-beige lobed bumpy) |
> | ING-03 | F-03 Kimbap | danmuji whole | CUT-02 채썰기 | fat vibrant yellow cylinder ~12-15cm × 3-3.5cm |
> | ING-04 | F-04 Tteokbokki | fish cake sheet whole | CUT-03 어슷썰기 | flat golden-brown rectangular sheet ~14-18cm × 6-8cm × 1-1.5cm |
> | ING-05 | F-05 Kimchi Bokkeumbap | kimchi leaf whole | CUT-01 다지기 | folded napa cabbage leaf + white rib + red kimchi paste |
> | ING-06 | F-06 Corn Dog | mozzarella stick whole | **(no cut)** | clean milky-white cylindrical cheese stick ~10-12cm × 2-2.5cm |
> | ING-07 | F-07 Haemul Pajeon | daepa large scallion whole | CUT-03 어슷썰기 | TWO thicker daepa stalks ~22-26cm × 2-2.5cm |
> | ING-08 | F-08 Bibimbap | carrot whole | CUT-02 채썰기 | vibrant orange tapered cone + small green leafy crown ~15-18cm |
> | ING-09 | F-09 Kimchi Jjigae | firm tofu block whole | CUT-06 깍둑썰기 | matte white rectangular block ~12×9×3.5cm + sharp edges |
> | ING-10 | F-10 Sundubu | soft tofu tube whole | **(no cut, broken curds)** | clear plastic tube ~18-20cm × 5-6cm + cloud-like white contents |
> | ING-11 | F-11 Japchae | carrot whole (F-08 variation) | CUT-02 채썰기 | same as ING-08 + slight diagonal angle + larger leafy crown |
> | ING-12 | F-12 Galbi-gui | garlic cloves whole | CUT-01 다지기 | 5-7 peeled off-white teardrop cloves cluster |

### 5.8.2 G_ingredient_whole (ingredient whole 12장 게이트, v1.15 신설)

> **정의**: ingredient whole 12장 각각이 (1) hero ingredient 시각 식별 명확 + (2) WHOLE/UNCUT state 명확 + (3) Cool Sage `#C8D5C0` bg + 도마 + 칼 LEFT side static 통일 + (4) modern saturated 톤 + 단순화 + (5) cross-cultural 누수 0건 5 요소를 모두 충족. G_new (modernity) + G3 (saturated) + G5 (modern clean)과 직교 critical 게이트.

#### G_ingredient_whole 5 요소 PASS 기준 (12/12 anchors × 5 요소 = 60/60 PASS 시 ingredient whole sprint LOCK)

| # | 요소 | 사용자 의도 시각 명세 | PASS 판정 기준 | FAIL 사례 (즉시 reroll) |
|---|------|------------------------------|----------------|----------------------|
| 1 | **CRITICAL — hero ingredient 시각 식별 명확** | 각 ingredient whole anchor의 시그니처 ingredient가 외부인 0.5초 안에 식별 (카테고리 + 종류 모두). ING-01 → 대파 cylindrical white-to-green / ING-02 → 견과류 lobed bumpy shell / ING-03 → 단무지 fat bright yellow cylinder / ING-04 → 어묵 flat golden-brown sheet / ING-05 → 김치 red-coated folded leaf with white rib / ING-06 → 모짜렐라 milky-white cylindrical stick / ING-07 → 대파 daepa 2 thicker stalks / ING-08 → 당근 orange tapered cone + leafy top / ING-09 → 두부 firm white rectangular block + sharp edges / ING-10 → 두부 soft clear plastic tube + cloud-like white contents / ING-11 → 당근 (F-08 + diagonal angle + larger leafy crown) / ING-12 → 마늘 5-7 peeled teardrop cloves cluster. | 각 ingredient의 시그니처 모양 + 색 + 크기가 명확 visible. 외부인 0.5초 안에 ingredient 카테고리 + 종류 답. cross-ingredient 디스트랙터 페어 (단무지 ↔ 신선 daikon / 어묵 ↔ Japanese naruto / spring onion ↔ daepa / firm tofu ↔ soft tofu / mozzarella ↔ cheddar / 마늘 ↔ 양파) 정확 구분. | 다른 ingredient로 추론 (단무지 → banana / 어묵 → 햄 / 두부 firm → 모짜렐라 / 모짜렐라 → 두부) / 색 누수 (단무지 pale beige / 어묵 white / 김치 brown sauce / 모짜렐라 yellow cheddar) / 크기 어긋남 (단무지 너무 슬림 / 두부 너무 얇음) / 디스트랙터 페어 혼동 |
| 2 | **CRITICAL — WHOLE/UNCUT state 명확** | 모든 12장이 cut 전 상태. 도마 위에 single intact whole ingredient만 (cut pieces scattered 0건 — minced bits / julienne strips / diagonal oval slices / round discs / cubes 모두 0건). ING-06 cheese / ING-10 soft tofu도 broken pieces 0건 (whole tube/stick). | 도마 위에 single intact whole ingredient + cut pieces scattered 0건. 칼은 LEFT side static placement, NOT chopping mid-motion. | cut pieces scattered 누수 (minced/julienne/sliced/cubes 1개라도 board에 추가) / cutting action mid-motion (칼이 raised mid-chop) / ingredient 자체가 partially cut (반쯤 자른 상태) / broken into pieces (soft tofu scoop 누수) |
| 3 | **CRITICAL — Cool Sage `#C8D5C0` bg + 도마 + 칼 LEFT side static (cross-asset 일관성)** | 모든 12장 ingredient whole anchor가 §5.5 cut anchor 7장과 같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 slim outline 2-3px. 19장 (cut 7 + ingredient 12) cross-asset one-game-world identity 형성. 도마 = warm brown wood `#A67049` + slim grain accent 1-2개 + rounded corners + ~16:9 가로비례. 칼 = warm brown wood handle + silver-gray steel blade `#C8C8C8` + slim simple geometric. 칼은 LEFT side, blade flat, handle lower-left corner (cut anchor와 동일 placement). | 12장 contact sheet + cut anchor 7장 같이 보았을 때 19장 모두 같은 도마 + 같은 칼 + 같은 Cool Sage bg + 같은 outline 인식. CUT-00 anchor seed reference upload로 ING-01~12 일관성 lock 달성. | 도마 색 변동 (different warm brown shade) / 칼 silhouette 변동 (cut anchor의 LEFT 정적 placement와 다름 — 칼 다른 위치 / 칼 누락 / 칼 mid-swing) / bg 다름 (cream-white / 베이지 누수) / outline 두께 mixed |
| 4 | **modern saturated 톤 + 단순화 (베이지/scrapbook/heavy texture 0건)** | 채도 80-90% / warm food + cool background balance / Royal Match aesthetic / 1-2 subtle shading lines + ONE specular highlight per element / heavy texture (heavy wood grain / heavy steel reflection / heavy ingredient texture) 0건 / 베이지·cream·scrapbook·storybook·Cookie Run 2021 톤 0건. | 채도 80-90% 명확. modern flat clean 톤. heavy texture 0건. 베이지 bg 0건. ingredient 표면 subtle shading + 1 highlight만. | 채도 70% 이하 muted / 채도 100% neon / 베이지 bg / Cookie Run frosting / scrapbook/storybook tone / heavy wood grain texture on board / heavy noise/grain on ingredient surface / multi-layer complex shading |
| 5 | **CRITICAL — cross-cultural 누수 0건 (각 ingredient 특화 + 공통)** | (a) **ingredient별 특화 negative** (top 5 risk): ING-03 banana/신선 daikon 누수 0건 / ING-04 Japanese naruto pink spiral / chikuwa hollow tube 누수 0건 / ING-07 F-01 spring onion 변종 (얇음·짧음) 누수 0건 / ING-06 cheddar yellow / 두부 matte square 누수 0건 / ING-12 whole garlic bulb (papery skin) / 양파 누수 0건. / (b) **cross-anchor 공통 negative**: Japanese kitchen knife (santoku/deba single-bevel + kanji) 0건 / Chinese cleaver (rectangular tall wide blade) 0건 / Western chef knife (large triangular bolster) 0건 / mortar 절구 0건 / 인간 hand 0건. | ingredient별 특화 누수 0건 + cross-anchor 공통 negative 0건. 한식 도마 + 한식 칼 + 한식 ingredient 카테고리 인식. | ingredient 특화 누수 (단무지 banana 추론 / 어묵 naruto pink spiral / daepa thin spring onion 추론 / mozzarella cheddar yellow / 마늘 whole bulb papery skin) / Japanese kitchen knife silhouette / 절구 누수 / 인간 hand 추가 / Chinese cleaver wide blade |

#### G_ingredient_whole LOCK 조건 (v1.15)

> **LOCK = 12/12 anchors × 5 요소 = 60/60 PASS**. 1 anchor라도 1 요소 FAIL이면 ingredient whole sprint REROLL. **CUT-00 anchor seed (이미 §5.7에서 LOCK)이 ingredient whole 12장의 cross-asset 일관성 시드** — CUT-00 image reference upload 의무.
>
> **ING-11 archive 가능성**: game-designer foods CSV `prep_*` 후속 확정 시 F-11 잡채가 F-08 비빔밥 carrot anchor를 재사용하는 것으로 결정되면 ING-11 archive (assets-raw 파일은 보존, §0 anchor 표 status `재사용 결정 archived`로 갱신, 본 게이트는 11/12 anchors × 5 = 55/55 PASS로 조정).

#### 부분 통과 정책

| 상황 | 정책 |
|------|------|
| 12 anchors × 5 요소 = 60/60 PASS | 완전 통과, 즉시 ingredient whole sprint LOCK → §0 anchor 표 ING-01~12 status 갱신 + ADR-005 Stage 2A 구현 진입 (cut 7 + whole 12 = 19장 모두 사용 가능) |
| 11 anchors LOCK + 1 anchor 1-2 요소 FAIL | **CONDITIONAL** — FAIL anchor 단일 reroll (`--only F-XX --version v2`) |
| 9-10 anchors LOCK + 2-3 anchors 1-2 요소 FAIL | **CONDITIONAL** — FAIL anchors batch reroll (`--only F-XX,F-YY --version v2`) |
| 8 anchors 이하 LOCK 또는 1 anchor 3+ 요소 FAIL | **FAIL** — pm 에스컬레이션 / prompt 재설계 (ingredient 식별 명세 강화) / game-designer 매핑 재확인 |
| G_ing #1 hero ingredient 시각 식별 (CRITICAL) FAIL | **REROLL** — ingredient 명세 강화 (e.g., ING-03 단무지 → "VIBRANT YELLOW + fat cylinder + flat end caps + pickled glossy" 더 강조). 같은 음식 다른 hero ingredient로 swap도 검토 (game-designer 확정 후). |
| G_ing #2 WHOLE state (CRITICAL) FAIL | **REROLL** — "ready-to-cut state, NO cut pieces, NO chopped bits" explicit 강조. cut state가 동시 출현하면 본 ingredient whole anchor의 game purpose가 무너짐. |
| G_ing #3 cross-asset 일관성 FAIL | **CONDITIONAL** — CUT-00 reference upload 재시도. 도마/칼 silhouette description 강화. |

### 5.8.3 Ingredient whole 12장 라운드 예산

- **R1 (1차 시도, 12장 batch)**: `py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium`. 12장 × $0.042 ≈ $0.50, ~4-5분. 사용자 시각 확인 ~15분, art-director 평가 0.5h.
- **R2 (follow-up reroll, FAIL anchor 집중)**: `--only F-XX --version v2`. +10-15분.
- **R3 (재시도)**: R2 후에도 FAIL 3+ anchors이면 → pm 에스컬레이션. ingredient 식별 명세 재설계 또는 hero ingredient swap 검토 (game-designer foods CSV `prep_*` 확정 결과 인용).

### 5.8.4 ingredient whole 12장 ChatGPT 약점 risk top 5 (prompts-library v1.15 §5.6.14 sync)

| Rank | Ingredient | 누수 risk | default % | 회피 전략 |
|------|-----------|----------|-----------|----------|
| 1 | ING-03 단무지 (yellow pickled radish) | 신선 백색 daikon 또는 banana 누수 | ~50% | VIBRANT YELLOW #F5D43E + fat cylinder + flat end caps + "pickled radish" 키워드 강제 + "NOT fresh white daikon, NOT banana" negative |
| 2 | ING-04 어묵 (fish cake sheet) | Japanese naruto (pink spiral cross-section) 또는 chikuwa (hollow tube) 누수 | ~50% | FLAT rectangular sheet + light golden-brown #C8923C + "NOT cylindrical, NOT pink spiral" negative |
| 3 | ING-07 대파 daepa (large scallion) | F-01 spring onion 변종으로 추론 (얇음/짧음) | ~40% | THICKER + LONGER variety (~22-26cm × 2-2.5cm) + 2 stalks + "THICKER LARGER variety than F-01 ramyeon spring onion" 명시 |
| 4 | ING-06 모짜렐라 (cheese stick) | cheddar yellow 또는 두부 matte square 누수 | ~40% | CLEAN MILKY WHITE + GLOSSY cylindrical + "NOT cheddar yellow/orange, NOT firm tofu sharp square" negative |
| 5 | ING-12 마늘 (garlic cloves) | whole garlic bulb (papery skin) 또는 양파 누수 | ~35% | PEELED INDIVIDUAL CLOVES + teardrop shape + 5-7 cluster + "NOT whole garlic bulb with papery skin, NOT onion" negative |

> 부차 risk (P2): ING-01 spring onion (Japanese negi 누수 ~25%), ING-09 firm tofu (silken/soft tofu 누수 ~25%), ING-10 soft tofu (F-09 firm tofu rectangular block 누수 ~25%).

### 5.8.5 game-designer 후속 confirm 사안 (음식 12 × hero ingredient 매핑 검증)

> 본 v1.15 음식 12 × hero ingredient × cut style 매핑은 art-director 임시 직관 매핑. game-designer가 foods CSV `prep_*` 컬럼으로 정식 매핑을 lock 시 (a) 일부 hero ingredient 변경 / (b) cut style 변경 가능. 검증 사안 12행 표는 [`prompts-library.md` v1.15 §5.6.16](prompts-library.md) 참조. game-designer 확정 후 art-director는 (a) 본 §5.8 + prompts-library §5.5.0 매핑 표 갱신 / (b) §5.6 ingredient whole prompt 일부 reroll / (c) driver script INGREDIENTS list sync 작업 진행.

---

## 5.9 M1 후반 양친 Reaction 6컷 평가 가이드 (v1.18 v2 image edit approach, supersedes v1.16 v1 prompt-only)

> **v1.18 v2 image edit patch (2026-05-30)**: v1 (prompt-only generation, `tools/gen_reaction_anchors_m1.py` gpt-image-1 medium 1024×1024 6장 batch) 결과 사용자 시각 확인 후 family IP 2건 FAIL (R-01/R-03 어머니 hair round-bun + side-puff vs CH-02 base round-bun simple mismatch + R-04 vs R-05/R-06 아버지 hair tone + shirt tone inconsistency) 발견 → v1 6장 deprecated, v2 image edit (CH-02_mother.png + CH-03_father.png base 직접 입력 + 표정만 변경) approach로 supersede. **G_reaction 5 요소 기준 무변경** (LOCK = 6/6 anchors × 5 = 30/30 PASS, 본 §5.9.2 그대로 적용). 단 v2는 image edit API 사용으로 G_reaction #1 (family IP 식별 명확) PASS 확률 ↑ (prompt-only가 자연어 description으로 hair shape/tone subtle detail 일관 재현 못했던 한계를 base PNG 직접 입력으로 극복). v2 driver = `tools/edit_reaction_anchors_v2.py` (BG sprint v4 template 기반 image edit API + COMMON_FRAME family IP IDENTICAL 강제 + 어머니 round-bun simple 명시 + 아버지 darker tone EXACTLY 일치 명시 + bust-up + Cool Sage bg + 표정만 변경 + 6 expression_prompt). 실행 명령: `py tools/edit_reaction_anchors_v2.py --quality medium` (6장 × $0.042 ≈ $0.25, ~2-3분, 출력 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v2.png` v1과 공존). 자세한 v2 trigger + diff 표 + R3 fallback은 §6.17 참조.
>
> **v2 risk top 3 (v1 prompt-only risk top 5와 다른 새 risk)**:
> 1. **R-04 ★1 thumb-up CH-03 base carry over (CRITICAL ~30%)**: image edit이 base의 thumb-up gesture를 표정과 별개 element로 인식 못하고 carry over할 risk. R-04 expression_prompt에 "NO thumb-up gesture" explicit 강제로 회피.
> 2. **base의 default expression 유지 (★1/★2/★3 gradient 무너짐, ~25%)**: image edit이 표정 변경을 충분히 강하게 적용 안 하면 6장 모두 base default 표정 (subtle smile)에 가까워질 risk. COMMON_FRAME "ONLY change the FACIAL EXPRESSION" + 각 expression_prompt "EXPRESSION CHANGE — ★N (gradient description)" 명시.
> 3. **base의 bowl/물건 prop carry over (~20%)**: CH-02 base는 양손으로 그릇 들고 있는데 R-03 ★3은 손이 cheeks 옆으로 가야 함 → conflict risk. R-03/R-06 expression_prompt에 hand position 명시.
>
> 부차 risk (P2): R-01/R-03 어머니 hair side-puff 회귀 ~15% (COMMON_FRAME explicit 강제로 회피) / R-04/R-05/R-06 아버지 lighter tone 회귀 ~10% (COMMON_FRAME "EXACTLY match base, NOT lighter" explicit 강제) / R-03 heart icon 폭주 ~20% / R-06 sparkle 폭주 ~25%.
>
> v1 prompt-only risk top 5 (R-01 sad teardrop 누수 ~60% 등)는 v2에서도 잠재 risk이나 image edit이 base의 정상 expression (sad 0건)을 input으로 사용하므로 sad teardrop 추론 risk는 v2에서 ~20%로 ↓ 기대.

### 5.9.1 배경 — M1 후반 art sprint 3번째 진입 (ingredient sprint와 fully parallel)

> 2026-05-30 M1 후반 art sprint 2번째 (ingredient whole 12장) 진행 중 + **art sprint 3번째 (양친 reaction 6컷) 병렬 동시 진입**. 친구 가족 단위 (project_adr003 2026-05-23 lock) 어머니 + 아버지 L11 동시 unlock + Scene 3 식탁 reaction context + ADR-005 Total Score gradient (재료 25% × 준비 20% × 방법 20% × 시간 35% → ★1 30%+ / ★2 60%+ / ★3 90%+) + friends-system 호불호 axis (project_adr003 v0.2 spicy/sweet/oily/salty/mild) trigger로 양친 reaction 6컷 anchor 필요. prompts-library v1.16에서 §2.5 STYLE_SUFFIX_REACTION 명시 + §5.7 full prompts 확장 + 새 driver `tools/gen_reaction_anchors_m1.py` 신설 완료.
>
> art-director가 Week 1 commit 7a6cffb base 4장 (`assets-raw/week1-anchors/`) Read tool로 시각 확인한 결과:
> - **CH-02_mother.png** (어머니 base) = round-bun short black hair (simple dark shape) + 빨간 V-collar jeogori top (#F23E3E 톤) + soft white apron + 양손으로 작은 음식 그릇 들고 + warm motherly subtle smile + 정상 dot eyes + light pink blush. default expression ≈ **★1-★2 경계** (subtle warm smile mouth closed, 약간 ★1 쪽). → R-01~R-03 어머니 3컷의 family IP base reference. **R-02 ★2가 CH-02 base default와 가장 가까움** → anchor seed.
> - **CH-03_father.png** (아버지 base) = short salt-and-pepper hair (gray-and-black simple shape) + solid teal-green button-up shirt (#2A8A6C 톤) + dark navy pants + LEFT 손 thumb-up + RIGHT 손 hip 옆 + slim smile + 정상 dot eyes + 매우 light pink blush. default expression ≈ **★2 경계** (thumb-up 때문에 ★1보다 한 단계 위). → R-04~R-06 아버지 3컷의 family IP base reference. **R-05 ★2가 CH-03 base default와 가장 가까움** → anchor seed.
> - **CH-04_mother_star1.png** (Week 1 어머니 ★1 variant) = round-bun + 빨간 sweater (apron 없음) + **sad teardrop expression** (한 눈에 작은 파란 teardrop visible) + downturned 입 + 한 손이 chin 쪽 어색한 worried 자세. → **본 sprint 재해석에서 폐기**. ADR-005 ★1 = "30%+ acceptable but not exciting" mild positive acceptance gradient ↔ Week 1 sad teardrop은 부정 reaction (0-29% 영역 또는 호불호 penalty deep negative). R-01 어머니 ★1 prompt는 subtle warm smile + 정상 open dot eyes로 새로 작성. CH-04 file 자체는 보존 (향후 deep negative reaction asset으로 재활용 가능).
> - **CH-05_father_star3.png** (Week 1 아버지 ★3 variant) = salt-and-pepper hair + **파란** button-up shirt (CH-03 base teal-green과 약간 다른 톤, 시각 디테일 inconsistency) + excited eyes-closed-arc happy + wide open mouth smile + LEFT thumb-up + RIGHT fist raised + **4개 simple flat orange sparkle accents** (얼굴 주변) + light pink blush. → **본 sprint settle 형태에 가장 가까움**. R-06 아버지 ★3 prompt는 CH-05 variant 거의 그대로 재현 (단 shirt teal-green CH-03 base 정확 매칭 + bust-up framing). **CH-05 image를 R-06 생성 시 추가 reference upload 권장** (★3 expression intensity reference).

### 5.9.2 G_reaction (reaction anchor 6장 게이트, v1.16 신설)

> **정의**: reaction anchor 6장 각각이 (1) 캐릭터 family IP 식별 명확 + (2) ★1/★2/★3 expression gradient 명확 + (3) anchor consistency (Cool Sage bg + cross-asset cluster) + (4) chibi mascot proportions + bust-up portrait + (5) sad/sleeping/negative expression 누수 0건 + 한식 family context 유지 5 요소를 모두 충족. G_new (modernity) + G3 (saturated) + G5 (modern clean)과 직교 critical 게이트.

#### G_reaction 5 요소 PASS 기준 (6/6 anchors × 5 요소 = 30/30 PASS 시 reaction sprint LOCK)

| # | 요소 | 사용자 의도 시각 명세 | PASS 판정 기준 | FAIL 사례 (즉시 reroll) |
|---|------|------------------------------|----------------|----------------------|
| 1 | **CRITICAL — 캐릭터 family IP 식별 명확** | 어머니 (R-01/R-02/R-03) = Week 1 CH-02_mother base와 동일 family IP — round-bun short black hair (simple dark shape) + 빨간 V-collar Korean jeogori-style top (vivid persimmon red) + soft white apron + 두 small black dot eyes + small arc smile + LIGHT pink (#FFCFCF) soft cheek blush + warm motherly nurturing tone. 아버지 (R-04/R-05/R-06) = Week 1 CH-03_father base와 동일 family IP — short salt-and-pepper hair (gray-and-black simple shape) + solid teal-green button-up shirt + small black dot eyes + small arc smile + optional LIGHT pink cheek blush + kind reserved fatherly tone. 6장 contact sheet에서 어머니 3장 + 아버지 3장 각각 같은 family IP (얼굴/머리/옷)으로 인식. | 어머니 3장 (R-01/R-02/R-03) 모두 CH-02_mother base와 같은 family IP (round-bun + 빨간 top + apron) 인식 + 아버지 3장 (R-04/R-05/R-06) 모두 CH-03_father base와 같은 family IP (salt-and-pepper hair + teal-green shirt) 인식. outline 두께·features·컬러 saturation 톤 Week 1 base와 일치. | family IP 다름 (어머니가 다른 hair style/outfit로 추론 / 아버지가 다른 hair color/shirt color로 추론) / outline 두께 mixed (Week 1 base는 2-3px, 본 sprint anchor는 4px+ heavy 누수) / 컬러 saturation 다름 (Week 1 base는 80-90%, 본 anchor는 muted 70% 이하 또는 neon 100%) / chibi proportions 다름 (Week 1 base는 1:1.7, 본 anchor는 anime girl 1:2.5+ tall slender 누수) |
| 2 | **CRITICAL — ★1/★2/★3 expression gradient 명확** | 3 단계 표정 진화가 어머니/아버지 각각 명확 visible: ★1 = SUBTLE small arc smile (mouth closed, 입꼬리 살짝 up) + 정상 OPEN dot eyes / ★2 = BIGGER warm smile mouth slightly OPEN + soft UPWARD CRESCENT ARC eyes (★1 ↔ ★3 in-between, 부드러운 호) / ★3 = BIG WIDE OPEN delighted smile + CLOSED-ARC HAPPY eyes (upward crescent smile-strokes). 어머니/아버지 톤 차이 — **어머니** = warm motherly nurturing tone amplification (★1 subtle warm / ★2 genuine warm happy / ★3 motherly delight + optional heart icon) / **아버지** = reserved masculine tone breaking into excitement amplification (★1 slim reserved / ★2 relaxed enjoyment + casual single thumb-up / ★3 excited big + double thumb-up + sparkle Week 1 CH-05 settle 형태). | 외부인 6장 contact sheet 보고 어머니 ★1 → ★2 → ★3 gradient 순서 + 아버지 ★1 → ★2 → ★3 gradient 순서 0.5초 안에 답 가능. 3 축 진화 (eye shape / mouth opening / body language) 동시 amplification 인식. 어머니/아버지 톤 차이 (motherly warmth vs reserved masculine) 명확. | gradient flat화 (★1=★2=★3 표정이 거의 같음) / gradient 역전 (★1이 ★3보다 더 expressive) / ★2 in-between collapse (★2가 ★1 또는 ★3로 똑같이 collapse, in-between gradient 단계 안 보임) / 어머니/아버지 톤 구분 안 됨 (어머니가 너무 reserved 또는 아버지가 너무 motherly nurturing) / ★3에서 closed-arc eyes가 sad/sleeping closed eyes로 잘못 추론 (CRITICAL) |
| 3 | **anchor consistency (Cool Sage `#C8D5C0` bg + cross-asset cluster)** | 모든 6장이 Cool Sage solid bg + slim outline 2-3px + modern saturated 80-90% 톤 + 음식 12 + cut 7 + ingredient whole 12 = 37-asset Scene 3 cross-asset cluster 합류 인식. 캐릭터 5장 CH-01~05의 soft mint `#9BE0D2` bg와는 다른 톤 (Scene 3 식탁 context cross-asset 결정). 단일 subtle ambient ellipse shadow under character bust. | 6장 contact sheet + 음식/cut/ingredient cluster sample과 같이 보았을 때 같은 Cool Sage bg + 같은 outline 톤 + 같은 saturation 80-90% 인식. cluster 합류 visual 일관성. | bg 다름 (베이지 #FAEFD8 누수 / cream #FFF1D6 누수 / 캐릭터 5장 soft mint #9BE0D2 누수 / golden hour sunset warm 누수) / outline 두께 mixed (Week 1 + 본 anchor 6장 across 7-9장 contact sheet에서 outline 두께가 일관 안 됨) / saturation muted/neon 누수 / multi-layer complex shading 누수 / scrapbook/storybook texture 누수 |
| 4 | **chibi mascot proportions + bust-up portrait** | chibi 1:1.7 head-to-body ratio (big head, smaller visible shoulders/upper body) + **bust-up portrait (head and shoulders only)** — Scene 3 식탁 seated context에서 framed from chest up. full body / lower body / legs / feet 0건 visible. character가 frame 중앙에 well-centered. | 6장 모두 bust-up framing (head and shoulders only, 다리/하반신 0건 visible) + chibi 1:1.7 proportions (big head smaller shoulders) 인식. character가 well-centered. | full body 누수 (다리/feet visible) / lower body 누수 (허리/엉덩이 visible) / chibi proportions 다름 (anime girl 1:2.5+ tall slender / realistic adult 1:6+ 누수) / framing 어색 (head crop 너무 위 또는 너무 아래) / multiple characters 결합 누수 (어머니 + 아버지 동시 한 image) |
| 5 | **CRITICAL — sad/sleeping/negative expression 누수 0건 + 한식 family context 유지** | (a) **부정 expression 누수 0건**: sad teardrop (Week 1 CH-04_mother_star1 pattern) 0건 / sleeping closed eyes 0건 / crying tears 0건 / 슬픈 downturned 입 0건 / disappointed cold expression 0건. (b) **한식 family context 유지**: Korean family IP 인식 (한복 jeogori 모티프 OK, 단 자수/패턴 없는 plain solid fill) / Japanese 기모노 / 중국 치파오 / Western Christmas sweater 누수 0건 / anime girl big sparkly eyes 누수 0건 / school uniform 누수 0건 / deep dark Cookie Run frosting pink cheek 누수 0건 / mortar 절구 누수 0건. | 6장 모두 긍정 reaction expression 인식 (★1 mild positive acceptance / ★2 happy pleased / ★3 very happy excited). 부정 expression 0건. Korean family context 인식 (어머니 jeogori 모티프 + 아버지 button-up shirt + chibi mascot proportions). 일/중/Western culture 누수 0건. | sad/teardrop 누수 (R-01 어머니 ★1에서 Week 1 CH-04 sad pattern carry over CRITICAL) / sleeping closed eyes 누수 (★3에서 closed-arc happy → sleeping 잘못 추론) / crying tears 누수 / anime girl big sparkly eyes / 기모노 누수 (어머니 V-collar jeogori → 기모노 cross-cultural 추론) / 치파오 누수 / deep dark Cookie Run pink cheek / mortar 절구 / sparkle detail 폭주 (anime sparkle effect 누수, 본 sprint sparkle은 simple flat geometric single color만) |

#### G_reaction LOCK 조건 (v1.16)

> **LOCK = 6/6 anchors × 5 요소 = 30/30 PASS**. 1 anchor라도 1 요소 FAIL이면 reaction sprint REROLL. **R-02 어머니 ★2 + R-05 아버지 ★2 anchor seed FAIL 시 REROLL 우선** (R-02 anchor seed 시 R-01/R-03 어머니 ★1/★3 reference 시드 / R-05 anchor seed 시 R-04/R-06 아버지 ★1/★3 reference 시드).

#### 부분 통과 정책

| 상황 | 정책 |
|------|------|
| 6 anchors × 5 요소 = 30/30 PASS | 완전 통과, 즉시 reaction sprint LOCK → §0 anchor 표 R-01~R-06 status 갱신 + Scene 3 식탁 reaction 구현 진입 (음식/cut/ingredient/reaction 모두 사용 가능) |
| 5 anchors LOCK + 1 anchor 1-2 요소 FAIL | **CONDITIONAL** — FAIL anchor 단일 reroll (`--only R-XX --version v2`) |
| 4 anchors LOCK + 2 anchors 1-2 요소 FAIL | **CONDITIONAL** — 2 FAIL anchors batch reroll (`--only R-XX,R-YY --version v2`) |
| 3 anchors 이하 LOCK 또는 1 anchor 3+ 요소 FAIL | **FAIL** — pm 에스컬레이션 / prompt 재설계 / 사용자 ChatGPT 웹 UI reference image upload chain-of-references 워크플로 권장 |
| **R-02 또는 R-05 anchor seed FAIL** | **REROLL** — seed 재생성 우선 (anchor seed가 다른 ★1/★3 variant generation의 family IP consistency 시드. seed FAIL 시 ★1/★3도 무너짐) |
| **G_reaction #1 family IP 식별 FAIL** | **REROLL** — Week 1 base reference image upload 강력 필수. driver script API call에서 family IP consistency 약하면 사용자 ChatGPT 웹 UI에서 수동 reference upload + chain-of-references 워크플로 실행 |
| **G_reaction #2 expression gradient FAIL** | **REROLL** — "★N expression intensity를 [더 subtle / 더 expressive]로 — ★1 subtle small arc mouth closed / ★2 bigger open arc / ★3 wide open delighted 3 단계 gradient 정확 매칭" follow-up. 3 anchors (어머니 또는 아버지) contact sheet 같이 평가하여 gradient 명확성 검증 |
| **G_reaction #5 sad/sleeping/negative 누수 (CRITICAL)** | **REROLL** — "MILD POSITIVE acceptance / HAPPY UPWARD ARC closed-arc / NOT sad NOT crying NOT sleeping" explicit 강제 follow-up. Week 1 CH-04 sad pattern 재현 risk가 가장 높음 (R-01 어머니 ★1 anchor) |

### 5.9.3 Reaction 6컷 라운드 예산

- **R1 (1차 시도, 6장 batch)**: `py tools/gen_reaction_anchors_m1.py --model gpt-image-1 --quality medium`. 6장 × $0.042 ≈ $0.25, ~2-3분. 사용자 시각 확인 ~10분, art-director 평가 0.5h.
- **R2 (follow-up reroll, FAIL anchor 집중)**: `--only R-XX --version v2`. +10-15분.
- **R3 (사용자 ChatGPT 웹 UI 수동 reference upload 워크플로)**: driver R1/R2의 family IP consistency가 약하면 (G_reaction #1 FAIL) 사용자 ChatGPT 웹 UI에서 수동 chain-of-references 워크플로 실행. (a) Week 1 CH-02_mother.png upload + R-02 ★2 prompt → 어머니 anchor seed lock / (b) seed image를 reference로 R-01 ★1 / R-03 ★3 generation / (c) 새 세션 + CH-03_father.png upload + R-05 ★2 prompt → 아버지 anchor seed lock / (d) seed image + (R-06만) CH-05_father_star3.png 추가 reference로 R-04 ★1 / R-06 ★3 generation.
- **R4 (재시도)**: R3 후에도 FAIL 2+ anchors이면 → pm 에스컬레이션. prompt 재설계 또는 expression gradient 명세 강화 또는 Week 1 base 4장 시각 의도 재확인.

### 5.9.4 Reaction 6컷 ChatGPT 약점 risk top 5

| Rank | reaction anchor | 누수 risk | default % | 회피 전략 |
|------|----------------|----------|-----------|----------|
| 1 | **R-01 mother_star1 (★1 mild satisfaction)** | sad teardrop / crying / disappointed expression 누수 (Week 1 CH-04 sad pattern + ChatGPT의 "low rating reaction" → sad 자동 추론) | ~60% | "MILD POSITIVE acceptance, subtle warm smile + 정상 OPEN dot eyes, NOT sad, NOT crying, NOT disappointed" explicit 강제 + ★1 = "30%+ acceptable but not exciting" gradient 정의 명시 + Week 1 CH-04_mother_star1 sad teardrop pattern 명시적 회피 negative |
| 2 | **R-06 father_star3 (★3 very happy + double thumb-up + sparkle)** | sparkle detail 폭주 (anime sparkle effect 누수) + double thumb-up이 single thumb-up로 단순화 | ~40% | "small simple flat geometric sparkle (single color, NOT detailed anime sparkle)" + "BOTH mitten hands enthusiastic thumb-up gesture (Week 1 CH-05_father_star3 settle pose, one thumb-up + one fist raised)" 명시 + Week 1 CH-05_father_star3.png reference upload 권장 |
| 3 | **R-03 mother_star3 (★3 very happy + heart accent)** | heart icon detail 폭주 (anime detailed sparkle heart 누수) + closed-arc eyes가 sad closed eyes로 잘못 추론 | ~35% | "HAPPY UPWARD ARC closed-arc (smiling eyes, NOT sad/sleeping)" + "small simple flat geometric heart icons (single color red, NOT detailed)" 명시 + closed-arc happy 시각 명세 강화 (upward crescent smile-strokes) |
| 4 | **R-02 / R-05 ★2 in-between** | ★2의 in-between expression이 ★1 또는 ★3로 collapse (gradient flat화) — soft eye crescent arcs가 정상 dot로 회귀하거나 fully closed-arc로 진화 | ~30% | "GENTLE UPWARD CRESCENT ARCS (★1 dot ↔ ★3 fully closed-arc 사이 in-between, slight upward curve at corners)" + "BIGGER than ★1 SMALLER than ★3" 양방향 비교 명시 + 6장 contact sheet 같이 평가하여 in-between 명확화 |
| 5 | **R-04 father_star1 (★1 slim reserved)** | thumb-up 누수 (Week 1 CH-03_father base의 thumb-up이 ★1로 carry over, 본 prompt는 ★1에서 thumb-up 제거 의도) | ~25% | "thumb-up 없음 (★1은 reserved, thumb-up은 ★2 이상에서만 등장)" explicit 명시 + ★1 hand gesture = "한 mitten 손 near chin in thoughtful evaluation gesture (NOT thumb-up)" 명시 |

> 부차 risk (P2): 모든 reaction에서 full body 누수 (~25%), bg 캐릭터 5장 soft mint #9BE0D2 누수 (~20%), multiple characters 결합 누수 (어머니 + 아버지 한 image, ~15%), 한복 jeogori 자수/패턴 폭주 (~15%), anime girl big sparkly eyes 누수 (~10%).

### 5.9.5 anchor seed 채택 + reference image upload 워크플로

> sref URL 부재 대체 → reference image upload + subject anchor 문장의 3축 운영. driver script는 ChatGPT API direct call로 fresh generation만 가능 (reference upload 자동화 X). R1 batch 결과의 family IP consistency가 약하면 (G_reaction #1 FAIL) 사용자 ChatGPT 웹 UI에서 수동 reference upload + chain-of-references 워크플로 실행 권장.

1. **R-02 어머니 ★2 = anchor seed** (CH-02_mother base default와 가장 가까움 — subtle warm smile mouth closed가 ★1-★2 경계이므로 R-02 ★2 prompt가 base와 가장 close fit). seed lock 후 R-01 어머니 ★1 + R-03 어머니 ★3 variant generation의 reference image upload 시드.
2. **R-05 아버지 ★2 = anchor seed** (CH-03_father base default와 가장 가까움 — thumb-up + slim smile이 ★2 lower end이므로 R-05 ★2 prompt가 base와 가장 close fit). seed lock 후 R-04 아버지 ★1 + R-06 아버지 ★3 variant generation의 reference image upload 시드.
3. **R-06 아버지 ★3 추가 reference**: Week 1 CH-05_father_star3.png가 settle 형태에 가장 가까우므로 R-06 generation 시 추가 reference upload 권장 (★3 expression intensity reference — closed-arc happy + double thumb-up + sparkle pattern). 단 shirt teal-green CH-03 base 정확 매칭 + bust-up framing은 R-06 prompt에서 명시.
4. **세션 분기 권장**: R-01/R-02/R-03 어머니 3컷 = 한 세션 + R-04/R-05/R-06 아버지 3컷 = 별도 세션. 같은 세션 안에서 어머니/아버지 캐릭터 cross-contamination 회피 (ChatGPT는 세션 안 context 일관성 유지하므로 character A → B switch 시 features 누수 risk).

---

## 5.10 M1 후반 Ingredient Cut 12장 평가 가이드 (v1.19 신설, ADR-005 Stage 2B/2C "after"-cut pair)

### 5.10.1 배경 — M1 후반 art sprint 4번째 진입 (사용자 verbatim trigger)

> 2026-05-30 M1 후반 art sprint 2번째 (ingredient whole 12장) + 3번째 (reaction 6컷) 진행 중 + **4번째 sprint 진입**. 사용자 verbatim **"손질하고 나서의 ingredient 이미지가 있어야 할 거 같고"** trigger. ingredient whole 12장 (§5.8 ING-01~12)은 "before" state, cut anchor 7장 (§5.7 CUT-00~06)은 generic cut style 시연. 그 사이 누락된 asset = 각 음식의 hero ingredient를 그 음식 특유 cut 결과로 specific 시각화. 음식별 cut된 결과는 generic CUT-01~06 anchor와 미세 차이 있음 — 예: F-02 애호박은 잔치국수용 thin disc 5-8개 (generic CUT-04 통썰기 anchor의 김밥 cylinder cross-section과 다름) / F-04 어묵은 떡볶이용 medium 6-8cm oval 5-7개 (generic CUT-03 어슷썰기 anchor의 어묵+대파 mixed cluster와 다름) / F-07 daepa는 pajeon용 large 5-7cm oval 5-7개 (generic CUT-03과 mixed) — 음식 시그니처 강화 가치 있음.
>
> **옵션 C 채택 (12장 specific 모두 생성)**: F-06 cheese는 ING-06과 동일 image이나 카탈로그 완전성 위해 별도 anchor (game-designer 후속 확정 시 재사용 결정되면 archive). F-11 carrot은 F-08과 slight visual variation으로 별도 생성 (game-designer foods CSV `prep_*` 후속 확정 시 F-08 재사용 결정되면 archive).
>
> prompts-library v1.19에서 §5.10 신설 (음식 × hero ingredient cut 매핑 표 + STYLE_SUFFIX_INGREDIENT_CUT inline note + 12장 prompt body single source = driver script INGREDIENT_CUTS list) + §0 anchor 표 ICUT-01~12 row 12장 추가 + 새 driver `tools/gen_ingredient_cut_anchors_m1.py` 신설 완료.

### 5.10.2 G_ingredient_cut (ingredient cut 12장 게이트, v1.19 신설)

> **정의**: ingredient cut anchor 12장 각각이 (1) hero ingredient cut 결과 시각 식별 명확 + (2) CUT/PREPARED RESULT state 명확 + (3) Cool Sage `#C8D5C0` bg + 도마 + 칼 LEFT side static 통일 (cross-asset 31+ anchor 일관성) + (4) modern saturated 톤 + 단순화 + (5) cross-cultural 누수 0건 + 음식 시그니처 시각 분리 (특히 F-04 vs F-07 daepa, F-09 vs F-12 갈비) 5 요소를 모두 충족. G_new (modernity) + G3 (saturated) + G5 (modern clean)과 직교 critical 게이트.

#### G_ingredient_cut 5 요소 PASS 기준 (12/12 anchors × 5 요소 = 60/60 PASS 시 ingredient cut sprint LOCK)

| # | 요소 | 사용자 의도 시각 명세 | PASS 판정 기준 | FAIL 사례 (즉시 reroll) |
|---|------|------------------------------|----------------|----------------------|
| 1 | **CRITICAL — hero ingredient cut 결과 시각 식별 명확** | 각 ingredient cut anchor의 시그니처 cut 결과가 외부인 0.5초 안에 식별 (ingredient + cut style + 음식 context). ICUT-01 → 송송 small thin green discs 20-30개 + white center ring / ICUT-02 → 통썰기 medium round zucchini discs 5-8개 green-rim + pale flesh / ICUT-03 → 채썰기 long yellow matchstick 15-20개 8-10cm kimbap-length / ICUT-04 → 어슷썰기 medium golden-brown oval 5-7개 6-8cm / ICUT-05 → 다지기 fine red kimchi bits scattered / ICUT-06 → cheese whole (no cut) / ICUT-07 → 어슷썰기 large DOMINANT GREEN daepa oval 5-7개 5-7cm × 1.5-2.5cm hollow center ring / ICUT-08 → 채썰기 short orange matchstick 15-20개 5-7cm bibimbap-length / ICUT-09 → marinade brown glaze coated thin beef 5-7 slices + small marinade pool / ICUT-10 → broken cloud-like white tofu curds organic fragments / ICUT-11 → 채썰기 medium orange matchstick 15-20개 6-8cm slight diagonal pile / ICUT-12 → 다지기 fine yellowish-white garlic granules 1-3mm. | 각 cut 결과의 시그니처 모양 + 색 + 크기가 명확 visible. 외부인 0.5초 안에 ingredient + cut style + 음식 context 답. cross-cut 디스트랙터 페어 (송송 vs 통썰기 vs 어슷썰기 다른 oval 크기 / 채썰기 다른 length: kimbap 8-10cm vs bibimbap 5-7cm vs japchae 6-8cm) 정확 구분. | 다른 cut style로 추론 (송송 → 통썰기 large round / 어슷썰기 → 통썰기 round disc) / 길이 어긋남 (bibimbap 5-7cm julienne이 kimbap 8-10cm으로 길어짐) / 색 누수 (zucchini → cucumber darker / daepa → 어묵 golden-brown) / cluster size 어긋남 (15-20 strips가 5개로 sparse / 5-7 ovals가 12개로 과다) |
| 2 | **CRITICAL — CUT/PREPARED RESULT state 명확** | 모든 12장이 cut/prep된 결과 cluster만 + WHOLE intact ingredient 0건 (whole은 ING-XX whole anchor 영역). cutting action mid-motion 0건 (칼이 LEFT static placement). ICUT-06 cheese / ICUT-09 marinated beef / ICUT-10 broken tofu도 prep result state (whole 상태가 아님 — cheese는 ICUT-06이 ING-06과 동일 image라 예외이나 카탈로그 완전성 위함). | 도마 위에 cut/prep된 결과 cluster + WHOLE intact ingredient 0건 (optional 1-2cm partial 끝 잘림 remnant는 OK). 칼은 LEFT side static, NOT chopping mid-motion. | WHOLE intact ingredient 누수 (cut 결과 cluster + 옆에 WHOLE intact carrot/zucchini/danmuji 1개 함께 그려짐 — 이건 ING-XX whole anchor 영역) / cutting action mid-motion (칼이 raised mid-chop) / cluster가 sparse 2-3 pieces만 (생성된 결과가 너무 적음, 의도 cluster size와 어긋남) |
| 3 | **CRITICAL — Cool Sage `#C8D5C0` bg + 도마 + 칼 LEFT side static (cross-asset 31+ anchor 일관성)** | 모든 12장 ingredient cut anchor가 §5.7 cut anchor 7장 + §5.8 ingredient whole 12장과 같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 slim outline 2-3px. **31장 cross-asset cluster** 합류 인식. CUT-00 anchor seed reference upload + 페어 ING-XX whole image 추가 reference upload 권장. 도마 = warm brown wood `#A67049` + slim grain accent 1-2개 + rounded corners + ~16:9 가로비례. 칼 = warm brown wood handle + silver-gray steel blade `#C8C8C8` + slim simple geometric + LEFT side, blade flat, handle lower-left corner. | 12장 + 페어 ING-XX whole 12장 + cut anchor 7장 = 31장 contact sheet 같이 보았을 때 모두 같은 도마 + 같은 칼 + 같은 Cool Sage bg + 같은 outline 인식. CUT-00 anchor seed reference upload로 ICUT-01~12 일관성 lock 달성. | 도마 색 변동 / 칼 silhouette 변동 (placement 다름) / bg 다름 (cream-white / 베이지 누수) / outline 두께 mixed / cross-asset 31장 cluster 불일관 |
| 4 | **modern saturated 톤 + 단순화 (베이지/scrapbook/heavy texture 0건)** | 채도 80-90% / warm food + cool background balance / Royal Match aesthetic / 1-2 subtle shading lines + ONE specular highlight per element / heavy texture 0건 / 베이지·cream·scrapbook·storybook·Cookie Run 2021 톤 0건. | 채도 80-90% 명확. modern flat clean 톤. heavy texture 0건. 베이지 bg 0건. ingredient cut 결과 표면 subtle shading + 1 highlight만. | 채도 70% 이하 muted / 채도 100% neon / 베이지 bg / Cookie Run frosting / scrapbook/storybook / heavy wood grain / heavy noise/grain on cut pieces / multi-layer complex shading |
| 5 | **CRITICAL — cross-cultural 누수 0건 + 음식 시그니처 시각 분리 (F-04 vs F-07 daepa, F-09 vs F-12 갈비)** | (a) **ingredient cut별 특화 negative** (top 5 risk): ICUT-02 cucumber/Italian zucchini 누수 0건 (cucumber darker + bumpy + larger seed cavity 회피, Korean zucchini bright medium green + smooth) / ICUT-04 Japanese naruto pink spiral / chikuwa hollow tube 누수 0건 / **ICUT-07 daepa F-04 어묵 oval 색 누수 0건 CRITICAL** (golden-brown 누수 → DOMINANT BRIGHT GREEN 강제) / **ICUT-09 marinade beef F-12 갈비 bone visible 누수 0건 CRITICAL + raw red 또는 grilled char marks 누수 0건** (brown glaze coating from MARINADE NOT grilling) / ICUT-10 firm cube 누수 0건 (organic irregular cloud-like fragments 강제) / ICUT-12 garlic slice 5mm flat disc 누수 0건 (mince 1-3mm granule 강제). (b) **cross-anchor 공통 negative**: Japanese kitchen knife 0건 / Chinese cleaver 0건 / Western chef knife 0건 / mortar 절구 0건 / 인간 hand 0건. | ingredient cut별 특화 누수 0건 + cross-anchor 공통 negative 0건. 한식 도마 + 한식 칼 + 한식 ingredient cut 결과 인식. F-04 vs F-07 색 분리 (golden-brown vs dominant green) + F-09 vs F-12 분리 (brown marinade NOT cooked grill char + NO bone). | ICUT-02 cucumber 누수 (darker green + bumpy) / ICUT-04 naruto pink spiral / ICUT-07 daepa가 F-04 어묵처럼 golden-brown 추론 (CRITICAL) / ICUT-09 raw red 또는 cooked char marks 누수 / ICUT-09 F-12 갈비 bone visible 누수 CRITICAL / ICUT-10 firm cube 누수 / ICUT-12 garlic slice 누수 / Japanese kitchen knife silhouette / 절구 누수 |

#### G_ingredient_cut LOCK 조건 (v1.19)

> **LOCK = 12/12 anchors × 5 요소 = 60/60 PASS**. 1 anchor라도 1 요소 FAIL이면 ingredient cut sprint REROLL. **CUT-00 anchor seed (§5.7에서 LOCK) + 페어 ING-XX whole anchor (§5.8에서 LOCK)이 ingredient cut 12장의 cross-asset 일관성 시드** — CUT-00 + 페어 ING-XX whole image reference upload 의무 권장.
>
> **ICUT-06 cheese 예외**: F-06 cheese는 cut prep mechanic 없음 (whole 그대로 corn dog 안 insertion). ICUT-06 anchor 결과가 ING-06과 시각 동일하면 PASS. game-designer 후속 확정 시 ICUT-06 archive 가능 (ING-06 재사용).
>
> **ICUT-11 archive 가능성**: game-designer foods CSV `prep_*` 후속 확정 시 F-11 잡채가 F-08 비빔밥 carrot cut anchor를 재사용하는 것으로 결정되면 ICUT-11 archive (assets-raw 파일은 보존, §0 anchor 표 status `재사용 결정 archived`로 갱신, 본 게이트는 11/12 anchors × 5 = 55/55 PASS로 조정).

#### 부분 통과 정책

| 상황 | 정책 |
|------|------|
| 12 anchors × 5 요소 = 60/60 PASS | 완전 통과, 즉시 ingredient cut sprint LOCK → §0 anchor 표 ICUT-01~12 status 갱신 + ADR-005 Stage 2B/2C 구현 진입 (cut 7 + whole 12 + cut 12 = 31장 + reaction 6 = 37장 모두 사용 가능) |
| 11 anchors LOCK + 1 anchor 1-2 요소 FAIL | **CONDITIONAL** — FAIL anchor 단일 reroll (`--only F-XX --version v2`) |
| 9-10 anchors LOCK + 2-3 anchors 1-2 요소 FAIL | **CONDITIONAL** — FAIL anchors batch reroll (`--only F-XX,F-YY --version v2`) |
| 8 anchors 이하 LOCK 또는 1 anchor 3+ 요소 FAIL | **FAIL** — pm 에스컬레이션 / prompt 재설계 (ingredient cut 결과 명세 강화) / game-designer 매핑 재확인 |
| **G_icut #1 hero cut 식별 (CRITICAL) FAIL** | **REROLL** — ingredient cut 결과 명세 강화 (e.g., ICUT-02 애호박 → "round zucchini disc BRIGHT MEDIUM GREEN outer rim #5FA060 + PALE GREEN-WHITE inner flesh #D8E8B8 + 3-5 tiny seed dots minimal" 더 강조). 같은 음식 다른 cut style로 swap도 검토 (game-designer 확정 후) |
| **G_icut #2 CUT RESULT state (CRITICAL) FAIL** | **REROLL** — "cut/prepared result cluster, NO whole intact ingredient on the board (whole is ING-XX anchor)" explicit 강조 |
| **G_icut #3 cross-asset 일관성 FAIL** | **CONDITIONAL** — CUT-00 + 페어 ING-XX whole anchor reference upload 재시도. 도마/칼 silhouette description 강화 |
| **G_icut #5 F-04 vs F-07 색 누수 (CRITICAL)** | **REROLL** — ICUT-07 daepa "DOMINANT BRIGHT GREEN daepa oval, NOT F-04 fish cake golden-brown oval, this is hollow scallion cross-section" explicit 강제 |
| **G_icut #5 F-09 vs F-12 (CRITICAL)** | **REROLL** — ICUT-09 beef "NO BONE VISIBLE (F-12 갈비 차별화), NO grilled char marks, brown color from MARINADE COATING NOT from grilling" explicit 강제 |

### 5.10.3 Ingredient cut 12장 라운드 예산

- **R1 (1차 시도, 12장 batch)**: `py tools/gen_ingredient_cut_anchors_m1.py --model gpt-image-1 --quality medium`. 12장 × $0.042 ≈ $0.50, ~4-5분. 사용자 시각 확인 ~15분, art-director 평가 0.5h.
- **R1 test (ICUT-01 권장, ~30초 / ~$0.05)**: `py tools/gen_ingredient_cut_anchors_m1.py --only F-01`. 1장 test 후 batch 결정.
- **R2 (follow-up reroll, FAIL anchor 집중)**: `--only F-XX --version v2`. +10-15분.
- **R3 (재시도)**: R2 후에도 FAIL 3+ anchors이면 → pm 에스컬레이션. ingredient cut 결과 명세 재설계 또는 hero ingredient swap 검토 (game-designer foods CSV `prep_*` 확정 결과 인용).

### 5.10.4 ingredient cut 12장 ChatGPT 약점 risk top 5 (prompts-library v1.19 §5.10.15 sync)

| Rank | Ingredient cut | 누수 risk | default % | 회피 전략 |
|------|---------------|----------|-----------|----------|
| 1 | ICUT-02 애호박 통썰기 | cucumber 누수 (darker green + bumpy skin + larger seed cavity) | ~50% | "Korean zucchini bright medium green #5FA060 + smooth skin + minimal 3-5 tiny seed dots center" 강제 + "NOT cucumber, NOT Italian zucchini darker forest green" negative |
| 2 | ICUT-04 어묵 어슷썰기 | Japanese naruto pink spiral cross-section 누수 | ~50% | "plain Korean 어묵 light golden-brown #C8923C elongated oval, NO pink spiral, NO hollow tube chikuwa" 강제 |
| 3 | **ICUT-07 daepa 어슷썰기 (CRITICAL)** | F-04 어묵 oval로 색 누수 (golden-brown 누수) | ~40% | **DOMINANT BRIGHT GREEN #52C160 강제** + F-04 분리 explicit "NOT F-04 fish cake golden-brown oval, this is daepa bright green hollow scallion cross-section, dominant green NOT golden-brown" |
| 4 | **ICUT-09 marinade beef (CRITICAL)** | raw red 또는 cooked char marks 누수 + F-12 갈비 bone visible 누수 | ~40% (cooked) + ~40% (F-12 bone) | "GLOSSY DARK BROWN soy-pear-garlic marinade COATING (brown comes from MARINADE NOT grilling), NO char marks, NO grilling, NO bone visible (F-12 차별화 CRITICAL), NO bone cross-section discs along strips" 강제 |
| 5 | ICUT-10 broken tofu | firm cube 누수 | ~40% | "SOFT broken into IRREGULAR CLOUD-LIKE FLUFFY WHITE FRAGMENTS organic uneven shapes 2-4cm, NOT firm sharp cube, NOT smooth puree, NOT single block, multiple irregular fragments clumped" 강제 |

> 부차 risk (P2): ICUT-01 spring onion (송송 → 통썰기 large round 누수 ~25%) / ICUT-03 단무지 (kimbap-length 8-10cm → bibimbap-length 5-7cm 누수 ~25%) / ICUT-05 김치 (large chunk 2-3cm 누수 ~20%) / ICUT-11 carrot (F-08과 완전 동일하게 추론, slight variation 차별 안 됨 ~30%) / ICUT-12 garlic (slice 5mm 누수, mince는 1-3mm 강제 ~20%) / ICUT-06 cheese (cut version (sliced rounds) 누수 — whole 그대로 강제 ~15%).

### 5.10.5 game-designer 후속 confirm 사안 (ingredient cut 12장)

> 본 v1.19 ingredient cut 12장 매핑은 §5.8 ingredient whole 12장 매핑 직접 follow-through. game-designer foods CSV `prep_*` 컬럼 lock 결과:

| ICUT 매핑 | 검증 사안 | 영향 |
|----------|----------|------|
| ICUT-06 F-06 cheese whole (no cut) | F-06 prep mechanic이 cheese 외 sausage 자체 cut 있는가? | 있으면 ICUT-06이 sausage cut으로 swap, cheese는 ING-06 그대로 재사용 |
| ICUT-09 F-09 marinade prep (no cut) | F-09 prep mechanic이 marinade 외 양파/대파 cut 있는가? | 있으면 ICUT-09는 양파/대파 cut로 swap, beef marinade는 별도 |
| ICUT-10 F-10 broken curds (no cut) | F-10 prep mechanic이 broken curds 외 멸치/김치 cut 있는가? | 있으면 ICUT-10는 멸치/김치 cut로 swap, soft tofu는 별도 |
| ICUT-11 F-11 carrot (F-08 variation) | F-11이 F-08 carrot cut anchor 재사용 결정 시 ICUT-11 archive | 재사용 시 assets-raw 보존 + §0 status `재사용 결정 archived` |

> game-designer 확정 후 art-director는 (a) 본 §5.10 매핑 표 갱신 / (b) prompts-library §5.10 ingredient cut prompt 일부 reroll / (c) driver script INGREDIENT_CUTS list sync 작업 진행.

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

### 6.13 M1 후반 art sprint 시작 — Cut anchor 7장 trigger (v1.14 신설, 2026-05-29)

> 2026-05-29 M1 anchor 22/22 LOCK 완료 (음식 12 + 환경 5 + 캐릭터 5, commit dfb141e) 후 M1 후반 art sprint 진입. **ADR-005 Stage 2A 재료 준비 = rhythm tap + Knife indicator** prerequisite로 칼/도마 base + cut style 6종 anchor 7장이 필요. cut anchor sprint trigger.

| 라운드 | 날짜 | trigger 사유 | 영향 anchor | LOCK 유지 anchor | art-director 메모 | pm 승인 |
|-------|------|------------|------------|----------------|------------------|--------|
| M1 후반 cut anchor 7장 trigger | 2026-05-29 | ADR-005 Stage 2A rhythm tap prerequisite (재료 준비 = rhythm tap + Knife indicator. 칼이 자동 위아래 움직임 AnimationPlayer, 도마 닿기 직전 = perfect tap). 칼/도마 base + cut style 6종 anchor 필요 | CUT-00 cutting_board base + CUT-01~06 cut style 6종 (7장 신규) | M1 anchor 22장 (음식 12 + 환경 5 v4 image edit + 캐릭터 5) LOCK 무영향 유지 | prompts-library v1.14로 §2.5 STYLE_SUFFIX_CUT 신설 + §5.5 placeholder → full prompts 확장 (cutting_board base + cut_style_mince/julienne/diagonal/whole/sliced_rounds/cube 7장 full prompt) + §0 anchor 표 cut anchor 7장 row 추가. **새 driver `tools/gen_cut_anchors_m1.py` 신설** — `tools/gen_food_anchors_m1.py` template 기반 + CUTS list 7개 inline + STYLE_SUFFIX_CUT inline + CLI args (`--only` `--version` `--model` `--quality` `--out-dir`) + gpt-image-1 medium 1024×1024 default. **§5.7 M1 후반 Cut Anchor 7장 평가 가이드 신설** — §5.7.1 배경 (M1 anchor 22/22 LOCK 완료 + ADR-005 Stage 2A trigger + cut style 6종 시그니처 재료 + BPM 매핑) / §5.7.2 G_cut 5 요소 점검표 신설 (cut style 시각 식별 명확 / hero ingredient 매칭 / Cool Sage bg + 도마/칼 통일 / modern saturated 톤 / cutting RESULT state + cross-cultural negative). **LOCK 조건 = 7/7 anchors × 5 요소 = 35/35 PASS**. CUT-00 anchor seed FAIL 시 전체 FAIL (cross-cut 일관성 무너짐). §5.7.3 cut anchor 7장 라운드 예산 (R1 7장 batch ~3-4분 $0.29 → R2 follow-up FAIL anchor 집중 `--only CUT-XX --version v2`). §5.7.4 ChatGPT 약점 risk top 3 (CUT-04 통썰기 Japanese maki sushi ~50% / CUT-06 깍둑썰기 Chinese mapo tofu ~40% / CUT-00~06 Japanese kitchen knife santoku/deba ~30%). **§3.4 cut anchor 평가 표 신설** (CUT-00 ~ CUT-06 7 row × G1/G3/G4/G5/G6/G7/G_new + G_cut 컬럼). main thread 실행 명령: `py tools/gen_cut_anchors_m1.py --model gpt-image-1 --quality medium` (7장 × $0.042 ≈ $0.29, ~3-4분, 출력 경로 `assets-raw/cut_anchors_m1/<name>_v1.png`). | pending |

#### cut anchor 7장 시그니처 매핑 + BPM 명세

| Cut style | 한식 명 | 시그니처 재료 | 음식 매핑 | BPM (ADR-005 Stage 2A) | 비고 |
|----------|--------|---------------|----------|------------------------|------|
| CUT-00 | (base) | none (knife + cutting board only) | 모든 Scene 2 (Kitchen) | N/A (정적 baseline) | anchor seed |
| CUT-01 mince | 다지기 | 마늘 (yellowish-white minced bits 1-3mm irregular) | F-12 갈비 양념 / F-09 김치찌개 | **140 (가장 빠름)** | fine granular cut |
| CUT-02 julienne | 채썰기 | 당근 (orange #FF9933 thin matchstick 4-6cm × 2-3mm × 2-3mm) | F-08 비빔밥 / F-11 잡채 | 110 | thin elongated strip |
| CUT-03 diagonal | 어슷썰기 | 어묵 (light golden-brown #C8923C 5-7cm long oval) + 대파 (white-to-green 3-4cm long oval) | F-04 떡볶이 / 모든 국물 | 100 | elongated oval (NOT round circle) |
| CUT-04 whole | 통썰기 | 김밥 cylinder 단면 (perfect round disc 3cm × 1.5-2cm + 5색 cross-section) | F-03 김밥 | **70 (가장 느림)** | most stable round disc — Japanese maki sushi 누수 risk ~50% |
| CUT-05 sliced_rounds | 송송썰기 | 대파 (bright green small thin round 1-1.5cm × 1-3mm + scallion ring pattern) | F-12 갈비 hero garnish / 모든 가니쉬 | 130 | distinctly thinner+smaller than 통썰기 |
| CUT-06 cube | 깍둑썰기 | 두부 (white #FAFAFA equal-sided cube 2-2.5cm + 3D volume hint) | F-09 김치찌개 / F-10 순두부 contrast | 90 | most volumetric — Chinese mapo tofu 누수 risk ~40% |

#### M1 anchor 22장 LOCK 무영향 확인 (캐릭터 5 + 음식 12 + 환경 5)

> cut anchor 7장 sprint trigger는 M1 anchor 22장 LOCK status에 무영향. cut anchor는 신규 asset class 추가 (cut anchor 디렉터리 `assets-raw/cut_anchors_m1/` 신설). 음식/환경/캐릭터 anchor 재실행 없음.

### 6.14 M1 후반 art sprint 2번째 — Ingredient whole 12장 trigger (v1.15 신설, 2026-05-30)

> 2026-05-30 M1 후반 art sprint 1번째 (cut anchor 7장) LOCK 완료 후 2번째 sprint 진입. **ADR-005 Stage 2A 재료 준비 = rhythm tap + Knife indicator** 미니게임은 음식별 hero ingredient를 적절한 cut style로 자르는 형태 → 음식 12 × hero ingredient whole(자르기 전) state asset이 필요. cut된 결과 ("after") = §5.5 cut anchor 7장 재사용 (한 cut style이 여러 음식에 매핑되므로 12 ≠ 7). 본 sprint = **whole 12장만 추가 생성** (ING-01~12).

| 라운드 | 날짜 | trigger 사유 | 영향 anchor | LOCK 유지 anchor | art-director 메모 | pm 승인 |
|-------|------|------------|------------|----------------|------------------|--------|
| M1 후반 ingredient whole 12장 trigger | 2026-05-30 | ADR-005 Stage 2A 재료 준비 미니게임 "before"-cut pair 필요. 음식 12 × hero ingredient 매핑 + whole state asset (cut된 "after"는 §5.5 cut anchor 7장 재사용) | ING-01~12 (12장 신규, F-01~F-12 각 음식 hero ingredient whole state) | M1 anchor 22장 + cut anchor 7장 LOCK 무영향 유지 (cut 7 + ingredient whole 12 = 19장 cross-asset 일관성 작동) | prompts-library v1.15로 §5.5.0 음식↔cut 매핑 표 + §5.6 ingredient whole 12장 prompt set + §2.5 STYLE_SUFFIX_INGREDIENT note + §0 anchor 표 ING-01~12 row 추가. **새 driver `tools/gen_ingredient_anchors_m1.py` 신설** — `tools/gen_cut_anchors_m1.py` template 기반 + INGREDIENTS list 12개 inline (id=food_id / name=ingredient_slug / food=food_name_en / cut_style=cut_style_id / body) + STYLE_SUFFIX_INGREDIENT inline (cut suffix 재활용 + INGREDIENT PLACEMENT 절 추가 + cut pieces scattered 회피) + CLI args (cut anchor와 동일 패턴) + gpt-image-1 medium 1024×1024 default. **§5.8 M1 후반 Ingredient Whole 12장 평가 가이드 신설** — §5.8.1 배경 (M1 후반 1번째 cut anchor 7장 LOCK 후 2번째 sprint 진입 + ADR-005 Stage 2A "before"-cut pair + ingredient whole 12장 매핑 표) / §5.8.2 G_ingredient_whole 5 요소 점검표 신설 (hero ingredient 시각 식별 명확 / WHOLE/UNCUT state 명확 / Cool Sage bg + 도마 + 칼 LEFT side static 통일 / modern saturated + 단순화 / cross-cultural 누수 0건). **LOCK 조건 = 12/12 anchors × 5 요소 = 60/60 PASS** (ING-11 archive 가능성 시 11/12 × 5 = 55/55). 부분 통과 정책 (11 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only F-XX --version v2` reroll / 9-10 LOCK = CONDITIONAL batch reroll / 8 이하 = FAIL / G_ing #1 hero 식별 FAIL = 명세 강화 또는 hero swap / G_ing #2 WHOLE state FAIL = ready-to-cut state 명시 강화 / G_ing #3 cross-asset FAIL = CUT-00 reference upload 재시도). §5.8.3 ingredient whole 12장 라운드 예산 (R1 12장 batch `py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium` 12장 × $0.042 ≈ $0.50, ~4-5분, R2 follow-up FAIL anchor 집중). §5.8.4 ChatGPT 약점 risk top 5 (ING-03 단무지 banana/daikon ~50% / ING-04 어묵 naruto/chikuwa ~50% / ING-07 daepa F-01 spring onion 변종 ~40% / ING-06 모짜렐라 cheddar/두부 ~40% / ING-12 마늘 whole bulb/양파 ~35%). §5.8.5 **game-designer 후속 confirm 사안** (음식 12 × hero ingredient × cut style 매핑 검증 — foods CSV `prep_*` 컬럼 lock 후 일부 reroll 가능). **§3.5 ingredient whole 평가 표 신설** (ING-01 ~ ING-12 12 row × G1/G3/G4/G5/G6/G7/G_new + G_ingredient_whole 컬럼). main thread 실행 명령: `py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium` (12장 × $0.042 ≈ $0.50, ~4-5분, 출력 경로 `assets-raw/ingredient_anchors_m1/<food_id>_<ingredient_name>_v1.png`). | pending |

#### ingredient whole 12장 hero ingredient + pair cut style 매핑 (임시; game-designer 후속 검증)

| ID | food | hero ingredient | pair cut style | game-designer 검증 사안 |
|----|------|----------------|---------------|----------------------|
| ING-01 | F-01 Ramyeon | 대파 spring onion whole | CUT-05 송송 | 계란/김 추가 hero 후보? |
| ING-02 | F-02 Hotteok | 견과류 peanut whole | CUT-01 다지기 | 흑설탕 filling도 prep mechanic? |
| ING-03 | F-03 Kimbap | 단무지 pickled radish whole | CUT-02 채썰기 | 단무지 외 5색 ingredient 중 어떤 게 hero? |
| ING-04 | F-04 Tteokbokki | 어묵 fish cake sheet whole | CUT-03 어슷썰기 | 떡 자체 prep (cylinder 통/송송)는 별도? |
| ING-05 | F-05 Kimchi Fried Rice | 김치 napa cabbage leaf whole | CUT-01 다지기 | 햄/계란도 prep mechanic? |
| ING-06 | F-06 Corn Dog | 모짜렐라 cheese stick whole | **(no cut)** | 소시지 자체 prep? |
| ING-07 | F-07 Haemul Pajeon | 대파 daepa large scallion whole | CUT-03 어슷썰기 | 새우/오징어/조개 중 hero? (대파 dominant이지만 해물도 후보) |
| ING-08 | F-08 Bibimbap | 당근 carrot whole | CUT-02 채썰기 | 6 section 중 시금치/콩나물/표고 후보? |
| ING-09 | F-09 Kimchi Jjigae | 두부 firm tofu block whole | CUT-06 깍둑썰기 | 김치 다지기 추가 mechanic? |
| ING-10 | F-10 Sundubu | 두부 soft tofu tube whole | **(no cut, broken curds)** | 멸치/김치/계란 풀기 별도? |
| ING-11 | F-11 Japchae | 당근 carrot whole (F-08 variation) | CUT-02 채썰기 | F-08 anchor 재사용 결정? (재사용 시 ING-11 archive) |
| ING-12 | F-12 Galbi-gui | 마늘 garlic cloves whole | CUT-01 다지기 | LA갈비 자체 prep (재우기/굽기)이 dominant? |

#### cut style 분포 통계 (음식 12 → cut style 5 + 2 no-cut)

| cut style | 사용 음식 수 | 음식 list | 비고 |
|----------|-----------|----------|------|
| CUT-01 다지기 | 3 | F-02 견과류 / F-05 김치 / F-12 마늘 | 가장 많이 사용 |
| CUT-02 채썰기 | 3 | F-03 단무지 / F-08 당근 / F-11 당근 | 당근 2회 (F-08/F-11 재사용 가능) |
| CUT-03 어슷썰기 | 2 | F-04 어묵 / F-07 대파 daepa | |
| CUT-04 통썰기 | **0** | (none) | **CUT-04 hero ingredient cut prep 매핑 없음 — game-designer 검증 필요** |
| CUT-05 송송썰기 | 1 | F-01 대파 spring onion | |
| CUT-06 깍둑썰기 | 1 | F-09 두부 firm | |
| **no cut** | 2 | F-06 모짜렐라 / F-10 soft tofu | cheese stick whole insertion / soft tofu broken curds |

> CUT-04 통썰기는 hero ingredient cut prep 매핑이 없음 → game-designer 검증 사안: (a) 김밥 자체 cylinder slice를 Stage 2C "plating" 단계 cut으로 분리 매핑하거나 (b) 다른 음식에 통썰기 추가 매핑 (예: F-04 떡볶이 떡 cylinder도 송송/통썰기 가능). CUT-04 anchor 자체는 LOCK 유지 (Stage 2C 또는 다른 mechanic에 활용).

#### cross-asset 일관성 (cut 7 + ingredient whole 12 = 19장)

> ingredient whole 12장의 G_ing #3 cross-asset 일관성 게이트는 §5.5 cut anchor 7장과 같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 outline 두께 인식을 요구. CUT-00 anchor seed가 19장 모두의 cross-asset 시드. 19장 contact sheet 시각 평가가 G_ing #3 PASS의 핵심.

#### M1 anchor 22장 + cut anchor 7장 LOCK 무영향 확인

> ingredient whole 12장 sprint trigger는 M1 anchor 22장 (음식 12 + 환경 5 v4 + 캐릭터 5) + cut anchor 7장 LOCK status에 무영향. ingredient whole는 신규 asset class 추가 (디렉터리 `assets-raw/ingredient_anchors_m1/` 신설). 음식/환경/캐릭터/cut anchor 재실행 없음.

### 6.15 M1 후반 art sprint 3번째 — 양친 reaction 6컷 trigger (v1.16 신설, 2026-05-30, ingredient sprint와 fully parallel)

> 2026-05-30 M1 후반 art sprint 2번째 (ingredient whole 12장) 진행 중 + **art sprint 3번째 (양친 reaction 6컷) 병렬 동시 진입**. 친구 가족 단위 (project_adr003 2026-05-23 lock) 어머니 + 아버지 L11 동시 unlock (0.6s 시차 fade-in) + Scene 3 식탁 reaction context + ADR-005 Total Score gradient (재료 25% × 준비 20% × 방법 20% × 시간 35% → ★1 30%+ / ★2 60%+ / ★3 90%+) + friends-system 호불호 axis (project_adr003 v0.2) trigger로 양친 reaction 6컷 anchor 필요. 각 reaction = single character bust-up portrait (어깨까지, Scene 3 식탁 seated context), Week 1 CH-02/CH-03 base와 동일 family IP + 표정만 ★1/★2/★3 gradient 변화.

| 라운드 | 날짜 | trigger 사유 | 영향 anchor | LOCK 유지 anchor | art-director 메모 | pm 승인 |
|-------|------|------------|------------|----------------|------------------|--------|
| M1 후반 reaction 6컷 trigger | 2026-05-30 | 친구 가족 단위 L11 unlock + Scene 3 식탁 reaction context + ADR-005 Total Score ★1/★2/★3 gradient + friends-system 호불호 axis | R-01~R-06 (6장 신규, 어머니 × ★1/★2/★3 + 아버지 × ★1/★2/★3) | M1 anchor 22장 + cut anchor 7장 + ingredient whole 12장 (병렬 진행 중) LOCK 무영향 유지 | prompts-library v1.16으로 §2.5 STYLE_SUFFIX_REACTION 명시 + §5.7 placeholder → full prompts 확장 (R-01~R-06 6장 full prompt + Week 1 base 시각 확인 결과 표 + ★1/★2/★3 expression gradient 정의 표 + driver script + 실행 명령) + §0 anchor 표 R-01~R-06 row 추가. **새 driver `tools/gen_reaction_anchors_m1.py` 신설** — `tools/gen_cut_anchors_m1.py` template 기반, REACTIONS list 6개 inline (id=R-XX / name=character_starN_slug / character=mother\|father / star=1\|2\|3 / body), STYLE_SUFFIX_REACTION inline append via **`.replace("%s", STYLE_SUFFIX_REACTION, 1)`** (gen_food/gen_ingredient에서 발생했던 `body의 % character ↔ Python %s formatting` ValueError fix 적용 — body에 "30-59 percent" 같은 % 문자 자유 사용 가능), CLI args (cut/ingredient anchor와 동일 패턴) + gpt-image-1 medium 1024×1024 default. **§5.9 M1 후반 양친 Reaction 6컷 평가 가이드 신설** — §5.9.1 배경 (M1 후반 sprint 2번째 (ingredient)와 병렬 3번째 (reaction) 진입 + 친구 가족 단위 + Scene 3 + ADR-005 gradient + Week 1 base 4장 시각 확인 결과 — CH-02_mother base ≈ ★1-★2 경계 / CH-03_father base ≈ ★2 경계 / CH-04_mother_star1 sad teardrop 폐기 / CH-05_father_star3 settle 형태) / §5.9.2 **G_reaction 5 요소 점검표 신설** = (1) **CRITICAL — 캐릭터 family IP 식별 명확** (어머니 Week 1 CH-02 base + 아버지 Week 1 CH-03 base와 동일 family IP — hair/outfit/face features/chibi mascot proportions/outline 두께/saturation 톤 일치, 6장 contact sheet에서 어머니 3장 + 아버지 3장 각각 같은 family IP 인식) / (2) **CRITICAL — ★1/★2/★3 expression gradient 명확** (3 단계 표정 진화 명확 visible — ★1 subtle small arc smile 정상 open dot eyes / ★2 bigger smile open arc + soft upward crescent arc eyes / ★3 big wide open delighted smile + closed-arc happy eyes; 어머니 warm motherly nurturing tone amplification / 아버지 reserved masculine breaking into excitement amplification; 외부인 0.5초 안에 gradient 순서 답 가능) / (3) **anchor consistency (Cool Sage `#C8D5C0` bg + cross-asset cluster)** (6장 모두 Cool Sage solid bg + slim outline 2-3px + 음식 12 + cut 7 + ingredient whole 12 = 37-asset Scene 3 cross-asset cluster 합류 인식, 캐릭터 5장 soft mint `#9BE0D2` 누수 0건) / (4) **chibi mascot proportions + bust-up portrait** (chibi 1:1.7 head-to-body ratio + bust-up 어깨까지만 visible — full body/lower body/legs/feet 누수 0건, multiple characters 결합 누수 0건) / (5) **CRITICAL — sad/sleeping/negative expression 누수 0건 + 한식 family context 유지** (Week 1 CH-04_mother_star1 sad teardrop pattern 누수 0건 / sleeping closed eyes 누수 0건 / crying tears 누수 0건 / Japanese 기모노 / 중국 치파오 / anime girl big sparkly eyes / school uniform / deep dark Cookie Run pink cheek / mortar 절구 누수 0건). **LOCK 조건 = 6/6 anchors × 5 요소 = 30/30 PASS**. **R-02 어머니 ★2 + R-05 아버지 ★2 = anchor seed** (각 캐릭터 base default expression과 가장 가까움 → seed lock 후 ★1/★3 variant generation의 reference image upload 시드). 부분 통과 정책 (5 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only R-XX --version v2` reroll / 4 LOCK = CONDITIONAL batch reroll / 3 이하 LOCK = FAIL → pm 에스컬레이션 / R-02 또는 R-05 anchor seed FAIL = REROLL seed 우선 / G_reaction #1 family IP FAIL = Week 1 base reference image upload 사용자 ChatGPT 웹 UI 수동 워크플로 권장 / G_reaction #2 gradient FAIL = ★1/★2/★3 비교 강제 follow-up / G_reaction #5 sad/sleeping 누수 = "MILD POSITIVE acceptance / HAPPY UPWARD ARC closed-arc / NOT sad NOT crying NOT sleeping" explicit 강제). §5.9.3 reaction 6컷 라운드 예산 (R1 6장 batch `py tools/gen_reaction_anchors_m1.py --model gpt-image-1 --quality medium` 6장 × $0.042 ≈ $0.25, ~2-3분 / R2 follow-up FAIL anchor 집중 / R3 사용자 ChatGPT 웹 UI 수동 reference upload chain-of-references 워크플로). §5.9.4 ChatGPT 약점 risk top 5 (R-01 mother_star1 sad teardrop 누수 ~60% CRITICAL / R-06 father_star3 sparkle detail 폭주 + double thumb-up 단순화 ~40% / R-03 mother_star3 heart icon 폭주 ~35% / R-02/R-05 ★2 in-between collapse ~30% / R-04 father_star1 thumb-up carry over ~25%). §5.9.5 anchor seed 채택 + reference image upload 워크플로 (R-02 어머니 ★2 = anchor seed → R-01/R-03 reference 시드 / R-05 아버지 ★2 = anchor seed → R-04/R-06 reference 시드 / R-06 generation 시 Week 1 CH-05_father_star3.png 추가 reference upload 권장 / 세션 분기 — 어머니 3컷 한 세션 + 아버지 3컷 별도 세션, character cross-contamination 회피). **§3.6 reaction 평가 표 신설** (R-01 ~ R-06 6 row × G1/G3/G4/G5/G6/G7/G_new + G_reaction 컬럼 + Week 1 base reference 컬럼 + risk top 항목 명시 + R-02/R-05 anchor seed 라벨). main thread 실행 명령: `py tools/gen_reaction_anchors_m1.py --model gpt-image-1 --quality medium` (6장 × $0.042 ≈ $0.25, ~2-3분, 출력 경로 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v1.png`). | pending |

#### Week 1 base 4장 시각 확인 결과 (art-director Read tool 2026-05-30)

| 파일 | 캐릭터 | Week 1 표정/포즈 시각 명세 | reaction sprint 활용 |
|------|--------|--------------------------|---------------------|
| **CH-02_mother.png** | 어머니 base | round-bun short black hair (simple dark shape) + 빨간 V-collar jeogori top (#F23E3E 톤) + soft white apron + 양손으로 작은 갈색 음식 그릇 들고 + warm motherly subtle smile mouth closed 살짝 up + 정상 dot eyes + light pink blush. **default expression ≈ ★1-★2 경계** (subtle warm smile 약간 ★1 쪽) | R-01~R-03 어머니 3컷 family IP base reference. **R-02 ★2 = anchor seed** (CH-02 base default와 가장 가까움). |
| **CH-03_father.png** | 아버지 base | short salt-and-pepper hair (gray-and-black simple shape) + solid teal-green button-up shirt (#2A8A6C 톤) + dark navy pants + LEFT 손 thumb-up + RIGHT 손 hip 옆 + slim smile mouth closed + 정상 dot eyes + 매우 light pink blush. **default expression ≈ ★2 경계** (thumb-up이 ★1 reserved보다 한 단계 위) | R-04~R-06 아버지 3컷 family IP base reference. **R-05 ★2 = anchor seed** (CH-03 base default와 가장 가까움). |
| **CH-04_mother_star1.png** | 어머니 Week 1 ★1 variant | round-bun + 빨간 sweater (apron 없음) + **sad teardrop expression** (한 눈에 작은 파란 teardrop visible) + downturned 입 + 한 손이 chin 쪽 어색한 worried 자세 + 정상 dot eyes + light pink blush | **본 sprint 재해석에서 폐기** — ADR-005 ★1 = "30%+ acceptable but not exciting" mild positive acceptance ↔ Week 1 sad teardrop은 부정 reaction (0-29% 영역 또는 호불호 penalty deep negative). R-01 prompt = subtle warm smile + 정상 open dot eyes로 새로 작성. CH-04 file 자체는 보존 (향후 deep negative reaction asset 재활용 가능). |
| **CH-05_father_star3.png** | 아버지 Week 1 ★3 variant | salt-and-pepper hair + **파란** button-up shirt (CH-03 base teal-green과 약간 다른 톤 inconsistency) + excited eyes-closed-arc happy + wide open mouth smile + LEFT thumb-up + RIGHT fist raised + **4개 simple flat orange sparkle accents** (얼굴 주변) + light pink blush | **본 sprint settle 형태에 가장 가까움**. R-06 prompt = CH-05 거의 그대로 재현 (단 shirt teal-green CH-03 base 정확 매칭 + bust-up framing). **CH-05 image를 R-06 generation 시 추가 reference upload 권장** (★3 expression intensity reference). |

#### ★1/★2/★3 Expression Gradient 정의 (어머니 column + 아버지 column)

| 단계 | Score | 어머니 (warm motherly nurturing tone) | 아버지 (reserved masculine tone) |
|------|-------|----------------------------------|------------------------------|
| **★1 mild satisfaction** | 30-59% | SUBTLE small arc smile (mouth closed, 살짝 up) + 정상 OPEN dot eyes + light pink blush + 살짝 head tilt + optional chin/chopsticks hand | SLIM RESERVED small arc smile (mouth closed, slight lift) + 정상 OPEN dot eyes + very light pink + 정상 upright + **thumb-up 없음** + optional chin hand |
| **★2 happy / pleased** | 60-89% | BIGGER warm smile mouth slightly OPEN + soft UPWARD CRESCENT ARC eyes + light pink more visible + 정상 upright relaxed + optional bowl/chopsticks | FULLER open smile (mouth slightly open) + slight UPWARD CRESCENT ARC eyes + light pink slightly more + 정상 upright relaxed + SMALL CASUAL single thumb-up (CH-03 base 톤) |
| **★3 very happy / excited** | 90-100% | BIG WIDE OPEN delighted smile + CLOSED-ARC HAPPY eyes (upward crescent) + light pink clearly visible + 양손 raised near cheeks in delight + optional 1-2 simple flat geometric heart icons | BIG WIDE OPEN delighted smile + CLOSED-ARC HAPPY eyes + light pink clearly visible + body slightly tilted forward + **DOUBLE thumb-up + one fist raised** (Week 1 CH-05 settle pose) + 2-4 simple flat geometric sparkle accents (Week 1 CH-05 sparkle pattern) |

#### M1 anchor 22장 + cut anchor 7장 + ingredient whole 12장 LOCK/병렬 무영향 확인

> reaction 6컷 sprint trigger는 M1 anchor 22장 (음식 12 + 환경 5 v4 + 캐릭터 5) + cut anchor 7장 LOCK status + ingredient whole 12장 sprint 병렬 진행에 모두 무영향. reaction은 신규 asset class 추가 (디렉터리 `assets-raw/reaction_anchors_m1/` 신설). 음식/환경/캐릭터/cut/ingredient anchor 재실행 없음. 단 reaction 6컷이 Cool Sage `#C8D5C0` bg를 사용하므로 음식 12 + cut 7 + ingredient whole 12 + reaction 6 = **37-asset Scene 3 cross-asset cluster**의 일관성 검증은 추후 별도 contact sheet 평가 권장.

### 6.16 mvp-food-selection v2.2 sync — F-02 호떡 → 잔치국수 + F-09 김치찌개 → 불고기 음식 anchor 2장 + ING-02/ING-09 ingredient anchor 2장 trigger (v1.17 신설, 2026-05-30)

> 2026-05-30 game-designer가 2026-05-28 mvp-food-selection v2.1 → v2.2 갱신 완료 (F-02 호떡 → 잔치국수 T1, 곡물+잡화+어물+청과 4가게 순회 / F-09 김치찌개 → 불고기 T2, 정육+청과+잡화). art-director는 본 v1.17에서 음식 anchor 2장 + ingredient anchor 2장 전면 교체.

| 라운드 | 날짜 | trigger 사유 | 영향 anchor | LOCK 유지 anchor | art-director 메모 | pm 승인 |
|-------|------|------------|------------|----------------|------------------|--------|
| M1 mvp v2.2 sync trigger (F-02/F-09 음식 + ING-02/ING-09 ingredient) | 2026-05-30 | game-designer mvp-food-selection v2.1 → v2.2 갱신 완료 (F-02 호떡 → 잔치국수 / F-09 김치찌개 → 불고기). 호떡/김치찌개 deprecated, 잔치국수/불고기 신규. ingredient도 hero 변경 (peanut R1 + brown_sugar R2 → 소면 / firm tofu R1 → 얇은 raw 소고기) | F-02 + F-09 음식 anchor (2건) + ING-02 + ING-09 ingredient anchor (2건) — **총 4장 신규** | 다른 8 음식 (F-01/F-03/F-04/F-05/F-06/F-07/F-08/F-10/F-11/F-12) + 10 ingredient (ING-01/ING-03/ING-04/ING-05/ING-06/ING-07/ING-08/ING-10/ING-11/ING-12) + cut 7 (CUT-00~06) + 환경 5 (BG-01~05 v4) + 캐릭터 5 (CH-01~05) + reaction 6 (R-01~06) LOCK status 무영향 유지 | prompts-library v1.17으로 §5.2 F-02/F-09 본문 전면 교체 + §5.6.2/§5.6.9 ING-02/ING-09 본문 전면 교체 + §0 anchor 표 4 row 갱신 + §6 변경 이력 v1.17 entry. driver script `tools/gen_food_anchors_m1.py` FOODS F-02 (hotteok → janchi_guksu) + F-09 (kimchi_jjigae → bulgogi) item name + body inline 전면 갱신 + docstring v1.17 sync. driver script `tools/gen_ingredient_anchors_m1.py` INGREDIENTS F-02 (brown_sugar_whole → somen_whole) + F-09 (firm_tofu_whole → thin_beef_whole) item name + food + cut_style + body inline 전면 갱신 + docstring v1.17 sync. main thread 실행 명령 = (1) **음식 anchor 2장**: `py tools/gen_food_anchors_m1.py --only F-02,F-09 --version v9 --model gpt-image-1 --quality medium` (2장 × $0.042 ≈ $0.08, ~30-60초, 출력 `assets-raw/food_anchors_m1/F-02_janchi_guksu_v9.png` + `F-09_bulgogi_v9.png` — version v9 = previous F-01~F-11 R1~R7 / F-12 R7 version과 충돌 회피, F-02/F-09 mvp v2.2 신규 첫 generation 명시 식별 가능) / (2) **ingredient anchor 2장**: `py tools/gen_ingredient_anchors_m1.py --only F-02,F-09 --version v3 --model gpt-image-1 --quality medium` (2장 × $0.042 ≈ $0.08, ~30-60초, 출력 `assets-raw/ingredient_anchors_m1/F-02_somen_whole_v3.png` + `F-09_thin_beef_whole_v3.png` — version v3 = previous v1 peanut/brown_sugar/firm_tofu / v2 (있다면) 회피, F-02/F-09 mvp v2.2 신규 generation 식별 가능). **총 4장 × $0.042 ≈ $0.17, ~2분**. | pending |

#### game-designer hero ingredient 매핑 인용 (mvp v2.2, 2026-05-28 완료)

| food (mvp v2.2) | hero ingredient | 부 hero (지원 ingredients) | art-director 매핑 결정 |
|----------------|----------------|------------------------|---------------------|
| **F-02 잔치국수 (T1)** | **소면 (white wheat thin noodle)** | 멸치 / 김 / 애호박 / 대파 | ING-02 = 소면 whole bundled dry (cut 없음, prep mechanic = sprinkle/serve into boiling broth). 부 hero 멸치/김/애호박/대파는 음식 anchor 자체에 garnish로 시각 통합 (별도 ingredient anchor 추가 안 함, M1 sprint 12 ingredient cap 유지). |
| **F-09 불고기 (T2)** | **얇은 marbled 소고기 (thin-sliced marbled sirloin, fanned)** | 양파 / 대파 / 당근 / 표고 | ING-09 = 얇은 raw marbled 소고기 stack/fan (cut 없음, prep mechanic = 양념재우기 marinade application). 부 hero 양파/대파/당근/표고는 음식 anchor 자체에 mixed-in vegetables로 시각 통합. **CRITICAL F-12 갈비 차별화**: NO bone-in LA cut + NOT grilled brown (RAW pink-red state) — cross-contamination risk ~40%. |

#### F-12 갈비구이 차별화 CRITICAL (불고기 F-09 ≠ 갈비 F-12)

> F-02 잔치국수는 cross-cultural negative만 critical (Japanese somen / Vietnamese pho 회피)이라 단순. **F-09 불고기는 한식 내부 cross-asset 차별화도 critical** — ChatGPT가 한식 BBQ 카테고리 (소고기 + 양념 + grill)를 보면 F-12 LA갈비로 cross-contamination 누수 빈번 (~40% default).

| 차별화 축 | F-09 불고기 (음식 anchor) | F-12 갈비구이 (음식 anchor) |
|---------|---------------------|-----------------------|
| meat form | thin marbled sirloin slices ~6-10cm × ~4-6cm × ~2-3mm, FANNED naturally curled | LA-style large rectangular strips ~18-25cm × ~8-12cm × ~0.5-0.8cm, parallel side-by-side |
| bone | **BONELESS** (NO visible white rib bone, NO bone cross-section discs, NO single long bone alongside) | 3-4 small ROUND WHITE BONE CROSS-SECTION DISCS along each strip's LENGTH (LA cross-cut signature) |
| cooking context | IN A DARK CAST-IRON Korean BBQ pan (전골 jeongol) + glossy brown marinade pool coating | ON a ROUND METALLIC WIRE MESH GRILL GRATE + slight 7/8 perspective + optional hot coals glow |
| sauce/marinade | GLOSSY BROWN soy-pear-garlic marinade POOL coating everything (양념 흠뻑) | well-grilled caramelized brown + char marks + chopped green scallion rounds garnish (양념 흠뻑 X, grill char dominant) |
| vegetables | mixed IN THE SAME PAN (양파/대파/당근/표고 + optional 당면) | NO vegetables on the grate (clean meat strips only) |
| garnish | sesame seeds + 송송 sliced 대파 chopped rounds (small) | chopped green scallion rounds (송송 sliced 대파, hero garnish) + sesame minor |
| view angle | 7/8 top-down | slight 7/8 perspective (paper-thin thickness visible) |

> 음식 anchor 2장이 visually 명확 분리되어야 game card 식별 충돌 0건. ChatGPT R1 결과 시각 확인 시 위 7 차별화 축 점검 필수.

#### F-12 갈비구이 차별화 CRITICAL (얇은 소고기 ING-09 ≠ 마늘 ING-12)

> ING-09 (얇은 소고기) vs ING-12 (마늘) ingredient anchor는 그 자체로는 ingredient 카테고리가 완전히 달라 cross-contamination 거의 없음 (beef vs garlic). 단 **ING-09 자체에서 ChatGPT가 음식 plated state로 잘못 추론** (F-12 plated 음식 anchor와 혼동)할 risk ~30%. 회피 = "RAW pink-red state, NOT cooked grilled brown, NOT a plated dish on a cutting board, NO bone visible (this is BONELESS thin-sliced sirloin)" explicit 명시.

#### 변경 사유 timeline (F-02 / F-09)

| food slot | mvp v2.1 (2026-05-25 archive) | mvp v2.2 (2026-05-28 settle) | game-designer 결정 사유 (인용) |
|----------|---------------------------|--------------------------|----------------------------|
| F-02 (T1) | 호떡 (Hotteok, 분식 sweet pancake, 잡화 single-shop) | 잔치국수 (Janchi-guksu, T1, 곡물+잡화+어물+청과 4가게 순회 noodle soup) | 4가게 순회 mechanic 추가 (mvp v2.2 multi-shop variation expansion), hero noodle 카테고리 도입 |
| F-09 (T2) | 김치찌개 (Kimchi Jjigae, ttukbaegi stew, 정육+잡화) | 불고기 (Bulgogi, T2, 정육+청과+잡화 3가게 — cast-iron pan meat dish) | meat-centric T2 dish 추가 (mvp v2.2 protein expansion), 청과 가게 사용 추가 |

> 자세한 game-designer 결정 timeline은 `docs/mvp-food-selection.md` v2.2 (2026-05-28) 참조.

#### ChatGPT 약점 risk top 7 (v1.17 갱신)

| Rank | anchor | 누수 risk | default % | 회피 전략 |
|------|--------|----------|-----------|----------|
| 1 | F-02 잔치국수 | Japanese somen tsuyu cold dipping + separate cup + ice | ~50% | "hot anchovy broth + egg ribbon + gim + zucchini garnish" + "NOT Japanese cold somen with tsuyu" explicit 강제 |
| 2 | F-09 불고기 | Japanese sukiyaki raw egg dipping bowl + 다른 vegetable set + napa cabbage dominant | ~50% | "Korean cast-iron pan + glossy brown soy-pear-garlic marinade pool + thin fanned marbled beef + mixed vegetables in same pan" + "NO raw egg dipping bowl, NO deep broth bath" |
| 3 | **F-09 불고기 vs F-12 갈비 CRITICAL cross-contamination** | bone-in LA cut + wire mesh grate + large 18-25cm strips 누수 | **~40% CRITICAL** | "BONELESS thin-sliced beef + NO bone-in LA cut + NOT grilled on wire mesh grate + NOT large 18-25cm LA strips + NOT separated meat strips" 반복 강조 + F-09 cast-iron pan + marinade pool / F-12 plated grill grate context 시각 분리 critical |
| 4 | ING-02 소면 | Japanese pink-and-white decorative paper band 누수 | ~40% | "Korean homestyle PLAIN white or pale cream paper band, NO printed text, NOT Japanese decorative pink-white striped" |
| 5 | ING-09 얇은 소고기 | Japanese wagyu A5 extreme intricate marbling + premium plating | ~40% | "subtle natural marbling on simple kitchen cutting board, NOT premium wagyu plating on leaf/stone" |
| 6 | ING-09 얇은 소고기 | cooked brown 누수 (이 anchor는 RAW state) | ~30% | "RAW pink-red base color + visible white marbled fat, NOT brown cooked, NOT marinade-coated" |
| 7 | F-02 잔치국수 | Vietnamese pho 누수 (clear broth + noodles 카테고리 혼동) | ~30% | "anchovy broth + egg ribbon + gim strips Korean garnish, NO lime, NO bean sprouts, NO basil/cilantro herbs, NO sliced raw beef" |

#### deprecation 기록 (F-02 호떡 + F-09 김치찌개 + ING-02 peanut/brown_sugar + ING-09 firm tofu)

> 본 v1.17 mvp v2.2 trigger로 deprecated된 5건의 음식/ingredient anchor 본문 + driver script item entries:

| ID | deprecated version | deprecation 사유 | archive 위치 |
|----|-------------------|----------------|-----------|
| F-02 호떡 (Hotteok) | v1.5 R3 LOCK candidate (식별 핵심 = brown sugar filling + topping syrup drizzle + paper cup) | mvp v2.1 → v2.2에서 F-02 slot 음식 자체 교체 (호떡 → 잔치국수). 호떡은 cross-cultural 누수 측면에서 LOCK candidate였으나 음식 selection 자체에서 제외됨 | prompts-library §6 변경 이력 v1.17 entry note (호떡 본문은 v1.5 R3 git history 참조; v1.17에서는 §5.2 F-02 본문 자체가 잔치국수로 전면 교체됨) |
| F-09 김치찌개 (Kimchi Jjigae) | v1.3 R1 LOCK 유지 (식별 핵심 = 검정 ttukbaegi + 빨간 gochugaru broth + 두부 cubes) | mvp v2.1 → v2.2에서 F-09 slot 음식 자체 교체 (김치찌개 → 불고기). 김치찌개는 R1 LOCK이었으나 음식 selection 자체에서 제외됨 | prompts-library §6 변경 이력 v1.17 entry note (김치찌개 본문은 v1.3 git history 참조; v1.17에서는 §5.2 F-09 본문 자체가 불고기로 전면 교체됨) |
| ING-02 peanut whole (R1) | R1 (식별 핵심 = 6-8 whole peanut shells lobed bumpy, F-02 호떡 보조 topping mapping) | R2 (2026-05-28)에서 사용자 명시 "흑설탕 dominant filling으로 교체" 시 peanut 보조 topping mapping은 archive 됨 | git history (이미 R2에서 archive 완료, v1.17은 추가 영향 없음) |
| ING-02 brown_sugar whole (R2) | R2 (식별 핵심 = dark brown granular sugar mound 5-6cm + optional cinnamon sticks, F-02 호떡 dominant filling mapping) | mvp v2.1 → v2.2에서 F-02 자체 교체 (호떡 → 잔치국수)로 흑설탕 hero ingredient 자체 deprecated | prompts-library §5.6.2 본문은 v1.17에서 소면으로 전면 교체됨; brown_sugar 본문은 git history (v1.15 §5.6.2 R2 또는 driver script v2 commit) 참조 |
| ING-09 firm_tofu whole (R1) | R1 (식별 핵심 = 12×9×3.5cm rectangular firm tofu block clean matte white #FAFAFA sharp edges, F-09 김치찌개 hero mapping) | mvp v2.1 → v2.2에서 F-09 자체 교체 (김치찌개 → 불고기)로 firm tofu hero ingredient 자체 deprecated | prompts-library §5.6.9 본문은 v1.17에서 얇은 소고기로 전면 교체됨; firm_tofu 본문은 git history (v1.15 §5.6.9 R1 또는 driver script v1 commit) 참조 |

#### M1 anchor 22장 + cut anchor 7장 + ingredient whole 12장 + reaction 6컷 LOCK/병렬 무영향 확인

> mvp v2.2 sync trigger는 다음 anchor에 모두 무영향: (a) **음식 anchor 10장** (F-01/F-03/F-04/F-05/F-06/F-07/F-08/F-10/F-11/F-12 — F-02/F-09 제외한 다른 음식들) / (b) **ingredient anchor 10장** (ING-01/ING-03/ING-04/ING-05/ING-06/ING-07/ING-08/ING-10/ING-11/ING-12 — ING-02/ING-09 제외) / (c) **cut anchor 7장** (CUT-00~06) / (d) **환경 5장** (BG-01~05 v4) / (e) **캐릭터 5장** (CH-01~05) / (f) **reaction 6컷** (R-01~06). 본 sprint는 F-02/F-09 음식 2장 + ING-02/ING-09 ingredient 2장 = **4장만 reroll**, 다른 음식 anchor (F-01~F-12 중 10장) 및 ingredient anchor (ING-01~ING-12 중 10장) 본문 / driver script body / 평가 표 status / Decisions Log 모두 무변경 유지. cut 7 + 환경 5 + 캐릭터 5 + reaction 6은 본 trigger와 완전 무관.

### 6.17 M1 후반 reaction 6컷 v2 image edit trigger (v1.18 신설, 2026-05-30)

> 2026-05-30 사용자가 v1 (prompt-only generation, `tools/gen_reaction_anchors_m1.py` gpt-image-1 medium 1024×1024 6장 batch) 결과 시각 확인 후 verbatim **"reaction 에서 R-01, R-03가 원래 이미지와 좀 다름, 그리고, R-04, R-05, R-06가 이미지가 좀 일관성이 없음"** 2건 피드백 raise. main thread 시각 분석으로 (a) **R-01/R-03 어머니 hair shape mismatch** (v1 round-bun + side-puff variant로 생성, CH-02 base의 round-bun simple과 다름) / (b) **R-04 vs R-05/R-06 아버지 family IP inconsistency** (R-04는 darker hair + darker teal-green shirt, R-05/R-06는 lighter tone — 셋 사이 inconsistency) 2건 발견. prompt-only generation이 CH-02/CH-03 base의 family IP를 정확 재현 못함을 확인 → **gpt-image-1 image edit API** (BG sprint v4에서 효과 입증된 패턴) 도입. v1.18 v2 = **CH-02_mother.png + CH-03_father.png base 직접 입력 + 표정만 변경** approach로 supersede. v1 6장 deprecated, v2 6장 image edit pending.

| 라운드 | 날짜 | trigger 사유 | 영향 anchor | LOCK 유지 anchor | art-director 메모 | pm 승인 |
|-------|------|------------|------------|----------------|------------------|--------|
| M1 후반 reaction v2 trigger (R-01~R-06) | 2026-05-30 | 사용자 v1 prompt-only 결과 시각 확인 후 verbatim "reaction 에서 R-01, R-03가 원래 이미지와 좀 다름, 그리고, R-04, R-05, R-06가 이미지가 좀 일관성이 없음" 2건 피드백 raise. main thread 분석 = (a) R-01/R-03 어머니 hair round-bun + side-puff mismatch vs CH-02 base round-bun simple / (b) R-04 vs R-05/R-06 아버지 family IP inconsistency (R-04 darker tone vs R-05/R-06 lighter tone). prompt-only가 base family IP 재현 못함 → v2 image edit trigger | R-01/R-02/R-03/R-04/R-05/R-06 (6건 — reaction anchor 전부, R-02는 anchor seed로 v1에서 사용자 silent ACK이었으나 통일 위해 v2 재생성) | **M1 anchor 22장 + cut anchor 7장 + ingredient whole 12장 LOCK 무영향 유지** (reaction sprint 단독 reroll) | prompts-library v1.18으로 §5.7 본문 전면 재작성 (v1.16 v1 prompt-only 본문은 §5.7.archive v1 deprecated 절로 이동 보존) + v2 image edit approach 명시 (COMMON_FRAME family IP IDENTICAL 강제 + 어머니 round-bun simple 명시적 강제 + 아버지 hair tone + shirt tone darker base와 EXACTLY 일치 명시적 강제 + bust-up crop + Cool Sage bg + 표정만 변경 + 6 expression_prompt ★1/★2/★3 어머니+아버지 각각 specific) + §0 anchor 표 R-01~R-06 6 row v1 deprecated → v2 image edit pending status 갱신 + §6 변경 이력 v1.18 entry. **새 driver `tools/edit_reaction_anchors_v2.py` 신설** — `tools/edit_bg_anchors_v4.py` template 기반 (image edit API + base image dimensions 검증 + PIL resize fallback + b64_json 응답 처리). 구조 = (1) COMMON_FRAME 상수 inline (single source) / (2) REACTIONS list 6개 inline (id / name / character / star / base / expression_prompt) / (3) base image 사전 검증 (CH-02_mother.png + CH-03_father.png 2장만) / (4) CLI args (`--only` `--version` `--quality` `--out-dir`) / (5) gpt-image-1 medium 1024×1024 default, version v2 default. v1 prompt-only driver (`tools/gen_reaction_anchors_m1.py`)는 보존 (git history). main thread 실행 명령: (1) test `py tools/edit_reaction_anchors_v2.py --only R-01 --quality medium` (1장 × ~$0.05, ~30초) → 시각 확인 후 (2) 6장 batch `py tools/edit_reaction_anchors_v2.py --quality medium` (6장 × $0.042 ≈ $0.25, ~2-3분, 출력 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v2.png` v1과 공존). 또는 어머니 mismatch만 `--only R-01,R-03` / 아버지 inconsistency만 `--only R-04,R-05,R-06`. v2 G_reaction 평가 = §5.9 G_reaction 5 요소 게이트 사용 (LOCK = 30/30 PASS, 변경 없음). v2가 v1 대비 G_reaction #1 family IP consistency PASS 확률 ↑ (image edit이 base PNG 직접 입력으로 family IP 보존). | pending |

#### v1 prompt-only vs v2 image edit 핵심 diff (6 요소)

| 요소 | v1 prompt-only (deprecated 2026-05-30) | v2 image edit (사용자 R1 v1 피드백 2건 fix) |
|------|-----------------------------|--------------------------|
| API approach | `client.images.generate(model="gpt-image-1", prompt=...)` — prompt-only generation (6장 batch, 매번 base와 다른 추론) | **`client.images.edit(model="gpt-image-1", image=open(base, "rb"), prompt=COMMON_FRAME + expression_prompt, size, quality, n=1)` — image edit API (base PNG 직접 입력)** |
| Base image input | None (text prompt에서 STYLE_SUFFIX_REACTION + body로 family IP description만 명시) | **CH-02_mother.png 직접 입력 (R-01/R-02/R-03)** + **CH-03_father.png 직접 입력 (R-04/R-05/R-06)** — Week 1 commit 7a6cffb base 5장 중 어머니/아버지 2장만 사용 |
| 어머니 R-01/R-03 hair | round-bun + side-puff variant (사용자 reject 사유 — CH-02 base와 다름) | **round-bun simple** (CH-02 base와 EXACTLY 일치, "round-bun without any side-puff or side-bangs additions" explicit 강제) |
| 아버지 R-04 vs R-05/R-06 family IP | R-04 darker tone vs R-05/R-06 lighter tone (사용자 reject 사유 — 셋 사이 inconsistency) | **3장 모두 CH-03 base의 darker salt-and-pepper hair + darker teal-green shirt tone EXACTLY 일치** ("MUST EXACTLY match the CH-03_father base image, same saturation, same shade, NOT lighter" explicit 강제) |
| Background | STYLE_SUFFIX_REACTION 안에 Cool Sage `#C8D5C0` 명시 (prompt-only가 정확히 재현 못할 수 있음) | COMMON_FRAME에서 "Replace any existing background with SOLID Cool Sage #C8D5C0" image edit instruction으로 base의 bg를 정확히 교체 |
| driver script | `tools/gen_reaction_anchors_m1.py` (gen_image.py `generate_image` 호출, STYLE_SUFFIX_REACTION + body 6 prompt-only) | **`tools/edit_reaction_anchors_v2.py` 신설** (image edit API + base image dimensions 검증 + PIL resize fallback + b64_json 응답 처리, COMMON_FRAME + 6 expression_prompt) |

#### 사용자 R1 v1 피드백 (verbatim, 2026-05-30)

> 사용자가 v1 6장 시각 확인 후 verbatim 명시:
>
> "reaction 에서 R-01, R-03가 원래 이미지와 좀 다름, 그리고, R-04, R-05, R-06가 이미지가 좀 일관성이 없음"

main thread 시각 분석 (CH-02/CH-03 base vs R-01~R-06 v1 비교):

**어머니 (CH-02 base vs R-01/R-03 v1)**:
- CH-02 base hair = round-bun **simple** (검정 짧은 둥근 봉우리, 단순)
- R-01 v1 hair = round-bun **+ side-puff** (앞머리 옆쪽 부풀어 오름 추가 variant)
- R-03 v1 hair = round-bun **+ side-puff** (R-01과 동일 패턴)
- R-02 v1 hair = round-bun simple (CH-02 base와 가장 가까움, anchor seed로 정상)
- 사용자 의도 = R-01/R-03 hair를 CH-02 base의 round-bun simple과 정확 매칭 (side-puff 제거)

**아버지 (CH-03 base vs R-04 vs R-05/R-06 v1)**:
- CH-03 base + R-04 v1 = darker salt-and-pepper hair (gray-and-black solid darker shade) + darker teal-green button-up shirt (#2A8A6C 톤)
- R-05 v1 + R-06 v1 = lighter salt-and-pepper hair (gray dominant, lighter tone) + lighter teal-green shirt (more washed out)
- 사용자 의도 = R-04/R-05/R-06 셋 모두 동일 family IP (hair tone + shirt tone + face proportions 통일) — R-05/R-06 lighter tone을 R-04 darker tone과 EXACTLY 일치로 fix (또는 R-04를 R-05/R-06 lighter tone에 맞춤, 단 CH-03 base가 darker이므로 R-04 darker가 base alignment 정확)

#### v2 v1 invalidation 기록 (reaction 6장만)

> v1 R-XX_<character>_star<N>_v1.png 6장 (2026-05-30 prompt-only generation, `assets-raw/reaction_anchors_m1/R-01~R-06_v1.png`)는 **invalidate**. 사용자 R1 verbatim 피드백 2건 (어머니 R-01/R-03 hair mismatch + 아버지 R-04/R-05/R-06 family IP inconsistency)로 deprecated. v1.18 v2 image edit으로 supersede. v1 출력 파일 6장은 git history reference로 보존 (v2 재실행 시 v2 출력은 별도 파일명 R-XX_<character>_star<N>_v2.png로 공존). **M1 anchor 22장 + cut anchor 7장 + ingredient whole 12장은 무영향** (reaction 6장 단독 reroll).

#### 도구 변경 사유 — prompt-only generation의 family IP 재현 한계

> v1 reaction 6장 sprint에서 학습한 점: prompt-only generation은 STYLE_SUFFIX_REACTION + body에서 Week 1 CH-02/CH-03 base family IP를 자연어로 자세히 description해도, ChatGPT는 base PNG를 직접 보지 못하므로 hair shape (round-bun simple → side-puff variant 추론) + hair tone + shirt tone에서 base와 어긋난 추론을 한다. 특히 어머니 hair shape처럼 미묘한 시각 디테일 (round-bun + side-puff vs round-bun simple)은 자연어로 명시해도 ChatGPT가 일관되게 재현하기 어려움. **해결**: gpt-image-1 image edit API로 base image PNG (CH-02_mother.png + CH-03_father.png)를 직접 입력하면, base의 family IP (hair shape/tone + outfit color/tone + face proportions)는 보존하고 prompt가 지정한 부분 (표정 + 손 위치 + bg)만 교체. BG sprint v4에서 동일 패턴 (v1.2 base 카게 구조 보존 + 지붕만 교체)이 성공한 precedent — reaction도 동일 패턴으로 family IP 보존 + 표정만 변경 달성 기대.

#### v2 risk top 3 (image edit이 새로 introduce하는 risk)

| Rank | risk | default % | 회피 전략 |
|------|------|-----------|----------|
| 1 | **R-04 ★1 thumb-up carry over (CH-03 base thumb-up이 ★1 reserved 의도와 conflict, CRITICAL)** | ~30% | R-04 expression_prompt에 "NO thumb-up gesture (★1 is reserved acceptance, NOT enthusiastic), optional one hand near chin or beside cheek in a thoughtful gesture" explicit 강제 |
| 2 | **base의 default expression 유지 (★1/★2/★3 gradient 무너짐)** | ~25% | COMMON_FRAME 시작부에 "ONLY change the FACIAL EXPRESSION to the specified star level" + 각 expression_prompt 시작부에 "EXPRESSION CHANGE — character ★N (gradient description)" 명시 + ★N specific description 강화 |
| 3 | **base의 bowl/물건 prop carry over (R-03 ★3 hands near cheeks와 conflict)** | ~20% | R-03/R-06 expression_prompt에 hand position 명시 ("both mitten hands raised near cheeks in delight" / "BOTH mitten hands giving enthusiastic thumb-up gesture") |

> 부차 risk (P2): R-01/R-03 어머니 hair side-puff 회귀 (~15%, COMMON_FRAME explicit 강제로 회피) / R-04/R-05/R-06 아버지 lighter tone 회귀 (~10%, COMMON_FRAME "EXACTLY match base, NOT lighter" explicit 강제로 회피) / R-03 heart icon 폭주 (~20%, expression_prompt "simple flat geometric, NOT detailed anime hearts" 명시) / R-06 sparkle 폭주 (~25%, expression_prompt "small simple flat geometric sparkle, NOT detailed anime sparkle effects" 명시).

#### R3 fallback — 사용자 ChatGPT 웹 UI 수동 chain-of-references 워크플로

> v2 image edit 결과가 여전히 family IP consistency 부족하거나 expression gradient 불명확하면, 사용자가 ChatGPT 웹 UI에서 수동 chain-of-references 워크플로 실행:
>
> 1. **어머니 세션**: 새 ChatGPT 세션 → CH-02_mother.png upload + R-02 ★2 prompt (anchor seed) → 어머니 ★2 anchor seed lock → 같은 세션에서 seed image + R-01 ★1 prompt follow-up → 같은 세션에서 seed image + R-03 ★3 prompt follow-up. 어머니 3컷 lock 후 세션 종료.
> 2. **아버지 세션**: 새 ChatGPT 세션 (cross-character contamination 회피) → CH-03_father.png upload + R-05 ★2 prompt (anchor seed) → 아버지 ★2 anchor seed lock → 같은 세션에서 seed image + R-04 ★1 prompt follow-up ("NO thumb-up" explicit 강조) → 같은 세션에서 seed image + R-06 ★3 prompt follow-up (CH-05_father_star3.png 추가 reference upload 권장, ★3 expression intensity reference). 아버지 3컷 lock 후 세션 종료.
> 3. 결과 6장을 `assets-raw/reaction_anchors_m1/` 디렉터리에 R-XX_<character>_star<N>_v3.png suffix로 저장 (v1/v2와 공존, v3 = manual chain-of-references).
> 4. art-director는 v3 6장에 대해 §5.9 G_reaction 5 요소 게이트 재평가 → LOCK 판정.

### 6.18 M1 후반 art sprint 4번째 — Ingredient Cut 12장 trigger (v1.19 신설, 2026-05-30)

> 2026-05-30 M1 후반 art sprint 2번째 (ingredient whole 12장) + 3번째 (reaction 6컷 v2) 진행 중 + **4번째 sprint 진입**. 사용자 verbatim **"손질하고 나서의 ingredient 이미지가 있어야 할 거 같고"** trigger. ingredient whole 12장 (§5.8 ING-01~12)은 "before" state, cut anchor 7장 (§5.7 CUT-00~06)은 generic cut style 시연. 그 사이 누락된 asset = 각 음식의 hero ingredient를 그 음식 특유 cut 결과로 specific 시각화. 음식별 cut 결과는 generic CUT-01~06 anchor와 미세 차이 있음 (음식 시그니처 강화 가치) — 예: F-02 애호박은 잔치국수용 thin disc 5-8개 (generic CUT-04 김밥 cylinder cross-section과 다름) / F-04 어묵은 떡볶이용 medium 6-8cm oval (generic CUT-03의 어묵+대파 mixed cluster와 다름) / F-07 daepa는 pajeon용 large 5-7cm oval (generic CUT-03과 mixed). **옵션 C 채택** (12장 specific 모두 생성, F-06 cheese는 ING-06과 동일 image이나 카탈로그 완전성 위해 별도, F-11 carrot은 F-08과 slight variation으로 별도 생성하나 game-designer 재사용 확정 시 archive).

| 라운드 | 날짜 | trigger 사유 | 영향 anchor | LOCK 유지 anchor | art-director 메모 | pm 승인 |
|-------|------|------------|------------|----------------|------------------|--------|
| M1 후반 ingredient cut 12장 trigger | 2026-05-30 | 사용자 verbatim "손질하고 나서의 ingredient 이미지가 있어야 할 거 같고" — ingredient whole 12장 "before"의 cut된 "after" pair 시각화 필요. ADR-005 Stage 2B/2C 사용 + 음식 시그니처 강화 (음식별 cut 결과는 generic CUT-01~06 anchor와 미세 차이 있음) | ICUT-01~12 (12장 신규, F-01~F-12 각 음식 hero ingredient cut 결과 specific) | M1 anchor 22장 + cut anchor 7장 + ingredient whole 12장 + reaction 6컷 LOCK 무영향 유지 (cut 7 + whole 12 + cut 12 = 31장 + reaction 6 = 37장 cross-asset 일관성 작동) | prompts-library v1.19로 §5.10 ingredient cut 12장 prompt set 신설 (음식 × hero ingredient cut 매핑 표 §5.10.0 + STYLE_SUFFIX_INGREDIENT_CUT inline note §5.10.1 + 12장 prompt body single source = driver script INGREDIENT_CUTS list inline §5.10.2~13) + §0 anchor 표 ICUT-01~12 row 12장 추가. **새 driver `tools/gen_ingredient_cut_anchors_m1.py` 신설** — `tools/gen_ingredient_anchors_m1.py` template 기반. 구조 = (1) STYLE_SUFFIX_INGREDIENT_CUT 상수 inline (single source) — §5.6 STYLE_SUFFIX_INGREDIENT (whole)와 cross-asset 31+ anchor 통일 + INGREDIENT PLACEMENT 절 변경 (whole "single intact whole + NO cut pieces" → cut "cut/prepared result cluster + NO whole intact ingredient") / (2) INGREDIENT_CUTS list 12개 inline (id=food_id / name=ingredient_cut_slug / food=food_name_en / cut_style=cut_style_id / body) / (3) CLI args (`--only` `--version` `--quality` `--out-dir`) / (4) gpt-image-1 medium 1024×1024 default + 출력 default `assets-raw/ingredient_cut_anchors_m1/` / (5) **`build_prompt(body) = body.replace("%s", STYLE_SUFFIX_INGREDIENT_CUT, 1)`** 패턴 사용 (gen_food/gen_ingredient에서 발생했던 `body % SUFFIX` Python old-style ValueError fix 적용 — body의 다른 `%` character 보존). 12장 specific 본문 핵심: F-01 송송 20-30 small green discs / F-02 통썰기 5-8 round green-rim+pale-flesh zucchini discs / F-03 채썰기 15-20 long 8-10cm yellow matchstick (kimbap-length) / F-04 어슷썰기 5-7 medium 6-8cm golden-brown oval / F-05 다지기 fine red kimchi bits / F-06 cheese whole (no cut, ING-06과 동일 image) / F-07 어슷썰기 5-7 large 5-7cm DOMINANT GREEN daepa oval (F-04와 색 분리 CRITICAL) / F-08 채썰기 15-20 short 5-7cm orange matchstick (bibimbap-length) / F-09 marinade brown glaze coated 5-7 thin beef slices + 작은 marinade pool (no cut, F-12 갈비 차별화 CRITICAL: NO bone + NOT cooked char marks) / F-10 broken cloud-like white tofu mound 2-4cm irregular fragments (no cut) / F-11 채썰기 15-20 medium 6-8cm orange matchstick slight diagonal pile (F-08 variation) / F-12 다지기 fine yellowish-white garlic granules 1-3mm. **§5.10 M1 후반 Ingredient Cut 12장 평가 가이드 신설** — §5.10.1 배경 (M1 후반 4번째 sprint 진입 + 사용자 verbatim trigger + 옵션 C 채택 사유) / §5.10.2 **G_ingredient_cut 5 요소 점검표 신설** = (1) **CRITICAL — hero ingredient cut 결과 시각 식별 명확** (12 ingredient cut 결과 시그니처 모양+색+크기+cluster size, cross-cut 디스트랙터 페어 정확 구분: 송송 vs 통썰기 vs 어슷썰기 다른 oval 크기 / 채썰기 다른 length kimbap 8-10cm vs bibimbap 5-7cm vs japchae 6-8cm) / (2) **CRITICAL — CUT/PREPARED RESULT state 명확** (cut/prep cluster만 + WHOLE intact ingredient 0건 + cutting action mid-motion 0건) / (3) **CRITICAL — Cool Sage `#C8D5C0` bg + 도마 + 칼 LEFT side static 통일 (cross-asset 31+ anchor 일관성)** (cut 7 + whole 12 + cut 12 = 31장 cross-asset cluster 합류 인식, CUT-00 anchor seed + 페어 ING-XX whole image 추가 reference upload 권장) / (4) **modern saturated 톤 + 단순화** (채도 80-90% / heavy texture 0건 / 베이지·scrapbook·Cookie Run 2021 톤 0건) / (5) **CRITICAL — cross-cultural 누수 0건 + 음식 시그니처 시각 분리 (특히 F-04 vs F-07 daepa, F-09 vs F-12 갈비)** = top 5 risk: ICUT-02 cucumber/Italian zucchini 0건 + ICUT-04 Japanese naruto pink spiral / chikuwa 0건 + **ICUT-07 daepa F-04 어묵 oval 색 누수 0건 CRITICAL** (golden-brown → dominant green) + **ICUT-09 marinade beef F-12 갈비 bone visible 누수 0건 CRITICAL + raw red 또는 grilled char marks 누수 0건** + ICUT-10 firm cube 누수 0건. **LOCK 조건 = 12/12 anchors × 5 요소 = 60/60 PASS** (ICUT-06 cheese ING-06과 동일 image면 PASS / ICUT-11 carrot variation은 F-08과 slight 차별 visible면 PASS, game-designer 재사용 확정 시 archive). 부분 통과 정책 (11 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only F-XX --version v2` reroll / 9-10 LOCK = CONDITIONAL batch reroll / 8 이하 = FAIL → pm 에스컬레이션 / G_icut #1 hero cut 식별 FAIL = 명세 강화 / G_icut #2 CUT RESULT state FAIL = "ready-to-cook prep result, NO whole intact" explicit 강조 / G_icut #3 cross-asset FAIL = CUT-00 + 페어 ING-XX whole reference upload 재시도 / G_icut #5 F-04 vs F-07 색 누수 FAIL = "DOMINANT BRIGHT GREEN daepa NOT F-04 golden-brown" 명세 강화 / G_icut #5 F-09 vs F-12 FAIL = "NO bone visible (F-12 차별화), brown from MARINADE NOT grill" 명세 강화). §5.10.3 ingredient cut 12장 라운드 예산 (R1 ICUT-01 test 권장 → 12장 batch ~4-5분 $0.50 / R2 follow-up FAIL anchor 집중). §5.10.4 **ChatGPT 약점 risk top 5 신설** = (1) ICUT-02 애호박 cucumber 누수 ~50% / (2) ICUT-04 어묵 Japanese naruto pink spiral ~50% / (3) **ICUT-07 daepa F-04 어묵 색 누수 ~40% CRITICAL** / (4) **ICUT-09 marinade beef raw red 또는 cooked char marks 누수 ~40% + F-12 갈비 bone visible 누수 CRITICAL** / (5) ICUT-10 broken tofu firm cube 누수 ~40%. §5.10.5 **game-designer 후속 confirm 사안** 4행 표 (ICUT-06 cheese / ICUT-09 marinade prep / ICUT-10 broken curds / ICUT-11 carrot 재사용 확정 시 archive). **§3.7 ingredient cut 평가 표 신설** (ICUT-01 ~ ICUT-12 12 row × G1/G3/G4/G5/G6/G7/G_new + G_ingredient_cut 컬럼 + risk top 항목 명시). main thread 실행 명령: **(1) test** `py tools/gen_ingredient_cut_anchors_m1.py --only F-01 --quality medium` (1장 × $0.042 ≈ $0.05, ~30초) → 시각 확인 후 **(2) batch** `py tools/gen_ingredient_cut_anchors_m1.py --quality medium` (12장 × $0.042 ≈ $0.50, ~4-5분, 출력 `assets-raw/ingredient_cut_anchors_m1/F-XX_<ingredient_cut_name>_v1.png`). | pending |

#### 옵션 C 채택 사유 (옵션 A/B vs C)

| 옵션 | 내용 | 비용 | 선택 사유 |
|------|------|------|----------|
| A (12장 모두 specific) | 12장 모두 음식별 specific cut 결과 생성 | ~$0.50, ~4-5분 | C와 동일 (옵션 C의 변형) |
| B (CUT-01~06 재사용 + specific 추가만) | generic CUT-01~06 anchor와 시각 차이 적은 음식 (F-08/F-11 당근 채썰기) skip, specific 음식 (F-02 애호박 / F-04 어묵 / F-07 daepa) 6-8장만 생성 | ~$0.30, ~3분 | **미채택** — F-08/F-11도 음식 시그니처 강화 가치 있음 (bibimbap 5-7cm short / japchae 6-8cm medium 차별), F-06 cheese / F-09 marinade / F-10 broken curds는 generic CUT-01~06에 매핑 없음 (no cut state) |
| **C (12장 specific, 권고)** | 12장 모두 specific 생성. F-11 carrot은 F-08과 slight variation으로 별도, F-06 cheese는 ING-06과 동일 image (카탈로그 완전성) | ~$0.50, ~4-5분 | **채택** — 음식 시그니처 강화 + Stage 2B/2C 사용 + game-designer 후속 확정 시 일부 archive 가능 (ICUT-06 cheese ING-06 재사용 / ICUT-11 carrot F-08 재사용) |

#### 음식 × hero ingredient cut 매핑 표 (12장, prompts-library v1.19 §5.10.0 sync)

| ID | food | hero ingredient cut 결과 | pair cut style | game-designer 검증 사안 |
|----|------|------------------------|---------------|----------------------|
| ICUT-01 | F-01 Ramyeon | spring onion 송송 thin green discs 20-30개 | CUT-05 송송 | 동일 (whole과 같은 mapping) |
| ICUT-02 | F-02 Janchi-guksu | Korean zucchini 통썰기 round discs 5-8개 4-5cm | CUT-04 통썰기 | 동일 |
| ICUT-03 | F-03 Kimbap | danmuji 채썰기 yellow matchstick 15-20개 8-10cm kimbap-length | CUT-02 채썰기 | 동일 |
| ICUT-04 | F-04 Tteokbokki | fish cake 어슷썰기 golden-brown oval 5-7개 6-8cm | CUT-03 어슷썰기 | 동일 |
| ICUT-05 | F-05 Kimchi Bokkeumbap | kimchi 다지기 fine red bits scattered | CUT-01 다지기 | 동일 |
| ICUT-06 | F-06 Corn Dog | mozzarella whole (no cut, ING-06 동일) | (no cut) | F-06 prep mechanic이 cheese 외 sausage cut 있는가? 있으면 ICUT-06 swap |
| ICUT-07 | F-07 Haemul Pajeon | daepa large dominant green oval 5-7개 5-7cm × 1.5-2.5cm | CUT-03 어슷썰기 | 동일 (F-04와 색 분리 CRITICAL) |
| ICUT-08 | F-08 Bibimbap | carrot 채썰기 orange matchstick 15-20개 5-7cm | CUT-02 채썰기 | 동일 |
| ICUT-09 | F-09 Bulgogi | thin beef marinade coated brown glaze (no cut, 양념재우기) | (no cut, marinade) | F-09 prep mechanic이 marinade 외 양파/대파 cut 있는가? 있으면 ICUT-09 swap |
| ICUT-10 | F-10 Sundubu | soft tofu broken cloud-like fragments (no cut, 스푼으로 푼) | (no cut, broken) | F-10 prep mechanic이 broken curds 외 멸치/김치 cut 있는가? 있으면 ICUT-10 swap |
| ICUT-11 | F-11 Japchae | carrot 채썰기 orange matchstick 15-20개 6-8cm slight diagonal pile | CUT-02 채썰기 (F-08 variation) | F-11이 F-08 carrot cut anchor 재사용 결정 시 ICUT-11 archive |
| ICUT-12 | F-12 Galbi-gui | garlic 다지기 fine yellowish-white granules 1-3mm | CUT-01 다지기 | 동일 |

#### cut style 분포 통계 (음식 12 → cut style 5 + 3 no-cut/prep)

| cut style | 사용 음식 수 | 음식 list | 비고 |
|----------|-----------|----------|------|
| CUT-01 다지기 | 2 | F-05 김치 / F-12 마늘 | (mvp v2.2에서 F-02 호떡 견과류 다지기 deprecated, 1 감소) |
| CUT-02 채썰기 | 3 | F-03 단무지 / F-08 당근 / F-11 당근 | 당근 2회 (F-08/F-11 재사용 가능, length 차별로 별도 생성) |
| CUT-03 어슷썰기 | 2 | F-04 어묵 / F-07 대파 daepa | F-04 vs F-07 색 분리 CRITICAL |
| **CUT-04 통썰기** | **1** | **F-02 잔치국수 애호박** | mvp v2.2 user fix mapping (이전 0건 → 활성화) |
| CUT-05 송송썰기 | 1 | F-01 대파 spring onion | |
| CUT-06 깍둑썰기 | **0** | (none) | **CUT-06 hero ingredient cut prep 매핑 없음 — mvp v2.2 F-09 firm tofu 깍둑 deprecated 후 0건, game-designer 검증 필요** |
| (no cut, whole) | 1 | F-06 모짜렐라 | ICUT-06 = ING-06 동일 image |
| (no cut, marinade) | 1 | F-09 얇은 소고기 | mvp v2.2 신규 prep state (marinade application) |
| (no cut, broken curds) | 1 | F-10 두부 soft | scooping/squeezing prep |

> 12 음식 = CUT-01 다지기 2 + CUT-02 채썰기 3 + CUT-03 어슷썰기 2 + CUT-04 통썰기 1 + CUT-05 송송 1 + (no cut) 3 = 12. CUT-06 깍둑썰기는 0건 (mvp v2.2 후), game-designer 후속 확정 시 hero ingredient swap 검토 가능 (현재 사용 음식 없음).

#### M1 anchor 22장 + cut anchor 7장 + ingredient whole 12장 + reaction 6컷 + 환경 5장 + 캐릭터 5장 LOCK/병렬 무영향 확인

> ingredient cut 12장 sprint trigger는 다음 anchor에 모두 무영향: (a) **음식 anchor 12장** (F-01~F-12) / (b) **ingredient whole anchor 12장** (ING-01~ING-12) — 본 sprint의 "before" pair, 본 sprint와 동시 진행 / (c) **cut anchor 7장** (CUT-00~06) / (d) **환경 5장** (BG-01~05 v4) / (e) **캐릭터 5장** (CH-01~05) / (f) **reaction 6컷** (R-01~06 v2). 본 sprint는 ICUT-01~12 신규 12장만 생성, 다른 anchor (food 12 / whole 12 / cut 7 / 환경 5 / 캐릭터 5 / reaction 6 = 47장) 모두 무변경 유지. ingredient cut 12장은 신규 asset class `assets-raw/ingredient_cut_anchors_m1/` 디렉터리 신설.

---

## 7. 변경 이력

- **2026-05-30 v1.19** (M1 후반 art sprint 4번째 — 음식 12 × hero ingredient CUT 12장 평가 가이드 §5.10 신설 + G_ingredient_cut 5 요소 게이트 + §3.7 ingredient cut 평가 표 신설 + §6.18 Decisions Log 신설, ADR-005 Stage 2B/2C "after"-cut pair, 사용자 verbatim "손질하고 나서의 ingredient 이미지가 있어야 할 거 같고" trigger, supersedes v1.18) — M1 후반 art sprint 4번째 진입. 사용자 verbatim trigger로 ingredient whole 12장 "before" state와 cut anchor 7장 generic 사이의 누락된 asset = 음식별 hero ingredient를 그 음식 특유 cut 결과로 specific 시각화. 옵션 C 채택 (12장 specific 모두 생성, F-06 cheese = ING-06 동일 image 별도 카탈로그 / F-11 carrot = F-08 slight variation 별도, game-designer 후속 재사용 확정 시 archive). prompts-library v1.19에서 §5.10 신설 (음식 × hero ingredient cut 매핑 표 + STYLE_SUFFIX_INGREDIENT_CUT inline note + 12장 prompt body single source = driver script INGREDIENT_CUTS list inline) + §0 anchor 표 ICUT-01~12 row 12장 추가 + 새 driver `tools/gen_ingredient_cut_anchors_m1.py` 신설 완료. 본 art-anchor-rubric v1.19 = 평가 가이드 신설: **§3.7 ingredient cut 평가 표 신설** (ICUT-01 ~ ICUT-12 12 row × G1/G3/G4/G5/G6/G7/G_new + G_ingredient_cut 컬럼 + risk top 항목 + food_id + cut style 매핑 + F-04 vs F-07 색 분리 CRITICAL + F-09 vs F-12 갈비 차별화 CRITICAL 명시). **§5.10 M1 후반 Ingredient Cut 12장 평가 가이드 신설** — §5.10.1 배경 (사용자 verbatim trigger + 옵션 C 채택 사유 + 음식별 cut 결과 generic CUT-01~06과 미세 차이 가치) / §5.10.2 **G_ingredient_cut 5 요소 점검표 신설** = (1) **CRITICAL — hero ingredient cut 결과 시각 식별 명확** / (2) **CRITICAL — CUT/PREPARED RESULT state 명확** (WHOLE intact 0건) / (3) **CRITICAL — Cool Sage bg + 도마 + 칼 LEFT static 통일 (cross-asset 31+ anchor 일관성, CUT-00 + 페어 ING-XX whole reference upload 권장)** / (4) **modern saturated 톤 + 단순화** / (5) **CRITICAL — cross-cultural 0건 + F-04 vs F-07 daepa 색 분리 CRITICAL + F-09 vs F-12 갈비 차별화 CRITICAL**. **LOCK = 12/12 × 5 = 60/60 PASS** (ICUT-06 cheese ING-06 동일 image면 PASS / ICUT-11 carrot F-08 variation slight 차별 visible면 PASS, game-designer 재사용 확정 시 archive). 부분 통과 정책 (11 LOCK + 1 FAIL = CONDITIONAL `--only F-XX --version v2` / 9-10 LOCK = batch reroll / 8 이하 = FAIL → pm). §5.10.3 라운드 예산 (ICUT-01 test ~30초 $0.05 → 12장 batch ~4-5분 $0.50 / R2 follow-up). §5.10.4 **ChatGPT 약점 risk top 5 신설** = (1) ICUT-02 cucumber 누수 ~50% / (2) ICUT-04 Japanese naruto pink spiral ~50% / (3) **ICUT-07 daepa F-04 어묵 색 누수 ~40% CRITICAL** / (4) **ICUT-09 raw red/cooked char marks ~40% + F-12 bone visible CRITICAL** / (5) ICUT-10 firm cube ~40%. §5.10.5 **game-designer 후속 confirm 사안** 4행 표 (ICUT-06/ICUT-09/ICUT-10/ICUT-11 swap 또는 archive). **§6.18 Decisions Log 신설** — M1 후반 art sprint 4번째 시작 + 사용자 verbatim trigger + ingredient cut 12장 trigger 행 + **옵션 A/B/C 비교 표** (옵션 C 채택 사유) + 음식 × hero ingredient cut 매핑 표 (12행, game-designer 검증 사안 포함) + **cut style 분포 통계** (CUT-01 다지기 2 / CUT-02 채썰기 3 / CUT-03 어슷썰기 2 / CUT-04 통썰기 1 mvp v2.2 신규 / CUT-05 송송 1 / **CUT-06 깍둑썰기 0 — mvp v2.2 F-09 firm tofu deprecated 후 0건, game-designer 검증 필요** / no cut 3) + main thread 실행 명령 (test `py tools/gen_ingredient_cut_anchors_m1.py --only F-01 --quality medium` ~$0.05 ~30초 → batch `py tools/gen_ingredient_cut_anchors_m1.py --quality medium` 12장 × $0.042 ≈ $0.50 ~4-5분, 출력 `assets-raw/ingredient_cut_anchors_m1/F-XX_<ingredient_cut_name>_v1.png`) + M1 anchor 22 + cut 7 + whole 12 + reaction 6 + 환경 5 + 캐릭터 5 = 47장 LOCK/병렬 무영향 확인 (ingredient cut 12장은 신규 asset class 디렉터리 신설). 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. ingredient whole 12장 평가 (§5.8) 무변경. reaction 6컷 평가 (§5.9) 무변경.
- **2026-05-30 v1.18** (M1 후반 reaction 6컷 v2 image edit — CH-02/CH-03 base + 표정만 변경, 사용자 R1 v1 피드백 2건 fix [어머니 R-01/R-03 hair mismatch + 아버지 R-04/R-05/R-06 family IP inconsistency] + §3.6 reaction 평가 표 v2 status 갱신 + §5.9 G_reaction v2 image edit approach note 추가 + §6.17 Decisions Log 신설, supersedes v1.17) — 사용자가 v1 (`tools/gen_reaction_anchors_m1.py` prompt-only generation, gpt-image-1 medium 1024×1024 6장 batch) 결과 시각 확인 후 verbatim "reaction 에서 R-01, R-03가 원래 이미지와 좀 다름, 그리고, R-04, R-05, R-06가 이미지가 좀 일관성이 없음" 2건 피드백 raise. main thread 시각 분석으로 (a) **R-01/R-03 어머니 hair shape mismatch** (v1 round-bun + side-puff variant vs CH-02 base round-bun simple) / (b) **R-04 vs R-05/R-06 아버지 family IP inconsistency** (R-04 darker hair+shirt tone vs R-05/R-06 lighter tone) 2건 발견. prompt-only generation이 CH-02/CH-03 base의 family IP를 정확 재현 못함을 확인 (자연어 description으로 hair shape/tone subtle detail 일관 재현 어려움) → **gpt-image-1 image edit API** (BG sprint v4에서 효과 입증된 패턴) 도입. **§3.6 reaction 평가 표 R-01~R-06 6 row status 갱신** — 모두 v1 prompt-only deprecated 2026-05-30 → v2 image edit pending. R-01/R-03 행에 "어머니 hair round-bun simple base 일치 강제" / R-04/R-05/R-06 행에 "아버지 hair tone + shirt tone darker (CH-03 base와 EXACTLY 일치, NOT lighter) family IP lock 강제" 추가. R-02는 anchor seed로 base와 가장 가까워 v1 시각 결과 가장 안정적이었으나 통일성 위해 v2에서 함께 재생성. **§5.9 G_reaction v2 image edit approach note 추가** — G_reaction 5 요소 기준 무변경 (LOCK = 30/30 PASS), 단 v2는 image edit API 사용으로 family IP consistency 게이트 (G_reaction #1) PASS 확률 ↑. v1 prompt-only approach의 한계 (base family IP 정확 재현 불가)를 image edit으로 극복. 새로운 v2 risk top 3 = (1) R-04 ★1 thumb-up CH-03 base carry over ~30% CRITICAL (prompt explicit "NO thumb-up" 회피) / (2) base의 default expression 유지 ★1/★2/★3 gradient 무너짐 ~25% (EXPRESSION CHANGE explicit + ★N specific description 강화) / (3) base의 bowl prop carry over R-03 ★3 hands near cheeks conflict ~20% (hand position 명시). 부차 risk = R-01/R-03 어머니 hair side-puff 회귀 ~15% (COMMON_FRAME explicit 강제로 회피) / R-04/R-05/R-06 아버지 lighter tone 회귀 ~10% (COMMON_FRAME "EXACTLY match base, NOT lighter" explicit 강제). **§6.17 Decisions Log 신설** — reaction v2 trigger 행 + 사용자 R1 v1 verbatim 피드백 + main thread 시각 분석 (어머니 CH-02 vs R-01/R-03 hair / 아버지 CH-03 + R-04 vs R-05/R-06 tone) + v1 prompt-only vs v2 image edit 6 핵심 diff 표 (API approach / Base image input / 어머니 hair / 아버지 family IP / Background / driver script) + v1 invalidation 기록 (6장만, M1 anchor 22 + cut 7 + ingredient whole 12 무영향 명시) + 도구 변경 사유 (prompt-only family IP 재현 한계 + image edit으로 base PNG 직접 입력으로 family IP 보존 + BG v4 precedent) + v2 risk top 3 표 (R-04 thumb-up CRITICAL + base default expression + bowl prop carry over) + **R3 fallback (사용자 ChatGPT 웹 UI 수동 chain-of-references)** 워크플로 명시 (어머니 세션 + 아버지 세션 분기, CH-02/CH-03 upload + ★2 seed + ★1/★3 follow-up, R-06에 CH-05_father_star3.png 추가 reference 권장) + main thread 실행 명령 (test `py tools/edit_reaction_anchors_v2.py --only R-01 --quality medium` ~$0.05 ~30초 → batch `py tools/edit_reaction_anchors_v2.py --quality medium` 6장 × $0.042 ≈ $0.25 ~2-3분, 출력 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v2.png` v1과 공존, 또는 어머니만 `--only R-01,R-03` / 아버지만 `--only R-04,R-05,R-06`). prompts-library v1.18 sync 완료 (§5.7 본문 v2 image edit approach 전면 재작성 + v1 prompt-only 본문 §5.7.archive v1 deprecated 절로 이동 보존 + §0 anchor 표 R-01~R-06 row 6장 status 갱신 + §6 변경 이력 v1.18 entry). **새 driver `tools/edit_reaction_anchors_v2.py` 신설** — `tools/edit_bg_anchors_v4.py` template 기반. 구조 = (1) COMMON_FRAME 상수 inline (family IP IDENTICAL 강제 + 어머니 round-bun simple 명시 + 아버지 darker tone base와 EXACTLY 일치 명시 + bust-up + Cool Sage bg + 표정만 변경 + sad/sleeping/Japanese kimono/anime girl 회피 negative) / (2) REACTIONS list 6개 inline (id / name / character / star / base / expression_prompt — 각 ★N specific description 강화) / (3) base image 사전 검증 (CH-02_mother.png + CH-03_father.png 2장만 사용) / (4) CLI args (`--only` `--version` `--quality` `--out-dir`) / (5) gpt-image-1 medium 1024×1024 default, version v2 default. v1 prompt-only driver (`tools/gen_reaction_anchors_m1.py`)는 보존 (git history). v1 output 6장도 보존 — v2와 공존. 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. ingredient whole 12장 평가 (§5.8) 무변경.
- **2026-05-30 v1.17** (mvp-food-selection v2.2 sync — F-02 호떡 → 잔치국수 + F-09 김치찌개 → 불고기 음식 anchor 2장 + ING-02/ING-09 ingredient anchor 2장 status 갱신 + §5.5.4 음식 평가 표 + §3.5 ingredient 평가 표 갱신 + §6.16 Decisions Log 신설, game-designer 2026-05-28 mvp v2.2 trigger, supersedes v1.16) — game-designer가 2026-05-28 mvp-food-selection v2.1 → v2.2 갱신 완료 (F-02 호떡 → 잔치국수 T1 곡물+잡화+어물+청과 4가게 / F-09 김치찌개 → 불고기 T2 정육+청과+잡화 3가게). game-designer hero ingredient 매핑 = F-02 hero 소면 (white wheat thin noodles) + 부 hero 멸치/김/애호박/대파 / F-09 hero 얇은 marbled 소고기 (thin-sliced sirloin fanned) + 부 hero 양파/대파/당근/표고. prompts-library v1.17에서 §5.2 F-02/F-09 본문 전면 교체 + §5.6.2/§5.6.9 ING-02/ING-09 본문 전면 교체 + §0 anchor 표 4 row 갱신 + §6 변경 이력 v1.17 entry + driver script `gen_food_anchors_m1.py` / `gen_ingredient_anchors_m1.py` body inline 갱신 + docstring v1.17 sync 완료. 본 art-anchor-rubric v1.17 = **§5.5.4 음식 평가 표 F-02 row + F-09 row status 갱신** (F-02 Hotteok t1_001 → Janchi-guksu t1_001 mvp v2.2 T1 CW v1.17 reroll pending v9 — 호떡 deprecated 2026-05-30 mvp v2.2 trigger / F-09 Kimchi Jjigae t2_009 → Bulgogi t2_009 mvp v2.2 T2 CW v1.17 reroll pending v9 — 김치찌개 deprecated 2026-05-30 + **F-12 갈비 차별화 CRITICAL**: NO bone-in LA cut + NOT grilled on wire mesh grate + NO large 18-25cm LA strips + NOT separated meat strips). **§3.5 ingredient whole 평가 표 ING-02 row + ING-09 row status 갱신** (ING-02 peanut whole R1 + brown_sugar_whole R2 deprecated → somen_whole pending v3 v1.17 mvp v2.2 — Japanese pink-white decorative band 누수 ~40% / Chinese yellow egg noodles / Italian spaghetti rigid / Korean ramyeon curly yellow risk / ING-09 firm_tofu_whole R1 deprecated → thin_beef_whole pending v3 v1.17 mvp v2.2 trigger — **F-12 갈비 차별화 CRITICAL**: NO bone visible + RAW NOT cooked grilled brown + Japanese wagyu extreme marbling ~40% / cooked brown 누수 ~30% / bacon parallel striped / salami cured / 삼겹살 thick alternating layered risk). **§6.16 Decisions Log 신설** — mvp v2.2 sync trigger 행 + game-designer hero ingredient 매핑 인용 표 (F-02 hero 소면 + 부 hero 멸치/김/애호박/대파 / F-09 hero 얇은 소고기 + 부 hero 양파/대파/당근/표고) + F-02/F-09 음식 anchor 2장 + ING-02/ING-09 ingredient anchor 2장 reroll trigger + **F-12 갈비구이 차별화 CRITICAL 표 (불고기 F-09 ≠ 갈비 F-12)** 7 차별화 축 (meat form / bone / cooking context / sauce/marinade / vegetables / garnish / view angle) + F-12 갈비 차별화 CRITICAL ING-09 ≠ ING-12 마늘 추가 절 + 변경 사유 timeline (mvp v2.1 archive vs mvp v2.2 settle) + **ChatGPT 약점 risk top 7 (v1.17 갱신)** = (1) F-02 잔치국수 Japanese somen 누수 ~50% / (2) F-09 불고기 Japanese sukiyaki raw egg dipping 누수 ~50% / (3) **F-09 불고기 vs F-12 갈비 CRITICAL cross-contamination ~40%** (bone-in LA cut + wire mesh grate + large 18-25cm strips 누수) / (4) ING-02 소면 Japanese pink-white decorative band 누수 ~40% / (5) ING-09 얇은 소고기 Japanese wagyu A5 extreme marbling 누수 ~40% / (6) ING-09 얇은 소고기 cooked brown 누수 ~30% (RAW state CRITICAL) / (7) F-02 잔치국수 Vietnamese pho 누수 ~30% + deprecation 기록 5건 (F-02 호떡 v1.5 R3 / F-09 김치찌개 v1.3 R1 / ING-02 peanut R1 + brown_sugar R2 / ING-09 firm_tofu R1 archive 보존) + main thread 실행 명령 (음식 2장 `py tools/gen_food_anchors_m1.py --only F-02,F-09 --version v9 --model gpt-image-1 --quality medium` 2장 × $0.042 ≈ $0.08, ~30-60초 + ingredient 2장 `py tools/gen_ingredient_anchors_m1.py --only F-02,F-09 --version v3 --model gpt-image-1 --quality medium` 2장 × $0.042 ≈ $0.08, ~30-60초, **총 4장 × $0.042 ≈ $0.17, ~2분**, 출력 `assets-raw/food_anchors_m1/F-02_janchi_guksu_v9.png` + `F-09_bulgogi_v9.png` + `assets-raw/ingredient_anchors_m1/F-02_somen_whole_v3.png` + `F-09_thin_beef_whole_v3.png`) + M1 anchor 22장 + cut anchor 7장 + ingredient whole 10장 (ING-02/ING-09 제외) + reaction 6컷 LOCK/병렬 무영향 확인 (mvp v2.2 sync는 4장만 reroll, 다른 anchor 모두 무변경). 음식 12 평가 표 다른 10 row (F-01/F-03/F-04/F-05/F-06/F-07/F-08/F-10/F-11/F-12 LOCK status) 무변경. ingredient whole 12장 평가 표 다른 10 row (ING-01/ING-03/ING-04/ING-05/ING-06/ING-07/ING-08/ING-10/ING-11/ING-12 status) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. reaction 6컷 평가 (§5.9) 무변경.
- **2026-05-30 v1.16** (M1 후반 art sprint 3번째 — 양친 reaction 6컷 anchor 평가 가이드 §5.9 신설 + G_reaction 5 요소 게이트 + §3.6 reaction 평가 표 신설 + §6.15 Decisions Log 신설, Scene 3 식탁 ★1/★2/★3 gradient, ingredient 12장 sprint와 fully parallel, supersedes v1.15) — M1 후반 art sprint 2번째 (ingredient whole 12장) 진행 중 + art sprint 3번째 (양친 reaction 6컷) 병렬 동시 진입. 친구 가족 단위 (project_adr003 2026-05-23 lock) 어머니 + 아버지 L11 동시 unlock + Scene 3 식탁 reaction context + ADR-005 Total Score gradient (재료 25% × 준비 20% × 방법 20% × 시간 35% → ★1 30%+ / ★2 60%+ / ★3 90%+) + friends-system 호불호 axis (project_adr003 v0.2) trigger로 양친 reaction 6컷 anchor 필요. art-director가 Week 1 commit 7a6cffb base 4장 (`assets-raw/week1-anchors/CH-02_mother.png` / `CH-03_father.png` / `CH-04_mother_star1.png` / `CH-05_father_star3.png`) Read tool 시각 확인 완료 — CH-02_mother base ≈ ★1-★2 경계 (subtle warm smile + 음식 그릇 들고) / CH-03_father base ≈ ★2 경계 (slim smile + thumb-up) / **CH-04_mother_star1 sad teardrop variant 본 sprint 폐기** (ADR-005 ★1 mild positive acceptance ↔ Week 1 sad teardrop 부정 reaction 어긋남, R-01 prompt = subtle warm smile + 정상 open dot eyes로 새로 작성, CH-04 file은 향후 deep negative reaction asset 재활용 가능 보존) / **CH-05_father_star3 settle 형태에 가장 가까움** (R-06 prompt = CH-05 거의 그대로 재현 단 shirt teal-green CH-03 base 정확 매칭 + bust-up framing, CH-05 image를 R-06 generation 시 추가 reference upload 권장). prompts-library v1.16에서 §2.5 STYLE_SUFFIX_REACTION 명시 (bust-up portrait + Cool Sage `#C8D5C0` bg + chibi mascot + Family IP consistency 어머니/아버지 Week 1 base 명세 + EXPRESSION GRADIENT 메타 정의 + sleeping/sad/crying/full body/multiple characters 0건 negative) + §5.7 placeholder → full prompts 확장 (R-01~R-06 6장 full prompt + Week 1 base 시각 확인 결과 표 + ★1/★2/★3 expression gradient 정의 표 + 6 prompt body 핵심 한 줄 요약 + anchor seed 채택 + reference image upload 워크플로 + reroll trigger 9종 + driver script 실행 명령 + ChatGPT 약점 risk top 5) + 새 driver `tools/gen_reaction_anchors_m1.py` 신설 완료. 본 art-anchor-rubric v1.16 = 평가 가이드 신설: **§3.6 reaction 평가 표 신설** (R-01 ~ R-06 6 row × G1/G3/G4/G5/G6/G7/G_new + G_reaction 컬럼 + Week 1 base reference 컬럼 + risk top 항목 명시 + R-02/R-05 anchor seed 라벨). **§5.9 M1 후반 양친 Reaction 6컷 평가 가이드 신설** — §5.9.1 배경 (M1 후반 sprint 2번째 (ingredient)와 병렬 3번째 (reaction) 진입 + Week 1 base 4장 시각 확인 결과 표 + ★1/★2/★3 gradient 정의 + CH-04 sad 폐기 + CH-05 settle 형태) / §5.9.2 **G_reaction 5 요소 점검표 신설** = (1) **CRITICAL — 캐릭터 family IP 식별 명확** (어머니 CH-02 base + 아버지 CH-03 base와 동일 family IP — hair/outfit/face features/chibi mascot proportions/outline 두께/saturation 톤 일치, 6장 contact sheet에서 어머니 3장 + 아버지 3장 각각 같은 family IP 인식) / (2) **CRITICAL — ★1/★2/★3 expression gradient 명확** (3 단계 표정 진화 명확 visible — ★1 subtle / ★2 in-between / ★3 wide open + closed-arc, 어머니 warm motherly amplification / 아버지 reserved breaking into excitement amplification, 외부인 0.5초 안에 gradient 순서 답) / (3) **anchor consistency (Cool Sage bg + cross-asset cluster)** (6장 모두 Cool Sage solid bg + slim outline 2-3px + 음식 12 + cut 7 + ingredient whole 12 = 37-asset Scene 3 cross-asset cluster 합류 인식, 캐릭터 5장 soft mint 누수 0건) / (4) **chibi mascot proportions + bust-up portrait** (chibi 1:1.7 + bust-up 어깨까지만, full body/lower body/legs/feet 0건, multiple characters 결합 0건) / (5) **CRITICAL — sad/sleeping/negative expression 누수 0건 + 한식 family context 유지** (Week 1 CH-04 sad teardrop pattern 누수 0건 / sleeping closed eyes 0건 / crying tears 0건 / Japanese 기모노 / 중국 치파오 / anime girl big sparkly eyes / school uniform / deep dark Cookie Run pink cheek / mortar 절구 0건). **LOCK 조건 = 6/6 anchors × 5 요소 = 30/30 PASS**. **R-02 어머니 ★2 + R-05 아버지 ★2 = anchor seed** (각 캐릭터 base default expression과 가장 가까움 → seed lock 후 ★1/★3 variant generation의 reference image upload 시드, seed FAIL 시 REROLL 우선). 부분 통과 정책 (5 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only R-XX --version v2` reroll / 4 LOCK = CONDITIONAL batch reroll / 3 이하 LOCK = FAIL → pm 에스컬레이션 / R-02 또는 R-05 anchor seed FAIL = REROLL seed 우선 / G_reaction #1 family IP FAIL = Week 1 base reference image upload 사용자 ChatGPT 웹 UI 수동 chain-of-references 워크플로 권장 / G_reaction #2 gradient FAIL = ★1/★2/★3 비교 강제 follow-up / G_reaction #5 sad/sleeping 누수 = "MILD POSITIVE acceptance / HAPPY UPWARD ARC closed-arc / NOT sad NOT crying NOT sleeping" explicit 강제). §5.9.3 reaction 6컷 라운드 예산 (R1 6장 batch `py tools/gen_reaction_anchors_m1.py --model gpt-image-1 --quality medium` 6장 × $0.042 ≈ $0.25, ~2-3분 / R2 follow-up FAIL anchor 집중 `--only R-XX --version v2` / R3 사용자 ChatGPT 웹 UI 수동 reference upload chain-of-references 워크플로 (CH-02 upload + R-02 seed → R-01/R-03 / CH-03 upload + R-05 seed → R-04/R-06, R-06에 CH-05 추가 reference) / R4 재시도 후 FAIL 2+ anchors = pm). §5.9.4 ChatGPT 약점 risk top 5 (**R-01 mother_star1 sad teardrop 누수 ~60% CRITICAL** / R-06 father_star3 sparkle detail 폭주 + double thumb-up 단순화 ~40% / R-03 mother_star3 heart icon 폭주 + closed-arc → sad 잘못 추론 ~35% / R-02/R-05 ★2 in-between collapse ~30% / R-04 father_star1 thumb-up CH-03 base carry over ~25%). §5.9.5 anchor seed 채택 + reference image upload 워크플로 (R-02/R-05 anchor seed → variant reference 시드 / 어머니/아버지 세션 분기 권장 cross-contamination 회피 / R-06에 CH-05 추가 reference upload). **§6.15 Decisions Log 신설** — M1 후반 art sprint 3번째 시작 + ingredient sprint와 병렬 동시 진행 명시 + Week 1 base 4장 시각 확인 결과 표 + ★1/★2/★3 expression gradient 정의 표 + reaction 6컷 trigger 행 + driver script `.replace("%s", STYLE_SUFFIX_REACTION, 1)` 패턴 명시 (gen_food/gen_ingredient에서 fix 됐던 `body의 % character ↔ Python %s formatting` ValueError 회피) + R-02/R-05 anchor seed 명시 + Week 1 CH-04 sad variant 폐기/CH-05 settle 형태 명시 + main thread 실행 명령 (`py tools/gen_reaction_anchors_m1.py --model gpt-image-1 --quality medium`, 6장 × $0.042 ≈ $0.25, ~2-3분, 출력 경로 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v1.png`) + M1 anchor 22장 + cut anchor 7장 + ingredient whole 12장 병렬 무영향 확인 (reaction 신규 asset class `assets-raw/reaction_anchors_m1/` 디렉터리 신설). 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경. ingredient whole 12장 평가 (§5.8) 무변경.
- **2026-05-30 v1.15** (M1 후반 art sprint 2번째 — 음식 12 × hero ingredient whole anchor 12장 평가 가이드 §5.8 신설 + G_ingredient_whole 5 요소 게이트 + §3.5 ingredient whole 평가 표 신설 + §6.14 Decisions Log 신설, ADR-005 Stage 2A "before"-cut pair, supersedes v1.14) — M1 후반 art sprint 1번째 (cut anchor 7장 LOCK 완료) 후 2번째 sprint 진입. ADR-005 Stage 2A 재료 준비 미니게임은 음식별 hero ingredient를 적절한 cut style로 자르는 형태 → 음식 12 × hero ingredient whole(자르기 전) state asset이 필요 ("before" pair, cut된 결과 "after"는 CUT-01~06 anchor 재사용). prompts-library v1.15에서 §5.5.0 음식↔cut 매핑 표 + §5.6 ingredient whole 12장 prompt set + 새 driver `tools/gen_ingredient_anchors_m1.py` 신설 완료. 본 art-anchor-rubric v1.15 = 평가 가이드 신설: **§3.5 ingredient whole 평가 표 신설** (ING-01 ~ ING-12 12 row × G1/G3/G4/G5/G6/G7/G_new + G_ingredient_whole 컬럼 + risk top 항목 명시). **§5.8 M1 후반 Ingredient Whole 12장 평가 가이드 신설** — §5.8.1 배경 (M1 후반 1번째 cut anchor 7장 LOCK 후 2번째 sprint 진입 + ADR-005 Stage 2A "before"-cut pair + 12장 매핑 표) / §5.8.2 **G_ingredient_whole 5 요소 점검표 신설** = (1) **CRITICAL — hero ingredient 시각 식별 명확** (대파/견과류/단무지/어묵/김치/모짜렐라/daepa/당근/firm tofu/soft tofu/마늘 12 ingredient 시그니처 모양+색+크기, cross-ingredient 디스트랙터 페어 정확 구분: 단무지↔daikon, 어묵↔naruto, spring onion↔daepa, firm tofu↔soft tofu, mozzarella↔cheddar, 마늘↔양파) / (2) **CRITICAL — WHOLE/UNCUT state 명확** (single intact whole ingredient + cut pieces scattered 0건: minced bits/julienne strips/diagonal oval slices/round discs/cubes 모두 0건, ING-06 cheese / ING-10 soft tofu도 broken pieces 0건) / (3) **CRITICAL — Cool Sage `#C8D5C0` bg + 도마 + 칼 LEFT side static 통일 (cross-asset 일관성)** (cut anchor 7장 + ingredient whole 12장 = 19장 cross-asset same 도마 + same 칼 silhouette + same Cool Sage bg + same slim outline 2-3px, CUT-00 anchor seed reference upload 의무) / (4) **modern saturated 톤 + 단순화** (채도 80-90% / Royal Match aesthetic / heavy texture 0건 / 베이지·scrapbook·Cookie Run 2021 톤 0건 / 1-2 subtle shading lines + ONE specular highlight per element) / (5) **CRITICAL — cross-cultural 누수 0건** (ingredient별 특화 negative: ING-03 banana/daikon 0건 / ING-04 naruto/chikuwa 0건 / ING-07 spring onion 변종 0건 / ING-06 cheddar/두부 0건 / ING-12 whole bulb/양파 0건 + cross-anchor 공통: Japanese kitchen knife santoku/deba 0건 / Chinese cleaver 0건 / Western chef knife 0건 / mortar 절구 0건 / 인간 hand 0건). **LOCK 조건 = 12/12 anchors × 5 요소 = 60/60 PASS** (ING-11 carrot은 F-08 anchor 재사용 결정 시 archive — game-designer foods CSV `prep_*` 후속 검증에 따라 11/12 × 5 = 55/55 조정). 부분 통과 정책 (11 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only F-XX --version v2` reroll / 9-10 LOCK + 2-3 anchors FAIL = CONDITIONAL batch reroll / 8 이하 LOCK = FAIL → pm 에스컬레이션 / G_ing #1 hero 식별 FAIL = ingredient 명세 강화 또는 hero ingredient swap 검토 / G_ing #2 WHOLE state FAIL = ready-to-cut state explicit 강조 / G_ing #3 cross-asset 일관성 FAIL = CUT-00 reference upload 재시도). §5.8.3 ingredient whole 12장 라운드 예산 (R1 12장 batch `py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium` 12장 × $0.042 ≈ $0.50, ~4-5분, R2 follow-up `--only F-XX --version v2` FAIL anchor 집중). §5.8.4 ChatGPT 약점 risk top 5 sync (ING-03 단무지 banana/daikon ~50% / ING-04 어묵 naruto/chikuwa ~50% / ING-07 daepa F-01 spring onion 변종 ~40% / ING-06 모짜렐라 cheddar/두부 ~40% / ING-12 마늘 whole bulb/양파 ~35%). §5.8.5 **game-designer 후속 confirm 사안** — 음식 12 × hero ingredient × cut style 매핑 검증 (foods CSV `prep_*` 컬럼 lock 후 일부 reroll 가능, 검증 사안 12행 표는 prompts-library v1.15 §5.6.16 참조). **§6.14 Decisions Log 신설** — M1 후반 art sprint 2번째 시작 + ADR-005 Stage 2A "before"-cut pair + ingredient whole 12장 trigger 행 + 12장 hero ingredient + pair cut style 매핑 표 + cut style 분포 통계 (CUT-01 다지기 3 / CUT-02 채썰기 3 / CUT-03 어슷썰기 2 / **CUT-04 통썰기 0 — game-designer 검증 필요** / CUT-05 송송 1 / CUT-06 깍둑 1 / no cut 2) + cross-asset 일관성 (cut 7 + ingredient whole 12 = 19장 cross-asset CUT-00 anchor seed 공유) + M1 anchor 22장 + cut anchor 7장 LOCK 무영향 확인 + main thread 실행 명령 (`py tools/gen_ingredient_anchors_m1.py --model gpt-image-1 --quality medium`, 12장 × $0.042 ≈ $0.50, ~4-5분, 출력 경로 `assets-raw/ingredient_anchors_m1/<food_id>_<ingredient_name>_v1.png`). 음식 12 평가 (§5.5) 무변경. 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경. cut anchor 7장 평가 (§5.7) 무변경.
- **2026-05-29 v1.14** (M1 후반 sprint 진입 — 칼/도마 base + cut style 6종 cut anchor 7장 평가 가이드 §5.7 신설 + G_cut 5 요소 게이트 + §3.4 cut anchor 평가 표 신설 + §6.13 Decisions Log 신설, ADR-005 Stage 2A rhythm tap prerequisite, supersedes v1.13) — M1 anchor 22/22 LOCK 완료 (음식 12 + 환경 5 v4 image edit + 캐릭터 5, commit dfb141e) 후 M1 후반 art sprint 진입. **ADR-005 Stage 2A 재료 준비 = rhythm tap + Knife indicator** prerequisite로 칼/도마 base + cut style 6종 anchor 7장이 필요. prompts-library v1.14에서 §2.5 STYLE_SUFFIX_CUT 신설 + §5.5 placeholder → full prompts 확장 (cutting_board base + cut_style_mince/julienne/diagonal/whole/sliced_rounds/cube 7장 full prompt) + §0 anchor 표 cut anchor 7장 row 추가 + 새 driver `tools/gen_cut_anchors_m1.py` 신설 완료. 본 art-anchor-rubric v1.14 = 평가 가이드 신설: **§3.4 cut anchor 평가 표 신설** (CUT-00 ~ CUT-06 7 row × G1/G3/G4/G5/G6/G7/G_new + G_cut 컬럼). **§5.7 M1 후반 Cut Anchor 7장 평가 가이드 신설** — §5.7.1 배경 (M1 anchor 22/22 LOCK 완료 + ADR-005 Stage 2A trigger + cut style 6종 시그니처 재료 매핑 + BPM 명세) / §5.7.2 **G_cut 5 요소 점검표 신설** = (1) **CRITICAL — cut style 시각 식별 명확** (시그니처 cut shape 외부인 0.5초 안에 식별: mince fine bits 1-3mm / julienne thin matchstick 4-6cm × 2-3mm / diagonal elongated oval / whole perfect round disc 3cm + 5색 cross-section / sliced_rounds small thin round 1-1.5cm × 1-3mm + scallion ring / cube 3D cube 2-2.5cm + top/side face shading) / (2) **hero ingredient 매칭** (mince → 마늘 yellowish-white / julienne → 당근 orange / diagonal → 어묵 light golden-brown + 대파 white-to-green / whole → 김밥 5색 cross-section / sliced_rounds → 대파 bright green + ring / cube → 두부 흰) / (3) **CRITICAL — Cool Sage `#C8D5C0` bg + 도마/칼 통일 (cross-asset 일관성)** (7장 contact sheet에서 같은 도마 + 같은 칼 silhouette + 같은 Cool Sage bg + 같은 slim outline 2-3px 인식, 음식 12 + 환경 5 cross-asset one-game-world identity) / (4) **modern saturated 톤** (채도 80-90% / 베이지·scrapbook·Cookie Run 2021 톤 0건) / (5) **CRITICAL — cutting RESULT state + cross-cultural negative** (cut 결과 상태이지 cutting action mid-motion 아님 / Japanese kitchen knife santoku/deba 0건 + kanji engraving 0건 / Chinese cleaver 0건 / Western chef knife 0건 / mortar 절구 0건 / CUT-04 통썰기 Japanese maki sushi 누수 0건 / CUT-06 깍둑썰기 Chinese mapo tofu 누수 0건). **LOCK 조건 = 7/7 anchors × 5 요소 = 35/35 PASS**. **CUT-00 anchor seed FAIL 시 전체 FAIL** (cross-cut 일관성 무너짐). 부분 통과 정책 (6 LOCK + 1 anchor 1-2 요소 FAIL = CONDITIONAL `--only CUT-XX --version v2` reroll / 4 anchors 이하 LOCK = FAIL / G_cut #1 cut style 시각 식별 FAIL = cut shape 명세 강화 또는 ingredient swap 검토 / G_cut #3 cross-asset 일관성 FAIL = CUT-00 reference upload 재시도). §5.7.3 cut anchor 7장 라운드 예산 (R1 7장 batch `py tools/gen_cut_anchors_m1.py --model gpt-image-1 --quality medium` 7장 × $0.042 ≈ $0.29, ~3-4분, R2 follow-up FAIL anchor 집중). §5.7.4 ChatGPT 약점 risk top 3 (CUT-04 통썰기 Japanese maki sushi ~50% / CUT-06 깍둑썰기 Chinese mapo tofu ~40% / CUT-00~06 Japanese kitchen knife santoku/deba ~30%). **§6.13 Decisions Log 신설** — M1 후반 art sprint 시작 + ADR-005 Stage 2A prerequisite + cut anchor 7장 trigger 행 + cut anchor 7장 시그니처 매핑 + BPM 명세 표 (CUT-00 N/A / CUT-01 mince 140 / CUT-02 julienne 110 / CUT-03 diagonal 100 / CUT-04 whole 70 / CUT-05 sliced_rounds 130 / CUT-06 cube 90) + M1 anchor 22장 LOCK 무영향 확인 (cut anchor 7장 신규 asset class 추가, 음식/환경/캐릭터 anchor 재실행 없음) + main thread 실행 명령 (`py tools/gen_cut_anchors_m1.py --model gpt-image-1 --quality medium`, 출력 경로 `assets-raw/cut_anchors_m1/<name>_v1.png`). 음식 12 평가 (§5.5) 무변경 (F-12 v1.10 R7 LOCK candidate 유지). 환경 5 v4 평가 (§5.6) 무변경. 캐릭터 5 평가 (§3.1) 무변경.
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
