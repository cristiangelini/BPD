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

export const models = {
	bread_loaf: buildLoaf, bread_half: buildHalfLoaf, bakery_cake: buildCake,
	stolen_ring: buildRing, jewelry_bag: buildJewelryBag, pawn_receipt: buildPawnReceipt,
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
};
