/**
 * publish-rollback - promote the previous version: point the preview back at
 * the version it pointed at before the current one.
 *
 * Refuses without the exact typed confirmation `ROLLBACK <current version>`:
 * the confirmation names the version you are taking out of the preview, so a
 * confirmation typed for one state cannot roll back another. Before it moves
 * the pointer it checks the version it goes back to against that folder's own
 * manifest. It changes one file: channels/preview.json.
 *
 *   bun run scripts/publish/rollback.ts --tree <dir> --confirm "ROLLBACK <current>" [--dry-run]
 */
import { Args } from "../ingest/lib/args.ts";
import { readChannel, verifyVersion, writeChannel } from "./lib/tree.ts";

const USAGE = 'usage: rollback.ts --tree <dir> --confirm "ROLLBACK <current version>" [--dry-run] [--run <id>]';

function main(): number {
  // Args refuses a repeated flag: a second --confirm can never appear and win.
  const args = new Args(process.argv.slice(2), ["dry-run"]);
  const tree = args.required("tree", USAGE);
  const confirm = args.optional("confirm");
  const dryRun = args.bool("dry-run");
  const run = args.optional("run") || null;

  const channel = readChannel(tree);
  if (!channel.current) {
    console.error("The preview points at no version yet. There is nothing to roll back. Nothing was changed.");
    return 1;
  }
  const expected = `ROLLBACK ${channel.current}`;
  if (confirm !== expected) {
    console.error(
      `The confirmation must read exactly "${expected}" (the version the preview points at now). ` +
        `It read "${confirm}". Nothing was changed.`,
    );
    return 1;
  }
  if (channel.stack.length < 2) {
    console.error(
      `Version ${channel.current} is the first version ever promoted. There is no earlier version to go back to. Nothing was changed.`,
    );
    return 1;
  }
  const target = channel.stack[channel.stack.length - 2];

  const { problems, manifest } = verifyVersion(tree, target);
  if (problems.length || !manifest) {
    console.error(
      `The version to go back to, ${target}, did not pass its hash check. Nothing was changed.\n` +
        problems.map((p) => `  - ${p}`).join("\n"),
    );
    return 1;
  }

  const lines = [
    `## Publish — rollback${dryRun ? " (dry run)" : ""}`,
    "",
    `| Item | Value |`,
    `|---|---|`,
    `| Preview now | \`${channel.current}\` |`,
    `| Preview after | \`${target}\` |`,
    `| Hash check of \`${target}\` | ${manifest.files.length} files match manifest.json; content \`${manifest.content_sha256}\` |`,
    `| Venues in \`${target}\` | ${manifest.counts.venues.toLocaleString("en-US")} |`,
    `| A second rollback after this would go to | ${channel.stack.length >= 3 ? `\`${channel.stack[channel.stack.length - 3]}\`` : "nothing (no earlier version)"} |`,
  ];

  if (dryRun) {
    lines.push("", "Dry run: every check passed. Nothing was changed.");
    console.log(lines.join("\n"));
    return 0;
  }

  const from = channel.current;
  channel.stack.pop();
  channel.current = target;
  channel.history.push({
    action: "rollback",
    version: target,
    from,
    at: new Date().toISOString().replace(/\.\d{3}Z$/, "Z"),
    run,
  });
  writeChannel(tree, channel);
  lines.push(
    "",
    `Done. \`channels/preview.json\` now points at \`${target}\`. ` +
      `Version \`${from}\` stays in the tree; to put it back, run **Publish — promote** with \`PUBLISH ${from}\`.`,
  );
  console.log(lines.join("\n"));
  return 0;
}

try {
  process.exit(main());
} catch (err) {
  console.error(`Rollback failed: ${(err as Error).message}`);
  process.exit(2);
}
