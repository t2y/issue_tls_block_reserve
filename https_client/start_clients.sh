#!/bin/bash

CLIENT_NUM=${1:-10}
SLEEP_SECOND=${2:-1}
SERVER=${3:-"localhost"}
PORT=${4:-4443}

echo "start client to $CLIENT_NUM every $SLEEP_SECOND seconds"
echo "target server/port: $SERVER:$PORT"

for i in $(seq 1 $CLIENT_NUM)
do
    ./client_main -server $SERVER -port $PORT -insecure > /dev/null 2>&1 &
    echo "client $i is running"
    sleep $SLEEP_SECOND
done
