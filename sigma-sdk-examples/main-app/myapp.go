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
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
}

func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":3306", nil)
}
