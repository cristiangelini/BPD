// The market walk (docs/diseno/politico-mercado.md): the stalls, what each one sells and the chemical toilet.
// Placeholder.
import { Builder, mat, V, THREE, ellipsoid, rng } from '../lib.js';

const wood = mat('stall_wood', 0x9a6a3e), dark = mat('stall_post', 0x5a3e26), crate = mat('crate_wood', 0xc89a5e);

// A market stall (step 1): a wooden counter 3 m wide and 0.8 m deep, two posts behind it holding a striped awning
// that leans to the customers. The awning's red stripes are their own node so the game tints each stall. Its origin
// on the ground under the middle of the counter, the customers' side to +Z.
export function buildStall() {
	const b = new Builder('market_stall');
	b.add('counter', wood, new THREE.BoxGeometry(3.0, 0.95, 0.8), { pos: V(0, 0.475, 0) });
	b.add('counter', dark, new THREE.BoxGeometry(3.06, 0.05, 0.86), { pos: V(0, 0.97, 0) });
	for (const x of [-1.45, 1.45]) b.add('counter', dark, new THREE.BoxGeometry(0.08, 2.4, 0.08), { pos: V(x, 1.2, -1.0) });
	for (let i = 0; i < 8; i++) {
		b.add(i % 2 ? 'awning_white' : 'awning', mat(i % 2 ? 'awning_white' : 'awning_red', i % 2 ? 0xf4f0e6 : 0xd8402e),
			new THREE.BoxGeometry(3.2 / 8, 0.03, 1.7), { pos: V(-1.6 + 0.2 + i * 0.4, 2.35, -0.25), rot: [0.22, 0, 0] });
	}
	for (let i = 0; i < 8; i++) {
		b.add('awning', mat('awning_red', 0xd8402e), new THREE.ConeGeometry(0.2, 0.18, 3), { pos: V(-1.4 + i * 0.4, 2.1, 0.62), rot: [Math.PI, 0, 0] });
	}
	return b.build();
}

// A low crate on the counter that holds the goods: 0.55 x 0.4, 0.12 tall, origin on its bottom.
function addCrate(b, x, z) {
	b.add('crate', crate, new THREE.BoxGeometry(0.55, 0.02, 0.4), { pos: V(x, 0.01, z) });
	for (const [dx, dz, w, d] of [[0, -0.19, 0.55, 0.02], [0, 0.19, 0.55, 0.02], [-0.265, 0, 0.02, 0.4], [0.265, 0, 0.02, 0.4]]) {
		b.add('crate', crate, new THREE.BoxGeometry(w, 0.12, d), { pos: V(x + dx, 0.06, z + dz) });
	}
}

// Four crates along the counter, each filled by `fill(b, x, z, i, r)`: what each stall sells, 2.6 m of it, the origin on
// the counter top under the middle.
function goods(name, fill, crates = true) {
	return () => {
		const b = new Builder(name);
		const r = rng(name.length * 31);
		for (let i = 0; i < 4; i++) {
			const x = -0.96 + i * 0.64;
			if (crates) addCrate(b, x, 0);
			fill(b, x, 0, i, r);
		}
		return b.build();
	};
}

// Round things heaped in a crate: fruit, olives, tomatoes.
function heap(b, x, z, radius, colors, r, count = 9) {
	for (let k = 0; k < count; k++) {
		const m = colors[k % colors.length];
		b.add('goods', m, ellipsoid(radius, radius * 0.9, radius, 6, 4),
			{ pos: V(x - 0.18 + (k % 3) * 0.18 + (r() - 0.5) * 0.04, 0.07 + Math.floor(k / 3) * 0.02, z - 0.12 + Math.floor(k / 3) * 0.12) });
	}
}

const FRUIT = [mat('apple', 0xd8302a), mat('orange', 0xf29a2a), mat('banana', 0xf2d23a), mat('pear_fruit', 0x9ac83a)];
const fruit = goods('market_food_fruit', (b, x, z, i, r) => heap(b, x, z, 0.06, [FRUIT[i]], r));
const cheese = goods('market_food_cheese', (b, x, z, i) => {
	const m = mat(i % 2 ? 'cheese_white' : 'cheese_yellow', i % 2 ? 0xf2ecd2 : 0xf2c84b);
	b.add('goods', m, new THREE.CylinderGeometry(0.17, 0.17, 0.12, 10), { pos: V(x, 0.08, z) });
	b.add('goods', m, new THREE.CylinderGeometry(0.12, 0.12, 0.1, 3), { pos: V(x + 0.1, 0.19, z + 0.05), rot: [0, 0.4, 0] });
});
const empanadas = goods('market_food_empanadas', (b, x, z, i, r) => {
	for (let k = 0; k < 6; k++) {
		b.add('goods', mat('pastry', 0xd9a050), new THREE.CylinderGeometry(0.07, 0.07, 0.04, 8, 1, false, 0, Math.PI),
			{ pos: V(x - 0.16 + (k % 3) * 0.16, 0.1, z - 0.08 + Math.floor(k / 3) * 0.16), rot: [Math.PI / 2, 0, r() * 0.3] });
	}
});
const fish = goods('market_food_fish', (b, x, z, i) => {
	b.add('goods', mat('ice', 0xdaf0f8), new THREE.BoxGeometry(0.5, 0.05, 0.36), { pos: V(x, 0.04, z) });
	for (let k = 0; k < 3; k++) {
		const fz = z - 0.11 + k * 0.11;
		b.add('goods', mat('fish_skin', 0x8aa6b8), ellipsoid(0.17, 0.035, 0.05, 8, 4), { pos: V(x - 0.03, 0.09, fz) });
		b.add('goods', mat('fish_skin', 0x8aa6b8), new THREE.ConeGeometry(0.05, 0.08, 3), { pos: V(x + 0.17, 0.09, fz), rot: [0, 0, -Math.PI / 2] });
	}
});
const pickles = goods('market_food_pickles', (b, x, z, i) => {
	for (const dx of [-0.13, 0.13]) {
		b.add('goods', mat('jar_glass', 0xb8e0c8), new THREE.CylinderGeometry(0.08, 0.08, 0.2, 8), { pos: V(x + dx, 0.12, z) });
		b.add('goods', mat('jar_lid', 0xd8402e), new THREE.CylinderGeometry(0.085, 0.085, 0.03, 8), { pos: V(x + dx, 0.235, z) });
		b.add('goods', mat('pickle', 0x4a8a2a), new THREE.CylinderGeometry(0.06, 0.06, 0.14, 6), { pos: V(x + dx, 0.11, z) });
	}
});
const olives = goods('market_food_olives', (b, x, z, i, r) => {
	b.add('goods', mat('bowl_clay', 0xb8643a), new THREE.CylinderGeometry(0.2, 0.14, 0.1, 10), { pos: V(x, 0.07, z) });
	heap(b, x, z + 0.02, 0.03, [mat(i % 2 ? 'olive_black' : 'olive_green', i % 2 ? 0x2a2a1e : 0x7a8a2a)], r, 12);
}, false);
const bread = goods('market_food_bread', (b, x, z, i) => {
	for (let k = 0; k < 3; k++) {
		b.add('goods', mat('crust', 0xc8843a), ellipsoid(0.16, 0.06, 0.07, 8, 4), { pos: V(x, 0.12, z - 0.12 + k * 0.12), rot: [0, 0.2 * (k - 1), 0] });
	}
});
const sweets = goods('market_food_sweets', (b, x, z, i, r) => {
	const colors = [mat('candy_pink', 0xf29ab8), mat('candy_blue', 0x7ab8f2), mat('candy_green', 0x8ad86a), mat('candy_yellow', 0xf2e05a)];
	for (let k = 0; k < 9; k++) {
		b.add('goods', colors[(k + i) % 4], new THREE.BoxGeometry(0.1, 0.08, 0.1),
			{ pos: V(x - 0.16 + (k % 3) * 0.16, 0.07, z - 0.12 + Math.floor(k / 3) * 0.12), rot: [0, r() * 0.6, 0] });
	}
});
const juice = goods('market_food_juice', (b, x, z, i) => {
	const m = [mat('juice_orange', 0xf2a02a), mat('juice_red', 0xd8302a), mat('juice_green', 0x8ad83a), mat('juice_yellow', 0xf2e05a)][i];
	for (const dx of [-0.14, 0, 0.14]) {
		b.add('goods', m, new THREE.CylinderGeometry(0.045, 0.045, 0.22, 6), { pos: V(x + dx, 0.13, z) });
		b.add('goods', mat('bottle_cap', 0xf4f0e6), new THREE.CylinderGeometry(0.02, 0.02, 0.04, 6), { pos: V(x + dx, 0.26, z) });
	}
}, false);
const meat = goods('market_food_meat', (b, x, z, i) => {
	b.add('goods', mat('tray_white', 0xf4f0e6), new THREE.BoxGeometry(0.5, 0.03, 0.34), { pos: V(x, 0.02, z) });
	for (let k = 0; k < 2; k++) {
		b.add('goods', mat('meat_red', 0xb83a3a), ellipsoid(0.13, 0.04, 0.09, 8, 4), { pos: V(x - 0.1 + k * 0.2, 0.06, z) });
		b.add('goods', mat('meat_fat', 0xf2e0d0), ellipsoid(0.05, 0.03, 0.04, 6, 3), { pos: V(x - 0.04 + k * 0.2, 0.08, z + 0.03) });
	}
});
const spices = goods('market_food_spices', (b, x, z, i) => {
	const m = [mat('spice_red', 0xc83a1e), mat('spice_yellow', 0xe8b81e), mat('spice_brown', 0x8a5a2a), mat('spice_green', 0x6a8a2a)][i];
	b.add('goods', mat('sack', 0xd8c49a), new THREE.CylinderGeometry(0.2, 0.18, 0.2, 8), { pos: V(x, 0.1, z) });
	b.add('goods', m, new THREE.ConeGeometry(0.19, 0.12, 8), { pos: V(x, 0.26, z) });
}, false);
const iceCream = goods('market_food_ice_cream', (b, x, z, i) => {
	const m = [mat('ice_pink', 0xf29ab8), mat('ice_vanilla', 0xf6ecc8), mat('ice_choc', 0x6a3e22), mat('ice_mint', 0xa8e8c8)][i];
	b.add('goods', mat('freezer', 0xe8f0f4), new THREE.BoxGeometry(0.56, 0.12, 0.4), { pos: V(x, 0.06, z) });
	b.add('goods', m, ellipsoid(0.2, 0.07, 0.14, 8, 4), { pos: V(x, 0.12, z) });
}, false);

// The chemical toilet at the back of the market (step 1; its door comes with step 4): a blue booth 1.2 m wide and
// 1.3 deep, open to +Z, with a white roof, the seat inside and a moon on the side. Its origin on the ground in the
// middle, the door's side to +Z.
export function buildToilet() {
	const blue = mat('toilet_blue', 0x2a6ad8), white = mat('toilet_white', 0xf4f4f0);
	const b = new Builder('chemical_toilet');
	b.add('booth', blue, new THREE.BoxGeometry(1.2, 2.3, 0.06), { pos: V(0, 1.15, -0.62) });
	for (const s of [-1, 1]) b.add('booth', blue, new THREE.BoxGeometry(0.06, 2.3, 1.3), { pos: V(s * 0.57, 1.15, 0) });
	for (const s of [-1, 1]) b.add('booth', blue, new THREE.BoxGeometry(0.2, 2.3, 0.06), { pos: V(s * 0.5, 1.15, 0.62) });
	b.add('booth', blue, new THREE.BoxGeometry(1.2, 0.2, 0.06), { pos: V(0, 2.2, 0.62) });
	b.add('booth', white, new THREE.BoxGeometry(1.3, 0.1, 1.4), { pos: V(0, 2.35, 0) });
	b.add('booth', white, new THREE.CylinderGeometry(0.55, 0.65, 0.12, 8), { pos: V(0, 2.45, 0) });
	b.add('booth', blue, new THREE.BoxGeometry(1.12, 0.06, 1.24), { pos: V(0, 0.03, 0) });
	b.add('seat', white, new THREE.BoxGeometry(0.6, 0.5, 0.5), { pos: V(0, 0.25, -0.33) });
	b.add('seat', mat('seat_hole', 0x1a1a1e), new THREE.CylinderGeometry(0.14, 0.14, 0.02, 8), { pos: V(0, 0.505, -0.3) });
	for (const s of [-1, 1]) b.add('booth', mat('moon', 0xf2d23a), new THREE.CylinderGeometry(0.1, 0.1, 0.02, 8, 1, false, 0, Math.PI), { pos: V(s * 0.61, 1.9, 0), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// Its door (step 4): 0.8 m wide, 2 m tall, with the green/red sign; the hinge on its west edge at the origin.
export function buildToiletDoor() {
	const blue = mat('toilet_blue', 0x2a6ad8);
	const b = new Builder('chemical_toilet_door');
	b.add('door', blue, new THREE.BoxGeometry(0.8, 2.0, 0.05), { pos: V(0.4, 1.05, 0) });
	b.add('door', mat('door_handle', 0xc0c4c8), new THREE.BoxGeometry(0.04, 0.14, 0.06), { pos: V(0.7, 1.05, 0.04) });
	b.add('sign', mat('sign_free', 0x3ad83a), new THREE.BoxGeometry(0.12, 0.05, 0.02), { pos: V(0.7, 1.2, 0.04) });
	return b.build();
}

export const KINDS = ['fruit', 'cheese', 'empanadas', 'fish', 'pickles', 'olives', 'bread', 'sweets', 'juice', 'meat', 'spices', 'ice_cream'];
const FOODS = [fruit, cheese, empanadas, fish, pickles, olives, bread, sweets, juice, meat, spices, iceCream];

export const models = {
	market_stall: buildStall,
	chemical_toilet: buildToilet,
	chemical_toilet_door: buildToiletDoor,
	...Object.fromEntries(KINDS.map((k, i) => [`market_food_${k}`, FOODS[i]])),
};

export const views = {
	market_stalls: {
		items: KINDS.slice(0, 4).flatMap((k, i) => [{ name: 'market_stall', pos: [(i - 1.5) * 3.3, 0, 0] },
			{ name: `market_food_${k}`, pos: [(i - 1.5) * 3.3, 1.0, 0] }]),
		cam: { pos: [0, 3.2, 9.5], target: [0, 1.0, 0], fov: 40 },
	},
	market_foods: {
		items: KINDS.map((k, i) => ({ name: `market_food_${k}`, pos: [((i % 4) - 1.5) * 2.8, 0, Math.floor(i / 4) * 0.9 - 0.9] })),
		cam: { pos: [0, 4.2, 4.0], target: [0, 0, 0], fov: 45 },
	},
	chemical_toilet: {
		items: [{ name: 'chemical_toilet', pos: [0, 0, 0], rotY: 0.5 }, { name: 'chemical_toilet_door', pos: [-0.4 * Math.cos(0.5) + 0.62 * Math.sin(0.5), 0, 0.4 * Math.sin(0.5) + 0.62 * Math.cos(0.5)], rotY: 0.5 - 1.6 }],
		cam: { pos: [2.5, 2.0, 4.0], target: [0, 1.1, 0], fov: 40 },
	},
};
