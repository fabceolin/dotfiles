docker images | python3 -c "import sys; from humanfriendly import parse_size; print('\n'.join(sorted(sys.stdin.read().strip().split('\n')[1:], key=lambda x: parse_size(x.split()[6]))))"

