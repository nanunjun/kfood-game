# Sound Guide — K-Food Master (sound sprint #1, code-synth)

> 버전: **v0.1** · 작성일: 2026-06-01 · 작성자: art-director (Phase 2 sound 겸직, ADR-005)
> 범위: 핵심 SFX 12종. BGM·보이스·정식 foley는 후속 sprint.
> **2026-06-01 LOCK (사용자 승인)**: 10슬롯 = 외부 CC0(Kenney 7 + freesound 3), sting 2 = 합성 가야금 유지. 출처·라이선스 = `godot-project/audio/sfx/SOURCES.md` §4. 합성본은 `synth_v2_archive/` 보관.
> 생성 도구: [`tools/gen_sfx.py`](../tools/gen_sfx.py) (numpy 파형 합성, 결정적) · 재생: `scripts/autoload/audio_manager.gd` + `scripts/audio/sfx_registry.gd`(자동 생성)

## 0. 박자 정렬 + BPM·SFX 매트릭스 (v0.2 추가, 리듬 정합)
> 외부 CC0 음원이 게임 리듬과 안 맞으면 손맛이 죽음 → 인제스트에 **transient 0ms 정렬 + 메트로놈 QC**(상세 `audio-pipeline-v1.md`). 노트/SFX/음악 BPM **3중 동기화**.
### 음식·레벨 BPM × SFX 적합성
| SFX 군 | 적합 BPM | 비고 |
|---|---|---|
| 칼질(chop) | 100~160 | 짧은 attack, 빠른 템포 OK |
| 볶기(stir/sizzle) | 90~140 | 중속 |
| 끓이기(boil 보글) | 80~110 | 느린 템포 전용(빠르면 뭉개짐) |
| 튀기기(fry) | 100~140 | 가변 리듬 |
| 양념 탭/홀드 | 전 구간 | 짧고 명료한 click형(게이지 +1 피드백, `scoring §1.5`) |
| 완성 스팅 | 무관 | 비트 밖 |
> 레벨 BPM 곡선 L1~80 → L12~160(`rhythm-variation-v1`). SFX attack 오차 합격 ≤ ±20ms(빠른 음식 ≤ ±12ms). QC = `tools/audio_qc.py`(신규 명세).

## 0.5 손맛 SFX layering (Phase 1 최우선 폴리시)
> `phase1/production-priorities.md §1` — "손맛"의 절반은 오디오. CC0 인제스트 후 **추가 layering 패스 필수**.
- **판정별 레이어**: Perfect = 본 SFX + 짧고 단단한 고역 "팅" + 미세 리버브 / Good = 본 SFX만 / Miss = 둔탁한 저역 "툭" + 짧은 노이즈.
- **액션별 정성 레이어**: 칼질=목제 "톡"(transient) + 도마 울림 / 양념=가루 "사르륵" + 게이지 "딸깍" / 끓음=보글 + 옹기 저역 / 플레이팅=그릇 "짤랑" + 안착 "차르륵".
- **완성 sting 3등급**: 보통 / 잘함(+화음) / 명품(+놋종 글로우 reverb). 점수 등급 변주.
- **양념별 차등**: 고춧가루·간장·소금·설탕 각기 다른 질감 SFX(색 게이지와 1:1).
- 모바일 햅틱과 동기: Perfect 진동(짧고 단단)·Miss 진동(길고 부드러움)과 SFX 동시 트리거.

## 1. 톤 north star

`art-style-guide v1.2`(Royal Match clean + Subway Surfers chibi + 재래시장 K-touch) + `GDD`(캐주얼·가족 친화·글로벌 K-food) + 사용자 "더 따뜻게/전통적으로"(2026-06-01)에서 도출:

> **"따뜻한 한식 주방·시장의 양식화된 추상 톤 — 나무 박(도마) 톡, 놋종·옹기의 둥근 울림, 보글거리는 국물, 국악 평조 5음계. 저-중역 중심, soft transient, 깨끗하되 차갑지 않게."**

**회피:** 차가운 전자음 / SF / 8-bit 아케이드 / EDM / 공격적 transient / 과채도 팝.
**한계 인정:** 완전 foley는 무리 → "양식화된 추상 톤이되 컨셉 결을 따른다".

## 2. 합성 공통 원칙
raised-cosine soft attack(공격 transient 제거) · 저-중역 120~1800Hz 에너지 집중 + lowpass 고역 roll-off · 약한 tanh 새추레이션(따뜻한 배음) · 놋종/woodblock = inharmonic warm partials · sting = 평조 5음계(G·A·C·D·E). 16-bit PCM 44.1kHz mono.

## 3. 사운드별 의도 ↔ 실측 (검증)

centroid(스펙트럴 중심주파수)가 낮을수록 따뜻함. 목표 = 대부분 1~2kHz 이하.

| SFX | 의도 | 길이 | peak | centroid(실측) | 톤 판정 |
|-----|------|------|------|----------------|---------|
| `metro_strong` | 나무 박 강박, 낮고 단단 | 0.09s | 0.80 | 2000Hz | ✅ 나무 톡 |
| `metro_weak` | 나무 박 약박, 높고 가볍게 | 0.07s | 0.55 | 1744Hz | ✅ |
| `judge_perfect` | 놋종 딩↑, 밝고 따뜻·보상 | 0.45s | 0.82 | 1687Hz | ✅ warm bell |
| `judge_good` | 부드러운 단음, 절제된 긍정 | 0.20s | 0.62 | 1277Hz | ✅ |
| `judge_miss` | 둔탁한 낮은 툭, 부드러운 실망 | 0.18s | 0.55 | 1483Hz | ✅ 가혹하지 않음 |
| `act_chop` | 칼이 도마에 탁 | 0.08s | 0.80 | 3703Hz | ◐ transient 특성상 다소 높음(허용) |
| `act_stir` | 휘젓기/볶기 쓱 | 0.32s | 0.45 | 1032Hz | ✅ 저역 swish |
| `act_boil` | 국물 보글(방울 4개) | 0.50s | 0.55 | 314Hz | ✅ 매우 따뜻 |
| `act_done` | 완성 종 딩—, 긴 여운 | 0.65s | 0.72 | 1276Hz | ✅ 만족감 |
| `ui_select` | 가벼운 나무 톡(메뉴) | 0.10s | 0.52 | 1131Hz | ✅ 비전자음 |
| `sting_start` | 평조 상행 3음(G→C→E) | 0.50s | 0.70 | 1117Hz | ✅ 경쾌·전통 |
| `sting_finish` | 평조 마무리 화음, resolved | 0.58s | 0.72 | 1145Hz | ✅ 따뜻 |

> `act_chop`만 노이즈 transient 때문에 centroid가 높으나, "칼-도마 탁"의 자연 특성이며 lowpass 3.3kHz로 이미 완화. 후속 조정 여지.

## 4. 트리거 매핑 (라운드 루프 배선)

| 트리거 시점 | SFX | 위치 |
|-------------|-----|------|
| 라운드 시작 | `sting_start` | round_controller `_start_round` |
| Stage 2A 매 비트 (4박 1마디, 1박=강) | `metro_strong`/`metro_weak` | stage_prep `_process` |
| Stage 2A 탭 (칼질) | `act_chop` + 판정음 | stage_prep `_judge_tap` |
| Stage 2A/2C 판정 | `judge_perfect`/`judge_good`/`judge_miss` | stage_prep / stage_timing |
| Stage 2B 조리법 선택 | `judge_perfect`(정답)/`judge_miss`(오답) | stage_method `_on_pick` |
| Stage 2C 진입 (조리 ambient) | `act_boil`(끓이기)/`act_stir`(그 외) | round_controller |
| 조리 완료 | `act_done` | round_controller (timing 종료 후) |
| 결과 화면 | `sting_finish` | round_controller `_show_result` |
| 메뉴/버튼 선택 | `ui_select` | food_select / result_screen |

## 5. 후속 (sound sprint #2+)
- BGM (시장/키친 warm loop), 음식별 완성 보이스("맛있겠다!"), 별점 1/2/3 차등 jingle.
- `act_chop` transient 추가 완화 검토 + DIP/MAR(콘도그·불고기) 전용 prep 사운드.
- 믹스 밸런스 (volume_db per-SFX), 옵션 메뉴 음소거 토글(AudioManager.muted 연결).

## 6. 변경 이력
- **2026-06-01 v0.1** — 코드 합성 12종 신설(메트로놈2/판정3/액션4/UI3). 톤 = 따뜻·전통(놋종/나무박/평조). gen_sfx.py + AudioManager + 라운드 루프 배선.
- **2026-06-01 v0.2 LOCK** — 합성 톤 "전자음" 피드백 → 외부 CC0 전면 교체. 10슬롯 = Kenney Interface Sounds(CC0) 7 + freesound CC0 3(spanrucker/BenjaminNelan/monsterthing). sting 2 = 합성 가야금 유지(CC0 koto 미확보). ingest_sfx.py(드롭박스 모드)+make_sfx_preview.py 파이프라인. 사용자 승인 완료. 배선·레지스트리·AudioManager 무변경(파일만 교체).
