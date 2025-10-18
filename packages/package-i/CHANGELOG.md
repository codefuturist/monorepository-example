# Changelog - Package I

All notable changes to package-i will be documented in this file.

## [1.0.0] - 2025-10-18

### Added

- Initial release of package-i
- Statistical analysis utilities (average, median, min, max)
- Word frequency analysis
- Email validation
- User data structure with JSON serialization
- CLI with subcommands using clap
- Colored terminal output
- Comprehensive test coverage
- Multi-platform support (Linux, macOS, Windows - x86_64 and aarch64)
- Native binary builds with Starship-style release pattern

### Features

- **Statistics**: Calculate average, median, min, max from numbers
- **Word Frequency**: Analyze word occurrence in text
- **Email Validation**: Simple email format validation
- **User Management**: Create and display user information with JSON support
- **Demo Mode**: Interactive demonstration of all features

### Dependencies

- serde + serde_json: JSON serialization
- colored: Terminal color output
- clap: Command-line argument parsing
- anyhow: Error handling
