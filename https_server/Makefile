.PHONY: clean

GOPATH=$(shell pwd)
export GOPATH

all: build

create_certificate:
	if [ ! -e ssl ]; then \
		openssl genrsa 2048 > myself.key; \
		openssl req -new -key myself.key > myself.csr; \
		openssl x509 -days 3650 -req -signkey myself.key < myself.csr > myself.crt; \
		mkdir -p ssl/development; \
		mv myself.key myself.crt ssl/development; \
	else \
		echo "ssl directory is found"; \
	fi

build:
	go build -o server_main main.go

clean:
	rm -f server_main

test:
	go test .
