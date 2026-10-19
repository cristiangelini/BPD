// Michi, the grandpa's cat (investigacion.md, "Más personajes en la casa"): a little pear like everyone else.
// 0.3 m tall, 0.4 m long, faces +Z, feet at y = 0. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, eyes } from './pear.js';

export function buildCat() {
	const fur = mat('cat_orange', 0xf0a040), stripe = mat('cat_stripe', 0xc0702a), pink = mat('cat_pink', 0xff9db5);
	const b = new Builder('cat_michi');
	b.add('body', fur, ellipsoid(0.13, 0.11, 0.18, 10, 7), { pos: V(0, 0.12, -0.02) });
	for (const z of [-0.08, 0.0, 0.08]) b.add('body', stripe, ellipsoid(0.132, 0.03, 0.025, 10, 4), { pos: V(0, 0.18, z - 0.02) });
	b.add('head', fur, ellipsoid(0.1, 0.09, 0.09, 10, 7), { pos: V(0, 0.22, 0.15) });
	for (const s of [-1, 1]) {
		b.add('head', fur, new THREE.ConeGeometry(0.035, 0.07, 4), { pos: V(s * 0.055, 0.31, 0.14), rot: [0, 0, -s * 0.3] });
		b.add('head', pink, new THREE.ConeGeometry(0.018, 0.04, 4), { pos: V(s * 0.055, 0.305, 0.155), rot: [0, 0, -s * 0.3] });
		for (const z of [-0.1, 0.08]) b.add('feet', M.white, ellipsoid(0.035, 0.025, 0.045, 6, 4), { pos: V(s * 0.07, 0.02, z) });
	}
	eyes(b, 0.235, 0.225, 0.04, 0.025);
	b.add('face', pink, ellipsoid(0.015, 0.01, 0.01, 5, 3), { pos: V(0, 0.205, 0.24) });
	// Tail curling up behind.
	for (let i = 0; i < 6; i++) {
		const t = i / 5;
		b.add('tail', i % 2 ? stripe : fur, ellipsoid(0.025, 0.025, 0.025, 6, 4), { pos: V(0, 0.12 + t * 0.16, -0.2 - Math.sin(t * 2) * 0.06) });
	}
	return b.build();
}

export const models = { cat_michi: buildCat };

export const views = {
	cat: {
		items: [{ name: 'cat_michi', pos: [0, 0, 0], rotY: 0.6 }, { name: 'npc_abuelo', pos: [0.8, 0, -0.6], rotY: -0.3 }],
		cam: { pos: [0.6, 0.9, 2.2], target: [0.2, 0.4, 0], fov: 32 },
	},
};
