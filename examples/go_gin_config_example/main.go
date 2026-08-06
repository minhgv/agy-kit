package main

import (
	"net/http"
)

func HealthCheckHandler() (int, string) {
	return http.StatusOK, "OK"
}

func main() {
	println("Starting Go Gin API Server...")
}
