// The bribe jailbreak (fuga-soborno.md): a wad of the bribes' bills held by a rubber band. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// A wad of green bills folded in two, a red rubber band around it: 0.16 x 0.05 x 0.08 m, origin in its middle.
export function buildBillWad() {
	const b = new Builder('bill_wad');
	const bill = mat('bill_green', 0x7aa86a), edge = mat('bill_edge', 0x5a8a4e), band = mat('wad_band', 0xc8402e);
	b.add('bills', bill, new THREE.BoxGeometry(0.16, 0.045, 0.08));
	for (const y of [-0.012, 0.0, 0.012]) {
		b.add('edge', edge, new THREE.BoxGeometry(0.161, 0.004, 0.081), { pos: V(0, y, 0) });
	}
	b.add('stamp', mat('bill_stamp', 0xd8e8c8), new THREE.BoxGeometry(0.05, 0.047, 0.05), { pos: V(-0.03, 0, 0) });
	b.add('band', band, new THREE.BoxGeometry(0.02, 0.052, 0.086), { pos: V(0.035, 0, 0) });
	return b.build();
}

export const models = { bill_wad: buildBillWad };

export const views = {
	bribe: {
		items: [
			{ name: 'bill_wad', pos: [-0.12, 0.025, 0], rotY: 0.3 },
			{ name: 'bill_wad', pos: [0.1, 0.025, 0.05], rotY: -0.5 },
			{ name: 'bill_wad', pos: [0.0, 0.07, -0.02], rotY: 1.2 },
		],
		cam: { pos: [0, 0.35, 0.55], target: [0, 0.03, 0], fov: 40 },
	},
};
