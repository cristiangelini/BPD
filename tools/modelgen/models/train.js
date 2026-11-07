// The train El Lento's people (escena-tren.md, step 2): the magician (six alike), don Silbato the engine driver,
// the ticket inspector Picadora and señor Mostaza with his food cart. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// The magician: a black cape to the floor, a top hat, a long white fake beard and white gloves, like the other five.
// The parts the game changes per magician have their own nodes: hat (taken off), hair (recolored, under the hat),
// beard, glasses (shown or not), teeth (shown when he bites), legs (the shoes, stretched to his size) and the three
// tricks, hidden until he does one: dove, hanky and coin.
function mago(b) {
	const cape = C('magician_cape', 0x1a1a22), lining = C('magician_lining', 0xb0182a), white = C('beard_white', 0xf4f4f0);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: cape, pants: cape, belted: false });
	b.add('body', lining, new THREE.ConeGeometry(0.52, 1.0, 10, 1, true), { pos: V(0, 0.55, -0.04) });
	b.add('body', cape, new THREE.ConeGeometry(0.54, 1.02, 10, 1, true, Math.PI * 0.35, Math.PI * 1.3), { pos: V(0, 0.55, -0.05) });
	b.add('body', lining, new THREE.TorusGeometry(0.17, 0.03, 4, 10), { pos: V(0, 1.12, 0), rot: [Math.PI / 2, 0, 0] });
	eyes(b, 1.36, 0.17, 0.08, 0.05);
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.24, 0.235) });
	b.add('beard', white, ellipsoid(0.17, 0.2, 0.09, 8, 5), { pos: V(0, 1.1, 0.16) });
	b.add('beard', white, ellipsoid(0.15, 0.05, 0.05, 8, 4), { pos: V(0, 1.27, 0.2) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.12, 0.2, 10, 5), { pos: V(0, 1.42, -0.02) });
	b.add('hat', cape, new THREE.CylinderGeometry(0.15, 0.15, 0.32, 10), { pos: V(0, 1.62, 0) });
	b.add('hat', cape, new THREE.CylinderGeometry(0.26, 0.26, 0.02, 12), { pos: V(0, 1.47, 0) });
	b.add('hat', lining, new THREE.CylinderGeometry(0.152, 0.152, 0.05, 10), { pos: V(0, 1.51, 0) });
	for (const s of [-1, 1]) b.add('glasses', M.black, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.36, 0.215) });
	b.add('glasses', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.365, 0.215) });
	for (const s of [-1, 1]) b.add('gloves', white, ellipsoid(0.085, 0.085, 0.085, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	limb(b, 'wand', M.black, V(0.49, 0.64, 0.12), V(0.55, 0.82, 0.35), 0.015);
	b.add('wand', white, new THREE.CylinderGeometry(0.017, 0.017, 0.05, 6), { pos: V(0.55, 0.82, 0.35), rot: [0.9, 0, -0.3] });
	b.add('dove', white, ellipsoid(0.08, 0.06, 0.12, 8, 5), { pos: V(0.5, 0.95, 0.2) });
	b.add('dove', white, ellipsoid(0.05, 0.05, 0.05, 6, 4), { pos: V(0.5, 1.02, 0.31) });
	for (const s of [-1, 1]) b.add('dove', white, ellipsoid(0.12, 0.015, 0.06, 6, 3), { pos: V(0.5 + s * 0.11, 0.98, 0.19), rot: [0, 0, s * 0.5] });
	const hanky = [0xe03030, 0xf0c020, 0x30a050, 0x3060e0];
	for (let i = 0; i < 8; i++) {
		b.add('hanky', C(`hanky_${i % 4}`, hanky[i % 4]), new THREE.BoxGeometry(0.1, 0.1, 0.01), { pos: V(0.5 + i * 0.07, 0.66 + Math.sin(i) * 0.04, 0.12 + i * 0.03), rot: [0, -0.4, i * 0.3] });
	}
	b.add('coin', M.gold, new THREE.CylinderGeometry(0.04, 0.04, 0.008, 12), { pos: V(0.5, 0.75, 0.15), rot: [Math.PI / 2, 0, 0] });
}

// Don Silbato, the engine driver: blue overalls, a striped cap, a red neckerchief, soot on the cheeks and the whistle
// on a string.
function maquinista(b) {
	const denim = C('overalls', 0x2a4a8a);
	pearBody(b, mat('skin_arena', 0xd9a06b), { shirt: C('engine_shirt', 0xd8d0c0), pants: denim, belted: false });
	b.add('body', denim, new THREE.BoxGeometry(0.4, 0.3, 0.05), { pos: V(0, 0.78, 0.33), rot: [-0.25, 0, 0] });
	b.add('body', C('neckerchief', 0xc02020), new THREE.ConeGeometry(0.09, 0.12, 4), { pos: V(0, 1.06, 0.16), rot: [Math.PI, 0, 0] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	for (const s of [-1, 1]) b.add('face', C('soot', 0x3a3a3a), ellipsoid(0.04, 0.025, 0.01, 6, 3), { pos: V(s * 0.1, 1.25, 0.18) });
	b.add('face', M.black, new THREE.BoxGeometry(0.08, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	const stripe = C('cap_stripe', 0xe8e8f0);
	b.add('cap', denim, new THREE.CylinderGeometry(0.2, 0.2, 0.12, 10), { pos: V(0, 1.47, 0) });
	for (let i = 0; i < 3; i++) b.add('cap', stripe, new THREE.CylinderGeometry(0.202, 0.202, 0.015, 10), { pos: V(0, 1.43 + i * 0.035, 0) });
	b.add('cap', denim, new THREE.BoxGeometry(0.24, 0.02, 0.12), { pos: V(0, 1.42, 0.22) });
	b.add('whistle', M.gold, new THREE.CylinderGeometry(0.015, 0.015, 0.07, 6), { pos: V(0.08, 0.95, 0.27), rot: [0, 0, Math.PI / 2] });
}

// Picadora, the ticket inspector: a maroon uniform with brass buttons, a peaked cap and the ticket punch in hand.
function guarda(b) {
	const uniform = C('inspector_uniform', 0x6a1a2a);
	pearBody(b, mat('skin_canela', 0xb57a4c), { shirt: uniform, pants: uniform, shoes: M.black });
	for (let i = 0; i < 3; i++) b.add('body', M.gold, new THREE.SphereGeometry(0.02, 5, 3), { pos: V(0, 0.95 - i * 0.12, 0.3 + i * 0.03) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.TorusGeometry(0.035, 0.01, 4, 8, Math.PI), { pos: V(0, 1.24, 0.195), rot: [0, 0, Math.PI] });
	b.add('head', C('hair_dark', 0x2a1a12), ellipsoid(0.08, 0.08, 0.08, 6, 4), { pos: V(0, 1.38, -0.18) });
	b.add('cap', uniform, new THREE.CylinderGeometry(0.21, 0.18, 0.1, 10), { pos: V(0, 1.5, 0) });
	b.add('cap', M.black, new THREE.CylinderGeometry(0.15, 0.15, 0.02, 8, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 1.45, 0.09) });
	b.add('cap', M.gold, new THREE.BoxGeometry(0.08, 0.03, 0.01), { pos: V(0, 1.51, 0.21) });
	b.add('punch', C('punch_steel', 0x9aa0a8), new THREE.BoxGeometry(0.05, 0.14, 0.04), { pos: V(0.5, 0.7, 0.14), rot: [0.3, 0, 0] });
}

// Señor Mostaza, the food cart man: a white jacket, a mustard-yellow bow tie and a paper hat.
function mostaza(b) {
	const jacket = C('vendor_jacket', 0xf2f0e8), mustard = C('mustard', 0xe0b020);
	pearBody(b, mat('skin_rosada', 0xf0b8a0), { shirt: jacket, pants: C('vendor_pants', 0x3a3a44), belted: false });
	b.add('body', mustard, new THREE.BoxGeometry(0.16, 0.06, 0.04), { pos: V(0, 1.07, 0.17) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', C('mustache_black', 0x1a1410), ellipsoid(0.09, 0.025, 0.03, 6, 4), { pos: V(0, 1.24, 0.2) });
	b.add('hat', jacket, new THREE.BoxGeometry(0.34, 0.12, 0.2), { pos: V(0, 1.5, 0) });
	b.add('hat', mustard, new THREE.BoxGeometry(0.345, 0.03, 0.205), { pos: V(0, 1.46, 0) });
}

// The food cart: a steel trolley 0.9 x 0.6, 0.9 m tall, with sandwiches, bottles and a pot of mustard on top. Its
// bottom at y = 0, pushed along +X.
function buildFoodCart() {
	const b = new Builder('train_cart');
	const steel = C('cart_steel', 0xb8bcc4);
	b.add('body', steel, new THREE.BoxGeometry(0.9, 0.6, 0.6), { pos: V(0, 0.45, 0) });
	b.add('body', steel, new THREE.BoxGeometry(0.94, 0.03, 0.64), { pos: V(0, 0.77, 0) });
	b.add('body', steel, new THREE.CylinderGeometry(0.015, 0.015, 0.6, 6), { pos: V(-0.5, 0.95, 0), rot: [Math.PI / 2, 0, 0] });
	for (const x of [-0.35, 0.35]) for (const z of [-0.25, 0.25]) b.add('wheels', M.black, new THREE.CylinderGeometry(0.06, 0.06, 0.04, 8), { pos: V(x, 0.06, z), rot: [Math.PI / 2, 0, 0] });
	for (let i = 0; i < 3; i++) b.add('food', C('bread_white', 0xf0e2c0), new THREE.BoxGeometry(0.16, 0.04, 0.1), { pos: V(-0.25 + i * 0.18, 0.81, -0.12), rot: [0, 0, 0.1] });
	for (let i = 0; i < 3; i++) b.add('food', C(`bottle_${i}`, [0x40a060, 0xc04030, 0xe0a020][i]), new THREE.CylinderGeometry(0.03, 0.03, 0.2, 6), { pos: V(-0.2 + i * 0.12, 0.88, 0.15) });
	b.add('food', C('mustard', 0xe0b020), new THREE.CylinderGeometry(0.05, 0.05, 0.1, 8), { pos: V(0.3, 0.84, 0.12) });
	return b.build();
}

// What was stolen on the train (escena-tren.md, "La historia"), one per match: the Golden Rabbit (the convention's
// prize, 0.3 m tall), the Great Abracadabra's wand (black with a gold tip and stars) and the engine driver's pocket
// watch on its chain. Their bottoms sit at y = 0.
function buildGoldenRabbit() {
	const b = new Builder('golden_rabbit');
	const gold = C('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	b.add('base', C('rabbit_base', 0x3a2a20), new THREE.CylinderGeometry(0.1, 0.11, 0.04, 10), { pos: V(0, 0.02, 0) });
	b.add('rabbit', gold, ellipsoid(0.08, 0.09, 0.1, 8, 6), { pos: V(0, 0.13, 0) });
	b.add('rabbit', gold, ellipsoid(0.06, 0.06, 0.06, 8, 5), { pos: V(0, 0.22, 0.07) });
	for (const s of [-1, 1]) b.add('rabbit', gold, ellipsoid(0.018, 0.07, 0.012, 6, 4), { pos: V(s * 0.025, 0.31, 0.06), rot: [0, 0, s * -0.2] });
	b.add('rabbit', gold, ellipsoid(0.03, 0.03, 0.03, 6, 4), { pos: V(0, 0.12, -0.1) });
	return b.build();
}
function buildMagicWand() {
	const b = new Builder('magic_wand');
	const gold = C('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	b.add('wand', M.black, new THREE.CylinderGeometry(0.012, 0.012, 0.4, 8), { pos: V(0, 0.012, 0), rot: [0, 0, Math.PI / 2] });
	for (const x of [-0.19, 0.19]) b.add('wand', gold, new THREE.CylinderGeometry(0.014, 0.014, 0.03, 8), { pos: V(x, 0.012, 0), rot: [0, 0, Math.PI / 2] });
	for (let i = 0; i < 3; i++) b.add('stars', gold, new THREE.OctahedronGeometry(0.02), { pos: V(-0.08 + i * 0.08, 0.03, 0.02) });
	return b.build();
}
function buildPocketWatch() {
	const b = new Builder('pocket_watch');
	const gold = C('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	b.add('watch', gold, new THREE.CylinderGeometry(0.04, 0.04, 0.015, 14), { pos: V(0, 0.008, 0) });
	b.add('face', M.white, new THREE.CylinderGeometry(0.034, 0.034, 0.003, 14), { pos: V(0, 0.017, 0) });
	b.add('face', M.black, new THREE.BoxGeometry(0.003, 0.002, 0.025), { pos: V(0, 0.019, -0.01) });
	b.add('watch', gold, new THREE.TorusGeometry(0.012, 0.003, 4, 8), { pos: V(0, 0.008, -0.05), rot: [Math.PI / 2, 0, 0] });
	for (let i = 0; i < 6; i++) b.add('chain', gold, new THREE.TorusGeometry(0.008, 0.002, 4, 6), { pos: V(0.01 * i, 0.004, -0.065 - 0.012 * i), rot: [Math.PI / 2, 0, i * 0.5] });
	return b.build();
}

const PEOPLE = { mago: mago, maquinista: maquinista, guarda_tren: guarda, mostaza: mostaza };

export const models = {
	...Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [`npc_${n}`, () => {
		const b = new Builder(`npc_${n}`);
		f(b);
		return b.build();
	}])),
	train_cart: buildFoodCart,
	golden_rabbit: buildGoldenRabbit, magic_wand: buildMagicWand, pocket_watch: buildPocketWatch,
};

export const views = {
	train_people: {
		items: [{ name: 'npc_maquinista', pos: [-1.8, 0, 0], rotY: 0.3 }, { name: 'npc_mago', pos: [-0.6, 0, 0], rotY: 0.2 },
			{ name: 'npc_mago', pos: [0.6, 0, 0], rotY: -0.3 }, { name: 'npc_guarda_tren', pos: [1.8, 0, 0], rotY: -0.3 },
			{ name: 'npc_mostaza', pos: [3.0, 0, 0], rotY: -0.4 }, { name: 'train_cart', pos: [3.0, 0, 1.0], rotY: 0.3 }],
		cam: { pos: [0.6, 1.5, 7.0], target: [0.6, 0.85, 0], fov: 40 },
	},
	train_loot: {
		items: [{ name: 'golden_rabbit', pos: [-0.3, 0, 0], rotY: 0.5 }, { name: 'magic_wand', pos: [0.1, 0, 0.1], rotY: 0.3 },
			{ name: 'pocket_watch', pos: [0.4, 0, 0], rotY: -0.3 }],
		cam: { pos: [0.05, 0.5, 1.3], target: [0.05, 0.1, 0], fov: 38 },
	},
};
