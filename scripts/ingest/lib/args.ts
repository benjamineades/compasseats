/**
 * Command-line arguments, read strictly.
 *
 * Strictly matters here. The typed confirmation is the only thing standing
 * between a staged batch and the live tables, so a second `--confirm` must
 * never be able to appear and win. A repeated flag is an error, not a
 * first-one-wins race.
 */
export class Args {
  private readonly flags = new Map<string, string>();
  private readonly bools = new Set<string>();

  constructor(argv: readonly string[], booleanFlags: readonly string[] = []) {
    for (let i = 0; i < argv.length; i += 1) {
      const token = argv[i];
      if (!token.startsWith("--")) {
        throw new Error(`Unexpected argument "${token}".`);
      }
      const name = token.slice(2);

      if (booleanFlags.includes(name)) {
        if (this.bools.has(name)) throw new Error(`--${name} was given more than once.`);
        this.bools.add(name);
        continue;
      }
      if (this.flags.has(name)) {
        throw new Error(
          `--${name} was given more than once. Refusing to guess which one you meant.`,
        );
      }
      const value = argv[i + 1];
      if (value === undefined || value.startsWith("--")) {
        throw new Error(`--${name} needs a value.`);
      }
      this.flags.set(name, value);
      i += 1;
    }
  }

  required(name: string, usage: string): string {
    const value = this.flags.get(name);
    if (value === undefined || value === "") throw new Error(`--${name} is required.\n\n${usage}`);
    return value;
  }

  optional(name: string, fallback = ""): string {
    return this.flags.get(name) ?? fallback;
  }

  bool(name: string): boolean {
    return this.bools.has(name);
  }
}
