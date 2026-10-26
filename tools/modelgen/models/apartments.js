// Props of the Las Palomas building's stories (docs/diseno/edificio.md), with origins at the floor in the middle of
// each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// The city aquarium's giant tank, 2 m long, 1 m deep and 1 m tall: a steel frame, glass, blue water, gravel, a little
// castle and the contest goldfish.
export function buildStolenAquarium() {
	const b = new Builder('stolen_aquarium');
	const steel = mat('tank_frame', 0x2a2e36);
	const glass = mat('tank_glass', 0xbfe4f2, { transparent: true, opacity: 0.35 });
	const water = mat('tank_water', 0x3a8ad0, { transparent: true, opacity: 0.55 });
	b.add('base', steel, new THREE.BoxGeometry(2.0, 0.1, 1.0), { pos: V(0, 0.05, 0) });
	b.add('base', steel, new THREE.BoxGeometry(2.0, 0.06, 1.0), { pos: V(0, 0.97, 0) });
	for (const x of [-0.97, 0.97]) for (const z of [-0.47, 0.47]) b.add('frame', steel, new THREE.BoxGeometry(0.06, 0.9, 0.06), { pos: V(x, 0.5, z) });
	b.add('glass', glass, new THREE.BoxGeometry(1.96, 0.86, 0.96), { pos: V(0, 0.53, 0) });
	b.add('water', water, new THREE.BoxGeometry(1.9, 0.7, 0.9), { pos: V(0, 0.46, 0) });
	b.add('gravel', mat('tank_gravel', 0xd8c08a), new THREE.BoxGeometry(1.9, 0.06, 0.9), { pos: V(0, 0.13, 0) });
	const stone = mat('tank_castle', 0xb8a8c8);
	b.add('castle', stone, new THREE.BoxGeometry(0.3, 0.3, 0.25), { pos: V(-0.6, 0.31, -0.15) });
	for (const x of [-0.72, -0.48]) b.add('castle', stone, new THREE.CylinderGeometry(0.06, 0.06, 0.42, 8), { pos: V(x, 0.37, -0.15) });
	const gold = mat('goldfish', 0xf29a2a);
	b.add('fish', gold, ellipsoid(0.12, 0.08, 0.05, 8, 5), { pos: V(0.3, 0.55, 0.1) });
	b.add('fish', gold, new THREE.ConeGeometry(0.07, 0.1, 4), { pos: V(0.44, 0.55, 0.1), rot: [0, 0, -Math.PI / 2] });
	b.add('fish', mat('fish_eye', 0x141414), ellipsoid(0.015, 0.015, 0.01, 5, 3), { pos: V(0.22, 0.57, 0.15) });
	b.add('label', mat('tank_label', 0xf4f0e0), new THREE.BoxGeometry(0.4, 0.1, 0.01), { pos: V(0.6, 0.97, 0.505) });
	return b.build();
}

// A fishing net: a wooden pole 0.9 m long with a green mesh hoop.
export function buildFishingNet() {
	const b = new Builder('fishing_net');
	b.add('pole', mat('net_pole', 0xa87a4a), new THREE.CylinderGeometry(0.015, 0.015, 0.7, 6), { pos: V(-0.1, 0.02, 0), rot: [0, 0, Math.PI / 2] });
	b.add('hoop', mat('net_hoop', 0x5a5e66), new THREE.TorusGeometry(0.13, 0.008, 4, 14), { pos: V(0.38, 0.02, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('mesh', mat('net_mesh', 0x4aa05a, { transparent: true, opacity: 0.7 }), new THREE.CircleGeometry(0.13, 12), { pos: V(0.38, 0.015, 0), rot: [-Math.PI / 2, 0, 0] });
	return b.build();
}

// The city aquarium's ticket with the day of the theft: a blue card 0.12 m long with a fish on it.
export function buildAquariumTicket() {
	const b = new Builder('aquarium_ticket');
	b.add('card', mat('ticket_blue', 0x4a8ad0), new THREE.BoxGeometry(0.12, 0.004, 0.06), { pos: V(0, 0.002, 0) });
	b.add('stub', mat('ticket_white', 0xf4f4f0), new THREE.BoxGeometry(0.03, 0.005, 0.06), { pos: V(0.045, 0.003, 0) });
	b.add('fish', mat('goldfish', 0xf29a2a), ellipsoid(0.02, 0.003, 0.012, 6, 3), { pos: V(-0.02, 0.005, 0) });
	return b.build();
}

// A black grand piano 1.5 m wide, 1.4 m deep and 1 m tall to its closed lid, the keyboard to -X: a box body on three
// legs, white and black keys, a music stand and gold pedals.
export function buildContrabandPiano() {
	const b = new Builder('contraband_piano');
	const black = mat('piano_black', 0x16161a), white = mat('piano_white', 0xf4f4ee), gold = mat('piano_gold', 0xd8b048);
	b.add('body', black, new THREE.BoxGeometry(1.5, 0.35, 1.4), { pos: V(0.05, 0.82, 0) });
	b.add('lid', black, new THREE.BoxGeometry(1.45, 0.03, 1.35), { pos: V(0.05, 1.0, 0) });
	for (const [x, z] of [[-0.6, -0.55], [-0.6, 0.55], [0.65, 0]]) b.add('legs', black, new THREE.CylinderGeometry(0.05, 0.04, 0.65, 8), { pos: V(x, 0.33, z) });
	b.add('keys', white, new THREE.BoxGeometry(0.18, 0.04, 1.2), { pos: V(-0.79, 0.72, 0) });
	for (let i = 0; i < 14; i++) b.add('keys', black, new THREE.BoxGeometry(0.1, 0.03, 0.03), { pos: V(-0.75, 0.75, -0.55 + i * 0.085) });
	b.add('stand', black, new THREE.BoxGeometry(0.03, 0.25, 0.6), { pos: V(-0.6, 1.1, 0), rot: [0, 0, -0.2] });
	for (const z of [-0.06, 0.06]) b.add('pedals', gold, new THREE.BoxGeometry(0.12, 0.02, 0.04), { pos: V(-0.55, 0.06, z) });
	return b.build();
}

// A page of sheet music 0.3 m tall with sums scribbled between the staves.
export function buildPianoSheet() {
	const b = new Builder('piano_sheet');
	b.add('page', mat('sheet_paper', 0xf6f2e4), new THREE.BoxGeometry(0.22, 0.004, 0.3), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 5; i++) b.add('staff', mat('sheet_ink', 0x2a2a2e), new THREE.BoxGeometry(0.18, 0.005, 0.006), { pos: V(0, 0.003, -0.11 + i * 0.05) });
	b.add('sums', mat('sheet_red', 0xc83a3a), new THREE.BoxGeometry(0.08, 0.005, 0.02), { pos: V(0.04, 0.0035, 0.13) });
	return b.build();
}

// A gold ingot 0.25 m long: a stepped bar with a stamp.
export function buildGoldIngot() {
	const b = new Builder('gold_ingot');
	const gold = mat('ingot_gold', 0xe8c040);
	b.add('bar', gold, new THREE.BoxGeometry(0.25, 0.04, 0.11), { pos: V(0, 0.02, 0) });
	b.add('bar', gold, new THREE.BoxGeometry(0.21, 0.03, 0.08), { pos: V(0, 0.055, 0) });
	b.add('stamp', mat('ingot_stamp', 0xb8902a), new THREE.BoxGeometry(0.06, 0.003, 0.03), { pos: V(0, 0.071, 0) });
	return b.build();
}

export const models = {
	stolen_aquarium: buildStolenAquarium, fishing_net: buildFishingNet, aquarium_ticket: buildAquariumTicket,
	contraband_piano: buildContrabandPiano, piano_sheet: buildPianoSheet, gold_ingot: buildGoldIngot,
};

export const views = {
	contraband_piano: {
		items: [{ name: 'contraband_piano', pos: [0, 0, 0] }, { name: 'piano_sheet', pos: [1.2, 0, 0.5] }, { name: 'gold_ingot', pos: [1.2, 0, -0.1] }],
		cam: { pos: [-1.6, 1.8, 2.6], target: [0.2, 0.55, 0], fov: 40 },
	},
	stolen_aquarium: {
		items: [{ name: 'stolen_aquarium', pos: [0, 0, 0] }, { name: 'fishing_net', pos: [1.4, 0, 0.4] }, { name: 'aquarium_ticket', pos: [1.3, 0, 0.0] }],
		cam: { pos: [0.6, 1.6, 3.2], target: [0.4, 0.45, 0], fov: 40 },
	},
};
