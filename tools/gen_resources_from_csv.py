#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_resources_from_csv.py — CSV → Godot .tres Resource 임포터 (K-Food Master)

docs/foods-database.csv + docs/ingredients-database.csv 를 읽어
godot-project/resources/ 하위에 .tres (Godot 4.x text resource) 를 생성한다.
또한 조리법(cooking_methods) / 가게(stores) / 타이밍 band(timing) 레지스트리도 생성한다.

원칙
- source of truth = docs/*.csv. 이 스크립트는 결정적(deterministic) — 같은 입력 → 같은 출력.
- notes 컬럼은 항상 마지막이며 쉼표를 포함할 수 있다 → split(',', N-1)로 처리.
- 다른 모든 다중값 컬럼(used_in_foods / cut_variations / method_options)은 세미콜론(;) 구분.
- 각 Resource의 own uid는 id 기반 결정적 생성 (재실행 시 안정적).

사용:  py tools/gen_resources_from_csv.py            # 생성
       py tools/gen_resources_from_csv.py --check    # dry-run (개수만 출력)
참조: docs/ui/scene-2-kitchen-layout.md §7.2, scripts/resources/*.gd
"""
from __future__ import annotations
import csv
import hashlib
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(ROOT, "docs")
RES = os.path.join(ROOT, "godot-project", "resources")

# 각 Resource 정의 스크립트의 uid (scripts/resources/*.gd.uid) — ext_resource 참조용
SCRIPT = {
    "food":   ("uid://tmwmc37kgdsy", "res://scripts/resources/food_definition.gd", "FoodDefinition"),
    "ing":    ("uid://df5hl3wmo1t33", "res://scripts/resources/ingredient_definition.gd", "IngredientDefinition"),
    "method": ("uid://c16ntsi703r1k", "res://scripts/resources/cooking_method_definition.gd", "CookingMethodDefinition"),
    "store":  ("uid://pxco5klnk05r",  "res://scripts/resources/store_definition.gd", "StoreDefinition"),
    "timing": ("uid://cynrm1dfeq6bh", "res://scripts/resources/timing_definition.gd", "TimingDefinition"),
}

_B36 = "abcdefghijklmnopqrstuvwxyz0123456789"


def gen_uid(seed: str) -> str:
    """id 기반 결정적 uid (uid://<13 base36>, 첫 글자는 알파벳)."""
    h = int.from_bytes(hashlib.md5(seed.encode("utf-8")).digest()[:8], "big")
    s = ""
    for _ in range(13):
        s += _B36[h % 36]
        h //= 36
    if s[0].isdigit():
        s = "b" + s[1:]
    return "uid://" + s


# ---- 값 직렬화 헬퍼 ----

def q(s: str) -> str:
    """Godot String 리터럴 (escape)."""
    return '"' + (s or "").replace("\\", "\\\\").replace('"', '\\"') + '"'


def sn(s: str) -> str:
    """StringName 리터럴."""
    return "&" + q(s or "")


def sn_array(items) -> str:
    inner = ", ".join(sn(x) for x in items if x != "")
    return "Array[StringName]([%s])" % inner


def f(x) -> str:
    """float 직렬화 (항상 소수점)."""
    return "%.1f" % float(x)


def split_row(line: str, ncols: int) -> list[str]:
    """notes(마지막 컬럼)의 쉼표 보존을 위한 제한 split."""
    return line.rstrip("\n").split(",", ncols - 1)


def read_csv(path: str):
    with open(path, encoding="utf-8") as fh:
        lines = [ln for ln in fh.read().splitlines() if ln.strip() != ""]
    header = lines[0].split(",")
    rows = [split_row(ln, len(header)) for ln in lines[1:]]
    return header, rows


def semic(val: str):
    return [x for x in val.split(";") if x.strip() != ""] if val else []


def write_tres(folder: str, name: str, script_key: str, body_lines: list[str], check: bool, counter: dict):
    uid, path, cls = SCRIPT[script_key]
    own = gen_uid(script_key + ":" + name)
    out = []
    out.append('[gd_resource type="Resource" script_class="%s" load_steps=2 format=3 uid="%s"]' % (cls, own))
    out.append("")
    out.append('[ext_resource type="Script" uid="%s" path="%s" id="1_%s"]' % (uid, path, script_key))
    out.append("")
    out.append("[resource]")
    out.append('script = ExtResource("1_%s")' % script_key)
    out.extend(body_lines)
    text = "\n".join(out) + "\n"
    counter[script_key] = counter.get(script_key, 0) + 1
    if check:
        return
    d = os.path.join(RES, folder)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, name + ".tres"), "w", encoding="utf-8") as fh:
        fh.write(text)


# ---- 레지스트리 (CSV에 없는 고정 데이터) ----

METHODS = {
    "boil": ("끓이기", "Boil"),
    "grill": ("굽기", "Grill"),
    "stirfry": ("볶기", "Stir-fry"),
    "panfry": ("부치기", "Pan-fry"),
    "deepfry": ("튀기기", "Deep-fry"),
    "roll": ("말기", "Roll"),
    "mix": ("비비기", "Mix"),
    "toss": ("섞기", "Toss"),
    "marinate": ("양념재우기", "Marinate"),
}

STORES = {
    "produce": ("농산물 가게", (0.45, 0.70, 0.30, 1.0)),
    "meat": ("정육점", (0.80, 0.25, 0.25, 1.0)),
    "seafood": ("어물전", (0.25, 0.55, 0.80, 1.0)),
    "grain": ("곡물 가게", (0.85, 0.70, 0.35, 1.0)),
    "sundry": ("잡화점", (0.70, 0.45, 0.75, 1.0)),
    "pantry": ("기본 양념 (Kitchen rack)", (0.60, 0.55, 0.50, 1.0)),
}

# C-4 lock (2026-05-24) + timing_definition.gd: perfect 10 / good 45 / miss 45 / no_tap 0
BANDS = [
    ("perfect", 0.10, 1.0),
    ("good", 0.45, 0.6),
    ("miss", 0.45, 0.2),
    ("no_tap", 0.0, 0.0),
]


def main():
    check = "--check" in sys.argv
    counter: dict = {}

    # --- foods ---
    fh, frows = read_csv(os.path.join(DOCS, "foods-database.csv"))
    idx = {c: i for i, c in enumerate(fh)}
    for r in frows:
        g = lambda c: r[idx[c]] if idx.get(c) is not None and idx[c] < len(r) else ""
        body = [
            "food_id = %s" % sn(g("food_id")),
            "name_ko = %s" % q(g("name_ko")),
            "name_en = %s" % q(g("name_en")),
            "tier = %s" % int(g("tier")),
            "servings = %s" % int(g("servings")),
            "store_count = %s" % int(g("store_count")),
            "primary_cooking_method = %s" % sn(g("primary_cooking_method")),
            "secondary_method = %s" % sn(g("secondary_method")),
            "cook_time_sec = %s" % f(g("cook_time_sec")),
            "perfect_window_ms = %s" % f(g("perfect_window_ms")),
            "difficulty_score = %s" % int(g("difficulty_score")),
            "visual_appeal_score = %s" % int(g("visual_appeal_score")),
            "recognition_score = %s" % int(g("recognition_score")),
            "ad_trigger_priority = %s" % q(g("ad_trigger_priority")),
            "prep_ingredient_id = %s" % sn(g("prep_ingredient_id")),
            "prep_cut_style = %s" % sn(g("prep_cut_style")),
            "prep_bpm = %s" % int(g("prep_bpm")),
            "prep_taps = %s" % int(g("prep_taps")),
            "correct_method_id = %s" % sn(g("correct_method_id")),
            "method_options = %s" % sn_array(semic(g("method_options"))),
            "notes = %s" % q(g("notes")),
        ]
        write_tres("foods", g("food_id"), "food", body, check, counter)

    # --- ingredients ---
    ih, irows = read_csv(os.path.join(DOCS, "ingredients-database.csv"))
    iidx = {c: i for i, c in enumerate(ih)}
    for r in irows:
        g = lambda c: r[iidx[c]] if iidx.get(c) is not None and iidx[c] < len(r) else ""
        body = [
            "ingredient_id = %s" % sn(g("ingredient_id")),
            "name_ko = %s" % q(g("name_ko")),
            "name_en = %s" % q(g("name_en")),
            "store_type = %s" % sn(g("store_type")),
            "used_in_foods = %s" % sn_array(semic(g("used_in_foods"))),
            "is_distractor_friendly = %s" % ("true" if g("is_distractor_friendly").strip().lower() == "true" else "false"),
            "distractor_weight = %s" % int(g("distractor_weight") or 1),
            "is_basic_pantry = %s" % ("true" if g("is_basic_pantry").strip().lower() == "true" else "false"),
            "cut_variations = %s" % sn_array(semic(g("cut_variations"))),
            "notes = %s" % q(g("notes")),
        ]
        write_tres("ingredients", g("ingredient_id"), "ing", body, check, counter)

    # --- cooking_methods ---
    for mid, (ko, en) in METHODS.items():
        body = [
            "method_id = %s" % sn(mid),
            "name_ko = %s" % q(ko),
            "name_en = %s" % q(en),
            "default_perfect_window_ms = 1000.0",
            "default_cook_time_sec = 10.0",
        ]
        write_tres("cooking_methods", mid, "method", body, check, counter)

    # --- stores ---
    for sid, (ko, col) in STORES.items():
        body = [
            "store_id = %s" % sn(sid),
            "name_ko = %s" % q(ko),
            "signature_color = Color(%s, %s, %s, %s)" % tuple("%.3f" % c for c in col),
        ]
        write_tres("stores", sid, "store", body, check, counter)

    # --- timing bands ---
    for bid, w, acc in BANDS:
        body = [
            "band_id = %s" % sn(bid),
            "weight = %s" % f(w),
            "accuracy_value = %s" % f(acc),
            'remote_config_key = "cooking.stage3.band_distribution"',
        ]
        write_tres("timing", bid, "timing", body, check, counter)

    mode = "CHECK (dry-run)" if check else "WROTE"
    print("[gen_resources_from_csv] %s" % mode)
    for k in ("food", "ing", "method", "store", "timing"):
        print("  %-7s : %d" % (k, counter.get(k, 0)))
    print("  TOTAL   : %d" % sum(counter.values()))
    if not check:
        print("  -> %s" % RES)


if __name__ == "__main__":
    main()
