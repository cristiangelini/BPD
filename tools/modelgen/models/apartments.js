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

// A brass telescope on a wooden tripod, 1.5 m tall, the tube pointing up toward +Z.
export function buildSpyTelescope() {
	const b = new Builder('spy_telescope');
	const wood = mat('tripod_wood', 0x8a5a32), brass = mat('scope_brass', 0xc8a040), black = mat('scope_lens', 0x16161a);
	for (let i = 0; i < 3; i++) {
		const a = i / 3 * Math.PI * 2;
		b.add('tripod', wood, new THREE.CylinderGeometry(0.02, 0.025, 1.15, 6), { pos: V(Math.sin(a) * 0.2, 0.55, Math.cos(a) * 0.2), rot: [-Math.cos(a) * 0.35, 0, Math.sin(a) * 0.35] });
	}
	b.add('head', wood, new THREE.CylinderGeometry(0.06, 0.06, 0.08, 8), { pos: V(0, 1.12, 0) });
	b.add('tube', brass, new THREE.CylinderGeometry(0.06, 0.08, 0.9, 12), { pos: V(0, 1.3, 0.05), rot: [Math.PI / 2 - 0.4, 0, 0] });
	b.add('lens', black, new THREE.CylinderGeometry(0.082, 0.082, 0.02, 12), { pos: V(0, 1.47, 0.47), rot: [Math.PI / 2 - 0.4, 0, 0] });
	b.add('eyepiece', black, new THREE.CylinderGeometry(0.025, 0.025, 0.1, 8), { pos: V(0, 1.11, -0.38), rot: [Math.PI / 2 - 0.4, 0, 0] });
	return b.build();
}

// A small black notebook 0.15 m long with a red band: the vault's code inside.
export function buildCodeNotebook() {
	const b = new Builder('code_notebook');
	b.add('cover', mat('notebook_black', 0x1e1e22), new THREE.BoxGeometry(0.15, 0.02, 0.1), { pos: V(0, 0.01, 0) });
	b.add('band', mat('notebook_band', 0xc83a3a), new THREE.BoxGeometry(0.01, 0.022, 0.1), { pos: V(0.05, 0.011, 0) });
	return b.build();
}

// A pair of green binoculars 0.15 m wide.
export function buildBinoculars() {
	const b = new Builder('binoculars');
	const green = mat('binocular_green', 0x3a5a3a), black = mat('scope_lens', 0x16161a);
	for (const x of [-0.04, 0.04]) {
		b.add('barrel', green, new THREE.CylinderGeometry(0.03, 0.035, 0.14, 10), { pos: V(x, 0.035, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('lens', black, new THREE.CylinderGeometry(0.031, 0.031, 0.01, 10), { pos: V(x, 0.035, 0.072), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('bridge', green, new THREE.BoxGeometry(0.05, 0.02, 0.05), { pos: V(0, 0.05, 0) });
	return b.build();
}

// The key of the floor that doesn't exist: a big gold key 0.12 m long with "31" on its bow.
export function buildFloorKey() {
	const b = new Builder('floor_key');
	const gold = mat('key_gold', 0xe8c040);
	b.add('bow', gold, new THREE.CylinderGeometry(0.025, 0.025, 0.01, 10), { pos: V(-0.04, 0.005, 0) });
	b.add('shaft', gold, new THREE.BoxGeometry(0.08, 0.008, 0.012), { pos: V(0.02, 0.005, 0) });
	for (const x of [0.04, 0.055]) b.add('bit', gold, new THREE.BoxGeometry(0.008, 0.008, 0.02), { pos: V(x, 0.005, 0.014) });
	b.add('number', mat('key_number', 0x2a2a2e), new THREE.BoxGeometry(0.02, 0.012, 0.012), { pos: V(-0.04, 0.006, 0) });
	return b.build();
}

// A wooden crate 0.9 x 0.6 x 0.5 m full of stolen paintings: gilded frames peek over its open top.
export function buildPaintingsBox() {
	const b = new Builder('paintings_box');
	const wood = mat('crate_wood', 0xb08850), gilt = mat('frame_gilt', 0xd8b048);
	b.add('bottom', wood, new THREE.BoxGeometry(0.9, 0.04, 0.5), { pos: V(0, 0.02, 0) });
	for (const z of [-0.23, 0.23]) b.add('side', wood, new THREE.BoxGeometry(0.9, 0.5, 0.04), { pos: V(0, 0.25, z) });
	for (const x of [-0.43, 0.43]) b.add('side', wood, new THREE.BoxGeometry(0.04, 0.5, 0.42), { pos: V(x, 0.25, 0) });
	const canvases = [0x3a6a9a, 0xc85a3a, 0x5a8a4a];
	canvases.forEach((color, i) => {
		const x = -0.25 + i * 0.25;
		b.add('frames', gilt, new THREE.BoxGeometry(0.04, 0.6, 0.38), { pos: V(x, 0.34, 0), rot: [0, 0, 0.08 * (i - 1)] });
		b.add('canvas', mat('canvas_' + i, color), new THREE.BoxGeometry(0.045, 0.5, 0.3), { pos: V(x, 0.36, 0), rot: [0, 0, 0.08 * (i - 1)] });
	});
	return b.build();
}

// The building's plan, rolled: a blue tube 0.4 m long with a white band, "31" drawn on the top floor.
export function buildFloorPlan() {
	const b = new Builder('floor_plan');
	b.add('roll', mat('plan_blue', 0x3a6ab8), new THREE.CylinderGeometry(0.03, 0.03, 0.4, 10), { pos: V(0, 0.03, 0), rot: [0, 0, Math.PI / 2] });
	b.add('band', mat('plan_band', 0xf4f4f0), new THREE.CylinderGeometry(0.032, 0.032, 0.03, 10), { pos: V(0.1, 0.03, 0), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// A pigeon 0.3 m long, facing +X: a grey body, a darker head with an orange eye and a beak, wings and a fan tail.
export function buildPigeon() {
	const b = new Builder('pigeon');
	const grey = mat('pigeon_grey', 0x8a8e9a), dark = mat('pigeon_dark', 0x4a5060);
	b.add('body', grey, ellipsoid(0.13, 0.08, 0.075, 10, 6), { pos: V(0, 0.1, 0) });
	b.add('head', dark, ellipsoid(0.05, 0.05, 0.045, 8, 5), { pos: V(0.12, 0.18, 0) });
	b.add('neck', mat('pigeon_neck', 0x4a8a7a), ellipsoid(0.05, 0.04, 0.05, 8, 4), { pos: V(0.09, 0.14, 0) });
	b.add('beak', mat('pigeon_beak', 0xd8a040), new THREE.ConeGeometry(0.012, 0.04, 4), { pos: V(0.18, 0.175, 0), rot: [0, 0, -Math.PI / 2] });
	for (const z of [-0.025, 0.025]) b.add('eye', mat('pigeon_eye', 0xe86a2a), ellipsoid(0.008, 0.008, 0.005, 5, 3), { pos: V(0.14, 0.19, z) });
	for (const z of [-0.07, 0.07]) b.add('wing', dark, ellipsoid(0.1, 0.035, 0.02, 8, 4), { pos: V(-0.02, 0.12, z) });
	b.add('tail', dark, new THREE.BoxGeometry(0.1, 0.015, 0.08), { pos: V(-0.15, 0.1, 0) });
	for (const z of [-0.02, 0.02]) b.add('leg', mat('pigeon_leg', 0xc85a5a), new THREE.CylinderGeometry(0.006, 0.006, 0.05, 4), { pos: V(0.01, 0.025, z) });
	return b.build();
}

// The pigeon loft: a wooden hutch 0.9 m wide, 0.6 m deep and 0.8 m tall on short legs, with a wire front, a sloped
// roof, a landing board and two pigeons inside.
export function buildPigeonLoft() {
	const b = new Builder('pigeon_loft');
	const wood = mat('loft_wood', 0xa87a4a), roof = mat('loft_roof', 0x7a4a3a);
	const wire = mat('loft_wire', 0xb8bcc4, { transparent: true, opacity: 0.45 });
	for (const [x, z] of [[-0.4, -0.25], [-0.4, 0.25], [0.4, -0.25], [0.4, 0.25]]) b.add('legs', wood, new THREE.BoxGeometry(0.05, 0.15, 0.05), { pos: V(x, 0.075, z) });
	b.add('floor', wood, new THREE.BoxGeometry(0.9, 0.04, 0.6), { pos: V(0, 0.17, 0) });
	b.add('back', wood, new THREE.BoxGeometry(0.9, 0.55, 0.03), { pos: V(0, 0.44, -0.285) });
	for (const x of [-0.435, 0.435]) b.add('side', wood, new THREE.BoxGeometry(0.03, 0.55, 0.6), { pos: V(x, 0.44, 0) });
	b.add('wire', wire, new THREE.BoxGeometry(0.84, 0.5, 0.01), { pos: V(0, 0.44, 0.29) });
	b.add('roof', roof, new THREE.BoxGeometry(1.0, 0.04, 0.72), { pos: V(0, 0.75, 0), rot: [0.15, 0, 0] });
	b.add('board', wood, new THREE.BoxGeometry(0.4, 0.02, 0.15), { pos: V(0, 0.2, 0.37) });
	const grey = mat('pigeon_grey', 0x8a8e9a);
	for (const x of [-0.2, 0.15]) {
		b.add('pigeons', grey, ellipsoid(0.1, 0.06, 0.06, 8, 5), { pos: V(x, 0.25, 0) });
		b.add('pigeons', mat('pigeon_dark', 0x4a5060), ellipsoid(0.04, 0.04, 0.035, 6, 4), { pos: V(x + 0.09, 0.32, 0) });
	}
	return b.build();
}

// A pearl necklace in a loose loop 0.15 m across.
export function buildPearlNecklace() {
	const b = new Builder('pigeon_necklace');
	const pearl = mat('pearl', 0xf4f0e8);
	for (let i = 0; i < 18; i++) {
		const a = i / 18 * Math.PI * 2;
		b.add('pearls', pearl, ellipsoid(0.012, 0.012, 0.012, 6, 4), { pos: V(Math.cos(a) * 0.07, 0.012, Math.sin(a) * 0.06) });
	}
	b.add('clasp', mat('clasp_gold', 0xd8b048), new THREE.BoxGeometry(0.02, 0.01, 0.015), { pos: V(0.075, 0.012, 0) });
	return b.build();
}

// A silver trainer's whistle 0.07 m long on a red cord.
export function buildTrainerWhistle() {
	const b = new Builder('trainer_whistle');
	const silver = mat('whistle_silver', 0xc8ccd4);
	b.add('body', silver, new THREE.CylinderGeometry(0.014, 0.014, 0.03, 10), { pos: V(0, 0.014, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('mouth', silver, new THREE.BoxGeometry(0.04, 0.012, 0.012), { pos: V(0.03, 0.014, 0) });
	b.add('cord', mat('whistle_cord', 0xc83a3a), new THREE.TorusGeometry(0.03, 0.003, 4, 12), { pos: V(-0.035, 0.004, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// A cardboard box 0.4 x 0.3 x 0.3 m, open, stuffed with the twenty rental contracts.
export function buildContractsBox() {
	const b = new Builder('contracts_box');
	const card = mat('cardboard', 0xc89a5a), paper = mat('contract_paper', 0xf4f2ea);
	b.add('bottom', card, new THREE.BoxGeometry(0.4, 0.02, 0.3), { pos: V(0, 0.01, 0) });
	for (const z of [-0.14, 0.14]) b.add('side', card, new THREE.BoxGeometry(0.4, 0.28, 0.02), { pos: V(0, 0.15, z) });
	for (const x of [-0.19, 0.19]) b.add('side', card, new THREE.BoxGeometry(0.02, 0.28, 0.26), { pos: V(x, 0.15, 0) });
	for (let i = 0; i < 6; i++) b.add('contracts', paper, new THREE.BoxGeometry(0.03, 0.3, 0.22), { pos: V(-0.14 + i * 0.055, 0.17, 0), rot: [0, 0, (i % 2 ? 0.1 : -0.08)] });
	b.add('label', mat('box_label', 0x2a2a2e), new THREE.BoxGeometry(0.16, 0.06, 0.005), { pos: V(0, 0.2, 0.153) });
	return b.build();
}

// The owner's fake stamp: a wooden handle 0.1 m tall on a red rubber base.
export function buildFakeStamp() {
	const b = new Builder('fake_stamp');
	b.add('base', mat('stamp_rubber', 0xc83a3a), new THREE.BoxGeometry(0.07, 0.02, 0.05), { pos: V(0, 0.01, 0) });
	b.add('block', mat('stamp_wood', 0x8a5a32), new THREE.BoxGeometry(0.06, 0.025, 0.04), { pos: V(0, 0.032, 0) });
	b.add('handle', mat('stamp_wood', 0x8a5a32), new THREE.CylinderGeometry(0.012, 0.016, 0.05, 8), { pos: V(0, 0.07, 0) });
	b.add('knob', mat('stamp_knob', 0x2a2a2e), ellipsoid(0.02, 0.015, 0.02, 8, 5), { pos: V(0, 0.1, 0) });
	return b.build();
}

// A bunch of twenty keys on a big ring, lying flat, 0.2 m across.
export function buildKeyBunch() {
	const b = new Builder('key_bunch');
	b.add('ring', mat('ring_steel', 0xb8bcc4), new THREE.TorusGeometry(0.05, 0.005, 4, 16), { pos: V(0, 0.008, 0), rot: [Math.PI / 2, 0, 0] });
	const colors = [0xd8b048, 0xb8bcc4, 0xc88a4a];
	for (let i = 0; i < 20; i++) {
		const a = i / 20 * Math.PI * 2;
		b.add('keys', mat('key_' + (i % 3), colors[i % 3]), new THREE.BoxGeometry(0.06, 0.006, 0.012), { pos: V(Math.cos(a) * 0.08, 0.004 + (i % 2) * 0.006, Math.sin(a) * 0.08), rot: [0, -a, 0] });
	}
	return b.build();
}

// A single mattress 0.9 x 1.9 m, 0.2 m thick, striped ticking.
export function buildMattress() {
	const b = new Builder('mattress');
	b.add('pad', mat('mattress_white', 0xeee8dc), new THREE.BoxGeometry(0.9, 0.2, 1.9), { pos: V(0, 0.1, 0) });
	for (let i = 0; i < 5; i++) b.add('stripes', mat('mattress_blue', 0x6a8ac8), new THREE.BoxGeometry(0.06, 0.205, 1.905), { pos: V(-0.36 + i * 0.18, 0.1, 0) });
	return b.build();
}

// A stuffed duffel bag 0.6 m long.
export function buildDuffelBag() {
	const b = new Builder('duffel_bag');
	b.add('bag', mat('bag_cloth', 0x5a6a4a), new THREE.CylinderGeometry(0.15, 0.15, 0.6, 10), { pos: V(0, 0.15, 0), rot: [0, 0, Math.PI / 2] });
	b.add('strap', mat('bag_strap', 0x2a2a2e), new THREE.TorusGeometry(0.12, 0.012, 4, 10, Math.PI), { pos: V(0, 0.28, 0), rot: [0, Math.PI / 2, 0] });
	return b.build();
}

export const models = {
	stolen_aquarium: buildStolenAquarium, fishing_net: buildFishingNet, aquarium_ticket: buildAquariumTicket,
	contraband_piano: buildContrabandPiano, piano_sheet: buildPianoSheet, gold_ingot: buildGoldIngot,
	spy_telescope: buildSpyTelescope, code_notebook: buildCodeNotebook, binoculars: buildBinoculars,
	floor_key: buildFloorKey, paintings_box: buildPaintingsBox, floor_plan: buildFloorPlan,
	pigeon: buildPigeon, pigeon_loft: buildPigeonLoft, pigeon_necklace: buildPearlNecklace, trainer_whistle: buildTrainerWhistle,
	contracts_box: buildContractsBox, fake_stamp: buildFakeStamp, key_bunch: buildKeyBunch, mattress: buildMattress,
	duffel_bag: buildDuffelBag,
};

export const views = {
	contracts_box: {
		items: [{ name: 'mattress', pos: [-0.3, 0, -0.6] }, { name: 'duffel_bag', pos: [-0.3, 0.2, -0.9] }, { name: 'contracts_box', pos: [0.6, 0, 0.3] }, { name: 'fake_stamp', pos: [1.0, 0, 0.6] }, { name: 'key_bunch', pos: [0.7, 0, 0.8] }],
		cam: { pos: [2.0, 1.4, 2.2], target: [0.3, 0.2, 0], fov: 40 },
	},
	pigeon_loft: {
		items: [{ name: 'pigeon_loft', pos: [0, 0, 0] }, { name: 'pigeon', pos: [0.75, 0, 0.3] }, { name: 'pigeon_necklace', pos: [0.7, 0, 0.7] }, { name: 'trainer_whistle', pos: [1.0, 0, 0.6] }],
		cam: { pos: [1.6, 1.2, 2.2], target: [0.35, 0.3, 0.2], fov: 40 },
	},
	floor_key: {
		items: [{ name: 'paintings_box', pos: [0, 0, 0] }, { name: 'floor_key', pos: [0.7, 0, 0.3] }, { name: 'floor_plan', pos: [0.7, 0, -0.1] }],
		cam: { pos: [1.4, 1.1, 1.6], target: [0.3, 0.25, 0], fov: 40 },
	},
	spy_telescope: {
		items: [{ name: 'spy_telescope', pos: [0, 0, 0] }, { name: 'code_notebook', pos: [0.6, 0, 0.3] }, { name: 'binoculars', pos: [0.6, 0, -0.1] }],
		cam: { pos: [1.6, 1.4, 2.2], target: [0.2, 0.7, 0], fov: 40 },
	},
	contraband_piano: {
		items: [{ name: 'contraband_piano', pos: [0, 0, 0] }, { name: 'piano_sheet', pos: [1.2, 0, 0.5] }, { name: 'gold_ingot', pos: [1.2, 0, -0.1] }],
		cam: { pos: [-1.6, 1.8, 2.6], target: [0.2, 0.55, 0], fov: 40 },
	},
	stolen_aquarium: {
		items: [{ name: 'stolen_aquarium', pos: [0, 0, 0] }, { name: 'fishing_net', pos: [1.4, 0, 0.4] }, { name: 'aquarium_ticket', pos: [1.3, 0, 0.0] }],
		cam: { pos: [0.6, 1.6, 3.2], target: [0.4, 0.45, 0], fov: 40 },
	},
};
