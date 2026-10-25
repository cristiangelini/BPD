// The cleaning crew's jailbreak (fuga-limpieza.md): Clotilde's cleaning cart, the mop and the feather duster. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';
import { limb } from './pear.js';

// Clotilde's cart: 0.9 x 1.0 x 0.5 m, grey frame on wheels with a yellow bucket, a trash bag, bottles on the top tray
// and a mop standing in the bucket. The key ring hangs from a hook at the front of the top tray (the level puts the
// CellKey there).
export function buildCleaningCart() {
	const b = new Builder('cleaning_cart');
	const frame = mat('cart_grey', 0x8a9098), dark = mat('cart_dark', 0x3a3e44);
	b.add('frame', frame, new THREE.BoxGeometry(0.9, 0.04, 0.5), { pos: V(0, 0.2, 0) });
	b.add('frame', frame, new THREE.BoxGeometry(0.9, 0.04, 0.5), { pos: V(0, 0.95, 0) });
	for (const x of [-0.42, 0.42]) for (const z of [-0.22, 0.22]) {
		b.add('frame', frame, new THREE.CylinderGeometry(0.02, 0.02, 0.8, 6), { pos: V(x, 0.58, z) });
		b.add('wheels', dark, new THREE.CylinderGeometry(0.07, 0.07, 0.04, 10), { pos: V(x, 0.07, z), rot: [0, 0, Math.PI / 2] });
	}
	b.add('bucket', mat('bucket_yellow', 0xf2c81a), new THREE.CylinderGeometry(0.17, 0.14, 0.3, 12), { pos: V(-0.22, 0.37, 0) });
	b.add('bucket', mat('water', 0x6ab0d0), new THREE.CylinderGeometry(0.16, 0.16, 0.01, 12), { pos: V(-0.22, 0.5, 0) });
	b.add('bag', mat('trash_bag', 0x22262a), new THREE.SphereGeometry(0.2, 8, 6), { pos: V(0.22, 0.4, 0), scale: [1, 1.1, 1] });
	const bottles = [mat('bottle_green', 0x3ac06a), mat('bottle_blue', 0x3a7ae0), mat('bottle_pink', 0xe05aa0)];
	bottles.forEach((m, i) => b.add('bottles', m, new THREE.CylinderGeometry(0.045, 0.05, 0.22, 8), { pos: V(-0.25 + i * 0.16, 1.08, -0.08) }));
	b.add('mop', mat('mop_handle', 0x2a6ad0), new THREE.CylinderGeometry(0.018, 0.018, 1.4, 6), { pos: V(-0.22, 1.1, 0.02), rot: [0.12, 0, 0] });
	b.add('mop', mat('mop_head', 0xe8e4d8), new THREE.CylinderGeometry(0.1, 0.12, 0.12, 8), { pos: V(-0.22, 0.46, -0.02) });
	limb(b, 'hook', dark, V(0.3, 0.97, 0.25), V(0.3, 0.92, 0.3), 0.012, 4);
	return b.build();
}

// A mop, 1.5 m: the grip at the origin and the head at the far end (-Z), like the jailbreak's broom (HookStick).
export function buildMop() {
	const b = new Builder('mop');
	b.add('stick', mat('mop_handle', 0x2a6ad0), new THREE.CylinderGeometry(0.018, 0.018, 1.45, 6), { pos: V(0, 0, -0.72), rot: [Math.PI / 2, 0, 0] });
	b.add('head', mat('mop_cap', 0x3a3e44), new THREE.CylinderGeometry(0.04, 0.05, 0.06, 8), { pos: V(0, 0, -1.45), rot: [Math.PI / 2, 0, 0] });
	const string = mat('mop_head', 0xe8e4d8);
	for (let i = 0; i < 8; i++) {
		const a = (i / 8) * Math.PI * 2;
		b.add('head', string, new THREE.CylinderGeometry(0.018, 0.012, 0.16, 4), { pos: V(Math.cos(a) * 0.04, Math.sin(a) * 0.04, -1.54), rot: [Math.PI / 2 + Math.sin(a) * 0.4, 0, -Math.cos(a) * 0.4] });
	}
	return b.build();
}

// A feather duster, 0.8 m: a wooden handle and a puff of colored feathers at the far end (-Z).
export function buildFeatherDuster() {
	const b = new Builder('feather_duster');
	b.add('stick', mat('duster_wood', 0xb07a40), new THREE.CylinderGeometry(0.015, 0.015, 0.65, 6), { pos: V(0, 0, -0.32), rot: [Math.PI / 2, 0, 0] });
	const colors = [0xd84a8a, 0x5ac0e0, 0xf2c84a, 0x7ad05a];
	for (let i = 0; i < 10; i++) {
		const a = (i / 10) * Math.PI * 2;
		b.add('feathers', mat(`feather_${i % 4}`, colors[i % 4]), ellipsoid(0.04, 0.04, 0.1, 5, 3), { pos: V(Math.cos(a) * 0.05, Math.sin(a) * 0.05, -0.72 - (i % 2) * 0.04) });
	}
	return b.build();
}

export const models = { cleaning_cart: buildCleaningCart, mop: buildMop, feather_duster: buildFeatherDuster };

export const views = {
	cleaning_closet: {
		items: [
			{ name: 'mop', pos: [-0.6, 0.05, 0.6], rotY: 0.2 },
			{ name: 'feather_duster', pos: [0.2, 0.05, 0.6], rotY: -0.2 },
			{ name: 'disguise_cleaner_cap', pos: [-0.5, 0.0, 0.5] },
			{ name: 'disguise_face_mask', pos: [-0.1, 0.06, 0.5] },
			{ name: 'folded_vest', pos: [0.35, 0.04, 0.5] },
			{ name: 'disguise_cleaner_cap', pos: [1.2, 1.42, 0], rotY: Math.PI },
			{ name: 'disguise_face_mask', pos: [1.2, 1.22, -0.2], rotY: Math.PI },
			{ name: 'disguise_cleaner_vest', pos: [1.2, 0.95, -0.3], rotY: Math.PI },
			{ name: 'cop_1', pos: [1.2, 0, 0], rotY: Math.PI },
		],
		cam: { pos: [0.3, 1.3, -3.2], target: [0.3, 0.6, 0], fov: 45 },
	},
	cleaning_cart: { items: [{ name: 'cleaning_cart', pos: [0, 0, 0], rotY: 0.5 }, { name: 'npc_limpieza', pos: [1.0, 0, 0.2], rotY: -0.3 }], cam: { pos: [0.4, 1.4, 3.4], target: [0.4, 0.7, 0], fov: 40 } },
};
