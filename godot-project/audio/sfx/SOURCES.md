# SFX Sources & License Manifest — K-Food Master

> sound sprint #1 (외부 CC0 소스). 합성본(synth v2)은 `synth_v2_archive/`에 보관, 슬롯 채워지면 교체.
> **라이선스 정책: CC0만.** CC-BY/기타 제외. 유료(ElevenLabs 등) 미사용.

## 0. ⚠️ 다운로드는 사용자 단계
Claude(이 환경)는 외부 바이너리 오디오를 작업공간으로 **직접 내려받을 수 없음**(웹 도구는 페이지 텍스트만, curl/wget 정책 금지). 따라서 큐레이션·파이프라인은 Claude가, **다운로드는 JS님**이 수행.

## 1. 소스 우선순위 (CC0 신뢰도순)
1. **Kenney** — https://kenney.nl/assets/category:Audio — **전부 명시적 CC0**, 무가입 zip 다운로드. UI/판정/클릭/차임에 최적.
2. **freesound.org (CC0 필터)** — 검색 후 좌측 License = **"Creative Commons 0"** 필터 필수. 가입 후 다운로드. 주방 foley(칼질/끓음/지글)에 최적.
3. **OpenGameArt.org (CC0 필터)** — License = CC0.
4. **Pixabay** — ⚠️ "Pixabay Content License"(무귀속·상업 OK)로 **엄밀히는 CC0 라벨 아님**. 정책상 가급적 회피, 불가피 시 페이지 라이선스 확인 후 사용.

## 2. 워크플로 (JS님 — 폴더 하나에 던지기)
1. 아래 §3 링크에서 CC0 후보 다운로드.
2. **이름 안 바꾸고 원본 그대로** 한 폴더에 다 넣기: `godot-project/audio/sfx/_dropbox/`
   (Kenney zip은 압축 풀어 쓸 OGG만, freesound는 받은 wav/ogg 그대로. 헷갈리면 후보 여러 개 넣어도 OK.)
3. Claude에게 **"사운드 다 넣었어, 정리해줘"** → Claude가:
   - `_dropbox/` 파일명 확인 → 슬롯 매핑(`_dropbox/mapping.txt`) 작성
   - `py tools/ingest_sfx.py --dropbox` (≤0.8s 트림·-14 LUFS·페이드·16-bit/44.1k mono → 슬롯 wav)
   - `py tools/make_sfx_preview.py` (미리듣기 재생성) → 검증 + §4 매니페스트 기록까지 대행.
> 대안(직접 매핑): 파일을 슬롯 key 이름으로 `_incoming/`에 넣고 `py tools/ingest_sfx.py` 실행해도 됨.

## 3. 확정 다운로드 체크리스트 (2026-06-01 검증)

받을 것은 **딱 2덩어리**: ① Kenney 팩 1개(7슬롯 커버) + ② freesound 3파일. sting 2슬롯은 합성본 유지 권장.

### A. Kenney "Interface Sounds" — **CC0 확인됨**, zip 1개로 7슬롯 커버 (최우선)
- 다운로드: https://kenney.nl/assets/interface-sounds (페이지에 `License: Creative Commons CC0` 명시 확인). zip(OGG 100개) 받아 압축 해제 → 아래 성격의 파일을 골라 **슬롯 key 이름**으로 `_incoming/`에 복사. (정확 파일명은 미리듣기로 선택 — ingest가 무엇이든 슬롯 key로 변환.)

  | 슬롯 | Kenney에서 고를 성격 |
  |------|---------------------|
  | `judge_perfect` | `confirmation_*.ogg` (밝은 상승 확인음) |
  | `judge_good` | 부드러운 `click_*.ogg` / 약한 confirmation |
  | `judge_miss` | `error_*.ogg` (부드러운 것) |
  | `ui_select` | `select_*.ogg` / `click_*.ogg` |
  | `metro_strong` | `switch_*.ogg`/tick 계열 (단단한 것) |
  | `metro_weak` | 같은 계열 더 가볍고 짧은 것 |
  | `act_done` | 길고 종 같은 `confirmation_*`/`glass_*.ogg` |

### B. freesound CC0 — 주방 foley 3슬롯 (License = "Creative Commons 0" 페이지 재확인 후 받기)
  | 슬롯 | 후보 (CC0 문구 확인됨) |
  |------|----------------------|
  | `act_chop` | https://freesound.org/people/spanrucker/sounds/272220/ (cutting peppers, CC0) |
  | `act_boil` | https://freesound.org/people/monsterthing/sounds/456382/ (boiling pot, CC0) · 대안 Euphrosyyn/370217 |
  | `act_stir` | https://freesound.org/people/BenjaminNelan/sounds/353124/ (frying pan sizzle, CC0) · 대안 FartMuffin/575514 |
  > freesound 무료 가입 후 다운로드. 길이 길어도 OK — ingest가 0.8s로 트림.

### C. sting (가야금) 2슬롯 — CC0 희소 → **합성본 유지 권장(보류)**
  - `sting_start`/`sting_finish`는 현재 합성 가야금(Karplus-Strong)이 전자음 느낌이 가장 적은 슬롯. 깔끔한 CC0 koto 단음을 못 찾으면 그대로 둠(인제스트가 자동 보류).
  - 굳이 교체 시 후보(라이선스 확인 필수): freesound `koto`/`guzheng` License=CC0 필터 · Pixabay koto ⚠️(Pixabay License로 **엄밀 CC0 아님**).

> **요약**: Kenney zip 1개 + freesound 3파일 = 필수. sting 2개는 선택(없으면 합성 유지). 받은 파일을 `_incoming/<슬롯key>.<확장자>`로 저장 후 "인제스트 돌려줘".

### D. 신규 슬롯 (페이즈 변주 + 양념 + evaluator) — sound sprint #2
> phase-variations-v1 / levels-v1 대응. 전부 CC0. 받아서 `_incoming/<슬롯key>.<ext>` 저장 → `py tools/ingest_sfx.py`.

| 슬롯 | 성격 | CC0 검색 가이드 |
|------|------|----------------|
| `act_panfry` | "지글지글" 부침 + 뒤집기 | freesound CC0 "sizzle" / "frying" (act_stir와 변주 다르게) |
| `act_roll` | 부드러운 "쓰윽~" 말기 | freesound CC0 "fabric slide" / "bamboo mat" / soft swipe |
| `act_mix` | "휘이익~" 비비기/휘젓기 | freesound CC0 "stir bowl" / "whisk" / "mixing" |
| `season_gochugaru` | 가루 뿌림 "솨아" | freesound CC0 "sprinkle" / "powder pour" |
| `season_gochujang` | 끈적한 한 스쿱 | freesound CC0 "scoop paste" / "squelch soft" |
| `season_ganjang` | 액체 따름 작은 "쪼르륵" | freesound CC0 "liquid pour small" |
| `season_seoltang` | 설탕 알갱이 "사르륵" | freesound CC0 "sugar pour" / granular |
| `season_chamgireum` | 기름 한 방울 "톡" | freesound CC0 "drop oil" / soft tick |
| `ui_menu` | 메뉴 그리드 진입 차임 | Kenney Interface `select_*`/`maximize_*` |
| `sting_mystery` | 조용·미스터리 (Mystery Diner) | Kenney/freesound CC0 low "suspense" tiny / muted koto |
| `sting_daniel` | 카메라 셔터 + 밝은 챠임 (Blogger) | freesound CC0 "camera shutter" + Kenney chime mix |
| `sting_goldspoon` | 위엄·긴장 (Golden Spoon) | freesound CC0 "regal" / "gong soft" / orchestral hit short |

> 양념 SFX는 가볍고 짧게(0.1~0.3s), 페이즈 액션은 attack-on-1. evaluator 스팅은 0.6~0.8s. 없는 슬롯은 ingest가 자동 보류(합성/무음 fallback) — 코드 안 깨짐.

## 4. 다운로드 매니페스트 (받을 때마다 기록)

| 슬롯 key | 파일명(원본) | URL | 작성자 | 라이선스 | 확인일 |
|----------|-------------|-----|--------|---------|--------|
| metro_strong | tick_001.ogg | https://kenney.nl/assets/interface-sounds | Kenney | CC0 | 2026-06-01 |
| metro_weak | tick_002.ogg | https://kenney.nl/assets/interface-sounds | Kenney | CC0 | 2026-06-01 |
| judge_perfect | confirmation_001.ogg | https://kenney.nl/assets/interface-sounds | Kenney | CC0 | 2026-06-01 |
| judge_good | confirmation_002.ogg | https://kenney.nl/assets/interface-sounds | Kenney | CC0 | 2026-06-01 |
| judge_miss | error_004.ogg | https://kenney.nl/assets/interface-sounds | Kenney | CC0 | 2026-06-01 |
| act_chop | 272220__spanrucker__cutting-peppers-chopping-board-knife.aiff | https://freesound.org/people/spanrucker/sounds/272220/ | spanrucker | CC0 | 2026-06-01 |
| act_stir | 353124__benjaminnelan__frying-pan-sizzle.wav | https://freesound.org/people/BenjaminNelan/sounds/353124/ | BenjaminNelan | CC0 | 2026-06-01 |
| act_boil | 456382__monsterthing__boiling-pot-of-water.mp3 | https://freesound.org/people/monsterthing/sounds/456382/ | monsterthing | CC0 | 2026-06-01 |
| act_done | bong_001.ogg | https://kenney.nl/assets/interface-sounds | Kenney | CC0 | 2026-06-01 |
| ui_select | select_001.ogg | https://kenney.nl/assets/interface-sounds | Kenney | CC0 | 2026-06-01 |
| sting_start | (합성 유지 — synth_v2_archive) | — | (code-synth) | CC0(자체) | 보류 |
| sting_finish | (합성 유지 — synth_v2_archive) | — | (code-synth) | CC0(자체) | 보류 |

> ⚠️ freesound 다운로드 시 각 페이지 License = "Creative Commons 0" 직접 재확인 필요(메타 캡처 권장). spanrucker 272220 / BenjaminNelan 353124 / monsterthing 456382 = 검색 단계에서 CC0 문구 확인됨.

## 5. 검증 체크리스트
- [ ] 각 음원 페이지 License = **CC0 / Creative Commons 0 / Public Domain** 확인 (캡처 권장).
- [ ] Pixabay 사용 시 "Pixabay License"임을 인지 (엄밀 CC0 아님 — 정책 재확인).
- [ ] 인제스트 후 슬롯 wav = 16-bit PCM 44.1kHz mono, ≤0.8s.
- [ ] §4 매니페스트 전 항목 기록.

## 6. 변경 이력
- **2026-06-01 v0.1** — 외부 CC0 전환 시작. 합성본 synth_v2_archive 보관. ingest_sfx.py + make_sfx_preview.py 파이프라인. 슬롯 후보 큐레이션.
