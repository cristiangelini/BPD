// Small props of the pet salon "Pelito Feliz" (docs/diseno/peluqueria.md): the fragile shampoo bottles on its shelves
// and the collars in the reception display, with origins at the middle of each piece; and the dogs, with the origin at
// their feet, facing +Z. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// A shampoo bottle: 0.07 m across, 0.22 m tall, with a pump. Pastel plastic, it shatters like porcelain in the game.
export function buildShampoo() {
	const b = new Builder('shampoo_bottle');
	const plastic = mat('shampoo', 0x8fd3f0), label = mat('shampoo_label', 0xfff2f8), pump = mat('shampoo_pump', 0xffffff);
	b.add('bottle', plastic, new THREE.CylinderGeometry(0.035, 0.038, 0.17, 8), { pos: V(0, -0.025, 0) });
	b.add('bottle', plastic, new THREE.CylinderGeometry(0.018, 0.033, 0.03, 8), { pos: V(0, 0.075, 0) });
	b.add('bottle', label, new THREE.CylinderGeometry(0.0385, 0.0385, 0.07, 8, 1, true, -0.9, 1.8), { pos: V(0, -0.03, 0) });
	b.add('pump', pump, new THREE.CylinderGeometry(0.008, 0.008, 0.03, 5), { pos: V(0, 0.1, 0) });
	b.add('pump', pump, new THREE.BoxGeometry(0.045, 0.012, 0.015), { pos: V(0.012, 0.11, 0) });
	return b.build();
}

// A dog collar on a little stand: red leather with studs and a bone tag. 0.14 m across, 0.13 m tall.
export function buildCollar() {
	const b = new Builder('dog_collar');
	b.add('stand', mat('collar_stand', 0xf4ead8), new THREE.CylinderGeometry(0.03, 0.05, 0.05, 8), { pos: V(0, -0.04, 0) });
	b.add('collar', mat('collar_leather', 0xd23a4a), new THREE.TorusGeometry(0.055, 0.012, 4, 14), { pos: V(0, 0.02, 0) });
	const gold = mat('gold', 0xffd24a);
	for (let i = 0; i < 6; i++) {
		const a = (i / 6) * Math.PI * 2;
		b.add('collar', gold, new THREE.OctahedronGeometry(0.009), { pos: V(Math.cos(a) * 0.055, 0.02 + Math.sin(a) * 0.055, 0.012) });
	}
	b.add('collar', gold, new THREE.BoxGeometry(0.03, 0.012, 0.004), { pos: V(0, -0.045, 0.012) });
	return b.build();
}

// The coats of the salon's dogs: body, ears and tail color, and spots (if any).
const COATS = [
	{ fur: 0xf4efe6, ears: 0xe0d6c4 },
	{ fur: 0x9a6a3a, ears: 0x6a4424 },
	{ fur: 0x2a2420, ears: 0x1a1612 },
	{ fur: 0xd8a848, ears: 0xb8862c },
	{ fur: 0x8a8e94, ears: 0x5e6268 },
	{ fur: 0xf4efe6, ears: 0x2a2420, spots: 0x2a2420 },
];

// A small dog with a pear body (decision 72): round belly, big head, floppy ears, stubby legs and a tail up.
// About 0.5 m tall and 0.6 m long.
export function buildDog(i) {
	const coat = COATS[i];
	const b = new Builder(`dog_${i}`);
	const fur = mat(`dog_fur_${i}`, coat.fur), ears = mat(`dog_ears_${i}`, coat.ears);
	const black = mat('dog_black', 0x141010), white = mat('dog_eye', 0xffffff), pink = mat('dog_tongue', 0xe8708a);
	b.add('body', fur, ellipsoid(0.17, 0.15, 0.24, 12, 8), { pos: V(0, 0.24, -0.02) });
	b.add('body', fur, ellipsoid(0.13, 0.13, 0.13, 10, 6), { pos: V(0, 0.3, 0.14) });
	for (const [x, z] of [[-0.09, 0.12], [0.09, 0.12], [-0.09, -0.15], [0.09, -0.15]]) {
		b.add('legs', fur, new THREE.CylinderGeometry(0.035, 0.04, 0.14, 6), { pos: V(x, 0.07, z) });
		b.add('legs', ears, ellipsoid(0.045, 0.025, 0.06, 6, 3), { pos: V(x, 0.015, z + 0.015) });
	}
	if (coat.spots) {
		const spots = mat(`dog_spots_${i}`, coat.spots);
		for (const [x, y, z] of [[0.12, 0.3, -0.05], [-0.1, 0.33, -0.12], [0.06, 0.37, 0.05]]) b.add('body', spots, ellipsoid(0.06, 0.05, 0.06, 6, 4), { pos: V(x, y, z) });
	}
	b.add('head', fur, ellipsoid(0.13, 0.12, 0.12, 12, 8), { pos: V(0, 0.44, 0.22) });
	b.add('head', fur, ellipsoid(0.07, 0.055, 0.07, 8, 5), { pos: V(0, 0.4, 0.33) });
	b.add('head', black, ellipsoid(0.028, 0.022, 0.02, 6, 4), { pos: V(0, 0.42, 0.395) });
	b.add('head', pink, ellipsoid(0.025, 0.012, 0.03, 6, 3), { pos: V(0.015, 0.365, 0.37), rot: [0.4, 0, 0] });
	for (const s of [-1, 1]) {
		b.add('head', white, ellipsoid(0.028, 0.03, 0.015, 6, 4), { pos: V(s * 0.05, 0.47, 0.32) });
		b.add('head', black, ellipsoid(0.016, 0.018, 0.01, 6, 4), { pos: V(s * 0.05, 0.47, 0.334) });
		b.add('ears', ears, ellipsoid(0.04, 0.09, 0.025, 6, 4), { pos: V(s * 0.12, 0.42, 0.2), rot: [0, 0, s * 0.35] });
	}
	b.add('tail', ears, new THREE.CylinderGeometry(0.02, 0.03, 0.16, 6), { pos: V(0, 0.36, -0.27), rot: [-0.7, 0, 0] });
	return b.build();
}

export const DOG_COATS = COATS.length;

// Fifí, the poodle the lady waits for: white, with pompoms on the head, the tail and the paws, and a pink bow.
export function buildPoodle() {
	const b = new Builder('dog_poodle');
	const fur = mat('poodle_fur', 0xfaf6f0), skin = mat('poodle_skin', 0xf0d8d0), bow = mat('poodle_bow', 0xf060a0);
	const black = mat('dog_black', 0x141010), white = mat('dog_eye', 0xffffff);
	b.add('body', fur, ellipsoid(0.14, 0.13, 0.2, 10, 8), { pos: V(0, 0.27, -0.02) });
	b.add('body', fur, ellipsoid(0.15, 0.15, 0.13, 10, 8), { pos: V(0, 0.33, 0.12) });
	for (const [x, z] of [[-0.08, 0.1], [0.08, 0.1], [-0.08, -0.13], [0.08, -0.13]]) {
		b.add('legs', skin, new THREE.CylinderGeometry(0.025, 0.025, 0.18, 6), { pos: V(x, 0.11, z) });
		b.add('legs', fur, ellipsoid(0.05, 0.05, 0.05, 6, 4), { pos: V(x, 0.04, z) });
	}
	b.add('head', skin, ellipsoid(0.09, 0.09, 0.1, 10, 6), { pos: V(0, 0.48, 0.22) });
	b.add('head', skin, ellipsoid(0.045, 0.04, 0.07, 8, 5), { pos: V(0, 0.45, 0.31) });
	b.add('head', black, ellipsoid(0.022, 0.018, 0.016, 6, 4), { pos: V(0, 0.46, 0.375) });
	b.add('head', fur, ellipsoid(0.1, 0.09, 0.09, 10, 6), { pos: V(0, 0.58, 0.2) });
	b.add('head', bow, ellipsoid(0.05, 0.03, 0.02, 6, 3), { pos: V(0.04, 0.65, 0.25), rot: [0, 0, 0.3] });
	for (const s of [-1, 1]) {
		b.add('head', white, ellipsoid(0.024, 0.026, 0.012, 6, 4), { pos: V(s * 0.04, 0.5, 0.3) });
		b.add('head', black, ellipsoid(0.014, 0.016, 0.008, 6, 4), { pos: V(s * 0.04, 0.5, 0.31) });
		b.add('ears', fur, ellipsoid(0.05, 0.08, 0.05, 6, 4), { pos: V(s * 0.1, 0.45, 0.2) });
	}
	b.add('tail', skin, new THREE.CylinderGeometry(0.015, 0.02, 0.14, 6), { pos: V(0, 0.38, -0.24), rot: [-0.6, 0, 0] });
	b.add('tail', fur, ellipsoid(0.05, 0.05, 0.05, 6, 4), { pos: V(0, 0.44, -0.29) });
	return b.build();
}

export const models = {
	shampoo_bottle: buildShampoo,
	dog_collar: buildCollar,
	...Object.fromEntries(COATS.map((_, i) => [`dog_${i}`, () => buildDog(i)])),
	dog_poodle: buildPoodle,
};

export const views = {
	groomer: {
		items: [{ name: 'shampoo_bottle', pos: [-0.08, 0.11, 0] }, { name: 'dog_collar', pos: [0.1, 0.065, 0] }],
		cam: { pos: [0, 0.2, 0.55], target: [0, 0.08, 0], fov: 40 },
	},
	dogs: {
		items: [...COATS.map((_, i) => ({ name: `dog_${i}`, pos: [(i - 3) * 0.7, 0, 0], rotY: 0.6 })), { name: 'dog_poodle', pos: [2.1, 0, 0], rotY: 0.6 }],
		cam: { pos: [0, 1.0, 4.6], target: [0, 0.3, 0], fov: 34 },
	},
};
