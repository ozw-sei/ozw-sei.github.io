#!/usr/bin/env bash
# Usage: scripts/strip-exif.sh [--check]
#
# Remove EXIF, GPS, XMP, and IPTC from images under content/ and static/.
# JPEG orientation is applied to the pixels first (lossless, via exiftran)
# so the picture is not left sideways. PNG and WebP are rotated with Pillow.
# Shooting dates belong in Hugo front matter; DateTimeOriginal is discarded.
#
#   scripts/strip-exif.sh           rewrite images in place
#   scripts/strip-exif.sh --check   exit 1 if any metadata remains
#
# Dependencies (Debian/Ubuntu):
#   sudo apt install libimage-exiftool-perl exiftran python3-pil
# --check needs only exiftool.

set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

check_only=0
if [[ "${1:-}" == "--check" ]]; then
    check_only=1
elif [[ $# -gt 0 ]]; then
    echo "Usage: scripts/strip-exif.sh [--check]" >&2
    exit 2
fi

if ! command -v exiftool >/dev/null 2>&1; then
    echo "error: exiftool is not installed. Install libimage-exiftool-perl." >&2
    exit 1
fi

targets=()
[[ -d content ]] && targets+=(content)
[[ -d static ]] && targets+=(static)
if [[ ${#targets[@]} -eq 0 ]]; then
    echo "error: neither content/ nor static/ exists" >&2
    exit 1
fi

# Print a path for every image that still has EXIF, GPS, XMP, or IPTC.
# Exit 0 when something matched, 2 when every image was clean, 0 when
# there were no images at all (stdout empty).
metadata_hits() {
    exiftool -q -r \
        -ext jpg -ext jpeg -ext png -ext webp -ext heic -ext heif \
        -if '$EXIF:All or $XMP:All or $IPTC:All or $GPS:All' \
        -p '$FilePath' \
        "$@"
}

if [[ "$check_only" -eq 1 ]]; then
    status=0
    hits=$(metadata_hits "${targets[@]}") || status=$?
    if [[ -n "$hits" ]]; then
        echo "error: image metadata (EXIF/GPS/XMP/IPTC) is still present:" >&2
        printf '%s\n' "$hits" >&2
        echo "Remove it with: scripts/strip-exif.sh" >&2
        exit 1
    fi
    if [[ "$status" -ne 0 && "$status" -ne 2 ]]; then
        echo "error: exiftool failed while checking images (exit $status)" >&2
        exit 1
    fi
    exit 0
fi

rotate_with_pillow() {
    python3 - "$1" <<'PY'
import sys

path = sys.argv[1]
try:
    from PIL import Image, ImageOps
except ImportError:
    sys.stderr.write("error: python3-pil is required to rotate %s\n" % path)
    sys.exit(1)

image = Image.open(path)
fmt = image.format
image = ImageOps.exif_transpose(image) or image
temporary = path + ".orienting"
if fmt == "PNG":
    image.save(temporary, format="PNG")
elif fmt == "WEBP":
    image.save(temporary, format="WEBP", lossless=True)
else:
    sys.stderr.write("error: cannot bake orientation into %s (%s)\n" % (path, fmt))
    sys.exit(1)
import os
os.replace(temporary, path)
PY
}

apply_orientation() {
    local file="$1"
    local orient=""
    orient=$(exiftool -s3 -n -Orientation -- "$file" || true)
    if [[ -z "$orient" || "$orient" == "1" ]]; then
        return 0
    fi
    local ext="${file##*.}"
    ext=$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')
    case "$ext" in
        jpg|jpeg)
            if ! command -v exiftran >/dev/null 2>&1; then
                echo "error: $file has EXIF orientation $orient. Install exiftran to rotate the pixels without re-encoding." >&2
                return 1
            fi
            exiftran -a -i -- "$file" >/dev/null
            ;;
        png|webp)
            rotate_with_pillow "$file"
            ;;
        *)
            echo "error: $file has EXIF orientation $orient and this script cannot rotate ${ext} pixels. Export a JPEG and run scripts/compress-photos.py." >&2
            return 1
            ;;
    esac
}

found=0
while IFS= read -r -d '' file; do
    found=1
    status=0
    exiftool -q -if '$EXIF:All or $XMP:All or $IPTC:All or $GPS:All' -p '$FilePath' -- "$file" >/dev/null || status=$?
    if [[ "$status" -eq 2 ]]; then
        continue
    fi
    if [[ "$status" -ne 0 ]]; then
        echo "error: exiftool failed on $file (exit $status)" >&2
        exit 1
    fi
    apply_orientation "$file"
    exiftool -overwrite_original -EXIF:all= -XMP:all= -IPTC:all= -GPS:all= -- "$file" >/dev/null
    echo "stripped $file"
done < <(find "${targets[@]}" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.heic' -o -iname '*.heif' \) \
    -print0)

if [[ "$found" -eq 0 ]]; then
    echo "no images under content/ or static/"
fi
