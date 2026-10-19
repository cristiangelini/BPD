// Pear body shared by every character (decision 72): bottom-heavy, no legs, big shoes, a small head on top.
// Cops all wear the blue uniform and the skin color tells the four players apart. Placeholder, not final art.
import { Builder, loft, ellipsoid, mat, V, THREE } from '../lib.js';

export const SKINS = [
	{ name: 'rosa', color: 0xff86b0 },
	{ name: 'naranja', color: 0xff9d3f },
	{ name: 'lima', color: 0x9ee05c },
	{ name: 'violeta', color: 0xac8cff },
];

export const M = {
	shirt: mat('shirt', 0x2f6bff),
	pants: mat('pants', 0x1b2a6b),
	cap: mat('cap', 0x1b2a6b),
	black: mat('black', 0x15151a),
	white: mat('white', 0xf6f4ee),
	gold: mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }),
};

// Cylinder from a to b (limbs).
export function limb(b, part, m, a, c, r, sides = 6) {
	const d = c.clone().sub(a);
	b.add(part, m, new THREE.CylinderGeometry(r, r, d.length(), sides, 1), { pos: a.clone().add(c).multiplyScalar(0.5), lookAt: d });
	b.add(part, m, ellipsoid(r, r, r, sides, 4), { pos: c });
}

// Two big eyes looking forward (+Z) on a surface at depth z.
export function eyes(b, y, z, gap, size) {
	for (const s of [-1, 1]) {
		b.add('face', M.white, ellipsoid(size, size * 1.15, size * 0.45, 8, 6), { pos: V(s * gap, y, z) });
		b.add('face', M.black, ellipsoid(size * 0.45, size * 0.55, size * 0.25, 6, 4), { pos: V(s * gap, y, z + size * 0.35) });
	}
}

// Police cap sitting on a head top.
export function cap(b, y, r, z = 0) {
	b.add('cap', M.cap, new THREE.CylinderGeometry(r * 1.05, r * 0.95, r * 0.55, 8), { pos: V(0, y + r * 0.2, z) });
	b.add('cap', M.black, new THREE.CylinderGeometry(r * 0.8, r * 0.8, 0.02, 8, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, y - 0.03, z + r * 0.35) });
	b.add('cap', M.gold, new THREE.CylinderGeometry(r * 0.16, r * 0.16, 0.012, 5), { pos: V(0, y + r * 0.22, z + r * 1.0), rot: [Math.PI / 2, 0, 0] });
}

export function belt(b, y, rx, rz) {
	b.add('body', M.black, loft([{ y: y - 0.035, rx, rz }, { y: y + 0.035, rx, rz }], 10));
	b.add('body', M.gold, new THREE.BoxGeometry(0.08, 0.06, 0.03), { pos: V(0, y, rz) });
}

// Outfit colors are parameters so NPCs reuse the same body. 1.55 m to the cap, faces +Z, feet at y = 0.
export function pearBody(b, skin, { shirt = M.shirt, pants = M.pants, shoes = M.black, belted = true, onePiece = false } = {}) {
	b.add('body', onePiece ? shirt : pants, loft([
		{ y: 0.1, rx: 0.36, rz: 0.32 }, { y: 0.3, rx: 0.48, rz: 0.43 }, { y: 0.5, rx: 0.46, rz: 0.41 },
	], 10, { capBottom: true }));
	b.add('body', shirt, loft([
		{ y: 0.5, rx: 0.46, rz: 0.41 }, { y: 0.8, rx: 0.36, rz: 0.32 }, { y: 1.05, rx: 0.24, rz: 0.22 }, { y: 1.15, rx: 0.15, rz: 0.14 },
	], 10, { capTop: true }));
	if (belted) belt(b, 0.52, 0.465, 0.415);
	b.add('head', skin, ellipsoid(0.2, 0.22, 0.19, 10, 7), { pos: V(0, 1.3, 0.02) });
	for (const s of [-1, 1]) {
		b.add('legs', shoes, ellipsoid(0.14, 0.08, 0.2, 6, 4), { pos: V(s * 0.2, 0.07, 0.12) });
		limb(b, 'arms', shirt, V(s * 0.3, 0.85, 0), V(s * 0.46, 0.68, 0.08), 0.06);
		b.add('arms', skin, ellipsoid(0.075, 0.075, 0.075, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	}
}
// Rookie cop: blue uniform, cap and player skin.
export function buildCop(skin) {
	const b = new Builder(`cop_${skin}`);
	pearBody(b, mat(`skin_${SKINS[skin].name}`, SKINS[skin].color));
	eyes(b, 1.33, 0.17, 0.08, 0.055);
	cap(b, 1.47, 0.17, 0.01);
	return b.build();
}

export const models = Object.fromEntries([0, 1, 2, 3].map((s) => [`cop_${s}`, () => buildCop(s)]));

export const views = {
	cops_front: {
		items: [0, 1, 2, 3].map((s) => ({ name: `cop_${s}`, pos: [(s - 1.5) * 1.1, 0, 0], rotY: 0.3 })),
		cam: { pos: [0, 1.3, 6.6], target: [0, 0.85, 0], fov: 34 },
	},
};
