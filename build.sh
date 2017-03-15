#!/bin/bash

echo "build client"
(cd https_client && make)

sleep 1
echo

echo "build server"
(cd https_server && make create_certificate build)
