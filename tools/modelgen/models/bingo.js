// The grandpa's illegal bingo (case 1.1, decision 75): betting book, bingo cage and bingo cards. Centered on their
// collision boxes in scenes/props/*.tscn. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

const gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });

// Betting book (libreta de apuestas): 0.16 x 0.03 x 0.22 m, red cover with a spiral on the left.
export function buildBettingBook() {
	const cover = mat('book_red', 0xd8343c), pages = mat('paper', 0xf6f0dc), wire = mat('wire', 0xc8ccd4);
	const b = new Builder('betting_book');
	b.add('book', cover, new THREE.BoxGeometry(0.16, 0.008, 0.22), { pos: V(0, 0.011, 0) });
	b.add('book', cover, new THREE.BoxGeometry(0.16, 0.008, 0.22), { pos: V(0, -0.011, 0) });
	b.add('book', pages, new THREE.BoxGeometry(0.15, 0.016, 0.21), { pos: V(0.003, 0, 0) });
	for (let i = 0; i < 7; i++) b.add('book', wire, new THREE.TorusGeometry(0.014, 0.003, 4, 8), { pos: V(-0.08, 0, -0.09 + i * 0.03), rot: [0, Math.PI / 2, 0] });
	b.add('book', gold, new THREE.BoxGeometry(0.07, 0.002, 0.03), { pos: V(0.01, 0.016, -0.05) });
	return b.build();
}

// Bingo cage (bolillero): 0.5 x 0.6 x 0.4 m, 30 kg. A wire drum full of balls on a wooden stand, with a crank.
export function buildBingoCage() {
	const wood = mat('wood', 0xc58a4e), wire = mat('cage_wire', 0xe8c84a, { emissive: 0x2a2005 }), dark = mat('wood_dark', 0x8a5a30);
	const b = new Builder('bingo_cage');
	const base = -0.26;
	b.add('stand', wood, new THREE.BoxGeometry(0.5, 0.08, 0.4), { pos: V(0, base, 0) });
	for (const x of [-1, 1]) b.add('stand', dark, new THREE.BoxGeometry(0.04, 0.32, 0.06), { pos: V(x * 0.22, base + 0.18, 0) });
	const cy = 0.06;
	// Drum: rings around the X axle and bars along it.
	for (const x of [-0.18, -0.06, 0.06, 0.18]) b.add('cage', wire, new THREE.TorusGeometry(0.17, 0.008, 4, 12), { pos: V(x, cy, 0), rot: [0, Math.PI / 2, 0] });
	for (let i = 0; i < 8; i++) {
		const a = (i / 8) * Math.PI * 2;
		b.add('cage', wire, new THREE.CylinderGeometry(0.007, 0.007, 0.38, 4), { pos: V(0, cy + Math.sin(a) * 0.17, Math.cos(a) * 0.17), rot: [0, 0, Math.PI / 2] });
	}
	b.add('cage', dark, new THREE.CylinderGeometry(0.015, 0.015, 0.5, 6), { pos: V(0, cy, 0), rot: [0, 0, Math.PI / 2] });
	// Crank on the right.
	b.add('crank', dark, new THREE.BoxGeometry(0.02, 0.12, 0.02), { pos: V(0.26, cy - 0.05, 0) });
	b.add('crank', wood, new THREE.CylinderGeometry(0.02, 0.02, 0.06, 6), { pos: V(0.29, cy - 0.11, 0), rot: [0, 0, Math.PI / 2] });
	// Balls inside, in party colors.
	const colors = [0xff4d6d, 0x4dabff, 0x7ee05c, 0xffd23f, 0xac8cff, 0xffffff];
	for (let i = 0; i < 14; i++) {
		const ball = mat(`ball_${i % colors.length}`, colors[i % colors.length]);
		const a = i * 2.4, r = 0.05 + (i % 3) * 0.03;
		b.add('balls', ball, new THREE.SphereGeometry(0.03, 6, 4), { pos: V(-0.13 + (i % 5) * 0.065, cy - 0.11 + Math.abs(Math.sin(a)) * r * 0.6, Math.cos(a) * r) });
	}
	return b.build();
}

// Bingo card (cartón): 0.18 x 0.005 x 0.12 m, a cream card with a 3 x 5 grid and a few marked numbers.
export function buildBingoCard() {
	const card = mat('card', 0xf6f0dc), cell = mat('card_green', 0x3fae6a), mark = mat('card_mark', 0xff4d6d);
	const b = new Builder('bingo_card');
	b.add('card', card, new THREE.BoxGeometry(0.18, 0.005, 0.12));
	for (let r = 0; r < 3; r++) for (let c = 0; c < 5; c++) {
		const m = (r * 5 + c) % 4 === 1 ? mark : cell;
		b.add('card', m, new THREE.BoxGeometry(0.026, 0.002, 0.026), { pos: V(-0.068 + c * 0.034, 0.003, -0.034 + r * 0.034) });
	}
	return b.build();
}

export const models = { betting_book: buildBettingBook, bingo_cage: buildBingoCage, bingo_card: buildBingoCard };

export const views = {
	bingo: {
		items: [{ name: 'bingo_cage', pos: [0, 0.3, 0], rotY: -0.5 }, { name: 'betting_book', pos: [0.55, 0.015, 0.4], rotY: 0.3 },
			{ name: 'bingo_card', pos: [-0.5, 0.003, 0.45], rotY: -0.2 }, { name: 'bingo_card', pos: [-0.3, 0.003, 0.6], rotY: 0.5 },
			{ name: 'safe', pos: [1.2, 0.32, -0.2], rotY: -0.4 }, { name: 'cop_0', pos: [-1.3, 0, -0.4], rotY: 0.4 }],
		cam: { pos: [0, 1.4, 3.2], target: [0, 0.4, 0], fov: 32 },
	},
};
