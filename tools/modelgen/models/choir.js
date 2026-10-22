// The church choir's things (docs/diseno/infiltracion-coro.md): the collection box with its false bottom.
// Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

// The collection box "para el órgano nuevo": a small wooden box with a coin slot and a brass plate, and a thin false
// bottom drawer showing at its foot. 0.26 x 0.2 x 0.18 m, origin in its middle.
export function buildCollectionBox() {
	const b = new Builder('collection_box');
	const wood = mat('collection_wood', 0x6a4426), dark = mat('collection_dark', 0x2a1a10);
	const brass = mat('collection_brass', 0xd0a848, { emissive: 0x201808 });
	b.add('box', wood, new THREE.BoxGeometry(0.26, 0.17, 0.18), { pos: V(0, 0.015, 0) });
	b.add('drawer', wood, new THREE.BoxGeometry(0.24, 0.03, 0.17), { pos: V(0, -0.085, 0.01) });
	b.add('drawer', dark, new THREE.BoxGeometry(0.1, 0.008, 0.005), { pos: V(0, -0.085, 0.096) });
	b.add('slot', dark, new THREE.BoxGeometry(0.1, 0.005, 0.02), { pos: V(0, 0.101, 0) });
	b.add('plate', brass, new THREE.BoxGeometry(0.14, 0.05, 0.005), { pos: V(0, 0.03, 0.092) });
	return b.build();
}

export const models = { collection_box: buildCollectionBox };

export const views = {
	choir_things: {
		items: [{ name: 'collection_box', pos: [0, 0.1, 0], rotY: 0.4 }],
		cam: { pos: [0, 0.4, 0.9], target: [0, 0.08, 0], fov: 40 },
	},
};
