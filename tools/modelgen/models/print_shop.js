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

export const models = {
	npc_don_renglon: buildDonRenglon,
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
		],
		cam: { pos: [0, 3.2, 9.5], target: [0.4, 0.9, 0], fov: 50 },
	},
};
