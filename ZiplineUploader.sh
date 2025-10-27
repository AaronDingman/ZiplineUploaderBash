#!/bin/bash

MONITORED_DIR=""
ZIPLINE_URL=""
AUTH_TOKEN=""

COMMAND_TO_RUN="echo 'New file created: $FILE_PATH'"

inotifywait -m -e create --format '%w%f' "$MONITORED_DIR" | while read FILE_PATH; do

echo "Detected new file: $FILE_PATH"

#chmod 777 $FILE_PATH

echo $FILE_PATH

if [[ ! -f "$FILE_PATH" ]]; then
	echo "Error: File not found: $FILE_PATH"
	exit 1
fi

for i in {1..10}; do
	if [[ -s "$FILE_PATH" ]]; then
		break
	fi
	echo "Waiting for file to finish writing..."
	sleep 0.2
done

if [[ ! -s "$FILE_PATH" ]]; then
	echo "Error: File is empty after waiting: $FILE_PATH"
	exit 1
fi

MIME_TYPE=$(file --mime-type -b "$FILE_PATH")
if [[ "$MIME_TYPE" == "inode/x-empty" ]]; then
	case "${FILE_PATH##*.}" in
		png) MIME_TYPE="image/png" ;;
		jpg|jpeg) MIME_TYPE="image/jpeg" ;;
		gif) MIME_TYPE="image/gif" ;;
		webp) MIME_TYPE="image/webp" ;;
		*) MIME_TYPE="application/octet-stream" ;;
	esac
fi

echo "Uploading '$FILE_PATH' ($MIME_TYPE)..."

RESPONSE=$(curl -sS \
	-H "authorization: $AUTH_TOKEN" \
	-F "file=@${FILE_PATH};type=${MIME_TYPE}" \
	"$ZIPLINE_URL")

URL=$(echo "$RESPONSE" | jq -r '.files[0].url' 2>/dev/null || true)

if [[ -z "$URL" || "$URL" == "null" ]]; then
	notify-send --app-name="Zipline Uploader" "Uploaded failed." "${RESPONSE}"
	exit 1
fi

echo -n "$URL" | wl-copy
notify-send --app-name="Zipline Uploader" -i ${FILE_PATH} "Uploaded successfully!" "<a href=\"${URL}\">${URL}</a>"
done
