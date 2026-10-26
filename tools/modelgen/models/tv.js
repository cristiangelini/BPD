// The TV debate (docs/diseno/politico-debate.md): the lecterns, the moderator's desk, the control room's console and the
// makeup mirror. Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// A candidate's lectern (step 1): a slanted blue front with a white star stripe, a gooseneck mic and a little glass
// of water on the top, 1.15 m tall, facing +Z. Its origin on the ground in the middle.
export function buildLectern() {
	const b = new Builder('tv_lectern');
	const blue = mat('tv_blue', 0x2b4f9a), white = mat('tv_white', 0xf2f2ee), black = mat('tv_black', 0x1e1f24);
	const metal = mat('tv_metal', 0xb8bcc2), glass = mat('tv_glass', 0xbfe3f0, { transparent: true, opacity: 0.5 });
	box(b, 'body', blue, 0.7, 1.05, 0.5, 0, 0.525, 0);
	box(b, 'body', blue, 0.8, 0.05, 0.6, 0, 1.12, 0.02, [-0.25, 0, 0]);
	box(b, 'body', black, 0.8, 0.08, 0.6, 0, 0.04, 0);
	box(b, 'stripe', white, 0.72, 0.12, 0.02, 0, 0.75, 0.255);
	for (const x of [-0.2, 0, 0.2]) box(b, 'stripe', blue, 0.05, 0.05, 0.025, x, 0.75, 0.26, [0, 0, Math.PI / 4]);
	b.add('mic', metal, new THREE.CylinderGeometry(0.008, 0.008, 0.35, 6), { pos: V(0.2, 1.3, 0.1), rot: [0.5, 0, 0] });
	b.add('mic', black, new THREE.CylinderGeometry(0.02, 0.015, 0.07, 8), { pos: V(0.2, 1.45, 0.2), rot: [1.1, 0, 0] });
	b.add('glass', glass, new THREE.CylinderGeometry(0.035, 0.03, 0.1, 8), { pos: V(-0.25, 1.2, 0.0) });
	return b.build();
}

// The moderator's desk (step 1): a curved red desk on a silver base with the channel's white stripe, a laptop and a
// pile of question cards, 2.4 m wide (x), facing +Z. Its origin on the ground in the middle.
export function buildAnchorDesk() {
	const b = new Builder('tv_anchor_desk');
	const red = mat('tv_red', 0xc8323a), white = mat('tv_white', 0xf2f2ee), metal = mat('tv_metal', 0xb8bcc2);
	const black = mat('tv_black', 0x1e1f24), card = mat('tv_card', 0xf6e8b0);
	box(b, 'base', metal, 2.2, 0.08, 0.7, 0, 0.04, 0);
	box(b, 'body', red, 2.4, 0.7, 0.12, 0, 0.43, 0.3);
	for (const x of [-1, 1]) box(b, 'body', red, 0.12, 0.7, 0.7, x * 1.14, 0.43, 0.0, [0, x * 0.3, 0]);
	box(b, 'body', white, 2.42, 0.08, 0.13, 0, 0.55, 0.31);
	box(b, 'top', metal, 2.5, 0.05, 0.85, 0, 0.8, 0.0);
	box(b, 'laptop', black, 0.36, 0.02, 0.26, 0.6, 0.835, -0.05);
	box(b, 'laptop', black, 0.36, 0.24, 0.02, 0.6, 0.95, -0.18, [-0.2, 0, 0]);
	box(b, 'cards', card, 0.2, 0.04, 0.14, -0.5, 0.845, 0.05, [0, 0.2, 0]);
	return b.build();
}

// The control room's console (step 1): a long dark desk 8 m long (z) with rows of colored buttons, faders and 5
// little monitors on a shelf, its operators' side to +X. Its origin on the ground in the middle.
export function buildConsole() {
	const b = new Builder('tv_console');
	const dark = mat('tv_console', 0x34363d), black = mat('tv_black', 0x1e1f24), screen = mat('tv_screen', 0x3a6ea8);
	const red = mat('tv_red', 0xc8323a), green = mat('tv_green', 0x3fae55), yellow = mat('tv_yellow', 0xe8c040);
	const L = 8;
	box(b, 'desk', dark, 1.0, 0.8, L, 0, 0.4, 0);
	box(b, 'desk', black, 1.1, 0.06, L + 0.1, 0.05, 0.83, 0, [0, 0, -0.12]);
	box(b, 'shelf', dark, 0.35, 0.5, L, -0.35, 1.1, 0);
	const colors = [red, green, yellow];
	for (let i = 0; i < 20; i++) {
		const z = -L / 2 + 0.4 + i * ((L - 0.8) / 19);
		for (let row = 0; row < 3; row++) box(b, 'buttons', colors[(i + row) % 3], 0.07, 0.04, 0.07, 0.25 - row * 0.15, 0.87 + row * 0.02, z);
	}
	for (let i = 0; i < 10; i++) box(b, 'faders', black, 0.2, 0.05, 0.04, 0.35, 0.86, -L / 2 + 0.6 + i * 0.75);
	for (let i = 0; i < 5; i++) {
		const z = -L / 2 + 0.9 + i * ((L - 1.8) / 4);
		box(b, 'monitors', black, 0.1, 0.5, 0.8, -0.35, 1.6, z);
		box(b, 'monitors', screen, 0.01, 0.42, 0.7, -0.295, 1.6, z);
	}
	return b.build();
}

// The makeup mirror (step 1): a mirror framed by round bulbs on a white table with a brush, a powder puff and a can of
// hairspray, 1.4 m wide (x), facing +Z. Its origin on the ground in the middle.
export function buildMakeupMirror() {
	const b = new Builder('makeup_mirror');
	const white = mat('tv_white', 0xf2f2ee), mirror = mat('makeup_glass', 0xcfe2ea, { metalness: 0.6, roughness: 0.15 });
	const bulb = mat('makeup_bulb', 0xfff2c0, { emissive: 0xfff2c0 }), pink = mat('makeup_pink', 0xf0a0b8);
	const black = mat('tv_black', 0x1e1f24);
	box(b, 'table', white, 1.4, 0.05, 0.5, 0, 0.75, 0);
	for (const x of [-0.65, 0.65]) box(b, 'table', white, 0.05, 0.75, 0.45, x, 0.375, 0);
	box(b, 'mirror', white, 1.1, 0.9, 0.04, 0, 1.3, -0.22);
	box(b, 'mirror', mirror, 0.95, 0.75, 0.01, 0, 1.3, -0.195);
	for (let i = 0; i < 5; i++) {
		b.add('bulbs', bulb, new THREE.SphereGeometry(0.04, 8, 6), { pos: V(-0.45 + i * 0.225, 1.77, -0.19) });
		for (const x of [-0.53, 0.53]) b.add('bulbs', bulb, new THREE.SphereGeometry(0.04, 8, 6), { pos: V(x, 0.92 + i * 0.19, -0.19) });
	}
	b.add('puff', pink, new THREE.SphereGeometry(0.06, 8, 5), { pos: V(0.3, 0.79, 0.05), scale: [1, 0.4, 1] });
	b.add('spray', pink, new THREE.CylinderGeometry(0.035, 0.035, 0.22, 8), { pos: V(-0.4, 0.89, 0.0) });
	box(b, 'brush', black, 0.02, 0.02, 0.18, 0.05, 0.79, 0.08, [0, 0.4, 0]);
	return b.build();
}

export const models = { tv_lectern: buildLectern, tv_anchor_desk: buildAnchorDesk, tv_console: buildConsole,
	makeup_mirror: buildMakeupMirror };

export const views = {
	tv_studio_props: {
		items: [{ name: 'tv_lectern', pos: [-1.6, 0, 0.5], rotY: 0.3 }, { name: 'tv_anchor_desk', pos: [0.6, 0, -0.5] },
			{ name: 'tv_lectern', pos: [2.8, 0, 0.5], rotY: -0.3 }, { name: 'makeup_mirror', pos: [-3.6, 0, -1.5], rotY: 0.4 },
			{ name: 'tv_console', pos: [6.5, 0, -2.0], rotY: -0.9 }],
		cam: { pos: [1.0, 3.2, 8.5], target: [1.2, 0.9, -0.5], fov: 55 },
	},
};
