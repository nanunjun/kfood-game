#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen_sfx.py — K-Food Master 핵심 SFX 코드 합성 (sound sprint #1, v2 = 물리모델 재작성).

v1(순수 사인/삼각파)이 "너무 전자음"(사용자 2026-06-01) → v2에서 합성 기법 전면 교체:
  - 타악(나무 박/도마/칼질/UI) = **노이즈 타격 + 2극 공명필터(modal)** — 사인 onset 제거, 자연 transient.
  - 종(판정/완성, 놋그릇) = **다중 inharmonic 모달 + 비팅(beating)** + 타격 exciter — 단순 beep 회피.
  - 발현음(시작/종료 sting) = **Karplus-Strong 현 물리모델 (가야금 결)** — 자연 plucked string.
  - 끓음 = 물방울 공명 blip. 휘젓기 = 대역통과 노이즈 swish.
모두 butter lowpass로 고역 roll-off(따뜻함) + raised-cosine fade.

톤 north star: "따뜻한 한식 주방·시장 — 나무 박, 놋그릇 울림, 가야금, 보글. 차가운 전자음/SF 회피."
출력: godot-project/audio/sfx/*.wav (12종, 16-bit/44.1kHz mono) + scripts/audio/sfx_registry.gd.
deps: numpy, scipy. 사용: py tools/gen_sfx.py
"""
from __future__ import annotations
import os
import wave
import numpy as np
from scipy.signal import lfilter, butter

SR = 44100
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "godot-project", "audio", "sfx")
REG = os.path.join(ROOT, "godot-project", "scripts", "audio", "sfx_registry.gd")
rng = np.random.default_rng(20260601)

SCALE = {"G4": 392.0, "A4": 440.0, "C5": 523.25, "D5": 587.33, "E5": 659.25, "C4": 261.63, "G3": 196.0}


# ---------- 기본 빌딩 블록 ----------

def secs(n):
	return n / SR


def fade(sig, fin=0.003, fout=0.02):
	n = len(sig)
	a = int(SR * fin)
	b = int(SR * fout)
	if a > 0 and a < n:
		sig[:a] *= 0.5 * (1 - np.cos(np.linspace(0, np.pi, a)))
	if b > 0 and b < n:
		sig[-b:] *= 0.5 * (1 + np.cos(np.linspace(0, np.pi, b)))
	return sig


def lp(sig, cutoff, order=4):
	b, a = butter(order, min(cutoff / (SR / 2), 0.99), btype="low")
	return lfilter(b, a, sig)


def bp(sig, lo, hi, order=2):
	b, a = butter(order, [lo / (SR / 2), min(hi / (SR / 2), 0.99)], btype="band")
	return lfilter(b, a, sig)


def strike(dur, ms=2.5):
	"""타격 exciter — 짧은 broadband 노이즈 버스트 (자연 transient의 핵심)."""
	n = int(SR * dur)
	e = np.zeros(n)
	k = max(1, int(SR * ms / 1000.0))
	e[:k] = rng.uniform(-1, 1, k)
	return e


def reson(exc, freq, decay_s):
	"""2극 공명필터 = 감쇠 사인 모드. exc로 여기(excite)."""
	r = np.exp(-1.0 / (decay_s * SR))
	w = 2 * np.pi * freq / SR
	a = [1.0, -2 * r * np.cos(w), r * r]
	return lfilter([1.0], a, exc)


def modal(freq, dur, modes, lp_cut, detune=0.0, strike_ms=2.5):
	"""modes = [(ratio, amp, decay_s), ...]. detune>0이면 비팅 partial 추가."""
	exc = strike(dur, strike_ms)
	out = np.zeros(int(SR * dur))
	for r, a, d in modes:
		out += a * reson(exc, freq * r, d)
		if detune > 0:
			out += a * 0.55 * reson(exc, freq * r + detune, d)
	out = lp(out, lp_cut)
	return out


def karplus(freq, dur, decay=0.9965, exc_lp=2600):
	"""Karplus-Strong 발현음 (가야금/현). 노이즈 여기 + 평균 피드백 = 자연 plucked string."""
	N = max(2, int(round(SR / freq)))
	buf = rng.uniform(-1, 1, N)
	buf = lp(buf, exc_lp)  # 여기 노이즈를 부드럽게 = 따뜻한 발현
	n = int(SR * dur)
	out = np.empty(n)
	prev = buf[-1]
	idx = 0
	for i in range(n):
		cur = buf[idx]
		out[i] = cur
		nv = decay * 0.5 * (cur + prev)
		buf[idx] = nv
		prev = cur
		idx = (idx + 1) % N
	return out


def norm(sig, peak=0.85):
	return sig / (np.max(np.abs(sig)) + 1e-9) * peak


# ---------- 개별 SFX ----------

def s_metro_strong():
	# 나무 박 강박 — 낮은 wood 공명, 짧고 단단
	s = modal(620, 0.10, [(1.0, 1.0, 0.045), (2.8, 0.45, 0.025), (5.1, 0.2, 0.014)], 4200, strike_ms=2.0)
	return norm(fade(s), 0.82)


def s_metro_weak():
	# 약박 — 높고 가볍게
	s = modal(1000, 0.07, [(1.0, 1.0, 0.028), (2.8, 0.35, 0.016)], 4600, strike_ms=1.5)
	return norm(fade(s), 0.5)


def s_act_chop():
	# 칼이 도마에 — 노이즈 transient 강하게 + 낮은 wood thunk
	exc = strike(0.08, 3.5)
	wood = 0.8 * reson(exc, 420, 0.03) + 0.3 * reson(exc, 1150, 0.018)
	noise = exc * 0.9
	s = lp(wood + noise, 3200)
	return norm(fade(s, fin=0.0005), 0.82)


def s_ui_select():
	# 가벼운 나무 톡 (메뉴)
	s = modal(840, 0.07, [(1.0, 1.0, 0.03), (2.7, 0.3, 0.018)], 4000, strike_ms=1.5)
	return norm(fade(s), 0.5)


def s_judge_perfect():
	# 놋그릇 "딩↑" — 다중 inharmonic 모달 + 비팅, 따뜻·보상
	s = modal(680, 0.5,
			  [(1.0, 1.0, 0.45), (2.76, 0.5, 0.32), (5.40, 0.25, 0.20), (8.93, 0.10, 0.13)],
			  4500, detune=0.7, strike_ms=1.2)
	return norm(fade(s, fout=0.06), 0.82)


def s_judge_good():
	# 부드러운 놋그릇 단타 — 짧고 절제
	s = modal(560, 0.24, [(1.0, 1.0, 0.20), (2.76, 0.4, 0.13), (5.4, 0.12, 0.08)],
			  3600, detune=0.5, strike_ms=1.2)
	return norm(fade(s, fout=0.04), 0.62)


def s_judge_miss():
	# 둔탁한 낮은 "툭" — 노이즈 + 저역 모드, 헤비 lowpass(가혹 X)
	exc = strike(0.16, 4.0)
	s = 1.0 * reson(exc, 175, 0.10) + 0.4 * reson(exc, 300, 0.05) + 0.5 * exc
	s = lp(s, 850)
	return norm(fade(s, fin=0.001, fout=0.04), 0.6)


def s_act_stir():
	# "쓱" — 대역통과 노이즈 swish, 종형 env
	n = int(SR * 0.32)
	noise = rng.uniform(-1, 1, n)
	sw = bp(noise, 350, 1500)
	t = np.linspace(0, 1, n)
	env = np.sin(np.pi * t) ** 1.3
	return norm(fade(sw * env, fin=0.02, fout=0.04), 0.5)


def s_act_boil():
	# "보글" — 물방울 공명 blip 5개 (짧은 reson burst, 랜덤 저역)
	dur = 0.5
	out = np.zeros(int(SR * dur))
	for _ in range(6):
		f = rng.uniform(240, 520)
		start = rng.uniform(0, dur - 0.1)
		blip = reson(strike(0.08, 1.0), f, 0.018) * rng.uniform(0.5, 1.0)
		i0 = int(SR * start)
		out[i0:i0 + len(blip)] += blip
	s = lp(out, 1900)
	return norm(fade(s), 0.6)


def s_act_done():
	# 완성 놋그릇 "딩—" — 긴 여운 + 비팅 shimmer
	s = modal(523.25, 0.7,
			  [(1.0, 1.0, 0.62), (2.0, 0.5, 0.45), (2.98, 0.3, 0.32), (4.5, 0.14, 0.20)],
			  4000, detune=0.8, strike_ms=1.0)
	return norm(fade(s, fout=0.08), 0.72)


def _ks_note(freq, dur, decay=0.9965, amp=1.0):
	out = karplus(freq, dur, decay=decay)
	t = np.linspace(0, 1, len(out))
	out *= np.exp(-t * 1.2)  # pluck 자연 감쇠 보강
	return out * amp


def s_sting_start():
	# 가야금 상행 3음 (평조 G→C→E)
	dur = 0.55
	out = np.zeros(int(SR * dur))
	for f, st, a in [(SCALE["G4"], 0.0, 0.9), (SCALE["C5"], 0.12, 0.95), (SCALE["E5"], 0.24, 1.0)]:
		p = _ks_note(f, 0.30, decay=0.994, amp=a)
		i0 = int(SR * st)
		m = min(len(p), len(out) - i0)
		out[i0:i0 + m] += p[:m]
	return norm(fade(out, fout=0.05), 0.78)


def s_sting_finish():
	# 가야금 마무리 화음 (평조 동시 + 저음, resolved)
	dur = 0.7
	out = np.zeros(int(SR * dur))
	for f, a in [(SCALE["G3"], 0.7), (SCALE["C5"], 0.9), (SCALE["E5"], 0.7), (SCALE["G4"], 0.8)]:
		p = _ks_note(f, 0.66, decay=0.9975, amp=a)
		m = min(len(p), len(out))
		out[:m] += p[:m]
	return norm(fade(out, fout=0.08), 0.8)


SOUNDS = {
	"metro_strong": s_metro_strong, "metro_weak": s_metro_weak,
	"judge_perfect": s_judge_perfect, "judge_good": s_judge_good, "judge_miss": s_judge_miss,
	"act_chop": s_act_chop, "act_stir": s_act_stir, "act_boil": s_act_boil, "act_done": s_act_done,
	"ui_select": s_ui_select, "sting_start": s_sting_start, "sting_finish": s_sting_finish,
}


def write_wav(path, sig):
	pcm = (np.clip(sig, -1, 1) * 32767.0).astype("<i2")
	with wave.open(path, "wb") as w:
		w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())


def centroid(sig):
	mag = np.abs(np.fft.rfft(sig))
	freqs = np.fft.rfftfreq(len(sig), 1.0 / SR)
	return float(np.sum(freqs * mag) / (np.sum(mag) + 1e-9))


def emit_registry(keys):
	head = ("## SfxRegistry — sfx key → res:// 경로 (자동 생성, tools/gen_sfx.py).\n"
			"## 수정 금지 — 사운드 추가/변경은 gen_sfx.py에서.\n"
			"class_name SfxRegistry\nextends RefCounted\n\nconst PATHS := {\n")
	body = "\n".join('\t"%s": "res://audio/sfx/%s.wav",' % (k, k) for k in sorted(keys))
	foot = ("\n}\n\nstatic func path(key: StringName) -> String:\n\treturn PATHS.get(String(key), \"\")\n")
	os.makedirs(os.path.dirname(REG), exist_ok=True)
	with open(REG, "w", encoding="utf-8") as fh:
		fh.write(head + body + foot)


def main():
	os.makedirs(OUT, exist_ok=True)
	print("[gen_sfx v2 물리모델] SR=%d 16-bit mono" % SR)
	print("%-15s %7s %8s %10s" % ("sfx", "dur(s)", "peak", "centroid"))
	for name, fn in SOUNDS.items():
		sig = np.asarray(fn(), dtype=np.float64)
		write_wav(os.path.join(OUT, name + ".wav"), sig)
		print("%-15s %7.3f %8.2f %9.0fHz" % (name, len(sig) / SR, float(np.max(np.abs(sig))), centroid(sig)))
	emit_registry(SOUNDS.keys())
	print("[gen_sfx] %d WAV + sfx_registry.gd → %s" % (len(SOUNDS), OUT))


if __name__ == "__main__":
	main()
