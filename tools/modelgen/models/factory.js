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

export const models = {
	jeweler_loupe: buildJewelerLoupe, delivery_list: buildDeliveryList, quality_sheet: buildQualitySheet,
	factory_doll: buildFactoryDoll,
	...Object.fromEntries(DRESSES.map((_, i) => [`porcelain_doll_${i}`, () => buildPorcelainDoll(i)])),
	plaster_mold: buildPlasterMold,
};

export const views = {
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
