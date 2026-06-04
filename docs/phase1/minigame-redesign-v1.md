# Minigame Redesign v1 — "the food IS the gauge"

> 플레이테스트 피드백(크리에이티브 디렉션): 화면이 "튜토리얼 설명서" 같고 음식이 안 보임. 원칙 전환 — **추상 막대 제거, 음식 자체가 미니게임/게이지**. Royal Match가 보석을 항상 보여주듯, 한식 게임은 음식이 항상 보여야 함. 연동: `phase-variations-v1`, `rhythm-prototype-spec`.

## 1. 핵심 원칙
- **음식이 항상 보인다**: 모든 조리 페이즈 상단에 "Cooking · {메뉴}(한글)" 배너 + 썸네일 상시 표시(`_build_now_cooking`). 플레이어는 늘 뭘 만드는지 안다.
- **음식이 곧 게이지**: 진행도를 막대가 아니라 음식의 상태로 표현(끓는 정도·구워지는 색·말리는 정도·섞이는 정도).
- **Perfect는 크게**: "PERFECT!" 큰 텍스트 + 스파클 버스트 + 김(`_perfect_burst`).

## 2. Boil 재설계 (구현 완료, 표준 예시)
막대 → **끓는 냄비**. 누르고 있으면:
- 냄비 안 **국물 색이 차오르며 깊어짐**(연한 주황→진한 빨강),
- **거품이 점점 빠르게** 올라오고(heat↑일수록 잦음),
- 둘레 **골든 히트 링**이 차오르고 **적정 구간(0.8~1.05)**에서 금색으로 굵어짐 + 김 모락모락,
- 적정에서 떼면 **PERFECT! + 스파클 + 김**, 빗나가면 설익음/넘침.
> 프롬프트(아트 교체용): "Korean ramen boiling pot top-down, broth bubbles + steam as the hold meter fills, golden perfect heat ring, glossy noodles on perfect release, warm kitchen, Cooking Mama/Madness polish, food is the focus, not abstract bars." (`image_prompts_phase1` 인입 예정)

## 3. 메뉴별 미니게임 매핑 (음식 동작 = 조작) — 방향
| 메뉴 | 조리 동작 | 현재 구현 |
|---|---|---|
| 라면 | 냄비 끓이기(hold) | ✅ boil 재설계 |
| 김밥 | 말기(roll hold) | 기본 hold(말기 비주얼 후속) |
| 떡볶이 | 소스 졸이기/볶기(stir) | stir 패드(졸임 비주얼 후속) |
| 비빔밥 | 비비기(mix 연타) | mix 패드 |
| 해물파전 | 뒤집기(panfry FLIP) | ✅ FLIP 패드 + perfect 버스트 |
| 불고기 | 뒤집기/볶기(stir) | stir |
| 찌개류 | 간 맞추기(season) + 끓이기(boil) | boil+season |
> Boil이 "음식=게이지" 표준. 나머지 페이즈도 같은 원칙으로 비주얼을 음식 상태로 점진 교체(roll=말리는 김밥, stir=졸아드는 소스, mix=섞이는 색).

## 4. 빈 공간 축소
상단 40% = 음식(배너+조리 비주얼), 중앙 = 조작(냄비/패드/게이지), 항상 움직임(거품·김·스파클). 빈 크림 여백 제거 방향.

## 5. 남은 작업 (다음 청크 후보)
- roll/stir/mix/season도 boil처럼 "음식 상태가 게이지"로 비주얼 교체(말기/졸임/섞임 애니메이션).
- 손님 초상 + 음식 동시 노출(상단 손님 칩).
- 페이즈 전용 음식 PNG(§H art) 인입 시 도형→실물 스왑.
- Perfect 전용 SFX(`sting`/sizzle) 배선.
