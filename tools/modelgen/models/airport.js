// The city airport (docs/diseno/politico-aeropuerto.md): the check-in counter with its scale, the X-ray machine, the
// little plane, the duty-free shelf and the gate's row of seats. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// The check-in counter (step 1): 3 m long (x), 1.1 m high, its desk side toward -Z, a blue band, the screen on top and
// the luggage scale built into its front-right, with a red display. Origin at its middle, on the ground.
export function buildCheckinCounter() {
	const b = new Builder('checkin_counter');
	const white = mat('airport_white', 0xeef0f2), blue = mat('airport_blue', 0x2a5aa8), dark = mat('airport_dark', 0x26292e);
	box(b, 'body', white, 3.0, 1.1, 0.8, 0, 0.55, 0);
	box(b, 'band', blue, 3.02, 0.18, 0.82, 0, 0.8, 0);
	box(b, 'top', dark, 3.1, 0.05, 0.9, 0, 1.12, 0);
	box(b, 'screen', dark, 0.5, 0.35, 0.05, -0.8, 1.35, -0.2, [-0.2, 0, 0]);
	box(b, 'scale', mat('scale_steel', 0xb8bec6, { metalness: 0.4, roughness: 0.4 }), 0.9, 0.12, 0.9, 1.0, 0.06, 0.9);
	box(b, 'display', dark, 0.4, 0.2, 0.04, 1.0, 1.0, 0.42);
	box(b, 'digits', mat('scale_red', 0xe03030, { emissive: 0x601010 }), 0.32, 0.1, 0.01, 1.0, 1.0, 0.445);
	return b.build();
}

// The X-ray machine (step 1): a gray tunnel 2.4 m long (x) the belt runs through, rubber flaps at both mouths and a
// red light on top. Origin at its middle, on the ground.
export function buildXrayMachine() {
	const b = new Builder('xray_machine');
	const grey = mat('xray_grey', 0x9aa2ac), dark = mat('airport_dark', 0x26292e), flap = mat('xray_flap', 0x3a3d44);
	box(b, 'top', grey, 2.4, 0.5, 1.2, 0, 1.55, 0);
	for (const z of [-0.55, 0.55]) box(b, 'side', grey, 2.4, 1.3, 0.1, 0, 0.65, z);
	for (const x of [-1.2, 1.2]) for (let i = -2; i <= 2; i++) box(b, 'flaps', flap, 0.02, 0.5, 0.18, x, 1.05, i * 0.2);
	box(b, 'base', dark, 2.4, 0.6, 1.0, 0, 0.3, 0);
	b.add('light', mat('xray_red', 0xe03030, { emissive: 0x801010 }), new THREE.CylinderGeometry(0.08, 0.08, 0.12, 8), { pos: V(0.9, 1.86, 0) });
	return b.build();
}

// The little plane on the apron (step 1): white with a blue stripe, 14 m long along +X, wings 14 m, two propellers
// and the boarding stairs on its left side (+Z). Origin under its middle, on the ground.
export function buildAirplane() {
	const b = new Builder('airplane');
	const white = mat('plane_white', 0xf4f4f2), blue = mat('airport_blue', 0x2a5aa8), glass = mat('car_glass', 0x9fd0ea);
	const dark = mat('airport_dark', 0x26292e);
	b.add('body', white, new THREE.CylinderGeometry(1.2, 1.0, 12, 12), { pos: V(0, 2.2, 0), rot: [0, 0, Math.PI / 2] });
	b.add('body', white, new THREE.SphereGeometry(1.2, 12, 8), { pos: V(6, 2.2, 0), scale: [1.4, 1, 1] });
	b.add('body', white, new THREE.ConeGeometry(1.0, 2.5, 12), { pos: V(-7.2, 2.4, 0), rot: [0, 0, Math.PI / 2] });
	box(b, 'stripe', blue, 12, 0.25, 2.3, 0, 2.3, 0);
	box(b, 'cockpit', glass, 0.6, 0.5, 1.6, 7.2, 2.7, 0, [0, 0, -0.5]);
	box(b, 'wings', white, 2.2, 0.2, 14, 0.5, 1.8, 0);
	box(b, 'tail', blue, 1.6, 2.4, 0.2, -7.4, 3.8, 0);
	box(b, 'tail', white, 1.4, 0.15, 4.5, -7.4, 2.6, 0);
	for (const z of [-3.5, 3.5]) {
		b.add('engine', dark, new THREE.CylinderGeometry(0.45, 0.45, 1.6, 10), { pos: V(1.6, 1.6, z), rot: [0, 0, Math.PI / 2] });
		box(b, 'propeller', dark, 0.08, 2.2, 0.2, 2.45, 1.6, z);
	}
	for (const x of [-4, -2, 0, 2, 4]) box(b, 'windows', glass, 0.4, 0.35, 2.42, x, 2.65, 0);
	for (const [x, z] of [[5, 0], [-1, -1.2], [-1, 1.2]]) {
		box(b, 'gear', dark, 0.1, 1.0, 0.1, x, 0.6, z);
		b.add('gear', dark, new THREE.CylinderGeometry(0.3, 0.3, 0.2, 10), { pos: V(x, 0.3, z), rot: [Math.PI / 2, 0, 0] });
	}
	for (let i = 0; i < 6; i++) box(b, 'stairs', mat('stairs_grey', 0xb8bec6), 1.0, 0.1, 0.4, 3.5, 0.2 + i * 0.3, 1.4 + 0.4 * (6 - i));
	return b.build();
}

// A duty-free shelf (step 1): 2 m long (x), 1.8 m high, 3 shelves of perfume bottles and sunglasses facing +Z.
export function buildDutyFreeShelf() {
	const b = new Builder('duty_free_shelf');
	const wood = mat('shelf_white', 0xf2efe8), gold = mat('perfume_gold', 0xe8c040, { metalness: 0.5, roughness: 0.3 });
	const colors = [0xd84a7a, 0x4ab0d8, 0x9a5ad8, 0xe8a030].map((c, i) => mat('perfume_' + i, c, { transparent: true, opacity: 0.8 }));
	box(b, 'frame', wood, 2.0, 1.8, 0.05, 0, 0.9, -0.22);
	for (const x of [-1, 1]) box(b, 'frame', wood, 0.05, 1.8, 0.45, x, 0.9, 0);
	for (let s = 0; s < 3; s++) {
		const y = 0.3 + s * 0.55;
		box(b, 'shelves', wood, 2.0, 0.04, 0.45, 0, y, 0);
		for (let i = 0; i < 8; i++) {
			const x = -0.85 + i * 0.24;
			if (s === 1) box(b, 'glasses', mat('airport_dark', 0x26292e), 0.16, 0.05, 0.02, x, y + 0.1, 0.1);
			else {
				box(b, 'bottles', colors[(i + s) % colors.length], 0.1, 0.18, 0.1, x, y + 0.11, 0.05);
				box(b, 'caps', gold, 0.05, 0.05, 0.05, x, y + 0.23, 0.05);
			}
		}
	}
	return b.build();
}

// A row of 4 linked gate seats (step 1), 2.4 m long (x), blue, facing +Z.
export function buildGateSeats() {
	const b = new Builder('gate_seats');
	const blue = mat('airport_blue', 0x2a5aa8), steel = mat('scale_steel', 0xb8bec6, { metalness: 0.4, roughness: 0.4 });
	box(b, 'beam', steel, 2.4, 0.08, 0.08, 0, 0.35, 0);
	for (const x of [-1.0, 1.0]) box(b, 'legs', steel, 0.06, 0.35, 0.5, x, 0.18, 0);
	for (let i = 0; i < 4; i++) {
		const x = -0.9 + i * 0.6;
		box(b, 'seats', blue, 0.52, 0.08, 0.48, x, 0.45, 0);
		box(b, 'seats', blue, 0.52, 0.5, 0.06, x, 0.72, -0.23, [-0.15, 0, 0]);
	}
	return b.build();
}

// Lustre's suitcase (step 2), lying flat: 0.7 m long (x), 0.25 high, 0.5 deep, black with the yellow ribbon around
// it, a handle on its +Z side and the tag on top. Origin at its middle. `open` lifts the lid (hinged at -Z) and shows
// his clothes: a folded suit, a tie and a teddy bear.
function buildSuitcase(name, open) {
	const b = new Builder(name);
	const black = mat('suitcase_black', 0x1e1f24), yellow = mat('ribbon_yellow', 0xf2c84b), white = mat('tag_white', 0xf4f4f0);
	if (open) {
		box(b, 'body', black, 0.7, 0.13, 0.5, 0, -0.06, 0);
		box(b, 'lid', black, 0.7, 0.5, 0.12, 0, 0.25, -0.31, [-0.15, 0, 0]);
		box(b, 'ribbon', yellow, 0.08, 0.5, 0.125, 0, 0.25, -0.31, [-0.15, 0, 0]);
		box(b, 'clothes', mat('suit_grey', 0x5a6070), 0.5, 0.06, 0.36, -0.05, 0.03, 0);
		box(b, 'clothes', mat('tie_red', 0xc8323a), 0.06, 0.02, 0.3, 0.12, 0.07, 0);
		b.add('bear', mat('bear_brown', 0x9a6a3a), new THREE.SphereGeometry(0.07, 8, 6), { pos: V(-0.22, 0.09, 0.08) });
		b.add('bear', mat('bear_brown', 0x9a6a3a), new THREE.SphereGeometry(0.05, 8, 6), { pos: V(-0.22, 0.13, -0.02) });
	} else {
		box(b, 'body', black, 0.7, 0.25, 0.5, 0, 0, 0);
		box(b, 'ribbon', yellow, 0.08, 0.255, 0.505, 0, 0, 0);
		box(b, 'handle', black, 0.2, 0.04, 0.05, 0, 0, 0.27);
		box(b, 'tag', white, 0.1, 0.01, 0.07, 0.22, 0.13, 0.12);
	}
	return b.build();
}

export const models = { checkin_counter: buildCheckinCounter, xray_machine: buildXrayMachine, airplane: buildAirplane,
	duty_free_shelf: buildDutyFreeShelf, gate_seats: buildGateSeats, suitcase: () => buildSuitcase('suitcase', false),
	suitcase_open: () => buildSuitcase('suitcase_open', true) };

export const views = {
	airport_props: {
		items: [{ name: 'checkin_counter', pos: [-2.5, 0, 1.0], rotY: 0.4 }, { name: 'xray_machine', pos: [1.5, 0, 1.0], rotY: -0.3 },
			{ name: 'duty_free_shelf', pos: [-2.0, 0, -2.0], rotY: 0.2 }, { name: 'gate_seats', pos: [2.0, 0, -1.6], rotY: -0.2 }],
		cam: { pos: [0.5, 2.6, 7.5], target: [0, 0.8, -0.3], fov: 50 },
	},
	suitcases: {
		items: [{ name: 'suitcase', pos: [-0.5, 0.13, 0], rotY: 0.4 }, { name: 'suitcase_open', pos: [0.5, 0.13, 0.1], rotY: -0.3 }],
		cam: { pos: [0.3, 1.2, 2.2], target: [0, 0.15, 0], fov: 45 },
	},
	airplane: {
		items: [{ name: 'airplane', pos: [0, 0, 0], rotY: 0.6 }],
		cam: { pos: [6, 6, 18], target: [0, 2, 0], fov: 50 },
	},
};
