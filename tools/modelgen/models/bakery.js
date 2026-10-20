// The bakery's goods and the ring story's evidence (docs/diseno/panaderia.md). Each model is centered on its collision
// shape in scenes/props/*.tscn. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

const crust = () => mat('crust', 0xc98a3e), crumb = () => mat('crumb', 0xf4e2b8), cut = () => mat('crust_cut', 0x9a5a22);

// A loaf: 0.34 x 0.13 x 0.15 m, with three cuts on top.
export function buildLoaf() {
	const b = new Builder('bread_loaf');
	b.add('loaf', crust(), ellipsoid(0.17, 0.065, 0.075, 10, 6));
	for (const x of [-0.08, 0, 0.08]) b.add('loaf', cut(), new THREE.BoxGeometry(0.015, 0.012, 0.09), { pos: V(x, 0.06, 0), rot: [0, 0.5, 0] });
	return b.build();
}

// Half a loaf, split open: 0.17 x 0.13 x 0.15 m, the crumb facing +x.
export function buildHalfLoaf() {
	const b = new Builder('bread_half');
	b.add('loaf', crust(), ellipsoid(0.085, 0.065, 0.075, 8, 6), { pos: V(-0.0, 0, 0), scale: [1, 1, 1] });
	b.add('loaf', crumb(), new THREE.CylinderGeometry(0.06, 0.065, 0.012, 10), { pos: V(0.08, 0, 0), rot: [0, 0, Math.PI / 2], scale: [1, 1, 1.1] });
	return b.build();
}

// A cake for the display: 0.36 m wide, 0.18 m tall, with frosting and a cherry.
export function buildCake() {
	const b = new Builder('bakery_cake');
	b.add('cake', mat('sponge', 0xf2c9a0), new THREE.CylinderGeometry(0.18, 0.18, 0.13, 12), { pos: V(0, -0.025, 0) });
	b.add('cake', mat('frosting', 0xf7a8c8), new THREE.CylinderGeometry(0.185, 0.185, 0.04, 12), { pos: V(0, 0.06, 0) });
	b.add('cake', mat('cherry', 0xd8202a), ellipsoid(0.025, 0.025, 0.025, 6, 4), { pos: V(0, 0.095, 0) });
	return b.build();
}

// The stolen ring: a gold band with a big blue stone, 0.04 m.
export function buildRing() {
	const b = new Builder('stolen_ring');
	b.add('ring', mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.TorusGeometry(0.016, 0.005, 5, 10), { rot: [Math.PI / 2, 0, 0] });
	b.add('ring', mat('sapphire', 0x2a6af0, { emissive: 0x0a1a50 }), new THREE.OctahedronGeometry(0.01), { pos: V(0, 0.003, 0.02) });
	return b.build();
}

// The jewelry shop's little bag: 0.1 x 0.12 x 0.04 m, velvet with a gold cord.
export function buildJewelryBag() {
	const b = new Builder('jewelry_bag');
	b.add('bag', mat('velvet', 0x6a1a5a), new THREE.BoxGeometry(0.1, 0.1, 0.04), { pos: V(0, -0.01, 0) });
	b.add('bag', mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.TorusGeometry(0.02, 0.004, 4, 8), { pos: V(0, 0.05, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The pawn shop's receipt: a 0.12 x 0.17 m slip of paper.
export function buildPawnReceipt() {
	const b = new Builder('pawn_receipt');
	b.add('paper', mat('receipt', 0xf8f4e6), new THREE.BoxGeometry(0.12, 0.004, 0.17));
	for (let i = 0; i < 5; i++) b.add('ink', mat('receipt_ink', 0x3a3a48), new THREE.BoxGeometry(0.08 - (i % 2) * 0.02, 0.002, 0.008), { pos: V(-0.01, 0.003, -0.06 + i * 0.025) });
	b.add('ink', mat('stamp', 0xd83a3a), new THREE.CylinderGeometry(0.02, 0.02, 0.002, 8), { pos: V(0.03, 0.003, 0.06) });
	return b.build();
}

// A 25 kg flour sack: 0.6 x 0.35 x 0.9 m, a rounded paper sack with a blue band. `cross` paints the red X of the
// sneezing story's sack (panaderia.md, "Polvo para estornudar").
function buildSack(name, cross) {
	const b = new Builder(name);
	b.add('sack', mat('sack_paper', 0xe8dcc0), new THREE.BoxGeometry(0.58, 0.33, 0.88), { pos: V(0, -0.005, 0) });
	b.add('sack', mat('sack_paper', 0xe8dcc0), ellipsoid(0.29, 0.06, 0.44, 10, 4), { pos: V(0, 0.15, 0) });
	b.add('band', mat('sack_band', 0x3a6ac0), new THREE.BoxGeometry(0.585, 0.12, 0.2), { pos: V(0, 0, 0) });
	if (cross) {
		for (const turn of [0.6, -0.6]) b.add('cross', mat('sack_cross', 0xd82020), new THREE.BoxGeometry(0.06, 0.012, 0.5), { pos: V(0, 0.2, 0.2), rot: [0, turn, 0] });
	}
	return b.build();
}
export const buildFlourSack = () => buildSack('flour_sack', false);
export const buildPepperSack = () => buildSack('pepper_sack', true);

// The list of "victims": a 0.15 x 0.21 m sheet with names, some crossed out.
export function buildVictimList() {
	const b = new Builder('victim_list');
	b.add('paper', mat('list_paper', 0xf4efd8), new THREE.BoxGeometry(0.15, 0.004, 0.21));
	for (let i = 0; i < 7; i++) {
		b.add('ink', mat('list_ink', 0x2a2a3a), new THREE.BoxGeometry(0.09, 0.002, 0.008), { pos: V(-0.01, 0.003, -0.08 + i * 0.026) });
		if (i % 2 === 0) b.add('ink', mat('list_cross', 0xd83a3a), new THREE.BoxGeometry(0.1, 0.003, 0.004), { pos: V(-0.01, 0.004, -0.08 + i * 0.026) });
	}
	return b.build();
}

// A tin funnel: 0.16 m wide at the top, 0.2 m tall, centered on its box.
export function buildFunnel() {
	const b = new Builder('funnel');
	const tin = () => mat('tin', 0xb8bcc4);
	b.add('funnel', tin(), new THREE.CylinderGeometry(0.08, 0.015, 0.12, 12, 1, true), { pos: V(0, 0.04, 0) });
	b.add('funnel', tin(), new THREE.CylinderGeometry(0.015, 0.012, 0.08, 8), { pos: V(0, -0.06, 0) });
	return b.build();
}

// Gertrudis, the prize sourdough, in a glass jar: 0.2 m wide, 0.3 m tall, centered on its box. The dough fills the
// jar up to the top and bubbles out; a red cloth lid tied with string.
export function buildSourdoughJar() {
	const b = new Builder('sourdough_jar');
	b.add('glass', mat('jar_glass', 0xbfe4ec, { transparent: true, opacity: 0.45 }), new THREE.CylinderGeometry(0.1, 0.1, 0.26, 14, 1, true), { pos: V(0, -0.02, 0) });
	b.add('glass', mat('jar_glass', 0xbfe4ec, { transparent: true, opacity: 0.45 }), new THREE.CylinderGeometry(0.1, 0.1, 0.01, 14), { pos: V(0, -0.145, 0) });
	b.add('dough', mat('dough', 0xf3e6c4), new THREE.CylinderGeometry(0.093, 0.093, 0.22, 12), { pos: V(0, -0.035, 0) });
	for (const [x, z, r] of [[0.03, 0.02, 0.02], [-0.035, -0.01, 0.016], [0.0, -0.04, 0.012]]) b.add('dough', mat('dough', 0xf3e6c4), ellipsoid(r, r * 0.7, r, 6, 4), { pos: V(x, 0.08, z) });
	b.add('lid', mat('lid_cloth', 0xc83a3a), new THREE.CylinderGeometry(0.115, 0.105, 0.03, 12), { pos: V(0, 0.125, 0) });
	b.add('lid', mat('string', 0xd8c89a), new THREE.TorusGeometry(0.104, 0.005, 4, 14), { pos: V(0, 0.105, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('tag', mat('jar_tag', 0xf8f4e6), new THREE.BoxGeometry(0.08, 0.06, 0.004), { pos: V(0, 0.0, 0.102) });
	return b.build();
}

// The neighborhood contest medal: a 0.07 m gold disc on a blue ribbon, lying flat (0.1 x 0.02 x 0.18 m).
export function buildContestMedal() {
	const b = new Builder('contest_medal');
	b.add('medal', mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.CylinderGeometry(0.035, 0.035, 0.008, 12), { pos: V(0, -0.004, 0.05) });
	b.add('ribbon', mat('ribbon', 0x2a5ac8), new THREE.BoxGeometry(0.035, 0.004, 0.11), { pos: V(0, -0.006, -0.035) });
	return b.build();
}

export const models = {
	bread_loaf: buildLoaf, bread_half: buildHalfLoaf, bakery_cake: buildCake,
	stolen_ring: buildRing, jewelry_bag: buildJewelryBag, pawn_receipt: buildPawnReceipt,
	flour_sack: buildFlourSack, pepper_sack: buildPepperSack, victim_list: buildVictimList, funnel: buildFunnel,
	sourdough_jar: buildSourdoughJar, contest_medal: buildContestMedal,
};

export const views = {
	bakery_goods: {
		items: [
			{ name: 'bread_loaf', pos: [-0.5, 0.07, 0], rotY: 0.3 }, { name: 'bread_half', pos: [-0.1, 0.07, 0.1], rotY: 0.4 },
			{ name: 'bakery_cake', pos: [0.35, 0.09, -0.1], rotY: 0 }, { name: 'stolen_ring', pos: [0.05, 0.02, 0.35], rotY: 0.5, scale: 2 },
			{ name: 'jewelry_bag', pos: [0.35, 0.06, 0.35], rotY: -0.3 }, { name: 'pawn_receipt', pos: [-0.45, 0.01, 0.35], rotY: 0.2 },
		],
		cam: { pos: [0, 0.9, 1.6], target: [0, 0.05, 0.1], fov: 34 },
	},
	sneeze_goods: {
		items: [
			{ name: 'flour_sack', pos: [-0.4, 0.17, 0], rotY: 0.2 }, { name: 'pepper_sack', pos: [0.35, 0.17, -0.1], rotY: -0.2 },
			{ name: 'victim_list', pos: [-0.2, 0.01, 0.65], rotY: 0.3 }, { name: 'funnel', pos: [0.3, 0.1, 0.65], rotY: 0 },
		],
		cam: { pos: [0, 1.4, 2.2], target: [0, 0.1, 0.2], fov: 38 },
	},
	sourdough_goods: {
		items: [{ name: 'sourdough_jar', pos: [-0.12, 0.15, 0], rotY: 0.3 }, { name: 'contest_medal', pos: [0.18, 0.01, 0.05], rotY: -0.4 }],
		cam: { pos: [0, 0.5, 0.9], target: [0, 0.1, 0], fov: 36 },
	},
};
