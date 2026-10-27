// Props of the "Heladería Pingüino Derretido" (docs/diseno/allanamiento-heladeria.md): the chest freezer and its
// glass lid, the counter with the 12 flavors, the soft-serve machine, the cold room's shelf and the fiberglass penguin
// by the door, with origins at the floor in the middle of each piece (the lid's at its hinge). Placeholder, not final
// art.
import { Builder, mat, V, THREE } from '../lib.js';

const FLAVORS = [0xffe8b0, 0x6a3a20, 0xff9fc0, 0x9ad870, 0xfff8f0, 0xc04050, 0xf0c040, 0x8a60c0, 0xe08040, 0x60b0e0,
	0xd8b080, 0x40a060];

// A chest freezer, 1.6 x 0.85 x 0.8 m: white body, a blue band, and the tubs of ice cream inside under the lid.
export function buildIceFreezer() {
	const b = new Builder('ice_freezer');
	const white = mat('freezer_white', 0xf2f4f6), blue = mat('freezer_blue', 0x3a7ad0), inside = mat('freezer_inside', 0xd8e4ee);
	b.add('body', white, new THREE.BoxGeometry(1.6, 0.06, 0.8), { pos: V(0, 0.03, 0) });
	for (const z of [-0.37, 0.37]) b.add('body', white, new THREE.BoxGeometry(1.6, 0.85, 0.06), { pos: V(0, 0.425, z) });
	for (const x of [-0.77, 0.77]) b.add('body', white, new THREE.BoxGeometry(0.06, 0.85, 0.8), { pos: V(x, 0.425, 0) });
	b.add('inside', inside, new THREE.BoxGeometry(1.48, 0.04, 0.68), { pos: V(0, 0.45, 0) });
	b.add('band', blue, new THREE.BoxGeometry(1.62, 0.12, 0.82), { pos: V(0, 0.2, 0) });
	for (let i = 0; i < 6; i++) {
		const c = FLAVORS[(i * 5) % FLAVORS.length];
		b.add(`tubs_${i}`, mat(`flavor_${(i * 5) % FLAVORS.length}`, c), new THREE.CylinderGeometry(0.16, 0.14, 0.3, 10), { pos: V(-0.55 + (i % 3) * 0.55, 0.62, i < 3 ? -0.16 : 0.16) });
	}
	return b.build();
}

// The freezer's sliding glass lid, 1.6 x 0.05 x 0.8 m, hinged along its back edge (-Z) at the origin.
export function buildFreezerLid() {
	const b = new Builder('freezer_lid');
	const frame = mat('lid_frame', 0xd0d4da), glass = mat('lid_glass', 0xb8dcf0, { transparent: true, opacity: 0.45 });
	b.add('glass', glass, new THREE.BoxGeometry(1.5, 0.02, 0.7), { pos: V(0, 0.02, 0.4) });
	for (const z of [0.03, 0.77]) b.add('frame', frame, new THREE.BoxGeometry(1.6, 0.05, 0.06), { pos: V(0, 0.025, z) });
	for (const x of [-0.77, 0.77]) b.add('frame', frame, new THREE.BoxGeometry(0.06, 0.05, 0.8), { pos: V(x, 0.025, 0.4) });
	b.add('handle', mat('lid_handle', 0x3a7ad0), new THREE.BoxGeometry(0.4, 0.04, 0.04), { pos: V(0, 0.06, 0.76) });
	return b.build();
}

// The counter with its glass case, 5.0 x 1.3 x 0.9 m: a pink front, the tilted glass and two rows of six flavors.
// The customers stand on its +Z side.
export function buildIceCounter() {
	const b = new Builder('ice_counter');
	const pink = mat('counter_pink', 0xf4a0c0), white = mat('counter_white', 0xf6f2ec), steel = mat('counter_steel', 0xb8bcc4);
	b.add('base', pink, new THREE.BoxGeometry(5.0, 0.95, 0.9), { pos: V(0, 0.475, 0) });
	b.add('top', white, new THREE.BoxGeometry(5.04, 0.05, 0.94), { pos: V(0, 0.975, 0) });
	b.add('stripe', white, new THREE.BoxGeometry(5.02, 0.1, 0.02), { pos: V(0, 0.6, 0.455) });
	b.add('glass', mat('case_glass', 0xc8e8f8, { transparent: true, opacity: 0.35 }), new THREE.BoxGeometry(4.9, 0.02, 0.5), { pos: V(0, 1.18, 0.2), rot: [0.75, 0, 0] });
	b.add('rail', steel, new THREE.BoxGeometry(5.0, 0.03, 0.03), { pos: V(0, 1.32, 0.04) });
	for (let i = 0; i < FLAVORS.length; i++) {
		const x = -2.06 + (i % 6) * 0.82, z = i < 6 ? -0.15 : 0.15;
		b.add(`flavors_${i}`, mat(`flavor_${i}`, FLAVORS[i]), new THREE.BoxGeometry(0.66, 0.1, 0.24), { pos: V(x, 1.05, z) });
		b.add(`flavors_${i}`, mat(`flavor_${i}`, FLAVORS[i]), new THREE.SphereGeometry(0.12, 8, 5), { pos: V(x, 1.1, z), scale: [2.2, 0.6, 0.8] });
	}
	return b.build();
}

// The soft-serve machine on its stand, 0.7 x 1.7 x 0.7 m: a steel box with two taps, the lever and a pink top.
export function buildSoftServeMachine() {
	const b = new Builder('soft_serve_machine');
	const steel = mat('machine_steel', 0xc8ccd2), pink = mat('machine_pink', 0xf080a8), dark = mat('machine_dark', 0x30323a);
	b.add('stand', dark, new THREE.BoxGeometry(0.7, 0.8, 0.7), { pos: V(0, 0.4, 0) });
	b.add('box', steel, new THREE.BoxGeometry(0.66, 0.75, 0.62), { pos: V(0, 1.18, -0.02) });
	b.add('top', pink, new THREE.BoxGeometry(0.68, 0.14, 0.64), { pos: V(0, 1.62, -0.02) });
	for (const x of [-0.16, 0.16]) {
		b.add('taps', steel, new THREE.CylinderGeometry(0.04, 0.03, 0.14, 8), { pos: V(x, 0.95, 0.32) });
		b.add('swirl', mat('swirl', 0xfff6e8), new THREE.ConeGeometry(0.05, 0.1, 8), { pos: V(x, 0.84, 0.32), rot: [Math.PI, 0, 0] });
	}
	b.add('lever', pink, new THREE.BoxGeometry(0.04, 0.2, 0.04), { pos: V(0, 1.1, 0.34), rot: [0.4, 0, 0] });
	b.add('tray', steel, new THREE.BoxGeometry(0.5, 0.03, 0.2), { pos: V(0, 0.82, 0.3) });
	return b.build();
}

// A shelf of the cold room, 2.0 x 2.0 x 0.6 m: steel racks with tubs of ice cream and two blocks of ice.
export function buildColdShelf() {
	const b = new Builder('cold_shelf');
	const steel = mat('rack_steel', 0xaab0b8), ice = mat('ice_block', 0xd0eefa, { transparent: true, opacity: 0.8 });
	for (const x of [-0.98, 0.98]) for (const z of [-0.28, 0.28]) b.add('posts', steel, new THREE.BoxGeometry(0.04, 2.0, 0.04), { pos: V(x, 1.0, z) });
	for (let s = 0; s < 4; s++) {
		const y = 0.1 + s * 0.6;
		b.add('racks', steel, new THREE.BoxGeometry(2.0, 0.03, 0.6), { pos: V(0, y, 0) });
		if (s === 3) break;
		for (let i = 0; i < 4; i++) {
			const c = (i * 3 + s * 2) % FLAVORS.length;
			b.add(`tubs_${c}`, mat(`flavor_${c}`, FLAVORS[c]), new THREE.CylinderGeometry(0.17, 0.15, 0.3, 10), { pos: V(-0.72 + i * 0.48, y + 0.17, 0) });
		}
	}
	for (const x of [-0.5, 0.5]) b.add('ice', ice, new THREE.BoxGeometry(0.6, 0.35, 0.45), { pos: V(x, 1.99, 0) });
	return b.build();
}

// The fiberglass penguin by the door, 1.0 x 2.2 x 0.9 m, holding a cone, with a drop of ice cream melting on its head.
export function buildPenguinStatue() {
	const b = new Builder('penguin_statue');
	const black = mat('penguin_black', 0x1c1e26), white = mat('penguin_white', 0xf4f4f0), orange = mat('penguin_orange', 0xf09030);
	b.add('base', mat('penguin_base', 0x5a8ad0), new THREE.CylinderGeometry(0.5, 0.55, 0.2, 12), { pos: V(0, 0.1, 0) });
	b.add('body', black, new THREE.SphereGeometry(0.45, 12, 10), { pos: V(0, 0.85, 0), scale: [1, 1.5, 0.9] });
	b.add('belly', white, new THREE.SphereGeometry(0.36, 12, 10), { pos: V(0, 0.8, 0.12), scale: [1, 1.5, 0.8] });
	b.add('head', black, new THREE.SphereGeometry(0.3, 12, 10), { pos: V(0, 1.72, 0) });
	for (const x of [-0.11, 0.11]) {
		b.add('eyes', white, new THREE.SphereGeometry(0.07, 8, 6), { pos: V(x, 1.78, 0.25) });
		b.add('pupils', black, new THREE.SphereGeometry(0.035, 6, 4), { pos: V(x, 1.78, 0.31) });
		b.add('feet', orange, new THREE.BoxGeometry(0.18, 0.06, 0.3), { pos: V(x * 1.4, 0.23, 0.2) });
	}
	b.add('beak', orange, new THREE.ConeGeometry(0.07, 0.2, 6), { pos: V(0, 1.68, 0.36), rot: [Math.PI / 2, 0, 0] });
	for (const x of [-1, 1]) b.add('wings', black, new THREE.BoxGeometry(0.08, 0.6, 0.3), { pos: V(x * 0.46, 1.0, 0), rot: [0, 0, x * 0.3] });
	b.add('cone', mat('statue_cone', 0xd99a4e), new THREE.ConeGeometry(0.1, 0.32, 8), { pos: V(0.55, 1.2, 0.15), rot: [Math.PI, 0, 0] });
	b.add('scoop', mat('statue_scoop', 0xff9fc0), new THREE.SphereGeometry(0.12, 8, 6), { pos: V(0.55, 1.42, 0.15) });
	b.add('drop', mat('statue_drop', 0xfff0d0), new THREE.SphereGeometry(0.16, 8, 6), { pos: V(0.05, 2.0, 0.02), scale: [1.3, 0.5, 1.3] });
	b.add('drop', mat('statue_drop', 0xfff0d0), new THREE.SphereGeometry(0.05, 6, 4), { pos: V(0.15, 1.88, 0.18), scale: [1, 1.8, 1] });
	return b.build();
}

export const models = {
	ice_freezer: buildIceFreezer, freezer_lid: buildFreezerLid, ice_counter: buildIceCounter,
	soft_serve_machine: buildSoftServeMachine, cold_shelf: buildColdShelf, penguin_statue: buildPenguinStatue,
};

export const views = {
	ice_cream_shop: {
		items: [
			{ name: 'ice_counter', pos: [-0.6, 0, 1.0] }, { name: 'ice_freezer', pos: [2.6, 0, 1.4] },
			{ name: 'freezer_lid', pos: [2.6, 0.85, 1.0] }, { name: 'soft_serve_machine', pos: [3.0, 0, -0.4] },
			{ name: 'cold_shelf', pos: [-1.4, 0, -1.0] }, { name: 'penguin_statue', pos: [1.2, 0, -0.8] },
		],
		cam: { pos: [0.5, 3.0, 7.5], target: [0.5, 1.0, 0], fov: 50 },
	},
};
