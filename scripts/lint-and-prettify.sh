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

mapfile -d "" -t BASH_FILES < <(
    find "$SCRIPT_DIR" -type f -name "*.sh" -print0
    find "$SCRIPT_DIR/../git-hooks" -type f -print0
)

if [[ $CHECK == true ]]; then
    set -x
    shfmt -i=4 -sr -l "${BASH_FILES[@]}"
    npx prettier@3.3.2 --check "$SCRIPT_DIR/../index.htm"
else
    set -x
    shfmt -i=4 -sr -w "${BASH_FILES[@]}"
    npx prettier@3.3.2 --write "$SCRIPT_DIR/../index.htm"
fi

shellcheck --shell=bash -x "${BASH_FILES[@]}"
