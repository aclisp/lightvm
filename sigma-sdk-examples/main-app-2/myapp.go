// Example from https://golang.org/doc/articles/wiki/
//
// If you run this program and access the URL:
//     http://localhost:3306/monkeys
// the program would present a page containing:
//     Hi there, I love monkeys!
//
// Compile with `go build myapp.go`

package main

import (
	"fmt"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()
	fmt.Fprintf(w, "Reply from %q, request is %q sent by %q\n", hostname, r.URL.Path[1:], r.RemoteAddr)
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":3306", nil)
}
