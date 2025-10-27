#!/bin/bash

TOKEN=""
URL=""

spectacle -o /tmp/screenshot.png -ribn

RESPONSE=$(curl \
  -H "authorization: $TOKEN" $URL \
  -F file=@/tmp/screenshot.png \
  -H 'content-type: multipart/form-data')


RESPONSE_URL=$(echo "$RESPONSE" | jq -r '.files[0].url' 2>/dev/null || true)


if [[ -z "$RESPONSE_URL" || "$RESPONSE_URL" == "null" ]]; then
        notify-send --app-name="Zipline Uploader" "Uploaded failed." "${RESPONSE_URL}"
        echo ${RESPONSE_URL}
else
        echo -n "$RESPONSE_URL" | wl-copy
        echo "$RESPONSE_URL"
        notify-send --app-name="Zipline Uploader" -i /tmp/screenshot.png "Uploaded successfully!" "<a href=\"${RESPONSE_URL}\">${RESPONSE_URL}</a>"
fi
