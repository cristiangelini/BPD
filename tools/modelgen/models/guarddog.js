// The guard dog's jailbreak (fuga-perro.md): Mordisco, the station's bulldog, with the origin at his feet, facing +Z.
// Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// Mordisco: a huge, chubby bulldog (decision 72, pear body), 0.75 m tall at the head and 1 m long, with a wide jaw,
// drool, a spiked red collar and the cells' key hanging from it (part 'key', hidden once a cop takes it). His part
// 'tail' wags in the game.
export function buildGuardDog() {
	const b = new Builder('guard_dog');
	const fur = mat('bulldog_fur', 0xc89a62), light = mat('bulldog_light', 0xf2e6d0), dark = mat('bulldog_dark', 0x6a4a2c);
	const black = mat('dog_black', 0x141010), white = mat('dog_eye', 0xffffff), pink = mat('dog_tongue', 0xe8708a);
	b.add('body', fur, ellipsoid(0.3, 0.26, 0.4, 14, 10), { pos: V(0, 0.4, -0.05) });
	b.add('body', fur, ellipsoid(0.32, 0.28, 0.24, 12, 8), { pos: V(0, 0.46, 0.2) });
	b.add('body', light, ellipsoid(0.22, 0.2, 0.2, 10, 6), { pos: V(0, 0.36, 0.28) });
	for (const [x, z] of [[-0.18, 0.26], [0.18, 0.26], [-0.17, -0.28], [0.17, -0.28]]) {
		b.add('legs', fur, new THREE.CylinderGeometry(0.07, 0.08, 0.22, 8), { pos: V(x, 0.11, z) });
		b.add('legs', light, ellipsoid(0.08, 0.04, 0.1, 6, 3), { pos: V(x, 0.03, z + 0.03) });
	}
	const head = new THREE.Vector3(0, 0.6, 0.36);
	const at = (x, y, z) => V(head.x + x, head.y + y, head.z + z);
	b.add('head', fur, ellipsoid(0.22, 0.19, 0.18, 12, 8), { pos: at(0, 0.02, 0.06) });
	b.add('head', light, ellipsoid(0.2, 0.11, 0.12, 10, 6), { pos: at(0, -0.08, 0.16) });
	b.add('head', dark, ellipsoid(0.12, 0.07, 0.07, 8, 5), { pos: at(0, 0.0, 0.2) });
	b.add('head', black, ellipsoid(0.05, 0.035, 0.03, 6, 4), { pos: at(0, 0.03, 0.26) });
	b.add('head', pink, ellipsoid(0.05, 0.02, 0.05, 6, 3), { pos: at(0, -0.15, 0.22), rot: [0.3, 0, 0] });
	b.add('head', white, ellipsoid(0.08, 0.05, 0.05, 6, 3), { pos: at(0, -0.12, 0.24) });
	b.add('head', white, new THREE.ConeGeometry(0.018, 0.05, 4), { pos: at(-0.09, -0.08, 0.25), rot: [0, 0, Math.PI] });
	b.add('head', white, new THREE.ConeGeometry(0.018, 0.05, 4), { pos: at(0.09, -0.08, 0.25), rot: [0, 0, Math.PI] });
	b.add('head', mat('drool', 0xbfe4ff), new THREE.CylinderGeometry(0.01, 0.006, 0.12, 4), { pos: at(0.13, -0.22, 0.2) });
	for (const s of [-1, 1]) {
		b.add('head', white, ellipsoid(0.035, 0.035, 0.02, 6, 4), { pos: at(s * 0.09, 0.08, 0.2) });
		b.add('head', black, ellipsoid(0.02, 0.022, 0.012, 6, 4), { pos: at(s * 0.09, 0.08, 0.215) });
		b.add('head', dark, ellipsoid(0.05, 0.015, 0.02, 6, 3), { pos: at(s * 0.09, 0.13, 0.2), rot: [0, 0, s * -0.3] });
		b.add('head', dark, ellipsoid(0.07, 0.05, 0.03, 6, 4), { pos: at(s * 0.19, 0.15, 0.0), rot: [0, 0, s * 0.6] });
	}
	const red = mat('collar_leather', 0xd23a4a), steel = mat('collar_steel', 0xc8ccd2);
	b.add('collar', red, new THREE.TorusGeometry(0.21, 0.03, 5, 16), { pos: V(0, 0.52, 0.32), rot: [Math.PI / 2 - 0.5, 0, 0] });
	for (let i = 0; i < 8; i++) {
		const a = (i / 8) * Math.PI * 2;
		b.add('collar', steel, new THREE.ConeGeometry(0.015, 0.04, 4), {
			pos: V(Math.cos(a) * 0.23, 0.52 + Math.sin(a) * 0.23 * Math.sin(0.5), 0.32 + Math.sin(a) * 0.23 * Math.cos(0.5)),
			rot: [Math.PI / 2 - 0.5, 0, a - Math.PI / 2],
		});
	}
	const gold = mat('key_gold', 0xf2c84a);
	b.add('key', steel, new THREE.TorusGeometry(0.03, 0.006, 4, 10), { pos: V(0, 0.38, 0.47) });
	b.add('key', gold, new THREE.TorusGeometry(0.025, 0.01, 4, 10), { pos: V(0, 0.33, 0.48) });
	b.add('key', gold, new THREE.BoxGeometry(0.016, 0.1, 0.01), { pos: V(0, 0.26, 0.48) });
	b.add('key', gold, new THREE.BoxGeometry(0.03, 0.015, 0.01), { pos: V(0.012, 0.22, 0.48) });
	b.add('tail', fur, new THREE.CylinderGeometry(0.025, 0.04, 0.12, 6), { pos: V(0, 0.5, -0.46), rot: [-0.9, 0, 0] });
	return b.build();
}

// The dog's food (step 2), each with its origin in its middle: a sausage, a slice of ham, a wedge of cheese, a lettuce
// leaf and the guard's sandwich, all small enough to throw through the bars.
export function buildSausage() {
	const b = new Builder('dog_sausage');
	const skin = mat('sausage', 0xb8503a);
	b.add('food', skin, new THREE.CylinderGeometry(0.022, 0.022, 0.14, 8), { rot: [0, 0, Math.PI / 2] });
	for (const s of [-1, 1]) b.add('food', skin, new THREE.SphereGeometry(0.022, 8, 5), { pos: V(s * 0.07, 0, 0) });
	return b.build();
}

export function buildHam() {
	const b = new Builder('dog_ham');
	b.add('food', mat('ham', 0xf09aa0), new THREE.CylinderGeometry(0.06, 0.06, 0.012, 12));
	b.add('food', mat('ham_fat', 0xfbe8e0), new THREE.TorusGeometry(0.058, 0.006, 3, 12), { rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

export function buildCheese() {
	const b = new Builder('dog_cheese');
	const cheese = mat('cheese', 0xf6cc40), hole = mat('cheese_hole', 0xd8a820);
	b.add('food', cheese, new THREE.CylinderGeometry(0.08, 0.08, 0.05, 3, 1, false, 0, Math.PI / 3), { pos: V(-0.03, 0, -0.03) });
	b.add('food', hole, new THREE.SphereGeometry(0.008, 5, 3), { pos: V(0.0, 0.026, 0.02) });
	return b.build();
}

export function buildLettuce() {
	const b = new Builder('dog_lettuce');
	b.add('food', mat('lettuce', 0x7ad05a), ellipsoid(0.07, 0.012, 0.09, 8, 3));
	b.add('food', mat('lettuce_vein', 0xc8f0a0), new THREE.BoxGeometry(0.008, 0.004, 0.15), { pos: V(0, 0.01, 0) });
	return b.build();
}

export function buildSandwich() {
	const b = new Builder('dog_sandwich');
	const bread = mat('bread', 0xe8c890), crust = mat('crust', 0xb07a40);
	for (const y of [-0.025, 0.025]) b.add('food', bread, new THREE.BoxGeometry(0.12, 0.018, 0.12), { pos: V(0, y, 0) });
	b.add('food', mat('ham', 0xf09aa0), new THREE.BoxGeometry(0.13, 0.01, 0.13), { pos: V(0, -0.01, 0) });
	b.add('food', mat('cheese', 0xf6cc40), new THREE.BoxGeometry(0.125, 0.01, 0.125), { pos: V(0, 0.004, 0) });
	b.add('food', mat('lettuce', 0x7ad05a), new THREE.BoxGeometry(0.135, 0.006, 0.12), { pos: V(0.005, 0.012, 0) });
	b.add('food', crust, new THREE.BoxGeometry(0.122, 0.006, 0.122), { pos: V(0, 0.036, 0) });
	return b.build();
}

// The break room's fridge (step 2): white, 0.7 x 1.7 x 0.65 m with the door left wide open (hinged on its right, +X) and the light
// on, three shelves at 0.45, 0.85 and 1.25 m. Origin at its feet, facing +Z.
export function buildFridge() {
	const b = new Builder('dog_fridge');
	const white = mat('fridge_white', 0xf2f4f6), inside = mat('fridge_inside', 0xdfe8f0), glass = mat('fridge_shelf', 0xbfe4ff);
	b.add('body', white, new THREE.BoxGeometry(0.7, 0.04, 0.65), { pos: V(0, 0.02, 0) });
	b.add('body', white, new THREE.BoxGeometry(0.7, 0.04, 0.65), { pos: V(0, 1.68, 0) });
	for (const x of [-0.33, 0.33]) b.add('body', white, new THREE.BoxGeometry(0.04, 1.7, 0.65), { pos: V(x, 0.85, 0) });
	b.add('body', inside, new THREE.BoxGeometry(0.62, 1.62, 0.02), { pos: V(0, 0.85, -0.31) });
	for (const y of [0.45, 0.85, 1.25]) b.add('shelves', glass, new THREE.BoxGeometry(0.62, 0.01, 0.58), { pos: V(0, y, 0) });
	b.add('light', mat('fridge_light', 0xfff6c0), new THREE.BoxGeometry(0.1, 0.03, 0.05), { pos: V(0, 1.64, -0.2) });
	b.add('door', white, new THREE.BoxGeometry(0.05, 1.7, 0.7), { pos: V(0.37, 0.85, 0.68) });
	b.add('door', mat('fridge_handle', 0x8a9098), new THREE.BoxGeometry(0.03, 0.4, 0.03), { pos: V(0.41, 1.0, 0.95) });
	return b.build();
}

export const models = {
	guard_dog: buildGuardDog, dog_sausage: buildSausage, dog_ham: buildHam, dog_cheese: buildCheese,
	dog_lettuce: buildLettuce, dog_sandwich: buildSandwich, dog_fridge: buildFridge,
};

export const views = {
	guard_dog: {
		items: [{ name: 'guard_dog', pos: [0, 0, 0], rotY: 0.6 }, { name: 'cop_1', pos: [1.0, 0, -0.3], rotY: -0.4 }],
		cam: { pos: [0.6, 1.2, 2.8], target: [0.4, 0.5, 0], fov: 40 },
	},
	dog_food: {
		items: [
			{ name: 'dog_fridge', pos: [0, 0, -0.5] },
			{ name: 'dog_sausage', pos: [-0.15, 0.48, -0.4] },
			{ name: 'dog_ham', pos: [0.12, 0.47, -0.4] },
			{ name: 'dog_cheese', pos: [-0.1, 0.88, -0.4] },
			{ name: 'dog_lettuce', pos: [0.15, 0.87, -0.4] },
			{ name: 'prison_tray', pos: [-1.0, 0.03, 0.2] },
			{ name: 'dog_sausage', pos: [-1.1, 0.06, 0.15] },
			{ name: 'dog_lettuce', pos: [-0.88, 0.05, 0.25] },
			{ name: 'dog_sandwich', pos: [1.1, 0.05, 0.3] },
			{ name: 'guard_dog', pos: [0.4, 0, 0.9], rotY: -2.4 },
		],
		cam: { pos: [0, 1.4, 3.0], target: [0, 0.5, 0], fov: 45 },
	},
};
