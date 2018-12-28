package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/gorilla/mux"
)

var (
	TIME = time.Now().String()
)

func Load() *mux.Router {
	r := mux.NewRouter()
	r.HandleFunc("/", sayHello)
	return r
}

func sayHello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte(fmt.Sprintf("Hello from plugin version 2, initially run at: %s", TIME)))
}
