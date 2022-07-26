#!/bin/bash
for PRESET in /opt/filter/preset/*; do
  gcc -DPRESET=\"$PRESET\" preset.c -o /usr/lib/cgi-bin/$(basename $PRESET)
  chmod u+s /usr/lib/cgi-bin/$(basename $PRESET)
done

