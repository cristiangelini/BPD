// The roof robbery (docs/diseno/robo-banco-techo.md, decision 126): the giant toy helicopter that El Oso's nephew
// flies from the sidewalk across. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// A toy helicopter as big as a fridge (2.4 m long with its tail, 1.1 m tall), bright yellow with red trim, a bubble
// cabin with a plastic pilot doll, skids and a hook under the belly. The main rotor ('rotor', centered on the mast's top)
// and the tail rotor ('tail_rotor', centered on its hub) are their own nodes so the game spins them. Faces +Z, origin
// on the ground under the mast.
export function buildToyHelicopter() {
	const yellow = mat('toy_yellow', 0xf6c81e), red = mat('toy_red', 0xd8322a), grey = mat('toy_grey', 0x6b7280);
	const glass = mat('toy_glass', 0x8ac8f0, { transparent: true, opacity: 0.6 }), black = mat('toy_black', 0x23252b);
	const b = new Builder('toy_helicopter');
	b.add('body', yellow, ellipsoid(0.42, 0.36, 0.6, 12, 8), { pos: V(0, 0.62, 0.05) });
	b.add('body', glass, ellipsoid(0.34, 0.28, 0.32, 10, 6), { pos: V(0, 0.72, 0.38) });
	b.add('body', mat('toy_doll', 0xf3d2b0), ellipsoid(0.08, 0.09, 0.08, 6, 4), { pos: V(0, 0.82, 0.4) });
	b.add('body', red, new THREE.TorusGeometry(0.42, 0.03, 4, 16), { pos: V(0, 0.62, 0.05), rot: [Math.PI / 2, 0, 0] });
	// The tail boom, its fin and the tail rotor's hub.
	b.add('body', yellow, new THREE.CylinderGeometry(0.06, 0.12, 1.1, 8), { pos: V(0, 0.72, -0.95), rot: [Math.PI / 2, 0, 0] });
	b.add('body', red, new THREE.BoxGeometry(0.04, 0.32, 0.22), { pos: V(0, 0.86, -1.42) });
	// Skids on their struts.
	for (const s of [-1, 1]) {
		b.add('body', grey, new THREE.CylinderGeometry(0.025, 0.025, 1.1, 6), { pos: V(s * 0.32, 0.06, 0.05), rot: [Math.PI / 2, 0, 0] });
		for (const z of [-0.2, 0.3]) b.add('body', grey, new THREE.CylinderGeometry(0.02, 0.02, 0.3, 5), { pos: V(s * 0.27, 0.2, z), rot: [0, 0, s * 0.35] });
	}
	b.add('body', grey, new THREE.TorusGeometry(0.06, 0.015, 4, 8), { pos: V(0, 0.24, 0.05) });
	// The mast and the main rotor: two long blades across.
	b.add('body', black, new THREE.CylinderGeometry(0.04, 0.04, 0.2, 6), { pos: V(0, 1.04, 0.05) });
	for (const a of [0, Math.PI / 2]) b.add('rotor', red, new THREE.BoxGeometry(2.2, 0.02, 0.12), { pos: V(0, 1.14, 0.05), rot: [0, a, 0] });
	b.add('rotor', black, new THREE.CylinderGeometry(0.07, 0.07, 0.06, 8), { pos: V(0, 1.14, 0.05) });
	for (const a of [0, Math.PI / 2]) b.add('tail_rotor', black, new THREE.BoxGeometry(0.02, 0.36, 0.05), { pos: V(0.05, 0.86, -1.42), rot: [a, 0, 0] });
	return b.build();
}

export const models = { toy_helicopter: buildToyHelicopter };

export const views = {
	toy_helicopter: {
		items: [{ name: 'toy_helicopter', pos: [0, 0, 0], rotY: 0.7 }, { name: 'npc_sobrino', pos: [1.6, 0, 0.4], rotY: -0.4, scale: 0.8 }],
		cam: { pos: [1.5, 1.8, 4.2], target: [0.6, 0.7, 0], fov: 42 },
	},
};
