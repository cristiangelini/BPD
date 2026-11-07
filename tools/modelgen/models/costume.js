// Props of the costume shop "Disfraces El Bigote Postizo" (docs/diseno/allanamiento-disfraces.md): the counter, the
// costume racks, a fitting room's curtain, the giant mirror, the mask display case, the stock room's shelf and boxes,
// the wig trunk, the sale basket, the office's safe and the giant mustache of the sign, with origins at the floor in
// the middle of each piece (the mirror and the mustache at their middle). Placeholder, not final art.
import { Builder, mat, ellipsoid, V, THREE } from '../lib.js';
import { pearBody, eyes } from './pear.js';

// The counter, 3.5 m long, 1 m tall and 0.8 m deep, its front to +Z: a red wooden box with a yellow top.
export function buildCostumeCounter() {
	const b = new Builder('costume_counter');
	b.add('body', mat('counter_red', 0xc8323a), new THREE.BoxGeometry(3.5, 0.96, 0.8), { pos: V(0, 0.48, 0) });
	b.add('top', mat('counter_top', 0xf2c230), new THREE.BoxGeometry(3.6, 0.04, 0.86), { pos: V(0, 0.98, 0) });
	for (let i = 0; i < 4; i++) b.add('star', mat('counter_star', 0xf6f2e2), new THREE.BoxGeometry(0.18, 0.18, 0.01), { pos: V(-1.2 + i * 0.8, 0.5, 0.405), rot: [0, 0, 0.78] });
	return b.build();
}

// A rack of costumes 3 m long along X: a chrome bar on two feet with eight costumes hanging, in `colors`.
function rack(name, colors) {
	const b = new Builder(name);
	const chrome = mat('rack_chrome', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 });
	for (const x of [-1.45, 1.45]) {
		b.add('post', chrome, new THREE.CylinderGeometry(0.025, 0.025, 1.7, 8), { pos: V(x, 0.85, 0) });
		b.add('foot', chrome, new THREE.BoxGeometry(0.06, 0.04, 0.6), { pos: V(x, 0.02, 0) });
	}
	b.add('bar', chrome, new THREE.CylinderGeometry(0.02, 0.02, 2.95, 8), { pos: V(0, 1.68, 0), rot: [0, 0, Math.PI / 2] });
	for (let i = 0; i < 8; i++) {
		const c = mat(name + '_' + (i % colors.length), colors[i % colors.length]);
		b.add('costume', c, new THREE.BoxGeometry(0.12, 1.0, 0.5), { pos: V(-1.2 + i * 0.34, 1.12, 0), rot: [0, 0, (i % 3 - 1) * 0.04] });
		b.add('hanger', chrome, new THREE.BoxGeometry(0.02, 0.06, 0.4), { pos: V(-1.2 + i * 0.34, 1.64, 0) });
	}
	return b;
}

export function buildRackPirates() {
	return rack('rack_pirates', [0x24242a, 0xd83a30, 0xf6f2e2]).build();
}

export function buildRackAnimals() {
	return rack('rack_animals', [0x8a5a30, 0xf2c230, 0xf6f2e2, 0xff8ad8]).build();
}

export function buildRackMonsters() {
	return rack('rack_monsters', [0x3aa86a, 0x6a3aa8, 0x24242a, 0xb0b8c0]).build();
}

export function buildRackPrincesses() {
	return rack('rack_princesses', [0xff5ad2, 0x8ac8ff, 0xf2c230, 0xf6f2e2]).build();
}

export function buildRackTrades() {
	return rack('rack_trades', [0x3a6ad2, 0xf6f2e2, 0xe87a20, 0x5a5650]).build();
}

// A fitting room's curtain, 1.2 m wide and 2.1 m tall, half drawn, on its rod; its middle at the floor.
export function buildFittingCurtain() {
	const b = new Builder('fitting_curtain');
	b.add('rod', mat('curtain_rod', 0xe8b830, { metalness: 0.6, roughness: 0.3 }), new THREE.CylinderGeometry(0.02, 0.02, 1.3, 8), { pos: V(0, 2.15, 0), rot: [Math.PI / 2, 0, 0] });
	const cloth = mat('curtain_red', 0xa81e3a);
	for (let i = 0; i < 4; i++) b.add('fold', cloth, new THREE.BoxGeometry(0.06, 2.05, 0.12), { pos: V((i % 2) * 0.04, 1.08, -0.55 + i * 0.1) });
	return b.build();
}

// The giant mirror, 3 m wide and 2.4 m tall, its glass to +X, its middle at the origin: a gold frame with bulbs.
export function buildGiantMirror() {
	const b = new Builder('giant_mirror');
	const gold = mat('mirror_gold', 0xe8b830, { metalness: 0.6, roughness: 0.3 });
	b.add('frame', gold, new THREE.BoxGeometry(0.08, 2.4, 3.0), { pos: V(0, 0, 0) });
	b.add('glass', mat('mirror_glass', 0xd8ecf4, { metalness: 0.9, roughness: 0.05 }), new THREE.BoxGeometry(0.02, 2.2, 2.8), { pos: V(0.04, 0, 0) });
	const bulb = mat('mirror_bulb', 0xfff2c0, { emissive: 0xfff2c0, emissiveIntensity: 0.6 });
	for (let i = 0; i < 7; i++) b.add('bulb', bulb, new THREE.SphereGeometry(0.045, 8, 6), { pos: V(0.06, 1.15, -1.35 + i * 0.45) });
	return b.build();
}

// The mask display case, 0.8 m deep, 1.8 m tall and 2.4 m long along Z, its glass to -X: a wooden frame, glass and
// three shelves of masks.
export function buildMaskCase() {
	const b = new Builder('mask_case');
	const wood = mat('case_wood', 0x6a4028);
	b.add('base', wood, new THREE.BoxGeometry(0.8, 0.5, 2.4), { pos: V(0, 0.25, 0) });
	b.add('top', wood, new THREE.BoxGeometry(0.8, 0.06, 2.4), { pos: V(0, 1.77, 0) });
	b.add('back', wood, new THREE.BoxGeometry(0.04, 1.3, 2.4), { pos: V(0.38, 1.15, 0) });
	b.add('glass', mat('case_glass', 0xd8ecf4, { transparent: true, opacity: 0.35 }), new THREE.BoxGeometry(0.02, 1.24, 2.36), { pos: V(-0.39, 1.12, 0) });
	const masks = [0xf6f2e2, 0xd83a30, 0x3aa86a, 0xf2c230, 0x6a3aa8, 0x24242a];
	for (let s = 0; s < 2; s++) {
		b.add('shelf', wood, new THREE.BoxGeometry(0.7, 0.03, 2.3), { pos: V(0, 0.9 + s * 0.45, 0) });
		for (let i = 0; i < 5; i++) b.add('mask', mat('mask_' + ((i + s) % masks.length), masks[(i + s) % masks.length]), ellipsoid(0.02, 0.12, 0.09), { pos: V(-0.1, 1.06 + s * 0.45, -0.9 + i * 0.45) });
	}
	return b.build();
}

// A metal shelf of the stock room, 2 m wide, 2.2 m tall and 0.6 m deep, its front to +Z, with costume boxes.
export function buildStockShelf() {
	const b = new Builder('stock_shelf');
	const metal = mat('shelf_metal', 0x7a7e86, { metalness: 0.5, roughness: 0.5 });
	for (const x of [-0.98, 0.98]) for (const z of [-0.28, 0.28]) b.add('post', metal, new THREE.BoxGeometry(0.04, 2.2, 0.04), { pos: V(x, 1.1, z) });
	const boxes = [0xd8b07a, 0xc8a070, 0xe0c090];
	for (let s = 0; s < 4; s++) {
		b.add('board', metal, new THREE.BoxGeometry(2.0, 0.03, 0.6), { pos: V(0, 0.1 + s * 0.65, 0) });
		if (s < 3) for (let i = 0; i < 3; i++) b.add('box', mat('stock_box_' + ((i + s) % 3), boxes[(i + s) % 3]), new THREE.BoxGeometry(0.5, 0.38, 0.45), { pos: V(-0.6 + i * 0.6, 0.31 + s * 0.65, 0) });
	}
	return b.build();
}

// A pile of costume boxes, 1.2 m wide and 1.3 m tall, with a mask sticking out of the top one.
export function buildBoxPile() {
	const b = new Builder('box_pile');
	const boxes = [0xd8b07a, 0xc8a070, 0xe0c090];
	const at = [[-0.3, 0, 0], [0.3, 0, 0.05], [0, 0, 0], [0.05, 0, 0]];
	for (let i = 0; i < 4; i++) {
		const y = i < 2 ? 0.25 : 0.25 + (i - 1) * 0.5;
		b.add('box', mat('pile_box_' + (i % 3), boxes[i % 3]), new THREE.BoxGeometry(0.55, 0.5, 0.5), { pos: V(at[i][0], y, at[i][2]), rot: [0, i * 0.15, 0] });
	}
	b.add('mask', mat('pile_mask', 0x3aa86a), ellipsoid(0.1, 0.12, 0.03), { pos: V(0.05, 1.3, 0.1) });
	return b.build();
}

// The wig trunk, 1 m long, open, with colored wigs coming out.
export function buildWigTrunk() {
	const b = new Builder('wig_trunk');
	const wood = mat('trunk_wood', 0x8a5a30);
	b.add('box', wood, new THREE.BoxGeometry(1.0, 0.5, 0.6), { pos: V(0, 0.25, 0) });
	b.add('lid', wood, new THREE.BoxGeometry(1.0, 0.04, 0.6), { pos: V(0, 0.75, -0.32), rot: [Math.PI / 2 - 0.3, 0, 0] });
	b.add('band', mat('trunk_brass', 0xe8b830, { metalness: 0.6, roughness: 0.3 }), new THREE.BoxGeometry(1.02, 0.05, 0.62), { pos: V(0, 0.4, 0) });
	const wigs = [0xff5ad2, 0xf2c230, 0x3a6ad2, 0xd83a30];
	for (let i = 0; i < 4; i++) b.add('wig', mat('wig_' + i, wigs[i]), ellipsoid(0.14, 0.09, 0.12), { pos: V(-0.33 + i * 0.22, 0.52, 0.02) });
	return b.build();
}

// The sale basket, a wire basket 0.8 m wide with costumes piled in it and a "Sale" tag.
export function buildSaleBasket() {
	const b = new Builder('sale_basket');
	const wire = mat('basket_wire', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 });
	b.add('bottom', wire, new THREE.BoxGeometry(0.8, 0.03, 0.6), { pos: V(0, 0.1, 0) });
	for (const x of [-0.4, 0.4]) b.add('side', wire, new THREE.BoxGeometry(0.02, 0.35, 0.6), { pos: V(x, 0.27, 0) });
	for (const z of [-0.3, 0.3]) b.add('side', wire, new THREE.BoxGeometry(0.8, 0.35, 0.02), { pos: V(0, 0.27, z) });
	for (const x of [-0.38, 0.38]) for (const z of [-0.28, 0.28]) b.add('leg', wire, new THREE.BoxGeometry(0.02, 0.1, 0.02), { pos: V(x, 0.05, z) });
	const cloth = [0xff8ad8, 0x3aa86a, 0xf2c230];
	for (let i = 0; i < 3; i++) b.add('cloth', mat('sale_' + i, cloth[i]), new THREE.BoxGeometry(0.5, 0.1, 0.35), { pos: V(-0.1 + i * 0.1, 0.17 + i * 0.08, 0), rot: [0, i * 0.6, 0.05] });
	b.add('tag', mat('sale_tag', 0xd83a30), new THREE.BoxGeometry(0.3, 0.15, 0.01), { pos: V(0, 0.5, 0.31) });
	return b.build();
}

// The office's little safe, 0.6 m on each side, its door to +Z.
export function buildCostumeSafe() {
	const b = new Builder('costume_safe');
	b.add('box', mat('safe_grey', 0x4a4e56, { metalness: 0.5, roughness: 0.5 }), new THREE.BoxGeometry(0.6, 0.6, 0.6), { pos: V(0, 0.3, 0) });
	b.add('dial', mat('safe_dial', 0xc8ccd2, { metalness: 0.7, roughness: 0.3 }), new THREE.CylinderGeometry(0.07, 0.07, 0.03, 14), { pos: V(0, 0.34, 0.31), rot: [Math.PI / 2, 0, 0] });
	b.add('handle', mat('safe_dial', 0xc8ccd2, { metalness: 0.7, roughness: 0.3 }), new THREE.BoxGeometry(0.03, 0.12, 0.03), { pos: V(0.18, 0.34, 0.32) });
	return b.build();
}

// The giant mustache of the sign, 3 m wide, its front to +Z, its middle at the origin.
export function buildGiantMustache() {
	const b = new Builder('giant_mustache');
	const hair = mat('mustache_black', 0x24242a);
	for (const s of [-1, 1]) {
		b.add('half', hair, ellipsoid(0.8, 0.28, 0.2), { pos: V(s * 0.65, 0, 0), rot: [0, 0, s * 0.25] });
		b.add('curl', hair, ellipsoid(0.25, 0.25, 0.18), { pos: V(s * 1.35, 0.25, 0) });
	}
	return b.build();
}

// A shop mannequin in costume, 1.5 m tall on its round stand: a smooth beige pear with no face dressed as `kind`
// (pirate, chicken, astronaut or vampire). Mimí dresses up like them to play hide and seek.
function mannequin(kind) {
	const b = new Builder('mannequin_' + kind);
	const plastic = mat('mannequin_plastic', 0xe8d8c0, { roughness: 0.35 });
	b.add('stand', mat('mannequin_stand', 0x6a6a70, { metalness: 0.5 }), new THREE.CylinderGeometry(0.28, 0.3, 0.04, 12), { pos: V(0, 0.02, 0.05) });
	if (kind === 'pirate') {
		pearBody(b, plastic, { shirt: mat('pirate_shirt', 0xd83a30), pants: mat('pirate_pants', 0x24242a), shoes: mat('pirate_boots', 0x3a2a20) });
		b.add('hat', mat('pirate_hat', 0x24242a), new THREE.CylinderGeometry(0.3, 0.3, 0.06, 3), { pos: V(0, 1.5, 0.02), rot: [0, Math.PI / 6, 0] });
		b.add('hat', mat('pirate_skull', 0xf6f2e2), new THREE.BoxGeometry(0.06, 0.06, 0.01), { pos: V(0, 1.52, 0.17) });
		b.add('patch', mat('pirate_hat', 0x24242a), new THREE.BoxGeometry(0.08, 0.06, 0.02), { pos: V(0.07, 1.34, 0.2) });
	} else if (kind === 'chicken') {
		const feathers = mat('chicken_yellow', 0xf6dc4a);
		pearBody(b, feathers, { shirt: feathers, pants: feathers, shoes: mat('chicken_feet', 0xf28a1e), belted: false, onePiece: true });
		b.add('crest', mat('chicken_crest', 0xe0302a), new THREE.BoxGeometry(0.04, 0.12, 0.18), { pos: V(0, 1.55, 0.02) });
		b.add('beak', mat('chicken_feet', 0xf28a1e), new THREE.ConeGeometry(0.05, 0.12, 6), { pos: V(0, 1.3, 0.25), rot: [Math.PI / 2, 0, 0] });
	} else if (kind === 'astronaut') {
		const suit = mat('astro_white', 0xf0f0ec);
		pearBody(b, plastic, { shirt: suit, pants: suit, shoes: mat('astro_boots', 0x8a8e96), belted: false, onePiece: true });
		b.add('helmet', mat('astro_glass', 0x9ad0f0, { transparent: true, opacity: 0.45 }), new THREE.SphereGeometry(0.27, 12, 8), { pos: V(0, 1.3, 0.02) });
		b.add('flag', mat('astro_badge', 0x3a6ad8), new THREE.BoxGeometry(0.1, 0.07, 0.01), { pos: V(0.14, 0.9, 0.3) });
	} else {
		pearBody(b, plastic, { shirt: mat('vampire_suit', 0x24242a), pants: mat('vampire_suit', 0x24242a), shoes: mat('vampire_shoes', 0x101014) });
		b.add('cape', mat('vampire_cape', 0x9a1a2a), new THREE.BoxGeometry(0.8, 1.0, 0.03), { pos: V(0, 0.7, -0.38), rot: [0.12, 0, 0] });
		b.add('collar', mat('vampire_cape', 0x9a1a2a), new THREE.BoxGeometry(0.5, 0.22, 0.03), { pos: V(0, 1.18, -0.12), rot: [-0.3, 0, 0] });
	}
	return b.build();
}

export const buildMannequinPirate = () => mannequin('pirate');
export const buildMannequinChicken = () => mannequin('chicken');
export const buildMannequinAstronaut = () => mannequin('astronaut');
export const buildMannequinVampire = () => mannequin('vampire');

// Don Fantoche, the owner: short and round, always in costume; today a pirate with a striped shirt, a red sash, an
// eye patch, a black hat with a skull, a big curled mustache and a green plush parrot on his shoulder. The game
// scales him short and wide.
export function buildFantoche() {
	const b = new Builder('npc_fantoche');
	const shirt = mat('fantoche_shirt', 0xf6f2e2);
	pearBody(b, mat('skin_fantoche', 0xe8b48a), { shirt, pants: mat('fantoche_pants', 0x3a3a8a), shoes: mat('fantoche_boots', 0x3a2a20), belted: false });
	const stripe = mat('fantoche_stripe', 0xd83a30);
	for (let i = 0; i < 3; i++) b.add('stripes', stripe, new THREE.CylinderGeometry(0.4 - i * 0.05, 0.42 - i * 0.05, 0.05, 12), { pos: V(0, 0.62 + i * 0.14, 0) });
	b.add('sash', stripe, new THREE.CylinderGeometry(0.47, 0.47, 0.09, 14), { pos: V(0, 0.52, 0) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	const black = mat('fantoche_black', 0x24242a);
	b.add('patch', black, new THREE.BoxGeometry(0.09, 0.07, 0.02), { pos: V(0.08, 1.35, 0.2) });
	b.add('patch', black, new THREE.BoxGeometry(0.38, 0.015, 0.015), { pos: V(0, 1.4, 0.17), rot: [0, 0, -0.25] });
	for (const s of [-1, 1]) {
		b.add('mustache', black, ellipsoid(0.1, 0.035, 0.03, 8, 4), { pos: V(s * 0.08, 1.24, 0.2), rot: [0, 0, s * 0.3] });
		b.add('mustache', black, ellipsoid(0.035, 0.035, 0.03, 6, 4), { pos: V(s * 0.17, 1.28, 0.18) });
	}
	b.add('hat', black, new THREE.CylinderGeometry(0.32, 0.32, 0.06, 3), { pos: V(0, 1.5, 0.02), rot: [0, Math.PI / 6, 0] });
	b.add('hat', black, new THREE.CylinderGeometry(0.16, 0.2, 0.16, 10), { pos: V(0, 1.57, 0.02) });
	b.add('hat', mat('fantoche_skull', 0xf6f2e2), new THREE.BoxGeometry(0.06, 0.06, 0.01), { pos: V(0, 1.58, 0.2) });
	const parrot = mat('parrot_green', 0x3fbf4a);
	b.add('parrot', parrot, ellipsoid(0.08, 0.12, 0.08, 8, 5), { pos: V(-0.24, 1.18, -0.02) });
	b.add('parrot', parrot, ellipsoid(0.06, 0.06, 0.06, 8, 5), { pos: V(-0.24, 1.32, 0.02) });
	b.add('parrot', mat('parrot_beak', 0xf2c230), new THREE.ConeGeometry(0.025, 0.06, 6), { pos: V(-0.24, 1.31, 0.09), rot: [Math.PI / 2, 0, 0] });
	b.add('parrot', mat('parrot_tail', 0xd83a30), new THREE.BoxGeometry(0.05, 0.12, 0.03), { pos: V(-0.24, 1.06, -0.1), rot: [0.4, 0, 0] });
	return b.build();
}

// Mimí, Don Fantoche's niece, playing hide and seek dressed as one of the chicken mannequins, stand and all: from
// afar she's one more, but her chicken hood leaves a round face with eyes and rosy cheeks, and two brown pigtails stick
// out of it. The game scales her small.
export function buildMimi() {
	const b = new Builder('npc_mimi');
	b.add('stand', mat('mannequin_stand', 0x6a6a70, { metalness: 0.5 }), new THREE.CylinderGeometry(0.28, 0.3, 0.04, 12), { pos: V(0, 0.02, 0.05) });
	const feathers = mat('chicken_yellow', 0xf6dc4a);
	pearBody(b, feathers, { shirt: feathers, pants: feathers, shoes: mat('chicken_feet', 0xf28a1e), belted: false, onePiece: true });
	b.add('crest', mat('chicken_crest', 0xe0302a), new THREE.BoxGeometry(0.04, 0.12, 0.18), { pos: V(0, 1.55, 0.02) });
	b.add('face', mat('skin_mimi', 0xf0c49a), ellipsoid(0.13, 0.14, 0.06, 10, 6), { pos: V(0, 1.3, 0.17) });
	eyes(b, 1.33, 0.21, 0.05, 0.035);
	const cheek = mat('mimi_cheek', 0xf08a8a);
	const hair = mat('mimi_hair', 0x6a3a1e);
	for (const s of [-1, 1]) {
		b.add('face', cheek, ellipsoid(0.025, 0.02, 0.01, 6, 4), { pos: V(s * 0.08, 1.26, 0.215) });
		b.add('hair', hair, ellipsoid(0.05, 0.1, 0.05, 6, 4), { pos: V(s * 0.22, 1.24, 0.0), rot: [0, 0, s * 0.5] });
	}
	b.add('beak', mat('chicken_feet', 0xf28a1e), new THREE.ConeGeometry(0.04, 0.09, 6), { pos: V(0, 1.47, 0.18), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The bear costume stuffed with the robbery's bills (the bear loot story): a shop mannequin in a big brown bear suit
// on its stand, 1.7 m tall and wide as a wardrobe, with a cream belly and muzzle, round ears and green bills sticking
// out of the seams at the neck, the belly and the sides.
export function buildBearLoot() {
	const b = new Builder('bear_loot');
	b.add('stand', mat('mannequin_stand', 0x6a6a70, { metalness: 0.5 }), new THREE.CylinderGeometry(0.34, 0.36, 0.04, 12), { pos: V(0, 0.02, 0.05) });
	const fur = mat('bear_fur', 0x7a4a26);
	const cream = mat('bear_cream', 0xe8cfa0);
	b.add('body', fur, ellipsoid(0.48, 0.62, 0.4, 12, 8), { pos: V(0, 0.68, 0) });
	b.add('belly', cream, ellipsoid(0.32, 0.42, 0.06, 10, 6), { pos: V(0, 0.64, 0.36) });
	b.add('head', fur, ellipsoid(0.3, 0.28, 0.27, 10, 7), { pos: V(0, 1.42, 0.02) });
	b.add('head', cream, ellipsoid(0.13, 0.1, 0.1, 8, 5), { pos: V(0, 1.36, 0.25) });
	b.add('head', mat('bear_nose', 0x241a14), ellipsoid(0.05, 0.035, 0.03, 6, 4), { pos: V(0, 1.4, 0.34) });
	eyes(b, 1.5, 0.25, 0.11, 0.04);
	for (const s of [-1, 1]) {
		b.add('ears', fur, ellipsoid(0.09, 0.09, 0.05, 8, 5), { pos: V(s * 0.22, 1.66, 0) });
		b.add('ears', cream, ellipsoid(0.05, 0.05, 0.02, 6, 4), { pos: V(s * 0.22, 1.66, 0.04) });
		b.add('arms', fur, ellipsoid(0.12, 0.32, 0.12, 8, 5), { pos: V(s * 0.5, 0.82, 0.04), rot: [0, 0, s * 0.35] });
		b.add('legs', fur, ellipsoid(0.15, 0.1, 0.2, 8, 5), { pos: V(s * 0.22, 0.12, 0.1) });
	}
	const bill = mat('bear_bill', 0x6ab86a);
	const sticking = [[-0.12, 1.17, 0.3, 0.3], [0.15, 1.18, 0.28, -0.4], [0.32, 0.5, 0.33, 0.6], [-0.44, 0.75, 0.2, -0.8], [0.45, 0.95, 0.15, 0.9]];
	for (const [x, y, z, r] of sticking) b.add('bills', bill, new THREE.BoxGeometry(0.15, 0.07, 0.01), { pos: V(x, y, z), rot: [0, 0, r] });
	return b.build();
}

// The list of the night's rentals (bear loot extra): a white sheet with a red header and rows, 21 x 30 cm, flat.
export function buildRentalList() {
	const b = new Builder('rental_list');
	b.add('sheet', mat('paper_white', 0xf4f2ea), new THREE.BoxGeometry(0.21, 0.004, 0.3), { pos: V(0, 0.002, 0) });
	b.add('header', mat('rental_red', 0xd83a30), new THREE.BoxGeometry(0.17, 0.002, 0.03), { pos: V(0, 0.005, -0.12) });
	for (let i = 0; i < 8; i++) b.add('rows', mat('ink', 0x30303a), new THREE.BoxGeometry(0.16, 0.002, 0.008), { pos: V(0, 0.005, -0.08 + i * 0.026) });
	return b.build();
}

// A clown mask from the robbery (bear loot extra): a white face lying on its back, red nose and smile, blue tufts.
export function buildClownMask() {
	const b = new Builder('clown_mask');
	b.add('face', mat('clown_white', 0xf6f2ea), ellipsoid(0.12, 0.15, 0.05, 10, 6), { pos: V(0, 0.05, 0), rot: [-Math.PI / 2, 0, 0] });
	b.add('nose', mat('clown_red', 0xe0302a), new THREE.SphereGeometry(0.03, 8, 6), { pos: V(0, 0.1, 0.0) });
	b.add('smile', mat('clown_red', 0xe0302a), new THREE.BoxGeometry(0.1, 0.01, 0.02), { pos: V(0, 0.09, 0.07) });
	for (const s of [-1, 1]) {
		b.add('eyes', mat('clown_blue', 0x3a6ad8), new THREE.BoxGeometry(0.035, 0.01, 0.05), { pos: V(s * 0.05, 0.09, -0.04) });
		b.add('hair', mat('clown_blue', 0x3a6ad8), ellipsoid(0.06, 0.04, 0.06, 6, 4), { pos: V(s * 0.13, 0.05, -0.08) });
	}
	return b.build();
}

// The sewing machine of the fake costumes (false fitting room main evidence): a cream machine on a dark wooden base,
// 0.7 m long along Z, with a spool and a half-sewn "Superfantasía" costume under the needle.
export function buildSewingMachine() {
	const b = new Builder('sewing_machine');
	b.add('base', mat('sewing_wood', 0x4a3426), new THREE.BoxGeometry(0.45, 0.08, 0.7), { pos: V(0, 0.04, 0) });
	const cream = mat('sewing_cream', 0xece2c8);
	b.add('body', cream, new THREE.BoxGeometry(0.2, 0.08, 0.6), { pos: V(0, 0.12, 0) });
	b.add('body', cream, new THREE.BoxGeometry(0.18, 0.28, 0.14), { pos: V(0, 0.28, -0.22) });
	b.add('body', cream, new THREE.BoxGeometry(0.16, 0.1, 0.5), { pos: V(0, 0.4, -0.02) });
	b.add('body', cream, new THREE.BoxGeometry(0.14, 0.16, 0.08), { pos: V(0, 0.29, 0.2) });
	b.add('needle', mat('sewing_steel', 0xc8ccd2, { metalness: 0.6 }), new THREE.CylinderGeometry(0.006, 0.006, 0.08, 6), { pos: V(0, 0.18, 0.2) });
	b.add('wheel', mat('sewing_steel', 0xc8ccd2, { metalness: 0.6 }), new THREE.CylinderGeometry(0.07, 0.07, 0.03, 12), { pos: V(0.1, 0.32, -0.22), rot: [0, 0, Math.PI / 2] });
	b.add('spool', mat('sewing_thread', 0xd83a30), new THREE.CylinderGeometry(0.02, 0.02, 0.05, 8), { pos: V(0, 0.48, -0.1) });
	b.add('cloth', mat('sewing_cloth', 0x3a6ad8), new THREE.BoxGeometry(0.4, 0.01, 0.28), { pos: V(-0.05, 0.165, 0.22), rot: [0, 0.2, 0] });
	b.add('cloth', mat('sewing_tag', 0xf2c230), new THREE.BoxGeometry(0.06, 0.012, 0.04), { pos: V(-0.12, 0.172, 0.28) });
	return b.build();
}

// The fake brand labels (false fitting room extra): a stack of yellow "Superfantasía" tags tied with a red ribbon.
export function buildFakeLabels() {
	const b = new Builder('fake_labels');
	for (let i = 0; i < 6; i++) b.add('tags', mat('label_yellow', 0xf2c230), new THREE.BoxGeometry(0.1, 0.008, 0.06), { pos: V(0, 0.004 + i * 0.009, 0), rot: [0, (i % 3 - 1) * 0.15, 0] });
	b.add('ribbon', mat('label_ribbon', 0xd83a30), new THREE.BoxGeometry(0.02, 0.06, 0.07), { pos: V(0, 0.03, 0) });
	return b.build();
}

// The costume pattern (false fitting room extra): a brown paper sheet folded in two with a dashed outline of a suit.
export function buildCostumePattern() {
	const b = new Builder('costume_pattern');
	b.add('paper', mat('pattern_paper', 0xc8a878), new THREE.BoxGeometry(0.3, 0.012, 0.4), { pos: V(0, 0.006, 0) });
	const ink = mat('pattern_ink', 0x30303a);
	b.add('outline', ink, new THREE.BoxGeometry(0.16, 0.002, 0.008), { pos: V(0, 0.013, -0.12) });
	b.add('outline', ink, new THREE.BoxGeometry(0.008, 0.002, 0.26), { pos: V(-0.08, 0.013, 0.01) });
	b.add('outline', ink, new THREE.BoxGeometry(0.008, 0.002, 0.26), { pos: V(0.08, 0.013, 0.01) });
	b.add('outline', ink, new THREE.BoxGeometry(0.16, 0.002, 0.008), { pos: V(0, 0.013, 0.14) });
	return b.build();
}

// The false back of fitting room 3: a mirror 2.8 m wide (along Z) and 2.4 m tall in a gold frame, 0.08 m thick, its
// glass to +X, origin at the floor in the middle.
export function buildFalseBack() {
	const b = new Builder('false_back');
	b.add('frame', mat('false_frame', 0xc89a30, { metalness: 0.4 }), new THREE.BoxGeometry(0.08, 2.4, 2.8), { pos: V(0, 1.2, 0) });
	b.add('glass', mat('false_glass', 0xb8d8e8, { metalness: 0.8, roughness: 0.1 }), new THREE.BoxGeometry(0.02, 2.2, 2.6), { pos: V(0.04, 1.2, 0) });
	return b.build();
}

// The drum of itching powder (itchy costumes main evidence): a blue plastic drum with a red band and a lid, 0.7 m tall.
export function buildItchDrum() {
	const b = new Builder('itch_drum');
	b.add('drum', mat('drum_blue', 0x2a5ab8), new THREE.CylinderGeometry(0.25, 0.25, 0.66, 14), { pos: V(0, 0.33, 0) });
	b.add('lid', mat('drum_lid', 0x1a3a80), new THREE.CylinderGeometry(0.26, 0.26, 0.04, 14), { pos: V(0, 0.68, 0) });
	b.add('band', mat('drum_red', 0xd83a30), new THREE.CylinderGeometry(0.255, 0.255, 0.16, 14), { pos: V(0, 0.38, 0) });
	for (let i = 0; i < 5; i++) b.add('dots', mat('drum_yellow', 0xf2c230), new THREE.SphereGeometry(0.025, 6, 4), { pos: V(Math.sin(i * 0.5 - 1) * 0.25, 0.38 + (i % 2) * 0.04 - 0.02, Math.cos(i * 0.5 - 1) * 0.25) });
	return b.build();
}

// The jars of "Antipica" cream (itchy costumes extra): three white jars with green lids on a cardboard tray.
export function buildCreamJars() {
	const b = new Builder('cream_jars');
	b.add('tray', mat('jar_tray', 0xc8a878), new THREE.BoxGeometry(0.3, 0.02, 0.12), { pos: V(0, 0.01, 0) });
	for (const x of [-0.09, 0, 0.09]) {
		b.add('jar', mat('jar_white', 0xf6f2ea), new THREE.CylinderGeometry(0.04, 0.04, 0.08, 10), { pos: V(x, 0.06, 0) });
		b.add('lid', mat('jar_green', 0x3aa860), new THREE.CylinderGeometry(0.042, 0.042, 0.02, 10), { pos: V(x, 0.11, 0) });
	}
	return b.build();
}

// The flyer of the cousin's pharmacy (itchy costumes extra): a white sheet with a big green cross, flat.
export function buildPharmacyFlyer() {
	const b = new Builder('pharmacy_flyer');
	b.add('sheet', mat('paper_white', 0xf4f2ea), new THREE.BoxGeometry(0.15, 0.004, 0.21), { pos: V(0, 0.002, 0) });
	const green = mat('flyer_green', 0x2aa850);
	b.add('cross', green, new THREE.BoxGeometry(0.03, 0.002, 0.09), { pos: V(0, 0.005, -0.03) });
	b.add('cross', green, new THREE.BoxGeometry(0.09, 0.002, 0.03), { pos: V(0, 0.005, -0.03) });
	for (let i = 0; i < 3; i++) b.add('rows', mat('ink', 0x30303a), new THREE.BoxGeometry(0.11, 0.002, 0.008), { pos: V(0, 0.005, 0.04 + i * 0.02) });
	return b.build();
}

// The itchy costume of the sale basket (itchy costumes clue): a folded pink bunny costume with two ears and red specks.
export function buildItchyCostume() {
	const b = new Builder('itchy_costume');
	const pink = mat('itchy_pink', 0xf0a0c8);
	b.add('body', pink, new THREE.BoxGeometry(0.4, 0.1, 0.3), { pos: V(0, 0.05, 0) });
	for (const x of [-0.06, 0.06]) b.add('ears', pink, ellipsoid(0.035, 0.02, 0.12, 6, 4), { pos: V(x, 0.1, -0.16) });
	for (let i = 0; i < 7; i++) b.add('specks', mat('itchy_red', 0xd83a30), new THREE.BoxGeometry(0.015, 0.004, 0.015), { pos: V(-0.15 + i * 0.05, 0.101, ((i * 37) % 9 - 4) * 0.03) });
	return b.build();
}

// The theater's trunk with the stolen costumes (theater costumes main evidence): a dark red trunk with gold trim and the
// two theater masks on its lid, a ruffled sleeve sticking out, 1 m long along X.
export function buildTheaterTrunk() {
	const b = new Builder('theater_trunk');
	const red = mat('trunk_red', 0x7a1a24);
	const gold = mat('trunk_gold', 0xd8a830, { metalness: 0.5 });
	b.add('box', red, new THREE.BoxGeometry(1.0, 0.5, 0.55), { pos: V(0, 0.25, 0) });
	b.add('lid', red, new THREE.BoxGeometry(1.02, 0.1, 0.57), { pos: V(0, 0.55, 0) });
	for (const x of [-0.45, 0.45]) b.add('trim', gold, new THREE.BoxGeometry(0.04, 0.62, 0.59), { pos: V(x, 0.31, 0) });
	b.add('lock', gold, new THREE.BoxGeometry(0.08, 0.1, 0.02), { pos: V(0, 0.45, 0.29) });
	b.add('masks', mat('mask_white', 0xf6f2ea), ellipsoid(0.08, 0.02, 0.1, 8, 4), { pos: V(-0.1, 0.61, 0) });
	b.add('masks', mat('mask_black', 0x24242a), ellipsoid(0.08, 0.02, 0.1, 8, 4), { pos: V(0.1, 0.61, 0.02) });
	b.add('sleeve', mat('sleeve_ruff', 0xf2c230), new THREE.BoxGeometry(0.2, 0.05, 0.12), { pos: V(0.3, 0.5, 0.3), rot: [0.3, 0, 0.2] });
	return b.build();
}

// The theater's stamp (theater costumes extra): a wooden handle on a red rubber block.
export function buildTheaterStamp() {
	const b = new Builder('theater_stamp');
	b.add('block', mat('stamp_wood', 0x8a5a30), new THREE.BoxGeometry(0.1, 0.04, 0.07), { pos: V(0, 0.03, 0) });
	b.add('rubber', mat('stamp_red', 0xd83a30), new THREE.BoxGeometry(0.1, 0.01, 0.07), { pos: V(0, 0.005, 0) });
	b.add('handle', mat('stamp_wood', 0x8a5a30), new THREE.CylinderGeometry(0.02, 0.025, 0.08, 8), { pos: V(0, 0.09, 0) });
	b.add('knob', mat('stamp_wood', 0x8a5a30), new THREE.SphereGeometry(0.03, 8, 6), { pos: V(0, 0.14, 0) });
	return b.build();
}

// The play's program (theater costumes extra): a purple booklet with the two masks on the cover, flat.
export function buildPlayProgram() {
	const b = new Builder('play_program');
	b.add('cover', mat('program_purple', 0x5a2a8a), new THREE.BoxGeometry(0.15, 0.008, 0.21), { pos: V(0, 0.004, 0) });
	b.add('masks', mat('mask_white', 0xf6f2ea), new THREE.BoxGeometry(0.04, 0.002, 0.05), { pos: V(-0.025, 0.009, -0.02) });
	b.add('masks', mat('mask_black', 0x24242a), new THREE.BoxGeometry(0.04, 0.002, 0.05), { pos: V(0.025, 0.009, -0.01) });
	return b.build();
}

// The theater's poster (theater costumes): a cream sheet 0.8 x 1.1 m on the wall, its face to +X, with a purple band and
// the two masks, origin in its middle.
export function buildTheaterPoster() {
	const b = new Builder('theater_poster');
	b.add('sheet', mat('poster_cream', 0xf2e8c8), new THREE.BoxGeometry(0.01, 1.1, 0.8), { pos: V(0, 0, 0) });
	b.add('band', mat('program_purple', 0x5a2a8a), new THREE.BoxGeometry(0.012, 0.2, 0.8), { pos: V(0, 0.4, 0) });
	b.add('masks', mat('mask_white', 0xf6f2ea), ellipsoid(0.01, 0.13, 0.1, 8, 4), { pos: V(0.01, 0.05, -0.1) });
	b.add('masks', mat('mask_black', 0x24242a), ellipsoid(0.01, 0.13, 0.1, 8, 4), { pos: V(0.01, 0.05, 0.1) });
	b.add('cross', mat('poster_red', 0xd83a30), new THREE.BoxGeometry(0.014, 0.06, 0.7), { pos: V(0.012, 0.05, 0), rot: [0.5, 0, 0] });
	return b.build();
}

// The box of colored smoke bombs (smoke bombs main evidence): an open cardboard box full of pink, green, blue and
// yellow balls with fuses, 0.6 x 0.35 x 0.4 m.
export function buildSmokeBox() {
	const b = new Builder('smoke_box');
	const card = mat('smoke_card', 0xb88a58);
	b.add('box', card, new THREE.BoxGeometry(0.6, 0.3, 0.4), { pos: V(0, 0.15, 0) });
	for (const s of [-1, 1]) b.add('flaps', card, new THREE.BoxGeometry(0.6, 0.01, 0.16), { pos: V(0, 0.33, s * 0.26), rot: [s * 0.6, 0, 0] });
	const colors = [0xff7ac8, 0x5ad86a, 0x5a8ae8, 0xf2d230];
	for (let i = 0; i < 12; i++) {
		const x = -0.22 + (i % 4) * 0.147;
		const z = -0.12 + Math.floor(i / 4) * 0.12;
		b.add('bombs', mat('bomb_' + (i % 4), colors[i % 4]), new THREE.SphereGeometry(0.06, 8, 6), { pos: V(x, 0.32, z) });
		b.add('fuses', mat('bomb_fuse', 0x30303a), new THREE.CylinderGeometry(0.006, 0.006, 0.05, 4), { pos: V(x, 0.39, z) });
	}
	return b.build();
}

// A magician's top hat standing on its brim with a band, its origin at the floor.
function topHat(name, color, band) {
	const b = new Builder(name);
	b.add('brim', mat(name + '_felt', color), new THREE.CylinderGeometry(0.18, 0.18, 0.015, 14), { pos: V(0, 0.008, 0) });
	b.add('crown', mat(name + '_felt', color), new THREE.CylinderGeometry(0.11, 0.115, 0.2, 14), { pos: V(0, 0.115, 0) });
	b.add('band', mat(name + '_band', band), new THREE.CylinderGeometry(0.117, 0.117, 0.04, 14), { pos: V(0, 0.04, 0) });
	return b;
}

// The magician's hat with a double bottom (smoke bombs extra): black, its red false bottom hanging open under the brim.
export function buildDoubleHat() {
	const b = topHat('double_hat', 0x1a1a20, 0xd83a30);
	b.add('bottom', mat('double_hat_band', 0xd83a30), new THREE.CylinderGeometry(0.1, 0.1, 0.01, 12), { pos: V(0.09, 0.03, 0), rot: [0, 0, 0.9] });
	return b.build();
}

// The show hat on the wig trunk (smoke bombs clue): purple with yellow stars; thrown on the floor it puffs smoke.
export function buildShowHat() {
	const b = topHat('show_hat', 0x5a2a8a, 0xf2c230);
	for (let i = 0; i < 5; i++) b.add('stars', mat('show_hat_band', 0xf2c230), new THREE.BoxGeometry(0.03, 0.03, 0.005), { pos: V(Math.sin(i * 1.26) * 0.116, 0.12 + (i % 2) * 0.05, Math.cos(i * 1.26) * 0.116), rot: [0, i * 1.26, 0.78] });
	return b.build();
}

// The list of smoke bomb buyers (smoke bombs extra): a pink sheet with rows, flat.
export function buildSmokeClients() {
	const b = new Builder('smoke_clients');
	b.add('sheet', mat('smoke_paper', 0xf8d8e8), new THREE.BoxGeometry(0.21, 0.004, 0.3), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 9; i++) b.add('rows', mat('ink', 0x30303a), new THREE.BoxGeometry(0.16, 0.002, 0.008), { pos: V(0, 0.005, -0.11 + i * 0.026) });
	return b.build();
}

export const models = {
	costume_counter: buildCostumeCounter, rack_pirates: buildRackPirates, rack_animals: buildRackAnimals,
	rack_monsters: buildRackMonsters, rack_princesses: buildRackPrincesses, rack_trades: buildRackTrades,
	fitting_curtain: buildFittingCurtain, giant_mirror: buildGiantMirror, mask_case: buildMaskCase,
	stock_shelf: buildStockShelf, box_pile: buildBoxPile, wig_trunk: buildWigTrunk, sale_basket: buildSaleBasket,
	costume_safe: buildCostumeSafe, giant_mustache: buildGiantMustache, mannequin_pirate: buildMannequinPirate,
	mannequin_chicken: buildMannequinChicken, mannequin_astronaut: buildMannequinAstronaut, mannequin_vampire: buildMannequinVampire,
	npc_fantoche: buildFantoche, npc_mimi: buildMimi,
	bear_loot: buildBearLoot, rental_list: buildRentalList, clown_mask: buildClownMask,
	sewing_machine: buildSewingMachine, fake_labels: buildFakeLabels, costume_pattern: buildCostumePattern,
	false_back: buildFalseBack, itch_drum: buildItchDrum, cream_jars: buildCreamJars, pharmacy_flyer: buildPharmacyFlyer,
	itchy_costume: buildItchyCostume, theater_trunk: buildTheaterTrunk, theater_stamp: buildTheaterStamp,
	play_program: buildPlayProgram, theater_poster: buildTheaterPoster, smoke_box: buildSmokeBox, double_hat: buildDoubleHat,
	show_hat: buildShowHat, smoke_clients: buildSmokeClients,
};

export const views = {
	costume_shop: {
		items: [
			{ name: 'costume_counter', pos: [3.4, 0, 1.6] }, { name: 'rack_pirates', pos: [-2.2, 0, -1.4] },
			{ name: 'rack_animals', pos: [1.4, 0, -1.4] }, { name: 'rack_monsters', pos: [-2.2, 0, 0.6] },
			{ name: 'fitting_curtain', pos: [-4.6, 0, 1.0] }, { name: 'giant_mirror', pos: [-4.8, 1.3, -1.6] },
			{ name: 'mask_case', pos: [5.4, 0, -1.2], rotY: 0 }, { name: 'stock_shelf', pos: [1.6, 0, -3.2] },
			{ name: 'box_pile', pos: [-0.6, 0, -3.2] }, { name: 'wig_trunk', pos: [-1.0, 0, 2.6] },
			{ name: 'sale_basket', pos: [0.6, 0, 2.6] }, { name: 'costume_safe', pos: [5.6, 0, 1.6] },
			{ name: 'giant_mustache', pos: [0.6, 3.4, -3.2] },
		],
		cam: { pos: [0.4, 5.0, 10.0], target: [0.4, 0.9, 0], fov: 50 },
	},
	fantoche: {
		items: [{ name: 'npc_fantoche', pos: [0, 0, 0], rotY: 0.3, scale: [1.05, 0.88, 1.05] }],
		cam: { pos: [0, 1.2, 3.6], target: [0, 0.8, 0], fov: 34 },
	},
	bear_loot: {
		items: [{ name: 'bear_loot', pos: [-0.5, 0, 0], rotY: 0.3 }, { name: 'rental_list', pos: [0.55, 0, 0.3], rotY: 0.2 },
			{ name: 'clown_mask', pos: [0.75, 0, -0.15] }],
		cam: { pos: [0, 1.4, 3.6], target: [0, 0.6, 0], fov: 40 },
	},
	false_fitting_room: {
		items: [{ name: 'false_back', pos: [-0.9, 0, -0.4], rotY: -1.2 }, { name: 'sewing_machine', pos: [0.4, 0, 0.2], rotY: 0.5 },
			{ name: 'fake_labels', pos: [0.9, 0, 0.7] }, { name: 'costume_pattern', pos: [1.2, 0, 0.2], rotY: 0.3 }],
		cam: { pos: [0.2, 1.6, 3.8], target: [0.2, 0.7, 0], fov: 44 },
	},
	itchy_costumes: {
		items: [{ name: 'itch_drum', pos: [-0.5, 0, 0] }, { name: 'cream_jars', pos: [0.2, 0, 0.3] },
			{ name: 'pharmacy_flyer', pos: [0.6, 0, 0.2], rotY: 0.3 }, { name: 'itchy_costume', pos: [0.4, 0, -0.3], rotY: -0.2 }],
		cam: { pos: [0, 1.2, 2.2], target: [0, 0.25, 0], fov: 40 },
	},
	theater_costumes: {
		items: [{ name: 'theater_trunk', pos: [-0.5, 0, 0], rotY: 0.2 }, { name: 'theater_stamp', pos: [0.4, 0, 0.4] },
			{ name: 'play_program', pos: [0.7, 0, 0.1], rotY: 0.3 }, { name: 'theater_poster', pos: [0.8, 0.8, -0.6], rotY: -1.2 }],
		cam: { pos: [0, 1.4, 2.8], target: [0, 0.4, 0], fov: 44 },
	},
	smoke_bombs: {
		items: [{ name: 'smoke_box', pos: [-0.4, 0, 0] }, { name: 'double_hat', pos: [0.35, 0, 0.3] },
			{ name: 'show_hat', pos: [0.6, 0, -0.2] }, { name: 'smoke_clients', pos: [0.1, 0, 0.6], rotY: 0.3 }],
		cam: { pos: [0, 1.2, 2.0], target: [0, 0.2, 0], fov: 40 },
	},
	mimi: {
		items: [{ name: 'mannequin_chicken', pos: [-0.6, 0, 0], rotY: 0.2 }, { name: 'npc_mimi', pos: [0.6, 0, 0], rotY: -0.2, scale: [0.85, 0.85, 0.85] }],
		cam: { pos: [0, 1.2, 3.4], target: [0, 0.8, 0], fov: 36 },
	},
	costume_mannequins: {
		items: ['pirate', 'chicken', 'astronaut', 'vampire'].map((k, i) => ({ name: 'mannequin_' + k, pos: [(i - 1.5) * 1.0, 0, 0], rotY: 0.3 })),
		cam: { pos: [0, 1.3, 5.6], target: [0, 0.8, 0], fov: 38 },
	},
};
