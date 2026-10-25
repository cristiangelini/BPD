// The ghost car traffic control (docs/diseno/control-auto-fantasma.md): the drivers leaning on their open windows, the
// ghost car's radio antenna on its roof and the Titiritero's remote control. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// A driver at an open window, faces +Z (out of the window), origin on the window sill where the glass would be: the
// head out in the air, the shoulder and an elbow on the sill, the hand hanging down the door. 'skin', 'hair' and
// 'shirt' are light so the game tints them per driver.
export function buildWindowDriver() {
	const b = new Builder('window_driver');
	const skin = mat('driver_skin', 0xf2f2ee), hair = mat('driver_hair', 0xe8e8e8), shirt = mat('driver_shirt', 0xeeeeee);
	const dark = mat('driver_features', 0x2a1a18);
	b.add('skin', skin, ellipsoid(0.11, 0.13, 0.11), { pos: V(0, 0.36, 0.04) });
	b.add('skin', skin, ellipsoid(0.025, 0.035, 0.03, 8, 5), { pos: V(0, 0.34, 0.15) });
	for (const x of [-1, 1]) b.add('features', dark, ellipsoid(0.015, 0.018, 0.01, 8, 5), { pos: V(x * 0.04, 0.39, 0.14) });
	b.add('features', dark, new THREE.BoxGeometry(0.06, 0.012, 0.01), { pos: V(0, 0.29, 0.14) });
	b.add('hair', hair, ellipsoid(0.12, 0.07, 0.12, 10, 5), { pos: V(0, 0.45, 0.02) });
	b.add('skin', skin, new THREE.CylinderGeometry(0.045, 0.05, 0.12, 8), { pos: V(0, 0.2, 0.0) });
	b.add('shirt', shirt, ellipsoid(0.2, 0.1, 0.12, 12, 6), { pos: V(-0.08, 0.1, -0.06) });
	// The elbow out on the sill, the forearm down along the door.
	const upper = new THREE.CapsuleGeometry(0.05, 0.22, 3, 8);
	b.add('shirt', shirt, upper, { pos: V(0.14, 0.04, 0.1), rot: [Math.PI / 2, 0, 0] });
	const fore = new THREE.CapsuleGeometry(0.045, 0.2, 3, 8);
	b.add('skin', skin, fore, { pos: V(0.14, -0.1, 0.25) });
	b.add('skin', skin, ellipsoid(0.05, 0.06, 0.03, 8, 5), { pos: V(0.14, -0.26, 0.25) });
	return b.build();
}

// The ghost car's radio antenna: a black base on the roof, a whip and a red light on top ('tip', that blinks).
export function buildRcAntenna() {
	const b = new Builder('rc_antenna');
	const black = mat('rc_black', 0x1c1c20), steel = mat('steel', 0x8c9098);
	const red = mat('rc_tip', 0xff2020, { emissive: 0x801010 });
	box(b, 'base', black, 0.14, 0.05, 0.14, 0, 0.025, 0);
	b.add('whip', steel, new THREE.CylinderGeometry(0.008, 0.012, 0.7, 6), { pos: V(0, 0.4, 0) });
	b.add('tip', red, ellipsoid(0.035, 0.035, 0.035, 8, 6), { pos: V(0, 0.77, 0) });
	return b.build();
}

// The Titiritero's remote control, held flat, faces +Z: the box with two sticks, buttons and its telescopic antenna up.
export function buildRcRemote() {
	const b = new Builder('rc_remote');
	const body = mat('rc_body', 0x2a2d35), stick = mat('rc_black', 0x1c1c20), steel = mat('steel', 0x8c9098);
	const red = mat('rc_button', 0xd82828), yellow = mat('rc_yellow', 0xf0c020);
	box(b, 'body', body, 0.22, 0.05, 0.13, 0, 0, 0);
	for (const x of [-1, 1]) {
		b.add('body', stick, new THREE.CylinderGeometry(0.008, 0.008, 0.05, 6), { pos: V(x * 0.06, 0.05, 0) });
		b.add('body', stick, ellipsoid(0.015, 0.012, 0.015, 8, 5), { pos: V(x * 0.06, 0.075, 0) });
	}
	box(b, 'body', red, 0.025, 0.012, 0.025, 0, 0.03, 0.03);
	box(b, 'body', yellow, 0.025, 0.012, 0.025, 0, 0.03, -0.03);
	b.add('antenna', steel, new THREE.CylinderGeometry(0.004, 0.007, 0.35, 6), { pos: V(0.09, 0.2, -0.05) });
	b.add('antenna', steel, ellipsoid(0.01, 0.01, 0.01, 6, 4), { pos: V(0.09, 0.375, -0.05) });
	return b.build();
}

export const models = { window_driver: buildWindowDriver, rc_antenna: buildRcAntenna, rc_remote: buildRcRemote };

export const views = {
	window_driver: {
		items: [{ name: 'window_driver', pos: [0, 0, 0] }],
		cam: { pos: [0.9, 0.4, 1.2], target: [0, 0.15, 0.05], fov: 35 },
	},
	rc_remote: {
		items: [{ name: 'rc_remote', pos: [0, 0, 0] }, { name: 'rc_antenna', pos: [0.4, -0.05, 0] }],
		cam: { pos: [0.5, 0.6, 1.0], target: [0.2, 0.15, 0], fov: 40 },
	},
};
