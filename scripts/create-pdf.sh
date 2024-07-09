#!/usr/bin/env bash

set -ueo pipefail

CHECK=false

while [[ $# -gt 0 ]]; do
    case $1 in
    --check)
        CHECK=true
        shift
        ;;
    *)
        echo "USAGE: $0 [--check]" >&2
        exit 1
        ;;
    esac
done

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)"

TEMP_PDF="$(mktemp /tmp/resume.XXXXXX.pdf)"

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
    --headless --disable-gpu --print-to-pdf="$TEMP_PDF" \
    --virtual-time-budget=60000 \
    --no-pdf-header-footer "$SCRIPT_DIR/../index.htm"

if [[ $CHECK == true ]]; then
    trap 'rm "$TEMP_PDF"' EXIT

    RESUME_NUM_PAGES="$(identify -format '%n\n' "$SCRIPT_DIR/../resume.pdf" | head -n 1)"
    TEMP_PAGES="$(identify -format '%n\n' "$TEMP_PDF" | head -n 1)"
    if [[ $RESUME_NUM_PAGES -ne $TEMP_PAGES ]]; then
        echo "PDFs have different page counts." >&2
        exit 1
    fi

    for ((i = 0; i < TEMP_PAGES; ++i)); do
        if ! compare "${SCRIPT_DIR}/../resume.pdf[$i]" "${TEMP_PDF}[$i]" /dev/null; then
            echo "PDFs differ on page $i." >&2
            exit 1
        fi
    done
else
    mv "$TEMP_PDF" "$SCRIPT_DIR/../resume.pdf"
fi
