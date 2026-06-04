#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
make_sfx_preview.py — 12 SFX 슬롯을 한 파일로 묶은 미리듣기 생성.

구성: (1) 카탈로그 — 12종 순서대로 0.45s 간격, (2) 라면 라운드 시뮬레이션(100 BPM).
출력: outputs/kfood_sfx_preview.wav (16-bit/44.1kHz mono). deps: numpy.
사용: py tools/make_sfx_preview.py [--out 경로]
"""
from __future__ import annotations
import argparse
import os
import wave
import numpy as np

SR = 44100
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SFX = os.path.join(ROOT, "godot-project", "audio", "sfx")
KEYS = ["metro_strong", "metro_weak", "judge_perfect", "judge_good", "judge_miss",
		"act_chop", "act_stir", "act_boil", "act_done", "ui_select", "sting_start", "sting_finish"]


def load(n):
	p = os.path.join(SFX, n + ".wav")
	w = wave.open(p, "rb")
	# 16-bit mono 가정; 스테레오면 좌채널만
	ch = w.getnchannels()
	d = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(np.float64) / 32767.0
	w.close()
	if ch == 2:
		d = d[::2]
	return d


def sil(s):
	return np.zeros(int(SR * s))


def main():
	ap = argparse.ArgumentParser()
	ap.add_argument("--out", default=os.path.join(ROOT, "..", "outputs", "kfood_sfx_preview.wav"))
	args = ap.parse_args()

	snd = {k: load(k) for k in KEYS}
	cat = []
	for k in KEYS:
		cat += [snd[k], sil(0.45)]
	catalog = np.concatenate(cat)

	bp = 0.6
	tl = np.zeros(int(SR * 12))

	def place(buf, sig, t):
		i = int(SR * t)
		n = min(len(sig), len(buf) - i)
		if n > 0:
			buf[i:i + n] += sig[:n]

	t = 0.2
	place(tl, snd["sting_start"], t); t += 1.0
	for i in range(4):
		place(tl, snd["metro_strong"] if i == 0 else snd["metro_weak"], t)
		place(tl, snd["act_chop"], t + 0.02)
		place(tl, snd["judge_perfect"], t + 0.05)
		t += bp
	t += 0.4
	place(tl, snd["judge_perfect"], t); t += 0.9
	place(tl, snd["act_boil"], t); t += 1.6
	place(tl, snd["judge_perfect"], t); t += 0.5
	place(tl, snd["act_done"], t); t += 0.9
	place(tl, snd["sting_finish"], t); t += 1.0
	sim = tl[:int(SR * (t + 0.3))]

	out = np.concatenate([catalog, sil(1.0), sim])
	out = out / (np.max(np.abs(out)) + 1e-9) * 0.9
	pcm = (np.clip(out, -1, 1) * 32767).astype("<i2")
	op = os.path.abspath(args.out)
	os.makedirs(os.path.dirname(op), exist_ok=True)
	w = wave.open(op, "wb")
	w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
	w.close()
	print("[make_sfx_preview] %s (%.1fs)" % (op, len(out) / SR))


if __name__ == "__main__":
	main()
