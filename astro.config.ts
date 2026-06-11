import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import mdx from '@astrojs/mdx';
import starlight from '@astrojs/starlight';
import remarkCodeImport from 'remark-code-import';
import { defineConfig, fontProviders } from 'astro/config';

/* ---------------------------------------------------------------
   Reader-friendly sidebar, generated from the content tree.

   Starlight's `autogenerate` labels each group with the raw folder
   name (e.g. "design-patterns"). Instead we walk src/content/docs and:
     - label each group with its index page's title when it has one,
       otherwise a Title-Cased version of the folder name;
     - relabel a group's own index page to "Introduction" so it does
       not repeat the group name;
     - label leaf pages with their frontmatter title.
   --------------------------------------------------------------- */
const DOCS = fileURLToPath(new URL('./src/content/docs', import.meta.url));

// Treeview order. Two layers, both "lower number = higher in the tree":
//   1) a page's `sidebar.order` frontmatter — the manual, per-page override;
//   2) src/data/treeview-order.json — generated from the manuscript TOC by
//      scripts/gen-treeview-order.mjs (maps a content path to its book position).
// Items with neither fall back to numeric/alphabetical order by name.
let TREEVIEW_ORDER = {};
try {
  TREEVIEW_ORDER = JSON.parse(fs.readFileSync(fileURLToPath(new URL('./src/data/treeview-order.json', import.meta.url)), 'utf8'));
} catch {}
const _orderCache = new Map();
function frontmatterOrder(file) {
  if (_orderCache.has(file)) return _orderCache.get(file);
  let v;
  try {
    const fm = fs.readFileSync(file, 'utf8').match(/^---\r?\n([\s\S]*?)\r?\n---/);
    const m = fm && fm[1].match(/(?:^|\n|\{)\s*order:\s*(-?\d+(?:\.\d+)?)/);
    v = m ? Number(m[1]) : undefined;
  } catch { v = undefined; }
  _orderCache.set(file, v);
  return v;
}
function orderOf(dir, name) {
  const full = path.join(dir, name);
  const isFile = fs.statSync(full).isFile();
  const fo = frontmatterOrder(isFile ? full : path.join(full, 'index.md')); // 1) per-page override
  if (fo !== undefined) return fo;
  let rel = path.relative(DOCS, full).split(path.sep).join('/');          // 2) generated treeview order
  if (isFile) rel = rel.replace(/\.mdx?$/i, '');
  const o = TREEVIEW_ORDER[rel];
  return o === undefined ? Infinity : o;
}
const ACRONYMS = {
  psa: 'PSA', sql: 'SQL', cdc: 'CDC', pit: 'PIT', lda: 'LDA',
  nbr: 'NBR', etl: 'ETL', elt: 'ELT', api: 'API', ddl: 'DDL',
};
const SMALL = new Set(['of', 'and', 'the', 'a', 'an', 'to', 'in', 'for', 'with', 'from', 'on', 'or']);

function prettify(name) {
  return name
    .replace(/_/g, '-')
    .split('-')
    .filter(Boolean)
    .map((w, i) => {
      const lw = w.toLowerCase();
      if (ACRONYMS[lw]) return ACRONYMS[lw];
      if (i > 0 && SMALL.has(lw)) return lw;
      return lw.charAt(0).toUpperCase() + lw.slice(1);
    })
    .join(' ');
}

function titleOf(file) {
  try {
    const fm = fs.readFileSync(file, 'utf8').match(/^---\r?\n([\s\S]*?)\r?\n---/);
    const t = fm && fm[1].match(/^title:\s*(.+?)\s*$/m);
    if (t) return t[1].replace(/^["']|["']$/g, '');
  } catch {}
  return null;
}

// A folder's index page is normally relabeled "Introduction"; a page can
// override that sidebar label with `sidebar.label` in its frontmatter.
function indexLabelOf(file) {
  try {
    const fm = fs.readFileSync(file, 'utf8').match(/^---\r?\n([\s\S]*?)\r?\n---/);
    const m = fm && fm[1].match(/^[ \t]*label:[ \t]*(.+?)[ \t]*$/m);
    if (m) return m[1].replace(/^["']|["']$/g, '');
  } catch {}
  return null;
}

function slugOf(abs) {
  return path
    .relative(DOCS, abs)
    .split(path.sep)
    .join('/')
    .replace(/\.mdx?$/i, '')
    .replace(/\/?index$/i, '');
}

function buildDir(dir) {
  const entries = fs
    .readdirSync(dir)
    .sort((a, b) => {
      const oa = orderOf(dir, a), ob = orderOf(dir, b);
      return oa !== ob ? oa - ob : a.localeCompare(b, undefined, { numeric: true });
    })
    .flatMap((name) => {
      const full = path.join(dir, name);
      if (fs.statSync(full).isDirectory()) {
        const idx = path.join(full, 'index.md');
        const label = (fs.existsSync(idx) && titleOf(idx)) || prettify(name);
        return [{ label, collapsed: true, items: buildDir(full) }];
      }
      if (/\.mdx?$/i.test(name) && name.toLowerCase() !== 'index.md') {
        return [{ label: titleOf(full) || prettify(name.replace(/\.mdx?$/i, '')), slug: slugOf(full) }];
      }
      return [];
    });
  const idx = path.join(dir, 'index.md');
  if (fs.existsSync(idx)) entries.unshift({ label: indexLabelOf(idx) || 'Introduction', slug: slugOf(idx) });
  return entries;
}

const section = (sub) => buildDir(path.join(DOCS, sub));

// https://astro.build/config
export default defineConfig({
  site: 'https://docs.dataenginethinking.com',
  outDir: 'dist',
  server: { port: 2330 },
  fonts: [
    {
      provider: fontProviders.google(),
      name: 'Roboto',
      cssVariable: '--font-roboto',
    },
    {
      provider: fontProviders.google(),
      name: 'Roboto Mono',
      cssVariable: '--font-roboto-mono',
    },
  ],
  devToolbar: { enabled: false },
  markdown: {
    // Pull SQL / Handlebars samples from the standalone files under code/ at
    // build time, so the files stay editable and runnable while the pages stay
    // in sync. `file=<rootDir>/x.sql` resolves relative to rootDir (code/).
    remarkPlugins: [[remarkCodeImport, { rootDir: fileURLToPath(new URL('./code', import.meta.url)) }]],
  },
  integrations: [
    starlight({
      title: 'Data Engine Thinking Samples',
      logo: { src: './src/assets/logo.png', alt: 'Data Engine Thinking', replacesTitle: true },
      customCss: ['./src/styles/custom.css'],
      components: {
        Head: './src/components/Head.astro',
      },
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/data-engine-thinking/samples',
        },
      ],
      editLink: {
        baseUrl: 'https://github.com/data-engine-thinking/samples/edit/main/',
      },
      sidebar: [
        { label: 'Patterns', items: section('patterns') },
        { label: 'Sample Setup', items: section('setup') },
        { label: 'Samples by Chapter', items: section('chapters') },
        { label: 'About', slug: 'about' },
        { label: 'Taking the Next Step', slug: 'next-steps' },
        { label: 'License', slug: 'license' },
        { label: 'Disclaimer', slug: 'disclaimer' },
      ],
    }),
    mdx(),
  ],
});
