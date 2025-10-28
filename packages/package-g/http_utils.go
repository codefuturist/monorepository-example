// Package packageg provides HTTP utility functions
package packageg

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// Version is the current version of package-g
const Version = "1.0.0"

// HTTPClient represents a simple HTTP client
type HTTPClient struct {
	client  *http.Client
	baseURL string
}

// NewHTTPClient creates a new HTTP client
func NewHTTPClient(baseURL string, timeout time.Duration) *HTTPClient {
	return &HTTPClient{
		client: &http.Client{
			Timeout: timeout,
		},
		baseURL: strings.TrimRight(baseURL, "/"),
	}
}

// Get performs a GET request
func (c *HTTPClient) Get(path string) (*http.Response, error) {
	url := fmt.Sprintf("%s/%s", c.baseURL, strings.TrimLeft(path, "/"))
	return c.client.Get(url)
}

// Post performs a POST request with JSON body
func (c *HTTPClient) Post(path string, body interface{}) (*http.Response, error) {
	url := fmt.Sprintf("%s/%s", c.baseURL, strings.TrimLeft(path, "/"))

	jsonData, err := json.Marshal(body)
	if err != nil {
		return nil, err
	}

	return c.client.Post(url, "application/json", strings.NewReader(string(jsonData)))
}

// FetchJSON fetches and decodes JSON from a URL
func (c *HTTPClient) FetchJSON(path string, target interface{}) error {
	resp, err := c.Get(path)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	return json.Unmarshal(body, target)
}

// BuildURL constructs a full URL from base and path
func BuildURL(base, path string) string {
	base = strings.TrimRight(base, "/")
	path = strings.TrimLeft(path, "/")
	return fmt.Sprintf("%s/%s", base, path)
}

// ParseQueryString parses a query string into a map
func ParseQueryString(query string) map[string]string {
	result := make(map[string]string)

	query = strings.TrimPrefix(query, "?")
	if query == "" {
		return result
	}

	pairs := strings.Split(query, "&")
	for _, pair := range pairs {
		parts := strings.SplitN(pair, "=", 2)
		if len(parts) == 2 {
			result[parts[0]] = parts[1]
		}
	}

	return result
}
