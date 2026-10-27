// The people of the mystery mansion (docs/diseno/escena-mansion.md, step 3): the six members of the Mystery Club, all
// dressed as Detective Pipa; doña Clotilde in her motorized wheelchair; Ceferino the butler; and Lorenzo the parrot in
// his cage.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// A club member dressed as Detective Pipa: a checked cape over a brown coat, the deerstalker cap, a magnifying glass in
// one hand and a bubble pipe in the mouth. The parts the game changes per member have their own nodes: cap (taken
// off), hair (recolored, under the cap), glasses (shown or not), teeth (shown when he bites) and legs (the shoes,
// stretched to his size).
function socio(b) {
	const coat = C('detective_coat', 0x8a6a44), check = C('detective_check', 0xb08a5a), dark = C('detective_dark', 0x5a4028);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: coat, pants: dark });
	// The cape: a short cone over the shoulders, with darker checks.
	b.add('body', check, new THREE.CylinderGeometry(0.22, 0.5, 0.36, 10, 1, true), { pos: V(0, 0.98, 0) });
	for (let i = 0; i < 10; i++) {
		const a = Math.PI * 2 * (i / 10);
		b.add('body', dark, new THREE.BoxGeometry(0.03, 0.34, 0.02), { pos: V(Math.sin(a) * 0.37, 0.98, Math.cos(a) * 0.34), rot: [0.5 * Math.cos(a), a, -0.5 * Math.sin(a)] });
	}
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.205, 0.2) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.42, -0.02) });
	// The deerstalker: a round crown with a peak in front and one behind, and the ear flaps tied on top.
	b.add('cap', check, ellipsoid(0.215, 0.12, 0.205, 10, 5), { pos: V(0, 1.47, 0.0) });
	for (const s of [-1, 1]) {
		b.add('cap', check, new THREE.CylinderGeometry(0.12, 0.12, 0.02, 8, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 1.44, s * 0.18), rot: [0, s > 0 ? 0 : Math.PI, 0] });
		b.add('cap', dark, new THREE.BoxGeometry(0.06, 0.1, 0.03), { pos: V(s * 0.19, 1.5, 0), rot: [0, 0, s * 0.5] });
	}
	b.add('cap', dark, ellipsoid(0.03, 0.025, 0.03, 5, 3), { pos: V(0, 1.6, 0) });
	for (const s of [-1, 1]) b.add('glasses', M.black, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.34, 0.215) });
	b.add('glasses', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.345, 0.215) });
	// The bubble pipe, curved down from the mouth, and the magnifying glass in the right hand.
	limb(b, 'props', dark, V(0.03, 1.2, 0.2), V(0.08, 1.15, 0.3), 0.015);
	b.add('props', dark, new THREE.CylinderGeometry(0.035, 0.03, 0.06, 8), { pos: V(0.09, 1.18, 0.32) });
	b.add('props', C('bubble', 0xbfe8ff, { emissive: 0x1a3040 }), new THREE.SphereGeometry(0.03, 8, 6), { pos: V(0.1, 1.25, 0.33) });
	limb(b, 'props', dark, V(0.49, 0.64, 0.09), V(0.52, 0.78, 0.16), 0.018);
	b.add('props', C('brass', 0xc8a050), new THREE.TorusGeometry(0.07, 0.012, 5, 12), { pos: V(0.53, 0.86, 0.18), rot: [0.3, 0, 0] });
	b.add('props', C('lens', 0xd8f0ff, { emissive: 0x203040 }), new THREE.CylinderGeometry(0.065, 0.065, 0.006, 12), { pos: V(0.53, 0.86, 0.18), rot: [Math.PI / 2 + 0.3, 0, 0] });
}

// Doña Clotilde Candelabro: an old lady in a long violet dress, a white bun, pearls and a lorgnette, sitting in her
// motorized wheelchair (big wheels, a little motor box behind, a lever under her right hand).
function clotilde(b) {
	const dress = C('clotilde_dress', 0x6a2a7a), metal = C('chair_metal', 0x9aa0a8);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: dress, pants: dress, belted: false, shoes: M.black, onePiece: true });
	for (const s of [-1, 1]) {
		b.add('chair', M.black, new THREE.TorusGeometry(0.3, 0.035, 5, 14), { pos: V(s * 0.52, 0.32, -0.05), rot: [0, Math.PI / 2, 0] });
		b.add('chair', metal, new THREE.CylinderGeometry(0.03, 0.03, 0.04, 6), { pos: V(s * 0.52, 0.32, -0.05), rot: [0, 0, Math.PI / 2] });
		b.add('chair', M.black, new THREE.TorusGeometry(0.08, 0.025, 4, 8), { pos: V(s * 0.35, 0.08, 0.4), rot: [0, Math.PI / 2, 0] });
		limb(b, 'chair', metal, V(s * 0.5, 0.55, -0.35), V(s * 0.5, 1.05, -0.4), 0.02);
	}
	b.add('chair', C('chair_seat', 0x3a2a4a), new THREE.BoxGeometry(0.95, 0.5, 0.06), { pos: V(0, 0.82, -0.4) });
	b.add('chair', C('chair_motor', 0x2a2e34), new THREE.BoxGeometry(0.4, 0.25, 0.2), { pos: V(0, 0.3, -0.5) });
	limb(b, 'chair', metal, V(0.5, 0.62, 0.15), V(0.5, 0.72, 0.2), 0.015);
	b.add('chair', M.black, new THREE.SphereGeometry(0.03, 6, 4), { pos: V(0.5, 0.74, 0.21) });
	for (let i = 0; i < 9; i++) {
		const a = Math.PI * (0.15 + 0.7 * i / 8);
		b.add('body', C('pearl', 0xf6f2ea), new THREE.SphereGeometry(0.022, 5, 3), { pos: V(Math.cos(a) * 0.17, 1.12 - Math.sin(a) * 0.06, 0.12 + Math.sin(a) * 0.06) });
	}
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.TorusGeometry(0.04, 0.01, 4, 8, Math.PI), { pos: V(0, 1.22, 0.195) });
	const hair = C('hair_white', 0xeeeeee);
	b.add('head', hair, ellipsoid(0.21, 0.12, 0.2, 10, 5), { pos: V(0, 1.42, -0.03) });
	b.add('head', hair, ellipsoid(0.11, 0.11, 0.11, 8, 5), { pos: V(0, 1.58, -0.06) });
	limb(b, 'props', M.gold, V(-0.46, 0.7, 0.1), V(-0.12, 1.3, 0.24), 0.01);
	for (const s of [-1, 1]) b.add('props', M.gold, new THREE.TorusGeometry(0.045, 0.008, 4, 8), { pos: V(s * 0.06 - 0.06, 1.33, 0.25) });
}

// Ceferino, the butler: black tailcoat with tails, a white shirt front and bow tie, white gloves, a bald top with grey
// sides and a silver tray held flat in his left hand.
function mayordomo(b) {
	const tails = C('butler_tails', 0x1a1a20), shirt = C('butler_shirt', 0xf4f2ec);
	pearBody(b, mat('skin_arena', 0xd9a06b), { shirt: tails, pants: tails, shoes: M.black, belted: false });
	b.add('body', shirt, new THREE.BoxGeometry(0.2, 0.32, 0.04), { pos: V(0, 0.92, 0.3), rot: [-0.35, 0, 0] });
	b.add('body', M.black, new THREE.BoxGeometry(0.12, 0.04, 0.03), { pos: V(0, 1.08, 0.26) });
	for (const s of [-1, 1]) {
		b.add('body', tails, new THREE.BoxGeometry(0.18, 0.5, 0.04), { pos: V(s * 0.12, 0.3, -0.42), rot: [0.15, 0, s * 0.05] });
		b.add('arms', C('glove_white', 0xffffff), ellipsoid(0.08, 0.08, 0.08, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
		b.add('head', C('hair_gray', 0xb8b8bc), ellipsoid(0.06, 0.08, 0.12, 6, 4), { pos: V(s * 0.19, 1.36, -0.02) });
	}
	eyes(b, 1.34, 0.17, 0.08, 0.045);
	b.add('face', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.02), { pos: V(0, 1.21, 0.195) });
	b.add('face', C('mustache_gray', 0x9a9aa0), ellipsoid(0.08, 0.02, 0.03, 6, 3), { pos: V(0, 1.25, 0.2) });
	b.add('props', C('silver', 0xc8ccd2), new THREE.CylinderGeometry(0.2, 0.2, 0.015, 14), { pos: V(-0.55, 0.72, 0.15) });
}

// Lorenzo the parrot: green, with a red head, a yellow beak and a long blue tail, standing on his perch. Its bottom is
// the perch's; he goes inside his cage.
function buildLoro() {
	const b = new Builder('loro');
	const green = C('parrot_green', 0x2fae4a), red = C('parrot_red', 0xd83a2a), blue = C('parrot_blue', 0x2a5ad8);
	b.add('body', C('perch', 0x7a5a32), new THREE.CylinderGeometry(0.012, 0.012, 0.2, 6), { pos: V(0, 0, 0), rot: [0, 0, Math.PI / 2] });
	b.add('body', green, ellipsoid(0.06, 0.09, 0.06, 8, 6), { pos: V(0, 0.09, 0) });
	b.add('body', red, ellipsoid(0.045, 0.045, 0.045, 8, 5), { pos: V(0, 0.19, 0.02) });
	b.add('body', C('beak', 0xf2c84b), new THREE.ConeGeometry(0.018, 0.04, 6), { pos: V(0, 0.18, 0.07), rot: [Math.PI / 2 + 0.4, 0, 0] });
	for (const s of [-1, 1]) {
		b.add('body', M.white, ellipsoid(0.012, 0.012, 0.006, 5, 4), { pos: V(s * 0.03, 0.2, 0.05) });
		b.add('body', green, ellipsoid(0.015, 0.06, 0.04, 5, 4), { pos: V(s * 0.055, 0.09, -0.01) });
	}
	b.add('body', blue, new THREE.BoxGeometry(0.03, 0.14, 0.01), { pos: V(0, 0.0, -0.05), rot: [0.5, 0, 0] });
	return b.build();
}

// Lorenzo's cage: a brass dome of bars on a round tray, on a tall stand. Its bottom sits at y = 0.
function buildParrotCage() {
	const b = new Builder('parrot_cage');
	const brass = C('brass', 0xc8a050);
	b.add('body', brass, new THREE.CylinderGeometry(0.2, 0.25, 0.04, 12), { pos: V(0, 0.02, 0) });
	b.add('body', brass, new THREE.CylinderGeometry(0.025, 0.025, 1.1, 6), { pos: V(0, 0.57, 0) });
	b.add('body', brass, new THREE.CylinderGeometry(0.28, 0.28, 0.03, 14), { pos: V(0, 1.13, 0) });
	for (let i = 0; i < 14; i++) {
		const a = Math.PI * 2 * (i / 14);
		b.add('bars', brass, new THREE.CylinderGeometry(0.006, 0.006, 0.5, 4), { pos: V(Math.cos(a) * 0.27, 1.38, Math.sin(a) * 0.27) });
	}
	b.add('bars', brass, new THREE.SphereGeometry(0.28, 14, 6, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(0, 1.62, 0) });
	b.add('bars', brass, new THREE.TorusGeometry(0.04, 0.008, 4, 8), { pos: V(0, 1.93, 0) });
	return b.build();
}

const PEOPLE = { socio_club: socio, dona_clotilde: clotilde, mayordomo: mayordomo };

export const models = {
	...Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [`npc_${n}`, () => {
		const b = new Builder(`npc_${n}`);
		f(b);
		return b.build();
	}])),
	loro: buildLoro, parrot_cage: buildParrotCage,
};

export const views = {
	mansion_people: {
		items: [{ name: 'npc_dona_clotilde', pos: [-1.5, 0, 0], rotY: 0.3 }, { name: 'npc_socio_club', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_socio_club', pos: [1.1, 0, 0], rotY: -0.4 }, { name: 'npc_mayordomo', pos: [2.3, 0, 0], rotY: -0.3 }],
		cam: { pos: [0.4, 1.4, 6.2], target: [0.4, 0.85, 0], fov: 38 },
	},
	parrot: {
		items: [{ name: 'parrot_cage', pos: [0, 0, 0] }, { name: 'loro', pos: [0, 1.25, 0], rotY: 0.4 }],
		cam: { pos: [0.6, 1.6, 2.0], target: [0, 1.3, 0], fov: 38 },
	},
};
