// The vecina's tupperware (investigacion.md, "Más personajes en la casa"): the grandpa borrowed it three years ago.
// 0.22 x 0.1 x 0.16 m, centered on its collision box in scenes/props/tupperware.tscn. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

export function buildTupperware() {
	const tub = mat('tupper_tub', 0xe8eef2), lid = mat('tupper_lid', 0x3fa9f5), tape = mat('tupper_tape', 0xf6e7b0), ink = mat('tupper_ink', 0x2b2f3a);
	const b = new Builder('tupperware');
	b.add('tub', tub, new THREE.BoxGeometry(0.2, 0.075, 0.14), { pos: V(0, -0.012, 0) });
	b.add('lid', lid, new THREE.BoxGeometry(0.22, 0.02, 0.16), { pos: V(0, 0.038, 0) });
	b.add('lid', lid, new THREE.BoxGeometry(0.04, 0.012, 0.03), { pos: V(0.11, 0.035, 0) });
	// Masking tape with her name in marker, on the front.
	b.add('tape', tape, new THREE.BoxGeometry(0.12, 0.03, 0.004), { pos: V(0, -0.01, 0.071) });
	for (let i = 0; i < 4; i++) b.add('tape', ink, new THREE.BoxGeometry(0.016, 0.012, 0.002), { pos: V(-0.036 + i * 0.024, -0.01, 0.074) });
	return b.build();
}

export const models = { tupperware: buildTupperware };

export const views = {
	tupperware: {
		items: [{ name: 'tupperware', pos: [0, 0.05, 0], rotY: 0.4 }, { name: 'npc_vecina', pos: [0.7, 0, -0.6], rotY: -0.3 }],
		cam: { pos: [0.6, 0.9, 2.2], target: [0.25, 0.4, 0], fov: 32 },
	},
};
