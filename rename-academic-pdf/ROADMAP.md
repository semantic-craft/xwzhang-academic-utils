# Roadmap

This document outlines planned features and improvements for rename-academic-pdf.

## Future Enhancements

### Additional Metadata Sources

Expand metadata lookup capabilities beyond CrossRef and arXiv:

- **PubMed Integration**
  - Add support for PubMed Central (PMC) API
  - Extract metadata using PubMed IDs (PMIDs)
  - Support for biomedical and life sciences papers

- **Semantic Scholar API**
  - Leverage Semantic Scholar's comprehensive academic database
  - Use DOI, arXiv ID, or title-based search
  - Access citation data and paper recommendations
  - Free API with generous rate limits

- **OpenAlex**
  - Open scholarly metadata source
  - Good coverage across disciplines
  - No authentication required

- **Microsoft Academic** (if API becomes available)
  - Cross-disciplinary academic search
  - Note: Microsoft Academic Graph was discontinued, but alternatives may emerge

### Caching Layer

Implement caching to improve performance and reduce API calls:

- **Local Cache**
  - SQLite database for storing metadata lookups
  - Cache DOI → metadata mappings
  - Cache arXiv ID → metadata mappings
  - Configurable cache expiration (default: 30 days)

- **Performance Benefits**
  - Avoid repeated API calls for the same papers
  - Faster processing of large batches
  - Offline mode for previously cached papers
  - Reduced load on external APIs (good citizenship)

- **Cache Management**
  - CLI commands to view cache statistics
  - Clear cache option
  - Export/import cache for sharing

### API Documentation

Generate comprehensive API documentation for developers:

- **Tools**
  - Use Sphinx for documentation generation
  - Auto-generate from docstrings
  - Host on Read the Docs or GitHub Pages

- **Content**
  - Module documentation
  - Function/class reference
  - Type annotations and signatures
  - Usage examples for each public API
  - Architecture diagrams

- **Developer Guide**
  - Contributing guidelines
  - Code style guide
  - Testing best practices
  - Release process

### Additional Features (Lower Priority)

- **Configuration File**
  - YAML/TOML config for user preferences
  - Custom filename templates
  - Excluded directories
  - Preferred metadata sources order

- **Batch Processing Improvements**
  - Progress bars for large batches
  - Parallel processing option
  - Resume interrupted batches

- **PDF Validation**
  - Detect and warn about corrupted PDFs
  - Verify PDF structure before processing
  - Handle password-protected PDFs gracefully

- **Enhanced Name Parsing**
  - Better handling of complex author names
  - Support for non-Western name formats
  - Configurable author name formatting

- **Interactive Mode**
  - Preview and confirm each rename
  - Edit metadata before renaming
  - Batch approve/reject changes

## Timeline

These features will be prioritized based on:
- Community interest and feedback
- Complexity and development time
- API availability and reliability
- Alignment with project goals

Contributions are welcome for any of these features! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Feedback

Have ideas for other features? Please [open an issue](https://github.com/osteele/rename-academic-pdf/issues) to discuss!
