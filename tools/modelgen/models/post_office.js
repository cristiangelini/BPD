// The Correo Central's people (escena-correo.md, step 2): the mail carrier (six alike in the post office's uniform: blue
// shirt, yellow vest, cap with a visor, leather bag across the chest and gloves), Doña Sellito the postmaster (grey
// bun, glasses on a chain, a cardigan and a big rubber stamp in her hand) and Cartita, the green parrot on its perch.
// Faces +Z, feet at y = 0. Placeholder, not final art.
import { Builder, ellipsoid, loft, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// The mail carrier. The parts the game changes per carrier have their own nodes: cap (taken off), hair (recolored,
// under the cap), teeth (shown when they bite), tongue (shown when they stick it out, recolored blue or pink), legs
// (the shoes, stretched to their size) and tag (the route's label on the bag, recolored to their route).
function cartero(b) {
	const shirt = C('post_shirt', 0x3a64b8), pants = C('post_pants', 0x2a3550), vest = C('post_vest', 0xf2d23a);
	const leather = C('post_leather', 0x7a4a24), blue = C('post_cap', 0x2a4a9a);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt, pants, belted: false, shoes: C('post_shoes', 0x2a2018) });
	// The yellow vest over the shirt, open at the neck, with a reflective stripe.
	b.add('body', vest, loft([{ y: 0.56, rx: 0.47, rz: 0.42 }, { y: 0.8, rx: 0.375, rz: 0.335 }, { y: 1.02, rx: 0.26, rz: 0.24 }], 12));
	b.add('body', C('reflective', 0xdfe4ea, { metalness: 0.4, roughness: 0.3 }), loft([{ y: 0.68, rx: 0.435, rz: 0.39 }, { y: 0.72, rx: 0.42, rz: 0.375 }], 12));
	// The leather bag across the chest: the strap from the right shoulder and the bag on the left hip, with its tag.
	limb(b, 'body', leather, V(0.22, 1.05, 0.12), V(-0.3, 0.55, 0.3), 0.025, 4);
	b.add('body', leather, new THREE.BoxGeometry(0.34, 0.26, 0.12), { pos: V(-0.36, 0.5, 0.26), rot: [0, 0.5, 0] });
	b.add('body', leather, new THREE.BoxGeometry(0.34, 0.1, 0.13), { pos: V(-0.36, 0.6, 0.27), rot: [0.2, 0.5, 0] });
	b.add('tag', C('post_tag', 0xffffff), new THREE.BoxGeometry(0.1, 0.07, 0.01), { pos: V(-0.3, 0.47, 0.35), rot: [0, 0.5, 0] });
	eyes(b, 1.31, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.205, 0.2) });
	b.add('tongue', C('post_tongue', 0xffffff), ellipsoid(0.035, 0.012, 0.05, 6, 3), { pos: V(0, 1.18, 0.22) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.2, 0.12, 0.18, 10, 5), { pos: V(0, 1.43, -0.04) });
	// The cap with its visor and the post horn badge.
	b.add('cap', blue, new THREE.CylinderGeometry(0.21, 0.2, 0.13, 10), { pos: V(0, 1.5, 0.0) });
	b.add('cap', blue, new THREE.CylinderGeometry(0.16, 0.16, 0.02, 10, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 1.44, 0.1) });
	b.add('cap', M.gold, new THREE.TorusGeometry(0.03, 0.01, 4, 8), { pos: V(0, 1.51, 0.21) });
	// The gloves.
	for (const [s, side] of [[-1, 'left'], [1, 'right']]) {
		b.add(`glove_${side}`, C('post_glove', 0x6a4a30), ellipsoid(0.085, 0.085, 0.085, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	}
}

// Doña Sellito, the postmaster: a grey bun, glasses on a chain, a long green cardigan over a white blouse and a big
// rubber stamp in her right hand.
function sellito(b) {
	const cardigan = C('sellito_cardigan', 0x3f7a52);
	pearBody(b, mat('skin_rosada', 0xf0c4a8), { shirt: cardigan, pants: C('sellito_skirt', 0x4a3a4a), belted: false, shoes: M.black });
	b.add('body', M.white, new THREE.BoxGeometry(0.2, 0.3, 0.05), { pos: V(0, 0.92, 0.3), rot: [-0.25, 0, 0] });
	eyes(b, 1.33, 0.17, 0.08, 0.045);
	for (const s of [-1, 1]) b.add('face', M.black, new THREE.TorusGeometry(0.06, 0.01, 4, 12), { pos: V(s * 0.08, 1.33, 0.21) });
	b.add('face', M.black, new THREE.BoxGeometry(0.05, 0.01, 0.01), { pos: V(0, 1.33, 0.22) });
	limb(b, 'face', M.gold, V(-0.14, 1.32, 0.2), V(0, 1.05, 0.24), 0.006, 4);
	limb(b, 'face', M.gold, V(0.14, 1.32, 0.2), V(0, 1.05, 0.24), 0.006, 4);
	b.add('face', C('lips', 0xc84a5a), ellipsoid(0.04, 0.02, 0.02, 6, 3), { pos: V(0, 1.2, 0.195) });
	const grey = C('hair_grey', 0xd8d8dc);
	b.add('hair', grey, ellipsoid(0.21, 0.12, 0.2, 10, 5), { pos: V(0, 1.42, -0.03) });
	b.add('hair', grey, ellipsoid(0.1, 0.1, 0.1, 8, 5), { pos: V(0, 1.55, -0.1) });
	// The rubber stamp: a wooden handle and a red rubber foot.
	b.add('props', C('stamp_wood', 0x8a5a2a), new THREE.CylinderGeometry(0.035, 0.045, 0.14, 8), { pos: V(0.52, 0.76, 0.12) });
	b.add('props', C('stamp_rubber', 0xc8303a), new THREE.BoxGeometry(0.14, 0.04, 0.1), { pos: V(0.52, 0.66, 0.12) });
}

// Cartita, the parrot: green with a yellow head, red wings' tips and a big hooked beak, on a little wooden perch (the
// model's base). Its parts: body, head (with the beak and eyes), wing_left and wing_right (spread when it shouts),
// tail and perch. About 0.6 m tall with the perch.
function loro(b) {
	const green = C('parrot_green', 0x3ab84a), yellow = C('parrot_yellow', 0xf2d23a), red = C('parrot_red', 0xd83a3a);
	const wood = C('perch_wood', 0x8a5a2a);
	b.add('perch', wood, new THREE.CylinderGeometry(0.12, 0.14, 0.03, 10), { pos: V(0, 0.015, 0) });
	b.add('perch', wood, new THREE.CylinderGeometry(0.018, 0.018, 0.26, 6), { pos: V(0, 0.15, 0) });
	b.add('perch', wood, new THREE.CylinderGeometry(0.015, 0.015, 0.3, 6), { pos: V(0, 0.28, 0), rot: [0, 0, Math.PI / 2] });
	b.add('body', green, ellipsoid(0.09, 0.14, 0.09, 10, 6), { pos: V(0, 0.4, 0), rot: [0.25, 0, 0] });
	b.add('head', yellow, ellipsoid(0.075, 0.075, 0.075, 10, 6), { pos: V(0, 0.56, 0.04) });
	b.add('head', C('beak', 0x3a3a3a), new THREE.ConeGeometry(0.03, 0.07, 6), { pos: V(0, 0.54, 0.12), rot: [Math.PI / 2 + 0.6, 0, 0] });
	for (const s of [-1, 1]) {
		b.add('head', M.white, ellipsoid(0.018, 0.018, 0.01, 6, 4), { pos: V(s * 0.045, 0.575, 0.085) });
		b.add('head', M.black, ellipsoid(0.009, 0.009, 0.006, 5, 3), { pos: V(s * 0.047, 0.576, 0.093) });
		const side = s < 0 ? 'left' : 'right';
		b.add(`wing_${side}`, green, ellipsoid(0.03, 0.11, 0.07, 8, 5), { pos: V(s * 0.085, 0.4, -0.01), rot: [0.3, 0, 0] });
		b.add(`wing_${side}`, red, ellipsoid(0.025, 0.04, 0.04, 6, 3), { pos: V(s * 0.087, 0.3, -0.05) });
		b.add('body', C('parrot_feet', 0x8a8a8a), ellipsoid(0.02, 0.015, 0.03, 5, 3), { pos: V(s * 0.03, 0.29, 0.02) });
	}
	b.add('tail', green, new THREE.BoxGeometry(0.06, 0.2, 0.02), { pos: V(0, 0.22, -0.09), rot: [-0.35, 0, 0] });
	b.add('tail', red, new THREE.BoxGeometry(0.06, 0.05, 0.021), { pos: V(0, 0.12, -0.125), rot: [-0.35, 0, 0] });
}

const PEOPLE = { npc_postal: cartero, npc_sellito: sellito, npc_loro: loro };

export const models = Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [n, () => {
	const b = new Builder(n);
	f(b);
	return b.build();
}]));

export const views = {
	post_office_people: {
		items: [{ name: 'npc_sellito', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_postal', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_loro', pos: [1.1, 0.6, 0], rotY: -0.4 }],
		cam: { pos: [0, 1.4, 6.0], target: [0, 0.85, 0], fov: 38 },
	},
};
