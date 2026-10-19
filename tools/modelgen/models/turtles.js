// The grandpa's turtle races (historias.md): Relámpago, the champion with a 7 on its shell, the plain turtles that
// look just like it, the betting board and the trophies. Centered on their collision boxes in scenes/props/*.tscn.
// Turtles face +Z. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { eyes } from './pear.js';

const gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });

// Turtle: 0.28 x 0.16 x 0.36 m. A domed shell with darker plates, four stubby legs and a little head.
function buildTurtle(name, number) {
	const shell = mat('turtle_shell', 0x4f9a3a), plate = mat('turtle_plate', 0x3a7a2a), skin = mat('turtle_skin', 0xa8d46a);
	const b = new Builder(name);
	const y0 = -0.08;
	b.add('shell', shell, ellipsoid(0.14, 0.09, 0.17, 12, 6), { pos: V(0, y0 + 0.05, 0) });
	b.add('shell', plate, new THREE.CylinderGeometry(0.14, 0.14, 0.03, 12), { pos: V(0, y0 + 0.045, 0), scale: [1, 1, 1.2] });
	for (const [x, z] of [[0, 0], [-0.06, 0.07], [0.06, 0.07], [-0.06, -0.07], [0.06, -0.07]]) {
		b.add('shell', plate, ellipsoid(0.04, 0.02, 0.04, 6, 3), { pos: V(x, y0 + 0.125 - Math.abs(x) * 0.4 - Math.abs(z) * 0.3, z) });
	}
	for (const sx of [-1, 1]) for (const sz of [-1, 1]) {
		b.add('legs', skin, ellipsoid(0.035, 0.03, 0.04, 6, 4), { pos: V(sx * 0.11, y0 + 0.025, sz * 0.11) });
	}
	b.add('head', skin, ellipsoid(0.05, 0.045, 0.06, 8, 6), { pos: V(0, y0 + 0.06, 0.2) });
	eyes(b, y0 + 0.08, 0.23, 0.025, 0.012);
	b.add('tail', skin, new THREE.ConeGeometry(0.02, 0.05, 4), { pos: V(0, y0 + 0.04, -0.19), rot: [-Math.PI / 2, 0, 0] });
	if (number) {
		// A white "7" painted on top of the shell, upright when seen from above with the head up.
		const paint = mat('turtle_paint', 0xffffff);
		b.add('number', paint, new THREE.BoxGeometry(0.1, 0.014, 0.026), { pos: V(0, y0 + 0.142, 0.05) });
		b.add('number', paint, new THREE.BoxGeometry(0.026, 0.014, 0.12), { pos: V(-0.012, y0 + 0.14, -0.005), rot: [0, -0.42, 0] });
	}
	return b.build();
}

// Betting board: 0.6 x 0.05 x 0.45 m, 8 kg. A green chalkboard with race lanes and chalk odds, in a wooden frame.
export function buildBettingBoard() {
	const frame = mat('wood', 0xc58a4e), board = mat('chalkboard', 0x2e5a3a), chalk = mat('chalk', 0xf2f2e8);
	const b = new Builder('betting_board');
	b.add('board', frame, new THREE.BoxGeometry(0.6, 0.05, 0.45));
	b.add('board', board, new THREE.BoxGeometry(0.54, 0.052, 0.39));
	for (let i = 0; i < 4; i++) {
		b.add('chalk', chalk, new THREE.BoxGeometry(0.46, 0.054, 0.006), { pos: V(0, 0, -0.14 + i * 0.09) });
		b.add('chalk', chalk, new THREE.BoxGeometry(0.06, 0.054, 0.03), { pos: V(0.2, 0, -0.1 + i * 0.09) });
	}
	return b.build();
}

// Trophy: 0.12 x 0.2 x 0.12 m, 0.5 kg. A gold cup with two handles on a dark base.
export function buildTrophy() {
	const base = mat('trophy_base', 0x3a2a20);
	const b = new Builder('trophy');
	b.add('base', base, new THREE.BoxGeometry(0.1, 0.04, 0.1), { pos: V(0, -0.08, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.015, 0.025, 0.05, 6), { pos: V(0, -0.035, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.055, 0.03, 0.09, 8), { pos: V(0, 0.045, 0) });
	for (const s of [-1, 1]) b.add('cup', gold, new THREE.TorusGeometry(0.025, 0.006, 4, 8, Math.PI), { pos: V(s * 0.055, 0.05, 0), rot: [0, 0, -s * Math.PI / 2] });
	return b.build();
}

export const models = {
	turtle_racer: () => buildTurtle('turtle_racer', true),
	turtle_plain: () => buildTurtle('turtle_plain', false),
	betting_board: buildBettingBoard,
	trophy: buildTrophy,
};

export const views = {
	turtles: {
		items: [{ name: 'turtle_racer', pos: [0, 0.08, 0], rotY: Math.PI }, { name: 'turtle_plain', pos: [0.45, 0.08, 0.2], rotY: -0.4 },
			{ name: 'turtle_plain', pos: [-0.4, 0.08, 0.3], rotY: 1.2 }, { name: 'betting_board', pos: [0.1, 0.025, -0.6], rotY: 0.1 },
			{ name: 'trophy', pos: [0.75, 0.1, -0.2], rotY: 0 }, { name: 'trophy', pos: [0.9, 0.1, 0.1], rotY: 0.4 }],
		cam: { pos: [0.2, 1.6, 1.2], target: [0.15, 0.05, -0.1], fov: 32 },
	},
};
