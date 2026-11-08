// The optician's shop "El Lente Borroso" (docs/diseno/allanamiento-optica.md): the wall display of glasses, the
// turning stand, the glass display case, the try-on mirror, the exam chair, the eye chart, the eye machine, the
// waiting room's chair and magazine table, the lens workbench, the box of empty cases and the giant glasses sign.
// Origins on the floor in the middle of each piece (the sign and the chart: their middle), fronts to +Z. Placeholder,
// not final art.
import { Builder, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), ...(rot ? { rot } : {}) });
}

const FRAMES = [0xd23a3a, 0x1e1e24, 0x2c4f9e, 0xc8a050, 0x3a8a4a, 0xe07ab8];

// A small pair of glasses facing +Z at (x, y, z), `w` wide: two lenses and the bridge, in frame colour `c`.
function glasses(b, x, y, z, w, c) {
	const frame = mat(`frame_${c.toString(16)}`, c), lens = mat('lens', 0xcfe8f4, { metalness: 0.2, roughness: 0.1 });
	const r = w * 0.22;
	for (const s of [-1, 1]) {
		b.add('lens', lens, new THREE.CylinderGeometry(r, r, 0.004, 12), { pos: V(x + s * w * 0.26, y, z), rot: [Math.PI / 2, 0, 0] });
		b.add('rim', frame, new THREE.TorusGeometry(r, w * 0.03, 4, 12), { pos: V(x + s * w * 0.26, y, z) });
		box(b, 'temple', frame, w * 0.02, w * 0.02, w * 0.5, x + s * w * 0.5, y + r * 0.6, z - w * 0.25);
	}
	box(b, 'bridge', frame, w * 0.1, w * 0.03, w * 0.03, x, y + r * 0.3, z);
}

// The wall display 1.2 x 2.0 x 0.35 m: white back and sides, five glass shelves with four pairs each.
export function buildGlassesDisplay() {
	const b = new Builder('glasses_display');
	const white = mat('display_white', 0xf2f0ea), shelf = mat('display_shelf', 0xd8ecf4, { roughness: 0.2 });
	box(b, 'back', white, 1.2, 2.0, 0.04, 0, 1.0, -0.155);
	for (const s of [-1, 1]) box(b, 'side', white, 0.04, 2.0, 0.35, s * 0.58, 1.0, 0);
	box(b, 'base', white, 1.2, 0.1, 0.35, 0, 0.05, 0);
	box(b, 'top', white, 1.2, 0.08, 0.35, 0, 1.96, 0);
	for (let i = 0; i < 5; i++) {
		const y = 0.45 + i * 0.32;
		box(b, 'shelf', shelf, 1.12, 0.02, 0.3, 0, y, 0);
		for (let j = 0; j < 4; j++) glasses(b, -0.39 + j * 0.26, y + 0.06, 0.05, 0.16, FRAMES[(i + j) % FRAMES.length]);
	}
	return b.build();
}

// The turning stand: a round foot, a pole 1.7 m tall and three tiers of arms with a pair on each.
export function buildGlassesCarousel() {
	const b = new Builder('glasses_carousel');
	const chrome = mat('carousel_chrome', 0xc8ccd2, { metalness: 0.7, roughness: 0.3 });
	b.add('foot', chrome, new THREE.CylinderGeometry(0.3, 0.32, 0.05, 16), { pos: V(0, 0.025, 0) });
	b.add('pole', chrome, new THREE.CylinderGeometry(0.025, 0.025, 1.6, 8), { pos: V(0, 0.85, 0) });
	b.add('cap', mat('carousel_cap', 0xd23a3a), new THREE.SphereGeometry(0.06, 10, 8), { pos: V(0, 1.68, 0) });
	for (let t = 0; t < 3; t++) {
		const y = 0.7 + t * 0.35;
		for (let k = 0; k < 6; k++) {
			const a = k * Math.PI / 3 + t * 0.4;
			box(b, 'arm', chrome, 0.24, 0.015, 0.015, Math.cos(a) * 0.12, y, -Math.sin(a) * 0.12, [0, a, 0]);
			const x = Math.cos(a) * 0.26, z = -Math.sin(a) * 0.26;
			b.add('pair', mat(`frame_${FRAMES[(k + t) % 6].toString(16)}`, FRAMES[(k + t) % 6]), new THREE.BoxGeometry(0.14, 0.05, 0.02), { pos: V(x, y - 0.03, z), rot: [0, a + Math.PI / 2, 0] });
		}
	}
	return b.build();
}

// The glass display case 1.4 x 1.0 x 0.6 m: a wooden base, a glass box on top with three pairs on a red cloth.
export function buildDisplayCase() {
	const b = new Builder('display_case');
	const wood = mat('case_wood', 0x6a3e22), glass = mat('case_glass', 0xcfe8f4, { metalness: 0.2, roughness: 0.05 });
	box(b, 'base', wood, 1.4, 0.7, 0.6, 0, 0.35, 0);
	box(b, 'cloth', mat('case_cloth', 0xa82a2a), 1.32, 0.01, 0.52, 0, 0.705, 0);
	box(b, 'glass_front', glass, 1.4, 0.3, 0.01, 0, 0.85, 0.295);
	box(b, 'glass_back', glass, 1.4, 0.3, 0.01, 0, 0.85, -0.295);
	for (const s of [-1, 1]) box(b, 'glass_side', glass, 0.01, 0.3, 0.6, s * 0.695, 0.85, 0);
	box(b, 'glass_top', glass, 1.4, 0.01, 0.6, 0, 1.0, 0);
	for (let i = 0; i < 3; i++) glasses(b, -0.4 + i * 0.4, 0.74, 0.0, 0.2, FRAMES[i * 2]);
	return b.build();
}

// The try-on mirror 0.6 x 1.8 m on a stand, with a small "¿Cómo me queda?" card on top.
export function buildTryMirror() {
	const b = new Builder('try_mirror');
	const white = mat('display_white', 0xf2f0ea), glass = mat('mirror_glass', 0xbcd8e8, { metalness: 0.6, roughness: 0.1 });
	box(b, 'glass', glass, 0.52, 1.3, 0.01, 0, 1.15, 0.02);
	box(b, 'frame', white, 0.6, 1.4, 0.04, 0, 1.15, 0);
	box(b, 'post', white, 0.08, 0.5, 0.08, 0, 0.25, 0);
	box(b, 'foot', white, 0.5, 0.04, 0.4, 0, 0.02, 0);
	box(b, 'card', mat('card_red', 0xd23a3a), 0.3, 0.1, 0.02, 0, 1.92, 0);
	return b.build();
}

// The exam chair: a red padded seat 0.6 m wide at 0.55 m on a chrome column, with arms and a footrest.
export function buildExamChair() {
	const b = new Builder('exam_chair');
	const red = mat('exam_red', 0xa82a2a), chrome = mat('carousel_chrome', 0xc8ccd2, { metalness: 0.7, roughness: 0.3 });
	b.add('foot', chrome, new THREE.CylinderGeometry(0.32, 0.36, 0.06, 16), { pos: V(0, 0.03, 0) });
	b.add('column', chrome, new THREE.CylinderGeometry(0.08, 0.08, 0.4, 10), { pos: V(0, 0.26, 0) });
	box(b, 'seat', red, 0.6, 0.14, 0.6, 0, 0.53, 0);
	box(b, 'back', red, 0.6, 0.8, 0.14, 0, 1.0, -0.28, [-0.12, 0, 0]);
	box(b, 'head', red, 0.34, 0.2, 0.12, 0, 1.48, -0.34);
	for (const s of [-1, 1]) box(b, 'arm', red, 0.1, 0.08, 0.5, s * 0.34, 0.74, 0.0);
	box(b, 'footrest', chrome, 0.44, 0.04, 0.24, 0, 0.2, 0.4, [0.4, 0, 0]);
	return b.build();
}

// The eye chart 0.7 x 1.1 m: a white board with rows of black letters that get smaller, a red line near the bottom.
export function buildEyeChart() {
	const b = new Builder('eye_chart');
	box(b, 'board', mat('chart_white', 0xfafaf4), 0.7, 1.1, 0.02, 0, 0, 0);
	const ink = mat('chart_ink', 0x1e1e24);
	const rows = [[1, 0.16], [2, 0.11], [3, 0.08], [4, 0.06], [5, 0.045], [6, 0.035], [7, 0.025], [8, 0.018]];
	let y = 0.42;
	for (const [n, h] of rows) {
		for (let i = 0; i < n; i++) box(b, 'letter', ink, h * 0.8, h, 0.005, (i - (n - 1) / 2) * h * 1.3, y, 0.012);
		y -= h + 0.04;
	}
	box(b, 'line', mat('chart_red', 0xd23a3a), 0.6, 0.008, 0.005, 0, y + 0.02, 0.012);
	return b.build();
}

// The eye machine: a chrome stand 1.3 m tall with an arm and the big black mask with its two round windows.
export function buildPhoropter() {
	const b = new Builder('phoropter');
	const chrome = mat('carousel_chrome', 0xc8ccd2, { metalness: 0.7, roughness: 0.3 }), black = mat('phoropter_black', 0x2a2a2e);
	b.add('foot', chrome, new THREE.CylinderGeometry(0.22, 0.24, 0.05, 14), { pos: V(0, 0.025, 0) });
	b.add('pole', chrome, new THREE.CylinderGeometry(0.03, 0.03, 1.25, 8), { pos: V(0, 0.65, 0) });
	box(b, 'arm', chrome, 0.05, 0.05, 0.45, 0, 1.25, 0.2);
	box(b, 'mask', black, 0.5, 0.24, 0.12, 0, 1.18, 0.45);
	for (const s of [-1, 1]) {
		b.add('dial', black, new THREE.CylinderGeometry(0.11, 0.11, 0.04, 14), { pos: V(s * 0.15, 1.18, 0.52), rot: [Math.PI / 2, 0, 0] });
		b.add('window', mat('lens', 0xcfe8f4, { metalness: 0.2, roughness: 0.1 }), new THREE.CylinderGeometry(0.03, 0.03, 0.05, 10), { pos: V(s * 0.15, 1.18, 0.53), rot: [Math.PI / 2, 0, 0] });
	}
	return b.build();
}

// The waiting room's chair: green plastic shell on four chrome legs, 0.5 x 0.85 m.
export function buildWaitingChair() {
	const b = new Builder('waiting_chair');
	const green = mat('waiting_green', 0x3a8a6a), chrome = mat('carousel_chrome', 0xc8ccd2, { metalness: 0.7, roughness: 0.3 });
	box(b, 'seat', green, 0.48, 0.05, 0.46, 0, 0.45, 0);
	box(b, 'back', green, 0.48, 0.4, 0.05, 0, 0.68, -0.22, [-0.1, 0, 0]);
	for (const sx of [-1, 1]) for (const sz of [-1, 1]) box(b, 'leg', chrome, 0.025, 0.45, 0.025, sx * 0.21, 0.22, sz * 0.2);
	return b.build();
}

// The magazine table 0.8 x 0.45 x 0.5 m with a messy pile of old magazines.
export function buildMagazineTable() {
	const b = new Builder('magazine_table');
	const wood = mat('case_wood', 0x6a3e22);
	box(b, 'top', wood, 0.8, 0.04, 0.5, 0, 0.43, 0);
	for (const sx of [-1, 1]) for (const sz of [-1, 1]) box(b, 'leg', wood, 0.04, 0.41, 0.04, sx * 0.36, 0.205, sz * 0.21);
	const colors = [0xe07ab8, 0x2c4f9e, 0xf2d23a, 0x3a8a4a];
	for (let i = 0; i < 4; i++) box(b, 'magazine', mat(`mag_${i}`, colors[i]), 0.22, 0.012, 0.3, -0.15 + (i % 2) * 0.28, 0.457 + i * 0.012, (i % 3 - 1) * 0.04, [0, i * 0.35, 0]);
	return b.build();
}

// The lens workbench 3.0 x 0.9 x 0.8 m: a grey top on two cabinets, the lens grinder with its wheel and a lamp.
export function buildLensWorkbench() {
	const b = new Builder('lens_workbench');
	const grey = mat('bench_grey', 0x8a8e94), dark = mat('phoropter_black', 0x2a2a2e);
	box(b, 'top', grey, 3.0, 0.06, 0.8, 0, 0.87, 0);
	for (const s of [-1, 1]) box(b, 'cabinet', mat('bench_blue', 0x4a6a9a), 0.8, 0.84, 0.76, s * 1.05, 0.42, 0);
	box(b, 'grinder', dark, 0.4, 0.3, 0.35, -0.4, 1.05, 0);
	b.add('wheel', grey, new THREE.CylinderGeometry(0.12, 0.12, 0.05, 14), { pos: V(-0.4, 1.12, 0.2), rot: [Math.PI / 2, 0, 0] });
	b.add('lamp_arm', dark, new THREE.CylinderGeometry(0.012, 0.012, 0.5, 6), { pos: V(0.8, 1.15, -0.2), rot: [0, 0, 0.3] });
	b.add('lamp', mat('lamp_bulb', 0xfff4c0, { emissive: 0xffe08a, emissiveIntensity: 0.8 }), new THREE.ConeGeometry(0.1, 0.14, 10, 1, true), { pos: V(0.72, 1.4, -0.2), rot: [Math.PI, 0, 0] });
	return b.build();
}

// A cardboard box of empty glasses cases 0.6 x 0.4 x 0.4 m, open, a few cases sticking out.
export function buildCaseBox() {
	const b = new Builder('case_box');
	const card = mat('box_card', 0xb08a5a);
	box(b, 'bottom', card, 0.6, 0.02, 0.4, 0, 0.01, 0);
	for (const s of [-1, 1]) {
		box(b, 'side', card, 0.6, 0.4, 0.02, 0, 0.2, s * 0.19);
		box(b, 'end', card, 0.02, 0.4, 0.4, s * 0.29, 0.2, 0);
	}
	for (let i = 0; i < 5; i++) box(b, 'case', mat(`frame_${FRAMES[i].toString(16)}`, FRAMES[i]), 0.16, 0.06, 0.07, -0.2 + i * 0.1, 0.38 + (i % 2) * 0.03, (i % 3 - 1) * 0.08, [0, 0, 0.3 * (i % 2 ? 1 : -1)]);
	return b.build();
}

// The giant glasses over the door, 4 m wide: red frame, pale blue lenses.
export function buildGiantGlassesSign() {
	const b = new Builder('giant_glasses_sign');
	const red = mat('frame_d23a3a', 0xd23a3a), lens = mat('lens', 0xcfe8f4, { metalness: 0.2, roughness: 0.1 });
	for (const s of [-1, 1]) {
		b.add('lens', lens, new THREE.CylinderGeometry(0.8, 0.8, 0.06, 24), { pos: V(s * 1.05, 0, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('rim', red, new THREE.TorusGeometry(0.85, 0.1, 8, 24), { pos: V(s * 1.05, 0, 0) });
	}
	box(b, 'bridge', red, 0.4, 0.14, 0.14, 0, 0.3, 0);
	return b.build();
}

// One loose pair of glasses 0.16 m wide, origin in its middle, lenses to +Z: what the turning stand throws and what a
// cop wears while trying a pair on.
export function buildLooseGlasses() {
	const b = new Builder('loose_glasses');
	glasses(b, 0, 0, 0, 0.16, FRAMES[0]);
	return b.build();
}

export const models = {
	glasses_display: buildGlassesDisplay, glasses_carousel: buildGlassesCarousel, display_case: buildDisplayCase,
	try_mirror: buildTryMirror, exam_chair: buildExamChair, eye_chart: buildEyeChart, phoropter: buildPhoropter,
	waiting_chair: buildWaitingChair, magazine_table: buildMagazineTable, lens_workbench: buildLensWorkbench,
	case_box: buildCaseBox, giant_glasses_sign: buildGiantGlassesSign, loose_glasses: buildLooseGlasses,
};

export const views = {
	optician: {
		items: [
			{ name: 'glasses_display', pos: [-2.6, 0, -0.6] }, { name: 'glasses_carousel', pos: [-1.2, 0, 0.4] },
			{ name: 'display_case', pos: [0.4, 0, 0.6] }, { name: 'try_mirror', pos: [1.8, 0, -0.4] },
			{ name: 'exam_chair', pos: [3.0, 0, 0.4] }, { name: 'phoropter', pos: [3.9, 0, -0.4] },
			{ name: 'waiting_chair', pos: [-2.4, 0, 1.6] }, { name: 'magazine_table', pos: [-1.4, 0, 1.8] },
			{ name: 'case_box', pos: [0.0, 0, 2.0] }, { name: 'eye_chart', pos: [1.2, 1.0, -1.4] },
		],
		cam: { pos: [0.6, 3.2, 6.6], target: [0.6, 0.6, 0], fov: 50 },
	},
	optician_big: {
		items: [{ name: 'lens_workbench', pos: [0, 0, 0] }, { name: 'giant_glasses_sign', pos: [0, 3.0, -0.8] }],
		cam: { pos: [0, 2.6, 5.0], target: [0, 1.6, 0], fov: 50 },
	},
	optician_small: {
		items: [{ name: 'loose_glasses', pos: [0, 0.1, 0] }],
		cam: { pos: [0.1, 0.25, 0.4], target: [0, 0.1, 0], fov: 50 },
	},
};
