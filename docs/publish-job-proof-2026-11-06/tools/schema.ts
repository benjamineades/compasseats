import { buildSchema } from "/home/claude/compasseats/scripts/ingest/test/harness.ts";
import { connectTo } from "/home/claude/compasseats/scripts/ingest/lib/db.ts";
const { client, close } = await connectTo(process.argv[2]);
await buildSchema(client, "/home/claude/compasseats");
await close();
console.log("schema built");
