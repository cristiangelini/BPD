// First person hand variants (Cristian, 19/10: "quiero que se vean las manos"). Not in the game yet:
// the views show each one from the cop's eyes so Cristian picks. Built in eye space: eye at (0, 1.35, 0) looking +Z.
// Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { SKINS, M, limb } from './pear.js';

const EYE = 1.35;
const skin = mat('skin_rosa', SKINS[0].color);
const cuffWhite = M.white;

// Hand center and elbow for side s (-1 left, 1 right), in eye space moved to the eye height.
const hand = (s) => V(s * 0.2, EYE - 0.19, 0.48);
const elbow = (s) => V(s * 0.3, EYE - 0.5, 0.1);

function arms(b, r = 0.05) {
	for (const s of [-1, 1]) limb(b, 'arms', M.shirt, elbow(s), hand(s).clone().add(V(0, -0.02, -0.11)), r);
}

// Fat sausage finger from the knuckle, pointing forward and a bit toward the middle.
function finger(b, at, s, len, r, spread) {
	const dir = V(-s * 0.15 + spread, -0.15, 1).normalize();
	limb(b, 'hand', skin, at, at.clone().add(dir.multiplyScalar(len)), r, 6);
}

const variants = {
	// A: round ball hands, like the pear body today.
	hands_ball(b) {
		arms(b);
		for (const s of [-1, 1]) b.add('hand', skin, ellipsoid(0.128, 0.12, 0.128, 8, 6), { pos: hand(s) });
	},
	// B: mitten, one block for the fingers and a thumb on the inside.
	hands_mitten(b) {
		arms(b);
		for (const s of [-1, 1]) {
			const h = hand(s);
			b.add('hand', skin, ellipsoid(0.105, 0.068, 0.15, 8, 6), { pos: h });
			b.add('hand', skin, ellipsoid(0.045, 0.042, 0.075, 6, 4), { pos: h.clone().add(V(-s * 0.105, 0.015, -0.015)), rot: [0, s * 0.9, 0] });
		}
	},
	// C: chubby hand with four short fingers and a thumb.
	hands_fingers(b) {
		arms(b);
		for (const s of [-1, 1]) {
			const h = hand(s);
			b.add('hand', skin, ellipsoid(0.098, 0.053, 0.09, 8, 5), { pos: h });
			for (let i = 0; i < 4; i++) finger(b, h.clone().add(V((i - 1.5) * 0.048, 0, 0.068)), s, 0.09, 0.024, (i - 1.5) * 0.075);
			finger(b, h.clone().add(V(-s * 0.09, 0.007, 0)), s, 0.068, 0.027, -s * 1.35);
		}
	},
	// D: cartoon hand, three fat fingers, thumb and a white cuff.
	hands_cartoon(b) {
		arms(b);
		for (const s of [-1, 1]) {
			const h = hand(s);
			b.add('cuff', cuffWhite, new THREE.CylinderGeometry(0.07, 0.065, 0.05, 8), { pos: h.clone().add(V(0, -0.01, -0.09)), lookAt: V(0, 0.45, 1) });
			b.add('hand', skin, ellipsoid(0.105, 0.06, 0.098, 8, 5), { pos: h });
			for (let i = 0; i < 3; i++) finger(b, h.clone().add(V((i - 1) * 0.06, 0, 0.075)), s, 0.105, 0.033, (i - 1) * 0.12);
			finger(b, h.clone().add(V(-s * 0.098, 0.007, 0)), s, 0.075, 0.033, -s * 1.35);
		}
	},
	// E: noodle arms (thin and long, R.E.P.O. style) with big round hands.
	hands_noodle(b) {
		for (const s of [-1, 1]) {
			const mid = V(s * 0.36, EYE - 0.38, 0.3);
			limb(b, 'arms', M.shirt, elbow(s), mid, 0.032);
			limb(b, 'arms', skin, mid, hand(s).clone().add(V(0, 0, -0.06)), 0.028);
			b.add('hand', skin, ellipsoid(0.105, 0.09, 0.112, 8, 6), { pos: hand(s) });
		}
	},
};

export const models = Object.fromEntries(Object.entries(variants).map(([name, fn]) => [name, () => {
	const b = new Builder(name);
	fn(b);
	return b.build();
}]));

const cam = { pos: [0, EYE, 0], target: [0, EYE - 0.05, 1], fov: 80 };
export const views = Object.fromEntries(Object.keys(variants).map((name) => [name, {
	items: [{ name, pos: [0, 0, 0] }, { name: 'cookie_tin', pos: [0.05, 0, 1.4] }, { name: 'crate', pos: [-0.9, 0, 2.6], rotY: 0.4 }],
	cam,
}]));
