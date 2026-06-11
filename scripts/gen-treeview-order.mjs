// Generates src/data/treeview-order.json — maps each content path (dir or page slug,
// relative to src/content/docs) to its position in the book, so the sidebar
// (astro.config.ts) orders sections as they appear in the manuscript rather than
// alphabetically. Order source = the Scrivener TOC (x-scrivener-item links).
// Run: DET_RTF="/path/to/Data Engine Thinking.rtf" node scripts/gen-treeview-order.mjs
import fs from 'node:fs';
import path from 'node:path';

const RTF = process.env.DET_RTF || 'C:/Users/me/OneDrive/Desktop/Data Engine Thinking.rtf';
const ROOT = 'C:/Repos/data-engine-thinking/samples';
const DOCS = path.join(ROOT, 'src/content/docs');
const OUT = path.join(ROOT, 'src/data/treeview-order.json');

let raw = fs.readFileSync(RTF, 'latin1');
function strip(s) {
  const out = []; let i = 0; const n = s.length;
  while (i < n) {
    if (s[i] === '{') {
      const h = s.substr(i, 26);
      if (/^\{\\pict\b/.test(h) || /^\{\\\*\\(shppict|nonshppict|datastore|do|mmath)\b/.test(h)) {
        let d = 0, j = i;
        for (; j < n; j++) { const c = s[j]; if (c === '\\') { j++; continue; } if (c === '{') d++; else if (c === '}') { d--; if (!d) { j++; break; } } }
        i = j; continue;
      }
    }
    out.push(s[i]); i++;
  }
  return out.join('');
}
function group(s, i) { let d = 0; for (let j = i; j < s.length; j++) { const c = s[j]; if (c === '\\') { j++; continue; } if (c === '{') d++; else if (c === '}') { d--; if (!d) return s.slice(i, j + 1); } } return s.slice(i, i + 6000); }
function decode(ch) {
  let out = '', i = 0; const n = ch.length;
  while (i < n) {
    const c = ch[i];
    if (c === '\\') {
      const nx = ch[i + 1];
      if (nx === '\\' || nx === '{' || nx === '}') { out += nx; i += 2; continue; }
      if (nx === "'") { const v = parseInt(ch.substr(i + 2, 2), 16); if (!isNaN(v)) out += String.fromCharCode(v); i += 4; continue; }
      if (nx === '~') { out += ' '; i += 2; continue; }
      if (nx === '-') { i += 2; continue; }
      let j = i + 1; while (j < n && /[a-zA-Z]/.test(ch[j])) j++;
      const w = ch.slice(i + 1, j); let num = '';
      while (j < n && /[0-9]/.test(ch[j])) { num += ch[j]; j++; }
      if (ch[j] === ' ') j++; i = j;
      if (w === 'tab') out += ' '; else if (w === 'u') { const v = parseInt(num, 10); if (!isNaN(v)) out += String.fromCharCode(v); if (ch[i] && ch[i] !== '\\') i++; }
      continue;
    }
    if (c === '{' || c === '}' || c === '\r' || c === '\n') { i++; continue; }
    out += c; i++;
  }
  return out;
}

const reduced = strip(raw); raw = null;

function norm(s) {
  return s.toLowerCase()
    .replace(/modelling/g, 'modeling').replace(/artefact/g, 'artifact').replace(/behaviour/g, 'behavior')
    .replace(/colour/g, 'color').replace(/organis/g, 'organiz').replace(/optimis/g, 'optimiz')
    .replace(/normalis/g, 'normaliz').replace(/summaris/g, 'summariz').replace(/centre/g, 'center')
    .replace(/licence/g, 'license').replace(/catalogue/g, 'catalog').replace(/condensing/g, 'compacting')
    .replace(/reinitialisation/g, 'reinitialization').replace(/[^a-z0-9]+/g, '');
}

// Treeview order source = the Scrivener TOC (x-scrivener-item links), in document order.
const full = reduced.split(/\\par(?![a-zA-Z])/).map(decode).join('\n');
const toc = [];
const seen = new Set();
const titleIdx = new Map();
let pos = 0;
for (const m of full.matchAll(/scrivener-item:[^"]*"\s*([^*"\n]{1,120}?)\s*\*HYPERLINK\s+"scrivlnk:/g)) {
  const title = m[1].trim().replace(/^\d+\s+/, '');     // drop leading chapter number
  const k = norm(title);
  if (!k) continue;
  titleIdx.set(k, pos);                                  // last occurrence wins → implementation section, not narrative intro
  if (!seen.has(k)) { seen.add(k); toc.push({ pos, title }); }
  pos++;
}
console.log('TOC entries (unique):', toc.length, ' raw:', pos);

// tiered match: exact -> 'the'-stripped -> folder⊂toc (prefix) -> toc⊂folder -> contains
function lookup(key) {
  if (!key) return undefined;
  const ks = key.startsWith('the') ? key.slice(3) : key;
  if (titleIdx.has(key)) return titleIdx.get(key);
  if (ks !== key && titleIdx.has(ks)) return titleIdx.get(ks);
  let best, bestLen = -1, bestTier = 9;
  for (const [tk, idx] of titleIdx) {
    if (tk.length < 8) continue;
    let tier;
    if (tk.startsWith(key) || tk.startsWith(ks)) tier = 0;                                              // folder ⊂ toc title (toc is more specific)
    else if ((key.length >= 8 && key.startsWith(tk)) || (ks.length >= 8 && ks.startsWith(tk))) tier = 1; // toc title ⊂ folder
    else if (ks.length >= 12 && tk.includes(ks)) tier = 2;
    else continue;
    if (tier < bestTier || (tier === bestTier && tk.length > bestLen)) { best = idx; bestLen = tk.length; bestTier = tier; }  // prefer most-specific title
  }
  return best;
}

function titleOf(file) {
  try { const fm = fs.readFileSync(file, 'utf8').match(/^---\r?\n([\s\S]*?)\r?\n---/); const t = fm && fm[1].match(/^title:\s*(.+?)\s*$/m); if (t) return t[1].replace(/^["']|["']$/g, ''); } catch {}
  return null;
}

const order = {};
const unmatched = [];
function walk(dir) {
  for (const name of fs.readdirSync(dir)) {
    const full = path.join(dir, name);
    const rel = path.relative(DOCS, full).split(path.sep).join('/');
    if (fs.statSync(full).isDirectory()) {
      const idx = path.join(full, 'index.md');
      const title = fs.existsSync(idx) ? titleOf(idx) : null;
      const oi = lookup(norm(title || name));
      if (oi !== undefined) order[rel] = oi; else unmatched.push(`DIR  ${rel}  (${title || name})`);
      walk(full);
    } else if (/\.mdx?$/i.test(name) && name.toLowerCase() !== 'index.md') {
      const slug = rel.replace(/\.mdx?$/i, '');
      const title = titleOf(full);
      const oi = lookup(norm(title || name.replace(/\.mdx?$/i, '')));
      if (oi !== undefined) order[slug] = oi; else unmatched.push(`PAGE ${slug}  (${title})`);
    }
  }
}
walk(DOCS);

fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(OUT, JSON.stringify(order, null, 0));
console.log(`matched: ${Object.keys(order).length}  unmatched (alphabetical fallback): ${unmatched.length}`);
console.log(unmatched.join('\n'));
