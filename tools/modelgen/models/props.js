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

export const models = { crate: buildCrate, safe: buildSafe };

export const views = {
	props: {
		items: [{ name: 'crate', pos: [-0.5, 0.25, 0], rotY: 0.4 }, { name: 'safe', pos: [0.5, 0.32, 0], rotY: -0.4 }, { name: 'cop_0', pos: [1.6, 0, -0.5], rotY: -0.3 }],
		cam: { pos: [0.3, 1.5, 4.2], target: [0.3, 0.6, 0], fov: 32 },
	},
};
