// Props of the supermarket "Súper El Changuito" (docs/diseno/allanamiento-super.md): a 3 m gondola module, the dairy
// fridge with its glass doors, a checkout counter with its belt and price button, the produce stand with its scale, the
// chest freezer and a can of the offer pyramid, with origins at the floor in the middle of each piece. Placeholder, not
// final art.
import { Builder, mat, V, THREE } from '../lib.js';

const PRODUCTS = [0xe8473a, 0xf2c230, 0x3a8ad2, 0x46b45a, 0xf08a2a, 0xb05ad2, 0xf2f2ea];

// A double-sided gondola module 3 m long (along Z), 1.2 m deep and 1.8 m tall: grey uprights, four shelves a side and
// rows of colored boxes and cans on each.
export function buildGondola() {
	const b = new Builder('gondola');
	const metal = mat('gondola_metal', 0xc8ccd2), base = mat('gondola_base', 0x4a4e56);
	b.add('base', base, new THREE.BoxGeometry(1.2, 0.12, 3.0), { pos: V(0, 0.06, 0) });
	b.add('spine', metal, new THREE.BoxGeometry(0.06, 1.8, 3.0), { pos: V(0, 0.9, 0) });
	const looks = PRODUCTS.map((c, i) => mat('product_' + i, c));
	let k = 0;
	for (const side of [-1, 1]) for (const y of [0.12, 0.55, 0.98, 1.41]) {
		b.add('shelf', metal, new THREE.BoxGeometry(0.55, 0.03, 3.0), { pos: V(side * 0.32, y + 0.015, 0) });
		for (let i = 0; i < 9; i++) {
			const tall = 0.18 + ((i * 7 + k) % 4) * 0.05;
			const geo = (i + k) % 3 === 0 ? new THREE.CylinderGeometry(0.07, 0.07, tall, 10) : new THREE.BoxGeometry(0.28, tall, 0.24);
			b.add('product', looks[(i + k) % looks.length], geo, { pos: V(side * 0.34, y + 0.03 + tall / 2, -1.33 + i * 0.33) });
		}
		k += 3;
	}
	return b.build();
}

// The dairy fridge, 4 m wide (along X), 0.9 m deep and 2.2 m tall, its glass doors to +Z: white box, four doors with
// handles, lit shelves of milk and yogurt behind the glass.
export function buildDairyFridge() {
	const b = new Builder('dairy_fridge');
	const white = mat('fridge_white', 0xeef0f2), glass = mat('fridge_glass', 0xa8d8f0, { opacity: 0.35, transparent: true }), handle = mat('fridge_handle', 0x8a8e94);
	b.add('back', white, new THREE.BoxGeometry(4.0, 2.2, 0.1), { pos: V(0, 1.1, -0.4) });
	for (const x of [-1.95, 1.95]) b.add('side', white, new THREE.BoxGeometry(0.1, 2.2, 0.9), { pos: V(x, 1.1, 0) });
	b.add('top', mat('fridge_sign', 0x3a8ad2), new THREE.BoxGeometry(4.0, 0.3, 0.9), { pos: V(0, 2.05, 0) });
	b.add('bottom', white, new THREE.BoxGeometry(4.0, 0.2, 0.9), { pos: V(0, 0.1, 0) });
	const milk = mat('milk', 0xf8f8f4), yogurt = mat('yogurt', 0xf2a6c2), cheese = mat('cheese', 0xf2c84a);
	for (const y of [0.45, 0.95, 1.45]) {
		b.add('shelf', handle, new THREE.BoxGeometry(3.8, 0.02, 0.7), { pos: V(0, y, -0.05) });
		for (let i = 0; i < 12; i++) {
			const look = [milk, yogurt, cheese][(i + Math.round(y * 2)) % 3];
			b.add('item', look, new THREE.BoxGeometry(0.2, 0.26, 0.18), { pos: V(-1.7 + i * 0.31, y + 0.14, -0.1) });
		}
	}
	for (let i = 0; i < 4; i++) {
		b.add('door', glass, new THREE.BoxGeometry(0.96, 1.6, 0.03), { pos: V(-1.45 + i * 0.97, 1.0, 0.43) });
		b.add('handle', handle, new THREE.BoxGeometry(0.03, 0.5, 0.04), { pos: V(-1.05 + i * 0.97, 1.0, 0.47) });
	}
	return b.build();
}

// A checkout counter 0.8 m wide and 2.4 m long (along Z), 0.9 m tall: the black belt, the till's stand at the +Z end
// and the red "price, please" button on a post.
export function buildCheckout() {
	const b = new Builder('checkout');
	b.add('body', mat('checkout_body', 0xd23a3a), new THREE.BoxGeometry(0.8, 0.86, 2.4), { pos: V(0, 0.43, 0) });
	b.add('belt', mat('checkout_belt', 0x1e1e20), new THREE.BoxGeometry(0.6, 0.04, 1.7), { pos: V(0, 0.88, -0.3) });
	b.add('divider', mat('checkout_bar', 0x8a8e94), new THREE.BoxGeometry(0.5, 0.04, 0.04), { pos: V(0, 0.92, -0.6) });
	b.add('stand', mat('checkout_stand', 0x4a4e56), new THREE.BoxGeometry(0.6, 0.06, 0.6), { pos: V(0, 0.89, 0.85) });
	b.add('post', mat('checkout_post', 0x8a8e94), new THREE.CylinderGeometry(0.02, 0.02, 0.5, 8), { pos: V(0.35, 1.11, 0.85) });
	b.add('button', mat('price_button', 0xf2402a), new THREE.CylinderGeometry(0.05, 0.05, 0.04, 12), { pos: V(0.35, 1.38, 0.85) });
	return b.build();
}

// The produce stand, 2.4 m long (along Z) and 1.0 m deep, its front to +X: a slanted wooden table with crates of
// tomatoes, lettuce, bananas and apples, and the green scale on a stool at the +Z end.
export function buildProduceStand() {
	const b = new Builder('produce_stand');
	const wood = mat('crate_wood', 0xb07a46);
	b.add('table', wood, new THREE.BoxGeometry(1.0, 0.8, 2.4), { pos: V(0, 0.4, -0.2) });
	const fruit = [0xe23a2a, 0x7ac24a, 0xf2d23a, 0xc23a4a].map((c, i) => mat('fruit_' + i, c));
	for (let i = 0; i < 4; i++) {
		const z = -1.1 + i * 0.6;
		b.add('crate', wood, new THREE.BoxGeometry(0.8, 0.2, 0.5), { pos: V(0, 0.9, z), rot: [0, 0, 0.2] });
		for (let j = 0; j < 6; j++) b.add('fruit', fruit[i], new THREE.SphereGeometry(0.06, 8, 6), { pos: V(-0.25 + (j % 3) * 0.25, 1.02 + (j % 3) * 0.05, z - 0.1 + Math.floor(j / 3) * 0.2) });
	}
	b.add('stool', wood, new THREE.BoxGeometry(0.5, 0.85, 0.5), { pos: V(0, 0.425, 1.3) });
	b.add('scale', mat('scale_green', 0x46b45a), new THREE.BoxGeometry(0.35, 0.12, 0.3), { pos: V(0, 0.91, 1.3) });
	b.add('tray', mat('scale_tray', 0xc8ccd2), new THREE.BoxGeometry(0.3, 0.02, 0.26), { pos: V(0, 0.98, 1.3) });
	b.add('dial', mat('scale_dial', 0xf2f2ea), new THREE.BoxGeometry(0.2, 0.12, 0.02), { pos: V(0.16, 0.95, 1.3), rot: [0, Math.PI / 2, 0] });
	return b.build();
}

// The open chest freezer, 2.0 m long (along X), 0.9 m deep and 0.9 m tall: white with a blue band, sliding glass on top
// and ice cream boxes inside.
export function buildChestFreezer() {
	const b = new Builder('chest_freezer');
	const white = mat('freezer_white', 0xeef0f2);
	b.add('bottom', white, new THREE.BoxGeometry(2.0, 0.1, 0.9), { pos: V(0, 0.05, 0) });
	for (const z of [-0.42, 0.42]) b.add('wall', white, new THREE.BoxGeometry(2.0, 0.9, 0.06), { pos: V(0, 0.45, z) });
	for (const x of [-0.97, 0.97]) b.add('wall', white, new THREE.BoxGeometry(0.06, 0.9, 0.9), { pos: V(x, 0.45, 0) });
	b.add('band', mat('freezer_band', 0x3a8ad2), new THREE.BoxGeometry(2.02, 0.12, 0.92), { pos: V(0, 0.7, 0) });
	const looks = [0xf2a6c2, 0x8a5a3a, 0xf2f2ea].map((c, i) => mat('ice_cream_' + i, c));
	for (let i = 0; i < 6; i++) b.add('ice_cream', looks[i % 3], new THREE.BoxGeometry(0.28, 0.14, 0.2), { pos: V(-0.7 + i * 0.28, 0.6, (i % 2) * 0.3 - 0.15) });
	b.add('glass', mat('freezer_glass', 0xa8d8f0, { opacity: 0.35, transparent: true }), new THREE.BoxGeometry(1.9, 0.02, 0.84), { pos: V(0, 0.89, 0) });
	return b.build();
}

// A can of the offer pyramid, 0.1 m across and 0.12 m tall: red label with a yellow band and a tin top.
export function buildFoodCan() {
	const b = new Builder('food_can');
	b.add('can', mat('can_label', 0xe8473a), new THREE.CylinderGeometry(0.05, 0.05, 0.12, 12), { pos: V(0, 0.06, 0) });
	b.add('band', mat('can_band', 0xf2c230), new THREE.CylinderGeometry(0.051, 0.051, 0.03, 12), { pos: V(0, 0.06, 0) });
	b.add('top', mat('can_tin', 0xc8ccd2), new THREE.CylinderGeometry(0.048, 0.048, 0.005, 12), { pos: V(0, 0.122, 0) });
	return b.build();
}

export const models = {
	gondola: buildGondola, dairy_fridge: buildDairyFridge, checkout: buildCheckout, produce_stand: buildProduceStand,
	chest_freezer: buildChestFreezer, food_can: buildFoodCan,
};

export const views = {
	supermarket: {
		items: [
			{ name: 'gondola', pos: [-2.2, 0, 0] }, { name: 'dairy_fridge', pos: [0.6, 0, -2.0] },
			{ name: 'checkout', pos: [1.6, 0, 1.2] }, { name: 'produce_stand', pos: [3.2, 0, 0], rotY: -Math.PI / 2 },
			{ name: 'chest_freezer', pos: [0.2, 0, 0.6] }, { name: 'food_can', pos: [1.6, 0.9, 0.5] },
		],
		cam: { pos: [0, 3.0, 7.5], target: [0.4, 0.9, 0], fov: 50 },
	},
};
