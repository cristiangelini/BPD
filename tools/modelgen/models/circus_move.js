// The circus move traffic check (docs/diseno/control-circo.md): the circus's striped truck with a cage on its bed,
// the cage's door, and the animals riding in the cages (Galleta the seal is circus.js's). Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

const black = mat('car_black', 0x23252b), grey = mat('car_grey', 0x6b7280), white = mat('circus_white', 0xf4f2ea);
const glass = mat('lamp', 0xfff3c0, { emissive: 0x806a20 }), tail = mat('tail', 0xd01828, { emissive: 0x500810 });
const darkGlass = mat('truck_glass', 0x2a3340), iron = mat('cage_iron', 0x3a3a40), gold = mat('cage_gold', 0xd8b040);
const straw = mat('cage_straw', 0xe0c060);
const W = 2.1, L = 4.6, FRONT = L / 2, REAR = -L / 2, FLOOR = 0.35, BED = 0.8, BED_F = 0.35;
// The cage on the bed: its floor at BED, this wide, tall and long, its door at the back (-Z).
const CW = 1.9, CH = 1.7, CL = 2.5;

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

function bar(b, part, m, x, y, z, length, axis) {
	const rot = axis === 'x' ? [0, 0, Math.PI / 2] : axis === 'z' ? [Math.PI / 2, 0, 0] : undefined;
	b.add(part, m, new THREE.CylinderGeometry(0.025, 0.025, length, 6), { pos: V(x, y, z), rot });
}

// Faces +Z, origin on the ground, 4.6 m long like the traffic cars (Godot adds the wheels). The cab's stripes are
// `paint` (white, so the game tints them per truck) over a white cab; the bed is a flat platform at BED for the cage.
export function buildCircusTruck() {
	const paint = mat('circus_paint', 0xf2f2ee);
	const b = new Builder('circus_truck');
	box(b, 'body', black, W, 0.2, L, 0, FLOOR, 0);
	box(b, 'cab', white, W, 0.6, FRONT - BED_F, 0, FLOOR + 0.4, (FRONT + BED_F) / 2);
	box(b, 'cab', white, W, 0.08, 1.3, 0, FLOOR + 1.36, BED_F + 0.75);
	box(b, 'cab', white, W, 0.7, 0.1, 0, FLOOR + 1.05, BED_F + 0.15);
	for (const x of [-1, 1]) box(b, 'cab', white, 0.08, 0.7, 0.1, x * (W / 2 - 0.04), FLOOR + 1.05, BED_F + 1.35);
	// The stripes down the hood and along the cab's sides.
	for (let i = 0; i < 4; i++) {
		const z = BED_F + 0.2 + i * 0.45;
		for (const x of [-1, 1]) box(b, 'paint', paint, 0.02, 0.6, 0.2, x * (W / 2 + 0.005), FLOOR + 0.4, z);
	}
	for (const x of [-0.6, 0, 0.6]) box(b, 'paint', paint, 0.25, 0.02, FRONT - BED_F - 1.3, x, FLOOR + 0.71, (FRONT + BED_F + 1.3) / 2);
	box(b, 'body', black, W - 0.2, 0.3, 0.5, 0, FLOOR + 0.85, BED_F + 0.45);
	box(b, 'body', darkGlass, W - 0.15, 0.45, 0.05, 0, FLOOR + 1.1, BED_F + 1.42, [-0.35, 0, 0]);
	box(b, 'body', grey, W + 0.06, 0.16, 0.14, 0, FLOOR + 0.05, FRONT + 0.03);
	for (const x of [-1, 1]) box(b, 'lights', glass, 0.32, 0.14, 0.04, x * 0.7, FLOOR + 0.45, FRONT + 0.01);
	// The flat bed, with a gold trim, and the tail lights.
	box(b, 'bed', grey, W, 0.1, BED_F - REAR, 0, BED - 0.05, (BED_F + REAR) / 2);
	for (const x of [-1, 1]) box(b, 'paint', paint, 0.04, 0.12, BED_F - REAR, x * (W / 2), BED - 0.05, (BED_F + REAR) / 2);
	for (const x of [-1, 1]) box(b, 'lights', tail, 0.25, 0.12, 0.04, x * 0.75, FLOOR + 0.4, REAR - 0.01);
	return b.build();
}

// The cage riding on the bed, origin at its floor's middle: straw on the floor, a striped roof (`paint`), iron bars
// all round and gold knobs on the corners. Its back (-Z) is open: the door is circus_cage_door.
export function buildCircusCage() {
	const paint = mat('circus_paint', 0xf2f2ee);
	const b = new Builder('circus_cage');
	box(b, 'floor', iron, CW, 0.06, CL, 0, 0.03, 0);
	box(b, 'straw', straw, CW - 0.1, 0.05, CL - 0.1, 0, 0.08, 0);
	box(b, 'roof', white, CW + 0.1, 0.08, CL + 0.1, 0, CH, 0);
	for (let i = 0; i < 5; i++) box(b, 'paint', paint, CW + 0.12, 0.1, 0.25, 0, CH, -CL / 2 + 0.25 + i * 0.5);
	for (const x of [-1, 1]) for (const z of [-1, 1]) {
		bar(b, 'bars', iron, x * CW / 2, CH / 2, z * CL / 2, CH);
		b.add('bars', gold, new THREE.SphereGeometry(0.07, 8, 6), { pos: V(x * (CW / 2 + 0.03), CH + 0.08, z * (CL / 2 + 0.03)) });
	}
	for (const x of [-1, 1]) {
		for (let i = 1; i < 8; i++) bar(b, 'bars', iron, x * CW / 2, CH / 2, -CL / 2 + i * CL / 8, CH);
		bar(b, 'bars', iron, x * CW / 2, CH * 0.45, 0, CL, 'z');
	}
	for (let i = 1; i < 6; i++) bar(b, 'bars', iron, -CW / 2 + i * CW / 6, CH / 2, CL / 2, CH);
	bar(b, 'bars', iron, 0, CH * 0.45, CL / 2, CW, 'x');
	return b.build();
}

// The cage's door, hinged at its left edge (x = 0), CW wide: bars, a cross bar and the lock. Origin at the hinge, on
// the floor; closed, it faces -Z.
export function buildCircusCageDoor() {
	const b = new Builder('circus_cage_door');
	for (let i = 0; i <= 6; i++) bar(b, 'bars', iron, i * CW / 6, CH / 2, 0, CH);
	bar(b, 'bars', iron, CW / 2, CH * 0.45, 0, CW, 'x');
	bar(b, 'bars', iron, CW / 2, CH - 0.05, 0, CW, 'x');
	box(b, 'lock', gold, 0.14, 0.18, 0.08, CW - 0.12, CH * 0.45, -0.04);
	return b.build();
}

const C = (name, color) => mat(name, color);

function eyePair(b, y, z, dx, r = 0.035) {
	for (const s of [-1, 1]) {
		b.add('face', white, ellipsoid(r, r, r * 0.6, 6, 4), { pos: V(s * dx, y, z) });
		b.add('face', black, ellipsoid(r * 0.55, r * 0.55, r * 0.4, 6, 4), { pos: V(s * dx, y, z + r * 0.45) });
	}
}

// The animals, sitting, facing +Z, feet at y = 0, each part named so El Peludo's costume (step 4) can show its sneakers
// under the `feet`. Every one fits the cage (under 1.5 m).
export function buildLion() {
	const b = new Builder('animal_lion');
	const fur = C('lion_fur', 0xe0a848), mane = C('lion_mane', 0xa8581e), nose = C('lion_nose', 0x4a2a20);
	b.add('body', fur, ellipsoid(0.38, 0.42, 0.5, 10, 7), { pos: V(0, 0.48, -0.1) });
	b.add('mane', mane, ellipsoid(0.42, 0.42, 0.25, 10, 7), { pos: V(0, 0.98, 0.2) });
	b.add('head', fur, ellipsoid(0.26, 0.26, 0.24, 10, 7), { pos: V(0, 1.0, 0.32) });
	b.add('head', fur, ellipsoid(0.13, 0.1, 0.1, 8, 5), { pos: V(0, 0.92, 0.52) });
	b.add('face', nose, ellipsoid(0.05, 0.035, 0.03, 6, 4), { pos: V(0, 0.97, 0.61) });
	eyePair(b, 1.07, 0.52, 0.1);
	for (const s of [-1, 1]) {
		b.add('head', fur, ellipsoid(0.07, 0.07, 0.04, 6, 4), { pos: V(s * 0.2, 1.24, 0.28) });
		b.add('legs', fur, ellipsoid(0.1, 0.3, 0.1, 6, 5), { pos: V(s * 0.2, 0.3, 0.32) });
		b.add('feet', fur, ellipsoid(0.11, 0.06, 0.15, 6, 4), { pos: V(s * 0.2, 0.05, 0.38) });
		b.add('feet', fur, ellipsoid(0.14, 0.07, 0.2, 6, 4), { pos: V(s * 0.3, 0.06, -0.3) });
	}
	for (let i = 0; i < 5; i++) b.add('tail', fur, ellipsoid(0.04, 0.04, 0.06, 5, 4), { pos: V(0.25 + i * 0.05, 0.1, -0.6 + i * 0.02) });
	b.add('tail', mane, ellipsoid(0.07, 0.07, 0.07, 6, 4), { pos: V(0.52, 0.12, -0.52) });
	return b.build();
}

export function buildBear() {
	const b = new Builder('animal_bear');
	const fur = C('bear_fur', 0x6a4426), snout = C('bear_snout', 0xb08a60), nose = C('bear_nose', 0x1c1410);
	b.add('body', fur, ellipsoid(0.45, 0.5, 0.42, 10, 7), { pos: V(0, 0.55, 0) });
	b.add('body', snout, ellipsoid(0.3, 0.35, 0.1, 10, 6), { pos: V(0, 0.55, 0.34) });
	b.add('head', fur, ellipsoid(0.27, 0.25, 0.25, 10, 7), { pos: V(0, 1.18, 0.08) });
	b.add('head', snout, ellipsoid(0.12, 0.1, 0.12, 8, 5), { pos: V(0, 1.12, 0.3) });
	b.add('face', nose, ellipsoid(0.05, 0.035, 0.03, 6, 4), { pos: V(0, 1.17, 0.41) });
	eyePair(b, 1.25, 0.28, 0.1, 0.03);
	for (const s of [-1, 1]) {
		b.add('head', fur, new THREE.SphereGeometry(0.08, 8, 6), { pos: V(s * 0.2, 1.4, 0.04) });
		b.add('arms', fur, ellipsoid(0.11, 0.3, 0.11, 6, 5), { pos: V(s * 0.42, 0.7, 0.15), rot: [0.3, 0, s * 0.3] });
		b.add('feet', fur, ellipsoid(0.13, 0.11, 0.22, 6, 4), { pos: V(s * 0.25, 0.1, 0.35) });
	}
	return b.build();
}

export function buildGorilla() {
	const b = new Builder('animal_gorilla');
	const fur = C('gorilla_fur', 0x2c2c30), skin = C('gorilla_skin', 0x55504e), chest = C('gorilla_chest', 0x45424a);
	b.add('body', fur, ellipsoid(0.42, 0.5, 0.36, 10, 7), { pos: V(0, 0.62, 0) });
	b.add('body', chest, ellipsoid(0.3, 0.3, 0.1, 10, 6), { pos: V(0, 0.75, 0.28) });
	b.add('head', fur, ellipsoid(0.22, 0.24, 0.22, 10, 7), { pos: V(0, 1.25, 0.12) });
	b.add('head', fur, ellipsoid(0.18, 0.12, 0.16, 8, 5), { pos: V(0, 1.43, 0.05) });
	b.add('face', skin, ellipsoid(0.16, 0.16, 0.08, 8, 6), { pos: V(0, 1.2, 0.3) });
	b.add('face', black, ellipsoid(0.06, 0.025, 0.02, 6, 4), { pos: V(0, 1.14, 0.37) });
	eyePair(b, 1.27, 0.34, 0.07, 0.03);
	for (const s of [-1, 1]) {
		b.add('arms', fur, ellipsoid(0.12, 0.42, 0.12, 6, 5), { pos: V(s * 0.48, 0.5, 0.15), rot: [0.2, 0, s * 0.15] });
		b.add('arms', skin, ellipsoid(0.11, 0.06, 0.13, 6, 4), { pos: V(s * 0.52, 0.06, 0.25) });
		b.add('feet', skin, ellipsoid(0.12, 0.08, 0.2, 6, 4), { pos: V(s * 0.2, 0.06, 0.35) });
	}
	return b.build();
}

export function buildMonkey() {
	const b = new Builder('animal_monkey');
	const fur = C('monkey_fur', 0x8a5a32), skin = C('monkey_skin', 0xe0b890);
	b.add('body', fur, ellipsoid(0.2, 0.26, 0.18, 10, 7), { pos: V(0, 0.32, 0) });
	b.add('head', fur, ellipsoid(0.17, 0.16, 0.16, 10, 7), { pos: V(0, 0.7, 0.04) });
	b.add('face', skin, ellipsoid(0.12, 0.11, 0.06, 8, 6), { pos: V(0, 0.68, 0.16) });
	eyePair(b, 0.72, 0.2, 0.05, 0.025);
	for (const s of [-1, 1]) {
		b.add('head', skin, ellipsoid(0.05, 0.06, 0.03, 6, 4), { pos: V(s * 0.17, 0.72, 0.02) });
		b.add('arms', fur, ellipsoid(0.05, 0.2, 0.05, 6, 5), { pos: V(s * 0.22, 0.3, 0.08) });
		b.add('feet', skin, ellipsoid(0.06, 0.04, 0.1, 6, 4), { pos: V(s * 0.1, 0.04, 0.16) });
	}
	for (let i = 0; i < 8; i++) {
		const a = i / 7 * Math.PI * 1.3;
		b.add('tail', fur, ellipsoid(0.03, 0.03, 0.03, 5, 4), { pos: V(0, 0.05 + Math.sin(a) * 0.25, -0.2 - Math.cos(a) * 0.15 - i * 0.02) });
	}
	return b.build();
}

export function buildZebra() {
	const b = new Builder('animal_zebra');
	const coat = C('zebra_white', 0xf0f0ea), stripe = C('zebra_stripe', 0x1c1c20);
	b.add('body', coat, ellipsoid(0.3, 0.32, 0.55, 10, 7), { pos: V(0, 0.75, -0.1) });
	for (let i = 0; i < 5; i++) b.add('body', stripe, ellipsoid(0.305, 0.325, 0.04, 10, 5), { pos: V(0, 0.75, -0.45 + i * 0.17) });
	b.add('neck', coat, ellipsoid(0.12, 0.3, 0.12, 8, 5), { pos: V(0, 1.1, 0.38), rot: [0.5, 0, 0] });
	b.add('head', coat, ellipsoid(0.11, 0.12, 0.26, 8, 5), { pos: V(0, 1.32, 0.6), rot: [0.3, 0, 0] });
	b.add('head', stripe, ellipsoid(0.04, 0.12, 0.2, 6, 4), { pos: V(0, 1.38, 0.38), rot: [0.5, 0, 0] });
	eyePair(b, 1.4, 0.62, 0.1, 0.025);
	for (const s of [-1, 1]) {
		b.add('head', coat, new THREE.ConeGeometry(0.04, 0.12, 4), { pos: V(s * 0.07, 1.5, 0.48) });
		for (const z of [0.25, -0.45]) {
			b.add('legs', coat, ellipsoid(0.06, 0.28, 0.06, 6, 5), { pos: V(s * 0.17, 0.3, z) });
			b.add('feet', stripe, ellipsoid(0.06, 0.04, 0.07, 6, 4), { pos: V(s * 0.17, 0.03, z) });
		}
	}
	return b.build();
}

export function buildKangaroo() {
	const b = new Builder('animal_kangaroo');
	const fur = C('kangaroo_fur', 0xc08a58), belly = C('kangaroo_belly', 0xe8c8a0);
	b.add('body', fur, ellipsoid(0.3, 0.45, 0.3, 10, 7), { pos: V(0, 0.6, 0) });
	b.add('body', belly, ellipsoid(0.2, 0.25, 0.08, 10, 6), { pos: V(0, 0.5, 0.25) });
	b.add('head', fur, ellipsoid(0.13, 0.15, 0.2, 8, 6), { pos: V(0, 1.15, 0.12) });
	b.add('face', black, ellipsoid(0.03, 0.025, 0.02, 6, 4), { pos: V(0, 1.12, 0.32) });
	eyePair(b, 1.2, 0.24, 0.07, 0.025);
	for (const s of [-1, 1]) {
		b.add('head', fur, ellipsoid(0.04, 0.12, 0.025, 6, 4), { pos: V(s * 0.08, 1.33, 0.05), rot: [0, 0, -s * 0.25] });
		b.add('arms', fur, ellipsoid(0.04, 0.16, 0.04, 6, 4), { pos: V(s * 0.17, 0.75, 0.24), rot: [0.6, 0, 0] });
		b.add('feet', fur, ellipsoid(0.08, 0.06, 0.32, 6, 4), { pos: V(s * 0.15, 0.05, 0.15) });
	}
	for (let i = 0; i < 5; i++) b.add('tail', fur, ellipsoid(0.1 - i * 0.012, 0.1 - i * 0.012, 0.1, 6, 4), { pos: V(0, 0.1, -0.28 - i * 0.14) });
	return b.build();
}

export const models = {
	circus_truck: buildCircusTruck, circus_cage: buildCircusCage, circus_cage_door: buildCircusCageDoor,
	animal_lion: buildLion, animal_bear: buildBear, animal_gorilla: buildGorilla, animal_monkey: buildMonkey,
	animal_zebra: buildZebra, animal_kangaroo: buildKangaroo,
};

export const views = {
	circus_truck: {
		items: [{ name: 'circus_truck', pos: [0, 0, 0] }, { name: 'circus_cage', pos: [0, 0.8, -0.95] },
			{ name: 'circus_cage_door', pos: [-0.95, 0.8, -2.2] }, { name: 'animal_lion', pos: [0, 0.9, -0.95], rotY: Math.PI }],
		cam: { pos: [4.5, 2.6, -5.5], target: [0, 1.2, -0.6], fov: 40 },
	},
	animals: {
		items: [{ name: 'animal_lion', pos: [-3, 0, 0] }, { name: 'animal_bear', pos: [-1.8, 0, 0] },
			{ name: 'animal_gorilla', pos: [-0.6, 0, 0] }, { name: 'animal_monkey', pos: [0.4, 0, 0] },
			{ name: 'animal_zebra', pos: [1.4, 0, 0], rotY: -0.6 }, { name: 'animal_kangaroo', pos: [2.6, 0, 0], rotY: -0.3 }],
		cam: { pos: [0, 1.6, 6.5], target: [0, 0.7, 0], fov: 42 },
	},
};
