// The Hotel Gran Siesta's people (escena-hotel.md, step 2): the guest (six alike, in bathrobe, towel turban, cucumber
// slices and slippers), don Bostezo the concierge, señora Perlita, Tito the bellboy and doña Escoba the maid with her
// laundry cart. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// A hotel guest: a white bathrobe with its belt and lapels, white slippers, a towel wrapped on the head and two
// cucumber slices on the eyes. The parts the game changes per guest have their own nodes: towel (it never comes off,
// "¡recién me lavé el pelo!"), hair (recolored, under the towel), cucumbers, glasses (under the cucumbers) and teeth
// (shown when he bites).
function huesped(b) {
	const robe = C('robe_white', 0xf4f2ee), terry = C('robe_terry', 0xdedad2);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: robe, pants: robe, belted: false, shoes: C('slipper', 0xfbfbf8) });
	b.add('body', terry, new THREE.TorusGeometry(0.47, 0.03, 4, 16), { pos: V(0, 0.52, 0), rot: [Math.PI / 2, 0, 0], scale: [1, 0.88, 1] });
	for (const s of [-1, 1]) {
		b.add('body', terry, new THREE.BoxGeometry(0.05, 0.03, 0.18), { pos: V(s * 0.06, 0.45, 0.43), rot: [0.3, 0, s * 0.3] });
		b.add('body', terry, new THREE.BoxGeometry(0.06, 0.4, 0.02), { pos: V(s * 0.09, 0.95, 0.3), rot: [-0.45, 0, s * -0.35] });
	}
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.21, 0.2) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.215, 0.205) });
	for (const s of [-1, 1]) {
		b.add('glasses', M.black, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.34, 0.19) });
		b.add('cucumbers', C('cucumber_skin', 0x3f8a3a), new THREE.CylinderGeometry(0.06, 0.06, 0.015, 10), { pos: V(s * 0.08, 1.34, 0.205), rot: [Math.PI / 2, 0, 0] });
		b.add('cucumbers', C('cucumber', 0xcfe8a8), new THREE.CylinderGeometry(0.05, 0.05, 0.004, 10), { pos: V(s * 0.08, 1.34, 0.214), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('glasses', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.345, 0.19) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.2, 0.1, 0.19, 10, 5), { pos: V(0, 1.42, -0.02) });
	const towel = C('towel', 0xf8f6f0);
	b.add('towel', towel, ellipsoid(0.23, 0.15, 0.22, 10, 6), { pos: V(0, 1.47, -0.01) });
	b.add('towel', towel, ellipsoid(0.15, 0.12, 0.15, 8, 5), { pos: V(0, 1.6, -0.05), rot: [-0.4, 0, 0] });
	b.add('towel', terry, new THREE.TorusGeometry(0.21, 0.02, 4, 14), { pos: V(0, 1.41, 0.0), rot: [Math.PI / 2 - 0.15, 0, 0] });
}

// Don Bostezo, the concierge: a wine-red jacket with gold buttons, a bow tie, droopy eyelids, his mouth open in a
// yawn and grey hair combed flat. The yawn has its own node (yawn).
function conserje(b) {
	const jacket = C('concierge_jacket', 0x7a1e2a);
	pearBody(b, mat('skin_arena', 0xd9a06b), { shirt: jacket, pants: M.black, belted: false });
	for (let i = 0; i < 3; i++) b.add('body', M.gold, new THREE.SphereGeometry(0.02, 5, 3), { pos: V(0, 0.65 + i * 0.13, 0.4 - i * 0.05) });
	for (const s of [-1, 1]) b.add('body', M.black, new THREE.ConeGeometry(0.05, 0.1, 4), { pos: V(s * 0.05, 1.14, 0.15), rot: [0, 0, s * Math.PI / 2] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	for (const s of [-1, 1]) b.add('face', C('eyelid', 0xc48a58), ellipsoid(0.055, 0.035, 0.03, 8, 4), { pos: V(s * 0.08, 1.37, 0.195) });
	b.add('yawn', C('mouth', 0x3a0a10), ellipsoid(0.045, 0.05, 0.02, 8, 5), { pos: V(0, 1.2, 0.19) });
	b.add('head', C('hair_gray', 0xb8b8bc), ellipsoid(0.205, 0.08, 0.19, 10, 5), { pos: V(0, 1.45, -0.02) });
}

// Señora Perlita: a pink dress, a white fur stole, a wide hat with a feather, big pearl earrings and a little fan.
function perlita(b) {
	const dress = C('perlita_dress', 0xf08ab8), fur = C('fur_white', 0xf6f3ec);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: dress, pants: dress, belted: false, shoes: C('perlita_shoes', 0xc0306a) });
	b.add('body', fur, new THREE.TorusGeometry(0.2, 0.07, 6, 14), { pos: V(0, 1.1, 0.02), rot: [Math.PI / 2, 0, 0] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', C('lipstick', 0xc0204a), ellipsoid(0.04, 0.018, 0.015, 8, 4), { pos: V(0, 1.21, 0.2) });
	for (const s of [-1, 1]) b.add('face', C('pearl', 0xf6f2ea), new THREE.SphereGeometry(0.03, 6, 4), { pos: V(s * 0.2, 1.25, 0.03) });
	b.add('head', C('hair_blond', 0xf0d070), ellipsoid(0.21, 0.12, 0.2, 10, 5), { pos: V(0, 1.42, -0.03) });
	const hat = C('perlita_hat', 0xc0306a);
	b.add('hat', hat, new THREE.CylinderGeometry(0.36, 0.36, 0.02, 14), { pos: V(0, 1.52, 0) });
	b.add('hat', hat, new THREE.CylinderGeometry(0.16, 0.18, 0.1, 12), { pos: V(0, 1.58, 0) });
	b.add('hat', C('feather', 0xfff2a0), ellipsoid(0.03, 0.15, 0.02, 6, 4), { pos: V(0.14, 1.7, -0.05), rot: [0, 0, -0.5] });
	b.add('props', C('fan', 0xfff0f6), new THREE.CylinderGeometry(0.12, 0.12, 0.01, 10, 1, false, 0, Math.PI), { pos: V(0.5, 0.72, 0.15), rot: [Math.PI / 2, 0, 0] });
}

// Tito, the bellboy: a red jacket with two rows of gold buttons, a little round red hat with a strap and a suitcase in
// his hand (its own node, suitcase).
function botones(b) {
	const red = C('bellboy_red', 0xd02a2a);
	pearBody(b, mat('skin_canela', 0xb8794a), { shirt: red, pants: M.black, belted: false });
	for (const s of [-1, 1]) for (let i = 0; i < 3; i++) b.add('body', M.gold, new THREE.SphereGeometry(0.018, 5, 3), { pos: V(s * 0.08, 0.66 + i * 0.13, 0.4 - i * 0.05) });
	eyes(b, 1.34, 0.17, 0.08, 0.055);
	b.add('face', M.black, new THREE.TorusGeometry(0.04, 0.01, 4, 8, Math.PI), { pos: V(0, 1.24, 0.195), rot: [0, 0, Math.PI] });
	b.add('head', C('hair_black', 0x1a1410), ellipsoid(0.205, 0.1, 0.19, 10, 5), { pos: V(0, 1.43, -0.03) });
	b.add('hat', red, new THREE.CylinderGeometry(0.1, 0.1, 0.1, 10), { pos: V(0.05, 1.53, 0), rot: [0, 0, -0.2] });
	b.add('hat', M.gold, new THREE.CylinderGeometry(0.102, 0.102, 0.02, 10), { pos: V(0.05, 1.5, 0), rot: [0, 0, -0.2] });
	const leather = C('suitcase_brown', 0x8a5a32);
	b.add('suitcase', leather, new THREE.BoxGeometry(0.16, 0.42, 0.55), { pos: V(0.6, 0.38, 0.1) });
	b.add('suitcase', M.gold, new THREE.BoxGeometry(0.04, 0.04, 0.16), { pos: V(0.6, 0.61, 0.1) });
}

// Doña Escoba, the maid: a black dress, a white apron and headband, a feather duster in one hand.
function mucama(b) {
	const dress = C('maid_black', 0x24242a);
	pearBody(b, mat('skin_arena', 0xd9a06b), { shirt: dress, pants: dress, belted: false });
	b.add('body', M.white, new THREE.BoxGeometry(0.5, 0.5, 0.04), { pos: V(0, 0.4, 0.44), rot: [-0.1, 0, 0] });
	b.add('body', M.white, new THREE.BoxGeometry(0.3, 0.2, 0.03), { pos: V(0, 0.82, 0.33), rot: [-0.45, 0, 0] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.21, 0.2) });
	b.add('head', C('hair_brown', 0x5a3a22), ellipsoid(0.21, 0.12, 0.2, 10, 5), { pos: V(0, 1.42, -0.03) });
	b.add('head', C('hair_brown', 0x5a3a22), ellipsoid(0.09, 0.09, 0.09, 8, 5), { pos: V(0, 1.47, -0.2) });
	b.add('head', M.white, new THREE.BoxGeometry(0.3, 0.05, 0.05), { pos: V(0, 1.53, 0.05), rot: [-0.3, 0, 0] });
	limb(b, 'props', C('duster_handle', 0x6a4a2a), V(-0.5, 0.65, 0.1), V(-0.55, 1.05, 0.2), 0.015);
	b.add('props', C('duster', 0xe8a0c0), ellipsoid(0.08, 0.13, 0.08, 6, 4), { pos: V(-0.56, 1.15, 0.22) });
}

// The maid's laundry cart: 1.0 x 0.6 m, a canvas bag of dirty sheets on a frame with four little wheels, a shelf of
// clean towels on top and the push bar at -Z. Its bottom at y = 0.
function buildLaundryCart() {
	const b = new Builder('laundry_cart');
	const frame = C('cart_metal', 0x9aa0a8);
	b.add('bag', C('cart_canvas', 0x5a7ab0), new THREE.BoxGeometry(0.58, 0.6, 0.95), { pos: V(0, 0.45, 0) });
	b.add('sheets', C('sheets_dirty', 0xe8e2cc), ellipsoid(0.26, 0.1, 0.42, 8, 4), { pos: V(0, 0.76, 0.05) });
	b.add('towels', C('towel', 0xf8f6f0), new THREE.BoxGeometry(0.4, 0.12, 0.3), { pos: V(0, 0.82, 0.3) });
	limb(b, 'frame', frame, V(-0.3, 0.9, -0.55), V(0.3, 0.9, -0.55), 0.015);
	for (const x of [-0.3, 0.3]) limb(b, 'frame', frame, V(x, 0.75, -0.48), V(x, 0.9, -0.55), 0.012);
	for (const x of [-0.24, 0.24]) for (const z of [-0.4, 0.4]) {
		b.add('wheels', M.black, new THREE.CylinderGeometry(0.06, 0.06, 0.04, 8), { pos: V(x, 0.06, z), rot: [0, 0, Math.PI / 2] });
	}
	return b.build();
}

const PEOPLE = { huesped, conserje, perlita, botones, mucama };

export const models = {
	...Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [`npc_${n}`, () => {
		const b = new Builder(`npc_${n}`);
		f(b);
		return b.build();
	}])),
	laundry_cart: buildLaundryCart,
};

export const views = {
	hotel_people: {
		items: [{ name: 'npc_huesped', pos: [-2.4, 0, 0], rotY: 0.3 }, { name: 'npc_huesped', pos: [-1.3, 0, 0], rotY: 0.1 },
			{ name: 'npc_conserje', pos: [-0.1, 0, 0], rotY: 0.1 }, { name: 'npc_perlita', pos: [1.1, 0, 0], rotY: -0.1 },
			{ name: 'npc_botones', pos: [2.2, 0, 0], rotY: -0.3 }, { name: 'npc_mucama', pos: [3.4, 0, 0], rotY: -0.4 },
			{ name: 'laundry_cart', pos: [4.4, 0, 0.3], rotY: -0.6 }],
		cam: { pos: [1.0, 1.5, 7.5], target: [1.0, 0.85, 0], fov: 40 },
	},
};
