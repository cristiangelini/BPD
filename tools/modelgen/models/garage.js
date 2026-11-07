// Props of the garage "El Pistón Feliz" (docs/diseno/allanamiento-taller.md): the two-post car lift, the oil drum,
// the counter's service bell and the tool wall's pegboard, with origins at the floor (or the back, for the pegboard)
// in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

// A two-post car lift 3.2 m wide and 3.4 m tall: yellow posts on base plates, a beam across the top and the control
// box with its two buttons. The arms that ride up and down with the car are garage_lift_arms.
export function buildLift() {
	const b = new Builder('garage_lift');
	const yellow = mat('lift_yellow', 0xf2c230), dark = mat('lift_dark', 0x35363a);
	for (const s of [-1, 1]) {
		b.add('plate', dark, new THREE.BoxGeometry(0.5, 0.04, 0.5), { pos: V(s * 1.6, 0.02, 0) });
		b.add('post', yellow, new THREE.BoxGeometry(0.22, 3.4, 0.28), { pos: V(s * 1.6, 1.7, 0) });
	}
	b.add('beam', yellow, new THREE.BoxGeometry(3.4, 0.18, 0.22), { pos: V(0, 3.35, 0) });
	b.add('control', mat('lift_box', 0x3a6ad2), new THREE.BoxGeometry(0.2, 0.3, 0.12), { pos: V(-1.6, 1.2, 0.2) });
	b.add('button_up', mat('lift_green', 0x3ac24a), new THREE.CylinderGeometry(0.03, 0.03, 0.03, 8), { pos: V(-1.6, 1.27, 0.27), rot: [Math.PI / 2, 0, 0] });
	b.add('button_down', mat('lift_red', 0xd23a3a), new THREE.CylinderGeometry(0.03, 0.03, 0.03, 8), { pos: V(-1.6, 1.15, 0.27), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The lift's two carriages with their arms and pads, origin at the arms' height in the middle of the lift.
export function buildLiftArms() {
	const b = new Builder('garage_lift_arms');
	const yellow = mat('lift_yellow', 0xf2c230), dark = mat('lift_dark', 0x35363a), pad = mat('lift_pad', 0x1e1e20);
	for (const s of [-1, 1]) {
		b.add('carriage', dark, new THREE.BoxGeometry(0.3, 0.4, 0.34), { pos: V(s * 1.6, 0.1, 0) });
		for (const z of [-1, 1]) {
			b.add('arm', yellow, new THREE.BoxGeometry(0.7, 0.08, 0.1), { pos: V(s * 1.2, 0, z * 0.55), rot: [0, s * z * 0.5, 0] });
			b.add('pad', pad, new THREE.CylinderGeometry(0.08, 0.08, 0.05, 10), { pos: V(s * 0.9, 0.06, z * 0.75) });
		}
	}
	return b.build();
}

// Don Tuerca, the mechanic: short and wide, a blue overall smeared with grease, a red cap turned backwards, a big
// oily mustache and a wrench in his right hand. The game scales him wide and short.
export function buildDonTuerca() {
	const b = new Builder('npc_don_tuerca');
	const overall = mat('tuerca_overall', 0x2f58a8), grease = mat('tuerca_grease', 0x26262a);
	pearBody(b, mat('skin_arena', 0xd9a06b), { shirt: overall, pants: overall, shoes: M.black, belted: false, onePiece: true });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	for (const [x, y, z, r] of [[0.25, 0.4, 0.33, 0.07], [-0.3, 0.62, 0.3, 0.06], [0.12, 0.85, 0.27, 0.05], [-0.1, 0.25, 0.36, 0.05]]) {
		b.add('body', grease, ellipsoid(r, r * 0.8, 0.02, 6, 4), { pos: V(x, y, z) });
	}
	const cap = mat('tuerca_cap', 0xd8302a);
	b.add('cap', cap, ellipsoid(0.205, 0.1, 0.2, 10, 5), { pos: V(0, 1.45, 0.02) });
	b.add('cap', cap, new THREE.BoxGeometry(0.2, 0.02, 0.16), { pos: V(0, 1.42, -0.22), rot: [0.15, 0, 0] });
	const tash = mat('tuerca_mustache', 0x1a1410);
	for (const s of [-1, 1]) b.add('mustache', tash, ellipsoid(0.07, 0.025, 0.03, 6, 4), { pos: V(s * 0.06, 1.24, 0.2), rot: [0, 0, s * -0.3] });
	const steel = mat('wrench_steel', 0xb0b4ba, { metalness: 0.6, roughness: 0.35 });
	b.add('wrench', steel, new THREE.BoxGeometry(0.04, 0.32, 0.02), { pos: V(0.5, 0.55, 0.12) });
	b.add('wrench', steel, new THREE.TorusGeometry(0.04, 0.015, 4, 8, Math.PI * 1.5), { pos: V(0.5, 0.39, 0.12) });
	return b.build();
}

// A 200 l oil drum 0.6 m across and 0.9 m tall, blue with two ribs, a dented top and a dribble of oil.
export function buildOilDrum() {
	const b = new Builder('oil_drum');
	const blue = mat('drum_blue', 0x2f5fa8), rib = mat('drum_rib', 0x234a86), top = mat('drum_top', 0x5a6670);
	b.add('body', blue, new THREE.CylinderGeometry(0.3, 0.3, 0.9, 16), { pos: V(0, 0.45, 0) });
	for (const y of [0.3, 0.6]) b.add('rib', rib, new THREE.TorusGeometry(0.302, 0.012, 4, 20), { pos: V(0, y, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('top', top, new THREE.CylinderGeometry(0.29, 0.29, 0.01, 16), { pos: V(0, 0.905, 0) });
	b.add('cap', top, new THREE.CylinderGeometry(0.04, 0.04, 0.03, 8), { pos: V(0.15, 0.92, 0.05) });
	b.add('oil', mat('oil_black', 0x141416), new THREE.BoxGeometry(0.06, 0.4, 0.01), { pos: V(0.12, 0.7, 0.297) });
	return b.build();
}

// The counter's service bell, 0.1 m across: a gold dome on a black base with the plunger on top.
export function buildServiceBell() {
	const b = new Builder('service_bell');
	const gold = mat('bell_gold', 0xe2b84a);
	b.add('base', mat('bell_base', 0x26262a), new THREE.CylinderGeometry(0.06, 0.065, 0.02, 14), { pos: V(0, 0.01, 0) });
	b.add('dome', gold, new THREE.SphereGeometry(0.05, 14, 8, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(0, 0.02, 0) });
	b.add('plunger', gold, new THREE.CylinderGeometry(0.008, 0.008, 0.03, 6), { pos: V(0, 0.08, 0) });
	b.add('knob', gold, new THREE.SphereGeometry(0.012, 8, 6), { pos: V(0, 0.096, 0) });
	return b.build();
}

// The tool wall's pegboard, 3.0 × 1.4 m, its back at z = 0 and its face to +Z: brown board, a grid of holes and the
// painted outlines where each of the 8 tools hangs.
export function buildToolBoard() {
	const b = new Builder('tool_board');
	const board = mat('peg_board', 0xa8743e), hole = mat('peg_hole', 0x5a3a1e), outline = mat('peg_outline', 0xf2f2ea);
	b.add('board', board, new THREE.BoxGeometry(3.0, 1.4, 0.03), { pos: V(0, 0.7, 0.015) });
	for (let i = 0; i < 14; i++) for (let j = 0; j < 6; j++) {
		b.add('hole', hole, new THREE.CylinderGeometry(0.008, 0.008, 0.005, 5), { pos: V(-1.4 + i * 0.215, 0.12 + j * 0.23, 0.032), rot: [Math.PI / 2, 0, 0] });
	}
	for (let i = 0; i < 8; i++) {
		const x = -1.31 + i * 0.375, tall = i % 2 === 0;
		b.add('outline', outline, new THREE.BoxGeometry(0.12, tall ? 0.42 : 0.3, 0.004), { pos: V(x, 0.75, 0.033) });
	}
	return b.build();
}

// A used tire lying flat, 0.76 m across and 0.24 m thick, with a grey rim showing in the hole.
export function buildGarageTire() {
	const b = new Builder('garage_tire');
	b.add('tire', mat('tire_rubber', 0x1c1c1e), new THREE.TorusGeometry(0.27, 0.12, 8, 18), { pos: V(0, 0.12, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('tread', mat('tire_tread', 0x2a2a2c), new THREE.CylinderGeometry(0.385, 0.385, 0.14, 18, 1, true), { pos: V(0, 0.12, 0) });
	b.add('rim', mat('tire_rim', 0x8a8e94), new THREE.CylinderGeometry(0.17, 0.17, 0.02, 12, 1, true), { pos: V(0, 0.12, 0) });
	return b.build();
}

// Grasita, the apprentice: thin and young, an orange overall too big for him with the sleeves rolled up, a grease
// smudge on his nose and cheek, messy hair and a rag hanging from his pocket.
export function buildGrasita() {
	const b = new Builder('npc_grasita');
	const overall = mat('grasita_overall', 0xe8742a), grease = mat('tuerca_grease', 0x26262a);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: overall, pants: overall, shoes: M.black, belted: false, onePiece: true });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	b.add('face', grease, ellipsoid(0.04, 0.02, 0.02, 6, 4), { pos: V(0, 1.27, 0.21) });
	b.add('face', grease, ellipsoid(0.04, 0.03, 0.02, 6, 4), { pos: V(0.12, 1.24, 0.16) });
	const hair = mat('grasita_hair', 0x2a1a10);
	for (let i = 0; i < 9; i++) {
		const a = (i / 9) * Math.PI * 2;
		b.add('hair', hair, ellipsoid(0.07, 0.1, 0.07, 6, 4), { pos: V(Math.cos(a) * 0.12, 1.5, Math.sin(a) * 0.1), rot: [Math.sin(a) * 0.5, 0, Math.cos(a) * 0.5] });
	}
	b.add('hair', hair, ellipsoid(0.19, 0.1, 0.18, 8, 5), { pos: V(0, 1.45, 0) });
	b.add('rag', mat('grasita_rag', 0xd23a3a), new THREE.BoxGeometry(0.12, 0.18, 0.02), { pos: V(0.25, 0.42, 0.33), rot: [0, 0.4, 0.1] });
	return b.build();
}

// The 8 tools of the tool wall, lying flat along x with origin at their middle: Grasita asks for them by name.
const steel = () => mat('tool_chrome', 0xb8bcc4, { metalness: 0.5, roughness: 0.35 });
const toolModels = {
	garage_spanner_13() {
		const b = new Builder('garage_spanner_13');
		b.add('handle', steel(), new THREE.BoxGeometry(0.2, 0.012, 0.025), { pos: V(0, 0, 0) });
		for (const s of [-1, 1]) b.add('jaw', steel(), new THREE.TorusGeometry(0.025, 0.008, 4, 8, Math.PI * 1.6), { pos: V(s * 0.115, 0, 0), rot: [Math.PI / 2, 0, s > 0 ? 0 : Math.PI] });
		b.add('mark', mat('tool_mark', 0x26262a), new THREE.BoxGeometry(0.03, 0.002, 0.012), { pos: V(0.02, 0.007, 0) });
		return b.build();
	},
	garage_adjustable_wrench() {
		const b = new Builder('garage_adjustable_wrench');
		b.add('handle', mat('wrench_red', 0xd23a3a), new THREE.BoxGeometry(0.22, 0.02, 0.035), { pos: V(-0.03, 0, 0) });
		for (const s of [-1, 1]) b.add('jaw', steel(), new THREE.BoxGeometry(0.06, 0.022, 0.02), { pos: V(0.11, 0, s * 0.03) });
		return b.build();
	},
	garage_hammer() {
		const b = new Builder('garage_hammer');
		b.add('handle', mat('tool_wood', 0xc8945a), new THREE.BoxGeometry(0.3, 0.028, 0.032), { pos: V(-0.02, 0, 0) });
		b.add('head', steel(), new THREE.BoxGeometry(0.045, 0.04, 0.13), { pos: V(0.13, 0.004, 0) });
		return b.build();
	},
	garage_screwdriver() {
		const b = new Builder('garage_screwdriver');
		b.add('handle', mat('handle_blue_tool', 0x3a6ad2), new THREE.CylinderGeometry(0.018, 0.018, 0.1, 6), { pos: V(-0.07, 0, 0), rot: [0, 0, Math.PI / 2] });
		b.add('shaft', steel(), new THREE.CylinderGeometry(0.005, 0.005, 0.15, 4), { pos: V(0.055, 0, 0), rot: [0, 0, Math.PI / 2] });
		b.add('tip', steel(), new THREE.BoxGeometry(0.02, 0.012, 0.012), { pos: V(0.135, 0, 0), rot: [Math.PI / 4, 0, 0] });
		return b.build();
	},
	garage_pliers() {
		const b = new Builder('garage_pliers');
		const grip = mat('pliers_grip', 0xf2c230);
		for (const s of [-1, 1]) {
			b.add('grip', grip, new THREE.BoxGeometry(0.14, 0.018, 0.022), { pos: V(-0.05, 0, s * 0.025), rot: [0, s * 0.18, 0] });
			b.add('jaw', steel(), new THREE.BoxGeometry(0.08, 0.016, 0.014), { pos: V(0.07, 0, s * 0.008), rot: [0, -s * 0.1, 0] });
		}
		b.add('pivot', steel(), new THREE.CylinderGeometry(0.014, 0.014, 0.024, 8), { pos: V(0.025, 0, 0) });
		return b.build();
	},
	garage_oil_can() {
		const b = new Builder('garage_oil_can');
		b.add('body', mat('oilcan_green', 0x3a8a4a), new THREE.CylinderGeometry(0.06, 0.07, 0.1, 10), { pos: V(-0.04, 0.05, 0) });
		b.add('spout', steel(), new THREE.CylinderGeometry(0.006, 0.012, 0.16, 6), { pos: V(0.06, 0.13, 0), rot: [0, 0, -1.0] });
		return b.build();
	},
	garage_tire_iron() {
		const b = new Builder('garage_tire_iron');
		b.add('bar', mat('iron_black', 0x2a2a2e), new THREE.CylinderGeometry(0.01, 0.01, 0.4, 6), { pos: V(0, 0, 0), rot: [0, 0, Math.PI / 2] });
		b.add('bar', mat('iron_black', 0x2a2a2e), new THREE.CylinderGeometry(0.01, 0.01, 0.4, 6), { pos: V(0, 0, 0), rot: [Math.PI / 2, 0, 0] });
		for (const [x, z] of [[0.2, 0], [-0.2, 0], [0, 0.2], [0, -0.2]]) b.add('socket', steel(), new THREE.CylinderGeometry(0.018, 0.018, 0.04, 6), { pos: V(x, 0, z), rot: x ? [0, 0, Math.PI / 2] : [Math.PI / 2, 0, 0] });
		return b.build();
	},
	garage_flashlight() {
		const b = new Builder('garage_flashlight');
		b.add('body', mat('flash_yellow', 0xf2c230), new THREE.CylinderGeometry(0.02, 0.02, 0.18, 8), { pos: V(-0.02, 0, 0), rot: [0, 0, Math.PI / 2] });
		b.add('head', mat('flash_black', 0x26262a), new THREE.CylinderGeometry(0.035, 0.022, 0.05, 10), { pos: V(0.09, 0, 0), rot: [0, 0, Math.PI / 2] });
		b.add('lens', mat('flash_lens', 0xf8f4d0, { emissive: 0x3a3a20 }), new THREE.CylinderGeometry(0.032, 0.032, 0.005, 10), { pos: V(0.117, 0, 0), rot: [0, 0, Math.PI / 2] });
		return b.build();
	},
};

// The swapped plates story: a wooden crate stuffed with 40 license plates, the list of stolen cars and the spray can.
const plateColors = [0xf2f2ea, 0xf2d24a, 0xf2f2ea, 0x9ad0f2];
export function buildPlatesBox() {
	const b = new Builder('garage_plates_box');
	const wood = mat('crate_wood', 0xb07a44);
	b.add('box', wood, new THREE.BoxGeometry(0.6, 0.04, 0.4), { pos: V(0, 0.02, 0) });
	for (const s of [-1, 1]) {
		b.add('box', wood, new THREE.BoxGeometry(0.6, 0.26, 0.03), { pos: V(0, 0.13, s * 0.185) });
		b.add('box', wood, new THREE.BoxGeometry(0.03, 0.26, 0.4), { pos: V(s * 0.285, 0.13, 0) });
	}
	for (let i = 0; i < 9; i++) {
		b.add('plates', mat('plate_' + (i % 4), plateColors[i % 4]), new THREE.BoxGeometry(0.02, 0.15, 0.34), { pos: V(-0.24 + i * 0.06, 0.25 + (i % 3) * 0.02, 0), rot: [0, 0, (i % 2 ? 1 : -1) * 0.12] });
		b.add('digits', mat('plate_ink', 0x26262a), new THREE.BoxGeometry(0.022, 0.04, 0.22), { pos: V(-0.24 + i * 0.06, 0.27 + (i % 3) * 0.02, 0), rot: [0, 0, (i % 2 ? 1 : -1) * 0.12] });
	}
	return b.build();
}

export function buildStolenList() {
	const b = new Builder('garage_stolen_list');
	b.add('paper', mat('sheet_paper', 0xfaf6ea), new THREE.BoxGeometry(0.21, 0.004, 0.29), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 9; i++) {
		b.add('lines', mat('sheet_ink', 0x2a2a30), new THREE.BoxGeometry(0.12, 0.002, 0.008), { pos: V(-0.02, 0.005, -0.11 + i * 0.026) });
		b.add('ticks', mat('list_tick', 0xd23a3a), new THREE.BoxGeometry(0.015, 0.002, 0.015), { pos: V(0.075, 0.005, -0.11 + i * 0.026), rot: [0, 0.8, 0] });
	}
	return b.build();
}

export function buildSprayCan() {
	const b = new Builder('garage_spray_can');
	b.add('can', mat('spray_green', 0x2fa84a), new THREE.CylinderGeometry(0.035, 0.035, 0.2, 10), { pos: V(0, 0.1, 0) });
	b.add('cap', mat('spray_cap', 0xf2f2ea), new THREE.CylinderGeometry(0.03, 0.035, 0.04, 10), { pos: V(0, 0.22, 0) });
	b.add('nozzle', mat('flash_black', 0x26262a), new THREE.BoxGeometry(0.015, 0.012, 0.015), { pos: V(0, 0.245, 0.01) });
	b.add('drip', mat('spray_green', 0x2fa84a), new THREE.BoxGeometry(0.01, 0.06, 0.004), { pos: V(0.01, 0.15, 0.035) });
	return b.build();
}

// The magic odometer story: the drill that winds odometers back (a yellow power drill with a little counter on it),
// the notebook with the real kilometers and the cardboard "0 km, one owner" sign.
export function buildOdometerDrill() {
	const b = new Builder('garage_odometer_drill');
	const yellow = mat('drill_yellow', 0xf2c230), black = mat('flash_black', 0x26262a);
	b.add('body', yellow, new THREE.BoxGeometry(0.24, 0.1, 0.08), { pos: V(0, 0.2, 0) });
	b.add('grip', black, new THREE.BoxGeometry(0.06, 0.16, 0.06), { pos: V(-0.06, 0.08, 0), rot: [0, 0, -0.2] });
	b.add('bit', mat('tool_chrome', 0xb8bcc4), new THREE.CylinderGeometry(0.008, 0.008, 0.12, 6), { pos: V(0.18, 0.2, 0), rot: [0, 0, Math.PI / 2] });
	b.add('counter', mat('counter_white', 0xf2f2ea), new THREE.BoxGeometry(0.1, 0.04, 0.005), { pos: V(0.02, 0.21, 0.042) });
	for (let i = 0; i < 4; i++) b.add('digits', black, new THREE.BoxGeometry(0.014, 0.022, 0.002), { pos: V(-0.015 + i * 0.022, 0.21, 0.046) });
	b.add('battery', black, new THREE.BoxGeometry(0.09, 0.04, 0.08), { pos: V(-0.08, 0.02, 0) });
	return b.build();
}

export function buildKmNotebook() {
	const b = new Builder('garage_km_notebook');
	b.add('cover', mat('notebook_blue', 0x2f58a8), new THREE.BoxGeometry(0.15, 0.015, 0.21), { pos: V(0, 0.0075, 0) });
	b.add('pages', mat('sheet_paper', 0xfaf6ea), new THREE.BoxGeometry(0.14, 0.004, 0.2), { pos: V(0.003, 0.017, 0) });
	b.add('label', mat('counter_white', 0xf2f2ea), new THREE.BoxGeometry(0.08, 0.002, 0.04), { pos: V(0, 0.02, -0.05) });
	return b.build();
}

export function buildZeroKmSign() {
	const b = new Builder('garage_zero_km_sign');
	b.add('board', mat('cardboard', 0xc8a070), new THREE.BoxGeometry(0.6, 0.4, 0.02), { pos: V(0, 0.2, 0) });
	b.add('text', mat('sign_red', 0xd23a3a), new THREE.BoxGeometry(0.26, 0.12, 0.004), { pos: V(-0.1, 0.27, 0.012) });
	b.add('text', mat('sheet_ink', 0x2a2a30), new THREE.BoxGeometry(0.44, 0.03, 0.004), { pos: V(0, 0.12, 0.012) });
	b.add('star', mat('sheet_star', 0xf2c84b), new THREE.CylinderGeometry(0.06, 0.06, 0.004, 5), { pos: V(0.18, 0.28, 0.012), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The swapped parts story: the crate of the clients' new parts (two cops), the fake invoices, the pile of old parts
// painted silver and the "new" brake disc on the counter that leaves rust on whoever grabs it.
export function buildPartsCrate() {
	const b = new Builder('garage_parts_crate');
	const wood = mat('crate_wood', 0xb07a44), steel = mat('tool_chrome', 0xb8bcc4);
	b.add('box', wood, new THREE.BoxGeometry(0.8, 0.05, 0.55), { pos: V(0, 0.025, 0) });
	for (const s of [-1, 1]) {
		b.add('box', wood, new THREE.BoxGeometry(0.8, 0.4, 0.04), { pos: V(0, 0.2, s * 0.255) });
		b.add('box', wood, new THREE.BoxGeometry(0.04, 0.4, 0.55), { pos: V(s * 0.38, 0.2, 0) });
		b.add('handles', mat('flash_black', 0x26262a), new THREE.BoxGeometry(0.02, 0.04, 0.16), { pos: V(s * 0.405, 0.3, 0) });
	}
	b.add('discs', steel, new THREE.CylinderGeometry(0.12, 0.12, 0.03, 14), { pos: V(-0.2, 0.42, 0), rot: [0.3, 0, 0] });
	b.add('discs', steel, new THREE.CylinderGeometry(0.12, 0.12, 0.03, 14), { pos: V(0.05, 0.43, 0.04), rot: [-0.2, 0, 0.2] });
	b.add('filters', mat('filter_blue', 0x2f58a8), new THREE.CylinderGeometry(0.05, 0.05, 0.12, 10), { pos: V(0.25, 0.42, -0.08) });
	b.add('boxes', mat('parts_box', 0xf2c230), new THREE.BoxGeometry(0.16, 0.1, 0.12), { pos: V(0.24, 0.43, 0.12) });
	b.add('tag', mat('counter_white', 0xf2f2ea), new THREE.BoxGeometry(0.2, 0.08, 0.004), { pos: V(0, 0.28, 0.275) });
	return b.build();
}

export function buildFakeInvoices() {
	const b = new Builder('garage_fake_invoices');
	for (let i = 0; i < 3; i++) {
		b.add('paper', mat('invoice_pink', 0xf2c8d0), new THREE.BoxGeometry(0.15, 0.003, 0.21), { pos: V(i * 0.02, 0.002 + i * 0.003, i * 0.015), rot: [0, i * 0.15, 0] });
	}
	for (let i = 0; i < 5; i++) b.add('lines', mat('sheet_ink', 0x2a2a30), new THREE.BoxGeometry(0.1, 0.002, 0.006), { pos: V(0.04, 0.012, -0.05 + i * 0.03) });
	b.add('stamp', mat('sign_red', 0xd23a3a), new THREE.CylinderGeometry(0.025, 0.025, 0.002, 10), { pos: V(0.08, 0.013, 0.09) });
	return b.build();
}

export function buildOldParts() {
	const b = new Builder('garage_old_parts');
	const silver = mat('paint_silver', 0xd8dce4, { metalness: 0.3, roughness: 0.5 }), rust = mat('rust', 0x8a4a22);
	b.add('discs', silver, new THREE.CylinderGeometry(0.13, 0.13, 0.03, 12), { pos: V(0, 0.015, 0) });
	b.add('discs', silver, new THREE.CylinderGeometry(0.12, 0.12, 0.03, 12), { pos: V(0.03, 0.045, 0.02), rot: [0.1, 0, 0.1] });
	b.add('pipe', silver, new THREE.CylinderGeometry(0.03, 0.03, 0.34, 8), { pos: V(-0.05, 0.08, -0.05), rot: [0, 0.6, Math.PI / 2] });
	b.add('rust', rust, new THREE.BoxGeometry(0.06, 0.004, 0.04), { pos: V(0.05, 0.062, 0.05) });
	b.add('rust', rust, new THREE.BoxGeometry(0.04, 0.004, 0.05), { pos: V(-0.06, 0.032, -0.07) });
	b.add('drip', silver, new THREE.BoxGeometry(0.01, 0.03, 0.004), { pos: V(0.12, 0.03, 0.02) });
	return b.build();
}

export function buildRustyDisc() {
	const b = new Builder('garage_rusty_disc');
	b.add('disc', mat('paint_silver', 0xd8dce4, { metalness: 0.3, roughness: 0.5 }), new THREE.CylinderGeometry(0.14, 0.14, 0.03, 16), { pos: V(0, 0.015, 0) });
	b.add('hub', mat('tool_chrome', 0xb8bcc4), new THREE.CylinderGeometry(0.06, 0.06, 0.05, 12), { pos: V(0, 0.03, 0) });
	b.add('rust', mat('rust', 0x8a4a22), new THREE.BoxGeometry(0.05, 0.004, 0.03), { pos: V(0.08, 0.032, -0.03), rot: [0, 0.4, 0] });
	b.add('label', mat('parts_box', 0xf2c230), new THREE.BoxGeometry(0.05, 0.002, 0.03), { pos: V(-0.08, 0.032, 0.04) });
	return b.build();
}

// The street race's trophy: a golden cup with two handles on a black base with a checkered plate, 0.42 m tall.
export function buildRaceTrophy() {
	const b = new Builder('garage_race_trophy');
	const gold = mat('trophy_gold', 0xe8b830, { metalness: 0.5, roughness: 0.35 });
	b.add('base', mat('flash_black', 0x26262a), new THREE.BoxGeometry(0.18, 0.08, 0.18), { pos: V(0, 0.04, 0) });
	for (let i = 0; i < 4; i++) {
		b.add('checks', mat(i % 2 ? 'check_white' : 'check_black', i % 2 ? 0xf2f2ea : 0x1a1a1c), new THREE.BoxGeometry(0.03, 0.03, 0.004), { pos: V(-0.045 + i * 0.03, 0.04, 0.091) });
	}
	b.add('stem', gold, new THREE.CylinderGeometry(0.02, 0.035, 0.12, 10), { pos: V(0, 0.14, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.09, 0.04, 0.18, 14), { pos: V(0, 0.29, 0) });
	for (const s of [-1, 1]) b.add('handles', gold, new THREE.TorusGeometry(0.04, 0.01, 6, 12), { pos: V(s * 0.1, 0.3, 0), rot: [0, 0, 0] });
	b.add('rim', gold, new THREE.CylinderGeometry(0.095, 0.095, 0.015, 14), { pos: V(0, 0.385, 0) });
	return b.build();
}

// The nitro tank: a blue bottle 0.7 m long lying on its side, with a red valve and a white "N2O" band.
export function buildNitroTank() {
	const b = new Builder('garage_nitro_tank');
	b.add('tank', mat('nitro_blue', 0x2f58d8, { metalness: 0.3, roughness: 0.4 }), new THREE.CylinderGeometry(0.1, 0.1, 0.6, 14), { pos: V(-0.03, 0.1, 0), rot: [0, 0, Math.PI / 2] });
	b.add('cap', mat('nitro_blue', 0x2f58d8, { metalness: 0.3, roughness: 0.4 }), new THREE.SphereGeometry(0.1, 12, 8), { pos: V(0.27, 0.1, 0), scale: [0.4, 1, 1] });
	b.add('valve', mat('tool_chrome', 0xb8bcc4), new THREE.CylinderGeometry(0.025, 0.025, 0.06, 8), { pos: V(0.32, 0.1, 0), rot: [0, 0, Math.PI / 2] });
	b.add('knob', mat('sign_red', 0xd23a3a), new THREE.CylinderGeometry(0.035, 0.035, 0.02, 10), { pos: V(0.34, 0.15, 0) });
	b.add('band', mat('counter_white', 0xf2f2ea), new THREE.CylinderGeometry(0.102, 0.102, 0.12, 14), { pos: V(0, 0.1, 0), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// The race map: an unfolded city map with a red route that goes around and around.
export function buildRaceMap() {
	const b = new Builder('garage_race_map');
	b.add('paper', mat('map_paper', 0xf2e6c0), new THREE.BoxGeometry(0.3, 0.004, 0.21), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 4; i++) b.add('streets', mat('map_street', 0xbcb4a0), new THREE.BoxGeometry(0.28, 0.002, 0.008), { pos: V(0, 0.005, -0.075 + i * 0.05) });
	for (let i = 0; i < 5; i++) b.add('streets', mat('map_street', 0xbcb4a0), new THREE.BoxGeometry(0.008, 0.002, 0.19), { pos: V(-0.12 + i * 0.06, 0.005, 0) });
	b.add('route', mat('sign_red', 0xd23a3a), new THREE.TorusGeometry(0.06, 0.006, 4, 20), { pos: V(0.02, 0.007, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('finish', mat('flash_black', 0x26262a), new THREE.BoxGeometry(0.03, 0.003, 0.02), { pos: V(0.08, 0.008, 0) });
	return b.build();
}

// The dent hammer: a short wooden handle with a big round steel head, lying on its side, 0.45 m long.
export function buildDentHammer() {
	const b = new Builder('garage_dent_hammer');
	b.add('handle', mat('wood', 0x9a6a3a), new THREE.CylinderGeometry(0.018, 0.022, 0.34, 8), { pos: V(-0.06, 0.05, 0), rot: [0, 0, Math.PI / 2] });
	b.add('grip', mat('flash_black', 0x26262a), new THREE.CylinderGeometry(0.025, 0.025, 0.1, 8), { pos: V(-0.17, 0.05, 0), rot: [0, 0, Math.PI / 2] });
	b.add('head', mat('tool_chrome', 0xb8bcc4, { metalness: 0.5, roughness: 0.35 }), new THREE.CylinderGeometry(0.05, 0.05, 0.12, 14), { pos: V(0.16, 0.05, 0), rot: [Math.PI / 2, 0, 0] });
	for (const s of [-1, 1]) b.add('faces', mat('lift_dark', 0x35363a), new THREE.SphereGeometry(0.05, 12, 6), { pos: V(0.16, 0.05, s * 0.06), scale: [1, 1, 0.3] });
	return b.build();
}

// The clients' plates list: a white sheet with rows of plates, each crossed in red or still waiting.
export function buildPlatesList() {
	const b = new Builder('garage_plates_list');
	b.add('paper', mat('counter_white', 0xf2f2ea), new THREE.BoxGeometry(0.21, 0.004, 0.3), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 7; i++) {
		b.add('plates', mat('plate_yellow', 0xf2d040), new THREE.BoxGeometry(0.07, 0.002, 0.025), { pos: V(-0.05, 0.005, -0.11 + i * 0.037) });
		b.add('lines', mat('sheet_ink', 0x2a2a30), new THREE.BoxGeometry(0.06, 0.002, 0.006), { pos: V(0.04, 0.005, -0.11 + i * 0.037) });
		if (i % 3 !== 2) b.add('ticks', mat('sign_red', 0xd23a3a), new THREE.BoxGeometry(0.09, 0.002, 0.006), { pos: V(-0.05, 0.007, -0.11 + i * 0.037), rot: [0, 0.3, 0] });
	}
	return b.build();
}

// The neighborhood map with crosses: a city map with a red cross on each street where a client parks.
export function buildCrossMap() {
	const b = new Builder('garage_cross_map');
	b.add('paper', mat('map_paper', 0xf2e6c0), new THREE.BoxGeometry(0.4, 0.006, 0.3), { pos: V(0, 0.003, 0) });
	for (let i = 0; i < 5; i++) b.add('streets', mat('map_street', 0xbcb4a0), new THREE.BoxGeometry(0.38, 0.002, 0.01), { pos: V(0, 0.007, -0.12 + i * 0.06) });
	for (let i = 0; i < 6; i++) b.add('streets', mat('map_street', 0xbcb4a0), new THREE.BoxGeometry(0.01, 0.002, 0.28), { pos: V(-0.17 + i * 0.068, 0.007, 0) });
	for (const [x, z] of [[-0.13, -0.09], [0.04, -0.03], [0.11, 0.09], [-0.06, 0.06], [0.16, -0.1]]) {
		for (const r of [0.8, -0.8]) b.add('crosses', mat('sign_red', 0xd23a3a), new THREE.BoxGeometry(0.035, 0.002, 0.008), { pos: V(x, 0.009, z), rot: [0, r, 0] });
	}
	return b.build();
}

// The taxi sign for the comisario's car: a yellow roof sign with a checkered band and a magnet base, 0.5 m wide.
export function buildTaxiSign() {
	const b = new Builder('garage_taxi_sign');
	b.add('base', mat('flash_black', 0x26262a), new THREE.BoxGeometry(0.5, 0.03, 0.15), { pos: V(0, 0.015, 0) });
	b.add('sign', mat('taxi_yellow', 0xf2c230), new THREE.BoxGeometry(0.46, 0.15, 0.12), { pos: V(0, 0.105, 0) });
	for (let i = 0; i < 10; i++) {
		for (const s of [-1, 1]) b.add('checks', mat(i % 2 ? 'check_white' : 'check_black', i % 2 ? 0xf2f2ea : 0x1a1a1c), new THREE.BoxGeometry(0.046, 0.03, 0.004), { pos: V(-0.207 + i * 0.046, 0.06, s * 0.061) });
	}
	for (const s of [-1, 1]) b.add('word', mat('flash_black', 0x26262a), new THREE.BoxGeometry(0.2, 0.05, 0.004), { pos: V(0, 0.13, s * 0.061) });
	return b.build();
}

// The taximeter: a black box with a red display and a flag on top.
export function buildTaximeter() {
	const b = new Builder('garage_taximeter');
	b.add('box', mat('flash_black', 0x26262a), new THREE.BoxGeometry(0.2, 0.1, 0.14), { pos: V(0, 0.05, 0) });
	b.add('display', mat('meter_red', 0xff3a2a, { emissive: 0x801008 }), new THREE.BoxGeometry(0.14, 0.035, 0.004), { pos: V(0, 0.06, 0.071) });
	b.add('buttons', mat('counter_white', 0xf2f2ea), new THREE.BoxGeometry(0.12, 0.012, 0.004), { pos: V(0, 0.025, 0.071) });
	b.add('flag', mat('sign_red', 0xd23a3a), new THREE.BoxGeometry(0.02, 0.07, 0.05), { pos: V(0.08, 0.135, 0) });
	return b.build();
}

// The trips notebook: a small yellow notebook with a rubber band.
export function buildTripsNotebook() {
	const b = new Builder('garage_trips_notebook');
	b.add('cover', mat('taxi_yellow', 0xf2c230), new THREE.BoxGeometry(0.12, 0.015, 0.18), { pos: V(0, 0.0075, 0) });
	b.add('pages', mat('sheet_paper', 0xfaf6ea), new THREE.BoxGeometry(0.115, 0.004, 0.17), { pos: V(0.002, 0.017, 0) });
	b.add('band', mat('flash_black', 0x26262a), new THREE.BoxGeometry(0.124, 0.022, 0.008), { pos: V(0, 0.01, 0.05) });
	return b.build();
}

export const models = {
	garage_parts_crate: buildPartsCrate, garage_fake_invoices: buildFakeInvoices, garage_old_parts: buildOldParts,
	garage_rusty_disc: buildRustyDisc,
	garage_taxi_sign: buildTaxiSign, garage_taximeter: buildTaximeter, garage_trips_notebook: buildTripsNotebook,
	garage_dent_hammer: buildDentHammer, garage_plates_list: buildPlatesList, garage_cross_map: buildCrossMap,
	garage_race_trophy: buildRaceTrophy, garage_nitro_tank: buildNitroTank, garage_race_map: buildRaceMap,
	garage_odometer_drill: buildOdometerDrill, garage_km_notebook: buildKmNotebook, garage_zero_km_sign: buildZeroKmSign,
	garage_plates_box: buildPlatesBox, garage_stolen_list: buildStolenList, garage_spray_can: buildSprayCan,
	npc_grasita: buildGrasita, ...toolModels,
	garage_lift: buildLift, garage_lift_arms: buildLiftArms, npc_don_tuerca: buildDonTuerca,
	oil_drum: buildOilDrum, garage_tire: buildGarageTire, service_bell: buildServiceBell, tool_board: buildToolBoard,
};

export const views = {
	garage: {
		items: [
			{ name: 'garage_lift', pos: [-1.2, 0, 0] }, { name: 'garage_lift_arms', pos: [-1.2, 1.8, 0] },
			{ name: 'npc_don_tuerca', pos: [0.6, 0, 0.9], rotY: -0.3 }, { name: 'oil_drum', pos: [1.6, 0, 0.4] }, { name: 'garage_tire', pos: [0.6, 0, 1.0] }, { name: 'garage_tire', pos: [0.6, 0.24, 1.0] },
			{ name: 'service_bell', pos: [1.6, 0.92, 0.4] }, { name: 'tool_board', pos: [1.7, 0.6, -0.8] },
		],
		cam: { pos: [0, 2.0, 6.5], target: [0, 1.4, 0], fov: 45 },
	},
	garage_swapped_plates: {
		items: [{ name: 'garage_plates_box', pos: [-0.2, 0, 0], rotY: 0.3 }, { name: 'garage_stolen_list', pos: [0.45, 0, 0.3], rotY: -0.2 },
			{ name: 'garage_spray_can', pos: [0.5, 0, -0.2] }],
		cam: { pos: [0.2, 1.0, 1.6], target: [0.1, 0.15, 0], fov: 42 },
	},
	garage_magic_odometer: {
		items: [{ name: 'garage_odometer_drill', pos: [-0.35, 0, 0], rotY: 0.3 }, { name: 'garage_km_notebook', pos: [0.05, 0, 0.3], rotY: -0.2 },
			{ name: 'garage_zero_km_sign', pos: [0.35, 0, -0.2], rotY: -0.3 }],
		cam: { pos: [0.0, 0.9, 1.5], target: [0.0, 0.15, 0], fov: 42 },
	},
	garage_swapped_parts: {
		items: [{ name: 'garage_parts_crate', pos: [-0.35, 0, 0], rotY: 0.3 }, { name: 'garage_fake_invoices', pos: [0.35, 0, 0.35], rotY: -0.2 },
			{ name: 'garage_old_parts', pos: [0.4, 0, -0.15] }, { name: 'garage_rusty_disc', pos: [0.05, 0, 0.45] }],
		cam: { pos: [0.1, 1.2, 1.9], target: [0.0, 0.2, 0], fov: 42 },
	},
	garage_street_race: {
		items: [{ name: 'garage_race_trophy', pos: [-0.3, 0, 0], rotY: 0.3 }, { name: 'garage_nitro_tank', pos: [0.25, 0, -0.25], rotY: -0.3 },
			{ name: 'garage_race_map', pos: [0.3, 0, 0.3], rotY: -0.2 }],
		cam: { pos: [0.0, 1.0, 1.7], target: [0.0, 0.18, 0], fov: 42 },
	},
	garage_dented_on_purpose: {
		items: [{ name: 'garage_dent_hammer', pos: [-0.25, 0, 0], rotY: 0.4 }, { name: 'garage_plates_list', pos: [0.3, 0, -0.15], rotY: -0.2 },
			{ name: 'garage_cross_map', pos: [0.05, 0, 0.3], rotY: 0.15 }],
		cam: { pos: [0.0, 0.9, 1.3], target: [0.0, 0.05, 0], fov: 42 },
	},
	garage_comisario_taxi: {
		items: [{ name: 'garage_taxi_sign', pos: [-0.25, 0, 0], rotY: 0.3 }, { name: 'garage_taximeter', pos: [0.3, 0, -0.1], rotY: -0.3 },
			{ name: 'garage_trips_notebook', pos: [0.1, 0, 0.3], rotY: 0.2 }],
		cam: { pos: [0.0, 0.8, 1.3], target: [0.0, 0.08, 0], fov: 42 },
	},
	garage_tools: {
		items: [
			{ name: 'npc_grasita', pos: [-0.9, 0, -0.3], rotY: 0.3 },
			...Object.keys(toolModels).map((name, i) => ({ name, pos: [0.25 + (i % 2) * 0.55, 0.05, -0.6 + Math.floor(i / 2) * 0.35] })),
		],
		cam: { pos: [0.2, 1.6, 2.2], target: [0.1, 0.5, -0.1], fov: 45 },
	},
};
