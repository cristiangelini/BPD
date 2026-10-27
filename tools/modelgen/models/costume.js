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

export const models = {
	costume_counter: buildCostumeCounter, rack_pirates: buildRackPirates, rack_animals: buildRackAnimals,
	rack_monsters: buildRackMonsters, rack_princesses: buildRackPrincesses, rack_trades: buildRackTrades,
	fitting_curtain: buildFittingCurtain, giant_mirror: buildGiantMirror, mask_case: buildMaskCase,
	stock_shelf: buildStockShelf, box_pile: buildBoxPile, wig_trunk: buildWigTrunk, sale_basket: buildSaleBasket,
	costume_safe: buildCostumeSafe, giant_mustache: buildGiantMustache, mannequin_pirate: buildMannequinPirate,
	mannequin_chicken: buildMannequinChicken, mannequin_astronaut: buildMannequinAstronaut, mannequin_vampire: buildMannequinVampire,
	npc_fantoche: buildFantoche,
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
	costume_mannequins: {
		items: ['pirate', 'chicken', 'astronaut', 'vampire'].map((k, i) => ({ name: 'mannequin_' + k, pos: [(i - 1.5) * 1.0, 0, 0], rotY: 0.3 })),
		cam: { pos: [0, 1.3, 5.6], target: [0, 0.8, 0], fov: 38 },
	},
};
