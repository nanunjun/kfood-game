# Visual Quality Audit — 2026-06 (Premium Casual Benchmark)

> 버전: **v0.1** · 작성일: 2026-06-04 · 작성자: ui-designer
> Scope: **시각 품질 only** — gameplay / 데이터 구조 / scoring 변경 X.
> 비교 대상: Royal Match (Dream Games 2021) · Travel Town (Magmatic 2021) · Cooking Madness (Mobaska 2017) · Merge Mansion (Metacore 2020).
> 대상 화면 4종: (1) Menu Select · (2) Guest Select · (3) Cooking Screen (cooking_module_runner 8 module) · (4) Result Screen v2.
> 입력 자료: `assets-raw/_screenshots/guest_v2/01,02_*.png`, `assets-raw/_screenshots/result_v2/01,02,03,04_*.png`, `assets-raw/_screenshots/cooking_framework_v2/01~06_*.png`.
> 후속: `docs/ui/premium-redesign-v1.md` (redesign spec) + `docs/ui/components.md` v0.6 (시각 컴포넌트 추가).

---

## 0. 4 Reference 게임 시각 패턴 분석

### 0.1 Royal Match (Dream Games, 2021)
**핵심 시각 톤**: 채도 75~85% saturated jewel-tone palette (royal blue / ruby red / emerald green / gold yellow). 모든 인터랙티브 요소는 **glossy 3D sphere** — 내부 상단 흰색 specular highlight + 외곽 어두운 outline + soft drop-shadow 8~12px. 마스코트(King) 캐릭터가 화면 모서리에서 항상 idle animation (눈 깜박임 / breathing) — 빈 시간을 캐릭터로 채움. CTA 버튼은 화면 폭의 60%, 라운드 32px, **두꺼운 인너 하이라이트** (top 20% = white 30% gradient). Premium gold 액센트는 헤더 띠 + 별 + 코인 hud에 일관 적용. **info hierarchy** = (1) 캐릭터 face / (2) CTA / (3) goal counter / (4) HUD 순서로 시선 유도.

### 0.2 Travel Town (Magmatic, 2021)
**핵심 시각 톤**: warm wood textures (sienna `#A0522D` / cream `#F5E6D3`) + **3D depth layering** — 모든 카드/패널이 1~3px lip(외곽 어두운 띠)으로 두께감, soft shadow 12~16px Y-offset. 캐릭터는 expression 5종 swap (idle / happy / sad / surprised / sleepy) — speech bubble 안에 **subtle pulse breathing** 1.5s loop. 보상은 화면 중앙에서 scale 1.3→1.0 bounce + radial light burst + particle 12개. **depth via shadow** — UI elements 위에 ColorRect 0.3 alpha drop shadow가 일관 적용되어 카드들이 떠 있는 느낌.

### 0.3 Cooking Madness (Mobaska, 2017)
**핵심 시각 톤**: vibrant red-orange palette (`#FF4500` / `#FFB800` / cream BG) — **dish hero shots** 항상 화면 중앙 oversized (화면 폭 70~80%) + 김(steam) particle loop + sparkle 4~6개 idle. Time pressure 시각 cue = 화면 가장자리 red pulse vignette + 타이머 bar 색상 단계 변화 (green→yellow→red→flashing). 보상 카운트업은 항상 **bouncing digit** + coin spray (10~20개 particle, 화면 좌상단 HUD로 흡수). 강력한 **before→after dish reveal** — 빈 접시 → 음식 splash drop + 0.4s scale bounce + sparkle ring.

### 0.4 Merge Mansion (Metacore, 2020)
**핵심 시각 톤**: cinematic depth + **soft gradient glow** behind characters (radial gradient from character center, warm yellow/peach). 캐릭터 close-up은 화면 30~40% 차지하는 큰 면적 + 표정 emote bubble. 카드들은 **stacked shadow** (1차 shadow 2px Y / 2차 shadow 12px Y soft) — 두 겹 그림자로 깊이 강조. 텍스트는 stroke 2px outline + drop shadow — 어떤 BG 위에서도 가독성 보장. Color story per area = 한 화면 내 5색 이하 제한, 액센트는 gold만 사용.

### 0.5 4 reference 공통 분모 (premium casual baseline)
1. **Glossy 3D button/icon** — 인너 하이라이트 + 외곽 어두운 lip + drop shadow (flat design 회피).
2. **Character presence** — 항상 character가 한 명 이상 visible, 표정 swap + idle breathing animation.
3. **Reward 강조** — 코인/별 보상은 bounce + particle burst + count-up tween 필수.
4. **Color hierarchy** — 한 화면 5색 이하, gold = premium 액센트 일관.
5. **Depth via shadow** — 모든 카드/패널이 떠 있는 느낌 (drop shadow 8~16px).
6. **Hero shot scale** — 핵심 오브젝트 (음식/캐릭터)는 화면 폭 60~80% 차지.

---

## 1. Screen 1 — Menu Select Audit (현 상태: `assets-raw/_screenshots/guest_v2/01_menu_select.png`)

### 1.1 Empty space problems
| # | issue | 위치 | severity |
|---|-------|------|:----:|
| MS-E1 | **상단 awning(차양)과 첫 카드 사이 공백 과다** — title "K-Food Master" + sub "choose a dish" 사이 + 그 아래 Y 140~280 dead zone | header Y 0~280 | high |
| MS-E2 | **카드 간 vertical gap 16px만** — 카드 4행이 다 채워지면 답답, 1080×1920 portrait에서 breathing 부족 | grid gap | medium |
| MS-E3 | **카드 내부 dish image 영역 비어 보임** — "Art coming soon" 텍스트가 placeholder Bibimbap/Kimchi Stew에 그대로 노출, 카드 4행 중 1행이 시각적으로 죽음 | card body | high |
| MS-E4 | **Lv 8 · Gwangjang 정보 띠가 가는 회색** — 정보 hierarchy에서 약함, 상단 80px 영역이 dead | header strip | medium |

### 1.2 Hierarchy problems
| # | issue | severity |
|---|-------|:----:|
| MS-H1 | **focal point 모호** — 사용자 시선이 어디 가야 할지 불분명. 6 카드 모두 동일 weight (compat % 92% vs 78%인데 시각적 차이 미미) | high |
| MS-H2 | **5-second rule 실패** — "어떤 음식을 골라야 best 점수일까"가 5초 안에 안 보임. 모든 카드 동일 layout + 작은 chip만 비교 | high |
| MS-H3 | **Best card에 RECOMMENDED 띠 없음** — Guest Select에는 ✨RECOMMENDED 띠가 있는데 Menu Select에는 가장 high compat 카드 강조 X | high |
| MS-H4 | **"Cook · Stock 3" CTA가 모든 카드에 동일** — 정작 cook 가능/불가능 / best/worst 차이가 시각화 안 됨 | medium |
| MS-H5 | **header awning + footer brown trim이 frame만 차지** — 콘텐츠와 무관, 시선 분산 | low |

### 1.3 Readability problems
| # | issue | severity |
|---|-------|:----:|
| MS-R1 | **mini-badge chip이 너무 작음** — "92%" 24pt + avatar 60×60 + "Best: Junho" 캡션 18pt가 카드 우상단 110×106 영역에 dense, 100ppi 모바일에서 캡션 읽기 어려움 | high |
| MS-R2 | **dish name + kr name 한 줄** — "Janchi Guksu (잔치국수)" 20pt면 카드 폭 510 안에서 가장자리 padding 부족 | medium |
| MS-R3 | **"Mystery Diner is watching" 회색 italic** — 잔치국수 카드 evaluator hint가 14pt 회색, 정작 중요 정보인데 안 보임 | medium |
| MS-R4 | **Cook · Stock 3 단조** — 빨강 BG + 흰 텍스트만, 어떤 stock인지 시각 cue 없음 (재료 N개 아이콘 등) | low |
| MS-R5 | **₩50,000 wallet 표시가 우측 상단 단일 텍스트** — 코인 vs 돈 구분 약함, 아이콘 강조 X | medium |

### 1.4 Emotional engagement problems
| # | issue | severity |
|---|-------|:----:|
| MS-E1 | **캐릭터 0명 visible** — Menu Select에서는 guest avatar 60×60 chip만 노출, "누가 기다리는지" emotion 없음. Royal Match King mascot 부재 | high |
| MS-E2 | **dish 이미지가 정적** — Cooking Madness처럼 steam particle / sparkle idle 없음, dish가 "맛있어 보이는" hook 부재 | high |
| MS-E3 | **"오늘 누가 기다리고 있어요" 같은 narrative hook 없음** — 단순 메뉴 리스트 톤 | medium |
| MS-E4 | **빈 placeholder 카드 (Kimchi Stew / Bibimbap "Art coming soon")** — 즉각 broken feeling, premium 톤 깨짐 | high |
| MS-E5 | **awning(시장 차양) BG가 frame 역할만** — Travel Town의 wood texture처럼 atmosphere 만들지 않음, 시각적 noise만 | medium |

---

## 2. Screen 2 — Guest Select Audit (현 상태: `assets-raw/_screenshots/guest_v2/02_guest_select.png`, `03_guest_select_spec_locked.png`)

### 2.1 Empty space problems
| # | issue | severity |
|---|-------|:----:|
| GS-E1 | **타이틀 "Who will love your Kimchi Stew?" 위 Y 0~50 dead zone** — awning trim과 title 사이 공백, awning 자체가 frame | low |
| GS-E2 | **avatar 안쪽 단색 원 + 큰 글자 (F / J / M / R)** — placeholder 임은 알지만 카드 면적의 40%가 단색 fill, 정보 density 0 | high |
| GS-E3 | **카드 하단 REWARD 띠 + "Cook for X >" 가 위/아래 분리** — 두 요소 사이 8px gap이 어색, 하나로 묶이지 않음 | medium |
| GS-E4 | **"compat = food flavor tags vs guest preferences" sub copy** — 너무 길고 회색, screen 상단 약 60px 차지하지만 정작 사용자 안 읽음 | medium |

### 2.2 Hierarchy problems
| # | issue | severity |
|---|-------|:----:|
| GS-H1 | **"93%" 두 카드 동률 시 차이 시각화 부재** — Father 93% / Junho 93% 동률인데 누가 더 "better" 선택인지 시각적 단서 X (reward 액수가 다르더라도) | high |
| GS-H2 | **RECOMMENDED 띠가 카드 위 -28px overlap인데 sub-bar 뒤로 잘림** — "Auto: Junho" sub-bar가 RECOMMENDED 띠 일부 가림, focal point 약화 | high |
| GS-H3 | **friendship 별점이 우상단 작은 회색** — 정작 가까운 친구 = best emotional motivation인데 시각적 weight 낮음 | medium |
| GS-H4 | **Likes / Avoids 두 줄 동일 weight** — Likes (positive)가 더 강조되어야 motivation 명확, 현재는 Avoids가 회색만 살짝 약함 | medium |
| GS-H5 | **REWARD 띠 "guest ×1.50x" 같은 미세 텍스트** — REWARD 자체 강조 X, 1.50x bonus가 시각적으로 안 띔 | high |

### 2.3 Readability problems
| # | issue | severity |
|---|-------|:----:|
| GS-R1 | **flavor tag pill (Spicy/Salty/Hearty)이 너무 작음** — H/Sa/F 1-letter icon + 영어 텍스트, 14pt, 카드당 5 tag = 시각 noise + 인식 어려움 | high |
| GS-R2 | **avatar 안 placeholder 글자 (F/J/M/R)이 너무 큼** — 60pt + 단색 원, character 부재가 더 두드러짐 | high |
| GS-R3 | **mood badge (😊 happy) 작은 노란 원** — avatar 우하단 overlay, 40×40px라 표정 인식 어려움 | medium |
| GS-R4 | **"Cook for Father >" CTA 텍스트 14pt 흰색** — 카드 하단 띠 안에서 작음, tap target 1-thumb로 OK이지만 readability 낮음 | medium |
| GS-R5 | **외곽 색상 = compat color sync (gold/green/yellow/orange/red)** — 카드 외곽 stroke 4px가 BG cream과 contrast 부족, 색 구분 약함 | medium |

### 2.4 Emotional engagement problems
| # | issue | severity |
|---|-------|:----:|
| GS-EM1 | **avatar 단색 원 + 1-letter** — character emotion 0, "이 사람에게 요리해주고 싶다" 동기 부재 | critical |
| GS-EM2 | **mood badge 작아서 표정 인식 어려움** — 5 mood (excited/happy/neutral/grumpy/sad) 중 어떤 mood인지 5초 안에 안 보임 | high |
| GS-EM3 | **speech bubble / dialog 없음** — Guest 카드에 "오늘 김치찌개가 먹고 싶어요" 같은 한 줄 대사 없음, character voice 부재 | high |
| GS-EM4 | **친밀도/관계 시각화 약함** — friendship 별점 5개 우상단 작은 회색, "어머니 ★★★★★ 가족" 같은 emotional weight 없음 | medium |
| GS-EM5 | **best card 펄스 미세함** — RECOMMENDED 띠 pulse만, particle/sparkle/halo 없음 | medium |

---

## 3. Screen 3 — Cooking Screen Audit (현 상태: 8 module screenshots `01~06_*.png`)

> Cooking screen = `cooking_module_runner.tscn` + 8 sub-module scenes (slice / arrange / stir / flip / timing / season / roll / plate). 현재 procedural placeholder (ColorRect/Polygon2D).

### 3.1 Empty space problems
| # | issue | severity |
|---|-------|:----:|
| CK-E1 | **화면 중앙 Y 200~700 대부분 빈 공간 (전 module 공통)** — slice module은 도마 placeholder Y 500 단 1개 시각 요소, timing module은 막대 Y 522 단 1개, 화면의 60%가 dead | critical |
| CK-E2 | **header awning + footer brown trim이 frame만** — 두 frame 사이 Y 80~1700가 비어보임, content 부족 | high |
| CK-E3 | **arrange module: 빈 슬롯 5개 + 재료 카드 5개 사이 Y 450~720 dead zone** — 두 row 사이 270px 빈 공간 | high |
| CK-E4 | **flip module: 검은 oval pan + 갈색 patty 만** — 시각 요소 2개로 화면 채움, atmosphere/depth 0 | high |
| CK-E5 | **"Now Cooking · Kimbap" 같은 dish banner는 있지만 작음** — CLAUDE 안내 따로면 추가됐다지만 screenshot에서는 module 단독 noise | medium |

### 3.2 Hierarchy problems
| # | issue | severity |
|---|-------|:----:|
| CK-H1 | **"Step 1/4 · Slice" 가이드 텍스트가 상단 14pt brown** — 가장 중요한 instruction이 작은 텍스트, focal point X | high |
| CK-H2 | **CTA button (TAP / STOP / FLIP / PRESS&HOLD)이 화면 하단 280×140px 단조 orange 사각형** — 모든 module에서 동일 디자인, module-specific 정체성 X | high |
| CK-H3 | **judgement feedback (MISS / GOOD / PERFECT)이 작은 chip Y 580** — 사용자 액션 후 피드백 약함, Cooking Madness 같은 "PERFECT!" 화면 중앙 burst 부재 | critical |
| CK-H4 | **dish 진행 상태 표시 (Step 1/4)가 텍스트만** — visual progress bar 없음, "지금 어디쯤?" 진행감 약함 | high |
| CK-H5 | **timing module: gold zone vs orange filled bar + 74% 텍스트** — 74%가 너무 작은 brown 텍스트, indicator도 없음, 사용자가 어디서 stop해야 할지 시각 cue 부족 | high |

### 3.3 Readability problems
| # | issue | severity |
|---|-------|:----:|
| CK-R1 | **"Tap anywhere on each beat as the knife drops" guide 14pt regular** — 신규 사용자 입장에서 작고 약함 | medium |
| CK-R2 | **CTA button 텍스트 ("TAP" / "STOP")이 36pt white지만 단색 BG + stroke 없음** — outline / shadow 없어 contrast 부족 | medium |
| CK-R3 | **arrange module 슬롯 (1/2/3/4/5) 숫자 회색 36pt** — 슬롯 BG도 회색, 너무 약함 | medium |
| CK-R4 | **roll module: PRESS & HOLD 버튼이 brown 단색 + 흰 텍스트 가운데 정렬** — gold goal zone bar는 작음, 진행 게이지 hierarchy 약함 | high |
| CK-R5 | **footer trim brown 60px가 정보 없이 차지** — 하단 dead band | low |

### 3.4 Emotional engagement problems
| # | issue | severity |
|---|-------|:----:|
| CK-EM1 | **dish (음식 자체)가 안 보임** — slice/arrange/stir module에서 김밥/떡볶이/김치찌개 실제 음식 sprite 없음, 사용자가 "뭘 요리하는지" 잊음 | critical |
| CK-EM2 | **guest character 안 보임** — 누가 기다리는지 visual reminder X, emotional motivation 0 | critical |
| CK-EM3 | **PERFECT 시 reward feedback 약함** — chip 색상만 변화, particle burst / sparkle / coin spray 없음 | high |
| CK-EM4 | **cooking atmosphere 부재** — 김 (steam) / 사이렌 (sizzle) / particle 등 mood 부재, sterile lab 느낌 | high |
| CK-EM5 | **module 간 transition 약함** — slice→arrange→roll→plate 연속 시 dish progression visual continuity 부족 | medium |

---

## 4. Screen 4 — Result Screen v2 Audit (현 상태: `assets-raw/_screenshots/result_v2/01,03_*.png`)

### 4.1 Empty space problems
| # | issue | severity |
|---|-------|:----:|
| RS-E1 | **§1 Summary dish 영역에 placeholder beige oval + "Kimchi Stew" 텍스트** — 화면 폭 폭 540px 차지하는 핵심 hero shot이 빈 동그라미 | critical |
| RS-E2 | **compat bar 길이 짧음 (300px)** — Y 320 가운데 단순 green bar + "93%" 흰 텍스트 inline, hero compat visualization 약함 | high |
| RS-E3 | **§4 Reaction speech bubble 가로 폭 부족 (370px)** — 카드 폭 540 안에서 좌 padding 큼, 대사 텍스트가 한 줄 잘림 ("loved the spicy kick! Now THAT'S a kick — l...") | high |
| RS-E4 | **avatar opacity 단색 placeholder + 1-letter (J)** — Guest Select와 동일 문제 | high |
| RS-E5 | **Score Breakdown 6 row 간 8px gap** — 6 row가 너무 답답, breathing 부족 | medium |

### 4.2 Hierarchy problems
| # | issue | severity |
|---|-------|:----:|
| RS-H1 | **"Score 8800" 텍스트 hero지만 36pt black plain** — bouncing / scale-in / gold glow 없어 hero 약함 | critical |
| RS-H2 | **★★★__ star rating이 plain gold asterisks** — Cooking Madness 같은 별 burst particle + chime feedback 부재 | high |
| RS-H3 | **NEW RECORD badge가 작은 gold ribbon (210×60px)** — 화면 폭 540 중 210px만, hero record celebration 약함 | high |
| RS-H4 | **Sticky CTA 3 button (Cook Again / Choose Other Guest / Back to Menu)이 동일 weight** — primary action 시각 강조 X, Choose Other / Back은 secondary여야 | high |
| RS-H5 | **Above-the-fold §1 Summary + §4 Reaction 사이 visual separator 없음** — 두 section이 시각적으로 합쳐 보임 | medium |

### 4.3 Readability problems
| # | issue | severity |
|---|-------|:----:|
| RS-R1 | **"compatibility with junho" 14pt 회색 inline** — compat bar 아래 메타 텍스트, 작아서 안 읽힘 | medium |
| RS-R2 | **§2 Score Breakdown row "Chop / roll / knead accuracy" 12pt 회색** — sub-line이 작아 reading flow 어색 | medium |
| RS-R3 | **§3 Rewards 텍스트 "+9,100 coin" 32pt orange but no count-up tween visualized in screenshot** — visual readability OK이나 dynamism 부재 | low |
| RS-R4 | **§3 Rewards "Recipe XP +59" + "Friendship +3 (3/10)" 22pt** — OK readability이나 progress bar 색상 약함 (회색 BG + orange/pink fill) | low |
| RS-R5 | **milestone toast inline expand "Lv 3 Friendship Unlocked!" 18pt** — gold gradient BG 좋지만 텍스트 hierarchy 약함, "+500 coin bonus" 부속 정보 작음 | medium |

### 4.4 Emotional engagement problems
| # | issue | severity |
|---|-------|:----:|
| RS-EM1 | **dish placeholder (beige oval + name)** — Result Screen의 hero shot이 가장 emotional moment ("내가 만든 음식!")인데 placeholder | critical |
| RS-EM2 | **guest avatar single letter** — Reaction speech bubble 옆 avatar가 단색 원 + "J", emotion 0 | critical |
| RS-EM3 | **PERFECT 결과 (Score 8800)인데 celebration FX 부재** — confetti / coin spray / star burst / chime visual 없음 | critical |
| RS-EM4 | **mood badge (😊 happy) 작은 노란 원** — Guest Select와 동일, 표정 reading 어려움 | high |
| RS-EM5 | **§3 Rewards 끝나면 화면 끝** — emotional closure (replay invitation) 없음, "다시 만들어볼까" hook 약함 | medium |

---

## 5. 4 Goal 달성 mapping (audit 결과)

| Goal | 현 상태 점수 (10점 만점) | 주된 결함 | 가장 시급한 screen |
|------|:--------:|----------|------|
| **1. 정보 density** | 5/10 | Menu Select chip 정보는 dense하나 카드 본문은 empty; Result Score Breakdown은 OK | Menu Select |
| **2. 시각 hierarchy** | 4/10 | focal point 모호, 모든 카드 동일 weight, hero element scale 작음 | Menu Select + Result |
| **3. character presence** | 2/10 | 모든 screen에서 avatar = 단색 원 + 1-letter placeholder, idle animation 0, expression swap 0 | Guest Select + Result + Cooking |
| **4. reward presentation** | 3/10 | NEW RECORD ribbon small, coin count-up text only, star rating plain, particle/burst 부재 | Result + Cooking PERFECT |

### 종합
- 현 시각 품질 baseline = **3.5/10** vs Royal Match/Travel Town baseline = **8/10**.
- 핵심 gap 3 = (a) **placeholder art**의 시각적 공백 (dish + avatar), (b) **flat design**에 머문 button/card (glossy 3D 부재), (c) **celebration FX 0** (PERFECT/NEW RECORD에 particle/burst 없음).
- gameplay 무변경으로 시각 quality만 끌어올리려면 **(1) drop shadow + glossy 인너 하이라이트 일관 적용**, **(2) placeholder dish/avatar에 즉시 사용 가능한 art swap**, **(3) celebration FX (particle/tween/sparkle) 4 screen 공통 도입**이 ROI 최대.

---

## 6. Audit → Redesign hand-off

다음 문서 `docs/ui/premium-redesign-v1.md` 에서:
- 각 screen별 5~10 specific redesign items (P0/P1/P2 priority)
- before/after ASCII sketch
- 신규 시각 component 5종 (GlossyButton / GoldFrame / DropShadow / SparkleParticle / CharacterIdleAnimator) `docs/ui/components.md` v0.6 등록
- godot-dev sprint hand-off (file별 변경 list)
