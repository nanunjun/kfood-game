"""
K-Food Master — OpenAI image generation utility.

ADR-006 reference: art 도구 = ChatGPT (GPT-4o image / DALL-E 3).
본 script는 OpenAI API를 직접 호출하여 art-style iteration 자동화.

Usage:
    py tools/gen_image.py --prompt "..." --out path/to/image.png
    py tools/gen_image.py --prompt-file path/to/prompt.txt --out path/to/image.png
    py tools/gen_image.py --model dall-e-3 --size 1024x1024 --quality standard ...

Model options:
    - dall-e-3        : standard $0.040/1024², HD $0.080/1024² (안정, 권장)
    - gpt-image-1     : standard ~$0.011~0.042 quality별 (최신)
"""

import argparse
import base64
import os
import sys
from pathlib import Path

# Windows cp949 stdout 회피 — emoji/한글 print 위해
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

from dotenv import load_dotenv
from openai import OpenAI


def load_api_key() -> str:
    """Load OPENAI_API_KEY from .env at project root."""
    project_root = Path(__file__).resolve().parent.parent
    load_dotenv(project_root / ".env")
    key = os.getenv("OPENAI_API_KEY")
    if not key or "PASTE_YOUR_KEY_HERE" in key:
        sys.exit("❌ OPENAI_API_KEY가 .env에 설정되지 않음. https://platform.openai.com/api-keys 에서 발급 후 .env 갱신.")
    return key


def generate_image(
    client: OpenAI,
    prompt: str,
    output_path: Path,
    model: str = "dall-e-3",
    size: str = "1024x1024",
    quality: str = "standard",
    background: str = "auto",
) -> Path:
    """Generate a single image and save to output_path. Returns the saved path."""
    print(f"🎨 모델={model} 사이즈={size} 품질={quality} 배경={background}")
    print(f"📝 prompt: {prompt[:120]}{'...' if len(prompt) > 120 else ''}")

    if model == "dall-e-3":
        result = client.images.generate(
            model="dall-e-3",
            prompt=prompt,
            size=size,
            quality=quality,
            n=1,
        )
    elif model == "gpt-image-1":
        # gpt-image-1은 quality에 'low'/'medium'/'high'/'auto' 사용
        gpt_quality = quality if quality in {"low", "medium", "high", "auto"} else "medium"
        gpt_background = background if background in {"transparent", "opaque", "auto"} else "auto"
        result = client.images.generate(
            model="gpt-image-1",
            prompt=prompt,
            size=size,
            quality=gpt_quality,
            background=gpt_background,
            n=1,
        )
    else:
        sys.exit(f"❌ 미지원 model: {model}. dall-e-3 또는 gpt-image-1 사용.")

    data = result.data[0]
    if hasattr(data, "b64_json") and data.b64_json:
        image_bytes = base64.b64decode(data.b64_json)
    elif hasattr(data, "url") and data.url:
        # fallback (대부분 b64 권장 — 다운로드 단계 추가 불필요)
        import urllib.request
        with urllib.request.urlopen(data.url) as resp:
            image_bytes = resp.read()
    else:
        sys.exit("❌ API 응답에 이미지 데이터 없음.")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(image_bytes)
    size_kb = len(image_bytes) / 1024
    print(f"✅ 저장: {output_path} ({size_kb:.1f} KB)")

    # revised_prompt (DALL-E 3가 prompt 자동 보강한 경우) 표시
    if hasattr(data, "revised_prompt") and data.revised_prompt:
        print(f"ℹ️  DALL-E가 prompt 자동 보강:")
        print(f"   {data.revised_prompt[:200]}{'...' if len(data.revised_prompt) > 200 else ''}")

    return output_path


def main() -> None:
    parser = argparse.ArgumentParser(description="OpenAI image generation for K-Food Master art.")
    src = parser.add_mutually_exclusive_group(required=True)
    src.add_argument("--prompt", type=str, help="Prompt 문자열")
    src.add_argument("--prompt-file", type=Path, help="Prompt 파일 경로 (UTF-8)")
    parser.add_argument("--out", type=Path, required=True, help="저장할 이미지 경로 (.png)")
    parser.add_argument("--model", default="gpt-image-1", choices=["dall-e-3", "gpt-image-1"], help="dall-e-3은 deprecated 가능, gpt-image-1 권장")
    parser.add_argument("--size", default="1024x1024", help="gpt-image-1: 1024x1024 / 1536x1024 / 1024x1536 / auto. dall-e-3 (legacy): 1024x1024 / 1792x1024 / 1024x1792")
    parser.add_argument("--quality", default="medium", help="gpt-image-1: low / medium / high / auto. dall-e-3 (legacy): standard / hd")
    parser.add_argument("--background", default="auto", choices=["transparent", "opaque", "auto"], help="gpt-image-1: transparent (PNG alpha), opaque (solid), auto. 게임 asset은 transparent 권장.")

    args = parser.parse_args()

    prompt = args.prompt if args.prompt else args.prompt_file.read_text(encoding="utf-8").strip()
    if not prompt:
        sys.exit("❌ 빈 prompt.")

    api_key = load_api_key()
    client = OpenAI(api_key=api_key)
    generate_image(client, prompt, args.out, args.model, args.size, args.quality, args.background)


if __name__ == "__main__":
    main()
