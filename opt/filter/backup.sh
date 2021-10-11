#!/bin/bash

for FILE in \
	/opt/filter/*.sh \
	/opt/filter/filter@.service \
	/etc/squid/*.conf /etc/squid/*.txt \
	/etc/network/interfaces \
	/var/lib/squidguard/db/kids/domains \
	; do
	mkdir -p "squid-backup/$(dirname $FILE)"
	cp "$FILE" "squid-backup/$FILE"
done

cd squid-backup
git add .
git commit -m "$(date)"
git push

