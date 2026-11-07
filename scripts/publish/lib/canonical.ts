import { createHash } from "node:crypto";

/**
 * Canonical JSON: the one way this job turns a value into bytes.
 *
 * The design says one database state gives the same bytes, every time. Two
 * things break that in plain JSON.stringify: object key order (which follows
 * insertion order) and anything that is not plain data (Date, bigint,
 * undefined). This writer sorts every object's keys, drops undefined, refuses
 * anything it cannot write the same way twice, and ends every file with one
 * newline.
 *
 * Arrays keep their order. Callers sort rows before they get here, and the
 * sort keys are written down next to each sort (lib/shape.ts).
 */
export function canonical(value: unknown, indent = 0): string {
  return write(value, indent, 0) + "\n";
}

function write(value: unknown, indent: number, depth: number): string {
  if (value === null) return "null";
  switch (typeof value) {
    case "string":
      return JSON.stringify(value);
    case "boolean":
      return value ? "true" : "false";
    case "number":
      if (!Number.isFinite(value)) throw new Error(`canonical: non-finite number ${value}`);
      return JSON.stringify(value);
    case "object":
      break;
    default:
      throw new Error(`canonical: cannot write a ${typeof value}`);
  }
  if (value instanceof Date) throw new Error("canonical: Date values are not allowed in output");

  const pad = indent > 0 ? "\n" + " ".repeat(indent * (depth + 1)) : "";
  const end = indent > 0 ? "\n" + " ".repeat(indent * depth) : "";
  const sep = indent > 0 ? ": " : ":";

  if (Array.isArray(value)) {
    if (value.length === 0) return "[]";
    const items = value.map((v) => write(v === undefined ? null : v, indent, depth + 1));
    return "[" + pad + items.join("," + pad) + end + "]";
  }

  const obj = value as Record<string, unknown>;
  const keys = Object.keys(obj)
    .filter((k) => obj[k] !== undefined)
    .sort(byCodePoint);
  if (keys.length === 0) return "{}";
  const parts = keys.map((k) => JSON.stringify(k) + sep + write(obj[k], indent, depth + 1));
  return "{" + pad + parts.join("," + pad) + end + "}";
}

/**
 * Plain code-point order. Never localeCompare: that depends on the ICU data on
 * the machine, and the design needs the same bytes on a GitHub runner as on
 * Ben's laptop.
 */
export function byCodePoint(a: string, b: string): number {
  return a < b ? -1 : a > b ? 1 : 0;
}

/** Compare tuples of strings/numbers/nulls; null sorts first. */
export function byKeys(a: readonly unknown[], b: readonly unknown[]): number {
  for (let i = 0; i < Math.max(a.length, b.length); i += 1) {
    const x = a[i] ?? null;
    const y = b[i] ?? null;
    if (x === y) continue;
    if (x === null) return -1;
    if (y === null) return 1;
    if (typeof x === "number" && typeof y === "number") return x - y;
    const c = byCodePoint(String(x), String(y));
    if (c !== 0) return c;
  }
  return 0;
}

export function sha256(text: string | Uint8Array): string {
  return createHash("sha256").update(text).digest("hex");
}
