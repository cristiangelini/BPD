// Props of the supermarket "Súper El Changuito" (docs/diseno/allanamiento-super.md): a 3 m gondola module, the dairy
// fridge with its glass doors, a checkout counter with its belt and price button, the produce stand with its scale, the
// chest freezer and a can of the offer pyramid, with origins at the floor in the middle of each piece. Placeholder, not
// final art.
import { Builder, mat, ellipsoid, loft, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

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

// A shopping cart 0.6 m wide, 0.95 m long (along Z, the handle at +Z) and 1.0 m tall: a wire basket of thin bars on a
// frame with four small wheels, the red handle and the folding child seat by it.
function cartParts(b) {
	const wire = mat('cart_wire', 0xc8ccd2), frame = mat('cart_frame', 0x8a8e94), red = mat('cart_red', 0xd23a3a), wheel = mat('cart_wheel', 0x26262a);
	const y0 = 0.35, y1 = 0.95;
	b.add('floor', wire, new THREE.BoxGeometry(0.56, 0.02, 0.9), { pos: V(0, y0, 0) });
	for (let i = 0; i <= 6; i++) {
		const z = -0.45 + i * 0.15;
		for (const s of [-1, 1]) b.add('bar', wire, new THREE.BoxGeometry(0.015, y1 - y0, 0.015), { pos: V(s * 0.28, (y0 + y1) / 2, z) });
	}
	for (let i = 0; i <= 4; i++) for (const z of [-0.45, 0.45]) b.add('bar', wire, new THREE.BoxGeometry(0.015, y1 - y0, 0.015), { pos: V(-0.28 + i * 0.14, (y0 + y1) / 2, z) });
	for (const y of [y0 + 0.3, y1]) {
		for (const s of [-1, 1]) b.add('rail', frame, new THREE.BoxGeometry(0.025, 0.025, 0.92), { pos: V(s * 0.28, y, 0) });
		for (const z of [-0.45, 0.45]) b.add('rail', frame, new THREE.BoxGeometry(0.58, 0.025, 0.025), { pos: V(0, y, z) });
	}
	for (const s of [-1, 1]) {
		b.add('leg', frame, new THREE.BoxGeometry(0.03, y0 - 0.08, 0.03), { pos: V(s * 0.24, (y0 + 0.08) / 2, -0.4) });
		b.add('leg', frame, new THREE.BoxGeometry(0.03, y0 - 0.08, 0.03), { pos: V(s * 0.24, (y0 + 0.08) / 2, 0.4) });
		b.add('handle_post', frame, new THREE.BoxGeometry(0.025, 0.12, 0.025), { pos: V(s * 0.27, y1 + 0.06, 0.5) });
		for (const z of [-0.4, 0.4]) b.add('wheel', wheel, new THREE.CylinderGeometry(0.06, 0.06, 0.03, 10), { pos: V(s * 0.24, 0.06, z), rot: [0, 0, Math.PI / 2] });
	}
	b.add('base_bar', frame, new THREE.BoxGeometry(0.5, 0.025, 0.8), { pos: V(0, 0.1, 0) });
	b.add('handle', red, new THREE.CylinderGeometry(0.02, 0.02, 0.6, 8), { pos: V(0, y1 + 0.12, 0.52), rot: [0, 0, Math.PI / 2] });
	b.add('seat', red, new THREE.BoxGeometry(0.4, 0.02, 0.18), { pos: V(0, y1 - 0.1, 0.36) });
}

export function buildShoppingCart() {
	const b = new Builder('shopping_cart');
	cartParts(b);
	return b.build();
}

// Don Ofertón, the manager: the store's red vest with a cart logo over a white shirt, a tie with price tags, a thin
// mustache, slicked-back hair and the wireless mic in his right hand. The game scales him tall and thin.
export function buildDonOferton() {
	const b = new Builder('npc_don_oferton');
	const vest = mat('oferton_vest', 0xd23a3a), shirt = M.white, slacks = mat('oferton_slacks', 0x2a2a34);
	pearBody(b, mat('skin_trigo', 0xe0b48a), { shirt, pants: slacks, shoes: M.black, belted: false });
	b.add('vest', vest, loft([{ y: 0.56, rx: 0.455, rz: 0.415 }, { y: 0.8, rx: 0.375, rz: 0.335 }, { y: 1.02, rx: 0.265, rz: 0.245 }], 10));
	b.add('vest', shirt, new THREE.BoxGeometry(0.12, 0.4, 0.04), { pos: V(0, 0.84, 0.33), rot: [-0.35, 0, 0] });
	b.add('vest', mat('oferton_logo', 0xf2f2ea), new THREE.BoxGeometry(0.08, 0.06, 0.01), { pos: V(0.2, 0.86, 0.32), rot: [-0.35, 0.5, 0] });
	const tie = mat('oferton_tie', 0xf2c230);
	b.add('tie', tie, new THREE.BoxGeometry(0.07, 0.36, 0.02), { pos: V(0, 0.88, 0.34), rot: [-0.3, 0, 0] });
	for (let i = 0; i < 3; i++) b.add('tie', mat('oferton_tag', 0x2a8a3a), new THREE.BoxGeometry(0.04, 0.03, 0.01), { pos: V(0, 0.98 - i * 0.1, 0.36 - i * 0.03), rot: [-0.3, 0, 0.3] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	const hair = mat('oferton_hair', 0x1a1a1e);
	b.add('hair', hair, ellipsoid(0.2, 0.09, 0.2, 10, 5), { pos: V(0, 1.45, -0.02) });
	for (const s of [-1, 1]) b.add('face', hair, new THREE.BoxGeometry(0.09, 0.012, 0.02), { pos: V(s * 0.05, 1.24, 0.2), rot: [0, 0, s * -0.25] });
	limb(b, 'mic', M.black, V(0.49, 0.64, 0.09), V(0.5, 0.82, 0.16), 0.02);
	b.add('mic', mat('oferton_mic', 0x6a6a72, { metalness: 0.5 }), ellipsoid(0.04, 0.04, 0.04, 6, 4), { pos: V(0.5, 0.85, 0.17) });
	return b.build();
}

// Lalo, the stocker: a kid with a red cap on backwards, a green apron with the store's logo over a striped shirt and a
// price gun clipped to the apron's pocket. The game scales him short.
export function buildLalo() {
	const b = new Builder('npc_lalo');
	const shirt = mat('lalo_shirt', 0xf2c230), apron = mat('lalo_apron', 0x2a8a4a), cap = mat('lalo_cap', 0xd23a3a);
	pearBody(b, mat('skin_canela', 0xc68a5a), { shirt, pants: mat('lalo_jeans', 0x3a5a9a), shoes: M.white, belted: false });
	b.add('apron', apron, loft([{ y: 0.3, rx: 0.49, rz: 0.44 }, { y: 0.52, rx: 0.475, rz: 0.425 }, { y: 0.8, rx: 0.375, rz: 0.335 }], 10));
	b.add('apron', apron, new THREE.BoxGeometry(0.3, 0.2, 0.04), { pos: V(0, 0.92, 0.27), rot: [-0.45, 0, 0] });
	b.add('apron', mat('lalo_logo', 0xf2f2ea), new THREE.BoxGeometry(0.1, 0.07, 0.01), { pos: V(0, 0.62, 0.46), rot: [-0.2, 0, 0] });
	b.add('apron', M.black, new THREE.BoxGeometry(0.05, 0.08, 0.04), { pos: V(0.22, 0.55, 0.43) });
	eyes(b, 1.34, 0.17, 0.08, 0.055);
	b.add('face', mat('mouth', 0x7a2a2a), ellipsoid(0.06, 0.025, 0.02, 6, 4), { pos: V(0, 1.22, 0.2) });
	b.add('cap', cap, ellipsoid(0.21, 0.11, 0.2, 10, 5), { pos: V(0, 1.45, 0.0) });
	b.add('cap', cap, new THREE.BoxGeometry(0.2, 0.02, 0.16), { pos: V(0, 1.42, -0.24), rot: [0.25, 0, 0] });
	return b.build();
}

// The changed dates' story: the labeling gun that prints "vence en 2099", a box of peeled-off old labels and a yogurt
// thirty years old, swollen and green.
export function buildPriceGun() {
	const b = new Builder('super_price_gun');
	const body = mat('gun_orange', 0xf08a2a), dark = mat('gun_dark', 0x2a2a30);
	b.add('body', body, new THREE.BoxGeometry(0.08, 0.12, 0.26), { pos: V(0, 0.16, 0) });
	b.add('body', dark, new THREE.BoxGeometry(0.06, 0.16, 0.06), { pos: V(0, 0.06, 0.07), rot: [0.3, 0, 0] });
	b.add('body', dark, new THREE.BoxGeometry(0.03, 0.05, 0.04), { pos: V(0, 0.09, 0.0) });
	b.add('roll', mat('gun_roll', 0xf6f4ee), new THREE.CylinderGeometry(0.06, 0.06, 0.05, 12), { pos: V(0, 0.2, -0.06), rot: [0, 0, Math.PI / 2] });
	b.add('label', mat('gun_label', 0xf2c230), new THREE.BoxGeometry(0.07, 0.03, 0.002), { pos: V(0, 0.15, -0.131) });
	return b.build();
}

export function buildLabelBox() {
	const b = new Builder('super_label_box');
	const card = mat('label_box_card', 0xb88a5a);
	b.add('box', card, new THREE.BoxGeometry(0.4, 0.22, 0.3), { pos: V(0, 0.11, 0) });
	for (let i = 0; i < 9; i++) b.add('labels', mat(`old_label_${i % 3}`, [0xf2f2ea, 0xf2c230, 0xe8473a][i % 3]), new THREE.BoxGeometry(0.06, 0.004, 0.04), { pos: V(-0.12 + (i % 3) * 0.12, 0.225, -0.08 + Math.floor(i / 3) * 0.08), rot: [0, i * 0.7, 0] });
	return b.build();
}

export function buildOldYogurt() {
	const b = new Builder('super_old_yogurt');
	b.add('cup', mat('yogurt_cup', 0xe8e4d0), new THREE.CylinderGeometry(0.05, 0.04, 0.1, 10), { pos: V(0, 0.05, 0) });
	b.add('lid', mat('yogurt_green', 0x7ab03a), ellipsoid(0.055, 0.04, 0.055, 8, 5), { pos: V(0, 0.11, 0) });
	return b.build();
}

// The fake cheese's story: the fridge's 10 kg cheese wheels, the big plastic one full of bills, its mold and a block of
// yellow wax.
function wheel(b, r, h, rind) {
	b.add('cheese', mat('cheese_yellow', 0xf2d24a), new THREE.CylinderGeometry(r, r, h, 16), { pos: V(0, h / 2, 0) });
	b.add('rind', rind, new THREE.CylinderGeometry(r + 0.004, r + 0.004, h * 0.3, 16, 1, true), { pos: V(0, h / 2, 0) });
}

export function buildCheeseWheel() {
	const b = new Builder('super_cheese_wheel');
	wheel(b, 0.2, 0.14, mat('cheese_rind', 0xc8a03a));
	b.add('label', mat('cheese_label', 0xf6f4ee), new THREE.BoxGeometry(0.1, 0.002, 0.06), { pos: V(0, 0.141, 0) });
	return b.build();
}

export function buildFakeCheese() {
	const b = new Builder('super_fake_cheese');
	wheel(b, 0.35, 0.28, mat('fake_cheese_rind', 0xe0b030));
	b.add('label', mat('cheese_label', 0xf6f4ee), new THREE.BoxGeometry(0.16, 0.002, 0.1), { pos: V(0, 0.281, 0) });
	b.add('bills', mat('bill_green', 0x5aa04a), new THREE.BoxGeometry(0.1, 0.03, 0.005), { pos: V(0.2, 0.2, 0.29), rot: [0, 0.6, 0.2] });
	return b.build();
}

export function buildCheeseMold() {
	const b = new Builder('super_cheese_mold');
	const steel = mat('mold_steel', 0xb8bcc4, { metalness: 0.5, roughness: 0.4, side: THREE.DoubleSide });
	b.add('mold', steel, new THREE.CylinderGeometry(0.36, 0.36, 0.3, 16, 1, true), { pos: V(0, 0.15, 0) });
	b.add('mold', steel, new THREE.CylinderGeometry(0.36, 0.36, 0.02, 16), { pos: V(0, 0.01, 0) });
	for (const s of [-1, 1]) b.add('handles', steel, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.38, 0.22, 0), rot: [0, Math.PI / 2, 0] });
	return b.build();
}

export function buildWaxBlock() {
	const b = new Builder('super_wax_block');
	b.add('wax', mat('wax_yellow', 0xf0c020, { roughness: 0.3 }), new THREE.BoxGeometry(0.22, 0.1, 0.14), { pos: V(0, 0.05, 0) });
	b.add('label', mat('wax_label', 0x2a2a30), new THREE.BoxGeometry(0.12, 0.04, 0.002), { pos: V(0, 0.05, 0.071) });
	return b.build();
}

// The double-bottomed carts' story: a cart with a false floor stuffed with goods, a welder and the plan to "enlarge
// carts".
export function buildDoubleCart() {
	const b = new Builder('super_double_cart');
	cartParts(b);
	const goods = [0xe8473a, 0xf2c230, 0x3a8ad2, 0x46b45a];
	for (let i = 0; i < 6; i++) b.add('goods', mat(`hidden_goods_${i % 4}`, goods[i % 4]), new THREE.BoxGeometry(0.16, 0.12, 0.22), { pos: V(-0.17 + (i % 3) * 0.17, 0.27, -0.2 + Math.floor(i / 3) * 0.4) });
	b.add('false_floor', mat('false_floor', 0x8a8e94), new THREE.BoxGeometry(0.56, 0.02, 0.9), { pos: V(0, 0.2, 0) });
	return b.build();
}

export function buildWelder() {
	const b = new Builder('super_welder');
	b.add('box', mat('welder_red', 0xc83a2a), new THREE.BoxGeometry(0.36, 0.26, 0.2), { pos: V(0, 0.13, 0) });
	b.add('dial', M.black, new THREE.CylinderGeometry(0.04, 0.04, 0.02, 10), { pos: V(-0.08, 0.16, 0.105), rot: [Math.PI / 2, 0, 0] });
	b.add('handle', M.black, new THREE.BoxGeometry(0.24, 0.03, 0.03), { pos: V(0, 0.3, 0) });
	b.add('torch', mat('welder_torch', 0x3a3a40), new THREE.CylinderGeometry(0.02, 0.02, 0.22, 8), { pos: V(0.24, 0.05, 0.05), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

export function buildCartPlan() {
	const b = new Builder('super_cart_plan');
	b.add('paper', mat('plan_blue', 0x3a6ad2), new THREE.BoxGeometry(0.42, 0.004, 0.3), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 3; i++) b.add('lines', mat('plan_line', 0xf2f2ea), new THREE.BoxGeometry(0.3, 0.002, 0.008), { pos: V(0, 0.005, -0.08 + i * 0.08) });
	return b.build();
}

export const models = {
	super_double_cart: buildDoubleCart, super_welder: buildWelder, super_cart_plan: buildCartPlan,
	super_cheese_wheel: buildCheeseWheel, super_fake_cheese: buildFakeCheese, super_cheese_mold: buildCheeseMold,
	super_wax_block: buildWaxBlock,
	super_price_gun: buildPriceGun, super_label_box: buildLabelBox, super_old_yogurt: buildOldYogurt,
	npc_don_oferton: buildDonOferton,
	npc_lalo: buildLalo,
	gondola: buildGondola, dairy_fridge: buildDairyFridge, checkout: buildCheckout, produce_stand: buildProduceStand,
	chest_freezer: buildChestFreezer, food_can: buildFoodCan, shopping_cart: buildShoppingCart,
};

export const views = {
	supermarket: {
		items: [
			{ name: 'gondola', pos: [-2.2, 0, 0] }, { name: 'dairy_fridge', pos: [0.6, 0, -2.0] },
			{ name: 'checkout', pos: [1.6, 0, 1.2] }, { name: 'produce_stand', pos: [3.2, 0, 0], rotY: -Math.PI / 2 },
			{ name: 'chest_freezer', pos: [0.2, 0, 0.6] }, { name: 'food_can', pos: [1.6, 0.9, 0.5] },
			{ name: 'shopping_cart', pos: [-0.6, 0, 2.2], rotY: 0.6 },
		],
		cam: { pos: [0, 3.0, 7.5], target: [0.4, 0.9, 0], fov: 50 },
	},
	carts: {
		items: [{ name: 'super_double_cart', pos: [-0.5, 0, 0], rotY: 0.5 }, { name: 'super_welder', pos: [0.5, 0, 0.2] }, { name: 'super_cart_plan', pos: [0.4, 0, -0.4] }],
		cam: { pos: [0, 1.6, 2.6], target: [0, 0.4, 0], fov: 40 },
	},
	cheese: {
		items: [{ name: 'super_fake_cheese', pos: [-0.5, 0, 0] }, { name: 'super_cheese_wheel', pos: [0.2, 0, 0.3] }, { name: 'super_cheese_mold', pos: [0.4, 0, -0.5] }, { name: 'super_wax_block', pos: [0.6, 0, 0.4] }],
		cam: { pos: [0, 1.2, 2.2], target: [0, 0.15, 0], fov: 40 },
	},
	dates: {
		items: [{ name: 'super_price_gun', pos: [-0.35, 0, 0], rotY: 0.6 }, { name: 'super_label_box', pos: [0.15, 0, 0] }, { name: 'super_old_yogurt', pos: [0.5, 0, 0.1] }],
		cam: { pos: [0, 0.6, 1.2], target: [0, 0.1, 0], fov: 40 },
	},
	don_oferton: {
		items: [{ name: 'npc_don_oferton', pos: [-0.6, 0, 0], rotY: 0.3 }, { name: 'npc_lalo', pos: [0.6, 0, 0], rotY: -0.3, scale: 0.8 }],
		cam: { pos: [0, 1.2, 3.2], target: [0, 0.85, 0], fov: 40 },
	},
};
