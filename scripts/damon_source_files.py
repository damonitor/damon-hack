#!/usr/bin/env python3

import os

# list of source files that manually updated.
# updated on 2025-07-11.
manually_updated_files = [
        'Documentation/ABI/testing/sysfs-kernel-mm-damon',
        'Documentation/admin-guide/mm/damon/',
        'Documentation/mm/damon/',
        'include/linux/damon.h',
        'include/trace/events/damon.h',
        'mm/damon/',
        'samples/damon/',
        'tools/testing/selftests/damon/',
]

def main():
    maintainers_file = 'MAINTAINERS'
    if not os.path.isfile(maintainers_file):
        print('cannot find %s' % maintainers_file)
        exit(1)
    with open(maintainers_file, 'r') as f:
        content = f.read()

    files = manually_updated_files
    for paragraph in content.split('\n\n'):
        lines = [l.strip() for l in paragraph.split('\n')]
        if lines[0] != 'DATA ACCESS MONITOR':
            continue
        for line in lines:
            if not line.startswith('F:\t'):
                continue
            files.append(line.split()[1])
    for file in set(files):
        print(file)

if __name__ == '__main__':
    main()
