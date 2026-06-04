# Audio Ingest v2 — SFX pipeline (sound sprint #2)

> 합성 SFX → CC0 외부 음원 인제스트 흐름 가동. 신규 페이즈·양념·evaluator 슬롯 추가 + QC 도구.
> **다운로드는 사용자(집에서)**, 큐레이션·파이프라인·검증은 여기. 라이선스 **CC0만**. 연동: `SOURCES.md`, `phase-variations-v1`, `levels-v1`.

## 1. 파이프라인 (`tools/ingest_sfx.py`)
이미 풀 파이프라인: 트림(≤0.8s) → **loudnorm −14 LUFS** TP −1.5 → fade in/out → **16-bit PCM / 44.1 kHz / mono** → `audio/sfx/<slot>.wav`(레지스트리 경로 동일 = 코드 변경 0).
- `_incoming/<slotkey>.<ext>`에 넣고 `py tools/ingest_sfx.py` (또는 `--dropbox` + `mapping.txt`).
- 없는 슬롯은 자동 보류 → `synth_v2_archive/` 합성본 fallback(코드 안 깨짐).

## 2. 슬롯 맵 (전 24종)
| 그룹 | 슬롯 |
|---|---|
| 메트로놈 | metro_strong, metro_weak |
| 판정 | judge_perfect, judge_good, judge_miss |
| 페이즈 액션 | act_chop, act_boil, act_done, **act_stir, act_panfry, act_roll, act_mix** |
| 양념 탭 | **season_gochujang, season_gochugaru, season_ganjang, season_seoltang, season_chamgireum** |
| UI | ui_select, **ui_menu**, sting_start, sting_finish |
| evaluator 스팅 | **sting_mystery, sting_daniel, sting_goldspoon** |
> 굵은 = 이번 추가. 양념=짧은 tick/sprinkle(0.1~0.3s), 액션=attack-on-1, 스팅=0.6~0.8s.

## 3. QC 도구 (`tools/audio_qc.py`)
인제스트된 액션/판정 SFX를 **메트로놈 클릭 그리드 위에** 배치한 미리듣기를 합성 → 어택이 비트에 붙는지 청취 검증.
```
py tools/audio_qc.py --bpm 120
py tools/audio_qc.py --bpm 132 --slots act_chop,act_stir,judge_perfect
```
출력: `audio/sfx/kfood_sfx_qc.wav` (click track + 슬롯 히트). deps: ffmpeg.
> 일반 미리듣기는 기존 `make_sfx_preview.py`(`kfood_sfx_preview*.wav`).

## 4. 사용자 워크플로 (집 도착 후 1쪽)
1. `SOURCES.md §3 A~D` 링크에서 **CC0** 음원 다운(Kenney 무가입 / freesound는 License="Creative Commons 0" 필터·재확인).
2. 슬롯 key 이름으로 `godot-project/audio/sfx/_incoming/`에 저장(예 `act_panfry.wav`). 헷갈리면 `_dropbox/`에 원본 다 던지고 "정리해줘".
3. `py tools/ingest_sfx.py` → `py tools/audio_qc.py --bpm 120`으로 박자 QC.
4. Godot 재생성/재임포트 후 인게임 확인. `SOURCES.md §4` 매니페스트에 출처 기록.
> 상세 슬롯 표·성격·검색어 = `_incoming/README.md` + `SOURCES.md §3D`.

## 5. 코드 배선 메모 (후속)
현재 라운드는 `FeedbackBus.hit`로 judge_*/ui_select만 재생. 신규 act_*/season_*/sting_* 슬롯은 ingest 후 `feedback_bus.gd`/페이즈별 호출 추가로 배선(전용 키 존재 확인 후). 미배선이어도 ingest·QC는 독립 가동.

## 6. 검증 체크
- [ ] 인제스트 wav = 16-bit/44.1k/mono ≤0.8s.
- [ ] audio_qc로 액션 SFX 어택이 클릭에 정렬.
- [ ] CC0 출처 매니페스트 기록.
- [ ] 미배선 슬롯이라도 게임 정상(보류 fallback).
