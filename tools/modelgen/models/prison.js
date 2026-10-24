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

// What flies in the riot (step 2b), each a few centimeters (the game shows them bigger): a scoop of mash, a jelly
// cube, a chicken drumstick and a yogurt cup.
export function buildMash() {
	const b = new Builder('prison_mash');
	b.add('mash', mat('mash', 0xf1dfa2), ellipsoid(0.045, 0.035, 0.045, 8, 5), { pos: V(0, 0, 0) });
	b.add('mash', mat('mash', 0xf1dfa2), ellipsoid(0.025, 0.02, 0.025, 6, 4), { pos: V(0.015, 0.03, 0.01) });
	return b.build();
}

export function buildJelly() {
	const b = new Builder('prison_jelly');
	b.add('jelly', mat('jelly', 0x5fd34a), new THREE.BoxGeometry(0.06, 0.05, 0.06), { pos: V(0, 0, 0), rot: [0, 0.2, 0] });
	return b.build();
}

export function buildChicken() {
	const meat = mat('chicken', 0xc98a3c), bone = mat('bone', 0xf2ead8);
	const b = new Builder('prison_chicken');
	b.add('chicken', meat, ellipsoid(0.035, 0.03, 0.05, 8, 5), { pos: V(0, 0, -0.01) });
	b.add('chicken', bone, new THREE.CylinderGeometry(0.008, 0.008, 0.05, 5), { pos: V(0, 0, 0.055), rot: [Math.PI / 2, 0, 0] });
	b.add('chicken', bone, ellipsoid(0.013, 0.013, 0.013, 5, 4), { pos: V(0, 0, 0.08) });
	return b.build();
}

export function buildYogurt() {
	const b = new Builder('prison_yogurt');
	b.add('cup', mat('yogurt_cup', 0xf4f4f0), new THREE.CylinderGeometry(0.035, 0.028, 0.07, 8), { pos: V(0, 0, 0) });
	b.add('cup', mat('yogurt_lid', 0xe25b8a), new THREE.CylinderGeometry(0.037, 0.037, 0.005, 8), { pos: V(0, 0.037, 0) });
	return b.build();
}

// What each leaves where it lands: a flat blob with drops around it, lying on +Y (the drumstick just lies there).
function buildSplat(name, color) {
	const goo = mat(`${name}_goo`, color);
	const b = new Builder(name);
	b.add('splat', goo, new THREE.CylinderGeometry(0.09, 0.1, 0.006, 9), { pos: V(0, 0.003, 0) });
	for (let i = 0; i < 6; i++) {
		const a = (i / 6) * Math.PI * 2 + 0.4, r = 0.13 + 0.03 * (i % 2);
		b.add('splat', goo, new THREE.CylinderGeometry(0.02 + 0.01 * (i % 3), 0.025, 0.005, 6),
			{ pos: V(Math.cos(a) * r, 0.003, Math.sin(a) * r) });
	}
	return b.build();
}

// A canteen tray (step 3): steel, with a raised rim and three hollows for the food. 45 cm by 35 cm; its origin in its
// middle, its face up (+Y).
export function buildTray() {
	const steel = mat('tray_steel', 0xb9c1c8), dark = mat('tray_hollow', 0x8d969e);
	const b = new Builder('prison_tray');
	b.add('tray', steel, new THREE.BoxGeometry(0.45, 0.012, 0.35), { pos: V(0, -0.009, 0) });
	for (const [x, z, w, d] of [[0, -0.17, 0.45, 0.012], [0, 0.17, 0.45, 0.012], [-0.22, 0, 0.012, 0.35], [0.22, 0, 0.012, 0.35]]) {
		b.add('tray', steel, new THREE.BoxGeometry(w, 0.03, d), { pos: V(x, 0, z) });
	}
	for (const [x, z, w, d] of [[-0.1, -0.06, 0.2, 0.16], [0.11, -0.06, 0.16, 0.16], [0, 0.09, 0.4, 0.1]]) {
		b.add('tray', dark, new THREE.BoxGeometry(w, 0.004, d), { pos: V(x, -0.001, z) });
	}
	return b.build();
}

// The kitchen's food cart (step 5b): the last ringleader's getaway, rolling downhill. A steel cart on four small
// casters, a lower shelf with a crate of yogurts, two pots of mash on top and the push handle at the back, where the
// ringleader stands on the frame (the inmate's model, set in the game). 1.4 m long; faces +Z like the vehicles. Its
// wheels are part of it.
export function buildFoodCart() {
	const steel = mat('cart_steel', 0xa9b1b8), dark = mat('canteen_leg', 0x4d5359), tire = mat('tire', 0x1a1a1e);
	const pot = mat('pot_steel', 0xa9b1b8), mash = mat('mash', 0xf1dfa2), crate = mat('yogurt_crate', 0x3e7fc4);
	const b = new Builder('food_cart');
	for (const x of [-0.3, 0.3]) {
		for (const z of [-0.6, 0.6]) {
			b.add('wheels', tire, new THREE.CylinderGeometry(0.07, 0.07, 0.05, 10), { pos: V(x, 0.07, z), rot: [0, 0, Math.PI / 2] });
			b.add('frame', dark, new THREE.CylinderGeometry(0.015, 0.015, 0.78, 6), { pos: V(x, 0.53, z) });
		}
	}
	b.add('frame', steel, new THREE.BoxGeometry(0.66, 0.03, 1.3), { pos: V(0, 0.3, 0) });
	b.add('frame', steel, new THREE.BoxGeometry(0.66, 0.03, 1.3), { pos: V(0, 0.9, 0) });
	b.add('frame', dark, new THREE.CylinderGeometry(0.02, 0.02, 0.7, 6), { pos: V(0, 1.12, -0.7), rot: [0, 0, Math.PI / 2] });
	b.add('food', crate, new THREE.BoxGeometry(0.4, 0.2, 0.5), { pos: V(0, 0.42, 0.2) });
	for (const z of [0.3, -0.15]) {
		b.add('food', pot, new THREE.CylinderGeometry(0.2, 0.18, 0.28, 10), { pos: V(0, 1.05, z) });
		b.add('food', mash, ellipsoid(0.18, 0.06, 0.18), { pos: V(0, 1.2, z) });
	}
	return b.build();
}

export const models = {
	food_cart: buildFoodCart,
	prison_tray: buildTray,
	prison_mash: buildMash,
	prison_jelly: buildJelly,
	prison_chicken: buildChicken,
	prison_yogurt: buildYogurt,
	splat_mash: () => buildSplat('splat_mash', 0xf1dfa2),
	splat_jelly: () => buildSplat('splat_jelly', 0x5fd34a),
	splat_yogurt: () => buildSplat('splat_yogurt', 0xf6c6d8),
	canteen_table: buildCanteenTable,
	prison_food_pot: buildFoodPot,
	prison_jelly_tray: buildJellyTray,
};

export const views = {
	food_cart: {
		items: [{ name: 'food_cart', pos: [0, 0, 0], rotY: 0.9 }, { name: 'npc_preso', pos: [-0.65, 0.3, -0.55], rotY: 0.9, scale: 0.85 }],
		cam: { pos: [2.2, 1.6, 2.4], target: [0, 0.7, 0], fov: 40 },
	},
	prison_food: {
		items: [{ name: 'prison_mash', pos: [-0.24, 0.04, 0] }, { name: 'prison_jelly', pos: [-0.08, 0.03, 0] },
			{ name: 'prison_chicken', pos: [0.08, 0.03, 0] }, { name: 'prison_yogurt', pos: [0.24, 0.04, 0] },
			{ name: 'splat_mash', pos: [-0.25, 0, 0.3] }, { name: 'splat_jelly', pos: [0, 0, 0.3] }, { name: 'splat_yogurt', pos: [0.25, 0, 0.3] }],
		cam: { pos: [0, 0.5, 0.9], target: [0, 0.02, 0.15], fov: 40 },
	},
	prison_canteen: {
		items: [{ name: 'canteen_table', pos: [0, 0, 0] }, { name: 'prison_food_pot', pos: [-0.8, 0.79, 0] },
			{ name: 'prison_jelly_tray', pos: [0.6, 0.79, 0.1] }],
		cam: { pos: [1.5, 2.2, 3.4], target: [0, 0.6, 0], fov: 40 },
	},
};
