// Rookie cop: chunky bean body, stubby legs, round head, big peaked cap, mustache. 1.8 m tall, faces +Z, feet at y = 0.
// Placeholder look for gameplay (not final art): low poly with flat facets and strong colors (decision 12, R.E.P.O. / PEAK).
import { Builder, loft, tube, ellipsoid, mat, V, THREE } from '../lib.js';

// Uniform colors per cop, so the four friends tell each other apart (cosmetics come later, decision 13).
export const UNIFORMS = [
	{ name: 'azul', shirt: 0x2f6bff, pants: 0x1b2a6b },
	{ name: 'verde', shirt: 0x22b35a, pants: 0x135a32 },
	{ name: 'rojo', shirt: 0xe8432e, pants: 0x7a1d16 },
	{ name: 'amarillo', shirt: 0xffbf1f, pants: 0x7a5410 },
];

export function buildCop({ uniform = 0, name = `cop_${uniform}` } = {}) {
	const U = UNIFORMS[uniform];
	const M = {
		skin: mat('skin', 0xe8b48a),
		shirt: mat('shirt', U.shirt),
		pants: mat('pants', U.pants),
		black: mat('black', 0x1a1a1f),
		gold: mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }),
		white: mat('white', 0xf4f1ea),
		hair: mat('hair', 0x3b2618),
		tie: mat('tie', 0x15192b),
	};
	const b = new Builder(name);

	// Legs: short and thick, with big shoes.
	for (const s of [-1, 1]) {
		b.add('legs', M.pants, loft([
			{ y: 0.1, rx: 0.11, rz: 0.12 },
			{ y: 0.35, rx: 0.12, rz: 0.13 },
			{ y: 0.62, rx: 0.14, rz: 0.15 },
		], 7, { capBottom: true }), { pos: V(s * 0.15, 0, 0) });
		b.add('legs', M.black, ellipsoid(0.13, 0.08, 0.2, 8, 5), { pos: V(s * 0.15, 0.07, 0.05) });
	}

	// Body: a bean, wider at the belly.
	b.add('body', M.shirt, loft([
		{ y: 0.58, rx: 0.3, rz: 0.26 },
		{ y: 0.72, rx: 0.38, rz: 0.33 },
		{ y: 0.95, rx: 0.4, rz: 0.36 },
		{ y: 1.2, rx: 0.36, rz: 0.31 },
		{ y: 1.36, rx: 0.27, rz: 0.24 },
		{ y: 1.42, rx: 0.15, rz: 0.14 },
	], 10, { capBottom: true, capTop: true }));
	// Belt with buckle, radio and cuffs pouch.
	b.add('body', M.black, loft([{ y: 0.66, rx: 0.36, rz: 0.315 }, { y: 0.74, rx: 0.39, rz: 0.335 }], 10));
	b.add('body', M.gold, new THREE.BoxGeometry(0.1, 0.07, 0.03), { pos: V(0, 0.7, 0.34) });
	b.add('body', M.black, new THREE.BoxGeometry(0.08, 0.14, 0.06), { pos: V(0.33, 0.72, 0.14), rot: [0, 0.6, 0] });
	b.add('body', M.black, new THREE.CylinderGeometry(0.008, 0.008, 0.1), { pos: V(0.34, 0.83, 0.13) });
	b.add('body', M.black, new THREE.BoxGeometry(0.1, 0.08, 0.06), { pos: V(-0.3, 0.7, 0.2), rot: [0, -0.7, 0] });
	// Tie and badge.
	b.add('body', M.tie, new THREE.ConeGeometry(0.045, 0.32, 4), { pos: V(0, 1.2, 0.33), rot: [Math.PI + 0.15, Math.PI / 4, 0] });
	b.add('body', M.gold, new THREE.CylinderGeometry(0.045, 0.045, 0.015, 6), { pos: V(-0.17, 1.15, 0.31), rot: [Math.PI / 2 - 0.35, 0, 0] });
	// Breast pockets.
	for (const s of [-1, 1]) b.add('body', M.pants, new THREE.BoxGeometry(0.11, 0.09, 0.02), { pos: V(s * 0.15, 1.04, 0.35), rot: [-0.25, s * 0.25, 0] });

	// Arms: sausages hanging a bit out, with mitten hands.
	for (const s of [-1, 1]) {
		b.add('arms', M.shirt, tube([V(s * 0.36, 1.3, 0), V(s * 0.46, 1.08, 0.03), V(s * 0.5, 0.84, 0.06)], (t) => 0.085 - 0.015 * t, { radial: 6, segs: 3, closed: true }));
		b.add('arms', M.skin, ellipsoid(0.075, 0.09, 0.07, 6, 4), { pos: V(s * 0.51, 0.76, 0.07) });
	}

	// Head: a big round ball with ears, nose, eyes and mustache.
	b.add('head', M.skin, ellipsoid(0.22, 0.23, 0.21, 12, 8), { pos: V(0, 1.6, 0.02) });
	for (const s of [-1, 1]) b.add('head', M.skin, ellipsoid(0.04, 0.06, 0.03, 6, 4), { pos: V(s * 0.215, 1.6, 0) });
	b.add('head', M.skin, ellipsoid(0.05, 0.045, 0.05, 6, 4), { pos: V(0, 1.58, 0.225) });
	for (const s of [-1, 1]) {
		b.add('head', M.white, ellipsoid(0.045, 0.05, 0.02, 8, 5), { pos: V(s * 0.085, 1.66, 0.19), rot: [0, s * 0.35, 0] });
		b.add('head', M.black, ellipsoid(0.02, 0.025, 0.012, 6, 4), { pos: V(s * 0.08, 1.655, 0.207), rot: [0, s * 0.35, 0] });
		b.add('head', M.hair, ellipsoid(0.075, 0.03, 0.035, 6, 4), { pos: V(s * 0.06, 1.52, 0.205), rot: [0, s * 0.4, s * -0.35] });
	}

	// Peaked cap: crown, band, visor and badge.
	b.add('cap', M.pants, loft([
		{ y: 1.73, rx: 0.215, rz: 0.205 },
		{ y: 1.82, rx: 0.25, rz: 0.24 },
		{ y: 1.86, rx: 0.26, rz: 0.25, cz: 0.02 },
		{ y: 1.87, rx: 0.2, rz: 0.19, cz: 0.02 },
	], 10, { capTop: true }));
	b.add('cap', M.black, loft([{ y: 1.71, rx: 0.222, rz: 0.212 }, { y: 1.76, rx: 0.226, rz: 0.216 }], 10));
	b.add('cap', M.black, ellipsoid(0.2, 0.018, 0.14, 10, 4), { pos: V(0, 1.725, 0.17), rot: [0.25, 0, 0] });
	b.add('cap', M.gold, new THREE.CylinderGeometry(0.035, 0.035, 0.012, 5), { pos: V(0, 1.79, 0.235), rot: [Math.PI / 2 - 0.2, 0, 0] });

	return b.build();
}

export const models = Object.fromEntries([0, 1, 2, 3].map((u) => [`cop_${u}`, () => buildCop({ uniform: u })]));

export const views = {
	cops_front: {
		items: [0, 1, 2, 3].map((u) => ({ name: `cop_${u}`, pos: [(u - 1.5) * 1.15, 0, 0], rotY: 0.25 })),
		cam: { pos: [0, 1.3, 7.2], target: [0, 0.95, 0], fov: 30 },
	},
	cop_face: { items: [{ name: 'cop_0', rotY: 0.35 }], cam: { pos: [0, 1.65, 1.7], target: [0, 1.62, 0], fov: 30 } },
};
