// The fruit truck traffic control (docs/diseno/control-frutas.md): the fruit seller's little pickup with an open bed,
// the watermelons (whole and broken) and the gold watches hidden in some. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

const black = mat('car_black', 0x23252b), grey = mat('car_grey', 0x6b7280);
const glass = mat('lamp', 0xfff3c0, { emissive: 0x806a20 }), tail = mat('tail', 0xd01828, { emissive: 0x500810 });
const darkGlass = mat('truck_glass', 0x2a3340), wood = mat('crate_wood', 0xc8a064);
const W = 2.1, L = 4.6, FRONT = L / 2, REAR = -L / 2, FLOOR = 0.35, BED = 0.8, BED_F = 0.35;

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// Faces +Z, origin on the ground, 4.6 m long like the traffic cars (Godot adds the wheels). `paint` is white so the
// game tints it per truck; the bed is open, its floor at BED, so the watermelons sit in it. One crate of another
// fruit rides at the front of the bed: crate_bananas, crate_oranges or crate_pineapples (the game shows one).
export function buildFruitTruck() {
	const paint = mat('fruit_paint', 0xf2f2ee);
	const b = new Builder('fruit_truck');
	box(b, 'body', black, W, 0.2, L, 0, FLOOR, 0);
	// The cab: hood and cabin.
	box(b, 'paint', paint, W, 0.6, FRONT - BED_F, 0, FLOOR + 0.4, (FRONT + BED_F) / 2);
	box(b, 'paint', paint, W, 0.7, 1.3, 0, FLOOR + 1.05, BED_F + 0.75);
	box(b, 'body', darkGlass, W - 0.15, 0.45, 0.05, 0, FLOOR + 1.1, BED_F + 1.42, [-0.35, 0, 0]);
	for (const x of [-1, 1]) box(b, 'body', darkGlass, 0.04, 0.4, 0.9, x * (W / 2 + 0.01), FLOOR + 1.15, BED_F + 0.75);
	box(b, 'body', grey, W + 0.06, 0.16, 0.14, 0, FLOOR + 0.05, FRONT + 0.03);
	for (const x of [-1, 1]) box(b, 'lights', glass, 0.32, 0.14, 0.04, x * 0.7, FLOOR + 0.45, FRONT + 0.01);
	// The bed: floor, two sides, the front wall and the tailgate.
	box(b, 'bed', grey, W - 0.1, 0.08, BED_F - REAR, 0, BED, (BED_F + REAR) / 2);
	for (const x of [-1, 1]) box(b, 'paint', paint, 0.08, 0.45, BED_F - REAR, x * (W / 2 - 0.04), BED + 0.25, (BED_F + REAR) / 2);
	box(b, 'paint', paint, W, 0.45, 0.08, 0, BED + 0.25, REAR + 0.04);
	box(b, 'paint', paint, W, 0.45, 0.08, 0, BED + 0.25, BED_F);
	for (const x of [-1, 1]) box(b, 'lights', tail, 0.25, 0.12, 0.04, x * 0.75, FLOOR + 0.4, REAR - 0.01);
	// The crates of other fruit, at the front of the bed on the right.
	const crate = (part) => {
		box(b, part, wood, 0.62, 0.3, 0.46, 0.55, BED + 0.19, BED_F - 0.35);
	};
	crate('crate_bananas');
	const banana = mat('banana', 0xf2d23a);
	for (let i = 0; i < 4; i++) b.add('crate_bananas', banana, new THREE.TorusGeometry(0.12, 0.035, 4, 8, Math.PI * 0.8), { pos: V(0.38 + i * 0.11, BED + 0.38, BED_F - 0.35), rot: [Math.PI / 2, 0, 0.3] });
	crate('crate_oranges');
	const orange = mat('orange_fruit', 0xf08a1a);
	for (let i = 0; i < 6; i++) b.add('crate_oranges', orange, ellipsoid(0.07, 0.07, 0.07, 6, 4), { pos: V(0.35 + (i % 3) * 0.17, BED + 0.38, BED_F - 0.45 + Math.floor(i / 3) * 0.2) });
	crate('crate_pineapples');
	const pine = mat('pineapple', 0xc89a2a), leaf = mat('pineapple_leaf', 0x3a8a2a);
	for (const x of [0.4, 0.7]) {
		b.add('crate_pineapples', pine, ellipsoid(0.09, 0.14, 0.09, 6, 5), { pos: V(x, BED + 0.45, BED_F - 0.35) });
		b.add('crate_pineapples', leaf, new THREE.ConeGeometry(0.06, 0.16, 5), { pos: V(x, BED + 0.65, BED_F - 0.35) });
	}
	return b.build();
}

const rind = mat('watermelon_rind', 0x3e9a3a), stripe = mat('watermelon_stripe', 0x1f5a22);
const flesh = mat('watermelon_flesh', 0xe8384a), seed = mat('watermelon_seed', 0x1a1410);
const R = 0.19, RY = 0.17, RZ = 0.26;

// A whole watermelon, its long axis along Z, origin at its center.
export function buildWatermelon() {
	const b = new Builder('watermelon');
	b.add('rind', rind, ellipsoid(R, RY, RZ, 12, 8));
	for (let i = 0; i < 6; i++) {
		const a = (i / 6) * Math.PI * 2;
		b.add('rind', stripe, ellipsoid(0.035, 0.035, RZ * 1.005, 4, 6), { pos: V(Math.cos(a) * R * 0.86, Math.sin(a) * RY * 0.86, 0) });
	}
	return b.build();
}

// Half a broken watermelon, cut side up, origin at the bottom.
export function buildWatermelonHalf() {
	const b = new Builder('watermelon_half');
	const dome = new THREE.SphereGeometry(1, 12, 6, 0, Math.PI * 2, Math.PI / 2, Math.PI / 2);
	b.add('rind', rind, dome, { pos: V(0, RY, 0), scale: [R, RY, RZ] });
	b.add('flesh', flesh, new THREE.CylinderGeometry(1, 1, 0.02, 12), { pos: V(0, RY, 0), scale: [R * 0.92, 1, RZ * 0.92] });
	for (const [x, z] of [[-0.06, 0.08], [0.05, -0.05], [0.0, 0.14], [0.08, 0.1], [-0.07, -0.12]]) {
		b.add('flesh', seed, ellipsoid(0.012, 0.006, 0.02, 4, 3), { pos: V(x, RY + 0.012, z) });
	}
	return b.build();
}

// A fake gold watch, what's smuggled inside the wanted fruit seller's watermelons.
export function buildGoldWatch() {
	const b = new Builder('gold_watch');
	const gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), face = mat('watch_face', 0xf6f0e0);
	b.add('watch', gold, new THREE.CylinderGeometry(0.035, 0.035, 0.012, 12), { pos: V(0, 0.006, 0) });
	b.add('watch', face, new THREE.CylinderGeometry(0.029, 0.029, 0.002, 12), { pos: V(0, 0.013, 0) });
	b.add('watch', gold, new THREE.BoxGeometry(0.025, 0.006, 0.18), { pos: V(0, 0.004, 0) });
	return b.build();
}

export const models = {
	fruit_truck: buildFruitTruck, watermelon: buildWatermelon, watermelon_half: buildWatermelonHalf,
	gold_watch: buildGoldWatch,
};

export const views = {
	fruit_truck: {
		items: [{ name: 'fruit_truck', pos: [0, 0, 0] }, ...[[-0.3, -0.5], [0.2, -0.9], [-0.2, -1.4], [0.3, -1.6]].map(([x, z]) => ({ name: 'watermelon', pos: [x, 1.02, z] })),
			{ name: 'watermelon_half', pos: [2.2, 0, -1.0] }, { name: 'gold_watch', pos: [2.6, 0, -0.6] }],
		cam: { pos: [3.6, 3.2, -4.6], target: [0.5, 0.8, -0.4], fov: 40 },
	},
};
