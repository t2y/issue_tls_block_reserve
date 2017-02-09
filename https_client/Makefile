.PHONY: clean

GOPATH=$(shell pwd)
export GOPATH

build:
	go build -o client_main main.go

clean:
	rm -f client_main

test:
	go test .
