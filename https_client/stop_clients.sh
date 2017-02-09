#!/bin/bash

PROCESS="client_main"

killall "$PROCESS"
if [ $? -eq 0 ]; then
    echo "all $PROCESS processes are killed"
fi
