// Props of the garage "El Pistón Feliz" (docs/diseno/allanamiento-taller.md): the two-post car lift, the oil drum,
// the counter's service bell and the tool wall's pegboard, with origins at the floor (or the back, for the pegboard)
// in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// A two-post car lift 3.2 m wide and 3.4 m tall: yellow posts on base plates, a beam across the top and two pairs of
// arms at `armY` (1.8 m, up) that hold the car's sills.
export function buildLift() {
	const b = new Builder('garage_lift');
	const armY = 1.8;
	const yellow = mat('lift_yellow', 0xf2c230), dark = mat('lift_dark', 0x35363a), pad = mat('lift_pad', 0x1e1e20);
	for (const s of [-1, 1]) {
		b.add('plate', dark, new THREE.BoxGeometry(0.5, 0.04, 0.5), { pos: V(s * 1.6, 0.02, 0) });
		b.add('post', yellow, new THREE.BoxGeometry(0.22, 3.4, 0.28), { pos: V(s * 1.6, 1.7, 0) });
		b.add('carriage', dark, new THREE.BoxGeometry(0.3, 0.4, 0.34), { pos: V(s * 1.6, armY + 0.1, 0) });
		for (const z of [-1, 1]) {
			b.add('arm', yellow, new THREE.BoxGeometry(0.7, 0.08, 0.1), { pos: V(s * 1.2, armY, z * 0.55), rot: [0, s * z * 0.5, 0] });
			b.add('pad', pad, new THREE.CylinderGeometry(0.08, 0.08, 0.05, 10), { pos: V(s * 0.9, armY + 0.06, z * 0.75) });
		}
	}
	b.add('beam', yellow, new THREE.BoxGeometry(3.4, 0.18, 0.22), { pos: V(0, 3.35, 0) });
	b.add('control', mat('lift_box', 0x3a6ad2), new THREE.BoxGeometry(0.2, 0.3, 0.12), { pos: V(-1.6, 1.2, 0.2) });
	b.add('button_up', mat('lift_green', 0x3ac24a), new THREE.CylinderGeometry(0.03, 0.03, 0.03, 8), { pos: V(-1.6, 1.27, 0.27), rot: [Math.PI / 2, 0, 0] });
	b.add('button_down', mat('lift_red', 0xd23a3a), new THREE.CylinderGeometry(0.03, 0.03, 0.03, 8), { pos: V(-1.6, 1.15, 0.27), rot: [Math.PI / 2, 0, 0] });
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

export const models = {
	garage_lift: buildLift,
	oil_drum: buildOilDrum, garage_tire: buildGarageTire, service_bell: buildServiceBell, tool_board: buildToolBoard,
};

export const views = {
	garage: {
		items: [
			{ name: 'garage_lift', pos: [-1.2, 0, 0] }, { name: 'oil_drum', pos: [1.6, 0, 0.4] }, { name: 'garage_tire', pos: [0.6, 0, 1.0] }, { name: 'garage_tire', pos: [0.6, 0.24, 1.0] },
			{ name: 'service_bell', pos: [1.6, 0.92, 0.4] }, { name: 'tool_board', pos: [1.7, 0.6, -0.8] },
		],
		cam: { pos: [0, 2.0, 6.5], target: [0, 1.4, 0], fov: 45 },
	},
};
