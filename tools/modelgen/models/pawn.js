// Props of the pawn shop "Empeños La Última Oferta" (docs/diseno/allanamiento-empenos.md): the barred counter, a glass
// case, a shelf full of pawned things, the knight's armor, the stuffed crocodile, the old TV, the guitar case, the
// parrot's cage, the cookie jar, the stock room's shelf and boxes, the big safe and the giant price tag of the sign,
// with origins at the floor in the middle of each piece (the price tag at its middle). Placeholder, not final art.
import { Builder, mat, ellipsoid, V, THREE } from '../lib.js';
import { pearBody, eyes } from './pear.js';

const brass = () => mat('pawn_brass', 0xe0b040, { metalness: 0.6, roughness: 0.3 });
const wood = () => mat('pawn_wood', 0x6a4028);

// The counter, 5 m long, 1 m tall and 0.8 m deep, its front to -Z (the shop), with brass bars on top and a window in
// the middle where things change hands.
export function buildPawnCounter() {
	const b = new Builder('pawn_counter');
	b.add('body', mat('pawn_counter_green', 0x2f5a46), new THREE.BoxGeometry(5.0, 0.96, 0.8), { pos: V(0, 0.48, 0) });
	b.add('top', wood(), new THREE.BoxGeometry(5.1, 0.04, 0.86), { pos: V(0, 0.98, 0) });
	b.add('rail', brass(), new THREE.BoxGeometry(5.0, 0.04, 0.04), { pos: V(0, 2.0, 0.3) });
	for (let i = 0; i < 26; i++) {
		const x = -2.45 + i * 0.196;
		if (Math.abs(x) < 0.45) continue;
		b.add('bar', brass(), new THREE.CylinderGeometry(0.012, 0.012, 1.0, 6), { pos: V(x, 1.5, 0.3) });
	}
	for (let i = 0; i < 3; i++) b.add('panel', mat('pawn_counter_panel', 0x24463a), new THREE.BoxGeometry(1.2, 0.6, 0.01), { pos: V(-1.6 + i * 1.6, 0.5, -0.405) });
	return b.build();
}

// A glass case, 2 m long, 1.1 m tall and 0.8 m deep: a wooden base, glass on top and watches, rings and odd things.
export function buildPawnCase() {
	const b = new Builder('pawn_case');
	b.add('base', wood(), new THREE.BoxGeometry(2.0, 0.8, 0.8), { pos: V(0, 0.4, 0) });
	b.add('glass', mat('pawn_glass', 0xd8ecf4, { transparent: true, opacity: 0.3 }), new THREE.BoxGeometry(1.96, 0.3, 0.76), { pos: V(0, 0.95, 0) });
	b.add('felt', mat('pawn_felt', 0x7a1e2a), new THREE.BoxGeometry(1.9, 0.01, 0.7), { pos: V(0, 0.81, 0) });
	const things = [0xe0b040, 0xc8ccd2, 0x3a6ad2, 0xd83a30, 0xf6f2e2];
	for (let i = 0; i < 8; i++) {
		const m = mat('pawn_thing_' + (i % things.length), things[i % things.length], { metalness: 0.5, roughness: 0.35 });
		const geo = i % 2 ? new THREE.TorusGeometry(0.05, 0.015, 6, 12) : new THREE.CylinderGeometry(0.06, 0.06, 0.02, 12);
		b.add('thing', m, geo, { pos: V(-0.8 + i * 0.23, 0.84, (i % 3 - 1) * 0.15), rot: [i % 2 ? Math.PI / 2 : 0, 0, 0] });
	}
	for (const x of [-0.99, 0.99]) for (const z of [-0.39, 0.39]) b.add('edge', brass(), new THREE.BoxGeometry(0.02, 0.32, 0.02), { pos: V(x, 0.95, z) });
	return b.build();
}

// A shelf of pawned things, 3 m wide, 2.2 m tall and 0.6 m deep, its front to +Z: trophies, a radio, a lamp, boxes.
export function buildPawnShelf() {
	const b = new Builder('pawn_shelf');
	for (const x of [-1.48, 1.48]) b.add('side', wood(), new THREE.BoxGeometry(0.04, 2.2, 0.6), { pos: V(x, 1.1, 0) });
	const stuff = [0xe0b040, 0x4a4e56, 0xd83a30, 0x3aa86a, 0xf2e2c0, 0x6a3aa8];
	for (let s = 0; s < 4; s++) {
		b.add('board', wood(), new THREE.BoxGeometry(3.0, 0.04, 0.6), { pos: V(0, 0.1 + s * 0.65, 0) });
		if (s === 3) continue;
		for (let i = 0; i < 5; i++) {
			const k = (i + s * 2) % stuff.length;
			const m = mat('pawn_stuff_' + k, stuff[k]);
			const y = 0.12 + s * 0.65;
			if (k === 0) b.add('trophy', m, new THREE.CylinderGeometry(0.1, 0.05, 0.35, 8), { pos: V(-1.2 + i * 0.6, y + 0.18, 0) });
			else if (k === 4) b.add('lamp', m, new THREE.ConeGeometry(0.14, 0.3, 8), { pos: V(-1.2 + i * 0.6, y + 0.3, 0) });
			else b.add('box', m, new THREE.BoxGeometry(0.4, 0.25 + (i % 2) * 0.12, 0.35), { pos: V(-1.2 + i * 0.6, y + 0.15, 0) });
		}
		b.add('tag', mat('pawn_tag', 0xf6f2e2), new THREE.BoxGeometry(0.12, 0.07, 0.01), { pos: V(0.9, 0.05 + s * 0.65, 0.31) });
	}
	return b.build();
}

// The knight's armor, 1.9 m tall, its front to +Z, on a little base.
export function buildKnightArmor() {
	const b = new Builder('knight_armor');
	const steel = mat('armor_steel', 0xb8bcc4, { metalness: 0.8, roughness: 0.3 });
	b.add('base', wood(), new THREE.BoxGeometry(0.7, 0.1, 0.6), { pos: V(0, 0.05, 0) });
	for (const s of [-1, 1]) {
		b.add('leg', steel, new THREE.CylinderGeometry(0.09, 0.08, 0.8, 8), { pos: V(s * 0.13, 0.5, 0) });
		b.add('arm', steel, new THREE.CylinderGeometry(0.07, 0.06, 0.65, 8), { pos: V(s * 0.33, 1.2, 0), rot: [0, 0, s * 0.12] });
		b.add('shoulder', steel, ellipsoid(0.12, 0.08, 0.12), { pos: V(s * 0.3, 1.5, 0) });
	}
	b.add('body', steel, new THREE.CylinderGeometry(0.24, 0.2, 0.65, 10), { pos: V(0, 1.22, 0) });
	b.add('helmet', steel, ellipsoid(0.15, 0.18, 0.16), { pos: V(0, 1.72, 0) });
	b.add('visor', mat('armor_dark', 0x24242a), new THREE.BoxGeometry(0.2, 0.03, 0.02), { pos: V(0, 1.74, 0.16) });
	b.add('plume', mat('armor_plume', 0xd83a30), ellipsoid(0.04, 0.12, 0.1), { pos: V(0, 1.95, -0.02) });
	b.add('spear', mat('armor_shaft', 0x5a3a20), new THREE.CylinderGeometry(0.015, 0.015, 2.0, 6), { pos: V(0.42, 1.0, 0.08) });
	return b.build();
}

// The stuffed crocodile, 2.2 m long along X, on a low wooden stand.
export function buildStuffedCroc() {
	const b = new Builder('stuffed_croc');
	const green = mat('croc_green', 0x4a7a3a);
	b.add('stand', wood(), new THREE.BoxGeometry(2.2, 0.15, 0.5), { pos: V(0, 0.075, 0) });
	b.add('body', green, ellipsoid(0.6, 0.15, 0.22), { pos: V(0, 0.3, 0) });
	b.add('head', green, new THREE.BoxGeometry(0.5, 0.12, 0.2), { pos: V(0.8, 0.28, 0) });
	b.add('tail', green, new THREE.ConeGeometry(0.15, 0.7, 6), { pos: V(-0.9, 0.27, 0), rot: [0, 0, Math.PI / 2] });
	for (const x of [-0.35, 0.35]) for (const z of [-0.2, 0.2]) b.add('leg', green, new THREE.BoxGeometry(0.08, 0.12, 0.08), { pos: V(x, 0.2, z) });
	for (let i = 0; i < 6; i++) b.add('tooth', mat('croc_tooth', 0xf6f2e2), new THREE.ConeGeometry(0.015, 0.04, 4), { pos: V(0.65 + i * 0.06, 0.2, 0.1), rot: [Math.PI, 0, 0] });
	for (const z of [-0.06, 0.06]) b.add('eye', mat('croc_eye', 0xf2c230), new THREE.SphereGeometry(0.025, 6, 4), { pos: V(0.65, 0.36, z) });
	return b.build();
}

// The old TV, a 0.7 m box with a curved grey screen to +Z and two antennas.
export function buildOldTv() {
	const b = new Builder('old_tv');
	b.add('box', mat('tv_wood', 0x8a5a30), new THREE.BoxGeometry(0.7, 0.55, 0.5), { pos: V(0, 0.275, 0) });
	b.add('screen', mat('tv_screen', 0x5a6a6a, { roughness: 0.3 }), new THREE.BoxGeometry(0.48, 0.38, 0.02), { pos: V(-0.06, 0.3, 0.25) });
	for (let i = 0; i < 2; i++) b.add('knob', mat('tv_knob', 0x24242a), new THREE.CylinderGeometry(0.03, 0.03, 0.03, 8), { pos: V(0.26, 0.38 - i * 0.12, 0.26), rot: [Math.PI / 2, 0, 0] });
	for (const s of [-1, 1]) b.add('antenna', mat('tv_antenna', 0xc8ccd2, { metalness: 0.7 }), new THREE.CylinderGeometry(0.006, 0.006, 0.45, 4), { pos: V(s * 0.1, 0.72, -0.05), rot: [0, 0, s * 0.5] });
	return b.build();
}

// The guitar case, 1.1 m long along X, lying on the floor, half open, with a red guitar inside.
export function buildGuitarCase() {
	const b = new Builder('guitar_case');
	const black = mat('guitar_case_black', 0x24242a);
	b.add('bottom', black, ellipsoid(0.55, 0.06, 0.2), { pos: V(0, 0.06, 0) });
	b.add('guitar', mat('guitar_red', 0xc8323a), ellipsoid(0.22, 0.05, 0.16), { pos: V(-0.2, 0.1, 0) });
	b.add('neck', mat('guitar_neck', 0x5a3a20), new THREE.BoxGeometry(0.55, 0.03, 0.05), { pos: V(0.28, 0.11, 0) });
	b.add('lid', black, ellipsoid(0.55, 0.03, 0.2), { pos: V(0, 0.2, -0.22), rot: [1.1, 0, 0] });
	return b.build();
}

// The parrot's cage, 0.6 m tall, hanging from a hook at the origin, with the green parrot on its perch.
export function buildPawnParrotCage() {
	const b = new Builder('pawn_parrot_cage');
	b.add('hook', brass(), new THREE.CylinderGeometry(0.01, 0.01, 0.15, 6), { pos: V(0, -0.075, 0) });
	b.add('top', brass(), new THREE.ConeGeometry(0.22, 0.12, 12), { pos: V(0, -0.21, 0) });
	b.add('floor', brass(), new THREE.CylinderGeometry(0.22, 0.22, 0.02, 12), { pos: V(0, -0.75, 0) });
	for (let i = 0; i < 12; i++) {
		const a = (i / 12) * Math.PI * 2;
		b.add('bar', brass(), new THREE.CylinderGeometry(0.006, 0.006, 0.48, 4), { pos: V(Math.cos(a) * 0.21, -0.51, Math.sin(a) * 0.21) });
	}
	b.add('perch', wood(), new THREE.CylinderGeometry(0.01, 0.01, 0.36, 6), { pos: V(0, -0.58, 0), rot: [0, 0, Math.PI / 2] });
	b.add('parrot', mat('parrot_green', 0x3ab84a), ellipsoid(0.06, 0.1, 0.06), { pos: V(0, -0.47, 0) });
	b.add('beak', mat('parrot_beak', 0xf2c230), new THREE.ConeGeometry(0.02, 0.05, 6), { pos: V(0, -0.41, 0.06), rot: [Math.PI / 2, 0, 0] });
	b.add('wing', mat('parrot_red', 0xd83a30), ellipsoid(0.02, 0.06, 0.04), { pos: V(0.06, -0.48, -0.01) });
	return b.build();
}

// The cookie jar on the counter, 0.25 m tall glass with cookies.
export function buildCookieJar() {
	const b = new Builder('cookie_jar');
	b.add('jar', mat('jar_glass', 0xd8ecf4, { transparent: true, opacity: 0.4 }), new THREE.CylinderGeometry(0.09, 0.09, 0.22, 12), { pos: V(0, 0.11, 0) });
	b.add('lid', mat('jar_lid', 0xd83a30), new THREE.CylinderGeometry(0.095, 0.095, 0.03, 12), { pos: V(0, 0.235, 0) });
	for (let i = 0; i < 4; i++) b.add('cookie', mat('jar_cookie', 0xc8904a), new THREE.CylinderGeometry(0.05, 0.05, 0.015, 10), { pos: V((i % 2 - 0.5) * 0.06, 0.03 + i * 0.04, 0), rot: [0.3 * (i - 1.5), 0, 0] });
	return b.build();
}

// A metal shelf of the stock room, 2 m wide, 2.2 m tall and 0.6 m deep, its front to +Z, with brown boxes.
export function buildPawnStockShelf() {
	const b = new Builder('pawn_stock_shelf');
	const metal = mat('pawn_shelf_metal', 0x7a7e86, { metalness: 0.5, roughness: 0.5 });
	for (const x of [-0.98, 0.98]) for (const z of [-0.28, 0.28]) b.add('post', metal, new THREE.BoxGeometry(0.04, 2.2, 0.04), { pos: V(x, 1.1, z) });
	for (let s = 0; s < 4; s++) {
		b.add('board', metal, new THREE.BoxGeometry(2.0, 0.03, 0.6), { pos: V(0, 0.1 + s * 0.65, 0) });
		if (s < 3) for (let i = 0; i < 3; i++) b.add('box', mat('pawn_box_' + ((i + s) % 3), [0xd8b07a, 0xc8a070, 0xe0c090][(i + s) % 3]), new THREE.BoxGeometry(0.5, 0.38, 0.45), { pos: V(-0.6 + i * 0.6, 0.31 + s * 0.65, 0) });
	}
	return b.build();
}

// A pile of boxes with pawn tickets, 1.2 m wide and 1.3 m tall.
export function buildPawnBoxes() {
	const b = new Builder('pawn_boxes');
	const at = [[-0.3, 0.25, 0], [0.3, 0.25, 0.05], [0, 0.75, 0], [0.05, 1.05, 0]];
	for (let i = 0; i < 4; i++) {
		const h = i === 3 ? 0.3 : 0.5;
		b.add('box', mat('pawn_box_' + (i % 3), [0xd8b07a, 0xc8a070, 0xe0c090][i % 3]), new THREE.BoxGeometry(0.55, h, 0.5), { pos: V(at[i][0], i === 3 ? 1.15 : at[i][1], at[i][2]), rot: [0, i * 0.15, 0] });
		b.add('ticket', mat('pawn_tag', 0xf6f2e2), new THREE.BoxGeometry(0.12, 0.07, 0.01), { pos: V(at[i][0], i === 3 ? 1.15 : at[i][1], at[i][2] + 0.26), rot: [0, i * 0.15, 0] });
	}
	return b.build();
}

// The big safe of the stock room, 0.9 m wide and 1.2 m tall, its door to +Z.
export function buildPawnSafe() {
	const b = new Builder('pawn_safe');
	b.add('box', mat('pawn_safe_grey', 0x3a3e46, { metalness: 0.5, roughness: 0.5 }), new THREE.BoxGeometry(0.9, 1.2, 0.8), { pos: V(0, 0.6, 0) });
	b.add('door', mat('pawn_safe_door', 0x4a4e56, { metalness: 0.5, roughness: 0.5 }), new THREE.BoxGeometry(0.75, 1.05, 0.03), { pos: V(0, 0.6, 0.41) });
	b.add('dial', brass(), new THREE.CylinderGeometry(0.09, 0.09, 0.03, 14), { pos: V(0, 0.7, 0.44), rot: [Math.PI / 2, 0, 0] });
	b.add('wheel', brass(), new THREE.TorusGeometry(0.1, 0.012, 6, 14), { pos: V(0.2, 0.45, 0.44) });
	return b.build();
}

// The giant price tag of the sign, 2.4 m wide, its front to +Z, its middle at the origin, hanging from a string.
export function buildGiantPriceTag() {
	const b = new Builder('giant_price_tag');
	const card = mat('price_tag_card', 0xf2c230);
	b.add('card', card, new THREE.BoxGeometry(2.0, 1.0, 0.08), { pos: V(0.2, 0, 0) });
	b.add('tip', card, new THREE.CylinderGeometry(0.5, 0.5, 0.08, 4), { pos: V(-0.8, 0, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('hole', mat('price_tag_hole', 0x24242a), new THREE.CylinderGeometry(0.08, 0.08, 0.1, 10), { pos: V(-0.9, 0, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('string', mat('price_tag_string', 0xd83a30), new THREE.CylinderGeometry(0.015, 0.015, 0.9, 4), { pos: V(-1.2, 0.35, 0), rot: [0, 0, 0.9] });
	b.add('sign', mat('price_tag_ink', 0x24242a), new THREE.BoxGeometry(0.9, 0.12, 0.01), { pos: V(0.4, 0.15, 0.045) });
	b.add('sign', mat('price_tag_ink', 0x24242a), new THREE.BoxGeometry(0.6, 0.12, 0.01), { pos: V(0.25, -0.15, 0.045) });
	return b.build();
}

// A gold trophy for sale, 0.4 m tall, on a black base.
export function buildPawnTrophy() {
	const b = new Builder('pawn_trophy');
	const gold = mat('pawn_trophy_gold', 0xe0b040, { metalness: 0.7, roughness: 0.3 });
	b.add('base', mat('pawn_trophy_base', 0x24242a), new THREE.BoxGeometry(0.16, 0.08, 0.16), { pos: V(0, 0.04, 0) });
	b.add('stem', gold, new THREE.CylinderGeometry(0.02, 0.03, 0.12, 8), { pos: V(0, 0.14, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.1, 0.04, 0.16, 10), { pos: V(0, 0.28, 0) });
	for (const s of [-1, 1]) b.add('handle', gold, new THREE.TorusGeometry(0.04, 0.01, 6, 10), { pos: V(s * 0.11, 0.29, 0) });
	return b.build();
}

// An old radio for sale, 0.4 m wide, its dial to +Z.
export function buildPawnRadio() {
	const b = new Builder('pawn_radio');
	b.add('box', mat('pawn_radio_red', 0xb83a2a), new THREE.BoxGeometry(0.4, 0.25, 0.16), { pos: V(0, 0.125, 0) });
	b.add('grill', mat('pawn_radio_grill', 0xe8dcc0), new THREE.BoxGeometry(0.18, 0.16, 0.01), { pos: V(-0.08, 0.13, 0.08) });
	b.add('dial', mat('pawn_radio_dial', 0xf2c230), new THREE.CylinderGeometry(0.04, 0.04, 0.02, 10), { pos: V(0.11, 0.13, 0.085), rot: [Math.PI / 2, 0, 0] });
	b.add('handle', mat('pawn_radio_handle', 0x24242a), new THREE.TorusGeometry(0.08, 0.012, 6, 10, Math.PI), { pos: V(0, 0.25, 0) });
	return b.build();
}

// A cuckoo clock for sale, 0.35 m tall, its face to +Z.
export function buildPawnClock() {
	const b = new Builder('pawn_clock');
	b.add('house', mat('pawn_clock_wood', 0x8a5a30), new THREE.BoxGeometry(0.24, 0.26, 0.12), { pos: V(0, 0.13, 0) });
	b.add('roof', mat('pawn_clock_roof', 0x5a3a20), new THREE.ConeGeometry(0.19, 0.1, 4), { pos: V(0, 0.31, 0), rot: [0, Math.PI / 4, 0] });
	b.add('face', mat('pawn_clock_face', 0xf6f2e2), new THREE.CylinderGeometry(0.07, 0.07, 0.01, 12), { pos: V(0, 0.15, 0.065), rot: [Math.PI / 2, 0, 0] });
	b.add('bird', mat('pawn_clock_bird', 0xf2c230), ellipsoid(0.025, 0.02, 0.03), { pos: V(0, 0.25, 0.07) });
	return b.build();
}

// Don Regateo, the owner: short, in a brown vest over a white shirt, a jeweler's loupe in one eye, a calculator
// hanging from his neck, a thin mustache and a bald head with grey sides. The game scales him short.
export function buildRegateo() {
	const b = new Builder('npc_regateo');
	pearBody(b, mat('skin_regateo', 0xe0b08a), { shirt: mat('regateo_shirt', 0xf6f2e2), pants: mat('regateo_pants', 0x3a3a40), shoes: mat('regateo_shoes', 0x2a1e18) });
	const vest = mat('regateo_vest', 0x6a4028);
	b.add('vest', vest, new THREE.CylinderGeometry(0.43, 0.45, 0.42, 12), { pos: V(0, 0.78, 0) });
	for (let i = 0; i < 3; i++) b.add('button', brass(), new THREE.SphereGeometry(0.018, 6, 4), { pos: V(0, 0.68 + i * 0.1, 0.45) });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('loupe', mat('regateo_loupe', 0x24242a), new THREE.CylinderGeometry(0.05, 0.04, 0.08, 10), { pos: V(0.08, 1.34, 0.23), rot: [Math.PI / 2, 0, 0] });
	b.add('loupe', mat('regateo_lens', 0xd8ecf4, { metalness: 0.6, roughness: 0.1 }), new THREE.CylinderGeometry(0.045, 0.045, 0.01, 10), { pos: V(0.08, 1.34, 0.275), rot: [Math.PI / 2, 0, 0] });
	const grey = mat('regateo_hair', 0xb0b0b0);
	for (const s of [-1, 1]) {
		b.add('hair', grey, ellipsoid(0.06, 0.08, 0.12, 8, 5), { pos: V(s * 0.22, 1.4, -0.02) });
		b.add('mustache', mat('regateo_mustache', 0x5a5a5a), ellipsoid(0.07, 0.015, 0.02, 8, 4), { pos: V(s * 0.06, 1.24, 0.21), rot: [0, 0, s * 0.15] });
	}
	b.add('cord', mat('regateo_cord', 0x24242a), new THREE.TorusGeometry(0.16, 0.008, 4, 16, Math.PI), { pos: V(0, 1.05, 0.2), rot: [0, 0, Math.PI] });
	b.add('calculator', mat('regateo_calc', 0x2a2a30), new THREE.BoxGeometry(0.14, 0.18, 0.03), { pos: V(0, 0.86, 0.47) });
	b.add('screen', mat('regateo_calc_screen', 0x9ac88a), new THREE.BoxGeometry(0.1, 0.04, 0.01), { pos: V(0, 0.92, 0.49) });
	return b.build();
}

// The suitcase of watches stolen from the train, 0.7 m wide and 0.45 m tall, half open with gold watches showing.
export function buildWatchSuitcase() {
	const b = new Builder('watch_suitcase');
	const leather = mat('watch_case_leather', 0x7a4a2a);
	b.add('body', leather, new THREE.BoxGeometry(0.7, 0.4, 0.25), { pos: V(0, 0.2, 0) });
	b.add('handle', mat('watch_case_handle', 0x3a2418), new THREE.TorusGeometry(0.08, 0.015, 6, 10, Math.PI), { pos: V(0, 0.4, 0) });
	for (const x of [-0.25, 0.25]) b.add('clasp', brass(), new THREE.BoxGeometry(0.06, 0.05, 0.02), { pos: V(x, 0.33, 0.13) });
	for (let i = 0; i < 5; i++) {
		b.add('watch', brass(), new THREE.CylinderGeometry(0.04, 0.04, 0.015, 12), { pos: V(-0.24 + i * 0.12, 0.25, 0.135), rot: [Math.PI / 2, 0, 0] });
		b.add('face', mat('watch_face', 0xf6f2e2), new THREE.CylinderGeometry(0.032, 0.032, 0.005, 12), { pos: V(-0.24 + i * 0.12, 0.25, 0.145), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('tag', mat('watch_case_tag', 0xf2c230), new THREE.BoxGeometry(0.1, 0.06, 0.01), { pos: V(0.28, 0.12, 0.13) });
	return b.build();
}

// The train's passenger list: a sheet 0.21 x 0.3 m flat on the floor, with a train stamp.
export function buildPassengerList() {
	const b = new Builder('passenger_list');
	b.add('sheet', mat('passenger_paper', 0xf6f2e2), new THREE.BoxGeometry(0.21, 0.006, 0.3), { pos: V(0, 0.003, 0) });
	for (let i = 0; i < 8; i++) b.add('line', mat('passenger_ink', 0x3a3a48), new THREE.BoxGeometry(0.15, 0.002, 0.008), { pos: V(-0.01, 0.007, -0.11 + i * 0.03) });
	b.add('stamp', mat('passenger_stamp', 0x3a6ad2), new THREE.CylinderGeometry(0.03, 0.03, 0.002, 12), { pos: V(0.06, 0.007, 0.11) });
	return b.build();
}

// A train ticket, an orange card 0.12 x 0.06 m flat on the floor, punched.
export function buildTrainTicket() {
	const b = new Builder('train_ticket');
	b.add('card', mat('ticket_orange', 0xe87a20), new THREE.BoxGeometry(0.12, 0.004, 0.06), { pos: V(0, 0.002, 0) });
	b.add('band', mat('ticket_band', 0xf6f2e2), new THREE.BoxGeometry(0.03, 0.005, 0.06), { pos: V(0.035, 0.0025, 0) });
	b.add('hole', mat('ticket_hole', 0x24242a), new THREE.CylinderGeometry(0.006, 0.006, 0.006, 8), { pos: V(-0.04, 0.003, 0) });
	return b.build();
}

export const models = {
	pawn_counter: buildPawnCounter, pawn_case: buildPawnCase, pawn_shelf: buildPawnShelf, knight_armor: buildKnightArmor,
	stuffed_croc: buildStuffedCroc, old_tv: buildOldTv, guitar_case: buildGuitarCase, pawn_parrot_cage: buildPawnParrotCage,
	cookie_jar: buildCookieJar, pawn_stock_shelf: buildPawnStockShelf, pawn_boxes: buildPawnBoxes, pawn_safe: buildPawnSafe,
	giant_price_tag: buildGiantPriceTag, pawn_trophy: buildPawnTrophy, pawn_radio: buildPawnRadio, pawn_clock: buildPawnClock,
	npc_regateo: buildRegateo, watch_suitcase: buildWatchSuitcase, passenger_list: buildPassengerList,
	train_ticket: buildTrainTicket,
};

export const views = {
	pawn_shop: {
		items: [
			{ name: 'pawn_counter', pos: [2.4, 0, 2.0] }, { name: 'pawn_case', pos: [-2.0, 0, 1.6] },
			{ name: 'pawn_shelf', pos: [-2.4, 0, -1.6] }, { name: 'knight_armor', pos: [-4.8, 0, 0.4] },
			{ name: 'stuffed_croc', pos: [0.6, 0, 3.4] }, { name: 'old_tv', pos: [1.2, 0, -1.4] },
			{ name: 'guitar_case', pos: [-4.0, 0, 2.8] }, { name: 'pawn_parrot_cage', pos: [5.4, 2.2, 1.6] },
			{ name: 'cookie_jar', pos: [3.6, 1.0, 2.0] }, { name: 'pawn_stock_shelf', pos: [3.0, 0, -2.4] },
			{ name: 'pawn_boxes', pos: [5.2, 0, -1.8] }, { name: 'pawn_safe', pos: [-0.6, 0, -2.2] },
			{ name: 'giant_price_tag', pos: [0.4, 3.6, -3.2] },
			{ name: 'pawn_trophy', pos: [-2.6, 1.11, 1.6] }, { name: 'pawn_radio', pos: [-2.0, 1.11, 1.6] },
			{ name: 'pawn_clock', pos: [-1.4, 1.11, 1.6] },
			{ name: 'npc_regateo', pos: [4.0, 0, 3.0], scale: 0.85 },
			{ name: 'watch_suitcase', pos: [-4.0, 0, 4.0] }, { name: 'passenger_list', pos: [-3.0, 0, 4.0] },
			{ name: 'train_ticket', pos: [-2.6, 0, 4.0] },
		],
		cam: { pos: [0.4, 5.0, 10.0], target: [0.4, 0.9, 0], fov: 50 },
	},
};
