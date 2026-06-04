#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_shopping_from_csv.py — 음식별 정답 재료 레지스트리 (가게 방문 쇼핑용).

ingredients-database.csv used_in_foods 역산. basic_pantry 제외.
출력 scripts/gameplay/shopping_registry.gd:
  CORRECT          : food_id → [정답 재료 name_en]            (평면, 개수/조립용)
  CORRECT_BY_STORE : food_id → { store_type → [정답 name_en] } (가게 방문용)
  POOL_BY_STORE    : store_type → [그 가게 전체 name_en]        (디스트랙터용)
사용: py tools/gen_shopping_from_csv.py
"""
from __future__ import annotations
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ING = os.path.join(ROOT, "docs", "ingredients-database.csv")
OUT = os.path.join(ROOT, "godot-project", "scripts", "gameplay", "shopping_registry.gd")


def main():
	lines = [l for l in open(ING, encoding="utf-8").read().splitlines() if l.strip()]
	hdr = lines[0].split(",")
	idx = {c: i for i, c in enumerate(hdr)}
	correct: dict = {}
	correct_store: dict = {}
	pool_store: dict = {}
	for ln in lines[1:]:
		c = ln.split(",", len(hdr) - 1)
		name = c[idx["name_en"]].strip()
		store = c[idx["store_type"]].strip()
		uf = c[idx["used_in_foods"]].strip()
		basic = c[idx["is_basic_pantry"]].strip().lower() == "true"
		if basic or name == "" or store == "":
			continue
		pool_store.setdefault(store, [])
		if name not in pool_store[store]:
			pool_store[store].append(name)
		for f in uf.split(";"):
			f = f.strip()
			if not f:
				continue
			correct.setdefault(f, [])
			if name not in correct[f]:
				correct[f].append(name)
			correct_store.setdefault(f, {})
			correct_store[f].setdefault(store, [])
			if name not in correct_store[f][store]:
				correct_store[f][store].append(name)

	def arr(items):
		return "[" + ", ".join('"%s"' % x for x in items) + "]"

	def dict_of_arr(d):
		parts = ['"%s": %s' % (k, arr(d[k])) for k in sorted(d.keys())]
		return "{" + ", ".join(parts) + "}"

	out = []
	out.append("## ShoppingRegistry — food_id → 정답 재료 (자동 생성, tools/gen_shopping_from_csv.py).")
	out.append("## CORRECT(평면) / CORRECT_BY_STORE(가게별) / POOL_BY_STORE(가게 전체). basic_pantry 제외.")
	out.append("class_name ShoppingRegistry")
	out.append("extends RefCounted\n")
	out.append("const CORRECT := {")
	for fid in sorted(correct.keys()):
		out.append('\t"%s": %s,' % (fid, arr(correct[fid])))
	out.append("}\n")
	out.append("const CORRECT_BY_STORE := {")
	for fid in sorted(correct_store.keys()):
		out.append('\t"%s": %s,' % (fid, dict_of_arr(correct_store[fid])))
	out.append("}\n")
	out.append("const POOL_BY_STORE := {")
	for store in sorted(pool_store.keys()):
		out.append('\t"%s": %s,' % (store, arr(pool_store[store])))
	out.append("}\n")
	out.append("static func correct(fid: StringName) -> Array:")
	out.append('\treturn CORRECT.get(String(fid), [])\n')
	out.append("static func correct_by_store(fid: StringName) -> Dictionary:")
	out.append('\treturn CORRECT_BY_STORE.get(String(fid), {})\n')
	out.append("static func pool_by_store(store: StringName) -> Array:")
	out.append('\treturn POOL_BY_STORE.get(String(store), [])')

	os.makedirs(os.path.dirname(OUT), exist_ok=True)
	with open(OUT, "w", encoding="utf-8") as fh:
		fh.write("\n".join(out) + "\n")
	print("[gen_shopping] foods=%d stores=%d → %s" % (len(correct), len(pool_store), OUT))


if __name__ == "__main__":
	main()
