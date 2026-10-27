// The Municipal Aquarium's people and animals (escena-acuario.md, step 2): the diver (six alike in the aquarium's black
// wetsuit with a whale on the chest, the hood, the mask up on the forehead, gloves and flippers), Don Anzuelo the keeper
// (yellow overalls, rubber boots, a cap and his bucket), Bigotes the sea lion and Doña Tinta the octopus. Faces +Z,
// feet at y = 0. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// The diver. The parts the game changes per diver have their own nodes: hood (taken off), hair (recolored, under the
// hood), glasses (the prescription lenses in the mask, shown or not), teeth (shown when they bite), legs (the
// flippers, stretched to their size), glove_left and glove_right (taken off), and the octopus ink on each hand under
// the glove (ink_left, ink_right: shown when the glove comes off and the diver has it).
function buzo(b) {
	const suit = C('wetsuit', 0x1c1d24), trim = C('wetsuit_trim', 0x2f8fd8), flipper = C('flipper', 0xf2c230);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: suit, pants: suit, belted: false, shoes: suit });
	// The whale on the chest.
	b.add('body', trim, ellipsoid(0.12, 0.06, 0.02, 8, 4), { pos: V(0, 0.82, 0.32) });
	b.add('body', trim, new THREE.ConeGeometry(0.05, 0.08, 4), { pos: V(-0.14, 0.86, 0.315), rot: [0, 0, 0.9] });
	// The flippers, long and yellow, pointing forward from each foot.
	for (const s of [-1, 1]) b.add('legs', flipper, new THREE.BoxGeometry(0.22, 0.03, 0.42), { pos: V(s * 0.2, 0.03, 0.36) });
	eyes(b, 1.31, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.205, 0.2) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.2, 0.12, 0.18, 10, 5), { pos: V(0, 1.43, -0.04) });
	b.add('hood', suit, ellipsoid(0.22, 0.22, 0.2, 10, 7), { pos: V(0, 1.36, -0.05) });
	// The mask up on the forehead: the black rim, the glass and, for some, thick prescription lenses.
	b.add('mask', M.black, new THREE.BoxGeometry(0.32, 0.11, 0.05), { pos: V(0, 1.47, 0.15) });
	b.add('mask', C('mask_glass', 0x9fd8f0, { emissive: 0x10303a }), new THREE.BoxGeometry(0.27, 0.07, 0.02), { pos: V(0, 1.47, 0.178) });
	b.add('mask', M.black, new THREE.TorusGeometry(0.2, 0.012, 4, 12, Math.PI), { pos: V(0, 1.42, -0.02), rot: [-0.3, 0, 0] });
	for (const s of [-1, 1]) b.add('glasses', C('lens', 0xe8f6ff), new THREE.CylinderGeometry(0.035, 0.035, 0.02, 8), { pos: V(s * 0.065, 1.47, 0.19), rot: [Math.PI / 2, 0, 0] });
	// The octopus ink on each hand, and the glove over it.
	const ink = C('octopus_ink', 0x241a4a);
	for (const [s, side] of [[-1, 'left'], [1, 'right']]) {
		for (let i = 0; i < 4; i++) {
			const a = i * 1.6;
			b.add(`ink_${side}`, ink, ellipsoid(0.03, 0.03, 0.012, 6, 3), { pos: V(s * (0.49 + Math.cos(a) * 0.035), 0.64 + Math.sin(a) * 0.035, 0.155) });
		}
		b.add(`glove_${side}`, trim, ellipsoid(0.085, 0.085, 0.085, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	}
}

// Don Anzuelo, the keeper: yellow overalls over a striped shirt, green rubber boots, a cap, a grey mustache and the
// bucket he chases Bigotes with.
function anzuelo(b) {
	const overalls = C('anzuelo_overalls', 0xf2c230), shirt = C('anzuelo_shirt', 0x2a5aa8);
	pearBody(b, mat('skin_morena', 0xd9a07a), { shirt, pants: overalls, belted: false, shoes: C('anzuelo_boots', 0x2e7a3a) });
	b.add('body', overalls, new THREE.BoxGeometry(0.4, 0.3, 0.05), { pos: V(0, 0.68, 0.38) });
	for (const s of [-1, 1]) b.add('body', overalls, new THREE.BoxGeometry(0.05, 0.4, 0.03), { pos: V(s * 0.15, 0.88, 0.3), rot: [-0.35, 0, 0] });
	eyes(b, 1.33, 0.17, 0.08, 0.045);
	b.add('face', C('hair_grey', 0xb8b8bc), ellipsoid(0.09, 0.025, 0.03, 8, 3), { pos: V(0, 1.24, 0.2) });
	b.add('head', C('anzuelo_cap', 0x2a5aa8), new THREE.CylinderGeometry(0.19, 0.2, 0.1, 8), { pos: V(0, 1.47, 0.0) });
	b.add('head', C('anzuelo_cap', 0x2a5aa8), new THREE.BoxGeometry(0.24, 0.02, 0.14), { pos: V(0, 1.43, 0.22) });
	const metal = C('bucket_metal', 0x9aa0a8);
	b.add('props', metal, new THREE.CylinderGeometry(0.14, 0.11, 0.24, 8, 1, true), { pos: V(0.52, 0.5, 0.15) });
	b.add('props', metal, new THREE.CylinderGeometry(0.11, 0.11, 0.01, 8), { pos: V(0.52, 0.385, 0.15) });
	b.add('props', C('fish_silver', 0xc8d0d8), ellipsoid(0.05, 0.02, 0.1, 6, 3), { pos: V(0.52, 0.64, 0.15), rot: [0.5, 0, 0] });
}

// Bigotes, the sea lion, sitting up on his front flippers: a long brown body, a round head with big whiskers and a
// black nose (the "nose" node, where he balances what he steals), the front flippers and the tail flippers.
function bigotes(b) {
	const fur = C('sealion_fur', 0x7a5638), belly = C('sealion_belly', 0x9a7450), dark = C('sealion_dark', 0x4a3424);
	b.add('body', fur, ellipsoid(0.28, 0.5, 0.3, 10, 8), { pos: V(0, 0.55, -0.05), rot: [0.35, 0, 0] });
	b.add('body', belly, ellipsoid(0.2, 0.38, 0.12, 8, 6), { pos: V(0, 0.55, 0.15), rot: [0.35, 0, 0] });
	b.add('body', fur, ellipsoid(0.24, 0.16, 0.4, 8, 6), { pos: V(0, 0.18, -0.45) });
	b.add('head', fur, ellipsoid(0.17, 0.16, 0.19, 10, 7), { pos: V(0, 1.05, 0.12) });
	b.add('head', belly, ellipsoid(0.09, 0.07, 0.1, 8, 5), { pos: V(0, 1.0, 0.28) });
	b.add('nose', M.black, ellipsoid(0.035, 0.025, 0.025, 6, 4), { pos: V(0, 1.03, 0.37) });
	eyes(b, 1.11, 0.25, 0.07, 0.04);
	// The whiskers: three long white bristles on each side.
	for (const s of [-1, 1]) {
		for (let i = 0; i < 3; i++) {
			limb(b, 'whiskers', M.white, V(s * 0.06, 0.99 - i * 0.02, 0.33), V(s * 0.24, 1.01 - i * 0.05, 0.3), 0.005, 3);
		}
	}
	for (const s of [-1, 1]) {
		b.add('flippers', dark, new THREE.BoxGeometry(0.12, 0.03, 0.3), { pos: V(s * 0.2, 0.04, 0.12), rot: [0, s * 0.4, 0] });
		b.add('flippers', dark, new THREE.BoxGeometry(0.14, 0.03, 0.26), { pos: V(s * 0.1, 0.05, -0.8), rot: [0, -s * 0.5, 0] });
	}
}

// Doña Tinta, the octopus lady: a big purple head with spots, sleepy eyes with lashes, a pearl necklace and eight arms
// curling on the sand around her.
function tinta(b) {
	const skin = C('octopus_skin', 0x9a4ab0), spot = C('octopus_spot', 0xc87ad8), sucker = C('octopus_sucker', 0xf2c8e0);
	b.add('head', skin, ellipsoid(0.28, 0.32, 0.26, 10, 8), { pos: V(0, 0.55, -0.05) });
	for (const [x, y, z] of [[-0.15, 0.68, 0.13], [0.12, 0.75, 0.1], [0.2, 0.55, 0.12], [-0.08, 0.82, -0.05]]) {
		b.add('head', spot, ellipsoid(0.04, 0.04, 0.015, 6, 3), { pos: V(x, y, z + 0.08) });
	}
	eyes(b, 0.45, 0.2, 0.1, 0.06);
	for (const s of [-1, 1]) b.add('face', M.black, new THREE.BoxGeometry(0.09, 0.015, 0.015), { pos: V(s * 0.1, 0.52, 0.23), rot: [0, 0, s * 0.3] });
	for (let i = 0; i < 7; i++) {
		const a = -0.9 + i * 0.3;
		b.add('head', M.white, new THREE.SphereGeometry(0.018, 5, 3), { pos: V(Math.sin(a) * 0.2, 0.3 + Math.abs(Math.sin(a)) * 0.04, Math.cos(a) * 0.19) });
	}
	// The eight arms, each a row of shrinking balls curling outwards, with a sucker under each ball.
	for (let k = 0; k < 8; k++) {
		const turn = (k / 8) * Math.PI * 2;
		for (let i = 0; i < 14; i++) {
			const t = i / 13;
			const reach = 0.22 + t * 0.45;
			const curl = turn + t * 0.9;
			const r = 0.075 * (1 - t * 0.65);
			const at = V(Math.sin(curl) * reach, 0.06 + Math.sin(t * Math.PI) * 0.08 + (1 - t) * 0.12, Math.cos(curl) * reach);
			b.add('arms', skin, ellipsoid(r, r * 0.8, r, 6, 4), { pos: at });
			if (i % 3 === 1) b.add('arms', sucker, ellipsoid(r * 0.45, r * 0.2, r * 0.45, 5, 3), { pos: at.clone().add(V(0, -r * 0.7, 0)) });
		}
	}
}

const PEOPLE = { npc_buzo: buzo, npc_anzuelo: anzuelo, sea_lion_bigotes: bigotes, octopus_tinta: tinta };

export const models = Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [n, () => {
	const b = new Builder(n);
	f(b);
	return b.build();
}]));

export const views = {
	aquarium_people: {
		items: [{ name: 'npc_anzuelo', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_buzo', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'sea_lion_bigotes', pos: [1.2, 0, 0], rotY: -0.5 }, { name: 'octopus_tinta', pos: [2.4, 0, 0], rotY: -0.3 }],
		cam: { pos: [0.5, 1.4, 6.0], target: [0.5, 0.75, 0], fov: 38 },
	},
};
