// The Teatro Municipal's people (escena-teatro.md, step 2): the ghost actor (six alike in the same white sheet with two
// eye holes, white gloves and plastic chains, the embroidery on the hem), Maestro Bambalina the director (beret, red
// scarf, black turtleneck and a megaphone) and Don Susurro the prompter (small and old, half-moon glasses, a cardigan
// and the script). Faces +Z, feet at y = 0. Placeholder, not final art.
import { Builder, ellipsoid, loft, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// The ghost actor. Under the sheet, an actor in black with their own face and hair. The parts the game changes per
// ghost have their own nodes: sheet (taken off), hair (recolored, only seen without the sheet), teeth (shown when they
// bite), legs (the shoes peeking out under the hem, stretched to their size), embroidery (the patch on the hem,
// recolored to their embroidery) and glove_left and glove_right (one comes off for the fingerprints).
function fantasma(b) {
	const black = C('actor_black', 0x1e1e24), sheet = C('ghost_sheet', 0xf4f4f0), plastic = C('ghost_chain', 0x8a8a92);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: black, pants: black, belted: false, shoes: C('actor_shoes', 0x2a2018) });
	eyes(b, 1.33, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.205, 0.2) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.13, 0.19, 10, 5), { pos: V(0, 1.43, -0.03) });
	// The sheet over everything down to the shoes, with two eye holes and a wavy hem.
	b.add('sheet', sheet, loft([
		{ y: 0.14, rx: 0.56, rz: 0.5 }, { y: 0.5, rx: 0.52, rz: 0.47 }, { y: 0.9, rx: 0.42, rz: 0.38 },
		{ y: 1.15, rx: 0.3, rz: 0.28 }, { y: 1.35, rx: 0.26, rz: 0.25 }, { y: 1.52, rx: 0.19, rz: 0.18 }, { y: 1.62, rx: 0.04, rz: 0.04 },
	], 14, { capTop: true }));
	for (let i = 0; i < 10; i++) {
		const a = (i / 10) * Math.PI * 2;
		b.add('sheet', sheet, ellipsoid(0.12, 0.06, 0.12, 6, 3), { pos: V(Math.sin(a) * 0.5, 0.14, Math.cos(a) * 0.45) });
	}
	for (const s of [-1, 1]) {
		b.add('sheet', M.black, ellipsoid(0.045, 0.06, 0.02, 8, 5), { pos: V(s * 0.08, 1.36, 0.245) });
	}
	// The plastic chains hanging round the middle.
	for (let i = 0; i < 9; i++) {
		const a = -0.9 + i * 0.22;
		b.add('sheet', plastic, new THREE.TorusGeometry(0.03, 0.01, 4, 8), { pos: V(Math.sin(a) * 0.45, 0.72 - Math.abs(a) * 0.08, Math.cos(a) * 0.41), rot: [0, a + Math.PI / 2, 0] });
	}
	// The embroidery: a patch on the front of the hem.
	b.add('embroidery', C('embroidery', 0xffffff), new THREE.CylinderGeometry(0.07, 0.07, 0.015, 10), { pos: V(0.18, 0.3, 0.49), rot: [Math.PI / 2 - 0.1, 0, 0] });
	// The white gloves out of the sheet.
	for (const [s, side] of [[-1, 'left'], [1, 'right']]) {
		b.add(`glove_${side}`, M.white, ellipsoid(0.085, 0.085, 0.085, 6, 4), { pos: V(s * 0.55, 0.64, 0.12) });
	}
}

// Maestro Bambalina, the director: a black turtleneck, a long red scarf, a beret, a thin moustache and a megaphone in
// his right hand.
function bambalina(b) {
	const black = C('director_black', 0x1a1a20), red = C('director_scarf', 0xc8283a);
	pearBody(b, mat('skin_trigo', 0xe8c094), { shirt: black, pants: C('director_pants', 0x3a3a44), belted: false, shoes: M.black });
	eyes(b, 1.33, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.14, 0.015, 0.02), { pos: V(0, 1.24, 0.2) });
	b.add('face', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.02), { pos: V(0, 1.19, 0.19) });
	b.add('hair', C('director_beret', 0x2a2a3a), ellipsoid(0.24, 0.07, 0.22, 10, 5), { pos: V(0.04, 1.49, -0.01), rot: [0, 0, -0.2] });
	b.add('hair', C('director_beret', 0x2a2a3a), new THREE.CylinderGeometry(0.01, 0.01, 0.05, 4), { pos: V(0.05, 1.56, 0) });
	b.add('body', red, loft([{ y: 1.05, rx: 0.27, rz: 0.25 }, { y: 1.13, rx: 0.2, rz: 0.19 }], 10));
	b.add('body', red, new THREE.BoxGeometry(0.12, 0.6, 0.03), { pos: V(-0.12, 0.8, 0.31), rot: [-0.25, 0, 0.1] });
	// The megaphone: a white cone with a red ring, pointing out to his right from his right hand.
	b.add('props', M.white, new THREE.CylinderGeometry(0.11, 0.035, 0.32, 10), { pos: V(0.66, 0.68, 0.1), rot: [0, 0, -Math.PI / 2] });
	b.add('props', red, new THREE.TorusGeometry(0.11, 0.015, 4, 12), { pos: V(0.82, 0.68, 0.1), rot: [0, Math.PI / 2, 0] });
}

// Don Susurro, the prompter: small and old, bald with grey tufts, half-moon glasses, a brown cardigan and the rolled
// script in his hand.
function susurro(b) {
	const cardigan = C('prompter_cardigan', 0x7a5a3a);
	pearBody(b, mat('skin_rosada', 0xf0c4a8), { shirt: cardigan, pants: C('prompter_pants', 0x4a4a52), belted: false, shoes: M.black });
	eyes(b, 1.33, 0.17, 0.08, 0.04);
	for (const s of [-1, 1]) {
		b.add('face', M.gold, new THREE.TorusGeometry(0.05, 0.008, 4, 12, Math.PI), { pos: V(s * 0.08, 1.31, 0.21), rot: [0, 0, Math.PI] });
		b.add('hair', C('hair_grey', 0xd8d8dc), ellipsoid(0.06, 0.06, 0.08, 6, 4), { pos: V(s * 0.18, 1.35, -0.02) });
	}
	b.add('face', C('nose', 0xe0a090), ellipsoid(0.04, 0.035, 0.04, 6, 4), { pos: V(0, 1.27, 0.22) });
	b.add('face', M.black, new THREE.BoxGeometry(0.05, 0.01, 0.02), { pos: V(0, 1.19, 0.19) });
	// The script, rolled up in his right hand.
	b.add('props', C('script_paper', 0xf2ead8), new THREE.CylinderGeometry(0.04, 0.04, 0.3, 8), { pos: V(0.5, 0.7, 0.14), rot: [0.3, 0, 0] });
}

// The theater's scenery truck the culprit flees in (escena-teatro.md, step 7): a red cab and an open flatbed with
// cardboard scenery tied on (a painted tree, a cloud, a castle wall), the theater's two masks on the doors. Front +Z,
// 2.3 x 3.0 x 7.0, wheels at x = ±1.2, z = 2.4, -1.5 and -2.5 (SuspectCar.MIXER_WHEELS).
function sceneryTruck(b) {
	const red = C('truck_red', 0xb82830), dark = C('truck_dark', 0x30343a), card = C('scenery_card', 0xc8a070);
	b.add('body', red, new THREE.BoxGeometry(2.3, 2.0, 1.8), { pos: V(0, 1.45, 2.5) });
	b.add('body', C('car_glass', 0x9fd0ea), new THREE.BoxGeometry(2.0, 0.7, 0.04), { pos: V(0, 1.95, 3.41) });
	b.add('body', dark, new THREE.BoxGeometry(2.3, 0.25, 0.2), { pos: V(0, 0.55, 3.45) });
	b.add('body', dark, new THREE.BoxGeometry(2.3, 0.3, 5.2), { pos: V(0, 0.75, -0.9) });
	b.add('body', red, new THREE.BoxGeometry(2.3, 0.4, 0.08), { pos: V(0, 1.1, -3.46) });
	for (const sx of [-1, 1]) {
		b.add('body', red, new THREE.BoxGeometry(0.08, 0.4, 5.2), { pos: V(sx * 1.11, 1.1, -0.9) });
		// The two masks of the theater on the doors: one gold, one white.
		b.add('masks', C('mask_gold', 0xe8b830), new THREE.CylinderGeometry(0.2, 0.2, 0.03, 10), { pos: V(sx * 1.16, 1.6, 2.7), rot: [0, 0, Math.PI / 2] });
		b.add('masks', M.white, new THREE.CylinderGeometry(0.17, 0.17, 0.03, 10), { pos: V(sx * 1.16, 1.4, 2.25), rot: [0, 0, Math.PI / 2] });
	}
	// The scenery on the flatbed: a painted tree, a cloud and a castle wall, standing, tied with rope.
	b.add('scenery', C('tree_trunk', 0x6a4a2a), new THREE.BoxGeometry(0.06, 1.2, 0.3), { pos: V(-0.6, 1.5, -0.4) });
	b.add('scenery', C('tree_crown', 0x3a8a3a), new THREE.BoxGeometry(0.06, 1.0, 1.4), { pos: V(-0.6, 2.4, -0.4) });
	b.add('scenery', M.white, new THREE.BoxGeometry(0.06, 0.8, 1.6), { pos: V(0.1, 1.9, -1.6) });
	b.add('scenery', C('castle_grey', 0x9a9aa2), new THREE.BoxGeometry(0.06, 1.4, 1.8), { pos: V(0.7, 1.6, -2.4) });
	b.add('scenery', card, new THREE.BoxGeometry(2.0, 0.04, 0.04), { pos: V(0, 2.0, -1.0) });
	for (const x of [-1.2, 1.2]) for (const z of [2.4, -1.5, -2.5]) {
		b.add('wheels', C('tire', 0x1a1a1e), new THREE.CylinderGeometry(0.38, 0.38, 0.28, 12), { pos: V(x, 0.38, z), rot: [0, 0, Math.PI / 2] });
	}
}

const PEOPLE = { npc_fantasma: fantasma, npc_bambalina: bambalina, npc_susurro: susurro, scenery_truck: sceneryTruck };

export const models = Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [n, () => {
	const b = new Builder(n);
	f(b);
	return b.build();
}]));

export const views = {
	scenery_truck: {
		items: [{ name: 'scenery_truck', pos: [0, 0, 0], rotY: 0.7 }],
		cam: { pos: [0.6, 3.4, 12.0], target: [0, 1.4, 0], fov: 38 },
	},
	theater_people: {
		items: [{ name: 'npc_bambalina', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_fantasma', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_susurro', pos: [1.3, 0, 0], rotY: -0.3 }],
		cam: { pos: [0, 1.4, 6.0], target: [0, 0.85, 0], fov: 38 },
	},
};
