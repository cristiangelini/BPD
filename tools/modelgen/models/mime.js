// The mime troupe's things (docs/diseno/infiltracion-mimos.md): the "invisible" box, which is really clear acrylic
// full of wallets, and the cloth bag of other people's watches from the trunk.
// Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

// The invisible box: a clear acrylic cube with its edges just showing and a pile of wallets inside. 0.4 m a side,
// origin in its middle.
export function buildInvisibleBox() {
	const b = new Builder('invisible_box');
	const glass = mat('acrylic', 0xdff4ff, { transparent: true, opacity: 0.18, roughness: 0.1 });
	const edge = mat('acrylic_edge', 0xeef8ff, { transparent: true, opacity: 0.6 });
	b.add('box', glass, new THREE.BoxGeometry(0.4, 0.4, 0.4));
	for (const [sx, sy, sz, x, y, z] of [
		[0.41, 0.01, 0.01, 0, 0.2, 0.2], [0.41, 0.01, 0.01, 0, -0.2, 0.2], [0.41, 0.01, 0.01, 0, 0.2, -0.2], [0.41, 0.01, 0.01, 0, -0.2, -0.2],
		[0.01, 0.41, 0.01, 0.2, 0, 0.2], [0.01, 0.41, 0.01, -0.2, 0, 0.2], [0.01, 0.41, 0.01, 0.2, 0, -0.2], [0.01, 0.41, 0.01, -0.2, 0, -0.2],
		[0.01, 0.01, 0.41, 0.2, 0.2, 0], [0.01, 0.01, 0.41, -0.2, 0.2, 0], [0.01, 0.01, 0.41, 0.2, -0.2, 0], [0.01, 0.01, 0.41, -0.2, -0.2, 0],
	]) b.add('edges', edge, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z) });
	const colors = [0x5a3420, 0x1e1e24, 0x8a2a2a, 0x6a4a2a, 0x2a3a5a, 0x3a2a1a, 0x7a5a3a, 0x222a22];
	for (let i = 0; i < colors.length; i++) {
		const wallet = mat(`wallet_${i}`, colors[i]);
		b.add('wallets', wallet, new THREE.BoxGeometry(0.11, 0.025, 0.09), {
			pos: V(-0.1 + (i % 3) * 0.1, -0.18 + Math.floor(i / 3) * 0.03, -0.08 + ((i * 5) % 3) * 0.08), rot: [0, i * 0.7, 0],
		});
	}
	return b.build();
}

// The bag of watches: a drawstring cloth bag with watch straps and a gold face peeking out. 0.24 x 0.26 x 0.2 m,
// origin in its middle.
export function buildWatchBag() {
	const b = new Builder('watch_bag');
	const cloth = mat('bag_cloth', 0x8a6a48), cord = mat('bag_cord', 0xd8c8a0);
	const gold = mat('watch_gold', 0xd8b040, { emissive: 0x302008 }), strap = mat('watch_strap', 0x2a1a10);
	b.add('bag', cloth, new THREE.SphereGeometry(0.12, 10, 7), { pos: V(0, -0.03, 0), scale: [1, 0.9, 0.85] });
	b.add('bag', cloth, new THREE.CylinderGeometry(0.04, 0.07, 0.06, 8), { pos: V(0, 0.09, 0) });
	b.add('cord', cord, new THREE.TorusGeometry(0.045, 0.006, 4, 10), { pos: V(0, 0.1, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('watches', gold, new THREE.CylinderGeometry(0.025, 0.025, 0.008, 10), { pos: V(0.03, 0.125, 0.01), rot: [0.4, 0, 0.3] });
	b.add('watches', strap, new THREE.BoxGeometry(0.02, 0.07, 0.004), { pos: V(-0.03, 0.13, 0.02), rot: [0.3, 0, -0.5] });
	return b.build();
}

// Maestra Pausa's invisible car (step 6): almost nothing, just the faint outline of a small car around her, so the cops
// can tell which way she's "driving". 1.6 x 1.1 x 2.6 m, faces +Z, origin on the ground in its middle.
export function buildInvisibleCar() {
	const b = new Builder('invisible_car');
	const ghost = mat('invisible_car', 0xeef6ff, { transparent: true, opacity: 0.12, roughness: 0.1 });
	const edge = mat('invisible_car_edge', 0xffffff, { transparent: true, opacity: 0.35 });
	b.add('body', ghost, new THREE.BoxGeometry(1.6, 0.5, 2.6), { pos: V(0, 0.45, 0) });
	b.add('body', ghost, new THREE.BoxGeometry(1.4, 0.45, 1.3), { pos: V(0, 0.92, -0.2) });
	for (const [x, z] of [[-0.8, 1.3], [0.8, 1.3], [-0.8, -1.3], [0.8, -1.3]]) {
		b.add('edges', edge, new THREE.BoxGeometry(0.02, 0.5, 0.02), { pos: V(x, 0.45, z) });
		b.add('wheels', edge, new THREE.TorusGeometry(0.22, 0.015, 4, 12), { pos: V(x, 0.22, z * 0.75), rot: [0, Math.PI / 2, 0] });
	}
	for (const z of [1.3, -1.3]) b.add('edges', edge, new THREE.BoxGeometry(1.6, 0.02, 0.02), { pos: V(0, 0.7, z) });
	return b.build();
}

export const models = { invisible_box: buildInvisibleBox, watch_bag: buildWatchBag, invisible_car: buildInvisibleCar };

export const views = {
	mime_evidence: {
		items: [{ name: 'invisible_box', pos: [-0.3, 0.2, 0] }, { name: 'watch_bag', pos: [0.35, 0.12, 0.1] }],
		cam: { pos: [0, 0.6, 1.4], target: [0, 0.15, 0], fov: 40 },
	},
	invisible_car: {
		items: [{ name: 'invisible_car', pos: [0, 0, 0], rotY: 0.6 }, { name: 'npc_pausa', pos: [0, 0, 0.1], rotY: 0.6, scale: 0.95 }],
		cam: { pos: [2.4, 1.8, 3.6], target: [0, 0.7, 0], fov: 40 },
	},
};
