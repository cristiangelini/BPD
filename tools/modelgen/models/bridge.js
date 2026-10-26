// The bridge inauguration (docs/diseno/politico-puente.md): the bridge's planks and the builder's pickup. Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

const pine = mat('bridge_pine', 0xc8955a), grain = mat('bridge_grain', 0x9a6a3e), nail = mat('bridge_nail', 0x4a4e56);

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// One plank of the deck (step 1): 1 m wide (x), 12 cm thick and 2.5 m long across the bridge (z), cheap pine with
// darker grain and a nail at each corner, one of them sticking out. Its origin in its middle.
export function buildPlank() {
	const b = new Builder('bridge_plank');
	box(b, 'plank', pine, 0.98, 0.12, 2.5, 0, 0, 0);
	for (const [x, z, l] of [[-0.3, -0.5, 1.2], [0.1, 0.4, 1.4], [0.35, -0.2, 0.9]]) box(b, 'grain', grain, 0.03, 0.005, l, x, 0.0625, z);
	for (const x of [-0.4, 0.4]) for (const z of [-1.1, 1.1]) {
		const out = x > 0 && z > 0;
		b.add('nails', nail, new THREE.CylinderGeometry(0.02, 0.02, out ? 0.05 : 0.01, 6), { pos: V(x, out ? 0.085 : 0.065, z), rot: out ? [0, 0, 0.3] : undefined });
	}
	return b.build();
}

// The builders' pickup (step 1): Pegote Hermanos', orange and dented, its bed loaded with spare planks under a loose
// strap, a ladder on the rack and a traffic cone on top. About 5 m long, front to +Z, its origin on the ground in the
// middle; the wheels are its own (it never drives).
export function buildBuilderVan() {
	const orange = mat('builder_orange', 0xe8873a), dent = mat('builder_dent', 0xc06a2a), darkGlass = mat('truck_glass', 0x2a3340);
	const black = mat('car_black', 0x23252b), grey = mat('car_grey', 0x6b7280), light = mat('lamp', 0xfff3c0, { emissive: 0x806a20 });
	const tire = mat('tire', 0x1a1a1e), cone = mat('cone_orange', 0xf26a1a), stripe = mat('cone_white', 0xf4f4f0), strap = mat('strap', 0xd8c02a);
	const W = 2.1, FLOOR = 0.6;
	const b = new Builder('builder_van');
	box(b, 'body', black, W, 0.2, 5.0, 0, FLOOR - 0.1, 0);
	// The cab in front: hood, windshield, roof, side windows and a dent on the door.
	box(b, 'body', orange, W, 0.6, 1.2, 0, FLOOR + 0.3, 1.9);
	box(b, 'body', orange, W, 1.4, 1.3, 0, FLOOR + 0.7, 0.65);
	box(b, 'body', darkGlass, W - 0.1, 0.55, 0.06, 0, FLOOR + 1.05, 1.32, [-0.3, 0, 0]);
	for (const x of [-1, 1]) box(b, 'body', darkGlass, 0.04, 0.45, 0.8, x * (W / 2 + 0.01), FLOOR + 1.05, 0.65);
	box(b, 'body', dent, 0.04, 0.3, 0.5, W / 2 + 0.02, FLOOR + 0.4, 0.7, [0, 0.1, 0.2]);
	box(b, 'body', grey, W + 0.06, 0.18, 0.16, 0, FLOOR + 0.05, 2.52);
	for (const x of [-1, 1]) box(b, 'lights', light, 0.3, 0.14, 0.04, x * 0.7, FLOOR + 0.4, 2.51);
	// The bed: low sides, the spare planks stacked crooked, the strap and the rack with the ladder.
	for (const x of [-1, 1]) box(b, 'bed', orange, 0.08, 0.5, 2.9, x * (W / 2 - 0.04), FLOOR + 0.25, -1.0);
	box(b, 'bed', orange, W, 0.5, 0.08, 0, FLOOR + 0.25, -2.46);
	for (let i = 0; i < 6; i++) box(b, 'load', i % 2 ? grain : pine, 0.98, 0.12, 2.5, (i % 2 - 0.5) * 0.12, FLOOR + 0.06 + i * 0.12, -1.05, [0, (i % 3 - 1) * 0.06, 0]);
	box(b, 'load', strap, 1.2, 0.02, 0.06, 0, FLOOR + 0.8, -1.0, [0, 0, 0.35]);
	for (const z of [-0.1, -2.3]) box(b, 'rack', grey, W, 0.06, 0.06, 0, FLOOR + 1.6, z);
	for (const x of [-1, 1]) for (const z of [-0.1, -2.3]) box(b, 'rack', grey, 0.06, 1.1, 0.06, x * (W / 2 - 0.05), FLOOR + 1.05, z);
	for (const x of [-0.35, 0.35]) box(b, 'ladder', grey, 0.05, 0.05, 2.8, x, FLOOR + 1.68, -1.2);
	for (let i = 0; i < 7; i++) box(b, 'ladder', grey, 0.7, 0.04, 0.04, 0, FLOOR + 1.68, -2.5 + i * 0.4);
	b.add('cone', cone, new THREE.ConeGeometry(0.16, 0.45, 8), { pos: V(0, FLOOR + 1.95, 0.65) });
	b.add('cone', stripe, new THREE.CylinderGeometry(0.1, 0.12, 0.08, 8), { pos: V(0, FLOOR + 1.98, 0.65) });
	for (const x of [-1, 1]) for (const z of [1.6, -1.7]) b.add('wheels', tire, new THREE.CylinderGeometry(0.38, 0.38, 0.28, 12), { pos: V(x * (W / 2 - 0.1), 0.38, z), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// The engineer's loot (step 5): the steel beams that are missing from the bridge, three grey I-beams 3 m long (x)
// with orange paint marks, stacked on two blocks. Its origin on the ground in the middle.
export function buildSteelBeams() {
	const b = new Builder('steel_beams');
	const steel = mat('beam_steel', 0x7d848c), mark = mat('beam_mark', 0xf26a1a), block = mat('bridge_grain', 0x9a6a3e);
	for (const x of [-1.1, 1.1]) box(b, 'blocks', block, 0.2, 0.12, 0.9, x, 0.06, 0);
	for (const [z, y] of [[-0.25, 0.12], [0.25, 0.12], [0, 0.42]]) {
		box(b, 'beams', steel, 3.0, 0.03, 0.22, 0, y + 0.015, z);
		box(b, 'beams', steel, 3.0, 0.24, 0.03, 0, y + 0.15, z);
		box(b, 'beams', steel, 3.0, 0.03, 0.22, 0, y + 0.285, z);
		box(b, 'marks', mark, 0.08, 0.2, 0.035, 0.9, y + 0.15, z);
	}
	return b.build();
}

// The blue tarp over the beams (step 5): a lumpy sheet with a stone on each corner so it doesn't fly off. Sized to
// cover the beams; its origin on the ground in the middle.
export function buildBridgeTarp() {
	const b = new Builder('bridge_tarp');
	const tarp = mat('tarp_blue', 0x2f6fb8), dark = mat('tarp_dark', 0x23558e), stone = mat('stone', 0x8a8780);
	box(b, 'tarp', tarp, 3.3, 0.04, 1.1, 0, 0.78, 0);
	for (const z of [-1, 1]) box(b, 'tarp', dark, 3.3, 0.7, 0.04, 0, 0.43, z * 0.55, [z * 0.12, 0, 0]);
	for (const x of [-1, 1]) box(b, 'tarp', dark, 0.04, 0.7, 1.1, x * 1.65, 0.43, 0, [0, 0, -x * 0.1]);
	box(b, 'tarp', tarp, 1.2, 0.08, 0.5, 0.6, 0.82, 0.1, [0, 0.2, 0.05]);
	for (const x of [-1, 1]) for (const z of [-1, 1]) b.add('stones', stone, new THREE.DodecahedronGeometry(0.11), { pos: V(x * 1.75, 0.1, z * 0.68) });
	return b.build();
}

// The invoices (step 5): a fat cardboard folder with papers sticking out, held to the tailgate with tape, the top
// one in big letters "material de primera" (the text is a Label3D in Godot). 30 x 40 cm, upright, facing +Z.
export function buildBridgeInvoices() {
	const b = new Builder('bridge_invoices');
	const card = mat('folder_card', 0xc9a66b), paper = mat('paper', 0xf4f1e6), tape = mat('tape', 0xd8d0b0), stamp = mat('stamp_red', 0xc0282a);
	box(b, 'folder', card, 0.32, 0.42, 0.03, 0, 0, 0);
	for (let i = 0; i < 4; i++) box(b, 'papers', paper, 0.28, 0.36, 0.005, (i - 1.5) * 0.012, 0.03 + i * 0.012, 0.018 + i * 0.004, [0, 0, (i - 1.5) * 0.05]);
	box(b, 'stamp', stamp, 0.12, 0.05, 0.004, 0.06, -0.1, 0.036, [0, 0, 0.3]);
	for (const x of [-1, 1]) box(b, 'tape', tape, 0.1, 0.04, 0.04, x * 0.15, 0.2, 0.01, [0, 0, x * 0.5]);
	return b.build();
}

// Pegote Hermanos' cement mixer (step 6): Remache's getaway. An orange cab in front (+Z) with a dented door, a grey
// drum lying tilted on the back with spiral fins, a chute at the back dripping cement and blobs stuck all over.
// About 2.5 x 3.2 x 7 m, its origin on the ground in the middle; the wheels are SuspectCar's (TOW_WHEELS).
export function buildCementMixer() {
	const b = new Builder('cement_mixer');
	const orange = mat('builder_orange', 0xe8873a), dent = mat('builder_dent', 0xc06a2a), darkGlass = mat('truck_glass', 0x2a3340);
	const black = mat('car_black', 0x23252b), grey = mat('car_grey', 0x6b7280), drum = mat('mixer_drum', 0xb8bcc2);
	const fin = mat('mixer_fin', 0xe8873a), cement = mat('cement', 0x9a958c), light = mat('lamp', 0xfff3c0, { emissive: 0x806a20 });
	const W = 2.3, FLOOR = 0.75;
	box(b, 'body', black, W, 0.3, 6.6, 0, FLOOR - 0.1, -0.1);
	box(b, 'body', orange, W, 1.6, 1.7, 0, FLOOR + 0.85, 2.3);
	box(b, 'body', darkGlass, W - 0.1, 0.65, 0.06, 0, FLOOR + 1.25, 3.16, [-0.15, 0, 0]);
	for (const x of [-1, 1]) box(b, 'body', darkGlass, 0.04, 0.55, 0.9, x * (W / 2 + 0.01), FLOOR + 1.25, 2.4);
	box(b, 'body', dent, 0.04, 0.35, 0.6, W / 2 + 0.02, FLOOR + 0.45, 2.4, [0, 0.1, 0.25]);
	for (const x of [-1, 1]) box(b, 'lights', light, 0.35, 0.16, 0.04, x * 0.75, FLOOR + 0.35, 3.16);
	box(b, 'body', grey, W + 0.06, 0.2, 0.16, 0, FLOOR - 0.05, 3.2);
	// The drum: two cones joined, tilted up toward the back, on a frame.
	const tilt = 0.18;
	b.add('drum', drum, new THREE.CylinderGeometry(1.0, 0.55, 2.2, 12), { pos: V(0, FLOOR + 1.45, 0.05), rot: [Math.PI / 2 + tilt, 0, 0] });
	b.add('drum', drum, new THREE.CylinderGeometry(0.45, 1.0, 1.8, 12), { pos: V(0, FLOOR + 1.75, -1.9), rot: [Math.PI / 2 + tilt, 0, 0] });
	for (let i = 0; i < 5; i++) box(b, 'fins', fin, 0.12, 0.08, 1.4, Math.cos(i * 1.3) * 0.85, FLOOR + 1.55 + Math.sin(i * 1.3) * 0.85, -0.9 + i * 0.25, [tilt, 0, i * 1.3]);
	for (const z of [0.9, -2.6]) box(b, 'frame', grey, W - 0.3, 0.9, 0.15, 0, FLOOR + 0.5, z);
	box(b, 'chute', grey, 0.4, 0.08, 1.2, 0, FLOOR + 1.0, -3.4, [-0.5, 0, 0]);
	for (const [x, y, z, r] of [[0.6, 1.9, 0.6, 0.2], [-0.7, 1.3, -0.9, 0.16], [0.2, 2.5, -1.6, 0.18], [0, 0.75, -3.9, 0.22], [-0.9, 1.0, 2.0, 0.12]]) {
		b.add('blobs', cement, new THREE.DodecahedronGeometry(r), { pos: V(x, FLOOR + y - 0.75, z) });
	}
	return b.build();
}

// A cement blob the mixer drops in the curves (step 6): a flat lumpy grey splat 2.4 m across that sticks the patrol car.
export function buildCementBlob() {
	const b = new Builder('cement_blob');
	const cement = mat('cement', 0x9a958c), wet = mat('cement_wet', 0x7f7a72);
	b.add('blob', cement, new THREE.CylinderGeometry(1.2, 1.25, 0.08, 10), { pos: V(0, 0.04, 0) });
	for (const [x, z, r] of [[0.4, 0.3, 0.35], [-0.5, -0.2, 0.3], [0.1, -0.6, 0.25], [-0.2, 0.6, 0.2]]) {
		b.add('lumps', wet, new THREE.DodecahedronGeometry(r), { pos: V(x, 0.06, z), scale: [1, 0.35, 1] });
	}
	return b.build();
}

export const models = { bridge_plank: buildPlank, builder_van: buildBuilderVan, steel_beams: buildSteelBeams,
	bridge_tarp: buildBridgeTarp, bridge_invoices: buildBridgeInvoices, cement_mixer: buildCementMixer,
	cement_blob: buildCementBlob };

export const views = {
	builder_van: {
		items: [{ name: 'builder_van', pos: [0, 0, 0], rotY: 0.6 }, { name: 'bridge_plank', pos: [2.4, 0.06, -0.5] }],
		cam: { pos: [6.5, 3.6, 6.0], target: [0, 1.0, 0], fov: 40 },
	},
	loot: {
		items: [{ name: 'steel_beams', pos: [0, 0, 0] }, { name: 'bridge_tarp', pos: [0, 0, 1.6] }, { name: 'bridge_invoices', pos: [2.0, 1.0, 0.5] }],
		cam: { pos: [2.5, 2.4, 4.5], target: [0.3, 0.4, 0.6], fov: 45 },
	},
	cement_mixer: {
		items: [{ name: 'cement_mixer', pos: [0, 0, 0], rotY: 0.7 }, { name: 'cement_blob', pos: [3.0, 0, -2.5] }],
		cam: { pos: [8.5, 4.5, 7.5], target: [0.5, 1.2, -0.5], fov: 42 },
	},
	engineer: {
		items: [{ name: 'npc_ingeniero', pos: [0, 0, 0], rotY: 0.4 }, { name: 'npc_puestero', pos: [1.3, 0, -0.4], rotY: -0.3 }],
		cam: { pos: [1.2, 1.4, 3.4], target: [0.5, 0.85, 0], fov: 36 },
	},
};
