# Package I

Rust CLI utilities for data processing with colored terminal output.

## Features

- 📊 **Statistical Analysis**: Calculate average, median, min, max from numbers
- 📝 **Word Frequency**: Analyze word occurrence in text
- 📧 **Email Validation**: Simple email format validation
- 👤 **User Management**: Create and display user information with JSON support
- 🎨 **Colored Output**: Beautiful terminal output with colors
- 🚀 **CLI Interface**: Powerful command-line interface with subcommands

## Installation

Download the appropriate binary for your platform from the [releases page](https://github.com/codefuturist/monorepository-example/releases).

### Quick Install

```bash
# Linux/macOS
tar -xzf package-i-<platform>.tar.gz
sudo mv package-i-<platform> /usr/local/bin/package-i

# Windows
unzip package-i-<platform>.zip
# Add to PATH
```

## Usage

### Demo Mode

Run a demonstration of all features:

```bash
package-i demo
```

### Statistical Analysis

Calculate statistics from numbers:

```bash
package-i stats --numbers 10,20,30,40,50
```

Output:

```
Statistical Analysis
==================================================
  Average: 30.00
  Median: 30.00
  Min: 10.00
  Max: 50.00
  Count: 5
```

### Word Frequency Analysis

Analyze word frequency in text:

```bash
package-i frequency --text "rust is awesome rust makes systems programming fun"
```

Output:

```
Word Frequency Analysis
==================================================
  rust: 2
  is: 1
  awesome: 1
  makes: 1
  systems: 1
```

### Email Validation

Validate email addresses:

```bash
package-i email --address user@example.com
```

Output:

```
Email Validation
==================================================
  Email: user@example.com
  Status: Valid ✓
```

### User Management

Create and display user information:

```bash
package-i user --id 1 --name "John Doe" --email john@example.com --active true
```

Output:

```
User Information:
  ID: 1
  Name: John Doe
  Email: john@example.com
  Status: Active

JSON Representation:
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "active": true
}
```

### Help

Get help on available commands:

```bash
package-i --help
package-i stats --help
package-i frequency --help
```

## Development

### Building from Source

```bash
cd packages/package-i
cargo build --release
```

### Running Tests

```bash
cargo test
```

### Building for Multiple Platforms

Use the build script:

```bash
chmod +x build.sh
./build.sh
```

## Dependencies

- **serde + serde_json**: JSON serialization
- **colored**: Terminal color output
- **clap**: Command-line argument parsing
- **anyhow**: Error handling

## Platform Support

Native binaries for:

- Linux (x86_64, aarch64)
- macOS (x86_64 Intel, aarch64 Apple Silicon)
- Windows (x86_64, aarch64 ARM64)

## License

MIT
