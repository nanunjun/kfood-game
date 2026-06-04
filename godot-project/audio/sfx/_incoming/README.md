# SFX Ingest — drop files here (`_incoming/`)

Save each CC0 audio file named **exactly as its slot key** (any extension):
`act_stir.wav`, `judge_perfect.mp3`, `sting_goldspoon.ogg`, …

Then run:
```
py tools/ingest_sfx.py
```
Each file is trimmed (≤0.8s), normalized (−14 LUFS), faded, converted to 16-bit / 44.1 kHz / mono,
and written to `godot-project/audio/sfx/<slot>.wav` (registry path unchanged → no code edits).
Slots with no incoming file stay on the synthesized fallback in `synth_v2_archive/`.

QC the rhythm feel after ingest:
```
py tools/audio_qc.py --bpm 120     # builds kfood_sfx_qc.wav (slot hits on a click grid)
```

## Slot keys
| Group | Slots |
|---|---|
| Metronome | `metro_strong` · `metro_weak` |
| Judgment | `judge_perfect` · `judge_good` · `judge_miss` |
| Phase actions | `act_chop` · `act_boil` · `act_done` · `act_stir` (stir-fry) · `act_panfry` · `act_roll` · `act_mix` |
| Seasoning taps | `season_gochujang` · `season_gochugaru` · `season_ganjang` · `season_seoltang` · `season_chamgireum` |
| UI | `ui_select` · `ui_menu` · `sting_start` · `sting_finish` |
| Evaluator stings | `sting_mystery` (quiet mysterious) · `sting_daniel` (camera shutter / upbeat) · `sting_goldspoon` (regal, tense) |

> Phase action SFX should be **short, percussive, attack-on-1** so they sit on the beat (see audio_qc).
> Seasoning taps: light "tick/sprinkle" variations. Stings: 0.6–0.8s, no hard tail.
> Licensing: **CC0 only** (no CC-BY, no paid). Log each source in `../SOURCES.md`.
