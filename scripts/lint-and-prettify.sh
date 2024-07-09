#!/usr/bin/env bash

set -ueo pipefail

DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
    --dry-run)
        DRY_RUN=true
        shift
        ;;
    *)
        echo "USAGE: $0 [--dry-run]" >&2
        exit 1
        ;;
    esac
done

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)"

if [[ $DRY_RUN == true ]]; then
    set -x
    find "$SCRIPT_DIR" -type f -name '*.sh' -exec shfmt -i=4 -sr -l {} +
    npx prettier@3.3.2 --check "$SCRIPT_DIR/../index.htm"
else
    set -x
    find "$SCRIPT_DIR" -type f -name '*.sh' -exec shfmt -i=4 -sr -w {} +
    npx prettier@3.3.2 --write "$SCRIPT_DIR/../index.htm"
fi

find "$SCRIPT_DIR" -type f -name '*.sh' -exec shellcheck --shell=bash -x {} +

echo "Done."
