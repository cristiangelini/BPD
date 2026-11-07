// The Zoológico Municipal's people (escena-zoo.md, step 2): the keeper (six alike in the same green overalls, rubber
// boots, gloves and a cap with a visor), Doña Jaula the director (safari hat, khaki shirt and a whistle) and Don Pico
// the parrot on his perch. Faces +Z, feet at y = 0. Placeholder, not final art.
import { Builder, ellipsoid, loft, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// The keeper. The parts the game changes per keeper have their own nodes: cap (taken off), hair (recolored, only seen
// without the cap), teeth (shown when they bite), legs (the boots, stretched to their size), bandage (the band-aid of
// a peck on the right hand, seen without the gloves) and glove_left and glove_right (on at feeding time and for the
// fingerprints).
function cuidador(b) {
	const green = C('keeper_overalls', 0x3f7a3a), boots = C('keeper_boots', 0x2a3a2a);
	pearBody(b, mat('skin_trigo', 0xe8c094), { shirt: green, pants: green, belted: false, shoes: boots, onePiece: true });
	eyes(b, 1.33, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.08, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.205, 0.2) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.13, 0.19, 10, 5), { pos: V(0, 1.43, -0.03) });
	// The overalls' bib with a pocket and the zoo's badge.
	b.add('body', green, new THREE.BoxGeometry(0.3, 0.26, 0.04), { pos: V(0, 0.88, 0.33) });
	b.add('body', C('keeper_badge', 0xf2c84b), new THREE.CylinderGeometry(0.035, 0.035, 0.012, 8), { pos: V(-0.1, 0.92, 0.36), rot: [Math.PI / 2, 0, 0] });
	// The cap with its visor, over the hair.
	const cap = C('keeper_cap', 0x2f5a2c);
	b.add('cap', cap, new THREE.CylinderGeometry(0.2, 0.21, 0.1, 10), { pos: V(0, 1.48, 0.0) });
	b.add('cap', cap, new THREE.CylinderGeometry(0.17, 0.17, 0.02, 10, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 1.44, 0.12) });
	// The band-aid on the back of the right hand.
	b.add('bandage', C('bandage', 0xe8b088), new THREE.BoxGeometry(0.07, 0.02, 0.035), { pos: V(0.49, 0.71, 0.1), rot: [0, 0.4, 0] });
	// The rubber gloves over the hands.
	for (const [s, side] of [[-1, 'left'], [1, 'right']]) {
		b.add(`glove_${side}`, C('keeper_gloves', 0xe8d23a), ellipsoid(0.09, 0.09, 0.09, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	}
}

// Doña Jaula, the director: a khaki shirt and shorts, a round safari hat, binoculars on her chest and a whistle.
function jaula(b) {
	const khaki = C('director_khaki', 0xc8b07a);
	pearBody(b, mat('skin_canela', 0xc68a5a), { shirt: khaki, pants: C('director_shorts', 0xa08a58), belted: true, shoes: C('director_boots', 0x5a3a20) });
	eyes(b, 1.33, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.1, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	b.add('hair', C('hair_grey', 0x8a8a92), ellipsoid(0.22, 0.12, 0.2, 10, 5), { pos: V(0, 1.38, -0.05) });
	b.add('hair', khaki, new THREE.CylinderGeometry(0.34, 0.34, 0.02, 14), { pos: V(0, 1.47, 0) });
	b.add('hair', khaki, ellipsoid(0.2, 0.12, 0.2, 10, 5), { pos: V(0, 1.5, 0) });
	b.add('props', M.black, new THREE.BoxGeometry(0.16, 0.08, 0.08), { pos: V(0, 0.92, 0.36) });
	b.add('props', M.gold, new THREE.CylinderGeometry(0.02, 0.02, 0.08, 6), { pos: V(0.2, 1.03, 0.25), rot: [0, 0, Math.PI / 2] });
}

// Don Pico, the parrot: green with a red head and a yellow beak, sitting on nothing (the zoo builds the perch).
function pico(b) {
	const green = C('parrot_green', 0x2fae4a), red = C('parrot_red', 0xd8303a), yellow = C('parrot_beak', 0xf2c84b);
	b.add('body', green, ellipsoid(0.12, 0.18, 0.11, 10, 7), { pos: V(0, 0.18, 0) });
	b.add('head', red, ellipsoid(0.09, 0.09, 0.09, 10, 7), { pos: V(0, 0.38, 0.03) });
	b.add('head', yellow, new THREE.ConeGeometry(0.035, 0.08, 6), { pos: V(0, 0.36, 0.12), rot: [Math.PI / 2 + 0.4, 0, 0] });
	for (const s of [-1, 1]) {
		b.add('face', M.white, ellipsoid(0.025, 0.025, 0.012, 6, 4), { pos: V(s * 0.055, 0.4, 0.09) });
		b.add('face', M.black, ellipsoid(0.012, 0.012, 0.008, 6, 4), { pos: V(s * 0.055, 0.4, 0.1) });
		b.add('body', C('parrot_wing', 0x2a6ad8), ellipsoid(0.04, 0.14, 0.09, 6, 4), { pos: V(s * 0.12, 0.17, -0.01) });
		b.add('body', yellow, ellipsoid(0.02, 0.03, 0.035, 6, 4), { pos: V(s * 0.05, 0.01, 0.03) });
	}
	b.add('body', red, loft([{ y: 0.0, rx: 0.05, rz: 0.03 }, { y: -0.22, rx: 0.02, rz: 0.015 }], 6), { pos: V(0, 0.06, -0.08), rot: [-0.5, 0, 0] });
}

const PEOPLE = { npc_cuidador: cuidador, npc_jaula: jaula, npc_pico: pico };

export const models = Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [n, () => {
	const b = new Builder(n);
	f(b);
	return b.build();
}]));

export const views = {
	zoo_people: {
		items: [{ name: 'npc_jaula', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_cuidador', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_pico', pos: [1.2, 0.9, 0], rotY: -0.3 }],
		cam: { pos: [0, 1.4, 6.0], target: [0, 0.85, 0], fov: 38 },
	},
};
