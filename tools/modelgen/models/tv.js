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

// A studio camera (step 2): a heavy gray pedestal on 3 wheeled feet, a column, and the camera on top with its lens to
// +Z, a hood, a viewfinder at the back, two pan handles and the red tally light on top (the game lights it when it's
// on air). About 1.75 m tall. Its origin on the ground in the middle.
export function buildCamera() {
	const b = new Builder('tv_camera');
	const gray = mat('tv_cam_gray', 0x6a6e76), dark = mat('tv_console', 0x34363d), black = mat('tv_black', 0x1e1f24);
	const metal = mat('tv_metal', 0xb8bcc2), glass = mat('tv_lens', 0x6fa8dc, { metalness: 0.5, roughness: 0.2 });
	const tally = mat('tv_tally', 0x7a1a1e);
	for (let i = 0; i < 3; i++) {
		const a = (i / 3) * Math.PI * 2 + Math.PI / 6;
		const x = Math.sin(a) * 0.38, z = Math.cos(a) * 0.38;
		box(b, 'base', gray, 0.1, 0.08, 0.42, x / 2, 0.16, z / 2, [0, a, 0]);
		b.add('wheels', black, new THREE.CylinderGeometry(0.07, 0.07, 0.05, 10), { pos: V(x, 0.07, z), rot: [0, a, Math.PI / 2] });
	}
	b.add('base', gray, new THREE.CylinderGeometry(0.12, 0.16, 0.25, 10), { pos: V(0, 0.25, 0) });
	b.add('column', metal, new THREE.CylinderGeometry(0.06, 0.06, 0.95, 8), { pos: V(0, 0.85, 0) });
	b.add('column', gray, new THREE.CylinderGeometry(0.17, 0.17, 0.1, 10), { pos: V(0, 0.75, 0) });
	box(b, 'head', dark, 0.3, 0.1, 0.3, 0, 1.36, 0);
	box(b, 'body', dark, 0.32, 0.34, 0.55, 0, 1.58, 0.0);
	b.add('lens', black, new THREE.CylinderGeometry(0.1, 0.12, 0.4, 12), { pos: V(0, 1.58, 0.47), rot: [Math.PI / 2, 0, 0] });
	b.add('lens', glass, new THREE.CylinderGeometry(0.085, 0.085, 0.02, 12), { pos: V(0, 1.58, 0.675), rot: [Math.PI / 2, 0, 0] });
	box(b, 'hood', black, 0.26, 0.04, 0.16, 0, 1.69, 0.68);
	box(b, 'viewfinder', black, 0.24, 0.18, 0.12, 0, 1.6, -0.33);
	box(b, 'viewfinder', glass, 0.2, 0.14, 0.01, 0, 1.6, -0.395);
	for (const x of [-1, 1]) {
		b.add('handles', metal, new THREE.CylinderGeometry(0.018, 0.018, 0.55, 6), { pos: V(x * 0.14, 1.38, -0.4), rot: [1.15, 0, 0] });
		b.add('handles', black, new THREE.CylinderGeometry(0.03, 0.03, 0.12, 6), { pos: V(x * 0.14, 1.27, -0.65), rot: [1.15, 0, 0] });
	}
	box(b, 'tally', tally, 0.1, 0.05, 0.06, 0, 1.78, 0.2);
	return b.build();
}

// The deputy's teleprompter (step 4): a low black stand with a monitor lying face up and a slanted glass over it that
// reflects the text toward the speaker (to -Z), and its cable with the plug, 1.3 m tall. Its origin on the ground.
export function buildTeleprompter() {
	const b = new Builder('teleprompter');
	const black = mat('tv_black', 0x1e1f24), metal = mat('tv_metal', 0xb8bcc2);
	const glass = mat('prompter_glass', 0xbfe3f0, { transparent: true, opacity: 0.35 }), cable = mat('prompter_cable', 0x2a2a30);
	box(b, 'stand', black, 0.5, 0.04, 0.5, 0, 0.02, 0);
	b.add('stand', metal, new THREE.CylinderGeometry(0.03, 0.03, 1.0, 8), { pos: V(0, 0.52, 0) });
	box(b, 'monitor', black, 0.42, 0.06, 0.32, 0, 1.04, 0.02);
	box(b, 'glass', glass, 0.42, 0.42, 0.01, 0, 1.22, -0.05, [-0.78, 0, 0]);
	for (const x of [-1, 1]) box(b, 'glass', metal, 0.015, 0.3, 0.015, x * 0.21, 1.2, -0.02, [-0.78, 0, 0]);
	box(b, 'cable', cable, 0.025, 0.025, 1.0, 0.1, 0.015, 0.7);
	box(b, 'cable', black, 0.06, 0.04, 0.08, 0.1, 0.03, 1.2);
	return b.build();
}

// A cue card (step 4): a white card 50 x 35 cm on a wooden stick to hold it up, the text is the game's. Its origin at
// the bottom of the stick; the card faces +Z.
export function buildCueCard() {
	const b = new Builder('cue_card');
	const white = mat('tv_white', 0xf2f2ee), wood = mat('card_stick', 0xb07a45), red = mat('tv_red', 0xc8323a);
	b.add('stick', wood, new THREE.CylinderGeometry(0.015, 0.015, 0.5, 6), { pos: V(0, 0.25, 0) });
	box(b, 'card', white, 0.5, 0.35, 0.01, 0, 0.67, 0.01);
	box(b, 'card', red, 0.5, 0.03, 0.012, 0, 0.83, 0.011);
	return b.build();
}

// The spare microphone (step 4): a handheld mic, black with a silver mesh head and the channel's red flag. Its origin
// in its middle, lying along z.
export function buildSpareMic() {
	const b = new Builder('spare_mic');
	const black = mat('tv_black', 0x1e1f24), mesh = mat('mic_mesh', 0xb8bcc2, { metalness: 0.5, roughness: 0.4 }), red = mat('tv_red', 0xc8323a);
	b.add('body', black, new THREE.CylinderGeometry(0.02, 0.016, 0.2, 8), { pos: V(0, 0, -0.04), rot: [Math.PI / 2, 0, 0] });
	b.add('head', mesh, new THREE.SphereGeometry(0.035, 8, 6), { pos: V(0, 0, 0.09) });
	box(b, 'flag', red, 0.06, 0.06, 0.03, 0, 0, 0.04);
	return b.build();
}

export const models = { tv_lectern: buildLectern, tv_anchor_desk: buildAnchorDesk, tv_console: buildConsole,
	makeup_mirror: buildMakeupMirror, tv_camera: buildCamera, teleprompter: buildTeleprompter, cue_card: buildCueCard,
	spare_mic: buildSpareMic };

export const views = {
	tv_studio_props: {
		items: [{ name: 'tv_lectern', pos: [-1.6, 0, 0.5], rotY: 0.3 }, { name: 'tv_anchor_desk', pos: [0.6, 0, -0.5] },
			{ name: 'tv_lectern', pos: [2.8, 0, 0.5], rotY: -0.3 }, { name: 'makeup_mirror', pos: [-3.6, 0, -1.5], rotY: 0.4 },
			{ name: 'tv_console', pos: [6.5, 0, -2.0], rotY: -0.9 }, { name: 'tv_camera', pos: [-0.8, 0, 3.4], rotY: 2.6 },
			{ name: 'tv_camera', pos: [1.8, 0, 3.2], rotY: 3.5 }, { name: 'teleprompter', pos: [3.6, 0, 1.6], rotY: 3.4 },
			{ name: 'cue_card', pos: [-2.6, 0, 2.6], rotY: 0.3 }, { name: 'spare_mic', pos: [0.2, 0.9, 0.2] }],
		cam: { pos: [1.0, 3.2, 8.5], target: [1.2, 0.9, -0.5], fov: 55 },
	},
};
