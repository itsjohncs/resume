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
find "$SCRIPT_DIR" -type f -name '*.sh' -exec shfmt -i=4 -sr -w {} +
npx prettier@3.3.2 --write "$SCRIPT_DIR/../index.htm"
echo "Done."
