package main

import (
	"net/http"
	"testing"
)

func TestHealthCheckHandler(t *testing.T) {
	status, body := HealthCheckHandler()
	if status != http.StatusOK {
		t.Errorf("Expected status 200, got %d", status)
	}
	if body != "OK" {
		t.Errorf("Expected body OK, got %s", body)
	}
}
