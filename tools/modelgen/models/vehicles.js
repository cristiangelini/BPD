// Patrol car for case 1.1 (allanamiento.md, "Patrullero"). Faces +Z, origin on the ground at the center.
// 4.8 m long, 2.2 m wide (two pear cops side by side), roof at 1.95 m. Wheels are a separate model so Godot spins them.
// The cabin is hollow with open windows (cops lean out) and the trunk is an open box with the lid up.
// Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

const blue = mat('police_blue', 0x1f4fbf), white = mat('car_white', 0xf4f4f0), black = mat('car_black', 0x23252b);
const grey = mat('car_grey', 0x6b7280), seat = mat('seat', 0x3b3f4a), red = mat('siren_red', 0xff2a3a, { emissive: 0x801018 });
const sirenBlue = mat('siren_blue', 0x2a7bff, { emissive: 0x0c2a80 }), glass = mat('lamp', 0xfff3c0, { emissive: 0x806a20 });
const tail = mat('tail', 0xd01828, { emissive: 0x500810 }), gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });

const W = 2.2, FRONT = 2.4, REAR = -2.4, CABIN_F = 1.2, CABIN_R = -1.0, SILL = 1.1, ROOF = 1.95, FLOOR = 0.35;

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

export function buildPatrolCar() {
	const b = new Builder('patrol_car');
	// Chassis floor and the lower skirt all around.
	box(b, 'body', black, W, 0.2, FRONT - REAR, 0, FLOOR - 0.1, 0);
	// Hood (front) and its bumper.
	box(b, 'body', blue, W, 0.6, FRONT - CABIN_F, 0, FLOOR + 0.3, (FRONT + CABIN_F) / 2);
	box(b, 'body', white, W * 0.98, 0.02, FRONT - CABIN_F - 0.1, 0, FLOOR + 0.61, (FRONT + CABIN_F) / 2);
	box(b, 'body', grey, W + 0.06, 0.18, 0.16, 0, FLOOR + 0.05, FRONT + 0.04);
	for (const x of [-1, 1]) box(b, 'lights', glass, 0.36, 0.14, 0.04, x * 0.72, FLOOR + 0.42, FRONT + 0.01);
	// Dashboard and windshield frame.
	box(b, 'body', black, W - 0.1, 0.25, 0.3, 0, SILL - 0.05, CABIN_F - 0.1);
	b.add('body', black, new THREE.TorusGeometry(0.17, 0.03, 4, 10), { pos: V(0.5, SILL + 0.05, CABIN_F - 0.35), rot: [-1.1, 0, 0] });
	// Door panels: blue below, white stripe, up to the window sill. Split in front and back doors.
	for (const x of [-1, 1]) {
		box(b, 'body', blue, 0.08, SILL - FLOOR, CABIN_F - CABIN_R, x * (W / 2 - 0.04), (SILL + FLOOR) / 2, (CABIN_F + CABIN_R) / 2);
		box(b, 'body', white, 0.02, 0.24, CABIN_F - CABIN_R - 0.1, x * (W / 2 + 0.005), SILL - 0.25, (CABIN_F + CABIN_R) / 2);
		box(b, 'body', black, 0.03, SILL - FLOOR - 0.05, 0.03, x * (W / 2 + 0.01), (SILL + FLOOR) / 2, 0.1);
		box(b, 'body', gold, 0.02, 0.14, 0.14, x * (W / 2 + 0.02), SILL - 0.25, 0.65, [0, 0, Math.PI / 4]);
		// Pillars: front (slanted), middle, back.
		box(b, 'frame', white, 0.08, ROOF - SILL, 0.08, x * (W / 2 - 0.06), (ROOF + SILL) / 2, CABIN_F - 0.15, [-0.35, 0, 0]);
		box(b, 'frame', white, 0.08, ROOF - SILL, 0.1, x * (W / 2 - 0.06), (ROOF + SILL) / 2, 0.1);
		box(b, 'frame', white, 0.08, ROOF - SILL, 0.1, x * (W / 2 - 0.06), (ROOF + SILL) / 2, CABIN_R + 0.05);
	}
	// Roof, light bar and the back wall of the cabin (open window above it, toward the trunk).
	box(b, 'body', white, W - 0.04, 0.08, CABIN_F - CABIN_R - 0.2, 0, ROOF, (CABIN_F + CABIN_R) / 2 - 0.05);
	box(b, 'siren', black, 1.2, 0.08, 0.3, 0, ROOF + 0.08, 0.15);
	box(b, 'siren_red', red, 0.5, 0.14, 0.26, -0.3, ROOF + 0.18, 0.15);
	box(b, 'siren_blue', sirenBlue, 0.5, 0.14, 0.26, 0.3, ROOF + 0.18, 0.15);
	box(b, 'body', blue, W, SILL - FLOOR, 0.08, 0, (SILL + FLOOR) / 2, CABIN_R);
	// Seats: two rows of two.
	for (const z of [0.55, -0.45]) for (const x of [-1, 1]) {
		box(b, 'seats', seat, 0.8, 0.2, 0.6, x * 0.5, FLOOR + 0.15, z);
		box(b, 'seats', seat, 0.8, 0.7, 0.14, x * 0.5, FLOOR + 0.55, z - 0.35, [-0.15, 0, 0]);
	}
	// Trunk: open box behind the cabin, lid raised on its hinge.
	const TRUNK_TOP = 0.95;
	box(b, 'trunk', grey, W - 0.16, 0.04, CABIN_R - REAR - 0.1, 0, FLOOR + 0.02, (CABIN_R + REAR) / 2);
	for (const x of [-1, 1]) box(b, 'trunk', blue, 0.08, TRUNK_TOP - FLOOR, CABIN_R - REAR, x * (W / 2 - 0.04), (TRUNK_TOP + FLOOR) / 2, (CABIN_R + REAR) / 2);
	box(b, 'trunk', blue, W, TRUNK_TOP - FLOOR, 0.08, 0, (TRUNK_TOP + FLOOR) / 2, REAR + 0.04);
	box(b, 'trunk', grey, W + 0.06, 0.18, 0.16, 0, FLOOR + 0.05, REAR - 0.04);
	for (const x of [-1, 1]) box(b, 'lights', tail, 0.36, 0.14, 0.04, x * 0.72, FLOOR + 0.42, REAR - 0.01);
	box(b, 'trunk', white, W - 0.1, CABIN_R - REAR - 0.1, 0.05, 0, TRUNK_TOP + 0.55, CABIN_R - 0.15, [0.35, 0, 0]);
	// Wheel arches (dark) so the separate wheels sit in them.
	for (const x of [-1, 1]) for (const z of [1.55, -1.55]) box(b, 'body', black, 0.1, 0.5, 0.95, x * (W / 2 + 0.01), FLOOR + 0.1, z);
	return b.build();
}

// One wheel, 0.38 m radius, axle along X, centered.
export function buildCarWheel() {
	const tire = mat('tire', 0x1b1c20), rim = mat('rim', 0xc8ccd4);
	const b = new Builder('car_wheel');
	b.add('wheel', tire, new THREE.CylinderGeometry(0.38, 0.38, 0.28, 12), { rot: [0, 0, Math.PI / 2] });
	b.add('wheel', rim, new THREE.CylinderGeometry(0.2, 0.2, 0.3, 6), { rot: [0, 0, Math.PI / 2] });
	return b.build();
}

export const models = { patrol_car: buildPatrolCar, car_wheel: buildCarWheel };

const wheels = [[-1.1, 1.55], [1.1, 1.55], [-1.1, -1.55], [1.1, -1.55]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] }));
export const views = {
	patrol_car: {
		items: [{ name: 'patrol_car', pos: [0, 0, 0] }, ...wheels, { name: 'cop_0', pos: [2.2, 0, -1.5], rotY: -0.6 }],
		cam: { pos: [6.5, 3.8, 6.5], target: [0, 0.9, 0], fov: 38 },
	},
};
