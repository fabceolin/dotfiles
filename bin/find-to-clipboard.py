#!/usr/bin/env python3
import argparse
import os
import fnmatch

def find_files(paths, include_patterns, exclude_patterns, maxdepth):
    included_files = set()

    # First, process include patterns that are paths to existing files
    for pattern in include_patterns[:]:
        if os.path.isfile(pattern):
            included_files.add(os.path.abspath(pattern))
            include_patterns.remove(pattern)

    for path in paths:
        base_depth = os.path.abspath(path).rstrip(os.path.sep).count(os.path.sep)
        for root, dirs, files in os.walk(path):
            current_depth = os.path.abspath(root).count(os.path.sep)
            if current_depth - base_depth >= maxdepth:
                del dirs[:]  # Do not descend further

            # Exclude directories that match exclude patterns
            dirs[:] = [
                d for d in dirs
                if not any(
                    fnmatch.fnmatch(os.path.relpath(os.path.join(root, d), path), pattern)
                    for pattern in exclude_patterns
                )
            ]

            for file in files:
                file_path = os.path.join(root, file)
                rel_file_path = os.path.relpath(file_path, path)

                # Skip files that match exclude patterns
                if any(fnmatch.fnmatch(rel_file_path, pattern) for pattern in exclude_patterns):
                    continue

                # Include files that match include patterns (match against relative path)
                if any(fnmatch.fnmatch(rel_file_path, pattern) for pattern in include_patterns):
                    included_files.add(os.path.abspath(file_path))

    # Process the included files
    for file_path in included_files:
        rel_file_path = os.path.relpath(file_path)
        try:
            with open(file_path, 'r', errors='ignore') as f:  # Ignore encoding errors
                content = f.read()
                print(f"File: {rel_file_path}\n{content}\n")
        except Exception as e:
            print(f"Error reading file {rel_file_path}: {str(e)}")

if __name__ == "__main__":
        parser = argparse.ArgumentParser(description="Find files matching patterns and print their content.")
        parser.add_argument('paths', nargs='*', default=['.'], help='Paths to search for files (default: current directory)')
        parser.add_argument('-i', '--include', metavar='INCLUDE_PATTERN', type=str, nargs='+', required=True, help='Patterns to include files in the search.')
        parser.add_argument('-e', '--exclude', metavar='EXCLUDE_PATTERN', type=str, nargs='+', default=[], help='Patterns to exclude files and directories from the search.')
        parser.add_argument('--maxdepth', type=int, default=float('inf'), help='Maximum depth to search (default: no limit).')

        args = parser.parse_args()
        find_files(args.paths, args.include, args.exclude, args.maxdepth)

