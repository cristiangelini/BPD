// Showroom furniture of "El Ropero Feliz" (docs/diseno/allanamiento-muebleria.md): the three-seat sofa, the bed, the
// wardrobe with its doors open, the chest of drawers, the floor lamp, the standing mirror, the dining table and chair
// and the flat-pack box. Origins on the floor in the middle of each piece, fronts to +Z. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), ...(rot ? { rot } : {}) });
}

// A price tag on a string: white card with a red stripe, hanging from (x, y, z).
function tag(b, x, y, z) {
	box(b, 'tag', mat('tag_card', 0xf6f2e6), 0.12, 0.08, 0.005, x, y - 0.06, z);
	box(b, 'tag', mat('tag_red', 0xd23a3a), 0.12, 0.02, 0.006, x, y - 0.04, z);
	box(b, 'tag', mat('tag_string', 0x2a2a2e), 0.004, 0.03, 0.004, x, y - 0.01, z);
}

// A three-seat sofa 2.1 × 0.85 × 0.9 m: mustard cloth, the seat at 0.45 m with three cushions, the back's two big
// cushions, round arms and dark wooden feet.
export function buildShowroomSofa() {
	const b = new Builder('showroom_sofa');
	const cloth = mat('sofa_cloth', 0xd4a23a), cushion = mat('sofa_cushion', 0xe2b44e), foot = mat('sofa_foot', 0x3a2414);
	box(b, 'base', cloth, 2.1, 0.3, 0.9, 0, 0.23, 0);
	for (let i = 0; i < 3; i++) box(b, 'cushion', cushion, 0.62, 0.14, 0.7, -0.65 + i * 0.65, 0.45, 0.07);
	box(b, 'back', cloth, 2.1, 0.45, 0.2, 0, 0.6, -0.35);
	for (let i = 0; i < 2; i++) box(b, 'back_cushion', cushion, 0.92, 0.36, 0.14, -0.47 + i * 0.94, 0.68, -0.2, [-0.15, 0, 0]);
	for (const s of [-1, 1]) {
		box(b, 'arm', cloth, 0.18, 0.3, 0.9, s * 0.96, 0.53, 0);
		b.add('arm_roll', cloth, new THREE.CylinderGeometry(0.1, 0.1, 0.9, 10), { pos: V(s * 0.96, 0.68, 0), rot: [Math.PI / 2, 0, 0] });
		for (const z of [-1, 1]) box(b, 'foot', foot, 0.06, 0.08, 0.06, s * 0.95, 0.04, z * 0.38);
	}
	tag(b, 0.96, 0.78, 0.46);
	return b.build();
}

// A double bed 1.5 × 2.0 m: the wooden frame on four legs (0.3 m clear underneath), the mattress up to 0.62 m, a
// headboard at -Z, two pillows and a folded blanket at the foot.
export function buildShowroomBed() {
	const b = new Builder('showroom_bed');
	const wood = mat('bed_wood', 0x8a5a34), sheet = mat('bed_sheet', 0xf2efe6), blanket = mat('bed_blanket', 0x4a7ab8);
	for (const x of [-1, 1]) for (const z of [-1, 1]) box(b, 'leg', wood, 0.08, 0.3, 0.08, x * 0.7, 0.15, z * 0.95);
	box(b, 'frame', wood, 1.5, 0.1, 2.0, 0, 0.35, 0);
	box(b, 'mattress', sheet, 1.44, 0.22, 1.94, 0, 0.51, 0);
	box(b, 'headboard', wood, 1.56, 0.7, 0.08, 0, 0.75, -1.0);
	for (const x of [-1, 1]) box(b, 'pillow', mat('bed_pillow', 0xffffff), 0.55, 0.12, 0.32, x * 0.35, 0.68, -0.72);
	box(b, 'blanket', blanket, 1.46, 0.06, 0.5, 0, 0.64, 0.7);
	tag(b, 0.78, 0.4, 1.0);
	return b.build();
}

// A two-door wardrobe 1.2 × 2.0 × 0.6 m with both doors swung wide open (the showroom shows the inside): the shell,
// a shelf and a rail with two hangers, the crown on top and round knobs.
export function buildShowroomWardrobe() {
	const b = new Builder('showroom_wardrobe');
	const wood = mat('wardrobe_wood', 0xa8703e), inside = mat('wardrobe_inside', 0x7a4e2a), knob = mat('wardrobe_knob', 0xd8b04a);
	box(b, 'back', inside, 1.2, 1.9, 0.04, 0, 1.0, -0.28);
	for (const s of [-1, 1]) box(b, 'side', wood, 0.04, 1.9, 0.6, s * 0.58, 1.0, 0);
	box(b, 'bottom', wood, 1.2, 0.05, 0.6, 0, 0.075, 0);
	box(b, 'top', wood, 1.2, 0.04, 0.6, 0, 1.93, 0);
	box(b, 'crown', wood, 1.3, 0.08, 0.66, 0, 1.99, 0);
	box(b, 'plinth', inside, 1.16, 0.05, 0.56, 0, 0.025, 0);
	box(b, 'shelf', inside, 1.12, 0.03, 0.52, 0, 1.6, 0);
	b.add('rail', mat('wardrobe_rail', 0x9a9ea4), new THREE.CylinderGeometry(0.012, 0.012, 1.1, 6), { pos: V(0, 1.5, 0), rot: [0, 0, Math.PI / 2] });
	for (const x of [-0.2, 0.15]) box(b, 'hanger', mat('wardrobe_hanger', 0x2a2a2e), 0.36, 0.02, 0.02, x, 1.42, 0, [0, 0, 0]);
	// The doors, each hinged on its outer edge and swung 100° out, with its knob near the free edge.
	for (const s of [-1, 1]) {
		const turn = s * 1.75, c = Math.cos(turn), out = Math.sin(Math.abs(turn));
		box(b, 'door', wood, 0.6, 1.86, 0.03, s * 0.6 - s * 0.3 * c, 1.0, 0.3 + 0.3 * out, [0, turn, 0]);
		b.add('knob', knob, new THREE.SphereGeometry(0.025, 8, 6), { pos: V(s * 0.6 - s * 0.52 * c + 0.03, 1.0, 0.3 + 0.52 * out) });
	}
	return b.build();
}

// A chest of four drawers 1.0 × 0.9 × 0.5 m, each drawer with two brass knobs.
export function buildShowroomDresser() {
	const b = new Builder('showroom_dresser');
	const wood = mat('dresser_wood', 0x9a6438), front = mat('dresser_front', 0xb47a48), knob = mat('dresser_knob', 0xd8b04a);
	box(b, 'body', wood, 1.0, 0.86, 0.5, 0, 0.47, 0);
	box(b, 'top', wood, 1.04, 0.03, 0.54, 0, 0.915, 0);
	for (let i = 0; i < 4; i++) {
		box(b, 'drawer', front, 0.92, 0.18, 0.02, 0, 0.16 + i * 0.205, 0.255);
		for (const x of [-0.25, 0.25]) b.add('knob', knob, new THREE.SphereGeometry(0.018, 8, 6), { pos: V(x, 0.16 + i * 0.205, 0.275) });
	}
	for (const x of [-1, 1]) for (const z of [-1, 1]) box(b, 'foot', wood, 0.05, 0.04, 0.05, x * 0.46, 0.02, z * 0.21);
	return b.build();
}

// A floor lamp 1.7 m tall: a round foot, a thin brass pole and a pleated cream shade with the bulb glowing inside.
export function buildShowroomLamp() {
	const b = new Builder('showroom_lamp');
	const brass = mat('lamp_brass', 0xc8a050, { metalness: 0.4, roughness: 0.5 }), shade = mat('lamp_cream', 0xf4e2b0);
	b.add('foot', brass, new THREE.CylinderGeometry(0.16, 0.18, 0.04, 14), { pos: V(0, 0.02, 0) });
	b.add('pole', brass, new THREE.CylinderGeometry(0.015, 0.015, 1.45, 6), { pos: V(0, 0.76, 0) });
	b.add('shade', shade, new THREE.CylinderGeometry(0.16, 0.26, 0.32, 12, 1, true), { pos: V(0, 1.54, 0) });
	b.add('bulb', mat('lamp_bulb', 0xfff4c0, { emissive: 0xffe08a, emissiveIntensity: 0.8 }), new THREE.SphereGeometry(0.05, 8, 6), { pos: V(0, 1.47, 0) });
	return b.build();
}

// A standing mirror 0.8 × 1.8 m: the glass in a carved wooden frame, tilted a little back on its two feet.
export function buildStandingMirror() {
	const b = new Builder('standing_mirror');
	const wood = mat('mirror_wood', 0x6a3e22), glass = mat('mirror_glass', 0xbcd8e8, { metalness: 0.6, roughness: 0.1 });
	const tilt = [-0.08, 0, 0];
	box(b, 'glass', glass, 0.68, 1.6, 0.01, 0, 0.98, 0.0, tilt);
	for (const s of [-1, 1]) box(b, 'frame', wood, 0.06, 1.72, 0.04, s * 0.37, 0.98, -0.01, tilt);
	for (const y of [0.15, 1.82]) box(b, 'frame', wood, 0.8, 0.06, 0.04, 0, y, -0.01 - (y - 0.98) * 0.08, tilt);
	b.add('crest', wood, new THREE.SphereGeometry(0.06, 8, 6), { pos: V(0, 1.88, -0.08) });
	for (const s of [-1, 1]) box(b, 'foot', wood, 0.06, 0.06, 0.5, s * 0.34, 0.03, -0.1);
	return b.build();
}

// The dining table 2.4 × 0.76 × 1.0 m, light wood, with a runner and a bowl of plastic fruit.
export function buildDiningTable() {
	const b = new Builder('dining_table');
	const wood = mat('table_wood', 0xc89a62);
	box(b, 'top', wood, 2.4, 0.05, 1.0, 0, 0.735, 0);
	for (const x of [-1, 1]) for (const z of [-1, 1]) box(b, 'leg', wood, 0.07, 0.71, 0.07, x * 1.12, 0.355, z * 0.44);
	box(b, 'runner', mat('table_runner', 0xb83a3a), 1.6, 0.005, 0.3, 0, 0.763, 0);
	b.add('bowl', mat('table_bowl', 0xf2f2ea), new THREE.SphereGeometry(0.16, 12, 6, 0, Math.PI * 2, Math.PI / 2, Math.PI / 2), { pos: V(0, 0.92, 0) });
	const fruit = [[0xd23a3a, -0.06, 0.03], [0xf2c230, 0.06, -0.02], [0x6ac24a, 0, 0.07]];
	for (const [color, x, z] of fruit) b.add('fruit', mat('fruit_' + color.toString(16), color), new THREE.SphereGeometry(0.055, 8, 6), { pos: V(x, 0.82, z) });
	return b.build();
}

// A dining chair 0.45 × 0.9 × 0.48 m: the seat at 0.46 m, four legs and a back with three slats. Chairs stack.
export function buildDiningChair() {
	const b = new Builder('dining_chair');
	const wood = mat('chair_wood', 0xb07a48), seat = mat('chair_seat', 0x4a7a4a);
	box(b, 'seat', seat, 0.45, 0.05, 0.45, 0, 0.46, 0);
	for (const x of [-1, 1]) for (const z of [-1, 1]) box(b, 'leg', wood, 0.04, 0.44, 0.04, x * 0.2, 0.22, z * 0.2);
	for (const x of [-1, 1]) box(b, 'post', wood, 0.04, 0.44, 0.04, x * 0.2, 0.7, -0.2);
	box(b, 'rail', wood, 0.44, 0.06, 0.03, 0, 0.88, -0.2);
	for (let i = 0; i < 3; i++) box(b, 'slat', wood, 0.04, 0.3, 0.02, -0.1 + i * 0.1, 0.7, -0.2);
	return b.build();
}

// A flat-pack box 1.2 × 0.15 × 0.6 m: brown cardboard, tape across, the arrows "this side up" and a drawing of a
// shelf on the lid.
export function buildFlatpackBox() {
	const b = new Builder('flatpack_box');
	box(b, 'box', mat('cardboard', 0xc49a62), 1.2, 0.15, 0.6, 0, 0.075, 0);
	box(b, 'tape', mat('cardboard_tape', 0xd8c49a), 1.21, 0.152, 0.08, 0, 0.075, 0);
	const ink = mat('cardboard_ink', 0x2a2a2e);
	box(b, 'drawing', ink, 0.3, 0.002, 0.02, -0.3, 0.151, 0.1);
	box(b, 'drawing', ink, 0.3, 0.002, 0.02, -0.3, 0.151, -0.1);
	for (const x of [-0.44, -0.16]) box(b, 'drawing', ink, 0.02, 0.002, 0.22, x, 0.151, 0);
	for (const x of [0.3, 0.42]) box(b, 'arrow', ink, 0.02, 0.06, 0.002, x, 0.075, 0.301);
	return b.build();
}

export const models = {
	showroom_sofa: buildShowroomSofa, showroom_bed: buildShowroomBed, showroom_wardrobe: buildShowroomWardrobe,
	showroom_dresser: buildShowroomDresser, showroom_lamp: buildShowroomLamp, standing_mirror: buildStandingMirror,
	dining_table: buildDiningTable, dining_chair: buildDiningChair, flatpack_box: buildFlatpackBox,
};

export const views = {
	furniture: {
		items: [
			{ name: 'showroom_sofa', pos: [-2.0, 0, 0.6] }, { name: 'showroom_bed', pos: [0.6, 0, -0.6] },
			{ name: 'showroom_wardrobe', pos: [2.8, 0, -0.8] }, { name: 'showroom_dresser', pos: [-2.4, 0, -1.4] },
			{ name: 'showroom_lamp', pos: [-3.6, 0, -0.4] }, { name: 'standing_mirror', pos: [4.2, 0, 0.6] },
			{ name: 'dining_chair', pos: [2.2, 0, 1.4] }, { name: 'flatpack_box', pos: [-0.6, 0, 1.6] },
		],
		cam: { pos: [0, 2.6, 7.5], target: [0, 0.8, 0], fov: 50 },
	},
	furniture_table: {
		items: [{ name: 'dining_table', pos: [0, 0, 0] }, { name: 'dining_chair', pos: [-0.6, 0, 0.75] }, { name: 'dining_chair', pos: [0.6, 0, -0.75] }],
		cam: { pos: [0, 2.2, 3.6], target: [0, 0.6, 0], fov: 45 },
	},
};
