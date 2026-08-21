#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0

import argparse
import os
import subprocess

def pr_damon_commits(linux_dir, base, tip, damon_src_files):
    cmd = ['git', '-C', linux_dir, 'log', '%s..%s' % (base, tip), '--oneline',
           '--no-merges', '--']
    cmd += damon_src_files
    res = subprocess.run(cmd, capture_output=True, text=True)
    print(' '.join(cmd + [ ' | wc -l']))
    if res.returncode != 0:
        print('\ncmd failed\n')
        print(res.stderr)
        exit(1)
    print(len(res.stdout.strip().split('\n')))

def pr_contributors(base, tip, repo, lazybox_dir, is_linux):
    authors_py = os.path.join(
            lazybox_dir, 'version_control', 'authors.py')
    cmd = [authors_py, repo, '--since', base, '--until', tip,
           '--skip_merge_commits']
    if is_linux:
        cmd += ['--linux_subsystems', 'DAMON']
    res = subprocess.run(cmd, capture_output=True, text=True)
    print(' '.join(cmd))
    if res.returncode != 0:
        print('\ncmd failed\n')
        print(res.stderr)
        exit(1)
    print(res.stdout)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('linux_dir', help='path to the linux local repo')
    parser.add_argument(
            'linux_version_range', nargs=2,
            help='base and tip linux versions, e.g., v7.3-rc1 and v7.4-rc1')
    parser.add_argument('damo_dir', help='path to the damo local repo')
    parser.add_argument('lazybox_dir', help='path to the lazybox local repo')

    args = parser.parse_args()

    # This file is at scripts/release_news/
    script_dir = os.path.dirname(os.path.abspath(__file__))
    scripts_dir = os.path.dirname(script_dir)

    src_files_path = os.path.join(scripts_dir, 'damon_source_files')
    with open(src_files_path, 'r') as f:
        src_files = f.read().strip().split()

    linux_ver_base, linux_ver_tip = args.linux_version_range
    last_major_release = linux_ver_base[:-len('-rc1')]

    print('Statistics')
    pr_damon_commits(args.linux_dir, linux_ver_base, last_major_release,
                     src_files)
    print()
    pr_damon_commits(args.linux_dir, last_major_release, linux_ver_tip,
                     src_files)

    print()
    print('Contributors')
    pr_contributors(linux_ver_base, linux_ver_tip, args.linux_dir,
                    args.lazybox_dir, is_linux=True)

if __name__ == '__main__':
    main()
