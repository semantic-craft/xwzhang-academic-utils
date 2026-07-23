"""Look up paper metadata from Zotero library by matching PDF filename or attachment."""

from __future__ import annotations

import os
import re
from pathlib import Path

from pyzotero import zotero  # type: ignore[import-untyped]


def _get_zotero_client() -> zotero.Zotero | None:
    api_key = os.environ.get("ZOTERO_API_KEY")
    library_id = os.environ.get("ZOTERO_LIBRARY_ID")
    library_type = os.environ.get("ZOTERO_LIBRARY_TYPE", "user")
    if not api_key or not library_id:
        return None
    return zotero.Zotero(library_id, library_type, api_key)


def _extract_author_display(creators: list[dict[str, str]]) -> str | None:
    """Extract first author display name. For CJK names, use full name."""
    if not creators:
        return None
    first = creators[0]
    last = first.get("lastName", "")
    first_name = first.get("firstName", "")
    name = first.get("name", "")

    if name:
        display = name
    elif last and first_name:
        display = f"{last}{first_name}" if _is_cjk(last) else last
    elif last:
        display = last
    else:
        return None

    if len(creators) > 1:
        display += " et al" if not _is_cjk(display) else "等"

    return display


def _is_cjk(text: str) -> bool:
    return any("一" <= ch <= "鿿" for ch in text)


def _extract_year(date_str: str) -> str | None:
    if not date_str:
        return None
    m = re.search(r"(\d{4})", date_str)
    return m.group(1) if m else None


def lookup_zotero_by_filename(pdf_path: Path) -> dict[str, str] | None:
    """Search Zotero for an item whose attachment matches this PDF filename."""
    zot = _get_zotero_client()
    if not zot:
        return None

    stem = pdf_path.stem
    try:
        results = zot.items(q=stem, itemType="-attachment", limit=5)
    except Exception:
        return None

    for item in results:
        data = item.get("data", {})
        metadata = _zotero_data_to_metadata(data)
        if metadata and metadata.get("title"):
            return metadata

    return None


def lookup_zotero_by_title(title: str) -> dict[str, str] | None:
    """Search Zotero by title string extracted from PDF."""
    zot = _get_zotero_client()
    if not zot:
        return None

    query = title[:80]
    try:
        results = zot.items(q=query, itemType="-attachment", limit=5)
    except Exception:
        return None

    title_lower = title.lower().strip()
    for item in results:
        data = item.get("data", {})
        item_title = data.get("title", "").lower().strip()
        if item_title and (item_title in title_lower or title_lower in item_title):
            metadata = _zotero_data_to_metadata(data)
            if metadata and metadata.get("title"):
                return metadata

    return None


def _zotero_data_to_metadata(data: dict[str, str]) -> dict[str, str] | None:
    if not data.get("title"):
        return None

    metadata: dict[str, str] = {"title": data["title"]}

    creators = data.get("creators", [])  # type: ignore[assignment]
    author = _extract_author_display(creators)  # type: ignore[arg-type]
    if author:
        metadata["author"] = author

    year = _extract_year(data.get("date", ""))
    if year:
        metadata["year"] = year

    return metadata
