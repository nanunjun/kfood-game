# assets-raw/

원본 에셋 보관소. **Unity는 이 폴더를 읽지 않는다.**

## 무엇을 두는가
- 일러스트 원본: `.psd`, `.ai`, `.clip`, `.kra`
- 고해상도 렌더: 4K 이상 PNG, EXR
- 사운드 원본: `.wav` (24bit/48kHz 이상), 멀티트랙 세션 (`.flp`, `.als`, `.logicx`)
- 폰트 원본 라이선스 파일
- 참고 자료 (한식 사진, 무드보드)

## 구조 예시
```
assets-raw/
├── illustrations/
│   ├── tteokbokki/
│   ├── kimbap/
│   └── kimchi/
├── audio/
│   ├── sfx-sessions/
│   └── bgm-stems/
├── fonts/
└── reference/         ← 무드보드, 한식 사진
```

## 운영 규칙
- 파일 크기 클 가능성 → **Git LFS** 사용 권장 (`*.psd`, `*.ai`, `*.wav` 등)
- 파일명에 공백/한글 지양 (도구 호환성)
- 가공된 결과물은 `../assets-processed/`로 export
