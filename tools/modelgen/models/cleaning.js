// The cleaning crew's jailbreak (fuga-limpieza.md): Clotilde's cleaning cart. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';
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

export const models = { cleaning_cart: buildCleaningCart };

export const views = {
	cleaning_cart: { items: [{ name: 'cleaning_cart', pos: [0, 0, 0], rotY: 0.5 }, { name: 'npc_limpieza', pos: [1.0, 0, 0.2], rotY: -0.3 }], cam: { pos: [0.4, 1.4, 3.4], target: [0.4, 0.7, 0], fov: 40 } },
};
