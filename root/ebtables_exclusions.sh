#!/bin/bash

for MAC in `cat mac_exclusions.txt`; do
	ebtables-legacy -t broute -I BROUTING 1 -s $MAC -j ACCEPT
	ebtables-legacy -t broute -I BROUTING 1 -d $MAC -j ACCEPT
done

