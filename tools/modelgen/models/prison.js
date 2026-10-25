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

// The ball and chain an inmate off the transfer bus drags along the sidewalk (traslado-presos.md, step 4): an iron ball
// behind them (-Z) on a chain from their right ankle. Origin on the ground at the inmate's feet; they face +Z.
export function buildBallAndChain() {
	const iron = mat('iron_ball', 0x2b2d31), chain = mat('chain', 0x8a8f96);
	const b = new Builder('ball_and_chain');
	b.add('ball', iron, new THREE.SphereGeometry(0.17, 12, 8), { pos: V(0.15, 0.17, -0.85) });
	b.add('chain', chain, new THREE.TorusGeometry(0.06, 0.015, 5, 10), { pos: V(0.1, 0.1, 0), rot: [Math.PI / 2, 0, 0] });
	for (let i = 0; i < 6; i++) {
		const t = (i + 0.5) / 6;
		b.add('chain', chain, new THREE.TorusGeometry(0.045, 0.012, 5, 8),
			{ pos: V(0.1 + 0.05 * t, 0.04, -0.68 * t), rot: [0, i % 2 ? 0 : Math.PI / 2, 0] });
	}
	return b.build();
}

// The prisoner transfer bus (traslado-presos.md, step 1): an old grey bus with an orange stripe and barred windows.
// Faces +Z, origin on the ground in the middle, 10 m long and 2.7 m wide. The driver sits front left (+X) behind the
// windshield, with the front door on the right (-X) and a barred partition behind the cab with a wide gap for the aisle.
// Past it, four rows of two inmate seats with a ring each by the window, and the back door at the end of the aisle.
// The wheels are the car's (separate, so Godot spins them). Placeholder, not final art.
export const BUS = { W: 2.7, F: 5.0, R: -5.0, FLOOR: 0.35, SILL: 1.25, WIN_TOP: 2.35, TOP: 2.95, CAB: 3.0,
	DOOR: [3.3, 4.5], ROWS: [2.0, 0.6, -0.8, -2.2], SEAT_X: 1.0, BACK_DOOR: 0.6 };

export function buildPrisonBus() {
	const body = mat('bus_grey', 0x8a96a4), stripe = mat('bus_orange', 0xe0782a), black = mat('car_black', 0x23252b);
	const bars = mat('bus_bars', 0x2a2d33), seat = mat('bus_seat', 0x6d5a3e), floor = mat('bus_floor', 0x5a5e66);
	const lamp = mat('lamp', 0xfff3c0, { emissive: 0x806a20 }), tail = mat('tail', 0xd01828, { emissive: 0x500810 });
	const ring = mat('bus_ring', 0xb8bec6), glass = mat('truck_glass', 0x2a3340), door = mat('bus_door', 0x5d6876);
	const { W, F, R, FLOOR, SILL, WIN_TOP, TOP, CAB, DOOR, ROWS, SEAT_X, BACK_DOOR } = BUS;
	const b = new Builder('prison_bus');
	const box = (part, m, sx, sy, sz, x, y, z, rot) => b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
	box('body', black, W, 0.2, F - R, 0, FLOOR - 0.1, 0);
	box('body', floor, W - 0.1, 0.02, F - R - 0.1, 0, FLOOR + 0.01, 0);
	box('body', body, W, 0.06, F - R, 0, TOP, 0);
	// The sides: the low panel up to the sill (with the front door's gap on the right), the band over the windows and
	// a pillar between windows; the barred windows themselves.
	const windows = [3.9, ...ROWS, -3.8];
	for (const x of [-1, 1]) {
		const wx = x * (W / 2 - 0.03);
		const runs = x < 0 ? [[R, DOOR[0]], [DOOR[1], F]] : [[R, F]];
		for (const [a, c] of runs) {
			box('body', body, 0.06, SILL - FLOOR, c - a, wx, (SILL + FLOOR) / 2, (a + c) / 2);
			box('body', stripe, 0.02, 0.18, c - a, x * (W / 2 + 0.005), SILL - 0.25, (a + c) / 2);
		}
		box('body', body, 0.06, TOP - WIN_TOP, F - R, wx, (TOP + WIN_TOP) / 2, 0);
		for (let z = R; z <= F + 0.01; z += 0.7) {
			if (x < 0 && z > DOOR[0] - 0.05 && z < DOOR[1] + 0.05) continue;
			box('body', body, 0.07, WIN_TOP - SILL, 0.12, wx, (WIN_TOP + SILL) / 2, Math.min(z, F - 0.06));
		}
		for (const z of windows) {
			if (x < 0 && z > DOOR[0] && z < DOOR[1]) continue;
			for (let k = -3; k <= 3; k++) box('bars', bars, 0.03, WIN_TOP - SILL, 0.03, x * (W / 2 - 0.02), (WIN_TOP + SILL) / 2, z + k * 0.15);
			box('bars', bars, 0.03, 0.04, 1.0, x * (W / 2 - 0.02), (WIN_TOP + SILL) / 2, z);
		}
		for (const z of [3.4, -3.0]) box('body', black, 0.1, 0.55, 1.0, x * (W / 2 + 0.01), FLOOR + 0.12, z);
	}
	// The front door, folded shut: two panels with a window each.
	for (const k of [0, 1]) {
		const z = DOOR[0] + 0.3 + k * 0.6;
		box('doors', door, 0.05, SILL - FLOOR, 0.56, -(W / 2 - 0.03), (SILL + FLOOR) / 2, z);
		box('doors', glass, 0.04, WIN_TOP - SILL - 0.1, 0.5, -(W / 2 - 0.03), (WIN_TOP + SILL) / 2, z);
	}
	// The front: low nose with lights and bumper, the open windshield's frame, the dashboard and the wheel.
	box('body', body, W, 1.0 - FLOOR + 0.1, 0.1, 0, (1.1 + FLOOR) / 2, F - 0.05);
	box('body', body, W, TOP - 2.6, 0.1, 0, (TOP + 2.6) / 2, F - 0.05);
	for (const x of [-1, 1]) box('body', body, 0.12, 2.6 - 1.1, 0.1, x * (W / 2 - 0.06), 1.85, F - 0.05);
	box('body', black, W + 0.06, 0.2, 0.16, 0, FLOOR + 0.05, F + 0.04);
	for (const x of [-1, 1]) box('lights', lamp, 0.34, 0.16, 0.04, x * 0.9, FLOOR + 0.45, F + 0.01);
	box('body', black, W - 0.1, 0.3, 0.45, 0, 1.0, F - 0.3);
	b.add('body', black, new THREE.TorusGeometry(0.22, 0.03, 4, 12), { pos: V(0.75, 1.25, F - 0.6), rot: [-1.0, 0, 0] });
	box('seats', seat, 0.6, 0.15, 0.55, 0.75, FLOOR + 0.4, 3.9);
	box('seats', seat, 0.6, 0.7, 0.12, 0.75, FLOOR + 0.8, 3.55, [-0.15, 0, 0]);
	// The partition behind the cab: bars from the sides to the aisle's gap.
	for (const x of [-1, 1]) {
		for (let k = 0; k < 5; k++) box('bars', bars, 0.04, TOP - FLOOR, 0.04, x * (0.82 + k * 0.12), (TOP + FLOOR) / 2, CAB);
		box('bars', bars, 0.55, 0.05, 0.05, x * 1.075, 1.4, CAB);
	}
	// The inmates' seats: a bench and back per seat by each window, and its ring on the wall.
	for (const z of ROWS) for (const x of [-1, 1]) {
		box('seats', seat, 0.6, 0.12, 0.5, x * SEAT_X, FLOOR + 0.45, z);
		box('seats', bars, 0.06, 0.4, 0.06, x * SEAT_X, FLOOR + 0.2, z);
		box('seats', seat, 0.6, 0.65, 0.1, x * SEAT_X, FLOOR + 0.85, z - 0.3, [-0.12, 0, 0]);
		b.add('rings', ring, new THREE.TorusGeometry(0.07, 0.015, 4, 10), { pos: V(x * (W / 2 - 0.08), FLOOR + 0.75, z + 0.1), rot: [0, Math.PI / 2, 0] });
	}
	// The back: the wall with the back door (a barred window in it), the bumper and the lights.
	for (const x of [-1, 1]) box('body', body, W / 2 - BACK_DOOR, TOP - FLOOR, 0.08, x * (W / 2 + BACK_DOOR) / 2, (TOP + FLOOR) / 2, R + 0.04);
	box('body', body, BACK_DOOR * 2, TOP - 2.45, 0.08, 0, (TOP + 2.45) / 2, R + 0.04);
	box('doors', door, BACK_DOOR * 2 - 0.04, 2.45 - FLOOR, 0.06, 0, (2.45 + FLOOR) / 2, R + 0.03);
	for (let k = -2; k <= 2; k++) box('doors', bars, 0.03, 0.6, 0.03, k * 0.15, 1.85, R - 0.01);
	box('body', black, W + 0.06, 0.2, 0.16, 0, FLOOR + 0.05, R - 0.04);
	for (const x of [-1, 1]) box('lights', tail, 0.3, 0.16, 0.04, x * 0.95, FLOOR + 0.5, R - 0.02);
	return b.build();
}

export const models = {
	prison_bus: buildPrisonBus,
	food_cart: buildFoodCart,
	ball_and_chain: buildBallAndChain,
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
	prison_bus: {
		items: [{ name: 'prison_bus', pos: [0, 0, 0] }, ...[[-1.2, 3.4], [1.2, 3.4], [-1.2, -3.0], [1.2, -3.0]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] })),
			{ name: 'npc_preso', pos: [-1.0, 0.8, 0.6], rotY: 0, scale: 0.85 }, { name: 'cop_0', pos: [-2.6, 0, 3.9], rotY: -1.2 }],
		cam: { pos: [-10.0, 5.0, 9.0], target: [0, 1.3, 0], fov: 40 },
	},
	prison_bus_inside: {
		items: [{ name: 'prison_bus', pos: [0, 0, 0] }, { name: 'npc_preso', pos: [1.0, 0.8, 0.6], scale: 0.85 }, { name: 'npc_preso', pos: [-1.0, 0.8, -0.8], scale: 0.85 }],
		cam: { pos: [0, 2.2, -4.6], target: [0, 1.2, 3.0], fov: 70 },
	},
	food_cart: {
		items: [{ name: 'food_cart', pos: [0, 0, 0], rotY: 0.9 }, { name: 'npc_preso', pos: [-0.65, 0.3, -0.55], rotY: 0.9, scale: 0.85 }],
		cam: { pos: [2.2, 1.6, 2.4], target: [0, 0.7, 0], fov: 40 },
	},
	ball_and_chain: {
		items: [{ name: 'ball_and_chain', pos: [0, 0, 0], rotY: 0.9 }, { name: 'npc_preso', pos: [0, 0, 0], rotY: 0.9, scale: 0.85 }],
		cam: { pos: [2.4, 1.4, 1.4], target: [0, 0.6, -0.3], fov: 40 },
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
