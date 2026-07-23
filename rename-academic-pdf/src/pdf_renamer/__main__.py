"""Command-line interface for PDF renamer."""

from __future__ import annotations

import sys
import traceback
from pathlib import Path

import click

from .lookup import lookup_paper_metadata
from .metadata import (
    extract_text_from_first_page,
    extract_xmp_metadata,
    extract_year_from_text,
    parse_title_and_authors_from_text,
)
from .renamer import FORMAT_GENERATORS, should_rename_file
from .zotero_lookup import lookup_zotero_by_filename, lookup_zotero_by_title


def collect_files_to_process(paths: tuple[str, ...], rename_all: bool = False) -> list[Path]:
    """Collect PDF files to process based on input paths."""
    files_to_process: list[Path] = []

    for path_str in paths:
        path = Path(path_str).resolve()

        if path.is_file():
            if path.suffix.lower() == ".pdf":
                files_to_process.append(path)
        elif path.is_dir():
            for file in path.iterdir():
                if file.is_file() and file.suffix.lower() == ".pdf":
                    if rename_all or should_rename_file(file):
                        files_to_process.append(file)

    return files_to_process


@click.command()
@click.argument("paths", nargs=-1, required=True, type=click.Path(exists=True))
@click.option("--dry-run", "-n", is_flag=True, help="Show what would be renamed without doing it")
@click.option("--verbose", "-v", is_flag=True, help="Show detailed processing information")
@click.option(
    "--format", "-f", "fmt",
    type=click.Choice(list(FORMAT_GENERATORS.keys())),
    default="author_year_title",
    help="Naming format (default: author_year_title)",
)
@click.option("--all", "rename_all", is_flag=True, help="Rename all PDFs in directory, not just generic names")
@click.option("--no-zotero", is_flag=True, help="Skip Zotero lookup")
def main(paths: tuple[str, ...], dry_run: bool, verbose: bool, fmt: str, rename_all: bool, no_zotero: bool) -> None:
    """Rename PDF files based on metadata. Default: 作者_年份_题名.pdf

    Lookup priority: Zotero → XMP → CrossRef/arXiv → text parsing
    """
    files_to_process: list[Path] = []

    for path_str in paths:
        path = Path(path_str).resolve()

        if not path.exists():
            click.echo(f"Path does not exist: {path}", err=True)
            continue
        elif path.is_file() and path.suffix.lower() != ".pdf":
            click.echo(f"Skipping non-PDF file: {path}", err=True)
            continue

        valid_files = collect_files_to_process((path_str,), rename_all=rename_all)
        files_to_process.extend(valid_files)

    if not files_to_process:
        click.echo("No suitable PDF files found to rename.")
        return

    renamed_count = 0
    failed_count = 0

    for pdf_path in files_to_process:
        click.echo(f"\nProcessing: {pdf_path.name}")

        try:
            metadata: dict[str, str] | None = None

            # Step 1: Zotero lookup (highest priority)
            if not no_zotero:
                if verbose:
                    click.echo("  Querying Zotero...")
                metadata = lookup_zotero_by_filename(pdf_path)
                if metadata and verbose:
                    click.echo(f"  Zotero match: {metadata}")

            # Step 2: XMP metadata
            if not metadata or not metadata.get("title"):
                if verbose:
                    click.echo("  Checking XMP metadata...")
                metadata = extract_xmp_metadata(pdf_path)

            # Step 3: Extract text from first page
            if verbose:
                click.echo("  Extracting text from first page...")
            first_page_text = extract_text_from_first_page(pdf_path)

            if not first_page_text and not metadata:
                click.echo(f"  Failed to extract text from {pdf_path.name}", err=True)
                failed_count += 1
                continue

            # Step 3.5: Zotero by title (if XMP got a title but no author/year)
            if not no_zotero and metadata and metadata.get("title") and (not metadata.get("author") or not metadata.get("year")):
                if verbose:
                    click.echo("  Zotero title search to fill gaps...")
                zot_meta = lookup_zotero_by_title(metadata["title"])
                if zot_meta:
                    metadata = zot_meta
                    if verbose:
                        click.echo(f"  Zotero title match: {metadata}")

            # Step 4: Online lookup (CrossRef / arXiv)
            if first_page_text and (not metadata or not metadata.get("title")):
                if verbose:
                    click.echo("  Looking up metadata online...")
                online_metadata = lookup_paper_metadata(first_page_text, metadata)
                if online_metadata:
                    metadata = online_metadata
                    if verbose:
                        click.echo("  Found metadata online!")

            # Step 5: Text parsing fallback
            if first_page_text and (not metadata or not metadata.get("title")):
                if verbose:
                    click.echo("  Parsing title and authors from text...")
                parsed_metadata = parse_title_and_authors_from_text(first_page_text)
                if parsed_metadata:
                    metadata = parsed_metadata

            # Step 5.5: Supplement year from text if missing
            if metadata and not metadata.get("year") and first_page_text:
                year = extract_year_from_text(first_page_text)
                if year:
                    metadata["year"] = year

            # Step 6: Generate new filename
            generate_fn = FORMAT_GENERATORS[fmt]
            if metadata and metadata.get("title"):
                new_filename = generate_fn(metadata)
                if new_filename:
                    new_path = pdf_path.parent / new_filename

                    if new_path.exists() and new_path != pdf_path:
                        click.echo(f"  Target already exists: {new_filename}", err=True)
                        failed_count += 1
                        continue

                    if new_path == pdf_path:
                        click.echo("  Already named correctly, skipping.")
                        continue

                    if dry_run:
                        click.echo(f"  Would rename to: {new_filename}")
                    else:
                        pdf_path.rename(new_path)
                        click.echo(f"  Renamed to: {new_filename}")
                    renamed_count += 1
                else:
                    click.echo(f"  Could not generate filename for {pdf_path.name}", err=True)
                    failed_count += 1
            else:
                click.echo(f"  No metadata found for {pdf_path.name}", err=True)
                failed_count += 1

        except Exception as e:
            click.echo(f"  Error processing {pdf_path.name}: {e}", err=True)
            if verbose:
                click.echo("  Traceback:", err=True)
                traceback.print_exc(file=sys.stderr)
            failed_count += 1

    click.echo(f"\n{'Would rename' if dry_run else 'Renamed'}: {renamed_count} file(s)")
    if failed_count:
        click.echo(f"Failed: {failed_count} file(s)")


if __name__ == "__main__":
    main()
