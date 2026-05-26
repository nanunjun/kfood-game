# godot-project/

Godot 4.6 (또는 4.5.2 LTS 라인) 프로젝트 루트. GDScript only. [ADR-004](../docs/decisions.md#adr-004) 참조.

## 초기 셋업 체크리스트
1. **Godot 4.6 (또는 4.5.2 LTS)** standard build 다운로드 (Mono 빌드 X — GDScript only)
2. Android export 환경:
   - Android SDK (API 24+) / Build Tools / Platform Tools
   - OpenJDK 17
   - Godot Editor → `Editor > Manage Export Templates`에서 Android template 설치
   - `Project > Export...`에서 Android preset 추가 후 SDK 경로 / debug keystore 지정
3. 공식 plugin 설치 (Asset Library 또는 GitHub):
   - **AppLovin MAX Godot plugin** (`AppLovin/AppLovin-MAX-Godot`) — Ads
   - **Godot Google Play Billing plugin** (Godot Foundation) — IAP
   - **Godotx Firebase** (`godot-x/firebase`, MIT) — Analytics / Crashlytics
   - (선택) Godot Google Play Games Services
4. AppLovin MAX SDK key 발급 후 Mediation Manager에서 어댑터(AdMob / Meta Audience Network / Amazon Publisher Services 등) 활성화

## 예상 폴더 구조
```
godot-project/
├── project.godot
├── scenes/             ← .tscn 씬 (시장/키친/식탁/메뉴 등)
├── scripts/
│   ├── gameplay/       ← cooking 3단계 루프(재료/방법/타이밍), 채점
│   ├── ui/             ← 메뉴, HUD, 팝업
│   ├── ads/            ← AppLovin MAX 래퍼
│   ├── iap/            ← Google Play Billing 래퍼
│   ├── save/           ← 저장/로드
│   └── analytics/      ← 이벤트 트래킹 (Firebase Analytics)
├── resources/          ← .tres Resource (FoodDefinition, IngredientDefinition, FriendDefinition 등 — Unity ScriptableObject 대응)
├── art/
│   ├── sprites/
│   ├── ui/
│   └── animations/
├── audio/
│   ├── sfx/
│   └── bgm/
├── addons/             ← 설치한 공식 plugin (applovin_max, googleplaybilling, firebase 등)
└── export_presets.cfg
```

## 주의
- `.godot/`, `.import/`, `export.cfg` 캐시, 빌드 출력 등은 `.gitignore` 처리됨 (godot 표준 `.gitignore` 참조)
- 빌드 산출물(AAB)은 이 폴더가 아닌 루트 `build/`로 출력
- `.tscn` (씬) / `.tres` (리소스) 텍스트 편집은 가급적 Godot Editor에서 처리 — 텍스트 diff 가능하더라도 손편집 우선순위 낮음
- C#/.NET 미사용 — Godot 4.x mono 빌드 다운로드 금지
