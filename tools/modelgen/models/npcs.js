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
};

export const NPC_NAMES = Object.keys(NPCS);
export const models = Object.fromEntries(NPC_NAMES.map((n) => [`npc_${n}`, () => {
	const b = new Builder(`npc_${n}`);
	NPCS[n](b);
	return b.build();
}]));

const SCALE = { comisario: 1.15, abuelo: 0.82 };
const row = (names, z = 0) => names.map((n, i) => ({ name: `npc_${n}`, pos: [(i - (names.length - 1) / 2) * 1.2, 0, z], rotY: 0.3, scale: SCALE[n] }));
export const views = {
	npcs_a: { items: row(NPC_NAMES.slice(0, 5)), cam: { pos: [0, 1.3, 8.0], target: [0, 0.85, 0], fov: 34 } },
	npcs_b: { items: row(NPC_NAMES.slice(5)), cam: { pos: [0, 1.3, 8.0], target: [0, 0.85, 0], fov: 34 } },
	...Object.fromEntries(NPC_NAMES.map((n) => [`npc_${n}`, {
		items: [{ name: `npc_${n}`, pos: [-0.5, 0, 0], rotY: 0.35, scale: SCALE[n] }, { name: `npc_${n}`, pos: [0.7, 0, 0], rotY: Math.PI - 0.6, scale: SCALE[n] }],
		cam: { pos: [0.1, 1.3, 4.2], target: [0.1, 0.8, 0], fov: 34 },
	}])),
};
