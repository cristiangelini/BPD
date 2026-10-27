// The Municipal Library's people (escena-biblioteca.md, step 2): the reader (six alike in the reading club's striped
// pajamas with a mouse on the chest, a nightcap with a pompom, a sleep mask up on the forehead and slippers), Doña
// Sigilo the librarian (cardigan, bun, glasses on a chain and her feather duster) and Tomasito, the boy asleep in the
// children's corner. Faces +Z, feet at y = 0. Placeholder, not final art.
import { Builder, loft, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// The pear body's outline (pear.js), to wrap stripes around it.
const OUTLINE = [[0.1, 0.36, 0.32], [0.3, 0.48, 0.43], [0.5, 0.46, 0.41], [0.8, 0.36, 0.32], [1.05, 0.24, 0.22]];

function widthAt(y) {
	for (let i = 1; i < OUTLINE.length; i++) {
		const [y0, x0, z0] = OUTLINE[i - 1], [y1, x1, z1] = OUTLINE[i];
		if (y <= y1) {
			const t = (y - y0) / (y1 - y0);
			return [x0 + (x1 - x0) * t, z0 + (z1 - z0) * t];
		}
	}
	return OUTLINE[OUTLINE.length - 1].slice(1);
}

// Horizontal stripes around the body every `step`, from `from` to `to`.
function stripes(b, m, from, to, step) {
	for (let y = from; y < to; y += step) {
		const [rx, rz] = widthAt(y + 0.02);
		b.add('body', m, loft([{ y, rx: rx + 0.006, rz: rz + 0.006 }, { y: y + 0.04, rx: rx + 0.006, rz: rz + 0.006 }], 10));
	}
}

// A nightcap that flops to one side, with its pompom.
function nightcap(b, part, m, pompom, y) {
	b.add(part, m, ellipsoid(0.215, 0.12, 0.205, 10, 6), { pos: V(0, y, 0) });
	b.add(part, m, new THREE.ConeGeometry(0.15, 0.4, 8), { pos: V(0.12, y + 0.16, -0.04), rot: [0, 0, -1.0] });
	b.add(part, pompom, new THREE.SphereGeometry(0.06, 6, 4), { pos: V(0.3, y + 0.27, -0.04) });
}

// The reader. The parts the game changes per reader have their own nodes: nightcap (taken off), hair (recolored,
// under the cap), glasses (shown or not), teeth (shown when they bite), legs (the slippers, stretched to their size),
// mask (the sleep mask up on the forehead), the gold dust on each hand (dust_left, dust_right: shown under the
// flashlight in step 3) and the book in their hands.
function lector(b) {
	const pajama = C('club_pajama', 0x8fb4e8), stripe = C('club_stripe', 0xf4f0e6), cap = C('club_cap', 0x3d5ca8);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: pajama, pants: pajama, belted: false, shoes: C('club_slipper', 0x8a5a3c) });
	stripes(b, stripe, 0.16, 1.0, 0.12);
	// The mouse embroidered on the chest: a grey face with two round ears and a pink nose.
	const grey = C('club_mouse', 0x9a9aa2);
	b.add('body', grey, ellipsoid(0.08, 0.07, 0.03, 8, 5), { pos: V(0, 0.82, 0.33) });
	for (const s of [-1, 1]) b.add('body', grey, ellipsoid(0.045, 0.045, 0.015, 6, 4), { pos: V(s * 0.07, 0.89, 0.32) });
	b.add('body', C('club_mouse_nose', 0xf08aa8), new THREE.SphereGeometry(0.014, 5, 3), { pos: V(0, 0.81, 0.365) });
	// Slipper pompoms.
	for (const s of [-1, 1]) b.add('legs', stripe, new THREE.SphereGeometry(0.05, 6, 4), { pos: V(s * 0.2, 0.13, 0.28) });
	eyes(b, 1.33, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.22, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.225, 0.2) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.41, -0.02) });
	nightcap(b, 'nightcap', cap, stripe, 1.47);
	// The sleep mask up on the forehead, under the cap's rim.
	b.add('mask', C('club_mask', 0x2a2a3a), new THREE.BoxGeometry(0.3, 0.06, 0.05), { pos: V(0, 1.41, 0.17) });
	for (const s of [-1, 1]) b.add('glasses', M.black, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.33, 0.215) });
	b.add('glasses', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.335, 0.215) });
	// The book held open in front, at the hands.
	const cover = C('club_book', 0x6b3a22);
	b.add('book', cover, new THREE.BoxGeometry(0.26, 0.02, 0.2), { pos: V(-0.12, 0.66, 0.46), rot: [0, 0, 0.25] });
	b.add('book', cover, new THREE.BoxGeometry(0.26, 0.02, 0.2), { pos: V(0.12, 0.66, 0.46), rot: [0, 0, -0.25] });
	b.add('book', M.white, new THREE.BoxGeometry(0.44, 0.03, 0.18), { pos: V(0, 0.69, 0.46) });
	// The gold dust from the Golden Book's covers, glittering on each hand.
	const dust = C('gold_dust', 0xffd84a, { emissive: 0x7a5a00 });
	for (const [s, side] of [[-1, 'left'], [1, 'right']]) {
		for (let i = 0; i < 5; i++) {
			const a = i * 1.3;
			b.add(`dust_${side}`, dust, new THREE.OctahedronGeometry(0.014), { pos: V(s * (0.49 + Math.cos(a) * 0.05), 0.66 + Math.sin(a) * 0.04, 0.15 + (i % 2) * 0.02) });
		}
	}
}

// Doña Sigilo: a long plum cardigan with big buttons, a grey bun, glasses on a chain, a key ring at the waist and her
// feather duster.
function sigilo(b) {
	const cardigan = C('sigilo_cardigan', 0x7a3a5e), skirt = C('sigilo_skirt', 0x3a3340);
	pearBody(b, mat('skin_rosada', 0xf6c7a8), { shirt: cardigan, pants: skirt, belted: false, shoes: C('sigilo_shoes', 0x2a1a14) });
	for (let i = 0; i < 4; i++) b.add('body', C('sigilo_button', 0xe8d8b0), new THREE.SphereGeometry(0.025, 5, 3), { pos: V(0, 0.95 - i * 0.14, widthAt(0.95 - i * 0.14)[1] + 0.005) });
	eyes(b, 1.33, 0.17, 0.08, 0.045);
	// Lips pressed together: shhh.
	b.add('face', C('sigilo_lips', 0xa83a4a), ellipsoid(0.025, 0.02, 0.01, 6, 3), { pos: V(0, 1.22, 0.195) });
	const grey = C('hair_grey', 0xb8b8bc);
	b.add('head', grey, ellipsoid(0.21, 0.14, 0.2, 10, 5), { pos: V(0, 1.4, -0.02) });
	b.add('head', grey, new THREE.SphereGeometry(0.1, 8, 6), { pos: V(0, 1.5, -0.14) });
	for (const s of [-1, 1]) b.add('head', M.black, new THREE.TorusGeometry(0.05, 0.008, 4, 8), { pos: V(s * 0.08, 1.33, 0.215) });
	b.add('head', M.gold, new THREE.TorusGeometry(0.17, 0.004, 3, 16, Math.PI), { pos: V(0, 1.2, 0.12), rot: [0, 0, Math.PI] });
	b.add('body', M.gold, new THREE.TorusGeometry(0.06, 0.01, 4, 10), { pos: V(0.38, 0.5, 0.25), rot: [0, 0.6, 0] });
	// The feather duster in her right hand: a stick and a puff of feathers.
	b.add('props', C('duster_stick', 0x6b4a2a), new THREE.CylinderGeometry(0.015, 0.015, 0.45, 5), { pos: V(0.5, 0.8, 0.12), rot: [0.2, 0, -0.2] });
	b.add('props', C('duster_feathers', 0xe46a9a), ellipsoid(0.1, 0.14, 0.1, 6, 5), { pos: V(0.55, 1.08, 0.17) });
}

// Tomasito: a small boy in pajamas with dinosaurs, his own nightcap, asleep (eyes closed) hugging a picture book.
function tomasito(b) {
	const pajama = C('kid_pajama', 0xf2a640), dino = C('kid_dino', 0x4aa04a);
	pearBody(b, mat('skin_morena', 0xd9a07a), { shirt: pajama, pants: pajama, belted: false, shoes: C('kid_socks', 0xf4f0e6) });
	for (const [x, y] of [[-0.25, 0.3], [0.2, 0.45], [-0.1, 0.75], [0.15, 0.95]]) {
		const z = widthAt(y)[1] * Math.sqrt(1 - (x / widthAt(y)[0]) ** 2);
		b.add('body', dino, ellipsoid(0.06, 0.04, 0.015, 6, 3), { pos: V(x, y, z) });
	}
	for (const s of [-1, 1]) b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.012, 0.012), { pos: V(s * 0.08, 1.32, 0.205), rot: [0, 0, s * 0.15] });
	b.add('face', C('kid_mouth', 0xa05040), ellipsoid(0.02, 0.02, 0.01, 6, 3), { pos: V(0, 1.21, 0.195) });
	b.add('head', C('kid_hair', 0x3a2418), ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.41, -0.02) });
	nightcap(b, 'head', C('kid_cap', 0x4aa04a), M.white, 1.47);
	b.add('props', C('kid_book', 0xd83a3a), new THREE.BoxGeometry(0.34, 0.26, 0.04), { pos: V(0, 0.72, 0.4), rot: [-0.3, 0, 0] });
}

const PEOPLE = { lector: lector, sigilo: sigilo, tomasito: tomasito };

export const models = Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [`npc_${n}`, () => {
	const b = new Builder(`npc_${n}`);
	f(b);
	return b.build();
}]));

export const views = {
	library_people: {
		items: [{ name: 'npc_sigilo', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_lector', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_lector', pos: [1.2, 0, 0], rotY: -0.4 }, { name: 'npc_tomasito', pos: [2.3, 0, 0], rotY: -0.3 }],
		cam: { pos: [0.5, 1.4, 6.0], target: [0.5, 0.85, 0], fov: 38 },
	},
};
