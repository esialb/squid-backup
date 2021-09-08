#!/bin/bash

for FILE in \
	/root/*.sh \
	/root/*.txt \
	/etc/squid/*.conf \
	/etc/network/interfaces \
	; do
	mkdir -p "squid-backup/$(dirname $FILE)"
	cp "$FILE" "squid-backup/$FILE"
done

cd squid-backup
git add .
git commit -m "$(date)"
git push

