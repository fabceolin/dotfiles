#!/usr/bin/env python3
import argparse
import os
import fnmatch
import re

def find_files(path, patterns, exclude_patterns, maxdepth):
    def is_excluded_dir(directory, exclude_patterns):
        # Check if any of the exclude patterns match the directory path
        return any(re.match(pattern, directory) for pattern in exclude_patterns)

    base_depth = path.rstrip(os.path.sep).count(os.path.sep)
    
    for root, dirs, files in os.walk(path):
        # Check the depth
        current_depth = root.count(os.path.sep)
        if current_depth - base_depth >= maxdepth:
            del dirs[:]  # Do not descend further
        
        # Exclude directories based on patterns
        dirs[:] = [d for d in dirs if not is_excluded_dir(os.path.join(root, d), exclude_patterns)]
        
        for file in files:
            if any(fnmatch.fnmatch(file, pattern) for pattern in patterns):
                file_path = os.path.join(root, file)
                print(f"File: {file_path}")
                with open(file_path, 'r') as f:
                    content = f.read()
                    print(content)
                print()  # Add a blank line for separation

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Find files matching patterns and print their content.")
    parser.add_argument('path', nargs='?', default='.', help='Path to search for files (default: current directory)')
    parser.add_argument('patterns', metavar='PATTERN', type=str, nargs='+', help='Patterns to search for in file names.')
    parser.add_argument('-e', '--exclude', metavar='EXCLUDE_PATTERN', type=str, nargs='*', default=[], help='Patterns to exclude directories from the search.')
    parser.add_argument('--maxdepth', type=int, default=float('inf'), help='Maximum depth to search (default: no limit).')

    args = parser.parse_args()
    find_files(args.path, args.patterns, args.exclude, args.maxdepth)

