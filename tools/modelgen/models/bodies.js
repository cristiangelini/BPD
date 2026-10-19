// Five body structures to choose from (Cristian, 19/10): odd PEAK / R.E.P.O. style bodies shared by every character.
// Cops wear the same blue uniform; the skin color tells the players apart. Preview only, no GLB until one is approved.
import { Builder, loft, ellipsoid, mat, V, THREE } from '../lib.js';

export const SKINS = [
	{ name: 'rosa', color: 0xff86b0 },
	{ name: 'naranja', color: 0xff9d3f },
	{ name: 'lima', color: 0x9ee05c },
	{ name: 'violeta', color: 0xac8cff },
];

const M = {
	shirt: mat('shirt', 0x2f6bff),
	pants: mat('pants', 0x1b2a6b),
	cap: mat('cap', 0x1b2a6b),
	black: mat('black', 0x15151a),
	white: mat('white', 0xf6f4ee),
	gold: mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }),
};

// Cylinder from a to b (limbs).
function limb(b, part, m, a, c, r, sides = 6) {
	const d = c.clone().sub(a);
	b.add(part, m, new THREE.CylinderGeometry(r, r, d.length(), sides, 1), { pos: a.clone().add(c).multiplyScalar(0.5), lookAt: d });
	b.add(part, m, ellipsoid(r, r, r, sides, 4), { pos: c });
}

// Two big eyes looking forward (+Z) on a surface at depth z.
function eyes(b, y, z, gap, size) {
	for (const s of [-1, 1]) {
		b.add('face', M.white, ellipsoid(size, size * 1.15, size * 0.45, 8, 6), { pos: V(s * gap, y, z) });
		b.add('face', M.black, ellipsoid(size * 0.45, size * 0.55, size * 0.25, 6, 4), { pos: V(s * gap, y, z + size * 0.35) });
	}
}

// Police cap sitting on a head top.
function cap(b, y, r, z = 0) {
	b.add('cap', M.cap, new THREE.CylinderGeometry(r * 1.05, r * 0.95, r * 0.55, 8), { pos: V(0, y + r * 0.2, z) });
	b.add('cap', M.black, new THREE.CylinderGeometry(r * 0.8, r * 0.8, 0.02, 8, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, y - 0.03, z + r * 0.35) });
	b.add('cap', M.gold, new THREE.CylinderGeometry(r * 0.16, r * 0.16, 0.012, 5), { pos: V(0, y + r * 0.22, z + r * 1.0), rot: [Math.PI / 2, 0, 0] });
}

function belt(b, y, rx, rz) {
	b.add('body', M.black, loft([{ y: y - 0.035, rx, rz }, { y: y + 0.035, rx, rz }], 10));
	b.add('body', M.gold, new THREE.BoxGeometry(0.08, 0.06, 0.03), { pos: V(0, y, rz) });
}

// 1. Frijol: head and body are one bean, the face is the skin top of it. Stubby legs, noodle arms.
function frijol(b, skin) {
	b.add('body', M.shirt, loft([
		{ y: 0.32, rx: 0.3, rz: 0.27 }, { y: 0.5, rx: 0.38, rz: 0.34 }, { y: 0.8, rx: 0.4, rz: 0.36 }, { y: 1.02, rx: 0.37, rz: 0.33 },
	], 10, { capBottom: true }));
	b.add('body', skin, loft([
		{ y: 1.02, rx: 0.37, rz: 0.33 }, { y: 1.25, rx: 0.33, rz: 0.3 }, { y: 1.42, rx: 0.24, rz: 0.22 }, { y: 1.5, rx: 0.1, rz: 0.1 },
	], 10, { capTop: true }));
	belt(b, 0.5, 0.385, 0.345);
	for (const s of [-1, 1]) {
		limb(b, 'legs', M.pants, V(s * 0.15, 0.36, 0), V(s * 0.16, 0.1, 0.02), 0.09);
		b.add('legs', M.black, ellipsoid(0.11, 0.07, 0.16, 6, 4), { pos: V(s * 0.16, 0.06, 0.05) });
		limb(b, 'arms', M.shirt, V(s * 0.36, 0.95, 0), V(s * 0.52, 0.6, 0.05), 0.06);
		b.add('arms', skin, ellipsoid(0.08, 0.08, 0.08, 6, 4), { pos: V(s * 0.55, 0.52, 0.06) });
	}
	eyes(b, 1.24, 0.3, 0.11, 0.07);
	cap(b, 1.47, 0.22);
}

// 2. Cabezón: giant round head on a small body and stick legs.
function cabezon(b, skin) {
	b.add('body', M.shirt, loft([
		{ y: 0.5, rx: 0.17, rz: 0.15 }, { y: 0.7, rx: 0.2, rz: 0.17 }, { y: 0.92, rx: 0.17, rz: 0.15 }, { y: 0.98, rx: 0.08, rz: 0.08 },
	], 8, { capBottom: true, capTop: true }));
	belt(b, 0.56, 0.18, 0.16);
	b.add('head', skin, ellipsoid(0.36, 0.34, 0.33, 12, 8), { pos: V(0, 1.28, 0) });
	for (const s of [-1, 1]) {
		limb(b, 'legs', M.pants, V(s * 0.09, 0.52, 0), V(s * 0.11, 0.08, 0), 0.045);
		b.add('legs', M.black, ellipsoid(0.08, 0.06, 0.13, 6, 4), { pos: V(s * 0.11, 0.05, 0.04) });
		limb(b, 'arms', M.shirt, V(s * 0.17, 0.88, 0), V(s * 0.3, 0.55, 0.04), 0.035);
		b.add('arms', skin, ellipsoid(0.06, 0.06, 0.06, 6, 4), { pos: V(s * 0.31, 0.5, 0.05) });
	}
	eyes(b, 1.32, 0.3, 0.13, 0.085);
	cap(b, 1.56, 0.25);
}

// 3. Pera: bottom-heavy pear with no legs, just big shoes; a little head pokes out on top. Short stub arms.
function pera(b, skin) {
	b.add('body', M.pants, loft([
		{ y: 0.1, rx: 0.36, rz: 0.32 }, { y: 0.3, rx: 0.48, rz: 0.43 }, { y: 0.5, rx: 0.46, rz: 0.41 },
	], 10, { capBottom: true }));
	b.add('body', M.shirt, loft([
		{ y: 0.5, rx: 0.46, rz: 0.41 }, { y: 0.8, rx: 0.36, rz: 0.32 }, { y: 1.05, rx: 0.24, rz: 0.22 }, { y: 1.15, rx: 0.15, rz: 0.14 },
	], 10, { capTop: true }));
	belt(b, 0.52, 0.465, 0.415);
	b.add('head', skin, ellipsoid(0.2, 0.22, 0.19, 10, 7), { pos: V(0, 1.3, 0.02) });
	for (const s of [-1, 1]) {
		b.add('legs', M.black, ellipsoid(0.14, 0.08, 0.2, 6, 4), { pos: V(s * 0.2, 0.07, 0.12) });
		limb(b, 'arms', M.shirt, V(s * 0.3, 0.85, 0), V(s * 0.46, 0.68, 0.08), 0.06);
		b.add('arms', skin, ellipsoid(0.075, 0.075, 0.075, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	}
	eyes(b, 1.33, 0.17, 0.08, 0.055);
	cap(b, 1.47, 0.17, 0.01);
}

// 4. Caja: boxy robot-like torso with a box head floating above it, no neck (R.E.P.O.). Thin pole limbs.
function caja(b, skin) {
	b.add('body', M.shirt, new THREE.BoxGeometry(0.62, 0.56, 0.44), { pos: V(0, 0.9, 0) });
	b.add('body', M.pants, new THREE.BoxGeometry(0.56, 0.18, 0.4), { pos: V(0, 0.55, 0) });
	b.add('body', M.black, new THREE.BoxGeometry(0.64, 0.06, 0.46), { pos: V(0, 0.65, 0) });
	b.add('body', M.gold, new THREE.BoxGeometry(0.08, 0.06, 0.03), { pos: V(0, 0.65, 0.235) });
	b.add('head', skin, new THREE.BoxGeometry(0.44, 0.38, 0.4), { pos: V(0, 1.45, 0) });
	for (const s of [-1, 1]) {
		limb(b, 'legs', M.pants, V(s * 0.16, 0.48, 0), V(s * 0.16, 0.08, 0), 0.045, 5);
		b.add('legs', M.black, new THREE.BoxGeometry(0.13, 0.08, 0.22), { pos: V(s * 0.16, 0.04, 0.04) });
		limb(b, 'arms', M.shirt, V(s * 0.33, 1.08, 0), V(s * 0.38, 0.62, 0.04), 0.04, 5);
		b.add('arms', skin, new THREE.BoxGeometry(0.1, 0.1, 0.1), { pos: V(s * 0.38, 0.58, 0.04) });
	}
	eyes(b, 1.48, 0.2, 0.1, 0.075);
	cap(b, 1.64, 0.23);
}

// 5. Fideo: tall noodle body with a small head and long dangly arms down to the knees; short legs.
function fideo(b, skin) {
	b.add('body', M.shirt, loft([
		{ y: 0.5, rx: 0.17, rz: 0.15 }, { y: 0.9, rx: 0.15, rz: 0.13 }, { y: 1.4, rx: 0.16, rz: 0.14 }, { y: 1.62, rx: 0.12, rz: 0.11 },
	], 8, { capBottom: true }));
	b.add('body', skin, loft([
		{ y: 1.62, rx: 0.12, rz: 0.11 }, { y: 1.78, rx: 0.1, rz: 0.09 },
	], 8));
	b.add('head', skin, ellipsoid(0.16, 0.19, 0.15, 10, 7), { pos: V(0, 1.92, 0.02) });
	belt(b, 0.62, 0.175, 0.155);
	for (const s of [-1, 1]) {
		limb(b, 'legs', M.pants, V(s * 0.08, 0.54, 0), V(s * 0.1, 0.08, 0), 0.06);
		b.add('legs', M.black, ellipsoid(0.08, 0.06, 0.14, 6, 4), { pos: V(s * 0.1, 0.05, 0.04) });
		limb(b, 'arms', M.shirt, V(s * 0.16, 1.5, 0), V(s * 0.3, 1.0, 0.03), 0.04);
		limb(b, 'arms', M.shirt, V(s * 0.3, 1.0, 0.03), V(s * 0.32, 0.45, 0.06), 0.04);
		b.add('arms', skin, ellipsoid(0.07, 0.09, 0.06, 6, 4), { pos: V(s * 0.32, 0.38, 0.06) });
	}
	eyes(b, 1.95, 0.14, 0.065, 0.05);
	cap(b, 2.08, 0.15, 0.01);
}

export const BODIES = { frijol, cabezon, pera, caja, fideo };

export function buildBody(shape, skin = 0) {
	const b = new Builder(`body_${shape}_${skin}`);
	BODIES[shape](b, mat(`skin_${SKINS[skin].name}`, SKINS[skin].color));
	return b.build();
}

const names = Object.keys(BODIES);
export const previews = Object.fromEntries(names.flatMap((n) => [0, 1, 2, 3].map((s) => [`body_${n}_${s}`, () => buildBody(n, s)])));

export const views = {
	cuerpos_todos: {
		items: names.map((n, i) => ({ name: `body_${n}_${i % 4}`, pos: [(i - 2) * 1.15, 0, 0], rotY: 0.35 })),
		cam: { pos: [0, 1.4, 8.2], target: [0, 1.0, 0], fov: 34 },
	},
	...Object.fromEntries(names.map((n) => [`cuerpo_${n}`, {
		items: [
			...[0, 1, 2, 3].map((s) => ({ name: `body_${n}_${s}`, pos: [(s - 2) * 1.05, 0, 0], rotY: 0.3 })),
			{ name: `body_${n}_0`, pos: [2.3, 0, 0], rotY: Math.PI / 2 },
		],
		cam: { pos: [0, 1.4, 7.4], target: [0, 1.0, 0], fov: 34 },
	}])),
};
