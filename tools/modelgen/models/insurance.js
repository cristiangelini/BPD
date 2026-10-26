// Props of the insurance office "Seguros Todo Tranquilo" (docs/diseno/seguros.md): the rolling chairs, the fragile
// monitors and glass trophies, the coffee machine and the water cooler, with origins at the middle of each piece (the
// chair's and the machine's at the floor). Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// A rolling office chair: five legs on wheels, a gas column, a padded seat and a tall back, 1 m tall.
export function buildOfficeChair() {
	const b = new Builder('office_chair');
	const black = mat('chair_black', 0x26262b), fabric = mat('chair_fabric', 0x3a5a8a), chrome = mat('chair_chrome', 0xb8bcc4);
	for (let i = 0; i < 5; i++) {
		const a = (i / 5) * Math.PI * 2;
		b.add('legs', black, new THREE.BoxGeometry(0.3, 0.03, 0.04), { pos: V(Math.cos(a) * 0.15, 0.07, Math.sin(a) * 0.15), rot: [0, -a, 0] });
		b.add('wheels', black, ellipsoid(0.03, 0.03, 0.03, 6, 4), { pos: V(Math.cos(a) * 0.29, 0.03, Math.sin(a) * 0.29) });
	}
	b.add('column', chrome, new THREE.CylinderGeometry(0.025, 0.025, 0.35, 8), { pos: V(0, 0.25, 0) });
	b.add('seat', fabric, new THREE.BoxGeometry(0.46, 0.08, 0.44), { pos: V(0, 0.46, 0) });
	b.add('back', fabric, new THREE.BoxGeometry(0.44, 0.5, 0.07), { pos: V(0, 0.78, -0.2), rot: [-0.08, 0, 0] });
	for (const s of [-1, 1]) {
		b.add('arms', black, new THREE.BoxGeometry(0.05, 0.03, 0.3), { pos: V(s * 0.24, 0.62, 0) });
		b.add('arms', black, new THREE.BoxGeometry(0.03, 0.14, 0.03), { pos: V(s * 0.24, 0.55, 0.05) });
	}
	return b.build();
}

// A boxy office monitor: a grey case 0.42 x 0.3 m on its foot, its screen showing a blue spreadsheet.
export function buildOfficeMonitor() {
	const b = new Builder('office_monitor');
	const grey = mat('monitor_grey', 0xd2cec4);
	b.add('case', grey, new THREE.BoxGeometry(0.42, 0.3, 0.12), { pos: V(0, 0.04, 0) });
	b.add('screen', mat('monitor_screen', 0x4a7ac8), new THREE.BoxGeometry(0.36, 0.24, 0.01), { pos: V(0, 0.045, 0.061) });
	for (let i = 0; i < 4; i++) {
		b.add('cells', mat('monitor_cells', 0xe6eef8), new THREE.BoxGeometry(0.32, 0.008, 0.012), { pos: V(0, 0.12 - i * 0.05, 0.062) });
	}
	b.add('foot', grey, new THREE.BoxGeometry(0.2, 0.03, 0.14), { pos: V(0, -0.135, 0) });
	b.add('neck', grey, new THREE.BoxGeometry(0.06, 0.05, 0.05), { pos: V(0, -0.1, 0) });
	return b.build();
}

// A glass trophy for "best floor boss": a clear star on a black base, 0.25 m tall.
export function buildGlassTrophy() {
	const b = new Builder('glass_trophy');
	const glass = mat('trophy_glass', 0xbfe8f6, { transparent: true, opacity: 0.6 });
	b.add('base', mat('trophy_base', 0x1e1e22), new THREE.BoxGeometry(0.1, 0.04, 0.08), { pos: V(0, -0.105, 0) });
	b.add('plate', mat('trophy_plate', 0xd8b04a), new THREE.BoxGeometry(0.06, 0.02, 0.002), { pos: V(0, -0.105, 0.041) });
	b.add('stem', glass, new THREE.CylinderGeometry(0.015, 0.025, 0.1, 8), { pos: V(0, -0.035, 0) });
	b.add('star', glass, new THREE.OctahedronGeometry(0.07, 0), { pos: V(0, 0.06, 0), scale: [1, 1, 0.4] });
	return b.build();
}

// The office's huge coffee machine: a brown and steel cabinet 0.7 x 1.6 x 0.6 m with buttons, a slot and a cup.
export function buildCoffeeMachine() {
	const b = new Builder('coffee_machine');
	const steel = mat('coffee_steel', 0xa8acb4), brown = mat('coffee_brown', 0x6a3e24);
	b.add('cabinet', steel, new THREE.BoxGeometry(0.7, 1.6, 0.6), { pos: V(0, 0.8, 0) });
	b.add('front', brown, new THREE.BoxGeometry(0.6, 0.9, 0.02), { pos: V(0, 1.05, 0.305) });
	b.add('sign', mat('coffee_sign', 0xf2e6c8), new THREE.BoxGeometry(0.5, 0.2, 0.01), { pos: V(0, 1.38, 0.32) });
	for (let i = 0; i < 6; i++) {
		b.add('buttons', mat('coffee_buttons', 0xe8c040), new THREE.BoxGeometry(0.06, 0.04, 0.02), { pos: V(-0.1 + (i % 2) * 0.2, 1.15 - Math.floor(i / 2) * 0.1, 0.32) });
	}
	b.add('slot', mat('coffee_slot', 0x1e1e22), new THREE.BoxGeometry(0.3, 0.3, 0.1), { pos: V(0, 0.45, 0.26) });
	b.add('cup', mat('coffee_cup', 0xffffff), new THREE.CylinderGeometry(0.035, 0.03, 0.08, 8), { pos: V(0, 0.36, 0.26) });
	return b.build();
}

// A water cooler: a white stand 1 m tall with a big blue bottle upside down on top.
export function buildWaterCooler() {
	const b = new Builder('water_cooler');
	const white = mat('cooler_white', 0xf0f0ec);
	b.add('stand', white, new THREE.BoxGeometry(0.32, 0.95, 0.32), { pos: V(0, 0.475, 0) });
	b.add('taps', mat('cooler_taps', 0x3a6ad0), new THREE.BoxGeometry(0.06, 0.04, 0.04), { pos: V(-0.06, 0.8, 0.17) });
	b.add('taps', mat('cooler_hot', 0xd03a3a), new THREE.BoxGeometry(0.06, 0.04, 0.04), { pos: V(0.06, 0.8, 0.17) });
	b.add('bottle', mat('cooler_bottle', 0x8ac8f0, { transparent: true, opacity: 0.7 }), new THREE.CylinderGeometry(0.14, 0.14, 0.4, 12), { pos: V(0, 1.18, 0) });
	b.add('neck', mat('cooler_bottle', 0x8ac8f0, { transparent: true, opacity: 0.7 }), new THREE.CylinderGeometry(0.05, 0.14, 0.06, 12), { pos: V(0, 0.98, 0) });
	return b.build();
}

const CAR_COLORS = [0xd23a3a, 0x3a6ad0, 0xf2c21e, 0x3aa85a];

// A toy car 0.12 m long: a colored body, a cabin and four black wheels.
function toyCar(b, at, color, turn = 0) {
	const paint = mat(`toy_car_${color.toString(16)}`, color), wheel = mat('toy_wheel', 0x1e1e22);
	b.add('body', paint, new THREE.BoxGeometry(0.12, 0.03, 0.06), { pos: V(at.x, at.y + 0.025, at.z), rot: [0, turn, 0] });
	b.add('cabin', mat('toy_glass', 0x9ad0e8), new THREE.BoxGeometry(0.06, 0.025, 0.05), { pos: V(at.x, at.y + 0.05, at.z), rot: [0, turn, 0] });
	for (const sx of [-1, 1]) for (const sz of [-1, 1]) {
		const dx = sx * 0.04, dz = sz * 0.032;
		b.add('wheels', wheel, new THREE.CylinderGeometry(0.013, 0.013, 0.01, 8), {
			pos: V(at.x + dx * Math.cos(turn) + dz * Math.sin(turn), at.y + 0.013, at.z - dx * Math.sin(turn) + dz * Math.cos(turn)), rot: [Math.PI / 2, turn, 0],
		});
	}
}

// One toy car lying on the floor (the fake crashes story makes cops slip on them).
export function buildToyCar() {
	const b = new Builder('toy_car');
	toyCar(b, V(0, -0.025, 0), 0xd23a3a);
	return b.build();
}

// The crash diorama: a board 0.8 x 0.6 m with a grey road, a zebra crossing, two crashed toy cars, a tiny lamppost and
// a plastic tree. Main evidence of the fake crashes.
export function buildCrashModel() {
	const b = new Builder('crash_model');
	b.add('board', mat('diorama_grass', 0x6aa84a), new THREE.BoxGeometry(0.8, 0.06, 0.6), { pos: V(0, -0.03, 0) });
	b.add('road', mat('diorama_road', 0x5a5a60), new THREE.BoxGeometry(0.8, 0.005, 0.22), { pos: V(0, 0.003, 0) });
	for (let i = 0; i < 5; i++) b.add('lines', mat('diorama_lines', 0xf2f2ea), new THREE.BoxGeometry(0.02, 0.006, 0.18), { pos: V(-0.2 + i * 0.035, 0.004, 0) });
	toyCar(b, V(0.05, 0.005, -0.03), CAR_COLORS[0], 0.4);
	toyCar(b, V(0.15, 0.005, 0.04), CAR_COLORS[1], -1.2);
	b.add('post', mat('diorama_post', 0x8a8e96), new THREE.CylinderGeometry(0.006, 0.006, 0.18, 6), { pos: V(-0.3, 0.09, -0.16) });
	b.add('lamp', mat('diorama_lamp', 0xf2e08a), ellipsoid(0.02, 0.012, 0.02, 6, 4), { pos: V(-0.3, 0.18, -0.15) });
	b.add('tree', mat('diorama_tree', 0x2e7a3a), new THREE.ConeGeometry(0.05, 0.14, 7), { pos: V(0.3, 0.09, 0.2) });
	b.add('trunk', mat('diorama_trunk', 0x6a4a2a), new THREE.CylinderGeometry(0.01, 0.01, 0.03, 5), { pos: V(0.3, 0.015, 0.2) });
	return b.build();
}

// A stack of glossy crash photos 0.15 x 0.1 m held with a clip. Extra of the fake crashes.
export function buildCrashPhotos() {
	const b = new Builder('crash_photos');
	for (let i = 0; i < 4; i++) {
		b.add('photos', mat('photo_white', 0xf6f6f2), new THREE.BoxGeometry(0.15, 0.003, 0.1), { pos: V(0, -0.006 + i * 0.003, 0), rot: [0, i * 0.08, 0] });
	}
	b.add('picture', mat('photo_crash', 0x6a7a9a), new THREE.BoxGeometry(0.13, 0.001, 0.08), { pos: V(0, 0.0065, 0), rot: [0, 0.24, 0] });
	b.add('clip', mat('photo_clip', 0xc8ccd2), new THREE.BoxGeometry(0.02, 0.008, 0.03), { pos: V(-0.06, 0.006, -0.03) });
	return b.build();
}

// A cardboard box 0.3 x 0.12 x 0.2 m, open, full of toy cars. Extra of the fake crashes.
export function buildToyCarBox() {
	const b = new Builder('toy_car_box');
	const card = mat('box_card', 0xb88a5a);
	b.add('bottom', card, new THREE.BoxGeometry(0.3, 0.01, 0.2), { pos: V(0, -0.055, 0) });
	for (const s of [-1, 1]) {
		b.add('sides', card, new THREE.BoxGeometry(0.3, 0.12, 0.01), { pos: V(0, 0, s * 0.095) });
		b.add('sides', card, new THREE.BoxGeometry(0.01, 0.12, 0.2), { pos: V(s * 0.145, 0, 0) });
	}
	for (let i = 0; i < 6; i++) toyCar(b, V(-0.08 + (i % 3) * 0.08, -0.05 + Math.floor(i / 3) * 0.035, -0.04 + Math.floor(i / 3) * 0.07), CAR_COLORS[i % 4], (i % 2) * 0.3);
	return b.build();
}

// The claim folder: a beige folder 0.24 x 0.32 m open with a crash photo where the "street" is grey office carpet and a
// stapler shows in a corner. The fake crashes' own clue.
export function buildClaimPhotos() {
	const b = new Builder('claim_photos');
	b.add('folder', mat('folder_beige', 0xe6d29a), new THREE.BoxGeometry(0.24, 0.006, 0.32), { pos: V(0, 0, 0) });
	b.add('photo', mat('photo_carpet', 0x8a8c90), new THREE.BoxGeometry(0.18, 0.002, 0.12), { pos: V(0, 0.004, -0.06) });
	toyCar(b, V(-0.02, 0.0, -0.06), CAR_COLORS[2], 0.2);
	b.add('stapler', mat('photo_stapler', 0x1e1e22), new THREE.BoxGeometry(0.05, 0.01, 0.02), { pos: V(0.06, 0.008, -0.1) });
	for (let i = 0; i < 5; i++) b.add('lines', mat('folder_text', 0x3a3a40), new THREE.BoxGeometry(0.16, 0.001, 0.008), { pos: V(0, 0.0035, 0.04 + i * 0.022) });
	return b.build();
}

// A yellow post-it 0.08 m square with a safe's combination scribbled on it. Extra of the coffee machine safe.
export function buildCodePostit() {
	const b = new Builder('code_postit');
	b.add('note', mat('postit_yellow', 0xf6e05a), new THREE.BoxGeometry(0.08, 0.002, 0.08), { pos: V(0, 0, 0) });
	for (let i = 0; i < 3; i++) b.add('digits', mat('postit_ink', 0x2a3a8a), new THREE.BoxGeometry(0.05, 0.001, 0.008), { pos: V(0, 0.0015, -0.02 + i * 0.02) });
	return b.build();
}

// The secret account book: a fat green ledger 0.22 x 0.05 x 0.3 m with a gold "$" on the cover. Extra of the coffee
// machine safe.
export function buildAccountBook() {
	const b = new Builder('account_book');
	b.add('cover', mat('ledger_green', 0x2e6a4a), new THREE.BoxGeometry(0.22, 0.05, 0.3), { pos: V(0, 0, 0) });
	b.add('pages', mat('ledger_pages', 0xf2eedc), new THREE.BoxGeometry(0.2, 0.042, 0.29), { pos: V(0.012, 0, 0) });
	b.add('sign', mat('ledger_gold', 0xd8b04a), new THREE.TorusGeometry(0.03, 0.006, 4, 10), { pos: V(0, 0.026, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('sign', mat('ledger_gold', 0xd8b04a), new THREE.BoxGeometry(0.006, 0.002, 0.09), { pos: V(0, 0.027, 0) });
	return b.build();
}

// The box of UFO policies: a cardboard file box 0.4 x 0.2 x 0.3 m, lid ajar, full of policies, with a green alien
// sticker. Main evidence of the UFO insurance.
export function buildUfoPolicies() {
	const b = new Builder('ufo_policies');
	const card = mat('file_box', 0xd8c49a);
	b.add('box', card, new THREE.BoxGeometry(0.4, 0.17, 0.3), { pos: V(0, -0.015, 0) });
	b.add('lid', card, new THREE.BoxGeometry(0.41, 0.03, 0.31), { pos: V(0.02, 0.085, 0.01), rot: [0, 0.06, 0.04] });
	for (let i = 0; i < 4; i++) b.add('papers', mat('policy_paper', 0xf6f6f0), new THREE.BoxGeometry(0.005, 0.03, 0.26), { pos: V(-0.15 + i * 0.03, 0.08, 0), rot: [0, 0, 0.1 * i] });
	b.add('sticker', mat('alien_green', 0x6ad84a), ellipsoid(0.05, 0.065, 0.004, 8, 4), { pos: V(0, -0.01, 0.151) });
	for (const s of [-1, 1]) b.add('eyes', mat('alien_eyes', 0x1a1a1e), ellipsoid(0.014, 0.008, 0.003, 6, 3), { pos: V(s * 0.02, 0.0, 0.154), rot: [0, 0, s * 0.4] });
	return b.build();
}

// A stack of blurry UFO photos 0.15 x 0.1 m: a grey saucer that is clearly a hubcap on a string. Extra of the UFO
// insurance.
export function buildUfoPhotos() {
	const b = new Builder('ufo_photos');
	for (let i = 0; i < 4; i++) b.add('photos', mat('photo_white', 0xf6f6f2), new THREE.BoxGeometry(0.15, 0.003, 0.1), { pos: V(0, -0.006 + i * 0.003, 0), rot: [0, -i * 0.07, 0] });
	b.add('sky', mat('photo_sky', 0x4a6a9a), new THREE.BoxGeometry(0.13, 0.001, 0.08), { pos: V(0, 0.0065, 0), rot: [0, -0.21, 0] });
	b.add('saucer', mat('photo_saucer', 0xb8bcc4), ellipsoid(0.025, 0.002, 0.01, 8, 3), { pos: V(0.01, 0.0075, -0.005), rot: [0, -0.21, 0] });
	b.add('string', mat('photo_string', 0x2a2a2e), new THREE.BoxGeometry(0.002, 0.001, 0.035), { pos: V(0.012, 0.0075, -0.027), rot: [0, -0.21, 0] });
	return b.build();
}

// A toy flying saucer 0.3 m across: a silver disc with a glass dome, a tiny green pilot and coloured lights. Extra of
// the UFO insurance.
export function buildToySaucer() {
	const b = new Builder('toy_saucer');
	b.add('disc', mat('saucer_silver', 0xc8ccd4), ellipsoid(0.15, 0.03, 0.15, 14, 6), { pos: V(0, -0.01, 0) });
	b.add('dome', mat('saucer_glass', 0x9ad8e8), ellipsoid(0.065, 0.05, 0.065, 10, 6), { pos: V(0, 0.02, 0) });
	b.add('pilot', mat('alien_green', 0x6ad84a), ellipsoid(0.02, 0.03, 0.02, 6, 4), { pos: V(0, 0.03, 0) });
	const lights = [0xe84a4a, 0xf2d24a, 0x4ad84a, 0x4a8ae8];
	for (let i = 0; i < 8; i++) {
		const a = (i / 8) * Math.PI * 2;
		b.add('lights', mat('saucer_light_' + (i % 4), lights[i % 4]), ellipsoid(0.01, 0.01, 0.01, 5, 3), { pos: V(Math.cos(a) * 0.13, -0.01, Math.sin(a) * 0.13) });
	}
	return b.build();
}

// The sales script: a clipboard 0.22 x 0.3 m with a printed sheet whose title is in big red letters. The UFO
// insurance's own clue.
export function buildSalesScript() {
	const b = new Builder('sales_script');
	b.add('board', mat('clipboard', 0x8a5a3a), new THREE.BoxGeometry(0.22, 0.008, 0.3), { pos: V(0, 0, 0) });
	b.add('clip', mat('clip_steel', 0xb8bcc4), new THREE.BoxGeometry(0.08, 0.012, 0.03), { pos: V(0, 0.006, -0.135) });
	b.add('sheet', mat('policy_paper', 0xf6f6f0), new THREE.BoxGeometry(0.2, 0.002, 0.27), { pos: V(0, 0.005, 0.01) });
	b.add('title', mat('script_red', 0xd23a3a), new THREE.BoxGeometry(0.15, 0.001, 0.02), { pos: V(0, 0.0065, -0.09) });
	for (let i = 0; i < 6; i++) b.add('lines', mat('folder_text', 0x3a3a40), new THREE.BoxGeometry(0.16, 0.001, 0.007), { pos: V(0, 0.0065, -0.04 + i * 0.025) });
	return b.build();
}

// A beige desk phone 0.2 x 0.18 m with its curly handset on top and a keypad. On every desk in the UFO insurance.
export function buildDeskPhone() {
	const b = new Builder('desk_phone');
	const beige = mat('phone_beige', 0xe2d8c0);
	b.add('base', beige, new THREE.BoxGeometry(0.2, 0.06, 0.18), { pos: V(0, 0.03, 0) });
	b.add('handset', beige, new THREE.BoxGeometry(0.22, 0.035, 0.05), { pos: V(0, 0.075, -0.05) });
	for (const s of [-1, 1]) b.add('handset', beige, ellipsoid(0.03, 0.02, 0.035, 6, 4), { pos: V(s * 0.1, 0.07, -0.05) });
	for (let i = 0; i < 9; i++) b.add('keys', mat('phone_keys', 0x5a5a60), new THREE.BoxGeometry(0.025, 0.006, 0.02), { pos: V(-0.035 + (i % 3) * 0.035, 0.062, 0.01 + Math.floor(i / 3) * 0.025) });
	b.add('cord', mat('phone_cord', 0x5a5a60), new THREE.CylinderGeometry(0.004, 0.004, 0.1, 5), { pos: V(-0.12, 0.05, -0.05), rot: [0, 0, 0.6] });
	return b.build();
}

// The box of unpaid claims: a grey archive box 0.36 x 0.26 x 0.3 m with a red "SIN PAGAR" band (a red stripe) and
// claim forms sticking out. Main evidence of the shredder.
export function buildClaimsBox() {
	const b = new Builder('claims_box');
	b.add('box', mat('archive_grey', 0x8a8e96), new THREE.BoxGeometry(0.36, 0.24, 0.3), { pos: V(0, -0.01, 0) });
	b.add('band', mat('script_red', 0xd23a3a), new THREE.BoxGeometry(0.365, 0.05, 0.305), { pos: V(0, 0.02, 0) });
	for (let i = 0; i < 5; i++) b.add('forms', mat('form_pink', i % 2 ? 0xf2c8d2 : 0xf6f6f0), new THREE.BoxGeometry(0.3, 0.04, 0.004), { pos: V(0, 0.12, -0.1 + i * 0.05), rot: [0.08 * (i - 2), 0, 0] });
	return b.build();
}

// A clear bag 0.35 m tall stuffed with shredded paper strips, tied at the top. Extra of the shredder.
export function buildShredBag() {
	const b = new Builder('shred_bag');
	b.add('bag', mat('bag_clear', 0xdfe6ea), ellipsoid(0.17, 0.16, 0.15, 10, 6), { pos: V(0, -0.02, 0) });
	b.add('knot', mat('bag_clear', 0xdfe6ea), ellipsoid(0.04, 0.04, 0.04, 6, 4), { pos: V(0, 0.15, 0) });
	for (let i = 0; i < 14; i++) {
		const a = i * 2.4, r = 0.12 + (i % 3) * 0.015;
		b.add('strips', mat('policy_paper', 0xf6f6f0), new THREE.BoxGeometry(0.008, 0.1, 0.002), { pos: V(Math.cos(a) * r, -0.04 + (i % 4) * 0.035, Math.sin(a) * r), rot: [0.3 * (i % 3), a, 0.4] });
	}
	return b.build();
}

// The "shred everything" order: a memo 0.21 x 0.3 m with a big red stamp and the boss's signature. Extra of the
// shredder.
export function buildShredOrder() {
	const b = new Builder('shred_order');
	b.add('sheet', mat('policy_paper', 0xf6f6f0), new THREE.BoxGeometry(0.21, 0.003, 0.3), { pos: V(0, 0, 0) });
	b.add('stamp', mat('script_red', 0xd23a3a), new THREE.BoxGeometry(0.15, 0.001, 0.05), { pos: V(0, 0.002, -0.08), rot: [0, 0.2, 0] });
	for (let i = 0; i < 4; i++) b.add('lines', mat('folder_text', 0x3a3a40), new THREE.BoxGeometry(0.16, 0.001, 0.007), { pos: V(0, 0.002, 0.0 + i * 0.025) });
	b.add('signature', mat('postit_ink', 0x2a3a8a), new THREE.TorusGeometry(0.025, 0.003, 3, 8), { pos: V(0.04, 0.002, 0.12), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The archive's shredder: a black cabinet 0.5 x 0.8 x 0.4 m with a wide slot on top, a red light and a bin of
// shredded paper behind its window. It eats whatever is put in it.
export function buildShredder() {
	const b = new Builder('shredder');
	const black = mat('shredder_black', 0x26262b);
	b.add('body', black, new THREE.BoxGeometry(0.5, 0.7, 0.4), { pos: V(0, 0.35, 0) });
	b.add('head', mat('shredder_grey', 0x5a5a60), new THREE.BoxGeometry(0.52, 0.1, 0.42), { pos: V(0, 0.75, 0) });
	b.add('slot', black, new THREE.BoxGeometry(0.4, 0.012, 0.04), { pos: V(0, 0.8, 0) });
	b.add('window', mat('bag_clear', 0xdfe6ea), new THREE.BoxGeometry(0.3, 0.3, 0.01), { pos: V(0, 0.3, 0.2) });
	for (let i = 0; i < 8; i++) b.add('strips', mat('policy_paper', 0xf6f6f0), new THREE.BoxGeometry(0.006, 0.08, 0.004), { pos: V(-0.12 + i * 0.034, 0.22 + (i % 3) * 0.03, 0.205), rot: [0, 0, 0.3 * ((i % 3) - 1)] });
	b.add('light', mat('shredder_light', 0xe84a4a), ellipsoid(0.015, 0.015, 0.01, 6, 3), { pos: V(0.2, 0.75, 0.212) });
	return b.build();
}

// The box of 20 neck braces: an open cardboard box 0.4 x 0.25 x 0.3 m with white foam collars piled in it. Main
// evidence of the office accidents.
export function buildNeckBraces() {
	const b = new Builder('neck_braces');
	const card = mat('box_card', 0xb88a5a);
	b.add('bottom', card, new THREE.BoxGeometry(0.4, 0.01, 0.3), { pos: V(0, -0.12, 0) });
	for (const s of [-1, 1]) {
		b.add('sides', card, new THREE.BoxGeometry(0.4, 0.25, 0.01), { pos: V(0, 0, s * 0.145) });
		b.add('sides', card, new THREE.BoxGeometry(0.01, 0.25, 0.3), { pos: V(s * 0.195, 0, 0) });
	}
	for (let i = 0; i < 6; i++) {
		b.add('collars', mat('collar_white', 0xf2f0e8), new THREE.TorusGeometry(0.06, 0.03, 5, 10), { pos: V(-0.1 + (i % 3) * 0.1, 0.06 + Math.floor(i / 3) * 0.04, -0.05 + Math.floor(i / 3) * 0.09), rot: [Math.PI / 2 + 0.2 * (i % 2), 0, 0.3 * (i % 3)] });
	}
	b.add('velcro', mat('collar_velcro', 0x3a5a8a), new THREE.BoxGeometry(0.04, 0.02, 0.01), { pos: V(0.1, 0.1, 0.06) });
	return b.build();
}

// Fake X-rays: a dark film 0.3 x 0.36 m with a neck's bones drawn on it, upside down. Extra of the office accidents.
export function buildXrays() {
	const b = new Builder('xrays');
	b.add('film', mat('xray_film', 0x1e2a36), new THREE.BoxGeometry(0.3, 0.004, 0.36), { pos: V(0, 0, 0) });
	for (let i = 0; i < 6; i++) b.add('bones', mat('xray_bone', 0xd8e2ea), new THREE.BoxGeometry(0.05, 0.002, 0.03), { pos: V(0, 0.003, -0.12 + i * 0.045) });
	b.add('skull', mat('xray_bone', 0xd8e2ea), ellipsoid(0.07, 0.002, 0.06, 8, 3), { pos: V(0, 0.003, 0.14) });
	return b.build();
}

// A paper tray 0.25 x 0.2 m with three yellow banana peels. Extra of the office accidents.
export function buildBananaPeels() {
	const b = new Builder('banana_peels');
	b.add('tray', mat('tray_grey', 0x8a8e96), new THREE.BoxGeometry(0.25, 0.02, 0.2), { pos: V(0, -0.03, 0) });
	for (let i = 0; i < 3; i++) {
		const x = -0.07 + i * 0.07;
		for (let j = 0; j < 3; j++) {
			const a = (j / 3) * Math.PI * 2 + i;
			b.add('peels', mat('banana_yellow', 0xf2d24a), new THREE.BoxGeometry(0.02, 0.008, 0.08), { pos: V(x + Math.cos(a) * 0.025, -0.012, Math.sin(a) * 0.025), rot: [0, a, 0.2] });
		}
		b.add('tips', mat('banana_tip', 0x4a3a2a), ellipsoid(0.008, 0.008, 0.008, 4, 3), { pos: V(x, 0.0, 0) });
	}
	return b.build();
}

// A yellow "wet floor" sign: an A-frame 0.3 x 0.6 m with a black slipping figure on each side.
export function buildWetSign() {
	const b = new Builder('wet_sign');
	const yellow = mat('sign_yellow', 0xf2c82a), black = mat('sign_black', 0x1e1e22);
	for (const s of [-1, 1]) {
		b.add('boards', yellow, new THREE.BoxGeometry(0.3, 0.6, 0.015), { pos: V(0, 0.3, s * 0.08), rot: [s * 0.27, 0, 0] });
		b.add('figure', black, ellipsoid(0.03, 0.03, 0.004, 6, 3), { pos: V(0.03, 0.42, s * 0.12), rot: [s * 0.27, 0, 0] });
		b.add('figure', black, new THREE.BoxGeometry(0.025, 0.12, 0.004), { pos: V(0.0, 0.33, s * 0.1), rot: [s * 0.27, 0, 0.6] });
		b.add('figure', black, new THREE.BoxGeometry(0.1, 0.02, 0.004), { pos: V(-0.03, 0.24, s * 0.075), rot: [s * 0.27, 0, -0.3] });
	}
	return b.build();
}

// An "employee of the month" frame 0.3 x 0.4 m: a smiling worker in a white neck brace.
export function buildEmployeePhoto() {
	const b = new Builder('employee_photo');
	b.add('frame', mat('frame_gold', 0xc8a04a), new THREE.BoxGeometry(0.3, 0.4, 0.03), { pos: V(0, 0, 0) });
	b.add('photo', mat('photo_blue', 0x8ab4d8), new THREE.BoxGeometry(0.24, 0.32, 0.005), { pos: V(0, 0.01, 0.016) });
	b.add('face', mat('photo_skin', 0xe0b48a), ellipsoid(0.05, 0.06, 0.004, 8, 3), { pos: V(0, 0.07, 0.02) });
	b.add('brace', mat('collar_white', 0xf2f0e8), new THREE.BoxGeometry(0.11, 0.05, 0.006), { pos: V(0, -0.005, 0.021) });
	b.add('shirt', mat('photo_shirt', 0x3a5a8a), new THREE.BoxGeometry(0.18, 0.08, 0.004), { pos: V(0, -0.09, 0.02) });
	b.add('plate', mat('frame_gold', 0xc8a04a), new THREE.BoxGeometry(0.16, 0.03, 0.006), { pos: V(0, -0.165, 0.02) });
	return b.build();
}

export const models = {
	office_chair: buildOfficeChair, office_monitor: buildOfficeMonitor, glass_trophy: buildGlassTrophy,
	coffee_machine: buildCoffeeMachine, water_cooler: buildWaterCooler,
	toy_car: buildToyCar, crash_model: buildCrashModel, crash_photos: buildCrashPhotos, toy_car_box: buildToyCarBox,
	claim_photos: buildClaimPhotos, code_postit: buildCodePostit, account_book: buildAccountBook,
	ufo_policies: buildUfoPolicies, ufo_photos: buildUfoPhotos, toy_saucer: buildToySaucer, sales_script: buildSalesScript,
	desk_phone: buildDeskPhone, claims_box: buildClaimsBox, shred_bag: buildShredBag, shred_order: buildShredOrder,
	shredder: buildShredder, neck_braces: buildNeckBraces, xrays: buildXrays, banana_peels: buildBananaPeels,
	wet_sign: buildWetSign, employee_photo: buildEmployeePhoto,
};

export const views = {
	accident_goods: {
		items: [
			{ name: 'neck_braces', pos: [-0.35, 0.125, 0] }, { name: 'xrays', pos: [0.3, 0.002, 0.35], rotY: 0.3 },
			{ name: 'banana_peels', pos: [0.15, 0.04, -0.1] }, { name: 'wet_sign', pos: [0.65, 0, -0.3] },
			{ name: 'employee_photo', pos: [-0.2, 0.2, 0.45] },
		],
		cam: { pos: [0, 1.1, 1.8], target: [0, 0.2, 0], fov: 40 },
	},
	shred_goods: {
		items: [
			{ name: 'shredder', pos: [-0.4, 0, -0.2] }, { name: 'claims_box', pos: [0.2, 0.13, 0.0] },
			{ name: 'shred_bag', pos: [0.6, 0.18, -0.2] }, { name: 'shred_order', pos: [0.1, 0.002, 0.4], rotY: 0.3 },
		],
		cam: { pos: [0, 1.2, 2.0], target: [0, 0.35, 0], fov: 40 },
	},
	ufo_goods: {
		items: [
			{ name: 'ufo_policies', pos: [-0.25, 0.1, -0.1] }, { name: 'ufo_photos', pos: [0.3, 0.01, 0.3] },
			{ name: 'toy_saucer', pos: [0.3, 0.04, -0.15] }, { name: 'sales_script', pos: [-0.2, 0.004, 0.35], rotY: 0.2 },
			{ name: 'desk_phone', pos: [0.05, 0, 0.15], rotY: -0.3 },
		],
		cam: { pos: [0, 0.9, 1.3], target: [0, 0.05, 0.05], fov: 40 },
	},
	coffee_goods: {
		items: [
			{ name: 'coffee_machine', pos: [-0.3, 0, -0.2] }, { name: 'code_postit', pos: [0.35, 0.002, 0.3] },
			{ name: 'account_book', pos: [0.4, 0.025, -0.05], rotY: 0.4 },
		],
		cam: { pos: [0, 1.2, 2.4], target: [0, 0.5, 0], fov: 40 },
	},
	crash_goods: {
		items: [
			{ name: 'crash_model', pos: [-0.2, 0.06, -0.1] }, { name: 'crash_photos', pos: [0.35, 0.01, 0.25] },
			{ name: 'toy_car_box', pos: [0.4, 0.06, -0.15] }, { name: 'claim_photos', pos: [-0.15, 0.003, 0.35] },
			{ name: 'toy_car', pos: [0.15, 0.025, 0.4] },
		],
		cam: { pos: [0, 0.9, 1.3], target: [0, 0.03, 0.1], fov: 40 },
	},
	insurance: {
		items: [
			{ name: 'office_chair', pos: [-0.6, 0, 0] }, { name: 'office_monitor', pos: [0.05, 0.15, 0.2] },
			{ name: 'glass_trophy', pos: [0.35, 0.12, 0.3] }, { name: 'coffee_machine', pos: [0.9, 0, -0.3] },
			{ name: 'water_cooler', pos: [-1.3, 0, -0.3] },
		],
		cam: { pos: [0, 1.3, 3.0], target: [0, 0.6, 0], fov: 40 },
	},
};
