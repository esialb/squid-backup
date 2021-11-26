#!/bin/bash

CMD="$1"
TIME="$2"

cd "$(dirname "$(readlink -f "$0")")"

if [ "$CMD" = "lock" ]; then
echo locking
at -M "$TIME" <<FFF
	touch /opt/filter/lockdown
	/opt/filter/apply.sh
FFF
else
echo unlocking
at -M "$TIME" <<FFF
	rm /opt/filter/lockdown
	/opt/filter/apply.sh
FFF
fi


