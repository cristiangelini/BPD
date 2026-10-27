// Props of the wrong house's stories (docs/diseno/casa-equivocada.md, steps 5 to 7), with origins at the middle of
// each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

const steel = mat('plate_steel', 0x8a9098), billGreen = mat('fake_bill_green', 0x7fb87a);
const ink = mat('ink_blue', 0x1e3cb8), face = mat('bill_face', 0xe8e0c8), black = mat('bill_ink', 0x1a1a1e);

// Don Tinta's printing plate: a heavy steel slab, 0.6 × 0.08 × 0.45, with a bill engraved on top (the comisario's
// face in the middle, mustache and all) and two grips on the sides.
export function buildPrintingPlate() {
	const b = new Builder('printing_plate');
	b.add('plate', steel, new THREE.BoxGeometry(0.6, 0.06, 0.45), { pos: V(0, -0.01, 0) });
	b.add('bill', billGreen, new THREE.BoxGeometry(0.46, 0.012, 0.24), { pos: V(0, 0.026, 0) });
	b.add('bill', face, new THREE.CylinderGeometry(0.07, 0.07, 0.014, 12), { pos: V(0, 0.028, 0) });
	b.add('bill', black, new THREE.BoxGeometry(0.08, 0.016, 0.02), { pos: V(0, 0.03, 0.015) });
	for (const x of [-0.17, 0.17]) b.add('bill', black, new THREE.BoxGeometry(0.06, 0.016, 0.03), { pos: V(x, 0.03, 0) });
	for (const x of [-0.33, 0.33]) b.add('grips', black, new THREE.BoxGeometry(0.05, 0.04, 0.2), { pos: V(x, 0.0, 0) });
	return b.build();
}

// The tin of printing ink, 0.24 across and 0.2 tall, with ink running down one side.
export function buildInkPot() {
	const b = new Builder('ink_pot');
	b.add('tin', mat('ink_tin', 0x2a2e3a), new THREE.CylinderGeometry(0.12, 0.12, 0.18, 12), { pos: V(0, -0.01, 0) });
	b.add('tin', ink, new THREE.CylinderGeometry(0.115, 0.115, 0.02, 12), { pos: V(0, 0.085, 0) });
	b.add('label', mat('ink_label', 0xf2ead8), new THREE.CylinderGeometry(0.122, 0.122, 0.08, 12, 1, true), { pos: V(0, -0.01, 0) });
	b.add('drip', ink, new THREE.BoxGeometry(0.03, 0.12, 0.01), { pos: V(0.05, 0.03, 0.118) });
	b.add('drip', ink, ellipsoid(0.02, 0.02, 0.01, 6, 4), { pos: V(0.05, -0.03, 0.118) });
	return b.build();
}

// A bundle of fake bills with the comisario's face, held by a paper band.
export function buildFakeBills() {
	const b = new Builder('fake_bills');
	b.add('bills', billGreen, new THREE.BoxGeometry(0.16, 0.05, 0.08), { pos: V(0, 0, 0) });
	b.add('bills', face, new THREE.CylinderGeometry(0.025, 0.025, 0.004, 10), { pos: V(0.03, 0.026, 0) });
	b.add('bills', black, new THREE.BoxGeometry(0.03, 0.004, 0.008), { pos: V(0.03, 0.028, 0.006) });
	b.add('band', mat('bill_band', 0xf2ead8), new THREE.BoxGeometry(0.03, 0.054, 0.084), { pos: V(-0.04, 0, 0) });
	return b.build();
}

export const models = {
	printing_plate: buildPrintingPlate, ink_pot: buildInkPot, fake_bills: buildFakeBills,
};

export const views = {
	wrong_house_bills: {
		items: [{ name: 'printing_plate', pos: [-0.25, 0.04, 0], rotY: 0.3 }, { name: 'ink_pot', pos: [0.35, 0.1, 0.1] },
			{ name: 'fake_bills', pos: [0.2, 0.03, 0.35], rotY: -0.5 }],
		cam: { pos: [0, 0.9, 1.4], target: [0, 0.05, 0.05], fov: 38 },
	},
};
