import { mkdirSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";

/**
 * Progress, on stdout and on disk.
 *
 * The first Michelin run printed nothing for twelve minutes and was cancelled.
 * Nothing was wrong with the log: stage only wrote its report at the very end,
 * so a slow run and a hung run looked identical from the Actions tab, and the
 * cancelled run left no file behind to say how far it had got.
 *
 * Two things fix that, and this class is both of them:
 *
 *   - a line on stdout at every phase and every 100 rows, so the log moves;
 *   - the report file rewritten as each phase completes, so a run that is
 *     killed - by a cancel, a timeout or a failure - still leaves a report
 *     naming the phase it died in.
 *
 * The partial report is plain markdown with the same title as the finished
 * one, so the file at `reports/<batch key>-stage.md` is always the best
 * account of the last run, complete or not. A successful run overwrites it
 * with the real thing.
 */

interface Phase {
  name: string;
  detail: string | null;
  /** ms spent in this phase alone */
  ms: number;
  /** ms from the start of the run to the end of this phase */
  elapsed: number;
}

const TICK_EVERY = 100;

export class Progress {
  private readonly started = Date.now();
  private readonly phases: Phase[] = [];
  private last = Date.now();
  /** set once the run is over, one way or the other */
  private outcome: string | null = null;

  constructor(
    private readonly reportPath: string,
    private readonly batchKey: string,
  ) {}

  private secs(ms: number): string {
    return `${(ms / 1000).toFixed(1)}s`;
  }

  private stamp(): string {
    return `[${this.secs(Date.now() - this.started).padStart(7)}]`;
  }

  /** A phase finished. Prints it, records it, and rewrites the report file. */
  phase(name: string, detail?: string): void {
    const now = Date.now();
    this.phases.push({
      name,
      detail: detail ?? null,
      ms: now - this.last,
      elapsed: now - this.started,
    });
    this.last = now;
    console.log(`${this.stamp()} ${name}${detail ? ` - ${detail}` : ""}`);
    this.write();
  }

  /**
   * Row-level progress inside a phase. Prints every 100 rows and once more on
   * the last row, so a phase that is shorter than 100 rows still says so.
   */
  tick(label: string, done: number, total: number): void {
    if (done % TICK_EVERY !== 0 && done !== total) return;
    console.log(`${this.stamp()}   ${label} ${done}/${total}`);
  }

  /** Note that the run ended badly. The next write() says so. */
  failed(reason: string): void {
    this.outcome = reason;
    this.write();
  }

  /** Stop rewriting the file - the finished report owns it from here. */
  done(): void {
    this.outcome = "done";
  }

  /**
   * The phase table, for the finished report. A stage run that took minutes
   * should say where the minutes went, in the artefact people actually read.
   */
  timingRows(): string[][] {
    return this.phases.map((ph, i) => [
      String(i + 1),
      ph.name,
      this.secs(ph.ms),
      this.secs(ph.elapsed),
      ph.detail ?? "",
    ]);
  }

  private write(): void {
    if (this.outcome === "done") return;
    writeFile(this.reportPath, this.partialReport());
  }

  /**
   * What a killed run leaves behind: which phases completed, how long each
   * took, and an unambiguous statement that nothing was promoted and - because
   * stage runs in one transaction - nothing was staged either.
   */
  partialReport(): string {
    const out: string[] = [];
    const p = (s = "") => out.push(s);

    p(`# Ingest stage - ${this.batchKey} (INCOMPLETE)`);
    p();
    if (this.outcome === null) {
      p(`This run is **still going** as of ${new Date().toISOString()}, or it was killed`);
      p(`without warning. This file is rewritten as each phase completes.`);
    } else {
      p(`This run **did not finish**: ${this.outcome}.`);
    }
    p();
    p(
      `Stage writes to \`ingest_batches\` and \`ingest_rows\` inside one transaction, and ` +
        `that transaction had not committed. No live table was touched, and no batch row ` +
        `was written. Re-running the same batch key is safe.`,
    );
    p();
    p(`## Phases that completed`);
    p();
    if (this.phases.length === 0) {
      p(`None. The run died before its first phase - most likely reading the CSV or`);
      p(`opening the database connection.`);
    } else {
      p(`| # | phase | took | elapsed | detail |`);
      p(`|---|---|---|---|---|`);
      this.phases.forEach((ph, i) => {
        p(
          `| ${i + 1} | ${ph.name} | ${this.secs(ph.ms)} | ${this.secs(ph.elapsed)} | ${
            ph.detail ?? ""
          } |`,
        );
      });
      p();
      p(`It stopped **after** "${this.phases[this.phases.length - 1].name}".`);
    }
    p();
    return out.join("\n");
  }
}

/** Write a file, creating its directory. Synchronous on purpose: this has to
 *  work from a signal handler, where nothing asynchronous is guaranteed to run. */
export function writeFile(path: string, body: string): void {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, body, "utf8");
}
