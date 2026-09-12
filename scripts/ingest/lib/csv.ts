/**
 * A small, correct RFC 4180 CSV reader and writer.
 *
 * Deliberately hand-rolled rather than a dependency: the ingest job runs in
 * GitHub Actions against the production database, and the fewer packages in
 * that path the better. The Award Radar exports and the review CSVs both carry
 * quoted fields with embedded commas, quotes and newlines, so a naive split on
 * "," is not good enough — this handles all three.
 */

export type CsvRecord = Record<string, string>;

/** Parse CSV text into header + rows of raw strings. */
export function parseCsv(text: string): { header: string[]; rows: string[][] } {
  // Strip a UTF-8 BOM; Sheets adds one on export.
  const src = text.charCodeAt(0) === 0xfeff ? text.slice(1) : text;

  const rows: string[][] = [];
  let field = "";
  let row: string[] = [];
  let inQuotes = false;
  let i = 0;

  const endField = () => {
    row.push(field);
    field = "";
  };
  const endRow = () => {
    endField();
    // Ignore a trailing blank line.
    if (!(row.length === 1 && row[0] === "")) rows.push(row);
    row = [];
  };

  while (i < src.length) {
    const ch = src[i];

    if (inQuotes) {
      if (ch === '"') {
        if (src[i + 1] === '"') {
          field += '"';
          i += 2;
          continue;
        }
        inQuotes = false;
        i += 1;
        continue;
      }
      field += ch;
      i += 1;
      continue;
    }

    if (ch === '"' && field === "") {
      inQuotes = true;
      i += 1;
      continue;
    }
    if (ch === ",") {
      endField();
      i += 1;
      continue;
    }
    if (ch === "\r") {
      if (src[i + 1] === "\n") i += 1;
      endRow();
      i += 1;
      continue;
    }
    if (ch === "\n") {
      endRow();
      i += 1;
      continue;
    }
    field += ch;
    i += 1;
  }
  if (field !== "" || row.length > 0) endRow();

  if (rows.length === 0) return { header: [], rows: [] };
  const [header, ...rest] = rows;
  return { header: header.map((h) => h.trim()), rows: rest };
}

/** Parse CSV text into records keyed by header name. */
export function parseCsvRecords(text: string): { header: string[]; records: CsvRecord[] } {
  const { header, rows } = parseCsv(text);
  const records = rows.map((cells) => {
    const rec: CsvRecord = {};
    header.forEach((h, idx) => {
      rec[h] = cells[idx] ?? "";
    });
    return rec;
  });
  return { header, records };
}

function quote(value: string): string {
  if (/[",\r\n]/.test(value)) return `"${value.replace(/"/g, '""')}"`;
  return value;
}

/** Serialise records to CSV text with the given column order. */
export function toCsv(columns: string[], records: CsvRecord[]): string {
  const lines = [columns.map(quote).join(",")];
  for (const rec of records) {
    lines.push(columns.map((c) => quote(rec[c] ?? "")).join(","));
  }
  return lines.join("\n") + "\n";
}
