// The wedding crime scene (docs/diseno/escena-boda.md): the three-tier wedding cake, the flower centerpieces of the
// round tables and the DJ's booth (step 1); the six tuxedos alike, Rosa the bride, the DJ, grandma Chola and her ear
// trumpet (step 2); what was stolen: the ring in its box, the gift envelopes' box and the sugar couple (step 4).
// Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

function cylinder(b, part, m, r, h, x, y, z, segments = 16) {
	b.add(part, m, new THREE.CylinderGeometry(r, r, h, segments), { pos: V(x, y, z) });
}

// The three-tier wedding cake on its silver stand, origin at the bottom of the stand: white tiers ('cake'), a pink
// ribbon around each and a row of frosting pearls on each rim. 0.95 m tall; the sugar couple goes on top.
export function buildWeddingCake() {
	const b = new Builder('wedding_cake');
	const cake = mat('wedding_cake_icing', 0xfbf8f0), ribbon = mat('wedding_cake_ribbon', 0xeea8c0);
	const silver = mat('wedding_cake_stand', 0xc8ccd4, { metalness: 0.3, roughness: 0.4 });
	cylinder(b, 'stand', silver, 0.48, 0.03, 0, 0.015, 0, 24);
	cylinder(b, 'stand', silver, 0.08, 0.12, 0, 0.09, 0, 12);
	cylinder(b, 'stand', silver, 0.46, 0.02, 0, 0.16, 0, 24);
	const tiers = [[0.42, 0.28], [0.31, 0.24], [0.2, 0.22]];
	let y = 0.17;
	for (const [r, h] of tiers) {
		cylinder(b, 'cake', cake, r, h, 0, y + h / 2, 0, 24);
		cylinder(b, 'ribbon', ribbon, r + 0.005, 0.04, 0, y + 0.06, 0, 24);
		const pearls = Math.round(r * 40);
		for (let i = 0; i < pearls; i++) {
			const a = (i / pearls) * Math.PI * 2;
			b.add('cake', cake, ellipsoid(0.022, 0.022, 0.022, 6, 4), { pos: V(Math.sin(a) * r, y + h, Math.cos(a) * r) });
		}
		y += h;
	}
	return b.build();
}

// A round table's centerpiece, origin at its base: a low glass vase and a ball of roses (red, pink and white) with
// leaves. 0.4 m tall.
export function buildFlowerCenterpiece() {
	const b = new Builder('flower_centerpiece');
	const glass = mat('centerpiece_glass', 0xd8eef0, { transparent: true, opacity: 0.6 });
	const leaf = mat('centerpiece_leaf', 0x3f8a3a);
	const roses = [mat('centerpiece_red', 0xd02840), mat('centerpiece_pink', 0xf0a0b8), mat('centerpiece_white', 0xfaf6ee)];
	b.add('vase', glass, new THREE.CylinderGeometry(0.09, 0.07, 0.14, 12), { pos: V(0, 0.07, 0) });
	for (let i = 0; i < 6; i++) {
		const a = (i / 6) * Math.PI * 2;
		b.add('flowers', leaf, ellipsoid(0.08, 0.025, 0.04, 6, 4), { pos: V(Math.sin(a) * 0.12, 0.17, Math.cos(a) * 0.12), rot: [0, a, 0.3] });
	}
	const spots = [[0, 0.3, 0], [0.09, 0.24, 0.05], [-0.08, 0.25, 0.06], [0.05, 0.25, -0.09], [-0.07, 0.23, -0.06],
		[0.12, 0.19, -0.02], [-0.12, 0.19, 0.01], [0.0, 0.2, 0.12], [0.02, 0.2, -0.13]];
	spots.forEach(([x, yy, z], i) => {
		b.add('flowers', roses[i % 3], ellipsoid(0.055, 0.05, 0.055, 8, 6), { pos: V(x, yy, z) });
	});
	return b.build();
}

// The DJ's booth, faces +Z (the dance floor), origin on the floor at its middle: a black desk with a lit "DJ" panel
// ('panel', the game writes over it), two turntables and the mixer on top, and a tall speaker on each side.
export function buildDjBooth() {
	const b = new Builder('dj_booth');
	const black = mat('dj_black', 0x1c1c22), panel = mat('dj_panel', 0x8040c0), grey = mat('dj_grey', 0x50545c);
	const vinyl = mat('dj_vinyl', 0x101012), cone = mat('dj_cone', 0x30323a);
	box(b, 'desk', black, 1.6, 1.0, 0.6, 0, 0.5, 0);
	box(b, 'panel', panel, 1.0, 0.4, 0.01, 0, 0.6, 0.305);
	for (const x of [-0.5, 0.5]) {
		box(b, 'deck', grey, 0.4, 0.04, 0.4, x, 1.02, 0);
		cylinder(b, 'deck', vinyl, 0.16, 0.01, x, 1.045, 0, 20);
	}
	box(b, 'deck', grey, 0.3, 0.06, 0.3, 0, 1.03, 0);
	for (const x of [-1.05, 1.05]) {
		box(b, 'speaker', black, 0.45, 1.4, 0.45, x, 0.7, 0);
		for (const [y, r] of [[1.1, 0.1], [0.55, 0.17]]) {
			b.add('speaker', cone, new THREE.CylinderGeometry(r, r, 0.02, 16), { pos: V(x, y, 0.23), rot: [Math.PI / 2, 0, 0] });
		}
	}
	return b.build();
}

// Tito and his five groomsmen: the same rented black tuxedo with a white shirt front, a bow tie, a top hat and slicked
// hair. The parts the game changes per suspect have their own nodes: hat (taken off), hair (recolored, under the hat),
// carnation (white for Tito, tinted red for the groomsmen), glasses (shown or not), teeth (shown when he bites) and
// legs (the rented shoes, stretched to his size).
function tuxedo(b) {
	const black = mat('tux_black', 0x18181e), shirt = mat('tux_shirt', 0xf6f4ee);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: black, pants: black, belted: false, shoes: mat('tux_shoes', 0x0c0c0e, { roughness: 0.25 }) });
	b.add('body', shirt, new THREE.BoxGeometry(0.16, 0.3, 0.02), { pos: V(0, 0.95, 0.3), rot: [-0.35, 0, 0] });
	for (const s of [-1, 1]) b.add('body', M.black, new THREE.ConeGeometry(0.035, 0.07, 4), { pos: V(s * 0.035, 1.1, 0.24), rot: [0, 0, s * Math.PI / 2] });
	b.add('carnation', mat('carnation', 0xffffff), ellipsoid(0.045, 0.045, 0.035, 8, 5), { pos: V(-0.17, 0.98, 0.27) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.22, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.225, 0.2) });
	b.add('hair', mat('hair', 0xffffff, { roughness: 0.2 }), ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.42, -0.02) });
	b.add('hat', M.black, new THREE.CylinderGeometry(0.15, 0.16, 0.24, 10), { pos: V(0, 1.6, 0) });
	b.add('hat', M.black, new THREE.CylinderGeometry(0.25, 0.25, 0.02, 12), { pos: V(0, 1.48, 0) });
	b.add('hat', mat('hat_band', 0x50505a), new THREE.CylinderGeometry(0.162, 0.162, 0.04, 10), { pos: V(0, 1.51, 0) });
	for (const s of [-1, 1]) b.add('glasses', M.black, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.34, 0.215) });
	b.add('glasses', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.345, 0.215) });
}

// Rosa, the bride: a long white dress to the floor, a veil from a tiara down her back, a brown bun and her bouquet in
// front of her (its own node, bouquet: she throws it).
function novia(b) {
	const dress = mat('bride_dress', 0xfbfaf6);
	pearBody(b, mat('skin_miel', 0xe8b48a), { shirt: dress, pants: dress, belted: false, shoes: dress });
	b.add('body', dress, ellipsoid(0.56, 0.14, 0.5, 12, 4), { pos: V(0, 0.08, 0) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', mat('lipstick', 0xd03850), new THREE.TorusGeometry(0.035, 0.01, 4, 8, Math.PI), { pos: V(0, 1.24, 0.195), rot: [0, 0, Math.PI] });
	const hair = mat('hair_brown', 0x6a3e20);
	b.add('head', hair, ellipsoid(0.21, 0.12, 0.2, 10, 5), { pos: V(0, 1.42, -0.03) });
	b.add('head', hair, ellipsoid(0.1, 0.1, 0.1, 8, 5), { pos: V(0, 1.53, -0.13) });
	b.add('veil', mat('wedding_gold', 0xe8c040), new THREE.TorusGeometry(0.13, 0.012, 5, 12), { pos: V(0, 1.5, 0.01), rot: [Math.PI / 2, 0, 0] });
	b.add('veil', mat('bride_veil', 0xfdfdfb, { transparent: true, opacity: 0.8 }), ellipsoid(0.22, 0.45, 0.1, 10, 6), { pos: V(0, 1.15, -0.2) });
	const roses = [mat('bouquet_white', 0xfaf6ee), mat('bouquet_pink', 0xf0a0b8)];
	b.add('bouquet', mat('bouquet_stem', 0x3f8a3a), new THREE.CylinderGeometry(0.03, 0.02, 0.18, 6), { pos: V(0, 0.62, 0.42) });
	[[0, 0.75, 0.44], [0.06, 0.73, 0.44], [-0.06, 0.73, 0.44], [0.03, 0.78, 0.4], [-0.03, 0.78, 0.48]].forEach(([x, y, z], i) => {
		b.add('bouquet', roses[i % 2], ellipsoid(0.045, 0.04, 0.045, 6, 4), { pos: V(x, y, z) });
	});
}

// DJ Bombo: a purple shirt with yellow lightning, big headphones and sunglasses.
function dj(b) {
	pearBody(b, mat('skin_cacao', 0x8a5a3a), { shirt: mat('dj_shirt', 0x7a30b0), pants: mat('dj_pants', 0x202028), belted: false });
	b.add('body', mat('dj_bolt', 0xf0d020), new THREE.BoxGeometry(0.06, 0.2, 0.02), { pos: V(0, 0.85, 0.36), rot: [0, 0, 0.5] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.24, 0.07, 0.03), { pos: V(0, 1.34, 0.2) });
	b.add('face', M.black, new THREE.TorusGeometry(0.035, 0.01, 4, 8, Math.PI), { pos: V(0, 1.23, 0.195), rot: [0, 0, Math.PI] });
	const phones = mat('dj_phones', 0x30303a);
	b.add('head', phones, new THREE.TorusGeometry(0.22, 0.02, 4, 12, Math.PI), { pos: V(0, 1.32, 0.0) });
	for (const s of [-1, 1]) b.add('head', phones, new THREE.CylinderGeometry(0.07, 0.07, 0.05, 10), { pos: V(s * 0.21, 1.3, 0), rot: [0, 0, Math.PI / 2] });
}

// Grandma Chola: a lilac cardigan over a grey skirt, white curls, round glasses and a brooch. Half deaf.
function abuela(b) {
	pearBody(b, mat('skin_rosa_viejo', 0xf0c8b4), { shirt: mat('grandma_cardigan', 0xb8a0d8), pants: mat('grandma_skirt', 0x707078), belted: false });
	b.add('body', mat('wedding_gold', 0xe8c040), ellipsoid(0.03, 0.03, 0.015, 6, 4), { pos: V(0.12, 1.0, 0.25) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.TorusGeometry(0.03, 0.008, 4, 8, Math.PI), { pos: V(0, 1.24, 0.195), rot: [0, 0, Math.PI] });
	const curls = mat('hair_white', 0xf0f0f4);
	for (let i = 0; i < 9; i++) {
		const a = Math.PI * 2 * (i / 9);
		b.add('head', curls, ellipsoid(0.07, 0.07, 0.07, 6, 4), { pos: V(Math.cos(a) * 0.15, 1.46 + (i % 2) * 0.03, Math.sin(a) * 0.14 - 0.02) });
	}
	b.add('head', curls, ellipsoid(0.12, 0.08, 0.12, 8, 5), { pos: V(0, 1.52, -0.02) });
	for (const s of [-1, 1]) b.add('face', mat('grandma_frames', 0xb08040), new THREE.TorusGeometry(0.05, 0.008, 4, 10), { pos: V(s * 0.08, 1.34, 0.21) });
}

// Grandma's brass ear trumpet, lying on its side on the table, the bell toward +Z; origin under its middle.
export function buildEarTrumpet() {
	const b = new Builder('ear_trumpet');
	const brass = mat('trumpet_brass', 0xd0a040, { metalness: 0.4, roughness: 0.35 });
	b.add('trumpet', brass, new THREE.CylinderGeometry(0.13, 0.02, 0.32, 14, 1, true), { pos: V(0, 0.13, 0.06), rot: [Math.PI / 2, 0, 0] });
	b.add('trumpet', brass, new THREE.CylinderGeometry(0.02, 0.015, 0.14, 8), { pos: V(0, 0.13, -0.16), rot: [Math.PI / 2, 0, 0] });
	b.add('trumpet', brass, new THREE.TorusGeometry(0.13, 0.01, 4, 16), { pos: V(0, 0.13, 0.22) });
	return b.build();
}

// The ring's velvet box with its lid open and the gold ring in the slot ('ring': hidden when the box is the empty one
// on the head table). Origin at its bottom; 6 cm wide.
export function buildRingBox() {
	const b = new Builder('wedding_ring_box');
	const velvet = mat('ring_velvet', 0xa01830), gold = mat('wedding_gold', 0xe8c040, { metalness: 0.5, roughness: 0.3 });
	box(b, 'box', velvet, 0.06, 0.035, 0.06, 0, 0.0175, 0);
	box(b, 'box', velvet, 0.06, 0.035, 0.012, 0, 0.06, -0.035, [-0.4, 0, 0]);
	box(b, 'box', mat('ring_satin', 0xf6f0e6), 0.05, 0.004, 0.05, 0, 0.036, 0);
	b.add('ring', gold, new THREE.TorusGeometry(0.014, 0.004, 6, 14), { pos: V(0, 0.05, 0.005) });
	b.add('ring', mat('ring_stone', 0xd8f0ff, { metalness: 0.2, roughness: 0.05 }), ellipsoid(0.005, 0.005, 0.005, 6, 4), { pos: V(0, 0.066, 0.005) });
	return b.build();
}

// The gift envelopes' box (the urn): a white box with a slot on top, a pink bow and a few envelopes peeking out.
// Origin at its bottom; 30 cm.
export function buildGiftUrn() {
	const b = new Builder('gift_urn');
	const white = mat('gift_box', 0xfbfaf6), pink = mat('wedding_cake_ribbon', 0xeea8c0);
	box(b, 'box', white, 0.3, 0.3, 0.3, 0, 0.15, 0);
	box(b, 'box', M.black, 0.16, 0.005, 0.02, 0, 0.301, 0);
	box(b, 'box', pink, 0.31, 0.04, 0.31, 0, 0.2, 0);
	b.add('box', pink, ellipsoid(0.06, 0.04, 0.03, 8, 5), { pos: V(-0.05, 0.24, 0.16) });
	b.add('box', pink, ellipsoid(0.06, 0.04, 0.03, 8, 5), { pos: V(0.05, 0.24, 0.16) });
	const paper = mat('envelope', 0xf2e8d0);
	[[-0.03, -0.1], [0.02, 0.15], [0.05, -0.05]].forEach(([x, tilt]) => box(b, 'envelopes', paper, 0.12, 0.08, 0.004, x, 0.33, 0, [0, 0, tilt]));
	return b.build();
}

// The sugar couple from the top of the cake (grandma's): a tiny bride and groom on a round base. Origin at its bottom;
// 14 cm tall.
export function buildSugarCouple() {
	const b = new Builder('sugar_couple');
	const sugar = mat('sugar', 0xfdfaf2), black = mat('tux_black', 0x18181e), skin = mat('sugar_skin', 0xf3d6c0);
	cylinder(b, 'base', mat('wedding_cake_stand', 0xc8ccd4, { metalness: 0.3, roughness: 0.4 }), 0.06, 0.012, 0, 0.006, 0);
	b.add('bride', sugar, new THREE.ConeGeometry(0.03, 0.08, 10), { pos: V(-0.025, 0.052, 0) });
	b.add('bride', skin, ellipsoid(0.015, 0.016, 0.015, 8, 5), { pos: V(-0.025, 0.105, 0) });
	b.add('groom', black, new THREE.CylinderGeometry(0.018, 0.024, 0.08, 10), { pos: V(0.025, 0.052, 0) });
	b.add('groom', skin, ellipsoid(0.015, 0.016, 0.015, 8, 5), { pos: V(0.025, 0.105, 0) });
	b.add('groom', black, new THREE.CylinderGeometry(0.01, 0.011, 0.02, 8), { pos: V(0.025, 0.128, 0) });
	return b.build();
}

const PEOPLE = { tuxedo, novia, dj_bombo: dj, abuela_chola: abuela };

export const models = {
	...Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [`npc_${n}`, () => {
		const b = new Builder(`npc_${n}`);
		f(b);
		return b.build();
	}])),
	wedding_cake: buildWeddingCake, flower_centerpiece: buildFlowerCenterpiece, dj_booth: buildDjBooth,
	ear_trumpet: buildEarTrumpet, wedding_ring_box: buildRingBox, gift_urn: buildGiftUrn,
	sugar_couple: buildSugarCouple,
};

export const views = {
	wedding_cake: {
		items: [{ name: 'wedding_cake', pos: [0, 0, 0] }, { name: 'flower_centerpiece', pos: [0.75, 0, 0.2] }],
		cam: { pos: [1.4, 1.1, 1.8], target: [0.3, 0.45, 0], fov: 40 },
	},
	wedding_people: {
		items: [{ name: 'npc_novia', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_tuxedo', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_tuxedo', pos: [1.2, 0, 0], rotY: -0.3 }, { name: 'npc_abuela_chola', pos: [2.4, 0, 0], rotY: -0.3 },
			{ name: 'npc_dj_bombo', pos: [3.6, 0, 0], rotY: -0.4 }, { name: 'ear_trumpet', pos: [2.6, 0, 0.8], rotY: 0.5 }],
		cam: { pos: [1.15, 1.4, 6.2], target: [1.15, 0.85, 0], fov: 40 },
	},
	wedding_loot: {
		items: [{ name: 'wedding_ring_box', pos: [-0.32, 0, 0], rotY: 0.3 }, { name: 'gift_urn', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'sugar_couple', pos: [0.32, 0, 0], rotY: -0.3 }],
		cam: { pos: [0, 0.5, 1.1], target: [0, 0.12, 0], fov: 40 },
	},
	dj_booth: {
		items: [{ name: 'dj_booth', pos: [0, 0, 0] }],
		cam: { pos: [1.8, 1.8, 3.0], target: [0, 0.7, 0], fov: 40 },
	},
};
