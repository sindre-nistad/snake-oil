#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">= 3.13"
# dependencies = [
#     "fonttools",
# ]
# ///
import tempfile
from pathlib import Path

from fontTools import ttx


def main():
    project_root = Path(__file__).parent.parent

    font_dir = (
        project_root / "src" / "mandelbrot" / "assets" / "fonts" / "liberation_sans"
    )

    print("Collecting fonts")
    with tempfile.TemporaryDirectory() as tmp:
        temp_file = Path(tmp) / "LiberationSans.tmp"
        for font in font_dir.glob("LiberationSans*.ttf"):
            ttx.main([str(font), "-q", "-o", str(temp_file)])
        ttx.main([str(temp_file), "-q", "-o", str(font_dir / "LiberationSans.ttc")])


if __name__ == "__main__":
    main()
