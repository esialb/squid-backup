#!/bin/bash

TIME="$1"
shift
DEVICES="$(cat "$@")"

cd "$(dirname "$(readlink -f "$0")")"

TARGET="/opt/filter/unblock/timed/$(date '+%F-%H-%M-%S')_$TIME"
echo "$DEVICES" > "$TARGET"
at -M "$TIME" <<FFF
	rm "$TARGET"
	/opt/filter/apply.sh
FFF

./apply.sh

