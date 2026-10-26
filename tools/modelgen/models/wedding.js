// The wedding breathalyzer check (docs/diseno/control-boda.md): the convoy's ribbon bow on the hood, the cans tied
// behind, the newlyweds' "just married" board, the bride's veil and the guests' bow ties. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// A big white ribbon bow, faces +Z, origin where it sits on the hood: two loops, the knot and two tails down the hood.
export function buildWeddingBow() {
	const b = new Builder('wedding_bow');
	const ribbon = mat('wedding_ribbon', 0xfaf8f2);
	for (const x of [-1, 1]) {
		b.add('ribbon', ribbon, ellipsoid(0.2, 0.11, 0.06, 10, 6), { pos: V(x * 0.19, 0.12, 0), rot: [0, 0, x * 0.35] });
		box(b, 'ribbon', ribbon, 0.08, 0.012, 0.45, x * 0.09, 0.01, 0.22, [0, x * 0.3, 0]);
	}
	b.add('ribbon', ribbon, ellipsoid(0.07, 0.07, 0.06, 8, 6), { pos: V(0, 0.11, 0.01) });
	return b.build();
}

// The cans tied to the back bumper, trailing -Z, origin at the bumper: a string to each of four cans on the ground.
export function buildWeddingCans() {
	const b = new Builder('wedding_cans');
	const tin = mat('wedding_tin', 0xb8bcc4), string = mat('wedding_string', 0xe8e0c8);
	const ends = [[-0.45, -0.75], [-0.15, -1.0], [0.2, -0.85], [0.5, -1.1]];
	for (const [x, z] of ends) {
		const dir = new THREE.Vector3(x * 0.7, -0.33, z);
		const len = dir.length();
		const string_geo = new THREE.CylinderGeometry(0.006, 0.006, len, 4);
		string_geo.translate(0, len / 2, 0);
		const quat = new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0, 1, 0), dir.clone().normalize());
		const rot = new THREE.Euler().setFromQuaternion(quat);
		b.add('string', string, string_geo, { pos: V(x * 0.3, 0, 0), rot: [rot.x, rot.y, rot.z] });
		b.add('cans', tin, new THREE.CylinderGeometry(0.05, 0.05, 0.12, 8), { pos: V(x, -0.3, z), rot: [Math.PI / 2, 0, 0.4 * x] });
	}
	return b.build();
}

// The newlyweds' board, leaning on the rear window, faces -Z (back): white with a pink frame; the game writes on it.
export function buildJustMarried() {
	const b = new Builder('just_married');
	const board = mat('wedding_board', 0xfaf8f2), pink = mat('wedding_pink', 0xe890b0);
	box(b, 'board', board, 1.2, 0.4, 0.02, 0, 0, 0);
	box(b, 'board', pink, 1.26, 0.04, 0.025, 0, 0.21, 0);
	box(b, 'board', pink, 1.26, 0.04, 0.025, 0, -0.21, 0);
	for (const x of [-1, 1]) box(b, 'board', pink, 0.04, 0.46, 0.025, x * 0.62, 0, 0);
	return b.build();
}

// The bride's veil, in the window driver's space: a tiara on the head and the veil down the back of it.
export function buildWeddingVeil() {
	const b = new Builder('wedding_veil');
	const veil = mat('wedding_veil', 0xfdfdfb, { transparent: true, opacity: 0.85 });
	const gold = mat('wedding_gold', 0xe8c040);
	b.add('veil', gold, new THREE.TorusGeometry(0.09, 0.012, 5, 12), { pos: V(0, 0.49, 0.03), rot: [Math.PI / 2, 0, 0] });
	b.add('veil', veil, ellipsoid(0.15, 0.24, 0.07, 10, 6), { pos: V(0, 0.34, -0.1) });
	return b.build();
}

// A guest's bow tie, in the window driver's space, at the neck: 'tie' is light so the game tints it.
export function buildBowTie() {
	const b = new Builder('bow_tie');
	const tie = mat('bow_tie', 0xeeeeee);
	for (const x of [-1, 1]) b.add('tie', tie, new THREE.ConeGeometry(0.04, 0.07, 4), { pos: V(x * 0.035, 0.21, 0.085), rot: [0, 0, x * Math.PI / 2] });
	b.add('tie', tie, ellipsoid(0.014, 0.014, 0.012, 6, 4), { pos: V(0, 0.2, 0.09) });
	return b.build();
}

// The patrol car's breathalyzer, upright, faces +Z: a yellow handheld box, its dark screen ('screen', the game writes
// the reading over it), a button and the white mouthpiece on top.
export function buildBreathalyzer() {
	const b = new Builder('breathalyzer');
	const body = mat('breath_body', 0xf0c020), dark = mat('breath_screen', 0x1a2a22), white = mat('breath_tube', 0xf4f4f0);
	const red = mat('breath_button', 0xd82828);
	box(b, 'body', body, 0.07, 0.16, 0.035, 0, 0.08, 0);
	box(b, 'screen', dark, 0.05, 0.04, 0.005, 0, 0.12, 0.018);
	b.add('body', red, new THREE.CylinderGeometry(0.01, 0.01, 0.008, 8), { pos: V(0, 0.06, 0.019), rot: [Math.PI / 2, 0, 0] });
	b.add('tube', white, new THREE.CylinderGeometry(0.008, 0.008, 0.07, 8), { pos: V(0, 0.19, 0.0) });
	return b.build();
}

// El Colado's loot: a stack of white gift envelopes tied with a pink ribbon, flat, faces +Z.
export function buildGiftEnvelopes() {
	const b = new Builder('gift_envelopes');
	const paper = mat('envelope_paper', 0xfaf8f2), flap = mat('envelope_flap', 0xe8e4da), pink = mat('wedding_pink', 0xe890b0);
	for (let i = 0; i < 5; i++) {
		const y = 0.006 + i * 0.012, r = (i % 2 ? 0.12 : -0.08) * (i % 3);
		box(b, 'paper', paper, 0.22, 0.01, 0.12, 0, y, 0, [0, r, 0]);
		box(b, 'paper', flap, 0.2, 0.003, 0.05, 0, y + 0.006, -0.03, [0, r, 0]);
	}
	box(b, 'ribbon', pink, 0.03, 0.07, 0.125, 0, 0.032, 0);
	box(b, 'ribbon', pink, 0.225, 0.07, 0.03, 0, 0.032, 0);
	b.add('ribbon', pink, ellipsoid(0.04, 0.02, 0.025, 8, 5), { pos: V(-0.03, 0.072, 0), rot: [0, 0, 0.4] });
	b.add('ribbon', pink, ellipsoid(0.04, 0.02, 0.025, 8, 5), { pos: V(0.03, 0.072, 0), rot: [0, 0, -0.4] });
	return b.build();
}

export const models = { gift_envelopes: buildGiftEnvelopes, breathalyzer: buildBreathalyzer, wedding_bow: buildWeddingBow, wedding_cans: buildWeddingCans, just_married: buildJustMarried,
	wedding_veil: buildWeddingVeil, bow_tie: buildBowTie };

export const views = {
	wedding_bow: {
		items: [{ name: 'wedding_bow', pos: [0, 0, 0] }, { name: 'wedding_cans', pos: [0, 0.35, -0.4] },
			{ name: 'just_married', pos: [0, 0.6, -0.6] }],
		cam: { pos: [1.6, 1.3, 1.6], target: [0, 0.2, -0.6], fov: 40 },
	},
	breathalyzer: {
		items: [{ name: 'breathalyzer', pos: [0, 0, 0] }, { name: 'gift_envelopes', pos: [0.25, 0, 0.05] }],
		cam: { pos: [0.35, 0.35, 0.6], target: [0.12, 0.06, 0], fov: 35 },
	},
	wedding_veil: {
		items: [{ name: 'window_driver', pos: [0, 0, 0] }, { name: 'wedding_veil', pos: [0, 0, 0] },
			{ name: 'window_driver', pos: [0.5, 0, 0] }, { name: 'bow_tie', pos: [0.5, 0, 0] }],
		cam: { pos: [0.6, 0.5, 1.4], target: [0.25, 0.3, 0], fov: 35 },
	},
};
