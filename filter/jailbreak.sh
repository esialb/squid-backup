#!/bin/bash

TIME="$1"

cd "$(dirname "$(readlink -f "$0")")"

TARGET="/opt/filter/jailbreak"
touch "$TARGET"
at -M "$TIME" <<FFF
	rm "$TARGET"
	/opt/filter/apply.sh
FFF

./apply.sh

