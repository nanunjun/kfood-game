# Asset Ingest Guide — home workflow (집 도착 후 사용자용)

> 집에서 이미지 생성기로 만든 PNG를 게임에 넣는 1쪽 가이드. 완성샷 3종 + (선택) 캐릭터·페이즈 아트. 프롬프트는 `image_prompts_phase1.md`.

## 0. 완성샷 3종 (최우선 — 현재 placeholder)
| 메뉴 | 프롬프트 | 저장 파일명 |
|---|---|---|
| Kimchi Stew | `image_prompts_phase1.md §D 김치찌개` | `m_kimchi_jjigae.png` |
| Doenjang Stew | `§D 된장찌개` | `m_doenjang_jjigae.png` |
| Spicy Fish Stew | `§D 매운탕` | `m_maeuntang.png` |
> 프롬프트는 premium v2 톤 + glow/sheen(컷아웃 정지컷이라 **김 없이**, 김은 인게임 VFX). 검정 배경으로 생성 → 컷아웃.

## 1. 단계
1. `image_prompts_phase1.md`의 해당 블록을 **그대로 복붙**해 이미지 생성(검정 배경, 1024²).
2. 생성 PNG를 `assets-raw/premium_v2_menus/`에 임시 저장.
3. 컷아웃: `py tools/cutout_bg.py`(검정/흰 자동 인식 → 투명 PNG).
4. 결과를 **정확한 파일명**으로 게임 폴더에 복사:
   `godot-project/art/sprites/food/m_kimchi_jjigae.png` (된장·매운탕 동일 규칙).
5. Godot 한 번 열어 임포트(.import 생성) → **끝**.

## 2. 자동 인식(auto-swap)
- `menu_db.gd`는 `ready`를 **실제 파일 존재(`ResourceLoader.exists`)로 판정**. PNG가 위 경로에 들어오면:
  - 메뉴 그리드 썸네일이 placeholder("Art coming soon") → 실제 이미지로 자동 교체.
  - 라운드 reveal에서 그릇 위에 실제 음식 PNG로 자동 표시.
  - "Final art coming soon" 토스트 자동 사라짐.
- **CSV 수정 불필요.** 파일명·경로만 맞으면 됨.

## 3. 캐릭터/시장/페이즈 아트 (선택, Phase 1 중후반)
| 종류 | 프롬프트 | 인테이크 폴더 | 게임 경로(예정) |
|---|---|---|---|
| 친구5·평가자3·상인2 | `§A/§B/§C` | `assets-raw/premium_v2_npc/` | `art/.../npc/` (guest_select 아바타 스왑) |
| 시장 BG 2 | `§E` | `assets-raw/premium_v2_markets/` | `art/bg/` (컷아웃 X) |
| UI 키트 | `§F` | `assets-raw/premium_v2_ui/` | `art/ui/` |
| 페이즈 아트 4 + 양념 아이콘 | `§H` | `assets-raw/premium_v2_ui/` | `art/phases/` (`phase-art-v1.md`) |
> 캐릭터·메뉴·페이즈 = `cutout_bg.py` 컷아웃. 시장 BG·컷씬·UI 키프레임 = 컷아웃 제외.

## 4. 파일명 규칙 요약 (자동 인식 핵심)
- 음식: `art/sprites/food/{food_id}.png` (food_id = menus.csv의 `menu_id`).
- 페이즈: `art/phases/phase_{stirfry|panfry|roll|mix}.png`, `art/phases/phase_seasoning_icons.png`.
- 잘못된 이름이면 placeholder 유지(깨지지 않음) → 이름만 고치면 다음 실행에 반영.
