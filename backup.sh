#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"

OLDIFS="$IFS"
IFS="\n"
rm -Rf ../squid-backup/*
cp -Rp * ../squid-backup
cd ../squid-backup
git add .
git commit -m "$(date)"
git push

