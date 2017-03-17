#!/bin/bash

SERVER=${1:-"localhost"}
PORT=${2:-44443}

SLEEP_SECOND=3

echo "target server/port: $SERVER:$PORT"

while true;
do
    echo "run date: $(date +"%Y-%m-%d %H:%M:%S")"
    echo "connection: $(lsof -i TCP:$PORT | wc -l)"

    # profile
    go tool pprof -top -inuse_space http://$SERVER:6060/debug/pprof/heap
    #go tool pprof -tree -inuse_space http://$SERVER:6060/debug/pprof/heap

    echo "sleeping $SLEEP_SECOND seconds ..."
    sleep $SLEEP_SECOND
    echo "===================================================================="
done
