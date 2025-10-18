# Changelog

## [1.2.5] - 2025-10-18
### Changed
- Migrated to new reusable workflow pattern (python-package-release.yml)
- Package now has dedicated workflow file (package-a-release.yml)
- Improved consistency with Rust/Go/C++ package workflows

## [1.2.4] - 2025-10-18
### Fixed
- Windows zip creation using PowerShell Compress-Archive

## [1.2.3] - 2025-10-18
### Fixed
- Windows virtual environment activation in build scripts

## [1.2.2] - 2025-10-18
### Fixed
- Package dependencies sync for CI workflows

## [1.2.1] - 2025-10-18
### Fixed
- Test workflow dependency sync

## [1.2.0] - 2025-10-18

### Features

- **package-a:** add comprehensive Python package structure
- **package-a:** add pytest test suite with 6 test classes
- **package-a:** add modern pyproject.toml configuration
- **package-a:** add GitHub Actions CI/CD workflows

# 1.1.0 (2025-10-15)

### Features

- **package-a:** add logger utility with multiple log levels 9e660b1
- **package-b:** add string utility functions 0802634
- **package-c:** add division and percentage functions 1b5fc65

### BREAKING CHANGES

- **package-a:** none

# Changelog

All notable changes to package-a will be documented in this file.

## [1.0.0] - 2025-10-15

### Added

- Initial release of package-a
