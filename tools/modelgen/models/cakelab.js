// Props of the cake lab "Dulce Ciencia" (docs/diseno/laboratorio.md): the industrial oven, the giant mixer and the
// flavor lab's microscope, with origins at the floor in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// An industrial oven 1.2 m wide, 1.6 m tall and 0.9 m deep, its front to +Z: steel body, a dark glass door with a
// handle, a red knob and a little orange light.
export function buildLabOven() {
	const b = new Builder('lab_oven');
	const steel = mat('oven_steel', 0xb8bcc4);
	b.add('body', steel, new THREE.BoxGeometry(1.2, 1.6, 0.9), { pos: V(0, 0.8, 0) });
	b.add('door', mat('oven_glass', 0x2a2e36), new THREE.BoxGeometry(0.9, 0.7, 0.02), { pos: V(0, 0.75, 0.455) });
	b.add('glow', mat('oven_glow', 0xe88a3a), new THREE.BoxGeometry(0.8, 0.05, 0.01), { pos: V(0, 0.5, 0.466) });
	b.add('handle', mat('oven_handle', 0x2a2a2e), new THREE.BoxGeometry(0.7, 0.04, 0.05), { pos: V(0, 1.15, 0.48) });
	b.add('panel', mat('oven_panel', 0x5a5e66), new THREE.BoxGeometry(1.1, 0.25, 0.02), { pos: V(0, 1.4, 0.455) });
	b.add('knob', mat('oven_knob', 0xd23a3a), new THREE.CylinderGeometry(0.05, 0.05, 0.04, 10), { pos: V(0.4, 1.4, 0.48), rot: [Math.PI / 2, 0, 0] });
	b.add('light', mat('oven_light', 0xf2a03a), ellipsoid(0.02, 0.02, 0.01, 6, 3), { pos: V(-0.4, 1.4, 0.47) });
	for (const s of [-1, 1]) b.add('feet', mat('oven_feet', 0x2a2a2e), new THREE.BoxGeometry(0.08, 0.06, 0.8), { pos: V(s * 0.5, 0.03, 0) });
	return b.build();
}

// A giant stand mixer 1.5 m tall: a pastel base, an arched arm over a steel bowl 0.7 m across, and a whisk inside.
export function buildGiantMixer() {
	const b = new Builder('giant_mixer');
	const mint = mat('mixer_mint', 0x9ad8c0), steel = mat('bowl_steel', 0xc8ccd2);
	b.add('base', mint, new THREE.BoxGeometry(0.9, 0.2, 0.9), { pos: V(0, 0.1, 0) });
	b.add('column', mint, new THREE.BoxGeometry(0.3, 1.2, 0.3), { pos: V(0, 0.8, -0.35) });
	b.add('head', mint, new THREE.BoxGeometry(0.35, 0.3, 0.8), { pos: V(0, 1.35, -0.05) });
	b.add('bowl', steel, new THREE.CylinderGeometry(0.35, 0.25, 0.5, 14, 1, true), { pos: V(0, 0.55, 0.05) });
	b.add('bowl', steel, new THREE.CylinderGeometry(0.25, 0.25, 0.02, 14), { pos: V(0, 0.3, 0.05) });
	b.add('dough', mat('dough', 0xf2e2b8), ellipsoid(0.28, 0.08, 0.28, 10, 4), { pos: V(0, 0.45, 0.05) });
	for (let i = 0; i < 4; i++) b.add('whisk', steel, new THREE.TorusGeometry(0.12, 0.008, 4, 10, Math.PI), { pos: V(0, 0.75, 0.05), rot: [0, (i / 4) * Math.PI, Math.PI] });
	b.add('shaft', steel, new THREE.CylinderGeometry(0.02, 0.02, 0.3, 6), { pos: V(0, 1.05, 0.05) });
	b.add('switch', mat('oven_knob', 0xd23a3a), new THREE.BoxGeometry(0.06, 0.06, 0.04), { pos: V(0.18, 1.35, 0.2) });
	return b.build();
}

// The flavor lab's microscope, 0.45 m tall, white with a black eyepiece.
export function buildMicroscope() {
	const b = new Builder('microscope');
	const white = mat('scope_white', 0xf2f2ee), black = mat('scope_black', 0x26262b);
	b.add('base', white, new THREE.BoxGeometry(0.2, 0.04, 0.25), { pos: V(0, 0.02, 0) });
	b.add('arm', white, new THREE.BoxGeometry(0.05, 0.3, 0.06), { pos: V(0, 0.19, -0.08) });
	b.add('stage', black, new THREE.BoxGeometry(0.14, 0.015, 0.12), { pos: V(0, 0.15, 0.02) });
	b.add('tube', white, new THREE.CylinderGeometry(0.025, 0.025, 0.2, 8), { pos: V(0, 0.3, 0.0), rot: [-0.4, 0, 0] });
	b.add('eyepiece', black, new THREE.CylinderGeometry(0.02, 0.02, 0.06, 8), { pos: V(0, 0.42, -0.05), rot: [-0.4, 0, 0] });
	return b.build();
}

// A rack of 6 test tubes 0.3 m wide with coloured syrups.
export function buildTestTubes() {
	const b = new Builder('test_tubes');
	b.add('rack', mat('rack_wood', 0x8a5a3a), new THREE.BoxGeometry(0.3, 0.04, 0.08), { pos: V(0, 0.08, 0) });
	b.add('rack', mat('rack_wood', 0x8a5a3a), new THREE.BoxGeometry(0.3, 0.02, 0.08), { pos: V(0, 0.01, 0) });
	const colors = [0xe84a8a, 0x4ad8a0, 0xf2d24a, 0x8a4ae8, 0xe88a3a, 0x4a8ae8];
	for (let i = 0; i < 6; i++) {
		b.add('glass', mat('tube_glass', 0xdfeef2), new THREE.CylinderGeometry(0.014, 0.014, 0.16, 6), { pos: V(-0.125 + i * 0.05, 0.1, 0) });
		b.add('syrup', mat('syrup_' + i, colors[i]), new THREE.CylinderGeometry(0.012, 0.012, 0.08, 6), { pos: V(-0.125 + i * 0.05, 0.065, 0) });
	}
	return b.build();
}

export const models = {
	lab_oven: buildLabOven, giant_mixer: buildGiantMixer, microscope: buildMicroscope, test_tubes: buildTestTubes,
};

export const views = {
	cake_lab: {
		items: [
			{ name: 'lab_oven', pos: [-1.0, 0, 0] }, { name: 'giant_mixer', pos: [0.4, 0, 0.1] },
			{ name: 'microscope', pos: [1.2, 0, 0.3] }, { name: 'test_tubes', pos: [1.25, 0, -0.1] },
		],
		cam: { pos: [0, 1.4, 3.6], target: [0, 0.7, 0], fov: 40 },
	},
};
