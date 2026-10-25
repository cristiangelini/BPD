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

export const models = {
	...Object.fromEntries(DRESSES.map((_, i) => [`porcelain_doll_${i}`, () => buildPorcelainDoll(i)])),
	plaster_mold: buildPlasterMold,
};

export const views = {
	factory: {
		items: [
			{ name: 'porcelain_doll_0', pos: [-0.25, 0.15, 0] }, { name: 'porcelain_doll_1', pos: [0, 0.15, -0.1] },
			{ name: 'porcelain_doll_2', pos: [0.25, 0.15, 0] }, { name: 'plaster_mold', pos: [0, 0.06, 0.25] },
		],
		cam: { pos: [0, 0.45, 1.0], target: [0, 0.1, 0.05], fov: 36 },
	},
};
