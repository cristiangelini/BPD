// Furniture of the police station (docs/diseno/comisaria.md): the comisario's desk, the lockers, the coffee machine,
// a bench, the armory's ram rack and a cell bunk. Every origin is on the floor at the middle of the piece, front to +Z,
// so StationRooms places them by their footprint. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';
import { limb } from './pear.js';

// The comisario's desk: 2 x 0.78 x 0.9 m, buried in papers, with a lamp and a "COMISARIO" plate.
export function buildDesk() {
	const b = new Builder('station_desk');
	const wood = mat('desk_wood', 0x7a4a28), dark = mat('desk_dark', 0x4e2e18), paper = mat('paper', 0xf4efd8);
	b.add('desk', wood, new THREE.BoxGeometry(2, 0.06, 0.9), { pos: V(0, 0.75, 0) });
	for (const x of [-0.75, 0.75]) b.add('desk', dark, new THREE.BoxGeometry(0.46, 0.72, 0.84), { pos: V(x, 0.36, 0) });
	b.add('desk', dark, new THREE.BoxGeometry(1.04, 0.5, 0.04), { pos: V(0, 0.47, 0.4) });
	for (let i = 0; i < 4; i++) b.add('papers', paper, new THREE.BoxGeometry(0.3, 0.04 + i * 0.05, 0.22), { pos: V(-0.7 + i * 0.12, 0.8 + i * 0.025, -0.15 + (i % 2) * 0.1), rot: [0, i * 0.3, 0] });
	b.add('lamp', mat('lamp_green', 0x2a7a4a), new THREE.CylinderGeometry(0.02, 0.14, 0.14, 8), { pos: V(0.7, 1.15, -0.2) });
	b.add('lamp', dark, new THREE.CylinderGeometry(0.012, 0.012, 0.36, 6), { pos: V(0.7, 0.96, -0.2) });
	b.add('plate', mat('plate_gold', 0xf0c040, { emissive: 0x302408 }), new THREE.BoxGeometry(0.5, 0.1, 0.03), { pos: V(0, 0.84, 0.36), rot: [-0.4, 0, 0] });
	return b.build();
}

// A row of 4 lockers: 2.4 x 1.9 x 0.5 m, one door ajar.
export function buildLockers() {
	const b = new Builder('station_lockers');
	const steel = mat('locker', 0x6a7f9a), dark = mat('locker_dark', 0x3a4456);
	for (let i = 0; i < 4; i++) {
		const x = -0.9 + i * 0.6;
		b.add('lockers', steel, new THREE.BoxGeometry(0.58, 1.9, 0.5), { pos: V(x, 0.95, 0) });
		for (const y of [1.6, 1.5, 1.4]) b.add('vents', dark, new THREE.BoxGeometry(0.3, 0.03, 0.01), { pos: V(x, y, 0.255) });
		b.add('handles', dark, new THREE.BoxGeometry(0.03, 0.12, 0.03), { pos: V(x + 0.2, 1.0, 0.27) });
	}
	b.add('ajar', steel, new THREE.BoxGeometry(0.56, 1.8, 0.03), { pos: V(0.5, 0.95, 0.45), rot: [0, -0.7, 0] });
	return b.build();
}

// The coffee machine on its cabinet: 0.7 x 1.6 x 0.6 m, with a red light and a mug.
export function buildCoffee() {
	const b = new Builder('station_coffee');
	b.add('cabinet', mat('cabinet', 0x8a5a2a), new THREE.BoxGeometry(0.7, 0.9, 0.6), { pos: V(0, 0.45, 0) });
	b.add('machine', mat('coffee_black', 0x2a2a2e), new THREE.BoxGeometry(0.45, 0.6, 0.45), { pos: V(0, 1.2, -0.02) });
	b.add('machine', mat('coffee_steel', 0xb8bcc4), new THREE.BoxGeometry(0.3, 0.12, 0.05), { pos: V(0, 1.05, 0.22) });
	b.add('light', mat('coffee_red', 0xff3020, { emissive: 0x801008 }), new THREE.SphereGeometry(0.02, 6, 4), { pos: V(0.15, 1.38, 0.21) });
	b.add('mug', mat('mug', 0xf4efd8), new THREE.CylinderGeometry(0.045, 0.04, 0.1, 8), { pos: V(-0.2, 0.95, 0.15) });
	return b.build();
}

// A wooden bench: 2 x 0.45 x 0.45 m.
export function buildBench() {
	const b = new Builder('station_bench');
	const wood = mat('bench_wood', 0xb07a40), dark = mat('bench_dark', 0x4e2e18);
	b.add('seat', wood, new THREE.BoxGeometry(2, 0.06, 0.45), { pos: V(0, 0.42, 0) });
	for (const x of [-0.85, 0.85]) b.add('legs', dark, new THREE.BoxGeometry(0.08, 0.4, 0.4), { pos: V(x, 0.2, 0) });
	return b.build();
}

// The armory rack: 2.4 x 1.8 x 0.5 m of shelves with three battering rams and boxes of donuts.
export function buildRack() {
	const b = new Builder('station_rack');
	const steel = mat('rack_steel', 0x4a4e56), ram = mat('ram_iron', 0x2e3238), handle = mat('ram_handle', 0xd8b020);
	for (const x of [-1.15, 1.15]) b.add('frame', steel, new THREE.BoxGeometry(0.06, 1.8, 0.5), { pos: V(x, 0.9, 0) });
	for (const y of [0.3, 0.9, 1.5]) b.add('shelves', steel, new THREE.BoxGeometry(2.3, 0.04, 0.5), { pos: V(0, y, 0) });
	for (const x of [-0.7, 0, 0.7]) {
		b.add('rams', ram, new THREE.CylinderGeometry(0.09, 0.09, 0.55, 8), { pos: V(x, 1.04, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('rams', handle, new THREE.BoxGeometry(0.04, 0.12, 0.04), { pos: V(x, 1.17, 0.12) });
	}
	for (const x of [-0.7, 0.1, 0.7]) b.add('donuts', mat('donut_box', 0xff8fb1), new THREE.BoxGeometry(0.4, 0.12, 0.3), { pos: V(x, 0.38, 0) });
	return b.build();
}

// A cell bunk: 2 x 0.5 x 0.8 m, with a grey blanket.
export function buildBunk() {
	const b = new Builder('station_bunk');
	b.add('frame', mat('bunk_steel', 0x5a5e66), new THREE.BoxGeometry(2, 0.35, 0.8), { pos: V(0, 0.175, 0) });
	b.add('blanket', mat('bunk_blanket', 0x8a8e96), new THREE.BoxGeometry(1.9, 0.1, 0.75), { pos: V(0, 0.4, 0) });
	b.add('pillow', mat('bunk_pillow', 0xf4efd8), new THREE.BoxGeometry(0.35, 0.1, 0.6), { pos: V(-0.75, 0.48, 0) });
	return b.build();
}

// A box of donuts from the armory (comisaria.md): 0.4 x 0.12 x 0.3 m, centered, lid open at the back and four
// donuts the game hides one by one (parts donut_0 to donut_3).
export function buildDonutBox() {
	return donutBox('donut_box', 0.4, [[-0.09, -0.065], [0.09, -0.065], [-0.09, 0.065], [0.09, 0.065]]);
}

// The night guard's box (fuga.md): 0.5 x 0.12 x 0.3 m with six donuts, donut_0 to donut_5.
export function buildGuardDonutBox() {
	const spots = [];
	for (const z of [-0.065, 0.065]) for (const x of [-0.15, 0, 0.15]) spots.push([x, z]);
	return donutBox('guard_donut_box', 0.5, spots);
}

function donutBox(name, width, spots) {
	const b = new Builder(name);
	const box = mat('donut_box', 0xff8fb1), inside = mat('donut_box_in', 0xf6e7d0);
	b.add('box', box, new THREE.BoxGeometry(width, 0.01, 0.3), { pos: V(0, -0.055, 0) });
	for (const s of [-1, 1]) {
		b.add('box', box, new THREE.BoxGeometry(width, 0.08, 0.01), { pos: V(0, -0.02, s * 0.145) });
		b.add('box', box, new THREE.BoxGeometry(0.01, 0.08, 0.3), { pos: V(s * (width / 2 - 0.005), -0.02, 0) });
	}
	b.add('box', inside, new THREE.BoxGeometry(width - 0.02, 0.005, 0.28), { pos: V(0, -0.048, 0) });
	b.add('lid', box, new THREE.BoxGeometry(width, 0.01, 0.3), { pos: V(0, 0.1, -0.2), rot: [-1.15, 0, 0] });
	b.add('lid', mat('donut_logo', 0xffffff), new THREE.BoxGeometry(0.14, 0.004, 0.08), { pos: V(0, 0.105, -0.188), rot: [-1.15, 0, 0] });
	const dough = mat('donut_dough', 0xd99a52);
	const icing = [mat('icing_pink', 0xff5fa2), mat('icing_choco', 0x5a3320), mat('icing_white', 0xfff4e0)];
	spots.forEach(([x, z], i) => {
		b.add(`donut_${i}`, dough, new THREE.TorusGeometry(0.055, 0.026, 6, 10), { pos: V(x, -0.02, z), rot: [Math.PI / 2, 0, 0] });
		b.add(`donut_${i}`, icing[i % 3], new THREE.TorusGeometry(0.055, 0.029, 6, 10), { pos: V(x, -0.004, z), rot: [Math.PI / 2, 0, 0], scale: [1, 1, 0.5] });
	});
	return b.build();
}

// The jailbreak's fishing tools (fuga.md): each lies in a cell, its origin at the grip and its length forward (-Z).
// A very long broom, 2.8 m with the bristles at the far end.
export function buildBroom() {
	const b = new Builder('broom');
	const wood = mat('broom_wood', 0xc8a060), straw = mat('broom_straw', 0xe0c25a), band = mat('broom_band', 0xc23a2a);
	b.add('stick', wood, new THREE.CylinderGeometry(0.018, 0.018, 2.8, 6), { pos: V(0, 0, -1.4), rot: [Math.PI / 2, 0, 0] });
	b.add('head', band, new THREE.BoxGeometry(0.1, 0.06, 0.06), { pos: V(0, 0, -2.78) });
	b.add('head', straw, new THREE.BoxGeometry(0.3, 0.05, 0.2), { pos: V(0, -0.04, -2.9) });
	return b.build();
}

// A fishing rod without a hook, 3 m, thinner toward the tip, with a reel by the grip and a bit of line hanging.
export function buildFishingRod() {
	const b = new Builder('fishing_rod');
	const rod = mat('rod_blue', 0x2f5fa8), cork = mat('rod_cork', 0xb88a55), reel = mat('rod_reel', 0x9aa0a8);
	b.add('grip', cork, new THREE.CylinderGeometry(0.022, 0.022, 0.35, 6), { pos: V(0, 0, 0.05), rot: [Math.PI / 2, 0, 0] });
	b.add('rod', rod, new THREE.CylinderGeometry(0.004, 0.014, 2.8, 6), { pos: V(0, 0, -1.55), rot: [-Math.PI / 2, 0, 0] });
	b.add('reel', reel, new THREE.CylinderGeometry(0.04, 0.04, 0.04, 8), { pos: V(0, -0.05, -0.1), rot: [0, 0, Math.PI / 2] });
	b.add('line', mat('rod_line', 0xeeeeee), new THREE.CylinderGeometry(0.002, 0.002, 0.3, 3), { pos: V(0, -0.15, -2.95) });
	return b.build();
}

// The armory's wheelbarrow (comisaria.md): origin on the floor under the tray, wheel ahead (-Z), handles back (+Z)
// toward the cop pushing it. Tray 0.7 x 0.3 x 0.9 m, its floor at 0.45 m.
export function buildWheelbarrow() {
	const b = new Builder('wheelbarrow');
	const tray = mat('wb_tray', 0x3f8f4a), steel = mat('wb_steel', 0x4a4e56), tire = mat('wb_tire', 0x1c1c20);
	b.add('tray', tray, new THREE.BoxGeometry(0.62, 0.03, 0.82), { pos: V(0, 0.45, 0) });
	for (const s of [-1, 1]) {
		b.add('tray', tray, new THREE.BoxGeometry(0.03, 0.3, 0.9), { pos: V(s * 0.34, 0.6, 0), rot: [0, 0, s * -0.18] });
		b.add('tray', tray, new THREE.BoxGeometry(0.7, 0.3, 0.03), { pos: V(0, 0.6, s * 0.44), rot: [s * 0.25, 0, 0] });
		limb(b, 'frame', steel, V(s * 0.22, 0.42, -0.42), V(s * 0.28, 0.7, 0.95), 0.022);
		b.add('frame', mat('wb_grip', 0xc23a2a), new THREE.CylinderGeometry(0.03, 0.03, 0.14, 6), { pos: V(s * 0.28, 0.71, 0.92), rot: [Math.PI / 2 - 0.3, 0, 0] });
		limb(b, 'frame', steel, V(s * 0.22, 0.43, 0.3), V(s * 0.24, 0.0, 0.36), 0.018);
	}
	b.add('wheel', tire, new THREE.CylinderGeometry(0.2, 0.2, 0.08, 10), { pos: V(0, 0.2, -0.55), rot: [0, 0, Math.PI / 2] });
	b.add('wheel', steel, new THREE.CylinderGeometry(0.06, 0.06, 0.1, 6), { pos: V(0, 0.2, -0.55), rot: [0, 0, Math.PI / 2] });
	limb(b, 'frame', steel, V(-0.22, 0.42, -0.42), V(0, 0.2, -0.55), 0.018);
	limb(b, 'frame', steel, V(0.22, 0.42, -0.42), V(0, 0.2, -0.55), 0.018);
	return b.build();
}

export const models = {
	wheelbarrow: buildWheelbarrow,
	donut_box: buildDonutBox, guard_donut_box: buildGuardDonutBox, broom: buildBroom, fishing_rod: buildFishingRod,
	station_desk: buildDesk, station_lockers: buildLockers, station_coffee: buildCoffee, station_bench: buildBench,
	station_rack: buildRack, station_bunk: buildBunk,
};

export const views = {
	wheelbarrow: { items: [{ name: 'wheelbarrow', pos: [0, 0, 0], rotY: 0.9 }], cam: { pos: [0, 1.4, 2.6], target: [0, 0.4, 0], fov: 40 } },
	donut_box: { items: [{ name: 'donut_box', pos: [0, 0.06, 0], rotY: 0.4 }], cam: { pos: [0, 0.55, 0.65], target: [0, 0.0, 0], fov: 40 } },
	station: {
		items: [
			{ name: 'station_desk', pos: [0, 0, 0] },
			{ name: 'station_lockers', pos: [-2.4, 0, -1.2], rotY: 0.5 },
			{ name: 'station_coffee', pos: [2.0, 0, -0.8], rotY: -0.4 },
			{ name: 'station_bench', pos: [-1.5, 0, 1.6], rotY: 0.2 },
			{ name: 'station_rack', pos: [1.2, 0, -2.6] },
			{ name: 'station_bunk', pos: [2.6, 0, 1.6], rotY: -0.6 },
		],
		cam: { pos: [0, 3.2, 6.0], target: [0, 0.7, -0.4], fov: 50 },
	},
};
