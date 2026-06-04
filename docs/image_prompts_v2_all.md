# Image Prompts v2 — 마스터 인덱스 (메타 개편 신규 슬롯 전부)

> v2.0 메타 개편으로 추가되는 **모든 신규 이미지 슬롯**의 완성 프롬프트 모음 인덱스. 집에서 바로 이미지 생성기에 카피페이스트 → 일괄 생성 → `tools/cutout_bg.py` 인제스트 흐름.
> **기존 활성분(음식 12 완성샷·기본 도구 9·기본 재료 24)은 재사용** — 여기 미포함, 아래 §0 참조.
> 설계 출처: `GDD-v2.md`, `characters-v2.md`, `scoring-v2.md`, `economy-balance-v1.md`, `unlock-tree-v1.md`, `data/schema-delta-v2.md`, `art-needs-v2.md`.

## 0. 기존 활성 프롬프트 (참조만, 재생성 불필요)
- 음식 12 완성샷 → `art-prompts-premium-foods.md` (생성·반영 완료)
- 기본 도구 9 / 기본 재료 24 / 가족 리액션 기본 → `art-prompts-premium-assets.md`
- 전체 레거시·활성 카탈로그 → `image_prompts_all.md`

## 1. 신규 프롬프트 파일 (카테고리 분할)
| 파일 | 내용 | 슬롯 수(블록) |
|---|---|---|
| `image_prompts_v2_characters.md` | 캐릭터 15명 × (풀바디 A / 표정3종 시트 B / 다인 페어 C) | 45 |
| `image_prompts_v2_assets.md` | 재료 특산품·명품(13) + 도구 프로9·마스터9(18) + 그릇 빈9·매칭6(15) | 46 |
| `image_prompts_v2_ui.md` | UI 11종 + 배경 7종 | 18 |
| `image_prompts_v2_markets.md` | 시장 BG 10 + 상인 NPC 10 + 가판대/소품/간판 3 + 이벤트 컷씬 2 | 25 |
| `image_prompts_v2_menus.md` | 신규 메뉴 완성샷(확장 29종) | 29 |
| **합계** | | **~163** |
> v2.3: 캐릭터(`image_prompts_v2_characters`)는 **보편 아키타입**으로 재작성 + **플레이어 프리셋 5종**(§C) 포함. 브랜딩 = Golden Spoon(미쉐린 미사용). 기존 음식 12·기본 재료/도구는 재사용.

## 2. 공통 토큰 (전 파일 인라인됨 — 참고용)
- **STYLE(premium v2)**: `premium mobile game asset, polished casual illustration in the style of Royal Match and Cooking Madness, soft volumetric shading, single key light from top-left, subtle rim light, glossy specular highlights, rounded form, warm appetizing palette, hand-painted stylized 2D illustration (NOT a photograph, NOT a photo, NOT a 3D render).`
- **NEG**: `Important: avoid background scene, table, props, steam, flat single-color fill, vector clipart, sticker, MS paint, amateurish, hard uniform black outline, harsh neon, muddy colors, texture noise, photorealistic photo, 3D render, anime, text, watermark.`
- **배경 규칙**: 캐릭터/도구 = 흰 단색 · 재료/밝은그릇 = 검정 단색 · 어두운그릇 = 흰 · 음식담김 = 검정 · UI = 흰/투명 · **BG = 풀 16:9 장면(컷아웃 안 함)**. 김(steam)은 그림 금지(인게임 VFX).
- **시드**: 이전 시드 기록 없음. 캐릭터·세트는 첫 베스트 컷을 reference 업로드로 동일성 고정, seed 값을 각 파일 머리말에 기록·재사용.

## 3. 슬롯 ID ↔ 출처 매핑
| 카테고리 | 슬롯 ID 예 | 파일명(저장) | 출처 설계 |
|---|---|---|---|
| 캐릭터 | C1-A~C15-C | (각 캐릭터별, art_keys로 매핑) | characters-v2 §2 |
| 재료 특산품·명품 | ing_*_specialty/luxury | `ing_*.png` | economy §2.1, scoring §4 |
| 도구 프로 | knife_pro … mixbowl_pro | `{tool}_pro.png` | economy §6.1 |
| 도구 마스터 | knife_master … | `{tool}_master.png` | economy §6.3 (어워드) |
| 그릇 빈 | dish_*_empty | `dish_*_empty.png` | economy §7 |
| 그릇 매칭 | dish_*_{food} | `dish_*_{food}.png` | scoring §11 |
| UI | UI-01~11 | `ui_*.png` | art-needs §5 |
| 배경 | BG-V2-01~07 | `bg_*.png` | art-needs §6 |
| 시장 BG | M1~M10 | `bg_market_*.png` | markets-v1, worldbuilding-v1 |
| 상인 NPC | npc_m1~m10 | `npc_m*.png` | characters-v2 §7 |
| 시장 소품/이벤트 | prop_*, cutscene_* | `prop_*.png`/`cutscene_*.png` | markets-v1 §4 |

## 4. 인제스트 워크플로 (생성 후)
1. 카테고리별 인테이크 폴더에 **파일명대로** 저장:
   - 캐릭터 → `assets-raw/premium_v2_characters/`
   - 재료 → `assets-raw/premium_v2_ingredients/` · 도구 → `..._tools/` · 그릇 → `..._dishware/`
   - UI → `assets-raw/premium_v2_ui/` · 배경 → `assets-raw/premium_v2_bg/`
   - 시장 BG → `assets-raw/premium_v2_markets/` · 상인 NPC → `assets-raw/premium_v2_npc/` · 소품/컷씬 → `assets-raw/premium_v2_market_props/`
   - 플레이어 프리셋 → `assets-raw/premium_v2_players/` · 신규 메뉴 → `assets-raw/premium_v2_menus/`
2. 컷아웃(캐릭터·도구·그릇·재료): `python3 tools/cutout_bg.py --in <폴더> --out <폴더>_cut` (흑/백 자동). **BG·일부 UI는 컷아웃 제외**(풀 장면/투명 의도).
3. 표정 3종 시트는 3등분 크롭 → star1/2/3. 페어/그룹은 그대로.
4. "넣었음" 알려주시면 → 게임 반영 + 신규 리소스(Character/Tool/Dishware) 데이터화는 구현 sprint에서.

## 5. 생성 우선순위 (권장)
1. **캐릭터 15** (메타의 얼굴, 가장 가시적) — 각 A 풀바디 먼저 → B/C
2. **그릇 9 빈 + UI(인벤토리·그릇선택·트로피룸)** (신규 페이즈 가시화)
3. **도구 마스터 9 → 프로 9** (어워드 동기)
4. **재료 특산품·명품 13** + 배경 7
> 카피 편의를 위해 각 파일은 슬롯별 단일 코드블록. 한 캐릭터/세트는 동일 reference로 일관성 유지.

## 6. A/B·미결 (디폴트 선택, 확인 대기)
- 채소 특산품 별도 제작 여부 — 디폴트: 핵심 게이트 재료만 신규, 채소는 기본 재사용. `[사용자 확인 필요]`
- 그릇 "음식 담김"을 런타임 합성으로 대체할지 — 디폴트: 핵심 6조합만 정지컷 제작. `[사용자 확인 필요]`
- 표정: 3종 시트(1블록) vs 개별 3블록 — 디폴트: 시트 후 크롭. `[사용자 확인 필요]`
