// The roof jailbreak (fuga-techo.md): the old skylight in each cell's ceiling, its glass pane, the bunk's folded sheet
// and the cell's spare mattress. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The skylight's frame, set in the ceiling: a rusty square frame 0.8 m wide with a crossbar, the origin at the
// ceiling's underside (it hangs down a little, -Y).
export function buildCellSkylight() {
	const b = new Builder('cell_skylight');
	const rust = mat('skylight_rust', 0x6a4a34), dark = mat('skylight_dark', 0x14161c);
	b.add('hole', dark, new THREE.BoxGeometry(0.72, 0.01, 0.72), { pos: V(0, 0.02, 0) });
	for (const s of [-1, 1]) {
		b.add('frame', rust, new THREE.BoxGeometry(0.8, 0.06, 0.06), { pos: V(0, -0.03, s * 0.37) });
		b.add('frame', rust, new THREE.BoxGeometry(0.06, 0.06, 0.8), { pos: V(s * 0.37, -0.03, 0) });
	}
	return b.build();
}

// The skylight's dirty glass pane, hinged on its -Z edge (the origin there): 0.7 x 0.03 x 0.7 m.
export function buildSkylightPane() {
	const b = new Builder('skylight_pane');
	const glass = mat('pane_glass', 0x8aa6a0, { emissive: 0x0c1412 }), rust = mat('skylight_rust', 0x6a4a34);
	b.add('glass', glass, new THREE.BoxGeometry(0.68, 0.02, 0.68), { pos: V(0, 0, 0.35) });
	b.add('bar', rust, new THREE.BoxGeometry(0.04, 0.035, 0.68), { pos: V(0, 0, 0.35) });
	b.add('latch', rust, new THREE.BoxGeometry(0.1, 0.04, 0.04), { pos: V(0, -0.03, 0.68) });
	return b.build();
}

// A folded white bed sheet with a faded blue stripe: 0.4 x 0.06 x 0.3 m, origin in its middle.
export function buildBedSheet() {
	const b = new Builder('bed_sheet');
	b.add('sheet', mat('sheet_white', 0xeeeee6), new THREE.BoxGeometry(0.4, 0.06, 0.3));
	b.add('stripe', mat('sheet_stripe', 0x8aa0c8), new THREE.BoxGeometry(0.41, 0.065, 0.04), { pos: V(0, 0, 0.08) });
	return b.build();
}

// The cell's spare mattress, thin and stained: 0.75 x 0.22 x 1.8 m, origin in its middle.
export function buildCellMattress() {
	const b = new Builder('cell_mattress');
	const cloth = mat('mattress_cloth', 0xb8b098), stain = mat('mattress_stain', 0x9a8a68);
	b.add('mattress', cloth, new THREE.BoxGeometry(0.75, 0.22, 1.8));
	b.add('stain', stain, new THREE.CylinderGeometry(0.16, 0.16, 0.01, 10), { pos: V(0.12, 0.11, -0.3) });
	for (const z of [-0.6, 0, 0.6]) b.add('seams', stain, new THREE.BoxGeometry(0.76, 0.225, 0.02), { pos: V(0, 0, z) });
	return b.build();
}

// A cardboard box of old files from the storage room: 0.5 x 0.4 x 0.4 m with a taped lid and a label, origin in
// its middle.
export function buildStorageBox() {
	const b = new Builder('storage_box');
	const card = mat('box_card', 0xb08a5a), tape = mat('box_tape', 0xd8c49a), label = mat('box_label', 0xf0ece0);
	b.add('box', card, new THREE.BoxGeometry(0.5, 0.4, 0.4));
	b.add('tape', tape, new THREE.BoxGeometry(0.08, 0.405, 0.405));
	b.add('label', label, new THREE.BoxGeometry(0.18, 0.1, 0.005), { pos: V(0.12, 0.02, 0.2) });
	return b.build();
}

// The wooden ladder from the storage room up to the roof's hatch: 0.5 m wide, 5.6 m tall, origin at its feet, leaning
// on +Z.
export function buildRoofLadder() {
	const b = new Builder('roof_ladder');
	const wood = mat('ladder_wood', 0x8a6238);
	for (const x of [-0.22, 0.22]) b.add('rails', wood, new THREE.BoxGeometry(0.05, 5.6, 0.06), { pos: V(x, 2.8, 0) });
	for (let i = 0; i < 18; i++) b.add('rungs', wood, new THREE.BoxGeometry(0.44, 0.04, 0.04), { pos: V(0, 0.3 + i * 0.3, 0) });
	return b.build();
}

// The roof's hatch: a grey metal lid 0.8 m wide on a low frame, lying on the roof, origin at its bottom middle.
export function buildRoofHatch() {
	const b = new Builder('roof_hatch');
	const metal = mat('hatch_metal', 0x6a6e74), dark = mat('hatch_dark', 0x2a2c30);
	b.add('frame', dark, new THREE.BoxGeometry(0.9, 0.12, 0.9), { pos: V(0, 0.06, 0) });
	b.add('lid', metal, new THREE.BoxGeometry(0.8, 0.04, 0.8), { pos: V(0, 0.14, 0) });
	b.add('handle', dark, new THREE.BoxGeometry(0.2, 0.04, 0.04), { pos: V(0, 0.18, 0.3) });
	return b.build();
}

// The sheets knotted into a rope, coiled: a white coil 0.5 m wide with knots, origin in its middle.
export function buildSheetRope() {
	const b = new Builder('sheet_rope');
	const sheet = mat('sheet_white', 0xeeeee6), stripe = mat('sheet_stripe', 0x8aa0c8);
	for (let i = 0; i < 3; i++) b.add('coil', sheet, new THREE.TorusGeometry(0.2, 0.05, 6, 14), { pos: V(0, -0.06 + i * 0.06, 0), rot: [Math.PI / 2, 0, i * 0.7] });
	for (const a of [0, 2.1, 4.2]) b.add('knots', stripe, new THREE.SphereGeometry(0.07, 6, 5), { pos: V(Math.cos(a) * 0.2, 0.06, Math.sin(a) * 0.2) });
	return b.build();
}

// The TV antenna on the roof: a thin pole 1.6 m tall on a base, with cross bars at the top. Origin on the roof.
export function buildRoofAntenna() {
	const b = new Builder('roof_antenna');
	const metal = mat('antenna_metal', 0x9aa0a8), dark = mat('antenna_dark', 0x3a3e44);
	b.add('base', dark, new THREE.BoxGeometry(0.4, 0.1, 0.4), { pos: V(0, 0.05, 0) });
	b.add('pole', metal, new THREE.CylinderGeometry(0.03, 0.03, 1.6, 8), { pos: V(0, 0.85, 0) });
	for (let i = 0; i < 4; i++) b.add('bars', metal, new THREE.BoxGeometry(0.9 - i * 0.15, 0.02, 0.02), { pos: V(0, 1.2 + i * 0.12, 0) });
	return b.build();
}

export const models = {
	cell_skylight: buildCellSkylight, skylight_pane: buildSkylightPane, bed_sheet: buildBedSheet,
	cell_mattress: buildCellMattress, storage_box: buildStorageBox, roof_ladder: buildRoofLadder, roof_hatch: buildRoofHatch,
	sheet_rope: buildSheetRope, roof_antenna: buildRoofAntenna,
};

export const views = {
	roof: {
		items: [
			{ name: 'cell_skylight', pos: [-0.6, 1.2, 0] },
			{ name: 'skylight_pane', pos: [-0.6, 1.17, -0.35], rotX: -0.9 },
			{ name: 'cell_mattress', pos: [0.6, 0.11, 0.2], rotY: 0.2 },
			{ name: 'bed_sheet', pos: [0.6, 0.25, 0.2] },
			{ name: 'bed_sheet', pos: [0.6, 0.31, 0.25], rotY: 0.3 },
		],
		cam: { pos: [0, 1.0, 2.8], target: [0, 0.6, 0], fov: 45 },
	},
	attic: {
		items: [
			{ name: 'storage_box', pos: [-0.8, 0.2, 0.3] },
			{ name: 'storage_box', pos: [-0.8, 0.6, 0.3], rotY: 0.3 },
			{ name: 'storage_box', pos: [-0.2, 0.2, 0.6], rotY: -0.2 },
			{ name: 'roof_ladder', pos: [0.6, 0, -0.4] },
			{ name: 'roof_hatch', pos: [0.6, 0, 0.8] },
		],
		cam: { pos: [0, 2.0, 4.6], target: [0, 1.4, 0], fov: 50 },
	},
	rope: {
		items: [
			{ name: 'roof_antenna', pos: [-0.4, 0, 0] },
			{ name: 'sheet_rope', pos: [0.5, 0.1, 0.3] },
		],
		cam: { pos: [0, 1.2, 2.6], target: [0, 0.7, 0], fov: 45 },
	},
};
