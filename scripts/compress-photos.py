#!/usr/bin/env python3
# Usage: python3 compress-photos.py SOURCE_DIR DEST_DIR
#
# Copy images from SOURCE_DIR into DEST_DIR as JPEGs for publishing.
# The long edge is at most 1600 pixels (smaller pictures are not enlarged),
# JPEG quality is 82, and EXIF orientation is baked into the pixels.
# EXIF, GPS, XMP, and IPTC are not written. An ICC color profile is kept
# when the source has one, so colors do not shift. Files that already exist
# in DEST_DIR are skipped. Directory structure is preserved and the output
# extension is .jpg.
#
# This file does not depend on the Hugo site. Point SOURCE_DIR at a camera
# card or a folder of scans, and DEST_DIR at an Obsidian vault or at
# content/plamo/<kit>/.
#
# Dependency: Pillow
#   pip install pillow
#   Debian/Ubuntu: sudo apt install python3-pil
# HEIC also needs pillow-heif (pip install pillow-heif).

import sys
from pathlib import Path

LONG_EDGE = 1600
QUALITY = 82
EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".heic", ".heif"}


def usage():
    print(
        "Usage: python3 compress-photos.py SOURCE_DIR DEST_DIR\n"
        "\n"
        "Resize to a 1600px long edge, JPEG quality 82, bake in EXIF\n"
        "orientation, and drop EXIF/GPS/XMP/IPTC. Skip existing outputs.",
        file=sys.stderr,
    )


def load_pillow():
    try:
        from PIL import Image, ImageOps, UnidentifiedImageError
    except ImportError:
        print(
            "error: Pillow is not installed. Install it with: pip install pillow",
            file=sys.stderr,
        )
        sys.exit(1)
    try:
        from pillow_heif import register_heif_opener

        register_heif_opener()
    except ImportError:
        pass
    resample = getattr(getattr(Image, "Resampling", Image), "LANCZOS")
    return Image, ImageOps, UnidentifiedImageError, resample


def to_rgb(image, image_module):
    if image.mode == "RGB":
        return image
    if image.mode in ("RGBA", "LA") or (
        image.mode == "P" and "transparency" in image.info
    ):
        rgba = image.convert("RGBA")
        background = image_module.new("RGB", rgba.size, (255, 255, 255))
        background.paste(rgba, mask=rgba.getchannel("A"))
        return background
    return image.convert("RGB")


def compress_one(src, dest, image_module, image_ops, resample):
    with image_module.open(src) as image:
        image = image_ops.exif_transpose(image) or image
        icc = image.info.get("icc_profile")
        image = to_rgb(image, image_module)
        image.thumbnail((LONG_EDGE, LONG_EDGE), resample)
        kwargs = {"format": "JPEG", "quality": QUALITY, "optimize": True}
        if icc:
            kwargs["icc_profile"] = icc
        dest.parent.mkdir(parents=True, exist_ok=True)
        image.save(dest, **kwargs)


def main(argv):
    if len(argv) != 3 or argv[1] in ("-h", "--help"):
        usage()
        return 0 if len(argv) > 1 and argv[1] in ("-h", "--help") else 2

    src = Path(argv[1]).expanduser().resolve()
    dest = Path(argv[2]).expanduser().resolve()
    if not src.is_dir():
        print(f"error: source is not a directory: {src}", file=sys.stderr)
        return 2
    if dest == src or src in dest.parents:
        print("error: destination must not be inside the source folder", file=sys.stderr)
        return 2

    image_module, image_ops, unidentified, resample = load_pillow()
    files = sorted(
        path
        for path in src.rglob("*")
        if path.is_file() and path.suffix.lower() in EXTENSIONS
    )
    if not files:
        print(f"no images under {src}")
        return 0

    failures = 0
    for path in files:
        relative = path.relative_to(src)
        output = dest / relative.with_suffix(".jpg")
        if output.exists():
            print(f"skip {output} (already exists)")
            continue
        try:
            compress_one(path, output, image_module, image_ops, resample)
        except unidentified:
            print(
                f"error: cannot open {path} (HEIC needs: pip install pillow-heif)",
                file=sys.stderr,
            )
            failures += 1
            continue
        except Exception as exc:
            print(f"error: {path}: {exc}", file=sys.stderr)
            failures += 1
            continue
        print(f"write {output}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
