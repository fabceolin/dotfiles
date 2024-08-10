#!/usr/bin/env python3
import argparse
import os
import fnmatch
import re

def find_files(path, include_patterns, exclude_patterns, maxdepth):
    def is_excluded_dir(directory, exclude_patterns):
        return any(re.search(pattern, directory) for pattern in exclude_patterns)

    base_depth = path.rstrip(os.path.sep).count(os.path.sep)

    for root, dirs, files in os.walk(path):
        current_depth = root.count(os.path.sep)
        if current_depth - base_depth >= maxdepth:
            del dirs[:]  # Do not descend further

        dirs[:] = [d for d in dirs if not is_excluded_dir(os.path.join(root, d), exclude_patterns)]

        for file in files:
            if any(fnmatch.fnmatch(file, pattern) for pattern in include_patterns):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', errors='ignore') as f:  # Ignore encoding errors
                        content = f.read()
                        print(f"File: {file_path}\n{content}\n")
                except Exception as e:  # Catch all exceptions and print an error message
                    print(f"Error reading file {file_path}: {str(e)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Find files matching patterns and print their content.")
    parser.add_argument('path', nargs='?', default='.', help='Path to search for files (default: current directory)')
    parser.add_argument('-i', '--include', metavar='INCLUDE_PATTERN', type=str, nargs='+', required=True, help='Patterns to include files in the search.')
    parser.add_argument('-e', '--exclude', metavar='EXCLUDE_PATTERN', type=str, nargs='+', default=[], help='Patterns to exclude directories from the search.')
    parser.add_argument('--maxdepth', type=int, default=float('inf'), help='Maximum depth to search (default: no limit).')

    args = parser.parse_args()
    find_files(args.path, args.include, args.exclude, args.maxdepth)
