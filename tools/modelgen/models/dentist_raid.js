// The dentist raid (allanamiento-dentista.md, decision 460): the dental office's things. The dentist's chair (with its
// lamp and the drill's arm), the X-ray light box, the waiting room's fish tank, a laughing gas tank, the glass cabinet
// of denture molds and one mold on its own, the candy jar and the next-patient bell. Bottoms at y = 0, fronts toward
// +Z. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

const C = (name, color, opts) => mat(name, color, opts);
const chrome = C('dental_chrome', 0xc8d0d8, { metalness: 0.7, roughness: 0.3 });
const enamel = C('dental_white', 0xf4f6f8);
const glass = C('dental_glass', 0xbfe4f4, { transparent: true, opacity: 0.35, roughness: 0.05 });

// A row of teeth on a pink gum, `w` wide, centered at `at`.
function teeth(b, at, w, part = 'mold') {
	b.add(part, C('gum_pink', 0xe88a9a), new THREE.BoxGeometry(w, 0.025, 0.05), { pos: at });
	const n = Math.max(3, Math.round(w / 0.022));
	for (let i = 0; i < n; i++) {
		b.add(part, enamel, new THREE.BoxGeometry(w / n * 0.8, 0.025, 0.03), { pos: V(at.x - w / 2 + (i + 0.5) * w / n, at.y + 0.022, at.z + 0.01) });
	}
}

export const models = {
	// The dentist's chair: a mint seat that leans back, its base and foot pedal, the lamp on an arm and the drill's
	// tray beside it. About 0.8 x 1.5 x 1.9 m, facing +Z (the patient's feet toward +Z).
	dentist_chair() {
		const b = new Builder('dentist_chair');
		const mint = C('chair_mint', 0x6ac8b0, { roughness: 0.4 });
		b.add('base', chrome, new THREE.CylinderGeometry(0.3, 0.38, 0.08, 14), { pos: V(0, 0.04, -0.1) });
		b.add('base', chrome, new THREE.CylinderGeometry(0.08, 0.08, 0.4, 10), { pos: V(0, 0.28, -0.1) });
		b.add('pedal', C('pedal_black', 0x202020), new THREE.BoxGeometry(0.16, 0.04, 0.12), { pos: V(0.3, 0.05, 0.2) });
		b.add('seat', mint, new THREE.BoxGeometry(0.6, 0.14, 0.6), { pos: V(0, 0.52, -0.1) });
		b.add('seat', mint, new THREE.BoxGeometry(0.56, 0.12, 0.6), { pos: V(0, 0.5, 0.42), rot: [-0.35, 0, 0] });
		b.add('back', mint, new THREE.BoxGeometry(0.58, 0.12, 0.72), { pos: V(0, 0.78, -0.62), rot: [1.05, 0, 0] });
		b.add('back', mint, new THREE.BoxGeometry(0.3, 0.1, 0.22), { pos: V(0, 1.12, -0.9), rot: [0.8, 0, 0] });
		for (const s of [-1, 1]) b.add('arms', mint, new THREE.BoxGeometry(0.08, 0.06, 0.4), { pos: V(s * 0.34, 0.68, -0.1) });
		b.add('lamp', chrome, new THREE.CylinderGeometry(0.025, 0.025, 1.4, 6), { pos: V(-0.45, 0.7, -0.5) });
		b.add('lamp', chrome, new THREE.CylinderGeometry(0.02, 0.02, 0.7, 6), { pos: V(-0.25, 1.4, -0.35), rot: [0, 0, Math.PI / 2.6] });
		b.add('lamp', C('lamp_white', 0xf0f0e8), new THREE.CylinderGeometry(0.12, 0.08, 0.08, 10), { pos: V(-0.05, 1.32, -0.25), rot: [0.4, 0, 0] });
		b.add('lamp', C('lamp_light', 0xfff4c0, { emissive: 0xfff4c0, emissiveIntensity: 0.6 }), new THREE.CylinderGeometry(0.075, 0.075, 0.01, 10), { pos: V(-0.05, 1.27, -0.24), rot: [0.4, 0, 0] });
		b.add('tray', chrome, new THREE.CylinderGeometry(0.02, 0.02, 0.85, 6), { pos: V(0.5, 0.43, -0.3) });
		b.add('tray', enamel, new THREE.BoxGeometry(0.34, 0.03, 0.24), { pos: V(0.5, 0.86, -0.3) });
		b.add('tray', C('cup_paper', 0x8ad0f0), new THREE.CylinderGeometry(0.035, 0.03, 0.08, 8), { pos: V(0.6, 0.91, -0.25) });
		return b.build();
	},
	// The drill on its own (what buzzes in the story where nobody hears): a grey handpiece on its curly hose. 0.3 m long.
	dental_drill() {
		const b = new Builder('dental_drill');
		b.add('handpiece', chrome, new THREE.CylinderGeometry(0.014, 0.018, 0.18, 8), { pos: V(0, 0.02, 0), rot: [0, 0, Math.PI / 2] });
		b.add('handpiece', chrome, new THREE.CylinderGeometry(0.006, 0.006, 0.03, 5), { pos: V(0.1, 0.0, 0), rot: [0, 0, 0] });
		b.add('hose', C('hose_grey', 0x707880), new THREE.TorusGeometry(0.035, 0.008, 4, 10), { pos: V(-0.13, 0.02, 0), rot: [Math.PI / 2, 0, 0] });
		return b.build();
	},
	// The X-ray light box on the wall: a white glowing panel with a dark film of a molar on it. 0.6 x 0.45 x 0.06 m, its
	// back at z = 0 and its bottom at y = 0 (it hangs where it goes).
	xray_lightbox() {
		const b = new Builder('xray_lightbox');
		b.add('frame', C('box_grey', 0xa8b0b8), new THREE.BoxGeometry(0.6, 0.45, 0.05), { pos: V(0, 0.225, 0.025) });
		b.add('screen', C('light_panel', 0xf8faff, { emissive: 0xe8f0ff, emissiveIntensity: 0.7 }), new THREE.BoxGeometry(0.54, 0.38, 0.01), { pos: V(0, 0.225, 0.052) });
		b.add('film', C('film_dark', 0x203040, { transparent: true, opacity: 0.85 }), new THREE.BoxGeometry(0.24, 0.3, 0.004), { pos: V(-0.08, 0.225, 0.059) });
		b.add('film', C('film_bone', 0xd8e0e8, { emissive: 0x8090a0, emissiveIntensity: 0.4 }), ellipsoid(0.05, 0.08, 0.002, 8, 4), { pos: V(-0.08, 0.22, 0.062) });
		b.add('switch', C('switch_red', 0xd83a3a), new THREE.BoxGeometry(0.04, 0.03, 0.02), { pos: V(0.25, 0.04, 0.06) });
		return b.build();
	},
	// The waiting room's fish tank on its cabinet, with two orange fish and a plastic diver. 1.0 x 1.3 x 0.45 m.
	fish_tank() {
		const b = new Builder('fish_tank');
		b.add('cabinet', C('cabinet_wood', 0x8a6a4a), new THREE.BoxGeometry(1.0, 0.75, 0.45), { pos: V(0, 0.375, 0) });
		b.add('water', C('tank_water', 0x5ab0e0, { transparent: true, opacity: 0.45, roughness: 0.05 }), new THREE.BoxGeometry(0.94, 0.46, 0.39), { pos: V(0, 0.98, 0) });
		b.add('glass', glass, new THREE.BoxGeometry(1.0, 0.52, 0.45), { pos: V(0, 1.01, 0) });
		b.add('lid', C('lid_black', 0x202020), new THREE.BoxGeometry(1.02, 0.04, 0.47), { pos: V(0, 1.29, 0) });
		b.add('gravel', C('gravel', 0xd8c8a0), new THREE.BoxGeometry(0.94, 0.05, 0.39), { pos: V(0, 0.775, 0) });
		for (const [x, y] of [[-0.2, 1.0], [0.18, 1.1]]) {
			b.add('fish', C('fish_orange', 0xf08020), ellipsoid(0.05, 0.03, 0.015, 6, 4), { pos: V(x, y, 0.05) });
			b.add('fish', C('fish_orange', 0xf08020), new THREE.ConeGeometry(0.025, 0.04, 4), { pos: V(x - 0.06, y, 0.05), rot: [0, 0, Math.PI / 2] });
		}
		b.add('diver', C('diver_yellow', 0xf0d020), new THREE.CylinderGeometry(0.03, 0.04, 0.12, 6), { pos: V(0.3, 0.86, -0.05) });
		b.add('diver', chrome, new THREE.SphereGeometry(0.035, 8, 6), { pos: V(0.3, 0.95, -0.05) });
		return b.build();
	},
	// A laughing gas tank: a blue cylinder with a white shoulder, its valve and a smiley label. 0.2 x 0.95 x 0.2 m.
	gas_tank() {
		const b = new Builder('gas_tank');
		b.add('tank', C('tank_blue', 0x2a5ab8, { metalness: 0.4, roughness: 0.4 }), new THREE.CylinderGeometry(0.1, 0.1, 0.78, 12), { pos: V(0, 0.39, 0) });
		b.add('tank', enamel, new THREE.SphereGeometry(0.1, 12, 6, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(0, 0.78, 0) });
		b.add('valve', chrome, new THREE.CylinderGeometry(0.025, 0.025, 0.08, 8), { pos: V(0, 0.9, 0) });
		b.add('valve', chrome, new THREE.TorusGeometry(0.04, 0.008, 4, 10), { pos: V(0, 0.94, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('label', C('label_yellow', 0xf8d830), new THREE.CylinderGeometry(0.101, 0.101, 0.14, 12, 1, true, -0.6, 1.2), { pos: V(0, 0.45, 0) });
		b.add('label', C('label_ink', 0x202020), new THREE.TorusGeometry(0.03, 0.006, 4, 8, Math.PI), { pos: V(0, 0.43, 0.102), rot: [0, 0, Math.PI] });
		return b.build();
	},
	// The lab's glass cabinet with three shelves of denture molds. 1.2 x 1.6 x 0.4 m, its front toward +Z.
	mold_cabinet() {
		const b = new Builder('mold_cabinet');
		const frame = C('cabinet_white', 0xe8ecf0);
		b.add('frame', frame, new THREE.BoxGeometry(1.2, 0.08, 0.4), { pos: V(0, 0.04, 0) });
		b.add('frame', frame, new THREE.BoxGeometry(1.2, 0.04, 0.4), { pos: V(0, 1.58, 0) });
		b.add('frame', frame, new THREE.BoxGeometry(1.2, 1.6, 0.02), { pos: V(0, 0.8, -0.19) });
		for (const s of [-1, 1]) b.add('frame', frame, new THREE.BoxGeometry(0.03, 1.6, 0.4), { pos: V(s * 0.585, 0.8, 0) });
		for (let i = 0; i < 3; i++) {
			const y = 0.35 + i * 0.45;
			b.add('shelves', glass, new THREE.BoxGeometry(1.14, 0.015, 0.36), { pos: V(0, y, 0) });
			for (let j = 0; j < 3; j++) teeth(b, V(-0.36 + j * 0.36, y + 0.02, 0), 0.14, 'molds');
		}
		b.add('door', glass, new THREE.BoxGeometry(1.16, 1.5, 0.01), { pos: V(0, 0.82, 0.2) });
		return b.build();
	},
	// One denture mold, the kind that breaks (plaster base and teeth). 0.14 x 0.07 x 0.1 m.
	denture_mold() {
		const b = new Builder('denture_mold');
		b.add('base', C('plaster', 0xf0e8d8), new THREE.BoxGeometry(0.14, 0.03, 0.1), { pos: V(0, 0.015, 0) });
		teeth(b, V(0, 0.04, 0.0), 0.12);
		return b.build();
	},
	// The candy jar on the reception desk, full of colored candies on sticks. 0.18 x 0.3 x 0.18 m.
	candy_jar() {
		const b = new Builder('candy_jar');
		b.add('jar', glass, new THREE.CylinderGeometry(0.09, 0.09, 0.24, 12), { pos: V(0, 0.12, 0) });
		b.add('lid', C('jar_lid', 0xd83a5a), new THREE.CylinderGeometry(0.095, 0.095, 0.03, 12), { pos: V(0, 0.255, 0) });
		const colors = [0xf03a3a, 0x3ad04a, 0xf0d020, 0x3a8af0, 0xf080d0];
		for (let i = 0; i < 7; i++) {
			const a = i * 2.4, r = 0.04 + (i % 2) * 0.02;
			b.add('candy', C(`candy_${i % 5}`, colors[i % 5]), new THREE.SphereGeometry(0.025, 8, 6), { pos: V(Math.cos(a) * r, 0.05 + (i % 3) * 0.05, Math.sin(a) * r) });
		}
		return b.build();
	},
	// One candy on its stick, what Lucho wants (carried in hand). 0.05 x 0.14 x 0.05 m.
	candy_pop() {
		const b = new Builder('candy_pop');
		b.add('stick', enamel, new THREE.CylinderGeometry(0.004, 0.004, 0.1, 5), { pos: V(0, 0.05, 0) });
		b.add('candy', C('candy_0', 0xf03a3a), new THREE.SphereGeometry(0.025, 8, 6), { pos: V(0, 0.115, 0) });
		return b.build();
	},
	// The next-patient bell on the reception desk: a chrome dome on a black base, with a "Siguiente" plate. 0.14 x 0.1 m.
	next_bell() {
		const b = new Builder('next_bell');
		b.add('base', C('bell_base', 0x202020), new THREE.CylinderGeometry(0.07, 0.07, 0.03, 12), { pos: V(0, 0.015, 0) });
		b.add('dome', chrome, new THREE.SphereGeometry(0.055, 12, 6, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(0, 0.03, 0) });
		b.add('button', chrome, new THREE.CylinderGeometry(0.008, 0.008, 0.02, 6), { pos: V(0, 0.095, 0) });
		b.add('plate', C('plate_gold', 0xe0c050, { metalness: 0.6, roughness: 0.3 }), new THREE.BoxGeometry(0.08, 0.02, 0.004), { pos: V(0, 0.015, 0.071) });
		return b.build();
	},
	// The gold teeth story's main evidence: a small locked box with tiny gold ingots melted from crowns, its lid open a
	// bit. 0.3 x 0.16 x 0.2 m.
	gold_crown_box() {
		const b = new Builder('gold_crown_box');
		const steel = C('box_steel', 0x5a6068, { metalness: 0.5, roughness: 0.4 });
		const gold = C('ingot_gold', 0xf8c828, { metalness: 0.3, roughness: 0.35 });
		b.add('box', steel, new THREE.BoxGeometry(0.3, 0.12, 0.2), { pos: V(0, 0.06, 0) });
		b.add('lid', steel, new THREE.BoxGeometry(0.3, 0.02, 0.2), { pos: V(0, 0.15, -0.06), rot: [-0.7, 0, 0] });
		for (let i = 0; i < 4; i++) {
			b.add('ingots', gold, new THREE.BoxGeometry(0.05, 0.025, 0.09), { pos: V(-0.09 + i * 0.06, 0.13, 0.02) });
		}
		b.add('lock', gold, new THREE.BoxGeometry(0.04, 0.04, 0.01), { pos: V(0, 0.08, 0.103) });
		return b.build();
	},
	// The crucible with gold left in it, on its tongs. 0.2 x 0.16 x 0.2 m.
	gold_crucible() {
		const b = new Builder('gold_crucible');
		const clay = C('crucible_clay', 0x8a7a6a, { roughness: 0.9 });
		b.add('pot', clay, new THREE.CylinderGeometry(0.08, 0.055, 0.14, 12), { pos: V(0, 0.07, 0) });
		b.add('gold', C('melt_gold', 0xf0b020, { metalness: 0.3, roughness: 0.3 }), new THREE.CylinderGeometry(0.075, 0.075, 0.01, 12), { pos: V(0, 0.137, 0) });
		b.add('tongs', chrome, new THREE.BoxGeometry(0.012, 0.012, 0.22), { pos: V(0.09, 0.06, -0.02), rot: [0, 0.2, 0] });
		return b.build();
	},
	// The price list "Coronas de oro 2x1": a laminated sheet with a gold stripe. 0.21 x 0.006 x 0.29 m, flat.
	crown_price_list() {
		const b = new Builder('crown_price_list');
		b.add('sheet', C('price_sheet', 0xfaf6ea), new THREE.BoxGeometry(0.21, 0.004, 0.29), { pos: V(0, 0.002, 0) });
		b.add('stripe', C('price_gold', 0xe0b030), new THREE.BoxGeometry(0.19, 0.002, 0.05), { pos: V(0, 0.005, -0.1) });
		for (let i = 0; i < 5; i++) {
			b.add('lines', C('price_ink', 0x303030), new THREE.BoxGeometry(0.15, 0.002, 0.008), { pos: V(0, 0.005, -0.04 + i * 0.035) });
		}
		return b.build();
	},
	// The laughing gas story's main evidence: three contraband laughing gas tanks strapped together on a small pallet.
	// 0.6 x 0.76 x 0.4 m.
	gas_bundle() {
		const b = new Builder('gas_bundle');
		const tank = C('bundle_pink', 0xe86aa8, { metalness: 0.4, roughness: 0.4 });
		b.add('pallet', C('pallet_wood', 0xa07a4a), new THREE.BoxGeometry(0.6, 0.08, 0.4), { pos: V(0, 0.04, 0) });
		for (let i = 0; i < 3; i++) {
			const x = -0.18 + i * 0.18;
			b.add('tanks', tank, new THREE.CylinderGeometry(0.085, 0.085, 0.6, 10), { pos: V(x, 0.38, 0) });
			b.add('tanks', chrome, new THREE.CylinderGeometry(0.02, 0.02, 0.08, 6), { pos: V(x, 0.72, 0) });
			b.add('labels', C('smiley_yellow', 0xf8d830), new THREE.CylinderGeometry(0.03, 0.03, 0.004, 10), { pos: V(x, 0.45, 0.086), rot: [Math.PI / 2, 0, 0] });
		}
		for (const y of [0.25, 0.55]) {
			b.add('straps', C('strap_black', 0x202020), new THREE.BoxGeometry(0.58, 0.04, 0.2), { pos: V(0, y, 0) });
		}
		return b.build();
	},
	// Three balloons filled with laughing gas, tied together, with a smiley on each. 0.5 x 1.0 x 0.3 m.
	gas_balloons() {
		const b = new Builder('gas_balloons');
		const colors = [0xf06aa8, 0x6ac8f0, 0xf8d830];
		for (let i = 0; i < 3; i++) {
			const at = V(-0.15 + i * 0.15, 0.78 + (i % 2) * 0.08, (i - 1) * 0.04);
			b.add('balloons', C('balloon_' + i, colors[i], { roughness: 0.3 }), ellipsoid(0.1, 0.13, 0.1, 10, 8), { pos: at });
			b.add('strings', C('balloon_string', 0xf0f0f0), new THREE.CylinderGeometry(0.003, 0.003, at.y - 0.05, 4), { pos: V(at.x / 2, (at.y - 0.05) / 2 + 0.05, at.z / 2), rot: [0, 0, -at.x * 0.4] });
		}
		b.add('weight', C('weight_grey', 0x707070), new THREE.BoxGeometry(0.06, 0.05, 0.06), { pos: V(0, 0.025, 0) });
		return b.build();
	},
	// The invoice from "Fiestas La Carcajada": a pink sheet with a laughing face. 0.21 x 0.006 x 0.29 m, flat.
	carcajada_invoice() {
		const b = new Builder('carcajada_invoice');
		b.add('sheet', C('invoice_pink', 0xf8d8e8), new THREE.BoxGeometry(0.21, 0.004, 0.29), { pos: V(0, 0.002, 0) });
		b.add('face', C('face_yellow', 0xf8d830), new THREE.CylinderGeometry(0.035, 0.035, 0.002, 12), { pos: V(0, 0.005, -0.09) });
		b.add('mouth', C('face_ink', 0x303030), new THREE.BoxGeometry(0.03, 0.002, 0.008), { pos: V(0, 0.007, -0.08) });
		for (let i = 0; i < 4; i++) {
			b.add('lines', C('invoice_ink', 0x404040), new THREE.BoxGeometry(0.15, 0.002, 0.008), { pos: V(0, 0.005, -0.01 + i * 0.035) });
		}
		return b.build();
	},
	// The tooth mouse story's main evidence: a big jar crammed with 500 baby teeth, a mouse on the label. 0.25 x 0.35 m.
	teeth_jar() {
		const b = new Builder('teeth_jar');
		b.add('jar', glass, new THREE.CylinderGeometry(0.12, 0.12, 0.3, 14), { pos: V(0, 0.15, 0) });
		b.add('teeth', enamel, new THREE.CylinderGeometry(0.11, 0.11, 0.26, 14), { pos: V(0, 0.135, 0) });
		for (let i = 0; i < 10; i++) {
			const a = i * 0.63;
			b.add('teeth', C('tooth_cream', 0xece4cc), new THREE.BoxGeometry(0.025, 0.03, 0.02), { pos: V(Math.cos(a) * 0.105, 0.04 + (i % 5) * 0.05, Math.sin(a) * 0.105), rot: [0, -a, 0] });
		}
		b.add('lid', C('lid_red', 0xc83a3a), new THREE.CylinderGeometry(0.125, 0.125, 0.04, 14), { pos: V(0, 0.32, 0) });
		b.add('label', C('label_cream', 0xf6ecd0), new THREE.CylinderGeometry(0.121, 0.121, 0.08, 14, 1, true, -0.5, 1.0), { pos: V(0, 0.16, 0) });
		b.add('label', C('label_mouse', 0x8a8a90), ellipsoid(0.02, 0.018, 0.004, 6, 4), { pos: V(0, 0.16, 0.123) });
		return b.build();
	},
	// The mouse costume: grey overalls with a long tail and a head with round ears, folded on itself. 0.5 x 0.3 x 0.4 m.
	mouse_costume() {
		const b = new Builder('mouse_costume');
		const grey = C('costume_grey', 0x8a8a92, { roughness: 0.9 });
		b.add('body', grey, new THREE.BoxGeometry(0.4, 0.12, 0.35), { pos: V(0, 0.06, 0) });
		b.add('head', grey, ellipsoid(0.11, 0.1, 0.12, 10, 6), { pos: V(0.1, 0.2, 0) });
		for (const z of [-0.08, 0.08]) {
			b.add('ears', C('ear_pink', 0xf0a0b0), new THREE.CylinderGeometry(0.06, 0.06, 0.015, 10), { pos: V(0.1, 0.3, z), rot: [Math.PI / 2, 0, 0] });
		}
		b.add('tail', C('tail_pink', 0xe890a0), new THREE.CylinderGeometry(0.01, 0.006, 0.4, 5), { pos: V(-0.3, 0.05, 0), rot: [0, 0, Math.PI / 2] });
		return b.build();
	},
	// The neighborhood map with every child's pillow marked in red. 0.3 x 0.006 x 0.21 m, flat.
	pillow_map() {
		const b = new Builder('pillow_map');
		b.add('sheet', C('map_paper', 0xe8eed8), new THREE.BoxGeometry(0.3, 0.004, 0.21), { pos: V(0, 0.002, 0) });
		for (let i = 0; i < 3; i++) {
			b.add('streets', C('map_street', 0xb0b4b8), new THREE.BoxGeometry(0.28, 0.002, 0.01), { pos: V(0, 0.005, -0.06 + i * 0.06) });
			b.add('streets', C('map_street', 0xb0b4b8), new THREE.BoxGeometry(0.01, 0.002, 0.19), { pos: V(-0.09 + i * 0.09, 0.005, 0) });
		}
		for (let i = 0; i < 6; i++) {
			b.add('marks', C('map_red', 0xd83030), new THREE.BoxGeometry(0.018, 0.003, 0.018), { pos: V(-0.12 + i * 0.05, 0.006, -0.08 + (i % 3) * 0.06) });
		}
		return b.build();
	},
	// A wind-up toy mouse with its key on its back. 0.16 x 0.08 x 0.08 m, its nose toward +Z.
	windup_mouse() {
		const b = new Builder('windup_mouse');
		b.add('body', C('mouse_grey', 0x9a9aa2, { metalness: 0.3, roughness: 0.5 }), ellipsoid(0.04, 0.035, 0.07, 8, 6), { pos: V(0, 0.035, 0) });
		for (const x of [-0.025, 0.025]) {
			b.add('ears', C('mouse_ear', 0xf0a0b0), new THREE.CylinderGeometry(0.014, 0.014, 0.004, 8), { pos: V(x, 0.065, 0.04), rot: [Math.PI / 2, 0, 0] });
		}
		b.add('key', C('key_brass', 0xd0a040, { metalness: 0.6, roughness: 0.3 }), new THREE.TorusGeometry(0.018, 0.004, 4, 10), { pos: V(0, 0.085, -0.02) });
		b.add('tail', C('mouse_tail', 0xe890a0), new THREE.CylinderGeometry(0.003, 0.002, 0.08, 4), { pos: V(0, 0.02, -0.1), rot: [Math.PI / 2, 0, 0] });
		return b.build();
	},
	// The famous dentures story's main evidence: a black briefcase open a bit, rows of dentures on velvet inside, each
	// with a name tag. 0.45 x 0.3 x 0.32 m.
	celebrity_dentures_case() {
		const b = new Builder('celebrity_dentures_case');
		const black = C('case_black', 0x26262c, { roughness: 0.5 });
		b.add('case', black, new THREE.BoxGeometry(0.45, 0.1, 0.32), { pos: V(0, 0.05, 0) });
		b.add('velvet', C('velvet_red', 0x8a1a2a, { roughness: 0.95 }), new THREE.BoxGeometry(0.42, 0.01, 0.29), { pos: V(0, 0.1, 0) });
		b.add('lid', black, new THREE.BoxGeometry(0.45, 0.32, 0.03), { pos: V(0, 0.25, -0.17), rot: [-0.25, 0, 0] });
		b.add('handle', C('handle_gold', 0xd0a040, { metalness: 0.6, roughness: 0.3 }), new THREE.BoxGeometry(0.12, 0.02, 0.02), { pos: V(0, 0.05, 0.17) });
		for (let i = 0; i < 2; i++) {
			for (let j = 0; j < 2; j++) {
				teeth(b, V(-0.1 + i * 0.2, 0.11, -0.06 + j * 0.12), 0.12, 'dentures');
				b.add('tags', C('tag_white', 0xf8f8f0), new THREE.BoxGeometry(0.05, 0.003, 0.02), { pos: V(-0.1 + i * 0.2, 0.108, -0.02 + j * 0.12) });
			}
		}
		return b.build();
	},
	// The signed photo "Gracias por mi sonrisa": a framed smiling face with a scrawl. 0.25 x 0.32 x 0.03 m, standing.
	smile_photo() {
		const b = new Builder('smile_photo');
		b.add('frame', C('photo_frame', 0xd0a040, { metalness: 0.4, roughness: 0.4 }), new THREE.BoxGeometry(0.25, 0.32, 0.02), { pos: V(0, 0.16, 0) });
		b.add('photo', C('photo_blue', 0x6a9ad0), new THREE.BoxGeometry(0.21, 0.28, 0.004), { pos: V(0, 0.16, 0.011) });
		b.add('face', C('photo_skin', 0xe8b890), ellipsoid(0.06, 0.075, 0.004, 10, 4), { pos: V(0, 0.18, 0.013) });
		b.add('smile', enamel, new THREE.BoxGeometry(0.06, 0.012, 0.004), { pos: V(0, 0.155, 0.016) });
		b.add('scrawl', C('photo_ink', 0x202020), new THREE.BoxGeometry(0.12, 0.006, 0.003), { pos: V(0.02, 0.06, 0.015), rot: [0, 0, 0.2] });
		return b.build();
	},
	// A half-finished denture mold: a plaster block with half a row of teeth. 0.16 x 0.08 x 0.12 m.
	half_mold() {
		const b = new Builder('half_mold');
		b.add('plaster', C('plaster_white', 0xe8e4dc, { roughness: 0.95 }), new THREE.BoxGeometry(0.16, 0.05, 0.12), { pos: V(0, 0.025, 0) });
		teeth(b, V(-0.035, 0.055, 0), 0.08, 'teeth');
		return b.build();
	},
	// A toy chattering denture on two little orange feet. 0.1 x 0.08 x 0.08 m, its front toward +Z.
	chatter_teeth() {
		const b = new Builder('chatter_teeth');
		for (const x of [-0.025, 0.025]) {
			b.add('feet', C('feet_orange', 0xf08a30), new THREE.BoxGeometry(0.03, 0.015, 0.04), { pos: V(x, 0.008, 0.005) });
		}
		teeth(b, V(0, 0.03, 0), 0.09, 'lower');
		b.add('upper', C('gum_pink', 0xe88a9a), new THREE.BoxGeometry(0.09, 0.025, 0.05), { pos: V(0, 0.072, -0.005), rot: [-0.3, 0, 0] });
		b.add('key', C('key_brass', 0xd0a040, { metalness: 0.6, roughness: 0.3 }), new THREE.TorusGeometry(0.014, 0.003, 4, 8), { pos: V(0.05, 0.04, 0), rot: [0, Math.PI / 2, 0] });
		return b.build();
	},
	// The rising chair story's main evidence: the loot bag of a robbery, a canvas sack tied at the top with a "$" on it.
	// 0.45 x 0.5 x 0.35 m.
	loot_bag() {
		const b = new Builder('loot_bag');
		const canvas = C('sack_canvas', 0xc8b088, { roughness: 0.95 });
		b.add('sack', canvas, ellipsoid(0.22, 0.2, 0.17, 10, 8), { pos: V(0, 0.2, 0) });
		b.add('neck', canvas, new THREE.CylinderGeometry(0.05, 0.09, 0.12, 8), { pos: V(0, 0.42, 0) });
		b.add('rope', C('sack_rope', 0x7a5a3a), new THREE.TorusGeometry(0.055, 0.012, 4, 10), { pos: V(0, 0.4, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('sign', C('sack_ink', 0x2a6a2a), new THREE.BoxGeometry(0.03, 0.12, 0.01), { pos: V(0, 0.22, 0.17) });
		b.add('sign', C('sack_ink', 0x2a6a2a), new THREE.BoxGeometry(0.08, 0.02, 0.01), { pos: V(0, 0.25, 0.168) });
		b.add('sign', C('sack_ink', 0x2a6a2a), new THREE.BoxGeometry(0.08, 0.02, 0.01), { pos: V(0, 0.19, 0.168) });
		return b.build();
	},
	// The key to the false ceiling's hatch: a long brass key on a ring with a tag. 0.12 x 0.02 x 0.05 m, lying flat.
	hatch_key() {
		const b = new Builder('hatch_key');
		const brass = C('key_brass', 0xd0a040, { metalness: 0.6, roughness: 0.3 });
		b.add('ring', brass, new THREE.TorusGeometry(0.02, 0.004, 4, 10), { pos: V(-0.04, 0.005, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('shaft', brass, new THREE.BoxGeometry(0.08, 0.008, 0.01), { pos: V(0.02, 0.005, 0) });
		b.add('bit', brass, new THREE.BoxGeometry(0.015, 0.008, 0.02), { pos: V(0.055, 0.005, 0.012) });
		b.add('tag', C('tag_red', 0xd03030), new THREE.BoxGeometry(0.03, 0.004, 0.04), { pos: V(-0.075, 0.003, 0.0) });
		return b.build();
	},
	// The plan of the ceiling with an X over the hatch above chair 2. 0.3 x 0.006 x 0.21 m, flat.
	ceiling_plan() {
		const b = new Builder('ceiling_plan');
		b.add('sheet', C('plan_blue', 0x3a6ac8), new THREE.BoxGeometry(0.3, 0.004, 0.21), { pos: V(0, 0.002, 0) });
		for (let i = 0; i < 4; i++) {
			b.add('grid', C('plan_white', 0xf0f4f8), new THREE.BoxGeometry(0.28, 0.002, 0.004), { pos: V(0, 0.005, -0.075 + i * 0.05) });
			b.add('grid', C('plan_white', 0xf0f4f8), new THREE.BoxGeometry(0.004, 0.002, 0.19), { pos: V(-0.105 + i * 0.07, 0.005, 0) });
		}
		b.add('mark', C('plan_red', 0xe03030), new THREE.BoxGeometry(0.05, 0.003, 0.008), { pos: V(0.04, 0.007, 0.02), rot: [0, 0.785, 0] });
		b.add('mark', C('plan_red', 0xe03030), new THREE.BoxGeometry(0.05, 0.003, 0.008), { pos: V(0.04, 0.007, 0.02), rot: [0, -0.785, 0] });
		return b.build();
	},
	// The dental floss story's main evidence: a crate of reinforced floss reels for a jailbreak, six big white reels
	// with mint labels in an open wooden crate. 0.5 x 0.3 x 0.35 m.
	floss_reels() {
		const b = new Builder('floss_reels');
		const wood = C('crate_wood', 0xa07848, { roughness: 0.9 });
		b.add('bottom', wood, new THREE.BoxGeometry(0.5, 0.03, 0.35), { pos: V(0, 0.015, 0) });
		for (const z of [-0.165, 0.165]) {
			b.add('side', wood, new THREE.BoxGeometry(0.5, 0.18, 0.02), { pos: V(0, 0.09, z) });
		}
		for (const x of [-0.24, 0.24]) {
			b.add('side', wood, new THREE.BoxGeometry(0.02, 0.18, 0.35), { pos: V(x, 0.09, 0) });
		}
		for (let i = 0; i < 6; i++) {
			const at = V(-0.15 + (i % 3) * 0.15, 0.13, i < 3 ? -0.08 : 0.08);
			b.add('reel', C('floss_white', 0xf4f4ee), new THREE.CylinderGeometry(0.065, 0.065, 0.2, 10), { pos: at });
			b.add('label', C('floss_mint', 0x50c8a0), new THREE.CylinderGeometry(0.067, 0.067, 0.06, 10), { pos: at });
		}
		return b.build();
	},
	// A climbing hook: a three-pronged grapnel with a loop of floss tied to it. 0.25 x 0.3 x 0.25 m.
	climbing_hook() {
		const b = new Builder('climbing_hook');
		const steel = C('hook_steel', 0x8a9098, { metalness: 0.7, roughness: 0.35 });
		b.add('shaft', steel, new THREE.CylinderGeometry(0.015, 0.015, 0.25, 6), { pos: V(0, 0.15, 0) });
		for (let i = 0; i < 3; i++) {
			const a = (i / 3) * Math.PI * 2;
			b.add('prong', steel, new THREE.BoxGeometry(0.11, 0.02, 0.02), { pos: V(Math.cos(a) * 0.05, 0.04, Math.sin(a) * 0.05), rot: [0, -a, 0.6] });
		}
		b.add('eye', steel, new THREE.TorusGeometry(0.025, 0.007, 4, 10), { pos: V(0, 0.29, 0) });
		b.add('floss', C('floss_white', 0xf4f4ee), new THREE.TorusGeometry(0.06, 0.004, 4, 12), { pos: V(0, 0.28, 0.04), rot: [Math.PI / 2, 0, 0] });
		return b.build();
	},
	// The plan of the jail with a dotted escape route over its wall. 0.3 x 0.006 x 0.21 m, flat.
	prison_plan() {
		const b = new Builder('prison_plan');
		b.add('sheet', C('jail_paper', 0xe8e0c8), new THREE.BoxGeometry(0.3, 0.004, 0.21), { pos: V(0, 0.002, 0) });
		b.add('wall', C('jail_ink', 0x303030), new THREE.BoxGeometry(0.22, 0.002, 0.006), { pos: V(0, 0.005, -0.07) });
		b.add('wall', C('jail_ink', 0x303030), new THREE.BoxGeometry(0.22, 0.002, 0.006), { pos: V(0, 0.005, 0.07) });
		b.add('wall', C('jail_ink', 0x303030), new THREE.BoxGeometry(0.006, 0.002, 0.14), { pos: V(-0.11, 0.005, 0) });
		b.add('wall', C('jail_ink', 0x303030), new THREE.BoxGeometry(0.006, 0.002, 0.14), { pos: V(0.11, 0.005, 0) });
		for (let i = 0; i < 5; i++) {
			b.add('route', C('plan_red', 0xe03030), new THREE.BoxGeometry(0.02, 0.003, 0.006), { pos: V(-0.04 + i * 0.035, 0.007, 0.03 + i * 0.012) });
		}
		return b.build();
	},
};

export const views = {
	dentist_floss: {
		items: [{ name: 'floss_reels', pos: [-0.35, 0, 0] }, { name: 'climbing_hook', pos: [0.2, 0, 0.0] },
			{ name: 'prison_plan', pos: [0.45, 0, 0.2], rotY: -0.3 }],
		cam: { pos: [0.0, 0.7, 1.4], target: [0.0, 0.12, 0], fov: 40 },
	},
	dentist_chair_story: {
		items: [{ name: 'loot_bag', pos: [-0.35, 0, 0] }, { name: 'hatch_key', pos: [0.15, 0, 0.15], rotY: 0.4 },
			{ name: 'ceiling_plan', pos: [0.4, 0, -0.05], rotY: -0.3 }],
		cam: { pos: [0.0, 0.6, 1.3], target: [0.0, 0.15, 0], fov: 40 },
	},
	dentist_dentures: {
		items: [{ name: 'celebrity_dentures_case', pos: [-0.35, 0, 0] }, { name: 'smile_photo', pos: [0.15, 0, -0.05], rotY: -0.2 },
			{ name: 'half_mold', pos: [0.45, 0, 0.1] }, { name: 'chatter_teeth', pos: [0.2, 0, 0.3], rotY: 0.4 }],
		cam: { pos: [0.0, 0.6, 1.4], target: [0.0, 0.12, 0], fov: 40 },
	},
	dentist_mouse: {
		items: [{ name: 'teeth_jar', pos: [-0.45, 0, 0] }, { name: 'mouse_costume', pos: [0.05, 0, 0], rotY: 0.4 },
			{ name: 'pillow_map', pos: [0.5, 0, 0.15], rotY: -0.3 }, { name: 'windup_mouse', pos: [0.3, 0, 0.35], rotY: 0.8 }],
		cam: { pos: [0.0, 0.8, 1.7], target: [0.0, 0.12, 0], fov: 40 },
	},
	dentist_gas: {
		items: [{ name: 'gas_bundle', pos: [-0.5, 0, 0] }, { name: 'gas_balloons', pos: [0.25, 0, 0] },
			{ name: 'carcajada_invoice', pos: [0.75, 0, 0.2], rotY: -0.3 }],
		cam: { pos: [0.1, 0.9, 2.6], target: [0.1, 0.45, 0], fov: 40 },
	},
	dentist_gold: {
		items: [{ name: 'gold_crown_box', pos: [-0.25, 0, 0] }, { name: 'gold_crucible', pos: [0.15, 0, 0.05] },
			{ name: 'crown_price_list', pos: [0.45, 0, 0.1], rotY: -0.3 }],
		cam: { pos: [0.1, 0.6, 1.1], target: [0.1, 0.05, 0], fov: 40 },
	},
	dentist_people: {
		items: [{ name: 'npc_molina', pos: [-0.6, 0, 0], rotY: 0.3 }, { name: 'npc_lucho', pos: [0.6, 0, 0.2], rotY: -0.2, scale: 0.65 }],
		cam: { pos: [0, 1.3, 5.0], target: [0, 0.85, 0], fov: 34 },
	},
	dentist_room: {
		items: [{ name: 'dentist_chair', pos: [-1.2, 0, 0], rotY: 0.6 }, { name: 'gas_tank', pos: [-0.2, 0, -0.6] },
			{ name: 'fish_tank', pos: [0.9, 0, -0.5], rotY: -0.3 }, { name: 'mold_cabinet', pos: [2.4, 0, -0.6], rotY: -0.4 }],
		cam: { pos: [0.6, 2.2, 6.2], target: [0.6, 0.8, 0], fov: 40 },
	},
	dentist_small: {
		items: [{ name: 'xray_lightbox', pos: [-0.5, 0, -0.2] }, { name: 'dental_drill', pos: [0.15, 0, 0.3], rotY: 0.4 },
			{ name: 'denture_mold', pos: [0.35, 0, 0.0] }, { name: 'candy_jar', pos: [0.6, 0, -0.1] },
			{ name: 'candy_pop', pos: [0.75, 0, 0.3] }, { name: 'next_bell', pos: [0.95, 0, 0.1] }],
		cam: { pos: [0.2, 0.9, 1.9], target: [0.2, 0.15, 0], fov: 40 },
	},
};
