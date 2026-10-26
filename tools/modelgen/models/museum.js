// The museum figurine (historias.md): the porcelain ballerina stolen from the museum, the souvenir copies that look
// just like it, and the newspaper clipping. Centered on their collision boxes in scenes/props/*.tscn. And the city
// museum's people (escena-museo.md, step 2): the guard (six alike), the director and the living statue. Placeholder,
// not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

// A porcelain ballerina on tiptoe: 0.12 m wide, 0.2 m tall, on a round base. The original has the museum's gold
// seal under the base, only seen when it's turned over.
function buildBallerina(name, seal) {
	const porcelain = mat('porcelain', 0xf4f1ea), pink = mat('porcelain_pink', 0xff8fb1), blue = mat('porcelain_blue', 0x3a6fd8);
	const b = new Builder(name);
	b.add('base', blue, new THREE.CylinderGeometry(0.05, 0.055, 0.02, 12), { pos: V(0, -0.09, 0) });
	b.add('body', porcelain, new THREE.CylinderGeometry(0.008, 0.008, 0.07, 6), { pos: V(0, -0.045, 0) });
	b.add('body', pink, new THREE.ConeGeometry(0.06, 0.035, 12, 1, true), { pos: V(0, 0.0, 0), rot: [Math.PI, 0, 0] });
	b.add('body', pink, new THREE.CylinderGeometry(0.06, 0.06, 0.006, 12), { pos: V(0, -0.017, 0) });
	b.add('body', porcelain, ellipsoid(0.018, 0.035, 0.014, 8, 6), { pos: V(0, 0.03, 0) });
	b.add('body', porcelain, ellipsoid(0.016, 0.018, 0.016, 8, 6), { pos: V(0, 0.08, 0) });
	b.add('body', mat('hair_bun', 0x5a3a22), ellipsoid(0.01, 0.01, 0.01, 6, 4), { pos: V(0, 0.097, -0.006) });
	for (const side of [-1, 1]) b.add('body', porcelain, new THREE.CylinderGeometry(0.004, 0.004, 0.06, 4), { pos: V(side * 0.025, 0.065, 0), rot: [0, 0, side * 0.7] });
	if (seal) b.add('seal', mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.CylinderGeometry(0.025, 0.025, 0.003, 10), { pos: V(0, -0.1015, 0) });
	return b.build();
}

// The newspaper clipping: a 0.14 x 0.18 m piece of newsprint with a headline, columns and the ballerina's photo.
export function buildNewsClipping() {
	const b = new Builder('news_clipping');
	b.add('paper', mat('newsprint', 0xe8e2cc), new THREE.BoxGeometry(0.14, 0.004, 0.18));
	b.add('ink', mat('news_ink', 0x2a2a30), new THREE.BoxGeometry(0.11, 0.002, 0.014), { pos: V(0, 0.003, -0.07) });
	b.add('photo', mat('news_photo', 0x8a8a90), new THREE.BoxGeometry(0.05, 0.002, 0.06), { pos: V(-0.035, 0.003, 0.0) });
	b.add('photo', mat('porcelain_pink', 0xff8fb1), new THREE.CylinderGeometry(0.012, 0.012, 0.002, 8), { pos: V(-0.035, 0.0045, 0.0) });
	for (let i = 0; i < 5; i++) b.add('ink', mat('news_ink', 0x2a2a30), new THREE.BoxGeometry(0.045, 0.002, 0.005), { pos: V(0.035, 0.003, -0.025 + i * 0.013) });
	for (let i = 0; i < 3; i++) b.add('ink', mat('news_ink', 0x2a2a30), new THREE.BoxGeometry(0.11, 0.002, 0.005), { pos: V(0, 0.003, 0.045 + i * 0.013) });
	return b.build();
}

const C = (name, color, opts) => mat(name, color, opts);

// The museum guard: grey uniform with a silver badge, a grey peaked cap and the same thick black mustache as the
// other five, a flashlight on the belt. The parts the game changes per guard have their own nodes: cap (taken off),
// hair (recolored, under the cap), mustache (pulled; a fake one comes off), glasses (shown or not), teeth (shown when
// he bites) and legs (the shoes, stretched to his size).
function guardia(b) {
	const uniform = C('museum_uniform', 0x7a7f88), dark = C('museum_uniform_dark', 0x4a4e56);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: uniform, pants: dark });
	b.add('body', C('silver', 0xc8ccd2), new THREE.CylinderGeometry(0.035, 0.035, 0.012, 5), { pos: V(-0.14, 0.9, 0.29), rot: [Math.PI / 2 - 0.4, 0, 0] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.205, 0.2) });
	for (const s of [-1, 1]) b.add('mustache', C('mustache_black', 0x1a1410), ellipsoid(0.07, 0.03, 0.035, 6, 4), { pos: V(s * 0.05, 1.25, 0.2), rot: [0, s * 0.4, s * -0.25] });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.42, -0.02) });
	b.add('cap', dark, new THREE.CylinderGeometry(0.21, 0.18, 0.12, 8), { pos: V(0, 1.53, 0.01) });
	b.add('cap', M.black, new THREE.CylinderGeometry(0.185, 0.185, 0.03, 8), { pos: V(0, 1.47, 0.01) });
	b.add('cap', M.black, new THREE.CylinderGeometry(0.15, 0.15, 0.02, 8, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 1.45, 0.09) });
	b.add('cap', C('silver', 0xc8ccd2), new THREE.CylinderGeometry(0.03, 0.03, 0.012, 5), { pos: V(0, 1.53, 0.21), rot: [Math.PI / 2, 0, 0] });
	for (const s of [-1, 1]) b.add('glasses', M.black, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.34, 0.215) });
	b.add('glasses', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.345, 0.215) });
	limb(b, 'props', C('flashlight', 0x2a2a30), V(0.42, 0.5, 0.22), V(0.42, 0.3, 0.26), 0.035);
}

// Señora Pincel, the museum's director: a purple suit, a pearl necklace, a grey bun and glasses on a chain.
function directora(b) {
	const suit = C('director_suit', 0x5a3a78);
	pearBody(b, mat('skin_arena', 0xd9a06b), { shirt: suit, pants: suit, belted: false, shoes: M.black });
	for (let i = 0; i < 9; i++) {
		const a = Math.PI * (0.15 + 0.7 * i / 8);
		b.add('body', C('pearl', 0xf6f2ea), new THREE.SphereGeometry(0.022, 5, 3), { pos: V(Math.cos(a) * 0.17, 1.12 - Math.sin(a) * 0.06, 0.12 + Math.sin(a) * 0.06) });
	}
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.TorusGeometry(0.04, 0.01, 4, 8, Math.PI), { pos: V(0, 1.24, 0.195), rot: [0, 0, Math.PI] });
	const hair = C('hair_gray', 0xb8b8bc);
	b.add('head', hair, ellipsoid(0.21, 0.12, 0.2, 10, 5), { pos: V(0, 1.42, -0.03) });
	b.add('head', hair, ellipsoid(0.1, 0.1, 0.1, 8, 5), { pos: V(0, 1.55, -0.1) });
	for (const s of [-1, 1]) b.add('face', M.gold, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.34, 0.205) });
	b.add('face', M.gold, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.345, 0.205) });
}

// The living statue on the museum's steps: all gold, a toga and a laurel wreath, one arm up and still, and his hat on
// the ground in front of him for the coins (its own node, hat).
function estatua(b) {
	const gilt = C('statue_gold', 0xd8b040, { emissive: 0x2a1e04 });
	pearBody(b, gilt, { shirt: gilt, pants: gilt, belted: false, shoes: gilt });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	for (let i = 0; i < 10; i++) {
		const a = Math.PI * 2 * (i / 10);
		b.add('head', C('laurel', 0x9a8a28), ellipsoid(0.05, 0.022, 0.03, 5, 3), { pos: V(Math.cos(a) * 0.205, 1.43, Math.sin(a) * 0.195 + 0.02), rot: [0, -a, 0.4] });
	}
	limb(b, 'props', gilt, V(0.3, 0.9, 0), V(0.5, 1.5, 0.1), 0.06);
	const hat = C('statue_hat', 0x2a2a30);
	b.add('hat', hat, new THREE.CylinderGeometry(0.14, 0.12, 0.12, 10, 1, true), { pos: V(0.62, 0.06, 0.25) });
	b.add('hat', hat, new THREE.CylinderGeometry(0.22, 0.22, 0.015, 12), { pos: V(0.62, 0.005, 0.25) });
}

// What was stolen from the museum (escena-museo.md, "La historia"), one per match: La Dama del Fideo (a painting in
// a gilt frame, 1.0 x 0.75 m, a lady with a noodle), the Founder's Egg (painted porcelain on a little stand) and the
// prop sword (painted cardboard, gold). Their bottoms sit at y = 0.
function buildStolenPainting() {
	const b = new Builder('museum_painting');
	const gilt = C('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	for (const [x, y, w, h] of [[0, 0.75, 1.08, 0.08], [0, 0.0, 1.08, 0.08], [-0.5, 0.375, 0.08, 0.75], [0.5, 0.375, 0.08, 0.75]]) {
		b.add('frame', gilt, new THREE.BoxGeometry(w, h, 0.06), { pos: V(x, y + 0.04, 0) });
	}
	b.add('canvas', C('canvas_green', 0x3f6a4a), new THREE.BoxGeometry(0.92, 0.67, 0.02), { pos: V(0, 0.415, 0) });
	b.add('canvas', C('lady_dress', 0x2a2a4a), ellipsoid(0.2, 0.2, 0.01, 8, 4), { pos: V(0, 0.2, 0.015) });
	b.add('canvas', mat('skin_crema', 0xf3d2b0), ellipsoid(0.09, 0.11, 0.01, 8, 4), { pos: V(0, 0.48, 0.015) });
	b.add('canvas', C('lady_hair', 0x3a2416), ellipsoid(0.12, 0.08, 0.01, 8, 4), { pos: V(0, 0.57, 0.012) });
	b.add('canvas', C('noodle', 0xf0d070), new THREE.TorusGeometry(0.05, 0.008, 4, 10, Math.PI * 1.6), { pos: V(0.02, 0.43, 0.022) });
	return b.build();
}
function buildFounderEgg() {
	const b = new Builder('founder_egg');
	b.add('stand', C('gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.CylinderGeometry(0.05, 0.07, 0.05, 10), { pos: V(0, 0.025, 0) });
	b.add('egg', C('porcelain', 0xf4f1ea), ellipsoid(0.08, 0.11, 0.08, 10, 8), { pos: V(0, 0.15, 0) });
	b.add('egg', C('porcelain_blue', 0x3a6fd8), new THREE.TorusGeometry(0.081, 0.008, 4, 14), { pos: V(0, 0.15, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('egg', C('porcelain_pink', 0xff8fb1), new THREE.TorusGeometry(0.07, 0.008, 4, 14), { pos: V(0, 0.2, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}
function buildPropSword() {
	const b = new Builder('prop_sword');
	const gilt = C('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	b.add('blade', gilt, new THREE.BoxGeometry(0.06, 0.8, 0.01), { pos: V(0, 0.55, 0) });
	b.add('guard', gilt, new THREE.BoxGeometry(0.24, 0.04, 0.03), { pos: V(0, 0.15, 0) });
	b.add('grip', C('cardboard', 0xa8845a), new THREE.CylinderGeometry(0.02, 0.02, 0.13, 6), { pos: V(0, 0.065, 0) });
	return b.build();
}

// The art transport van the culprit flees in: white with a gold stripe, a tall box behind the cab and two back doors
// that swing open to let the empty frames out. Front +Z, wheels the sedan's (SuspectCar.SEDAN_WHEELS), 2.1 x 2.3 x 4.8.
function buildArtVan() {
	const b = new Builder('art_van');
	const white = C('van_white', 0xf2f2ee), gilt = C('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	b.add('body', white, new THREE.BoxGeometry(2.0, 1.0, 1.4), { pos: V(0, 0.95, 1.6) });
	b.add('body', white, new THREE.BoxGeometry(2.1, 1.85, 3.4), { pos: V(0, 1.38, -0.7) });
	b.add('glass', C('car_glass', 0x9fd0ea), new THREE.BoxGeometry(1.8, 0.5, 0.04), { pos: V(0, 1.3, 2.31), rot: [-0.25, 0, 0] });
	b.add('stripe', gilt, new THREE.BoxGeometry(2.12, 0.18, 3.42), { pos: V(0, 1.2, -0.7) });
	b.add('doors', C('door_line', 0xb8b8b0), new THREE.BoxGeometry(0.03, 1.6, 0.02), { pos: V(0, 1.35, -2.41) });
	for (const x of [-0.5, 0.5]) b.add('doors', gilt, new THREE.BoxGeometry(0.06, 0.06, 0.04), { pos: V(x * 0.3, 1.3, -2.42) });
	for (const x of [-1.05, 1.05]) for (const z of [-1.55, 1.55]) {
		b.add('wheels', C('tire', 0x1a1a1e), new THREE.CylinderGeometry(0.38, 0.38, 0.26, 12), { pos: V(x, 0.38, z), rot: [0, 0, Math.PI / 2] });
	}
	return b.build();
}

// An empty gilt frame, as it falls out of the van and lies on the street: 1.2 x 0.9 m, flat, its bottom at y = 0.
function buildChaseFrame() {
	const b = new Builder('chase_frame');
	const gilt = C('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	for (const [x, z, w, d] of [[0, 0.45, 1.2, 0.1], [0, -0.45, 1.2, 0.1], [0.55, 0, 0.1, 0.8], [-0.55, 0, 0.1, 0.8]]) {
		b.add('frame', gilt, new THREE.BoxGeometry(w, 0.06, d), { pos: V(x, 0.03, z) });
	}
	return b.build();
}

const PEOPLE = { guardia_museo: guardia, directora_museo: directora, estatua: estatua };

export const models = {
	...Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [`npc_${n}`, () => {
		const b = new Builder(`npc_${n}`);
		f(b);
		return b.build();
	}])),
	museum_painting: buildStolenPainting, founder_egg: buildFounderEgg, prop_sword: buildPropSword,
	art_van: buildArtVan, chase_frame: buildChaseFrame,
	museum_ballerina: () => buildBallerina('museum_ballerina', true),
	ornament_ballerina: () => buildBallerina('ornament_ballerina', false),
	news_clipping: buildNewsClipping,
};

export const views = {
	museum_people: {
		items: [{ name: 'npc_directora_museo', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_guardia_museo', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_guardia_museo', pos: [1.2, 0, 0], rotY: -0.4 }, { name: 'npc_estatua', pos: [2.4, 0, 0], rotY: -0.3 }],
		cam: { pos: [0.55, 1.4, 6.0], target: [0.55, 0.85, 0], fov: 38 },
	},
	museum_loot: {
		items: [{ name: 'museum_painting', pos: [-0.5, 0, 0], rotY: 0.2 }, { name: 'founder_egg', pos: [0.35, 0, 0.2] },
			{ name: 'prop_sword', pos: [0.75, 0, 0.1], rotY: -0.3 }],
		cam: { pos: [0.1, 0.8, 2.4], target: [0.1, 0.4, 0], fov: 38 },
	},
	art_van: {
		items: [{ name: 'art_van', pos: [-0.8, 0, 0], rotY: 0.7 }, { name: 'npc_guardia_museo', pos: [-1.3, 0.4, 1.5], rotY: 0.7, scale: 0.85 },
			{ name: 'chase_frame', pos: [1.9, 0, 0.6], rotY: -0.4 }],
		cam: { pos: [0.4, 2.6, 8.0], target: [0.4, 1.0, 0], fov: 38 },
	},
	museum: {
		items: [
			{ name: 'museum_ballerina', pos: [-0.12, 0.1, 0], rotY: 0.3 }, { name: 'ornament_ballerina', pos: [0.12, 0.1, -0.05], rotY: -0.3 },
			{ name: 'news_clipping', pos: [0.0, 0.01, 0.25], rotY: 0.15 },
		],
		cam: { pos: [0, 0.45, 0.85], target: [0, 0.07, 0.05], fov: 34 },
	},
};
