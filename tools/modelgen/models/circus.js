// The Cascabel Brothers' circus people (docs/diseno/escena-circo.md, step 3): the clown (six alike), the ringmaster
// and Zulema the tamer. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);
const SKIN = mat('skin_crema', 0xf3d2b0);
const red = C('clown_red', 0xe0262e), black = M.black, white = M.white, gold = M.gold;

// The clown: polka-dot one-piece with a ruff, and on top what hides who he is. The parts the game changes per clown
// have their own nodes: makeup (the white face and the painted smile, cleaned off with the sponge), wig (the orange
// curls, taken off), hair (his own, recolored, under the wig), glasses (only his, shown once the makeup is off),
// gloves (taken off for his prints), shoe_left and shoe_right (the giant shoes; under them, his own feet in `legs`),
// nose (it honks) and teeth (shown when he laughs).
function payaso(b) {
	const suit = C('clown_suit', 0xf6f0e0);
	pearBody(b, SKIN, { shirt: suit, onePiece: true, belted: false, shoes: C('clown_feet', 0x3a2a22) });
	const dots = [C('dot_red', 0xe0262e), C('dot_blue', 0x2a6ad8), C('dot_yellow', 0xf0c030)];
	let i = 0;
	for (const [x, y, z] of [[-0.25, 0.35, 0.38], [0.2, 0.5, 0.39], [-0.05, 0.75, 0.31], [0.25, 0.85, 0.23], [-0.22, 0.95, 0.2],
		[0.32, 0.3, 0.33], [-0.38, 0.55, 0.2], [0.05, 0.22, 0.37]]) {
		b.add('body', dots[i++ % 3], ellipsoid(0.05, 0.015, 0.05, 6, 3), { pos: V(x, y, z), lookAt: V(x, 0, z) });
	}
	b.add('body', white, new THREE.TorusGeometry(0.17, 0.06, 6, 12), { pos: V(0, 1.1, 0.02), rot: [Math.PI / 2, 0, 0] });
	for (let k = 0; k < 3; k++) b.add('body', dots[k], ellipsoid(0.045, 0.045, 0.045, 6, 4), { pos: V(0, 0.98 - k * 0.17, 0.29 + k * 0.03) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('makeup', white, ellipsoid(0.17, 0.17, 0.06, 10, 6), { pos: V(0, 1.28, 0.16) });
	b.add('makeup', red, new THREE.TorusGeometry(0.08, 0.02, 4, 10, Math.PI), { pos: V(0, 1.23, 0.215), rot: [0, 0, Math.PI] });
	for (const s of [-1, 1]) b.add('makeup', C('clown_blue', 0x2a6ad8), new THREE.ConeGeometry(0.02, 0.07, 4), { pos: V(s * 0.08, 1.43, 0.2) });
	b.add('teeth', white, new THREE.BoxGeometry(0.09, 0.025, 0.02), { pos: V(0, 1.215, 0.21) });
	b.add('nose', red, ellipsoid(0.055, 0.055, 0.055, 8, 6), { pos: V(0, 1.3, 0.225) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.42, -0.02) });
	const curls = C('wig_orange', 0xf07a1a);
	for (const [x, y, z, r] of [[-0.2, 1.42, 0.0, 0.12], [0.2, 1.42, 0.0, 0.12], [-0.13, 1.5, -0.1, 0.11], [0.13, 1.5, -0.1, 0.11],
		[0, 1.47, -0.15, 0.12], [-0.25, 1.32, -0.03, 0.1], [0.25, 1.32, -0.03, 0.1], [0, 1.53, 0.0, 0.09]]) {
		b.add('wig', curls, ellipsoid(r, r, r, 7, 5), { pos: V(x, y, z) });
	}
	b.add('wig', C('hat_tiny', 0x2a2a30), new THREE.CylinderGeometry(0.06, 0.07, 0.08, 8), { pos: V(0, 1.62, 0.0) });
	for (const s of [-1, 1]) {
		b.add('glasses', black, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.34, 0.215) });
		b.add('gloves', white, ellipsoid(0.09, 0.09, 0.09, 7, 5), { pos: V(s * 0.49, 0.64, 0.09) });
		b.add(s < 0 ? 'shoe_left' : 'shoe_right', red, ellipsoid(0.16, 0.1, 0.34, 8, 5), { pos: V(s * 0.21, 0.09, 0.22) });
	}
	b.add('glasses', black, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.345, 0.215) });
}

// The ringmaster: red tailcoat with gold buttons, white trousers, black boots, a top hat, a curled mustache and his
// megaphone.
function director(b) {
	const coat = C('ringmaster_coat', 0xc81e2a);
	pearBody(b, SKIN, { shirt: coat, pants: white, shoes: C('boots_black', 0x1a1a1e), belted: false });
	b.add('body', coat, new THREE.ConeGeometry(0.3, 0.5, 6, 1, true), { pos: V(0, 0.35, -0.3), rot: [0.3, 0, 0] });
	for (const y of [0.75, 0.88, 1.0]) for (const s of [-1, 1]) b.add('body', gold, new THREE.SphereGeometry(0.02, 5, 3), { pos: V(s * 0.08, y, 0.3 - (y - 0.75) * 0.25) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	const tash = C('mustache_black', 0x1a1410);
	for (const s of [-1, 1]) b.add('face', tash, new THREE.TorusGeometry(0.05, 0.015, 4, 8, Math.PI * 1.2), { pos: V(s * 0.06, 1.25, 0.2), rot: [0, 0, s > 0 ? 0.3 : Math.PI - 0.3] });
	b.add('cap', black, new THREE.CylinderGeometry(0.15, 0.15, 0.32, 10), { pos: V(0, 1.6, 0.0) });
	b.add('cap', black, new THREE.CylinderGeometry(0.25, 0.25, 0.02, 12), { pos: V(0, 1.45, 0.0) });
	b.add('cap', red, new THREE.CylinderGeometry(0.152, 0.152, 0.05, 10), { pos: V(0, 1.5, 0.0) });
	b.add('props', C('megaphone', 0xe8e4d8), new THREE.CylinderGeometry(0.03, 0.11, 0.3, 8, 1, true), { pos: V(0.5, 0.75, 0.25), rot: [Math.PI / 2, 0, 0] });
}

// Zulema the tamer: a sequined green jacket with gold epaulettes, a tall black hairdo with a feather, and a whip.
function domadora(b) {
	const jacket = C('tamer_jacket', 0x1e8a5a);
	pearBody(b, mat('skin_arena', 0xd9a06b), { shirt: jacket, pants: C('tamer_pants', 0xf4f0e6), shoes: C('boots_black', 0x1a1a1e), belted: false });
	for (const s of [-1, 1]) b.add('body', gold, new THREE.CylinderGeometry(0.09, 0.09, 0.04, 8), { pos: V(s * 0.27, 1.04, 0.0), rot: [0, 0, s * 0.5] });
	for (const [x, y] of [[-0.1, 0.8], [0.12, 0.92], [0.05, 0.68], [-0.15, 0.98]]) b.add('body', gold, ellipsoid(0.02, 0.02, 0.01, 4, 3), { pos: V(x, y, 0.3) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', red, new THREE.TorusGeometry(0.05, 0.012, 4, 8, Math.PI), { pos: V(0, 1.24, 0.195), rot: [0, 0, Math.PI] });
	const hair = C('hair_black', 0x1a1410);
	b.add('head', hair, ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.42, -0.02) });
	b.add('head', hair, ellipsoid(0.13, 0.2, 0.13, 8, 6), { pos: V(0, 1.62, -0.03) });
	b.add('head', C('feather', 0xe84a9a), new THREE.ConeGeometry(0.03, 0.3, 5), { pos: V(0.08, 1.85, -0.03), rot: [0, 0, -0.3] });
	limb(b, 'props', C('whip_handle', 0x5a3a1e), V(0.5, 0.62, 0.1), V(0.5, 0.72, 0.3), 0.025);
	b.add('props', C('whip', 0x2a1a10), new THREE.TorusGeometry(0.18, 0.012, 4, 14), { pos: V(0.52, 0.45, 0.32), rot: [0, Math.PI / 2, 0] });
}

const BUILD = { payaso, director, domadora };
export const models = Object.fromEntries(Object.entries(BUILD).map(([n, f]) => [`npc_${n}`, () => {
	const b = new Builder(`npc_${n}`);
	f(b);
	return b.build();
}]));

export const views = {
	circus_people: {
		items: [{ name: 'npc_director', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_payaso', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_payaso', pos: [1.2, 0, 0], rotY: -0.4 }, { name: 'npc_domadora', pos: [2.4, 0, 0], rotY: -0.3 }],
		cam: { pos: [0.55, 1.4, 6.0], target: [0.55, 0.85, 0], fov: 38 },
	},
	npc_payaso: {
		items: [{ name: 'npc_payaso', pos: [-0.5, 0, 0], rotY: 0.35 }, { name: 'npc_payaso', pos: [0.7, 0, 0], rotY: Math.PI - 0.6 }],
		cam: { pos: [0.1, 1.3, 4.2], target: [0.1, 0.8, 0], fov: 34 },
	},
};
