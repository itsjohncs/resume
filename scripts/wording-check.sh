#!/bin/bash

set -ueo pipefail

BROAD=false

while [[ $# -gt 0 ]]; do
    case $1 in
    --broad)
        BROAD=true
        shift
        ;;
    *)
        echo "USAGE: $0 [--broad]" >&2
        exit 1
        ;;
    esac
done

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)"

HTML_FILE="$SCRIPT_DIR/../index.htm"

# Extract content between <body> and </body> tags
HTML_CONTENT=$(sed -n '/<body>/,/<\/body>/p' "$HTML_FILE" | sed '1d;$d')

# Calculate the indentation level of the first non-empty line
INDENT_LEVEL=$(echo "$HTML_CONTENT" | sed '/^$/d' | head -n 1 | awk '{print match($0, /[^ ]/)-1}')

# Unindent
ADJUSTED_HTML_CONTENT=$(echo "$HTML_CONTENT" | sed -r "s/^ {0,$INDENT_LEVEL}//")

if [[ $BROAD == "true" ]]; then
    PROMPT_FILE="$SCRIPT_DIR/openai/broad-prompt.md"
    TEMPERATURE=1
else
    PROMPT_FILE="$SCRIPT_DIR/openai/spellcheck-prompt.md"
    TEMPERATURE=0
fi
PROMPT=$(cat < "$PROMPT_FILE")

# shellcheck source=SCRIPTDIR/openai/secrets.env
source "$SCRIPT_DIR/openai/secrets.env"

OPEN_AI_REQUEST_BODY=$(jq -n \
    --argjson temperature "$TEMPERATURE" \
    --arg prompt "$PROMPT" \
    --arg html "$ADJUSTED_HTML_CONTENT" \
    '{
      "model": "gpt-4o",
      "messages": [
        {"role": "system", "content": $prompt},
        {"role": "user", "content": $html}
      ],
      "temperature": $temperature
    }')

echo "Sending request to ChatGPT."
RESPONSE=$(curl https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPEN_AI_RESUME_PROJECT_KEY" \
    -d "$OPEN_AI_REQUEST_BODY" \
    --no-progress-meter)

FINISH_REASON=$(jq --raw-output .choices[0].finish_reason <<< "$RESPONSE")
if [[ $FINISH_REASON != "stop" ]]; then
    echo "Unexpected finish reason: $FINISH_REASON. Full response:" >&2
    echo "$RESPONSE" >&2
    exit 1
fi

RESPONSE_CONTENT=$(jq --raw-output .choices[0].message.content <<< "$RESPONSE")
if [[ $BROAD == "true" ]]; then
    glow <<< "$RESPONSE_CONTENT"
elif [[ $RESPONSE_CONTENT != "No errors found." ]]; then
    echo "$RESPONSE_CONTENT" >&2
    exit 1
fi
