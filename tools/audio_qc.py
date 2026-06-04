#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
audio_qc.py — QC overlay for ingested SFX (sound sprint, external sources).

Builds a single preview WAV that plays each ingested phase/judgment SFX on a steady
metronome grid, so you can hear whether attacks land ON the beat (rhythm feel QC).

Usage:
  py tools/audio_qc.py                 # default 120 BPM, all action+judge slots
  py tools/audio_qc.py --bpm 132
  py tools/audio_qc.py --slots act_chop,act_stir,judge_perfect

Output: godot-project/audio/sfx/kfood_sfx_qc.wav  (click track + slot hits aligned to beats)
deps: ffmpeg (system). No numpy/scipy.
"""
from __future__ import annotations
import argparse
import os
import subprocess
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SFX = os.path.join(ROOT, "godot-project", "audio", "sfx")
DEFAULT_SLOTS = ["act_chop", "act_stir", "act_panfry", "act_roll", "act_mix",
                 "act_boil", "judge_perfect", "judge_good", "judge_miss"]


def have_ffmpeg() -> bool:
    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True)
        return True
    except Exception:
        return False


def make_click(path: str, beats: int, beat_s: float) -> None:
    """Generate a metronome click track: a short 1kHz blip at each beat."""
    total = beats * beat_s
    # one click = 1kHz sine 0.03s; repeat every beat via aevalsrc gate
    expr = "0.35*sin(2*PI*1000*t)*lt(mod(t\\,%.4f)\\,0.03)" % beat_s
    cmd = ["ffmpeg", "-y", "-f", "lavfi",
           "-i", "aevalsrc=%s:s=44100:d=%.3f" % (expr, total),
           "-ac", "1", "-ar", "44100", "-sample_fmt", "s16", path]
    subprocess.run(cmd, capture_output=True, check=True)


def slot_path(slot: str) -> str | None:
    p = os.path.join(SFX, slot + ".wav")
    return p if os.path.exists(p) else None


def place_on_grid(slots, beat_s: float, tmp: str) -> str | None:
    """Place each slot's hit at successive beats, padded to the grid; concat to one file."""
    parts = []
    for i, slot in enumerate(slots):
        sp = slot_path(slot)
        if sp is None:
            print("  [skip] %s (not ingested yet)" % slot)
            continue
        # pad each hit to exactly beat_s so hits land on the grid
        out = os.path.join(tmp, "g%02d.wav" % i)
        af = "adelay=0|0,apad=whole_dur=%.3f,atrim=0:%.3f" % (beat_s, beat_s)
        subprocess.run(["ffmpeg", "-y", "-i", sp, "-af", af,
                        "-ac", "1", "-ar", "44100", "-sample_fmt", "s16", out],
                       capture_output=True, check=True)
        parts.append(out)
    if not parts:
        return None
    listf = os.path.join(tmp, "list.txt")
    with open(listf, "w") as fh:
        for p in parts:
            fh.write("file '%s'\n" % p)
    seq = os.path.join(tmp, "seq.wav")
    subprocess.run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", listf,
                    "-ac", "1", "-ar", "44100", "-sample_fmt", "s16", seq],
                   capture_output=True, check=True)
    return seq


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bpm", type=float, default=120.0)
    ap.add_argument("--slots", default=None)
    args = ap.parse_args()
    if not have_ffmpeg():
        print("ffmpeg not found — install ffmpeg to run audio QC.")
        return
    slots = args.slots.split(",") if args.slots else DEFAULT_SLOTS
    beat_s = 60.0 / args.bpm
    print("[audio_qc] %.0f BPM (beat=%.3fs), slots: %s" % (args.bpm, beat_s, ", ".join(slots)))
    with tempfile.TemporaryDirectory() as tmp:
        seq = place_on_grid(slots, beat_s, tmp)
        if seq is None:
            print("No ingested slots found. Run ingest_sfx.py first.")
            return
        click = os.path.join(tmp, "click.wav")
        # count beats from seq duration
        import json
        d = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                            "-of", "json", seq], capture_output=True, text=True, check=True)
        dur = float(json.loads(d.stdout)["format"]["duration"])
        make_click(click, int(dur / beat_s) + 1, beat_s)
        out = os.path.join(SFX, "kfood_sfx_qc.wav")
        # mix click + sequence
        subprocess.run(["ffmpeg", "-y", "-i", seq, "-i", click,
                        "-filter_complex", "[0:a][1:a]amix=inputs=2:duration=longest:dropout_transition=0",
                        "-ac", "1", "-ar", "44100", "-sample_fmt", "s16", out],
                       capture_output=True, check=True)
        print("\nWrote %s — play it to check attacks land on the click." % out)


if __name__ == "__main__":
    main()
