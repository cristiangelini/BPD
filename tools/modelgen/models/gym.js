// The gym "Hierro Puro" (docs/diseno/infiltracion-gimnasio.md, step 2): its machines. Each faces +Z with its
// origin on the floor at its middle. Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

const black = mat('gym_black', 0x1c1c20), steel = mat('gym_steel', 0x9aa0a8), red = mat('gym_machine_red', 0xc8202a);
const pad = mat('gym_pad', 0x2a2a30);

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// A treadmill: 0.8 m wide, 1.8 m long, its belt 0.2 m up, two posts up to a console at 1.3 m on its front (+Z).
export function buildTreadmill() {
	const b = new Builder('gym_treadmill');
	box(b, 'base', steel, 0.8, 0.14, 1.8, 0, 0.07, 0);
	box(b, 'belt', black, 0.64, 0.03, 1.7, 0, 0.155, 0);
	for (const s of [-1, 1]) box(b, 'posts', steel, 0.06, 1.2, 0.06, s * 0.36, 0.7, 0.8, [-0.15, 0, 0]);
	box(b, 'console', black, 0.76, 0.3, 0.12, 0, 1.3, 0.9, [-0.5, 0, 0]);
	box(b, 'console', mat('gym_screen', 0x40c0ff, { emissive: 0x104060 }), 0.3, 0.12, 0.01, 0, 1.31, 0.85, [-0.5, 0, 0]);
	for (const s of [-1, 1]) box(b, 'rails', red, 0.04, 0.04, 0.6, s * 0.38, 1.0, 0.55);
	return b.build();
}

// A weight bench under its rack, with a barbell resting on top: 0.5 m wide bench, 1.2 m long, the rack 1.2 m wide.
export function buildBench() {
	const b = new Builder('gym_bench');
	box(b, 'bench', pad, 0.35, 0.08, 1.2, 0, 0.45, 0);
	for (const z of [-0.45, 0.45]) box(b, 'legs', steel, 0.3, 0.41, 0.06, 0, 0.205, z);
	for (const s of [-1, 1]) box(b, 'rack', steel, 0.06, 1.15, 0.06, s * 0.55, 0.575, -0.5);
	const bar = new THREE.CylinderGeometry(0.02, 0.02, 1.7, 8);
	b.add('bar', steel, bar, { pos: V(0, 1.12, -0.5), rot: [0, 0, Math.PI / 2] });
	for (const s of [-1, 1]) b.add('plates', black, new THREE.CylinderGeometry(0.22, 0.22, 0.06, 14), { pos: V(s * 0.72, 1.12, -0.5), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// A rack of dumbbells against the wall: 1.8 m wide, two shelves of five pairs each.
export function buildDumbbellRack() {
	const b = new Builder('gym_dumbbell_rack');
	for (const s of [-1, 1]) box(b, 'frame', steel, 0.06, 0.85, 0.5, s * 0.87, 0.425, 0);
	for (const [y, z] of [[0.45, 0.08], [0.8, -0.08]]) {
		box(b, 'shelf', steel, 1.8, 0.04, 0.22, 0, y, z);
		for (let i = 0; i < 5; i++) {
			const x = -0.68 + i * 0.34, r = 0.05 + i * 0.008;
			b.add('bells', i % 2 ? red : black, new THREE.CylinderGeometry(r, r, 0.26, 8), { pos: V(x, y + 0.02 + r, z), rot: [0, 0, Math.PI / 2] });
		}
	}
	return b.build();
}

// A single dumbbell, 0.34 m long, lying on its side: the one the routine has the cops lift (step 3).
export function buildDumbbell() {
	const b = new Builder('gym_dumbbell');
	b.add('bar', steel, new THREE.CylinderGeometry(0.018, 0.018, 0.3, 8), { rot: [0, 0, Math.PI / 2] });
	for (const s of [-1, 1]) b.add('bells', black, new THREE.CylinderGeometry(0.065, 0.065, 0.08, 10), { pos: V(s * 0.13, 0, 0), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// A red punching bag hanging from a chain: the bag from 0.6 to 1.7 m, the chain up to the ceiling at 2.7 m.
export function buildPunchingBag() {
	const b = new Builder('gym_punching_bag');
	b.add('bag', red, new THREE.CylinderGeometry(0.22, 0.22, 1.1, 12), { pos: V(0, 1.15, 0) });
	b.add('bag', black, new THREE.CylinderGeometry(0.225, 0.225, 0.06, 12), { pos: V(0, 1.68, 0) });
	b.add('chain', steel, new THREE.CylinderGeometry(0.015, 0.015, 1.0, 5), { pos: V(0, 2.2, 0) });
	return b.build();
}

// The stolen safe painted black as a 40 kg weight (step 4): a 0.5 m cube, its dial and handle still showing, a white
// band where "40 KG" is painted and a chip where the grey steel shows. Its origin at its middle (it's grabbed).
export function buildSafeWeight() {
	const b = new Builder('gym_safe_weight');
	box(b, 'body', black, 0.5, 0.5, 0.5, 0, 0, 0);
	box(b, 'band', mat('gym_paint_white', 0xf2f2ee), 0.505, 0.1, 0.505, 0, 0.12, 0);
	box(b, 'chip', steel, 0.12, 0.08, 0.01, -0.12, -0.12, 0.251);
	b.add('dial', steel, new THREE.CylinderGeometry(0.06, 0.06, 0.03, 12), { pos: V(0.08, -0.06, 0.26), rot: [Math.PI / 2, 0, 0] });
	box(b, 'handle', steel, 0.03, 0.14, 0.03, -0.16, -0.04, 0.27);
	return b.build();
}

// El Toro's protein shake (step 4): a shaker with a purple shake, a black lid and a rolled map sticking out of it.
// Its origin at its middle (it's grabbed).
export function buildShake() {
	const b = new Builder('gym_shake');
	b.add('cup', mat('gym_shaker', 0xd8d8e0, { opacity: 0.6, transparent: true }), new THREE.CylinderGeometry(0.055, 0.045, 0.18, 10), { pos: V(0, -0.01, 0) });
	b.add('shake', mat('gym_shake_purple', 0x8a3aa8), new THREE.CylinderGeometry(0.05, 0.042, 0.13, 10), { pos: V(0, -0.03, 0) });
	b.add('lid', black, new THREE.CylinderGeometry(0.058, 0.058, 0.03, 10), { pos: V(0, 0.09, 0) });
	b.add('map', mat('gym_map', 0xf0e0a0), new THREE.CylinderGeometry(0.015, 0.015, 0.12, 6), { pos: V(0.02, 0.13, 0), rot: [0, 0, 0.2] });
	return b.build();
}

// A gym bag on the locker room's bench, where the office key is (step 4): a blue duffel with black straps. Its origin
// on the floor.
export function buildGymBag() {
	const b = new Builder('gym_bag');
	b.add('bag', mat('gym_bag_blue', 0x2a4aa8), new THREE.CylinderGeometry(0.15, 0.15, 0.5, 10), { pos: V(0, 0.15, 0), rot: [0, 0, Math.PI / 2] });
	for (const x of [-0.12, 0.12]) b.add('straps', black, new THREE.TorusGeometry(0.155, 0.015, 4, 12), { pos: V(x, 0.15, 0), rot: [0, Math.PI / 2, 0] });
	b.add('handle', black, new THREE.TorusGeometry(0.1, 0.015, 4, 10, Math.PI), { pos: V(0, 0.3, 0) });
	return b.build();
}

export const models = {
	gym_treadmill: buildTreadmill, gym_bench: buildBench, gym_dumbbell_rack: buildDumbbellRack, gym_dumbbell: buildDumbbell,
	gym_punching_bag: buildPunchingBag, gym_safe_weight: buildSafeWeight, gym_shake: buildShake, gym_bag: buildGymBag,
};

export const views = {
	gym_machines: {
		items: [
			{ name: 'gym_treadmill', pos: [-1.8, 0, 0], rotY: 0.5 },
			{ name: 'gym_bench', pos: [0, 0, -0.3], rotY: 0.3 },
			{ name: 'gym_dumbbell_rack', pos: [1.8, 0, -0.6], rotY: -0.3 },
			{ name: 'gym_dumbbell', pos: [1.2, 0.065, 0.8], rotY: 0.6 },
			{ name: 'gym_punching_bag', pos: [3.2, 0, 0.2] },
		],
		cam: { pos: [0.6, 2.4, 5.8], target: [0.6, 0.8, 0], fov: 45 },
	},
	gym_evidence: {
		items: [
			{ name: 'gym_safe_weight', pos: [-0.6, 0.25, 0], rotY: 0.4 },
			{ name: 'gym_shake', pos: [0.3, 0.09, 0.3], rotY: 0.3 },
			{ name: 'gym_bag', pos: [0.9, 0, -0.2], rotY: -0.4 },
		],
		cam: { pos: [0.2, 1.0, 1.8], target: [0.1, 0.2, 0], fov: 45 },
	},
};
