#!/bin/bash

SERVER="localhost"
PORT=4443
SLEEP_SECOND=20

while true;
do
    echo "run date: $(date +"%Y-%m-%d %H:%M:%S")"
    echo "connection: $(lsof -i TCP:$PORT | wc -l)"

    # profile
    go tool pprof -text -inuse_space http://$SERVER:6060/debug/pprof/heap
    go tool pprof -tree -inuse_space http://$SERVER:6060/debug/pprof/heap

    echo "sleeping $SLEEP_SECOND seconds ..."
    sleep $SLEEP_SECOND
    echo "===================================================================="
done
