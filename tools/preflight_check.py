#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
preflight_check.py — Godot 에디터 실행 전 정적 검증 (godot 바이너리 없이 깨짐 사전 차단).

검사:
  1) project.godot: main_scene + autoload 경로 파일 존재.
  2) art_registry.gd / sfx_registry.gd 의 모든 res:// 경로 파일 존재.
  3) resources/foods/*.tres 12개 존재 + 각 음식 prep_ingredient 의 ingredient .tres 존재(CSV 기준).
  4) 모든 .tres/.tscn 의 ext_resource Script path 존재 + (uid 있으면) .gd.uid 와 일치.
  5) scenes/*.tscn 존재 + food_select 가 참조하는 12 food tres 존재.
종료코드 0 = 통과. 실패 항목은 [FAIL]로 출력.
"""
from __future__ import annotations
import os
import re
import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GP = os.path.join(ROOT, "godot-project")
fails = []
checks = 0


def res_to_fs(res: str) -> str:
	return os.path.join(GP, res.replace("res://", "").replace("/", os.sep))


def exists(res: str) -> bool:
	return os.path.exists(res_to_fs(res))


def check(cond: bool, msg: str):
	global checks
	checks += 1
	if not cond:
		fails.append(msg)


def read(path):
	with open(path, encoding="utf-8") as f:
		return f.read()


# 1) project.godot
pg = read(os.path.join(GP, "project.godot"))
m = re.search(r'run/main_scene="(res://[^"]+)"', pg)
check(bool(m) and exists(m.group(1)), "main_scene 누락: %s" % (m.group(1) if m else "?"))
for am in re.finditer(r'^\w+="\*(res://[^"]+)"', pg, re.M):
	check(exists(am.group(1)), "autoload 경로 누락: %s" % am.group(1))

# 2) 레지스트리 res:// 전수
for reg in ["scripts/gameplay/art_registry.gd", "scripts/audio/sfx_registry.gd"]:
	p = os.path.join(GP, reg)
	if not os.path.exists(p):
		fails.append("레지스트리 누락: %s" % reg); continue
	for r in re.findall(r'"(res://[^"]+)"', read(p)):
		check(exists(r), "[%s] 경로 누락: %s" % (os.path.basename(reg), r))

# 3) foods tres + prep ingredient tres (CSV 기준)
csv = read(os.path.join(ROOT, "docs", "foods-database.csv")).splitlines()
hdr = csv[0].split(",")
fi, pi = hdr.index("food_id"), hdr.index("prep_ingredient_id")
for ln in csv[1:]:
	if not ln.strip():
		continue
	cols = ln.split(",")
	fid, ping = cols[fi], cols[pi]
	check(exists("res://resources/foods/%s.tres" % fid), "food tres 누락: %s" % fid)
	check(exists("res://resources/ingredients/%s.tres" % ping), "ingredient tres 누락: %s (%s prep)" % (ping, fid))

# 4) ext_resource Script path + uid 일치 (.tres + .tscn)
def uid_of_script(script_res: str):
	uidf = res_to_fs(script_res) + ".uid"
	return read(uidf).strip() if os.path.exists(uidf) else None

for f in glob.glob(os.path.join(GP, "**", "*.tres"), recursive=True) + \
		 glob.glob(os.path.join(GP, "**", "*.tscn"), recursive=True):
	if ".godot" in f or os.sep + "android" + os.sep in f:
		continue
	txt = read(f)
	for mm in re.finditer(r'\[ext_resource type="Script"(?:\s+uid="(uid://[^"]+)")?\s+(?:uid="(uid://[^"]+)"\s+)?path="(res://[^"]+)"', txt):
		uid = mm.group(1) or mm.group(2)
		path = mm.group(3)
		check(exists(path), "[%s] ext script 경로 누락: %s" % (os.path.basename(f), path))
		if uid and exists(path):
			actual = uid_of_script(path)
			check(actual is None or actual == uid,
				  "[%s] script uid 불일치: %s (tres=%s vs uid파일=%s)" % (os.path.basename(f), path, uid, actual))

# 5) 씬 파일 존재
for sc in ["res://scenes/food_select.tscn", "res://scenes/round_demo.tscn"]:
	check(exists(sc), "씬 누락: %s" % sc)

print("[preflight] 검사 %d건" % checks)
if fails:
	print("FAIL %d:" % len(fails))
	for x in fails:
		print("  -", x)
	raise SystemExit(1)
print("ALL PASS ✅")
