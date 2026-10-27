// The station's staff for the station crime scene (docs/diseno/escena-comisaria.md, step 2): five coworkers in the
// same blue uniform, cap and regulation mustache as the cops, with a name plate on the chest and one thing each, and
// el Chancho, the prisoner in cell 1. Their teeth are a hidden part ('teeth') the game shows when they bite. On the
// pear body like every character. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, cap, limb } from './pear.js';

const skin = mat('skin_staff', 0xf0d4a8), black = M.black, white = M.white;

function face(b) {
	eyes(b, 1.33, 0.17, 0.08, 0.05);
	// The regulation mustache (the station has asked for it since 1974).
	for (const s of [-1, 1]) b.add('face', black, ellipsoid(0.065, 0.028, 0.03, 6, 4), { pos: V(s * 0.048, 1.25, 0.2), rot: [0, s * 0.4, s * -0.3] });
	b.add('face', black, new THREE.BoxGeometry(0.06, 0.014, 0.02), { pos: V(0, 1.205, 0.19) });
	b.add('teeth', white, new THREE.BoxGeometry(0.08, 0.035, 0.02), { pos: V(0, 1.2, 0.2) });
}

// The coworker's base: the cop's uniform and cap, the name plate and the face.
function coworker(name) {
	const b = new Builder(name);
	pearBody(b, skin);
	b.add('plate', white, new THREE.BoxGeometry(0.24, 0.05, 0.02), { pos: V(-0.12, 0.9, 0.3), rot: [-0.45, -0.3, 0] });
	b.add('badge', M.gold, new THREE.CylinderGeometry(0.04, 0.04, 0.015, 5), { pos: V(0.14, 0.92, 0.3), rot: [Math.PI / 2 - 0.45, 0, 0.3] });
	face(b);
	return b;
}

// Cabo Ronquido: did the night shift; heavy eyelids and a thermos.
export function buildRonquido() {
	const b = coworker('npc_cabo_ronquido');
	for (const s of [-1, 1]) b.add('face', skin, ellipsoid(0.06, 0.035, 0.03, 8, 4), { pos: V(s * 0.08, 1.37, 0.205) });
	cap(b, 1.47, 0.17, 0.01);
	const thermos = mat('thermos_green', 0x2f7a4a);
	b.add('props', thermos, new THREE.CylinderGeometry(0.05, 0.05, 0.28, 8), { pos: V(0.52, 0.72, 0.14) });
	b.add('props', mat('thermos_cap', 0xc8ccd2), new THREE.CylinderGeometry(0.052, 0.052, 0.05, 8), { pos: V(0.52, 0.88, 0.14) });
	return b.build();
}

// Oficial Sellito: the front desk; a rubber stamp always in hand.
export function buildSellito() {
	const b = coworker('npc_oficial_sellito');
	cap(b, 1.47, 0.17, 0.01);
	b.add('props', mat('stamp_wood', 0x8a5a2a), new THREE.CylinderGeometry(0.03, 0.035, 0.12, 8), { pos: V(0.5, 0.74, 0.12) });
	b.add('props', mat('stamp_red', 0xc82020), new THREE.BoxGeometry(0.1, 0.03, 0.07), { pos: V(0.5, 0.66, 0.12) });
	return b.build();
}

// Don Mopa: the cleaner, in uniform anyway; yellow rubber gloves and his mop.
export function buildMopa() {
	const b = coworker('npc_don_mopa');
	cap(b, 1.47, 0.17, 0.01);
	const gloves = mat('rubber_yellow', 0xf2d22a);
	for (const s of [-1, 1]) b.add('arms', gloves, ellipsoid(0.085, 0.085, 0.085, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	limb(b, 'props', mat('mop_stick', 0xb07a40), V(0.52, 0.05, 0.25), V(0.5, 1.45, 0.1), 0.02, 5);
	const strings = mat('mop_strings', 0xc8c4b8);
	for (let i = 0; i < 7; i++) {
		const a = (i / 7) * Math.PI * 2;
		b.add('props', strings, new THREE.CylinderGeometry(0.012, 0.012, 0.22, 4), { pos: V(0.52 + Math.cos(a) * 0.05, 0.08, 0.25 + Math.sin(a) * 0.05), rot: [Math.sin(a) * 0.4, 0, Math.cos(a) * 0.4] });
	}
	return b.build();
}

// Doña Fritanga: makes the donuts and the coffee; a white apron over the uniform and a donut in hand.
export function buildFritanga() {
	const b = coworker('npc_dona_fritanga');
	cap(b, 1.47, 0.17, 0.01);
	const apron = mat('apron_white', 0xf4f2ea);
	b.add('body', apron, new THREE.BoxGeometry(0.5, 0.5, 0.03), { pos: V(0, 0.55, 0.42), rot: [-0.12, 0, 0] });
	b.add('props', mat('donut_dough', 0xd89a50), new THREE.TorusGeometry(0.05, 0.025, 6, 10), { pos: V(0.5, 0.74, 0.14), rot: [Math.PI / 2, 0, 0] });
	b.add('props', mat('donut_icing', 0xff7ab0), new THREE.TorusGeometry(0.05, 0.018, 4, 10), { pos: V(0.5, 0.755, 0.14), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// El archivista Polilla: the filing clerk; thick glasses, dust on the shoulders and a file box under his arm.
export function buildPolilla() {
	const b = coworker('npc_polilla');
	cap(b, 1.47, 0.17, 0.01);
	const frame = mat('glasses_thick', 0x3a2a1a), lens = mat('glasses_lens', 0xc8e8f0, { transparent: true, opacity: 0.5 });
	for (const s of [-1, 1]) {
		b.add('face', frame, new THREE.TorusGeometry(0.055, 0.016, 4, 10), { pos: V(s * 0.08, 1.33, 0.21) });
		b.add('face', lens, new THREE.CylinderGeometry(0.05, 0.05, 0.01, 10), { pos: V(s * 0.08, 1.33, 0.21), rot: [Math.PI / 2, 0, 0] });
	}
	const dust = mat('dust_grey', 0xb8b4aa);
	for (const s of [-1, 1]) b.add('body', dust, ellipsoid(0.12, 0.03, 0.1, 6, 3), { pos: V(s * 0.2, 1.06, 0.02) });
	b.add('props', mat('evidence_box', 0xb8925a), new THREE.BoxGeometry(0.3, 0.22, 0.26), { pos: V(-0.5, 0.72, 0.08) });
	return b.build();
}

// El Chancho, in cell 1: the orange jumpsuit, a big round pink nose and a happy face; he saw everything.
export function buildChancho() {
	const b = new Builder('npc_chancho');
	const orange = mat('jumpsuit', 0xff7a1a), pink = mat('chancho_pink', 0xf4a0a8);
	pearBody(b, pink, { shirt: orange, onePiece: true, belted: false });
	eyes(b, 1.35, 0.17, 0.08, 0.045);
	b.add('face', mat('chancho_nose', 0xe8808c), new THREE.CylinderGeometry(0.06, 0.065, 0.06, 10), { pos: V(0, 1.27, 0.21), rot: [Math.PI / 2, 0, 0] });
	for (const s of [-1, 1]) b.add('face', black, ellipsoid(0.012, 0.018, 0.01, 5, 3), { pos: V(s * 0.022, 1.27, 0.245) });
	for (const s of [-1, 1]) b.add('head', pink, new THREE.ConeGeometry(0.05, 0.09, 4), { pos: V(s * 0.13, 1.5, 0.0), rot: [0, 0, s * -0.5] });
	b.add('body', white, new THREE.BoxGeometry(0.2, 0.1, 0.02), { pos: V(0, 0.86, 0.3), rot: [-0.4, 0, 0] });
	b.add('body', black, new THREE.BoxGeometry(0.05, 0.06, 0.01), { pos: V(0, 0.86, 0.315), rot: [-0.4, 0, 0] });
	b.add('teeth', white, new THREE.BoxGeometry(0.08, 0.035, 0.02), { pos: V(0, 1.19, 0.2) });
	return b.build();
}

export const models = {
	npc_cabo_ronquido: buildRonquido, npc_oficial_sellito: buildSellito, npc_don_mopa: buildMopa,
	npc_dona_fritanga: buildFritanga, npc_polilla: buildPolilla, npc_chancho: buildChancho,
};

const STAFF = ['npc_armero', 'npc_cabo_ronquido', 'npc_oficial_sellito', 'npc_don_mopa', 'npc_dona_fritanga', 'npc_polilla', 'npc_chancho'];
export const views = {
	station_staff: {
		items: STAFF.map((name, i) => ({ name, pos: [(i - 3) * 1.1, 0, 0], rotY: 0.25 })),
		cam: { pos: [0, 1.3, 8.4], target: [0, 0.85, 0], fov: 36 },
	},
};
