# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Integration tests with synthetic PDFs for testing XMP metadata extraction
- Test coverage for SHA-256 hash filenames (64 characters)
- Test coverage for case-insensitive PDF extension matching in directory processing
- MIT License file
- This CHANGELOG file
- ROADMAP for future enhancements

### Changed
- Improved exception handling specificity throughout codebase:
  - `metadata.py`: Now catches specific exceptions (OSError, PdfReadError, ValueError, etc.)
  - `lookup.py`: Now catches specific exceptions (RequestException, JSONDecodeError, etc.)
  - `__main__.py`: Added verbose mode traceback output for better debugging
- Refactored duplicated author name parsing logic into shared `parse_author_name()` function
- Updated CrossRef API User-Agent header to use maintainer's actual email
- Fixed case-insensitive PDF extension matching in directory processing (now handles .PDF, .Pdf, etc.)
- Enhanced XMP-only workflow to properly handle scanned PDFs with metadata but no text layer

### Fixed
- Case-sensitive PDF extension bug where files with .PDF or .Pdf extensions were skipped in directories
- XMP metadata was discarded when text extraction failed, even when metadata was complete
- Missing SHA-256 hash pattern in generic filename detection (added 64-character hash support)

## [0.1.0] - 2025-01-20

### Added
- Initial release
- PDF renaming with Zotero-style filenames: `Author - Title (Year).pdf`
- Multiple metadata extraction sources:
  - Embedded XMP metadata
  - CrossRef API (DOI-based lookup)
  - arXiv API lookup
  - First-page text parsing
- Smart file selection (processes generic filenames by default)
- Safe operations with dry-run mode and conflict detection
- Command-line interface with Click
- Comprehensive test suite (40+ tests)
- Support for multi-author papers with "et al." notation
- Generic filename detection (arXiv IDs, hash strings, common names)

[Unreleased]: https://github.com/osteele/rename-academic-pdf/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/osteele/rename-academic-pdf/releases/tag/v0.1.0
