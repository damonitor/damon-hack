#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0

import argparse
import os
import subprocess

def linux_ver_date(linux_dir, version):
    cmd = ['git', '-C', linux_dir, 'log', version, '-1', '--pretty=%cd',
           '--date=iso-strict']
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print('%s fail\n', ' '.join(cmd))
        exit(1)
    return res.stdout.strip()

def pr_damon_changes(linux_dir, base, tip, damon_src_files):
    cmd = ['git', '-C', linux_dir, 'log', '%s..%s' % (base, tip), '--reverse',
           '--no-merges', '--pretty=%H', '--'] + damon_src_files
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print('%s fail\n', ' '.join(cmd))
        exit(1)
    commits = res.stdout.strip().split()
    to_skip = 0
    for commit in commits:
        if to_skip > 0:
            to_skip -= 1
            continue
        cmd = ['git', '-C', linux_dir, 'log', '-1', '--pretty=%B', commit]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            print('%s fail\n', ' '.join(cmd))
            exit(1)
        pars = [p.strip() for p in res.stdout.strip().split('\n\n')
                if p.strip() != '']
        if not pars[1].startswith('Patch series "'):
            print('Commit %s: %s' % (commit[:12], pars[0]))
            continue
        for par in pars[2:]:
            if not par.startswith('This patch (of '):
                continue
            if par.endswith(')'):
                suffix_len = 1
            elif par.endswith('):'):
                suffix_len = 2
            sz_series = int(par[len('This patch (of '):-suffix_len])
            to_skip = sz_series - 1
            break
        subject = ' '.join(pars[1].split('\n'))
        print('Commit %s: %s' % (commit[:12], subject))

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

def pr_damon_mail_traffic(linux_dir, base, tip):
    now_dir = os.getcwd()
    os.chdir(linux_dir)
    cmd = ['hkml', 'list', 'damon', '--since', base, '--until', tip,
           '--collapse', '--stat_only', '--stdout']
    res = subprocess.run(cmd, capture_output=True, text=True)
    print(' '.join(cmd))
    if res.returncode != 0:
        print('\ncmd failed\n')
        print(res.stderr)
        exit(1)
    print(res.stdout)
    os.chdir(now_dir)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('linux_dir', help='path to the linux local repo')
    parser.add_argument(
            'linux_version_range', nargs=2,
            help='base and tip linux versions, e.g., v7.3-rc1 and v7.4-rc1')
    parser.add_argument('damo_dir', help='path to the damo local repo')
    parser.add_argument('lazybox_dir', help='path to the lazybox local repo')
    parser.add_argument(
            '--categories', choices=[
                'time_range', 'changes', 'nr_commits', 'contributors',
                'mail_traffic'],
            default=[
                'time_range', 'changes', 'nr_commits', 'contributors',
                'mail_traffic'],
            help='cateogries to print out')

    args = parser.parse_args()

    # This file is at scripts/release_news/
    script_dir = os.path.dirname(os.path.abspath(__file__))
    scripts_dir = os.path.dirname(script_dir)

    src_files_path = os.path.join(scripts_dir, 'damon_source_files')
    with open(src_files_path, 'r') as f:
        src_files = f.read().strip().split()

    linux_ver_base, linux_ver_tip = args.linux_version_range
    last_major_release = linux_ver_base[:-len('-rc1')]

    time_base = linux_ver_date(args.linux_dir, linux_ver_base)
    time_tip = linux_ver_date(args.linux_dir, linux_ver_tip)
    if 'time_range' in args.categories:
        print('Time range')
        print('%s..%s' % (linux_ver_base, linux_ver_tip))
        print('%s to %s' % (time_base, time_tip))
        print()

    if 'changes' in args.categories:
        print('Changes in this merge window')
        pr_damon_changes(args.linux_dir, last_major_release, linux_ver_tip,
                         src_files)
        print()

    if 'nr_commits' in args.categories:
        print('Statistics')
        pr_damon_commits(args.linux_dir, linux_ver_base, last_major_release,
                         src_files)
        print()
        pr_damon_commits(args.linux_dir, last_major_release, linux_ver_tip,
                         src_files)
        print()

    if 'contributors' in args.categories:
        print('Contributors')
        pr_contributors(linux_ver_base, linux_ver_tip, args.linux_dir,
                        args.lazybox_dir, is_linux=True)
        print()
        pr_contributors(time_base, time_tip, args.damo_dir, args.lazybox_dir,
                        is_linux=False)

    if 'mail_traffic' in args.categories:
        print('Mailing List Traffic')
        pr_damon_mail_traffic(args.linux_dir, linux_ver_base, linux_ver_tip)

if __name__ == '__main__':
    main()
