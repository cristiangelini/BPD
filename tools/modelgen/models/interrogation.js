// Furniture of the interrogation wing (docs/diseno/interrogatorio.md): the bolted steel table, the chairs, the lamp
// hanging over the table, the wall clock, the security camera and the observers' recording desk. Origins on the floor
// at the middle of the piece, front to +Z, like station.js; the lamp's origin is the bottom of its shade and the clock and
// the camera sit on theirs on the wall. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The steel table: 1.8 x 0.76 x 0.9 m, bolted down, with the ring for the handcuffs on the suspect's side (-Z), a
// tape recorder, a paper cup and an ashtray (nobody reads the sign). The case folder on it is loose (case_folder).
export function buildTable() {
	const b = new Builder('interrogation_table');
	const steel = mat('int_steel', 0x8a9096), dark = mat('int_steel_dark', 0x4a4e54);
	b.add('top', steel, new THREE.BoxGeometry(1.8, 0.04, 0.9), { pos: V(0, 0.74, 0) });
	for (const x of [-0.82, 0.82]) for (const z of [-0.38, 0.38]) {
		b.add('legs', dark, new THREE.BoxGeometry(0.05, 0.72, 0.05), { pos: V(x, 0.36, z) });
		b.add('bolts', dark, new THREE.BoxGeometry(0.12, 0.02, 0.12), { pos: V(x, 0.01, z) });
	}
	b.add('ring', mat('int_chrome', 0xd0d4d8), new THREE.TorusGeometry(0.05, 0.012, 6, 12), { pos: V(0, 0.79, -0.34) });
	b.add('recorder', mat('int_recorder', 0x2a2a2e), new THREE.BoxGeometry(0.3, 0.08, 0.2), { pos: V(0.55, 0.8, 0.12) });
	for (const x of [0.48, 0.62]) b.add('recorder', mat('int_reel', 0xb8bcc4), new THREE.CylinderGeometry(0.045, 0.045, 0.012, 10), { pos: V(x, 0.846, 0.12) });
	b.add('recorder', mat('int_led', 0xff3020, { emissive: 0x801008 }), new THREE.BoxGeometry(0.02, 0.02, 0.01), { pos: V(0.66, 0.82, 0.225) });
	b.add('cup', mat('int_cup', 0xf4efd8), new THREE.CylinderGeometry(0.04, 0.032, 0.1, 8), { pos: V(-0.1, 0.81, -0.2) });
	b.add('ashtray', mat('int_glass', 0x9ab0b8), new THREE.CylinderGeometry(0.07, 0.06, 0.03, 10), { pos: V(0.2, 0.775, -0.15) });
	return b.build();
}

// A steel chair: 0.5 x 0.9 x 0.5 m, seat at 0.46 m, back toward -Z.
export function buildChair() {
	const b = new Builder('interrogation_chair');
	const steel = mat('int_chair', 0x5a6068), seat = mat('int_seat', 0x3a3e44);
	b.add('seat', seat, new THREE.BoxGeometry(0.46, 0.04, 0.44), { pos: V(0, 0.46, 0) });
	for (const x of [-0.21, 0.21]) for (const z of [-0.2, 0.2]) b.add('legs', steel, new THREE.CylinderGeometry(0.015, 0.015, 0.46, 6), { pos: V(x, 0.23, z) });
	for (const x of [-0.21, 0.21]) b.add('back', steel, new THREE.CylinderGeometry(0.015, 0.015, 0.44, 6), { pos: V(x, 0.7, -0.21) });
	b.add('back', seat, new THREE.BoxGeometry(0.46, 0.2, 0.03), { pos: V(0, 0.8, -0.21) });
	return b.build();
}

// The lamp over the table: a green enamel shade with a bright bulb, its origin at the bottom of the shade, and the
// cord up 0.85 m to the ceiling.
export function buildHangingLamp() {
	const b = new Builder('hanging_lamp');
	b.add('cord', mat('int_cord', 0x1c1c20), new THREE.CylinderGeometry(0.008, 0.008, 0.85, 4), { pos: V(0, 0.625, 0) });
	b.add('shade', mat('int_shade', 0x2a5a3a, { side: THREE.DoubleSide }), new THREE.CylinderGeometry(0.04, 0.26, 0.2, 12, 1, true), { pos: V(0, 0.1, 0) });
	b.add('bulb', mat('int_bulb', 0xfff4d0, { emissive: 0xfff0c0 }), new THREE.SphereGeometry(0.06, 8, 6), { pos: V(0, 0.05, 0) });
	return b.build();
}

// The wall clock: 0.36 m across, facing +Z, its hands stuck at ten to two.
export function buildWallClock() {
	const b = new Builder('wall_clock');
	b.add('rim', mat('int_clock_rim', 0x2a2a2e), new THREE.CylinderGeometry(0.18, 0.18, 0.05, 16), { rot: [Math.PI / 2, 0, 0] });
	b.add('face', mat('int_clock_face', 0xf4efd8), new THREE.CylinderGeometry(0.16, 0.16, 0.01, 16), { pos: V(0, 0, 0.026), rot: [Math.PI / 2, 0, 0] });
	const hand = mat('int_clock_hand', 0x1c1c20);
	b.add('hands', hand, new THREE.BoxGeometry(0.012, 0.12, 0.005), { pos: V(-0.035, 0.04, 0.035), rot: [0, 0, 0.9] });
	b.add('hands', hand, new THREE.BoxGeometry(0.012, 0.09, 0.005), { pos: V(0.03, 0.03, 0.035), rot: [0, 0, -0.9] });
	return b.build();
}

// The security camera in a corner: an arm off the wall and the camera looking +Z, with its red light on.
export function buildCamera() {
	const b = new Builder('security_camera');
	const body = mat('int_camera', 0xd8dade), dark = mat('int_camera_dark', 0x2a2a2e);
	b.add('arm', dark, new THREE.BoxGeometry(0.04, 0.04, 0.25), { pos: V(0, 0, -0.1) });
	b.add('camera', body, new THREE.BoxGeometry(0.12, 0.1, 0.24), { pos: V(0, -0.04, 0.08), rot: [0.35, 0, 0] });
	b.add('camera', dark, new THREE.CylinderGeometry(0.035, 0.035, 0.03, 10), { pos: V(0, -0.09, 0.2), rot: [Math.PI / 2 + 0.35, 0, 0] });
	b.add('light', mat('int_camera_red', 0xff2010, { emissive: 0xff2010 }), new THREE.SphereGeometry(0.012, 6, 4), { pos: V(0.04, -0.01, 0.2) });
	return b.build();
}

// The observers' desk against the mirror: 1.6 x 0.76 x 0.7 m with a reel-to-reel recorder, a monitor, a microphone
// on its stand and a pair of headphones.
export function buildRecordingDesk() {
	const b = new Builder('recording_desk');
	const wood = mat('rec_wood', 0x6a5a48), dark = mat('rec_dark', 0x2a2a2e), steel = mat('rec_steel', 0xb8bcc4);
	b.add('desk', wood, new THREE.BoxGeometry(1.6, 0.05, 0.7), { pos: V(0, 0.735, 0) });
	for (const x of [-0.75, 0.75]) b.add('desk', dark, new THREE.BoxGeometry(0.06, 0.71, 0.66), { pos: V(x, 0.355, 0) });
	b.add('recorder', dark, new THREE.BoxGeometry(0.5, 0.35, 0.25), { pos: V(-0.45, 0.935, -0.15) });
	for (const x of [-0.57, -0.33]) b.add('reels', steel, new THREE.CylinderGeometry(0.09, 0.09, 0.02, 12), { pos: V(x, 1.0, -0.02), rot: [Math.PI / 2, 0, 0] });
	b.add('monitor', mat('rec_monitor', 0x4a4e54), new THREE.BoxGeometry(0.4, 0.32, 0.3), { pos: V(0.3, 0.92, -0.15) });
	b.add('monitor', mat('rec_screen', 0x5a9a7a, { emissive: 0x1a3a2a }), new THREE.BoxGeometry(0.32, 0.24, 0.01), { pos: V(0.3, 0.93, 0.005) });
	b.add('mic', dark, new THREE.CylinderGeometry(0.06, 0.07, 0.02, 10), { pos: V(0.0, 0.77, 0.15) });
	b.add('mic', steel, new THREE.CylinderGeometry(0.008, 0.008, 0.25, 6), { pos: V(0.0, 0.9, 0.15) });
	b.add('mic', dark, new THREE.CylinderGeometry(0.025, 0.02, 0.07, 8), { pos: V(0.0, 1.05, 0.17), rot: [0.6, 0, 0] });
	b.add('headphones', dark, new THREE.TorusGeometry(0.08, 0.012, 6, 10, Math.PI), { pos: V(0.62, 0.77, 0.15), rot: [-Math.PI / 2, 0, 0] });
	return b.build();
}

// The paper cup of coffee from the observation room's machine: 0.09 x 0.12 m, centered, with a lid and a sleeve.
export function buildCoffeeCup() {
	const b = new Builder('coffee_cup');
	b.add('cup', mat('cup_paper', 0xf4efd8), new THREE.CylinderGeometry(0.045, 0.035, 0.11, 10), { pos: V(0, -0.005, 0) });
	b.add('sleeve', mat('cup_sleeve', 0x8a5a2a), new THREE.CylinderGeometry(0.044, 0.039, 0.045, 10), { pos: V(0, -0.005, 0) });
	b.add('lid', mat('cup_lid', 0xffffff), new THREE.CylinderGeometry(0.047, 0.047, 0.012, 10), { pos: V(0, 0.054, 0) });
	return b.build();
}

// The light switch by the interrogation room's door: a plate 0.12 x 0.16 m from its origin up, facing +Z.
export function buildLightSwitch() {
	const b = new Builder('light_switch');
	b.add('plate', mat('switch_plate', 0xe8e4d8), new THREE.BoxGeometry(0.12, 0.16, 0.02), { pos: V(0, 0.08, 0) });
	b.add('toggle', mat('switch_toggle', 0x3a3e44), new THREE.BoxGeometry(0.03, 0.05, 0.03), { pos: V(0, 0.09, 0.02), rot: [0.4, 0, 0] });
	return b.build();
}

// A box of tissues for the good cop, on the table: 0.24 x 0.1 x 0.13 m from its origin up, one tissue sticking out.
export function buildTissueBox() {
	const b = new Builder('tissue_box');
	b.add('box', mat('tissue_box', 0x7ab0d8), new THREE.BoxGeometry(0.24, 0.1, 0.13), { pos: V(0, 0.05, 0) });
	b.add('tissue', mat('tissue', 0xffffff), new THREE.BoxGeometry(0.08, 0.06, 0.01), { pos: V(0, 0.12, 0), rot: [0, 0, 0.3] });
	return b.build();
}

// The case folder, loose on the table: 0.32 x 0.02 x 0.24 m, centered, with the suspect's photo clipped on. The twins'
// case carries it from one twin to the other (interrogatorio.md).
export function buildCaseFolder() {
	const b = new Builder('case_folder');
	b.add('folder', mat('int_folder', 0xd8b070), new THREE.BoxGeometry(0.32, 0.02, 0.24), { pos: V(0, 0, 0) });
	b.add('photo', mat('int_photo', 0xf4efd8), new THREE.BoxGeometry(0.12, 0.004, 0.09), { pos: V(-0.05, 0.012, -0.03), rot: [0, -0.5, 0] });
	b.add('clip', mat('int_chrome', 0xd0d4d8), new THREE.BoxGeometry(0.03, 0.006, 0.02), { pos: V(-0.05, 0.016, 0.01) });
	return b.build();
}

export const models = {
	interrogation_table: buildTable, interrogation_chair: buildChair, hanging_lamp: buildHangingLamp,
	wall_clock: buildWallClock, security_camera: buildCamera, recording_desk: buildRecordingDesk,
	coffee_cup: buildCoffeeCup, light_switch: buildLightSwitch, tissue_box: buildTissueBox, case_folder: buildCaseFolder,
};

export const views = {
	interrogation: {
		items: [
			{ name: 'interrogation_table', pos: [0, 0, 0] },
			{ name: 'interrogation_chair', pos: [0, 0, -0.8] },
			{ name: 'interrogation_chair', pos: [-0.6, 0, 1.0], rotY: Math.PI },
			{ name: 'interrogation_chair', pos: [0.6, 0, 1.0], rotY: Math.PI },
			{ name: 'hanging_lamp', pos: [0, 1.35, 0] },
			{ name: 'wall_clock', pos: [-1.6, 1.6, -1.6] },
			{ name: 'security_camera', pos: [1.6, 2.1, -1.6], rotY: -0.6 },
			{ name: 'recording_desk', pos: [-2.6, 0, 0.4], rotY: Math.PI / 2 },
		],
		cam: { pos: [1.2, 2.6, 4.2], target: [-0.3, 0.9, -0.2], fov: 50 },
	},
};
