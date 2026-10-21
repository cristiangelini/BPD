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
	return patrolCar('patrol_car', blue, white);
}

// The old patrol car behind the station (persecucion-lugares.md, la grúa): the same car, faded, with rust patches,
// a dented door and the light bar taped on. It runs, more or less.
export function buildOldPatrolCar() {
	const faded = mat('police_faded', 0x5a77a3), cream = mat('car_cream', 0xd9d0b4), rust = mat('rust', 0x8a4a22);
	const tape = mat('tape', 0xb8b0a0);
	const b = patrolCar('old_patrol_car', faded, cream, true);
	box(b, 'body', rust, 0.02, 0.3, 0.5, W / 2 + 0.01, FLOOR + 0.3, 0.6);
	box(b, 'body', rust, 0.02, 0.2, 0.35, -(W / 2 + 0.01), FLOOR + 0.25, -0.5);
	box(b, 'body', rust, 0.5, 0.02, 0.35, -0.4, FLOOR + 0.615, 1.8);
	box(b, 'body', rust, 0.02, 0.22, 0.4, W / 2 + 0.01, FLOOR + 0.35, -1.9);
	// The dent in the front left door, and the tape holding the light bar.
	box(b, 'body', faded, 0.06, 0.35, 0.5, -(W / 2 - 0.02), FLOOR + 0.45, 0.65, [0, 0, 0.12]);
	for (const x of [-0.45, 0.45]) box(b, 'siren', tape, 0.1, 0.05, 0.34, x, ROOF + 0.26, 0.15);
	return b.build();
}

function patrolCar(name, blue, white, unbuilt = false) {
	const b = new Builder(name);
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
	return unbuilt ? b : b.build();
}

// One wheel, 0.38 m radius, axle along X, centered.
export function buildCarWheel() {
	const tire = mat('tire', 0x1b1c20), rim = mat('rim', 0xc8ccd4);
	const b = new Builder('car_wheel');
	b.add('wheel', tire, new THREE.CylinderGeometry(0.38, 0.38, 0.28, 12), { rot: [0, 0, Math.PI / 2] });
	b.add('wheel', rim, new THREE.CylinderGeometry(0.2, 0.2, 0.3, 6), { rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// The ice cream truck of the first chase suspect (persecucion.md, "El heladero"). Faces +Z, origin on the ground at
// the center, 5.2 m long, 2.2 m wide, a giant cone on the roof. Uses the same separate wheels. Placeholder, not final art.
export function buildIceCreamTruck() {
	const cream = mat('truck_cream', 0xfff4e0), pink = mat('truck_pink', 0xff8fb8), mint = mat('truck_mint', 0x8fe3c8);
	const cone = mat('cone', 0xd99a4e), scoop = mat('scoop', 0xffb6d0), darkGlass = mat('truck_glass', 0x2a3340);
	const L = 5.2, F = L / 2, R = -L / 2, BOX_F = 0.9, TOP = 2.6;
	const b = new Builder('ice_cream_truck');
	box(b, 'body', black, W, 0.2, L, 0, FLOOR - 0.1, 0);
	// Cab in front: hood, windshield, roof.
	box(b, 'body', pink, W, 0.65, F - BOX_F, 0, FLOOR + 0.32, (F + BOX_F) / 2);
	box(b, 'body', darkGlass, W - 0.1, 0.6, 0.06, 0, FLOOR + 0.95, F - 0.6, [-0.4, 0, 0]);
	box(b, 'body', pink, W, 0.12, F - BOX_F - 0.6, 0, FLOOR + 1.3, (F + BOX_F - 0.6) / 2);
	for (const x of [-1, 1]) box(b, 'body', darkGlass, 0.04, 0.5, 0.9, x * (W / 2 + 0.01), FLOOR + 0.95, BOX_F + 0.6);
	box(b, 'body', grey, W + 0.06, 0.18, 0.16, 0, FLOOR + 0.05, F + 0.04);
	for (const x of [-1, 1]) box(b, 'lights', glass, 0.36, 0.14, 0.04, x * 0.72, FLOOR + 0.42, F + 0.01);
	// The ice cream box: cream walls, a mint stripe, the serving window on the right side.
	box(b, 'box', cream, W, TOP - FLOOR, BOX_F - R, 0, (TOP + FLOOR) / 2, (BOX_F + R) / 2);
	for (const x of [-1, 1]) box(b, 'box', mint, 0.02, 0.3, BOX_F - R - 0.1, x * (W / 2 + 0.005), FLOOR + 0.55, (BOX_F + R) / 2);
	box(b, 'box', darkGlass, 0.03, 0.8, 1.6, W / 2 + 0.01, FLOOR + 1.45, -0.6);
	box(b, 'box', pink, 0.5, 0.06, 1.8, W / 2 + 0.22, FLOOR + 1.95, -0.6, [0, 0, -0.35]);
	box(b, 'box', grey, W + 0.06, 0.18, 0.16, 0, FLOOR + 0.05, R - 0.04);
	for (const x of [-1, 1]) box(b, 'lights', tail, 0.3, 0.14, 0.04, x * 0.72, FLOOR + 0.42, R - 0.01);
	// Giant cone on the roof, tip down, with two scoops.
	b.add('cone', cone, new THREE.ConeGeometry(0.45, 1.1, 8), { pos: V(0, TOP + 0.55, -0.8), rot: [Math.PI, 0, 0] });
	b.add('cone', scoop, new THREE.SphereGeometry(0.5, 8, 6), { pos: V(0, TOP + 1.25, -0.8) });
	b.add('cone', mint, new THREE.SphereGeometry(0.4, 8, 6), { pos: V(0, TOP + 1.8, -0.8) });
	for (const x of [-1, 1]) for (const z of [1.7, -1.7]) box(b, 'body', black, 0.1, 0.5, 0.95, x * (W / 2 + 0.01), FLOOR + 0.1, z);
	return b.build();
}

// Moving truck (persecución, sospechoso 3): orange cab, a tall brown box with a rolled-up back door, furniture piled
// inside and a rope that clearly isn't holding anything. Same size as the ice cream truck, so it drives the same.
export function buildMovingTruck() {
	const orange = mat('moving_orange', 0xe8873a), brown = mat('moving_brown', 0x8a5a36), darkGlass = mat('truck_glass', 0x2a3340);
	const rope = mat('rope', 0xd8c08a), sofa = mat('moving_sofa', 0x5a7fbf), wood = mat('moving_wood', 0xb07a48), cardboard = mat('cardboard', 0xc89c62);
	const L = 5.2, F = L / 2, R = -L / 2, BOX_F = 0.9, TOP = 2.9;
	const b = new Builder('moving_truck');
	box(b, 'body', black, W, 0.2, L, 0, FLOOR - 0.1, 0);
	box(b, 'body', orange, W, 0.65, F - BOX_F, 0, FLOOR + 0.32, (F + BOX_F) / 2);
	box(b, 'body', darkGlass, W - 0.1, 0.6, 0.06, 0, FLOOR + 0.95, F - 0.6, [-0.4, 0, 0]);
	box(b, 'body', orange, W, 0.12, F - BOX_F - 0.6, 0, FLOOR + 1.3, (F + BOX_F - 0.6) / 2);
	for (const x of [-1, 1]) box(b, 'body', darkGlass, 0.04, 0.5, 0.9, x * (W / 2 + 0.01), FLOOR + 0.95, BOX_F + 0.6);
	box(b, 'body', grey, W + 0.06, 0.18, 0.16, 0, FLOOR + 0.05, F + 0.04);
	for (const x of [-1, 1]) box(b, 'lights', glass, 0.36, 0.14, 0.04, x * 0.72, FLOOR + 0.42, F + 0.01);
	// The box: two walls and a roof, open at the back with the door rolled up.
	for (const x of [-1, 1]) box(b, 'box', brown, 0.08, TOP - FLOOR, BOX_F - R, x * (W / 2 - 0.04), (TOP + FLOOR) / 2, (BOX_F + R) / 2);
	box(b, 'box', brown, W, 0.08, BOX_F - R, 0, TOP, (BOX_F + R) / 2);
	box(b, 'box', brown, W, TOP - FLOOR, 0.08, 0, (TOP + FLOOR) / 2, BOX_F);
	box(b, 'box', grey, W, 0.25, 0.25, 0, TOP - 0.15, R + 0.12);
	for (const x of [-1, 1]) box(b, 'box', orange, 0.02, 0.35, BOX_F - R - 0.3, x * (W / 2 + 0.005), FLOOR + 1.6, (BOX_F + R) / 2);
	box(b, 'box', grey, W + 0.06, 0.18, 0.16, 0, FLOOR + 0.05, R - 0.04);
	for (const x of [-1, 1]) box(b, 'lights', tail, 0.3, 0.14, 0.04, x * 0.72, FLOOR + 0.42, R - 0.01);
	// The furniture inside, piled too high, and a loose rope across the back.
	box(b, 'load', sofa, 1.8, 0.7, 0.8, 0, FLOOR + 0.45, -0.3);
	box(b, 'load', wood, 0.9, 1.5, 0.5, -0.45, FLOOR + 1.6, -1.2, [0, 0, 0.12]);
	box(b, 'load', cardboard, 0.6, 0.5, 0.6, 0.5, FLOOR + 1.1, -1.5);
	box(b, 'load', cardboard, 0.5, 0.4, 0.5, 0.55, FLOOR + 1.55, -1.5, [0, 0.4, 0]);
	b.add('load', rope, new THREE.CylinderGeometry(0.025, 0.025, W - 0.2, 5), { pos: V(0, FLOOR + 1.3, R + 0.05), rot: [0, 0, Math.PI / 2 + 0.15] });
	for (const x of [-1, 1]) for (const z of [1.7, -1.7]) box(b, 'body', black, 0.1, 0.5, 0.95, x * (W / 2 + 0.01), FLOOR + 0.1, z);
	return b.build();
}

// What falls off the moving truck: a sofa, a wardrobe, a floor lamp and a cardboard box. Origin on the ground.
export function buildFallingSofa() {
	const b = new Builder('falling_sofa'), m = mat('moving_sofa', 0x5a7fbf);
	box(b, 'sofa', m, 1.8, 0.45, 0.8, 0, 0.23, 0);
	box(b, 'sofa', m, 1.8, 0.5, 0.2, 0, 0.7, -0.3);
	for (const x of [-1, 1]) box(b, 'sofa', m, 0.2, 0.3, 0.8, x * 0.8, 0.6, 0);
	return b.build();
}
export function buildFallingWardrobe() {
	const b = new Builder('falling_wardrobe'), m = mat('moving_wood', 0xb07a48), knob = mat('knob', 0x3a2414);
	box(b, 'wardrobe', m, 0.9, 1.5, 0.5, 0, 0.75, 0);
	box(b, 'wardrobe', knob, 0.02, 1.3, 0.02, 0, 0.75, 0.26);
	for (const x of [-1, 1]) box(b, 'wardrobe', knob, 0.05, 0.05, 0.04, x * 0.08, 0.8, 0.27);
	return b.build();
}
export function buildFallingLamp() {
	const b = new Builder('falling_lamp'), metal = mat('lamp_metal', 0x3a3a40), shade = mat('lamp_shade', 0xf2d98a);
	b.add('lamp', metal, new THREE.CylinderGeometry(0.2, 0.22, 0.05, 8), { pos: V(0, 0.03, 0) });
	b.add('lamp', metal, new THREE.CylinderGeometry(0.025, 0.025, 1.4, 5), { pos: V(0, 0.72, 0) });
	b.add('lamp', shade, new THREE.CylinderGeometry(0.15, 0.28, 0.3, 8, 1, true), { pos: V(0, 1.45, 0) });
	return b.build();
}
export function buildFallingBox() {
	const b = new Builder('falling_box'), m = mat('cardboard', 0xc89c62), tape = mat('tape', 0xe8d8a8);
	box(b, 'box', m, 0.6, 0.5, 0.6, 0, 0.25, 0);
	box(b, 'box', tape, 0.12, 0.01, 0.62, 0, 0.505, 0);
	return b.build();
}

// School bus (persecución, sospechoso 5): long and yellow, a black stripe, a stop sign arm on the left and a row of
// windows full of kids' heads. 8.4 m long, 2.5 m wide; faces +Z like the rest.
export function buildSchoolBus() {
	const yellow = mat('bus_yellow', 0xf5c21b), darkGlass = mat('truck_glass', 0x2a3340), stop = mat('stop_red', 0xd8282a);
	const skins = [0xf3d2b0, 0xd9a06b, 0x9a6440, 0xffd0a8].map((c, i) => mat('kid_skin_' + i, c));
	const hair = [0x2a1a10, 0xe8c060, 0x7a3a1a, 0x1a1410].map((c, i) => mat('kid_hair_' + i, c));
	const BW = 2.5, L = 8.4, F = L / 2, R = -L / 2, TOP = 3.0, NOSE = 1.4;
	const b = new Builder('school_bus');
	box(b, 'body', black, BW, 0.2, L, 0, FLOOR - 0.1, 0);
	// Short hood in front, then the long box.
	box(b, 'body', yellow, BW - 0.2, 0.8, NOSE, 0, FLOOR + 0.4, F - NOSE / 2);
	box(b, 'body', yellow, BW, TOP - FLOOR, L - NOSE, 0, (TOP + FLOOR) / 2, (F - NOSE + R) / 2);
	box(b, 'body', darkGlass, BW - 0.2, 0.9, 0.05, 0, FLOOR + 1.75, F - NOSE + 0.01);
	box(b, 'body', grey, BW + 0.06, 0.2, 0.16, 0, FLOOR + 0.05, F + 0.04);
	for (const x of [-1, 1]) box(b, 'lights', glass, 0.3, 0.16, 0.04, x * 0.8, FLOOR + 0.5, F + 0.01);
	for (const x of [-1, 1]) {
		box(b, 'body', black, 0.02, 0.12, L - NOSE - 0.2, x * (BW / 2 + 0.005), FLOOR + 0.95, (F - NOSE + R) / 2);
		// Windows, with a kid's head in each, shouting.
		for (let i = 0; i < 6; i++) {
			const z = F - NOSE - 0.7 - i * 1.0;
			box(b, 'windows', darkGlass, 0.03, 0.7, 0.8, x * (BW / 2 + 0.01), FLOOR + 1.75, z);
			b.add('kids', skins[(i + (x > 0 ? 1 : 0)) % 4], new THREE.SphereGeometry(0.17, 7, 5), { pos: V(x * (BW / 2 - 0.02), FLOOR + 1.72, z) });
			b.add('kids', hair[(i * 3 + (x > 0 ? 2 : 0)) % 4], new THREE.SphereGeometry(0.175, 7, 5, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(x * (BW / 2 - 0.02), FLOOR + 1.77, z) });
		}
	}
	box(b, 'body', stop, 0.04, 0.4, 0.4, -(BW / 2 + 0.12), FLOOR + 1.3, F - NOSE - 0.4);
	box(b, 'body', grey, BW + 0.06, 0.2, 0.16, 0, FLOOR + 0.05, R - 0.04);
	for (const x of [-1, 1]) box(b, 'lights', tail, 0.3, 0.16, 0.04, x * 0.8, FLOOR + 0.5, R - 0.01);
	box(b, 'body', darkGlass, BW - 0.4, 0.8, 0.04, 0, FLOOR + 1.75, R - 0.01);
	for (const x of [-1, 1]) for (const z of [2.7, -2.6]) box(b, 'body', black, 0.1, 0.55, 1.0, x * (BW / 2 + 0.01), FLOOR + 0.12, z);
	return b.build();
}

// The getaway car (persecución, sospechosos 7 y 10: bajo la lluvia y de noche): a plain dark sedan with tinted windows
// and its lights off, the kind you lose at night. 4.6 m long, 2.1 m wide; faces +Z like the rest.
export function buildGetawayCar() {
	return buildSedan('getaway_car', mat('getaway_paint', 0x2c3038), mat('lamp_off', 0x5a5a50), mat('tail_off', 0x501018));
}

// The highway's traffic (persecución, la autopista): the same plain sedan in everyday colors, lights on.
const TRAFFIC_PAINTS = [0xf2f2ee, 0xe8c547, 0x5b9a5a, 0x7aa6d8];
const trafficCar = (i) => () => buildSedan('traffic_car_' + i, mat('traffic_paint_' + i, TRAFFIC_PAINTS[i]),
	mat('lamp', 0xf4f0d0), mat('tail', 0xc0202a));

function buildSedan(name, paint, lampOff, tailOff) {
	const tint = mat('getaway_glass', 0x14181e), chrome = mat('chrome', 0x9aa0a8);
	const CW = 2.1, F = 2.3, R = -2.3, HOOD = 0.95, CABIN_F = 0.9, CABIN_R = -1.2, TOP = 1.55;
	const b = new Builder(name);
	box(b, 'body', black, CW, 0.2, F - R, 0, FLOOR - 0.1, 0);
	box(b, 'body', paint, CW, HOOD - FLOOR, F - R, 0, (HOOD + FLOOR) / 2, 0);
	// The cabin: a narrower box with tinted windows all around, and the roof on top.
	box(b, 'body', tint, CW - 0.16, TOP - HOOD - 0.06, CABIN_F - CABIN_R, 0, (TOP + HOOD) / 2 - 0.03, (CABIN_F + CABIN_R) / 2);
	box(b, 'body', paint, CW - 0.1, 0.07, CABIN_F - CABIN_R - 0.3, 0, TOP, (CABIN_F + CABIN_R) / 2);
	for (const x of [-1, 1]) {
		box(b, 'frame', paint, 0.07, TOP - HOOD, 0.08, x * (CW / 2 - 0.08), (TOP + HOOD) / 2, CABIN_F - 0.12, [-0.4, 0, 0]);
		box(b, 'frame', paint, 0.07, TOP - HOOD, 0.1, x * (CW / 2 - 0.08), (TOP + HOOD) / 2, (CABIN_F + CABIN_R) / 2);
		box(b, 'frame', paint, 0.07, TOP - HOOD, 0.08, x * (CW / 2 - 0.08), (TOP + HOOD) / 2, CABIN_R + 0.12, [0.4, 0, 0]);
		box(b, 'body', chrome, 0.02, 0.04, 0.2, x * (CW / 2 + 0.005), HOOD - 0.12, 0.2);
		box(b, 'body', chrome, 0.02, 0.04, 0.2, x * (CW / 2 + 0.005), HOOD - 0.12, -0.8);
		box(b, 'lights', lampOff, 0.34, 0.12, 0.04, x * 0.7, FLOOR + 0.4, F + 0.01);
		box(b, 'lights', tailOff, 0.34, 0.12, 0.04, x * 0.7, FLOOR + 0.4, R - 0.01);
		for (const z of [1.55, -1.55]) box(b, 'body', black, 0.1, 0.5, 0.95, x * (CW / 2 + 0.01), FLOOR + 0.1, z);
	}
	box(b, 'body', grey, CW + 0.06, 0.16, 0.14, 0, FLOOR + 0.05, F + 0.04);
	box(b, 'body', grey, CW + 0.06, 0.16, 0.14, 0, FLOOR + 0.05, R - 0.04);
	return b.build();
}

// The sports car (persecución, sospechoso 6: en la autopista): low, bright red, a long hood, a black stripe and a
// spoiler on the back. 4.6 m long, 2.1 m wide; faces +Z like the rest, and takes the sedan's wheels.
export function buildSportsCar() {
	const paint = mat('sports_red', 0xd8241c), tint = mat('getaway_glass', 0x14181e), stripe = mat('sports_stripe', 0x1a1a1e);
	const lamp = mat('lamp', 0xf4f0d0), tail = mat('tail', 0xc0202a);
	const CW = 2.1, F = 2.3, R = -2.3, HOOD = 0.78, CABIN_F = 0.3, CABIN_R = -1.4, TOP = 1.22;
	const b = new Builder('sports_car');
	box(b, 'body', black, CW, 0.2, F - R, 0, FLOOR - 0.1, 0);
	box(b, 'body', paint, CW, HOOD - FLOOR, F - R, 0, (HOOD + FLOOR) / 2, 0);
	box(b, 'body', stripe, 0.4, 0.02, F - R, 0, HOOD + 0.005, 0);
	// The cabin sits far back, low, its windshield leaning; tinted windows all around.
	box(b, 'body', tint, CW - 0.3, TOP - HOOD, CABIN_F - CABIN_R, 0, (TOP + HOOD) / 2, (CABIN_F + CABIN_R) / 2);
	box(b, 'body', paint, CW - 0.26, 0.06, CABIN_F - CABIN_R - 0.5, 0, TOP, (CABIN_F + CABIN_R) / 2 - 0.1);
	box(b, 'body', tint, CW - 0.32, 0.05, 0.55, 0, (TOP + HOOD) / 2, CABIN_F + 0.15, [1.0, 0, 0]);
	// The spoiler: a wing on two posts over the trunk.
	for (const x of [-0.6, 0.6]) box(b, 'body', stripe, 0.08, 0.22, 0.08, x, HOOD + 0.11, R + 0.3);
	box(b, 'body', stripe, CW - 0.1, 0.05, 0.36, 0, HOOD + 0.24, R + 0.3);
	for (const x of [-1, 1]) {
		box(b, 'lights', lamp, 0.4, 0.08, 0.04, x * 0.7, HOOD - 0.15, F + 0.01);
		box(b, 'lights', tail, 0.46, 0.08, 0.04, x * 0.65, HOOD - 0.12, R - 0.01);
		for (const z of [1.55, -1.55]) box(b, 'body', black, 0.1, 0.45, 0.95, x * (CW / 2 + 0.01), FLOOR + 0.08, z);
	}
	box(b, 'body', grey, CW + 0.04, 0.12, 0.14, 0, FLOOR + 0.02, F + 0.04);
	return b.build();
}

// The tow truck (persecución, sospechoso 8: la grúa): an orange cab, a flat back with the crane's boom leaning back and
// its hook hanging over the rear, an amber light bar. 6.2 m long, 2.3 m wide; faces +Z, takes the truck's wheels apart.
export function buildTowTruck() {
	const orange = mat('tow_orange', 0xf08a1c), dark = mat('tow_dark', 0x2b2d33), amber = mat('amber', 0xffb020, { emissive: 0x603800 });
	const steel = mat('steel', 0x8c9098), glassDark = mat('truck_glass', 0x2a3340);
	const BW = 2.3, F = 3.1, R = -3.1, CAB_R = 0.9, TOP = 2.6;
	const b = new Builder('tow_truck');
	box(b, 'body', black, BW, 0.25, F - R, 0, FLOOR - 0.05, 0);
	// The cab up front, with its windows and the light bar.
	box(b, 'body', orange, BW, TOP - FLOOR, F - CAB_R, 0, (TOP + FLOOR) / 2, (F + CAB_R) / 2);
	box(b, 'body', glassDark, BW - 0.3, 0.7, 0.04, 0, TOP - 0.55, F + 0.01);
	for (const x of [-1, 1]) box(b, 'body', glassDark, 0.04, 0.6, 1.0, x * (BW / 2 + 0.01), TOP - 0.6, (F + CAB_R) / 2 + 0.2);
	box(b, 'body', dark, 1.4, 0.1, 0.3, 0, TOP + 0.05, (F + CAB_R) / 2);
	for (const x of [-0.45, 0.45]) box(b, 'lights', amber, 0.5, 0.16, 0.26, x, TOP + 0.17, (F + CAB_R) / 2);
	box(b, 'lights', glass, 0.4, 0.16, 0.04, -0.75, FLOOR + 0.45, F + 0.01);
	box(b, 'lights', glass, 0.4, 0.16, 0.04, 0.75, FLOOR + 0.45, F + 0.01);
	// The flat back, the crane's base and its boom leaning back over the rear, the cable and the hook.
	box(b, 'body', dark, BW, 0.35, CAB_R - R, 0, FLOOR + 0.3, (CAB_R + R) / 2);
	box(b, 'body', orange, 0.7, 0.6, 0.7, 0, FLOOR + 0.75, -0.6);
	box(b, 'body', steel, 0.3, 0.3, 2.8, 0, FLOOR + 1.6, -1.8, [0.45, 0, 0]);
	box(b, 'body', steel, 0.04, 1.0, 0.04, 0, FLOOR + 1.85, R - 0.15);
	box(b, 'body', dark, 0.3, 0.25, 0.2, 0, FLOOR + 1.25, R - 0.15);
	box(b, 'body', steel, BW + 0.06, 0.2, 0.16, 0, FLOOR + 0.1, R - 0.04);
	for (const x of [-1, 1]) {
		box(b, 'lights', tail, 0.3, 0.14, 0.04, x * 0.85, FLOOR + 0.35, R - 0.01);
		for (const z of [2.0, -1.8]) box(b, 'body', black, 0.1, 0.55, 1.0, x * (BW / 2 + 0.01), FLOOR + 0.12, z);
	}
	box(b, 'body', grey, BW + 0.06, 0.2, 0.16, 0, FLOOR + 0.05, F + 0.04);
	return b.build();
}

// The delivery scooter (persecución, sospechoso 2): a small red scooter with the delivery box on the back and the
// delivery guy (npc_repartidor) rides it, standing on the board. 1.9 m long, 0.7 m wide; faces +Z like the rest. Its wheels are part of it.
export function buildDeliveryScooter() {
	const red = mat('scooter_red', 0xd8322a), tire = mat('tire', 0x1a1a1e), rim = mat('rim', 0xc8ccd2);
	const jacket = mat('delivery_red', 0xd8322a), thermal = mat('thermal_box', 0xf2b01e);
	const b = new Builder('delivery_scooter');
	for (const z of [0.68, -0.68]) {
		b.add('wheels', tire, new THREE.CylinderGeometry(0.26, 0.26, 0.12, 10), { pos: V(0, 0.26, z), rot: [0, 0, Math.PI / 2] });
		b.add('wheels', rim, new THREE.CylinderGeometry(0.12, 0.12, 0.13, 8), { pos: V(0, 0.26, z), rot: [0, 0, Math.PI / 2] });
	}
	// Floorboard, the body under the seat, the front shield and the handlebar.
	box(b, 'body', red, 0.36, 0.1, 0.8, 0, 0.32, 0.05);
	box(b, 'body', red, 0.42, 0.36, 0.6, 0, 0.5, -0.45);
	box(b, 'body', black, 0.36, 0.08, 0.5, 0, 0.72, -0.4);
	box(b, 'body', red, 0.38, 0.75, 0.1, 0, 0.7, 0.55, [-0.25, 0, 0]);
	box(b, 'body', grey, 0.05, 0.05, 0.3, 0, 0.95, 0.68, [-0.3, 0, 0]);
	box(b, 'body', black, 0.6, 0.04, 0.04, 0, 1.12, 0.62);
	box(b, 'lights', glass, 0.14, 0.1, 0.03, 0, 0.98, 0.72);
	// The delivery box on the back.
	box(b, 'box', thermal, 0.5, 0.45, 0.45, 0, 1.0, -0.72);
	box(b, 'box', jacket, 0.3, 0.12, 0.02, 0, 1.05, -0.96);
	return b.build();
}

// The electric wheelchair (persecución, sospechoso 9): two big wheels, two small ones in front, a joystick on the arm
// and a little flag on a pole so everyone sees him coming. The grandpa (npc_abuelo) sits in it. 1.2 m long, 0.75 m
// wide; faces +Z like the rest. Its wheels are part of it.
export function buildWheelchair() {
	const frame = mat('chair_frame', 0x3a3e46), cushion = mat('chair_cushion', 0x2a5ab0), tire = mat('tire', 0x1a1a1e);
	const rim = mat('rim', 0xc8ccd2), flag = mat('chair_flag', 0xff7a1a), battery = mat('battery', 0x202226);
	const b = new Builder('wheelchair');
	for (const x of [-1, 1]) {
		b.add('wheels', tire, new THREE.CylinderGeometry(0.32, 0.32, 0.08, 12), { pos: V(x * 0.38, 0.32, -0.15), rot: [0, 0, Math.PI / 2] });
		b.add('wheels', rim, new THREE.CylinderGeometry(0.24, 0.24, 0.09, 10), { pos: V(x * 0.38, 0.32, -0.15), rot: [0, 0, Math.PI / 2] });
		b.add('wheels', tire, new THREE.CylinderGeometry(0.1, 0.1, 0.06, 8), { pos: V(x * 0.28, 0.1, 0.4), rot: [0, 0, Math.PI / 2] });
		box(b, 'frame', frame, 0.04, 0.04, 0.6, x * 0.3, 0.22, 0.12);
		// Armrests, the right one with the joystick.
		box(b, 'frame', frame, 0.06, 0.04, 0.45, x * 0.3, 0.72, 0.0);
		box(b, 'frame', frame, 0.04, 0.24, 0.04, x * 0.3, 0.6, 0.2);
	}
	box(b, 'seat', cushion, 0.56, 0.1, 0.5, 0, 0.48, 0.0);
	box(b, 'seat', cushion, 0.56, 0.6, 0.08, 0, 0.82, -0.27, [-0.1, 0, 0]);
	box(b, 'frame', battery, 0.4, 0.22, 0.3, 0, 0.3, -0.12);
	box(b, 'frame', frame, 0.4, 0.04, 0.14, 0, 0.12, 0.48);
	b.add('frame', black, new THREE.CylinderGeometry(0.02, 0.02, 0.1, 6), { pos: V(0.3, 0.8, 0.18) });
	b.add('frame', mat('joystick_knob', 0xd8322a), new THREE.SphereGeometry(0.035, 6, 4), { pos: V(0.3, 0.86, 0.18) });
	b.add('flag', frame, new THREE.CylinderGeometry(0.012, 0.012, 1.4, 5), { pos: V(-0.32, 1.25, -0.3) });
	b.add('flag', flag, new THREE.BoxGeometry(0.01, 0.2, 0.3), { pos: V(-0.32, 1.85, -0.45) });
	return b.build();
}

export const models = { patrol_car: buildPatrolCar, old_patrol_car: buildOldPatrolCar, car_wheel: buildCarWheel, ice_cream_truck: buildIceCreamTruck,
	moving_truck: buildMovingTruck, falling_sofa: buildFallingSofa, falling_wardrobe: buildFallingWardrobe, falling_lamp: buildFallingLamp,
	falling_box: buildFallingBox, school_bus: buildSchoolBus, getaway_car: buildGetawayCar, sports_car: buildSportsCar, tow_truck: buildTowTruck,
	traffic_car_0: trafficCar(0), traffic_car_1: trafficCar(1), traffic_car_2: trafficCar(2), traffic_car_3: trafficCar(3),
	delivery_scooter: buildDeliveryScooter, wheelchair: buildWheelchair };

const wheels = [[-1.1, 1.55], [1.1, 1.55], [-1.1, -1.55], [1.1, -1.55]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] }));
export const views = {
	patrol_car: {
		items: [{ name: 'patrol_car', pos: [0, 0, 0] }, ...wheels, { name: 'cop_0', pos: [2.2, 0, -1.5], rotY: -0.6 }],
		cam: { pos: [6.5, 3.8, 6.5], target: [0, 0.9, 0], fov: 38 },
	},
	old_patrol_car: {
		items: [{ name: 'old_patrol_car', pos: [0, 0, 0] }, ...wheels],
		cam: { pos: [6.5, 3.8, 6.5], target: [0, 0.9, 0], fov: 38 },
	},
	ice_cream_truck: {
		items: [{ name: 'ice_cream_truck', pos: [0, 0, 0] }, ...[[-1.1, 1.7], [1.1, 1.7], [-1.1, -1.7], [1.1, -1.7]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] }))],
		cam: { pos: [7.5, 4.2, 6.5], target: [0, 1.2, 0], fov: 38 },
	},
	school_bus: {
		items: [{ name: 'school_bus', pos: [0, 0, 0] }, ...[[-1.15, 2.7], [1.15, 2.7], [-1.15, -2.6], [1.15, -2.6]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] }))],
		cam: { pos: [9.5, 4.8, 8.5], target: [0, 1.4, 0], fov: 40 },
	},
	wheelchair: {
		items: [{ name: 'wheelchair', pos: [0, 0, 0] }, { name: 'npc_abuelo', pos: [0, 0.12, 0.02], scale: 0.72 }],
		cam: { pos: [2.6, 1.6, 2.6], target: [0, 0.75, 0], fov: 38 },
	},
	delivery_scooter: {
		items: [{ name: 'delivery_scooter', pos: [0, 0, 0] }, { name: 'npc_repartidor', pos: [0, 0.36, -0.15], scale: 0.85 }],
		cam: { pos: [4.0, 2.2, 3.6], target: [0.5, 0.8, 0], fov: 38 },
	},
	getaway_car: {
		items: [{ name: 'getaway_car', pos: [0, 0, 0] }, ...[[-1.05, 1.55], [1.05, 1.55], [-1.05, -1.55], [1.05, -1.55]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] }))],
		cam: { pos: [6.5, 3.6, 6.0], target: [0, 0.9, 0], fov: 38 },
	},
	traffic_car_1: {
		items: [{ name: 'traffic_car_1', pos: [0, 0, 0] }, ...[[-1.05, 1.55], [1.05, 1.55], [-1.05, -1.55], [1.05, -1.55]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] }))],
		cam: { pos: [6.5, 3.6, 6.0], target: [0, 0.9, 0], fov: 38 },
	},
	tow_truck: {
		items: [{ name: 'tow_truck', pos: [0, 0, 0] }, ...[[-1.15, 2.0], [1.15, 2.0], [-1.15, -1.8], [1.15, -1.8]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] })),
			{ name: 'patrol_car', pos: [0, 0.6, -5.4], rot: [-0.12, 0, 0] }, ...wheels.map((w) => ({ ...w, pos: [w.pos[0], w.pos[1] + 0.6, w.pos[2] - 5.4] }))],
		cam: { pos: [9.0, 4.5, 4.0], target: [0, 1.0, -2.0], fov: 42 },
	},
	sports_car: {
		items: [{ name: 'sports_car', pos: [0, 0, 0] }, ...[[-1.05, 1.55], [1.05, 1.55], [-1.05, -1.55], [1.05, -1.55]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] }))],
		cam: { pos: [6.5, 3.2, 6.0], target: [0, 0.7, 0], fov: 38 },
	},
	moving_truck: {
		items: [{ name: 'moving_truck', pos: [0, 0, 0], rotY: Math.PI }, ...[[-1.1, 1.7], [1.1, 1.7], [-1.1, -1.7], [1.1, -1.7]].map(([x, z]) => ({ name: 'car_wheel', pos: [x, 0.38, z] })),
			{ name: 'falling_sofa', pos: [3.2, 0, -1.5], rotY: 0.4 }, { name: 'falling_wardrobe', pos: [3.4, 0, 0.6], rotY: -0.3 },
			{ name: 'falling_lamp', pos: [2.6, 0, 1.8] }, { name: 'falling_box', pos: [3.6, 0, 2.2], rotY: 0.6 }],
		cam: { pos: [7.5, 4.2, -6.5], target: [0.8, 1.2, 0], fov: 42 },
	},
};
