// Package the Rojo-built place, scripts, tour, screenshots, and Roblox metadata.
// Run with: MAKEFUN_OUTPUT_DIR=out node main.ts
import { cpSync, copyFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const root = fileURLToPath(new URL('.', import.meta.url));
const output = process.env.MAKEFUN_OUTPUT_DIR ?? join(root, 'out');
const include = (path: string): boolean => !basename(path).startsWith('.');

mkdirSync(output, { recursive: true });
for (const name of ['game.rbxl', 'PLAY.json', 'TOUR.json', 'README.md', 'default.project.json']) {
  copyFileSync(join(root, name), join(output, name));
}
cpSync(join(root, 'src'), join(output, 'src'), { recursive: true, filter: include });
cpSync(join(root, 'screenshots'), join(output, 'screenshots'), { recursive: true, filter: include });

const dossier = buildDossier(output, {
  text_max_bytes: 65536,
  screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000,
  scripts_max_source_bytes: 8388608,
  scripts_max_path_chars: 1048576,
});
writeFileSync(join(output, 'dossier.json'), dossier);
