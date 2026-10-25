// The bribe jailbreak (fuga-soborno.md): a wad of the bribes' bills held by a rubber band, and the corridor's security
// camera. Placeholder, not final art.
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

// The corridor's security camera, hanging from the ceiling: a grey box on an arm, its lens looking along +Z and a red
// light on top. The origin is where the arm meets the ceiling (it hangs down, -Y); it turns about Y there.
export function buildCorridorCamera() {
	const b = new Builder('corridor_camera');
	const grey = mat('camera_grey', 0xb8bcc0), dark = mat('camera_dark', 0x202428);
	b.add('mount', dark, new THREE.CylinderGeometry(0.06, 0.06, 0.03, 10), { pos: V(0, -0.015, 0) });
	b.add('arm', dark, new THREE.BoxGeometry(0.04, 0.22, 0.04), { pos: V(0, -0.13, 0) });
	b.add('body', grey, new THREE.BoxGeometry(0.14, 0.12, 0.3), { pos: V(0, -0.28, 0.06), rot: [0.35, 0, 0] });
	b.add('hood', grey, new THREE.BoxGeometry(0.17, 0.02, 0.34), { pos: V(0, -0.21, 0.07), rot: [0.35, 0, 0] });
	b.add('lens', dark, new THREE.CylinderGeometry(0.045, 0.05, 0.04, 12), { pos: V(0, -0.34, 0.22), rot: [Math.PI / 2 + 0.35, 0, 0] });
	b.add('light', mat('camera_red', 0xff2a1a, { emissive: 0xff2a1a }), new THREE.SphereGeometry(0.018, 8, 6), { pos: V(0.06, -0.2, 0.12) });
	return b.build();
}

export const models = { bill_wad: buildBillWad, corridor_camera: buildCorridorCamera };

export const views = {
	bribe: {
		items: [
			{ name: 'bill_wad', pos: [-0.12, 0.025, 0], rotY: 0.3 },
			{ name: 'bill_wad', pos: [0.1, 0.025, 0.05], rotY: -0.5 },
			{ name: 'bill_wad', pos: [0.0, 0.07, -0.02], rotY: 1.2 },
		],
		cam: { pos: [0, 0.35, 0.55], target: [0, 0.03, 0], fov: 40 },
	},
	camera: {
		items: [{ name: 'corridor_camera', pos: [0, 0.6, 0], rotY: 0.6 }],
		cam: { pos: [0.5, 0.55, 0.8], target: [0, 0.35, 0], fov: 40 },
	},
};
