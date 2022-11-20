#!/usr/bin/env python3

import os

def main():
    maintainers_file = 'MAINTAINERS'
    if not os.path.isfile(maintainers_file):
        print('cannot find %s' % maintainers_file)
        exit(1)
    with open(maintainers_file, 'r') as f:
        content = f.read()

    for paragraph in content.split('\n\n'):
        lines = [l.strip() for l in paragraph.split('\n')]
        if lines[0] != 'DATA ACCESS MONITOR':
            continue
        for line in lines:
            if not line.startswith('F:\t'):
                continue
            print(line.split()[1])

if __name__ == '__main__':
    main()
