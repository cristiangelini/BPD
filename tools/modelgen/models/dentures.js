// The care home dentures (historias.md): the case of rented dentures and the list of clients. Centered on their
// collision boxes in scenes/props/*.tscn. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

// A small suitcase full of dentures: 0.5 x 0.3 x 0.35 m, brown with a handle and two brass locks, and a pair of
// dentures peeking out of the lid.
export function buildDentureCase() {
	const b = new Builder('denture_case');
	const leather = mat('case_leather', 0x7a4a2a), brass = mat('brass', 0xd8b048, { emissive: 0x2a2005 });
	b.add('case', leather, new THREE.BoxGeometry(0.5, 0.28, 0.35), { pos: V(0, -0.01, 0) });
	b.add('case', mat('case_band', 0x5a3418), new THREE.BoxGeometry(0.51, 0.03, 0.36), { pos: V(0, 0.05, 0) });
	b.add('handle', mat('case_band', 0x5a3418), new THREE.TorusGeometry(0.05, 0.012, 4, 10, Math.PI), { pos: V(0, 0.13, 0) });
	for (const x of [-0.14, 0.14]) b.add('locks', brass, new THREE.BoxGeometry(0.04, 0.03, 0.01), { pos: V(x, 0.06, 0.18) });
	const gum = mat('gum', 0xe86a7a), tooth = mat('tooth', 0xfafaf0);
	b.add('teeth', gum, ellipsoid(0.06, 0.012, 0.04, 8, 4), { pos: V(0.05, 0.136, 0.05) });
	for (let i = 0; i < 6; i++) b.add('teeth', tooth, new THREE.BoxGeometry(0.012, 0.012, 0.01), { pos: V(0.05 - 0.035 + i * 0.014, 0.148, 0.088) });
	return b.build();
}

// The list of clients: a 0.15 x 0.21 m sheet with names and a tooth drawn at the top.
export function buildClientList() {
	const b = new Builder('client_list');
	b.add('paper', mat('list_paper', 0xf4efd8), new THREE.BoxGeometry(0.15, 0.004, 0.21));
	b.add('ink', mat('tooth', 0xfafaf0), new THREE.BoxGeometry(0.025, 0.003, 0.03), { pos: V(0, 0.003, -0.08) });
	for (let i = 0; i < 7; i++) b.add('ink', mat('list_ink', 0x2a2a3a), new THREE.BoxGeometry(0.09 - (i % 3) * 0.015, 0.002, 0.007), { pos: V(-0.01, 0.003, -0.045 + i * 0.019) });
	return b.build();
}

export const models = { denture_case: buildDentureCase, client_list: buildClientList };

export const views = {
	dentures: {
		items: [{ name: 'denture_case', pos: [-0.15, 0.15, 0], rotY: 0.3 }, { name: 'client_list', pos: [0.32, 0.01, 0.2], rotY: -0.2 }],
		cam: { pos: [0, 0.7, 1.2], target: [0, 0.1, 0.05], fov: 38 },
	},
};
