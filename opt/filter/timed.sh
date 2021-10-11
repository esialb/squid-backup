#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"

TIME="$1"
shift

for DEVICE in "$@"; do
	TARGET="/opt/filter/bypass/timed/$(date '+%F-%H-%M-%S')_$TIME_$(basename "$DEVICE")"
	cp "$DEVICE" "$TARGET"
	at -M "$TIME" <<FFF
	rm "$TARGET"
	/opt/filter/apply.sh
FFF
done
./apply.sh

