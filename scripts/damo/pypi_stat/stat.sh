#!/bin/bash

bindir=$(dirname "$0")

filename=$(date +%Y-%m-%d.json)
"$bindir/__download_stat.sh" "$filename"
"$bindir/__stat.py" "$filename"
