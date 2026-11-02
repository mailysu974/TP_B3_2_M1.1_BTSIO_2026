// Contrôle Unicode des fichiers texte, sans suivre les liens symboliques.
const fs = require('node:fs');
const path = require('node:path');
const { TextDecoder } = require('node:util');
const root = path.resolve(__dirname, '..');
const excluded = new Set(['.git', 'node_modules', '__pycache__', 'lab1']);
const pattern = /\p{Extended_Pictographic}|\p{Emoji_Presentation}|[\uFE0E\uFE0F\u200D\u20E3\u{E0020}-\u{E007F}]/u;
let checked = 0;
let failed = false;
function walk(dir) {
  for (const entry of fs.readdirSync(dir, {withFileTypes: true})) {
    if (excluded.has(entry.name) || entry.isSymbolicLink()) continue;
    const file = path.join(dir, entry.name);
    if (entry.isDirectory()) { walk(file); continue; }
    if (!entry.isFile()) continue;
    const data = fs.readFileSync(file);
    if (data.includes(0)) continue;
    let text;
    try { text = new TextDecoder('utf-8', {fatal: true}).decode(data); }
    catch { continue; }
    checked++;
    if (pattern.test(text) || pattern.test(entry.name)) {
      console.error(`Emoji détecté : ${path.relative(root, file)}`);
      failed = true;
    }
  }
}
walk(root);
if (failed) process.exitCode = 1;
else console.log(`Absence d'emojis : OK (${checked} fichiers texte)`);
