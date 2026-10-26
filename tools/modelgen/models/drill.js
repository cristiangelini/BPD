// The fire drill jailbreak (fuga-simulacro.md): the prisoners' orange vest, each cell's old heater, the bunk's blanket
// and the smoke detector on the cell's ceiling. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid, loft } from '../lib.js';

// The orange prisoner's vest, worn over a cop's body: a shell just outside the shirt (pear.js) from the belt to the
// shoulders, with a white stripe. Origin at the chest's front (DisguisePiece.SLOTS), the cop's middle 0.3 m behind
// (-Z) and his feet 0.95 m down.
export function buildPrisonVest() {
	const b = new Builder('prison_vest');
	const orange = mat('vest_orange', 0xf07818), white = mat('vest_white', 0xeeeeea);
	const ring = (y, rx, rz) => ({ y: y - 0.95, rx, rz, cz: -0.3 });
	b.add('vest', orange, loft([ring(0.46, 0.5, 0.45), ring(0.8, 0.4, 0.36), ring(1.04, 0.28, 0.26)], 14));
	b.add('stripe', white, loft([ring(0.62, 0.48, 0.43), ring(0.68, 0.465, 0.415)], 14));
	return b.build();
}

// The vest taken off, lying on the floor: 0.42 x 0.06 x 0.32 m with its stripe, origin in its middle.
export function buildFoldedPrisonVest() {
	const b = new Builder('folded_prison_vest');
	b.add('vest', mat('vest_orange', 0xf07818), new THREE.BoxGeometry(0.42, 0.06, 0.32));
	b.add('stripe', mat('vest_white', 0xeeeeea), new THREE.BoxGeometry(0.43, 0.02, 0.05), { pos: V(0, 0.025, 0) });
	return b.build();
}

// The waiting room's coat, worn: a beige trench coat from the shoulders to the knees, over the uniform and the vest,
// with a collar and buttons. Origin at the chest's front like the vest's.
export function buildDisguiseCoat() {
	const b = new Builder('disguise_coat');
	const cloth = mat('coat_beige', 0xb89a6a), dark = mat('coat_dark', 0x5a4630);
	const ring = (y, rx, rz) => ({ y: y - 0.95, rx, rz, cz: -0.3 });
	b.add('coat', cloth, loft([ring(0.3, 0.57, 0.51), ring(0.8, 0.48, 0.42), ring(1.12, 0.33, 0.31)], 14));
	b.add('collar', cloth, new THREE.TorusGeometry(0.27, 0.05, 6, 14), { pos: V(0, 0.17, -0.3), rot: [Math.PI / 2, 0, 0] });
	for (let i = 0; i < 3; i++) b.add('buttons', dark, new THREE.CylinderGeometry(0.025, 0.025, 0.02, 8), { pos: V(0, -0.1 - i * 0.18, 0.15 - i * 0.02), rot: [Math.PI / 2, 0, 0] });
	b.add('belt', dark, loft([ring(0.68, 0.5, 0.44), ring(0.73, 0.49, 0.43)], 14));
	return b.build();
}

// The coat on its hanger, as it hangs from the coat rack: 0.5 x 0.9 x 0.12 m, origin at the hook (its top middle).
export function buildHangingCoat() {
	const b = new Builder('hanging_coat');
	const cloth = mat('coat_beige', 0xb89a6a), dark = mat('coat_dark', 0x5a4630);
	b.add('coat', cloth, new THREE.BoxGeometry(0.5, 0.86, 0.12), { pos: V(0, -0.47, 0) });
	b.add('sleeves', cloth, new THREE.BoxGeometry(0.1, 0.6, 0.1), { pos: V(-0.29, -0.4, 0) });
	b.add('sleeves', cloth, new THREE.BoxGeometry(0.1, 0.6, 0.1), { pos: V(0.29, -0.4, 0) });
	b.add('hanger', dark, new THREE.BoxGeometry(0.44, 0.03, 0.03), { pos: V(0, -0.04, 0) });
	b.add('belt', dark, new THREE.BoxGeometry(0.51, 0.04, 0.13), { pos: V(0, -0.5, 0) });
	return b.build();
}

// A grey felt hat with a black band, big enough to go over a cop's cap: 0.48 m wide, origin at its bottom middle.
export function buildDisguiseHat() {
	const b = new Builder('disguise_hat');
	const felt = mat('hat_felt', 0x6a6a72), band = mat('hat_band', 0x1a1a1e);
	b.add('brim', felt, new THREE.CylinderGeometry(0.24, 0.24, 0.02, 16), { pos: V(0, 0.01, 0) });
	b.add('crown', felt, new THREE.CylinderGeometry(0.15, 0.17, 0.16, 14), { pos: V(0, 0.09, 0) });
	b.add('band', band, new THREE.CylinderGeometry(0.172, 0.172, 0.035, 14), { pos: V(0, 0.04, 0) });
	return b.build();
}

// The waiting room's coat rack: a dark wooden pole 1.8 m high on three feet, with six hooks around its top. The origin
// on the floor.
export function buildCoatRack() {
	const b = new Builder('coat_rack');
	const wood = mat('rack_wood', 0x4a3020), brass = mat('rack_brass', 0xc8a040);
	b.add('pole', wood, new THREE.CylinderGeometry(0.03, 0.04, 1.8, 8), { pos: V(0, 0.9, 0) });
	for (let i = 0; i < 3; i++) {
		const a = (i / 3) * Math.PI * 2;
		b.add('feet', wood, new THREE.BoxGeometry(0.05, 0.04, 0.4), { pos: V(Math.sin(a) * 0.18, 0.02, Math.cos(a) * 0.18), rot: [0, a, 0] });
	}
	for (let i = 0; i < 6; i++) {
		const a = (i / 6) * Math.PI * 2;
		b.add('hooks', brass, new THREE.CylinderGeometry(0.012, 0.012, 0.18, 6), { pos: V(Math.sin(a) * 0.08, 1.68, Math.cos(a) * 0.08), rot: [Math.cos(a) * 1.0, 0, -Math.sin(a) * 1.0] });
	}
	b.add('top', brass, ellipsoid(0.05, 0.04, 0.05, 8, 5), { pos: V(0, 1.82, 0) });
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
	smoke_detector: buildSmokeDetector, folded_prison_vest: buildFoldedPrisonVest, disguise_coat: buildDisguiseCoat,
	hanging_coat: buildHangingCoat, disguise_hat: buildDisguiseHat, coat_rack: buildCoatRack,
};

export const views = {
	drill: {
		items: [
			{ name: 'cop_2', pos: [-0.6, 0, 0] },
			{ name: 'prison_vest', pos: [-0.6, 0.95, 0.3] },
			{ name: 'cell_heater', pos: [0.5, 0, 0.2] },
			{ name: 'cell_blanket', pos: [0.5, 0.6, 0.2] },
			{ name: 'smoke_detector', pos: [1.2, 1.2, 0.4] },
		],
		cam: { pos: [0.3, 1.4, 3.2], target: [0.2, 0.7, 0], fov: 42 },
	},
	coats: {
		items: [
			{ name: 'cop_2', pos: [-0.7, 0, 0] },
			{ name: 'prison_vest', pos: [-0.7, 0.95, 0.3] },
			{ name: 'disguise_coat', pos: [-0.7, 0.95, 0.3] },
			{ name: 'disguise_hat', pos: [-0.7, 1.5, 0] },
			{ name: 'coat_rack', pos: [0.6, 0, 0] },
			{ name: 'hanging_coat', pos: [0.6, 1.68, 0.12] },
			{ name: 'disguise_hat', pos: [0.6, 1.62, -0.14], rotY: 0.4 },
			{ name: 'folded_prison_vest', pos: [0.0, 0.03, 0.6], rotY: 0.3 },
		],
		cam: { pos: [0.0, 1.4, 3.4], target: [0.0, 0.85, 0], fov: 42 },
	},
};
