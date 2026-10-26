// The chess club "El Peón Dormido" (docs/diseno/infiltracion-ajedrez.md, step 3): the pieces, white and black, and the
// clock on each table. Placeholder. Each piece's origin at its bottom, its height about a board square (0.1 m) and up.
import { Builder, mat, V, THREE } from '../lib.js';

const PIECE = { white: 0xf2eee0, black: 0x26242a };
const lathe = (points, segs = 10) => new THREE.LatheGeometry(points.map(([r, y]) => new THREE.Vector2(r, y)), segs);
const BASE = [[0, 0], [0.035, 0], [0.035, 0.012], [0.028, 0.02], [0.022, 0.03]];

const SHAPES = {
	pawn(b, m) {
		b.add('piece', m, lathe([...BASE, [0.014, 0.06], [0.02, 0.066], [0, 0.068]]));
		b.add('piece', m, new THREE.SphereGeometry(0.02, 8, 6), { pos: V(0, 0.082, 0) });
	},
	rook(b, m) {
		b.add('piece', m, lathe([...BASE, [0.02, 0.09], [0.03, 0.095], [0.03, 0.115], [0, 0.115]]));
		for (let i = 0; i < 4; i++) {
			const a = (i / 4) * Math.PI * 2;
			b.add('piece', m, new THREE.BoxGeometry(0.014, 0.02, 0.014), { pos: V(Math.cos(a) * 0.022, 0.125, Math.sin(a) * 0.022) });
		}
	},
	knight(b, m) {
		b.add('piece', m, lathe([...BASE, [0.02, 0.05], [0, 0.05]]));
		b.add('piece', m, new THREE.BoxGeometry(0.03, 0.07, 0.04), { pos: V(0, 0.08, -0.005), rot: [-0.25, 0, 0] });
		b.add('piece', m, new THREE.BoxGeometry(0.028, 0.03, 0.06), { pos: V(0, 0.11, 0.015), rot: [0.3, 0, 0] });
		for (const s of [-1, 1]) b.add('piece', m, new THREE.ConeGeometry(0.007, 0.02, 4), { pos: V(s * 0.008, 0.135, -0.01) });
	},
	bishop(b, m) {
		b.add('piece', m, lathe([...BASE, [0.014, 0.08], [0.022, 0.085], [0.015, 0.09], [0, 0.09]]));
		b.add('piece', m, new THREE.SphereGeometry(0.022, 8, 6), { pos: V(0, 0.11, 0), scale: [1, 1.4, 1] });
		b.add('piece', m, new THREE.SphereGeometry(0.008, 6, 4), { pos: V(0, 0.145, 0) });
	},
	queen(b, m) {
		b.add('piece', m, lathe([...BASE, [0.015, 0.1], [0.026, 0.11], [0.02, 0.125], [0, 0.125]]));
		for (let i = 0; i < 6; i++) {
			const a = (i / 6) * Math.PI * 2;
			b.add('piece', m, new THREE.SphereGeometry(0.006, 5, 4), { pos: V(Math.cos(a) * 0.022, 0.13, Math.sin(a) * 0.022) });
		}
		b.add('piece', m, new THREE.SphereGeometry(0.01, 6, 4), { pos: V(0, 0.14, 0) });
	},
	king(b, m) {
		b.add('piece', m, lathe([...BASE, [0.016, 0.11], [0.027, 0.12], [0.022, 0.135], [0, 0.135]]));
		b.add('piece', m, new THREE.BoxGeometry(0.01, 0.04, 0.01), { pos: V(0, 0.155, 0) });
		b.add('piece', m, new THREE.BoxGeometry(0.03, 0.01, 0.01), { pos: V(0, 0.16, 0) });
	},
};

function piece(kind, color) {
	return () => {
		const b = new Builder(`chess_${kind}_${color}`);
		SHAPES[kind](b, mat(`chess_piece_${color}`, PIECE[color]));
		return b.build();
	};
}

// The chess clock: a wooden box 0.24 m wide with a face to each player (+Z and -Z, the game writes the times on them)
// and a button on top over each side. Origin at its bottom.
export function buildChessClock() {
	const b = new Builder('chess_clock');
	const wood = mat('clock_wood', 0x6a4022), face = mat('clock_face', 0xf4f0e0), button = mat('clock_button', 0xc8202a);
	b.add('box', wood, new THREE.BoxGeometry(0.24, 0.12, 0.09), { pos: V(0, 0.06, 0) });
	for (const s of [-1, 1]) {
		b.add('faces', face, new THREE.BoxGeometry(0.18, 0.07, 0.005), { pos: V(0, 0.065, s * 0.046) });
		b.add('buttons', button, new THREE.CylinderGeometry(0.018, 0.018, 0.025, 8), { pos: V(s * 0.06, 0.13, 0) });
	}
	return b.build();
}

const KINDS = Object.keys(SHAPES);

export const models = {
	...Object.fromEntries(KINDS.flatMap((k) => ['white', 'black'].map((c) => [`chess_${k}_${c}`, piece(k, c)]))),
	chess_clock: buildChessClock,
};

export const views = {
	chess: {
		items: [
			...KINDS.map((k, i) => ({ name: `chess_${k}_white`, pos: [-0.25 + i * 0.1, 0, 0.08] })),
			...KINDS.map((k, i) => ({ name: `chess_${k}_black`, pos: [-0.25 + i * 0.1, 0, -0.08], rotY: Math.PI })),
			{ name: 'chess_clock', pos: [0.45, 0, 0] },
		],
		cam: { pos: [0.1, 0.35, 0.65], target: [0.1, 0.07, 0], fov: 40 },
	},
};
