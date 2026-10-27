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

export const models = {
	raffle_urn: buildRaffleUrn, contest_blender: buildContestBlender, winners_list: buildWinnersList,
	ad_contracts: buildAdContracts, billing_book: buildBillingBook, paid_stamp: buildPaidStamp,
};

export const views = {
	radio_stories: {
		items: [
			{ name: 'raffle_urn', pos: [-0.5, 0.225, 0], rotY: 0.3 }, { name: 'contest_blender', pos: [0.1, 0.2, 0.1] },
			{ name: 'winners_list', pos: [0.55, 0.005, 0.15], rotY: -0.3 },
			{ name: 'ad_contracts', pos: [-0.6, 0.175, -0.7], rotY: 0.2 }, { name: 'billing_book', pos: [0.1, 0.015, -0.5] },
			{ name: 'paid_stamp', pos: [0.5, 0.06, -0.5] },
		],
		cam: { pos: [0, 1.4, 2.4], target: [0, 0.15, -0.3], fov: 40 },
	},
};
