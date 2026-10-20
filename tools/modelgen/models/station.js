// Furniture of the police station (docs/diseno/comisaria.md): the comisario's desk, the lockers, the coffee machine,
// a bench, the armory's ram rack and a cell bunk. Every origin is on the floor at the middle of the piece, front to +Z,
// so StationRooms places them by their footprint. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

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
	const b = new Builder('donut_box');
	const box = mat('donut_box', 0xff8fb1), inside = mat('donut_box_in', 0xf6e7d0);
	b.add('box', box, new THREE.BoxGeometry(0.4, 0.01, 0.3), { pos: V(0, -0.055, 0) });
	for (const s of [-1, 1]) {
		b.add('box', box, new THREE.BoxGeometry(0.4, 0.08, 0.01), { pos: V(0, -0.02, s * 0.145) });
		b.add('box', box, new THREE.BoxGeometry(0.01, 0.08, 0.3), { pos: V(s * 0.195, -0.02, 0) });
	}
	b.add('box', inside, new THREE.BoxGeometry(0.38, 0.005, 0.28), { pos: V(0, -0.048, 0) });
	b.add('lid', box, new THREE.BoxGeometry(0.4, 0.01, 0.3), { pos: V(0, 0.1, -0.2), rot: [-1.15, 0, 0] });
	b.add('lid', mat('donut_logo', 0xffffff), new THREE.BoxGeometry(0.14, 0.004, 0.08), { pos: V(0, 0.105, -0.188), rot: [-1.15, 0, 0] });
	const dough = mat('donut_dough', 0xd99a52);
	const icing = [mat('icing_pink', 0xff5fa2), mat('icing_choco', 0x5a3320), mat('icing_white', 0xfff4e0), mat('icing_pink', 0xff5fa2)];
	[[-0.09, -0.065], [0.09, -0.065], [-0.09, 0.065], [0.09, 0.065]].forEach(([x, z], i) => {
		b.add(`donut_${i}`, dough, new THREE.TorusGeometry(0.055, 0.026, 6, 10), { pos: V(x, -0.02, z), rot: [Math.PI / 2, 0, 0] });
		b.add(`donut_${i}`, icing[i], new THREE.TorusGeometry(0.055, 0.029, 6, 10), { pos: V(x, -0.004, z), rot: [Math.PI / 2, 0, 0], scale: [1, 1, 0.5] });
	});
	return b.build();
}

export const models = {
	donut_box: buildDonutBox,
	station_desk: buildDesk, station_lockers: buildLockers, station_coffee: buildCoffee, station_bench: buildBench,
	station_rack: buildRack, station_bunk: buildBunk,
};

export const views = {
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
