#!/bin/bash

if [ ! -z "$DEBUG" ]; then set -x; set -e; fi

set -e

if [ ! -x "$(command -v trace-summary)" ]; then
    echo "This script requires trace-summary to be installed."
    echo "https://gist.github.com/ethack/6bd3a9551c02bbf8b404af0d2023114d#file-trace-summary-md"
    exit 1
fi

print_usage() {
    echo "Reads Zeek conn log from stdin and writes trace summaries to stdout.
Alternatively, you can pass in conn.log files as arguments (not gzipped).

Usage:
$(basename "$0") [-h|--help] [files...] [-- [OPTIONS]]

Any OPTIONS specified after -- will be passed directly to trace-summary. See below for available options."
    echo
    trace-summary --help
}

logs=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_usage
            exit 0
        ;;
        --)
            shift
            break
        ;;
        *)
            logs+=("$1")
            shift
        ;;
    esac
done

if [ -t 0 ] && [ ${#logs[@]} -eq 0 ]; then
    # stdin is not attached and no logs specified, print help
    print_usage
    exit 0
fi

# trace-summary python script wouldn't read from stdin so instead write to actual files

networks=$(mktemp)
trap "rm -f \"$networks\"" EXIT
cat << EOF > "$networks"
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
EOF

# no logs specified, assume reading from stdin
if [ ${#logs[@]} -eq 0 ]; then
    log=$(mktemp)
    trap "rm -f \"$log\"" EXIT
    cat > "$log"
    logs=("$log")
fi

echo Connections:
echo ============
trace-summary "$@" --conn-summaries --external --local-nets "$networks" "${logs[@]}" | head -15

echo Bytes:
echo ======
trace-summary "$@" --bytes --conn-summaries --external --local-nets "$networks" "${logs[@]}" | head -15
