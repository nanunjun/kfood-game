# Phase Art v1 — 페이즈 전용 시각 (M1+)

> 신규 4페이즈가 도형 placeholder → 페이즈별 아트로 손맛 시각 보강. 프롬프트 = `image_prompts_phase1.md §H`. 인제스트 매핑·placeholder 폴리시.

## 1. 필요 아트 슬롯
| 슬롯 | 파일명(`art/phases/`) | 용도 | 현재 placeholder |
|---|---|---|---|
| Stir-fry | `phase_stirfry.png` | 볶기 배경(팬+주걱+재료) | 웍(타원)+재료 조각+중앙선 |
| Pan-fry | `phase_panfry.png` | 부치기(전+기름 튀김) | 팬+전(raw→golden 색변화) |
| Roll | `phase_roll.png` | 말기(김+밥 매트) | 김 매트+진행바 |
| Mix | `phase_mix.png` | 비비기(큰 그릇+주걱) | 그릇+5색 재료 회전 |
| 양념 아이콘 5 | `phase_seasoning_icons.png` | 양념 버튼 아이콘 | 색상 버튼(텍스트) |
> 양념 아이콘은 시트 1장 → 잘라 5개 슬롯에 매핑(고추장·고춧가루·간장·설탕·참기름). 색은 `seasoning_gauge.COLORS`와 일치.

## 2. placeholder 폴리시 (현재 — premium 톤 근접)
- 도형이지만 색·형태를 premium 팔레트(terracotta/cream/warm)에 맞춤. 손맛(FeedbackBus 5중 자극)·SFX는 **풀 적용**(프로덕션 우선순위 위반 X) — 아트만 도형.
- Stir-fry: 진한 웍 + 주황 재료 4조각 + 중앙 판정선. Pan-fry: 전 색이 raw→golden lerp(진행바 대용 시각). Roll: 김 매트 + 갈색 진행바 + 목표존. Mix: 그릇 + 5색 재료가 탭마다 회전·펄스.

## 3. 인제스트 매핑 (auto-swap)
1. `§H` 프롬프트로 생성(흰 배경) → `assets-raw/premium_v2_ui/`.
2. `py tools/cutout_bg.py`(흰 자동) → 투명 PNG.
3. `godot-project/art/phases/phase_*.png`로 복사 → Godot 임포트.
4. (후속 코드) `rhythm_proto`의 각 `_start_*`에서 도형 대신 `art/phases/phase_*.png` 로드해 표시(파일 존재 시). 현재는 도형; 스왑 시 `_make_wok`/`_start_panfry`/`_start_hold(roll)`/`_start_knead`에 `ResourceLoader.exists` 분기 추가.
> 음식 완성샷과 동일한 "있으면 실제, 없으면 placeholder" 패턴으로 코드 안 깨짐.

## 4. transition (페이즈 간)
- 현재: `_clear_stage()` 즉시 전환 + 다음 페이즈 빌드. 짧은 fade·zoom transition은 후속(공통 `_phase_transition()` 추가해 0.2s 크로스페이드).
- Phase 1은 즉시 전환으로도 충분(스텝 라벨 "Step k/n"으로 맥락 제공).

## 5. 검증
- 도형 placeholder로 4페이즈 플레이 완결(현재 PASS).
- 아트 드롭 시 경로/파일명만 맞으면 스왑(코드 분기 추가 후).
- preflight PASS.

## A/B
- **[A/B] 양념 아이콘**: A=시트 1장 분할(디폴트) / B=개별 PNG 5장. 디폴트 A.
- **[A/B] 페이즈 transition**: A=즉시(디폴트) / B=0.2s 크로스페이드. 디폴트 A(후속 B).
