#!/bin/bash

BYPASSED="$(find bypass/ -not -type d -exec cat {} \; | sort | uniq | grep :)"
BLOCKED="$(find block/ -not -type d -exec cat {} \; | sort | uniq | grep :)"

for MAC in $BYPASSED; do
	grep -l -F $MAC `find devices/ -not -type d` | sed -r 's/^/BYPASS FILTERS:   /g'
done

for MAC in $BYPASSED; do
BLOCKED="$(echo $BLOCKED | sed -r "s/$MAC//g")"
done

for MAC in $BLOCKED; do
	grep -l -F $MAC `find devices/ -not -type d` | sed -r 's/^/BLOCK EVERYTHING: /g'
done
