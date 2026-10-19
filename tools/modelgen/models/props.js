// Props for the first raid: wooden crate (3 kg) and the small safe (40 kg). Sizes match scenes/props/*.tscn.
import { Builder, mat, V, THREE } from '../lib.js';

export function buildCrate() {
	const wood = mat('wood', 0xc58a4e), dark = mat('wood_dark', 0x8a5a30);
	const b = new Builder('crate');
	const s = 0.5;
	b.add('crate', wood, new THREE.BoxGeometry(s * 0.94, s * 0.94, s * 0.94));
	// Frame planks on every edge.
	const e = 0.06;
	for (const x of [-1, 1]) for (const z of [-1, 1]) b.add('crate', dark, new THREE.BoxGeometry(e, s, e), { pos: V(x * (s - e) / 2, 0, z * (s - e) / 2) });
	for (const y of [-1, 1]) for (const z of [-1, 1]) b.add('crate', dark, new THREE.BoxGeometry(s, e, e), { pos: V(0, y * (s - e) / 2, z * (s - e) / 2) });
	for (const y of [-1, 1]) for (const x of [-1, 1]) b.add('crate', dark, new THREE.BoxGeometry(e, e, s), { pos: V(x * (s - e) / 2, y * (s - e) / 2, 0) });
	// Diagonal brace on the front and back.
	for (const z of [-1, 1]) b.add('crate', dark, new THREE.BoxGeometry(e * 0.8, s * 1.2, 0.02), { pos: V(0, 0, z * s * 0.48), rot: [0, 0, Math.PI / 4] });
	return b.build();
}

export function buildSafe() {
	const steel = mat('steel', 0x4b5563), trim = mat('steel_dark', 0x2b313a), gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	const b = new Builder('safe');
	const s = 0.6;
	b.add('safe', steel, new THREE.BoxGeometry(s, s, s));
	b.add('safe', trim, new THREE.BoxGeometry(s * 0.8, s * 0.8, 0.03), { pos: V(0, 0, s / 2 + 0.01) });
	b.add('safe', gold, new THREE.CylinderGeometry(0.07, 0.07, 0.04, 8), { pos: V(-0.08, 0.04, s / 2 + 0.04), rot: [Math.PI / 2, 0, 0] });
	b.add('safe', steel, new THREE.BoxGeometry(0.04, 0.16, 0.05), { pos: V(0.17, 0, s / 2 + 0.05) });
	for (const x of [-1, 1]) for (const z of [-1, 1]) b.add('safe', trim, new THREE.BoxGeometry(0.08, 0.04, 0.08), { pos: V(x * 0.24, -s / 2 - 0.02, z * 0.24) });
	return b.build();
}

// Cookie tin: the main evidence of case 1.1 (3 kg, 1000). Round, 0.36 m wide and 0.16 m tall, centered.
export function buildCookieTin() {
	const tin = mat('tin', 0xd8343c), lid = mat('tin_lid', 0x2a5bd8), gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), label = mat('label', 0xf6f0dc);
	const b = new Builder('cookie_tin');
	b.add('tin', tin, new THREE.CylinderGeometry(0.17, 0.17, 0.13, 12), { pos: V(0, -0.015, 0) });
	b.add('tin', lid, new THREE.CylinderGeometry(0.18, 0.18, 0.04, 12), { pos: V(0, 0.06, 0) });
	b.add('tin', gold, new THREE.CylinderGeometry(0.182, 0.182, 0.012, 12), { pos: V(0, 0.04, 0) });
	b.add('tin', gold, new THREE.CylinderGeometry(0.06, 0.06, 0.012, 8), { pos: V(0, 0.083, 0) });
	b.add('tin', label, new THREE.BoxGeometry(0.16, 0.07, 0.02), { pos: V(0, -0.02, 0.165) });
	return b.build();
}

// The grandpa's fragile ornaments (case 1.1). Each is centered on its collision cylinder in scenes/props/ornament_*.tscn.
// Porcelain figurine of a little pear-shaped dog: 0.1 m wide, 0.16 m tall.
export function buildFigurine() {
	const porcelain = mat('porcelain', 0xf4f1ea), blue = mat('porcelain_blue', 0x3a6fd8), pink = mat('porcelain_pink', 0xff8fb1);
	const b = new Builder('ornament_figurine');
	b.add('figurine', blue, new THREE.CylinderGeometry(0.05, 0.05, 0.02, 10), { pos: V(0, -0.07, 0) });
	b.add('figurine', porcelain, new THREE.SphereGeometry(0.045, 8, 6), { pos: V(0, -0.025, 0), scale: [1, 1.1, 1] });
	b.add('figurine', porcelain, new THREE.SphereGeometry(0.03, 8, 6), { pos: V(0, 0.045, 0.005) });
	for (const x of [-1, 1]) b.add('figurine', pink, new THREE.SphereGeometry(0.014, 6, 4), { pos: V(x * 0.026, 0.07, 0), scale: [0.7, 1.4, 0.7] });
	b.add('figurine', blue, new THREE.BoxGeometry(0.07, 0.01, 0.06), { pos: V(0, 0.005, 0) });
	return b.build();
}

// Decorated plate lying flat: 0.22 m wide.
export function buildPlate() {
	const porcelain = mat('porcelain', 0xf4f1ea), blue = mat('porcelain_blue', 0x3a6fd8), gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	const b = new Builder('ornament_plate');
	b.add('plate', porcelain, new THREE.CylinderGeometry(0.11, 0.07, 0.02, 14));
	b.add('plate', gold, new THREE.CylinderGeometry(0.112, 0.112, 0.006, 14), { pos: V(0, 0.008, 0) });
	b.add('plate', blue, new THREE.CylinderGeometry(0.06, 0.06, 0.004, 10), { pos: V(0, 0.011, 0) });
	return b.build();
}

// Tall vase: 0.15 m wide, 0.26 m tall.
export function buildVase() {
	const glaze = mat('vase_glaze', 0x2fb8a0), white = mat('porcelain', 0xf4f1ea), gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	const b = new Builder('ornament_vase');
	b.add('vase', glaze, new THREE.CylinderGeometry(0.04, 0.05, 0.03, 10), { pos: V(0, -0.115, 0) });
	b.add('vase', glaze, new THREE.SphereGeometry(0.075, 10, 7), { pos: V(0, -0.04, 0), scale: [1, 1.15, 1] });
	b.add('vase', white, new THREE.CylinderGeometry(0.077, 0.077, 0.02, 10), { pos: V(0, -0.04, 0) });
	b.add('vase', glaze, new THREE.CylinderGeometry(0.035, 0.045, 0.1, 10), { pos: V(0, 0.07, 0) });
	b.add('vase', gold, new THREE.CylinderGeometry(0.05, 0.04, 0.02, 10), { pos: V(0, 0.12, 0) });
	return b.build();
}

export const models = {
	crate: buildCrate, safe: buildSafe, cookie_tin: buildCookieTin,
	ornament_figurine: buildFigurine, ornament_plate: buildPlate, ornament_vase: buildVase,
};

export const views = {
	props: {
		items: [{ name: 'crate', pos: [-0.5, 0.25, 0], rotY: 0.4 }, { name: 'safe', pos: [0.5, 0.32, 0], rotY: -0.4 }, { name: 'cookie_tin', pos: [-0.2, 0.08, 0.6], rotY: 0.3 }, { name: 'ornament_figurine', pos: [0.15, 0.08, 0.8], rotY: 0.4 }, { name: 'ornament_plate', pos: [0.45, 0.01, 0.75] }, { name: 'ornament_vase', pos: [0.75, 0.13, 0.7] }, { name: 'cop_0', pos: [1.6, 0, -0.5], rotY: -0.3 }],
		cam: { pos: [0.3, 1.5, 4.2], target: [0.3, 0.6, 0], fov: 32 },
	},
};
