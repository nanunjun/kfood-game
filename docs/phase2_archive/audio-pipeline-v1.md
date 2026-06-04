# Audio Pipeline v1 — 정밀 박자 보정 인제스트

> CC0 외부 음원의 BPM·타이밍이 게임 리듬과 안 맞으면 "손맛"이 죽음. 인제스트에 **transient 정렬 + BPM 적합성 + 메트로놈 QC**를 추가.
> 연동: `tools/ingest_sfx.py`(기존 트림/정규화/변환), `rhythm-variation-v1`(BPM 곡선·노트), `sound-guide.md`(매트릭스). 본 단계는 설계 명세(구현은 후속).

## 1. 인제스트 파이프라인 (확장)
```
CC0 다운 → ① BPM/onset 분석 → ② transient attack 0ms 정렬 → ③ tail 트림(attack 보호)
         → ④ 정규화/포맷 변환(기존) → ⑤ 메트로놈 QC → 합격 시 슬롯 배치 / 실패 시 리포트
```
| 단계 | 내용 | 도구 |
|---|---|---|
| ① 분석 | onset/BPM 자동 감지 | librosa onset_detect / beat_track |
| ② attack 정렬 | transient attack 위치 = 탭 노트 트리거 0ms에 일치하도록 앞단 silence 트림/패딩 | numpy/soundfile |
| ③ tail 트림 | attack 보호하며 꼬리만 정리(길이 일관) | 기존 ingest 확장 |
| ④ 정규화·변환 | -LUFS 정규화, ogg/wav (기존) | ffmpeg |
| ⑤ QC | click track 오버레이로 박자 일치 시각/청각 확인 | **tools/audio_qc.py (신규)** |

## 2. 레퍼런스 BPM × SFX 적합성 매트릭스
음식·레벨 BPM 80~160 그리드에 SFX 적합성 라벨. (상세 표 `sound-guide.md`.)
| SFX 군 | 적합 BPM | 비고 |
|---|---|---|
| 칼질(chop) | 100~160 | 빠른 템포 OK, 짧은 attack |
| 볶기(stir/sizzle) | 90~140 | 중속 |
| 끓이기(boil 보글) | 80~110만 | 느린 템포 전용(빠르면 뭉개짐) |
| 튀기기(fry) | 100~140 | 가변 리듬 |
| 양념 탭/홀드 | 전 구간 | 짧고 명료한 click형 |
| 완성 스팅 | 무관 | 비트 밖 |
> 노트 타이밍·SFX·음악 BPM **3중 동기화**: 음악 BPM 확정 → SFX attack·노트 타이밍 모두 그 BPM에 정렬.

## 3. tools/audio_qc.py (신규, 명세)
- 입력: SFX 파일(들) + 목표 BPM.
- 처리: 목표 BPM click track 생성 → SFX와 믹스/오버레이 → 미리듣기 wav + onset vs beat 오차(ms) 리포트.
- 출력: `audio_qc_report.md`(슬롯별 오차·합격/불합격), 미리듣기 wav. 불합격 슬롯 = 재정렬 또는 교체 대상.
- 합격 기준(디폴트): attack 오차 ≤ ±20ms(빠른 음식 ≤ ±12ms).

## 4. CC0 다운 후 워크플로
1. 다운 → `assets-raw/audio_intake/`.
2. `tools/ingest_sfx.py --align`(① ② ③ ④) → 정렬·정규화.
3. `tools/audio_qc.py --bpm <목표>` → 메트로놈 QC 리포트.
4. 합격 → 슬롯 배치(`sfx_registry`), 불합격 → 어떤 슬롯이 왜 안 맞는지 리포트 후 재처리/교체.
> 현 단계 문서·도구 명세만(코드 변경 0). 구현은 후속 sprint(librosa 의존성 추가 검토).

## 5. A/B
- **[A/B] attack 정렬 허용 오차**: A=±20ms(±12ms 빠른 음식, 디폴트) / B=±10ms 일괄(엄격, 음원 탈락↑). 디폴트 A.
- **[A/B] 음악 유무**: A=레벨 BGM + SFX(디폴트) / B=SFX 중심(BGM 최소). 디폴트 A.
