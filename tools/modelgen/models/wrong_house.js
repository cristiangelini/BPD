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

// Pepe, the parrot who knows the bank's safe code: 0.34 m tall from its feet, green with a red head and a yellow
// beak, facing +z, wings folded (the code flaps wing_l and wing_r). Origin at the middle of the body.
export function buildParrot() {
	const b = new Builder('parrot');
	const green = () => mat('parrot_green', 0x2fa84a), red = mat('parrot_red', 0xd8322a);
	b.add('body', green(), ellipsoid(0.07, 0.11, 0.07, 8, 6), { pos: V(0, 0, 0) });
	b.add('body', red, ellipsoid(0.055, 0.055, 0.055, 8, 6), { pos: V(0, 0.13, 0.02) });
	b.add('beak', mat('parrot_beak', 0xf2c230), new THREE.ConeGeometry(0.022, 0.05, 6), { pos: V(0, 0.115, 0.08), rot: [Math.PI / 2 + 0.5, 0, 0] });
	for (const x of [-0.03, 0.03]) b.add('eyes', mat('parrot_eye', 0x101010), new THREE.SphereGeometry(0.01, 6, 4), { pos: V(x, 0.15, 0.06) });
	b.add('tail', mat('parrot_blue', 0x2a5ad8), new THREE.BoxGeometry(0.06, 0.16, 0.015), { pos: V(0, -0.15, -0.06), rot: [0.4, 0, 0] });
	for (const side of [-1, 1]) b.add(side < 0 ? 'wing_r' : 'wing_l', green(), new THREE.BoxGeometry(0.015, 0.14, 0.09), { pos: V(side * 0.07, 0.0, -0.01) });
	for (const x of [-0.025, 0.025]) b.add('feet', mat('parrot_feet', 0x8a8a8a), new THREE.BoxGeometry(0.02, 0.05, 0.03), { pos: V(x, -0.12, 0.01) });
	return b.build();
}

// Pepe's empty cage: 0.4 across and 0.5 tall, a round base, wire bars and a domed top with a ring. Origin in the middle.
export function buildBirdCage() {
	const b = new Builder('bird_cage');
	const brass = () => mat('cage_brass', 0xc8a040);
	b.add('cage', brass(), new THREE.CylinderGeometry(0.2, 0.21, 0.04, 16), { pos: V(0, -0.23, 0) });
	for (let i = 0; i < 12; i++) {
		const a = (i / 12) * Math.PI * 2;
		b.add('bars', brass(), new THREE.CylinderGeometry(0.004, 0.004, 0.36, 4), { pos: V(Math.cos(a) * 0.19, -0.03, Math.sin(a) * 0.19) });
	}
	b.add('cage', brass(), new THREE.SphereGeometry(0.19, 16, 6, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(0, 0.15, 0) });
	b.add('cage', brass(), new THREE.TorusGeometry(0.035, 0.008, 4, 10), { pos: V(0, 0.37, 0) });
	b.add('perch', mat('cage_perch', 0x8a5a32), new THREE.CylinderGeometry(0.008, 0.008, 0.36, 6), { pos: V(0, -0.05, 0), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// El Chispa's box of rockets: 0.6 × 0.3 × 0.4, red cardboard with a yellow star, rocket tips sticking out the top.
export function buildRocketBox() {
	const b = new Builder('rocket_box');
	b.add('box', mat('rocket_box_red', 0xc8302a), new THREE.BoxGeometry(0.6, 0.3, 0.4), { pos: V(0, 0, 0) });
	b.add('label', mat('rocket_star', 0xf2d040), new THREE.CylinderGeometry(0.08, 0.08, 0.005, 5), { pos: V(0, 0, 0.202), rot: [Math.PI / 2, 0, 0] });
	const tips = [0xf2d040, 0x2a5ad8, 0x2fa84a, 0xe8e0d0];
	for (let i = 0; i < 8; i++) {
		const x = -0.24 + (i % 4) * 0.16, z = i < 4 ? -0.1 : 0.1;
		b.add('rockets', mat('rocket_tip_' + (i % 4), tips[i % 4]), new THREE.ConeGeometry(0.03, 0.1, 6), { pos: V(x, 0.2, z) });
	}
	return b.build();
}

// A coil of fuses: 0.2 across, tied with string. Origin in the middle.
export function buildFuses() {
	const b = new Builder('fuses');
	b.add('fuse', mat('fuse_green', 0x4a6a2a), new THREE.TorusGeometry(0.08, 0.012, 6, 16), { pos: V(0, 0, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('fuse', mat('fuse_green', 0x4a6a2a), new THREE.TorusGeometry(0.065, 0.012, 6, 16), { pos: V(0, 0.015, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('string', mat('fuse_string', 0xe8dcc0), new THREE.BoxGeometry(0.02, 0.04, 0.18), { pos: V(0, 0.005, 0) });
	return b.build();
}

export const models = {
	printing_plate: buildPrintingPlate, ink_pot: buildInkPot, fake_bills: buildFakeBills,
	parrot: buildParrot, bird_cage: buildBirdCage, rocket_box: buildRocketBox, fuses: buildFuses,
};

export const views = {
	wrong_house_bills: {
		items: [{ name: 'printing_plate', pos: [-0.25, 0.04, 0], rotY: 0.3 }, { name: 'ink_pot', pos: [0.35, 0.1, 0.1] },
			{ name: 'fake_bills', pos: [0.2, 0.03, 0.35], rotY: -0.5 }],
		cam: { pos: [0, 0.9, 1.4], target: [0, 0.05, 0.05], fov: 38 },
	},
	wrong_house_parrot_fireworks: {
		items: [{ name: 'parrot', pos: [-0.5, 0.17, 0.1], rotY: 0.4 }, { name: 'bird_cage', pos: [-0.05, 0.25, -0.1] },
			{ name: 'rocket_box', pos: [0.5, 0.15, 0], rotY: -0.3 }, { name: 'fuses', pos: [0.15, 0.02, 0.4] }],
		cam: { pos: [0, 1.0, 2.0], target: [0, 0.15, 0.05], fov: 38 },
	},
};
