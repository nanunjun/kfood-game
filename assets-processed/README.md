# assets-processed/

Unity 임포트용으로 가공된 에셋.

## 무엇을 두는가
- 스프라이트: `.png` (투명 배경, POT 권장)
- 스프라이트 시트 / 아틀라스
- 사운드: `.ogg` (BGM) / `.wav` 또는 `.ogg` (SFX, 압축 정책에 따라)
- 폰트: `.ttf`, `.otf` (라이선스 확인 완료된 것만)
- UI 9-slice 이미지

## 구조 예시
```
assets-processed/
├── sprites/
│   ├── food/          ← 한식 아이템
│   ├── ui/
│   └── effects/
├── audio/
│   ├── sfx/
│   └── bgm/
└── fonts/
```

## 운영 규칙
- 파일명: `snake_case` (예: `tteokbokki_lv3.png`)
- 모바일 최적화: 텍스처 최대 1024x1024 권장, 필요 시 2048
- 이 폴더 → `unity-project/Assets/` 로 복사하거나 심볼릭 링크
- **원본 보존**: 수정이 필요하면 `assets-raw/`에서 다시 export
