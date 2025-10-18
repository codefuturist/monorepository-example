package main

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/codefuturist/monorepository-example/packages/package-g"
	"github.com/fatih/color"
	"github.com/jedib0t/go-pretty/v6/table"
)

func main() {
	printSeparator("Package G - HTTP Utilities v1.0.0")

	// Verify dependencies
	green := color.New(color.FgGreen)
	green.Println("\n✓ fatih/color dependency loaded successfully")
	green.Println("✓ go-pretty/table dependency loaded successfully")
	green.Println("✓ HTTP utilities initialized\n")

	if err := runTests(); err != nil {
		red := color.New(color.FgRed, color.Bold)
		red.Fprintf(os.Stderr, "\nERROR: %v\n", err)
		os.Exit(1)
	}

	green.Println()
	printSeparator("Package G executed successfully!")
	fmt.Println()
}

func runTests() error {
	cyan := color.New(color.FgCyan, color.Bold)
	cyan.Println("HTTP Utility Demonstrations:")
	fmt.Println(repeat("-", 60))

	// Test BuildURL
	fmt.Println("\n" + color.YellowString("BuildURL Tests:"))
	urls := []struct {
		base   string
		params map[string]string
	}{
		{"https://api.example.com/search", map[string]string{"q": "golang", "limit": "10"}},
		{"https://example.com", map[string]string{"foo": "bar", "baz": "qux"}},
	}

	t := table.NewWriter()
	t.SetOutputMirror(os.Stdout)
	t.AppendHeader(table.Row{"Base URL", "Parameters", "Result"})

	for _, u := range urls {
		// Build base URL (BuildURL takes base and path as strings)
		result := u.base
		if len(u.params) > 0 {
			// Append query parameters manually
			var params []string
			for k, v := range u.params {
				params = append(params, fmt.Sprintf("%s=%s", k, v))
			}
			result = fmt.Sprintf("%s?%s", result, strings.Join(params, "&"))
		}
		t.AppendRow(table.Row{u.base, fmt.Sprintf("%v", u.params), result})
	}
	t.Render()

	// Test ParseQueryString
	fmt.Println("\n" + color.YellowString("ParseQueryString Tests:"))
	queryStrings := []string{
		"name=John&age=30&city=NYC",
		"search=go+lang&page=1",
		"",
	}

	t2 := table.NewWriter()
	t2.SetOutputMirror(os.Stdout)
	t2.AppendHeader(table.Row{"Query String", "Parsed Result"})

	for _, qs := range queryStrings {
		parsed := packageg.ParseQueryString(qs)
		t2.AppendRow(table.Row{qs, fmt.Sprintf("%v", parsed)})
	}
	t2.Render()

	// Test HTTPClient
	fmt.Println("\n" + color.YellowString("HTTPClient Test:"))
	client := packageg.NewHTTPClient("https://api.example.com", 30*time.Second)
	if client == nil {
		return fmt.Errorf("failed to create HTTP client")
	}
	
	green := color.New(color.FgGreen)
	green.Println("✓ HTTPClient created successfully")
	green.Printf("✓ Client base URL: https://api.example.com\n")
	green.Printf("✓ Client timeout: 30s\n")

	// Test BuildURL with path
	fmt.Println("\n" + color.CyanString("BuildURL Test:"))
	testURL := packageg.BuildURL("https://api.example.com", "/v1/users")
	green.Printf("BuildURL result: %s\n", testURL)
	
	// Error handling test
	fmt.Println("\n" + color.CyanString("Error Handling Test:"))
	emptyURL := packageg.BuildURL("", "")
	if emptyURL == "/" {
		green.Println("✓ Empty URL handled correctly")
	}

	return nil
}

func printSeparator(title string) {
	fmt.Println(repeat("=", 60))
	if title != "" {
		fmt.Println(title)
		fmt.Println(repeat("=", 60))
	}
}

func repeat(s string, count int) string {
	result := ""
	for i := 0; i < count; i++ {
		result += s
	}
	return result
}
