#!/bin/bash

API_KEY="AIzaSyCZKl8uDSn_xn9kRhOAGwZHuI45cWTr0m4"

API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

git add $1

REQ_TEXT="Just add Comments to the following code. Do not modify code. Also add Comments explaining each functional blocks:"

PROMPT_TEXT=$(cat "$1" | tr -d '\n' | sed 's/"/\\"/g')

JSON_PAYLOAD=$(printf '{
  "contents": [
    {
      "parts": [
        {
          "text": "%s %s"
        }]}]}' "$REQ_TEXT" "$PROMPT_TEXT")

curl -s -X POST "${API_URL}?key=${API_KEY}" -H 'Content-Type: application/json' -d "${JSON_PAYLOAD}" | jq -r '.candidates[0].content.parts[0].text' | sed '1d' | sed '$d' > $1
code $1
