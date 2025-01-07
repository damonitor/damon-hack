#!/usr/bin/env python3

import argparse
import json
import sys

parser = argparse.ArgumentParser()
parser.add_argument('input')
args = parser.parse_args()

with open(args.input, 'r') as f:
    parsed = json.load(f)

daily_data = sorted(parsed['data'], key=lambda x: x['date'])

for i in range(29, len(daily_data)):
    date = daily_data[i]['date']
    monthly_downloads = sum([d['downloads'] for d in daily_data[i - 29:i + 1]])
    print('%s %d' % (date, monthly_downloads))
