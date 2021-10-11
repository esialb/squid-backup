#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"


rm -Rf /opt/squid-backup/*
cp -Rp /opt/filter /etc/network/interfaces /etc/squid /etc/squidguard /var/lib/squidguard /opt/squid-backup
cd /opt/squid-backup
git add .
git commit -m "$(date)"
git push

