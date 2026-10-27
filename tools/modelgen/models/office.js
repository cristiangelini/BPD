// Formularios Infinitos' people (escena-oficina.md, step 2): the employee (six alike, in the same grey suit, blue tie
// and badge, with the same black briefcase), el señor Trámite the manager, Benja the intern behind his pile of papers
// and Pelusa, the robot vacuum. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);
const SUIT = 0x5c626e;

// The suit's lapels, the white shirt's V and the tie, on any pear body.
function suitFront(b, tieColor) {
	const shirt = C('office_shirt', 0xf4f4f0), lapel = C('suit_lapel', 0x4a505a);
	b.add('body', shirt, new THREE.BoxGeometry(0.16, 0.3, 0.02), { pos: V(0, 0.98, 0.36), rot: [-0.3, 0, 0] });
	for (const s of [-1, 1]) b.add('body', lapel, new THREE.BoxGeometry(0.06, 0.32, 0.02), { pos: V(s * 0.09, 0.96, 0.37), rot: [-0.32, 0, s * -0.3] });
	const tie = C('tie', tieColor);
	b.add('body', tie, new THREE.BoxGeometry(0.06, 0.05, 0.03), { pos: V(0, 1.1, 0.33) });
	b.add('body', tie, new THREE.BoxGeometry(0.07, 0.32, 0.02), { pos: V(0, 0.9, 0.4), rot: [-0.32, 0, 0] });
}

// An employee: the company's grey suit and blue tie, the badge with the blurry photo, the black briefcase in the right
// hand (its own node, briefcase). The parts the game changes per employee have their own nodes: hair (recolored),
// glasses, teeth (shown when he bites), legs (stretched to his shoe size) and a company cup in each hand, cup_left
// and cup_right (shown while he drinks his coffee: the hand he holds it with).
function oficinista(b) {
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: C('suit_grey', SUIT), pants: C('suit_grey', SUIT), belted: false });
	suitFront(b, 0x2a4fb0);
	b.add('body', M.white, new THREE.BoxGeometry(0.1, 0.12, 0.01), { pos: V(-0.2, 0.92, 0.36), rot: [-0.3, 0.3, 0] });
	b.add('body', C('badge_photo', 0x9aa4b0), new THREE.BoxGeometry(0.05, 0.05, 0.005), { pos: V(-0.2, 0.94, 0.37), rot: [-0.3, 0.3, 0] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.08, 0.015, 0.02), { pos: V(0, 1.21, 0.2) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.215, 0.205) });
	for (const s of [-1, 1]) b.add('glasses', M.black, new THREE.TorusGeometry(0.055, 0.01, 4, 8), { pos: V(s * 0.08, 1.34, 0.2) });
	b.add('glasses', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.345, 0.2) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.1, 0.2, 10, 5), { pos: V(0, 1.43, -0.03) });
	const leather = C('briefcase_black', 0x1c1c20);
	b.add('briefcase', leather, new THREE.BoxGeometry(0.1, 0.32, 0.44), { pos: V(0.6, 0.32, 0.08) });
	b.add('briefcase', M.gold, new THREE.BoxGeometry(0.04, 0.03, 0.12), { pos: V(0.6, 0.5, 0.08) });
	const cup = C('office_cup', 0xffffff), coffee = C('coffee', 0x3a2414);
	for (const [id, s] of [['cup_left', 1], ['cup_right', -1]]) {
		b.add(id, cup, new THREE.CylinderGeometry(0.045, 0.04, 0.1, 8), { pos: V(s * 0.47, 0.74, 0.16) });
		b.add(id, coffee, new THREE.CylinderGeometry(0.04, 0.04, 0.01, 8), { pos: V(s * 0.47, 0.79, 0.16) });
		b.add(id, cup, new THREE.TorusGeometry(0.025, 0.008, 4, 8), { pos: V(s * 0.52, 0.74, 0.16), rot: [Math.PI / 2, 0, 0] });
	}
}

// El señor Trámite, the manager: short and round, a darker suit with a red tie, a bald head with two tufts, a thin
// mustache and the rubber stamp in his hand (its own node, stamp).
function senorTramite(b) {
	pearBody(b, mat('skin_arena', 0xd9a06b), { shirt: C('suit_dark', 0x3a3e48), pants: C('suit_dark', 0x3a3e48), belted: false });
	suitFront(b, 0xc02a2a);
	eyes(b, 1.34, 0.17, 0.08, 0.06);
	b.add('face', C('mustache', 0x2a1e18), new THREE.BoxGeometry(0.14, 0.02, 0.02), { pos: V(0, 1.24, 0.2) });
	b.add('face', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.02), { pos: V(0, 1.2, 0.2) });
	for (const s of [-1, 1]) b.add('head', C('hair_gray', 0xb8b8bc), ellipsoid(0.06, 0.07, 0.08, 6, 4), { pos: V(s * 0.19, 1.36, -0.03) });
	const wood = C('stamp_wood', 0x8a5a32);
	b.add('stamp', wood, new THREE.CylinderGeometry(0.03, 0.03, 0.12, 8), { pos: V(0.55, 0.78, 0.2) });
	b.add('stamp', C('stamp_rubber', 0x2a2a2a), new THREE.BoxGeometry(0.1, 0.03, 0.07), { pos: V(0.55, 0.7, 0.2) });
}

// Benja, the intern: a short-sleeved white shirt, a tie too short, a lanyard and a pile of papers taller than his head
// held in front of him (its own node, papers).
function pasanteBenja(b) {
	pearBody(b, mat('skin_canela', 0xb8794a), { shirt: C('office_shirt', 0xf4f4f0), pants: C('chinos', 0xb8a27a), belted: true });
	b.add('body', C('tie_green', 0x3a8a4a), new THREE.BoxGeometry(0.06, 0.16, 0.02), { pos: V(0, 1.02, 0.36), rot: [-0.3, 0, 0] });
	eyes(b, 1.34, 0.17, 0.08, 0.055);
	b.add('face', M.black, new THREE.TorusGeometry(0.04, 0.01, 4, 8, Math.PI), { pos: V(0, 1.24, 0.195), rot: [0, 0, Math.PI] });
	b.add('head', C('hair_curly', 0x2a1a10), ellipsoid(0.23, 0.14, 0.22, 10, 5), { pos: V(0, 1.44, -0.02) });
	const paper = C('paper', 0xfbfbf6);
	for (let i = 0; i < 7; i++) b.add('papers', paper, new THREE.BoxGeometry(0.34, 0.12, 0.26), { pos: V(((i * 37) % 5 - 2) * 0.01, 0.75 + i * 0.12, 0.55), rot: [0, ((i * 13) % 7 - 3) * 0.04, 0] });
}

// Pelusa, the robot vacuum: a flat round body 0.34 m wide, a bumper, a green light and two little brushes. Its bottom
// at y = 0.
function buildRobotVacuum() {
	const b = new Builder('robot_vacuum');
	b.add('body', C('vacuum_body', 0xe8e8ec), new THREE.CylinderGeometry(0.17, 0.17, 0.07, 16), { pos: V(0, 0.045, 0) });
	b.add('body', C('vacuum_top', 0x30343c), new THREE.CylinderGeometry(0.12, 0.12, 0.012, 16), { pos: V(0, 0.085, 0) });
	b.add('body', C('vacuum_bumper', 0x5a5e66), new THREE.CylinderGeometry(0.172, 0.172, 0.03, 16, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 0.04, 0) });
	b.add('light', C('vacuum_light', 0x3ad06a, { emissive: 0x3ad06a }), new THREE.SphereGeometry(0.015, 6, 4), { pos: V(0, 0.092, 0.1) });
	for (const s of [-1, 1]) b.add('brush', C('brush', 0xd0b040), new THREE.CylinderGeometry(0.04, 0.04, 0.01, 6), { pos: V(s * 0.12, 0.012, 0.1) });
	return b.build();
}

// What was stolen from Formularios Infinitos (escena-oficina.md, "La historia"), one per match: the Golden Stamp the
// manager approves everything with, the Founder's bronze Stapler and the fat envelope with everybody's year-end bonus.
// Their bottoms sit at y = 0.
function buildGoldenStamp() {
	const b = new Builder('golden_stamp');
	const gilt = C('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	b.add('handle', gilt, new THREE.SphereGeometry(0.035, 8, 6), { pos: V(0, 0.15, 0) });
	b.add('handle', gilt, new THREE.CylinderGeometry(0.018, 0.022, 0.09, 8), { pos: V(0, 0.09, 0) });
	b.add('base', gilt, new THREE.BoxGeometry(0.1, 0.03, 0.07), { pos: V(0, 0.03, 0) });
	b.add('base', C('stamp_rubber', 0x2a2a2a), new THREE.BoxGeometry(0.09, 0.015, 0.06), { pos: V(0, 0.008, 0) });
	return b.build();
}
function buildStapler() {
	const b = new Builder('founder_stapler');
	const bronze = C('bronze', 0xb07a3a, { emissive: 0x201000 });
	b.add('base', bronze, new THREE.BoxGeometry(0.06, 0.02, 0.22), { pos: V(0, 0.01, 0) });
	b.add('arm', bronze, new THREE.BoxGeometry(0.05, 0.035, 0.2), { pos: V(0, 0.045, 0.005), rot: [-0.12, 0, 0] });
	b.add('base', C('wood_plaque', 0x6a4022), new THREE.BoxGeometry(0.1, 0.012, 0.26), { pos: V(0, -0.002, 0) });
	return b.build();
}
function buildBonusEnvelope() {
	const b = new Builder('bonus_envelope');
	b.add('envelope', C('envelope', 0xd9c49a), new THREE.BoxGeometry(0.26, 0.05, 0.16), { pos: V(0, 0.025, 0) });
	b.add('envelope', C('envelope_flap', 0xc8b088), new THREE.BoxGeometry(0.26, 0.004, 0.07), { pos: V(0, 0.052, -0.045) });
	b.add('bills', C('bills', 0x6aa86a), new THREE.BoxGeometry(0.2, 0.02, 0.03), { pos: V(0, 0.045, 0.085) });
	b.add('seal', C('seal_red', 0xc02a2a), new THREE.CylinderGeometry(0.015, 0.015, 0.006, 8), { pos: V(0, 0.054, -0.01) });
	return b.build();
}

const PEOPLE = { oficinista, senor_tramite: senorTramite, pasante_benja: pasanteBenja };

export const models = {
	...Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [`npc_${n}`, () => {
		const b = new Builder(`npc_${n}`);
		f(b);
		return b.build();
	}])),
	robot_vacuum: buildRobotVacuum,
	golden_stamp: buildGoldenStamp, founder_stapler: buildStapler, bonus_envelope: buildBonusEnvelope,
};

export const views = {
	office_loot: {
		items: [{ name: 'golden_stamp', pos: [-0.3, 0, 0], rotY: 0.3 }, { name: 'founder_stapler', pos: [0, 0, 0.05], rotY: -0.5 },
			{ name: 'bonus_envelope', pos: [0.32, 0, 0], rotY: 0.2 }],
		cam: { pos: [0, 0.45, 0.9], target: [0, 0.05, 0], fov: 38 },
	},
	office_people: {
		items: [{ name: 'npc_oficinista', pos: [-2.2, 0, 0], rotY: 0.3 }, { name: 'npc_oficinista', pos: [-1.1, 0, 0], rotY: 0.1 },
			{ name: 'npc_senor_tramite', pos: [0.1, 0, 0], rotY: 0.0 }, { name: 'npc_pasante_benja', pos: [1.3, 0, 0], rotY: -0.2 },
			{ name: 'robot_vacuum', pos: [2.3, 0, 0.4], rotY: -0.4 }],
		cam: { pos: [0.0, 1.5, 6.5], target: [0.0, 0.85, 0], fov: 40 },
	},
};
