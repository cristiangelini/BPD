// The vent jailbreak (fuga-ventilacion.md): the loose grille high on each cell's back wall and the key board behind
// the night guard. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The vent grille, 0.6 x 0.4 m, facing +Z, the origin in its middle. The screws are their own parts (screw_0..3).
export function buildVentGrille() {
	const b = new Builder('vent_grille');
	const metal = mat('vent_metal', 0x9aa0a6);
	b.add('grille', metal, new THREE.BoxGeometry(0.6, 0.04, 0.02), { pos: V(0, 0.18, 0) });
	b.add('grille', metal, new THREE.BoxGeometry(0.6, 0.04, 0.02), { pos: V(0, -0.18, 0) });
	b.add('grille', metal, new THREE.BoxGeometry(0.04, 0.4, 0.02), { pos: V(-0.28, 0, 0) });
	b.add('grille', metal, new THREE.BoxGeometry(0.04, 0.4, 0.02), { pos: V(0.28, 0, 0) });
	const slat = mat('vent_slat', 0x7d838a);
	for (let i = -2; i <= 2; i++) {
		b.add('grille', slat, new THREE.BoxGeometry(0.52, 0.015, 0.03), { pos: V(0, i * 0.06, 0.005), rot: [0.5, 0, 0] });
	}
	const screw = mat('vent_screw', 0xd8c070);
	[[-0.26, 0.16], [0.26, 0.16], [-0.26, -0.16], [0.26, -0.16]].forEach(([x, y], i) => {
		b.add(`screw_${i}`, screw, new THREE.CylinderGeometry(0.012, 0.012, 0.012, 8), { pos: V(x, y, 0.016), rot: [Math.PI / 2, 0, 0] });
	});
	return b.build();
}

// The dark hole behind the grille, 0.56 x 0.36 m, facing +Z.
export function buildVentHole() {
	const b = new Builder('vent_hole');
	b.add('hole', mat('vent_dark', 0x101010), new THREE.BoxGeometry(0.56, 0.36, 0.01));
	return b.build();
}

// The key board on the wall behind the guard: a wooden board 0.9 x 0.4 m with 6 hooks and a key on each (parts
// key_0..5, left to right), facing +Z, the origin in its middle.
export function buildKeyBoard() {
	const b = new Builder('key_board');
	b.add('board', mat('key_board_wood', 0x8a5a30), new THREE.BoxGeometry(0.9, 0.4, 0.03));
	const hook = mat('key_hook', 0x505050);
	const brass = mat('key_brass', 0xd0b050);
	const tags = [0xd04040, 0x40a040, 0x4060d0, 0xd0a020, 0x9040b0, 0x30a0a0];
	for (let i = 0; i < 6; i++) {
		const x = -0.35 + i * 0.14;
		b.add('board', hook, new THREE.CylinderGeometry(0.006, 0.006, 0.05, 6), { pos: V(x, 0.08, 0.035), rot: [Math.PI / 2, 0, 0] });
		b.add(`key_${i}`, brass, new THREE.TorusGeometry(0.018, 0.005, 6, 12), { pos: V(x, 0.05, 0.05) });
		b.add(`key_${i}`, brass, new THREE.BoxGeometry(0.01, 0.07, 0.006), { pos: V(x, -0.01, 0.05) });
		b.add(`key_${i}`, mat(`key_tag_${i}`, tags[i]), new THREE.BoxGeometry(0.04, 0.05, 0.004), { pos: V(x, -0.08, 0.05) });
	}
	return b.build();
}

export const models = { vent_grille: buildVentGrille, vent_hole: buildVentHole, key_board: buildKeyBoard };

export const views = {
	vent: {
		items: [
			{ name: 'vent_hole', pos: [0, 1.0, -0.01] },
			{ name: 'vent_grille', pos: [0, 1.0, 0] },
			{ name: 'vent_grille', pos: [0.8, 1.0, 0], rotY: 0 },
			{ name: 'key_board', pos: [0.4, 1.6, 0] },
		],
		cam: { pos: [0.4, 1.3, 1.8], target: [0.4, 1.3, 0], fov: 40 },
	},
};
