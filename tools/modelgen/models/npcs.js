// NPCs on the pear body (decision 33 and the cases so far): same structure as the cops, told apart by outfit and props.
// Approved by Cristian (19/10). Placeholder, not final art.
import { Builder, loft, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

// NPC skins stay softer than the four bright player skins, so a cop always stands out.
const SKIN = { crema: mat('skin_crema', 0xf3d2b0), arena: mat('skin_arena', 0xd9a06b), cacao: mat('skin_cacao', 0x9a6440), celeste: mat('skin_celeste', 0xa9d6e0) };
const C = (name, color, opts) => mat(name, color, opts);
const white = M.white, black = M.black, gold = M.gold;

function mouth(b, { open = false, smile = false } = {}) {
	if (open) b.add('face', C('mouth', 0x5a1420), ellipsoid(0.07, 0.06, 0.03, 8, 5), { pos: V(0, 1.21, 0.185) });
	else if (smile) b.add('face', black, new THREE.TorusGeometry(0.05, 0.012, 4, 8, Math.PI), { pos: V(0, 1.24, 0.195), rot: [0, 0, Math.PI] });
	else b.add('face', black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.22, 0.195) });
}
function mustache(b, m, size = 1) {
	for (const s of [-1, 1]) b.add('face', m, ellipsoid(0.06 * size, 0.025 * size, 0.03, 6, 4), { pos: V(s * 0.045 * size, 1.25, 0.2), rot: [0, s * 0.4, s * -0.3] });
}
function glasses(b, m = black) {
	for (const s of [-1, 1]) b.add('face', m, new THREE.TorusGeometry(0.05, 0.01, 4, 8), { pos: V(s * 0.08, 1.33, 0.205) });
	b.add('face', m, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(0, 1.335, 0.205) });
}
function sunglasses(b) {
	for (const s of [-1, 1]) b.add('face', black, new THREE.BoxGeometry(0.1, 0.06, 0.02), { pos: V(s * 0.075, 1.33, 0.2) });
	b.add('face', black, new THREE.BoxGeometry(0.34, 0.015, 0.015), { pos: V(0, 1.345, 0.19) });
}
function hairCap(b, m, { y = 1.38, sx = 1.04, sy = 0.55, back = 0 } = {}) {
	b.add('head', m, ellipsoid(0.2 * sx, 0.22 * sy, 0.19 * sx, 10, 5), { pos: V(0, y, 0.0 - back) });
}
function peakedCap(b, m, band, badge = gold) {
	b.add('cap', m, new THREE.CylinderGeometry(0.2, 0.17, 0.1, 8), { pos: V(0, 1.52, 0.01) });
	b.add('cap', band, new THREE.CylinderGeometry(0.175, 0.175, 0.03, 8), { pos: V(0, 1.47, 0.01) });
	b.add('cap', black, new THREE.CylinderGeometry(0.14, 0.14, 0.02, 8, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 1.45, 0.08) });
	b.add('cap', badge, new THREE.CylinderGeometry(0.03, 0.03, 0.012, 5), { pos: V(0, 1.52, 0.2), rot: [Math.PI / 2, 0, 0] });
}
// An open songbook held in front with both hands, at the hands' height.
function songbook(b) {
	b.add('props', C('songbook_cover', 0x1d1a22), new THREE.BoxGeometry(0.34, 0.02, 0.24), { pos: V(0, 0.72, 0.32), rot: [-0.9, 0, 0] });
	b.add('props', C('songbook_pages', 0xf4eedc), new THREE.BoxGeometry(0.32, 0.012, 0.22), { pos: V(0, 0.73, 0.335), rot: [-0.9, 0, 0] });
}
function tie(b, m) {
	b.add('body', m, new THREE.ConeGeometry(0.035, 0.22, 4), { pos: V(0, 0.92, 0.29), rot: [Math.PI + 0.35, Math.PI / 4, 0] });
}
function lapels(b, shirt) {
	b.add('body', shirt, new THREE.ConeGeometry(0.09, 0.3, 3), { pos: V(0, 0.93, 0.255), rot: [Math.PI + 0.38, 0, 0] });
}
function briefcase(b, m, s = 1) {
	b.add('props', m, new THREE.BoxGeometry(0.08, 0.26, 0.34), { pos: V(s * 0.52, 0.42, 0.12) });
	b.add('props', black, new THREE.BoxGeometry(0.02, 0.06, 0.1), { pos: V(s * 0.52, 0.58, 0.12) });
}

// A robber: all in black with gloves, and the mask (its color, plus what `extra` adds) over the whole head.
function robber(b, mask, extra) {
	const outfit = C('robber_black', 0x26262c);
	pearBody(b, mask, { shirt: outfit, pants: outfit, belted: false, shoes: black });
	for (const s of [-1, 1]) b.add('arms', C('glove_black', 0x111114), ellipsoid(0.08, 0.08, 0.08, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	b.add('head', mask, ellipsoid(0.215, 0.235, 0.205, 10, 7), { pos: V(0, 1.31, 0.02) });
	eyes(b, 1.35, 0.19, 0.08, 0.045);
	extra(mask);
}

// A grandpa robber (robo-banco-abuelos.md, decision 122): a retiree in a cardigan with slippers and a cane, the face of
// an old man under the rubber mask and his glasses over it. The mask and what it adds go in their own node ('mask') so
// the game can take it off (step 2); under it, white eyebrows, a mustache and the white hair on the sides.
function grandpaRobber(b, mask, cardigan, extra) {
	pearBody(b, SKIN.arena, { shirt: cardigan, pants: C('abuelo_pants', 0x8c8378), shoes: C('slippers', 0x7a3e2a), belted: false });
	eyes(b, 1.32, 0.15, 0.08, 0.045);
	for (const s of [-1, 1]) b.add('face', white, ellipsoid(0.05, 0.02, 0.025, 6, 4), { pos: V(s * 0.08, 1.4, 0.17) });
	for (const s of [-1, 1]) b.add('face', white, ellipsoid(0.05, 0.02, 0.02, 6, 4), { pos: V(s * 0.045, 1.25, 0.18), rot: [0, s * 0.4, s * -0.3] });
	for (const s of [-1, 1]) b.add('face', white, ellipsoid(0.05, 0.09, 0.1, 6, 4), { pos: V(s * 0.18, 1.32, -0.02) });
	b.add('mask', mask, ellipsoid(0.215, 0.235, 0.205, 10, 7), { pos: V(0, 1.31, 0.02) });
	for (const s of [-1, 1]) {
		b.add('mask', white, ellipsoid(0.08, 0.092, 0.036, 8, 6), { pos: V(s * 0.08, 1.35, 0.205) });
		b.add('mask', black, ellipsoid(0.036, 0.044, 0.02, 6, 4), { pos: V(s * 0.08, 1.35, 0.233) });
	}
	extra(mask);
	// The mask stuffed in the pocket once he takes it off (hidden until then): a crumpled ball and a bit sticking out.
	b.add('pocket', mask, ellipsoid(0.07, 0.05, 0.05, 6, 4), { pos: V(-0.24, 0.68, 0.38), rot: [-0.3, -0.5, 0] });
	b.add('pocket', mask, ellipsoid(0.03, 0.09, 0.025, 6, 4), { pos: V(-0.22, 0.76, 0.37), rot: [-0.2, 0, 0.35] });
	for (const s of [-1, 1]) b.add('glasses', black, new THREE.TorusGeometry(0.06, 0.01, 4, 8), { pos: V(s * 0.08, 1.35, 0.25) });
	b.add('glasses', black, new THREE.BoxGeometry(0.05, 0.012, 0.012), { pos: V(0, 1.355, 0.25) });
	for (let i = 0; i < 4; i++) b.add('body', C('button', 0xe8dcc0), ellipsoid(0.02, 0.02, 0.01, 5, 3), { pos: V(0, 1.0 - i * 0.13, 0.25 + i * 0.045) });
	// The cardigan's pocket, where the mask goes when he takes it off.
	b.add('body', C('cardigan_pocket', 0x4a3a2a), new THREE.BoxGeometry(0.14, 0.12, 0.03), { pos: V(-0.24, 0.62, 0.39), rot: [-0.3, -0.5, 0] });
	limb(b, 'cane', C('cane', 0x5a3a20), V(0.5, 0.62, 0.12), V(0.62, 0.0, 0.2), 0.02);
}

const NPCS = {
	// Comisario: big, shouting, with a gold-banded cap, huge mustache and medals.
	comisario(b) {
		const coat = C('comisario_coat', 0x6b4a2b), pants = C('comisario_pants', 0x3a2a1a);
		pearBody(b, SKIN.crema, { shirt: coat, pants });
		eyes(b, 1.34, 0.17, 0.08, 0.05);
		for (const s of [-1, 1]) b.add('face', black, new THREE.BoxGeometry(0.09, 0.02, 0.02), { pos: V(s * 0.08, 1.4, 0.19), rot: [0, 0, s * 0.35] });
		mouth(b, { open: true });
		mustache(b, C('gray', 0xd8d8d8), 1.5);
		peakedCap(b, black, gold);
		for (let i = 0; i < 3; i++) b.add('body', i === 1 ? C('medal_red', 0xd23a3a) : gold, new THREE.CylinderGeometry(0.03, 0.03, 0.01, 6), { pos: V(-0.12 + i * 0.06, 0.88, 0.3), rot: [Math.PI / 2 - 0.4, 0, 0] });
	},
	// Comisario in his pajamas (fuga.md): woken up by the night guard's call, striped pajamas, nightcap and slippers.
	comisario_pijama(b) {
		const pajama = C('pajama', 0xbcd3ea), stripe = C('pajama_stripe', 0x4a6fa5);
		pearBody(b, SKIN.crema, { shirt: pajama, pants: pajama, shoes: C('slippers_comisario', 0x8a2f3a) });
		for (const y of [0.55, 0.7, 0.85, 1.0]) {
			const r = y < 0.8 ? 0.36 + (0.8 - y) * 0.33 : 0.36 - (y - 0.8) * 0.48;
			b.add('body', stripe, loft([{ y: y - 0.02, rx: r + 0.012, rz: r * 0.89 + 0.012 }, { y: y + 0.02, rx: r + 0.006, rz: r * 0.89 + 0.006 }], 10));
		}
		eyes(b, 1.34, 0.17, 0.08, 0.05);
		for (const s of [-1, 1]) b.add('face', black, new THREE.BoxGeometry(0.09, 0.02, 0.02), { pos: V(s * 0.08, 1.4, 0.19), rot: [0, 0, s * 0.35] });
		mouth(b, { open: true });
		mustache(b, C('gray', 0xd8d8d8), 1.5);
		b.add('cap', pajama, new THREE.ConeGeometry(0.19, 0.42, 8), { pos: V(0.05, 1.62, -0.03), rot: [0, 0, -0.5] });
		b.add('cap', stripe, new THREE.CylinderGeometry(0.2, 0.2, 0.05, 8), { pos: V(0, 1.45, 0.0) });
		b.add('cap', white, ellipsoid(0.05, 0.05, 0.05, 6, 4), { pos: V(0.15, 1.8, -0.03) });
	},
	// Mr. Moneda, the bank's manager (robo-banco-gerente.md, decision 124): woken up by the robbery, green striped
	// pajamas, a robe's belt, slippers, glasses, a thin mustache and a bald top with grey hair on the sides. The walkie in
	// his pajama's pocket goes in its own node ('walkie') so the game shows it only when he's the boss and talks into it.
	gerente(b) {
		const pajama = C('pajama_green', 0xb8dcc0), stripe = C('pajama_green_stripe', 0x3e7a52);
		pearBody(b, SKIN.crema, { shirt: pajama, pants: pajama, shoes: C('slippers_brown', 0x6a4a32), belted: false });
		for (const y of [0.5, 0.65, 0.8, 0.95, 1.08]) {
			const r = y < 0.8 ? 0.36 + (0.8 - y) * 0.33 : 0.36 - (y - 0.8) * 0.48;
			b.add('body', stripe, loft([{ y: y - 0.015, rx: r + 0.012, rz: r * 0.89 + 0.012 }, { y: y + 0.015, rx: r + 0.006, rz: r * 0.89 + 0.006 }], 10));
		}
		b.add('body', C('robe_belt', 0x8a2a3a), new THREE.TorusGeometry(0.4, 0.025, 4, 16), { pos: V(0, 0.62, 0.0), rot: [Math.PI / 2, 0, 0] });
		b.add('body', C('pajama_pocket', 0x9cc8a8), new THREE.BoxGeometry(0.12, 0.1, 0.03), { pos: V(0.17, 0.98, 0.29), rot: [-0.35, 0.4, 0] });
		eyes(b, 1.33, 0.16, 0.08, 0.045);
		glasses(b);
		mouth(b);
		mustache(b, C('hair_grey', 0x8a8a8a), 0.8);
		const hair = C('hair_grey', 0x8a8a8a);
		for (const s of [-1, 1]) b.add('head', hair, ellipsoid(0.06, 0.1, 0.13, 6, 4), { pos: V(s * 0.18, 1.33, -0.03) });
		b.add('head', hair, ellipsoid(0.15, 0.08, 0.06, 8, 4), { pos: V(0, 1.31, -0.17) });
		b.add('walkie', black, new THREE.BoxGeometry(0.06, 0.14, 0.04), { pos: V(0.17, 1.06, 0.3), rot: [-0.35, 0.4, 0] });
		b.add('walkie', black, new THREE.CylinderGeometry(0.006, 0.006, 0.14, 4), { pos: V(0.15, 1.18, 0.3) });
	},
	// Abuelo (case 1.1): small, cardigan, flat cap, glasses, white eyebrows and a cane.
	abuelo(b) {
		const cardigan = C('cardigan', 0x7c8b52), pants = C('abuelo_pants', 0x8c8378);
		pearBody(b, SKIN.arena, { shirt: cardigan, pants, shoes: C('slippers', 0x7a3e2a) });
		eyes(b, 1.32, 0.17, 0.08, 0.045);
		glasses(b);
		for (const s of [-1, 1]) b.add('face', white, ellipsoid(0.05, 0.02, 0.025, 6, 4), { pos: V(s * 0.08, 1.4, 0.19) });
		mustache(b, white);
		b.add('cap', C('flatcap', 0x5c4a3a), ellipsoid(0.22, 0.07, 0.24, 10, 5), { pos: V(0, 1.47, 0.04) });
		for (let i = 0; i < 4; i++) b.add('body', C('button', 0xe8dcc0), ellipsoid(0.02, 0.02, 0.01, 5, 3), { pos: V(0, 1.0 - i * 0.13, 0.25 + i * 0.045) });
		limb(b, 'props', C('cane', 0x5a3a20), V(0.5, 0.62, 0.12), V(0.62, 0.0, 0.2), 0.02);
	},
	// Abuela of the grandparents' club (infiltracion.md): flowered dress, grey bun, glasses and a knitted shawl.
	abuela(b) {
		const dress = C('flower_dress', 0x6a8ad0);
		pearBody(b, SKIN.crema, { shirt: dress, onePiece: true, belted: false, shoes: C('slippers_pink', 0xd88aa0) });
		for (let i = 0; i < 8; i++) b.add('body', C('flower', 0xf4e070), ellipsoid(0.03, 0.03, 0.01, 5, 3), { pos: V(-0.3 + (i % 4) * 0.2, 0.35 + Math.floor(i / 4) * 0.2, 0.44) });
		b.add('body', C('shawl', 0xc84a4a), new THREE.TorusGeometry(0.2, 0.07, 6, 14), { pos: V(0, 1.05, 0.02), rot: [Math.PI / 2, 0, 0] });
		eyes(b, 1.32, 0.17, 0.08, 0.045);
		glasses(b);
		mouth(b, { smile: true });
		const hair = C('hair_gray', 0x9aa0a8);
		hairCap(b, hair, { y: 1.39, back: 0.02 });
		b.add('head', hair, ellipsoid(0.1, 0.1, 0.1, 8, 6), { pos: V(0, 1.55, -0.06) });
	},
	// Doña Chela, the club's boss (infiltracion.md): purple suit, pearls, a tall white hairdo, cat-eye glasses and a
	// bingo marker in her hand. She always wins.
	chela(b) {
		const suit = C('chela_suit', 0x6a2a7a);
		pearBody(b, SKIN.arena, { shirt: suit, onePiece: true, belted: false, shoes: C('chela_shoes', 0x2a1a2a) });
		for (let i = 0; i < 9; i++) {
			const a = Math.PI * (0.1 + 0.8 * (i / 8));
			b.add('body', C('pearl', 0xfaf6ee), ellipsoid(0.025, 0.025, 0.025, 5, 3), { pos: V(Math.cos(a) * 0.16, 1.13 - Math.sin(a) * 0.09, 0.16) });
		}
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		for (const s of [-1, 1]) b.add('face', C('cat_eye', 0xd03a8a), new THREE.BoxGeometry(0.12, 0.05, 0.02), { pos: V(s * 0.08, 1.35, 0.2), rot: [0, 0, s * -0.25] });
		mouth(b, { smile: true });
		const hair = C('hair_white', 0xf4f0ea);
		hairCap(b, hair, { y: 1.39, back: 0.02 });
		b.add('head', hair, ellipsoid(0.17, 0.22, 0.16, 10, 6), { pos: V(0, 1.58, -0.02) });
		b.add('props', C('marker', 0xe83a5a), new THREE.CylinderGeometry(0.03, 0.03, 0.16, 6), { pos: V(0.5, 0.7, 0.14) });
	},
	// The club's doorman (infiltracion.md): a broad grandpa in a black suit and sunglasses, arms crossed.
	portero(b) {
		const suit = C('doorman_suit', 0x22222a);
		pearBody(b, SKIN.cacao, { shirt: suit, pants: suit });
		lapels(b, white);
		tie(b, C('doorman_tie', 0xb02a2a));
		sunglasses(b);
		mouth(b);
		mustache(b, C('gray', 0xd8d8d8), 1.2);
		b.add('cap', C('bald', 0x8a5a3a), ellipsoid(0.2, 0.08, 0.19, 10, 5), { pos: V(0, 1.46, 0.02) });
		b.add('body', suit, new THREE.BoxGeometry(0.62, 0.12, 0.14), { pos: V(0, 0.75, 0.3) });
	},
	// A chorister of the chapel's choir (infiltracion-coro.md): the burgundy robe with the white collar, gray curls
	// and an open songbook in both hands.
	corista(b) {
		const robe = C('robe_cloth', 0x7a1f2e);
		pearBody(b, SKIN.crema, { shirt: robe, onePiece: true, belted: false, shoes: black });
		b.add('body', white, new THREE.TorusGeometry(0.16, 0.035, 6, 12), { pos: V(0, 1.1, 0.02), rot: [Math.PI / 2, 0, 0] });
		eyes(b, 1.32, 0.17, 0.08, 0.045);
		mouth(b, { open: true });
		const hair = C('hair_gray', 0x9aa0a8);
		hairCap(b, hair, { y: 1.39, back: 0.02 });
		for (const s of [-1, 1]) b.add('head', hair, ellipsoid(0.08, 0.1, 0.08, 6, 4), { pos: V(s * 0.17, 1.33, -0.02) });
		songbook(b);
	},
	// Another chorister: bald, glasses and a thick white beard, same robe and songbook.
	corista_b(b) {
		const robe = C('robe_cloth', 0x7a1f2e);
		pearBody(b, SKIN.cacao, { shirt: robe, onePiece: true, belted: false, shoes: black });
		b.add('body', white, new THREE.TorusGeometry(0.16, 0.035, 6, 12), { pos: V(0, 1.1, 0.02), rot: [Math.PI / 2, 0, 0] });
		eyes(b, 1.32, 0.17, 0.08, 0.045);
		glasses(b);
		mouth(b, { open: true });
		b.add('face', C('beard', 0xeeeae2), ellipsoid(0.15, 0.1, 0.08, 8, 5), { pos: V(0, 1.16, 0.15) });
		b.add('cap', C('bald_cacao', 0x8a5a3a), ellipsoid(0.2, 0.08, 0.19, 10, 5), { pos: V(0, 1.46, 0.02) });
		songbook(b);
	},
	// Maestro Ernesto, the choir's director (infiltracion-coro.md): black tailcoat, white bow tie, wild white hair,
	// a gold watch and the baton up in his right hand.
	ernesto(b) {
		const coat = C('tailcoat', 0x16161c);
		pearBody(b, SKIN.arena, { shirt: coat, pants: coat });
		lapels(b, white);
		for (const s of [-1, 1]) b.add('body', white, new THREE.ConeGeometry(0.04, 0.08, 4), { pos: V(s * 0.04, 1.08, 0.2), rot: [0, 0, s * Math.PI / 2] });
		b.add('body', coat, new THREE.BoxGeometry(0.3, 0.35, 0.05), { pos: V(0, 0.32, -0.42), rot: [-0.2, 0, 0] });
		b.add('body', gold, new THREE.TorusGeometry(0.03, 0.008, 4, 8), { pos: V(0.2, 0.62, 0.38) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		const hair = C('hair_white', 0xf4f0ea);
		for (let i = 0; i < 7; i++) {
			const a = Math.PI * (i / 6);
			b.add('head', hair, ellipsoid(0.09, 0.09, 0.09, 6, 4), { pos: V(Math.cos(a) * 0.2, 1.4 + Math.sin(a) * 0.1, -0.04) });
		}
		limb(b, 'props', C('baton', 0xf8f6f0), V(0.5, 0.66, 0.12), V(0.62, 1.05, 0.3), 0.012);
	},
	// The lady at the chapel's door (infiltracion-coro.md): a green cardigan, a tight bun, reading glasses on a chain
	// and the attendance list on a clipboard.
	portera(b) {
		const cardigan = C('door_cardigan', 0x3e7a5a);
		pearBody(b, SKIN.celeste, { shirt: cardigan, pants: C('door_skirt', 0x4a4a5a), belted: false, shoes: black });
		eyes(b, 1.32, 0.17, 0.08, 0.045);
		glasses(b, gold);
		b.add('face', gold, new THREE.TorusGeometry(0.16, 0.004, 3, 12, Math.PI), { pos: V(0, 1.28, 0.12), rot: [0, 0, Math.PI] });
		mouth(b);
		const hair = C('hair_dark', 0x4a3a32);
		hairCap(b, hair, { y: 1.39, back: 0.02 });
		b.add('head', hair, ellipsoid(0.09, 0.09, 0.09, 8, 5), { pos: V(0, 1.45, -0.18) });
		b.add('props', C('clipboard', 0xa87a4a), new THREE.BoxGeometry(0.22, 0.3, 0.02), { pos: V(-0.42, 0.75, 0.25), rot: [-0.5, 0.3, 0] });
		b.add('props', white, new THREE.BoxGeometry(0.18, 0.24, 0.005), { pos: V(-0.415, 0.75, 0.263), rot: [-0.5, 0.3, 0] });
	},
	// Sospechoso: striped shirt, beanie and eye mask, with a loot sack.
	sospechoso(b) {
		pearBody(b, SKIN.celeste, { shirt: white, pants: C('jeans', 0x2a2f3a) });
		for (const y of [0.6, 0.72, 0.84, 0.96]) {
			const r = y < 0.8 ? 0.36 + (0.8 - y) * 0.33 : 0.36 - (y - 0.8) * 0.48;
			b.add('body', black, loft([{ y: y - 0.025, rx: r + 0.012, rz: r * 0.89 + 0.012 }, { y: y + 0.025, rx: r + 0.006, rz: r * 0.89 + 0.006 }], 10));
		}
		b.add('face', black, new THREE.BoxGeometry(0.32, 0.08, 0.06), { pos: V(0, 1.33, 0.16) });
		eyes(b, 1.33, 0.18, 0.08, 0.045);
		mouth(b, { smile: true });
		b.add('cap', black, ellipsoid(0.205, 0.14, 0.195, 10, 5), { pos: V(0, 1.42, 0.01) });
		b.add('props', C('sack', 0xc9a66b), ellipsoid(0.2, 0.24, 0.18, 8, 6), { pos: V(-0.3, 1.0, -0.35) });
	},
	// Vecina: dress, hair bun with curlers and a handbag.
	vecina(b) {
		const dress = C('dress', 0xe86aa0);
		pearBody(b, SKIN.cacao, { shirt: dress, onePiece: true, belted: false, shoes: C('red_shoes', 0xb02a2a) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		const hair = C('hair_gray', 0x9aa0a8);
		hairCap(b, hair, { y: 1.39, back: 0.02 });
		b.add('head', hair, ellipsoid(0.1, 0.1, 0.1, 8, 6), { pos: V(0, 1.55, -0.04) });
		for (const x of [-0.1, 0, 0.1]) b.add('head', C('curler', 0x7ad0e8), new THREE.CylinderGeometry(0.03, 0.03, 0.08, 6), { pos: V(x, 1.47, 0.14), rot: [0, 0, Math.PI / 2] });
		for (let i = 0; i < 5; i++) b.add('body', white, ellipsoid(0.035, 0.035, 0.01, 5, 3), { pos: V(-0.2 + i * 0.1, 0.38 + (i % 2) * 0.12, 0.43) });
		b.add('props', C('bag', 0x6a3fa0), new THREE.BoxGeometry(0.2, 0.15, 0.08), { pos: V(-0.52, 0.5, 0.12) });
	},
	// Periodista (prensa): jacket, backwards cap, press badge and a big camera on the shoulder.
	periodista(b) {
		const jacket = C('jacket', 0x8a9099);
		pearBody(b, SKIN.arena, { shirt: jacket, pants: C('khaki', 0xb79a6a) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { open: true });
		const capM = C('press_cap', 0xd8402a);
		b.add('cap', capM, ellipsoid(0.205, 0.12, 0.195, 10, 5), { pos: V(0, 1.42, 0.0) });
		b.add('cap', capM, new THREE.CylinderGeometry(0.12, 0.12, 0.02, 8, 1, false, Math.PI / 2, Math.PI), { pos: V(0, 1.43, -0.17) });
		b.add('body', white, new THREE.BoxGeometry(0.12, 0.08, 0.01), { pos: V(0.13, 0.9, 0.29), rot: [-0.4, 0.2, 0] });
		b.add('props', black, new THREE.BoxGeometry(0.2, 0.2, 0.36), { pos: V(0.3, 1.33, 0.05) });
		b.add('props', C('lens', 0x3a3a48), new THREE.CylinderGeometry(0.07, 0.08, 0.14, 8), { pos: V(0.3, 1.33, 0.28), rot: [Math.PI / 2, 0, 0] });
		b.add('props', C('rec', 0xff2020, { emissive: 0x800000 }), ellipsoid(0.02, 0.02, 0.02, 5, 3), { pos: V(0.38, 1.44, 0.15) });
	},
	// Asuntos Internos: black suit, sunglasses, earpiece and briefcase.
	asuntos_internos(b) {
		const suit = C('black_suit', 0x22232a);
		pearBody(b, SKIN.crema, { shirt: suit, pants: suit, belted: false });
		lapels(b, white);
		tie(b, black);
		sunglasses(b);
		mouth(b);
		hairCap(b, C('hair_black', 0x1a1410), { y: 1.4 });
		b.add('head', C('earpiece', 0xdadada), ellipsoid(0.02, 0.02, 0.02, 5, 3), { pos: V(-0.2, 1.3, 0.02) });
		briefcase(b, C('case_black', 0x111111));
	},
	// Carcelero: grey-green guard uniform, keys and baton.
	carcelero(b) {
		const uni = C('guard_uniform', 0x5f6e4c), dark = C('guard_dark', 0x39432d);
		pearBody(b, SKIN.cacao, { shirt: uni, pants: dark });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b);
		mustache(b, C('hair_black', 0x1a1410));
		peakedCap(b, dark, black, C('silver', 0xc8ccd2));
		b.add('body', C('silver', 0xc8ccd2), new THREE.TorusGeometry(0.06, 0.012, 4, 10), { pos: V(0.32, 0.45, 0.32), rot: [0, 0.6, 0] });
		limb(b, 'props', black, V(-0.42, 0.62, 0.22), V(-0.4, 0.3, 0.32), 0.03);
	},
	// Armero (the station's armory, comisaria.md): grey work shirt under a leather apron, goggles up on a bald head,
	// a big beard and a wrench. Grumpy but fair.
	armero(b) {
		const shirt = C('work_shirt', 0x7d8590), apron = C('apron', 0x7a4a26);
		pearBody(b, SKIN.arena, { shirt, pants: C('work_pants', 0x3d4148) });
		b.add('body', apron, new THREE.BoxGeometry(0.5, 0.62, 0.03), { pos: V(0, 0.68, 0.4), rot: [-0.22, 0, 0] });
		for (const s of [-1, 1]) b.add('body', apron, new THREE.BoxGeometry(0.04, 0.16, 0.02), { pos: V(s * 0.2, 1.04, 0.29), rot: [-0.7, 0, 0] });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		for (const s of [-1, 1]) b.add('face', black, new THREE.BoxGeometry(0.09, 0.025, 0.02), { pos: V(s * 0.08, 1.39, 0.19), rot: [0, 0, s * 0.3] });
		const beard = C('beard', 0x6a4a30);
		b.add('face', beard, ellipsoid(0.17, 0.13, 0.08, 8, 5), { pos: V(0, 1.17, 0.15) });
		mustache(b, beard, 1.3);
		const glass = C('goggles', 0x8fd0e0, { emissive: 0x10303a });
		for (const s of [-1, 1]) b.add('head', glass, new THREE.CylinderGeometry(0.045, 0.045, 0.03, 8), { pos: V(s * 0.07, 1.5, 0.15), rot: [Math.PI / 2 - 0.5, 0, 0] });
		b.add('head', black, new THREE.TorusGeometry(0.172, 0.014, 4, 14), { pos: V(0, 1.47, 0.0), rot: [Math.PI / 2 - 0.15, 0, 0] });
		const steel = C('silver', 0xc8ccd2);
		limb(b, 'props', steel, V(0.5, 0.75, 0.22), V(0.56, 0.38, 0.3), 0.025);
		b.add('props', steel, new THREE.TorusGeometry(0.045, 0.018, 4, 8, Math.PI * 1.4), { pos: V(0.56, 0.36, 0.3) });
	},
	// Clotilde, the cleaner of the cleaning crew's jailbreak (fuga-limpieza.md): light blue smock with a pocket, a
	// red kerchief over her hair, yellow rubber gloves and a feather duster in the pocket.
	limpieza(b) {
		const smock = C('smock_blue', 0x8fc4e0), gloves = C('rubber_yellow', 0xf2d22a);
		pearBody(b, SKIN.arena, { shirt: smock, onePiece: true, belted: false, shoes: C('clog_white', 0xeeeeee) });
		b.add('body', C('smock_pocket', 0x6fa8c8), new THREE.BoxGeometry(0.2, 0.14, 0.02), { pos: V(0.16, 0.6, 0.43), rot: [-0.1, 0, 0] });
		for (let i = 0; i < 5; i++) b.add('props', C('feather', [0xd84a8a, 0x5ac0e0, 0xf2c84a][i % 3]), ellipsoid(0.035, 0.09, 0.02, 5, 3), { pos: V(0.1 + i * 0.03, 0.78, 0.43), rot: [0, 0, -0.5 + i * 0.25] });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		const scarf = C('kerchief_red', 0xd0383a);
		hairCap(b, scarf, { y: 1.4, sx: 1.08, sy: 0.6 });
		b.add('head', scarf, new THREE.ConeGeometry(0.06, 0.14, 5), { pos: V(0, 1.38, -0.22), rot: [-2.2, 0, 0] });
		for (const s of [-1, 1]) b.add('arms', gloves, ellipsoid(0.09, 0.09, 0.09, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	},
	// Preso: orange jumpsuit with a number, bald, ball and chain.
	preso(b) {
		const orange = C('jumpsuit', 0xff7a1a);
		pearBody(b, SKIN.celeste, { shirt: orange, onePiece: true, belted: false });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		b.add('body', white, new THREE.BoxGeometry(0.2, 0.1, 0.02), { pos: V(0, 0.86, 0.3), rot: [-0.4, 0, 0] });
		b.add('body', black, new THREE.BoxGeometry(0.14, 0.03, 0.01), { pos: V(0, 0.86, 0.315), rot: [-0.4, 0, 0] });
		b.add('props', C('iron', 0x30343a), ellipsoid(0.13, 0.13, 0.13, 8, 6), { pos: V(0.3, 0.13, 0.55) });
		limb(b, 'props', C('iron', 0x30343a), V(0.2, 0.08, 0.2), V(0.3, 0.13, 0.45), 0.015, 4);
	},
	// Abogado: beige suit, bow tie, slicked hair and a fat briefcase full of papers.
	abogado(b) {
		const suit = C('beige_suit', 0xc8b48a);
		pearBody(b, SKIN.arena, { shirt: suit, pants: suit, belted: false, shoes: C('brown_shoes', 0x5a3a20) });
		lapels(b, white);
		const bow = C('bowtie', 0x9a1c3a);
		for (const s of [-1, 1]) b.add('body', bow, new THREE.ConeGeometry(0.04, 0.07, 4), { pos: V(s * 0.035, 1.08, 0.22), rot: [0, 0, s * Math.PI / 2] });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		glasses(b, gold);
		mouth(b, { smile: true });
		hairCap(b, C('hair_brown', 0x4a2e1a), { y: 1.4, sy: 0.6 });
		briefcase(b, C('case_brown', 0x6a3e1e), -1);
		b.add('props', white, new THREE.BoxGeometry(0.06, 0.04, 0.3), { pos: V(-0.52, 0.57, 0.12) });
	},
	// Peluquero Ramiro (the pet salon): pink smock covered in dog hair, a quiff, a mustache and a pair of scissors.
	peluquero(b) {
		pearBody(b, SKIN.crema, { shirt: C('groomer_smock', 0xe889b0), onePiece: true, belted: false, shoes: C('clogs', 0x4a8a8a) });
		const fur = [C('fur_white', 0xf4efe6), C('fur_brown', 0x9a6a3a), C('fur_black', 0x2a2420)];
		const tufts = [[-0.2, 0.55], [0.15, 0.7], [0.0, 0.42], [0.25, 0.5], [-0.1, 0.85], [0.08, 0.95], [-0.28, 0.72]];
		tufts.forEach(([x, y], i) => b.add('body', fur[i % fur.length], ellipsoid(0.045, 0.03, 0.02, 5, 3), { pos: V(x, y, 0.4 - Math.abs(x) * 0.25) }));
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		const hair = C('hair_blond', 0xd8b040);
		hairCap(b, hair, { y: 1.38, back: 0.02 });
		b.add('cap', hair, ellipsoid(0.13, 0.06, 0.09, 8, 4), { pos: V(0.03, 1.5, 0.15), rot: [-0.9, 0, 0.2] });
		mustache(b, C('mustache_blond', 0xb89030), 1.3);
		const steel = C('silver', 0xc8ccd2);
		for (const s of [-1, 1]) limb(b, 'props', steel, V(0.52, 0.62, 0.2), V(0.52 + s * 0.04, 0.62, 0.42), 0.012);
		for (const s of [-1, 1]) b.add('props', C('scissor_grip', 0xe04a4a), new THREE.TorusGeometry(0.03, 0.01, 4, 8), { pos: V(0.52 + s * 0.035, 0.62, 0.17), rot: [0, Math.PI / 2, 0] });
	},
	// Ferretero Tobías (the hardware store): grey shop coat with pockets full of screwdrivers, a pencil behind the ear,
	// glasses on the tip of the nose and a bushy grey mustache.
	ferretero(b) {
		pearBody(b, SKIN.cacao, { shirt: C('shop_coat', 0x8a9098), onePiece: true, belted: false, shoes: C('work_boots', 0x4a3a2a) });
		for (const s of [-1, 1]) b.add('body', C('coat_pocket', 0x767c84), new THREE.BoxGeometry(0.16, 0.12, 0.03), { pos: V(s * 0.2, 0.62, 0.42) });
		const handles = [C('handle_red', 0xd23a3a), C('handle_yellow', 0xf2c230), C('handle_blue', 0x3c7be8)];
		handles.forEach((m, i) => b.add('props', m, new THREE.CylinderGeometry(0.014, 0.014, 0.1, 5), { pos: V(0.15 + i * 0.04, 0.7, 0.42), rot: [0.15, 0, (i - 1) * 0.2] }));
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		b.add('face', black, new THREE.TorusGeometry(0.045, 0.008, 4, 10), { pos: V(-0.07, 1.27, 0.2) });
		b.add('face', black, new THREE.TorusGeometry(0.045, 0.008, 4, 10), { pos: V(0.07, 1.27, 0.2) });
		mustache(b, C('mustache_grey', 0xb8b8b4), 1.4);
		const hair = C('hair_grey', 0xc8c8c4);
		for (const s of [-1, 1]) b.add('head', hair, ellipsoid(0.07, 0.08, 0.1, 6, 4), { pos: V(s * 0.17, 1.38, -0.02) });
		limb(b, 'props', C('pencil', 0xf2c230), V(0.16, 1.42, 0.0), V(0.24, 1.36, 0.1), 0.012);
	},
	// Don Cosme (the hardware store's regular): a retiree in a brown cardigan and a flat cap, waiting for his key copy
	// with the old key held up in his hand.
	cosme(b) {
		pearBody(b, SKIN.arena, { shirt: C('cardigan_brown', 0x9a6a3a), pants: C('grey_pants', 0x6a6e74), shoes: C('brown_shoes', 0x5a3a20) });
		for (let i = 0; i < 4; i++) b.add('body', C('cardigan_button', 0xe8d8b0), ellipsoid(0.018, 0.018, 0.01, 5, 3), { pos: V(0, 0.95 - i * 0.12, 0.31 + i * 0.03) });
		eyes(b, 1.33, 0.17, 0.08, 0.045);
		mouth(b, { smile: true });
		mustache(b, C('mustache_white', 0xeeeeea), 1.0);
		const cap = C('flat_cap', 0x6a5a48);
		b.add('cap', cap, ellipsoid(0.21, 0.07, 0.2, 10, 4), { pos: V(0, 1.47, 0.0) });
		b.add('cap', cap, new THREE.BoxGeometry(0.22, 0.02, 0.1), { pos: V(0, 1.45, 0.2), rot: [0.2, 0, 0] });
		b.add('props', gold, new THREE.BoxGeometry(0.03, 0.09, 0.008), { pos: V(0.49, 0.74, 0.12) });
		b.add('props', gold, new THREE.TorusGeometry(0.025, 0.007, 4, 8), { pos: V(0.49, 0.8, 0.12) });
	},
	// Señora del caniche (the pet salon): lilac fur coat, a tall white hairdo, sunglasses up, pearls and a tiny handbag.
	senora(b) {
		pearBody(b, SKIN.arena, { shirt: C('fur_coat', 0xb48ad8), onePiece: true, belted: false, shoes: C('heels', 0x6a2a8a) });
		const collar = C('coat_fur', 0xf0e8f4);
		b.add('body', collar, new THREE.TorusGeometry(0.2, 0.06, 6, 14), { pos: V(0, 1.06, 0.02), rot: [Math.PI / 2, 0, 0] });
		for (let i = 0; i < 7; i++) {
			const a = Math.PI * (0.15 + 0.7 * (i / 6));
			b.add('body', C('pearl', 0xfaf6ee), ellipsoid(0.022, 0.022, 0.022, 5, 3), { pos: V(Math.cos(a) * 0.15, 1.14 - Math.sin(a) * 0.08, 0.16) });
		}
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		for (const s of [-1, 1]) b.add('face', C('blush', 0xf09a9a), ellipsoid(0.04, 0.025, 0.01, 6, 3), { pos: V(s * 0.12, 1.26, 0.18) });
		const hair = C('hair_white', 0xf4f0ea);
		hairCap(b, hair, { y: 1.39, back: 0.02 });
		b.add('head', hair, ellipsoid(0.15, 0.17, 0.14, 10, 6), { pos: V(0, 1.62, -0.02) });
		b.add('head', C('sunglasses_up', 0x2a1a3a), new THREE.BoxGeometry(0.26, 0.04, 0.03), { pos: V(0, 1.44, 0.175), rot: [-0.3, 0, 0] });
		b.add('props', C('tiny_bag', 0xe8508a), new THREE.BoxGeometry(0.14, 0.1, 0.06), { pos: V(-0.52, 0.55, 0.12) });
		b.add('props', gold, new THREE.TorusGeometry(0.05, 0.008, 4, 8, Math.PI), { pos: V(-0.52, 0.6, 0.12) });
	},
	// Panadera Marta (the bakery): pear dress with a white apron dusted with flour, a tall baker's hat and a rolling pin.
	panadera(b) {
		pearBody(b, SKIN.arena, { shirt: C('baker_dress', 0x5aa0d8), onePiece: true, belted: false, shoes: white });
		const apron = C('apron', 0xf6f2e8);
		b.add('body', apron, loft([{ y: 0.3, rx: 0.42, rz: 0.12 }, { y: 0.75, rx: 0.36, rz: 0.1 }, { y: 1.0, rx: 0.2, rz: 0.08 }], 8), { pos: V(0, 0, 0.3) });
		for (const [x, y] of [[-0.12, 0.62], [0.1, 0.48], [0.02, 0.8]]) b.add('body', C('flour', 0xffffff), ellipsoid(0.05, 0.035, 0.02, 5, 3), { pos: V(x, y, 0.43) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		for (const s of [-1, 1]) b.add('face', C('blush', 0xf09a9a), ellipsoid(0.04, 0.025, 0.01, 6, 3), { pos: V(s * 0.12, 1.26, 0.18) });
		hairCap(b, C('hair_red', 0xb0482a), { y: 1.38, back: 0.02 });
		b.add('cap', white, new THREE.CylinderGeometry(0.17, 0.15, 0.12, 8), { pos: V(0, 1.5, 0.0) });
		b.add('cap', white, ellipsoid(0.22, 0.12, 0.2, 10, 5), { pos: V(0, 1.62, 0.0) });
		limb(b, 'props', C('rolling_pin', 0xc8945a), V(0.5, 0.55, 0.0), V(0.5, 0.55, 0.42), 0.04);
	},
	// Pastelero (escena-del-crimen.md, the stolen cake): six of them at the contest, all floury and alike. The parts the
	// game changes per cook have their own nodes: apron (recolored), hair (recolored, under the hat), glasses (shown or
	// not), whisk (mirrored for a lefty) and the shoes (stretched to his size).
	pastelero(b) {
		pearBody(b, SKIN.crema, { shirt: C('chef_jacket', 0xf4f4f0), pants: C('chef_pants', 0x5a5e66), shoes: C('cook_shoes', 0x2a2a2e) });
		for (const y of [0.82, 0.95]) for (const s of [-1, 1]) b.add('body', C('chef_button', 0xc8c8c0), new THREE.SphereGeometry(0.018, 5, 3), { pos: V(s * 0.07, y, 0.3) });
		b.add('apron', C('apron', 0xffffff), loft([{ y: 0.3, rx: 0.42, rz: 0.12 }, { y: 0.72, rx: 0.36, rz: 0.1 }], 8), { pos: V(0, 0, 0.31) });
		for (const [x, y, z] of [[-0.14, 0.6, 0.43], [0.12, 0.5, 0.43], [0.05, 0.9, 0.3], [-0.2, 1.3, 0.12], [0.16, 1.18, 0.15]]) b.add('body', C('flour', 0xffffff), ellipsoid(0.05, 0.035, 0.02, 5, 3), { pos: V(x, y, z) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		b.add('hair', C('hair', 0xffffff), ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.4, -0.02) });
		b.add('cap', white, new THREE.CylinderGeometry(0.18, 0.17, 0.14, 8), { pos: V(0, 1.5, 0.0) });
		b.add('cap', white, ellipsoid(0.25, 0.16, 0.23, 10, 5), { pos: V(0, 1.66, 0.0) });
		glasses(b);
		// The glasses() helper puts them on the face; this cook keeps them in their own node.
		const face = b.parts.get('face');
		const frames = face.get(black).splice(-3);
		b.parts.set('glasses', new Map([[black, frames]]));
		limb(b, 'whisk', C('whisk_handle', 0xc8945a), V(0.5, 0.5, 0.0), V(0.5, 0.62, 0.18), 0.03);
		b.add('whisk', C('whisk_wire', 0xc0c4c8), ellipsoid(0.06, 0.1, 0.06, 6, 4), { pos: V(0.5, 0.7, 0.26), rot: [0.6, 0, 0] });
	},
	// Cliente (a bakery customer): checked shirt, hat and a paper bag of bread.
	cliente(b) {
		pearBody(b, SKIN.crema, { shirt: C('checked_shirt', 0x3a8a5a), pants: C('brown_pants', 0x6a4a30) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b);
		b.add('cap', C('hat_gray', 0x6a6e74), new THREE.CylinderGeometry(0.17, 0.19, 0.12, 8), { pos: V(0, 1.5, 0.01) });
		b.add('cap', C('hat_gray', 0x6a6e74), new THREE.CylinderGeometry(0.28, 0.28, 0.02, 10), { pos: V(0, 1.44, 0.01) });
		b.add('props', C('paper_bag', 0xc9a66b), new THREE.BoxGeometry(0.18, 0.26, 0.12), { pos: V(0.52, 0.5, 0.12) });
		b.add('props', C('baguette', 0xd9a050), new THREE.CylinderGeometry(0.03, 0.03, 0.3, 6), { pos: V(0.52, 0.7, 0.12), rot: [0, 0, 0.2] });
	},
	// Clienta (a bakery customer): yellow raincoat, short black hair and a shopping bag.
	clienta(b) {
		pearBody(b, SKIN.cacao, { shirt: C('raincoat', 0xf0c030), onePiece: true, belted: false, shoes: C('boots', 0x2a6a8a) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { open: true });
		hairCap(b, C('hair_black', 0x1a1410), { y: 1.4, sy: 0.65 });
		b.add('props', C('shopping_bag', 0xd84a6a), new THREE.BoxGeometry(0.1, 0.3, 0.3), { pos: V(-0.52, 0.45, 0.12) });
	},
	// Político: white suit, red tie, sash, big smile and a helmet of hair.
	politico(b) {
		const suit = C('white_suit', 0xf0eee8);
		pearBody(b, SKIN.crema, { shirt: suit, pants: suit, belted: false, shoes: C('shiny_shoes', 0x222222) });
		lapels(b, C('shirt_blue', 0xbfd8ff));
		tie(b, C('red_tie', 0xd82a2a));
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		const hair = C('hair_blond', 0xe8c060);
		hairCap(b, hair, { y: 1.4, sx: 1.08, sy: 0.7 });
		b.add('head', hair, ellipsoid(0.16, 0.06, 0.1, 8, 4), { pos: V(0.04, 1.5, 0.12), rot: [0.3, 0, -0.2] });
		b.add('body', C('sash', 0x2a8a4a), new THREE.TorusGeometry(0.4, 0.035, 4, 14), { pos: V(0, 0.75, 0.02), rot: [Math.PI / 2, 0.6, 0], scale: [1, 0.85, 1] });
	},
	// Mudancero (persecución): orange overalls with straps, a back support belt, a cap backwards and a tape measure.
	mudancero(b) {
		const overalls = C('overalls', 0xe8873a);
		pearBody(b, SKIN.cacao, { shirt: C('tshirt_grey', 0xa8acb4), pants: overalls });
		for (const s of [-1, 1]) b.add('body', overalls, new THREE.BoxGeometry(0.07, 0.4, 0.03), { pos: V(s * 0.13, 0.95, 0.28), rot: [-0.35, 0, 0] });
		b.add('body', C('back_belt', 0x2a2a30), loft([{ y: 0.62, rx: 0.47, rz: 0.43 }, { y: 0.72, rx: 0.46, rz: 0.42 }], 10));
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		const cap = C('mover_cap', 0x3a6ad8);
		b.add('cap', cap, ellipsoid(0.205, 0.12, 0.195, 10, 5), { pos: V(0, 1.42, 0.0) });
		b.add('cap', cap, new THREE.CylinderGeometry(0.12, 0.12, 0.02, 8, 1, false, Math.PI / 2, Math.PI), { pos: V(0, 1.43, -0.17) });
		b.add('props', C('tape_measure', 0xf2c84b), new THREE.BoxGeometry(0.1, 0.1, 0.05), { pos: V(0.46, 0.62, 0.1) });
	},
	// Heladero (persecución): white jacket with a pink apron, a paper cap, a big mustache and a cone in his hand.
	heladero(b) {
		const jacket = C('ice_jacket', 0xf6f2ea), pink = C('ice_pink', 0xf29ab8);
		pearBody(b, SKIN.arena, { shirt: jacket, pants: C('ice_pants', 0x8fb8d8) });
		b.add('body', pink, new THREE.BoxGeometry(0.36, 0.42, 0.04), { pos: V(0, 0.62, 0.33), rot: [-0.18, 0, 0] });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { open: true });
		mustache(b, C('ice_mustache', 0x3a2414), 1.3);
		b.add('cap', pink, new THREE.BoxGeometry(0.32, 0.12, 0.16), { pos: V(0, 1.5, 0.0) });
		b.add('cap', white, new THREE.BoxGeometry(0.33, 0.03, 0.17), { pos: V(0, 1.45, 0.0) });
		b.add('props', C('ice_cone', 0xd9a35a), new THREE.ConeGeometry(0.05, 0.16, 6), { pos: V(0.52, 0.55, 0.15), rot: [Math.PI, 0, 0] });
		b.add('props', pink, ellipsoid(0.06, 0.06, 0.06, 6, 4), { pos: V(0.52, 0.66, 0.15) });
	},
	// El Oso's nephew (robo-banco-techo.md, decision 126): a kid in an orange hoodie with a cap on backwards and big
	// sneakers, the toy helicopter's remote control held in both hands in front of him (its own node, 'remote').
	sobrino(b) {
		const hoodie = C('hoodie_orange', 0xf08a2a);
		pearBody(b, SKIN.arena, { shirt: hoodie, pants: C('kid_shorts', 0x3a5a8a), shoes: C('sneakers_white', 0xf2f2f2) });
		b.add('body', C('hoodie_pocket', 0xd8741e), new THREE.BoxGeometry(0.36, 0.14, 0.04), { pos: V(0, 0.82, 0.37), rot: [-0.25, 0, 0] });
		eyes(b, 1.33, 0.17, 0.09, 0.055);
		mouth(b, { smile: true });
		const cap = C('kid_cap', 0x2a8a4a);
		b.add('cap', cap, ellipsoid(0.215, 0.1, 0.21, 10, 5), { pos: V(0, 1.45, 0.0) });
		b.add('cap', cap, new THREE.BoxGeometry(0.24, 0.02, 0.14), { pos: V(0, 1.44, -0.22), rot: [-0.2, 0, 0] });
		b.add('remote', black, new THREE.BoxGeometry(0.26, 0.05, 0.16), { pos: V(0, 0.98, 0.42), rot: [-0.5, 0, 0] });
		for (const x of [-0.07, 0.07]) b.add('remote', C('remote_stick', 0xd8322a), new THREE.CylinderGeometry(0.012, 0.012, 0.06, 5), { pos: V(x, 1.02, 0.44), rot: [-0.5, 0, 0] });
		b.add('remote', C('remote_antenna', 0xc8ccd2), new THREE.CylinderGeometry(0.005, 0.005, 0.3, 4), { pos: V(0.1, 1.14, 0.38), rot: [-0.3, 0, -0.2] });
	},
	// Don Plácido, the town bank's only clerk (robo-banco-pueblo.md, decision 127): white shirt, a brown knitted vest,
	// bald with a white crown of hair and a big white mustache, his eyes shut and his mouth open, snoring. The back door's key sticks out of his vest pocket (its own node, 'key', so the game hides it once taken).
	empleado(b) {
		const vest = C('vest_brown', 0x7a5032), hair = C('hair_white', 0xeeeeea);
		pearBody(b, SKIN.crema, { shirt: C('shirt_white', 0xf4f2ec), pants: C('clerk_pants', 0x4a4038) });
		b.add('body', vest, loft([{ y: 0.55, rx: 0.42, rz: 0.37 }, { y: 0.8, rx: 0.37, rz: 0.33 }, { y: 1.05, rx: 0.26, rz: 0.24 }], 10));
		b.add('body', C('vest_pocket', 0x5e3c24), new THREE.BoxGeometry(0.12, 0.08, 0.03), { pos: V(0.17, 0.92, 0.31), rot: [-0.35, 0.4, 0] });
		b.add('key', gold, new THREE.BoxGeometry(0.025, 0.1, 0.012), { pos: V(0.17, 0.98, 0.32), rot: [-0.35, 0.4, 0] });
		b.add('key', gold, new THREE.TorusGeometry(0.025, 0.008, 4, 8), { pos: V(0.17, 1.04, 0.31), rot: [-0.35, 0.4, 0] });
		for (const s of [-1, 1]) b.add('face', black, new THREE.TorusGeometry(0.035, 0.008, 4, 8, Math.PI), { pos: V(s * 0.08, 1.34, 0.2), rot: [0, 0, Math.PI] });
		mouth(b, { open: true });
		mustache(b, hair, 1.4);
		for (const s of [-1, 1]) b.add('head', hair, ellipsoid(0.07, 0.1, 0.14, 6, 4), { pos: V(s * 0.18, 1.32, -0.03) });
		b.add('head', hair, ellipsoid(0.16, 0.09, 0.07, 8, 4), { pos: V(0, 1.3, -0.17) });
	},
	// Repartidor (persecución): red jacket, a big helmet and the thermal delivery backpack on his back.
	repartidor(b) {
		const jacket = C('delivery_red', 0xd8322a), helmet = C('helmet_white', 0xf2f2f0);
		pearBody(b, SKIN.crema, { shirt: jacket, pants: C('delivery_jeans', 0x3a4a6a) });
		b.add('props', C('thermal_box', 0xf2b01e), new THREE.BoxGeometry(0.5, 0.5, 0.36), { pos: V(0, 0.95, -0.5) });
		b.add('props', C('thermal_logo', 0xd8322a), new THREE.BoxGeometry(0.3, 0.12, 0.02), { pos: V(0, 1.0, -0.69) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { open: true });
		b.add('cap', helmet, ellipsoid(0.27, 0.22, 0.27, 10, 6), { pos: V(0, 1.42, -0.02) });
		b.add('cap', C('visor', 0x2a3340), new THREE.BoxGeometry(0.3, 0.08, 0.04), { pos: V(0, 1.38, 0.25) });
	},
	// Puestero (politico-mercado.md, the market's twelve vendors): rolled-up shirt, a long apron the game tints per
	// stall (its own node), a flat cap and a pencil behind the ear.
	puestero(b) {
		pearBody(b, SKIN.arena, { shirt: C('vendor_shirt', 0xe8e2d0), pants: C('vendor_pants', 0x4a4e58) });
		b.add('apron', C('vendor_apron', 0x3a8a5a), loft([{ y: 0.3, rx: 0.42, rz: 0.12 }, { y: 0.78, rx: 0.36, rz: 0.1 }, { y: 1.02, rx: 0.2, rz: 0.08 }], 8), { pos: V(0, 0, 0.31) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { smile: true });
		mustache(b, C('vendor_mustache', 0x3a2414));
		const cap = C('flat_cap', 0x6a5a48);
		b.add('cap', cap, ellipsoid(0.215, 0.09, 0.21, 10, 5), { pos: V(0, 1.45, 0.0) });
		b.add('cap', cap, new THREE.BoxGeometry(0.26, 0.02, 0.12), { pos: V(0, 1.43, 0.2), rot: [0.15, 0, 0] });
		limb(b, 'props', C('pencil', 0xf2c84b), V(0.2, 1.33, 0.02), V(0.2, 1.4, -0.1), 0.012);
	},
	// Bank robbers (robo-banco.md, step 2): black clothes and gloves, and a rubber animal mask over the whole head.
	ladron_conejo(b) {
		robber(b, C('mask_rabbit', 0xf2eeea), (m) => {
			for (const s of [-1, 1]) b.add('head', m, ellipsoid(0.05, 0.2, 0.03, 6, 5), { pos: V(s * 0.08, 1.62, 0.0), rot: [0, 0, s * -0.15] });
			for (const s of [-1, 1]) b.add('head', C('mask_rabbit_ear', 0xf2a0b8), ellipsoid(0.03, 0.15, 0.01, 6, 4), { pos: V(s * 0.08, 1.62, 0.025), rot: [0, 0, s * -0.15] });
			b.add('face', C('mask_rabbit_nose', 0xf27a9a), ellipsoid(0.03, 0.025, 0.02, 6, 4), { pos: V(0, 1.27, 0.2) });
			for (const s of [-1, 1]) b.add('face', white, new THREE.BoxGeometry(0.04, 0.05, 0.01), { pos: V(s * 0.022, 1.2, 0.19) });
		});
	},
	ladron_chancho(b) {
		robber(b, C('mask_pig', 0xf2a6b6), (m) => {
			b.add('face', m, new THREE.CylinderGeometry(0.07, 0.07, 0.06, 10), { pos: V(0, 1.26, 0.2), rot: [Math.PI / 2, 0, 0] });
			for (const s of [-1, 1]) b.add('face', C('mask_pig_hole', 0x8a3a4a), ellipsoid(0.015, 0.02, 0.01, 5, 3), { pos: V(s * 0.025, 1.26, 0.232) });
			for (const s of [-1, 1]) b.add('head', m, new THREE.ConeGeometry(0.06, 0.1, 4), { pos: V(s * 0.14, 1.48, 0.0), rot: [0.4, 0, s * -0.5] });
		});
		b.add('props', C('sandwich_bread', 0xe0b070), new THREE.BoxGeometry(0.16, 0.06, 0.1), { pos: V(0.5, 0.66, 0.16) });
		b.add('props', C('sandwich_ham', 0xe06a7a), new THREE.BoxGeometry(0.17, 0.015, 0.11), { pos: V(0.5, 0.66, 0.16) });
	},
	ladron_pato(b) {
		robber(b, C('mask_duck', 0xf2d23a), (m) => {
			b.add('face', C('mask_duck_beak', 0xf2902a), new THREE.BoxGeometry(0.16, 0.04, 0.14), { pos: V(0, 1.24, 0.24) });
			b.add('head', m, ellipsoid(0.03, 0.06, 0.03, 5, 3), { pos: V(0, 1.53, 0.04), rot: [0.5, 0, 0] });
		});
		// The ear muffs: the drill is loud and he hears nothing.
		for (const s of [-1, 1]) b.add('head', C('ear_muff', 0xd8322a), ellipsoid(0.06, 0.08, 0.05, 6, 4), { pos: V(s * 0.2, 1.3, 0.0) });
		b.add('head', C('ear_muff_band', 0x2a2a30), new THREE.TorusGeometry(0.2, 0.015, 4, 12, Math.PI), { pos: V(0, 1.3, 0.0) });
	},
	// El Oso, the boss: a brown bear mask, a gold chain and a phone in his hand.
	ladron_oso(b) {
		robber(b, C('mask_bear', 0x8a5a32), (m) => {
			for (const s of [-1, 1]) b.add('head', m, ellipsoid(0.07, 0.07, 0.04, 6, 4), { pos: V(s * 0.15, 1.48, 0.0) });
			b.add('face', C('mask_bear_muzzle', 0xd8b088), ellipsoid(0.09, 0.07, 0.05, 8, 5), { pos: V(0, 1.24, 0.18) });
			b.add('face', black, ellipsoid(0.035, 0.025, 0.02, 6, 4), { pos: V(0, 1.27, 0.23) });
		});
		b.add('body', gold, new THREE.TorusGeometry(0.15, 0.015, 4, 14), { pos: V(0, 1.06, 0.12), rot: [1.2, 0, 0] });
		b.add('props', C('phone_red', 0xc8202a), new THREE.BoxGeometry(0.06, 0.16, 0.05), { pos: V(-0.5, 0.72, 0.12) });
	},
	// The grandpa robbers (robo-banco-abuelos.md, step 1): the same four masks, a cardigan of each one's color.
	abuelo_conejo(b) {
		grandpaRobber(b, C('mask_rabbit', 0xf2eeea), C('cardigan_beige', 0xc8b48a), (m) => {
			for (const s of [-1, 1]) b.add('mask', m, ellipsoid(0.05, 0.2, 0.03, 6, 5), { pos: V(s * 0.08, 1.62, 0.0), rot: [0, 0, s * -0.15] });
			for (const s of [-1, 1]) b.add('mask', C('mask_rabbit_ear', 0xf2a0b8), ellipsoid(0.03, 0.15, 0.01, 6, 4), { pos: V(s * 0.08, 1.62, 0.025), rot: [0, 0, s * -0.15] });
			b.add('mask', C('mask_rabbit_nose', 0xf27a9a), ellipsoid(0.03, 0.025, 0.02, 6, 4), { pos: V(0, 1.27, 0.22) });
			for (const s of [-1, 1]) b.add('mask', white, new THREE.BoxGeometry(0.04, 0.05, 0.01), { pos: V(s * 0.022, 1.2, 0.21) });
		});
	},
	abuelo_chancho(b) {
		grandpaRobber(b, C('mask_pig', 0xf2a6b6), C('cardigan_brown', 0x7a5236), (m) => {
			b.add('mask', m, new THREE.CylinderGeometry(0.07, 0.07, 0.06, 10), { pos: V(0, 1.26, 0.22), rot: [Math.PI / 2, 0, 0] });
			for (const s of [-1, 1]) b.add('mask', C('mask_pig_hole', 0x8a3a4a), ellipsoid(0.015, 0.02, 0.01, 5, 3), { pos: V(s * 0.025, 1.26, 0.252) });
			for (const s of [-1, 1]) b.add('mask', m, new THREE.ConeGeometry(0.06, 0.1, 4), { pos: V(s * 0.14, 1.48, 0.0), rot: [0.4, 0, s * -0.5] });
		});
		b.add('props', C('sandwich_bread', 0xe0b070), new THREE.BoxGeometry(0.16, 0.06, 0.1), { pos: V(-0.5, 0.66, 0.16) });
		b.add('props', C('sandwich_ham', 0xe06a7a), new THREE.BoxGeometry(0.17, 0.015, 0.11), { pos: V(-0.5, 0.66, 0.16) });
	},
	// The duck grandma: a lilac cardigan, a grey bun over the mask and her bag of marbles (step 3).
	abuelo_pato(b) {
		grandpaRobber(b, C('mask_duck', 0xf2d23a), C('cardigan_lilac', 0xa88ac8), (m) => {
			b.add('mask', C('mask_duck_beak', 0xf2902a), new THREE.BoxGeometry(0.16, 0.04, 0.14), { pos: V(0, 1.24, 0.26) });
			b.add('mask', C('bun_grey', 0xc8c8cc), ellipsoid(0.1, 0.09, 0.1, 8, 5), { pos: V(0, 1.55, -0.06) });
		});
		b.add('props', C('marble_bag', 0x3a6ad8), ellipsoid(0.08, 0.1, 0.08, 6, 4), { pos: V(-0.5, 0.52, 0.12) });
	},
	// El Oso, the boss: a bear mask, the gold chain over his cardigan and the phone in his hand.
	abuelo_oso(b) {
		grandpaRobber(b, C('mask_bear', 0x8a5a32), C('cardigan_navy', 0x2e3a5c), (m) => {
			for (const s of [-1, 1]) b.add('mask', m, ellipsoid(0.07, 0.07, 0.04, 6, 4), { pos: V(s * 0.15, 1.48, 0.0) });
			b.add('mask', C('mask_bear_muzzle', 0xd8b088), ellipsoid(0.09, 0.07, 0.05, 8, 5), { pos: V(0, 1.24, 0.2) });
			b.add('mask', black, ellipsoid(0.035, 0.025, 0.02, 6, 4), { pos: V(0, 1.27, 0.25) });
		});
		b.add('body', gold, new THREE.TorusGeometry(0.15, 0.015, 4, 14), { pos: V(0, 1.06, 0.12), rot: [1.2, 0, 0] });
		b.add('props', C('phone_red', 0xc8202a), new THREE.BoxGeometry(0.06, 0.16, 0.05), { pos: V(-0.5, 0.72, 0.12) });
	},
	// Capataz Fermín (the doll factory): blue work shirt under a yellow reflective vest, a yellow hard hat, a whistle on
	// a red cord, a clipboard in hand and a thick black mustache.
	capataz(b) {
		pearBody(b, SKIN.arena, { shirt: C('work_shirt', 0x3a5a8a), pants: C('work_pants', 0x4a4a52), shoes: C('work_boots', 0x4a3a2a) });
		const vest = C('safety_vest', 0xf2d21e), stripe = C('vest_stripe', 0xe8ecf0);
		b.add('body', vest, loft([
			{ y: 0.55, rx: 0.475, rz: 0.425 }, { y: 0.8, rx: 0.375, rz: 0.335 }, { y: 1.0, rx: 0.27, rz: 0.25 },
		], 10));
		b.add('body', stripe, loft([{ y: 0.66, rx: 0.445, rz: 0.4 }, { y: 0.72, rx: 0.42, rz: 0.375 }], 10));
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mustache(b, black, 1.3);
		const hat = C('hard_hat', 0xf2c21e);
		b.add('cap', hat, ellipsoid(0.23, 0.15, 0.23, 10, 5), { pos: V(0, 1.45, 0.0) });
		b.add('cap', hat, new THREE.CylinderGeometry(0.28, 0.28, 0.03, 12), { pos: V(0, 1.42, 0.03) });
		limb(b, 'props', C('whistle_cord', 0xd23a3a), V(-0.1, 1.12, 0.2), V(0.04, 0.96, 0.31), 0.008);
		b.add('props', C('whistle', 0xc8ccd2), new THREE.CylinderGeometry(0.02, 0.02, 0.06, 6), { pos: V(0.06, 0.95, 0.32), rot: [0, 0, Math.PI / 2] });
		b.add('props', C('clipboard', 0x8a5a30), new THREE.BoxGeometry(0.22, 0.3, 0.02), { pos: V(0.5, 0.72, 0.18), rot: [0.3, 0, 0] });
		b.add('props', white, new THREE.BoxGeometry(0.18, 0.24, 0.005), { pos: V(0.5, 0.72, 0.195), rot: [0.3, 0, 0] });
	},
	// Operaria Nilda (the doll factory's eyes machine): pink work coat, a white hairnet over grey curls, safety goggles
	// pushed up and a doll's googly eye stuck on her cheek.
	operaria(b) {
		pearBody(b, SKIN.crema, { shirt: C('factory_coat', 0xe88aa8), onePiece: true, belted: false, shoes: C('clogs', 0xf2f2f0) });
		eyes(b, 1.33, 0.17, 0.08, 0.05);
		mouth(b, { open: true });
		b.add('head', C('curls_grey', 0xb8b4b0), ellipsoid(0.22, 0.12, 0.21, 10, 5), { pos: V(0, 1.44, -0.02) });
		b.add('cap', C('hairnet', 0xf6f6f2, { transparent: true, opacity: 0.85 }), ellipsoid(0.23, 0.13, 0.22, 10, 5), { pos: V(0, 1.47, -0.02) });
		b.add('cap', C('goggles', 0x9ad0e8), new THREE.BoxGeometry(0.3, 0.06, 0.04), { pos: V(0, 1.47, 0.18) });
		b.add('face', white, ellipsoid(0.035, 0.035, 0.015, 6, 4), { pos: V(0.15, 1.24, 0.15) });
		b.add('face', black, ellipsoid(0.015, 0.015, 0.008, 5, 3), { pos: V(0.155, 1.23, 0.165) });
	},
};

export const NPC_NAMES = Object.keys(NPCS);
export const models = Object.fromEntries(NPC_NAMES.map((n) => [`npc_${n}`, () => {
	const b = new Builder(`npc_${n}`);
	NPCS[n](b);
	return b.build();
}]));

const SCALE = { comisario: 1.15, comisario_pijama: 1.15, abuelo: 0.82, abuela: 0.8, chela: 0.85, portero: 1.2, corista: 0.85, corista_b: 0.85, ernesto: 1.0, portera: 0.9, ladron_oso: 1.15, abuelo_oso: 1.15 };
const row = (names, z = 0) => names.map((n, i) => ({ name: `npc_${n}`, pos: [(i - (names.length - 1) / 2) * 1.2, 0, z], rotY: 0.3, scale: SCALE[n] }));
export const views = {
	npcs_a: { items: row(NPC_NAMES.slice(0, 5)), cam: { pos: [0, 1.3, 8.0], target: [0, 0.85, 0], fov: 34 } },
	npcs_b: { items: row(NPC_NAMES.slice(5)), cam: { pos: [0, 1.3, 8.0], target: [0, 0.85, 0], fov: 34 } },
	...Object.fromEntries(NPC_NAMES.map((n) => [`npc_${n}`, {
		items: [{ name: `npc_${n}`, pos: [-0.5, 0, 0], rotY: 0.35, scale: SCALE[n] }, { name: `npc_${n}`, pos: [0.7, 0, 0], rotY: Math.PI - 0.6, scale: SCALE[n] }],
		cam: { pos: [0.1, 1.3, 4.2], target: [0.1, 0.8, 0], fov: 34 },
	}])),
};
