// The parade traffic check (docs/diseno/control-desfile.md): the float (a low truck under a painted skirt with a gold
// fringe), the seven themes that ride on its front, the masked dancers on its back with their arms apart (so the game
// can dance them) and what they hold. Placeholder, not final art.
import { Builder, loft, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, eyes, limb, belt } from './pear.js';

const black = mat('car_black', 0x23252b), grey = mat('car_grey', 0x6b7280), gold = M.gold;
const glass = mat('lamp', 0xfff3c0, { emissive: 0x806a20 }), tail = mat('tail', 0xd01828, { emissive: 0x500810 });
const C = (name, color, opts) => mat(name, color, opts);
// The float: this wide and long like the traffic cars, its deck at DECK. Themes sit on the front FRONT_L meters.
const W = 2.3, L = 4.6, DECK = 0.9, FRONT_L = 1.9;

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// Faces +Z, origin on the ground, 4.6 m long. The skirt is `paint` (white, so the game tints it per float) down to
// the street, hiding the wheels and the driver inside; a gold fringe runs round the deck and the number sign is the
// game's. Lamps peek out of the skirt in front, tail lights at the back.
export function buildParadeFloat() {
	const paint = mat('float_paint', 0xf2f2ee);
	const b = new Builder('parade_float');
	box(b, 'body', black, W - 0.2, 0.3, L - 0.2, 0, 0.35, 0);
	box(b, 'paint', paint, W, DECK - 0.15, L, 0, (DECK + 0.15) / 2, 0);
	box(b, 'deck', grey, W + 0.06, 0.08, L + 0.06, 0, DECK, 0);
	for (const x of [-1, 1]) {
		for (let i = 0; i < 18; i++) {
			const z = -L / 2 + 0.13 + i * (L - 0.26) / 17;
			b.add('fringe', gold, new THREE.ConeGeometry(0.06, 0.18, 4), { pos: V(x * (W / 2 + 0.04), DECK - 0.13, z), rot: [Math.PI, 0, 0] });
		}
	}
	for (const z of [-1, 1]) {
		for (let i = 0; i < 9; i++) {
			const x = -W / 2 + 0.13 + i * (W - 0.26) / 8;
			b.add('fringe', gold, new THREE.ConeGeometry(0.06, 0.18, 4), { pos: V(x, DECK - 0.13, z * (L / 2 + 0.04)), rot: [Math.PI, 0, 0] });
		}
	}
	// Big polka dots on the skirt, and a low gold rail round the dancers' half.
	const dot = C('float_dot', 0xfff6d8);
	for (const x of [-1, 1]) for (let i = 0; i < 4; i++) {
		b.add('body', dot, new THREE.CylinderGeometry(0.14, 0.14, 0.02, 10), { pos: V(x * (W / 2 + 0.01), 0.5 + (i % 2) * 0.15, -1.7 + i * 1.1), rot: [0, 0, Math.PI / 2] });
	}
	const rail = (x0, z0, x1, z1) => limb(b, 'rail', gold, V(x0, DECK + 0.35, z0), V(x1, DECK + 0.35, z1), 0.025);
	rail(-W / 2 + 0.05, -L / 2 + 0.05, W / 2 - 0.05, -L / 2 + 0.05);
	for (const x of [-1, 1]) {
		rail(x * (W / 2 - 0.05), -L / 2 + 0.05, x * (W / 2 - 0.05), L / 2 - FRONT_L);
		for (let i = 0; i < 4; i++) {
			const z = -L / 2 + 0.05 + i * (L - FRONT_L - 0.05) / 3;
			limb(b, 'rail', gold, V(x * (W / 2 - 0.05), DECK, z), V(x * (W / 2 - 0.05), DECK + 0.35, z), 0.02);
		}
	}
	for (const x of [-1, 1]) {
		box(b, 'lights', glass, 0.3, 0.14, 0.04, x * 0.75, 0.35, L / 2 + 0.01);
		box(b, 'lights', tail, 0.25, 0.12, 0.04, x * 0.75, 0.35, -L / 2 - 0.01);
	}
	return b.build();
}

// The themes, each on the float's front half: origin on the deck's front-half middle, facing +Z, about 2.2 m wide,
// 1.8 m long and up to 2.2 m tall. Their main color is `paint`-free: each theme has its own.
export function buildFloatDragon() {
	const b = new Builder('float_dragon');
	const green = C('dragon_green', 0x3aa04a), belly = C('dragon_belly', 0xf0d050), red = C('dragon_red', 0xe0302a);
	b.add('body', green, ellipsoid(0.6, 0.45, 0.8, 10, 7), { pos: V(0, 0.45, -0.1) });
	b.add('body', belly, ellipsoid(0.45, 0.3, 0.6, 10, 6), { pos: V(0, 0.3, 0.05) });
	limb(b, 'body', green, V(0, 0.7, 0.4), V(0, 1.5, 0.6), 0.22, 8);
	b.add('head', green, ellipsoid(0.32, 0.25, 0.42, 10, 7), { pos: V(0, 1.6, 0.75) });
	b.add('head', red, new THREE.ConeGeometry(0.22, 0.4, 6), { pos: V(0, 1.55, 1.25), rot: [Math.PI / 2, 0, 0] });
	for (const s of [-1, 1]) {
		eyesAt(b, s * 0.17, 1.75, 0.9, 0.08);
		b.add('head', belly, new THREE.ConeGeometry(0.06, 0.3, 5), { pos: V(s * 0.15, 1.95, 0.55), rot: [-0.5, 0, s * 0.2] });
		const wing = new THREE.Shape([new THREE.Vector2(0, 0), new THREE.Vector2(0.9, 0.5), new THREE.Vector2(0.7, -0.1),
			new THREE.Vector2(0.95, -0.3), new THREE.Vector2(0.4, -0.25)]);
		b.add('wings', red, new THREE.ExtrudeGeometry(wing, { depth: 0.04, bevelEnabled: false }), { pos: V(s * 0.45, 0.85, -0.1), rot: [0, s > 0 ? -Math.PI / 2 : Math.PI / 2, 0], scale: [1, 1, 1] });
	}
	for (let i = 0; i < 4; i++) b.add('body', red, new THREE.ConeGeometry(0.1, 0.25, 4), { pos: V(0, 0.92 - i * 0.05, -0.7 + i * 0.35) });
	return b.build();
}

function eyesAt(b, x, y, z, size) {
	b.add('face', M.white, ellipsoid(size, size * 1.1, size * 0.6, 8, 6), { pos: V(x, y, z) });
	b.add('face', M.black, ellipsoid(size * 0.5, size * 0.6, size * 0.3, 6, 4), { pos: V(x, y, z + size * 0.45) });
}

export function buildFloatShip() {
	const b = new Builder('float_ship');
	const wood = C('ship_wood', 0x8a5a2a), dark = C('ship_dark', 0x4a2e14), sail = C('ship_sail', 0xf4f0e0);
	b.add('hull', wood, loft([{ y: 0, rx: 0.6, rz: 0.8 }, { y: 0.5, rx: 1.0, rz: 0.95 }, { y: 0.6, rx: 1.05, rz: 0.95 }], 10, { capBottom: true, capTop: true }));
	box(b, 'hull', dark, 2.1, 0.08, 0.08, 0, 0.62, 0.9);
	limb(b, 'mast', dark, V(0, 0.6, -0.1), V(0, 2.2, -0.1), 0.05);
	limb(b, 'mast', dark, V(-0.7, 1.9, -0.1), V(0.7, 1.9, -0.1), 0.03);
	b.add('sail', sail, new THREE.BoxGeometry(1.3, 1.0, 0.04), { pos: V(0, 1.4, -0.05), scale: [1, 1, 1] });
	b.add('flag', black, new THREE.BoxGeometry(0.35, 0.22, 0.02), { pos: V(0.18, 2.1, -0.1) });
	b.add('flag', M.white, ellipsoid(0.05, 0.05, 0.02, 6, 4), { pos: V(0.15, 2.12, -0.08) });
	for (const x of [-0.5, 0, 0.5]) b.add('hull', black, new THREE.CylinderGeometry(0.08, 0.08, 0.04, 8), { pos: V(x, 0.35, 0.88), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

export function buildFloatCake() {
	const b = new Builder('float_cake');
	const sponge = C('cake_pink', 0xf2a0c0), cream = C('cake_cream', 0xfff6e8), cherry = C('cake_cherry', 0xd01830);
	const tiers = [[0.95, 0.5], [0.7, 0.45], [0.45, 0.4]];
	let y = 0;
	for (const [r, h] of tiers) {
		b.add('cake', sponge, new THREE.CylinderGeometry(r, r, h, 14), { pos: V(0, y + h / 2, 0) });
		b.add('cake', cream, new THREE.TorusGeometry(r, 0.06, 5, 14), { pos: V(0, y + h, 0), rot: [Math.PI / 2, 0, 0] });
		y += h;
	}
	b.add('cake', cherry, new THREE.SphereGeometry(0.16, 10, 8), { pos: V(0, y + 0.14, 0) });
	for (let i = 0; i < 5; i++) {
		const a = i / 5 * Math.PI * 2;
		limb(b, 'candles', C('candle', 0x6ab0f0), V(Math.cos(a) * 0.3, y, Math.sin(a) * 0.3), V(Math.cos(a) * 0.3, y + 0.25, Math.sin(a) * 0.3), 0.03);
		b.add('candles', glass, new THREE.ConeGeometry(0.03, 0.08, 5), { pos: V(Math.cos(a) * 0.3, y + 0.32, Math.sin(a) * 0.3) });
	}
	return b.build();
}

export function buildFloatCastle() {
	const b = new Builder('float_castle');
	const stone = C('castle_stone', 0xc8c0b0), roof = C('castle_roof', 0x3a5ad8), door = C('castle_door', 0x6a4220);
	box(b, 'walls', stone, 1.6, 0.9, 1.0, 0, 0.45, 0);
	for (let i = 0; i < 5; i++) box(b, 'walls', stone, 0.18, 0.18, 1.0, -0.7 + i * 0.35, 0.99, 0);
	for (const x of [-1, 1]) {
		b.add('towers', stone, new THREE.CylinderGeometry(0.3, 0.3, 1.5, 10), { pos: V(x * 0.85, 0.75, 0.1) });
		b.add('towers', roof, new THREE.ConeGeometry(0.38, 0.6, 10), { pos: V(x * 0.85, 1.8, 0.1) });
		b.add('flags', C('castle_flag', 0xe0302a), new THREE.BoxGeometry(0.2, 0.12, 0.02), { pos: V(x * 0.85 + 0.1, 2.2, 0.1) });
	}
	box(b, 'walls', door, 0.4, 0.55, 0.04, 0, 0.28, 0.51);
	return b.build();
}

export function buildFloatVolcano() {
	const b = new Builder('float_volcano');
	const rock = C('volcano_rock', 0x6a4a3a), lava = C('lava', 0xff6a1a, { emissive: 0x802a00 });
	b.add('mountain', rock, new THREE.CylinderGeometry(0.35, 1.0, 1.6, 10, 1, true), { pos: V(0, 0.8, 0) });
	b.add('mountain', lava, new THREE.CylinderGeometry(0.33, 0.33, 0.05, 10), { pos: V(0, 1.58, 0) });
	for (let i = 0; i < 4; i++) {
		const a = i / 4 * Math.PI * 2 + 0.4;
		b.add('lava', lava, ellipsoid(0.1, 0.5, 0.06, 6, 4), { pos: V(Math.cos(a) * 0.55, 1.05, Math.sin(a) * 0.55), rot: [Math.sin(a) * 0.5, 0, -Math.cos(a) * 0.5] });
	}
	for (let i = 0; i < 3; i++) b.add('smoke', C('smoke', 0xd8d4d0), new THREE.SphereGeometry(0.2 + i * 0.05, 8, 6), { pos: V(0.1 * i, 1.8 + i * 0.25, -0.05 * i) });
	return b.build();
}

export function buildFloatWhale() {
	const b = new Builder('float_whale');
	const blue = C('whale_blue', 0x3a6ab8), belly = C('whale_belly', 0xd8e4f0), water = C('spout', 0x9ad0f0);
	b.add('body', blue, ellipsoid(0.8, 0.6, 0.95, 12, 8), { pos: V(0, 0.6, 0) });
	b.add('body', belly, ellipsoid(0.65, 0.35, 0.8, 12, 6), { pos: V(0, 0.35, 0.1) });
	for (const s of [-1, 1]) {
		eyesAt(b, s * 0.42, 0.75, 0.75, 0.08);
		b.add('body', blue, ellipsoid(0.35, 0.05, 0.15, 6, 3), { pos: V(s * 0.85, 0.4, 0.2), rot: [0, s * 0.4, s * 0.5] });
	}
	b.add('body', blue, ellipsoid(0.5, 0.06, 0.18, 8, 3), { pos: V(0, 0.85, -0.95), rot: [0.5, 0, 0] });
	for (let i = 0; i < 5; i++) {
		const a = i / 5 * Math.PI * 2;
		b.add('spout', water, ellipsoid(0.05, 0.25, 0.05, 5, 4), { pos: V(Math.cos(a) * 0.12, 1.5, Math.sin(a) * 0.12 - 0.1), rot: [Math.sin(a) * 0.5, 0, -Math.cos(a) * 0.5] });
	}
	return b.build();
}

export function buildFloatRocket() {
	const b = new Builder('float_rocket');
	const body = C('rocket_white', 0xf0f0f4), red = C('rocket_red', 0xe0302a), win = C('rocket_window', 0x5ab0f0);
	b.add('rocket', body, new THREE.CylinderGeometry(0.4, 0.4, 1.4, 12), { pos: V(0, 0.9, 0) });
	b.add('rocket', red, new THREE.ConeGeometry(0.4, 0.7, 12), { pos: V(0, 1.95, 0) });
	b.add('rocket', win, new THREE.CylinderGeometry(0.15, 0.15, 0.05, 10), { pos: V(0, 1.2, 0.4), rot: [Math.PI / 2, 0, 0] });
	for (let i = 0; i < 3; i++) {
		const a = i / 3 * Math.PI * 2;
		b.add('fins', red, new THREE.BoxGeometry(0.05, 0.6, 0.45), { pos: V(Math.sin(a) * 0.5, 0.4, Math.cos(a) * 0.5), rot: [0, a, 0] });
	}
	b.add('fire', C('rocket_fire', 0xffb020, { emissive: 0x804000 }), new THREE.ConeGeometry(0.25, 0.4, 8), { pos: V(0, 0.15, 0), rot: [Math.PI, 0, 0] });
	return b.build();
}

// A dancer, 0.7 times a person on the pear body without arms (parade_arm is each arm, so the game can dance them):
// a sequined costume (`paint`, white so the game tints it per float), a feathered headdress and the eye mask (the
// antifaz, `mask`, white so the game tints it per dancer). Faces +Z, feet at y = 0, 1.55 m like the others before the
// game scales it.
export function buildParadeDancer() {
	const b = new Builder('parade_dancer');
	const costume = mat('dancer_paint', 0xf2f2ee), skin = mat('skin_arena', 0xd9a06b);
	b.add('paint', costume, loft([
		{ y: 0.1, rx: 0.36, rz: 0.32 }, { y: 0.3, rx: 0.48, rz: 0.43 }, { y: 0.5, rx: 0.46, rz: 0.41 },
		{ y: 0.8, rx: 0.36, rz: 0.32 }, { y: 1.05, rx: 0.24, rz: 0.22 }, { y: 1.15, rx: 0.15, rz: 0.14 },
	], 10, { capBottom: true, capTop: true }));
	belt(b, 0.52, 0.465, 0.415);
	for (const [x, y] of [[-0.2, 0.75], [0.15, 0.9], [0.02, 0.62], [-0.1, 0.98], [0.25, 0.68], [-0.3, 0.4], [0.3, 0.3]]) {
		b.add('body', gold, new THREE.OctahedronGeometry(0.025), { pos: V(x, y, 0.33 + (0.5 - y) * 0.15) });
	}
	b.add('head', skin, ellipsoid(0.2, 0.22, 0.19, 10, 7), { pos: V(0, 1.3, 0.02) });
	eyes(b, 1.33, 0.17, 0.08, 0.05);
	b.add('mask', mat('mask_paint', 0xf2f2ee), ellipsoid(0.2, 0.07, 0.06, 10, 4), { pos: V(0, 1.34, 0.15) });
	b.add('face', C('mouth', 0x5a1420), new THREE.TorusGeometry(0.05, 0.012, 4, 8, Math.PI), { pos: V(0, 1.22, 0.19), rot: [0, 0, Math.PI] });
	b.add('head', gold, new THREE.TorusGeometry(0.17, 0.025, 4, 12), { pos: V(0, 1.45, 0.0), rot: [Math.PI / 2 - 0.2, 0, 0] });
	const feather = [C('feather_pink', 0xe84a9a), C('feather_blue', 0x4ab0e8), C('feather_yellow', 0xf0d040)];
	for (let i = 0; i < 5; i++) {
		const a = (i - 2) * 0.35;
		b.add('head', feather[i % 3], ellipsoid(0.05, 0.25, 0.02, 5, 4), { pos: V(Math.sin(a) * 0.2, 1.68, -0.05), rot: [0, 0, -a] });
	}
	for (const s of [-1, 1]) b.add('legs', M.black, ellipsoid(0.14, 0.08, 0.2, 6, 4), { pos: V(s * 0.2, 0.07, 0.12) });
	return b.build();
}

// One of a dancer's arms, its right one (the game mirrors it for the left): origin at the shoulder, hanging down and a
// bit out, the hand at (0.16, -0.22, 0.08). The sleeve is `paint` like the costume.
export function buildParadeArm() {
	const b = new Builder('parade_arm');
	limb(b, 'paint', mat('dancer_paint', 0xf2f2ee), V(0, 0, 0), V(0.14, -0.19, 0.07), 0.06);
	b.add('arms', mat('skin_arena', 0xd9a06b), ellipsoid(0.075, 0.075, 0.075, 6, 4), { pos: V(0.16, -0.22, 0.08) });
	return b.build();
}

// What the dancers hold, in the hand (origin at the grip): pompoms, maracas, a fan and a ribbon on a stick.
export function buildHeldPompom() {
	const b = new Builder('held_pompom');
	const red = C('pompom', 0xf0f0f0);
	for (let i = 0; i < 9; i++) {
		const a = i / 9 * Math.PI * 2;
		b.add('paint', red, ellipsoid(0.03, 0.12, 0.03, 4, 3), { pos: V(Math.cos(a) * 0.05, -0.05, Math.sin(a) * 0.05), rot: [Math.sin(a) * 0.8, 0, -Math.cos(a) * 0.8] });
	}
	b.add('paint', red, new THREE.SphereGeometry(0.08, 8, 6), { pos: V(0, -0.03, 0) });
	return b.build();
}

export function buildHeldMaracas() {
	const b = new Builder('held_maracas');
	limb(b, 'handle', C('maraca_wood', 0x8a5a2a), V(0, 0.04, 0), V(0, -0.06, 0), 0.015);
	b.add('paint', C('maraca', 0xf0f0f0), ellipsoid(0.06, 0.08, 0.06, 8, 6), { pos: V(0, 0.12, 0) });
	b.add('body', gold, new THREE.TorusGeometry(0.06, 0.008, 4, 10), { pos: V(0, 0.12, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

export function buildHeldFan() {
	const b = new Builder('held_fan');
	const fan = C('fan', 0xf0f0f0);
	for (let i = 0; i < 7; i++) {
		const a = (i - 3) * 0.25;
		b.add('paint', fan, new THREE.BoxGeometry(0.06, 0.22, 0.008), { pos: V(Math.sin(a) * 0.11, 0.11 * Math.cos(a), 0), rot: [0, 0, -a] });
	}
	b.add('body', gold, new THREE.SphereGeometry(0.015, 6, 4), { pos: V(0, 0, 0) });
	return b.build();
}

export function buildHeldRibbon() {
	const b = new Builder('held_ribbon');
	limb(b, 'handle', C('ribbon_stick', 0x2a2a30), V(0, -0.05, 0), V(0, 0.3, 0), 0.01);
	for (let i = 0; i < 6; i++) {
		b.add('paint', C('ribbon', 0xf0f0f0), new THREE.BoxGeometry(0.03, 0.12, 0.005), { pos: V(0.05 + i * 0.06, 0.28 - Math.sin(i) * 0.08, 0), rot: [0, 0, 0.6 + Math.cos(i) * 0.6] });
	}
	return b.build();
}

export const models = {
	parade_float: buildParadeFloat, float_dragon: buildFloatDragon, float_ship: buildFloatShip, float_cake: buildFloatCake,
	float_castle: buildFloatCastle, float_volcano: buildFloatVolcano, float_whale: buildFloatWhale,
	float_rocket: buildFloatRocket, parade_dancer: buildParadeDancer, parade_arm: buildParadeArm,
	held_pompom: buildHeldPompom, held_maracas: buildHeldMaracas, held_fan: buildHeldFan, held_ribbon: buildHeldRibbon,
};

const dancers = [[-0.6, -1.9], [0, -1.9], [0.6, -1.9], [-0.35, -1.1], [0.35, -1.1]].flatMap(([x, z]) => [
	{ name: 'parade_dancer', pos: [x, 0.94, z], scale: 0.7 },
	{ name: 'parade_arm', pos: [x + 0.21, 0.94 + 0.6, z], scale: 0.7 },
	{ name: 'parade_arm', pos: [x - 0.21, 0.94 + 0.6, z], scale: [-0.7, 0.7, 0.7] },
]);

export const views = {
	parade_float: {
		items: [{ name: 'parade_float', pos: [0, 0, 0] }, { name: 'float_dragon', pos: [0, 0.94, 1.35] }, ...dancers],
		cam: { pos: [5.5, 3.2, -5.5], target: [0, 1.2, 0], fov: 42 },
	},
	float_themes: {
		items: ['dragon', 'ship', 'cake', 'castle', 'volcano', 'whale', 'rocket'].map((t, i) => ({ name: `float_${t}`, pos: [(i - 3) * 2.5, 0, 0] })),
		cam: { pos: [0, 4, 13], target: [0, 1, 0], fov: 50 },
	},
	parade_held: {
		items: [{ name: 'held_pompom', pos: [-0.45, 0.3, 0] }, { name: 'held_maracas', pos: [-0.15, 0.3, 0] },
			{ name: 'held_fan', pos: [0.15, 0.3, 0] }, { name: 'held_ribbon', pos: [0.4, 0.3, 0] }],
		cam: { pos: [0, 0.6, 1.4], target: [0, 0.35, 0], fov: 40 },
	},
};
