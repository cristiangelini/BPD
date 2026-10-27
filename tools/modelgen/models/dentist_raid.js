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
};

export const views = {
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
