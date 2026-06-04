#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
import_art_to_godot.py — M1 LOCK 아트 anchor → Godot art/ 반입 + 레지스트리 생성 (W2).

assets-raw/transparent_m1/ 의 anchor PNG를 godot-project/art/ 하위에 food_id 기준 clean name으로
복사하고, scripts/gameplay/art_registry.gd (food_id/method → res:// 경로 dict) 를 자동 생성한다.

매핑 원칙
- 음식 완성샷: 최신/최선 버전 (FOOD_SRC, 일부 미LOCK placeholder — art-anchor-rubric 참조).
- Stage 2A prep whole/cut: **CSV prep_ingredient 기준** (음식 F번호와 다를 수 있음 — 예: 잔치국수=대파, 순두부=애호박).
- method → 조리도구 vessel sprite.

재현 가능: 같은 입력 → 같은 출력. 버전/매핑 변경 시 본 스크립트만 수정 후 재실행.
사용:  py tools/import_art_to_godot.py
"""
from __future__ import annotations
import os
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "assets-raw", "transparent_m1")
ART = os.path.join(ROOT, "godot-project", "art")
REG = os.path.join(ROOT, "godot-project", "scripts", "gameplay", "art_registry.gd")

# 음식 완성샷 (food_id → 소스 상대경로). 최신/최선 버전. ⚠=미LOCK placeholder.
FOOD_SRC = {
    "t1_002": "food_anchors_m1/F-01_ramyeon_v3.png",          # ⚠ R3 reroll pending
    "t1_003": "food_anchors_m1/F-04_tteokbokki_v1.png",
    "t1_004": "food_anchors_m1/F-03_kimbap_v3.png",
    "t1_005": "food_anchors_m1/F-05_kimchi_fried_rice_v3.png",
    "t1_006": "food_anchors_m1/F-07_haemul_pajeon_v2.png",
    "t1_007": "food_anchors_m1/F-06_corn_dog_v3.png",
    "t1_008": "food_anchors_m1/F-02_janchi_guksu_v9.png",
    "t2_008": "food_anchors_m1/F-08_bibimbap_v2.png",
    "t2_010": "food_anchors_m1/F-11_japchae_v2.png",
    "t2_012": "food_anchors_m1/F-12_galbi_gui_v8.png",
    "t2_013": "food_anchors_m1/F-10_sundubu_jjigae_v2.png",
    "t2_014": "food_anchors_m1/F-09_bulgogi_v10.png",
}

# Stage 2A prep — CSV prep_ingredient 기준 (food_id → whole, cut 소스).
PREP_WHOLE_SRC = {
    "t1_002": "ingredient_anchors_m1/F-01_spring_onion_whole_v1.png",   # 파 CUT-05
    "t1_003": "ingredient_anchors_m1/F-04_fish_cake_whole_v1.png",      # 어묵 CUT-03
    "t1_004": "ingredient_anchors_m1/F-03_danmuji_whole_v1.png",        # 단무지 CUT-04
    "t1_005": "ingredient_anchors_m1/F-05_kimchi_whole_v1.png",         # 김치 CUT-06
    "t1_006": "ingredient_anchors_m1/F-07_daepa_whole_v1.png",          # 쪽파≈대파 CUT-05
    "t1_007": "ingredient_anchors_m1/F-06_mozzarella_whole_v1.png",     # 콘도그 DIP-00 (치즈 placeholder)
    "t1_008": "ingredient_anchors_m1/F-01_spring_onion_whole_v1.png",   # 잔치국수 대파 CUT-05
    "t2_008": "ingredient_anchors_m1/F-08_carrot_whole_bibimbap_v1.png",# 당근 CUT-02
    "t2_010": "ingredient_anchors_m1/F-11_carrot_whole_japchae_v1.png", # 당근 CUT-02
    "t2_012": "ingredient_anchors_m1/F-12_garlic_whole_v1.png",         # 마늘 CUT-01
    "t2_013": "ingredient_anchors_m1/F-02_zucchini_whole_v4.png",       # 호박 CUT-04
    "t2_014": "ingredient_anchors_m1/F-09_thin_beef_whole_v3.png",      # 소고기 MAR-00
}
PREP_CUT_SRC = {
    "t1_002": "ingredient_cut_anchors_m1/F-01_spring_onion_cut_v1.png",
    "t1_003": "ingredient_cut_anchors_m1/F-04_fish_cake_cut_v1.png",
    "t1_004": "ingredient_cut_anchors_m1/F-03_danmuji_cut_v1.png",
    "t1_005": "ingredient_cut_anchors_m1/F-05_kimchi_cut_v1.png",
    "t1_006": "ingredient_cut_anchors_m1/F-07_daepa_cut_v1.png",
    "t1_007": "ingredient_cut_anchors_m1/F-06_mozzarella_whole_no_cut_v1.png",
    "t1_008": "ingredient_cut_anchors_m1/F-01_spring_onion_cut_v1.png",
    "t2_008": "ingredient_cut_anchors_m1/F-08_carrot_cut_bibimbap_v1.png",
    "t2_010": "ingredient_cut_anchors_m1/F-11_carrot_cut_japchae_v1.png",
    "t2_012": "ingredient_cut_anchors_m1/F-12_garlic_cut_v1.png",
    "t2_013": "ingredient_cut_anchors_m1/F-02_zucchini_cut_v1.png",
    "t2_014": "ingredient_cut_anchors_m1/F-09_thin_beef_marinade_v1.png",
}

# 별점(1~3) → 가족 리액션 (시식 반응, v3 코믹). 어머니 기준.
REACTION_SRC = {
	"1": "reaction_anchors_m1/R-01_mother_star1_v3.png",
	"2": "reaction_anchors_m1/R-02_mother_star2_v3.png",
	"3": "reaction_anchors_m1/R-03_mother_star3_v3.png",
}

# method_id → 조리도구 vessel
METHOD_TOOL_SRC = {
    "boil": "tool_anchors_m1/TOOL-02_pot_yangun_v1.png",
    "stirfry": "tool_anchors_m1/TOOL-03_frying_pan_v1.png",
    "panfry": "tool_anchors_m1/TOOL-03_frying_pan_v1.png",
    "deepfry": "tool_anchors_m1/TOOL-04_deep_fryer_pot_v1.png",
    "grill": "tool_anchors_m1/TOOL-05_grill_wire_grate_v1.png",
    "roll": "tool_anchors_m1/TOOL-10_bamboo_rolling_mat_v1.png",
    "mix": "tool_anchors_m1/TOOL-11_mixing_bowl_v1.png",
    "toss": "tool_anchors_m1/TOOL-11_mixing_bowl_v1.png",
    "marinate": "tool_anchors_m1/TOOL-11_mixing_bowl_v1.png",
}


def copy(src_rel: str, dst_abs: str) -> bool:
    s = os.path.join(SRC, src_rel)
    if not os.path.exists(s):
        print("  [MISSING] %s" % src_rel)
        return False
    os.makedirs(os.path.dirname(dst_abs), exist_ok=True)
    shutil.copyfile(s, dst_abs)
    return True


def res(p: str) -> str:
    return "res://art/" + p.replace(os.sep, "/")


def main():
    food_reg, whole_reg, cut_reg, tool_reg = {}, {}, {}, {}
    n = 0

    for fid, src in FOOD_SRC.items():
        rel = "sprites/food/%s.png" % fid
        if copy(src, os.path.join(ART, rel)):
            food_reg[fid] = res(rel); n += 1
    for fid, src in PREP_WHOLE_SRC.items():
        rel = "sprites/ingredient/%s_whole.png" % fid
        if copy(src, os.path.join(ART, rel)):
            whole_reg[fid] = res(rel); n += 1
    for fid, src in PREP_CUT_SRC.items():
        rel = "sprites/ingredient/%s_cut.png" % fid
        if copy(src, os.path.join(ART, rel)):
            cut_reg[fid] = res(rel); n += 1
    for mid, src in METHOD_TOOL_SRC.items():
        rel = "sprites/tool/%s.png" % mid
        if copy(src, os.path.join(ART, rel)):
            tool_reg[mid] = res(rel); n += 1
    react_reg = {}
    for stars, src in REACTION_SRC.items():
        rel = "sprites/reaction/star%s.png" % stars
        if copy(src, os.path.join(ART, rel)):
            react_reg[stars] = res(rel); n += 1

    _emit_registry(food_reg, whole_reg, cut_reg, tool_reg, react_reg)
    print("[import_art_to_godot] 복사 %d 파일 + art_registry.gd 생성" % n)


def _dict_block(name: str, d: dict) -> str:
    lines = ["const %s := {" % name]
    for k in sorted(d.keys()):
        lines.append('\t"%s": "%s",' % (k, d[k]))
    lines.append("}")
    return "\n".join(lines)


def _emit_registry(food, whole, cut, tool, react):
    header = (
        "## ArtRegistry — food_id / method_id / stars → 스프라이트 res:// 경로 (자동 생성).\n"
        "##\n"
        "## 생성: tools/import_art_to_godot.py (수정 금지 — 매핑 변경은 임포터에서).\n"
        "## 일부 음식 완성샷은 미LOCK placeholder (art-anchor-rubric 참조).\n"
        "class_name ArtRegistry\n"
        "extends RefCounted\n\n"
    )
    body = "\n\n".join([
        _dict_block("FOOD", food),
        _dict_block("PREP_WHOLE", whole),
        _dict_block("PREP_CUT", cut),
        _dict_block("METHOD_TOOL", tool),
        _dict_block("REACTION", react),
    ])
    helpers = (
        "\n\n"
        "static func food(fid: StringName) -> String:\n"
        "\treturn FOOD.get(String(fid), \"\")\n\n"
        "static func prep_whole(fid: StringName) -> String:\n"
        "\treturn PREP_WHOLE.get(String(fid), \"\")\n\n"
        "static func prep_cut(fid: StringName) -> String:\n"
        "\treturn PREP_CUT.get(String(fid), \"\")\n\n"
        "static func method_tool(mid: StringName) -> String:\n"
        "\treturn METHOD_TOOL.get(String(mid), \"\")\n\n"
        "static func reaction(stars: int) -> String:\n"
        "\treturn REACTION.get(str(stars), \"\")\n"
    )
    os.makedirs(os.path.dirname(REG), exist_ok=True)
    with open(REG, "w", encoding="utf-8") as fh:
        fh.write(header + body + helpers)


if __name__ == "__main__":
    main()
