import argparse
import os
import fnmatch

def find_files(path, patterns, exclude_dirs):
    exclude_dirs_set = set(os.path.abspath(d) for d in exclude_dirs)
    
    for root, dirs, files in os.walk(path):
        # Exclude directories
        dirs[:] = [d for d in dirs if os.path.abspath(os.path.join(root, d)) not in exclude_dirs_set]
        
        for file in files:
            for pattern in patterns:
                if fnmatch.fnmatch(file, pattern):
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
    parser.add_argument('--exclude', metavar='EXCLUDE_DIR', type=str, nargs='*', default=[], help='Directories to exclude from the search.')

    args = parser.parse_args()
    find_files(args.path, args.patterns, args.exclude)

