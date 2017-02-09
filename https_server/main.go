package main

import (
	"io"
	"log"
	"net/http"
	_ "net/http/pprof"
	"os"
)

var MemProfileRate int = 1

func index(w http.ResponseWriter, r *http.Request) {
	file, err := os.Open("./index.html")
	if err != nil {
		log.Printf("err opening file: %s", err)
		return
	}
	defer file.Close()
	io.Copy(w, file)
	log.Println(r)
}

func main() {
	go func() {
		log.Println(http.ListenAndServe("localhost:6060", nil))
	}()

	http.HandleFunc("/", index)
	err := http.ListenAndServeTLS(":4443", "ssl/development/myself.crt", "ssl/development/myself.key", nil)
	if err != nil {
		log.Fatal("ListenAndServeTLS: ", err)
	}
}
