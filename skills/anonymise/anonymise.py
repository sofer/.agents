#!/usr/bin/env python3
"""
CSV Anonymiser

Removes personally identifying information from CSV files by stripping configured columns,
creates a timestamped output file, and removes the original.
"""

import csv
import sys
import re
from datetime import datetime
from pathlib import Path
from typing import Iterable

CONFIG_PATH = Path(__file__).resolve().parent / "config.txt"
TIMESTAMP_PATTERN = re.compile(r"\d{8}_\d{6}")

def find_new_csv_files() -> list[Path]:
    """
    Find CSV files that don't have a timestamp pattern in their name.

    Returns:
        List of Path objects for CSV files without timestamps
    """
    return [f for f in Path(".").glob("*.csv") if not TIMESTAMP_PATTERN.search(f.stem)]


def load_columns_to_remove(path: Path = CONFIG_PATH) -> list[str]:
    """Load column names to remove, ignoring blank lines and comments."""
    if not path.exists():
        raise FileNotFoundError(f"Config file not found: {path}")

    lines = path.read_text(encoding="utf-8").splitlines()
    columns = [line.strip() for line in lines if line.strip() and not line.strip().startswith("#")]

    if not columns:
        raise ValueError(f"No columns specified to remove in {path}")

    return columns


def indexes_for_columns(header: list[str], columns_to_remove: Iterable[str]) -> list[int]:
    """
    Map configured column names to indexes in the header (case-insensitive).
    Returns indexes found; warns if any are missing.
    """
    header_lookup = {name.strip().lower(): idx for idx, name in enumerate(header)}
    indexes = [
        header_lookup[name.lower()]
        for name in columns_to_remove
        if name.lower() in header_lookup
    ]
    missing = [name for name in columns_to_remove if name.lower() not in header_lookup]

    if missing:
        print(f"Warning: columns not found and will be ignored: {', '.join(missing)}", file=sys.stderr)

    if not indexes:
        raise ValueError("No matching columns found to remove; update config or CSV headers.")

    return sorted(set(indexes))


def strip_columns(rows: list[list[str]], indexes: list[int]) -> list[list[str]]:
    """Return new rows with specified column indexes removed."""
    return [
        [value for i, value in enumerate(row) if i not in indexes]
        for row in rows
    ]


def anonymise_csv(input_file: str) -> str:
    """
    Anonymise a CSV file by removing configured columns, saving with a timestamp, and deleting the original.

    Args:
        input_file: Path to the input CSV file

    Returns:
        Path to the anonymised output file
    """
    columns_to_remove = load_columns_to_remove()

    # Validate input file exists
    input_path = Path(input_file)
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_file}")

    # Generate timestamp for output filename (just timestamp, no original name)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = f"{timestamp}.csv"

    # Read and process CSV
    with open(input_file, 'r', encoding='utf-8-sig') as infile:
        reader = csv.reader(infile)
        rows = list(reader)

    if not rows:
        raise ValueError("Input CSV file is empty")

    header = rows[0]
    indexes = indexes_for_columns(header, columns_to_remove)

    anonymised_rows = strip_columns(rows, indexes)

    # Write anonymised data
    with open(output_file, 'w', newline='', encoding='utf-8') as outfile:
        writer = csv.writer(outfile)
        writer.writerows(anonymised_rows)

    # Remove original file
    input_path.unlink()

    return output_file


def main():
    """Main entry point for the script."""
    # If no arguments provided, auto-detect new CSV files
    if len(sys.argv) == 1:
        new_files = find_new_csv_files()

        if not new_files:
            print("No new CSV files found (files without timestamps)")
            sys.exit(0)

        if len(new_files) > 1:
            print("Multiple new CSV files found:")
            for i, f in enumerate(new_files, 1):
                print(f"  {i}. {f.name}")
            print("\nUsage: python3 anonymise.py <input_csv_file>")
            sys.exit(1)

        input_file = str(new_files[0])
        print(f"Found new file: {input_file}")

    elif len(sys.argv) == 2:
        input_file = sys.argv[1]

    else:
        print("Usage: python3 anonymise.py [input_csv_file]")
        print("  If no file specified, will auto-detect new CSV files")
        sys.exit(1)

    try:
        output_file = anonymise_csv(input_file)
        print(f"Success! Anonymised file created: {output_file}")
        print(f"Original file '{input_file}' has been removed")
        print("Configured columns have been stripped from the data")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
