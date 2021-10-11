#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"

for MAC in `cat filter-disabled/*`; do
	ebtables-legacy -t broute -I BROUTING 1 -s $MAC -j ACCEPT
	ebtables-legacy -t broute -I BROUTING 1 -d $MAC -j ACCEPT
done

