#!/usr/bin/env python
# SPDX-License-Identifier: GPL-2.0

'''
Show total DAMON development statistics per reslease for all history, up to
given version.  E.g.,

$ time ../dhack/scripts/stat/release_history.py ./ ../lazybox/ 7 2 | ../lazybox/format_data/fmt_tbl.py --spaces 2
<version>  <nr_authors>  <nr_commits>  <nr_lines>
v7.2-rc1   14            109           3311
v7.1-rc1   9             77            1070
v7.0-rc1   12            75            1279
v6.19-rc1  10            85            1640
v6.18-rc1  13            59            864
v6.17-rc1  8             104           3785
v6.16-rc1  5             22            564
v6.15-rc1  7             68            1479
v6.14-rc1  8             61            4008
v6.13-rc1  10            23            132
v6.12-rc1  5             22            253
v6.11-rc1  5             39            1491
v6.10-rc1  2             23            495
v6.9-rc1   4             51            1480
v6.8-rc1   5             31            1259
v6.7-rc1   8             54            1109
v6.6-rc1   7             27            571
v6.5-rc1   6             25            635
v6.4-rc1   3             6             35
v6.3-rc1   11            46            1311
v6.2-rc1   5             36            3646
v6.1-rc1   15            73            1891
v6.0-rc1   8             24            1493
v5.19-rc1  7             28            1020
v5.18-rc1  8             36            4521
v5.17-rc1  6             44            1159
v5.16-rc1  10            47            2821
v5.15-rc1  1             11            3516

real    0m38.279s
user    0m27.892s
sys     0m10.071s
'''

import argparse
import os
import subprocess

def linux_version_before(major, minor):
    if [major, minor] == [5, 14]:
        return None, None

    if minor > 0:
        return major, minor - 1

    major_last_minors = {
            6: 19,
            5: 19,
            }
    if minor == 0:
        return major - 1, major_last_minors[major - 1]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('linux_dir', metavar='<dir>',
                        help='local linux repo')
    parser.add_argument('lazybox_dir', metavar='<dir>',
                        help='path to lazybox')
    parser.add_argument('last_version', nargs=2, type=int,
                        metavar=('<major version>', '<minor version>'),
                        help='last version to print history up to')
    args = parser.parse_args()

    authors_py = os.path.join(
            args.lazybox_dir, 'version_control', 'authors.py')
    major, minor = args.last_version
    print('<version> <nr_authors> <nr_commits> <nr_lines>')
    while True:
        before_major, before_minor = linux_version_before(major, minor)
        if before_major is None:
            break
        since = 'v%d.%d-rc1' % (before_major, before_minor)
        until = 'v%d.%d-rc1' % (major, minor)
        cmd = [authors_py, args.linux_dir, '--since=%s' % since, '--until=%s' %
               until, '--total_only', '--linux_subsystems', 'DAMON']
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            print('cmd fail: %s' % ' '.join(cmd))
            exit(1)
        # "# X authors, Y commits in total"
        fields = res.stdout.strip().split()
        nr_authors, nr_commits = fields[1], fields[3]

        cmd = [authors_py, args.linux_dir, '--since=%s' % since, '--until=%s' %
               until, '--total_only', '--linux_subsystems', 'DAMON',
               '--sortby', 'lines']
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            print('cmd fail: %s' % ' '.join(cmd))
            exit(1)
        fields = res.stdout.strip().split()
        nr_lines = fields[3]

        print('%s %s %s %s' % (until, nr_authors, nr_commits, nr_lines))
        major, minor = before_major, before_minor

if __name__ == '__main__':
    main()
