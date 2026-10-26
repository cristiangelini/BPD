// The restaurant's kitchen (docs/diseno/infiltracion-restaurante.md, step 3): the ingredients, the pot, the frying pan,
// the plate and the crates the ingredients come from. Ingredients and dishes have their origin at their middle (they're
// grabbed); the crates on the floor. Shown a bit bigger than real, so they read from across the kitchen. Placeholder.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

const steel = mat('kitchen_steel', 0xb8bcc4), black = mat('kitchen_black', 0x26262a), wood = mat('crate_wood', 0xb08850);
const tomatoRed = mat('food_tomato', 0xd8302a), stem = mat('food_stem', 0x3a8a2a), onionSkin = mat('food_onion', 0xd8b880);
const lettuceGreen = mat('food_lettuce', 0x6ac040), fishBlue = mat('food_fish', 0x8aa8c0), pastaYellow = mat('food_pasta', 0xf0d890);

function tomato(b, x = 0, y = 0, z = 0) {
	b.add('tomato', tomatoRed, ellipsoid(0.07, 0.06, 0.07, 10, 6), { pos: V(x, y, z) });
	b.add('stem', stem, new THREE.CylinderGeometry(0.015, 0.03, 0.02, 5), { pos: V(x, y + 0.06, z) });
}

function onion(b, x = 0, y = 0, z = 0) {
	b.add('onion', onionSkin, ellipsoid(0.065, 0.07, 0.065, 10, 6), { pos: V(x, y, z) });
	b.add('onion', onionSkin, new THREE.ConeGeometry(0.02, 0.05, 5), { pos: V(x, y + 0.08, z) });
}

function lettuce(b, x = 0, y = 0, z = 0) {
	b.add('lettuce', lettuceGreen, ellipsoid(0.1, 0.08, 0.1, 10, 6), { pos: V(x, y, z) });
	for (let i = 0; i < 5; i++) {
		const a = (i / 5) * Math.PI * 2;
		b.add('lettuce', mat('food_lettuce_light', 0x9ad860), ellipsoid(0.06, 0.05, 0.02, 6, 4), { pos: V(x + Math.cos(a) * 0.07, y + 0.02, z + Math.sin(a) * 0.07), rot: [0, -a, 0.4] });
	}
}

function fish(b, x = 0, y = 0, z = 0) {
	b.add('fish', fishBlue, ellipsoid(0.15, 0.05, 0.035, 10, 6), { pos: V(x, y, z) });
	b.add('fish', fishBlue, new THREE.ConeGeometry(0.06, 0.08, 4), { pos: V(x - 0.18, y, z), rot: [0, 0, Math.PI / 2] });
	b.add('eye', black, new THREE.SphereGeometry(0.01, 5, 3), { pos: V(x + 0.11, y + 0.015, z + 0.03) });
}

function pasta(b, x = 0, y = 0, z = 0) {
	b.add('pasta', mat('food_pasta_paper', 0x3a6ab8), new THREE.CylinderGeometry(0.035, 0.035, 0.08, 8), { pos: V(x, y, z), rot: [0, 0, Math.PI / 2] });
	for (let i = 0; i < 7; i++) {
		const a = (i / 7) * Math.PI * 2;
		b.add('pasta', pastaYellow, new THREE.CylinderGeometry(0.006, 0.006, 0.26, 4), { pos: V(x, y + Math.cos(a) * 0.02, z + Math.sin(a) * 0.02), rot: [0, 0, Math.PI / 2] });
	}
}

const FOOD = { tomato, onion, lettuce, fish, pasta };

function single(kind) {
	return () => {
		const b = new Builder(`food_${kind}`);
		FOOD[kind](b);
		return b.build();
	};
}

// A crate on the floor full of one ingredient: 0.6 x 0.3 x 0.4 m.
function crate(kind) {
	return () => {
		const b = new Builder(`kitchen_crate_${kind}`);
		b.add('crate', wood, new THREE.BoxGeometry(0.6, 0.04, 0.4), { pos: V(0, 0.02, 0) });
		for (const s of [-1, 1]) {
			b.add('crate', wood, new THREE.BoxGeometry(0.6, 0.26, 0.03), { pos: V(0, 0.15, s * 0.185) });
			b.add('crate', wood, new THREE.BoxGeometry(0.03, 0.26, 0.4), { pos: V(s * 0.285, 0.15, 0) });
		}
		const spots = kind === 'fish' || kind === 'pasta' ? [[-0.12, 0.1], [0.1, -0.08], [0.05, 0.1]] : [[-0.18, -0.1], [0, -0.1], [0.18, -0.1], [-0.18, 0.1], [0, 0.1], [0.18, 0.1]];
		for (const [x, z] of spots) FOOD[kind](b, x, 0.25, z);
		return b.build();
	};
}

// The soup pot: 0.4 m wide, 0.3 m tall, open, with two handles. Its origin at its middle.
export function buildPot() {
	const b = new Builder('kitchen_pot');
	b.add('pot', steel, new THREE.CylinderGeometry(0.2, 0.18, 0.3, 14, 1, true));
	b.add('pot', steel, new THREE.CylinderGeometry(0.18, 0.18, 0.02, 14), { pos: V(0, -0.14, 0) });
	for (const s of [-1, 1]) b.add('handles', black, new THREE.TorusGeometry(0.045, 0.012, 4, 8, Math.PI), { pos: V(s * 0.22, 0.1, 0), rot: [Math.PI / 2, 0, s * Math.PI / 2] });
	return b.build();
}

// The frying pan: 0.4 m wide, low, with a long handle to +X. Its origin at its middle.
export function buildPan() {
	const b = new Builder('kitchen_pan');
	b.add('pan', black, new THREE.CylinderGeometry(0.2, 0.17, 0.06, 14, 1, true));
	b.add('pan', black, new THREE.CylinderGeometry(0.17, 0.17, 0.015, 14), { pos: V(0, -0.025, 0) });
	b.add('handle', black, new THREE.BoxGeometry(0.35, 0.03, 0.04), { pos: V(0.36, 0.02, 0) });
	return b.build();
}

// A white plate, 0.36 m wide, with a gold rim. Its origin at its middle.
export function buildPlate() {
	const b = new Builder('kitchen_plate');
	b.add('plate', mat('plate_white', 0xf4f4f0), new THREE.CylinderGeometry(0.18, 0.12, 0.03, 16));
	b.add('rim', mat('plate_gold', 0xd8b040), new THREE.TorusGeometry(0.165, 0.008, 4, 16), { pos: V(0, 0.016, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The double-bottom pot from the walk-in fridge (step 5): the soup pot, a bit taller, with the false bottom lifted and
// pearl and gold necklaces spilling over the rim. Its origin at its middle.
export function buildNecklacePot() {
	const b = new Builder('kitchen_pot_necklaces');
	b.add('pot', steel, new THREE.CylinderGeometry(0.2, 0.18, 0.34, 14, 1, true));
	b.add('pot', steel, new THREE.CylinderGeometry(0.18, 0.18, 0.02, 14), { pos: V(0, -0.16, 0) });
	b.add('bottom', steel, new THREE.CylinderGeometry(0.185, 0.185, 0.02, 14), { pos: V(0, 0.1, 0), rot: [0.35, 0, 0] });
	for (const s of [-1, 1]) b.add('handles', black, new THREE.TorusGeometry(0.045, 0.012, 4, 8, Math.PI), { pos: V(s * 0.22, 0.12, 0), rot: [Math.PI / 2, 0, s * Math.PI / 2] });
	const pearl = mat('necklace_pearl', 0xf4f0e8), gold = mat('necklace_gold', 0xe8c040);
	for (let n = 0; n < 3; n++) {
		const m = n === 1 ? gold : pearl;
		for (let i = 0; i < 9; i++) {
			const t = i / 8;
			const a = n * 2.1 + t * 1.2;
			b.add('necklace', m, new THREE.SphereGeometry(0.018, 6, 4), { pos: V(Math.cos(a) * (0.12 + t * 0.1), 0.16 + Math.sin(t * Math.PI) * 0.06 - t * 0.12, Math.sin(a) * (0.12 + t * 0.1)) });
		}
	}
	return b.build();
}

// The Chef's getaway (step 6): the restaurant's delivery scooter, white with gold trim, with a giant thermal box on the
// back (the pizzas he loses in the curves come out of it). 1.9 m long, 0.7 m wide; faces +Z like the other suspect
// vehicles, and its wheels are part of it. The Chef (npc_flambe) rides it, standing on the board.
export function buildPizzaScooter() {
	const b = new Builder('pizza_scooter');
	const white = mat('scooter_white', 0xf4f2ea), gold = mat('scooter_gold', 0xd8b040), tire = mat('tire', 0x1a1a1e);
	const thermal = mat('thermal_box_red', 0xc8302a), glass = mat('scooter_glass', 0xbfe0f0);
	const add = (part, m, w, h, d, x, y, z, rot) => b.add(part, m, new THREE.BoxGeometry(w, h, d), { pos: V(x, y, z), rot });
	for (const z of [0.68, -0.68]) {
		b.add('wheels', tire, new THREE.CylinderGeometry(0.26, 0.26, 0.12, 10), { pos: V(0, 0.26, z), rot: [0, 0, Math.PI / 2] });
		b.add('wheels', gold, new THREE.CylinderGeometry(0.12, 0.12, 0.13, 8), { pos: V(0, 0.26, z), rot: [0, 0, Math.PI / 2] });
	}
	add('body', white, 0.36, 0.1, 0.8, 0, 0.32, 0.05);
	add('body', white, 0.42, 0.36, 0.6, 0, 0.5, -0.45);
	add('body', black, 0.36, 0.08, 0.5, 0, 0.72, -0.4);
	add('body', white, 0.38, 0.75, 0.1, 0, 0.7, 0.55, [-0.25, 0, 0]);
	add('body', gold, 0.4, 0.04, 0.11, 0, 1.05, 0.52, [-0.25, 0, 0]);
	add('body', steel, 0.05, 0.05, 0.3, 0, 0.95, 0.68, [-0.3, 0, 0]);
	add('body', black, 0.6, 0.04, 0.04, 0, 1.12, 0.62);
	add('lights', glass, 0.14, 0.1, 0.03, 0, 0.98, 0.72);
	// The giant thermal box, far wider than the scooter, on a rack, with a gold spoon on each side.
	add('box', steel, 0.5, 0.04, 0.5, 0, 0.74, -0.9);
	add('box', thermal, 1.1, 0.8, 0.8, 0, 1.16, -0.95);
	add('box', gold, 1.12, 0.06, 0.82, 0, 1.58, -0.95);
	for (const s of [-1, 1]) {
		add('spoon', gold, 0.02, 0.36, 0.06, s * 0.56, 1.12, -0.95);
		b.add('spoon', gold, new THREE.SphereGeometry(0.07, 8, 6), { pos: V(s * 0.56, 1.32, -0.95), scale: [0.3, 1, 0.8] });
	}
	return b.build();
}

// A pizza box that falls off the Chef's scooter: 0.4 m square, flat, cardboard, with the restaurant's gold spoon on
// the lid and a slice of pizza sticking out. Its origin at its bottom.
export function buildPizzaBox() {
	const b = new Builder('pizza_box');
	const card = mat('pizza_card', 0xd8b07a), gold = mat('scooter_gold', 0xd8b040);
	b.add('box', card, new THREE.BoxGeometry(0.4, 0.05, 0.4), { pos: V(0, 0.025, 0) });
	b.add('logo', gold, new THREE.BoxGeometry(0.04, 0.005, 0.2), { pos: V(0, 0.052, 0) });
	b.add('logo', gold, new THREE.SphereGeometry(0.04, 8, 4), { pos: V(0, 0.052, 0.1), scale: [1, 0.15, 1.4] });
	b.add('slice', mat('pizza_cheese', 0xf0c040), new THREE.CylinderGeometry(0.12, 0.12, 0.015, 3, 1, false, 0, Math.PI / 3), { pos: V(0.15, 0.03, 0.12) });
	b.add('slice', tomatoRed, new THREE.SphereGeometry(0.02, 6, 4), { pos: V(0.2, 0.04, 0.17), scale: [1, 0.3, 1] });
	return b.build();
}

const KINDS = Object.keys(FOOD);

export const models = {
	...Object.fromEntries(KINDS.map((k) => [`food_${k}`, single(k)])),
	...Object.fromEntries(KINDS.map((k) => [`kitchen_crate_${k}`, crate(k)])),
	kitchen_pot: buildPot, kitchen_pan: buildPan, kitchen_plate: buildPlate,
	kitchen_pot_necklaces: buildNecklacePot, pizza_scooter: buildPizzaScooter, pizza_box: buildPizzaBox,
};

export const views = {
	kitchen: {
		items: [
			...KINDS.map((k, i) => ({ name: `food_${k}`, pos: [-1.0 + i * 0.4, 0.1, 0.6] })),
			{ name: 'kitchen_pot', pos: [-0.6, 0.15, -0.1] },
			{ name: 'kitchen_pan', pos: [0.1, 0.03, -0.1] },
			{ name: 'kitchen_plate', pos: [0.8, 0.015, 0.0] },
			{ name: 'kitchen_pot_necklaces', pos: [1.4, 0.17, -0.1] },
			...KINDS.map((k, i) => ({ name: `kitchen_crate_${k}`, pos: [-1.4 + i * 0.7, 0, -0.9] })),
		],
		cam: { pos: [0, 1.5, 2.3], target: [0, 0.1, -0.1], fov: 50 },
	},
	pizza_scooter: {
		items: [{ name: 'pizza_scooter', pos: [0, 0, 0] }, { name: 'npc_flambe', pos: [0, 0.36, -0.1], scale: 0.85 },
			{ name: 'pizza_box', pos: [1.0, 0, 0.6] }],
		cam: { pos: [3.2, 2.0, 3.4], target: [0, 0.8, 0], fov: 45 },
	},
};
