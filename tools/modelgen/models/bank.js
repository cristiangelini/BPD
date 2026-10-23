// The bank robbery's things (docs/diseno/robo-banco.md): the robbers' getaway van. Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// The robbers' van (step 1): a grey panel van disguised as a florist's, with a big painted daisy on each side and a
// wilted bunch on the dashboard. The sliding door on the right is open. Same size as the trucks (5.2 m long, 2.2 m
// wide) and the same wheels, so it drives like them in the chase; faces +Z like the rest.
export function buildRobbersVan() {
	const grey = mat('van_grey', 0x7b8088), black = mat('car_black', 0x23252b), dark = mat('truck_glass', 0x2a3340);
	const petal = mat('daisy_petal', 0xf6f2e6), heart = mat('daisy_heart', 0xf2c230), stem = mat('daisy_stem', 0x4a8a3a);
	const lamp = mat('lamp', 0xfff3c0, { emissive: 0x806a20 }), tail = mat('tail', 0xd01828, { emissive: 0x500810 });
	const bumper = mat('car_grey', 0x6b7280), inside = mat('van_inside', 0x3a3d44);
	const W = 2.2, L = 5.2, F = L / 2, R = -L / 2, FLOOR = 0.35, TOP = 2.35, HOOD = 1.1;
	const b = new Builder('robbers_van');
	box(b, 'body', black, W, 0.2, L, 0, FLOOR - 0.1, 0);
	box(b, 'body', inside, W - 0.1, 0.04, L - 0.2, 0, FLOOR + 0.02, 0);
	// A short sloped nose, then the tall box all the way back.
	box(b, 'body', grey, W, 0.6, 0.8, 0, FLOOR + 0.3, F - 0.4);
	box(b, 'body', dark, W - 0.12, 0.75, 0.06, 0, FLOOR + 1.0, F - 0.85, [-0.45, 0, 0]);
	box(b, 'body', grey, W, TOP - FLOOR, L - 1.1, 0, (TOP + FLOOR) / 2, (F - 1.1 + R) / 2);
	for (const x of [-1, 1]) box(b, 'body', dark, 0.04, 0.5, 0.8, x * (W / 2 + 0.01), FLOOR + 1.2, F - 1.6);
	// The open sliding door on the right: a dark doorway, the door slid back along the side.
	box(b, 'door', inside, 0.04, 1.6, 1.3, W / 2 + 0.01, FLOOR + 0.9, 0.2);
	box(b, 'door', grey, 0.05, 1.7, 1.3, W / 2 + 0.07, FLOOR + 0.95, -1.1);
	// The daisy on each side (on the left in full, on the right behind the doorway).
	for (const [x, z] of [[-1, -0.6], [1, -1.6]]) {
		const side = x * (W / 2 + 0.03 + (x > 0 ? 0.05 : 0));
		for (let i = 0; i < 8; i++) {
			const a = (i / 8) * Math.PI * 2;
			b.add('daisy', petal, new THREE.SphereGeometry(0.17, 6, 4), { pos: V(side, FLOOR + 1.4 + Math.sin(a) * 0.28, z + Math.cos(a) * 0.28), scale: [0.15, 1, 0.55] });
		}
		b.add('daisy', heart, new THREE.SphereGeometry(0.14, 8, 6), { pos: V(side, FLOOR + 1.4, z), scale: [0.25, 1, 1] });
		box(b, 'daisy', stem, 0.02, 0.7, 0.06, side, FLOOR + 0.85, z);
	}
	// The wilted bunch on the dashboard.
	for (const x of [-0.3, -0.15, 0]) b.add('bunch', stem, new THREE.CylinderGeometry(0.015, 0.015, 0.3), { pos: V(x, FLOOR + 0.85, F - 0.75), rot: [0, 0, 0.9] });
	box(b, 'bunch', petal, 0.12, 0.06, 0.12, -0.45, FLOOR + 0.78, F - 0.75);
	for (const x of [-1, 1]) {
		box(b, 'lights', lamp, 0.3, 0.16, 0.04, x * 0.75, FLOOR + 0.42, F + 0.01);
		box(b, 'lights', tail, 0.16, 0.3, 0.04, x * 0.9, FLOOR + 0.7, R - 0.01);
		for (const wz of [1.7, -1.7]) box(b, 'body', black, 0.1, 0.5, 0.95, x * (W / 2 + 0.01), FLOOR + 0.1, wz);
	}
	box(b, 'body', bumper, W + 0.06, 0.18, 0.16, 0, FLOOR + 0.05, F + 0.04);
	box(b, 'body', bumper, W + 0.06, 0.18, 0.16, 0, FLOOR + 0.05, R - 0.04);
	box(b, 'body', dark, W - 0.5, 0.6, 0.04, 0, FLOOR + 1.5, R - 0.01);
	return b.build();
}

// The drill (step 3): a fat orange drill on a steel tripod, its nose at the height of the vault door's middle, a
// cable running down to a little generator box at its feet. The spinning bit is added by the game (BankDrill), so it
// turns on its own axis; it comes out of the nose at (0, 1.05, 0.3). Faces +Z, feet at y = 0.
export function buildBankDrill() {
	const orange = mat('drill_orange', 0xf2802a), steel = mat('drill_steel', 0x8a9098), black = mat('car_black', 0x23252b);
	const yellow = mat('drill_yellow', 0xf2c230);
	const b = new Builder('bank_drill');
	for (let i = 0; i < 3; i++) {
		const a = (i / 3) * Math.PI * 2;
		b.add('stand', steel, new THREE.CylinderGeometry(0.025, 0.025, 1.0, 5), { pos: V(Math.sin(a) * 0.22, 0.45, Math.cos(a) * 0.22 - 0.1), rot: [Math.cos(a) * -0.4, 0, Math.sin(a) * 0.4] });
	}
	box(b, 'stand', steel, 0.12, 0.08, 0.12, 0, 0.92, -0.1);
	box(b, 'body', orange, 0.26, 0.24, 0.5, 0, 1.05, -0.02);
	box(b, 'body', black, 0.27, 0.06, 0.3, 0, 1.18, -0.08);
	box(b, 'body', yellow, 0.02, 0.1, 0.18, 0.14, 1.05, -0.05);
	b.add('body', steel, new THREE.CylinderGeometry(0.07, 0.09, 0.1, 8), { pos: V(0, 1.05, 0.26), rot: [Math.PI / 2, 0, 0] });
	box(b, 'body', black, 0.05, 0.22, 0.06, 0, 0.88, -0.05);
	// The cable to the generator.
	b.add('cable', black, new THREE.CylinderGeometry(0.015, 0.015, 1.0, 4), { pos: V(0.25, 0.55, -0.4), rot: [0.5, 0, -0.35] });
	box(b, 'generator', yellow, 0.4, 0.3, 0.3, 0.4, 0.15, -0.6);
	box(b, 'generator', black, 0.1, 0.1, 0.02, 0.4, 0.2, -0.44);
	return b.build();
}

export const models = { robbers_van: buildRobbersVan, bank_drill: buildBankDrill };

export const views = {
	bank_drill: {
		items: [{ name: 'bank_drill', pos: [0, 0, 0], rotY: 0.9 }],
		cam: { pos: [0.2, 1.3, 2.6], target: [0, 0.75, 0], fov: 40 },
	},
	robbers: {
		items: ['conejo', 'chancho', 'pato', 'oso'].map((n, i) => ({ name: `npc_ladron_${n}`, pos: [(i - 1.5) * 1.2, 0, 0], rotY: 0.3, scale: n === 'oso' ? 1.15 : 1 })),
		cam: { pos: [0, 1.4, 6.0], target: [0, 0.9, 0], fov: 36 },
	},
	robbers_van: {
		items: [{ name: 'robbers_van', pos: [0, 0, 0] },
			...[[-1.1, 1.7], [1.1, 1.7], [-1.1, -1.7], [1.1, -1.7]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] }))],
		cam: { pos: [7.5, 4.2, 6.5], target: [0, 1.2, 0], fov: 38 },
	},
	robbers_van_left: {
		items: [{ name: 'robbers_van', pos: [0, 0, 0] },
			...[[-1.1, 1.7], [1.1, 1.7], [-1.1, -1.7], [1.1, -1.7]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] }))],
		cam: { pos: [-8.0, 3.5, 2.0], target: [0, 1.2, 0], fov: 38 },
	},
};
