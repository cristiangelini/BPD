// The bank robbery's things (docs/diseno/robo-banco.md): the robbers' getaway van. Placeholder.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

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

// A sack of the vault's money (step 6): grey cloth tied at the neck with a gold coin painted on, El Oso's on his run
// on foot, left on the ground when he gives up. About 0.5 m tall, its bottom at y = 0.
export function buildMoneyBag() {
	const cloth = mat('bag_cloth', 0xb8b0a0), rope = mat('bag_rope', 0x8a6a3a), coin = mat('bag_coin', 0xf2c84b, { emissive: 0x3a2a05 });
	const b = new Builder('money_bag');
	b.add('bag', cloth, ellipsoid(0.24, 0.22, 0.2, 9, 6), { pos: V(0, 0.2, 0) });
	b.add('bag', cloth, new THREE.ConeGeometry(0.1, 0.16, 7), { pos: V(0, 0.46, 0), rot: [Math.PI, 0, 0] });
	b.add('bag', rope, new THREE.TorusGeometry(0.06, 0.015, 4, 10), { pos: V(0, 0.4, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('bag', coin, new THREE.CylinderGeometry(0.08, 0.08, 0.01, 10), { pos: V(0, 0.22, 0.2), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The hostages' party (robo-banco-rehenes.md, step 1): a garland of paper pennants, 4 m long along X, its ends at
// y = 0 and sagging 0.35 m in the middle, hung between the bank's walls.
export function buildBankGarland() {
	const cord = mat('garland_cord', 0xe8e0c8);
	const colors = [0xe8433a, 0xf2c230, 0x3a8ee8, 0x4ab04a, 0xe86ab8].map((c, i) => mat(`pennant_${i}`, c, { side: THREE.DoubleSide }));
	const b = new Builder('bank_garland');
	const L = 4.0, SAG = 0.35, N = 12;
	const y = (x) => -SAG * (1 - (2 * x / L) ** 2);
	for (let i = 0; i < 8; i++) {
		const x0 = -L / 2 + (i / 8) * L, x1 = -L / 2 + ((i + 1) / 8) * L;
		const a = V(x0, y(x0), 0), c = V(x1, y(x1), 0);
		const mid = a.clone().add(c).multiplyScalar(0.5);
		b.add('cord', cord, new THREE.CylinderGeometry(0.008, 0.008, a.distanceTo(c), 4), { pos: mid, lookAt: c.clone().sub(a) });
	}
	for (let i = 0; i < N; i++) {
		const x = -L / 2 + ((i + 0.5) / N) * L;
		const flag = new THREE.BufferGeometry();
		flag.setAttribute('position', new THREE.Float32BufferAttribute([-0.12, 0, 0, 0.12, 0, 0, 0, -0.26, 0], 3));
		flag.computeVertexNormals();
		b.add('pennants', colors[i % colors.length], flag, { pos: V(x, y(x), 0) });
	}
	return b.build();
}

// The robbers' boombox on the bench (step 1): 0.55 x 0.3 x 0.16 m, two big speakers, a tape door and a handle,
// bottom at y = 0, speakers facing +Z.
export function buildBankBoombox() {
	const body = mat('boombox', 0x2b2d33), grille = mat('boombox_grille', 0x55585f), chrome = mat('drill_steel', 0x8a9098);
	const glow = mat('boombox_glow', 0x7ae0ff, { emissive: 0x206070 });
	const b = new Builder('bank_boombox');
	box(b, 'body', body, 0.55, 0.3, 0.16, 0, 0.15, 0);
	for (const x of [-0.17, 0.17]) {
		b.add('speakers', grille, new THREE.CylinderGeometry(0.1, 0.1, 0.02, 12), { pos: V(x, 0.14, 0.08), rot: [Math.PI / 2, 0, 0] });
		b.add('speakers', chrome, new THREE.CylinderGeometry(0.03, 0.03, 0.025, 8), { pos: V(x, 0.14, 0.085), rot: [Math.PI / 2, 0, 0] });
	}
	box(b, 'body', glow, 0.14, 0.06, 0.01, 0, 0.2, 0.081);
	box(b, 'body', chrome, 0.12, 0.08, 0.01, 0, 0.1, 0.081);
	for (const x of [-0.2, 0.2]) box(b, 'handle', chrome, 0.02, 0.1, 0.02, x, 0.35, 0);
	box(b, 'handle', chrome, 0.42, 0.02, 0.02, 0, 0.4, 0);
	box(b, 'antenna', chrome, 0.01, 0.3, 0.01, 0.24, 0.45, -0.05);
	return b.build();
}

// One croissant (step 1, taken in step 4): a crescent of five puffy rolls, 0.18 m from tip to tip, bottom at y = 0.
export function buildBankCroissant() {
	const crust = mat('croissant', 0xd99a3c), dark = mat('croissant_dark', 0xb0702a);
	const b = new Builder('bank_croissant');
	for (let i = 0; i < 5; i++) {
		const t = (i - 2) / 2, a = t * 1.1;
		const r = 0.035 * (1 - 0.45 * Math.abs(t));
		b.add('croissant', i % 2 ? dark : crust, ellipsoid(r * 1.2, r, r, 8, 5), { pos: V(Math.sin(a) * 0.08, r, -Math.cos(a) * 0.05 + 0.05), rot: [0, a, 0] });
	}
	return b.build();
}

// The croissants' tray on the counter (step 1): a round silver tray 0.5 m wide with seven croissants piled on it.
// Bottom at y = 0. Step 4 takes them one by one, so the game hides them (parts croissant_0..6).
export function buildBankCroissantTray() {
	const silver = mat('tray_silver', 0xc8ccd2), crust = mat('croissant', 0xd99a3c), dark = mat('croissant_dark', 0xb0702a);
	const b = new Builder('bank_croissant_tray');
	b.add('tray', silver, new THREE.CylinderGeometry(0.25, 0.23, 0.02, 16), { pos: V(0, 0.01, 0) });
	b.add('tray', silver, new THREE.TorusGeometry(0.245, 0.012, 4, 20), { pos: V(0, 0.025, 0), rot: [Math.PI / 2, 0, 0] });
	const spots = [[0, 0, 0], [0.13, 0, 0.6], [-0.13, 0, 2.2], [0.06, 0.12, 4.0], [-0.07, -0.12, 1.1], [0.07, -0.12, 3.1], [0, 0, 5.0]];
	spots.forEach(([x, z, rot], n) => {
		const lift = n === 6 ? 0.05 : 0.02;
		for (let i = 0; i < 5; i++) {
			const t = (i - 2) / 2, a = t * 1.1, r = 0.035 * (1 - 0.45 * Math.abs(t));
			const p = V(Math.sin(a) * 0.08, r + lift, -Math.cos(a) * 0.05 + 0.05).applyAxisAngle(V(0, 1, 0), rot).add(V(x, 0, z));
			b.add(`croissant_${n}`, i % 2 ? dark : crust, ellipsoid(r * 1.2, r, r, 8, 5), { pos: p, rot: [0, a + rot, 0] });
		}
	});
	return b.build();
}

export const models = { robbers_van: buildRobbersVan, bank_drill: buildBankDrill, money_bag: buildMoneyBag,
	bank_garland: buildBankGarland, bank_boombox: buildBankBoombox, bank_croissant: buildBankCroissant,
	bank_croissant_tray: buildBankCroissantTray };

export const views = {
	bank_party: {
		items: [{ name: 'bank_garland', pos: [0, 1.6, -0.6] }, { name: 'bank_boombox', pos: [-0.8, 0, 0.2], rotY: 0.3 },
			{ name: 'bank_croissant_tray', pos: [0.5, 0, 0.3] }, { name: 'bank_croissant', pos: [0.05, 0, 0.8], rotY: 0.6 }],
		cam: { pos: [0, 1.2, 3.0], target: [0, 0.6, 0], fov: 45 },
	},
	money_bag: {
		items: [{ name: 'money_bag', pos: [0, 0, 0], rotY: 0.3 }, { name: 'npc_ladron_oso', pos: [0.7, 0, -0.2], rotY: -0.3, scale: 1.15 }],
		cam: { pos: [0.4, 1.2, 3.0], target: [0.35, 0.6, 0], fov: 38 },
	},
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
