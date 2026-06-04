#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ingest_sfx.py — 외부 CC0 오디오 → K-Food Master SFX 슬롯 인제스트 (sound sprint #1, 외부소스).

워크플로
  1) CC0 파일을 다운로드 (Pixabay/OpenGameArt CC0/freesound CC0 — SOURCES.md 참조).
  2) godot-project/audio/sfx/_incoming/ 에 **슬롯 key 이름**으로 저장 (확장자 무관):
        예) _incoming/metro_strong.mp3, _incoming/judge_perfect.wav, _incoming/act_boil.ogg
  3) py tools/ingest_sfx.py   ← 본 스크립트 실행.
  4) 각 파일을 트림(≤0.8s)·-14 LUFS 정규화·페이드·16-bit PCM 44.1kHz mono 변환 후
     godot-project/audio/sfx/<key>.wav 로 덮어씀 (레지스트리 경로 동일 → 코드 변경 0).
  5) _incoming에 없는 슬롯은 "보류"로 보고 (기존 합성본 유지).

옵션: --max 0.8 (최대 길이 초) / --lufs -14 / --slot metro_strong (특정 슬롯만)
deps: ffmpeg, ffprobe (시스템). numpy/scipy 불필요.
"""
from __future__ import annotations
import argparse
import json
import os
import subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SFX = os.path.join(ROOT, "godot-project", "audio", "sfx")
INBOX = os.path.join(SFX, "_incoming")
DROPBOX = os.path.join(SFX, "_dropbox")
MAPPING = os.path.join(DROPBOX, "mapping.txt")  # 형식: "slot_key  원본파일명" (줄당 1개, # 주석)

SLOTS = [
	# metronome / judgment
	"metro_strong", "metro_weak",
	"judge_perfect", "judge_good", "judge_miss",
	# cooking phase actions (4 new phases + existing)
	"act_chop", "act_boil", "act_done",
	"act_stir", "act_panfry", "act_roll", "act_mix",
	# per-seasoning taps
	"season_gochujang", "season_gochugaru", "season_ganjang",
	"season_seoltang", "season_chamgireum",
	# UI
	"ui_select", "ui_menu", "sting_start", "sting_finish",
	# evaluator entrance stings
	"sting_mystery", "sting_daniel", "sting_goldspoon",
]
AUDIO_EXT = (".wav", ".mp3", ".ogg", ".flac", ".aiff", ".aif", ".m4a")


def find_incoming(slot: str):
	for ext in AUDIO_EXT:
		p = os.path.join(INBOX, slot + ext)
		if os.path.exists(p):
			return p
	return None


def probe_dur(path: str) -> float:
	try:
		out = subprocess.run(
			["ffprobe", "-v", "error", "-show_entries", "format=duration",
			 "-of", "json", path], capture_output=True, text=True, check=True)
		return float(json.loads(out.stdout)["format"]["duration"])
	except Exception:
		return 0.0


def ingest(slot: str, src: str, max_s: float, lufs: float) -> bool:
	dur = probe_dur(src)
	out_dur = min(dur, max_s) if dur > 0 else max_s
	fade_out = max(0.04, min(0.06, out_dur * 0.15))
	fo_start = max(0.0, out_dur - fade_out)
	# 트림 → 정규화(loudnorm) → 페이드 in/out → mono 44.1k 16-bit
	af = (
		"atrim=0:%.3f," % out_dur
		+ "loudnorm=I=%.1f:TP=-1.5:LRA=11," % lufs
		+ "afade=t=in:st=0:d=0.006,"
		+ "afade=t=out:st=%.3f:d=%.3f" % (fo_start, fade_out)
	)
	dst = os.path.join(SFX, slot + ".wav")
	cmd = ["ffmpeg", "-y", "-i", src, "-af", af,
		   "-ar", "44100", "-ac", "1", "-sample_fmt", "s16", dst]
	r = subprocess.run(cmd, capture_output=True, text=True)
	if r.returncode != 0:
		print("  [FAIL] %s\n    %s" % (slot, r.stderr.strip().splitlines()[-1] if r.stderr else "?"))
		return False
	print("  [OK]   %-14s ← %s (%.2fs→%.2fs)" % (slot, os.path.basename(src), dur, out_dur))
	return True


def read_mapping():
	"""_dropbox/mapping.txt → {slot: 절대경로}. 형식: 'slot_key  원본파일명'."""
	pairs = {}
	if not os.path.exists(MAPPING):
		return pairs
	with open(MAPPING, encoding="utf-8") as fh:
		for ln in fh:
			ln = ln.strip()
			if not ln or ln.startswith("#"):
				continue
			parts = ln.split(None, 1)
			if len(parts) != 2:
				continue
			slot, fname = parts[0], parts[1].strip()
			src = os.path.join(DROPBOX, fname)
			if slot in SLOTS and os.path.exists(src):
				pairs[slot] = src
			else:
				print("  [경고] 매핑 무시: %s (슬롯/파일 확인)" % ln)
	return pairs


def main():
	ap = argparse.ArgumentParser()
	ap.add_argument("--max", type=float, default=0.8)
	ap.add_argument("--lufs", type=float, default=-14.0)
	ap.add_argument("--slot", default=None)
	ap.add_argument("--dropbox", action="store_true", help="_dropbox/mapping.txt 기반 인제스트")
	args = ap.parse_args()

	done, pending = [], []
	if args.dropbox:
		mp = read_mapping()
		print("[ingest_sfx] _dropbox/mapping.txt → SFX 슬롯 (≤%.1fs, %.0f LUFS)" % (args.max, args.lufs))
		for s in SLOTS:
			if s in mp and ingest(s, mp[s], args.max, args.lufs):
				done.append(s)
			else:
				pending.append(s)
	else:
		os.makedirs(INBOX, exist_ok=True)
		slots = [args.slot] if args.slot else SLOTS
		print("[ingest_sfx] _incoming → SFX 슬롯 (≤%.1fs, %.0f LUFS)" % (args.max, args.lufs))
		for s in slots:
			src = find_incoming(s)
			if src is None:
				pending.append(s)
				continue
			if ingest(s, src, args.max, args.lufs):
				done.append(s)
			else:
				pending.append(s)
	print("\n완료 %d: %s" % (len(done), ", ".join(done) if done else "-"))
	print("보류 %d (합성본 유지): %s" % (len(pending), ", ".join(pending) if pending else "-"))
	print("\n다음: py tools/make_sfx_preview.py 로 preview 재생성 (또는 알림 주세요).")


if __name__ == "__main__":
	main()
