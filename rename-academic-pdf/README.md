# Rename Academic PDF

A command-line tool that renames academic PDF files to bibliography format, similar to how Zotero organizes papers. The tool extracts bibliographic information from PDFs and generates descriptive filenames in the format: `Author - Title (Year).pdf`.

## Features

- **Smart Metadata Extraction**: Tries multiple sources in order:
  1. Embedded XMP metadata from the PDF
  2. Online database lookups (CrossRef, arXiv) using DOI or arXiv ID
  3. Text parsing from the first page

- **Generic Filename Detection**: Only renames files with generic names like:
  - arXiv IDs (`1706.03762v7.pdf`)
  - Hash strings (`a1b2c3d4e5f6...pdf`)
  - Generic names (`download.pdf`, `paper.pdf`, `document.pdf`)
  
- **Smart File Selection**: 
  - **Direct files**: Processes any PDF you specify directly, regardless of filename
  - **Directories**: Only processes PDFs with generic names like:
    - arXiv IDs (`1706.03762v7.pdf`)
    - Hash strings (`a1b2c3d4e5f6...pdf`)
    - Generic names (`download.pdf`, `paper.pdf`, `document.pdf`)

- **Zotero-style Naming**: Generates clean, readable filenames:
  - `Vaswani - Attention Is All You Need (2017).pdf`
  - `Liu - Ring Attention with Blockwise Transformers for Near-Infinite Context (2023).pdf`

- **Safe Operations**:
  - `--dry-run` option to preview changes
  - Never overwrites existing files
  - Conflict detection and prevention

## Installation

### Prerequisites

- Python 3.11 or higher
- [uv](https://github.com/astral-sh/uv) package manager

### Install from GitHub (Recommended)

```bash
# Install as a tool (available globally)
uv tool install git+https://github.com/osteele/rename-academic-pdf.git

# Or install in a project
uv add git+https://github.com/osteele/rename-academic-pdf.git
```

### Install from PyPI (when published)

```bash
# Install as a tool (available globally)
uv tool install rename-academic-pdf

# Or install in a project
uv add rename-academic-pdf
```

### Install from source

```bash
git clone https://github.com/osteele/rename-academic-pdf.git
cd rename-academic-pdf
just setup
```

## Usage

### Basic Usage

```bash
# Rename PDFs in a directory (dry run)
rename-academic-pdf --dry-run ~/Downloads/Papers

# Actually rename the files
rename-academic-pdf ~/Downloads/Papers

# Process specific files
rename-academic-pdf file1.pdf file2.pdf

# Verbose output to see processing details
rename-academic-pdf --verbose --dry-run ~/Downloads/Papers
```

### Command Options

- `--dry-run, -n`: Show what would be renamed without making changes
- `--verbose, -v`: Show detailed processing information
- `--help`: Show help message

### Examples

```bash
# Preview changes for all PDFs in Downloads
rename-academic-pdf --dry-run ~/Downloads

# Rename papers with verbose output
rename-academic-pdf --verbose ~/Research/Papers

# Process specific files (any PDF, regardless of name)
rename-academic-pdf attention-paper.pdf ~/Downloads/1234.5678v1.pdf

# Mix directories and specific files
rename-academic-pdf my-paper.pdf ~/Downloads/Papers
```

## How It Works

1. **File Selection**: For directories, only processes PDF files with generic filenames (like arXiv IDs)
2. **Metadata Extraction**:
1. **File Selection**: 
   - **Direct files**: Always processes any PDF file you specify directly (e.g., `rename-academic-pdf attention-paper.pdf`)
   - **Directories**: Only processes PDF files with generic names (like arXiv IDs, `download.pdf`, etc.)
2. **Metadata Extraction**: 
   - First tries to extract XMP metadata embedded in the PDF
   - If unsuccessful, extracts text from first page and looks for DOI/arXiv ID
   - Queries online databases (CrossRef for DOIs, arXiv for arXiv IDs)
   - Falls back to parsing title and author from first page text
3. **Filename Generation**: Creates Zotero-style filenames: `Author - Title (Year).pdf`
4. **Safe Renaming**: Checks for conflicts and never overwrites existing files

## Development

### Setup Development Environment

```bash
just setup          # Install dependencies
just check           # Run all quality checks
just lint            # Run linting
just format          # Format code
just typecheck       # Run type checking
just test            # Run tests
```

### Project Structure

```
src/pdf_renamer/
├── __init__.py      # Package initialization
├── __main__.py      # CLI interface
├── metadata.py      # PDF metadata extraction
├── lookup.py        # Online database lookups
└── renamer.py       # Filename generation and validation
```

### Dependencies

- **pymupdf**: PDF text extraction
- **pypdf**: PDF metadata extraction
- **requests**: HTTP requests for online lookups
- **beautifulsoup4**: XML/HTML parsing for API responses
- **click**: Command-line interface
- **lxml**: XML processing

## Supported Sources

### Online Databases

- **CrossRef**: DOI-based paper lookup
- **arXiv**: arXiv ID-based paper lookup
- Future: PubMed, Google Scholar (when APIs available)

### Metadata Formats

- **XMP metadata**: Embedded PDF metadata
- **DOI extraction**: From paper text
- **arXiv ID extraction**: From paper text
- **Text parsing**: Title and author extraction from first page

## Limitations

- Only processes PDFs with generic filenames by default
- Text parsing is heuristic-based and may not work for all paper formats
- Online lookups require internet connection
- Some publishers may not provide complete metadata

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run `just check` to ensure quality standards
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Inspired by Zotero's automatic PDF organization
- Uses CrossRef and arXiv APIs for metadata lookup
- Part of the [Academic Software](https://osteele.com/software/academic-software) collection
