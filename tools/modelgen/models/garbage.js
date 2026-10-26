// The garbage truck jailbreak (fuga-basura.md): the cell's trash bin, the guard's giant garbage bag and the dumpster on
// the station's sidewalk. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// A cell's trash bin: a dented metal can, 0.3 m wide and 0.45 m tall, the origin on the floor.
export function buildTrashBin() {
	const b = new Builder('trash_bin');
	const tin = mat('bin_tin', 0x8a9098);
	b.add('bin', tin, new THREE.CylinderGeometry(0.16, 0.13, 0.45, 12, 1, true), { pos: V(0, 0.225, 0) });
	b.add('bin', mat('bin_bottom', 0x5a6068), new THREE.CylinderGeometry(0.13, 0.13, 0.01, 12), { pos: V(0, 0.005, 0) });
	b.add('bin', mat('bin_rim', 0xa0a6ae), new THREE.TorusGeometry(0.16, 0.012, 6, 16), { pos: V(0, 0.45, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('peel', mat('banana_peel', 0xe0c040), ellipsoid(0.06, 0.02, 0.03, 8, 4), { pos: V(0.03, 0.43, 0.02), rot: [0, 0, 0.4] });
	return b.build();
}

// The giant garbage bag, black and lumpy, 0.9 m tall and 0.7 m wide (a crouched cop fits), the origin on the floor,
// knotted at the top.
export function buildGarbageBag() {
	const b = new Builder('garbage_bag');
	const plastic = mat('bag_plastic', 0x1c1c20, { roughness: 0.35 });
	b.add('bag', plastic, ellipsoid(0.36, 0.42, 0.34, 14, 10), { pos: V(0, 0.42, 0) });
	b.add('bag', plastic, ellipsoid(0.2, 0.14, 0.18, 10, 6), { pos: V(0.12, 0.2, 0.16) });
	b.add('bag', plastic, ellipsoid(0.18, 0.16, 0.2, 10, 6), { pos: V(-0.14, 0.62, -0.1) });
	b.add('bag', plastic, new THREE.ConeGeometry(0.08, 0.16, 8), { pos: V(0, 0.9, 0) });
	b.add('bag', mat('bag_tie', 0xd03030), new THREE.TorusGeometry(0.05, 0.012, 6, 12), { pos: V(0, 0.86, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The dumpster on the sidewalk: green, 1.8 x 1.3 x 1.1 m, lid open, the origin on the ground, the front at +Z.
export function buildDumpster() {
	const b = new Builder('dumpster');
	const green = mat('dumpster_green', 0x2f6b3a);
	b.add('body', green, new THREE.BoxGeometry(1.8, 0.08, 1.1), { pos: V(0, 0.2, 0) });
	b.add('body', green, new THREE.BoxGeometry(1.8, 1.1, 0.06), { pos: V(0, 0.7, -0.52) });
	b.add('body', green, new THREE.BoxGeometry(1.8, 1.0, 0.06), { pos: V(0, 0.65, 0.52) });
	for (const s of [-1, 1]) b.add('body', green, new THREE.BoxGeometry(0.06, 1.1, 1.1), { pos: V(s * 0.87, 0.7, 0) });
	b.add('lid', mat('dumpster_lid', 0x24552e), new THREE.BoxGeometry(1.8, 0.05, 1.1), { pos: V(0, 1.55, -0.95), rot: [-1.2, 0, 0] });
	const wheel = mat('dumpster_wheel', 0x222222);
	for (const x of [-0.7, 0.7]) for (const z of [-0.4, 0.4]) {
		b.add('body', wheel, new THREE.CylinderGeometry(0.08, 0.08, 0.06, 10), { pos: V(x, 0.08, z), rot: [0, 0, Math.PI / 2] });
	}
	b.add('body', mat('dumpster_sign', 0xe8e8e8), new THREE.BoxGeometry(0.5, 0.2, 0.01), { pos: V(0, 0.8, 0.56) });
	return b.build();
}

export const models = { trash_bin: buildTrashBin, garbage_bag: buildGarbageBag, dumpster: buildDumpster };

export const views = {
	garbage: {
		items: [
			{ name: 'trash_bin', pos: [-1.2, 0, 0.6] },
			{ name: 'garbage_bag', pos: [-0.4, 0, 0.6] },
			{ name: 'dumpster', pos: [1.0, 0, 0] },
			{ name: 'cop_1', pos: [-1.8, 0, -0.4], rotY: 0.5 },
		],
		cam: { pos: [0, 1.8, 4.2], target: [0, 0.6, 0], fov: 45 },
	},
};
