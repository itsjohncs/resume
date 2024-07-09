#!/bin/bash

set -ueo pipefail

# Check if the correct number of arguments are passed
if [ "$#" -ne 0 ]; then
    echo "Usage: $0"
    exit 1
fi

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

PROMPT="I'm a Software Engineer looking for a new full-stack software \
engineering role. I've written my resume as an HTML webpage. Please flag any \
spelling and grammar errors. You may also flag very egregious wording problems \
but I have other checks in place to handle general flow, so focus on spelling \
and grammar.

To flag a problem, print out where it is, the line, and use text to point out \
the problematic area. Then describe what needs to change. For example:

\`\`\`
Under the job Shmeppy:
    Founded the modstly successful SaaS product
                ^^^^^^^
    Spelling Error: Should be spelled \"modestly\".
\`\`\`

If you do not find any problems, print only:

\`\`\`
No errors found.
\`\`\`

Everything that follows is the resume's HTML:

"

# shellcheck source=SCRIPTDIR/../secrets.env
source "$SCRIPT_DIR/../secrets.env"

OPEN_AI_REQUEST_BODY=$(jq -n \
    --arg prompt "$PROMPT" \
    --arg html "$ADJUSTED_HTML_CONTENT" \
    '{
      "model": "gpt-3.5-turbo",
      "messages": [{"role": "user", "content": [
        {"type": "text", "text": $prompt},
        {"type": "text", "text": $html}
      ]}],
      "temperature": 0
    }')

echo "Sending request to ChatGPT."
RESPONSE=$(curl https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPEN_AI_RESUME_PROJECT_KEY" \
    -d "$OPEN_AI_REQUEST_BODY")

FINISH_REASON=$(jq --raw-output .choices[0].finish_reason <<< "$RESPONSE")
if [[ $FINISH_REASON != "stop" ]]; then
    echo "Unexpected finish reason: $FINISH_REASON. Full response:" >&2
    echo "$RESPONSE" >&2
    exit 1
fi

RESPONSE_CONTENT=$(jq --raw-output .choices[0].message.content <<< "$RESPONSE")
if [[ $RESPONSE_CONTENT != "No errors found." ]]; then
    echo "$RESPONSE_CONTENT" >&2
    exit 1
fi
