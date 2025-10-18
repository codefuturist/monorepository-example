package main

import (
	"fmt"
	"os"

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
		result := packageg.BuildURL(u.base, u.params)
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
	client := packageg.NewHTTPClient()
	if client == nil {
		return fmt.Errorf("failed to create HTTP client")
	}
	
	green := color.New(color.FgGreen)
	green.Println("✓ HTTPClient created successfully")
	green.Printf("✓ Client timeout: %v\n", client.Timeout)

	// Error handling test
	fmt.Println("\n" + color.CyanString("Error Handling Test:"))
	emptyURL := packageg.BuildURL("", nil)
	if emptyURL == "" {
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
