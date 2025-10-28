package packageg

import (
	"testing"
	"time"
)

func TestNewHTTPClient(t *testing.T) {
	client := NewHTTPClient("https://api.example.com", 10*time.Second)

	if client == nil {
		t.Fatal("Expected client to be created")
	}

	if client.baseURL != "https://api.example.com" {
		t.Errorf("Expected baseURL to be 'https://api.example.com', got '%s'", client.baseURL)
	}
}

func TestBuildURL(t *testing.T) {
	tests := []struct {
		base     string
		path     string
		expected string
	}{
		{"https://example.com", "/api/users", "https://example.com/api/users"},
		{"https://example.com/", "api/users", "https://example.com/api/users"},
		{"https://example.com", "api/users", "https://example.com/api/users"},
		{"https://example.com/", "/api/users", "https://example.com/api/users"},
	}

	for _, tt := range tests {
		result := BuildURL(tt.base, tt.path)
		if result != tt.expected {
			t.Errorf("BuildURL(%q, %q) = %q, want %q", tt.base, tt.path, result, tt.expected)
		}
	}
}

func TestParseQueryString(t *testing.T) {
	tests := []struct {
		query    string
		expected map[string]string
	}{
		{"?key1=value1&key2=value2", map[string]string{"key1": "value1", "key2": "value2"}},
		{"key1=value1&key2=value2", map[string]string{"key1": "value1", "key2": "value2"}},
		{"", map[string]string{}},
		{"key1=value1", map[string]string{"key1": "value1"}},
	}

	for _, tt := range tests {
		result := ParseQueryString(tt.query)

		if len(result) != len(tt.expected) {
			t.Errorf("ParseQueryString(%q) returned %d items, want %d", tt.query, len(result), len(tt.expected))
			continue
		}

		for key, expectedValue := range tt.expected {
			if result[key] != expectedValue {
				t.Errorf("ParseQueryString(%q)[%q] = %q, want %q", tt.query, key, result[key], expectedValue)
			}
		}
	}
}
