/**
 * publish-promote - point the preview at one version.
 *
 * Refuses without the exact typed confirmation `PUBLISH <version>`. Before it
 * moves the pointer it checks the version folder against its own manifest:
 * every file there, every sha256 the same, no extra file, every gate passed at
 * build. It changes one file: channels/preview.json. It never touches the
 * database and never touches the live site.
 *
 *   bun run scripts/publish/promote.ts --tree <dir> --version <id> --confirm "PUBLISH <id>" [--dry-run]
 */
import { Args } from "../ingest/lib/args.ts";
import { VERSION_ID, readChannel, verifyVersion, writeChannel } from "./lib/tree.ts";

const USAGE = 'usage: promote.ts --tree <dir> --version <id> --confirm "PUBLISH <id>" [--dry-run] [--run <id>]';

function main(): number {
  // Args refuses a repeated flag: a second --confirm can never appear and win.
  const args = new Args(process.argv.slice(2), ["dry-run"]);
  const tree = args.required("tree", USAGE);
  const version = args.required("version", USAGE).trim();
  const confirm = args.optional("confirm");
  const dryRun = args.bool("dry-run");
  const run = args.optional("run") || null;

  if (!VERSION_ID.test(version)) {
    console.error(`"${version}" is not a version id. It looks like 20261107T020000Z.`);
    return 1;
  }
  const expected = `PUBLISH ${version}`;
  if (confirm !== expected) {
    console.error(`The confirmation must read exactly "${expected}". It read "${confirm}". Nothing was changed.`);
    return 1;
  }

  const channel = readChannel(tree);
  if (channel.current === version) {
    console.log(`## Publish — promote\n\nVersion \`${version}\` is already the preview. Nothing to do.`);
    return 0;
  }

  const { problems, manifest } = verifyVersion(tree, version);
  if (problems.length || !manifest) {
    console.error(
      `Version ${version} did not pass its hash check. Nothing was changed.\n` +
        problems.map((p) => `  - ${p}`).join("\n"),
    );
    return 1;
  }

  const lines = [
    `## Publish — promote${dryRun ? " (dry run)" : ""}`,
    "",
    `| Item | Value |`,
    `|---|---|`,
    `| Preview now | ${channel.current ? `\`${channel.current}\`` : "none (first promote)"} |`,
    `| Preview after | \`${version}\` |`,
    `| Hash check | ${manifest.files.length} files match manifest.json; content \`${manifest.content_sha256}\` |`,
    `| Venues in the version | ${manifest.counts.venues.toLocaleString("en-US")} |`,
    `| Built at / database read at | ${manifest.built_at} / ${manifest.database.read_at} |`,
    `| Rollback after this would go to | ${channel.current ? `\`${channel.current}\`` : "nothing (no earlier version)"} |`,
  ];

  if (dryRun) {
    lines.push("", "Dry run: every check passed. Nothing was changed.");
    console.log(lines.join("\n"));
    return 0;
  }

  const from = channel.current;
  channel.stack.push(version);
  channel.current = version;
  channel.history.push({
    action: "promote",
    version,
    from,
    at: new Date().toISOString().replace(/\.\d{3}Z$/, "Z"),
    run,
  });
  writeChannel(tree, channel);
  lines.push("", `Done. \`channels/preview.json\` now points at \`${version}\`.`);
  console.log(lines.join("\n"));
  return 0;
}

try {
  process.exit(main());
} catch (err) {
  console.error(`Promote failed: ${(err as Error).message}`);
  process.exit(2);
}
