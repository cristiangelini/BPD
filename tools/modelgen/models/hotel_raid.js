// The hotel raid (hotel-allanamiento.md, step 1): the bedside lamp that breaks, 0.3 m wide and 0.42 m tall with its
// origin in the middle, like the ornaments. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

export function buildHotelLamp() {
	const brass = mat('lamp_brass', 0xc9a04a), shade = mat('lamp_shade', 0xf3e2b8, { emissive: 0x3a2a10 });
	const fringe = mat('lamp_fringe', 0xb0283a);
	const b = new Builder('hotel_lamp');
	b.add('base', brass, new THREE.CylinderGeometry(0.07, 0.09, 0.04, 12), { pos: V(0, -0.19, 0) });
	b.add('base', brass, new THREE.SphereGeometry(0.06, 10, 7), { pos: V(0, -0.13, 0) });
	b.add('base', brass, new THREE.CylinderGeometry(0.012, 0.012, 0.18, 6), { pos: V(0, -0.02, 0) });
	b.add('shade', shade, new THREE.CylinderGeometry(0.08, 0.15, 0.16, 12, 1, true), { pos: V(0, 0.13, 0) });
	b.add('shade', fringe, new THREE.CylinderGeometry(0.152, 0.152, 0.02, 12, 1, true), { pos: V(0, 0.05, 0) });
	return b.build();
}

// The casino of the 13 (step 4): the roulette (0.8 m wide, 0.3 m tall, origin in the middle), the box of chips, the
// debt book and a little stack of chips left as a clue.
export function buildRoulette() {
	const wood = mat('roulette_wood', 0x6b3b1e), green = mat('felt', 0x1f7a3a), red = mat('roulette_red', 0xc42a2a);
	const black = mat('roulette_black', 0x1c1c1c), gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	const b = new Builder('roulette');
	b.add('base', wood, new THREE.CylinderGeometry(0.4, 0.36, 0.18, 24), { pos: V(0, -0.06, 0) });
	b.add('wheel', green, new THREE.CylinderGeometry(0.34, 0.34, 0.04, 24), { pos: V(0, 0.05, 0) });
	for (let i = 0; i < 18; i++) {
		const a = (i / 18) * Math.PI * 2;
		b.add('wheel', i % 2 ? red : black, new THREE.BoxGeometry(0.1, 0.02, 0.06), { pos: V(Math.cos(a) * 0.27, 0.075, Math.sin(a) * 0.27), rot: [0, -a, 0] });
	}
	b.add('wheel', wood, new THREE.CylinderGeometry(0.12, 0.14, 0.05, 12), { pos: V(0, 0.09, 0) });
	b.add('spindle', gold, new THREE.CylinderGeometry(0.015, 0.015, 0.12, 6), { pos: V(0, 0.15, 0) });
	for (const r of [0, Math.PI / 2]) b.add('spindle', gold, new THREE.BoxGeometry(0.2, 0.015, 0.015), { pos: V(0, 0.19, 0), rot: [0, r, 0] });
	b.add('ball', mat('ball', 0xf8f8f8), new THREE.SphereGeometry(0.018, 8, 6), { pos: V(0.3, 0.1, 0.05) });
	return b.build();
}

function chipColors() {
	return [mat('chip_red', 0xd23030), mat('chip_blue', 0x2f5fd0), mat('chip_green', 0x2a9a48), mat('chip_white', 0xf2f2ee)];
}

export function buildChipBox() {
	const wood = mat('chip_box', 0x8a5a2b), felt = mat('felt', 0x1f7a3a), chips = chipColors();
	const b = new Builder('casino_chip_box');
	b.add('box', wood, new THREE.BoxGeometry(0.34, 0.06, 0.22), { pos: V(0, -0.03, 0) });
	b.add('box', felt, new THREE.BoxGeometry(0.32, 0.005, 0.2), { pos: V(0, 0.001, 0) });
	for (let row = 0; row < 4; row++) {
		for (let k = 0; k < 6; k++) {
			b.add('chips', chips[row], new THREE.CylinderGeometry(0.02, 0.02, 0.008, 10), { pos: V(-0.13 + k * 0.052, 0.012 + (k % 3) * 0.008, -0.075 + row * 0.05) });
		}
	}
	b.add('lid', wood, new THREE.BoxGeometry(0.34, 0.012, 0.22), { pos: V(0, 0.07, -0.13), rot: [-1.2, 0, 0] });
	return b.build();
}

export function buildDebtBook() {
	const cover = mat('debt_cover', 0x2b2b33), paper = mat('paper', 0xf3eedf), red = mat('roulette_red', 0xc42a2a);
	const b = new Builder('debt_book');
	b.add('book', cover, new THREE.BoxGeometry(0.15, 0.03, 0.21));
	b.add('book', paper, new THREE.BoxGeometry(0.14, 0.024, 0.2), { pos: V(0.006, 0, 0) });
	b.add('book', red, new THREE.BoxGeometry(0.02, 0.031, 0.21), { pos: V(-0.065, 0, 0) });
	return b.build();
}

export function buildCasinoChips() {
	const chips = chipColors();
	const b = new Builder('casino_chips');
	for (let k = 0; k < 5; k++) b.add('chips', chips[k % 4], new THREE.CylinderGeometry(0.02, 0.02, 0.008, 10), { pos: V(0, -0.016 + k * 0.008, 0) });
	b.add('chips', chips[1], new THREE.CylinderGeometry(0.02, 0.02, 0.008, 10), { pos: V(0.045, -0.016, 0.01), rot: [0, 0, 0.1] });
	return b.build();
}

// The regular guest (step 5): señor Ramón's costume trunk (0.8 x 0.5 x 0.45 m, origin in the middle), the fake guest
// book and the spare wig.
export function buildCostumeTrunk() {
	const wood = mat('trunk_wood', 0x7a4a26), brass = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), band = mat('trunk_band', 0x3a2a1a);
	const red = mat('costume_red', 0xc42a2a), feather = mat('feather', 0x43b0e0);
	const b = new Builder('costume_trunk');
	b.add('trunk', wood, new THREE.BoxGeometry(0.8, 0.4, 0.45), { pos: V(0, -0.05, 0) });
	for (const x of [-0.28, 0.28]) b.add('trunk', band, new THREE.BoxGeometry(0.05, 0.41, 0.46), { pos: V(x, -0.05, 0) });
	b.add('trunk', brass, new THREE.BoxGeometry(0.1, 0.08, 0.02), { pos: V(0, 0.08, 0.23) });
	b.add('lid', wood, new THREE.BoxGeometry(0.8, 0.06, 0.45), { pos: V(0, 0.17, -0.04), rot: [-0.25, 0, 0] });
	b.add('costumes', red, new THREE.BoxGeometry(0.3, 0.06, 0.2), { pos: V(-0.15, 0.17, 0.08), rot: [0, 0.3, 0.2] });
	b.add('costumes', feather, new THREE.ConeGeometry(0.03, 0.25, 6), { pos: V(0.2, 0.2, 0.05), rot: [0, 0, -0.8] });
	b.add('costumes', mat('mustache', 0x1c1c1c), new THREE.BoxGeometry(0.12, 0.025, 0.03), { pos: V(0.05, 0.16, 0.12) });
	return b.build();
}

export function buildFakeGuestBook() {
	const cover = mat('guest_book', 0x6a1e24), paper = mat('paper', 0xf3eedf), gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	const b = new Builder('fake_guest_book');
	b.add('book', cover, new THREE.BoxGeometry(0.32, 0.04, 0.24));
	b.add('book', paper, new THREE.BoxGeometry(0.31, 0.034, 0.23), { pos: V(0, 0, 0.004) });
	b.add('book', gold, new THREE.BoxGeometry(0.1, 0.002, 0.04), { pos: V(0, 0.021, 0) });
	return b.build();
}

export function buildSpareWig() {
	const hair = mat('wig_orange', 0xe8762a);
	const b = new Builder('spare_wig');
	b.add('wig', hair, new THREE.SphereGeometry(0.12, 10, 6, 0, Math.PI * 2, 0, Math.PI / 2), { scale: [1, 0.7, 1.1], pos: V(0, -0.04, 0) });
	for (let i = 0; i < 6; i++) {
		const a = (i / 6) * Math.PI * 2;
		b.add('wig', hair, new THREE.SphereGeometry(0.045, 6, 4), { pos: V(Math.cos(a) * 0.11, -0.03, Math.sin(a) * 0.12) });
	}
	return b.build();
}

// The stolen robes (step 5): the bag of embroidered robes (0.7 x 0.6 x 0.5 m, origin in the middle), the buyers' list,
// the embroidery machine and the robe hanging on a hook, with another hotel's crest.
export function buildRobeBag() {
	const sack = mat('robe_bag', 0xe8e4da), cord = mat('cord', 0x8a6a3a), robe = mat('robe_white', 0xf4f2ee);
	const crest = mat('crest_blue', 0x2a4aa0), gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	const b = new Builder('robe_bag');
	b.add('bag', sack, new THREE.SphereGeometry(0.34, 10, 7), { scale: [1, 0.85, 0.75], pos: V(0, -0.02, 0) });
	b.add('bag', cord, new THREE.TorusGeometry(0.1, 0.015, 4, 10), { pos: V(0, 0.27, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('robes', robe, new THREE.SphereGeometry(0.1, 6, 4), { pos: V(0.02, 0.32, 0.02), scale: [1.3, 0.6, 1] });
	b.add('robes', crest, new THREE.BoxGeometry(0.06, 0.06, 0.01), { pos: V(0.12, 0.05, 0.25) });
	b.add('robes', gold, new THREE.BoxGeometry(0.05, 0.05, 0.01), { pos: V(-0.14, 0.1, 0.24) });
	return b.build();
}

export function buildBuyersList() {
	const paper = mat('paper', 0xf3eedf), ink = mat('ink', 0x2a2a6a);
	const b = new Builder('buyers_list');
	b.add('paper', paper, new THREE.BoxGeometry(0.21, 0.004, 0.29));
	for (let i = 0; i < 6; i++) b.add('lines', ink, new THREE.BoxGeometry(0.15, 0.001, 0.008), { pos: V(-0.01, 0.0025, -0.11 + i * 0.04) });
	return b.build();
}

export function buildEmbroideryMachine() {
	const body = mat('machine_body', 0xd8d2c0), dark = mat('machine_dark', 0x3a3a40), red = mat('thread_red', 0xd23030);
	const b = new Builder('embroidery_machine');
	b.add('base', body, new THREE.BoxGeometry(0.45, 0.08, 0.22), { pos: V(0, -0.12, 0) });
	b.add('arm', body, new THREE.BoxGeometry(0.1, 0.22, 0.16), { pos: V(0.17, 0.0, 0) });
	b.add('arm', body, new THREE.BoxGeometry(0.42, 0.09, 0.16), { pos: V(0.0, 0.1, 0) });
	b.add('arm', dark, new THREE.BoxGeometry(0.04, 0.12, 0.04), { pos: V(-0.17, 0.0, 0) });
	b.add('thread', red, new THREE.CylinderGeometry(0.025, 0.025, 0.06, 8), { pos: V(0.05, 0.17, 0) });
	return b.build();
}

export function buildHangingRobe() {
	const robe = mat('robe_white', 0xf4f2ee), terry = mat('robe_terry', 0xdedad2), crest = mat('crest_blue', 0x2a4aa0);
	const b = new Builder('hanging_robe');
	b.add('robe', robe, new THREE.CylinderGeometry(0.18, 0.26, 0.95, 8), { pos: V(0, -0.1, 0), scale: [1, 1, 0.45] });
	for (const s of [-1, 1]) b.add('robe', robe, new THREE.CylinderGeometry(0.06, 0.08, 0.6, 6), { pos: V(s * 0.24, 0.0, 0), rot: [0, 0, s * 0.2] });
	b.add('robe', terry, new THREE.BoxGeometry(0.42, 0.04, 0.14), { pos: V(0, -0.05, 0.02) });
	b.add('crest', crest, new THREE.BoxGeometry(0.08, 0.09, 0.01), { pos: V(-0.08, 0.2, 0.09) });
	b.add('hook', mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.TorusGeometry(0.03, 0.008, 4, 8), { pos: V(0, 0.42, 0) });
	return b.build();
}

export const models = {
	robe_bag: buildRobeBag, buyers_list: buildBuyersList, embroidery_machine: buildEmbroideryMachine,
	hanging_robe: buildHangingRobe,
	costume_trunk: buildCostumeTrunk, fake_guest_book: buildFakeGuestBook, spare_wig: buildSpareWig,
	hotel_lamp: buildHotelLamp, roulette: buildRoulette, casino_chip_box: buildChipBox, debt_book: buildDebtBook,
	casino_chips: buildCasinoChips,
};

export const views = {
	hotel_lamp: { items: [{ name: 'hotel_lamp', pos: [0, 0.21, 0] }, { name: 'ornament_vase', pos: [0.35, 0.13, 0] }],
		cam: { pos: [0.2, 0.5, 1.4], target: [0.15, 0.2, 0], fov: 35 } },
	regular_guest: { items: [{ name: 'costume_trunk', pos: [0, 0.25, 0] }, { name: 'fake_guest_book', pos: [0.75, 0.02, 0.2], rotY: -0.3 },
		{ name: 'spare_wig', pos: [-0.7, 0.05, 0.2] }],
		cam: { pos: [0, 1.1, 1.8], target: [0, 0.15, 0], fov: 38 } },
	robes: { items: [{ name: 'robe_bag', pos: [0, 0.3, 0] }, { name: 'buyers_list', pos: [0.7, 0.01, 0.3], rotY: -0.3 },
		{ name: 'embroidery_machine', pos: [-0.75, 0.16, 0.1], rotY: 0.4 }, { name: 'hanging_robe', pos: [1.3, 0.6, -0.3] }],
		cam: { pos: [0.2, 1.2, 2.4], target: [0.2, 0.3, 0], fov: 40 } },
	casino_13: { items: [{ name: 'roulette', pos: [0, 0.12, 0] }, { name: 'casino_chip_box', pos: [0.65, 0.06, 0.1], rotY: -0.3 },
		{ name: 'debt_book', pos: [-0.6, 0.015, 0.2], rotY: 0.4 }, { name: 'casino_chips', pos: [0.4, 0.02, 0.5] }],
		cam: { pos: [0, 1.1, 1.8], target: [0, 0.1, 0], fov: 38 } },
};
