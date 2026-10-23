// The prison (docs/diseno/carcel-motin.md): the canteen's tables and the food on its counter. Placeholder.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// A canteen table (step 1): a long steel top on two T legs, with a bench along each side, all one piece like the
// ones bolted to the floor. 4 m long along X, 2 m across with the benches; its origin on the ground in the middle.
export function buildCanteenTable() {
	const steel = mat('canteen_steel', 0x8d969e), dark = mat('canteen_leg', 0x4d5359), seat = mat('canteen_seat', 0xd2783a);
	const b = new Builder('canteen_table');
	b.add('table', steel, new THREE.BoxGeometry(4.0, 0.06, 0.9), { pos: V(0, 0.76, 0) });
	for (const x of [-1.6, 1.6]) {
		b.add('table', dark, new THREE.BoxGeometry(0.08, 0.73, 0.08), { pos: V(x, 0.365, 0) });
		b.add('table', dark, new THREE.BoxGeometry(0.08, 0.06, 1.9), { pos: V(x, 0.03, 0) });
		for (const z of [-0.75, 0.75]) {
			b.add('table', dark, new THREE.BoxGeometry(0.06, 0.42, 0.06), { pos: V(x, 0.24, z) });
		}
	}
	for (const z of [-0.75, 0.75]) {
		b.add('table', seat, new THREE.BoxGeometry(3.8, 0.05, 0.32), { pos: V(0, 0.46, z) });
	}
	return b.build();
}

// A big pot of mashed potatoes (step 1, where step 2's food comes from): steel, two handles, a heap of purée and
// the ladle stuck in it. 0.5 m across; its origin on its bottom.
export function buildFoodPot() {
	const steel = mat('pot_steel', 0xa9b1b8), mash = mat('mash', 0xf1dfa2);
	const b = new Builder('prison_food_pot');
	b.add('pot', steel, new THREE.CylinderGeometry(0.25, 0.23, 0.36, 10, 1, true), { pos: V(0, 0.18, 0) });
	b.add('pot', steel, new THREE.CylinderGeometry(0.23, 0.23, 0.02, 10), { pos: V(0, 0.01, 0) });
	for (const s of [-1, 1]) {
		b.add('pot', steel, new THREE.TorusGeometry(0.05, 0.012, 4, 8, Math.PI), { pos: V(s * 0.27, 0.3, 0), rot: [Math.PI / 2, s > 0 ? -Math.PI / 2 : Math.PI / 2, 0] });
	}
	b.add('mash', mash, ellipsoid(0.23, 0.08, 0.23, 9, 5), { pos: V(0, 0.33, 0) });
	b.add('ladle', steel, new THREE.CylinderGeometry(0.012, 0.012, 0.45, 5), { pos: V(0.06, 0.5, 0), rot: [0, 0, -0.4] });
	b.add('ladle', steel, ellipsoid(0.05, 0.03, 0.05, 6, 4), { pos: V(-0.02, 0.33, 0) });
	return b.build();
}

// A tray of jelly cubes (step 1): a steel tray with a grid of wobbly green cubes. 0.6 m by 0.4 m; its origin on its
// bottom.
export function buildJellyTray() {
	const steel = mat('pot_steel', 0xa9b1b8), jelly = mat('jelly', 0x5fd34a);
	const b = new Builder('prison_jelly_tray');
	b.add('tray', steel, new THREE.BoxGeometry(0.6, 0.02, 0.4), { pos: V(0, 0.01, 0) });
	for (const [x, z, w, d] of [[0, -0.19, 0.6, 0.02], [0, 0.19, 0.6, 0.02], [-0.29, 0, 0.02, 0.4], [0.29, 0, 0.02, 0.4]]) {
		b.add('tray', steel, new THREE.BoxGeometry(w, 0.05, d), { pos: V(x, 0.035, z) });
	}
	for (let i = 0; i < 4; i++) {
		for (let j = 0; j < 3; j++) {
			b.add('jelly', jelly, new THREE.BoxGeometry(0.11, 0.08 + 0.01 * ((i + j) % 2), 0.1),
				{ pos: V(-0.2 + i * 0.133, 0.06, -0.12 + j * 0.12), rot: [0, 0.08 * ((i * 3 + j) % 3 - 1), 0] });
		}
	}
	return b.build();
}

export const models = {
	canteen_table: buildCanteenTable,
	prison_food_pot: buildFoodPot,
	prison_jelly_tray: buildJellyTray,
};

export const views = {
	prison_canteen: {
		items: [{ name: 'canteen_table', pos: [0, 0, 0] }, { name: 'prison_food_pot', pos: [-0.8, 0.79, 0] },
			{ name: 'prison_jelly_tray', pos: [0.6, 0.79, 0.1] }],
		cam: { pos: [1.5, 2.2, 3.4], target: [0, 0.6, 0], fov: 40 },
	},
};
