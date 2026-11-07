// Props of the "Juguetería El Trompo Loco" (docs/diseno/allanamiento-jugueteria.md): the toy shelf, the counter, the
// train table with its loop and cardboard tunnel, the block castle, the giant teddy bear, the collectors' glass case,
// the ball pit, the giant spinning top of the sign and the delivery van, with origins at the floor in the middle of
// each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

const TOYS = [0xe84a3a, 0xf2c230, 0x3a8ae8, 0x4ac060, 0xb060d8, 0xf08a30, 0x40c8c8, 0xf070b0];

// A toy shelf, 3.0 x 1.8 x 0.6 m, open on both long sides: three boards of boxes, balls, robots and dolls.
export function buildToyShelf() {
	const b = new Builder('toy_shelf');
	const wood = mat('shelf_wood', 0xd8b080), side = mat('shelf_side', 0xe84a3a);
	for (const x of [-1.47, 1.47]) b.add('sides', side, new THREE.BoxGeometry(0.06, 1.8, 0.6), { pos: V(x, 0.9, 0) });
	for (let s = 0; s < 4; s++) b.add('boards', wood, new THREE.BoxGeometry(2.9, 0.04, 0.58), { pos: V(0, 0.08 + s * 0.56, 0) });
	for (let s = 0; s < 3; s++) {
		const y = 0.1 + s * 0.56;
		for (let i = 0; i < 6; i++) {
			const c = (i + s * 3) % TOYS.length, x = -1.15 + i * 0.46, m = mat(`toy_${c}`, TOYS[c]);
			if ((i + s) % 3 === 0) b.add(`toys_${c}`, m, new THREE.BoxGeometry(0.32, 0.36, 0.3), { pos: V(x, y + 0.18, 0) });
			else if ((i + s) % 3 === 1) b.add(`toys_${c}`, m, new THREE.SphereGeometry(0.15, 10, 8), { pos: V(x, y + 0.15, 0) });
			else {
				b.add(`toys_${c}`, m, new THREE.BoxGeometry(0.2, 0.24, 0.16), { pos: V(x, y + 0.12, 0) });
				b.add(`toys_${c}`, m, new THREE.BoxGeometry(0.14, 0.12, 0.14), { pos: V(x, y + 0.3, 0) });
			}
		}
	}
	return b.build();
}

// The counter by the door, 3.0 x 1.0 x 0.9 m: a yellow front with stars and a wooden top. Customers stand on +Z.
export function buildToyCounter() {
	const b = new Builder('toy_counter');
	const yellow = mat('counter_yellow', 0xf2c230), top = mat('counter_top', 0xc89060), star = mat('counter_star', 0x3a8ae8);
	b.add('base', yellow, new THREE.BoxGeometry(3.0, 0.95, 0.9), { pos: V(0, 0.475, 0) });
	b.add('top', top, new THREE.BoxGeometry(3.06, 0.05, 0.96), { pos: V(0, 0.975, 0) });
	for (let i = 0; i < 4; i++) b.add('stars', star, new THREE.OctahedronGeometry(0.12), { pos: V(-1.05 + i * 0.7, 0.55, 0.46), scale: [1, 1, 0.2] });
	return b.build();
}

// The train table, 4.4 x 0.9 x 2.4 m: a green board on legs with an oval track, a little red train and a cardboard
// tunnel over the track's +X curve.
export function buildTrainTable() {
	const b = new Builder('train_table');
	const green = mat('table_green', 0x5ab050), leg = mat('table_leg', 0x8a6040), rail = mat('rail_steel', 0x9aa0a8);
	b.add('board', green, new THREE.BoxGeometry(4.4, 0.08, 2.4), { pos: V(0, 0.86, 0) });
	for (const x of [-2.0, 2.0]) for (const z of [-1.0, 1.0]) b.add('legs', leg, new THREE.BoxGeometry(0.1, 0.82, 0.1), { pos: V(x, 0.41, z) });
	const track = new THREE.TorusGeometry(0.85, 0.035, 4, 32);
	b.add('track', rail, track, { pos: V(0, 0.92, 0), rot: [Math.PI / 2, 0, 0], scale: [2.0, 1.0, 1.0] });
	b.add('tunnel', mat('tunnel_card', 0xc8a070), new THREE.CylinderGeometry(0.4, 0.4, 0.7, 10, 1, true, 0, Math.PI), { pos: V(1.7, 0.9, 0), rot: [0, 0, Math.PI / 2] });
	const red = mat('train_red', 0xe84a3a), black = mat('train_black', 0x2a2a30);
	b.add('engine', red, new THREE.BoxGeometry(0.34, 0.16, 0.16), { pos: V(-0.5, 1.02, 0.85) });
	b.add('chimney', black, new THREE.CylinderGeometry(0.03, 0.03, 0.1, 6), { pos: V(-0.4, 1.14, 0.85) });
	for (let i = 1; i < 3; i++) b.add('cars', mat(`toy_${i + 1}`, TOYS[i + 1]), new THREE.BoxGeometry(0.28, 0.12, 0.15), { pos: V(-0.5 - i * 0.34, 1.0, 0.85) });
	for (const x of [-1.2, 0.9]) b.add('trees', mat('tree_green', 0x2f8a40), new THREE.ConeGeometry(0.12, 0.3, 6), { pos: V(x, 1.05, 0) });
	return b.build();
}

// The block castle on its table, 1.4 x 1.6 x 1.0 m: a low table and a castle of colored blocks with four towers.
export function buildBlockCastle() {
	const b = new Builder('block_castle');
	b.add('table', mat('castle_table', 0xf6f0e4), new THREE.BoxGeometry(1.4, 0.8, 1.0), { pos: V(0, 0.4, 0) });
	for (let i = 0; i < 12; i++) {
		const c = i % TOYS.length, x = -0.45 + (i % 4) * 0.3, z = i < 4 ? -0.3 : i < 8 ? 0.3 : 0;
		if (i >= 8 && (i === 8 || i === 11)) continue;
		b.add(`blocks_${c}`, mat(`toy_${c}`, TOYS[c]), new THREE.BoxGeometry(0.28, 0.24, 0.28), { pos: V(x, 0.92, z) });
	}
	for (const [x, z] of [[-0.45, -0.3], [0.45, -0.3], [-0.45, 0.3], [0.45, 0.3]]) {
		b.add('towers', mat('toy_2', TOYS[2]), new THREE.BoxGeometry(0.26, 0.4, 0.26), { pos: V(x, 1.24, z) });
		b.add('roofs', mat('toy_0', TOYS[0]), new THREE.ConeGeometry(0.2, 0.26, 4), { pos: V(x, 1.57, z), rot: [0, Math.PI / 4, 0] });
	}
	return b.build();
}

// The giant teddy bear by the door, 1.2 x 2.2 x 1.0 m, sitting, with a red bow.
export function buildGiantTeddy() {
	const b = new Builder('giant_teddy');
	const fur = mat('teddy_fur', 0xb07840), light = mat('teddy_light', 0xe8c8a0), dark = mat('teddy_dark', 0x2a1e18);
	b.add('body', fur, new THREE.SphereGeometry(0.55, 12, 10), { pos: V(0, 0.65, 0), scale: [1, 1.15, 0.9] });
	b.add('belly', light, new THREE.SphereGeometry(0.4, 12, 10), { pos: V(0, 0.6, 0.2), scale: [1, 1.1, 0.7] });
	b.add('head', fur, new THREE.SphereGeometry(0.42, 12, 10), { pos: V(0, 1.6, 0) });
	b.add('snout', light, new THREE.SphereGeometry(0.16, 10, 8), { pos: V(0, 1.52, 0.36), scale: [1.2, 0.9, 0.8] });
	b.add('nose', dark, new THREE.SphereGeometry(0.06, 8, 6), { pos: V(0, 1.58, 0.48) });
	for (const x of [-1, 1]) {
		b.add('ears', fur, new THREE.SphereGeometry(0.14, 10, 8), { pos: V(x * 0.32, 1.95, 0), scale: [1, 1, 0.6] });
		b.add('eyes', dark, new THREE.SphereGeometry(0.05, 8, 6), { pos: V(x * 0.14, 1.72, 0.36) });
		b.add('arms', fur, new THREE.SphereGeometry(0.17, 10, 8), { pos: V(x * 0.58, 0.85, 0.15), scale: [1, 1.8, 1] });
		b.add('legs', fur, new THREE.SphereGeometry(0.22, 10, 8), { pos: V(x * 0.32, 0.22, 0.38), scale: [1, 0.9, 1.4] });
	}
	b.add('bow', mat('teddy_bow', 0xe84a3a), new THREE.BoxGeometry(0.4, 0.14, 0.08), { pos: V(0, 1.22, 0.4) });
	return b.build();
}

// The collectors' glass case, 2.4 x 1.8 x 0.6 m: a dark wooden frame, glass and figures on three shelves.
export function buildCollectorCase() {
	const b = new Builder('collector_case');
	const frame = mat('case_frame', 0x4a3020), glass = mat('case_glass', 0xc8e8f8, { transparent: true, opacity: 0.3 });
	b.add('base', frame, new THREE.BoxGeometry(2.4, 0.3, 0.6), { pos: V(0, 0.15, 0) });
	b.add('top', frame, new THREE.BoxGeometry(2.4, 0.06, 0.6), { pos: V(0, 1.77, 0) });
	for (const x of [-1.17, 1.17]) b.add('posts', frame, new THREE.BoxGeometry(0.06, 1.5, 0.6), { pos: V(x, 1.05, 0) });
	b.add('glass', glass, new THREE.BoxGeometry(2.3, 1.44, 0.02), { pos: V(0, 1.02, 0.29) });
	for (let s = 0; s < 3; s++) {
		const y = 0.3 + s * 0.48;
		b.add('shelves', glass, new THREE.BoxGeometry(2.3, 0.02, 0.5), { pos: V(0, y, 0) });
		for (let i = 0; i < 5; i++) {
			const c = (i * 3 + s) % TOYS.length, x = -0.9 + i * 0.45;
			b.add(`figures_${c}`, mat(`toy_${c}`, TOYS[c]), new THREE.CylinderGeometry(0.06, 0.08, 0.22, 8), { pos: V(x, y + 0.12, 0) });
			b.add(`figures_${c}`, mat(`toy_${c}`, TOYS[c]), new THREE.SphereGeometry(0.06, 8, 6), { pos: V(x, y + 0.28, 0) });
		}
	}
	return b.build();
}

// The ball pit, 4.0 x 0.6 x 4.0 m: a padded blue rim, a sea of colored balls and a little yellow slide.
export function buildBallPit() {
	const b = new Builder('ball_pit');
	const pad = mat('pit_pad', 0x3a8ae8);
	for (const z of [-1.9, 1.9]) b.add('rim', pad, new THREE.BoxGeometry(4.0, 0.6, 0.2), { pos: V(0, 0.3, z) });
	for (const x of [-1.9, 1.9]) b.add('rim', pad, new THREE.BoxGeometry(0.2, 0.6, 3.6), { pos: V(x, 0.3, 0) });
	b.add('floor', mat('pit_floor', 0x2a60b0), new THREE.BoxGeometry(3.6, 0.3, 3.6), { pos: V(0, 0.15, 0) });
	for (let i = 0; i < 90; i++) {
		const c = i % 5, x = -1.6 + ((i * 7) % 15) * 0.23, z = -1.6 + ((i * 11) % 14) * 0.245;
		b.add(`balls_${c}`, mat(`toy_${c}`, TOYS[c]), new THREE.SphereGeometry(0.1, 6, 4), { pos: V(x, 0.42 + ((i * 13) % 3) * 0.04, z) });
	}
	b.add('slide', mat('slide_yellow', 0xf2c230), new THREE.BoxGeometry(0.6, 0.06, 1.6), { pos: V(1.4, 0.75, 1.0), rot: [-0.55, 0, 0] });
	b.add('ladder', mat('slide_ladder', 0xe84a3a), new THREE.BoxGeometry(0.6, 1.2, 0.1), { pos: V(1.4, 0.6, 0.2) });
	return b.build();
}

// The giant spinning top of the sign, 1.2 x 1.6 x 1.2 m, striped in red, yellow and blue, standing on its tip.
export function buildGiantTop() {
	const b = new Builder('giant_top');
	b.add('tip', mat('top_tip', 0x2a2a30), new THREE.ConeGeometry(0.08, 0.2, 8), { pos: V(0, 0.1, 0), rot: [Math.PI, 0, 0] });
	const bands = [0xe84a3a, 0xf2c230, 0x3a8ae8];
	for (let i = 0; i < 3; i++) {
		const r0 = 0.1 + i * 0.17, r1 = 0.27 + i * 0.17;
		b.add(`bands_${i}`, mat(`top_band_${i}`, bands[i]), new THREE.CylinderGeometry(r1, r0, 0.2, 14), { pos: V(0, 0.3 + i * 0.2, 0) });
	}
	b.add('crown', mat('top_band_0', bands[0]), new THREE.CylinderGeometry(0.3, 0.6, 0.3, 14), { pos: V(0, 1.05, 0) });
	b.add('handle', mat('top_handle', 0xc89060), new THREE.CylinderGeometry(0.05, 0.05, 0.4, 8), { pos: V(0, 1.4, 0) });
	return b.build();
}

// The delivery van, 2.0 x 2.2 x 4.6 m, its front to +Z: a yellow box with a red stripe, the cab and four wheels.
export function buildToyVan() {
	const b = new Builder('toy_van');
	const yellow = mat('van_yellow', 0xf2c230), red = mat('van_red', 0xe84a3a), glass = mat('van_glass', 0x2a3a50), tire = mat('van_tire', 0x1a1a1e);
	b.add('box', yellow, new THREE.BoxGeometry(2.0, 1.7, 3.2), { pos: V(0, 1.25, -0.6) });
	b.add('cab', yellow, new THREE.BoxGeometry(2.0, 1.3, 1.4), { pos: V(0, 1.05, 1.6) });
	b.add('windshield', glass, new THREE.BoxGeometry(1.8, 0.5, 0.04), { pos: V(0, 1.4, 2.31) });
	b.add('stripe', red, new THREE.BoxGeometry(2.02, 0.2, 4.4), { pos: V(0, 0.95, 0) });
	for (const x of [-0.95, 0.95]) for (const z of [-1.5, 1.5]) b.add('wheels', tire, new THREE.CylinderGeometry(0.38, 0.38, 0.28, 12), { pos: V(x, 0.38, z), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// Don Cucho, the owner: an old man, thin and tall, a cap with a propeller, a vest full of pockets with batteries in
// them and a magnifier hanging from his neck. The game scales him tall.
export function buildDonCucho() {
	const b = new Builder('npc_don_cucho');
	pearBody(b, mat('skin_cucho', 0xe8c0a0), { shirt: mat('cucho_shirt', 0xe8e0c8), pants: mat('cucho_pants', 0x6a5a48), shoes: M.black, belted: false });
	const vest = mat('cucho_vest', 0x5a7a40), pocket = mat('cucho_pocket', 0x4a6630);
	b.add('vest', vest, new THREE.BoxGeometry(0.62, 0.42, 0.06), { pos: V(0, 0.74, 0.33), rot: [-0.18, 0, 0] });
	for (const [x, y] of [[-0.17, 0.66], [0.17, 0.66], [-0.17, 0.84], [0.17, 0.84]]) {
		b.add('pockets', pocket, new THREE.BoxGeometry(0.14, 0.11, 0.03), { pos: V(x, y, 0.37), rot: [-0.18, 0, 0] });
	}
	b.add('batteries', mat('battery', 0xe8c030), new THREE.CylinderGeometry(0.02, 0.02, 0.08, 6), { pos: V(-0.2, 0.87, 0.38) });
	b.add('batteries', mat('battery', 0xe8c030), new THREE.CylinderGeometry(0.02, 0.02, 0.08, 6), { pos: V(0.14, 0.69, 0.4) });
	eyes(b, 1.34, 0.18, 0.08, 0.05);
	b.add('beard', mat('cucho_beard', 0xd8d8dc), ellipsoid(0.15, 0.07, 0.08, 8, 4), { pos: V(0, 1.18, 0.15) });
	const capRed = mat('cucho_cap', 0xe84a3a), capBlue = mat('cucho_cap_b', 0x3a8ae8);
	b.add('cap', capRed, new THREE.SphereGeometry(0.2, 10, 5, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(0, 1.42, 0.01) });
	b.add('cap', capBlue, new THREE.CylinderGeometry(0.15, 0.15, 0.02, 10, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 1.43, 0.14) });
	b.add('propeller', mat('cucho_stick', 0x2a2a30), new THREE.CylinderGeometry(0.012, 0.012, 0.12, 5), { pos: V(0, 1.68, 0.01) });
	b.add('propeller', mat('cucho_blade', 0xf2c230), new THREE.BoxGeometry(0.4, 0.015, 0.06), { pos: V(0, 1.74, 0.01), rot: [0, 0.4, 0.1] });
	b.add('magnifier', mat('lens_rim', 0x2a2a30), new THREE.TorusGeometry(0.06, 0.012, 5, 12), { pos: V(0.05, 0.98, 0.38) });
	b.add('magnifier', mat('lens_glass', 0xc8e8f8, { transparent: true, opacity: 0.5 }), new THREE.CircleGeometry(0.06, 12), { pos: V(0.05, 0.98, 0.385) });
	return b.build();
}

// Doña Ramona, the grandmother of 14: a purple cardigan, a grey bun, round glasses and a big shopping bag full of
// gifts on her arm. The game scales her small.
export function buildDonaRamona() {
	const b = new Builder('npc_dona_ramona');
	pearBody(b, mat('skin_ramona', 0xe8b898), { shirt: mat('ramona_cardigan', 0x8a5ab0), pants: mat('ramona_skirt', 0x4a4a6a), shoes: M.black, belted: false });
	for (const x of [-0.06, 0.06]) b.add('buttons', mat('ramona_button', 0xf2e8d8), new THREE.SphereGeometry(0.018, 6, 4), { pos: V(0, 0.62 + x, 0.4) });
	eyes(b, 1.34, 0.18, 0.08, 0.05);
	const rim = mat('ramona_glasses', 0x2a2a30);
	for (const x of [-0.08, 0.08]) b.add('glasses', rim, new THREE.TorusGeometry(0.055, 0.01, 4, 10), { pos: V(x, 1.34, 0.2) });
	const hair = mat('ramona_hair', 0xd0d0d4);
	b.add('hair', hair, ellipsoid(0.21, 0.11, 0.2, 10, 5), { pos: V(0, 1.43, -0.02) });
	b.add('hair', hair, new THREE.SphereGeometry(0.09, 8, 6), { pos: V(0, 1.5, -0.14) });
	b.add('bag', mat('ramona_bag', 0xe8d8b0), new THREE.BoxGeometry(0.34, 0.32, 0.16), { pos: V(-0.55, 0.42, 0.08) });
	b.add('bag', mat('ramona_handle', 0x8a6040), new THREE.TorusGeometry(0.1, 0.012, 4, 10, Math.PI), { pos: V(-0.55, 0.58, 0.08) });
	for (const [x, y, c] of [[-0.62, 0.62, 0xe84a3a], [-0.5, 0.64, 0x3a8ae8], [-0.56, 0.68, 0xf2c230]]) {
		b.add(`gifts_${c.toString(16)}`, mat(`gift_${c.toString(16)}`, c), new THREE.BoxGeometry(0.1, 0.1, 0.1), { pos: V(x, y, 0.08) });
	}
	return b.build();
}

export const models = {
	toy_shelf: buildToyShelf, toy_counter: buildToyCounter, train_table: buildTrainTable, block_castle: buildBlockCastle,
	giant_teddy: buildGiantTeddy, collector_case: buildCollectorCase, ball_pit: buildBallPit, giant_top: buildGiantTop,
	toy_van: buildToyVan, npc_don_cucho: buildDonCucho, npc_dona_ramona: buildDonaRamona,
};

export const views = {
	toy_store: {
		items: [
			{ name: 'toy_shelf', pos: [-2.6, 0, -1.4] }, { name: 'toy_counter', pos: [2.4, 0, 1.6] },
			{ name: 'train_table', pos: [1.6, 0, -1.6] }, { name: 'block_castle', pos: [-2.6, 0, 1.6] },
			{ name: 'giant_teddy', pos: [-0.4, 0, 1.0] }, { name: 'collector_case', pos: [5.0, 0, -1.0] },
			{ name: 'ball_pit', pos: [-6.0, 0, 0.0] }, { name: 'giant_top', pos: [4.8, 0, 1.8] },
			{ name: 'npc_don_cucho', pos: [3.4, 0, 2.4], rotY: -0.3 },
			{ name: 'npc_dona_ramona', pos: [-4.4, 0, 2.4], rotY: 0.3 },
		],
		cam: { pos: [-0.5, 4.5, 9.5], target: [-0.5, 0.8, 0], fov: 55 },
	},
};
