.PHONY: clean

GOPATH=$(shell pwd)
export GOPATH

HOSTNAME=$(shell hostname)
TLS_COUNTRY=JP
TLS_SUBJ="/C=$(TLS_COUNTRY)/CN=$(HOSTNAME)/O=self-signed"
TLS_KEY=myself.key
TLS_CRT=myself.crt

all: build

create_certificate:
	openssl req -batch -new -x509 -newkey rsa:2048 -nodes -sha256 -days 3650 -subj $(TLS_SUBJ) -keyout $(TLS_KEY) -out $(TLS_CRT)

build:
	go build -o server_main main.go

clean:
	rm -f server_main

test:
	go test .
