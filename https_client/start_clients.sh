#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 total_number"
    exit 0
fi

CLIENT_NUM="$1"
for i in $(seq 1 $CLIENT_NUM)
do
    ./client_main -insecure > /dev/null 2>&1 &
    echo "client $i is running"
done
