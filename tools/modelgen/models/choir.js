// The church choir's things (docs/diseno/infiltracion-coro.md): the collection box with its false bottom, and the
// choir's van.
// Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

// The collection box "para el órgano nuevo": a small wooden box with a coin slot and a brass plate, and a thin false
// bottom drawer showing at its foot. 0.26 x 0.2 x 0.18 m, origin in its middle.
export function buildCollectionBox() {
	const b = new Builder('collection_box');
	const wood = mat('collection_wood', 0x6a4426), dark = mat('collection_dark', 0x2a1a10);
	const brass = mat('collection_brass', 0xd0a848, { emissive: 0x201808 });
	b.add('box', wood, new THREE.BoxGeometry(0.26, 0.17, 0.18), { pos: V(0, 0.015, 0) });
	b.add('drawer', wood, new THREE.BoxGeometry(0.24, 0.03, 0.17), { pos: V(0, -0.085, 0.01) });
	b.add('drawer', dark, new THREE.BoxGeometry(0.1, 0.008, 0.005), { pos: V(0, -0.085, 0.096) });
	b.add('slot', dark, new THREE.BoxGeometry(0.1, 0.005, 0.02), { pos: V(0, 0.101, 0) });
	b.add('plate', brass, new THREE.BoxGeometry(0.14, 0.05, 0.005), { pos: V(0, 0.03, 0.092) });
	return b.build();
}

function box(b, part, m, sx, sy, sz, x, y, z) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z) });
}

// The choir's van (step 5): an old two-tone combi, sky blue below and cream above, with the windows open all around
// so the choristers inside show from the chest up (they ride in it, SuspectCar.RIDERS), a church-window sign on each
// side and a roof rack with a folded music stand. 4.6 m long, 2.0 m wide, roof at 2.15 m; faces +Z like the rest and
// takes the sedan's wheels.
export function buildChoirVan() {
	const blue = mat('van_blue', 0x6aa8d8), cream = mat('van_cream', 0xf2ead2), black = mat('car_black', 0x23252b);
	const grey = mat('car_grey', 0x6b7280), seat = mat('seat', 0x3b3f4a), glass = mat('van_glass', 0x9fc4d8);
	const lamp = mat('lamp', 0xfff3c0, { emissive: 0x806a20 }), tail = mat('tail', 0xd01828, { emissive: 0x500810 });
	const sign = [0xd84a3a, 0x3a7ad8, 0xe8c040, 0x4aa050].map((c, i) => mat('van_sign_' + i, c));
	const W = 2.0, F = 2.3, R = -2.3, FLOOR = 0.35, SILL = 1.15, ROOF = 2.15, T = 0.06;
	const b = new Builder('choir_van');
	box(b, 'body', black, W, 0.2, F - R, 0, FLOOR - 0.1, 0);
	box(b, 'body', seat, W - 2 * T, 0.04, F - R - 2 * T, 0, FLOOR + 0.02, 0);
	// Blue below the windows: the flat nose, the back and both sides.
	box(b, 'body', blue, W, SILL - FLOOR, T, 0, (SILL + FLOOR) / 2, F - T / 2);
	box(b, 'body', blue, W, SILL - FLOOR, T, 0, (SILL + FLOOR) / 2, R + T / 2);
	for (const x of [-1, 1]) box(b, 'body', blue, T, SILL - FLOOR, F - R, x * (W / 2 - T / 2), (SILL + FLOOR) / 2, 0);
	// Cream above: the roof on pillars, the windshield the only glass.
	box(b, 'body', cream, W, 0.1, F - R, 0, ROOF - 0.05, 0);
	for (const x of [-1, 1]) for (const z of [F - 0.05, 0.6, -0.8, R + 0.05])
		box(b, 'frame', cream, 0.08, ROOF - SILL, 0.1, x * (W / 2 - 0.04), (ROOF + SILL) / 2, z);
	box(b, 'body', glass, W - 0.16, ROOF - SILL - 0.2, 0.02, 0, (ROOF + SILL) / 2, F - 0.03);
	// The cream V on the nose, the steering wheel and the driver's bench.
	box(b, 'body', cream, 0.9, 0.35, 0.02, 0, FLOOR + 0.45, F + 0.005);
	b.add('body', black, new THREE.TorusGeometry(0.17, 0.025, 6, 14), { pos: V(-0.45, SILL - 0.05, F - 0.45), rot: [-0.9, 0, 0] });
	box(b, 'body', seat, W - 0.2, 0.4, 0.5, 0, FLOOR + 0.2, F - 1.0);
	// The church-window sign on both sides: four colored panes under a pointed top.
	for (const x of [-1, 1]) {
		for (let i = 0; i < 4; i++) box(b, 'sign', sign[i], 0.02, 0.18, 0.18, x * (W / 2 + 0.01), FLOOR + 0.35 + (i >> 1) * 0.2, -0.4 + (i & 1) * 0.2);
		b.add('sign', cream, new THREE.ConeGeometry(0.2, 0.2, 4), { pos: V(x * (W / 2 + 0.01), FLOOR + 0.83, -0.3), rot: [0, Math.PI / 4, 0] });
	}
	for (const x of [-1, 1]) {
		box(b, 'lights', lamp, 0.22, 0.22, 0.04, x * 0.65, FLOOR + 0.35, F + 0.01);
		box(b, 'lights', tail, 0.12, 0.25, 0.04, x * 0.8, FLOOR + 0.5, R - 0.01);
	}
	box(b, 'body', grey, W + 0.06, 0.16, 0.14, 0, FLOOR + 0.05, F + 0.04);
	box(b, 'body', grey, W + 0.06, 0.16, 0.14, 0, FLOOR + 0.05, R - 0.04);
	// The roof rack with a folded music stand tied on.
	for (const x of [-1, 1]) box(b, 'rack', grey, 0.04, 0.04, 3.0, x * 0.7, ROOF + 0.1, -0.3);
	box(b, 'rack', black, 0.5, 0.04, 1.2, 0.1, ROOF + 0.14, -0.4);
	return b.build();
}

export const models = { collection_box: buildCollectionBox, choir_van: buildChoirVan };

export const views = {
	choir_things: {
		items: [{ name: 'collection_box', pos: [0, 0.1, 0], rotY: 0.4 }],
		cam: { pos: [0, 0.4, 0.9], target: [0, 0.08, 0], fov: 40 },
	},
	choir_van: {
		items: [{ name: 'choir_van', pos: [0, 0, 0] },
			...[[-1.05, 1.55], [1.05, 1.55], [-1.05, -1.55], [1.05, -1.55]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] })),
			{ name: 'npc_ernesto', pos: [-0.45, 0.4, 1.3], scale: 0.85 },
			{ name: 'npc_corista', pos: [-0.5, 0.4, -0.1], scale: 0.85 }, { name: 'npc_corista_b', pos: [0.5, 0.4, -0.1], scale: 0.85 },
			{ name: 'npc_corista_b', pos: [-0.5, 0.4, -1.4], scale: 0.85 }, { name: 'npc_corista', pos: [0.5, 0.4, -1.4], scale: 0.85 }],
		cam: { pos: [6.5, 3.8, 6.0], target: [0, 1.2, 0], fov: 38 },
	},
};
