#!/usr/bin/env bash

set -ueo pipefail

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)"

if [[ $# -ne 0 ]]; then
    echo "USAGE: $0" >&2
    exit 1
fi

set -x
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
    --headless --disable-gpu --print-to-pdf="$SCRIPT_DIR/../resume.pdf" \
    --no-pdf-header-footer ./index.htm
echo "Done."
