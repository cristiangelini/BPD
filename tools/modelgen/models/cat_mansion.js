// The Monedero mansion's people (escena-gato.md, step 2): the nephew (six alike in the sweater their aunt knitted, a
// ginger cat on the chest, a wool beanie and a scarf), Señora Ofelia (silk dressing gown, pearls and a fan) and Don
// Plumas, the parrot. Faces +Z, feet at y = 0. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// The nephew. The parts the game changes per nephew have their own nodes: beanie (taken off), hair (recolored, under
// the beanie), glasses (shown or not), teeth (shown when he bites), legs (the shoes, stretched to his size) and the
// scratches on each hand (scratch_left, scratch_right: shown when he rolls up his sleeves), with the sleeves' cuffs
// (cuff_left, cuff_right: hidden then).
function sobrino(b) {
	const sweater = C('aunt_sweater', 0x2e7d5b), ginger = C('sweater_cat', 0xf0a040), wool = C('aunt_wool', 0xc8384a);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: sweater, pants: C('nephew_pants', 0x3a3f55), belted: false });
	// The cat knitted on the chest: a round face with two ears.
	b.add('body', ginger, ellipsoid(0.11, 0.1, 0.03, 8, 5), { pos: V(0, 0.8, 0.33) });
	for (const s of [-1, 1]) b.add('body', ginger, new THREE.ConeGeometry(0.035, 0.07, 4), { pos: V(s * 0.06, 0.92, 0.32), rot: [0, 0, -s * 0.3] });
	for (const s of [-1, 1]) b.add('body', M.black, ellipsoid(0.012, 0.015, 0.01, 5, 3), { pos: V(s * 0.04, 0.82, 0.36) });
	// The scarf around the neck, its end hanging in front.
	b.add('body', wool, new THREE.TorusGeometry(0.15, 0.045, 6, 12), { pos: V(0, 1.12, 0.01), rot: [Math.PI / 2, 0, 0] });
	b.add('body', wool, new THREE.BoxGeometry(0.1, 0.3, 0.04), { pos: V(0.1, 0.95, 0.2), rot: [0.2, 0, 0.1] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.22, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.225, 0.2) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.42, -0.02) });
	b.add('beanie', wool, ellipsoid(0.215, 0.16, 0.205, 10, 6), { pos: V(0, 1.47, 0.0) });
	b.add('beanie', M.white, new THREE.SphereGeometry(0.06, 6, 4), { pos: V(0, 1.64, -0.01) });
	b.add('beanie', ginger, new THREE.TorusGeometry(0.2, 0.03, 4, 12), { pos: V(0, 1.4, 0.0), rot: [Math.PI / 2, 0, 0] });
	for (const s of [-1, 1]) b.add('glasses', M.black, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.34, 0.215) });
	b.add('glasses', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.345, 0.215) });
	// The sleeves' cuffs over each wrist, and the three red scratch lines under them.
	const red = C('scratch_red', 0xd02020);
	for (const [s, side] of [[-1, 'left'], [1, 'right']]) {
		b.add(`cuff_${side}`, sweater, new THREE.CylinderGeometry(0.07, 0.07, 0.06, 8), { pos: V(s * 0.46, 0.69, 0.08), rot: [0.3, 0, s * 0.6] });
		for (let i = 0; i < 3; i++) b.add(`scratch_${side}`, red, new THREE.BoxGeometry(0.012, 0.012, 0.09), { pos: V(s * (0.47 + i * 0.02), 0.66 + i * 0.012, 0.15), rot: [0, s * 0.4, 0] });
	}
}

// Señora Ofelia Monedero: a pink silk dressing gown, a three-row pearl necklace, white curls and a lace fan.
function ofelia(b) {
	const silk = C('ofelia_silk', 0xe68bb4), lace = C('ofelia_lace', 0xfff4f8);
	pearBody(b, mat('skin_rosada', 0xf6c7a8), { shirt: silk, pants: silk, belted: false, shoes: C('slipper', 0xb0306a) });
	b.add('body', silk, new THREE.TorusGeometry(0.42, 0.04, 6, 12), { pos: V(0, 0.52, 0), rot: [Math.PI / 2, 0, 0] });
	for (let row = 0; row < 3; row++) {
		for (let i = 0; i < 11; i++) {
			const a = Math.PI * (0.12 + 0.76 * i / 10);
			const r = 0.16 + row * 0.03;
			b.add('body', C('pearl', 0xf6f2ea), new THREE.SphereGeometry(0.02, 5, 3), { pos: V(Math.cos(a) * r, 1.12 - row * 0.04 - Math.sin(a) * 0.06, 0.12 + Math.sin(a) * 0.06) });
		}
	}
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', C('lipstick', 0xc0204a), ellipsoid(0.04, 0.015, 0.01, 6, 3), { pos: V(0, 1.23, 0.195) });
	const curls = C('hair_white', 0xf2f0ec);
	for (let i = 0; i < 9; i++) {
		const a = Math.PI * 2 * (i / 9);
		b.add('head', curls, new THREE.SphereGeometry(0.075, 6, 4), { pos: V(Math.cos(a) * 0.17, 1.45, Math.sin(a) * 0.16 - 0.02) });
	}
	b.add('head', curls, new THREE.SphereGeometry(0.1, 6, 4), { pos: V(0, 1.53, -0.02) });
	// The fan, open in her right hand.
	b.add('props', lace, new THREE.CylinderGeometry(0.22, 0.22, 0.01, 10, 1, false, -Math.PI / 2.4, Math.PI / 1.2), { pos: V(0.52, 0.8, 0.18), rot: [Math.PI / 2, 0, 0.3] });
}

// Don Plumas, the parrot: green with a red head, a yellow beak and blue wing tips, standing on his perch.
function loro(b) {
	const green = C('parrot_green', 0x2fae48), red = C('parrot_red', 0xd83030), blue = C('parrot_blue', 0x2f5fd0);
	b.add('body', green, ellipsoid(0.08, 0.12, 0.08, 8, 6), { pos: V(0, 0.12, 0) });
	b.add('head', red, ellipsoid(0.065, 0.065, 0.065, 8, 6), { pos: V(0, 0.26, 0.02) });
	b.add('head', C('beak', 0xf2c84b), new THREE.ConeGeometry(0.025, 0.06, 5), { pos: V(0, 0.25, 0.09), rot: [Math.PI / 2 + 0.4, 0, 0] });
	eyes(b, 0.28, 0.06, 0.035, 0.015);
	for (const s of [-1, 1]) b.add('body', blue, ellipsoid(0.03, 0.09, 0.06, 6, 4), { pos: V(s * 0.08, 0.1, -0.02), rot: [0.3, 0, 0] });
	b.add('body', blue, new THREE.BoxGeometry(0.04, 0.14, 0.02), { pos: V(0, 0.0, -0.08), rot: [-0.5, 0, 0] });
	limb(b, 'legs', C('parrot_feet', 0x707070), V(-0.12, 0.0, 0.0), V(0.12, 0.0, 0.0), 0.012);
}

const PEOPLE = { sobrino_tia: sobrino, ofelia: ofelia };

export const models = {
	...Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [`npc_${n}`, () => {
		const b = new Builder(`npc_${n}`);
		f(b);
		return b.build();
	}])),
	parrot: () => {
		const b = new Builder('parrot');
		loro(b);
		return b.build();
	},
};

export const views = {
	cat_mansion_people: {
		items: [{ name: 'npc_ofelia', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_sobrino_tia', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_sobrino_tia', pos: [1.2, 0, 0], rotY: -0.4 }, { name: 'parrot', pos: [2.2, 0.9, 0], rotY: -0.5 }],
		cam: { pos: [0.45, 1.4, 6.0], target: [0.45, 0.85, 0], fov: 38 },
	},
};
