// Builds the placeholder GLBs into assets/models/ and preview PNGs into the given folder.
// Usage: node run.mjs [--shots <dir>] [--only <view,...>] [--glb <model,...>] [--no-glb]
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright-core';

const here = path.dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const arg = (k) => (args.includes(k) ? args[args.indexOf(k) + 1] : null);
const shots = arg('--shots');
const only = arg('--only')?.split(',');
const glbOnly = arg('--glb')?.split(',');
const glbDir = path.resolve(here, '../../assets/models');

const server = http.createServer((req, res) => {
	const p = path.join(here, decodeURIComponent(req.url.split('?')[0]));
	if (!p.startsWith(here) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) return res.writeHead(404).end();
	const type = p.endsWith('.html') ? 'text/html' : p.endsWith('.js') ? 'text/javascript' : 'application/octet-stream';
	res.writeHead(200, { 'content-type': type }).end(fs.readFileSync(p));
});
await new Promise((r) => server.listen(0, r));
const browser = await chromium.launch({
	executablePath: process.env.CHROMIUM ?? '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
	args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'],
});
const page = await browser.newPage({ viewport: { width: 1600, height: 900 } });
page.on('console', (m) => console.log('[page]', m.text()));
page.on('pageerror', (e) => console.log('[page error]', e.message));
await page.goto(`http://localhost:${server.address().port}/index.html`);
await page.waitForFunction('window.ready === true', null, { timeout: 120000 });
const files = fs.readdirSync(path.join(here, 'models')).filter((f) => f.endsWith('.js')).sort();
const { views, models } = await page.evaluate((f) => window.loadModules(f), files);

if (!args.includes('--no-glb')) {
	fs.mkdirSync(glbDir, { recursive: true });
	for (const name of glbOnly ?? models) {
		const { b64, triangles, size } = await page.evaluate((n) => window.exportGlb(n), name);
		fs.writeFileSync(path.join(glbDir, `${name}.glb`), Buffer.from(b64, 'base64'));
		console.log(`${name}.glb: ${triangles} triangles, size ${size.join(' x ')} m`);
	}
}
if (shots) {
	fs.mkdirSync(shots, { recursive: true });
	for (const [name, spec] of Object.entries(views)) {
		if (only && !only.includes(name)) continue;
		const url = await page.evaluate((s) => window.renderView(s), spec);
		fs.writeFileSync(path.join(shots, `${name}.png`), Buffer.from(url.split(',')[1], 'base64'));
		console.log(`shot ${name}`);
	}
}
await browser.close();
server.close();
