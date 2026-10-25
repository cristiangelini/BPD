// The fire drill jailbreak (fuga-simulacro.md): the prisoners' orange vest, each cell's old heater, the bunk's blanket
// and the smoke detector on the cell's ceiling. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid, loft } from '../lib.js';

// The orange prisoner's vest, worn over a cop's body: the origin at the cop's feet, a shell just outside the shirt
// (pear.js) from the belt to the shoulders, with a white stripe. Seen on the cop and lying on the floor.
export function buildPrisonVest() {
	const b = new Builder('prison_vest');
	const orange = mat('vest_orange', 0xf07818), white = mat('vest_white', 0xeeeeea);
	b.add('vest', orange, loft([
		{ y: 0.46, rx: 0.5, rz: 0.45 }, { y: 0.8, rx: 0.4, rz: 0.36 }, { y: 1.04, rx: 0.28, rz: 0.26 },
	], 14));
	b.add('stripe', white, loft([{ y: 0.62, rx: 0.48, rz: 0.43 }, { y: 0.68, rx: 0.465, rz: 0.415 }], 14));
	return b.build();
}

// The cell's old electric heater: a rusty box 0.6 x 0.55 x 0.25 m on short legs, its grille glowing orange in front
// (+Z). The origin on the floor.
export function buildCellHeater() {
	const b = new Builder('cell_heater');
	const rust = mat('heater_rust', 0x8a5a3a), dark = mat('heater_dark', 0x2a2420);
	const glow = mat('heater_glow', 0xff6a20, { emissive: 0xff5010 });
	b.add('box', rust, new THREE.BoxGeometry(0.6, 0.45, 0.25), { pos: V(0, 0.33, 0) });
	for (const x of [-0.26, 0.26]) b.add('legs', dark, new THREE.BoxGeometry(0.04, 0.1, 0.2), { pos: V(x, 0.05, 0) });
	for (let i = 0; i < 4; i++) b.add('grille', glow, new THREE.BoxGeometry(0.48, 0.03, 0.02), { pos: V(0, 0.2 + i * 0.08, 0.13) });
	b.add('knob', dark, new THREE.CylinderGeometry(0.03, 0.03, 0.03, 8), { pos: V(0.24, 0.5, 0.13), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The bunk's grey blanket, folded: 0.5 x 0.1 x 0.4 m, origin in its middle.
export function buildCellBlanket() {
	const b = new Builder('cell_blanket');
	const wool = mat('blanket_grey', 0x7a7a86), edge = mat('blanket_edge', 0x5a5a66);
	b.add('blanket', wool, new THREE.BoxGeometry(0.5, 0.1, 0.4));
	b.add('edge', edge, new THREE.BoxGeometry(0.51, 0.02, 0.41), { pos: V(0, 0.03, 0) });
	return b.build();
}

// The smoke detector on a cell's ceiling: a white disc 0.16 m wide with a red light, the origin at the ceiling (it
// hangs down, -Y).
export function buildSmokeDetector() {
	const b = new Builder('smoke_detector');
	b.add('body', mat('detector_white', 0xf0f0ec), new THREE.CylinderGeometry(0.08, 0.07, 0.04, 16), { pos: V(0, -0.02, 0) });
	b.add('light', mat('detector_red', 0xe02020, { emissive: 0x801010 }), ellipsoid(0.012, 0.008, 0.012, 6, 4), { pos: V(0.04, -0.045, 0) });
	return b.build();
}

export const models = {
	prison_vest: buildPrisonVest, cell_heater: buildCellHeater, cell_blanket: buildCellBlanket,
	smoke_detector: buildSmokeDetector,
};

export const views = {
	drill: {
		items: [
			{ name: 'cop_2', pos: [-0.6, 0, 0] },
			{ name: 'prison_vest', pos: [-0.6, 0, 0] },
			{ name: 'cell_heater', pos: [0.5, 0, 0.2] },
			{ name: 'cell_blanket', pos: [0.5, 0.6, 0.2] },
			{ name: 'smoke_detector', pos: [1.2, 1.2, 0.4] },
		],
		cam: { pos: [0.3, 1.4, 3.2], target: [0.2, 0.7, 0], fov: 42 },
	},
};
