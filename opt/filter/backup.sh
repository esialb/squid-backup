#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"

for FILE in \
	$(find /opt/filter/ -not -type d) \
	/etc/squid/*.conf /etc/squid/*.txt \
	/etc/network/interfaces \
	/var/lib/squidguard/db/kids/domains \
	; do
	mkdir -p "../squid-backup/$(dirname $FILE)"
	cp "$FILE" "../squid-backup/$FILE"
done

cd ../squid-backup
git add .
git commit -m "$(date)"
git push

