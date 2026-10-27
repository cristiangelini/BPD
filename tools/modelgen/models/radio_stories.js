// The evidence of the radio's stories (docs/diseno/allanamiento-radio.md, "Las historias"), centered on their collision
// boxes in scenes/props/*.tscn. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The contest's raffle urn: a 0.4 x 0.45 x 0.4 m glass cube on a wooden base, full of paper slips, with a slot on top.
export function buildRaffleUrn() {
	const b = new Builder('raffle_urn');
	const wood = mat('urn_wood', 0x7a4a26);
	b.add('base', wood, new THREE.BoxGeometry(0.4, 0.05, 0.4), { pos: V(0, -0.2, 0) });
	b.add('lid', wood, new THREE.BoxGeometry(0.4, 0.04, 0.4), { pos: V(0, 0.205, 0) });
	b.add('slot', mat('black', 0x15151a), new THREE.BoxGeometry(0.16, 0.01, 0.03), { pos: V(0, 0.226, 0) });
	b.add('glass', mat('urn_glass', 0xbfe4f2, { transparent: true, opacity: 0.35 }), new THREE.BoxGeometry(0.38, 0.36, 0.38));
	const paper = mat('slip_paper', 0xf6f0d8);
	for (let i = 0; i < 18; i++) {
		const x = ((i * 37) % 30) / 100 - 0.15, z = ((i * 53) % 30) / 100 - 0.15, y = -0.16 + (i % 4) * 0.025;
		b.add('slips', paper, new THREE.BoxGeometry(0.06, 0.004, 0.035), { pos: V(x, y, z), rot: [0, i * 0.7, 0.2] });
	}
	return b.build();
}

// The prize nobody got: a blender, 0.2 x 0.4 x 0.2 m, red base and a clear jar with a ribbon.
export function buildContestBlender() {
	const b = new Builder('contest_blender');
	b.add('base', mat('blender_red', 0xd83020), new THREE.BoxGeometry(0.2, 0.12, 0.2), { pos: V(0, -0.14, 0) });
	b.add('jar', mat('blender_jar', 0xcfe8f0, { transparent: true, opacity: 0.5 }), new THREE.CylinderGeometry(0.08, 0.06, 0.24, 10), { pos: V(0, 0.04, 0) });
	b.add('lid', mat('black', 0x15151a), new THREE.CylinderGeometry(0.085, 0.085, 0.03, 10), { pos: V(0, 0.18, 0) });
	b.add('ribbon', mat('ribbon_gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.TorusGeometry(0.05, 0.012, 4, 10), { pos: V(0, 0.2, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The winners list: a 0.21 x 0.01 x 0.3 m sheet with the same name in every row.
export function buildWinnersList() {
	const b = new Builder('winners_list');
	b.add('sheet', mat('list_paper', 0xf6f4ee), new THREE.BoxGeometry(0.21, 0.004, 0.3));
	const ink = mat('ink_blue', 0x2a3a9a);
	for (let i = 0; i < 8; i++) b.add('rows', ink, new THREE.BoxGeometry(0.12, 0.001, 0.008), { pos: V(-0.02, 0.0025, -0.12 + i * 0.033) });
	return b.build();
}

// The ad contracts: a 0.45 x 0.35 x 0.35 m cardboard archive box full of folders, with a red "CONTRATOS" band.
export function buildAdContracts() {
	const b = new Builder('ad_contracts');
	b.add('box', mat('archive_box', 0xc8a070), new THREE.BoxGeometry(0.45, 0.3, 0.35), { pos: V(0, -0.025, 0) });
	b.add('band', mat('band_red', 0xc82a20), new THREE.BoxGeometry(0.452, 0.06, 0.352), { pos: V(0, 0.0, 0) });
	const folders = [0xf2d24a, 0x4a8ad8, 0x6ac46a, 0xe87a3a];
	for (let i = 0; i < 8; i++) b.add('folders', mat(`folder_${i % 4}`, folders[i % 4]), new THREE.BoxGeometry(0.4, 0.06, 0.012), { pos: V(0, 0.15, -0.14 + i * 0.04), rot: [0, 0, (i % 3 - 1) * 0.03] });
	return b.build();
}

// The billing notebook: 0.2 x 0.03 x 0.28 m, green cover with a white label.
export function buildBillingBook() {
	const b = new Builder('billing_book');
	b.add('cover', mat('book_green', 0x2f7a4a), new THREE.BoxGeometry(0.2, 0.03, 0.28));
	b.add('label', mat('white', 0xf6f4ee), new THREE.BoxGeometry(0.1, 0.002, 0.05), { pos: V(0, 0.016, -0.05) });
	b.add('pages', mat('page_cream', 0xf4ecd0), new THREE.BoxGeometry(0.004, 0.024, 0.27), { pos: V(0.099, 0, 0) });
	return b.build();
}

// The "PAGADO" rubber stamp: a 0.08 x 0.12 x 0.08 m wooden handle on a red pad.
export function buildPaidStamp() {
	const b = new Builder('paid_stamp');
	b.add('pad', mat('stamp_red', 0xc82a20), new THREE.BoxGeometry(0.08, 0.02, 0.06), { pos: V(0, -0.05, 0) });
	b.add('base', mat('stamp_wood', 0x8a5a2e), new THREE.BoxGeometry(0.07, 0.03, 0.05), { pos: V(0, -0.025, 0) });
	b.add('handle', mat('stamp_wood', 0x8a5a2e), new THREE.CylinderGeometry(0.015, 0.02, 0.06, 8), { pos: V(0, 0.02, 0) });
	b.add('knob', mat('stamp_knob', 0x2a1e18), new THREE.SphereGeometry(0.025, 8, 5), { pos: V(0, 0.055, 0) });
	return b.build();
}

// The neighbors' recordings: a 0.4 x 0.3 x 0.3 m cardboard box packed with cassettes, a hand-written label on the side.
export function buildNeighborTapes() {
	const b = new Builder('neighbor_tapes');
	b.add('box', mat('tape_box', 0xb88a5a), new THREE.BoxGeometry(0.4, 0.26, 0.3), { pos: V(0, -0.02, 0) });
	b.add('label', mat('white', 0xf6f4ee), new THREE.BoxGeometry(0.2, 0.08, 0.002), { pos: V(0, 0.0, 0.151) });
	const shells = [0x1e1e24, 0xe8e4da, 0xd84a3a];
	for (let i = 0; i < 9; i++) {
		const x = -0.13 + (i % 3) * 0.13, z = -0.09 + Math.floor(i / 3) * 0.09;
		b.add('tapes', mat(`tape_${i % 3}`, shells[i % 3]), new THREE.BoxGeometry(0.1, 0.06, 0.064), { pos: V(x, 0.135, z), rot: [0.2, (i % 2) * 0.2, 0] });
	}
	return b.build();
}

// The mic in a flowerpot: a 0.2 m terracotta pot with a little fern, a black mic poking out and its cable.
export function buildPotMic() {
	const b = new Builder('pot_mic');
	b.add('pot', mat('terracotta', 0xc0603a), new THREE.CylinderGeometry(0.1, 0.075, 0.16, 10), { pos: V(0, -0.06, 0) });
	b.add('soil', mat('soil', 0x3a2618), new THREE.CylinderGeometry(0.092, 0.092, 0.01, 10), { pos: V(0, 0.015, 0) });
	for (let i = 0; i < 5; i++) b.add('leaves', mat('leaf', 0x3a8a3a), new THREE.ConeGeometry(0.03, 0.14, 5), { pos: V(Math.cos(i * 1.3) * 0.04, 0.08, Math.sin(i * 1.3) * 0.04), rot: [Math.sin(i) * 0.5, 0, Math.cos(i) * 0.5] });
	b.add('mic', mat('black', 0x15151a), new THREE.SphereGeometry(0.022, 8, 6), { pos: V(0.05, 0.05, 0.03) });
	b.add('cable', mat('black', 0x15151a), new THREE.CylinderGeometry(0.005, 0.005, 0.14, 4), { pos: V(0.09, -0.02, 0.04), rot: [0, 0, 0.6] });
	return b.build();
}

// The neighborhood map with crosses: a 0.4 x 0.006 x 0.3 m folded sheet, streets in grey and red crosses on the houses.
export function buildCrossedMap() {
	const b = new Builder('crossed_map');
	b.add('sheet', mat('map_paper', 0xf0ead2), new THREE.BoxGeometry(0.4, 0.004, 0.3));
	for (let i = 0; i < 3; i++) b.add('streets', mat('street_grey', 0x9a9a9a), new THREE.BoxGeometry(0.4, 0.001, 0.02), { pos: V(0, 0.0025, -0.1 + i * 0.1) });
	for (let i = 0; i < 3; i++) b.add('streets', mat('street_grey', 0x9a9a9a), new THREE.BoxGeometry(0.02, 0.001, 0.3), { pos: V(-0.12 + i * 0.12, 0.0025, 0) });
	const crosses = [[-0.06, -0.05], [0.06, 0.05], [0.17, -0.05], [-0.17, 0.12], [0.0, 0.13]];
	for (const [x, z] of crosses) {
		b.add('crosses', mat('cross_red', 0xd02a20), new THREE.BoxGeometry(0.04, 0.002, 0.008), { pos: V(x, 0.004, z), rot: [0, 0.785, 0] });
		b.add('crosses', mat('cross_red', 0xd02a20), new THREE.BoxGeometry(0.04, 0.002, 0.008), { pos: V(x, 0.004, z), rot: [0, -0.785, 0] });
	}
	return b.build();
}

// The reception's big flowerpot (fixed, the clue): a 0.5 m pot with a leafy plant and a mic among the leaves, its cable
// running down the side to the floor.
export function buildReceptionPlant() {
	const b = new Builder('reception_plant');
	b.add('pot', mat('terracotta', 0xc0603a), new THREE.CylinderGeometry(0.22, 0.17, 0.45, 12), { pos: V(0, 0.225, 0) });
	b.add('soil', mat('soil', 0x3a2618), new THREE.CylinderGeometry(0.2, 0.2, 0.02, 12), { pos: V(0, 0.44, 0) });
	b.add('trunk', mat('trunk', 0x6a4a2a), new THREE.CylinderGeometry(0.025, 0.03, 0.5, 6), { pos: V(0, 0.7, 0) });
	for (let i = 0; i < 7; i++) b.add('leaves', mat('leaf', 0x3a8a3a), new THREE.SphereGeometry(0.16, 7, 5), { pos: V(Math.cos(i * 0.9) * 0.15, 0.95 + (i % 3) * 0.08, Math.sin(i * 0.9) * 0.15) });
	b.add('mic', mat('black', 0x15151a), new THREE.SphereGeometry(0.035, 8, 6), { pos: V(0.0, 0.88, 0.24) });
	b.add('cable', mat('black', 0x15151a), new THREE.CylinderGeometry(0.008, 0.008, 0.9, 4), { pos: V(0.0, 0.45, 0.235) });
	return b.build();
}

// The stolen collection: a 0.4 x 0.34 x 0.36 m wooden crate full of vinyl sleeves standing on edge.
export function buildVinylCrate() {
	const b = new Builder('vinyl_crate');
	const wood = mat('crate_wood', 0x9a6a3a);
	b.add('bottom', wood, new THREE.BoxGeometry(0.4, 0.02, 0.36), { pos: V(0, -0.16, 0) });
	for (const x of [-0.19, 0.19]) b.add('sides', wood, new THREE.BoxGeometry(0.02, 0.22, 0.36), { pos: V(x, -0.06, 0) });
	for (const z of [-0.17, 0.17]) b.add('sides', wood, new THREE.BoxGeometry(0.4, 0.22, 0.02), { pos: V(0, -0.06, z) });
	const sleeves = [0xd84a3a, 0x2a2a30, 0xf2c84a, 0x4a7ad8, 0x8a4ac8, 0x3aa86a];
	for (let i = 0; i < 12; i++) b.add('sleeves', mat(`sleeve_${i % 6}`, sleeves[i % 6]), new THREE.BoxGeometry(0.31, 0.31, 0.008), { pos: V(0, 0.0, -0.15 + i * 0.027), rot: [(i % 2 - 0.5) * 0.08, 0, 0] });
	return b.build();
}

// The collector's catalog: a 0.22 x 0.04 x 0.3 m leather-bound book with a golden record on the cover.
export function buildCollectorCatalog() {
	const b = new Builder('collector_catalog');
	b.add('cover', mat('leather', 0x5a2a1a), new THREE.BoxGeometry(0.22, 0.04, 0.3));
	b.add('pages', mat('page_cream', 0xf4ecd0), new THREE.BoxGeometry(0.004, 0.032, 0.29), { pos: V(0.109, 0, 0) });
	b.add('disc', mat('gold', 0xe0b040, { metalness: 0.6, roughness: 0.35 }), new THREE.CylinderGeometry(0.06, 0.06, 0.003, 16), { pos: V(0, 0.021, 0) });
	return b.build();
}

// The golden record player: a 0.36 x 0.14 x 0.3 m gold box with its platter, a black record and the arm.
export function buildGoldenPlayer() {
	const b = new Builder('golden_player');
	const gold = mat('gold', 0xe0b040, { metalness: 0.6, roughness: 0.35 });
	b.add('body', gold, new THREE.BoxGeometry(0.36, 0.1, 0.3), { pos: V(0, -0.02, 0) });
	b.add('record', mat('vinyl', 0x15151a), new THREE.CylinderGeometry(0.12, 0.12, 0.006, 20), { pos: V(-0.04, 0.035, 0) });
	b.add('label', mat('label_red', 0xd84a3a), new THREE.CylinderGeometry(0.035, 0.035, 0.007, 12), { pos: V(-0.04, 0.036, 0) });
	b.add('arm', gold, new THREE.BoxGeometry(0.015, 0.015, 0.2), { pos: V(0.13, 0.06, 0.0), rot: [0, 0.3, 0] });
	b.add('knob', gold, new THREE.CylinderGeometry(0.02, 0.02, 0.04, 8), { pos: V(0.14, 0.05, -0.1) });
	return b.build();
}

// The private record (fixed, the clue): a 0.32 m square sleeve on its edge with a white label, leaning on the shelf.
export function buildPrivateRecord() {
	const b = new Builder('private_record');
	b.add('sleeve', mat('sleeve_private', 0x2a3a5a), new THREE.BoxGeometry(0.32, 0.32, 0.01), { pos: V(0, 0.16, 0), rot: [-0.15, 0, 0] });
	b.add('label', mat('white', 0xf6f4ee), new THREE.BoxGeometry(0.2, 0.08, 0.002), { pos: V(0, 0.2, 0.011), rot: [-0.15, 0, 0] });
	b.add('text', mat('cross_red', 0xd02a20), new THREE.BoxGeometry(0.16, 0.012, 0.002), { pos: V(0, 0.2, 0.013), rot: [-0.15, 0, 0] });
	return b.build();
}

// The code box: a 0.36 x 0.22 x 0.26 m grey metal box, lid open, with the code book and a portable radio inside.
export function buildCodeBox() {
	const b = new Builder('code_box');
	const metal = mat('box_grey', 0x6a7078, { metalness: 0.4, roughness: 0.5 });
	b.add('bottom', metal, new THREE.BoxGeometry(0.36, 0.02, 0.26), { pos: V(0, -0.1, 0) });
	for (const x of [-0.17, 0.17]) b.add('sides', metal, new THREE.BoxGeometry(0.02, 0.14, 0.26), { pos: V(x, -0.03, 0) });
	for (const z of [-0.12, 0.12]) b.add('sides', metal, new THREE.BoxGeometry(0.36, 0.14, 0.02), { pos: V(0, -0.03, z) });
	b.add('lid', metal, new THREE.BoxGeometry(0.36, 0.02, 0.26), { pos: V(0, 0.1, -0.2), rot: [-1.2, 0, 0] });
	b.add('book', mat('book_black', 0x22222a), new THREE.BoxGeometry(0.14, 0.04, 0.2), { pos: V(-0.08, -0.07, 0) });
	b.add('book_mark', mat('cross_red', 0xd02a20), new THREE.BoxGeometry(0.02, 0.041, 0.2), { pos: V(-0.08, -0.07, 0) });
	b.add('radio', mat('radio_red', 0xc84a3a), new THREE.BoxGeometry(0.14, 0.09, 0.06), { pos: V(0.08, -0.045, 0) });
	b.add('antenna', mat('steel', 0xc0c4c8, { metalness: 0.6, roughness: 0.3 }), new THREE.CylinderGeometry(0.003, 0.003, 0.18, 4), { pos: V(0.13, 0.08, 0) });
	return b.build();
}

// The "listeners" list: a 0.21 x 0.004 x 0.3 m sheet with a column of code names.
export function buildListenerList() {
	const b = new Builder('listener_list');
	b.add('sheet', mat('white', 0xf6f4ee), new THREE.BoxGeometry(0.21, 0.004, 0.3));
	for (let i = 0; i < 8; i++) b.add('lines', mat('ink_green', 0x2a7a3a), new THREE.BoxGeometry(0.12 - (i % 3) * 0.02, 0.001, 0.008), { pos: V(-0.02, 0.0025, -0.12 + i * 0.033) });
	return b.build();
}

// The delivery clock: a 0.16 m round alarm clock with two bells, hands stopped on Tuesday's hour.
export function buildDeliveryClock() {
	const b = new Builder('delivery_clock');
	b.add('body', mat('clock_blue', 0x3a6ab8), new THREE.CylinderGeometry(0.08, 0.08, 0.05, 16), { pos: V(0, 0, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('face', mat('white', 0xf6f4ee), new THREE.CylinderGeometry(0.068, 0.068, 0.002, 16), { pos: V(0, 0, 0.026), rot: [Math.PI / 2, 0, 0] });
	b.add('hands', mat('black', 0x15151a), new THREE.BoxGeometry(0.006, 0.05, 0.002), { pos: V(0, 0.02, 0.028) });
	b.add('hands', mat('black', 0x15151a), new THREE.BoxGeometry(0.04, 0.006, 0.002), { pos: V(0.02, 0, 0.028) });
	for (const x of [-0.05, 0.05]) b.add('bells', mat('steel', 0xc0c4c8, { metalness: 0.6, roughness: 0.3 }), new THREE.SphereGeometry(0.025, 8, 5, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(x, 0.075, 0) });
	for (const x of [-0.05, 0.05]) b.add('legs', mat('black', 0x15151a), new THREE.CylinderGeometry(0.006, 0.006, 0.03, 4), { pos: V(x, -0.08, 0) });
	return b.build();
}

export const models = {
	raffle_urn: buildRaffleUrn, contest_blender: buildContestBlender, winners_list: buildWinnersList,
	ad_contracts: buildAdContracts, billing_book: buildBillingBook, paid_stamp: buildPaidStamp,
	neighbor_tapes: buildNeighborTapes, pot_mic: buildPotMic, crossed_map: buildCrossedMap,
	reception_plant: buildReceptionPlant, vinyl_crate: buildVinylCrate, collector_catalog: buildCollectorCatalog,
	golden_player: buildGoldenPlayer, private_record: buildPrivateRecord, code_box: buildCodeBox,
	listener_list: buildListenerList, delivery_clock: buildDeliveryClock,
};

export const views = {
	radio_stories: {
		items: [
			{ name: 'raffle_urn', pos: [-0.5, 0.225, 0], rotY: 0.3 }, { name: 'contest_blender', pos: [0.1, 0.2, 0.1] },
			{ name: 'winners_list', pos: [0.55, 0.005, 0.15], rotY: -0.3 },
			{ name: 'ad_contracts', pos: [-0.6, 0.175, -0.7], rotY: 0.2 }, { name: 'billing_book', pos: [0.1, 0.015, -0.5] },
			{ name: 'paid_stamp', pos: [0.5, 0.06, -0.5] },
			{ name: 'neighbor_tapes', pos: [-0.6, 0.15, 0.7] }, { name: 'pot_mic', pos: [0.05, 0.14, 0.75] },
			{ name: 'crossed_map', pos: [0.6, 0.003, 0.7], rotY: 0.3 }, { name: 'reception_plant', pos: [1.3, 0, -0.2] },
			{ name: 'vinyl_crate', pos: [-0.6, 0.17, 1.5] }, { name: 'collector_catalog', pos: [0.0, 0.02, 1.5] },
			{ name: 'golden_player', pos: [0.5, 0.07, 1.5] }, { name: 'private_record', pos: [1.1, 0, 1.4] },
			{ name: 'code_box', pos: [-0.6, 0.11, 2.2] }, { name: 'listener_list', pos: [0.0, 0.002, 2.2], rotY: 0.2 },
			{ name: 'delivery_clock', pos: [0.5, 0.095, 2.2] },
		],
		cam: { pos: [0.3, 2.6, 5.2], target: [0.2, 0.2, 0.9], fov: 42 },
	},
};
