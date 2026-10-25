// The spoon tunnel jailbreak (fuga-tunel.md): the dinner spoons the cops dig with and the bunk's mattress that hides the
// hole. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// A dinner spoon, 0.18 m: the bowl at +Z, the origin in its middle.
export function buildSpoon() {
	const b = new Builder('tunnel_spoon');
	const steel = mat('spoon_steel', 0xc8ccd2);
	b.add('spoon', steel, new THREE.BoxGeometry(0.012, 0.004, 0.12), { pos: V(0, 0, -0.03) });
	b.add('spoon', steel, ellipsoid(0.022, 0.008, 0.032, 8, 4), { pos: V(0, 0.002, 0.06) });
	return b.build();
}

// The bunk's mattress: striped ticking, 1.9 x 0.12 x 0.75 m, the origin in its middle.
export function buildMattress() {
	const b = new Builder('tunnel_mattress');
	b.add('mattress', mat('mattress', 0xe8e0cc), new THREE.BoxGeometry(1.9, 0.12, 0.75));
	const stripe = mat('mattress_stripe', 0x6a8ab0);
	for (let i = -3; i <= 3; i++) b.add('mattress', stripe, new THREE.BoxGeometry(1.902, 0.122, 0.03), { pos: V(0, 0, i * 0.1) });
	b.add('mattress', mat('mattress_stain', 0xc8b890), ellipsoid(0.2, 0.002, 0.14, 8, 2), { pos: V(0.4, 0.061, 0.1) });
	return b.build();
}

export const models = { tunnel_spoon: buildSpoon, tunnel_mattress: buildMattress };

export const views = {
	tunnel: {
		items: [
			{ name: 'prison_tray', pos: [0, 0.02, 0.4] },
			{ name: 'tunnel_spoon', pos: [-0.08, 0.03, 0.4], rotY: 0.3 },
			{ name: 'tunnel_spoon', pos: [0.08, 0.03, 0.4], rotY: -0.2 },
			{ name: 'tunnel_mattress', pos: [0.2, 0.06, -0.6], rotY: 0.2 },
			{ name: 'cop_1', pos: [1.1, 0, 0], rotY: -0.6 },
		],
		cam: { pos: [0.3, 1.5, 2.6], target: [0.3, 0.3, 0], fov: 45 },
	},
};
