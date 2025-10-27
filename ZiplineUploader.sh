#!/bin/bash

TOKEN=""

URL=""

SAVE_DIR=""

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

FILE_PATH="$SAVE_DIR/screenshot_${TIMESTAMP}.png"

spectacle -o ${FILE_PATH} -ribn

if [ ! -e ${FILE_PATH} ]; then
        exit 0
fi

RESPONSE=$(curl \
  -H "authorization: $TOKEN" $URL \
  -F file=@${FILE_PATH} \
  -H 'content-type: multipart/form-data')


RESPONSE_URL=$(echo "$RESPONSE" | jq -r '.files[0].url' 2>/dev/null || true)


if [[ -z "$RESPONSE_URL" || "$RESPONSE_URL" == "null" ]]; then
        notify-send --app-name="Zipline Uploader" "Uploaded failed." "${RESPONSE_URL}"
        echo ${RESPONSE_URL}
else
        echo -n "$RESPONSE_URL" | wl-copy
        echo "$RESPONSE_URL"
        notify-send --app-name="Zipline Uploader" -i ${FILE_PATH} "Uploaded successfully!" "<a href=\"${RESPONSE_URL}\">${RESPONSE_URL}</a>"
fi
