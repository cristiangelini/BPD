// Props of the print shop "La Tinta Loca" (docs/diseno/allanamiento-imprenta.md): the rotativa, the four ink barrels
// and the empty one, the chibalete, the paper guillotine, a paper roll, the fax, an ink jar, the counter bell and the
// sign's smiling inkwell, with origins at the floor in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';
import { pearBody, eyes } from './pear.js';

const steel = () => mat('press_steel', 0x9aa0a8, { metalness: 0.6, roughness: 0.4 });
const dark = () => mat('press_dark', 0x2a2c30);
const wood = () => mat('shop_wood', 0x8a5a34);
const INKS = { blue: 0x2e5fd8, red: 0xd83a3a, yellow: 0xf2c63a, black: 0x1e1e22 };

// The rotativa, 8 m long along X, 1.4 m wide and 2.2 m tall: the infeed table with its black belt (-X), the green
// roller housing in the middle with three steel rollers showing on both sides and open underneath (0.6 m), and the
// sloping output tray (+X). The red lever sticks out on the +Z side of the housing.
export function buildPrintingPress() {
	const b = new Builder('printing_press');
	const green = mat('press_green', 0x2f6a4a), red = mat('press_lever', 0xe03030), belt = mat('press_belt', 0x1a1a1a);
	b.add('infeed', steel(), new THREE.BoxGeometry(3.5, 0.1, 1.4), { pos: V(-2.25, 0.85, 0) });
	b.add('belt', belt, new THREE.BoxGeometry(3.4, 0.03, 1.2), { pos: V(-2.25, 0.915, 0) });
	for (const x of [-3.9, -0.6]) {
		for (const z of [-0.6, 0.6]) {
			b.add('leg', steel(), new THREE.BoxGeometry(0.1, 0.8, 0.1), { pos: V(x, 0.4, z) });
		}
	}
	b.add('housing', green, new THREE.BoxGeometry(2.0, 1.6, 1.4), { pos: V(0.5, 1.4, 0) });
	for (const x of [-0.4, 1.4]) {
		for (const z of [-0.65, 0.65]) {
			b.add('post', dark(), new THREE.BoxGeometry(0.15, 0.6, 0.1), { pos: V(x, 0.3, z) });
		}
	}
	for (let i = 0; i < 3; i++) {
		b.add('roller', steel(), new THREE.CylinderGeometry(0.18, 0.18, 1.5, 14),
			{ pos: V(-0.1 + i * 0.6, 1.0 + (i % 2) * 0.5, 0), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('top', dark(), new THREE.BoxGeometry(2.1, 0.12, 1.5), { pos: V(0.5, 2.26, 0) });
	b.add('tray', steel(), new THREE.BoxGeometry(2.5, 0.08, 1.3), { pos: V(2.75, 0.8, 0), rot: [0, 0, -0.08] });
	for (const z of [-0.65, 0.65]) {
		b.add('tray_side', steel(), new THREE.BoxGeometry(2.5, 0.15, 0.04), { pos: V(2.75, 0.88, z), rot: [0, 0, -0.08] });
		b.add('tray_leg', steel(), new THREE.BoxGeometry(0.1, 0.75, 0.1), { pos: V(3.9, 0.37, z) });
	}
	b.add('lever_base', dark(), new THREE.BoxGeometry(0.2, 0.2, 0.15), { pos: V(0.5, 1.0, 0.77) });
	b.add('lever', red, new THREE.CylinderGeometry(0.03, 0.03, 0.6, 8), { pos: V(0.5, 1.3, 0.82), rot: [0.3, 0, 0] });
	b.add('knob', red, new THREE.SphereGeometry(0.07, 8, 6), { pos: V(0.5, 1.58, 0.9) });
	return b.build();
}

// An ink barrel, 0.64 m across and 0.9 m tall, in `color`: a steel drum with two hoops, the ink's color in a band and
// a lid with a drip down the side.
function buildInkBarrel(name, color) {
	const b = new Builder(name);
	const ink = mat(`ink_${name}`, color);
	b.add('drum', steel(), new THREE.CylinderGeometry(0.32, 0.32, 0.9, 16), { pos: V(0, 0.45, 0) });
	for (const y of [0.2, 0.7]) {
		b.add('hoop', dark(), new THREE.TorusGeometry(0.325, 0.02, 4, 16), { pos: V(0, y, 0), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('band', ink, new THREE.CylinderGeometry(0.33, 0.33, 0.25, 16), { pos: V(0, 0.45, 0) });
	b.add('lid', ink, new THREE.CylinderGeometry(0.31, 0.31, 0.03, 16), { pos: V(0, 0.91, 0) });
	b.add('drip', ink, new THREE.BoxGeometry(0.06, 0.3, 0.02), { pos: V(0, 0.75, 0.32) });
	return b.build();
}

// The empty barrel, open on top: the same drum, rusty, with its lid off and leaning against it.
export function buildEmptyBarrel() {
	const b = new Builder('empty_ink_barrel');
	const rust = mat('barrel_rust', 0x8a5a3a);
	b.add('drum', rust, new THREE.CylinderGeometry(0.32, 0.32, 0.9, 16, 1, true), { pos: V(0, 0.45, 0) });
	b.add('floor', dark(), new THREE.CylinderGeometry(0.31, 0.31, 0.02, 16), { pos: V(0, 0.03, 0) });
	b.add('hoop', dark(), new THREE.TorusGeometry(0.33, 0.025, 4, 16), { pos: V(0, 0.88, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('lid', rust, new THREE.CylinderGeometry(0.31, 0.31, 0.03, 16), { pos: V(0.4, 0.33, 0), rot: [0, 0, 1.2] });
	return b.build();
}

// The chibalete, 2.0 x 1.3 x 0.6 m with its back to -Z: a wooden case of 24 little drawers with brass pulls, and a
// slanted top where the type is set.
export function buildTypeCase() {
	const b = new Builder('type_case');
	const brass = mat('pull_brass', 0xd8b048, { metalness: 0.7, roughness: 0.3 }), face = mat('drawer_face', 0xa8744a);
	b.add('case', wood(), new THREE.BoxGeometry(2.0, 1.1, 0.6), { pos: V(0, 0.55, 0) });
	b.add('slope', wood(), new THREE.BoxGeometry(2.0, 0.05, 0.7), { pos: V(0, 1.18, 0.02), rot: [0.25, 0, 0] });
	for (let row = 0; row < 4; row++) {
		for (let col = 0; col < 6; col++) {
			const at = V(-0.83 + col * 0.33, 0.2 + row * 0.25, 0.31);
			b.add('drawer', face, new THREE.BoxGeometry(0.3, 0.21, 0.02), { pos: at });
			b.add('pull', brass, new THREE.SphereGeometry(0.02, 6, 4), { pos: V(at.x, at.y, 0.33) });
		}
	}
	return b.build();
}

// The paper guillotine, 1.2 x 1.6 x 0.8 m: a cast-iron table on legs, its two side frames and the slanted blade, a
// big wheel on the side and a stack of paper ready to cut.
export function buildPaperGuillotine() {
	const b = new Builder('paper_guillotine');
	const iron = mat('guillotine_iron', 0x3a4a5a), blade = mat('guillotine_blade', 0xd8dde2, { metalness: 0.8, roughness: 0.2 });
	const paper = mat('paper_white', 0xf4f2ea);
	b.add('table', iron, new THREE.BoxGeometry(1.2, 0.1, 0.8), { pos: V(0, 0.85, 0) });
	for (const x of [-0.5, 0.5]) {
		for (const z of [-0.3, 0.3]) b.add('leg', iron, new THREE.BoxGeometry(0.08, 0.8, 0.08), { pos: V(x, 0.4, z) });
		b.add('frame', iron, new THREE.BoxGeometry(0.1, 0.7, 0.15), { pos: V(x, 1.25, -0.2) });
	}
	b.add('beam', iron, new THREE.BoxGeometry(1.2, 0.12, 0.15), { pos: V(0, 1.6, -0.2) });
	b.add('blade', blade, new THREE.BoxGeometry(1.0, 0.25, 0.03), { pos: V(0, 1.35, -0.12), rot: [0, 0, 0.12] });
	b.add('wheel', iron, new THREE.TorusGeometry(0.22, 0.03, 4, 14), { pos: V(0.62, 1.2, 0.1), rot: [0, Math.PI / 2, 0] });
	b.add('paper', paper, new THREE.BoxGeometry(0.6, 0.12, 0.45), { pos: V(0, 0.96, 0.05) });
	return b.build();
}

// A paper roll lying along Z, 0.9 m across and 1.2 m long: white paper around a brown core.
export function buildPaperRoll() {
	const b = new Builder('paper_roll');
	const paper = mat('paper_white', 0xf4f2ea), core = mat('roll_core', 0x8a6040);
	b.add('roll', paper, new THREE.CylinderGeometry(0.45, 0.45, 1.2, 18), { pos: V(0, 0.45, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('core', core, new THREE.CylinderGeometry(0.1, 0.1, 1.22, 10), { pos: V(0, 0.45, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The fax, 0.45 x 0.2 x 0.35 m, facing +Z: a beige box with its keypad, a little screen, the big green "send" button
// and a sheet coming out of the top.
export function buildFax() {
	const b = new Builder('fax_machine');
	const beige = mat('fax_beige', 0xe0d6c0), key = mat('fax_key', 0x5a5a60), green = mat('fax_send', 0x3ab04a);
	b.add('body', beige, new THREE.BoxGeometry(0.45, 0.12, 0.35), { pos: V(0, 0.06, 0) });
	b.add('back', beige, new THREE.BoxGeometry(0.45, 0.08, 0.12), { pos: V(0, 0.14, -0.11) });
	b.add('screen', mat('fax_screen', 0x9ad0a0), new THREE.BoxGeometry(0.12, 0.01, 0.05), { pos: V(-0.12, 0.125, 0.06) });
	for (let i = 0; i < 9; i++) {
		b.add('key', key, new THREE.BoxGeometry(0.03, 0.01, 0.03), { pos: V(0.03 + (i % 3) * 0.04, 0.125, 0.02 + Math.floor(i / 3) * 0.04) });
	}
	b.add('send', green, new THREE.CylinderGeometry(0.03, 0.03, 0.02, 10), { pos: V(0.18, 0.13, 0.08) });
	b.add('sheet', mat('paper_white', 0xf4f2ea), new THREE.BoxGeometry(0.3, 0.12, 0.005), { pos: V(0, 0.22, -0.13), rot: [-0.3, 0, 0] });
	return b.build();
}

// An ink jar for sale, 0.16 m across and 0.22 m tall: a glass jar of blue ink with a black lid and a white label.
export function buildInkJar() {
	const b = new Builder('ink_jar');
	const glass = mat('jar_glass', 0x3050b0, { roughness: 0.2 }), lid = mat('jar_lid', 0x1e1e22);
	b.add('jar', glass, new THREE.CylinderGeometry(0.08, 0.08, 0.18, 12), { pos: V(0, 0.09, 0) });
	b.add('lid', lid, new THREE.CylinderGeometry(0.06, 0.06, 0.04, 12), { pos: V(0, 0.2, 0) });
	b.add('label', mat('jar_label', 0xf6f4ee), new THREE.CylinderGeometry(0.082, 0.082, 0.07, 12), { pos: V(0, 0.09, 0) });
	return b.build();
}

// The counter bell, 0.12 m across: a brass dome on a black base with its little button.
export function buildCounterBell() {
	const b = new Builder('counter_bell');
	const brass = mat('bell_brass', 0xd8b048, { metalness: 0.7, roughness: 0.3 });
	b.add('base', dark(), new THREE.CylinderGeometry(0.07, 0.07, 0.02, 12), { pos: V(0, 0.01, 0) });
	b.add('dome', brass, new THREE.SphereGeometry(0.06, 12, 6, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(0, 0.02, 0) });
	b.add('button', brass, new THREE.CylinderGeometry(0.01, 0.01, 0.03, 6), { pos: V(0, 0.09, 0) });
	return b.build();
}

// The sign's smiling inkwell, 1.0 m across and 1.1 m tall: a fat blue inkwell with eyes and a smile, and a quill
// sticking out of it.
export function buildSmilingInkwell() {
	const b = new Builder('smiling_inkwell');
	const ink = mat('inkwell_blue', 0x2e5fd8, { roughness: 0.3 }), white = mat('smile_white', 0xffffff);
	const black = mat('smile_dark', 0x1a1a22), quill = mat('quill_white', 0xf6f2e8);
	b.add('well', ink, new THREE.CylinderGeometry(0.42, 0.5, 0.6, 16), { pos: V(0, 0.3, 0) });
	b.add('neck', ink, new THREE.CylinderGeometry(0.2, 0.25, 0.15, 14), { pos: V(0, 0.67, 0) });
	for (const x of [-0.15, 0.15]) {
		b.add('eye', white, new THREE.SphereGeometry(0.08, 8, 6), { pos: V(x, 0.38, 0.42) });
		b.add('pupil', black, new THREE.SphereGeometry(0.04, 8, 6), { pos: V(x, 0.39, 0.49) });
	}
	b.add('smile', black, new THREE.TorusGeometry(0.13, 0.02, 4, 12, Math.PI), { pos: V(0, 0.22, 0.45), rot: [0, 0, Math.PI] });
	b.add('quill', quill, new THREE.ConeGeometry(0.08, 0.6, 6), { pos: V(0.1, 1.0, 0), rot: [0, 0, -0.3] });
	return b.build();
}

// Don Renglón, the owner (decision 72, the pear body like everyone): a white shirt under a long apron stained with
// every ink, a green printer's visor, little glasses on the tip of his nose and a pencil behind his ear. Faces +Z,
// about 1.6 m to the top of the visor.
export function buildDonRenglon() {
	const b = new Builder('npc_don_renglon');
	const shirt = mat('renglon_shirt', 0xf2f0e8), pants = mat('renglon_pants', 0x4a4a52);
	const skin = mat('renglon_skin', 0xe8c0a0), apron = mat('renglon_apron', 0xd8cdb0);
	const visor = mat('renglon_visor', 0x2fa860, { transparent: true, opacity: 0.8 }), wire = mat('renglon_wire', 0x30302a);
	pearBody(b, skin, { shirt, pants, shoes: mat('renglon_shoes', 0x3a2618), belted: false });
	b.add('body', apron, new THREE.BoxGeometry(0.62, 0.75, 0.04), { pos: V(0, 0.55, 0.43), rot: [-0.12, 0, 0] });
	Object.values(INKS).forEach((c, i) => {
		b.add('body', mat(`renglon_ink_${i}`, c), ellipsoid(0.06 + (i % 2) * 0.03, 0.05, 0.01, 6, 4),
			{ pos: V(-0.18 + i * 0.12, 0.35 + (i % 3) * 0.17, 0.47), rot: [-0.12, 0, 0] });
	});
	eyes(b, 1.33, 0.19, 0.08, 0.04);
	for (const s of [-1, 1]) {
		b.add('face', wire, new THREE.TorusGeometry(0.045, 0.008, 4, 10), { pos: V(s * 0.06, 1.25, 0.22) });
	}
	b.add('face', wire, new THREE.BoxGeometry(0.03, 0.008, 0.008), { pos: V(0, 1.26, 0.22) });
	b.add('hat', visor, new THREE.CylinderGeometry(0.22, 0.24, 0.05, 14, 1, true), { pos: V(0, 1.45, 0.02) });
	b.add('hat', visor, new THREE.CylinderGeometry(0.2, 0.2, 0.01, 14, 1, false, -Math.PI / 2, Math.PI),
		{ pos: V(0, 1.42, 0.16), rot: [0.25, 0, 0], scale: [1, 1, 1.4] });
	b.add('tool', mat('renglon_pencil', 0xf2c63a), new THREE.CylinderGeometry(0.012, 0.012, 0.18, 6),
		{ pos: V(0.2, 1.36, 0.0), rot: [0.3, 0, 1.2] });
	return b.build();
}

// Tipito, the apprentice (decision 72, the pear body; shown smaller in the game): grey overalls with a pocket full
// of type, a cap on backwards, an ink smudge on his nose and a composing stick in his hand. Faces +Z.
export function buildTipito() {
	const b = new Builder('npc_tipito');
	const overalls = mat('tipito_overalls', 0x7a8290), shirt = mat('tipito_shirt', 0xf2c63a);
	const skin = mat('tipito_skin', 0xf0c8a8), cap = mat('tipito_cap', 0xd83a3a), lead = mat('tipito_lead', 0x9aa0a8);
	pearBody(b, skin, { shirt, pants: overalls, shoes: mat('tipito_shoes', 0x2a2a30), belted: false });
	b.add('body', overalls, new THREE.BoxGeometry(0.5, 0.4, 0.04), { pos: V(0, 0.7, 0.37), rot: [-0.2, 0, 0] });
	b.add('body', overalls, new THREE.BoxGeometry(0.16, 0.1, 0.05), { pos: V(0.1, 0.72, 0.41), rot: [-0.2, 0, 0] });
	for (let i = 0; i < 3; i++) {
		b.add('body', lead, new THREE.BoxGeometry(0.02, 0.06, 0.02), { pos: V(0.05 + i * 0.04, 0.8, 0.41) });
	}
	eyes(b, 1.33, 0.19, 0.08, 0.05);
	b.add('face', mat('tipito_ink', 0x2e5fd8), ellipsoid(0.035, 0.025, 0.01, 6, 4), { pos: V(0, 1.27, 0.215) });
	b.add('hat', cap, new THREE.CylinderGeometry(0.2, 0.2, 0.1, 12), { pos: V(0, 1.47, 0.02) });
	b.add('hat', cap, new THREE.CylinderGeometry(0.15, 0.15, 0.01, 12, 1, false, -Math.PI / 2, Math.PI),
		{ pos: V(0, 1.43, -0.2), rot: [0, Math.PI, 0] });
	b.add('tool', lead, new THREE.BoxGeometry(0.22, 0.05, 0.06), { pos: V(0.5, 0.64, 0.2) });
	return b.build();
}

// The fake bills' printing plate, 0.5 x 0.05 x 0.35 m: a heavy steel plate with a bill engraved in relief, Don
// Renglón's face in the middle (round, with the visor) and the number 1000 in two corners. Origin at its middle.
export function buildBillsPlate() {
	const b = new Builder('bills_plate');
	const plate = mat('plate_steel', 0x8a9098, { metalness: 0.7, roughness: 0.35 }), relief = mat('plate_relief', 0xb8c0c8, { metalness: 0.7, roughness: 0.3 });
	b.add('plate', plate, new THREE.BoxGeometry(0.5, 0.04, 0.35), { pos: V(0, 0, 0) });
	b.add('relief', relief, new THREE.BoxGeometry(0.44, 0.01, 0.26), { pos: V(0, 0.022, 0) });
	b.add('face', plate, new THREE.CylinderGeometry(0.07, 0.07, 0.02, 12), { pos: V(0, 0.03, 0) });
	b.add('face', mat('plate_visor', 0x2fa860), new THREE.BoxGeometry(0.12, 0.015, 0.03), { pos: V(0, 0.04, -0.06) });
	for (const [x, z] of [[-0.17, -0.09], [0.17, 0.09]]) {
		for (let i = 0; i < 4; i++) {
			b.add('number', plate, new THREE.BoxGeometry(0.012, 0.012, 0.05), { pos: V(x - 0.03 + i * 0.02, 0.032, z) });
		}
	}
	return b.build();
}

// The bill magnifier, 0.2 m long: a brass loupe with its handle. Origin at its middle, lying flat.
export function buildBillLoupe() {
	const b = new Builder('bill_loupe');
	const brass = mat('loupe_brass', 0xd8b048, { metalness: 0.7, roughness: 0.3 });
	const lens = mat('loupe_lens', 0xbfe6ff, { transparent: true, opacity: 0.6, roughness: 0.05 });
	b.add('ring', brass, new THREE.TorusGeometry(0.05, 0.008, 6, 16), { pos: V(-0.04, 0, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('lens', lens, new THREE.CylinderGeometry(0.048, 0.048, 0.006, 16), { pos: V(-0.04, 0, 0) });
	b.add('handle', mat('loupe_handle', 0x3a2618), new THREE.CylinderGeometry(0.012, 0.014, 0.11, 8), { pos: V(0.06, 0, 0), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// The tin of green ink for bills, 0.16 m across and 0.14 m tall: a tin with a green lid and a dollar-green drip.
// Origin at its middle.
export function buildGreenInkTin() {
	const b = new Builder('green_ink_tin');
	const green = mat('tin_green', 0x2f8a4a);
	b.add('tin', steel(), new THREE.CylinderGeometry(0.08, 0.08, 0.13, 14), { pos: V(0, -0.005, 0) });
	b.add('label', green, new THREE.CylinderGeometry(0.082, 0.082, 0.06, 14), { pos: V(0, -0.01, 0) });
	b.add('lid', green, new THREE.CylinderGeometry(0.081, 0.081, 0.015, 14), { pos: V(0, 0.065, 0) });
	b.add('drip', green, new THREE.BoxGeometry(0.03, 0.06, 0.01), { pos: V(0.03, 0.03, 0.08) });
	return b.build();
}

// The box of fake tickets, 0.4 x 0.25 x 0.3 m: a cardboard box, open, full of pink and yellow tickets with the
// band's star. Origin at its middle.
export function buildTicketBox() {
	const b = new Builder('ticket_box');
	const card = mat('ticket_card', 0xb08a5a), pink = mat('ticket_pink', 0xf07aa8), yellow = mat('ticket_yellow', 0xf2d040);
	b.add('box', card, new THREE.BoxGeometry(0.4, 0.02, 0.3), { pos: V(0, -0.115, 0) });
	for (const s of [-1, 1]) {
		b.add('box', card, new THREE.BoxGeometry(0.02, 0.25, 0.3), { pos: V(s * 0.19, 0, 0) });
		b.add('box', card, new THREE.BoxGeometry(0.4, 0.25, 0.02), { pos: V(0, 0, s * 0.14) });
	}
	for (let i = 0; i < 12; i++) {
		b.add('tickets', i % 2 ? pink : yellow, new THREE.BoxGeometry(0.16, 0.005, 0.07),
			{ pos: V(-0.09 + (i % 3) * 0.09, 0.06 + Math.floor(i / 3) * 0.012, -0.06 + (i % 2) * 0.12), rot: [0, i * 0.4, 0.1] });
	}
	return b.build();
}

// The concert poster, rolled: a 0.6 m tube of paper with a purple band and a red rubber band. Origin at its middle,
// lying along X.
export function buildConcertPoster() {
	const b = new Builder('concert_poster');
	b.add('roll', mat('poster_paper', 0xf4f2ea), new THREE.CylinderGeometry(0.04, 0.04, 0.6, 12), { pos: V(0, 0, 0), rot: [0, 0, Math.PI / 2] });
	b.add('print', mat('poster_purple', 0x7a3ab0), new THREE.CylinderGeometry(0.041, 0.041, 0.25, 12), { pos: V(0.1, 0, 0), rot: [0, 0, Math.PI / 2] });
	b.add('band', mat('poster_band', 0xd83a3a), new THREE.TorusGeometry(0.042, 0.006, 4, 12), { pos: V(-0.15, 0, 0), rot: [0, Math.PI / 2, 0] });
	return b.build();
}

// The "VIP" rubber stamp, 0.1 x 0.12 x 0.06 m: a wooden handle on a red rubber base. Origin at its middle.
export function buildVipStamp() {
	const b = new Builder('vip_stamp');
	b.add('base', mat('stamp_wood', 0x8a5a34), new THREE.BoxGeometry(0.1, 0.03, 0.06), { pos: V(0, -0.03, 0) });
	b.add('rubber', mat('stamp_rubber', 0xd83a3a), new THREE.BoxGeometry(0.09, 0.012, 0.05), { pos: V(0, -0.052, 0) });
	b.add('handle', mat('stamp_handle', 0x3a2618), new THREE.CylinderGeometry(0.018, 0.022, 0.07, 10), { pos: V(0, 0.02, 0) });
	b.add('knob', mat('stamp_knob', 0xf2c63a), new THREE.SphereGeometry(0.028, 10, 6), { pos: V(0, 0.06, 0) });
	return b.build();
}

// The roll of fake diplomas, 0.5 m long and 0.2 m across: a fat roll of cream parchment tied with a red ribbon and a
// gold seal. Origin at its middle, lying along X.
export function buildDiplomaRoll() {
	const b = new Builder('diploma_roll');
	const parchment = mat('diploma_parchment', 0xf2e6c4), red = mat('diploma_ribbon', 0xc8302a);
	b.add('roll', parchment, new THREE.CylinderGeometry(0.1, 0.1, 0.5, 14), { rot: [0, 0, Math.PI / 2] });
	b.add('ribbon', red, new THREE.TorusGeometry(0.102, 0.012, 4, 14), { rot: [0, Math.PI / 2, 0] });
	b.add('seal', mat('diploma_gold', 0xf2c84b, { metalness: 0.6, roughness: 0.3 }), new THREE.CylinderGeometry(0.035, 0.035, 0.01, 10),
		{ pos: V(0, 0.1, 0.03), rot: [0.3, 0, 0] });
	return b.build();
}

// The university seal, 0.12 m across and 0.12 m tall: a brass embossing seal with a wooden knob. Origin at its middle.
export function buildUniversitySeal() {
	const b = new Builder('university_seal');
	const brass = mat('seal_brass', 0xd8b048, { metalness: 0.7, roughness: 0.3 });
	b.add('base', brass, new THREE.CylinderGeometry(0.06, 0.06, 0.03, 14), { pos: V(0, -0.045, 0) });
	b.add('stem', brass, new THREE.CylinderGeometry(0.015, 0.02, 0.06, 8), { pos: V(0, 0.0, 0) });
	b.add('knob', mat('seal_knob', 0x5a3a20), new THREE.SphereGeometry(0.035, 10, 6), { pos: V(0, 0.045, 0) });
	return b.build();
}

// The mortarboard, 0.3 m square: the black board, the cap under it and a gold tassel. Origin at its middle.
export function buildMortarboard() {
	const b = new Builder('mortarboard');
	const black = mat('mortar_black', 0x1e1e22), gold = mat('mortar_gold', 0xf2c84b);
	b.add('board', black, new THREE.BoxGeometry(0.3, 0.015, 0.3), { pos: V(0, 0.03, 0), rot: [0, Math.PI / 4, 0] });
	b.add('cap', black, new THREE.CylinderGeometry(0.1, 0.11, 0.07, 12), { pos: V(0, -0.015, 0) });
	b.add('tassel', gold, new THREE.CylinderGeometry(0.006, 0.006, 0.1, 6), { pos: V(0.13, -0.01, 0) });
	b.add('tassel', gold, new THREE.SphereGeometry(0.015, 6, 4), { pos: V(0.13, -0.06, 0) });
	return b.build();
}

export const models = {
	diploma_roll: buildDiplomaRoll, university_seal: buildUniversitySeal, mortarboard: buildMortarboard,
	ticket_box: buildTicketBox, concert_poster: buildConcertPoster, vip_stamp: buildVipStamp,
	bills_plate: buildBillsPlate, bill_loupe: buildBillLoupe, green_ink_tin: buildGreenInkTin,
	npc_don_renglon: buildDonRenglon, npc_tipito: buildTipito,
	printing_press: buildPrintingPress, empty_ink_barrel: buildEmptyBarrel, type_case: buildTypeCase,
	paper_guillotine: buildPaperGuillotine, paper_roll: buildPaperRoll, fax_machine: buildFax, ink_jar: buildInkJar,
	counter_bell: buildCounterBell, smiling_inkwell: buildSmilingInkwell,
	...Object.fromEntries(Object.entries(INKS).map(([k, c]) => [`ink_barrel_${k}`, () => buildInkBarrel(`ink_barrel_${k}`, c)])),
};

export const views = {
	print_shop: {
		items: [
			{ name: 'printing_press', pos: [-1.0, 0, -1.2] }, { name: 'ink_barrel_blue', pos: [-4.0, 0, 1.2] },
			{ name: 'ink_barrel_red', pos: [-3.2, 0, 1.4] }, { name: 'ink_barrel_yellow', pos: [-2.4, 0, 1.5] },
			{ name: 'ink_barrel_black', pos: [-1.6, 0, 1.6] }, { name: 'empty_ink_barrel', pos: [-0.7, 0, 1.7] },
			{ name: 'type_case', pos: [4.0, 0, -0.6], rotY: -0.4 }, { name: 'paper_guillotine', pos: [1.2, 0, 1.6] },
			{ name: 'paper_roll', pos: [3.4, 0, 1.4] }, { name: 'fax_machine', pos: [2.6, 0, 2.6] },
			{ name: 'ink_jar', pos: [3.2, 0, 2.7] }, { name: 'counter_bell', pos: [3.6, 0, 2.7] },
			{ name: 'smiling_inkwell', pos: [5.0, 0, 1.6], rotY: -0.3 },
			{ name: 'npc_don_renglon', pos: [6.2, 0, 1.8], rotY: -0.3 },
			{ name: 'npc_tipito', pos: [7.3, 0, 2.0], rotY: -0.4 },
			{ name: 'bills_plate', pos: [0.2, 0.04, 3.2] }, { name: 'bill_loupe', pos: [0.9, 0.01, 3.3] },
			{ name: 'green_ink_tin', pos: [1.4, 0.07, 3.2] }, { name: 'ticket_box', pos: [2.1, 0.125, 3.2] },
			{ name: 'concert_poster', pos: [2.9, 0.04, 3.3] }, { name: 'vip_stamp', pos: [3.5, 0.06, 3.3] },
		],
		cam: { pos: [0, 3.2, 9.5], target: [0.4, 0.9, 0], fov: 50 },
	},
};
