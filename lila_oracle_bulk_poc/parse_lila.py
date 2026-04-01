#!/usr/bin/env python3
"""Parse LiLa 'Spalte' files (like pegel-qvhs-spalte.lila) into 2 CSVs:
- stations.csv
- observations.csv (long format)

Usage:
  python parse_lila.py input.lila out_dir/
"""

import re
import csv
import sys
from pathlib import Path

DATE_RE = re.compile(r"^\d{2}\.\d{2}\.\d{4}\s+\d{2}:\d{2}$")

def split_semicolon(line: str):
    parts = line.rstrip("\n").split(";")
    if parts and parts[-1] == "":
        parts = parts[:-1]
    return parts

def to_float(x: str):
    if x is None:
        return ""
    x = str(x).strip()
    if x == "":
        return ""
    try:
        return str(float(x.replace(",", ".")))
    except:
        return ""

def main():
    if len(sys.argv) < 3:
        print("Usage: python parse_lila.py input.lila out_dir/")
        sys.exit(2)

    inp = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)

    lines = inp.read_text(encoding="utf-8").splitlines()

    header = {}
    i = 0
    while i < len(lines):
        parts = split_semicolon(lines[i])
        if not parts:
            i += 1
            continue
        key = parts[0].strip()
        if DATE_RE.match(key):
            break
        header[key] = parts[1:]
        i += 1

    data_start = i
    station_names = header["Station"]
    n = len(station_names)

    def get_row(name):
        return header.get(name, [""] * n)

    run_ts = ""
    for v in get_row("Vorhersagezeitpunkt"):
        if str(v).strip():
            run_ts = str(v).strip()
            break

    stations_fields = [
        "station_name","gewaesser","stationsnummer","datenart","dimension","datenbezug","zeitzone",
        "zeitintervall","datentyp","datenursprung","flaeche","flusskilometer","vorhersagezeitpunkt","kommentar"
    ]

    stations_path = out_dir / "stations.csv"
    with stations_path.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f, delimiter=";")
        w.writerow(stations_fields)
        for idx, name in enumerate(station_names):
            w.writerow([
                name,
                get_row("Gewaesser")[idx],
                get_row("Stationsnummer")[idx],
                get_row("Datenart")[idx],
                get_row("Dimension")[idx],
                get_row("Datenbezug")[idx],
                get_row("Zeitzone")[idx],
                get_row("Zeitintervall")[idx],
                get_row("Datentyp")[idx],
                get_row("Datenursprung")[idx],
                to_float(get_row("Flaeche")[idx]),
                to_float(get_row("Flusskilometer")[idx]),
                get_row("Vorhersagezeitpunkt")[idx],
                get_row("Kommentar")[idx],
            ])

    obs_fields = ["vorhersagezeitpunkt","station_name","ts","value_q","dimension"]
    obs_path = out_dir / "observations.csv"
    with obs_path.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f, delimiter=";")
        w.writerow(obs_fields)
        for line in lines[data_start:]:
            parts = split_semicolon(line)
            if not parts:
                continue
            ts = parts[0].strip()
            if not DATE_RE.match(ts):
                continue
            vals = parts[1:]
            if len(vals) < n:
                vals += [""] * (n - len(vals))
            for idx in range(n):
                w.writerow([run_ts, station_names[idx], ts, to_float(vals[idx]), get_row("Dimension")[idx]])

    print(f"Wrote: {stations_path}")
    print(f"Wrote: {obs_path}")

if __name__ == "__main__":
    main()
