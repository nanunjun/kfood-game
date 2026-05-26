# Godot Setup Guide — K-Food Master

> 버전: **v1.0 (2026-05-24)** · 작성자: godot-dev
> 대상 사용자: K-Food Master 1인 개발자 (Windows 11 환경 기준)
> 목적: 본 가이드 따라 **한 sprint(1~3일) 내 Godot 개발 + Android AAB 빌드 환경 완성**.
> 상위 결정: [ADR-004](decisions.md#adr-004) Engine = Godot 4.5.2 LTS, GDScript only.

---

## 0. Prerequisite Check

- [ ] **OS**: Windows 11 (Pro/Home 모두 OK)
- [ ] **디스크 여유**: ~10 GB
  - Godot Editor ~150 MB
  - JDK 17 ~300 MB
  - Android SDK + NDK ~7 GB (NDK가 큼)
  - Gradle 캐시 ~1 GB
  - 첫 빌드 산출 ~50 MB
- [ ] **인터넷 안정 회선** (SDK manager 패키지 다운로드 ~30분)
- [ ] **관리자 권한** (환경 변수 등록 시)

> Mac/Linux 사용자는 §10 OS 변환표 참조.

---

## Step 1 — Godot 4.5.2 LTS 설치

1. https://godotengine.org/download/archive/ 접속 → **4.5.2 LTS Standard** (Mono 빌드 X — GDScript only)
   - Windows 64-bit: `Godot_v4.5.2-stable_win64.exe.zip`
2. 권장 설치 경로: `C:\Tools\Godot\Godot_v4.5.2-stable_win64.exe`
3. 첫 실행:
   - "Import" 버튼 → `C:\Projects\kfood-game\godot-project\project.godot` 선택
   - "Import & Edit" 클릭 → editor가 프로젝트 열림
4. 검증: Editor 좌측 FileSystem 탭에서 `scripts/`, `resources/`, `scenes/` 등 폴더 표시
   - import 에러 0건 (하단 출력 패널 확인)

> **메모**: 4.6은 새 기능 트랙으로 보류 (ADR-004 default). 4.6 사용 시 export template 호환성 별도 검증.

---

## Step 2 — JDK 17 설치

Godot 4.5.x Android 빌드는 **JDK 17** 권장. 11/21은 비호환 가능.

### 옵션 A: Eclipse Temurin 17 LTS (권장)
1. https://adoptium.net/temurin/releases/?version=17 → Windows x64 MSI 다운로드
2. MSI 설치 시 **"Set JAVA_HOME variable"** 옵션 체크
3. 새 PowerShell 창에서 검증:
   ```powershell
   java -version
   # openjdk version "17.0.x" 2024-xx-xx 출력 확인
   echo $env:JAVA_HOME
   # C:\Program Files\Eclipse Adoptium\jdk-17.0.x.x-hotspot 확인
   ```

### 옵션 B: Microsoft OpenJDK 17
1. https://learn.microsoft.com/en-us/java/openjdk/download → "OpenJDK 17.x.x LTS" Windows x64 MSI
2. 설치 후 동일 검증

---

## Step 3 — Android SDK 설치

### 옵션 A: commandlinetools만 (권장, 1인 개발 ~500MB)

1. https://developer.android.com/studio → 페이지 하단 "Command line tools only" → Windows zip
2. 압축 풀기: `C:\AndroidSDK\cmdline-tools\latest\` (subfolder `latest` 필수)
3. 환경 변수 설정 (시스템 환경 변수):
   ```
   ANDROID_HOME = C:\AndroidSDK
   PATH += C:\AndroidSDK\cmdline-tools\latest\bin
   PATH += C:\AndroidSDK\platform-tools
   ```
4. 새 PowerShell 창에서 license 동의 + 필수 패키지 설치:
   ```powershell
   sdkmanager --licenses
   # y 반복 입력하여 모든 license accept

   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;25.2.9519653"
   # ~3~5GB 다운로드 (NDK 크기 dominant)
   ```
5. 검증:
   ```powershell
   adb --version
   # Android Debug Bridge version 1.0.41 확인
   ```

### 옵션 B: Android Studio (GUI 선호 시)
- https://developer.android.com/studio 풀 IDE 다운로드 (~1GB)
- SDK Manager에서 동일 패키지 install
- `ANDROID_HOME` = `%USERPROFILE%\AppData\Local\Android\Sdk`

---

## Step 4 — Godot Android Export Template 설치

1. Godot Editor: `Editor` 메뉴 → `Manage Export Templates`
2. "Download and Install" 클릭 → 4.5.2 LTS template 다운로드 (~1GB, 모든 플랫폼 포함)
3. 설치 후 "Templates installed successfully" 메시지 확인

### Project-level Android 설정
4. `Project` → `Project Settings` → 좌측 "Plugins" 또는 직접 `Editor Settings` →
   - Editor Settings → `Export > Android`:
     - **Android SDK Path**: `C:\AndroidSDK`
     - **Debug Keystore**: (Step 5에서 생성 후 입력)
     - **Java SDK Path**: `%JAVA_HOME%` (또는 직접 경로)

5. Custom Build (Gradle) 활성화:
   - `Project` → `Install Android Build Template` 실행 → `android/build/` 폴더 생성됨
   - export_presets.cfg 의 `gradle_build/use_gradle_build=true` (이미 설정됨) 확인

---

## Step 5 — Debug Keystore 생성

```powershell
# %USERPROFILE%\.android\ 폴더 미존재 시 생성
New-Item -ItemType Directory -Force "$env:USERPROFILE\.android"

# debug keystore 생성 (Android 표준 매개변수)
keytool -keyalg RSA -genkeypair -alias androiddebugkey `
    -keypass android -keystore "$env:USERPROFILE\.android\debug.keystore" `
    -storepass android -dname "CN=Android Debug,O=Android,C=US" `
    -validity 9999 -deststoretype pkcs12
```

→ `C:\Users\{user}\.android\debug.keystore` 생성됨.

Godot Editor:
- `Editor Settings > Export > Android > Debug Keystore`: 위 경로 입력
- Debug Keystore User: `androiddebugkey`
- Debug Keystore Password: `android`

> **release keystore**는 Google Play 정식 출시 직전 별도 생성 (Step 7 후 별도 sprint).

---

## Step 6 — 공식 Plugin 3종 설치

### 6.1 AppLovin MAX Godot Plugin (광고)

- **Repo**: `AppLovin/AppLovin-MAX-Godot` (GitHub), v1.2.0+ (2025-04-24)
- **공식 가이드**: https://developers.applovin.com/en/max/godot/

**설치**:
1. **옵션 A (Asset Library)**: Godot Editor → AssetLib 탭 → "AppLovin MAX" 검색 → Download
2. **옵션 B (GitHub release)**:
   - https://github.com/AppLovin/AppLovin-MAX-Godot/releases → latest zip 다운로드
   - 압축 풀기 → `godot-project/addons/applovin_max/` 배치
3. `Project > Project Settings > Plugins`에서 enable

**SDK Key 발급**:
1. https://www.applovin.com/ → Sign Up / Login
2. Dashboard → **Account > Keys** → SDK Key 복사
3. **NEVER commit**. AppLovin MAX 설정 화면에서 직접 입력 또는 ENV 주입.

**Ad Unit 생성**:
1. MAX dashboard → "Applications" → K-Food Master Android app 등록 (Google Play upload 후 package name 확정 시)
2. Rewarded / Interstitial / Banner 각 1개 unit 생성
3. Ad unit ID를 `scripts/autoload/ads_manager.gd` 의 `AD_UNIT_*` 상수에 입력 (NEVER hardcode 후 commit; Remote Config 우선)

**Mediation 어댑터** (M2~M3 sprint):
- AdMob, Meta Audience Network, Amazon Publisher Services 어댑터를 MAX Mediation Manager에서 활성화.

### 6.2 Godot Foundation Google Play Billing Plugin (IAP)

**설치**:
1. Godot Editor → AssetLib → "Google Play Billing" 검색 → Godot Foundation 공식 plugin Download
2. 압축 풀기 → `godot-project/addons/googleplaybilling/` 배치
3. `Project > Project Settings > Plugins`에서 enable

**Google Play Console SKU 생성**:
1. https://play.google.com/console → K-Food Master 앱 (production track 등록 후 가능)
2. **Monetize > Products > In-app products**:
   - SKU: `remove_ads` — $2.99 — "광고 제거"
   - SKU: `coin_pack_small` — $0.99 — placeholder
   - SKU: `coin_pack_medium` — $4.99 — placeholder
   - SKU: `coin_pack_large` — $9.99 — placeholder
3. 가격 책정은 ADR-003 / GDD §5.3 기준. placeholder는 M3 soft launch 직전 본 값 확정.

> **메모**: SKU 생성은 Play Console에 첫 internal track upload 후에만 가능. 즉 첫 AAB 빌드(Step 7) → Play Console internal upload → SKU 생성 순서.

### 6.3 Godotx Firebase Plugin (Analytics + Crashlytics + Remote Config)

- **Repo**: https://github.com/paulocoutinho/godotx-firebase (MIT)
- **Maintainer**: paulocoutinho (커뮤니티, ADR-004 검증)

**설치**:
1. GitHub release → latest zip
2. 압축 풀기 → `godot-project/addons/godotx_firebase/` 배치
3. `Project > Project Settings > Plugins`에서 enable

**Firebase Console 설정**:
1. https://console.firebase.google.com → "Add Project" → "K-Food Master"
2. **Add Android app** → package name = `com.studio.kfoodmaster` (export_presets.cfg와 동일)
3. **google-services.json** 다운로드 → `godot-project/google-services.json` 배치
   - **NEVER commit** (`.gitignore` 이미 명시)
4. Console에서 활성화:
   - Analytics: 자동 (별도 설정 X)
   - **Crashlytics**: Firebase Console → Crashlytics → "Enable"
   - **Remote Config**: balance-config.md v0.2 §2 키 catalog를 Remote Config에 등록 (M2 sprint에서 일괄 import)

---

## Step 7 — 첫 AAB Smoke Test

목표: Step 1~6 검증. 실 gameplay 없어도 빈 씬으로 AAB 빌드 성공해야 함.

### 7.1 main 씬 생성 (skeleton)
1. Godot Editor → `Scene > New Scene` → 2D Scene → 저장: `scenes/main.tscn`
   - (project.godot `run/main_scene`이 본 경로 가리킴)
2. Node 추가: `Label` → text = "K-Food Master v0.1.0" (placeholder, M2에서 main menu로 교체)
3. 저장 후 F5로 editor 내 실행 → Label 표시 확인

### 7.2 AAB Export
1. `Project > Export...` → Android preset 클릭
2. "Export Project" 버튼 클릭 → 파일 경로 = `C:\Projects\kfood-game\build\kfoodmaster-0.1.0.aab`
   - export_presets.cfg `export_path`가 본 경로 가리킴
3. 빌드 시간: 첫 빌드 5~15분 (Gradle 캐시 warm up). 후속 빌드 1~3분.

### 7.3 (선택) Device install 검증
- bundletool 사용:
  ```powershell
  java -jar bundletool.jar build-apks --bundle=build/kfoodmaster-0.1.0.aab --output=build/kfoodmaster.apks --mode=universal
  java -jar bundletool.jar install-apks --apks=build/kfoodmaster.apks
  ```
- USB 디버깅 활성 Android 디바이스 연결 + `adb devices` 인식 확인 후 위 명령 실행.

---

## Step 8 — 검증 체크리스트

- [ ] Godot Editor에서 `godot-project/project.godot` 정상 import
- [ ] FileSystem 탭에서 폴더 트리(scripts/resources/scenes/...) 표시
- [ ] Resource 스키마 6종 (food_definition.gd 등) import 에러 0건
- [ ] autoload 6종 (GameManager 등) `Project Settings > Autoload` 탭에서 enable 표시
- [ ] `Project > Export > Android` preset 표시 + 'Export Project' 버튼 활성 (회색 아님)
- [ ] AAB 빌드 산출 `C:\Projects\kfood-game\build\kfoodmaster-0.1.0.aab` 생성 (50~80 MB 예상)
- [ ] (Step 6 완료 시) AppLovin MAX plugin autoload 노출 (`AppLovinMAX` singleton 사용 가능)
- [ ] (Step 6 완료 시) Firebase init 로그에 에러 0 (Crashlytics test crash 없이 init OK)

---

## Step 9 — 알려진 함정

### 우선순위 Top 3 (가장 자주 만남)
1. **JDK 버전 mismatch** — Godot 4.5.x는 **JDK 17** 권장. JDK 11/21 사용 시 gradle 빌드 fail.
   - 증상: "Unsupported class file major version" 에러
   - 해결: Step 2 재실행, `JAVA_HOME` 17 가리키는지 확인
2. **Android NDK 미설치 / 버전 mismatch** — Godot mobile renderer는 NDK 필요.
   - 증상: AAB export 시 "NDK not found" 또는 ".so missing" 에러
   - 해결: `sdkmanager "ndk;25.2.9519653"` 실행, Editor Settings에서 NDK path 명시
3. **AppLovin SDK Key 미발급 / 미입력** — plugin이 silent fail.
   - 증상: 광고 호출해도 콜백 무반응, 로그에 "SDK key not set" 경고
   - 해결: developers.applovin.com Account > Keys에서 발급 후 plugin 설정에 입력

### 기타 함정
4. **Gradle daemon 메모리 부족** — Windows 기본 heap 부족 시 빌드 OOM.
   - 해결: `android/build/gradle.properties`에 `org.gradle.jvmargs=-Xmx2g` 추가
5. **Firebase `google-services.json` 경로 오류** — Godotx Firebase는 정확한 경로 요구.
   - 해결: 반드시 `godot-project/google-services.json` (project.godot 옆)에 배치
6. **export_presets.cfg keystore 경로에 공백** — Windows 경로의 `Program Files` 등 공백 처리.
   - 해결: 경로를 single quote로 감싸거나 8.3 short name 사용
7. **Asset Library plugin 버전 표시 mismatch** — Godot 4.5.2와 plugin 메타 4.6 표시 시.
   - 해결: GitHub release에서 직접 4.5.x branch 다운로드
8. **Custom Build Template 재설치 필요** — Godot upgrade 후 `android/build/` 폴더 conflict.
   - 해결: `android/build/` 폴더 삭제 후 `Install Android Build Template` 재실행

---

## Step 10 — Mac / Linux 대응

본 가이드는 Windows 11 기준. Mac/Linux 사용 시:

| 항목 | Windows | Mac | Linux |
|------|---------|-----|-------|
| Godot 다운로드 | `_win64.exe.zip` | `_macos.universal.zip` | `_linux.x86_64.zip` |
| JDK | Adoptium MSI | `brew install temurin@17` | `apt install openjdk-17-jdk` |
| Android SDK 경로 | `C:\AndroidSDK` | `~/Library/Android/sdk` | `~/Android/Sdk` |
| keystore 경로 | `%USERPROFILE%\.android\debug.keystore` | `~/.android/debug.keystore` | `~/.android/debug.keystore` |
| ENV 설정 | 시스템 환경 변수 | `~/.zshrc` export | `~/.bashrc` export |

기타 절차(plugin 설치, AAB export)는 모두 동일.

---

## 다음 sprint (M2) 이월 항목

- [ ] godot-dev: main 씬 → main menu 씬 교체 (UI 디자인 따라)
- [ ] godot-dev: Resource 스키마 6종 → .tres 인스턴스 12 음식 + 42 재료 + 5 가게 일괄 생성
- [ ] godot-dev: AppLovin MAX 실 wiring (rewarded ad → Hint 버튼 연결)
- [ ] godot-dev: Google Play Billing 실 wiring (Remove Ads 구매 flow)
- [ ] godot-dev: Firebase Analytics 이벤트 5종 logging 구현
- [ ] godot-dev: Remote Config fetch + balance-config v0.2 키 catalog Console 등록
- [ ] godot-dev: U-2 양친 0.6s 시차 unlock 컷씬 AnimationPlayer 구현
- [ ] qa-tester: 본 가이드 따라 신규 환경 sample run + 함정 ranking update

---

## 변경 이력

- **2026-05-24 v1.0** — godot-dev 신설. Godot 4.5.2 LTS + JDK 17 + Android SDK + plugin 3종 + AAB smoke test 가이드. 알려진 함정 Top 3 + 기타 5종. Windows 11 기준, Mac/Linux 변환표 §10.
