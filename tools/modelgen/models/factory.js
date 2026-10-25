// Small props of the doll factory "Sonrisas" (docs/diseno/fabrica.md): the fragile porcelain dolls of the showcase and
// the plaster molds of the factory floor, with origins at the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// The dresses of the porcelain dolls, one per doll in the showcase.
const DRESSES = [0xe86a9a, 0x7aa8e8, 0xf2d26a, 0x9ad48a, 0xc89ae8, 0xf29a6a];

// A porcelain doll sitting up straight: 0.3 m tall, white face with pink cheeks, curls and a wide dress.
export function buildPorcelainDoll(i) {
	const b = new Builder(`porcelain_doll_${i}`);
	const skin = mat('porcelain', 0xfbf3ec), dress = mat(`doll_dress_${i}`, DRESSES[i]);
	b.add('dress', dress, new THREE.ConeGeometry(0.09, 0.18, 8), { pos: V(0, -0.06, 0) });
	b.add('collar', mat('doll_lace', 0xffffff), new THREE.CylinderGeometry(0.04, 0.05, 0.02, 8), { pos: V(0, 0.035, 0) });
	b.add('head', skin, ellipsoid(0.055, 0.06, 0.055, 8, 6), { pos: V(0, 0.09, 0) });
	b.add('hair', mat('doll_curls', 0xa86a30), ellipsoid(0.062, 0.045, 0.06, 8, 4), { pos: V(0, 0.12, -0.01) });
	for (const s of [-1, 1]) {
		b.add('eyes', mat('doll_eyes', 0x2a5ab0), ellipsoid(0.01, 0.012, 0.006, 5, 3), { pos: V(s * 0.02, 0.095, 0.05) });
		b.add('cheeks', mat('doll_cheeks', 0xf2a0a8), ellipsoid(0.012, 0.008, 0.004, 5, 3), { pos: V(s * 0.03, 0.075, 0.048) });
		b.add('arms', skin, new THREE.CylinderGeometry(0.012, 0.012, 0.09, 5), { pos: V(s * 0.055, -0.0, 0.01), rot: [0, 0, s * 0.35] });
	}
	return b.build();
}

// A plaster mold of half a doll: a white block 0.3 x 0.12 x 0.2 m with the doll's shape sunk in its top.
export function buildPlasterMold() {
	const b = new Builder('plaster_mold');
	const plaster = mat('plaster', 0xeee8dc), inside = mat('plaster_inside', 0xc8c0b0);
	b.add('block', plaster, new THREE.BoxGeometry(0.3, 0.1, 0.2), { pos: V(0, -0.01, 0) });
	b.add('shape', inside, ellipsoid(0.05, 0.012, 0.05, 8, 3), { pos: V(-0.08, 0.04, 0) });
	b.add('shape', inside, ellipsoid(0.1, 0.012, 0.06, 8, 3), { pos: V(0.04, 0.04, 0) });
	b.add('strap', mat('mold_strap', 0xd23a3a), new THREE.BoxGeometry(0.02, 0.105, 0.205), { pos: V(0.12, -0.01, 0) });
	return b.build();
}

// A doll as it rides the belt, before the machines: bare pink plastic, 0.3 m tall, arms out, no face and no hair.
export function buildFactoryDoll() {
	const b = new Builder('factory_doll');
	const plastic = mat('doll_plastic', 0xf6c6b4);
	b.add('body', plastic, ellipsoid(0.055, 0.08, 0.04, 8, 5), { pos: V(0, -0.02, 0) });
	b.add('head', plastic, ellipsoid(0.05, 0.055, 0.05, 8, 5), { pos: V(0, 0.095, 0) });
	for (const s of [-1, 1]) {
		b.add('legs', plastic, new THREE.CylinderGeometry(0.018, 0.016, 0.07, 6), { pos: V(s * 0.025, -0.115, 0) });
		b.add('arms', plastic, new THREE.CylinderGeometry(0.014, 0.012, 0.08, 6), { pos: V(s * 0.075, 0.0, 0), rot: [0, 0, s * 1.0] });
	}
	return b.build();
}

// The jeweler's loupe: a black eyepiece 0.05 m across with its lens. Extra of the diamond doll.
export function buildJewelerLoupe() {
	const b = new Builder('jeweler_loupe');
	b.add('body', mat('loupe_black', 0x1e1e22), new THREE.CylinderGeometry(0.025, 0.02, 0.035, 10), { pos: V(0, 0, 0) });
	b.add('lens', mat('loupe_lens', 0xbfe4f2, { transparent: true, opacity: 0.6 }), new THREE.CylinderGeometry(0.019, 0.019, 0.004, 10), { pos: V(0, 0.018, 0) });
	return b.build();
}

// The delivery list: a typed sheet 0.21 x 0.3 m with a circled line. Extra of the diamond doll.
export function buildDeliveryList() {
	const b = new Builder('delivery_list');
	b.add('sheet', mat('paper', 0xf6f2e6), new THREE.BoxGeometry(0.21, 0.004, 0.3), { pos: V(0, 0, 0) });
	for (let i = 0; i < 8; i++) {
		b.add('lines', mat('ink', 0x3a3a44), new THREE.BoxGeometry(0.15, 0.001, 0.008), { pos: V(-0.01, 0.0025, -0.11 + i * 0.03) });
	}
	b.add('circle', mat('ink_red', 0xd23a3a), new THREE.TorusGeometry(0.03, 0.003, 3, 12), { pos: V(0.06, 0.003, 0.04), rot: [Math.PI / 2, 0, 0], scale: [2.2, 1, 1] });
	return b.build();
}

// The quality control sheet on a clipboard, 0.23 x 0.32 m, with a big "2 kg" in red. The diamond doll's clue.
export function buildQualitySheet() {
	const b = new Builder('quality_sheet');
	b.add('board', mat('clipboard', 0x8a5a30), new THREE.BoxGeometry(0.23, 0.01, 0.32), { pos: V(0, 0, 0) });
	b.add('sheet', mat('paper', 0xf6f2e6), new THREE.BoxGeometry(0.2, 0.002, 0.27), { pos: V(0, 0.006, 0.01) });
	b.add('clip', mat('clip_steel', 0xb8bcc4), new THREE.BoxGeometry(0.08, 0.012, 0.03), { pos: V(0, 0.008, -0.14) });
	for (let i = 0; i < 6; i++) {
		b.add('lines', mat('ink', 0x3a3a44), new THREE.BoxGeometry(0.14, 0.001, 0.008), { pos: V(-0.02, 0.0075, -0.08 + i * 0.03) });
	}
	b.add('mark', mat('ink_red', 0xd23a3a), new THREE.BoxGeometry(0.06, 0.001, 0.04), { pos: V(0.05, 0.0078, 0.1) });
	return b.build();
}

// The tape recorder with the spy dolls' tapes: a grey reel-to-reel case 0.42 x 0.16 x 0.3 m. Main evidence of the spy dolls.
export function buildTapeRecorder() {
	const b = new Builder('tape_recorder');
	b.add('case', mat('recorder_grey', 0x6a6e76), new THREE.BoxGeometry(0.42, 0.12, 0.3), { pos: V(0, -0.02, 0) });
	b.add('panel', mat('recorder_panel', 0x2a2c30), new THREE.BoxGeometry(0.4, 0.01, 0.28), { pos: V(0, 0.045, 0) });
	for (const s of [-1, 1]) {
		b.add('reels', mat('reel_tape', 0x3a2a20), new THREE.CylinderGeometry(0.07, 0.07, 0.02, 14), { pos: V(s * 0.1, 0.06, -0.03) });
		b.add('hubs', mat('reel_hub', 0xd8d8dc), new THREE.CylinderGeometry(0.02, 0.02, 0.025, 8), { pos: V(s * 0.1, 0.062, -0.03) });
	}
	for (let i = 0; i < 4; i++) {
		b.add('keys', mat('recorder_keys', i === 0 ? 0xd23a3a : 0xc8c8cc), new THREE.BoxGeometry(0.05, 0.02, 0.03), { pos: V(-0.09 + i * 0.06, 0.055, 0.1) });
	}
	return b.build();
}

// The box of tiny microphones: a small black box 0.2 x 0.08 x 0.14 m, open, with mics sticking out. Extra of the spy dolls.
export function buildMicBox() {
	const b = new Builder('mic_box');
	b.add('box', mat('mic_box', 0x1e1e22), new THREE.BoxGeometry(0.2, 0.06, 0.14), { pos: V(0, -0.01, 0) });
	for (let i = 0; i < 6; i++) {
		const x = -0.06 + (i % 3) * 0.06, z = -0.03 + Math.floor(i / 3) * 0.06;
		b.add('mics', mat('mic_steel', 0xb8bcc4), new THREE.SphereGeometry(0.012, 6, 4), { pos: V(x, 0.03, z) });
	}
	return b.build();
}

// The client list: a sheet 0.21 x 0.3 m with a "CONFIDENCIAL" red band. Extra of the spy dolls.
export function buildClientList() {
	const b = new Builder('client_list');
	b.add('sheet', mat('paper', 0xf6f2e6), new THREE.BoxGeometry(0.21, 0.004, 0.3), { pos: V(0, 0, 0) });
	b.add('band', mat('ink_red', 0xd23a3a), new THREE.BoxGeometry(0.17, 0.001, 0.03), { pos: V(0, 0.0025, -0.12) });
	for (let i = 0; i < 7; i++) {
		b.add('lines', mat('ink', 0x3a3a44), new THREE.BoxGeometry(0.15, 0.001, 0.008), { pos: V(0, 0.0025, -0.07 + i * 0.03) });
	}
	return b.build();
}

// The astronaut helmet the fake Captain Galaxy dolls wear: a white bubble 0.13 m across with a blue visor, centered
// on the doll's head (origin at the head's middle).
export function buildCaptainHelmet() {
	const b = new Builder('captain_helmet');
	b.add('bubble', mat('helmet_white', 0xf2f2f6), ellipsoid(0.065, 0.068, 0.065, 10, 6), { pos: V(0, 0.005, 0) });
	b.add('visor', mat('helmet_visor', 0x3a6ab8), ellipsoid(0.045, 0.035, 0.02, 8, 4), { pos: V(0, 0.0, 0.055) });
	b.add('antenna', mat('helmet_antenna', 0xd23a3a), new THREE.CylinderGeometry(0.004, 0.004, 0.05, 5), { pos: V(0.035, 0.075, 0) });
	return b.build();
}

// A reject fake Captain Galaxy: the belt doll with the helmet and its face painted crooked (one eye high, the mouth
// slanted). The story's clue, in the reject dumpster.
export function buildRejectCaptain() {
	const b = new Builder('reject_captain');
	const plastic = mat('doll_plastic', 0xf6c6b4);
	b.add('body', mat('captain_suit', 0x8a9ab0), ellipsoid(0.055, 0.08, 0.04, 8, 5), { pos: V(0, -0.02, 0) });
	b.add('head', plastic, ellipsoid(0.05, 0.055, 0.05, 8, 5), { pos: V(0, 0.095, 0) });
	b.add('bubble', mat('helmet_white', 0xf2f2f6, { transparent: true, opacity: 0.45 }), ellipsoid(0.065, 0.068, 0.065, 10, 6), { pos: V(0, 0.1, 0) });
	b.add('eyes', mat('doll_eyes_paint', 0x1e1e22), ellipsoid(0.01, 0.01, 0.005, 5, 3), { pos: V(-0.02, 0.1, 0.047) });
	b.add('eyes', mat('doll_eyes_paint', 0x1e1e22), ellipsoid(0.012, 0.007, 0.005, 5, 3), { pos: V(0.022, 0.125, 0.044) });
	b.add('mouth', mat('doll_mouth_paint', 0xd23a3a), new THREE.BoxGeometry(0.035, 0.006, 0.004), { pos: V(0.005, 0.072, 0.048), rot: [0, 0, 0.45] });
	for (const s of [-1, 1]) {
		b.add('legs', plastic, new THREE.CylinderGeometry(0.018, 0.016, 0.07, 6), { pos: V(s * 0.025, -0.115, 0) });
		b.add('arms', plastic, new THREE.CylinderGeometry(0.014, 0.012, 0.08, 6), { pos: V(s * 0.075, 0.0, 0), rot: [0, 0, s * 1.0] });
	}
	return b.build();
}

// The competitor's stolen mold of Captain Galaxy: a heavy steel mold 0.6 x 0.3 x 0.4 m in two halves bolted shut, with
// the captain's star on top. Main evidence of the fake captain (15 kg).
export function buildStolenMold() {
	const b = new Builder('stolen_mold');
	const steel = mat('mold_steel', 0x8a9098);
	b.add('halves', steel, new THREE.BoxGeometry(0.6, 0.14, 0.4), { pos: V(0, -0.075, 0) });
	b.add('halves', mat('mold_steel_dark', 0x6a7078), new THREE.BoxGeometry(0.6, 0.14, 0.4), { pos: V(0, 0.075, 0) });
	for (const x of [-0.26, 0.26]) for (const z of [-0.16, 0.16]) {
		b.add('bolts', mat('bolt', 0xd8c050), new THREE.CylinderGeometry(0.02, 0.02, 0.03, 6), { pos: V(x, 0.155, z) });
	}
	const star = new THREE.Shape();
	for (let i = 0; i < 10; i++) {
		const r = i % 2 ? 0.045 : 0.1, a = Math.PI / 2 + i * Math.PI / 5;
		if (i === 0) star.moveTo(Math.cos(a) * r, Math.sin(a) * r); else star.lineTo(Math.cos(a) * r, Math.sin(a) * r);
	}
	b.add('star', mat('captain_star', 0xf2c230), new THREE.ExtrudeGeometry(star, { depth: 0.01, bevelEnabled: false }), { pos: V(0, 0.15, 0), rot: [-Math.PI / 2, 0, 0] });
	return b.build();
}

// A roll of fake "Capitán Galaxia" labels: a stack of yellow labels 0.15 x 0.1 x 0.1 m tied with a rubber band.
export function buildFakeLabels() {
	const b = new Builder('fake_labels');
	b.add('stack', mat('label_yellow', 0xf2d040), new THREE.BoxGeometry(0.15, 0.1, 0.1), { pos: V(0, 0, 0) });
	b.add('print', mat('label_blue', 0x3a6ab8), new THREE.BoxGeometry(0.1, 0.06, 0.002), { pos: V(0, 0, 0.051) });
	b.add('band', mat('rubber_band', 0xd23a3a), new THREE.BoxGeometry(0.152, 0.012, 0.102), { pos: V(0, 0, 0) });
	return b.build();
}

// The prototype photos: three snapshots 0.1 x 0.15 m fanned out, of a doll in a helmet.
export function buildPrototypePhotos() {
	const b = new Builder('prototype_photos');
	for (let i = 0; i < 3; i++) {
		b.add('photo', mat('photo_border', 0xf6f6f2), new THREE.BoxGeometry(0.1, 0.002, 0.15), { pos: V(-0.03 + i * 0.03, i * 0.002, 0), rot: [0, -0.3 + i * 0.3, 0] });
		b.add('picture', mat('photo_picture', 0x4a6a9a), new THREE.BoxGeometry(0.08, 0.001, 0.1), { pos: V(-0.03 + i * 0.03, i * 0.002 + 0.0015, -0.01), rot: [0, -0.3 + i * 0.3, 0] });
	}
	return b.build();
}

export const models = {
	captain_helmet: buildCaptainHelmet, reject_captain: buildRejectCaptain, stolen_mold: buildStolenMold,
	fake_labels: buildFakeLabels, prototype_photos: buildPrototypePhotos,
	tape_recorder: buildTapeRecorder, mic_box: buildMicBox, client_list: buildClientList,
	jeweler_loupe: buildJewelerLoupe, delivery_list: buildDeliveryList, quality_sheet: buildQualitySheet,
	factory_doll: buildFactoryDoll,
	...Object.fromEntries(DRESSES.map((_, i) => [`porcelain_doll_${i}`, () => buildPorcelainDoll(i)])),
	plaster_mold: buildPlasterMold,
};

export const views = {
	captain_goods: {
		items: [
			{ name: 'stolen_mold', pos: [-0.25, 0.15, -0.1] }, { name: 'reject_captain', pos: [0.2, 0.15, 0.1] },
			{ name: 'fake_labels', pos: [0.35, 0.05, -0.15] }, { name: 'prototype_photos', pos: [0.0, 0.002, 0.35] },
			{ name: 'captain_helmet', pos: [0.4, 0.07, 0.3] },
		],
		cam: { pos: [0, 0.8, 1.2], target: [0, 0.05, 0.05], fov: 40 },
	},
	spy_goods: {
		items: [
			{ name: 'tape_recorder', pos: [-0.15, 0.08, 0] }, { name: 'mic_box', pos: [0.22, 0.04, 0.05] },
			{ name: 'client_list', pos: [0.05, 0.002, 0.3], rotY: 0.3 },
		],
		cam: { pos: [0, 0.7, 1.0], target: [0, 0.05, 0.1], fov: 40 },
	},
	diamond_goods: {
		items: [
			{ name: 'factory_doll', pos: [-0.2, 0.15, 0] }, { name: 'jeweler_loupe', pos: [0.05, 0.02, 0.1] },
			{ name: 'delivery_list', pos: [0.25, 0.002, 0], rotY: 0.3 }, { name: 'quality_sheet', pos: [0, 0.005, 0.3], rotY: -0.2 },
		],
		cam: { pos: [0, 0.6, 0.9], target: [0, 0.05, 0.1], fov: 40 },
	},
	factory: {
		items: [
			{ name: 'porcelain_doll_0', pos: [-0.25, 0.15, 0] }, { name: 'porcelain_doll_1', pos: [0, 0.15, -0.1] },
			{ name: 'porcelain_doll_2', pos: [0.25, 0.15, 0] }, { name: 'plaster_mold', pos: [0, 0.06, 0.25] }, { name: 'factory_doll', pos: [0.35, 0.15, 0.2] },
		],
		cam: { pos: [0, 0.45, 1.0], target: [0, 0.1, 0.05], fov: 36 },
	},
};
