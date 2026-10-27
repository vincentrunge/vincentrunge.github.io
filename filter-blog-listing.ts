import { parse, stringify } from "stdlib/yaml";

type Metadata = Record<string, unknown>;

async function findPosts(directory: string): Promise<string[]> {
  const posts: string[] = [];
  for await (const entry of Deno.readDir(directory)) {
    const path = `${directory}/${entry.name}`;
    if (entry.isDirectory) {
      posts.push(...await findPosts(path));
    } else if (entry.isFile && path.endsWith(".qmd")) {
      posts.push(path);
    }
  }
  return posts;
}

function parseMetadata(content: string): Metadata | undefined {
  const frontMatter = content.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
  const metadata = parse(frontMatter ? frontMatter[1] : content);
  return typeof metadata === "object" && metadata !== null
    ? metadata as Metadata
    : undefined;
}

function isoDate(value: unknown): string {
  if (value instanceof Date) return value.toISOString().slice(0, 10);
  return typeof value === "string" ? value.slice(0, 10) : "";
}

const today = new Date().toISOString().slice(0, 10);
const posts: Metadata[] = [];

for (const file of await findPosts("posts")) {
  const metadata = parseMetadata(await Deno.readTextFile(file));
  if (!metadata || typeof metadata.title !== "string") continue;

  const date = isoDate(metadata.date);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date) || date > today) continue;

  posts.push({ path: file });
}

await Deno.writeTextFile("blog-listing.yml", stringify(posts));