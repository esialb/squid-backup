#!/bin/bash

BYPASSED="$(find bypass/ -not -type d -exec cat {} \; | sort | uniq | grep :)"
for MAC in $BYPASSED; do
	grep -l -F $MAC `find devices/ -not -type d`
done

