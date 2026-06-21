#!/usr/bin/env python3
"""Create a rainfall CSV template for importing into the future app."""

from pathlib import Path

CSV_HEADER = "date,amount_inches,source,notes\n"
SAMPLE_ROWS = [
    "2026-06-21,0.00,Weather estimate,Starter sample row",
    "2026-06-22,0.75,NWS / NOAA,Example beneficial rain",
]

output = Path("rainfall_template.csv")
output.write_text(CSV_HEADER + "\n".join(SAMPLE_ROWS) + "\n", encoding="utf-8")
print(f"Wrote {output.resolve()}")
