// The pieces the station's old patrol car loses in the curves when the station crime scene's culprit runs off in it
// (docs/diseno/escena-comisaria.md, step 5): a hubcap, the front bumper and the siren off the roof. Origins on the
// ground at the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

const chrome = mat('old_chrome', 0xb8bcc4), white = mat('old_patrol_white', 0xeeeeea), dark = mat('old_rubber', 0x222226);

export function buildHubcap() {
	const b = new Builder('car_hubcap');
	b.add('cap', chrome, new THREE.CylinderGeometry(0.2, 0.22, 0.05, 12), { pos: V(0, 0.025, 0) });
	b.add('cap', dark, new THREE.CylinderGeometry(0.05, 0.05, 0.06, 8), { pos: V(0, 0.03, 0) });
	return b.build();
}

export function buildBumper() {
	const b = new Builder('car_bumper');
	b.add('bumper', chrome, new THREE.BoxGeometry(1.7, 0.16, 0.14), { pos: V(0, 0.08, 0) });
	for (const x of [-0.75, 0.75]) b.add('bumper', chrome, new THREE.BoxGeometry(0.12, 0.16, 0.25), { pos: V(x, 0.08, -0.1) });
	return b.build();
}

export function buildRoofSiren() {
	const b = new Builder('car_roof_siren');
	b.add('base', white, new THREE.BoxGeometry(0.9, 0.08, 0.25), { pos: V(0, 0.04, 0) });
	b.add('light', mat('siren_red', 0xe02020, { emissive: 0x500808 }), new THREE.CylinderGeometry(0.1, 0.1, 0.16, 8), { pos: V(-0.25, 0.16, 0) });
	b.add('light', mat('siren_dead', 0x5a6070), new THREE.CylinderGeometry(0.1, 0.1, 0.16, 8), { pos: V(0.25, 0.16, 0) });
	return b.build();
}

export const models = { car_hubcap: buildHubcap, car_bumper: buildBumper, car_roof_siren: buildRoofSiren };

export const views = {
	old_patrol_parts: {
		items: [
			{ name: 'car_bumper', pos: [0, 0, -0.4] },
			{ name: 'car_hubcap', pos: [-0.7, 0, 0.5], rotY: 0.3 },
			{ name: 'car_roof_siren', pos: [0.6, 0, 0.5], rotY: -0.4 },
		],
		cam: { pos: [0, 1.6, 2.6], target: [0, 0.1, 0], fov: 45 },
	},
};
