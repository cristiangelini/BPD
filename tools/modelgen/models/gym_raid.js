// The gym raid (allanamiento-gimnasio.md, decision 250): el profe Fito, Lula the receptionist, the reception's stereo,
// the record wall with its bar and a shop mannequin that "trains" for a ghost member. Placeholder, not final art.
import { Builder, loft, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);
const white = M.white, black = M.black;

function mouth(b, smile = true) {
	b.add('face', C('mouth', 0x7a2a2a), ellipsoid(0.05, smile ? 0.02 : 0.03, 0.02, 6, 4), { pos: V(0, 1.22, 0.2) });
}

// Stripes around the pear body's bottom (pants) or top (shirt), at the heights in `ys`.
function stripes(b, m, ys) {
	for (const y of ys) {
		const r = y < 0.5 ? 0.36 + Math.min(y - 0.1, 0.2) * 0.6 - Math.max(y - 0.3, 0) * 0.1 : y < 0.8 ? 0.46 - (y - 0.5) * 0.33 : 0.36 - (y - 0.8) * 0.48;
		b.add('body', m, loft([{ y: y - 0.02, rx: r + 0.012, rz: r * 0.89 + 0.012 }, { y: y + 0.02, rx: r + 0.012, rz: r * 0.89 + 0.012 }], 10));
	}
}

function wristbands(b, m) {
	for (const s of [-1, 1]) b.add('arms', m, new THREE.CylinderGeometry(0.07, 0.07, 0.07, 8), { pos: V(s * 0.43, 0.71, 0.07), lookAt: V(s * 0.16, -0.17, 0.08) });
}

// A whistle hanging from a cord on the chest.
function whistle(b) {
	const cord = C('whistle_cord', 0xe23a3a);
	b.add('body', cord, new THREE.TorusGeometry(0.17, 0.008, 4, 16, Math.PI), { pos: V(0, 1.08, 0.08), rot: [0.5, 0, Math.PI] });
	b.add('body', C('whistle_steel', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 }), new THREE.CylinderGeometry(0.025, 0.025, 0.07, 8), { pos: V(0, 0.92, 0.27), rot: [0, 0, Math.PI / 2] });
}

const models = {
	// El profe Fito, the aerobics teacher: neon headband over huge curls, a pink tank top, striped tights, wristbands and
	// his whistle. The game scales him thin (x 0.85).
	npc_profe_fito() {
		const b = new Builder('npc_profe_fito');
		const tank = C('fito_tank', 0xff4fa8), tights = C('fito_tights', 0x2a2a8a), stripe = C('fito_stripe', 0x3fe0ff);
		pearBody(b, C('skin_arena', 0xd9a06b), { shirt: tank, pants: tights, shoes: white, belted: false });
		stripes(b, stripe, [0.2, 0.32, 0.44]);
		eyes(b, 1.34, 0.17, 0.08, 0.05);
		mouth(b);
		const hair = C('fito_hair', 0x3a2414);
		for (let i = 0; i < 14; i++) {
			const a = (i / 14) * Math.PI * 2, up = i % 2 ? 1.5 : 1.42;
			b.add('hair', hair, ellipsoid(0.09, 0.09, 0.09, 6, 4), { pos: V(Math.cos(a) * 0.17, up, 0.02 + Math.sin(a) * 0.16 - (Math.sin(a) > 0.6 ? 0.06 : 0)) });
		}
		b.add('hair', hair, ellipsoid(0.17, 0.1, 0.16, 8, 5), { pos: V(0, 1.53, -0.01) });
		b.add('hair', C('fito_headband', 0xc8ff2a, { emissive: 0x2a3a00 }), new THREE.CylinderGeometry(0.205, 0.205, 0.05, 12, 1, true), { pos: V(0, 1.42, 0.02) });
		wristbands(b, stripe);
		whistle(b);
		return b.build();
	},
	// Lula, the receptionist: a purple tracksuit with white stripes on the sleeves, a high ponytail and a headset.
	npc_lula() {
		const b = new Builder('npc_lula');
		const suit = C('lula_suit', 0x7a3fc8), stripe = C('lula_stripe', 0xf6f4ee);
		pearBody(b, C('skin_crema', 0xf3d2b0), { shirt: suit, pants: suit, shoes: C('lula_shoes', 0xff9d3f), belted: false, onePiece: true });
		for (const s of [-1, 1]) limb(b, 'arms', stripe, V(s * 0.31, 0.88, 0.01), V(s * 0.45, 0.72, 0.08), 0.03);
		eyes(b, 1.34, 0.17, 0.08, 0.05);
		mouth(b);
		const hair = C('lula_hair', 0xd89a3a);
		b.add('hair', hair, ellipsoid(0.21, 0.13, 0.2, 10, 6), { pos: V(0, 1.43, 0.0) });
		b.add('hair', hair, ellipsoid(0.06, 0.06, 0.06, 6, 4), { pos: V(0, 1.58, -0.12) });
		b.add('hair', hair, ellipsoid(0.07, 0.2, 0.07, 6, 5), { pos: V(0, 1.44, -0.25), rot: [0.5, 0, 0] });
		b.add('headset', black, new THREE.TorusGeometry(0.24, 0.014, 4, 14, Math.PI), { pos: V(0, 1.32, 0.0) });
		b.add('headset', black, ellipsoid(0.03, 0.05, 0.04, 6, 4), { pos: V(0.22, 1.3, 0.0) });
		limb(b, 'headset', black, V(0.22, 1.27, 0.03), V(0.08, 1.2, 0.2), 0.008, 4);
		return b.build();
	},
	// The reception's stereo: a big silver boombox with two speakers, a cassette door and a handle.
	gym_stereo() {
		const b = new Builder('gym_stereo');
		const body = C('stereo_silver', 0xb8bcc4, { metalness: 0.4, roughness: 0.4 });
		b.add('box', body, new THREE.BoxGeometry(0.8, 0.4, 0.22), { pos: V(0, 0.2, 0) });
		for (const s of [-1, 1]) {
			b.add('speakers', black, new THREE.CylinderGeometry(0.14, 0.14, 0.03, 12), { pos: V(s * 0.24, 0.19, 0.115), rot: [Math.PI / 2, 0, 0] });
			b.add('speakers', C('stereo_cone', 0x3a3a44), new THREE.CylinderGeometry(0.05, 0.05, 0.035, 8), { pos: V(s * 0.24, 0.19, 0.12), rot: [Math.PI / 2, 0, 0] });
		}
		b.add('box', C('stereo_tape', 0x2a2a30), new THREE.BoxGeometry(0.18, 0.1, 0.01), { pos: V(0, 0.22, 0.115) });
		for (let i = 0; i < 4; i++) b.add('buttons', i === 0 ? C('stereo_play', 0x3fd06a, { emissive: 0x0a3a14 }) : black, new THREE.BoxGeometry(0.035, 0.025, 0.04), { pos: V(-0.06 + i * 0.04, 0.41, 0.05) });
		b.add('handle', black, new THREE.TorusGeometry(0.2, 0.02, 4, 12, Math.PI), { pos: V(0, 0.4, -0.04) });
		return b.build();
	},
	// The record wall's frame: el profe "lifting 300 kg" (a stick picture), a gold plaque and the hooks for the bar.
	gym_record_wall() {
		const b = new Builder('gym_record_wall');
		b.add('frame', C('record_frame', 0xd8a83a, { metalness: 0.5, roughness: 0.4 }), new THREE.BoxGeometry(1.4, 1.0, 0.04), { pos: V(0, 0.5, 0) });
		b.add('photo', C('record_photo', 0xfff4d8), new THREE.BoxGeometry(1.24, 0.84, 0.01), { pos: V(0, 0.5, 0.025) });
		const ink = C('record_ink', 0xff4fa8);
		b.add('photo', ink, ellipsoid(0.07, 0.08, 0.01, 8, 4), { pos: V(0, 0.66, 0.032) });
		b.add('photo', ink, new THREE.BoxGeometry(0.06, 0.24, 0.01), { pos: V(0, 0.48, 0.032) });
		b.add('photo', black, new THREE.BoxGeometry(0.9, 0.025, 0.01), { pos: V(0, 0.78, 0.034) });
		for (const s of [-1, 1]) {
			b.add('photo', black, new THREE.BoxGeometry(0.05, 0.22, 0.01), { pos: V(s * 0.42, 0.78, 0.034) });
			b.add('photo', ink, new THREE.BoxGeometry(0.03, 0.18, 0.01), { pos: V(s * 0.08, 0.68, 0.032), rot: [0, 0, s * -0.5] });
		}
		b.add('plaque', C('record_plaque', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.BoxGeometry(0.6, 0.12, 0.02), { pos: V(0, -0.12, 0.01) });
		for (const s of [-1, 1]) b.add('hooks', black, new THREE.BoxGeometry(0.04, 0.12, 0.12), { pos: V(s * 0.6, -0.4, 0.06) });
		return b.build();
	},
	// The record bar "300 kg": a long bar with three huge black plates on each end (it's polystyrene, it only looks heavy).
	gym_record_bar() {
		const b = new Builder('gym_record_bar');
		const steel = C('bar_steel', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 }), plate = C('bar_plate', 0x1e1e24);
		b.add('bar', steel, new THREE.CylinderGeometry(0.025, 0.025, 1.8, 8), { pos: V(0, 0, 0), rot: [0, 0, Math.PI / 2] });
		for (const s of [-1, 1]) {
			for (let i = 0; i < 3; i++) b.add('plates', plate, new THREE.CylinderGeometry(0.22 - i * 0.03, 0.22 - i * 0.03, 0.06, 14), { pos: V(s * (0.6 + i * 0.07), 0, 0), rot: [0, 0, Math.PI / 2] });
			b.add('plates', white, new THREE.CylinderGeometry(0.1, 0.1, 0.065, 10), { pos: V(s * 0.6, 0, 0), rot: [0, 0, Math.PI / 2] });
		}
		return b.build();
	},
	// A shop mannequin in a gym tank top: smooth beige pear with no face, the ghost members' stand-in.
	gym_mannequin() {
		const b = new Builder('gym_mannequin');
		const plastic = C('mannequin_plastic', 0xe8d8c0, { roughness: 0.35 });
		pearBody(b, plastic, { shirt: C('mannequin_tank', 0x3fd06a), pants: plastic, shoes: plastic, belted: false });
		b.add('stand', C('mannequin_stand', 0x6a6a70, { metalness: 0.5 }), new THREE.CylinderGeometry(0.25, 0.28, 0.04, 12), { pos: V(0, 0.02, 0.05) });
		return b.build();
	},
	// The silver dumbbells story's main evidence: a giant dumbbell (20 kg) whose hollow plates are stuffed with bills, a
	// few sticking out of the seams. It lies on the floor, its bar along x.
	gym_silver_dumbbell() {
		const b = new Builder('gym_silver_dumbbell');
		const steel = C('bar_steel', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 }), plate = C('silver_plate', 0x2a2a30);
		const bill = C('bill_green', 0x6ab36a);
		b.add('bar', steel, new THREE.CylinderGeometry(0.04, 0.04, 0.9, 10), { pos: V(0, 0.25, 0), rot: [0, 0, Math.PI / 2] });
		for (const s of [-1, 1]) {
			b.add('plates', plate, new THREE.CylinderGeometry(0.25, 0.25, 0.16, 16), { pos: V(s * 0.3, 0.25, 0), rot: [0, 0, Math.PI / 2] });
			b.add('plates', steel, new THREE.CylinderGeometry(0.08, 0.08, 0.17, 10), { pos: V(s * 0.3, 0.25, 0), rot: [0, 0, Math.PI / 2] });
			for (let i = 0; i < 3; i++) {
				const a = i * 2.1 + (s > 0 ? 0.4 : 1.2);
				b.add('bills', bill, new THREE.BoxGeometry(0.02, 0.08, 0.12), { pos: V(s * 0.39, 0.25 + Math.sin(a) * 0.2, Math.cos(a) * 0.2), rot: [a, 0, 0] });
			}
		}
		return b.build();
	},
	// The reception's rigged scale: a platform scale whose dial always says 10 kg less, with a sticker over the needle.
	gym_fake_scale() {
		const b = new Builder('gym_fake_scale');
		const body = C('scale_white', 0xf0f0ec), dial = C('scale_dial', 0xfffbe8);
		b.add('base', body, new THREE.BoxGeometry(0.36, 0.06, 0.36), { pos: V(0, 0.03, 0) });
		b.add('base', C('scale_mat', 0x3a3a44), new THREE.BoxGeometry(0.3, 0.008, 0.26), { pos: V(0, 0.064, 0.03) });
		b.add('dial', body, new THREE.CylinderGeometry(0.08, 0.08, 0.04, 14), { pos: V(0, 0.07, -0.13), rot: [Math.PI / 2 - 0.5, 0, 0] });
		b.add('dial', dial, new THREE.CylinderGeometry(0.065, 0.065, 0.01, 14), { pos: V(0, 0.08, -0.115), rot: [Math.PI / 2 - 0.5, 0, 0] });
		b.add('sticker', C('scale_sticker', 0xff4fa8), new THREE.BoxGeometry(0.06, 0.012, 0.03), { pos: V(0, 0.09, -0.105), rot: [-0.5, 0, 0.3] });
		return b.build();
	},
	// The "special quotas" sheet: a list of names with huge amounts next to each, and a gold star on top.
	gym_quota_sheet() {
		const b = new Builder('gym_quota_sheet');
		b.add('paper', C('sheet_paper', 0xfaf6ea), new THREE.BoxGeometry(0.21, 0.004, 0.29), { pos: V(0, 0.002, 0) });
		const ink = C('sheet_ink', 0x2a2a30);
		for (let i = 0; i < 8; i++) {
			b.add('lines', ink, new THREE.BoxGeometry(0.09, 0.002, 0.008), { pos: V(-0.045, 0.005, -0.09 + i * 0.026) });
			b.add('lines', C('sheet_money', 0x3a9a4a), new THREE.BoxGeometry(0.05, 0.002, 0.008), { pos: V(0.06, 0.005, -0.09 + i * 0.026) });
		}
		b.add('star', C('sheet_star', 0xf2c84b), new THREE.CylinderGeometry(0.025, 0.025, 0.003, 5), { pos: V(0, 0.005, -0.12) });
		return b.build();
	},
	// The fake record's doctored photo: el profe's head glued over a strongman's body, the cut line in white tape.
	gym_record_photo() {
		const b = new Builder('gym_record_photo');
		b.add('paper', C('photo_paper', 0xfff4d8), new THREE.BoxGeometry(0.2, 0.004, 0.15), { pos: V(0, 0.002, 0) });
		b.add('print', C('photo_strongman', 0x7a5a3a), new THREE.BoxGeometry(0.07, 0.002, 0.08), { pos: V(0, 0.005, 0.025) });
		b.add('print', C('fito_hair', 0x3a2414), new THREE.CylinderGeometry(0.025, 0.025, 0.002, 10), { pos: V(0, 0.006, -0.035) });
		b.add('print', black, new THREE.BoxGeometry(0.16, 0.002, 0.01), { pos: V(0, 0.006, 0.0) });
		b.add('tape', white, new THREE.BoxGeometry(0.09, 0.003, 0.012), { pos: V(0, 0.007, -0.012), rot: [0, 0.2, 0] });
		return b.build();
	},
	// The record contest's certificate: a gold-bordered sheet with a red seal and a ribbon.
	gym_record_certificate() {
		const b = new Builder('gym_record_certificate');
		b.add('paper', C('cert_gold', 0xe0b84a), new THREE.BoxGeometry(0.3, 0.003, 0.22), { pos: V(0, 0.0015, 0) });
		b.add('paper', C('sheet_paper', 0xfaf6ea), new THREE.BoxGeometry(0.27, 0.004, 0.19), { pos: V(0, 0.002, 0) });
		for (let i = 0; i < 4; i++) b.add('lines', C('sheet_ink', 0x2a2a30), new THREE.BoxGeometry(0.16, 0.002, 0.008), { pos: V(0, 0.005, -0.06 + i * 0.03) });
		b.add('seal', C('cert_seal', 0xc83a3a), new THREE.CylinderGeometry(0.03, 0.03, 0.006, 12), { pos: V(0.09, 0.006, 0.06) });
		b.add('seal', C('cert_ribbon', 0x3a6ad8), new THREE.BoxGeometry(0.015, 0.003, 0.05), { pos: V(0.09, 0.005, 0.09), rot: [0, 0.3, 0] });
		return b.build();
	},
	// The ghost members' binder: a fat green ring binder, "SOCIOS" on the spine and pages sticking out.
	gym_members_binder() {
		const b = new Builder('gym_members_binder');
		const cover = C('binder_green', 0x3fa05a);
		b.add('cover', cover, new THREE.BoxGeometry(0.26, 0.012, 0.32), { pos: V(0, 0.006, 0) });
		b.add('cover', cover, new THREE.BoxGeometry(0.26, 0.012, 0.32), { pos: V(0, 0.094, 0) });
		b.add('cover', cover, new THREE.BoxGeometry(0.012, 0.1, 0.32), { pos: V(-0.125, 0.05, 0) });
		b.add('pages', C('sheet_paper', 0xfaf6ea), new THREE.BoxGeometry(0.24, 0.076, 0.3), { pos: V(0.005, 0.05, 0) });
		b.add('label', white, new THREE.BoxGeometry(0.004, 0.04, 0.14), { pos: V(-0.133, 0.05, 0) });
		for (let i = 0; i < 5; i++) b.add('tabs', C('binder_tab', [0xff4fa8, 0xf2c84b, 0x3fe0ff][i % 3]), new THREE.BoxGeometry(0.02, 0.004, 0.03), { pos: V(0.13, 0.02 + i * 0.015, -0.1 + i * 0.05) });
		return b.build();
	},
	// A cardboard box of shop dummies: two plastic arms and a bald head sticking out, and a green tank top on the flap.
	gym_dummy_box() {
		const b = new Builder('gym_dummy_box');
		const card = C('box_card', 0xc89a5a), plastic = C('mannequin_plastic', 0xe8d8c0, { roughness: 0.35 });
		b.add('box', card, new THREE.BoxGeometry(0.6, 0.4, 0.4), { pos: V(0, 0.2, 0) });
		b.add('box', card, new THREE.BoxGeometry(0.6, 0.01, 0.2), { pos: V(0, 0.42, 0.28), rot: [0.6, 0, 0] });
		b.add('head', plastic, ellipsoid(0.1, 0.12, 0.1, 8, 6), { pos: V(-0.12, 0.44, 0) });
		limb(b, 'arms', plastic, V(0.1, 0.35, 0.05), V(0.22, 0.62, 0.1), 0.035);
		limb(b, 'arms', plastic, V(0.15, 0.35, -0.08), V(0.3, 0.55, -0.15), 0.035);
		b.add('tank', C('mannequin_tank', 0x3fd06a), new THREE.BoxGeometry(0.18, 0.012, 0.14), { pos: V(0.05, 0.47, 0.32), rot: [0.6, 0, 0.1] });
		return b.build();
	},
	// The fake gym stamp: a wooden handle on a rubber block, with a pink ink pad.
	gym_fake_stamp() {
		const b = new Builder('gym_fake_stamp');
		b.add('pad', C('stamp_pad', 0x2a2a30), new THREE.BoxGeometry(0.12, 0.02, 0.08), { pos: V(0.09, 0.01, 0) });
		b.add('pad', C('stamp_ink', 0xff4fa8), new THREE.BoxGeometry(0.1, 0.004, 0.06), { pos: V(0.09, 0.022, 0) });
		b.add('block', C('stamp_rubber', 0x6a4a3a), new THREE.BoxGeometry(0.07, 0.025, 0.05), { pos: V(-0.06, 0.0125, 0) });
		b.add('handle', C('stamp_wood', 0xb07a3a), new THREE.CylinderGeometry(0.015, 0.02, 0.07, 8), { pos: V(-0.06, 0.06, 0) });
		b.add('handle', C('stamp_wood', 0xb07a3a), ellipsoid(0.025, 0.02, 0.025, 8, 5), { pos: V(-0.06, 0.1, 0) });
		return b.build();
	},
	// The power treadmills' main evidence: a grey junction box with a thick black cable coiled on top, its end clamped
	// with a yellow "danger" tag.
	gym_cable_box() {
		const b = new Builder('gym_cable_box');
		b.add('box', C('cable_box_grey', 0x8a8f96, { metalness: 0.3 }), new THREE.BoxGeometry(0.45, 0.3, 0.3), { pos: V(0, 0.15, 0) });
		b.add('box', C('cable_box_lid', 0x6a6f76, { metalness: 0.3 }), new THREE.BoxGeometry(0.47, 0.03, 0.32), { pos: V(0, 0.31, 0) });
		for (let i = 0; i < 3; i++) b.add('cable', black, new THREE.TorusGeometry(0.13 - i * 0.02, 0.022, 6, 16), { pos: V(0, 0.35 + i * 0.035, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('cable', black, new THREE.CylinderGeometry(0.022, 0.022, 0.3, 6), { pos: V(0.28, 0.2, 0), rot: [0, 0, 0.6] });
		b.add('tag', C('danger_yellow', 0xf2d24a), new THREE.BoxGeometry(0.08, 0.06, 0.005), { pos: V(0.36, 0.1, 0.03) });
		b.add('tag', black, new THREE.BoxGeometry(0.03, 0.03, 0.006), { pos: V(0.36, 0.1, 0.033), rot: [0, 0, Math.PI / 4] });
		return b.build();
	},
	// The power meter turned upside down: a meter box with its dial on the bottom and a few loose wires.
	gym_power_meter() {
		const b = new Builder('gym_power_meter');
		b.add('box', C('meter_cream', 0xe8e2d0), new THREE.BoxGeometry(0.22, 0.3, 0.14), { pos: V(0, 0.15, 0) });
		b.add('dial', C('meter_glass', 0xbfe3f2, { roughness: 0.1 }), new THREE.CylinderGeometry(0.07, 0.07, 0.02, 14), { pos: V(0, 0.08, 0.07), rot: [Math.PI / 2, 0, 0] });
		b.add('dial', C('meter_needle', 0xc83a3a), new THREE.BoxGeometry(0.06, 0.008, 0.004), { pos: V(0, 0.08, 0.082), rot: [0, 0, 2.6] });
		for (const [x, c] of [[-0.05, 0xc83a3a], [0, 0x3a6ad8], [0.05, 0xf2d24a]]) limb(b, 'wires', C('wire_' + c.toString(16), c), V(x, 0.3, 0), V(x * 2, 0.38, 0.05), 0.008, 4);
		return b.build();
	},
	// The wiring plan: a blueprint with white lines from the gym to the plant next door.
	gym_wiring_plan() {
		const b = new Builder('gym_wiring_plan');
		b.add('paper', C('blueprint', 0x2a5aa8), new THREE.BoxGeometry(0.3, 0.004, 0.21), { pos: V(0, 0.002, 0) });
		b.add('lines', white, new THREE.BoxGeometry(0.06, 0.002, 0.05), { pos: V(-0.09, 0.005, 0) });
		b.add('lines', white, new THREE.BoxGeometry(0.06, 0.002, 0.07), { pos: V(0.09, 0.005, 0) });
		b.add('lines', C('plan_red', 0xff5a4a), new THREE.BoxGeometry(0.12, 0.002, 0.006), { pos: V(0, 0.006, 0) });
		return b.build();
	},
	// The lucky shakes' main evidence: a big jar of green "champion" shake powder with a gold trophy on the label.
	gym_shake_jar() {
		const b = new Builder('gym_shake_jar');
		b.add('jar', C('jar_glass', 0xbfe3d0, { roughness: 0.1 }), new THREE.CylinderGeometry(0.1, 0.1, 0.24, 14), { pos: V(0, 0.12, 0) });
		b.add('powder', C('shake_green', 0x5ac85a), new THREE.CylinderGeometry(0.09, 0.09, 0.16, 14), { pos: V(0, 0.09, 0) });
		b.add('lid', C('jar_lid', 0xf2c84b, { metalness: 0.5 }), new THREE.CylinderGeometry(0.105, 0.105, 0.04, 14), { pos: V(0, 0.26, 0) });
		b.add('label', white, new THREE.CylinderGeometry(0.102, 0.102, 0.08, 14, 1, true), { pos: V(0, 0.12, 0) });
		b.add('label', C('trophy_gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.BoxGeometry(0.04, 0.05, 0.01), { pos: V(0, 0.12, 0.1) });
		return b.build();
	},
	// The list of members who won the lottery: a sheet with a column of ticks and clovers.
	gym_lottery_list() {
		const b = new Builder('gym_lottery_list');
		b.add('paper', C('sheet_paper', 0xfaf6ea), new THREE.BoxGeometry(0.21, 0.004, 0.29), { pos: V(0, 0.002, 0) });
		for (let i = 0; i < 7; i++) {
			b.add('lines', C('sheet_ink', 0x2a2a30), new THREE.BoxGeometry(0.11, 0.002, 0.008), { pos: V(-0.03, 0.005, -0.1 + i * 0.03) });
			b.add('clovers', C('clover_green', 0x2a9a3a), new THREE.CylinderGeometry(0.008, 0.008, 0.002, 4), { pos: V(0.07, 0.005, -0.1 + i * 0.03) });
		}
		return b.build();
	},
	// The golden blender: a shiny gold base with a glass jug full of green shake.
	gym_gold_blender() {
		const b = new Builder('gym_gold_blender');
		const gold = C('blender_gold', 0xf2c03a, { metalness: 0.3, roughness: 0.3, emissive: 0x3a2a05 });
		b.add('base', gold, new THREE.BoxGeometry(0.18, 0.12, 0.18), { pos: V(0, 0.06, 0) });
		b.add('jug', C('jar_glass', 0xbfe3d0, { roughness: 0.1 }), new THREE.CylinderGeometry(0.08, 0.06, 0.22, 12), { pos: V(0, 0.23, 0) });
		b.add('jug', C('shake_green', 0x5ac85a), new THREE.CylinderGeometry(0.07, 0.055, 0.12, 12), { pos: V(0, 0.19, 0) });
		b.add('lid', gold, new THREE.CylinderGeometry(0.085, 0.085, 0.02, 12), { pos: V(0, 0.35, 0) });
		b.add('knob', black, new THREE.CylinderGeometry(0.02, 0.02, 0.02, 8), { pos: V(0, 0.06, 0.095), rot: [Math.PI / 2, 0, 0] });
		return b.build();
	},
	// The reception's shake cup: a tall plastic cup of green shake, a straw and a four-leaf clover sticker.
	gym_shake_cup() {
		const b = new Builder('gym_shake_cup');
		b.add('cup', C('cup_plastic', 0xf6f4ee, { roughness: 0.3 }), new THREE.CylinderGeometry(0.045, 0.035, 0.16, 12), { pos: V(0, 0.08, 0) });
		b.add('shake', C('shake_green', 0x5ac85a), new THREE.CylinderGeometry(0.042, 0.042, 0.01, 12), { pos: V(0, 0.15, 0) });
		b.add('straw', C('straw_pink', 0xff4fa8), new THREE.CylinderGeometry(0.006, 0.006, 0.14, 6), { pos: V(0.015, 0.2, 0), rot: [0, 0, -0.25] });
		const clover = C('clover_green', 0x2a9a3a);
		for (let i = 0; i < 4; i++) {
			const a = i * Math.PI / 2;
			b.add('clover', clover, new THREE.CylinderGeometry(0.012, 0.012, 0.004, 8), { pos: V(Math.cos(a) * 0.012, 0.08 + Math.sin(a) * 0.012, 0.043), rot: [Math.PI / 2, 0, 0] });
		}
		return b.build();
	},
};

export { models };
export const views = {
	gym_raid_people: {
		items: [{ name: 'npc_profe_fito', pos: [-0.7, 0, 0], rotY: 0.35, scale: 0.95 }, { name: 'npc_lula', pos: [0.7, 0, 0], rotY: -0.35 }],
		cam: { pos: [0, 1.3, 4.2], target: [0, 0.8, 0], fov: 34 },
	},
	gym_raid_people_back: {
		items: [{ name: 'npc_profe_fito', pos: [-0.7, 0, 0], rotY: Math.PI - 0.5, scale: 0.95 }, { name: 'npc_lula', pos: [0.7, 0, 0], rotY: Math.PI + 0.5 }],
		cam: { pos: [0, 1.3, 4.2], target: [0, 0.8, 0], fov: 34 },
	},
	gym_raid_props: {
		items: [{ name: 'gym_stereo', pos: [-1.3, 0, 0.6], rotY: 0.3 }, { name: 'gym_record_wall', pos: [0, 0.9, -0.3] },
			{ name: 'gym_record_bar', pos: [0, 0.4, 0.1] }, { name: 'gym_mannequin', pos: [1.5, 0, 0.2], rotY: -0.4 }],
		cam: { pos: [0, 1.4, 5.2], target: [0, 0.8, 0], fov: 38 },
	},
	gym_silver_dumbbells: {
		items: [{ name: 'gym_silver_dumbbell', pos: [-0.25, 0, 0], rotY: 0.4 }, { name: 'gym_fake_scale', pos: [0.55, 0, 0.2], rotY: -0.3 },
			{ name: 'gym_quota_sheet', pos: [0.5, 0, -0.35], rotY: 0.2 }],
		cam: { pos: [0.3, 1.1, 1.9], target: [0.1, 0.2, 0], fov: 40 },
	},
	gym_fake_record: {
		items: [{ name: 'gym_record_bar', pos: [0, 0.22, 0] }, { name: 'gym_record_photo', pos: [-0.3, 0, 0.45], rotY: 0.3 },
			{ name: 'gym_record_certificate', pos: [0.3, 0, 0.45], rotY: -0.2 }],
		cam: { pos: [0, 1.2, 1.9], target: [0, 0.15, 0.2], fov: 45 },
	},
	gym_ghost_members: {
		items: [{ name: 'gym_members_binder', pos: [-0.45, 0, 0.1], rotY: 0.3 }, { name: 'gym_dummy_box', pos: [0.1, 0, -0.1], rotY: -0.2 },
			{ name: 'gym_fake_stamp', pos: [0.55, 0, 0.25], rotY: 0.4 }],
		cam: { pos: [0.1, 1.0, 1.7], target: [0.05, 0.2, 0], fov: 42 },
	},
	gym_power_treadmills: {
		items: [{ name: 'gym_cable_box', pos: [-0.35, 0, 0], rotY: 0.3 }, { name: 'gym_power_meter', pos: [0.35, 0, -0.1], rotY: -0.3 },
			{ name: 'gym_wiring_plan', pos: [0.3, 0, 0.35], rotY: 0.2 }],
		cam: { pos: [0, 1.0, 1.6], target: [0, 0.2, 0], fov: 42 },
	},
	gym_lucky_shakes: {
		items: [{ name: 'gym_shake_jar', pos: [-0.3, 0, 0] }, { name: 'gym_gold_blender', pos: [0.05, 0, -0.1] },
			{ name: 'gym_shake_cup', pos: [0.3, 0, 0.1] }, { name: 'gym_lottery_list', pos: [0.05, 0, 0.3], rotY: 0.2 }],
		cam: { pos: [0, 0.7, 1.1], target: [0, 0.12, 0], fov: 42 },
	},
};
