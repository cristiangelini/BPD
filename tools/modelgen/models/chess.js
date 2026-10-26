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

// The Gran Maestro's hollow black king (step 5): a king twice the size, its base unscrewed and lying beside it, and
// diamonds spilling out of it. Origin at its bottom.
export function buildHollowKing() {
	const b = new Builder('chess_hollow_king');
	const black = mat('chess_piece_black', PIECE.black), diamond = mat('diamond', 0xd8f4ff, { emissive: 0x204050 });
	b.add('king', black, lathe([[0.03, 0.025], [0.05, 0.03], [0.04, 0.05], [0.03, 0.22], [0.05, 0.24], [0.04, 0.27], [0, 0.27]]), { rot: [0, 0, 0] });
	b.add('king', black, new THREE.BoxGeometry(0.02, 0.08, 0.02), { pos: V(0, 0.31, 0) });
	b.add('king', black, new THREE.BoxGeometry(0.06, 0.02, 0.02), { pos: V(0, 0.32, 0) });
	b.add('base', black, new THREE.CylinderGeometry(0.07, 0.07, 0.025, 12), { pos: V(0.14, 0.0125, 0.04) });
	for (const [x, z] of [[0.02, 0.06], [-0.04, 0.08], [0.06, 0.1], [0.0, 0.12], [-0.07, 0.03]]) {
		b.add('diamonds', diamond, new THREE.OctahedronGeometry(0.014), { pos: V(x, 0.012, z) });
	}
	return b.build();
}

// The briefcase under the stage (step 5): black leather, open, full of hollow pieces in rows. 0.5 x 0.3 m, origin at
// its bottom.
export function buildChessBriefcase() {
	const b = new Builder('chess_briefcase');
	const leather = mat('briefcase_leather', 0x1c1a1e), lining = mat('briefcase_lining', 0x7a1a2a), steel = mat('briefcase_steel', 0xb8bcc4);
	b.add('case', leather, new THREE.BoxGeometry(0.5, 0.1, 0.32), { pos: V(0, 0.05, 0) });
	b.add('case', lining, new THREE.BoxGeometry(0.46, 0.01, 0.28), { pos: V(0, 0.1, 0) });
	b.add('lid', leather, new THREE.BoxGeometry(0.5, 0.32, 0.03), { pos: V(0, 0.26, -0.17), rot: [-0.15, 0, 0] });
	for (const x of [-0.12, 0.12]) b.add('locks', steel, new THREE.BoxGeometry(0.04, 0.03, 0.01), { pos: V(x, 0.08, 0.161) });
	const pieces = [mat('chess_piece_white', PIECE.white), mat('chess_piece_black', PIECE.black)];
	for (let i = 0; i < 8; i++) for (let r = 0; r < 2; r++) {
		b.add('pieces', pieces[(i + r) % 2], new THREE.CylinderGeometry(0.018, 0.022, 0.06, 8), { pos: V(-0.19 + i * 0.054, 0.135, -0.05 + r * 0.1) });
	}
	return b.build();
}

// The Gran Maestro's getaway (step 6): a motorized carousel horse, white with gold, its head a chess knight's, on a round
// red platform with a gold skirt, a gold pole through it up to a small striped canopy. Faces +Z, origin at the ground.
export function buildCarouselHorse() {
	const b = new Builder('carousel_horse');
	const white = mat('horse_white', 0xf4f0e6), gold = mat('horse_gold', 0xd8b040), red = mat('horse_red', 0xc0302a);
	const mane = mat('horse_mane', 0x7a4a2a), black = mat('chess_piece_black', PIECE.black);
	const add = (part, m, w, h, d, x, y, z, rot) => b.add(part, m, new THREE.BoxGeometry(w, h, d), { pos: V(x, y, z), rot });
	b.add('base', red, new THREE.CylinderGeometry(0.75, 0.8, 0.25, 14), { pos: V(0, 0.15, 0) });
	b.add('base', gold, new THREE.CylinderGeometry(0.82, 0.82, 0.06, 14), { pos: V(0, 0.29, 0) });
	b.add('pole', gold, new THREE.CylinderGeometry(0.035, 0.035, 2.4, 8), { pos: V(0, 1.5, 0.24) });
	for (let i = 0; i < 8; i++) {
		b.add('canopy', i % 2 ? white : red, new THREE.CylinderGeometry(0.02, 0.7, 0.3, 8, 1, false, (i / 8) * Math.PI * 2, Math.PI / 4), { pos: V(0, 2.75, 0.24) });
	}
	b.add('canopy', gold, new THREE.SphereGeometry(0.07, 8, 6), { pos: V(0, 2.92, 0.24) });
	// The horse: body, legs folded as if galloping, a saddle and the knight's head with its mane.
	add('body', white, 0.38, 0.38, 0.95, 0, 0.82, 0.0);
	for (const [x, z, r] of [[-0.12, 0.38, -0.9], [0.12, 0.38, -0.6], [-0.12, -0.38, 0.9], [0.12, -0.38, 0.6]]) {
		add('legs', white, 0.09, 0.4, 0.09, x, 0.62, z + Math.sign(z) * 0.08, [r, 0, 0]);
		add('legs', gold, 0.1, 0.06, 0.1, x, 0.46, z + Math.sign(z) * 0.24, [r, 0, 0]);
	}
	add('saddle', red, 0.42, 0.06, 0.4, 0, 1.03, -0.05);
	add('saddle', gold, 0.44, 0.02, 0.42, 0, 1.0, -0.05);
	add('neck', white, 0.3, 0.55, 0.3, 0, 1.15, 0.45, [0.35, 0, 0]);
	add('head', white, 0.3, 0.32, 0.3, 0, 1.45, 0.58);
	add('head', white, 0.24, 0.18, 0.32, 0, 1.38, 0.82, [0.25, 0, 0]);
	add('mane', mane, 0.1, 0.6, 0.14, 0, 1.3, 0.34, [0.35, 0, 0]);
	for (const x of [-0.08, 0.08]) {
		add('ears', white, 0.06, 0.12, 0.05, x, 1.66, 0.54, [0.2, 0, 0]);
		add('eyes', black, 0.02, 0.05, 0.05, x * 1.9, 1.5, 0.66);
	}
	add('tail', mane, 0.06, 0.4, 0.06, 0, 0.75, -0.55, [-0.4, 0, 0]);
	return b.build();
}

const KINDS = Object.keys(SHAPES);

export const models = {
	...Object.fromEntries(KINDS.flatMap((k) => ['white', 'black'].map((c) => [`chess_${k}_${c}`, piece(k, c)]))),
	chess_clock: buildChessClock, chess_hollow_king: buildHollowKing, chess_briefcase: buildChessBriefcase,
	carousel_horse: buildCarouselHorse,
};

export const views = {
	chess: {
		items: [
			...KINDS.map((k, i) => ({ name: `chess_${k}_white`, pos: [-0.25 + i * 0.1, 0, 0.08] })),
			...KINDS.map((k, i) => ({ name: `chess_${k}_black`, pos: [-0.25 + i * 0.1, 0, -0.08], rotY: Math.PI })),
			{ name: 'chess_clock', pos: [0.45, 0, 0] },
			{ name: 'chess_hollow_king', pos: [-0.5, 0, 0] },
			{ name: 'chess_briefcase', pos: [0.1, 0, -0.45] },
		],
		cam: { pos: [0.0, 0.6, 1.0], target: [0.0, 0.07, -0.1], fov: 45 },
	},
	carousel_horse: {
		items: [{ name: 'carousel_horse', pos: [0, 0, 0] }, { name: 'npc_alfil', pos: [0, 0.82, -0.22], scale: 0.8 }],
		cam: { pos: [3.0, 2.0, 3.2], target: [0, 1.0, 0], fov: 45 },
	},
};
