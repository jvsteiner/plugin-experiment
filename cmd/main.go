package main

import (
	"fmt"
	"log"
	"net/http"
	"plugin"
	"time"

	"github.com/gorilla/mux"
	fsnotify "gopkg.in/fsnotify.v1"
)

func main() {
	r := mux.NewRouter()

	r.HandleFunc("/", sayHello)

	svr := &http.Server{
		Handler:      r,
		Addr:         "127.0.0.1:8080",
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}

	go lookForChanges(svr)

	log.Fatal(svr.ListenAndServe())
}

func sayHello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello, this is the originally compiled code."))
}

func lookForChanges(svr *http.Server) {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		panic(err)
	}
	defer watcher.Close()
	watcher.Add("plug")
	watcher.Add("plug/1")
	fmt.Println("Events are received in a loop, see fsevents for details.")
	fmt.Println("When we recompile an existing plugin binary, a CHMOD event is usually the last")
	fmt.Println("that happens, so we will use that to trigger loading of the new module.")
	for {
		select {
		case event, ok := <-watcher.Events:
			if !ok {
				fmt.Println("watcher chan closed", err)
				return
			}
			fmt.Println("event received:", event)
			if event.Op == fsnotify.Write {
				fmt.Println("modified file:", event.Name)
			}
			if event.Op == fsnotify.Chmod {
				fmt.Println("switching handler")
				p, err := plugin.Open(event.Name)
				if err != nil {
					fmt.Println(err)
					continue
				}
				symbol, err := p.Lookup("Load")
				if err != nil {
					panic(err)
				}
				factory := symbol.(func() *mux.Router)
				svr.Handler = factory()
			}
		case err, ok := <-watcher.Errors:
			if !ok {
				fmt.Println("error chan closed", err)
				return
			}
			fmt.Println("error:", err)
		}
	}
}
