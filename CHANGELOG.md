# CHANGELOG / Working Memory

> 이 파일은 K-Food Master 프로젝트의 **작업 로그 + working memory**.
> 새 작업/결정/이슈가 발생할 때마다 최상단에 항목 추가.
> 날짜는 절대 표기 (`YYYY-MM-DD`), 필요 시 작성자 명시.

---

## 형식
```
## [YYYY-MM-DD] 짧은 제목
- **무엇**: 한 줄 요약
- **왜**: 의사결정 배경 / 트리거
- **결과/다음 단계**: 산출물, 후속 작업
```

---

## [2026-06-15] Gimbap Roll 이중 이미지 제거(연속 변형) + 재료 얇게 (godot-dev)
- **무엇**: F5 교정 — Roll 드래그 시 **flat 김/밥(gimbap_mat base)이 아래 그대로 남고 그 위에 별도 "말린 통"(진행 sprite)이 따로 떠 보이던 이중 이미지를 제거**. roll 시작(roundness>=0.16) 순간 gimbap_mat base를 재료 overlay와 **함께 cross-fade out** → roll 중에는 자기완결적 진행 sprite(flat이 통에 먹히는 한 장) 1개만 보인다(같은 footprint, flat이 그 자체로 말리는 연속 변형). + 재료 strip 세로 두께 **얇게**(rice_h*0.25→0.18, 약 28%). **scoring/two-finger/4-factor/consequence contract 전부 무변경 — 시각/전환/두께만.**
- **왜**: 사용자 F5(Roll Step 4/7) 핵심 불만 — "말기를 하니까 김과 밥(flat)은 아래 그대로 있는데 그 위에 별도의 말리는 그림(말린 통)이 따로 떠서 보임. 지금 있는 김/밥/대나무발이 그 자체로 말리는 것으로 보여줘." 원인 = gimbap_mat base(_bamboo_mat)가 roll 내내 full alpha로 깔린 채, 자체적으로 [flat bed + 말리는 통]을 다 담은 진행 sprite가 그 위에 겹쳐 그려져 flat bed 2겹 + 통 1개가 동시에 보임.
- **결과/다음 단계**:
  - **roll_module** `_TopDownRollStage._fade_flat_fillings`: 기존엔 `_flat_fillings`(재료 overlay)만 fade. 이제 **`_bamboo_mat`(gimbap_mat flat base)도 같은 0.18s 동안 cross-fade out** → base alpha→0 / 진행 sprite alpha→1이 같은 footprint(stage box 중심)에서 동시 전환. 진행 sprite(roll_edge_lift~compression)가 자체 flat bed를 포함하므로 base를 지우면 이중 이미지 0. 완성은 result variant(roll_finished*)가 시각 인계(무변경).
  - **roll_module** `_build_flat_fillings`: 재료 strip 두께 `strip_h = rice_h*0.25 → 0.18`(약 28% 얇게), `stride = strip_h*0.66 → 0.70`(비례 다발 납작·고르게). strip_w/band crop/AtlasTexture 텍스처 무변경(음식 텍스처 유지). set_roll/finalize_roll/_apply_roll_visual/scoring 무변경.
  - **검증**: full regression **497 PASS / 0 FAIL**(9 scene, gimbap_vs_smoke 33 PASS 포함, 변화 0). **실제 F5 opengl3 캡처** `assets-raw/_screenshots/gimbap_rollfix/`(roll_flat / roll_mid / roll_finished). **roll_mid(roundness 0.45) = 자기완결적 진행 sprite 1장만, flat base 사라짐 → 이중 이미지 0 자체 확인**. roll_flat=얇아진 재료. 신규 dev shot: `scripts/dev/shot_gimbap_rollfix.gd` + `scenes/shot_gimbap_rollfix.tscn` + `tools/run_gimbap_rollfix_shots.ps1`.

## [2026-06-15] Gimbap 재료 교정 — Roll flat_fillings painterly 텍스처(ColorRect 폐기) + 재료 밥보다 길게 (godot-dev)
- **무엇**: F5 교정 — 김밥 속(filling)이 "색깔 있는 나무 통나무(솔리드 색 바)"로 보이던 문제를 (1) **Roll의 flat_fillings ColorRect/Panel → Build와 동일한 filling_{id}_painterly band crop(AtlasTexture)로 교체**(음식 텍스처: 당근채/계란지단/시금치잎/단무지가 보이게), (2) Build+Roll **재료 strip 두께 키워**(STRIP_VIS_H 50→70) 텍스처가 또렷이 읽히게, (3) Build+Roll **재료를 밥보다 좌우로 길게**(양끝이 밥/김 위로 삐져나오되 김 안쪽). **scoring/4-factor/arrange/consequence contract 전부 무변경 — 텍스처/길이/시각 layer만.**
- **왜**: 사용자 F5 "김/밥/대나무발은 굿. 올라간 재료가 색깔 있는 나무 통나무로 보임 + 재료가 밥보다 좌우로 조금 길게 나와야 함." Build는 이미 painterly band를 썼으나 50px로 짜부라져 텍스처 안 읽힘 + Roll은 순수 ColorRect 솔리드 색 바(나무 통나무의 실체).
- **결과/다음 단계**:
  - **gimbap_build_module**: `STRIP_W`를 placement-zone 비례(RICE_BOX_W*0.92≈497)에서 **gimbap_mat 실측 밥/김 폭 기반 669**(흰 밥 frac 0.132..0.844=641px / 김 안쪽 0.102..0.876=697px의 평균)로 — 밥보다 길고 김 안쪽. `STRIP_VIS_H` 50→70(텍스처 읽힘), `STRIP_STRIDE` 34→46(두께 비례 overlap 유지, 다발 cohesion). `BUNDLE_TARGET_Y` 0.18→0.10*RICE_BOX_H(두꺼워진 다발이 밥 region 안에). drop_x/RICE_BOX_W/RICE_CENTER_X/_is_over_rice/_even_quality/get_arrange_* 전부 무변경.
  - **roll_module** `_TopDownRollStage`: `_build_flat_fillings`의 Panel+StyleBoxFlat 솔리드 색 바 → 신규 `_make_flat_filling_node`(filling_{id}_painterly band AtlasTexture STRETCH_SCALE, 미존재 시 둥근 색 Panel fallback). strip_w = 실측 밥/김 평균(밥보다 길게), strip_h = rice_h*0.25(두툼). FILL_BAND/FILL_SRC_W/FILL_*_FRAC_W 상수 추가(Build FILLING_BAND 동일 측정값). set_roll/finalize_roll/scoring 무변경.
  - **검증**: full regression **497 PASS / 0 FAIL**(9 scene, gimbap_vs_smoke 33 PASS 포함, 변화 0). **실제 F5 opengl3 캡처** `assets-raw/_screenshots/gimbap_filltex/`(build_filled / roll_initial). build_filled placed=4 STRIP_W=668.7 STRIP_VIS_H=70 balance=1.00. zoom 확인: 당근채/시금치잎/계란지단/단무지 음식 텍스처 + 양끝 김 위로 삐져나옴(김 밖 X) + Build=Roll. 신규 dev shot: `scripts/dev/shot_gimbap_filltex.gd` + `scenes/shot_gimbap_filltex.tscn` + `tools/run_gimbap_filltex_shots.ps1`.

## [2026-06-15] Gimbap Build/Roll base = 사용자 제작 gimbap_mat.png 한 장 (타일 합성 폐기) (godot-dev)
- **무엇**: Build/Roll setup base를 **사용자가 직접 만든 `gimbap_mat.png`(1151×716) 한 장**으로 배선. 김발(얇은 테두리)+김(dark)+고운 밥알 full bed가 전부 한 장에 담긴 완벽한 setup(이미 똑바로 정렬 + recline baked). 이전 **Godot 타일 합성**(bamboo_mat_large + seaweed_sheet_rect + rice_bed_full 레이어 쌓기), **RICE_CROP/AtlasTexture core crop**, **RECLINE_SQUASH(세로 squash)** 전부 폐기. **scoring/4-factor/arrange/consequence contract 전부 무변경 — 시각/배치 layer만.**
- **왜**: 사용자가 직접 완벽한 setup 이미지를 제작 제공 — "이게 Build setup의 정답, 그대로 base로 써라". 김발/김/밥을 코드가 합성·통제할 필요가 사라짐(기하가 전부 이미지에 baked). rotation 0(이미 똑바름), scale (1,1)(recline은 이미지에 baked — 코드 squash 불필요).
- **결과/다음 단계**:
  - **gimbap_build_module**: `_build_mat`+`_build_seaweed_rice`+`_build_far_seal_margin` 3함수 → 단일 `_build_base`로 교체. `gimbap_mat` 한 장을 `MAT_BOX`(900×560, 1151:716 비율) KEEP_ASPECT_CENTERED TextureRect로 깔고, mat_holder·stage_group 둘 다 `rotation=0` / `scale=(1,1)`. 흰 밥 region 좌표(측정 frac: cx 0.48 / cy 0.455 / w 0.60 / h 0.50)를 `RICE_*` 상수로 재정의 → 재료 strip이 밥 region lower-third에 안착. `drop_x`는 밥 region 중심(`RICE_CENTER_X`) 상대값으로 기록 → `_even_quality`/`get_arrange_balance`/`get_arrange_bias_dir` scoring/consequence 시그니처 무변경. SEAWEED_*/RICE_CROP/RICE_CORE_FALLBACK/RECLINE_SQUASH 상수 제거.
  - **roll_module**: `_TopDownRollStage` Layer 0 base를 `bamboo_mat_large` → `gimbap_mat`(KEEP_ASPECT)로 교체 + 초기 flat state(roundness 0) sprite 비우고 `gimbap_mat` base가 그대로 보이게 + Build와 동일한 색 strip 다발 overlay(`_build_flat_fillings`, 말기 시작 roundness>=0.16에 fade out). → **Build 최종 = Roll 초기**. set_roll/finalize_roll/scoring 무변경(말리는 edge_lift~finished sequence 그대로).
  - **ArtRegistry**: PAINTERLY_KEYS에 `gimbap_mat` 등록. `.ctex` 컴파일 확인.
  - **검증**: full regression **497 PASS / 0 FAIL**(9 scene, gimbap_vs_smoke 33 PASS·arrange→prep·get_arrange_* getter 포함). **실제 F5 opengl3 캡처** `assets-raw/_screenshots/gimbap_usermat/`(build_base / build_filled / roll_initial). build_filled placed=4 balance=1.00. 신규 dev shot: `scripts/dev/shot_gimbap_usermat.gd` + `scenes/shot_gimbap_usermat.tscn` + `tools/run_gimbap_usermat_shots.ps1`.

## [2026-06-14] Gimbap Build setup 축정렬(axis-aligned) 합성 — AI base 옆 회전 폐기 (godot-dev)
- **무엇**: Build 김밥 setup을 **Godot 축정렬 직사각 layer로 합성**(김발/김/밥 각각 axis-aligned TextureRect로 쌓음) + 앞으로 뉘임은 회전 아닌 **세로 squash**(recline) + **꽉 찬 밥 bed + 밥알 작게**(얇은 RICE_CROP 폐기). Build→Roll 연속성(roll_flat_setup도 축정렬로 교체). **AI gimbap_setup_base 이미지 미사용**(매번 옆 회전). **scoring/4-factor/arrange/consequence contract 전부 무변경 — 시각/배치 layer만.**
- **왜**: 사용자 핵심 불만 "옆으로 돌리지 말라는데 왜 자꾸 돌려?" — gpt-image-1이 setup 한 장 이미지를 매번 살짝 옆으로 회전(diamond/oblique)시켜 프롬프트로 강제 불가(모델 한계). 직사각형 TextureRect는 rotation/skew를 코드가 0으로 통제 → 옆으로 돌아갈 수가 없다(기하를 Godot이 통제).
- **결과/다음 단계**:
  - **gimbap_build_module**: mat holder + stage_group 둘 다 `rotation=0` / `scale=(1.0, RECLINE_SQUASH=0.84)`(세로 squash만, skew 0) → near edge 화면 하단 평행, 좌우 edge 수직, 앞으로 recline. 김발=`bamboo_mat_large`(김보다 사방 얇게=thin border), 김=`seaweed_sheet_rect` dark core, 밥=신규 `rice_bed_full.png`(꽉 찬 full bed, 작은 밥알) STRETCH_SCALE. 얇은 `RICE_CROP`(820×395) 폐기 → `RICE_BOX` 716×380(김 ~88% 덮음). drag 좌표 변환 `_to_stage_local`로 squash(scale.y) 보정. `_placed_local` scoring / `get_arrange_balance`·`get_arrange_bias_dir` consequence 시그니처 무변경.
  - **신규 자산** `rice_bed_full.png`(1536×768): rice_painterly 클린 흰 core를 작은 grain으로 tile-fill(어두운 테두리/노란 배경 0). ArtRegistry PAINTERLY_KEYS 등록.
  - **roll_flat_setup.png 교체**: 기존 AI oblique(diamond 회전) → 축정렬 composite(seaweed rect + rice bed + 가로 색 strip, near edge 하단 평행)로 교체 → Roll 초기 setup도 옆 회전 0, Build과 연속. roll_module 코드/scoring 무변경(자산만 swap).
  - **검증**: full regression **441 PASS / 0 FAIL**(9 scene, gimbap_vs_smoke 33 PASS 포함 — scoring/consequence 무변경 확인). **실제 F5 opengl3 캡처** `assets-raw/_screenshots/gimbap_aligned/`(build_aligned / build_filled / roll_initial_continuity). 자체 확인: stage_group·mat_holder `rot=0.0000 scale=(1.000,0.840)`, build_filled placed=4 balance=1.00. 신규 dev shot: `scripts/dev/shot_gimbap_aligned.gd` + `scenes/shot_gimbap_aligned.tscn` + `tools/run_gimbap_aligned_shots.ps1`.

## [2026-06-14] Gimbap Build=Roll setup + 김발(bamboo mat) 보이게 + Build→Roll 연속성 (godot-dev)
- **무엇**: Build 화면을 Roll setup처럼(재료가 밥 위 색색 다발) 교정 + Build·Roll 둘 다 **김발(bamboo rolling mat)을 김보다 크게 깔아 보이게** + Build→Roll 시각 연속성. instruction "tight bundle"→"Place the fillings across the lower third of the rice". **scoring/4-factor/arrange/consequence contract 전부 무변경 — 시각/배치 layer만.**
- **왜**: F5 비교 거부 — Build이 prototype 같음(재료가 floating thin strip + 점선 guide 비침), Roll setup이 시각 목표인데 **둘 다 김발이 안 보임**. 다른 dish 무영향.
- **결과/다음 단계**:
  - **roll_module** `_TopDownRollStage._build_painterly_sprites`: 진행 painterly sprite **밑에** `bamboo_mat_large`(평면 top-down)를 box*`MAT_OVERSCALE`(1.20)로 깔아 김 사방으로 bamboo frame 노출. 진행/입력/scoring 전부 무변경(김발 추가만). painterly 미존재 시 procedural mat과 double 방지 위해 sprite 숨김.
  - **gimbap_build_module**: 김발 mat을 김(720×432)보다 `MAT_MARGIN_X/Y`(120/96)만큼 사방 크게(900→960×624) + bamboo brightness boost + 김 밑 contact shadow(김이 mat 위에 얹힌 느낌). 재료 strip `STRIP_VIS_H`60 / `STRIP_STRIDE`42(overlap)로 **빈틈 0 색색 다발**(분리 thin strip 제거). 첫 재료 안착 시 점선 guide line **fade out**(다발 사이로 비치던 prototype 느낌 제거). far seal "seal" 점선 dash 제거(맨 김 sheen만). drag/snap/`_placed_local` scoring·`get_arrange_balance`/`get_arrange_bias_dir` consequence 시그니처 무변경.
  - **instruction**: header/hint "tight bundle" 표현 제거 → "Place the fillings across the lower third of the rice" + drag/placed hint를 lower-third 언어로.
  - **연속성**: Build 최종(mat+김+밥+재료 다발)과 Roll 초기(roll_flat_setup+김발) 모두 같은 위치(center 540,940)·같은 layer 구성으로 이어진다.
  - **검증**: full regression **521 PASS / 0 FAIL**(9 scene, gimbap_vs_smoke 33 PASS 포함 — scoring/consequence 무변경 확인). **실제 F5 4컷** `assets-raw/_screenshots/gimbap_buildroll/`(build_initial / build_placed / roll_initial / roll_edge_lift) opengl3 캡처. 신규 dev shot: `scripts/dev/shot_gimbap_buildroll.gd` + `scenes/shot_gimbap_buildroll.tscn` + `tools/run_gimbap_buildroll_shots.ps1`.

## [2026-06-13] Gimbap procedural→painterly swap + Choose-Your-Chef 6 preset (godot-dev)
- **무엇**: 김밥(t1_004) 5 조리 stage의 **procedural vector geometry → high-angle painterly sprite** 전면 교체 (시각 layer만) + Chef **Min/Ari** preset 배선(4→6). **입력/scoring(4-factor)/save/consequence contract 전부 무변경 — 순수 시각 swap.**
- **왜**: `docs/design/gimbap-visual-quality-rebuild-v1.md` 승인 (§3 high-angle 70-80° painterly 해소안, §5 swap 매핑, §6 roll 6-state, §7 slice collapse, §8 real tray). 현 조리 화면이 "vector placeholder prototype"으로 거부됨.
- **결과/다음 단계**:
  - **asset**: painterly 25장(`assets-raw/gimbap_painterly_m2`) → `godot-project/art/sprites/painterly/` import. chef Min/Ari ×4 emotion(8장) → `protagonist/`.
  - **ArtRegistry**: `PAINTERLY_KEYS` + `get_painterly()`/`gimbap_painterly_filling()` helper. PROTAGONIST_PRESETS/_PREFIX에 min/ari 추가. save_manager `CHEF_PRESETS`에 min/ari (backward-compat).
  - **roll_module** `_TopDownRollStage`: procedural capsule `_draw` → painterly **6-state cross-fade** (flat_setup→edge_lift→first_fold→curling→compression→finished) + result 분기(finished/loose/burst). tilt = sprite 미세 회전/offset만(mat twist 금지). `_draw`는 painterly 미존재 시 fallback. **two-finger 입력/_compute_roll_score(40/25/20/15)/consequence 무변경.**
  - **julienne_module**: procedural board `Panel` → `board_topdown_painterly`, Polygon2D 칼 → `knife_topdown_painterly`, 당근 → `carrot_on_board` painterly, 완성 채 더미 → `carrot_strips_good`/`_bad` painterly. **rhythm/scoring/prep_quality 무변경, HUD vector 유지.**
  - **gimbap_build_module**: mat/김/밥/filling 4 → `mat_painterly`/`seaweed_painterly`/`rice_painterly`/`filling_{id}_painterly`. **layer order/snap/arrange consequence 무변경.**
  - **gimbap_slice_module**: procedural capsule roll → `gimbap_roll_for_slice`, 칼 → `knife_topdown_painterly`, cut 조각 → `gimbap_piece_good` / **bad roll(roll_quality 낮음→wobble≥0.32) → `gimbap_piece_collapse`(filling 쏟아짐 시각, 텍스트 아님)**. **slice_quality/window(§8.4) 무변경.**
  - **plate_module**: procedural box tray(box corner 폐기) → `wooden_tray_topdown` real 나무 tray + slot silhouette 유지. 조각 good/broken(slice 나쁨 → collapse). **drag/snap/plate_quality 무변경.**
  - **gender_select**: Choose Your Chef 4→**6 카드**(2×3) — +Min(Creative & balanced)/+Ari(Cheerful & curious). save backward-compat.
  - **검증**: 전 모듈 painterly 미존재 시 기존 procedural _draw로 graceful fallback(무해). regression **441 PASS / 0 FAIL**(scoring/save/consequence 보존, protagonist_smoke 6 preset 갱신). 실제 F5 9컷 → `assets-raw/_screenshots/gimbap_painterly/`(julienne/build/roll_flat·curling·finished/slice·collapse/plate/chef_select_6).

## [2026-06-10] Gimbap Vertical Slice — Pass B: cross-stage consequence chain (godot-dev)
- **무엇**: 김밥(t1_004) vertical slice **Pass B** — Pass A의 stub stage를 실제 wiring해 **"내가 먼저 한 행동이 나중 결과를 바꾼다"** consequence chain 6개를 구현 + Plating drag-arrange 격상 + Guest 5-quality reaction. **economy/save/4-factor scoring contract 전부 무변경, 신규 module 0, 신규 system 최소(transient quality-state carry만).**
- **왜**: `docs/design/gimbap-vertical-slice-v1.md` §8 — 5-stage loop의 진짜 검증 대상은 cross-stage 인과 체감. Pass A가 carry만 한 quality-state(`vs_quality_state`)를 module이 실제 소비.
- **결과/다음 단계**:
  - **consequence chain 6개 wiring** (모두 기존 입력/공식 무변경 — sweet zone/window/tilt만 quality-state로 보정):
    - §8.1 shopping→arrange: runner `_available_filling_slots()` — `collected_fillings` 중 filling(carrot/egg/spinach/danmuji/ham) 수만큼만 arrange slot 생성(누락 재료 = 빈 김밥). arrange가 `vs_available_slots` 소비.
    - §8.2 prep→roll: roll_module `_consume_vs_consequence` — `prep_quality` → sweet zone 폭 `lerp(0.62,1.0)`. 나쁜 strip → 좁은 zone → 같은 push가 burst/loose. `_compute_roll_score` + `_finalize_roll` burst/loose 임계가 scale 반응.
    - §8.3 arrange→roll: arrange `get_arrange_balance()/get_arrange_bias_dir()`(filled slot 좌우 대칭) → runner가 quality_state에 기록 → roll `_vs_tilt_offset`(균등 push여도 비뚤어짐).
    - §8.4 roll→slice: slice_module `_consume_vs_consequence` — `roll_quality` → cut window `lerp(0.6,1.0)`(angle/speed tolerance 좁힘) + `_spawn_piece` wobble(조각 제각각). loose roll → 같은 cut이 빡빡 판정.
    - §8.5 slice→plating: plate `_start_vs_plating`이 `slice_quality` → 조각 단면 wobble/orientation.
    - §8.6 plate→guest: runner `_pick_reaction_line`이 5 quality 종합 → 가장 약/강 stage 직접 지목 bubble.
  - **Plating 격상 (drag-arrange, design §5.3)**: plate_module에 vs-plating MODE 추가(`vs_quality_state` 있을 때만 — 일반 dish는 기존 3지선다 tier tap 100% 보존). 김밥 6조각을 wooden_tray target row에 **drag로 배치** → `plate_quality = placement(spacing/중앙안착) 0.6 + orientation(slice 기반) 0.4`. plate_quality=display bonus(★ 무영향).
  - **Guest reaction (5 quality bubble)**: guest avatar(neutral sprite) + 짧은 reaction("Wow, the roll is so clean!" / "The filling is falling out a bit." / "Some pieces are thicker than others." / "It looks a little messy." / "The strips are a bit chunky.") — 약점 우선 지목 후 강점 칭찬.
  - **bad julienne asset import**: `carrot_julienne_bad.png` → `godot-project/art/sprites/ingredient/` 임포트 + ArtRegistry INGREDIENT_KEYS 등록. julienne bad swap이 procedural fallback 대신 실제 chunky asset 사용.
  - **검증**: 실제 F5 opengl3 540x960 screenshot `assets-raw/_screenshots/gimbap_vs_b/` 12컷 (arrange / roll_mid / roll_perfect / roll_bad / slice_clean / slice_wobble / plating / guest_reaction + **consequence 비교쌍** roll_cmp_prep_good vs bad[같은 push 1.04, prep만 다름 → tight vs squeeze-out] / slice_cmp_roll_good vs bad[같은 cut, roll만 다름 → clean row vs wobble]). 신규 unit smoke `gimbap_vs_smoke.tscn` 14 PASS(consequence 수치 + 기본 무변경 + plate gate). **Regression 전 suite 0 FAIL / 416 inline PASS**(CTA guest_v2 19 PASS 유지, t1_004 integration plating==1.0 무변경). consequence 수치 증명: roll 같은 push 1.04 → prep0.95=93.9 vs prep0.15=85.5 / slice 같은 cut → roll0.95=89.5 vs roll0.15=77.6.
  - **shot harness**: `shot_gimbap_vs_b.tscn` + `run_gimbap_vs_b_shots.ps1`. 일반 runner(vs_quality_state 미전달)는 전 module이 default scale 1.0 → 기존 12 dish 난이도 100% 보존.

---

## [2026-06-09] Gimbap Vertical Slice — Pass A: runner 골격 + Shopping + Julienne (godot-dev)
- **무엇**: 김밥(t1_004) 1종 5-stage vertical slice의 **Pass A** 구현 — 오케스트레이션 runner 골격(5-stage chain + shared quality-state) + Stage 1 Shopping 미니게임 + Stage 2 Julienne(angle+rhythm+spacing+thickness) prep. 나머지 3 stage(Arrange+Roll / Slice+Plate / Guest)는 **stub**(기존 module 호출 + consequence hook 예약). **economy/save/기존 4-factor scoring contract 전부 무변경, 신규 system 최소, 신규 module 0(ADR-011 정합 — Shopping=stage, Julienne=Slice 확장).**
- **왜**: `docs/design/gimbap-vertical-slice-v1.md`(game-designer 승인) 5-stage loop 비전을 김밥 1종으로 vertical slice 검증. content volume 아닌 gameplay quality + cross-stage consequence chain 검증.
- **결과/다음 단계**:
  - **`gimbap_slice_runner.gd`** (CookingModuleRunner 상속 — scoring/save/economy/result contract 100% 보존): STEP_PLAN 7-step(shopping → julienne → arrange → roll → slice → plate → guest)을 `_run_next_module` override로 dispatch. **shared `quality_state` dict**{shopping/prep/roll/slice/plate_quality 각 [0,1]} = consequence chain backbone(transient runtime, save 무관). step-aware 4-factor 매핑(shopping/julienne/arrange→prep, roll→cook, slice→timing, plate→plating — design §9.3 첫/둘째 Slice 구분 flag 해소).
  - **`shopping_stage.gd`** (Stage 1, 신규 module 아님 — 독립 Control + `stage_completed(quality, fillings)` signal): 한식 시장(MarketBG 톤, e-commerce UI 금지) 좌판에 정답 6(seaweed/rice/danmuji/carrot/egg/spinach) + 함정 4(ramyeon/gochujang/tofu/tteok) 셔플 진열. `shopping_quality = clamp01(correct/N − 0.15×wrong − key누락 0.20)` (cooking-mechanics §2.5 보존). 핵심 재료(seaweed/rice/danmuji) 누락 = `!` 빈 슬롯 + §8.1 consequence hook(`collected_fillings` carry). freshness/budget/inventory 제외(MVP LOCK).
  - **`julienne_module.gd`** (Stage 2, SliceModule **상속** — drag-knife engine 재사용): cut timestamp/x 배열 누적 → 변동계수(CV) 기반 **rhythm/spacing consistency** 2축 신규 + angle(부모 cut score) + thickness(rhythm·spacing 유도) = `prep_quality` 4축 가중평균(각 25%). live "Even/Uneven" feedback. **visual 분기 검증**: perfect(prep≥0.80)=고른 얇은 strip + sparkle / bad=chunky uneven(carrot_julienne_bad asset, 미존재 시 ArtRegistry fallback + procedural chunky overlay). `module_completed(0~100)` contract 무변경.
  - **검증**: 실제 F5 opengl3 540x960 screenshot `assets-raw/_screenshots/gimbap_vs_a/` (shopping / julienne_perfect[prep=0.99] / julienne_bad[prep=0.18] / runner_flow[Step 1/7 Market]). Regression **전 suite 351 PASS / 0 FAIL**(기존 scoring/save/t1_004 sequence 무변경 — parent runner integration smoke 포함). `--check-only` 3 신규 script parse 0 error. shot harness: `shot_gimbap_vs_a.tscn` + `run_gimbap_vs_a_shots.ps1`.
  - **Pass B 인계**: stub 3 stage(arrange/roll/slice/plate 기존 module 호출 자리) + consequence hook 예약 — runner가 `params["vs_quality_state"]`/`vs_collected_fillings`를 module에 carry(현재 미소비, 기존 난이도 보존). Pass B = prep→roll sweet zone 보정 / roll→slice window 보정 / Arrange filling balance / Plating drag 격상 / Guest reaction 심화.

---

## [2026-06-08] Player-Name Personalization — 주인공 셰프 이름 직접 입력 (godot-dev)
- **무엇**: 주인공 host 라벨을 고정명("Chef Mina"/"Chef Junho")에서 **플레이어 직접 입력명**으로 전환. gender select 직후 1회 이름 입력 화면 추가. **scoring/CSV/economy/progression 전부 무변경, save는 `player_name` 1필드만 추가(backward-compatible), 7 guest 시스템/이름 무변경 — visual + 1 field.**
- **왜**: gender_select 카드의 "Chef Mina/Junho" 고정명이 **guest 7명 이름(Mina/Junho 등)과 충돌**. result에서 guest Junho reaction인데 플레이어도 "Chef Junho"면 혼란. 사용자 결정 = 주인공 이름 플레이어 입력.
- **결과/다음 단계**:
  - **흐름**: gender_select → **name_entry**(신규) → menu (최초 1회). menu_select `_ready` 게이트가 `has_chosen_chef()` && `has_player_name()` 둘 다 충족해야 메뉴 렌더 — 성별만 있고 이름 없으면 name_entry로 redirect(legacy save 안전망).
  - **name_entry.gd/.tscn**: 선택한 셰프(neutral) 미리보기 + `LineEdit`(가상 키보드 `virtual_keyboard_enabled=true`, `max_length=12`, clear 버튼) + "Start Cooking" CTA. 빈/공백 입력 → fallback "My Chef" 저장(재진입 방지). "change later in Settings" 톤 일관.
  - **SaveManager**: `player_name`(기본 "") + `player_name()`/`player_name_display()`(fallback "My Chef")/`has_player_name()`/`set_player_name()`/`sanitize_player_name()`(static: trim + 내부 공백 squash + 12자 clamp). 기존 save는 `_merge()`로 backward-compatible(필드 없으면 "" → name_entry 1회).
  - **host 라벨 반영**: 메뉴 헤더 badge 캡션("Your Chef" 고정 → 입력명) / result host("You cooked!" → "{입력명} cooked this!") / cooking cook host("Chef" → 입력명). gender_select 카드 라벨은 guest명 제거 → 성별 설명("Female Chef / 여자 셰프", "Male Chef / 남자 셰프"). **guest 7명 이름 무변경**.
  - **버그 fix**: `menu_select._build_warm_dish_placeholder` — `Polygon2D`(Node2D)에 없는 `mouse_filter` 할당 제거(food art 미존재 dish 카드에서 SCRIPT ERROR 발생하던 latent 버그).
  - **검증**: 실제 F5 opengl3 1080x1920 screenshot `assets-raw/_screenshots/player_name/` (gender_select / name_entry / name_entry_typed / menu_with_name / result_with_name — 전부 입력명 반영 + script error 0). Regression **전 suite 0 FAIL**(`save_migration_test`에 player_name backward-compat/trim/blank-reject/clamp assert 추가, `protagonist_smoke`에 player_name 필드 14 assert 추가 — 둘 다 economy 무변경 확인). shot harness: `shot_player_name.tscn` + `run_player_name_shots.ps1`.

---

## [2026-06-08] Player-Chef Integration — 주인공 셰프 통합 (성별 선택 + host 배치) (godot-dev)
- **무엇**: 플레이어 본인 아바타 "셰프"를 게임에 통합. 성별 선택(여/남) 1회 + 화면별 host 배치. **scoring/CSV/progression/economy 전부 무변경, save는 `player_chef_gender` 1필드만 추가(backward-compatible), 7 guest 시스템 무변경 — visual + 1 setting field.**
- **왜**: 손님(먹는 쪽, 7 guest avatar)은 있으나 "요리하는 나" 주인공이 부재. 플레이어가 선택하는 본인 셰프 아바타로 정체성/몰입 부여. 손님-셰프 역할 분리(먹는 쪽 vs 요리하는 쪽).
- **결과/다음 단계**:
  - **8장 asset import**: `assets-raw/protagonist_pack_m2` → `art/sprites/protagonist/chef_{f|m}_{neutral|cheer|think|cook}.png` (transparent rembg cutout, 1536×1024 landscape, north star 톤 — 여=크림 자켓+테라코타 앞치마+헤어밴드 / 남=navy 자켓+sand 앞치마+반다나). 8 `.import` 생성 + headless reimport로 ctex.
  - **ArtRegistry**: `get_protagonist(gender, emotion)` 헬퍼 + `PROTAGONIST_EMOTIONS`/`PROTAGONIST_GENDERS` 상수. gender 미지정→"f", emotion 미존재→neutral graceful fallback, `ResourceLoader.exists()` 가드.
  - **SaveManager**: `player_chef_gender` 필드(기본 "") + `player_chef_gender()`/`has_chosen_chef()`/`set_player_chef_gender()` (invalid 값 무시). 기존 save는 `_merge()`로 backward-compatible(필드 없으면 "" 유지) — migration 불필요.
  - **gender_select.gd/.tscn**: 최초 1회 성별 선택 화면(여/남 2 카드, 실제 chef 미리보기 + 정체성 라벨 + Choose CTA). menu_select가 `has_chosen_chef()` 게이트로 미선택 시 redirect.
  - **host 배치(용도별 emotion)**: 메뉴 헤더=neutral("Your Chef" 코너 badge) / result=성공 시 cheer·보통 neutral("You cooked!" 상단 좌측) / cooking 요청=think("Hmm, how to cook this...") / cooking 진행=cook(우하단 — 손님 mini 좌하단과 역할 분리). 전부 world BG 위 layer.
  - **렌더 버그 회피**: 원형 프레임 chef는 `frame.clip_contents=true` + 자식 TextureRect `FULL_RECT anchor + STRETCH_KEEP_ASPECT_COVERED` 조합이어야 렌더(수동 size+COVERED는 Godot 4.6.3에서 미렌더 — debug로 확정, 4개 host 전부 anchor 방식).
  - **검증**: 실제 F5 opengl3 1080x1920 screenshot `assets-raw/_screenshots/protagonist/` (gender_select / menu_host_f / menu_host_m / result_host_cheer / cooking_request_think / cooking_cook_host). Regression **337 PASS / 0 FAIL** (신규 `protagonist_smoke` 30 PASS + `save_migration_test`에 chef 필드 7 assert 추가 — backward-compat·legacy 보존·set/reload round-trip·invalid reject 전부 PASS). shot harness: `shot_protagonist.tscn` + `run_protagonist_shots.ps1`.

---

## [2026-06-08] P0 Screen World-Integration — flat 베이지 void를 한식 주방 world로 (godot-dev)
- **무엇**: Menu / Guest / Result / Cooking 4개 화면의 **배경 레이어만** 재배치. flat 베이지 procedural 배경(`MarketBG` / `CookingBackground`)을 **기존 PASS 환경 art**(`art/bg/l1~l5`)로 교체해 모든 화면을 따뜻한 한식 주방 world 위에 integrate. **economy/save/scoring/CSV/progression 전부 무변경, 신규 art 0(기존 환경 재사용).**
- **왜**: North Star audit 결론 — asset은 북극성급 PASS이나 screen 조립 레이어가 격차. 좋은 asset을 flat 베이지 void 위에 product-catalog처럼 배치 → 첫인상 "prototype UI". 최단 수렴 = 재생성 아닌 재배치(기존 환경 BG를 화면 뒤에 깔기).
- **결과/다음 단계**:
  - **`kitchen_background.gd` 확장**: (1) `MARKET_TO_ENV` static 매핑 + `env_key_for_market()` static helper — levels.csv의 실제 market 값(home/noryangjin/market/gwangjang)을 env art key로 정규화(noryangjin→L3 market, gwangjang→L5 prestige). 4개 화면이 같은 source of truth 공유. (2) `fill_screen` 모드 — art를 화면 전체 cover(중앙 0.35 정렬), 상단 wall-연장 gradient 생략 → beige void 박멸. (3) `scrim_alpha` — 카드/텍스트 가독성용 얇은 warm 막.
  - **menu_select.gd**: procedural `MarketBG` → `KitchenBackground(fill_screen, scrim 0.14)`, player level market로 매핑. "Recipe art coming soon" raw 라벨 → `_build_warm_dish_placeholder()`(받침+무쇠솥+나무뚜껑+김 procedural 일러스트, "simmering soon").
  - **result_screen_v2.gd**: procedural `CookingBackground` → `KitchenBackground(fill_screen, scrim 0.16)`, 음식 unlock level market로 매핑. "K" chef-hat+이니셜 placeholder → `_build_warm_dish_card()`(menu와 동일 솥 motif). food art 없는 3 stew(kimchi/doenjang/maeuntang `ready=0`)만 placeholder, 나머지는 실제 음식 art swap.
  - **cooking_module_runner.gd + base_module.gd**: `KitchenBackground.fill_screen=true`로 전환 — 기존 width-cover 하단정렬은 상단 절반이 beige wall-연장 void였음. 이제 환경 world가 화면을 가득 채우고 action zone이 그 안에 얹힘. `_env_key_for_market` / `_env_key_for_level`을 공유 helper로 위임. module은 runner의 `skip_bg=true`로 BG 1장만(중복 방지).
  - **guest_select.gd**: 흐름 일관성 위해 동일 적용(`fill_screen, scrim 0.16`) — menu→guest→cooking→result 전 여정이 같은 warm world 공유.
  - **환경 BG 매핑**: home(L1 home kitchen) / noryangjin·market(L3 traditional market) / gwangjang(L5 prestige). dish의 unlock_level이 native market을 결정 → 라면(Lv1)=L1 home, 비빔밥·김치찌개(Lv4)=L3 market.
  - **검증**: 실제 F5 opengl3 1080x1920 screenshot `assets-raw/_screenshots/world_integration/` (menu/result/cooking/guest before·after + cooking_home_l1 + cooking_step 1~5). Regression **338 PASS / 0 FAIL** (6 smoke scene scene-exit=0). shot harness: `shot_world_integration.tscn` + `run_world_integration_shots.ps1`.

## [2026-06-07] Gimbap Roll 레이아웃 교정 — long-strip 자산으로 실제 김밥 마는 setup (godot-dev)
- **무엇**: Roll module의 시각 composition만 교정. long-strip wide 자산으로 실제 김밥 마는 setup 표현. **gameplay/scoring/CSV 전부 무변경** (`_compute_roll_score` / gesture handlers / MODULE_TO_FACTOR("roll"→prep) 동일).
- **왜**: 기존 roll이 김밥 만드는 것처럼 안 보임 — rice sheet + 중앙 tiny short fillings + bamboo mat 분리. 실제 김밥: 김발 받침 → 김 → 밥 → 속재료를 김 폭 가로질러 긴 strip → 아래→위 말기.
- **결과/다음 단계**:
  - **자산 import (7 long-strip wide)**: `assets-raw/roll_assets_m2/`의 `bamboo_mat_large / seaweed_sheet_rect / rice_layer_flat_rect / carrot_strip_long / egg_strip_long / green_strip_long / beef_strip_long` (각 1536x1024 transparent) → `godot-project/art/sprites/roll/` clean naming + Godot .import.
  - **`art_registry.gd ROLL_KEYS` 확장** — 7 신규 key 추가. `get_roll_asset(key)` 무변경(디렉터리 lookup). 구 square 자산 graceful fallback 유지.
  - **`roll_module.gd` LOCKED layer order 재구현** (z bottom→top): (1) bamboo_mat_large base 받침(action zone 중앙, 860w wide) → (2) seaweed_sheet_rect 김 stacked(720w, mat이 받침 frame) → (3) rice_layer_flat_rect 밥(612w, 김 top edge 살짝 보이게) → (4) filling 4 strip(carrot/egg/green/beef)을 김 폭 75%(540px, 70~85% 안) continuous 가로 band로 lower-middle third에 세로 stacking → (5) roll direction guide(`_RollGuideDraw` 곡선 베지어 + arrowhead, 아래→위) + "Roll from the bottom edge" text → (6) 완성 김밥(content_only)은 SUCCESS에서만(HR1). 자산 측정(solid bar y 0.24~0.43h / x 0.76~0.89w)으로 box·row_gap 산출해 4 strip 모두 distinct full-width로 가시화. 완성 swap box를 460² square로 키워 finished roll이 dominant.
  - **검증**: 실제 F5 screenshot `assets-raw/_screenshots/roll_layout_fix/{state1_setup, state3_rolling, state4_finished}.png` (opengl3 540x960 viewport, `shot_roll_layout_fix.tscn` + `run_roll_layout_shots.ps1`). Regression **352 PASS / 0 FAIL** (roll instantiate + `_compute_roll_score` 도메인 under=29.3/ideal=96.0/over=22.2/burst=35.0 사전값 동일).

## [2026-06-06] 5-Layer Composition LAYOUT 긴급 수정 — 7-zone 시스템 + scale clamp + L1 환경 배경 (godot-dev)
- **무엇**: standalone layered asset architecture는 유지(baked revert X), runtime layout/scaling/framing만 refactor. 신규 system 없음, gameplay/scoring/CSV 무변경.
- **왜**: 5-layer 화면이 (1) asset scale 틀림 (2) 화면 밖 crop (3) tool/ingredient 거대 (4) layer 랜덤 overlap (5) framing 미설계 (6) 큰 beige void (7) guest mini 작음 — 의도된 cooking scene으로 안 보임. 실제 F5 screenshot으로 확인된 문제.
- **결과/다음 단계**:
  - **신설 `scripts/cooking_modules/composition.gd`** (CookingComposition) — 7 zone const(1080x1920: Instruction 15% / Action 55% / Control / Feedback 20% / Safe / GuestMini) + `clamp_scale_to_zone` / `fit_asset_to_rect` / `rect_in_zone` / `rect_inside` / `rect_at_center` + per-layer scale clamp(ingredient 45/35, tool 40/28, vessel 65/42, dish hero 70/45) + `debug_zone_overlay` toggle(default OFF).
  - **신설 `scripts/ui/kitchen_background.gd`** — environment_pack_m2 L1 home kitchen art를 화면에 깔아 beige void 제거(L1~L5 level 매핑). `art/bg/`에 L1~L5 import. runner + base_module가 사용(runner는 chrome 가림 방지 위해 module skip_bg).
  - **8 module composition preset 적용** — slice/arrange/stir/flip/timing/season/roll/plate 모두 zone+clamp+framing으로 5-layer mount. vessel 중앙, food는 vessel 안쪽(rect_inside)에만, tool visible 대각선 대기.
  - **근본 버그 수정**: `TextureRect.texture = load()` 후 `.size` 설정 시 1024px 최소크기가 박혀 asset이 화면 전체를 덮던 버그(stir 거대 kimchi 더미 / F5 now_cooking_banner thumb가 화면 덮음)를 8 module + now_cooking_banner.gd에서 `expand_mode`를 texture 할당 전에 설정해 수정. `cooking_fx.attach_dish_shadow`를 hard ColorRect→rounded Panel(soft ellipse)로 교체(grey bar 제거). `sparkle_particle.gd` class_name 오타(SparkleParticle55→SparkleParticle) 수정.
  - **검증**: 실제 F5 screenshot `assets-raw/_screenshots/layout_fix/{after,before}/` (8 module isolated + 4 F5 runner 경로). Regression 350 PASS / 0 FAIL (cooking_modules 166 + runner_integration 6 + action_first_w1 43 + w2 62 + guest_v2 19 + result_v2 50 + save_migration 4).

## [2026-06-05] Polish Phase 3-design — P5 Learning content + P6 Food Critic flow + 사안#1 Casual mode spec (ADR-013, game-designer)
- **무엇**: ADR-013 Polish Phase의 game-designer 위임 3건. **NO new gameplay systems** (content + flow + input-variant design only). scoring/progression/sequence 전부 무변경.
- **왜**: ADR-013 §3(사안 #1 Casual) / §5 brief Pillar 1+2(P5 Learning) / §5 사안 #3(P6 Critic). 사용자 mandate "Presentation > Features / Emotion > Numbers".
- **결과/다음 단계**:
  - **P5 Learning Layer V1** — 신설 `data/learning_facts.csv` (12 음식 × 4 fact = Food/Ingredient/Cooking Tip/Culture, 각 ≤ 60 char, 영어 primary + 한글 음식명 sub, US 8~60 친화). 신설 `docs/systems/learning-layer-v1.md` v1.0 (flavor card non-blocking UX: result reveal 시 2.5s auto-dismiss + ⓘ flip-card, 회차별 fact rotation, retention 정당화). 8 핵심(라면/김밥/비빔밥/김치찌개/갈비/잡채/떡볶이/순두부) + 잔여 4(해물파전/콘도그/잔치국수/김치볶음밥) full coverage.
  - **P6 Food Critic System** — 신설 `docs/systems/food-critic-v1.md` v1.0. **mastery = Recipe XP Lv 7 도달**(recipe_xp.csv 기존 milestone 재활용, ★3 N회 카운터 신규 storage 회피). **Golden Spoon Inspector**(기존 goldspoon guest, reward_bonus 2.00, fictional brand — Michelin 금지). 5-step flow(mastery→appears→special eval→badge→one-time reward). special evaluation = 기존 ADR-009 compat 공식 + critic_pass(★3 AND compat≥80) 게이트(scoring 무영향). one-time reward 5종(friendship +3 / reputation coin / encyclopedia unlock / Korean food fact / badge) 전부 기존 자산. **no-farming guard**(critic_pending/critic_unlocked 2 dict). 신설 `data/critic_badges.csv` (12 음식 badge). 신규 currency/mechanic 0.
  - **사안#1 Casual Mode** — 신설 `docs/systems/cooking-modes-v1.md` v1.0. ADR-012 gesture = **Immersive(opt-in)** 재라벨, **Casual(default)** = 8 module 단순화 variant 표(slice tap-hold / arrange tap-to-place / stir 짧은 swipe N회 / flip single tap / timing single tap zone / season 1-tap auto-pour / roll tap-hold / plate tap select). one-handed 친화. **scoring 무변경 audit**(두 mode 동일 output signal → 동일 4-factor → 동일 ★, 입력 난이도만 완화). mode toggle = settings + Remote Config `cooking.mode.default=casual`. input-layer variant only (TouchGestureRecognizer 재활용), 신규 system 아님 = ADR-012 amendment.
  - **cross-ref 갱신**: `cooking-modules-v1.md` v1.1→v1.2 (Casual/Immersive 정합 + §8 관련문서). `cooking-mechanics.md` v0.7 상단에 Polish Phase 3 신규 문서 cross-ref 추가.
  - **무변경 보증**: 4-factor(25/20/20/35) / ★ 임계(30/60/90) / perfect_width 12 row / `module_completed(score)` signal / dish_modules.csv sequence / Skip auto-perfect 0.9 전부 무변경.
  - **godot-dev 후속**: P5 LearningDB loader + flavor card scene(non-blocking CanvasLayer). P6 mastery hook(Lv 7) + critic_pending/unlocked guard + CriticDB loader. Casual 8 module 입력 핸들러 + settings toggle. ui-designer: P5 flavor card layout(result-screen-v2-layout) / P6 critic appears prompt + badge reveal / Casual settings toggle UI + onboarding opt-in.

## [2026-06-05] Master Product Brief LOCKED 박제 + Polish Phase 방향 정합 (ADR-013, pm)
- **무엇**: 사용자 LOCKED Master Product Brief를 canonical 박제 + 현 프로젝트 상태 정합. **방향 전환** = feature/system 구축 종료 → **production-quality presentation 우선** (Presentation > Features / Emotion > Numbers / Polish > Complexity). **신규 gameplay system 0건** — ADR-009~012 전부 유지, presentation/emotion/polish layer만 얹음.
- **왜**: 사용자 mandate "Do not add new systems until production quality is achieved." Product vision = "Korean Food Discovery Game" (NOT Cooking Fever clone). NOT prioritize = new modes/currencies/ads/IAP/analytics/remote config/monetization/feature expansion.
- **결과/다음 단계**:
  - **신설 `docs/product-brief-locked.md` v1.0** — canonical 브리프 (5 Core Pillars / 6 Immediate Priorities / Food Critic + Haptic + Art Direction LOCK / Environment L1~L5 / success criteria + 정합 사안 5건 해소).
  - **신설 `docs/roadmap-polish-phase.md` v1.0** — 6 priority 상세 done/todo + owner + 의존성 + ROI sequencing.
  - **`docs/decisions.md` ADR-013 신설** (Accepted) — Polish Phase Direction. Casual(default)/Immersive(opt-in) mode 정합 + Result emotion-first 순서 + Critic=Golden Spoon + Art LOCK + 6 priority lock. ADR-009~012 무변경 audit.
  - **`docs/GDD.md` v2.2 → v2.3** — §1.1 Vision 신설 + §10.1.P Polish Phase Roadmap 신설 (Art Direction = Cooking Diary/Animal Restaurant/Travel Town, NOT Royal Match).
  - **6 priority audit**: P1 ~85% / P2 ~70% / P3 ~50% / P4 ~30% / P5 ~0% / P6 ~20%. P1-P3 이미 상당 완료, **P4(result reorder) / P5(learning) / P6(critic flow)가 실질 신규 todo**.
  - **정합 사안 5건 해소**: ① ADR-012 gesture = Immersive opt-in 재라벨링, Casual tap default variant 추가(scoring 무변경) ② Result 역순 → emotion-first 재배치(데이터 무변경) ③ goldspoon="Golden Spoon Inspector" 이미 존재 → mastery wire ④ BG-01~05=storefront → 신규 L1~L5 cooking 환경 art ⑤ done audit = 재작업 최소.
  - **ROI 권고 next**: P4 Result reorder 최우선(데이터 무변경 + Pillar 4 직결) → P5 Learning → P6 Critic. P2/P3 art는 art-style lock(R-A14) 후.
  - **위임 plan**: game-designer(casual variant spec / P5 fact content / P6 critic flow) / ui-designer(P4 reorder layout / P5 non-blocking UX) / godot-dev(P4 impl / casual input / P5·P6 wire / env swap) / art-director(P2 avatar+emotion / P3 환경 5종 / P6 badge, art-style lock 후).

## [2026-06-05] Action-First Cooking W2 — stir/arrange/roll/flip input redesign → 8 module 전체 완성 (ADR-012, godot-dev)
- **무엇**: ADR-012 input-layer redesign Sprint M3 W2. W1(slice/timing/season)에 이어 나머지 4 module(stir/arrange/roll/flip)을 추상 ActionPuck tap → 실제 조리 동작 gesture로 교체. **이로써 8 module 전체(slice/timing/season W1 + stir/arrange/roll/flip W2 + plate 기존 drag) = 8/8 action-first 완성.** scoring / sequence / progression / 4-factor / `module_completed(score)` signal contract 전부 무변경 — 입력 gesture만 교체.
- **왜**: 사용자 verbatim "I rolled gimbap NOT I held a button / I stirred NOT I tapped / I flipped NOT I tapped a beat / I arranged NOT I auto-placed." game-designer ADR-012 lock `docs/systems/action-first-cooking-v1.md`.
- **결과**:
  - **수정 GDScript 4 (input gesture만 교체, W1 TouchGestureRecognizer 재사용)**:
    - `stir_module.gd`: ActionPuck STIR rhythm-tap 폐기 → **continuous circular swipe**. drag_updated raw stream을 stir 중심 기준 누적 각도(라디안) 적분 = 회전 수. 재료 토큰 orbit churn + 양념색 spread + 윤기 sheen. 3 states: 안 섞임(원 부족)/균일(적정 turns+속도)/뭉개짐(과속). variant: wok(빠른 작은 원 김치볶음밥)/bibim(느린 큰 원 비빔밥)/toss(좌우 잡채). **score = 회전 수 × 각속도 band 일관성 → accuracy(cook) [0,100] (§6.1).**
    - `arrange_module.gd`: tap-ingredient/tap-slot + AUTO skip 폐기 → **press-drag-release settle**. 재료를 집어(press) 손가락 따라 drag → 가장 가까운 미충족 슬롯 magnet glow → release 시 magnet 반경 안이면 snap settle(BACK ease 바운스), 정확=색채움+녹색보더, 오답=비뚤(회전)+빨강보더, 슬롯 밖=홈 복귀 retry. 5색 띠(김밥) / 6색 방사형(비빔밥). **score = correct/total × 100 → accuracy_prep, 기존 tap-match와 1:1 동일.**
    - `roll_module.gd`: ActionPuck HOLD timer 폐기 → **forward drag bamboo mat**. ★ 김발(roll.png LOCK)을 앞으로(위로) 미는 forward drag = roll progress(drag distance/MAT_TRAVEL), 김밥 hero가 점진적으로 round화(scale.x↓)+재료 빨려듦, release 시 sweet zone 근접도 = shape quality. 3 states: 덜 말림/단단한 원통/터짐(drag 과속=avg_speed cap). **score = roll 완성도 + release timing → accuracy(prep) [0,100].**
    - `flip_module.gd`: ActionPuck FLIP single-window tap 폐기 → **directional flick**. drag_released의 velocity vector(avg_speed→공중 회전 수, direction→방향 정확도). 음식이 flick 방향으로 공중 arc 회전(Tween position arc + rotation) → 착지 후 texture flip_v(구워진 뒷면 tint). 3 states: 반뒤집(flick 약)/한 바퀴(적정 velocity)/과회전(flick 과다). variant: pajeon(swipe-up)/corndog(회전)/galbi(좌우). **score = 회전 수(1바퀴 근접) + 방향 정확도 → accuracy(cook) [0,100].**
  - **runner**: `cooking_module_runner.gd` `_build_module_params` stir/flip 분기를 variant param(음식별 wok/bibim/toss, pajeon/corndog/galbi) + target_turns로 교체. legacy tap_count/bpm/window_* param은 모듈이 무시 — 무변경 안전. MODULE_TO_FACTOR / sequence / 가중치 전부 무변경.
  - **신규 test**: `scripts/dev/action_first_w2_smoke.gd` + scene — 62 assertion: 4 module instantiate+start / module_completed [0,100] 단일 emit + clamp passthrough + >100 clamp + re-entrancy guard / 내부 score 함수 도메인+단조성(stir under<ideal, over-fast 페널티 / roll under<ideal, burst cap / flip half<clean>over, dir 정확) / gesture quality 변환(flip speed→turns 단조, ideal~1.0바퀴, swipe-up dir_acc) / MODULE_TO_FACTOR 무변경(stir→cook, arrange→prep, roll→prep, flip→cook) / runner factor bucket 정규화 [0,1].
  - **신규 capture**: `scripts/dev/shot_action_first_w2.gd` + scene — 4 module GIF frame sequence(stir 7 / arrange 6 / roll 7 / flip 7) → `assets-raw/_screenshots/action_first_w2/{stir,arrange,roll,flip}/`. W1 shot 패턴 응용(실 module instantiate → _finished freeze → stager가 _apply_churn/_apply_roll_visual/_settle_into_slot/회전 단계 직접 세팅).
  - **신규 art 0건**: LOCK 재활용(stirfry / panfry / roll=bamboo_mat tool / ingredient cut / food sprite / steam VFX) + procedural(주걱 / 김발 strip fallback / 재료 토큰 / magnet glow / 공중 arc·churn·roll Tween).
  - **regression**: cooking_modules_smoke 166 + result_v2 50 + guest_v2 19 + save_migration 4 + integration 36 + action_first_w1 43 + **action_first_w2 62 = 380/380 PASS / 0 FAIL.** scoring 도메인 [0,100] + signal contract + MODULE_TO_FACTOR 동일 검증 완료.
  - **남은 polish**: 레거시 `shot_module_gif_frames.gd`(ActionPuck 기반 구 8-module GIF stager)는 W2로 8 module 전체가 gesture화되며 obsolete — retire 후보. ActionPuck 자체는 plate-pick/AUTO 외 cooking module에서 미사용(slice/timing/season/stir/arrange/roll/flip 전부 TouchGestureRecognizer). flip arc anim은 W1 동결 stager에서 한 바퀴만 시각화(과회전 시각은 score만 반영) — polish 시 turns>1.5 추가 회전 anim.

## [2026-06-05] Action-First Cooking W1 — slice/timing/season input redesign (ADR-012, godot-dev)
- **무엇**: ADR-012 input-layer redesign Sprint M3 W1. 추상 button/puck tap → 실제 조리 동작 gesture. 3 hero module (slice / timing / season)만 이번 sprint. **scoring / sequence / progression / 4-factor / `module_completed(score)` signal contract 전부 무변경 — 입력 gesture만 교체.**
- **왜**: 사용자 verbatim "Do not design minigames. Design cooking actions." slice = drag knife("I cut carrots" NOT "I tapped a beat"), timing = heat dial("I controlled the heat" NOT "I stopped a meter"), season = tilt bottle("I added seasoning" NOT "I pressed ADD"). game-designer lock `docs/systems/action-first-cooking-v1.md` v1.0.
- **결과**:
  - **신규 GDScript 1 (공통 유틸)**: `scripts/cooking_modules/touch_gesture.gd` (`TouchGestureRecognizer`) — drag tracking (start/move/release + velocity + direction + distance + straightness), vertical drag, tilt angle, continuous path sampling. 8 module 공유 primitive. signal: `drag_started` / `drag_updated(pos, velocity)` / `drag_released(info)` / `tilt_changed(angle, hold)`. 점수 무관 — raw 동작 품질 지표만 제공.
  - **수정 GDScript 3 (input gesture만 교체)**:
    - `slice_module.gd`: ActionPuck TAP rhythm 폐기 → vertical drag knife. 손가락 따라 procedural 칼(knife.png LOCK 미발급 → Polygon2D blade+handle) 내려옴 → 재료 hitbox 가로지름 = 1 cut → whole sprite fade + cut overlay reveal + 조각 누적. N cuts(tap_count) 반복. cut style(다지기/채썰기/어슷썰기) param → 목표 drag 방향·속도 band. **score = cut 위치정확도 + drag 속도band 일관성 종합 평균 → accuracy_prep [0,1]×100 (§6.1 매핑).**
    - `timing_module.gd`: STOP-meter perfect tap 폐기 → vertical drag heat dial. 세로 다이얼 drag → procedural 불꽃 intensity + bubble 강도 + overflow risk 게이지(불 세면 국물 차오름) 실시간. ideal heat zone 유지 비율(zone-hold ratio) 누적 → 4-tier(1.0/0.6/0.2/0.0)×100. perfect_at→zone 중심, perfect_width→zone 폭(갈비 0.10 등 음식별 12 row 무변경). cook window 후 auto-finalize.
    - `season_module.gd`: ADD button 폐기 → tilt + hold. Mode A(default 11종): procedural 양념병 drag tilt → 입자 낙하(고춧가루/간장/참기름 style별) + 음식 표면 양념 코팅 tint. 충분히 부으면 완료, **score=90 (기존 auto-pour 90.0 그대로, balance 무변경)**. Mode B(불고기 marinade): tilt-and-massage 연속 drag → 비트 근처 마사지로 tap 판정, **score=tap 평균(기존 marinade 계산 무변경)**.
  - **신규 test**: `scripts/dev/action_first_w1_smoke.gd` + scene — 43 assertion: instantiate+start / module_completed [0,100] 도메인 / 단일 emit / clamp passthrough / re-entrancy guard / MODULE_TO_FACTOR 무변경(slice→prep, timing→timing, season→season) / TouchGestureRecognizer primitive / slice·timing 내부 score [0,100] / runner factor bucket 정규화 [0,1].
  - **신규 capture**: `scripts/dev/shot_action_first_w1.gd` + scene — 3 module GIF frame sequence(slice 8 / timing 8 / season 7) → `assets-raw/_screenshots/action_first_w1/`. slice(칼 내려옴→재료 갈라짐→조각 누적) / timing(불 약→ideal simmer→overflow burnt + 불꽃/dial/bubble/overflow bar) / season(병 tilt→입자 낙하→음식 코팅).
  - **신규 art 0건**: LOCK 재활용(cutting_board / ingredient whole+cut / boil·grill·deepfry tool / marinate bowl / steam VFX) + procedural 3건(칼 / 불꽃 2겹 / 양념병).
  - **regression**: cooking_modules_smoke 166 + result_v2 50 + guest_v2 19 + save_migration 4 + integration 36 + **action_first_w1 43 = 318/318 PASS / 0 FAIL.** scoring 도메인 [0,100] + signal contract 동일 검증 완료.
  - **나머지 5 module 미변경**: arrange/stir/flip/roll/plate 기존 ActionPuck 유지(점진 마이그레이션, 다음 sprint W2~W4). ADR-012 §9 우선순위 — W2 timing 정밀+cut style 6종, W3 stir(continuous swipe), W4 arrange+roll.

## [2026-06-05] D1+D2+D3 Premium Polish Pass — Result Hero + Action Puck + Cooking BG (godot-dev)
- **무엇**: Result Screen v2 production polish (D1) + 8 cooking module unified ActionPuck system (D2) + shared CookingBackground / steam VFX / dish shadow (D3). gameplay/scoring/progression 절대 무변경 — visual only.
- **왜**: 사용자 피드백 critical issue 3건 (placeholder oval, NEW RECORD ribbon overlap, ASCII stars) + 5건 (rectangular orange TAP pads inconsistent, "floating dish in beige void" 느낌, awning bleeds into cooking/result). premium mobile game tier 도달 목표.
- **결과**:
  - **신규 GDScript 3**: `scripts/ui/action_puck.gd` (5-state circular puck), `scripts/ui/cooking_background.gd` (3-band procedural kitchen surface), `scripts/ui/cooking_fx.gd` (steam loop + dish shadow helpers)
  - **신규 PackedScene 2**: `scenes/ui/action_puck.tscn`, `scenes/ui/cooking_background.tscn`
  - **수정 GDScript 11**: `scripts/gameplay/result_screen_v2.gd` (D1 dish hero + sprite stars + NEW RECORD above + emotion hero mode), `scripts/ui/components/emotion_reaction.gd` (set_hero_mode API: avatar 220→320, bubble width+height, font 30→34), `scripts/gameplay/cooking_module_runner.gd` (MarketBG awning → CookingBackground), `scripts/cooking_modules/base_module.gd` (shared helpers _attach_cooking_bg / _make_action_puck / _attach_dish_shadow / _attach_steam), 8 module 전부 (slice/arrange/stir/flip/timing/season/roll/plate) rectangular pads → ActionPuck swap
  - **D1 Result Screen**: dish hero card (real food sprite if exists OR chef hat + dish name fallback for unready dishes — NO more beige oval void); 5-point Polygon2D sprite stars (gold fill + dark outline + inner highlight crescent) replacing ASCII `***__`; NEW RECORD ribbon repositioned ABOVE stars+score (was overlapping below); EmotionReaction hero mode = primary focal point (avatar 320 px + speech bubble width+font enlarge + autowrap)
  - **D2 ActionPuck 5 states**: idle (persimmon #E04C24 + soft glow + drop shadow + inner highlight crescent) / hover (scale 1.05 + brighter) / active (scale 0.95) / perfect (gold flash + sparkle ring + bounce 1.0→1.20→1.0) / miss (red flash + shake ±10 px + dim 0.85α). signals (`pressed` / `button_down` / `button_up` / `state_changed`) drop-in compatible with old Button — gameplay 무변경 보장.
  - **D3 Cooking Background**: 3-band procedural composite (top: warm cream/peach kitchen wall gradient, middle: working area with warm radial spotlight pool under dish anchor, bottom: warm brown countertop strip with 4 slim wood-grain accent lines) + soft bottom vignette. dish shadow ellipse (2-layer for soft edge) + steam swirl loop (3 puffs rising + alpha fade + scale 0.6→1.0, stagger 0.7 s) reusing existing `art/vfx/steam_swirl.png`. Awning bleed Critical Issue #8 resolved by replacing MarketBG with CookingBackground in cooking_module_runner + result_screen_v2 (menu_select / guest_select still use MarketBG = awning preserved).
  - **신규 art 0건**: LOCK assets 100% 재활용 (food 12 + character 5×4 emotion + UI star_rating + VFX steam_swirl + perfect_glow + tool 12 + ingredient cut/whole 12), 추가 procedural 1건 (5-point Polygon2D star).
  - **regression**: cooking_modules_smoke 166 PASS / 0 FAIL + cooking_runner_integration_smoke 36 PASS / 0 FAIL = **202/202 PASS**. signal contract identical, ADR-011 score-mapping table 무변경, 12 dish sequence 동일.
  - **screenshots**: `assets-raw/_screenshots/d1_d2_d3_polish/` 15 PNG (01 result_top with NEW RECORD ribbon above + chef hat hero + sprite stars + hero emotion / 02 result_bottom / 03-07 cooking modules with cooking BG + ActionPuck / 08-10 puck idle/hover/active states / 11-13 arrange/flip/roll / 14-15 result no-record variant with real food sprite).
- **follow-up**: Critical Issue 10 중 D1+D2+D3로 해결: #1 placeholder dish oval / #2 NEW RECORD overlap / #3 ASCII stars / #4 rectangular pads / #5 floating beige void / #8 awning bleed. **남은 6건**: #6 guest_select avatar quality / #7 menu_select dish thumbnail crop / #9 sticky CTA wallet pill formatting / #10 milestone toast position 등은 다음 sprint. art-director에 sparkle particle PNG sprite sheet 16 frame / steam particle PNG 정식 의뢰 (현재는 procedural Polygon2D + 기존 LOCK swirl 재활용).

---

## [2026-06-04] Visual Quality Audit + Premium Redesign v1 sprint LOCK (ui-designer)
- **무엇**: 4 screen (Menu Select / Guest Select / Cooking 8 module / Result v2) **시각 품질 audit + premium redesign spec lock**. gameplay / 데이터 / scoring / progression **무변경** — visual only.
- **왜**: 사용자 피드백 "STOP adding gameplay systems, focus only on visual quality. Act as a senior mobile game UI designer." Royal Match (Dream Games 2021) / Travel Town (Magmatic 2021) / Cooking Madness (Mobaska 2017) / Merge Mansion (Metacore 2020) 4 premium casual benchmark 기준 현 quality 3.5/10 → 목표 8/10. 4 goal = 정보 density / 시각 hierarchy / character presence / reward presentation.
- **결과**:
  - **신규**: `docs/ui/visual-audit-2026-06.md` v0.1 (4 screen × 4 카테고리 = 16 section audit, 4 reference 게임 시각 패턴 분석, 4 goal mapping)
  - **신규**: `docs/ui/premium-redesign-v1.md` v0.1 (각 screen별 5~11 redesign items P0/P1/P2 priority + before/after ASCII sketch + 색상 palette hex lock + Typography lock + 4 goal contribution + godot-dev sprint 7.1~7.5 파일별 변경 list + before/after screenshot 캡처 plan + 11 open questions + 8 decisions PR-1~8)
  - **갱신**: `docs/ui/components.md` **v0.5 → v0.6** — Premium Redesign 시각 컴포넌트 **CP-33~41 9종 신설** (glossy_button / drop_shadow_card / sparkle_particle / character_idle_animator / hero_number_bounce / gold_ribbon_banner / coin_spray_particle / now_cooking_banner / step_progress_dots). §16 Z-order 9 row 추가. Decisions PR-1~8 등록. Confirm #23~28 신설.
  - **scope lock**: gameplay 변경 X / 데이터 구조 변경 X / scoring 변경 X / progression 변경 X / placeholder art OK / 기존 anchor 재활용 우선 (food 12 hero + character 5 anchor + mood 5 sprite + CUT-00~06 + TOOL-01~12 + ICUT-01~12 = 2026-05-31 LOCK 자산 100% 활용).
  - **godot-dev hand-off**: P0 only 32h (1주 sprint), P0+P1 48h. 7.1 menu_select / 7.2 guest_select / 7.3 cooking_module_runner + 8 sub-module / 7.4 result_screen_v2 / 7.5 신규 9 component PackedScene + scripts. shot_*.tscn 기존 스크립트 재활용. after screenshot 캡처 디렉터리 `assets-raw/_screenshots/premium_v1/`.
  - **art-director hand-off (this sprint)**: sparkle particle PNG sprite sheet 16 frame / steam particle PNG / gold ribbon NinePatch sprite (fishtail) / speech bubble round template. MVP fallback = procedural Polygon2D + simple white circle (godot-dev이 placeholder로 진행 가능, art polish는 art-director sprint 동시 진행).
  - **4 goal 달성 예상 (after redesign)**: 정보 density 5→8 / 시각 hierarchy 4→8 / character presence 2→8 (largest gain) / reward presentation 3→9 (largest gain).
- **follow-up**: godot-dev sprint 진입 (P0 32h 1주). game-designer M2에 CP-36 idle breathing scale amplitude/period confirm 요청 (1.0→1.02 vs 1.0→1.05 / 2s vs 1.5s, 권고 1.0→1.02 / 2s SINE). art-director에 4 자산 (sparkle/steam/gold ribbon/speech bubble) 1주 sprint 의뢰. before/after 비교 보고서 = godot-dev sprint 종료 시 `docs/ui/before-after-premium-v1.md` 작성.

## [2026-06-04] Cooking Framework 2.0 — ADR-011 8-module runner refactor (godot-dev)
- **무엇**: 하드코딩된 7-phase rhythm flow(`rhythm_proto.gd`)를 데이터 주도 8-module runner로 교체. 새 음식 추가 = `dish_modules.csv` 1줄 + `menus.csv` 1줄 → **코드 수정 0**.
- **왜**: ADR-011 lock — 음식 12종 × 미니게임 다양성을 phase token 7개로 표현 못 함. 8 module(slice/arrange/stir/flip/timing/season/roll/plate) universal primitive + per-dish sequence CSV.
- **결과**:
  - **신규**: `scripts/gameplay/cooking_module_runner.gd` (CSV → 8 module 디스패치 → ResultScreenV2 핸드오프, 옵션 A clean refactor). `scripts/cooking_modules/base_module.gd` + `slice/arrange/stir/flip/timing/season/roll/plate_module.gd` (각각 `module_completed(score: float)` signal). `scenes/cooking/*.tscn` 8개 + `scenes/cooking_module_runner.tscn`.
  - **데이터**: `godot-project/data/dish_modules.csv` 15행(12 음식 + 3 stew fallback). `MenuDB.module_sequence(food_id)` API + ALL_MODULES whitelist + FALLBACK_SEQUENCE.
  - **라우팅**: `menu_select.gd` + `guest_select.gd` → `cooking_module_runner.tscn`. `rhythm_proto.gd`는 git history 보존 위해 남김(진입점 없음).
  - **score map (ADR-011 lock)**: slice/arrange/roll → prep · stir/flip → cook · timing → timing(cook 4-factor에 fold) · season → season · plate → plating.
  - **save compat**: SaveManager v2 그대로 (records / recipe_xp / friendship / intimacy 전부 backward compat). v1/v2/v2+records 3-tier 로드 테스트 통과.
  - **테스트**: `cooking_modules_smoke` 166 PASS, `cooking_runner_integration_smoke` 36 PASS (12 음식 _finish() 정상 도달), `result_v2_smoke` 50 PASS(regression), `save_migration_test` 4 PASS(regression). **합계 256 PASS / 0 FAIL**.
  - **스크린샷**: `assets-raw/_screenshots/cooking_framework_v2/` 10장 (slice/arrange/roll/timing/plate/flip + 김밥 full sequence 4프레임).
- **follow-up**: art-director에 12 그릇/garnish + module별 visual variation 의뢰. ui-designer에 FTUE/Plate polish 의뢰. season "marinade" 모드 외 다른 음식별 special variant는 CSV column 확장(현재는 `_build_module_params` hardcode bridge).

## [2026-06-03] 미니게임 재설계 시작: "음식이 곧 게이지" + 끓는 냄비 + Perfect 연출
- **무엇**: "튜토리얼 설명서" 같던 미니게임을 음식 중심으로 전환. Boil = 막대 → **실제 끓는 냄비**, 모든 조리 페이즈에 "지금 만드는 음식" 상시 배너, **PERFECT! 버스트**.
- **왜**: 크리에이티브 피드백 — 음식이 안 보임/막대 심심함/Perfect 약함/리듬게임 느낌 약함. Royal Match처럼 핵심 오브젝트(음식)가 항상 보여야.
- **결과**:
  - **Now-Cooking 배너**(`_build_now_cooking`): 상단에 음식 썸네일 + "Cooking · Ramyeon (라면)" 상시 표시(조리 중). plating/reveal에서 숨김. SPAWN_Y 120→250로 칼질 노트가 배너 아래에서 시작.
  - **Boil 재설계**: `_build_boil_pot` + `_update_boil` — 냄비 국물 색이 깊어지고(연주황→진빨강), 거품이 heat↑에 따라 잦아지고, 둘레 **골든 히트 링**이 차오르며 적정구간(0.8~1.05)에서 금색·굵게 + 김. 적정 릴리스 = PERFECT.
  - **`_perfect_burst`**: "PERFECT!" 큰 텍스트(스케일 인) + 10방향 스파클 + (boil)김. boil·panfry perfect에 연결.
  - 검증: preflight 255 PASS, := 타입추론 안전.
  - 문서: `docs/phase1/minigame-redesign-v1.md`("음식=게이지" 원칙 + 메뉴별 미니게임 매핑 + 끓는냄비 프롬프트). 남은 작업: roll/stir/mix/season도 음식상태 비주얼로 교체, 손님+음식 동시 노출, 페이즈 음식 PNG 스왑.

## [2026-06-03] 피드백 3건: 그릇 중첩 수정 · 글자 오버플로우 · 게임 폰트
- **무엇**: (1) reveal에서 "그릇 안의 그릇"(라면 PNG의 사기그릇 + 내가 그린 양은냄비) 제거, (2) 글자 화면 밖 튀어나감 수정, (3) PowerPoint 느낌 폰트 → 게임 느낌.
- **결과**:
  - **(1)** 원인: 음식 PNG에 이미 그릇이 포함됨 → 그 위에 그릇을 또 그려 중첩. `_build_vessel` 재작성: PNG가 있으면 그릇으로 감싸지 않고 **밑에 받치는 serving stand/tray**(`_draw_stand`, 금속=손잡이/나무=널결/유기=금테)로 그려 음식을 올림. placeholder(PNG 없는 찌개 3종)만 실제 그릇(`_draw_bowl`) + mound. → 중첩 해소, 그릇 선택은 받침 재질로 구분.
  - **(2)** reveal 매칭 배지 autowrap + 좌우 여백(폭 1000) + 폰트 44. 레벨 배너를 **불투명 알약 패널**(차양 위에서도 읽힘, 짧은 "Lv N · 평가자")로 교체.
  - **(3)** 프로젝트 기본 테마 `ui/game_theme.tres` 추가(`gui/theme/custom`): 전 Label/Button에 **외곽선 + 그림자 + 큰 기본 크기** → 기본 폰트도 도톰한 게임 UI 느낌. (전용 TTF는 폰트 파일 확보 후 교체 가능.)
  - 검증: preflight 255 PASS, 타입추론 안전, 테마/씬 ref OK.
  - 메모: 진짜 그릇 아트(서빙 식기 6~8종)는 `image_prompts_v2_assets.md §그릇`으로 생성→`cutout`→스왑하면 받침 도형 대체 가능.

## [2026-06-03] 피드백 3건: 화폐 명시 · 손님 입맛 다양화 · 미니게임 직관화
- **무엇**: (1) 화폐 = 인게임 **원(₩)** 확정/명시, (2) 친구 5명 입맛을 5축 전부로 분산, (3) 미니게임 UI를 "사각 박스" → 직관적 안내·타겟·패드로 개편.
- **왜**: 플레이테스트 피드백 — 단위 불명확 / 친구 다수가 savory로 쏠림 / 미니게임이 뭔지·어떻게 하는지 모름.
- **결과**:
  - **(2 입맛)** `guests.csv` 재설계: Junho=매운맛 / Mina=단맛 / Riley=신맛(상큼) / Mrs.Lee=감칠 / Seoyeon=짠맛 — **5축 dominant 전부 distinct**(검증). 기본 손님↔메뉴 매핑도 손님 dominant축이 그 메뉴 양념 슬롯과 맞게 재배치(예: Mina→떡볶이/잡채(단), Riley→해물파전(신), Seoyeon→불고기/된장(짠)).
  - **(3 직관화)** 라운드 전 페이즈에 **큰 제목 + 한 줄 how-to 배너**(`_phase_header`/`_howto`). Chop=판정선에 **펄싱 글로우 타겟 링** + 재료를 **둥근 슬라이스**(상자 X). Stir-fry=**큰 LEFT/RIGHT 패드** + 화살표 도착 시 해당 패드 **하이라이트**(탭 위치 명확). Pan-fry=**FLIP 패드**가 타이밍에 금색 "FLIP!"으로 점등. Mix=**TAP 패드 + 실시간 카운터**(n/12). Boil/Roll="PRESS & HOLD / let go here" 캡션. 입력도 패드 버튼 기반으로 명확화.
  - **(1 화폐)** 그리드 머니/보상 모두 ₩ 유지(인게임 원). "Coins"로 전환은 라벨 한 줄.
  - 검증: preflight 255 PASS, 타입추론 안전, 손님 5/5 축 분산 확인.

## [2026-06-03] 한국 전통시장 배경 + 게임다운 UI (market_bg)
- **무엇**: 밋밋한 베이지 슬라이드 → 절차적 한국 전통시장 배경(`market_bg.gd`): 노을 그라데이션·기와 한옥 지붕·줄무늬 차양·청사초롱·시장 보케·나무 좌판. 메뉴=나무 간판 헤더+알약 배지, 게임플레이=`light` 모드(가독성 유지).

## [2026-06-03] 경제·세이브 + 손님 선택 UI + SFX 인제스트 + 아트 가이드 (5청크)
- **무엇**: 레벨업이 실제로 이어지는 **세이브·경제 레이어**, **손님 선택 UI**, **SFX 인제스트 파이프라인 확장**, 완성샷·페이즈 **아트 인제스트 가이드** 5묶음.
- **왜**: 게임으로서의 진전(progression이 저장·누적) + 내러티브 깊이(손님 선택) + 사운드/아트 외부 자산 흐름 가동.
- **결과/다음 단계**:
  - **[1 경제·세이브]** `save_manager.gd` 전면 개편 → JSON(`user://kfood_save.json` v1): level·money·per-menu stock·unlocks·stats·reputation·intimacy·player_char·settings. 얕은 머지로 버전 호환, 구 A2 API 보존. 라운드 통과 시 보상 입금(`Level.reward`×우수1.3), 진입 시 재고 1 소비(0이면 그리드 "Out of stock"+Restock ₩2,000), 누적 클리어로 레벨업(토스트 "Level Up! ▲ … market unlocked"). `rhythm_proto._finish`·`menu_select` 배선. **sim: perfect 플레이 41라운드에 L8(목표 30~50 부합), 최종 ₩798,800.**
  - **[2 손님 선택]** `guest_select.gd`+씬. 메뉴 선택 후 손님 카드 그리드(친구5+멘토, evaluator 제외) — 아바타(placeholder)·동적 미각 힌트·친밀도 ★·Auto Select·Back. evaluator 레벨은 스킵. 결과 후 친밀도 ±(만족+1/보통0/불만−0.5). `pending_guest_id` 라운드 연동.
  - **[3 SFX 인제스트]** `ingest_sfx.py` 슬롯 24종으로 확장(act_panfry/roll/mix·season_*5·sting_mystery/daniel/goldspoon·ui_menu). 신규 `audio_qc.py`(메트로놈 클릭 그리드 위 어택 정렬 QC). `_incoming/README.md` 슬롯 규칙 + `SOURCES.md §3D` CC0 검색 가이드. 다운로드는 사용자(집).
  - **[4 완성샷]** `image_prompts_phase1.md §D` 3종(김치/된장/매운탕) 풀스펙 확인 OK. `menu_db.ready`를 **실제 파일 존재(`ResourceLoader.exists`)로 자동 판정** → PNG 드롭만으로 placeholder→실물 auto-swap(CSV 수정 불요). `asset-ingest-guide.md`(파일명·폴더 규칙).
  - **[5 페이즈 아트]** `image_prompts_phase1.md §H` 신규(stir-fry/pan-fry/roll/mix + 양념 아이콘 5). `phase-art-v1.md`(슬롯·placeholder 폴리시·`art/phases/` 매핑).
  - 검증: preflight 255 PASS, 코드 := 안전, 씬 ref OK, 레벨업 pacing sim OK. 신규 문서: economy-save-v1·guest-select-ui·audio-ingest-v2·asset-ingest-guide·phase-art-v1.
  - 남은 작업: 신규 SFX 슬롯 코드 배선(FeedbackBus/페이즈), 페이즈 아트 스왑 코드 분기, L8 엔딩 컷씬, 캐릭터 풀바디 아트 스왑, 친밀도 특수효과(Phase 2).

## [2026-06-03] 페이즈 변주 4종 + 레벨 8단계 데이터화 + Evaluator
- **무엇**: 12메뉴가 똑같던 페이즈를 **음식별 조리 동작**으로 다양화(신규 4종) + 난이도·점수·보상을 **`levels.csv`로 외부화** + 평가자 3종 등장.
- **왜**: 손맛 1순위(메뉴별 차별화) + 디자이너 튜닝 가능한 레벨 데이터 + "초반 관대 → 후반 Golden Spoon급 엄격" 곡선.
- **결과/다음 단계**:
  - 신규 페이즈 4종(`rhythm_proto.gd`): **Stir-fry**(좌/우 화살표 탭), **Pan-fry**(FLIP 타이밍 + raw→golden 진행), **Roll**(말기 홀드), **Mix/Knead**(연타). 전부 `FeedbackBus.hit` 경유 5중 자극(팝업·플래시·SFX·햅틱) 풀 적용.
  - 라운드를 **phase-queue 상태기계**로 리팩터: `menus.csv`의 `phases` 컬럼(`chop|stirfry|season`)대로 순서 실행. 카테고리 버킷(prep/cook/season)으로 채점.
  - 신규 데이터: `data/levels.csv`(L1~8: 윈도우 90→36ms, tol 0.40→0.10, 가중 w_prep/cook/season/dish, θ 0.55→0.88, 별점·보상·시장·evaluator). guests.csv에 평가자 3명(Mystery Diner L3 / Daniel Kim L5 / Golden Spoon L8).
  - MenuDB: phases 파싱 + levels 로드(`get_level`, 범위 clamp) + `dish_bonus_scaled`/`dish_tier`.
  - 레벨 적용: 라운드 level=메뉴 unlock_level → 윈도우·tol·가중·별·보상 자동. 결과 화면에 별점·통과여부·"Earned N coins".
  - evaluator: 해당 레벨 메뉴는 일반 손님 대신 평가자 등장(보라 배너 "… is watching"). 메뉴 그리드에 레벨 배지·"★ Evaluator"·잠금(회색) 표시.
  - 검증: preflight 254 PASS. 로직 sim(정답 데이터) — 7페이즈 토큰 전부 사용, 12메뉴 perfect S=1.00 ≥ θ, worst=0 fail, 중급 L1~6 통과·L7~8 탈락(의도된 마스터리 곡선), evaluator 트리거 L3/5/8 정상. ⚠ bash 마운트가 menus.csv를 일시 truncate 표시했으나 실제 Windows 파일은 13행 정상(Read 확인) — Godot 로드 영향 없음.
  - 문서: `docs/phase1/phase-variations-v1.md`(페이즈 4종·메뉴 매핑·SFX/모션), `docs/phase1/levels-v1.md`(8레벨 곡선·evaluator). 남은 작업: 경제·세이브로 레벨업 연결, 손님 선택 UI, 전용 SFX 루프 ingest, 완성샷 3종, 페이즈 전용 아트 스왑.

## [2026-06-03] 데이터 주도 라운드 일반화 (12메뉴) + English-first 언어 정책
- **무엇**: 라면 하드코딩 라운드를 **12메뉴 데이터 주도** 시스템으로 리팩터. + 게임 내 텍스트 **영어 1차** 전환(한국어는 문화 부제).
- **왜**: (c) 코드 일반화 directive — F5 누르면 메뉴 그리드에서 12메뉴 중 아무거나 골라 라운드가 돌아야. 타깃 외국인 → 영어 정책.
- **결과/다음 단계**:
  - 신규 데이터: `godot-project/data/menus.csv`(12메뉴: 양념·그릇 best/2nd/bad·손님·unlock·완성샷·ready), `data/guests.csv`(친구 5명, 영어 대사·미각벡터·tol).
  - 신규 코드: `scripts/gameplay/menu_db.gd`(CSV 파서 레지스트리, class_name 없이 preload — 전역클래스 desync 회피; VESSELS 8종 색·kind; dish_bonus), `scripts/ui/menu_select.gd`+`scenes/menu_select.tscn`(unlocked 카드 그리드 → 라운드).
  - 리팩터: `scripts/gameplay/rhythm_proto.gd`(`RhythmRound`) — 라면 상수 제거, MenuDB에서 양념·그릇·손님·완성샷 로드. 양념 버튼 동적 생성, vessel kind별 reveal 형태(metal 손잡이/glass 반투명/plate 얕음), placeholder food mound + "Final art coming soon".
  - `seasoning_gauge.gd`: 양념 색 7종 추가(gochujang·chamgireum·gukganjang·doenjang·chojanga·saeujeot), `display_name`/`summary_en` 영어화.
  - `project.godot` main_scene → `menu_select.tscn`. 라운드 종료 탭 → 메뉴 그리드 복귀.
  - placeholder 정책: 완성샷 없는 3종(김치/된장/매운탕 `m_*`)은 `ready=0`으로 플레이 정상.
  - 검증: preflight 254 ALL PASS. Python sanity — 12메뉴 전부 guest/vessel/axis 유효 + ready 플래그 파일 일치 + perfect play S=1.00 ≥ θ_pass(레벨별) → 깨지는 메뉴 없음. 코드 `.text` 한글 잔재 0(남은 한글은 주석·`name_kr` 부제뿐).
  - 문서: `docs/phase1/round-system-v3.md`(일반화 구조·데이터 트리·메뉴 추가법). 남은 작업: Level 차등 데이터화, 손님 선택 UI, 페이즈 변주, 완성샷 3종 생성, 평가자 데이터.

## [2026-06-02] 프로토타입 현실화(그릇 담김·라면 양념) + 레시피/밸런스 표

- **그릇 담김**: 프로토타입 reveal에서 선택 그릇에 **라면이 실제 담긴 모습**(양은냄비/사기/돌솥 — Polygon2D로 그릇+국물+면+계란+파 묘사). 라면 그릇 궁합 = **양은냄비 정답(+0.12) / 사기 2번(+0.05) / 돌솥 안어울림(−0.08)**, 글로우·배지·별 차등.
- **양념 현실화**: 라면에 간장 X → **라면스프(간·감칠) + 고춧가루(매 추가)**. SeasoningGauge에 `soup` 추가.
- **신규 `docs/phase1/recipes-balance-phase1.md`**: (a) 12메뉴 현실적 양념 슬롯 + 그릇 궁합(정답/2번/안어울림), (b) 밸런스 튜닝값(윈도우·tol·점수가중·θ·그릇보너스·보상), (c) M1 데이터 주도 통합 매핑(MenuRecipe·Guest·Level). `scoring-v2 §1.1`에 현실성 원칙 명문화.
- preflight 253 ALL PASS. (c) M1 정식 통합(12메뉴·5손님·그릇/조리 연출 일반화)은 본 표를 데이터 소스로 다음 빌드 청크에서 진행.

## [2026-06-02] M0+ 새 라운드 구조 프로토타입 (한 판 전체 통합)

- **무엇**: `rhythm_proto.gd`를 새 구조 한 판 전체로 확장 — **손님 요구(자연어) → 칼질(탭) → 끓이기(Hold) → 양념 게이지 → 플레이팅(그릇 선택+매칭) → 음식 reveal(줌+글로우+sting) → 손님 자연어 반응+별**. 미각 벡터는 백엔드, 화면엔 자연어/별만(정체성). 라면 1메뉴·손님 1명(준호) 샘플. project.godot main_scene = rhythm_proto.tscn(임시), 결과 화면 탭 시 재시작.
- **검증**: preflight 253 ALL PASS, `:=` Variant 함정 스캔 0, 만족도 로직 Python 실행(완벽 매칭 5★ / 너무 순함 3★+"좀 더 매콤했으면" 귀띔 / 미스매치 1★ — 합리적·단조).
- **남은 것(엔진=사용자 머신)**: 실제 손맛·연출 체감은 F5 실행. 그래픽은 프로토타입(노트=원, 칼=폴리곤, 그릇=버튼). 손맛/밸런스 확정 후 M1에서 정식 라운드·12메뉴·시장으로 일반화.

## [2026-06-02] M0 손맛 프로토타입 스캐폴드 빌드 + 로직 검증

- **무엇**: rhythm-prototype-spec 기반 **M0 코어를 실제 GDScript로 구현**. autoload 4종(`beat_clock`·`tuning`·`haptic_manager`·`feedback_bus`) + `rhythm_judge.gd`(class_name RhythmJudge, 판정·윈도우·hold_score) + `seasoning_gauge.gd`(class_name SeasoningGauge) + `rhythm_proto.gd`(절차적 칼질 4탭→양념 게이지→결과·메트릭 로깅) + `scenes/rhythm_proto.tscn`. project.godot에 autoload 4종 등록.
- **검증(이 환경=Godot 바이너리 없음·다운로드 차단)**: ① `preflight_check.py` **253건 ALL PASS**. ② 위험 패턴(`:=`+round/clamp/lerp 류 타입추론 실패, autoload↔class_name 충돌) 스캔 0. ③ **핵심 판정·점수 로직을 Python으로 동일 포팅해 실제 실행** — 윈도우 단조감소 OK, 난이도 곡선(숙련 L1 Perfect95%→L8 58%·Miss7.6%), Pro칼 ×1.3 효과(L4 Miss 10.4%→3.4%), Hold 부분점수(엄격 tol에서 오차10%→0.31) 전부 설계대로.
- **발견(튜닝 플래그)**: L1 윈도우가 매우 관대(숙련 Perfect 95%, 캐주얼 77%) → spec QA의 "Perfect 30~40%"는 L1엔 부적용(의도적 온보딩 관대). 30~40% Perfect 목표는 중반(L4~6)에 부합. L1 타깃 재정의 또는 의도 확정 필요.
- **남은 것(엔진 필요, 사용자 머신)**: 실제 60fps·입력 레이턴시·햅틱·시청각 5중 자극은 Godot 4.x 실행에서 검증(F6 `rhythm_proto.tscn`). 끓이기 Hold·플레이팅·reveal 연결은 후속.

## [2026-06-02] Phase 1 플레이팅·음식 reveal 연출 스펙 (3대 폴리시 스펙 완성)

- **무엇**: `docs/phase1/reveal-plating-spec.md` — ③플레이팅(그릇 캐러셀 스와이프·snap·담기 애니·"+15% Match!" reward·garnish 1슬롯, 5초 타임라인) + ②음식 reveal(카메라 줌인+기울기·황금 글로우·메뉴 12 입자 프로파일 개별·완성 sting 3등급 보통/잘함/명품·한 박자 멈춤, ~2.0s 타임라인). 플레이팅→reveal→결과 무컷 연결. Godot 노드·튜닝 다이얼·QA·A/B 4건.
- **결과**: 리듬(①)·reveal(②)·플레이팅(③) **3대 폴리시 스펙 세트 완성** → M3 폴리시 패스 즉시 구현 가능. 코드 변경 0.
- **A/B(디폴트)**: reveal 줌인+미세기울기 / garnish 1슬롯 연출+미세보정 / 매칭 "+15%" 표기 허용 / 플레이팅 5초.

## [2026-06-02] Phase 1 데이터 스키마 확정 + 빌드 스프린트 계획

- **무엇**: `docs/phase1/data-schema-phase1.md`(기존 리소스 스크립트 위 필드 추가 계약 — FoodDefinition seasoning_slots·dishware·market_id 등, CharacterDefinition taste_vector·tolerance·dialogue, IngredientDefinition tier·uses·price, 신규 Tool/Dishware/Seasoning/Level 리소스, SaveManager 필드, levels_phase1.csv 8행) + `docs/phase1/build-plan-phase1.md`(M0 손맛 프로토타입→M1 시스템→M2 콘텐츠→M3 폴리시→M4 출시, 의존성·DoD·리스크·즉시 착수 항목).
- **근거**: 기존 `scripts/resources/`(Food·Character·Ingredient·Store·CookingMethod·Timing) 위에 비파괴 추가로 정합. 아트·사운드는 병행 트랙. Godot 바이너리 없는 환경이라 빌드는 사용자 머신, 본 저장소는 preflight 정적검사.
- **다음**: M0(손맛 프로토타입) 착수 — autoload 4종 + JudgmentZone + 노트풀 + 5중 피드백 + 게이지, 스키마 필드 추가 병행, CC0 박자 정렬 1차.

## [2026-06-02] Phase 1 리듬 손맛 프로토타입 스펙 (구현 수준)

- **무엇**: `docs/phase1/rhythm-prototype-spec.md` 신규(14절). 노트 타입(Single/Double/Hold/Slide)·**판정 윈도우 ms 매트릭스**(L1 Perfect±90/Good±200 → L8 ±36/±80, Pro칼 ×1.3)·**5중 히트 피드백** 판정별 정밀값(파티클 색·수·수명 / 글로우 / 팝업 모션 / SFX 믹스 / 햅틱)·양념 게이지 UI(색·증분·MAX·자연어)·등속 강하·레이턴시 ≤16ms·오디오클럭 BeatClock·SFX layering·햅틱 iOS/Android 매핑·1주 빌드 범위·튜닝 다이얼·레퍼런스 5종·QA 체크리스트·Godot 노드구조/스니펫·A/B 4건.
- **결과**: 다음 sprint Godot 프로토타입 즉시 착수 가능(self-check 통과). 코드 변경 0(스펙).
- **A/B(디폴트)**: 노트 위→아래 / 게이지 하단 고정 / 햅틱 ON / 모바일 우선.

## [2026-06-02] Phase 1 MVP 스코프 확정 + 프로덕션 우선순위

- **무엇**: 풀 v2 설계를 `docs/phase2_archive/`(24개 문서)로 보존하고, **Phase 1 cut 문서 세트 8종**을 `docs/phase1/`에 신규 작성. 시장 2(동네·노량진)·메뉴 12(L1~8, 해산물 2)·친구 5(Mina·Junho·Riley·Mrs.Lee·Sora)·평가자 3(Mystery Diner·Food Blogger=Daniel Kim 흡수·Golden Spoon Inspector L8 보스)·레벨 L1~8(엔딩)·난이도 ±0.40→±0.10·재료/도구/그릇 2티어·다인/명품/DLC 제외(Phase 2).
- **프로덕션 우선순위(사용자 못박음)**: 공수 대부분을 **3대 폴리시**(① 리듬 입력 손맛 5중 피드백·판정 차등·60fps·양념 게이지·SFX layering·햅틱 ② 음식 완성 reveal 1.5~2.5초·김/글로우/줌·sting 3등급·메뉴별 개별 ③ 플레이팅 snap·그릇 캐러셀·매칭 보너스 reward)에. 인벤토리·시장 UX·입퇴장·알림·BG는 functional만. 배분 60/30/10.
- **산출**: `phase1/` README·GDD-phase1(우선순위 절 포함)·production-priorities·menu-roster-phase1·characters-phase1·markets-phase1·unlock-tree-phase1·image_prompts_phase1. `sound-guide §0.5`·`audio-pipeline §1.5` SFX layering 추가. 메뉴 신규 3(김치찌개·된장찌개·매운탕) reveal 키프레임 프롬프트 포함.
- **정합**: 외국인 타깃·Golden Spoon·자연어 UI·플레이어 5종 등 v2 결정 모두 유지. 코드/데이터 변경 0 — Phase 1 빌드는 다음 sprint에서 본 세트 기준.

## [2026-06-02] v2.4 외부 리뷰 보완 — 양념 입력 UX · 다인 안전장치 · 오디오 박자 정렬

- **무엇(3건)**: (1) **양념 양 입력 직관성** — 색깔별 양념 게이지 + 양념통 노트(일반 노트와 색·아이콘 구분) + 탭카운트/홀드 두 방식 + 탭마다 즉시 피드백 + 결과 자연어("고춧가루 4단위"). (2) **다인 디너 밸런싱 안전장치 2단계** — 콤보는 미각 코사인 유사도 ≥0.85만(상충 차단) + 플레이팅 개인 양념·고명 3슬롯으로 베이스+개인 가중(캐주얼 70:30, 미식가 50:50) → All-pass 구조적 항상 가능. (3) **오디오 정밀 박자 보정** — transient 0ms 정렬 + BPM×SFX 적합성 매트릭스 + 메트로놈 QC(`tools/audio_qc.py` 명세).
- **결과/산출물**: 신규 `docs/audio-pipeline-v1.md`. 갱신 `scoring-v2`(§1.5 입력 UX·§6.0 다인 안전장치), `rhythm-variation-v1`(§2.5 노트 종류), `characters-v2`(§3 콤보 호환 임계), `GDD-v2`(다인 플레이팅 분기), `sound-guide`(§0 BPM·SFX 매트릭스), `image_prompts_v2_ui`(UI-12 양념 게이지·UI-13 다인 분할 플레이팅), `art-needs`(§5.6.1).
- **정합**: v2.1~2.3과 충돌 없음. 코드 변경 0(설계·명세). librosa/audio_qc는 후속 구현.

## [2026-06-02] v2.3 메뉴확장 · 브랜딩(Golden Spoon) · 글로벌 캐릭터 · 플레이어 선택

- **무엇(우선 3건 + α)**: (1) **메뉴 12→41종**(`menu-roster-v1.md`, `data/menus-v2.csv`) — 단계별 분포(입문11·가정식10·입소문10·명인10), DLC 별도. (2) **미쉐린→Golden Spoon Guide 전수 치환**(11개 문서, 잔여 0, 황금 숟가락 모티프, `branding-v1.md`). (3) **캐릭터 글로벌 보편 아키타입 전면 재작성**(`characters-v2.md` v2.3: 옆집 어르신 멘토·룸메·동료·트레이너·집주인 등, 한·영 병기, 대사 EN 우선, 평가자 Golden Spoon 라인, 상인 보편 톤, 구버전 `archive/`). (4) **플레이어 프리셋 5종 선택**(`player-characters-v1.md`: Mia·Alex·Jin·Sora·Pat, 20~30대, 메커닉 동일·서사/톤만 분기, 오프닝 컷씬). (5) **포지셔닝**(`positioning-v1.md`, 글로벌 타깃·USP는 한국).
- **결과/산출물**: 신규 `branding-v1`, `positioning-v1`, `menu-roster-v1`, `player-characters-v1`, `data/menus-v2.csv`, `image_prompts_v2_menus.md`. 재작성 `characters-v2`, `image_prompts_v2_characters`(+플레이어 5종). 갱신 `GDD-v2`(글로벌·플레이어선택·메뉴·시스템표), `onboarding-pace-v1`(R0 캐릭터 선택), `art-needs-v2`(§5.6), `image_prompts_v2_all`(인덱스), 전 문서 브랜딩 치환.
- **정합**: v2.1(미각 백엔드·평가자·온보딩·리듬·수익화)·v2.2(시장 허브) 유지. 친구 'Sora'는 플레이어 프리셋 Sora와 충돌 회피 위해 'Seoyeon'으로 개명. 인테이크 폴더 `premium_v2_players/menus` 생성.
- **A/B**: 브랜드명(Golden Spoon 디폴트/Starfork·Crown 대안), 본편 메뉴 수(41/35), 프리셋 수(5/4), 플레이어 분기 깊이(톤만) — 전부 디폴트 선택, 확인 대기.

## [2026-06-02] v2.2 월드빌딩 — 한식 명인 여정 + 전통시장 허브

- **무엇**: 컨셉/세계관 정식화. (A) 정체성 = "평범한 일반인이 **한식 장인**이 되는 영웅 서사"(무명→동네→시장 단골→지역 명인→한식 명인). (B) 세계 = **한국 전통시장**이 허브 — 추상 "재료 구매"를 실제 시장(동네·가락동·노량진·경동·광장·남대문 도매 + 지역 전주·부산·안동·통인)으로 대체. (C) 시장별 분위기·BGM·재료·**단골 상인 NPC 10명**·**평판 시스템**·**이벤트**(새벽 경매·도매 특가). (D) 12레벨 ↔ 서사 비트(레벨별 컷씬).
- **결과/산출물**: 신규 `docs/worldbuilding-v1.md`, `docs/markets-v1.md`, `docs/image_prompts_v2_markets.md`(시장 BG10·상인10·소품/간판3·이벤트컷씬2). 갱신 `GDD-v2`(정체성·포지셔닝·세계관·시스템표), `characters-v2`(§7 상인 NPC 10, 부산/전주 방언), `unlock-tree`(§2.6 시장 개방 곡선+평판표), `economy-balance`(§8 시장 가격차등·평판할인·이벤트보너스), `monetization`(시장 정보 미리보기 광고), `art-needs`(§5.5 시장 아트), `image_prompts_v2_all`(인덱스).
- **톤**: 진짜 한국 시장 디테일(빨간 차양·플라스틱 박스·LED 가격표) + 양식화, 미화 없이 따뜻하게.
- **정합**: v2.1(미각 백엔드·평가자 떡밥·캐릭터 개성·온보딩·리듬·수익화)과 충돌 없음. 인테이크 폴더 `premium_v2_markets/npc/market_props` 생성.

## [2026-06-02] v2.1 리프레이밍 — 정체성·UX·페이싱 보완 (외부 리뷰 반영)

- **무엇**: 백엔드 결정은 유지하되 **얼굴(정체성·캐릭터·페이싱·표현)**을 재정렬. (A) 정체성 = "한식 문화 컬렉션 게임"으로 GDD 서두 정렬. (B) 미각 벡터·편차 = **백엔드 전용, UI 숫자 노출 0** → 자연어 대사·표정·별 매핑. (C) 캐릭터 인격 골격(별명·3줄 백스토리·시그니처 대사3·등장 narrative) 전원 적용. (D) **평가자 떡밥 곡선** 신설(L3 수상한 평가단 → L5 동네 블로거 미나 → L7 푸드유튜버 도연 → L10 골든스푼 평가관 reveal). (E) 첫 15라운드 온보딩(시스템 한 겹씩). (F) 리듬 변주 곡선. (G) 수익화(광고 보상 + 고정 DLC, 가챠X).
- **결과/산출물**: 신규 `docs/monetization-v1.md`, `docs/onboarding-pace-v1.md`, `docs/rhythm-variation-v1.md`. 갱신 `GDD-v2`(정체성·포지셔닝·온보딩 §5.5·평가자 §7.6·리듬 §9.5·수익화 §11), `characters-v2`(인격 골격+평가자 4종, 가족 인격화), `scoring-v2`(§0 UI 자연어/표정 매핑·숫자 비노출), `unlock-tree`(§2.5 평가자 곡선), `image_prompts_v2_characters`(평가자 EV1·EV2 신규+EV3/EV4 매핑).
- **근거**: 골든스푼이 L10에야 나오면 대다수 미노출 → 떡밥 조기 배치. 숫자 노출은 캐주얼·컬렉션 정체성과 상충 → 사람으로 표현.

## [2026-06-02] v2.0 메타 구조 개편 (문서·데이터 스키마, 코드 변경 0) — PM 위임 셋팅

- **무엇**: 게임 메타를 "캐릭터 미각 만족 + 경제 + 12단계 사회 진행 + 다인 디너 + 도구·그릇 어워드"로 전면 개편하는 GDD v2 + 5개 시스템 문서 + 데이터 스키마 델타 + 아트 니즈를 신규 작성. **코어 리듬·조리 라운드와 기존 12음식 데이터·아트는 보존**, 그 위에 새 레이어.
- **왜**: 사용자 위임 — 양념 양 기반 연속 점수, 시드머니 경제, 친구별 미각 프로파일, 풀 메뉴 마스터→까다로운 미식가 만족 엔드게임. 추가 원칙(우선): 관대→골든스푼 곡선, 12단계 레벨, 다인 디너, 재료 횟수제 소모, 도구 3티어(구매/어워드), 그릇 플레이팅+어워드.
- **핵심 결정(디폴트)**: 미각 5축[단·짠·매·신·감칠]; 편차 ±0.40(L1)→±0.05(L12) 단조 감소; 캐릭터 15명(가족2+친구13); 양념=리듬 탭 횟수, 점수 = `raw + qualityBonus(재료) + dishwareBonus(그릇)`, τ_eff=편차+도구흡수; 시드 50,000원·재료 횟수제 소모(무환급); 도구·그릇 마스터=레벨 어워드(구매불가)→트로피 룸→"한식 명인"; **엔드게임 = 마스터 도구+명품 재료+매칭 그릇 3박자**; 다인 채점 = All-pass(디폴트).
- **결과/산출물**: `docs/GDD-v2.md`, `docs/characters-v2.md`, `docs/scoring-v2.md`, `docs/economy-balance-v1.md`, `docs/unlock-tree-v1.md`, `data/schema-delta-v2.md`, `docs/art-needs-v2.md` (+ 본 CHANGELOG). 결정마다 1줄 근거 + A/B 미결 7건 `[사용자 확인 필요]` 태그.
- **A/B 미결(요약)**: 미각 노출(정성힌트), 편차 음식의존(고정), 다인채점(All-pass), 보너스 결합(가산), 파산(엄마찬스), 실패보상(0원), 한정식 신규음식(기존 명품화) — 전부 디폴트 선택, 확인 대기.
- **다음**: 사용자 A/B 확정 → 구현 sprint(스키마 .tres/CSV 반영 → 점수·경제·해제 로직 → 신규 아트 ~110슬롯 단계 생성).

## [2026-06-02] 요리 소개 화면 (외국 플레이어 인지 보조) + 프리미엄 프롬프트 음식별 정합 (godot-dev / art-director)

- **무엇**: (1) 라운드 시작 전 **요리 소개 스테이지** 신설 — 만들 음식을 큰 이미지로 보여주고 영어/한국어 이름 + tagline + 1~2문장 설명 + "Start Cooking ▶". (2) **DishInfoRegistry**(12종 영어 소개 텍스트, 레지스트리 패턴). (3) 프리미엄 음식 프롬프트(`art-prompts-premium-foods.md`) 배경=단색 검정·김 제거(인게임 VFX)로 컷아웃 정합 + 음식별 정확도 수정(콘도그=소시지 노출, 잔치국수=면 소량·맑은 국물, 비빔밥=고추장 그릇 안에 없음 별도, 순두부찌개=네모 두부 아닌 몽글 순두부). 라면 레퍼런스 = G_premium LOCK.
- **왜**: 외국인이 한식을 몰라 게임 진입 장벽 → 무엇을 만드는지 확실히 인지시키기. + 사용자 어닝(음식별 디테일 오류 + 컷아웃 위해 배경/김 제거 필요) 반영.
- **결과/다음**: `round_controller._run_stages()` 맨 앞에 StageIntro await 배선. preflight 248건 ALL PASS. 외부 생성본은 `assets-raw/premium_v2/`에 `food_id.png`로 드롭 → strip_bg(검정 단색 luma-key 가능)→import.
- **패치**: `scripts/gameplay/dish_info_registry.gd`(신설), `scripts/gameplay/stage_intro.gd`(신설), `scripts/gameplay/round_controller.gd`(intro 배선), `docs/art-prompts-premium-foods.md`, `docs/art-style-guide-v2-premium.md`.

## [2026-06-02] 프리미엄 음식 12종 컷아웃 + 게임 반영 (godot-dev)

- **무엇**: 외부 생성한 프리미엄 음식 12종(검정 단색 배경, `assets-raw/premium_v2/`)을 투명 PNG로 컷아웃 → `art/sprites/food/{food_id}.png` 교체. `tools/cutout_black_bg.py` 신설(테두리-연결 flood/propagation 방식 = 음식 내부 검정 보존, 검정 합성 unmultiply로 가장자리 번짐 제거, 내용 bbox 크롭).
- **왜**: rembg 미설치 환경 + 검정 단색 배경 특성 활용. 음식 아트 프리미엄 업그레이드(#2) 실물 반영.
- **이슈/수정**: 김밥(t1_004) 김(나포)이 배경 검정과 동일 명도라 첫 패스에서 가장자리 김이 같이 제거됨 → BLACK_THRESH 36→14 + binary_opening(김↔배경 얇은 연결 끊기)으로 재처리해 김 보존. 도구 기본값을 이 방식으로 업데이트.
- **결과/다음**: 기존 스프라이트 `art/sprites/food/_backup_pre_premium_v2/` 백업. preflight 248건 ALL PASS. Godot이 소스 변경 감지 → 다음 실행 시 자동 재임포트. 후속: 재료/도구/캐릭터 아트도 동일 파이프라인으로 업그레이드 가능.
- **패치**: `tools/cutout_black_bg.py`(신설), `art/sprites/food/*.png`(12종 교체).

## [2026-06-01] #2 프리미엄 아트 스타일 v2.0 spec + 재생성 프롬프트 (art-director)

- **무엇**: `docs/art-style-guide-v2-premium.md` 신설. 진단(현 flat single-fill → 아마추어) → north star(Royal Match/Cooking Madness급 폴리시드 캐주얼) → **렌더링 10규칙**(좌상단 키라이트·소프트 그라데이션 음영·림라이트·글로시 하이라이트·접지 그림자·깊이·머티리얼·소프트 아웃라인) → v2.0 팔레트 → **카테고리별 재생성 프롬프트 템플릿**(STYLE_PREMIUM 접두+NEG_PREMIUM, 음식/재료/도구/캐릭터/배경/UI + 라면 예시) → 일관성 규칙 → Premium Gate(G_p1~5) → 재생성 파이프라인.
- **왜**: "고급스러운 모바일게임 느낌"(#2). 차이는 디테일이 아니라 빛·면·재질·일관성이라 진단.
- **결과/다음**: Claude는 이미지 생성 불가 → **실 그림은 외부(ChatGPT gpt-image-1, ADR-006)에서 템플릿으로 재생성** → `strip_bg.py` → `import_art_to_godot.py`(파일명 규칙 유지=코드 변경 0). 권장 순서: 음식 12 → 도구 → 캐릭터/리액션 → 재료 → 가게. 다음 사용자 순서 = **#4 추가 UI 폴리시**.
- **패치**: `docs/art-style-guide-v2-premium.md`(신설).

---

## [2026-06-01] #1 재래시장 가게 방문 쇼핑 + #3 진행도 패널 (사용자 순서 1→3)

- **무엇**:
  - **(#1) 가게 방문 쇼핑**: 단일 다중선택 → **재래시장 방문 흐름**. 시장 화면(필요 가게 목록=청과/정육/어물/곡물/잡화) → 가게 진입(그 가게 재료 토글 선택, 정답+디스트랙터) → 시장 복귀(방문 표시) → 전 가게 방문 후 **Checkout** → 정확도 채점. `shopping_registry.gd`에 **CORRECT_BY_STORE / POOL_BY_STORE** 추가(used_in_foods×store_type 역산). StageShop 전면 재작성, round_controller는 `shop.setup(name, food_id)`.
  - **(#3) 진행도 패널**: food_select에 **누적 별 바(★ N/36) + Dishes N/12 + 3★ N/12** 표시. SaveManager `cleared_count()/three_star_count()` 추가. A2 백본 위 가시화.
- **왜**: "가게 방문 없음/단순 선택 재미없음"(#1) + "누적 성과 시스템"(#3) 대응. 사용자 우선순위 1→3.
- **결과/다음**: preflight 248 PASS. 다음 순서 = **#2 프리미엄 아트 스타일 spec**(외부 생성용) → **#4 추가 UI 폴리시**. 패치: `tools/gen_shopping_from_csv.py`·`shopping_registry.gd`(가게별)·`stage_shop.gd`(시장)·`save_manager.gd`(통계)·`food_select.gd`(진행도)·`round_controller.gd`(shop 시그니처).
- **참고**: 재료별 개별 스프라이트 부재로 가게 화면은 텍스트 토글(아트 후속). 시장 맵 비주얼·가게 일러스트는 #2 아트 트랙.

---

## [2026-06-01] UI 디자인 시스템 도입 (#4 배경·버튼·글자 통일) + 폴리시 방향 정리

- **무엇** (사용자 "아마추어 느낌 / 디자인 필요"):
  - **`scripts/ui/ui_theme.gd` (UITheme) 신설** — 공용 디자인 시스템: 따뜻한 K-food 팔레트(크림 그라데이션 배경 + 테라코타 라운드 버튼 + 다크 글자 + 골드 강조), StyleBoxFlat(둥근 모서리·소프트 섀도·상태별 normal/hover/pressed/disabled), Label/Panel 기본값. `make_theme()`(캐시) + `add_background()` + `make_card()`.
  - **전 화면 적용**: food_select·round_controller(배경 그라데이션) + 모든 스테이지(shop/prep/method/timing) + result에 `theme = UITheme.make_theme()`. 평면 크림 ColorRect → 세로 그라데이션, 밋밋한 버튼 → 라운드+섀도 테라코타.
- **왜**: "배경·글자·버튼 디자인 필요"(#4) 직접 대응 — 코드로 가능한 최대 시각 향상.
- **결과/다음 (사용자 결정 대기)**:
  - **#2 일러스트 고급화**: 현 AI 하이퍼캐주얼 그림이 아마추어 인상 → art-director **프리미엄 스타일 재정의 + 재생성**(외부 이미지 생성, ADR-006). Claude는 이미지 생성 불가 → 스타일 spec/prompt는 제작 가능.
  - **#1 가게 방문 쇼핑**: 단순 선택 → 재래시장 맵·가게 방문 Scene 1 정식 제작(디자인+씬+아트).
  - **#3 누적 성과**: A2 백본(별·해금·도감) 완료 — 확장 여지(보상·업적 화면).
- **패치**: `scripts/ui/ui_theme.gd`(신설)·`food_select.gd`·`round_controller.gd`(+모든 스테이지 theme). preflight 248 PASS.

---

## [2026-06-01] alpha 6차 튜닝 — 결과 겹침/채점 엄격화/난이도 스프레드 + 큰 건 백로그화

- **무엇** (실플레이 피드백 8건 트리아지):
  - **(#1 완료) 결과 New Best↔리액션 겹침**: 리액션 축소(280)·위로 + New Best/별점/점수 간격 재배치 + 라벨 박스 컴팩트(세로중앙).
  - **(#4 완료) 채점 너무 관대**: 별점 기준 3★ 0.85→**0.92**, 2★ 0.55→**0.72**. (75%=2★, all-GOOD≈1★ 수준)
  - **(#6 완료) 난이도 차이 미미**: prep 판정창 **난이도별** 적용(쉬움 ±120ms ~ 어려움 ±55ms), timing sweep **2.4→0.7s**·PERFECT 폭 **0.14→0.035**로 스프레드 확대.
  - **(#8 권고) 타이밍 바 방향**: **가로 유지** 권고(portrait+한손 엄지 ergonomics). 사용자 확인 대기.
  - **(#2/#3/#5/#7 백로그)** `docs/design/progression-and-variety-v0.1.md` §9:
    - #2 칼/도구가 조잡 → **art-director에 전용 칼·도구 + board-less 재료 스프라이트** 위임(현 절차적 칼=placeholder; 재료 anchor의 baked 도마가 prep 구도 근본 제약).
    - #5 새 미니게임 "실행 안됨" = **아직 미구현**(이전엔 계획만). #7 다중재료와 합쳐 **다음 집중 빌드 = 드래그 썰기 prep(여러 재료 차례)**.
    - #3 김밥 roll = 스와이프 말기 미니게임(후속).
- **왜**: 안전한 튜닝은 즉시, 아트·신메커닉 대형 건은 런타임 테스트 필요 → 한 묶음씩 별도 빌드.
- **결과/다음**: preflight 248 PASS. **다음 = 드래그 썰기 + 다중재료 prep**(#5+#7) 집중 구현. 패치: `round_controller.gd`(별점)·`stage_prep.gd`(판정창 난이도)·`stage_timing.gd`(스프레드)·`result_screen.gd`(레이아웃).

---

## [2026-06-01] 픽스 — "Tap anywhere" 입력 차단 해소 (배경·장식 Control mouse_filter)

- **무엇**: Stage 2A/2C에서 "Tap anywhere"인데 일부 영역만 탭 인식 → 배경 ColorRect·라벨·스프라이트(Control)가 기본 `MOUSE_FILTER_STOP`으로 클릭을 가로채 `_unhandled_input` 미도달이 원인. round_controller `_bg` + StagePrep(라벨/재료) + StageTiming(라벨/표면/완성/스팀/타이밍바) 장식 Control 전부 **MOUSE_FILTER_IGNORE**로 → 탭이 어디서나 판정에 도달.
- **왜**: 입력 사각지대 제거(리듬탭·타이밍탭 신뢰성).
- **결과/다음**: preflight 248 PASS. F5 재실행. 패치: `round_controller.gd`·`stage_prep.gd`·`stage_timing.gd`.

---

## [2026-06-01] 구조 재설계 착수 — A2 메타 progression(누적 별·해금·도감) 백본 구현

- **무엇** (사용자 "선형 난이도 단조로움 / 누적 보상 / 다른 게임 필요" → 방향 결정 후):
  - **설계 문서** `docs/design/progression-and-variety-v0.1.md` 신설 — 메타 progression 3안 + 미니게임 다양성 제안. **사용자 결정: A2(재료·도감 해금) + 신규 미니게임 3종(드래그 썰기·붓기·휘젓기)**.
  - **SaveManager 실구현**(skeleton→실제): `total_stars` 누적 + 음식별 `best` 최고 별점, user:// ConfigFile write-through. `record_result/best_of/is_cleared`.
  - **해금 룰**: 정렬(tier→difficulty)에서 **이전 음식 클리어(별 1+) 시 다음 해금**(sequential) → "다음 단계 음식/재료 제공" 실현.
  - **food_select 진행도 UI**: 상단 누적 별(★ N/36) + 음식별 최고 별점(★★☆=도감) + 잠금 음식 비활성("clear previous"). Play in Order = 첫 미클리어 해금 음식부터.
  - **결과 화면**: 라운드 종료 시 SaveManager 기록 + 최고 갱신 시 "★ New Best!".
- **왜**: 그 판에서 끝나던 별점을 **누적→해금**으로 전환 → 플레이 동기·진행감. 게임 뼈대 1차 변경.
- **결과/다음**: preflight 248 PASS. **다음 sprint = 신규 미니게임 3종**(드래그 썰기/누르면 붓기/휘젓기 — 조리법별 매핑)으로 "선택+타이밍" 단조로움 해소. 각 미니게임은 런타임 테스트 필요 → 한 묶음씩. 패치: `save_manager.gd`·`food_select.gd`·`round_controller.gd`·`result_screen.gd`, `docs/design/progression-and-variety-v0.1.md`.

---

## [2026-06-01] alpha 피드백 5차 — 조리 중 도마 제거(추상 칩) + 결과화면 구도 재정렬

- **무엇**:
  - **(조리 중 도마 제거)** 투입 재료·내용물에 `prep_cut`(도마 baked-in anchor)을 써서 조리 화면에 도마가 나오던 문제 → 투입물을 **추상 재료 칩(색 도형 5색)** 으로, 조리 표면을 **조리도구(냄비/팬/그릴/김발/그릇, 도마 아님)** 로 변경. 칩이 도구에 쌓였다가 탭 판정 시 **완성 요리로 cross-fade**. (무-조리도 method_tool 사용 → cutting_board 참조 0)
  - **(결과화면 구도)** 엄마 리액션이 "Ramyeon" 글자와 중첩 → **세로 구도 재정렬**: 음식 이름(상단) → 완성 요리(중앙) → **시식 리액션 → 별점 → 점수**(하단에 인접 배치). 리액션과 점수가 붙어 "점수=리액션" 관계가 읽힘. 겹침 제거.
- **왜**: 조리 단계 시각 정합(도마 부재) + 결과 가독성/구도. 점수 100%↔엄마 만족 표정 인접 요청.
- **결과/다음**: preflight 248 PASS. F5 재실행. 남은 트랙(art/디자인): 재료별 개별 스프라이트(칩=추상), 정식 5가게 쇼핑. 패치: `stage_timing.gd`(칩 투입·도구표면·완성 cross-fade) / `result_screen.gd`(세로 구도).

---

## [2026-06-01] alpha 피드백 4차 — 조리과정 시퀀스 + 조리화면 스택 정리 + 글자 대비 + 리액션 동적화

- **무엇** (실플레이 피드백):
  - **(조리 과정 동적화)** Stage 2C에 **재료 투입 시퀀스** 신설 — 준비된 재료가 조리도구로 차례로 떨어지며(낙하+squash+사운드) 내용물이 점점 차오르고(alpha·scale 증가), 투입 끝나면 타이밍 바 등장, 탭 판정 후 **손질재료→완성요리 cross-fade**. round_controller가 ShoppingRegistry 재료 수 전달(최대 4). `StageTiming._run_assembly/_drop_ingredient`.
  - **(#1 조리화면 스택 정리)** 가스레인지+도구+그릇+접시 다층 중첩 → **단일 조리 표면(가열=도구 / 무조리=도마) + 내용물 1개**로 단순화. "그릴 위 팬 위 그릇" 이상함 해소.
  - **(#4 글자 대비)** 베이지 배경에 흰 글자 안 보임 → 전 화면 라벨 **다크(#2D1D14)** 색 적용(food_select/stage_prep/method/timing/shop/result).
  - **(#3 리액션 동적·표정 변화)** "너무 동적"→차분 과교정→"너무 정적" 재피드백 반영. **평온한 얼굴(★1) → 별점 표정으로 변화**(텍스처 swap + 부드러운 scale) + 접시·리액션 **idle 호흡 loop**(연속). 싸구려 바운스 대신 매끄러운 SINE/연속 모션.
- **왜**: 조리 과정 가시화(원 디자인 "재료 차례 투입") + 가독성 + 동영상 같은 생동감.
- **결과/다음**: preflight 248 PASS. F5 재실행. 남은 큰 트랙(사용자 확인): **#2 재료별 개별 스프라이트**(현재 투입 토큰=손질재료 1종 재사용) / **#5 정식 5가게 방문 쇼핑**(현재 단일화면 다중선택) — art/디자인 sprint 필요. 패치: `stage_timing.gd`(투입 시퀀스·스택 정리·라벨색) / `result_screen.gd`(리액션 변화·idle) / `stage_prep/method/shop·food_select`(라벨색) / `round_controller.gd`(재료수 전달).

---

## [2026-06-01] 픽스 — Stage 2A 칼 중복/도마 중첩 제거 + stray char(f) 수정

- **무엇**: 실플레이 스크린샷에서 Stage 2A "그림 이상" = **칼 2개**(절차적 칼 + `cutting_board.png` 아트에 그려진 누운 칼) + **도마 중첩**(배경 도마 + 재료 anchor 자체 도마). 
  - 배경 `cutting_board.png` 제거 — 재료 whole/cut anchor가 이미 도마 위 구성이라 별도 배경 도마 불필요(칼 중복 주원인 해소). 칼질 충격은 도마 대신 **재료 흔들림**으로 변경. 절차적 칼 1개만 애니메이션.
  - `stage_prep.gd` 61행 stray `f` 제거(syntax error).
- **왜**: 칼/도마 중복으로 prep 화면이 어수선. anchor에 도마가 baked-in인 점 반영.
- **결과/다음**: preflight 248 PASS. F5 재실행 시 prep 화면 = 재료(도마 포함 anchor) + 단일 애니 칼. 남은 가능성: 일부 재료 anchor에 좌측 static 칼이 baked되어 있으면 여전히 미세 중복 → 그 경우 board-less 재료 아트(art sprint) 필요. 패치: `stage_prep.gd`.

---

## [2026-06-01] alpha 피드백 3차 — 난이도 progression + 조리/서빙/시식 연출 + 칼질 개선

- **무엇** (실플레이 피드백 4건, 절차적 연출 — 전용 아트는 후속):
  - **(#1) 난이도 progression**: food_select를 tier·difficulty_score **오름차순(쉬움→어려움) 정렬** + 난이도 배지(●●●○○). "Play in Order(Easy→Hard)" 버튼 + 결과 화면 **Next ▶**로 다음(더 어려운) 음식 진행. RoundController.sequence(정렬된 경로) + `_next_food_path()`.
  - **(#2) 조리되는 모습**: Stage 2C에서 도구/도마 위에 음식이 **raw(cut)→cooked(plated) cross-fade**(천천히 익음). round_controller가 prep_cut(raw) 전달.
  - **(#3) 서빙 + 시식 리액션**: 결과에서 완성요리 **서빙 scale-in(bounce)** + 먹는 사람 리액션이 별점 맞춰 **pop-in(표정 reveal)** + sting_finish 동기. (중복 sting 제거)
  - **(#4) 칼질 연출 개선**: 칼을 **날+날끝 하이라이트+손잡이** 폴리곤으로 형태화 + 찹 모션에 약간의 회전, 탭마다 **도마 흔들림 + 칼 스케일 팝 + 칩 파티클 5개 + 재료 점진 절단(whole→cut 단계 reveal)**. (전용 칼 스프라이트는 art 후속)
- **왜**: alpha 3차 피드백. "맛" 살리는 연출 + 난이도 곡선.
- **결과/다음**: preflight 248 PASS. **F5 재실행**. 라면(쉬움)→갈비(어려움) 순서, 조리 중 음식이 익고, 서빙·표정 연출, 칼질이 덜 단편적. 남은 placeholder: 전용 칼/조리단계/리액션 표정 프레임 아트, raw→cooked는 plated 1장 cross-fade(중간 단계 art 후속). 패치: `food_select.gd`·`round_controller.gd`(progression/sequence) / `stage_timing.gd`(raw→cooked) / `result_screen.gd`(서빙·리액션·Next) / `stage_prep.gd`(칼질).

---

## [2026-06-01] alpha 피드백 2차 — 장보기 다중선택 재설계 + 무-조리 가스레인지 제거 + 제목 센터

- **무엇** (실플레이 피드백 5건):
  - **(#1) 장보기 다중선택 재설계**: 1택 → **여러 재료 골라담기**(학습형). `tools/gen_shopping_from_csv.py`로 ingredients `used_in_foods` 역산 → `scripts/gameplay/shopping_registry.gd`(food_id→정답 재료 name_en, basic_pantry 제외 / POOL 40). StageShop = 토글 그리드(정답 최대5+디스트랙터, 총 8) + Confirm, 정답 초록/오답 빨강/놓친정답 노랑 피드백.
  - **(#2,#5) 재료 이미지 mismatch 제거**: 기존 distractor가 타 음식 prep 스프라이트를 빌려 이름↔이미지 어긋남(Tofu→호박, Pancake Mix→단무지). 장보기를 **텍스트 기반**으로 전환해 근본 해소(재료별 전용 스프라이트는 art 후속).
  - **(#3) 무-조리 음식 가스레인지 제거**: Stage 2C가 모든 음식에 가스레인지 표시 → 김밥(roll)·비빔밥(mix)·잡채 toss 등 NO_COOK은 **도마 base + 완성요리**로, 가열식만 가스레인지+스팀. round_controller가 correct_method_id 전달.
  - **(#4) 메뉴 제목 센터 이탈**: `PRESET_TOP_WIDE`+size를 _ready 시점 부모 크기 확정 전 적용해 offset 오산 → 앵커 프리셋 제거하고 **절대 박스(0~1080)** 로 중앙 정렬.
- **왜**: 첫 실플레이 alpha 2차 피드백. 장보기를 "들어가는 재료 학습" 본래 의도대로 강화 + 시각 오결(가스레인지/이미지) 정리.
- **결과/다음**: preflight 248 PASS. **Godot 재실행(F5)**. 장보기 = 음식별 실제 재료 다중선택. 남은 placeholder: 재료별 개별 스프라이트(현재 텍스트) / 장보기 정식 5가게 순회 / 장보기 점수 별점 미반영(게이트). 패치: `tools/gen_shopping_from_csv.py`·`shopping_registry.gd`(신설) / `stage_shop.gd`(다중선택) / `stage_timing.gd`(NO_COOK 분기) / `round_controller.gd`(shop·method 전달) / `food_select.gd`(제목).

---

## [2026-06-01] 폴리시 픽스 — 조리법 4카드 레이아웃 + 타이밍 난도(왕복·존) + 장보기/제목 stale 확인

- **무엇** (실플레이 피드백 4건):
  - **(실버그) 조리법 카드 화면 넘침**: stage_method 4카드(T2) 시 total 1136px > 1080 → **반응형 카드 폭**(`min(280, avail/n)`, margin/gap 반영)으로 항상 화면 안. font 44→40.
  - **(실버그) 타이밍 너무 느림/쉬움**: 인디케이터가 cook_time(5~18s) 1회 통과라 중앙 맞추기 쉬움 → **난도(difficulty_score) 기반 좌↔우 왕복(ping-pong)**으로 변경. sweep 편도 2.0s(쉬움)~0.85s(어려움), PERFECT 폭 0.12~0.05로 좁아짐. round_controller가 `difficulty_score` 전달. 무탭 timeout = 4왕복.
  - **(stale 확인) 비빔밥/잡채 당근 2회**: 현재 코드는 hero=Carrot이면 DISTRACTOR_POOL의 Carrot을 name으로 dedup → 중복 없음(검증). 직전(무-dedup) 빌드 잔상.
  - **(stale 확인) 조리법 제목이 "끓는 타이밍…"**: 현재 method 제목 = "How do you cook it?"(영어), timing = "Catch the right moment!"로 분리 확인. 재import 전 옛 빌드.
- **왜**: 첫 실플레이 alpha 피드백. 실버그 2건 즉시 수정, stale 2건은 재실행으로 해소.
- **결과/다음**: preflight 248 PASS. **Godot에서 완전 재실행 필요**(스크립트 reload — 실행 중이었다면 정지 후 F5, 또는 Project→Reload Current Project). 난도별 체감: 라면(d1) 느긋, 갈비(d5) 빠르고 좁음. 패치: `stage_method.gd`(레이아웃) / `stage_timing.gd`(왕복·난도) / `round_controller.gd`(difficulty 전달).

---

## [2026-06-01] W2 폴리시 — UI 전체 영어화 + 장보기/요리/시식 비주얼 (실플레이 피드백 반영)

- **무엇** (사용자 실플레이 피드백: "영어로, 구매·요리·시식 모습 없음"):
  - **UI 전체 영어화**: stage_shop/prep/method/timing + result_screen + food_select 표시 문자열 영어 전환. 음식/재료/조리법 = `name_en`(FoodDefinition/IngredientDefinition) + METHOD_LABEL(Boil/Stir-fry…). round_controller가 shop·result에 name_en 전달. UI 표시 문자열 한글 0 검증.
  - **장보기 비주얼**: StageShop 선택지를 텍스트→**재료 이미지 버튼**(Button.icon = whole 스프라이트). 정답=hero whole, 오답=타 음식 whole(DISTRACTOR_POOL: Carrot/Tofu/Garlic/Fish Cake/Green Onion) → 정답 재료와 중복 회피. "물건 구매" 느낌.
  - **요리 비주얼**: StageTiming에 **가스레인지 base(TOOL-01) + 조리도구 vessel + 스팀 VFX**(steam_swirl, Tween 무한 펄스) 추가. "요리하는 모습".
  - **시식 비주얼**: 가족 리액션 anchor(어머니 star1/2/3 v3) import → ArtRegistry.REACTION + reaction(stars), result_screen에 **별점별 리액션 스프라이트** 표시. "시식/반응".
- **왜**: 글로벌 K-food 타깃(영어) + 3-scene 정서(구매→요리→시식) 시각 표현 부재 해소.
- **결과/다음 단계**:
  - **검증**: preflight 248건 PASS(리액션 3경로 포함), 리액션 3장 import, UI 한글 0. (실행 확인은 사용자 F5.)
  - **남은 placeholder**: 장보기는 여전히 1택 게이트(정식 5가게 순회는 Scene 1 트랙) / 리액션은 어머니만(아버지 anchor 보유, 후속 다양화) / 스팀은 전 조리법 공통(볶기·튀기기별 VFX 분기는 후속) / 음식 한글명은 데이터엔 유지(name_ko), 표시만 영어.
- **패치 파일**: `scripts/gameplay/{stage_shop,stage_method,stage_prep,stage_timing,result_screen,round_controller}.gd` + `scripts/ui/food_select.gd` + `tools/import_art_to_godot.py`(REACTION) + `scripts/gameplay/art_registry.gd`(REACTION) + `art/sprites/reaction/star{1,2,3}.png` + `CHANGELOG.md`

---

## [2026-06-01] 버그픽스 — 오토로드 6종 class_name 충돌 제거 (에디터 첫 실행 parse error)

- **무엇**: Godot 4.6 에디터 첫 실행 시 `Parser Error: Class "RemoteConfigManager" hides an autoload singleton.` (remote_config_manager.gd:12). 부트스트랩 때 만든 6개 매니저(remote_config/save/ads/iap/analytics/game_manager)가 **오토로드 이름과 동일한 `class_name`**을 선언해 충돌. Godot 4는 autoload 이름 == global class_name을 금지.
- **수정**: 6개 autoload 스크립트에서 `class_name XxxManager` 줄 제거 (오토로드는 이름으로 접근하므로 불필요). audio_manager.gd는 처음부터 class_name 없어 무관. 잔존 class_name(RoundController/ArtRegistry/SfxRegistry/*Definition/Stage* 등) = 오토로드와 비충돌 확인.
- **왜**: 잠복 버그(원 부트스트랩, AAB smoke 빌드에선 미검출) → 실플레이(사용자 1번 선택) 첫 실행에서 노출. 정적 프리플라이트로는 못 잡는 런타임/parse 류.
- **결과/다음**: 재실행(F5) → 다음 에러 있으면 보고. 패치: `scripts/autoload/{remote_config,save,ads,iap,analytics,game}_manager.gd`.
- **2차 픽스 (동일 실행)**: `stage_prep.gd` `var nearest := round(...)` / `var phase := fmod(...)` → Godot 4에서 `round()`/`fmod()` 등은 Variant 반환이라 `:=` 추론 실패("Cannot infer type") → 명시적 `: float`로 수정. 에러 8건은 `nearest` 추론 실패의 연쇄. 전 스크립트 `:=` 전수 점검 = 나머지 안전(`.new()`/typed 반환).

---

## [2026-06-01] Sound — 외부 CC0 음원 인제스트 완료 (10/12 슬롯 교체, sting 2 합성 유지)

- **무엇** (art-director): 사용자가 `_dropbox/`에 CC0 음원 투입 → Claude가 파일명 보고 슬롯 매핑 → `ingest_sfx.py --dropbox`로 변환·배치.
  - **Kenney Interface Sounds (CC0) 7슬롯**: tick_001/002→metro_strong/weak, confirmation_001/002→judge_perfect/good, error_004→judge_miss, select_001→ui_select, bong_001→act_done.
  - **freesound CC0 3슬롯**: spanrucker/272220→act_chop, BenjaminNelan/353124→act_stir, monsterthing/456382→act_boil (각 30/25/14s → 0.8s 트림).
  - **sting_start/finish 2슬롯**: CC0 koto 미확보 → **합성(Karplus-Strong 가야금) 유지**(보류).
  - 전 슬롯 16-bit/44.1kHz mono 검증 PASS(12/12). `_dropbox/mapping.txt`로 재현 가능. SOURCES.md §4 매니페스트 기록(출처·작성자·CC0).
- **왜**: 합성 톤("전자음") 대체. 외부 다운로드는 사용자, 분류·변환·배치·검증은 Claude 분업.
- **결과/다음 단계**: 레지스트리·AudioManager·배선 무변경(파일만 교체) → 즉시 게임 반영. 미리듣기 `kfood_sfx_preview.wav` 재생성(20.4s). 청감 확인 후 개별 슬롯 교체 가능(예: act_done=bong_001 0.12s 짧음 → glass 계열 대안 / act_chop 0.8s가 단일 타격 아닐 수 있음 → 구간 재트림). sting CC0 확보 시 교체.
- **패치 파일**: `godot-project/audio/sfx/{metro_strong,metro_weak,judge_perfect,judge_good,judge_miss,act_chop,act_stir,act_boil,act_done,ui_select}.wav` 교체 / `_dropbox/mapping.txt` 신설 / `SOURCES.md` §4 / `tools/ingest_sfx.py` 드롭박스 모드 / `CHANGELOG.md`

---

## [2026-06-01] Sound — 외부 CC0 전환 착수 (합성본 아카이브 + ingest 파이프라인 + SOURCES 큐레이션)

- **무엇** (art-director + godot-dev):
  - **방향 전환**: 코드 합성(synth v1 사인 → v2 물리모델)이 여전히 "전자음" 피드백 → **외부 무료 CC0 음원으로 전면 교체** 결정. 합성 12종을 `godot-project/audio/sfx/synth_v2_archive/`로 보관(레지스트리·배선·키 유지).
  - **인제스트 파이프라인** `tools/ingest_sfx.py` — `_incoming/<slot_key>.*`(임의 포맷) → ffmpeg 트림(≤0.8s)·-14 LUFS 정규화·페이드·**16-bit PCM 44.1kHz mono** → 슬롯 wav 덮어쓰기. 누락 슬롯은 "보류"(합성본 유지)로 자동 처리. `tools/make_sfx_preview.py` 분리(미리듣기 재생성).
  - **`godot-project/audio/sfx/SOURCES.md`** — CC0 정책 + 소스 우선순위(Kenney CC0 > freesound CC0필터 > OGA CC0 > Pixabay⚠️) + 12슬롯 후보 검색 링크 + 다운로드 매니페스트 표 + 검증 체크리스트.
  - **라이선스 nuance 확인**: Pixabay = "Pixabay Content License"(무귀속·상업 OK)로 **엄밀히 CC0 라벨 아님** → 정책상 Kenney(명시 CC0)·freesound CC0필터·OpenGameArt CC0 우선.
- **왜**: 합성 톤으로는 따뜻·전통 주방 질감 한계. 무료 CC0 실음원이 현실적 해법. 사용자 정책(CC0만/무료만) 명시.
- **결과/다음 단계**:
  - **환경 제약**: Claude는 외부 바이너리 오디오를 작업공간에 직접 다운로드 불가(웹툴=텍스트만, curl/wget 정책 금지) → **다운로드는 사용자 단계**로 분업.
  - **사용자 액션**: SOURCES.md §3 링크에서 CC0 음원 받아 `_incoming/`에 슬롯 key 이름으로 저장 → Claude가 ingest + preview 재생성.
  - sting(가야금) 슬롯이 CC0에서 가장 희소 가능 → 막히면 해당 슬롯만 합성본 유지.
- **패치 파일**: `tools/ingest_sfx.py` + `tools/make_sfx_preview.py` — **신설** / `godot-project/audio/sfx/SOURCES.md` — **신설** / `synth_v2_archive/` 12 wav 보관 / `CHANGELOG.md` — 본 entry
- **참고**: 직전 합성 entry(아래)의 배선·레지스트리·AudioManager는 그대로 유효 — 파일만 교체.

---

## [2026-06-01] Sound sprint #1 — 핵심 SFX 12종 코드 합성 + AudioManager + 라운드 루프 배선

- **무엇** (art-director sound 겸직 + godot-dev):
  - **톤 명세 선행** (사용자 "톤이 컨셉과 맞아야" 제약): art-style-guide v1.2 + GDD에서 톤 키워드 추출 → north star "따뜻한 한식 주방·시장 양식화 추상 톤(나무 박·놋종·옹기·보글·평조)". 사용자 "더 따뜻게/전통적으로" 선택 반영. `docs/sound-guide.md` v0.1 신설(의도↔실측 centroid 검증표 + 트리거 매핑).
  - **`tools/gen_sfx.py` 신설** — numpy 파형 합성(결정적). 12 WAV(16-bit/44.1kHz mono, 0.07~0.65s): 메트로놈2(metro_strong/weak) + 판정3(judge_perfect/good/miss) + 액션4(act_chop/stir/boil/done) + UI3(ui_select/sting_start/sting_finish). raised-cosine soft attack(공격 transient 금지) + lowpass 고역 roll-off + tanh warm sat + 평조 5음계 sting. **`scripts/audio/sfx_registry.gd` 자동 생성**(key→res 경로).
  - **AudioManager 오토로드** `scripts/autoload/audio_manager.gd` — AudioStreamPlayer 풀(8) round-robin + 스트림 캐시 + `muted` 토글. SfxRegistry 기반 `play(key)`. project.godot autoload 등록.
  - **라운드 루프 배선** — 시작/종료 sting, Stage 2A 메트로놈(4박 1마디)+칼질+판정, Stage 2B 조리법 정답/오답, Stage 2C 조리 ambient(보글/쓱)+판정, 완성 종, 메뉴/버튼 ui_select. **레지스트리 방식 유지(하드코딩 경로 0)**.
- **왜**: 리듬 타이밍 게임의 핵심 피드백(박자감·판정감) 부재 해소. "재미 검증"을 사운드 포함 상태로 가능하게. 사용자 sound sprint #1(코드 합성) 지시.
- **결과/다음 단계**:
  - **검증 완료**: 12 WAV 실파일 + 헤더(ch1/2B/44100) 정합 / centroid 따뜻 톤(대부분 ≤2kHz, act_boil 314Hz) / play 호출 키 12종 전부 레지스트리 존재(누락 0) + 12종 전부 사용(orphan 0) / 오토로드 등록 확인.
  - **사용자 검증**: Godot 4.6 에디터 열기 → WAV import 자동 → F5 플레이로 청감 확인.
  - **후속(sprint #2)**: BGM(시장/키친 loop) / 별점 차등 jingle / act_chop transient 추가 완화 / DIP·MAR 전용 prep 사운드 / 옵션 음소거 토글 UI.
- **패치 파일**:
  - `tools/gen_sfx.py` — **신설** / `godot-project/audio/sfx/*.wav` — **신규 12** / `scripts/audio/sfx_registry.gd` — **자동 생성**
  - `scripts/autoload/audio_manager.gd` — **신설**, `project.godot` autoload 등록
  - `scripts/gameplay/{round_controller,stage_prep,stage_method,stage_timing,result_screen}.gd` + `scripts/ui/food_select.gd` — play 배선
  - `docs/sound-guide.md` — **신설 v0.1**
  - `CHANGELOG.md` — 본 entry

---

## [2026-05-31] M2 W2 — 12음식 전체 플레이어블 일반화 + 음식 선택 메뉴 + 아트 레지스트리

- **무엇** (godot-dev):
  - **아트 반입 파이프라인 완성** `tools/import_art_to_godot.py` — M1 LOCK anchor를 food_id 기준 clean name으로 godot-project/art/에 복사(45파일) + **`scripts/gameplay/art_registry.gd` 자동 생성**(food_id/method → res:// 경로 dict + static helper). 음식 완성샷(최신/최선 버전 picker) + Stage 2A prep whole/cut(**CSV prep_ingredient 기준**, F번호 불일치 케이스 명시 매핑: 잔치국수=대파, 순두부=애호박, 콘도그=치즈 placeholder) + method→조리도구 vessel.
  - **round_controller 일반화** — 라면 하드코딩 dict(INGREDIENT_SPRITES/FOOD_SPRITES) 제거 → ArtRegistry 사용. `class_name RoundController` + `static var pending_food_path`로 메뉴→라운드 음식 주입. **12음식 모두 동일 루프로 플레이 가능**.
  - **stage_timing 일반화** — 하드코딩 냄비 제거 → method별 조리도구 vessel 스프라이트(setup 3번째 인자).
  - **음식 선택 메뉴** `scripts/ui/food_select.gd` + `scenes/food_select.tscn` — 12 FoodDefinition 로드해 2열 그리드 버튼(이름·Tier·인분), 탭 → 해당 음식 라운드 진입. **main_scene = food_select.tscn**. 결과 화면에 "메뉴로" 버튼 추가.
- **왜**: W1 라면 단일 → MVP 12음식 전체 콘텐츠 플레이 가능 상태로 확장. "재미 검증"을 전 음식에서 가능하게. 사용자 W2 진행 선택.
- **결과/다음 단계**:
  - **검증 완료**: art_registry 45 경로 전수 실파일 존재 + 하드코딩 잔존 0 + 12음식 .tres↔아트 정합. (Godot 에디터 실행 검증은 사용자 환경 필요 — main_scene=food_select.)
  - **사용자 검증**: Godot 4.6 에디터 열기 → F5 → 음식 12종 중 선택 플레이.
  - **알려진 placeholder/한계**: 일부 완성샷 미LOCK(라면 v3/galbi v8 등 reroll 후보) / 칼·timing bar 도형 placeholder / **사운드 없음**(BPM 메트로놈·SFX = art-director sound sprint, 리듬게임 핵심 → 우선순위 ↑) / Scene 1 다점포 미구현(1택 게이트) / DIP·MAR special 모션 미구현(generic rhythm tap 대체) / W1 임시 아트 일부 중복 잔존(미참조, 무해).
  - **W3 후보**: 사운드(BPM 메트로놈+SFX) / Scene 1 정식 다점포 / 아트 anchor LOCK 확정 swap / 매니저(Save·Analytics) 실구현 + 라운드 결과 영속화.
- **패치 파일**:
  - `tools/import_art_to_godot.py` — **신설**
  - `godot-project/scripts/gameplay/art_registry.gd` — **자동 생성**
  - `godot-project/scripts/gameplay/round_controller.gd` — 일반화 + class_name + static 주입
  - `godot-project/scripts/gameplay/stage_timing.gd` — 조리도구 vessel 인자
  - `godot-project/scripts/ui/food_select.gd` + `scenes/food_select.tscn` — **신설**
  - `godot-project/scripts/gameplay/result_screen.gd` — 메뉴 버튼
  - `godot-project/art/sprites/{food,ingredient,tool}/*.png` — 12음식 아트 45파일
  - `project.godot` — main_scene = food_select
  - `CHANGELOG.md` — 본 entry

---

## [2026-05-31] M2 W1 — 라면 수직 슬라이스 구현 (장보기→2A→2B→2C→결과 end-to-end, 절차적 GDScript)

- **무엇** (godot-dev):
  - **라면 round end-to-end 플레이어블 슬라이스** — `.tres`(t1_002)를 실제 소비하는 첫 게임 루프. Scene 1 장보기(간이) → Stage 2A 재료준비(rhythm tap) → Stage 2B 조리방법 선택 → Stage 2C 타이밍 → 결과(별점) 순차 실행.
  - **신규 스크립트 6종** (`scripts/gameplay/`): `round_controller.gd`(오케스트레이터, 가중평균 prep0.20/method0.30/timing0.50 → 1~3별) + `stage_shop.gd`(StageShop) + `stage_prep.gd`(StagePrep, 칼 BPM oscillation + perfect±80ms/good±200ms 판정 + whole→cut cross-fade) + `stage_method.gd`(StageMethod, method_options 셔플 + 오답 시 정답 highlight=decisions A3 C안) + `stage_timing.gd`(StageTiming, 좌→우 sweep + PERFECT 중앙10%/good30%) + `result_screen.gd`(ResultScreen, 별점+점수분해+재시작).
  - **신규 씬** `scenes/round_demo.tscn` + `project.godot run/main_scene` → round_demo로 변경(테스트용; 정식 진입점은 후속 교체).
  - **Resource 스키마 확장** (W1 prerequisite): `food_definition.gd`에 prep_*(4) + correct_method_id + method_options 6필드, `ingredient_definition.gd`에 is_basic_pantry + cut_variations + distractor_weight range 0~3.
  - **UI 절차적 생성**: Godot Editor 없이도 구조 검증 가능하도록 각 Stage가 _ready에서 노드 구성. 1080×1920 좌표.
- **왜**: 설계→코드 최대 공백 해소의 핵심 단계. "재미 검증"이 가능한 최소 플레이어블 루프 확보. 사용자 "파이프라인 → 수직 슬라이스" 방향.
- **결과/다음 단계**:
  - **사용자 검증 필요 (제 환경엔 Godot 바이너리 없음)**: Godot 4.6 에디터로 godot-project 열기 → 텍스처 import 자동 생성 → F5 실행. 라면 1라운드 플레이 후 "재미/난도/템포" 피드백.
  - **정적 검증 완료**: 탭 입력 단일화(_unhandled_input + mouse_filter IGNORE, 중복판정 제거), %d-float 캐스팅, await 시그널 반환, class_name 5종, .tres/script 참조 정합.
  - **알려진 단순화/placeholder**: Scene 1 다점포 순회 미구현(1택 게이트, 별점 미반영) / 칼·timing bar는 도형 placeholder(아트 anchor swap 후속) / 라면 완성샷 v3 미LOCK(R3 reroll pending) / 사운드 없음(BPM 메트로놈·SFX = art-director sound sprint) / 양념재우기·콘도그 dip 등 special prep 모션 미구현.
  - **W1 후속 → W2**: cut style 11종 확장 + 음식별 round + 아트 anchor 정식 swap + Scene 1 정식 다점포 + 사운드.
- **패치 파일**:
  - `scripts/gameplay/{round_controller,stage_shop,stage_prep,stage_method,stage_timing,result_screen}.gd` — **신설 6종**
  - `scenes/round_demo.tscn` — **신설**, `project.godot` main_scene 변경
  - `godot-project/art/{sprites,ui,vfx}/*.png` — 라면 범위 스프라이트 17장 반입
  - `CHANGELOG.md` — 본 entry

---

## [2026-05-31] M2 파이프라인 #1 — CSV→.tres 임포터 신설 + Resource 스키마 확장 (76 resource 생성)

- **무엇** (godot-dev, M2 prerequisite 파이프라인):
  - **`tools/gen_resources_from_csv.py` 신설** — docs/*.csv를 읽어 godot-project/resources/ 하위에 Godot 4.x `.tres` 텍스트 resource를 결정적(deterministic)으로 생성하는 재현 가능한 임포터. notes 컬럼 쉼표 보존(split maxsplit), 다중값은 세미콜론, id 기반 결정적 uid 생성. `--check` dry-run 지원.
  - **생성물 76개**: foods 12 + ingredients 45 + cooking_methods 9(boil/grill/stirfry/panfry/deepfry/roll/mix/toss/marinate) + stores 6(produce/meat/seafood/grain/sundry/**pantry**) + timing 4(perfect/good/miss/no_tap, C-4 lock 0.10/0.45/0.45/0.0).
  - **Resource 스키마 확장 (godot-dev)**:
    - `food_definition.gd` — Stage 2A `prep_ingredient_id`/`prep_cut_style`/`prep_bpm`/`prep_taps` + Stage 2B `correct_method_id`/`method_options: Array[StringName]` 6 필드 신설 (scene-2 §7.2 정합, B1 컬럼 import).
    - `ingredient_definition.gd` — `is_basic_pantry: bool`(ADR-007) + `cut_variations: Array[StringName]` 신설. `distractor_weight` range 1→0 시작(basic_pantry=0 정합).
  - **CSV 위생 개선**: foods-database.csv notes 내 쉼표 제거(세미콜론 통일) — 임포터/파서 안정성 확보 (이전 entry의 데이터 위생 follow-up 해소).
- **왜**: 설계가 코드로 옮겨지지 못한 최대 공백(에셋·데이터 파이프라인 단절) 중 데이터 절반을 해소. 12음식·45재료가 CSV로만 존재 → Godot Resource 인스턴스화 완료로 W1(라면 수직 슬라이스) 진입 unblock. 사용자 "파이프라인 먼저 → 수직 슬라이스" 방향 채택.
- **결과/다음 단계**:
  - **검증 완료**: 디스크 76 .tres 형식·타입배열(Array[StringName])·ext_resource 참조·basic_pantry/토큰(DIP-00·MAR-00) 전수 스폿체크 + 무결성 스캔 clean. (Godot 에디터 import 최종 확인은 사용자 환경에서 1회 필요.)
  - **남은 파이프라인 절반 (아트 import)**: assets-raw/transparent_m1 → godot-project/art/sprites/ 배치 + 버전 선택(LOCK 판정). art-director sprint와 함께 진행 권고.
  - **cut_style/cooking_tool 토큰 registry**: 현재 prep params는 FoodDefinition에 보유. CUT-01~06/DIP-00/MAR-00 → cut 스프라이트 매핑 registry는 W1~W2 시 godot-dev 필요 시 신설(현재 토큰→anchor 직접 매핑 가능).
  - **godot-dev W1 착수 가능**: 라면 Scene 1→2A→2B→2C→3.
- **패치 파일**:
  - `tools/gen_resources_from_csv.py` — **신설**
  - `godot-project/scripts/resources/food_definition.gd` — prep_* + method 6 필드
  - `godot-project/scripts/resources/ingredient_definition.gd` — is_basic_pantry + cut_variations + range
  - `godot-project/resources/{foods,ingredients,cooking_methods,stores,timing}/*.tres` — **신규 76개**
  - `docs/foods-database.csv` — notes 쉼표 정리
  - `CHANGELOG.md` — 본 entry

---

## [2026-05-31] 미결 12건 중 핵심 3건 사용자 결정·적용 — B1 method_options 컬럼 + B2 DIP-00/MAR-00 토큰 분리 + C3 CH-01 OFF

- **무엇** (사용자 결정 → game-designer/pm 적용):
  - **B1 승인 → foods-database.csv 적용 완료**: 헤더에 `correct_method_id` + `method_options` 2 컬럼 신설 + 12음식 전부 값 lock. T1=3 후보 / T2=4 후보. 정답(`correct_method_id`)과 후보군(`method_options`, 세미콜론 구분) 분리 — godot Resource 스키마(scene-2 §7.2) 정합. 불고기는 `primary_cooking_method=marinate`(Stage 2A 소화)이나 Stage 2B `correct_method_id=stirfry`로 명시.
  - **B2 승인 (원안 확장) → 토큰 분리 적용 완료**: 사용자 질문("그럼 불고기는?") 반영하여 콘도그·불고기 **둘 다** 칼질이 아님을 명확화. 콘도그 `prep_cut_style` `CUT-00`→**`DIP-00`** (반죽 담그기), 불고기 `CUT-00`→**`MAR-00`** (양념 주무르기). `CUT-00`은 실제 칼질(도마) 전용으로 정리. 메커닉/BPM/tap 수치 변경 없음 (라벨만 분리).
  - **C3 승인 → CH-01 주인공 chibi default OFF 확정**: 조리 화면 VFX(불꽃·김) 시각 집중 + 성능 여유. 토글이라 alpha 후 ON 전환 가능. godot는 `CharacterArea` `visible=false` placeholder.
  - **사실 정정**: 사용자가 "콘도그 빠지고 불고기로 대체된 것 같다"고 했으나, 실제로는 불고기(t2_014)가 **김치찌개(t2_009)를 대체**(2026-05-30 N-2 lock)한 것이고 **콘도그(t1_007)·불고기 둘 다 12종에 존속**. CSV grep으로 확인.
  - 나머지 9건(A1~A6 현행 확정 / C1 손 sprite / C2 옹기 placeholder)은 권고대로 M2 비차단 — 별도 액션 불요.
- **왜**: M2(라면 수직 슬라이스 W1) 착수 unblock. 진성 blocker였던 method_options 데이터 부재 해소 + CUT-00 토큰 충돌(콘도그 dip ↔ 불고기 marinade) 정리로 godot 런타임 분기 명확화.
- **결과/다음 단계**:
  - **데이터 위생 follow-up (godot-dev)**: foods CSV `notes` 필드에 쉼표 포함 주석 존재(예: 불고기 "...marinade bowl, motion-spec §3.3"). CSV→.tres 임포터는 20번째 쉼표 이후 전체를 notes로 처리하거나 notes를 따옴표 처리할 것.
  - **balance-config 명문화 (game-designer)**: Stage 2B 카드 수 규칙(T1=3/T2=4) + DIP-00/MAR-00 토큰을 balance-config/motion-spec에 sync (후속).
  - **남은 의사결정**: B3(Scene2→3 0.5s overlap, godot-dev sync 시 확인) — alpha 비차단.
  - **godot-dev W1 착수 가능**: 라면 Scene 1→2A→2B→2C→3 end-to-end.
- **패치 파일**:
  - `docs/foods-database.csv` — `correct_method_id` + `method_options` 컬럼 신설, 콘도그 `DIP-00` / 불고기 `MAR-00` 토큰, 12음식 notes sync
  - `docs/specs/decisions-pending-m2.md` — B1/B2/C3 결정 결과 반영
  - `CHANGELOG.md` — 본 entry

---

## [2026-05-31] M2 착수 전 미결 확인 12건 통합 — docs/specs/decisions-pending-m2.md 신설 (진성 blocker 1건 식별)

- **무엇** (pm 주도, game-designer + ui-designer sub-agent 권고 통합):
  - **신규 문서 `docs/specs/decisions-pending-m2.md` v0.1** — 누적된 사용자 확인 대기 항목 12건(scene-2-kitchen-layout §6 8건 + 2026-05-31 design sprint CHANGELOG confirm 4건)을 한 문서로 수집·권고·통합. owner·긴급도(🔴 진성 blocker / 🟡 soft / 🟢 unblocked·alpha 후)별 그룹화 + 항목별 맥락/선택지/권고/영향/결정자 + TL;DR 결정 체크리스트.
  - **핵심 발견 (진성 M2 blocker 1건)**: foods-database.csv에 scene-2 §2.2가 전제하는 **`method_options` 컬럼이 실제로 부재** (현재 `primary_cooking_method` + `secondary_method`만 존재, secondary는 2음식만 채워짐). godot Resource 스키마(scene-2 §7.2)가 `method_options`/`correct_method_id`를 요구 → W1 라면 end-to-end 구현 전 컬럼 신설 + 12음식 lock 필요.
  - **나머지 분류**: 🟡 soft blocker 2건 (B2 콘도그 dip `CUT-00`↔불고기 marinade 토큰 충돌 → `DIP-00` 분리 권고 / B3 Scene2→3 transition 0.5s overlap SSOT lock) + 🟢 9건 (placeholder unblock 또는 현행 확정·alpha 후). cook_time_sec(구 #4)은 §3.2에 이미 lock 완료로 확인 — §6 #4 cross-ref 문구만 정정 대상.
- **왜**: 사용자가 "PM + sub-agent 체제로 진행" 지시 + "미결 확인 12건 정리" 선택. M2(게임플레이 코드) sprint 착수 전 의사결정을 한 곳에 모아 blocker를 명확히 분리하기 위함. 12건이 scene-2 §6과 design CHANGELOG에 흩어져 있어 사용자 결정이 지연되던 상태.
- **결과/다음 단계**:
  - **사용자 결정 필요 3건**: B1(method_options 컬럼+12행 승인) / B2(콘도그 `DIP-00` 토큰 분리 승인) / C3(CH-01 chibi default OFF 동의). 나머지 9건은 "현행 확정" 일괄 동의로 닫힘.
  - **game-designer 후속**: foods CSV `method_options` 컬럼+12행 lock, 콘도그 `DIP-00` 토큰, 카드 수 규칙(T1=3/T2=4) balance-config 명문화.
  - **ui-designer/pm 후속**: scene-2 §6 각 항목 결정 결과 반영 + §6 #4 cross-ref 정정.
  - **art-director 미니 sprint**: hand_marinade.png + corndog_batter_bowl.png ($0.08).
  - 이후 **godot-dev W1**(라면 end-to-end) 착수 unblock.
- **패치 파일**:
  - `docs/specs/decisions-pending-m2.md` — **신설 v0.1**
  - `CHANGELOG.md` — 본 entry

---

## [2026-05-31] M2 prerequisite UI sprint — Scene 2 (Kitchen) layout 신설 + components CP-18~22 + screen-flow v0.3 (ADR-005 4-stage)

- **무엇** (ui-designer 3 트랙 sprint):
  - **U1 신규 문서 `docs/ui/scene-2-kitchen-layout.md` v0.1** — Scene 2 안의 sub-flow 3종 (Stage 2A/2B/2C) layout detail spec (1080×1920 portrait, one-thumb zone, Y 좌표 절대값 / pixel anchor / transition timeline / godot-dev Scene tree). Stage 2A 도마 (Y 1100~1450 X 240~840 one-thumb) + Knife indicator (Y 900~1150 translation, **Option 1 motion lock** = Y position only, AnimationPlayer "knife_loop" + BPM speed_scale, perfect ±80ms Gold halo). Stage 2B 가스레인지 (Y 600~1000) + 도구 카드 3~4 (Y 1100~1500). Stage 2C timing bar (Y 1150~1280 full width) + tap area (Y 1380~1620). Kitchen rack (Y 130~340 X 820~1060). 양념재우기 variant (불고기/갈비구이) Kitchen rack arc motion 정합. CH-01 chibi optional (우측 하단). transition timeline 4종 (2A→2B 1.0s slide / 2B→2C 0.3s fade / 2C→Scene3 1.5s "서빙"). Decisions K2-01~10 + Confirm 8건.
  - **U2 `docs/ui/components.md` v0.2 → v0.3 갱신** — **CP-18~22 5종 신설**:
    - **CP-18 도마 (cutting_board.tscn)** — Stage 2A tap target, CUT-00 art anchor, 전체 영역 단일 Button, perfect/good/miss hit 상태 + chunk particle.
    - **CP-19 Knife indicator (knife_indicator.tscn)** — 위↕아래 motion (Y 900~1150 translation only, Option 1 motion lock), AnimationPlayer "knife_loop" + `set_bpm(bpm)` → speed_scale 조정, perfect ±80ms Gold glow halo, `signal knife_hit_bottom` (CuttingBoard와 timing sync).
    - **CP-20 Tool sprite (tool_sprite.tscn)** — TOOL-01~12 generic swap layer, Stage 2B 카드 → 2C dock Tween arc motion (0.4s, scale 240→400), CP-04 (cooking_tool_slot)과 분리된 순수 sprite layer.
    - **CP-21 Timing bar (timing_bar.tscn)** — Stage 2C 게이지 (Y 1150~1280 full width 960×130px), 5 구간 (miss 60% / good 30% / PERFECT 10% or 20%), 인디케이터 Tween linear, perfect ±80ms 변환 공식 명시 (balance-config §6 sync), Gold halo pulse 1Hz, **기존 §5 Timing bar deprecation alias**.
    - **CP-22 Kitchen rack (kitchen_rack.tscn)** — basic_pantry 5종 옹기 (Y 130~340 X 820~1060), **interactive X (visual cue only, ADR-007 정합)**, Stage 2A fade-in / 2B·2C dim 50% / 양념재우기 highlight + arc Tween, 옹기 5종 sprite는 Post-M1 art-director sprint pending (MVP placeholder = ingredient_card 5개 mini).
    - §16 Z-order에 Kitchen rack(80) + Stage 2A/2B/2C 영역(50) + 캐릭터(40) 신규 layer. Decisions CP-06~10 + Confirm #6~10.
  - **U3 `docs/ui/screen-flow.md` v0.1 → v0.3 갱신** — ADR-005 4-stage 정합:
    - §2 Round 다이어그램 4-stage 재작성 (Scene 2 안에 Stage 2A/2B/2C sub-flow + Kitchen rack + Skip Rewarded).
    - §2.1 광고 트리거 표 **Stage 2A "재료 준비 Skip" Rewarded 신규 위치** + Stage 2C 표기 sync (총 Round당 3 Rewarded slot).
    - §4 Scene 2 sub-flow 전면 재작성 (§4.0 공통 + §4.1 Stage 2A + §4.2 Stage 2B + §4.3 Stage 2C, 상호작용 + transition 명시).
    - §6.1A Kitchen rack 신규 + §6.2 하단 액션 바 Stage 2A/2B/2C 행 신규.
    - §7 전이 매트릭스 Stage 2A→2B (1.0s slide parallel) + 2B→2C (0.3s fade, Scene 유지) 행 신규.
    - Decisions **SF-07~10 신설** (Scene 2 sub-flow / Stage 2A Skip 광고 / transition timing / Kitchen rack 항상 표시).
  - **CHANGELOG.md** — 본 entry.
- **왜**: M2 godot-dev sprint (Scene 2 키친 Godot scene tree 구현) prerequisite. ADR-005 4-stage mechanic이 cooking-mechanics v0.6에 lock + 같은 날 game-designer가 motion-spec.md / foods CSV prep_* / balance-config v0.4 BPM lock 완료 → UI layer만 미명세 상태였음. screen-flow v0.1은 3-stage 그대로 + Scene 2 안의 sub-stage 좌표/transition/Kitchen rack 위치가 미명세 → godot-dev가 scene 구조 의사결정 불가능 상태. 또한 art LOCK 완료 (CUT-00 + CUT-01~06 + TOOL-01~12 + ING-01~12 whole + ICUT-01~12 cut = 49+ anchor, art-anchor-rubric v1.21)된 상태라 UI prefab/Scene 구조 lock 시 즉시 godot-dev 구현 진입 가능. **Option 1 motion lock** (사용자 confirm 2026-05-31, Godot AnimationPlayer Transform animation only, frame art 추가 0건)을 모든 motion 컴포넌트 (Knife indicator / Tool sprite / Kitchen rack arc)에 일관 적용 → low cost + GDScript only ADR-004 정합.
- **결과/다음 단계**:
  - **godot-dev M2 sprint 후속 (즉시 구현 가능)**:
    - 신규 Scene 7종 생성: `scenes/ui/cutting_board.tscn` (CP-18) / `scenes/ui/knife_indicator.tscn` (CP-19) / `scenes/ui/tool_sprite.tscn` (CP-20) / `scenes/ui/timing_bar.tscn` (CP-21) / `scenes/ui/kitchen_rack.tscn` (CP-22) / `scenes/scene_2_kitchen.tscn` (root composition) / `scripts/ui/scene2_transition.gd` (Stage 2A↔2B↔2C controller).
    - 신규 Resource 스키마 2종: `resources/cut_style/{cut_id}.tres` (CutStyleResource — bpm / tap_count / cut_sprite_id / audio_id) + `resources/cooking_tool/{tool_id}.tres` (CookingToolResource — texture / display_name / audio_id / cooking_vfx_id) — game-designer D2 CSV 컬럼과 sync.
    - 기존 `resources/food/{food_id}.tres` 확장 (D2 foods CSV prep_* 컬럼 import).
    - AnimationPlayer keyframe 5종: "knife_loop" (Y position, BPM speed_scale) / "dock_motion" (Tween arc) / "halo_pulse" (Gold glow 1Hz) / "fade_in" (Kitchen rack) / "arc_to_marinade" (옹기 → marinade bowl).
    - 의존 art lock 확인: CUT-00 + CUT-01~06 + TOOL-01~12 + ING-01~12 + ICUT-01~12 (49+ anchor, 모두 LOCK 완료) — 즉시 Sprite2D 노드 import 가능. **옹기 5종 (Kitchen rack)은 Post-M1 art-director pending** → MVP placeholder = ingredient_card.tscn 5개 mini 임시 사용.
  - **art-director Post-M1 sprint**:
    - 옹기 5종 individual sprite (간장 옹기 / 고추장 옹기 / 설탕 단지 / 참기름 호리병 / 소금 항아리) — CP-22 Kitchen rack 시각 identity lock 후 swap.
    - 양념재우기 손 sprite (motion-spec.md §3.3 hand_marinade + §3.10 corndog_batter_bowl 미니 sprint와 합쳐서 진행) — 현재 MVP fallback은 CP-19 칼 motion 재사용.
  - **qa-tester M2 후반 sprint**:
    - Scene 2 transition timing 검증 (2A→2B 1.0s slide, 2B→2C 0.3s fade, 2C→Scene3 1.5s).
    - Stage 2A Knife indicator BPM 60~140 전 range에서 perfect ±80ms hit 가능한지 검증 (D3 balance-config v0.4 BPM lock 후).
    - one-thumb zone 도달 검증 (Stage 2A 도마 / Stage 2B 카드 / Stage 2C tap area 모두 Y 1100~1700).
    - Kitchen rack interactive X 검증 (사용자 탭 무반응 확인).
    - 양념재우기 variant (불고기 / 갈비구이) Kitchen rack arc motion 시각 검증.
  - **pm 후속**:
    - **확인 사안 8건** (scene-2-kitchen-layout §6): CH-01 표시 ON/OFF default / 양념재우기 손 sprite vs 칼 fallback / Stage 2B 카드 수 / cook_time_sec / Stage 2A miss tap 처리 / Kitchen rack 옹기 sprite / Scene 2→3 transition timing / Stage 2B 오답 자동 배치 UX.
- **패치 파일**:
  - `docs/ui/scene-2-kitchen-layout.md` — **신설 v0.1** (Stage 2A/2B/2C layout detail)
  - `docs/ui/components.md` — v0.2 → **v0.3** (CP-18~22 5종 신설, §5 deprecation alias, §16 Z-order 갱신, CP-06~10 Decisions, Confirm #6~10)
  - `docs/ui/screen-flow.md` — v0.1 → **v0.3** (§2 4-stage 다이어그램, §2.1 광고 표, §4 Scene 2 sub-flow 전면 재작성, §6.1A Kitchen rack, §6.2 액션바, §7 전이 매트릭스, SF-07~10 Decisions)
  - `CHANGELOG.md` — 본 entry

---

## [2026-05-31] M2 prerequisite design sprint — D1 motion-spec.md 신설 + D2 foods CSV prep_* 4 컬럼 + D3 balance-config v0.4 BPM 본격 + D4 ingredients cut_variations + basic_pantry 5 row 검증

- **무엇** (game-designer 4 트랙 묶음 sprint):
  - **D1 motion-spec.md v0.1 신설** (`docs/systems/motion-spec.md`) — ADR-005 Stage 2A/2B/2C tool animation 본격 spec. 12 음식 × 3 stage × 도구 × motion 매핑 (§2 main 표). 9종 AnimationPlayer keyframe spec (§3.1 칼 down-stroke / §3.2 주걱 stir / §3.3 손바닥 marinade press / §3.4 가위 post-launch / §3.5 뒤집개 flip post-launch / §3.6 국자 scoop / §3.7 집게 grip-and-lift / §3.8 김발 roll / §3.9 그릇+주걱 bibim orbit / §3.10 콘도그 batter dip). BPM ↔ cut style ↔ hero ingredient cross-reference (§4). godot-dev 단계적 sprint plan W1~W5+ (§5.3). 사용자 confirm 8건 (§6). **Option 1 motion lock** (사용자 명시 2026-05-31): Godot AnimationPlayer Transform animation only, frame art 추가 0건. 재료 변화 = whole sprite fade-out → cut sprite fade-in.
  - **D1 cooking-mechanics.md v0.6 → v0.7** — §X Motion Spec cross-ref 신설. 본격 spec은 motion-spec.md 분리, 본 문서는 mechanic 룰 + motion 영역 참조만. Asset path 의존성 표 (M1 LOCK 출처 + art-director 미니 sprint 2건 권고: hand_marinade + corndog_batter_bowl).
  - **D2 foods-database.csv prep_* 4 컬럼 신설** — 헤더에 `prep_ingredient_id` / `prep_cut_style` / `prep_bpm` / `prep_taps` 4 컬럼 추가 + 12 음식 모두 row 값 lock. 라면 100 / 떡볶이 100 / 김밥 70 / 김치볶음밥 90 / 해물파전 110 / 콘도그 80 (dip) / 잔치국수 110 / 비빔밥 115 / 잡채 120 / 갈비구이 140 / 순두부찌개 80 / 불고기 60 (marinade).
  - **D2 ingredients-database.csv cut_variations 컬럼 신설** — 헤더에 `cut_variations` 컬럼 추가 (콤마 구분, 예: `CUT-05;CUT-03` = 대파는 송송 + 어슷 둘 다). 41 row 모두 매핑 — primary cut hero + 디자인 대안 cut + cut 메커닉 X (whole 그대로 사용) 명시. basic_pantry 5종 모두 cut_variations 빈 값 (cut 메커닉 X).
  - **D4 basic_pantry 5 row 검증** — 이미 v0.6 C-2 lock 시점에 ingredients CSV에 5 row 모두 존재 (ing_x_003 간장 / ing_x_004 고추장 / ing_x_005 설탕 / ing_x_006 참기름 / ing_x_007 소금). 본 sprint D4는 신규 row 추가가 아닌 cut_variations 컬럼 + used_in_foods 매핑 정합성 검증 (간장 = F-06/08/10/12/14 5음식 / 고추장 = F-03/08 / 설탕 = F-07/12/14 / 참기름 = F-10/12/14 / 소금 = implicit_all).
  - **D3 balance-config.md v0.3.3 → v0.4** — §7.1 음식별 prep_bpm 12음식 전체 매핑 본격 lock (v0.3.2 placeholder 2개 → v0.4 본격 12/12). BPM 분포 검증 표 (T1 평균 94.3 / T2 평균 103). Cut style 8 카테고리 모두 노출 검증 (송송 3 / 채썰기 2 / 통썰기 2 / 어슷 1 / 깍둑 1 / 다지기 1 / 양념재우기 1 / dip substitute 1). Tap 수 분포 점진 ramp 검증 (T1 3~5 / T2 5~6). Stage 2C 보조 cook 행위 BPM 표 신설 (시각 ambient 용도). §7.2 사용자 confirm 4건. §11 #9 ADR-005 음식별 prep lock open 해소.
  - **패치 파일 5종 + 신설 1종**:
    - `docs/systems/motion-spec.md` **신설** v0.1 (D1)
    - `docs/systems/cooking-mechanics.md` v0.6 → **v0.7** (D1 §X)
    - `docs/foods-database.csv` (D2 prep_* 4 컬럼)
    - `docs/ingredients-database.csv` (D2 cut_variations + D4 basic_pantry 검증)
    - `docs/balance-config.md` v0.3.3 → **v0.4** (D3 본격)
    - `CHANGELOG.md` — 본 entry
- **왜**:
  - M1 art sprint 71 anchor LOCK 완료 후 M2 gameplay code sprint 진입 prerequisite.
  - **godot-dev가 즉시 implementation 시작 가능한 수준**으로 design 본격 lock: 12 음식 × Stage × 도구 × motion + BPM + AnimationPlayer keyframe spec 완비.
  - **Option 1 motion lock** (사용자 명시): Godot AnimationPlayer Transform animation만 — single sprite 회전/이동/스케일 keyframe으로 모든 motion 구현. frame 추가 art 0건 = M1 anchor 71 LOCK만으로 M2 sprint 진입 가능 (단, hand_marinade + corndog_batter_bowl 2 sprite 미니 추가 권고).
  - **balance-config v0.4 본격 BPM**은 ADR-005 §7 BPM by Tier high-level → 12음식 본격 lock의 maturity 단계. game-designer open question #9 해소.
- **결과/다음 단계**:
  - **godot-dev 후속 implementation 의존성 (M2 W1~W5+)**:
    1. **W1**: `stage_2a_knife_indicator.tscn` + `tool_animations.tres` (칼 down-stroke keyframe §3.1) + 라면 (100 BPM × 4 taps) round 단독 end-to-end 검증
    2. **W2**: Cut style 6 BPM 음식 11종 확장 + ingredient whole↔cut transition (fade-out/in)
    3. **W3**: `stage_2a_marinade_indicator.tscn` (손바닥 marinade §3.3) + 불고기 round
    4. **W4**: Stage 2C 도구 motion 6종 (stir / grip / orbit / dip / roll) + timing bar integration
    5. **W5+**: 콘도그 batter dip chain (§3.10) + 김발 roll + 김밥 마무리 + alpha 검증
  - **art-director 후속 미니 sprint 권고 (motion-spec asset gap)**:
    1. `hand_marinade.png` single sprite (Cool Sage bg, transparent, ~$0.04, 1024×1024) — 불고기 Stage 2A 양념 마사지 손바닥
    2. `corndog_batter_bowl.png` single sprite (~$0.04) — 콘도그 Stage 2A batter dip substitute
    3. CUT-00 base anchor 활용 검토 — 양념재우기 시그니처 표현이 현재 base cutting_board만 표시되면, 별도 marinade 60 BPM cut anchor 신규 작성 트리거
  - **사용자 confirm 필요 사안 (low priority, alpha 후 결정 가능)**:
    1. 잔치국수 hero ingredient final lock (대파 송송 110 BPM·4 taps 권고 유지 vs 애호박 통썰기 70 BPM·3 taps — 정통 잔치국수 시그니처)
    2. 불고기 multi-cut sub-sequence (양념재우기 단독 vs + 양파 채썰기 sequential)
    3. 콘도그 Stage 2A dip substitute (칼 cut 메커닉 비적용 — 80 BPM × 3 taps batter dip lock 확인)
    4. Stage 2C 보조 rhythm 메커닉 도입 시점 (cook BPM stir/grip/orbit)
  - **M2 sprint kick-off ready**: godot-dev + ui-designer + game-designer alpha 검증 fan-out 가능.

---

## [2026-05-31] M1 reaction 6컷 v3 코믹 amplification — v2 family IP LOCK 유지 + 표정 3축 강화
- **무엇**: art-director가 사용자 v2 피드백 "reaction을 코믹하게 만드는게 어때? 지금 reaction 이미지는 너무 심심해" trigger로 reaction 6컷 v3 image edit driver 신설 + prompts-library v1.20 → v1.21 + art-anchor-rubric v1.20 → v1.21 갱신. v2 family IP consistency LOCK 유지 + 코믹 amplification 3축 (눈/입/body+icons) 강화.
- **왜**: v2는 image edit API로 어머니/아버지 family IP consistency PASS 했으나, subtle smile / big smile / single-double thumb-up gradient가 점잖아서 player가 ★1/★2/★3 차이를 즉시 체감 못함. "Korean variety show / K-drama exaggerated reaction" 톤 부재.
- **결과/다음 단계**: 새 driver `tools/edit_reaction_anchors_v3.py` 신설 (v2 driver는 보존, v1/v2/v3 output 공존). COMMON_FRAME_V3에 TONE TARGET 절 + CRITICAL BOUNDARIES 5건 (anime sparkly pupils 회피 + over-exaggerated goofy 회피 신규 2건). main thread 실행: (1) test `py tools/edit_reaction_anchors_v3.py --only R-03,R-06 --quality medium` (★3 peak 2장 ~$0.08 ~1분) → (2) batch `py tools/edit_reaction_anchors_v3.py --quality medium` (6장 ~$0.25 ~2-3분, 출력 `assets-raw/reaction_anchors_m1/R-XX_<character>_star<N>_v3.png`). G_reaction_v3 5 요소 (코믹 amplification 3축 PASS 기준 추가) 통과 시 LOCK candidate.

## [2026-05-31] C-2 basic_pantry 5종 정책 lock — 떡볶이·잡채 3가게 강등 + 잡화점 SKU 17→12 + 4 docs sync + ADR-007 pm 위임

- **무엇**:
  - **사용자 verbatim 결정 (2026-05-31)**: "default 수용 — C-1 떡볶이/잡채 3가게 강등 + C-2 basic_pantry 5종 (간장/고추장/참기름/설탕/소금) lock + C-3 양념재우기 = marinade rhythm 정합 + C-4 accuracy_ingredients 완전 제외 + C-5 Kitchen rack 위치 ui-designer 위임 + C-6 ADR-007 신설 pm 위임"
  - **C-2 lock 핵심**: 한국 가정 부엌 상시 비치 양념 5종 (`ing_x_003` 간장 / `ing_x_004` 고추장 / `ing_x_005` 설탕 / `ing_x_006` 참기름 / `ing_x_007` 소금) → Stage 1 재래시장 진열대 미표시 + Scene 2 kitchen rack 자동 표시 (시각 cue만) + accuracy_ingredients 분모 N에서 자동 차감.
  - **소금 ing_x_007 신규 row** (basic_pantry default base, foods CSV `used_in_foods = implicit_all` 명시 X). 기존 ing_x_007 = 깨는 **ing_x_019로 ID 재매핑** (사용자 명시 ID list 정합 위함).
  - **떡볶이·잡채 4가게 → 3가게 강등** (잡화점 정답 0): 떡볶이 잡화 = 고추장 1종 (basic_pantry 제거 후 0) / 잡채 잡화 = 간장·참기름 2종 (basic_pantry 제거 후 0).
  - **4 docs ripple sync**:
    - `docs/ingredients-database.csv` — 신규 컬럼 `is_basic_pantry: bool` 추가 (헤더 sync). 양념 4 row(간장·고추장·참기름·설탕) → `is_basic_pantry: true` + `store_type: pantry` + `distractor_weight: 0` + `is_distractor_friendly: false`. 일반 재료 36 row → `is_basic_pantry: false`. **소금 ing_x_007 신규 row** (`store_type: pantry`, `used_in_foods: implicit_all`). 기존 깨 → `ing_x_019` ID 이동.
    - `docs/store-distribution.md` v1.2 → **v1.3** — 5×12 매트릭스 재산정 (잡화 음식 등장 12→10, 정답 합계 29→17, 평균 2.42→1.7). 떡볶이·잡채 3가게 강등 명시. 가게 수 분포: 5가게(1) / 4가게(6→4) / 3가게(5→7) / 2가게(0 유지). 어물전 floor 5 유지 확인. §X "Basic Pantry 제외 정책" 신설 (정의·룰·Remote Config 3 키·후속 작업). §1.5 잡화점 정답 합계 산정 상세 표 신설 (12 차감 검증).
    - `docs/balance-config.md` v0.3.2 → **v0.3.3** — §4A "Basic Pantry 정책" 신설 (5종 정의 + Remote Config 키 3종). §2.2.2 음식별 Stage 1 time_limit 재산정 (떡볶이 22→18s / 잡채 30→25s / 그 외 변동 없음). §2.2.3 디스트랙터 평균 재산정 (T1 3.86→3.43 / T2 3.4→2.8, 잡화 SKU pool 17→12 distractor=1 충분 검증 PASS). §5.1 accuracy_ingredients 공식 갱신 (분모 N에서 basic_pantry 자동 차감). §11 #13·#14·#15 신규 (alpha 검증 / ADR-007 격상 / ing_x_007 ID 재매핑 ripple).
    - `docs/systems/cooking-mechanics.md` v0.5 → **v0.6** — §2.2.1 basic_pantry 자동 제외 룰 신설. §2.2.7 Kitchen rack 자동 표시 신설 (Scene 1→2 transition 시 자동, art-director 옹기 5종 anchor 후속). §2.5 accuracy_ingredients 공식 분모 N에서 basic_pantry 차감 명시. §2A.X 양념재우기 정합 명시 신설 (양념 자동 제공 + marinade rhythm tap, 양념 "고르기" 행위 X). §8 store_type mapping에 `pantry` 카테고리 추가 (basic_pantry 5종 전용 enum).
    - `CHANGELOG.md` — 본 entry.
  - **Remote Config 신규 키 3종** (`balance-config.md` v0.3.3 §4A.2):
    - `cooking.basic_pantry_ingredient_ids` = `["ing_x_003","ing_x_004","ing_x_005","ing_x_006","ing_x_007"]`
    - `cooking.stage1.exclude_basic_pantry` = `true`
    - `cooking.accuracy.exclude_basic_pantry` = `true`
- **왜**: 사용자 직관 정확 — 한국 가정 부엌의 base seasoning을 매 음식마다 잡화점에서 픽업하는 반복 노동이 게임 인지 부담을 dilute. basic_pantry 정책으로 음식별 unique signature 재료(어물 멸치 / 정육 얇은소고기 / 곡물 소면 등)에 집중 가능 + 잡화점 dominant 패턴(평균 2.42) 자연 해소 (어물 1.6과 비슷한 1.7로 중-tier 자연 위치). 떡볶이·잡채 3가게 강등은 의도된 결과 — 두 음식 모두 잡화점 정답이 basic_pantry 단독이라 정책 적용 후 0이 됨, 그러나 다른 가게(곡물·청과·정육·어물) 정답 재료는 충분해 음식 정체성 손실 없음.
- **결과/다음 단계**:
  - **godot-dev 후속 sprint 영향 (Resource 스키마 sync)**:
    - `ingredient_definition.gd` Resource 스키마에 `is_basic_pantry: bool = false` field 추가
    - `store_type` enum에 `pantry` value 추가 (기존 vegetable_shop/butcher/seafood_shop/grain_shop/general_store + pantry 6종)
    - Stage 1 진열대 build 로직: `is_basic_pantry == true` filter 적용
    - Scene 2 kitchen rack 노드 instantiate 로직 신규 (basic_pantry 5종 fetch + AnimationPlayer fade-in 0.3s)
    - accuracy_ingredients 분모 N에 `N_effective = required.filter(NOT IN basic_pantry_ingredient_ids).count` 적용
    - **소금 ing_x_007 ID 재매핑 ripple**: 기존 ing_x_007 (깨) Resource(.tres) 인스턴스를 ing_x_019로 rename + 갈비구이 t2_012 ingredients[] 배열 sync (foods CSV는 명시 변경 없음, ID는 Resource path 기반 매핑이라 Resource rename으로 처리). 즉시 처리 vs migrate 정책 결정 필요.
    - Remote Config 신규 키 3종 Console 등록
  - **ui-designer 후속 sprint 위임 (C-5)**:
    - Kitchen rack 위치 결정 (좌측 상단 vs 우측 상단 vs 가스레인지 옆 선반 vs 도마 뒤 배경)
    - 옹기 5종 표시 layout (가로 정렬 / 세로 정렬 / 옹기 항아리 클러스터)
    - Stage 2A 양념재우기 진입 시 양념이 marinade bowl로 자동 이동하는 transition animation 사양
    - components.md에 KitchenRack 컴포넌트 신규 추가
  - **art-director 후속 sprint (Post-M1)**:
    - 옹기 5종 anchor (간장 옹기 / 고추장 옹기 / 설탕 단지 / 참기름 호리병 / 소금 항아리) — kitchen rack 시각 identity
    - 옹기 시각 디스트랙터 손실(간장↔고추장 페어) 회복 차원 — Stage 1 잡화점에서 빠진 옹기 페어가 kitchen rack에서 시각 학습 보존
  - **qa-tester 후속 sprint**:
    - C-2 정책 검증 테스트 케이스: 떡볶이 round (고추장 미표시 → 사용자 혼란 없음 확인) / 잡채 round (간장·참기름 미표시 → 정답 재료 6개 안 5종 100% pickup 가능) / 갈비구이 round (3 basic_pantry 차감 후 N_effective=6 → ★3 도달 가능 검증)
    - accuracy_ingredients 분모 차감 unit test
  - **pm 후속 sprint 위임 (C-6)**:
    - **ADR-007 신설** = basic_pantry 정책 정식 ADR 격상 (의사결정 배경 + 대안 검토 + Remote Config 운영 정책 + post-launch M1 들기름 추가 검토 hook)
  - **art-director / ui-designer / godot-dev / qa-tester 후속 작업 list**:
    1. art-director: 옹기 5종 anchor (Post-M1, ~$0.21 generation, ~2h evaluation)
    2. ui-designer: Kitchen rack 위치 + 옹기 layout + transition animation 사양 (M1 후반 sprint, ~3-5h)
    3. godot-dev: Resource 스키마 sync + 진열대 filter + kitchen rack node + accuracy 분모 차감 + ID 재매핑 ripple (M2 sprint, ~6-10h)
    4. qa-tester: C-2 정책 검증 테스트 케이스 작성 (M2 후반, ~2h)
    5. pm: ADR-007 신설 (별도 sprint, ~1h)

---

## [2026-05-30] MVP 음식 list v2.1 → v2.2 — F-02 호떡 → 잔치국수 / F-09 김치찌개 → 불고기 (사용자 N-1·N-2 lock, 8 docs ripple sync)

- **무엇**:
  - **사용자 verbatim 결정 2건 (2026-05-30)**:
    - "잔치국수가 좋을거 같고, 순두부나 김치찌게 중에 하나도 다른거로 바꿨으면 해...둘다 찌게 종류라 MVP에서는 다른 종류의 음식이 더 나을거 같음"
    - 후속 선택: "**순두부 유지 + 김치찌개 → 불고기**"
  - **N-1 lock**: F-02 호떡 (t1_001) → **잔치국수 (t1_008)** — T1. 사유: 호떡 디저트/길거리 음식이라 cooking matching fit 약함, 잔치국수 = 정통 한식 면 요리 + 곡물·잡화·어물 3가게 순회 + 명절·잔치 시그니처. 어물전 멸치 hero로 floor 5 유지.
  - **N-2 lock**: F-09 김치찌개 (t2_009) → **불고기 (t2_014)** — T2. 사유: T2 끓이기 2개(김치찌개+순두부찌개) 카테고리 중복 해소. 순두부찌개는 T2 어물전 단독 책임이라 유지(사용자 명시). 불고기 = K-BBQ 시그니처 (단맛 양념 marinade + thin-slice + 채소 mixed) + ADR-005 §7 양념재우기 60 BPM cut style 시그니처 음식.
  - **8 docs ripple sync**:
    - `docs/systems/mvp-food-selection.md` v2.1 → **v2.2** — Final 12 lock 갱신. §1.5·§1.6 신규(불고기 데이터 포인트 + F-12 갈비구이 vs F-09 불고기 차별화 매트릭스). 호떡·김치찌개 post-launch M1 1순위 격리.
    - `docs/foods-database.csv` — t1_001 호떡 행 삭제 + t1_008 잔치국수 신규 / t2_009 김치찌개 행 삭제 + t2_014 불고기 신규. ID gap 정책 유지 (Resource(.tres) id-key 매핑이라 무영향).
    - `docs/ingredients-database.csv` — 호떡 전용 재료(밀가루 ing_g_004, 이스트, 견과류, 계피, 소금) 삭제 / 잔치국수 신규 재료(소면 ing_g_008, 애호박 ing_p_012, 다진마늘 ing_x_018) 추가 + 멸치·김 used_in_foods 확장 / 김치찌개 전용 재료(돼지고기 ing_m_003, 두부 ing_x_009) 삭제, 김치 used_in_foods에서 t2_009 제거 / 불고기 신규 재료(얇은소고기 ing_m_007) 추가 + 기존 재료(양파·당근·표고·배·간장·설탕·참기름·다진마늘) used_in_foods 확장.
    - `docs/store-distribution.md` v1.1 → **v1.2** — 5×12 합계 재산정 (청과 10→11, 정육 7 유지, 어물 5 유지, 곡물 9 유지, 잡화 12 유지). T2 정육 메커닉 carrier 3종(양념재우기+볶기/굽기/볶기+무치기) 완성. 신규 디스트랙터 클러스터 4종(곡물 면 트리오 라면사리·당면·소면 / 정육 형태 트리오 LA갈비·꽃갈비·얇은소고기 / 애호박↔호박 변종 / 다진마늘↔통마늘 form factor).
    - `docs/balance-config.md` v0.3.1 → **v0.3.2** — §2.2.2 Stage 1 time_limit 행 교체 (호떡 18s → 잔치국수 22s / 김치찌개 25s → 불고기 28s) / §3.2 perfect_width 행 교체 (호떡 8s·1100ms·0.14 → 잔치국수 12s·1000ms·0.10 / 김치찌개 15s·950ms·0.06 → 불고기 16s·900ms·0.09) / **§7.1 음식별 prep_bpm placeholder 신설** (잔치국수=대파 송송 110 BPM·4 taps / 불고기=양념재우기 60 BPM·3 taps ADR-005 시그니처 음식 lock).
    - `docs/friends-system.md` v0.2 → **v0.3** — 호불호 axis 매트릭스 갱신 (호떡 sweet+oily → 잔치국수 mild+salty / 김치찌개 spicy+salty → 불고기 sweet+salty+oily light). 어머니/아버지 net 보정 + 가족 합산 재계산. 가족 최고 선호 음식(+2) 그룹 5 → 7개 확장 (잔치국수·불고기 추가).
    - `docs/ui/ftue.md` v0.2 → **v0.3** — U-1 호떡 LOCK 폐기 (호떡 MVP 음식 제외). **FTUE 첫 음식 신규 LOCK = 라면 (t1_002)** — 3가게 / 재료 3 / 끓이기 / 글로벌 SS급. Step 1~4 화면 흐름·카피·룰 일괄 갱신 (호떡 굽기 → 라면 끓이기 / 밀가루 → 라면사리 / 호떡 접시 → 라면 냄비). FT-08 신규 (FTUE 종료 후 Round 2 음식 잔치국수 권고).
    - `CHANGELOG.md` — 본 entry.
- **왜**: 사용자 직관 정확 — MVP 12개 음식 중 찌개 카테고리 2종 중복(김치찌개·순두부찌개)이 다양성 약화. 호떡은 디저트 카테고리 단독이나 cooking matching 게임 메커니즘 fit이 약함(5재료 중 3개가 잡화 코너 = "잡화점에서 다 사오기" 단조). 잔치국수+불고기 swap으로 메커니즘 carrier 다양화 + 어물전 floor 5 유지 + T2 정육 메커닉 carrier 3종 완성.
- **결과/다음 단계**:
  - **art-director 후속 sprint 요청 (음식 2 + ingredient 4 anchor 신규)**:
    - F-02 잔치국수 음식 anchor 신규 작성 (hero ingredient = 소면, 부 hero = 멸치/김/애호박/대파, cross-cultural risk = 일본 somen 50% / 베트남 phở 30% — clear shallow bowl + bright yellow egg ribbon + dark gim strips + dried anchovy garnish 명시)
    - F-09 불고기 음식 anchor 신규 작성 (hero ingredient = 얇은 소고기, 부 hero = 양파/대파/당근/표고, cross-cultural risk = 일본 sukiyaki/shabu 40% — brown marinade pool + Korean cast-iron pan + mixed vegetables in same dish 명시)
    - F-02 ingredient anchor 매핑 (소면 신규 + 애호박 신규 + 멸치 확장 사용처)
    - F-09 ingredient anchor 매핑 (얇은 소고기 신규 + 양파 채썰기 CUT-02 매핑)
    - **양념재우기 cut style anchor 확인 sprint** (CUT-00이 base anchor만 표현이면 별도 양념재우기 60 BPM marinade rhythm cut anchor 신규 작성 트리거 — art-director cut anchor 7장 v1.14 sync 확인 필요)
    - M1 anchor 22/22 LOCK은 무효화 X (다른 20 anchor 영향 없음, F-02·F-09 두 음식 anchor만 신규).
  - **godot-dev sprint 영향**: foods/ingredients 데이터베이스 .tres Resource instance 신규 2개 추가 (t1_008 잔치국수 + t2_014 불고기) + 신규 ingredient .tres 4개 (소면·애호박·얇은소고기·다진마늘). 삭제된 ID(t1_001 호떡·t2_009 김치찌개·관련 ingredient) Resource는 deprecation 처리(즉시 삭제 vs migrate 정책 결정 필요).
  - **사용자 confirm 필요 (low priority)**:
    - 잔치국수 prep BPM 선택: 대파 송송썰기 110 BPM·4 taps (권고, 시그니처 마무리 임팩트) vs 애호박 통썰기 70 BPM·3 taps (정통 잔치국수 시그니처, T1 가장 부드러운 진입 곡선) — game-designer ADR-005 본격 sprint에서 결정.
    - 불고기 prep BPM: 양념재우기 60 BPM·3 taps 단독 vs 양념재우기 + 양파 채썰기 sequential — Stage 2A multi-cut sub-sequence 도입 결정 (open question).
    - FTUE 종료 후 Round 2 음식 lock: 잔치국수(권고, anchor 작성 후 활성) vs 떡볶이(anchor 기존 LOCK, 즉시 활성) vs 김치볶음밥 — ftue.md v0.3 §10 #6.

---

## [2026-05-29] M1 후반 art sprint 시작 — Cut anchor 7장 (칼/도마 base + cut style 6종) prompt set + driver script

- **무엇**:
  - **ADR-005 Stage 2A rhythm tap prerequisite**: 재료 준비 = rhythm tap + Knife indicator. 칼/도마 base + cut style 6종 anchor가 Stage 2A 구현 시작 prerequisite.
  - **prompts-library v1.13 → v1.14 패치**:
    - §2.5 STYLE_SUFFIX_CUT 신설 (square 1:1, top-down view, Korean cutting board + knife 통일 silhouette, Cool Sage #C8D5C0 bg, modern saturated, slim outline 2-3px). 이전 §2.5 anchor consistency 운영 규칙 → §2.6 번호 shift.
    - §5.5 placeholder → full prompts 확장 (cutting_board base + cut_style_mince/julienne/diagonal/whole/sliced_rounds/cube 7장 full prompt).
    - 시그니처 재료 매핑: mince → 마늘 (BPM 140) / julienne → 당근 / diagonal → 어묵+대파 / whole → 김밥 cylinder 단면 (BPM 70) / sliced_rounds → 대파 / cube → 두부.
    - §0 anchor 표에 CUT-00 ~ CUT-06 7장 row 추가.
  - **art-anchor-rubric v1.13 → v1.14 패치**:
    - §3.4 cut anchor 평가 표 신설 (CUT-00 ~ CUT-06 × G1/G3/G4/G5/G6/G7/G_new + G_cut 컬럼).
    - §5.7 G_cut 5 요소 평가 게이트 신설: (1) cut style 시각 식별 명확 CRITICAL / (2) hero ingredient 매칭 / (3) Cool Sage bg + 도마/칼 통일 CRITICAL / (4) modern saturated 톤 / (5) cutting RESULT state + cross-cultural negative CRITICAL.
    - LOCK 조건 = 7/7 anchors × 5 요소 = 35/35 PASS. CUT-00 anchor seed FAIL 시 전체 FAIL.
    - §6.13 Decisions Log 신설 (M1 후반 art sprint 시작 + cut anchor 7장 trigger 행 + 시그니처+BPM 매핑 표 + M1 anchor 22장 LOCK 무영향 확인).
  - **새 driver script `tools/gen_cut_anchors_m1.py` 신설**:
    - `tools/gen_food_anchors_m1.py` template 기반 (STYLE_SUFFIX_CUT inline + CUTS list 7개 inline + build_prompt body % suffix 자동 append).
    - CLI args: `--only` `--version` `--model` `--quality` `--out-dir`.
    - default: gpt-image-1 medium 1024×1024, 출력 `assets-raw/cut_anchors_m1/<name>_v1.png`.
- **왜**: M1 anchor 22/22 LOCK 완료 (음식 12 + 환경 5 + 캐릭터 5, commit dfb141e) 후 M1 후반 art sprint 진입. ADR-005 (4-stage rhythm) Stage 2A = 재료 준비 rhythm tap + Knife indicator. 칼 자동 위아래 움직임 (AnimationPlayer), 도마 닿기 직전 = perfect tap. Stage 2A 구현 시작에 cut anchor 7장 필요.
- **결과/다음 단계**:
  - 패치 파일 3 + 신규 1: `docs/prompts-library.md` v1.14 / `docs/art-anchor-rubric.md` v1.14 / `tools/gen_cut_anchors_m1.py` 신설 / `CHANGELOG.md` 본 entry.
  - main thread 실행 명령: `py tools/gen_cut_anchors_m1.py --model gpt-image-1 --quality medium` (7장 × $0.042 ≈ $0.29, ~3-4분, 출력 `assets-raw/cut_anchors_m1/`).
  - 사용자 시각 확인 + G_cut 5 요소 게이트 평가 (35/35 PASS 시 LOCK → ADR-005 Stage 2A 구현 진입).
  - CUT-00 anchor seed 우선 평가 후 CUT-01~06 일관성 확인 (reference upload 패턴).

---

## [2026-05-31] M1 후반 art sprint 완료 — 조리도구 12 + ingredient cut 12 + reaction v3 코믹 + 양념 제거 + ADR-007 + rembg transparent

- **무엇**:
  - **조리도구 12종 신설** (`assets-raw/tool_anchors_m1/TOOL-01~12_*_v1.png`, ~$0.50): Cookingo-inspired single sprite (애니메이션 prerequisite). 가스레인지/냄비/후라이팬/튀김기/그릴/국자/주걱/뒤집개/집게/김발/그릇/한식 가위. 각 도구 별도 sprite로 godot AnimationPlayer transform animation 대상.
  - **Ingredient cut variation 12장** (`assets-raw/ingredient_cut_anchors_m1/F-XX_*_cut_v1.png`, ~$0.50): 음식별 hero ingredient cut된 결과 (whole의 "after" pair, ADR-005 Stage 2B/2C 시각 자산).
  - **F-02 ingredient v4 mapping fix** (`assets-raw/ingredient_anchors_m1/F-02_zucchini_whole_v4.png`): 사용자 지적 — 소면 자르기 메커닉 불일치 → 애호박 통썰기 (CUT-04 mapping 0건 활성화). hero ingredient 진화 timeline: peanut → 흑설탕 → 소면 → **애호박** (lock).
  - **MVP 음식 v2.2 변경 반영** (이전 sprint 후속):
    - F-02 호떡 → 잔치국수 (T1, 곡물+잡화+어물+청과 4가게 순회)
    - F-09 김치찌개 → 불고기 (T2, 정육+청과+잡화, F-12 갈비 차별화 — bone X, grill grate X, plate hero shot)
    - 8 docs ripple sync (mvp-food-selection v2.2 / foods CSV / ingredients CSV / store-dist v1.2 / balance-config v0.3.2 / friends-system v0.3 / ftue v0.3 / CHANGELOG)
  - **ADR-007 Accepted (Basic Pantry 자동 제공)** — 사용자 명시 "기본 양념은 구매하러 가지 않아도 되고 그냥 제공". 간장/고추장/참기름/설탕/소금 5종을 `basic_pantry` 카테고리로 분리. 잡화점 floor 12 → 10. **떡볶이/잡채 4→3가게 강등** (양념이 잡화 유일 SKU였음). ADR-005 4-stage 무변경 (Stage 2A 양념재우기 = marinade rhythm 유지, 자동 제공과 호환). 4 docs ripple sync (ingredients CSV / store-dist v1.3 / balance-config v0.3.3 / cooking-mechanics v0.6).
  - **rembg AI background removal 도입** (`tools/strip_bg.py`): Python rembg + onnxruntime CPU + u2net/isnet-general-use model. 116장 transparent PNG 생성 (`assets-raw/transparent_m1/<category>/`). 게임 asset 표준 (Godot/Unity sprite 합성 자유).
    - u2net: food/bg/cut/ingredient 우수 (Cool Sage 솔리드 bg 깨끗 alpha)
    - isnet-general-use: reaction/scissors detail 보존 (인물 portrait + 가위 blade 보존)
    - TOOL-12 가위 alpha = handle ring 가운데 transparent + blade 보존 정상
  - **Reaction v3 코믹 amplification** (`assets-raw/reaction_anchors_m1/R-01~R-06_*_v3.png`, ~$0.25): 사용자 v2 피드백 "심심해" → cartoon-style EXAGGERATED. 3축 amplification (눈/입/body+icons). image edit API + CH-02/CH-03 base family IP consistency 유지 (v2 LOCK 패턴 계승).
    - ★1: chin hand + thinking icon (?/sweat drop) + 비대칭 eyebrow + 코믹 사고 표정
    - ★2: closed crescent ^_^ + O-mouth + 한 손 cheek (mother) / DOUBLE thumb-up (father, v3 KEY: single → double)
    - ★3 (EXPLOSIVE): GIANT closed-arc + WIDE open with teeth + 양손 raised cheek/over head + 다중 hearts (mother) / stars (father) + 5-6 sparkles + motion lines
  - **Option 1 motion animation lock** — 사용자 결정 "도구 motion = Godot AnimationPlayer Transform only". 추가 frame art 0건. M2 godot-dev 영역 (rotation/translation/scale keyframe으로 motion 구현, 칼 위↕아래/가위 회전/주걱 좌↔우 등). 재료 변화 = whole(ING-XX) fade-out → cut(ICUT-XX) fade-in transition.
- **왜**:
  - M1 art sprint 완료 milestone — anchor 71-83장 LOCK + transparent 116장 archive + 8+4=12 docs ripple + 2 ADR (ADR-005 marinade rhythm + ADR-007 basic pantry).
  - 사용자 빠른 turnaround + 직관 검증 흐름: 각 sub-sprint마다 시각 확인 → 즉시 reroll/패치 사이클.
  - rembg 도입 — game asset 표준 transparent PNG 확보 (godot sprite 합성 자유).
  - Reaction v3 코믹 — Cookingo-inspired tone + K-drama variety show 인상.
- **결과/다음 단계**:
  - **누적 비용 (M1 후반)**: ~$1.50 (음식 list v2.2 reroll + ingredient cut + reaction v3 + 조리도구 + ingredient v4)
  - **M1 anchor 종합**: 71 LOCK (음식 12 + 환경 5 + 캐릭터 5 + cut 7 + ingredient whole 12 + ingredient cut 12 + reaction 6 + 조리도구 12) + ~30장 reroll archive + 116장 transparent
  - **사용자 다음 액션 결정**:
    - M1 후반 잔여 UI ~7장 + VFX ~4-5장 (task #33, 선택)
    - M2 gameplay code sprint 진입 (godot-dev/game-designer)
    - ADR-005 motion spec 명확화 (도구별 Transform sequence + BPM 매핑)
  - **TOOL-07 minor 보류**: paddle 흰색 (원본 prompt 이슈), silver-gray reroll 가능 (사용자 dismissed)
  - **commit point**: 본 sprint LOCK 박제 후 git commit + push

---

## [2026-05-28] M1 anchor 종합 22/22 LOCK — 음식 12 (R1~R8) + 환경 5 (v1.2→v4) + 캐릭터 5

- **무엇**:
  - **음식 12 LOCK** (`assets-raw/food_anchors_m1/F-01~F-12_*_v[1-8].png`):
    - R1 v1 (DALL-E 3 시도 → org access X, gpt-image-1로 pivot): 12/12 PASS
    - R2 v2 (사용자 피드백 10건 — 면 두께/밥알/cheese/배추 등): F-04, F-09 R1 LOCK 유지
    - R3 v3 (사용자 R2 피드백 6건 — v1 base 회복 + 부분 fix): F-01/02/03/05/06/12 reroll
    - R4~R8 (F-12 single anchor 7 round iteration): 갈비구이 reference image 진화 적용
    - 최종 LOCK: F-01~F-11 R3 v3 또는 R2 v2 LOCK, **F-12 R8 v8 LOCK** (LA-cut strips + 칼집 + 대파 + 흰 plate)
  - **환경 5 LOCK** (`assets-raw/bg_anchors_m1/BG-01_v4, BG-02_v4, BG-03_v5, BG-04_v4, BG-05_v4`):
    - v1.2 base (Week 1 anchor candidate, commit 7a6cffb): red/green 줄무늬 천막 + 정면 view
    - v2 한옥 풀세트 (한옥 frame + 옹기 + lantern + 처마 풀): 너무 많음 → 폐기
    - v3 minimal patch (prompt-only generation): 5가게 구조 inconsistent + slight 7/8 perspective → 폐기
    - **v4 image edit API 도입** (`tools/edit_bg_anchors_v4.py`): v1.2 base PNG를 input → gpt-image-1 edit으로 천막→기와 지붕 단일 fix → frontal view 유지 + 5가게 구조 정확 일관성 달성
    - BG-03 v5 micro-fix: double-tier 지붕 → single layer 조정 (다른 4가게와 일관)
    - 최종 LOCK: 5/5 PASS (검정 기와 곡선 지붕 + 처마 곡선 + 와당 + v1.2 카테고리 시그니처 + Cool Sage bg + icon+영어 minimal + frontal view)
  - **캐릭터 5 LOCK** (`assets-raw/week1-anchors/CH-01~CH-05_*.png`, commit 7a6cffb): Week 1 anchor 작업에서 lock, M1 sprint 무영향.
  - **갱신 docs (art-director batch sync)**:
    - `docs/prompts-library.md` v1.3 → **v1.13** (F-12 v3~v8 7 round + BG-01~05 v1.2 archive + v2/v3 deprecated + v4 image edit approach)
    - `docs/art-anchor-rubric.md` v1.3 → **v1.13** (G_food + G_user_visual_detail + G_env_v4 8 요소 + Decisions Log §6.3~§6.12)
    - `tools/gen_food_anchors_m1.py` v1.0 → **v1.9 sync** (F-12 v8 body + STYLE_SUFFIX_FOOD)
    - `tools/gen_bg_anchors_m1.py` 신설 (v1.12 v3 deprecated 후 archive 보존)
    - `tools/edit_bg_anchors_v4.py` **신설** — gpt-image-1 image edit API wrapper (base image dimensions 검증 + PIL LANCZOS resize fallback)
  - **DALL-E 3 cross-cultural 누수 회피 검증** (음식 risk top 5 → 5/5 LOCK):
    - F-12 갈비구이 (일본 야키니쿠 + 미국 BBQ ribs 60%+30% default)
    - F-03 김밥 (일본 maki sushi 70% default)
    - F-06 콘도그 (미국 corn dog 80% default)
    - F-11 잡채 (중식 lo mein 70% default)
    - F-09 김치찌개 (중식 hot pot 50% default)
    - 모두 explicit negative + signature feature 강조로 LOCK 달성
- **왜**:
  - M1 sprint art track 진입 prerequisite — anchor LOCK 후 M1 후반 (cut anim / ingredient cut / reaction 6컷 / UI / VFX) 및 M2 gameplay sprint kick-off 가능.
  - F-12 7 round reroll iteration — 사용자 시각 의도 점진 명확화 (single bone at end → bone at edges → bone TOP LONG EDGE → bone SHORT EDGE → LA cross-cut + 대파 + wire mesh → 흰 plate). 정통 한식 갈비구이 정체성을 사용자 reference image 2건과 함께 정확 reverse-engineer.
  - BG image edit API 도입 — prompt-only generation의 본질적 한계 (DALL-E가 매번 다르게 해석 → 5가게 구조 inconsistent) 우회. v1.2 base를 input으로 사용해 사용자 의도 ("원래 버전에서 지붕만 바꿈") 정확 매칭.
- **결과/다음 단계**:
  - **누적 비용**: ~$2.67 (음식 28 generations $1.71 + 환경 v2 $0.21 + v3 $0.21 + v4 BG-01 test $0.04 + BG-02~05 batch $0.17 + BG-03 v5 $0.04 + 기타)
  - **누적 시간**: ~30분 generation time + 평가/iteration round trips
  - **사용자 다음 액션 결정**:
    - Track A — M1 후반 art sprint (칼/도마 → cut anim 6종 → 재료 cut variation 24장 → 양친 reaction 6컷 → UI ~7 → VFX ~4-5)
    - Track B — M2 gameplay code sprint (foods CSV prep_* + balance-config BPM + Stage 2A rhythm tap + 4-factor 채점 + Knife indicator UI)
    - 또는 Track A + B 병렬 (art-director + godot-dev/game-designer/ui-designer fan-out)
  - **art-director / godot-dev / game-designer / ui-designer 대기**: 다음 sprint sub-agent 위임 우선순위 사용자 결정 대기.
  - **commit 시점**: 본 LOCK 박제 후 git commit (재출발점 확보).

---

## [2026-05-27] M1 sprint kickoff — 음식 12 anchor prompt set + ChatGPT 세션 가이드 + G_food 평가 rubric

- **무엇**:
  - **art-director M1 prompt set 산출 4종**:
    - `docs/prompts-library.md` v1.2 → **v1.3** — §0 anchor 표 F-01~F-12 12행 추가, **§2.4 STYLE_SUFFIX_FOOD 신설** (Cool Sage `#C8D5C0` / Cream-white `#FAFAFA` bg, white baekja/pale celadon bowl, no characters/hands/cooking action, cross-cultural negative 강제), **§5.1~§5.4 음식 12 anchor full prompt** (DALL-E 3 자연어, 식별 핵심 시각 요소 + Tier 1/2 abundance 단서 + 누수 risk + reroll 트리거), §5.5~§5.7 cut anim/reaction/UI placeholder 격리 (M1 후반/M2).
    - `docs/ai-session-kit.md` v1.2 → **v1.3** — §M1 음식 12 세션 가이드 신설 (Step 0 F-01 anchor 시드 → Step 1 T1 6장 한 세션 → Step 2 T2 5장 새 세션, 인계 schema 12행, ~1.5~2.5h 소요).
    - `docs/art-anchor-rubric.md` v1.2 → **v1.3** — §5.5 M1 음식 12 평가 가이드 신설 (G_food 신설, G2 chibi N/A, G6 W5/W6 가중치↑, F-01~F-12 평가 표). **LOCK 조건 = 10/12 PASS + F-01 PASS + risk top 5 중 4 LOCK**.
    - `docs/art-style-guide.md` §4.1 bg `#FAEFD8`(deprecated) → **Cool Sage `#C8D5C0` / Cream-white `#FAFAFA`** sync, v1.3 cross-ref.
  - **DALL-E 3 cross-cultural 누수 risk top 5** (한식 anchor 특화 G6 세분화):
    1. **F-06 콘도그** → 미국 corn dog default ~80% — mozzarella stretch 2~3 strands + crispy panko + ketchup/mustard zigzag 강제
    2. **F-03 김밥** → 일본 maki sushi ~70% — THICK 3cm + matte gim + cooked veggies + NO raw fish/wasabi/gari 강제
    3. **F-11 잡채** → 중식 lo mein/chow mein ~70% — translucent brown-amber dangmyeon glass noodles + NOT yellow egg noodles 강제
    4. **F-12 갈비구이** → 일본 야키니쿠 ~60% / 미국 BBQ ribs ~30% — **VISIBLE WHITE RIB BONE** + soy-pear-garlic marinade + LA-style cut + 상추 ssam
    5. **F-09 김치찌개** → 중식 hot pot ~50% — 검정 ttukbaegi (rounded thick rim, individual) + gochugaru broth + NO raw thin-sliced meat around
  - P2 risk 7종: F-05 (Chinese egg fried rice ~50%) / F-07 (Japanese okonomiyaki ~40%) / F-01 (Japanese ramen ~30%) / F-10 (Chinese mapo tofu ~30%) / F-04 (Chinese nian gao ~25%) / F-08 (Western Buddha bowl ~25%) / F-02 (Western pancake stack ~15%).
- **왜**: ADR-006 lock(ChatGPT + DALL-E 3) + Week 1 캐릭터/환경 anchor 10장 candidate 완료 → M1 음식 anchor 트랙 즉시 진입 (Week 1 evaluation과 독립 병행). Final 12 음식 lock 상태 + art-style v1.2 modern + icon+English i18n + cross-cultural negative 강제로 음식 12장 hero shot anchor 작업 ready.
- **결과/다음 단계**:
  - **사용자 다음 액션**: ChatGPT Plus 세션 1회 ~1.5~2.5h 실행 — `ai-session-kit.md §M1` Step 0~2 순서. 결과 12 image + 인계 schema → art-director G_food rubric 평가 → LOCK/FAIL 판정.
  - **음식 12장 anchor LOCK 후 M1 후반 sprint 진입**: cut style 6종 anim (12~18 frames) + hero ingredient cut variation ~24 sprite + 양친 reaction 6컷 + 재료 카드 ~20 + UI ~7 + VFX ~4~5 + 칼/도마 base anchor (ADR-005 Stage 2A prerequisite).
  - **사용자 confirm 필요 없음** — art-director 영역 progressing.
  - **F-03/F-06/F-11/F-12 reroll 2~3회 예상** — risk top 5 안의 4개 음식이 collapse 빈도 높음. 사용자 세션 시간 buffer 확보.

---

## [2026-05-27] ADR-006: Art 생성 도구 영구 pivot — Midjourney → ChatGPT (GPT-4o image / DALL-E 3)
- **무엇**:
  - **ADR-006 Accepted** — Art 도구 = ChatGPT (Plus $20/월, DALL-E 무제한). MJ Standard $30/월 다음 billing 전 취소 (main thread reminder).
  - **art-director 5종 art 문서 영구 sync**:
    - `docs/art-style-guide.md` v1.0 → **v1.1** (§7 ChatGPT 약점 10항 재정의)
    - `docs/prompts-library.md` v1.0 → **v1.1** (자연어 prompt 전면 재작성, `--sref` 운영 → subject anchor 단어 통일 + reference image upload)
    - `docs/ai-session-kit.md` v1.0 → **v1.1** (rename + ChatGPT 워크플로, 4-grid/upscale 개념 제거)
    - `docs/art-anchor-rubric.md` v1.0 → **v1.1** (G6 ChatGPT 약점 6~10항 sync)
    - `docs/art-workload-estimate.md` v4.0 → **v4.1** (비용 ~$60~90 → ~$20~25, -67~78%)
    - `docs/ai-comparison-test.md` v1.1 cross-ref 점검 (renamed from mj-)
  - **pm sync 4종**:
    - `docs/decisions.md` ADR-006 본문 신설 + 인덱스 추가 + ADR-002 #3 / ADR-003 §유지결정 #3 cross-ref 註
    - `.claude/agents/art-director.md` ChatGPT 전면 sync
    - `docs/agent-roster.md` art-director 행 sync + ADR-006 link
    - `docs/systems/friends-system.md` line 82 도구 중립화
  - **Main thread**:
    - Bash mv: `mj-comparison-test.md` → `ai-comparison-test.md`, `mj-session-kit.md` → `ai-session-kit.md`
    - CHANGELOG (본 항목)
    - 메모리 sync (`feedback_ai_image_tool.md` 신설, `MEMORY.md` index 추가, `project_adr003.md` 미해결 항목 갱신 예정)
- **왜**: 사용자 5/23 MJ Standard 결제 후 5일만에 ChatGPT pivot 확정. Discord UX 부담 + 대화형 iteration 선호 + 이미 ChatGPT 구독 (추가 비용 회피). visual comparison test 패턴(feedback_visual_decisions)과도 정합.
- **결과/다음 단계**:
  - **MVP art 비용 ~70% 절감** ($60~90 → $20~25, 4개월 기준)
  - **가장 큰 trade-off**: sref 부재 → subject anchor 자연어 통일 + reference image upload 3축으로 보완
  - **시간 ±10% 미세 변동** (4-grid 손실 vs 자연어 iteration 속도 상쇄, M1 ~67~73h / 총 ~75~85h 무변동)
  - **사용자 다음 액션**: ChatGPT Plus $20/월 결제 → `ai-comparison-test.md` v1.1로 비교 세션 ~30~40분 → variant lock → ai-session-kit으로 Week 1 anchor ~1~1.5h
  - **art-style 결정은 여전히 보류** — comparison test 결과 기반 lock 예정
  - **MJ Standard 결제 취소 reminder**: 다음 billing 일자 확인 후 취소 (sunk cost ~$30 1개월)

---

## [2026-05-27] art-style reset COMPLETE — hyper-casual flat (Subway Surfers / Crossy Road / Stack 계열) scratch v1.0
- **무엇**:
  - **사용자 결정 (2026-05-27)**: art-style reference = **하이퍼캐주얼 flat** (단색 fill, geometric, bold outline, 최소 detail). 직전 mascot baseline(Cookie Run / 라인프렌즈) supersede.
  - **art-director 5종 scratch v1.0 재작성**:
    - `docs/art-style-guide.md` v0.2 → **v1.0** (flat 톤 baseline, MJ 약점 flat 특화 10항, ADR-005 cut anim 