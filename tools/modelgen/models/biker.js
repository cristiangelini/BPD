// The biker bar "El Caño Libre" (docs/diseno/infiltracion-motos.md): El Cromado's "bike", a 50 cc moped with chopper
// handlebars far too tall, a sissy bar, chrome everywhere and flames painted on its tiny tank. Faces +Z, origin at the
// ground. Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

export function buildChopperMoped() {
	const b = new Builder('chopper_moped');
	const chrome = mat('chrome', 0xdde2ea, { metalness: 0.8, roughness: 0.2 }), black = mat('moped_black', 0x1a1a1e);
	const red = mat('moped_red', 0xc0302a), flame = mat('moped_flame', 0xf0a020), tire = mat('tire', 0x1a1a1e);
	const add = (part, m, w, h, d, x, y, z, rot) => b.add(part, m, new THREE.BoxGeometry(w, h, d), { pos: V(x, y, z), rot });
	for (const z of [0.62, -0.62]) {
		b.add('wheels', tire, new THREE.CylinderGeometry(0.22, 0.22, 0.1, 10), { pos: V(0, 0.22, z), rot: [0, 0, Math.PI / 2] });
		b.add('wheels', chrome, new THREE.CylinderGeometry(0.1, 0.1, 0.11, 8), { pos: V(0, 0.22, z), rot: [0, 0, Math.PI / 2] });
	}
	add('frame', chrome, 0.06, 0.06, 1.1, 0, 0.35, 0);
	add('frame', chrome, 0.05, 0.5, 0.05, 0, 0.55, 0.62, [0.35, 0, 0]);
	add('engine', black, 0.22, 0.2, 0.3, 0, 0.32, -0.05);
	add('exhaust', chrome, 0.06, 0.06, 0.7, 0.16, 0.28, -0.35);
	add('tank', red, 0.26, 0.16, 0.36, 0, 0.55, 0.25);
	for (const s of [-1, 1]) add('flames', flame, 0.01, 0.08, 0.22, s * 0.131, 0.53, 0.25, [0.3, 0, 0]);
	add('seat', black, 0.3, 0.08, 0.5, 0, 0.52, -0.2);
	// The far too tall chopper handlebars and the sissy bar behind the seat.
	for (const s of [-1, 1]) {
		add('bars', chrome, 0.035, 0.75, 0.035, s * 0.12, 1.08, 0.75, [0, 0, s * -0.12]);
		add('bars', black, 0.05, 0.05, 0.14, s * 0.18, 1.44, 0.7);
		add('sissy', chrome, 0.03, 0.6, 0.03, s * 0.13, 0.82, -0.48);
	}
	add('bars', chrome, 0.3, 0.035, 0.035, 0, 1.45, 0.75);
	add('sissy', chrome, 0.29, 0.03, 0.03, 0, 1.12, -0.48);
	b.add('lights', mat('moped_light', 0xfff4c0, { emissive: 0x605020 }), new THREE.SphereGeometry(0.07, 8, 6), { pos: V(0, 0.7, 0.75) });
	return b.build();
}

// The patio's heavy bike (step 3): a big black and chrome chopper, 2.1 m long, with a teardrop tank, a wide back tyre
// and long forks. Faces +Z, origin at the ground.
export function buildHeavyBike() {
	const b = new Builder('heavy_bike');
	const chrome = mat('chrome', 0xdde2ea, { metalness: 0.8, roughness: 0.2 }), black = mat('moped_black', 0x1a1a1e);
	const tire = mat('tire', 0x1a1a1e), paint = mat('bike_paint', 0x2a2a6a), flame = mat('moped_flame', 0xf0a020);
	const add = (part, m, w, h, d, x, y, z, rot) => b.add(part, m, new THREE.BoxGeometry(w, h, d), { pos: V(x, y, z), rot });
	b.add('wheels', tire, new THREE.CylinderGeometry(0.34, 0.34, 0.12, 12), { pos: V(0, 0.34, 0.8), rot: [0, 0, Math.PI / 2] });
	b.add('wheels', tire, new THREE.CylinderGeometry(0.36, 0.36, 0.24, 12), { pos: V(0, 0.36, -0.7), rot: [0, 0, Math.PI / 2] });
	for (const z of [0.8, -0.7]) b.add('wheels', chrome, new THREE.CylinderGeometry(0.15, 0.15, 0.25, 8), { pos: V(0, 0.35, z), rot: [0, 0, Math.PI / 2] });
	for (const s of [-1, 1]) add('forks', chrome, 0.05, 0.8, 0.05, s * 0.09, 0.7, 0.62, [0.45, 0, 0]);
	add('frame', black, 0.12, 0.12, 1.2, 0, 0.48, 0.0);
	add('engine', chrome, 0.32, 0.32, 0.4, 0, 0.5, 0.05);
	add('exhaust', chrome, 0.08, 0.08, 1.1, 0.22, 0.36, -0.3);
	b.add('tank', paint, new THREE.SphereGeometry(0.2, 10, 6), { pos: V(0, 0.82, 0.3), scale: [0.8, 0.6, 1.4] });
	for (const sd of [-1, 1]) add('flames', flame, 0.01, 0.08, 0.3, sd * 0.16, 0.8, 0.3, [0.3, 0, 0]);
	add('seat', black, 0.36, 0.1, 0.6, 0, 0.72, -0.25);
	add('fender', paint, 0.3, 0.06, 0.5, 0, 0.75, -0.75, [-0.3, 0, 0]);
	add('bars', chrome, 0.8, 0.04, 0.04, 0, 1.1, 0.5);
	for (const sd of [-1, 1]) add('bars', black, 0.06, 0.06, 0.14, sd * 0.4, 1.1, 0.46);
	b.add('lights', mat('moped_light', 0xfff4c0, { emissive: 0x605020 }), new THREE.SphereGeometry(0.1, 8, 6), { pos: V(0, 0.95, 0.75) });
	return b.build();
}

// The arm-wrestling table (step 3): a small high round table with two red elbow pads; origin at the floor.
export function buildArmTable() {
	const b = new Builder('arm_table');
	const wood = mat('arm_wood', 0x6a4022), red = mat('arm_pad', 0xb02424), steel = mat('arm_steel', 0x7a7c84);
	b.add('top', wood, new THREE.CylinderGeometry(0.45, 0.45, 0.06, 14), { pos: V(0, 1.0, 0) });
	b.add('leg', steel, new THREE.CylinderGeometry(0.06, 0.06, 0.97, 8), { pos: V(0, 0.5, 0) });
	b.add('leg', steel, new THREE.CylinderGeometry(0.3, 0.3, 0.04, 12), { pos: V(0, 0.02, 0) });
	for (const s of [-1, 1]) b.add('pads', red, new THREE.CylinderGeometry(0.09, 0.09, 0.03, 10), { pos: V(0, 1.045, s * 0.18) });
	for (const s of [-1, 1]) b.add('grips', steel, new THREE.CylinderGeometry(0.015, 0.015, 0.14, 6), { pos: V(s * 0.3, 1.1, 0) });
	return b.build();
}

// Two clasped forearms (step 3), one in a cop's blue sleeve and one in black leather, the hands locked in the middle;
// origin at the elbows' middle, the hands up. The table tilts it to show who is winning.
export function buildArmLock() {
	const b = new Builder('arm_lock');
	const blue = mat('cop_sleeve', 0x2a5ad0), leather = mat('biker_leather', 0x1a1a1e), skin = mat('skin_arena', 0xd9a06b);
	b.add('arms', blue, new THREE.CylinderGeometry(0.05, 0.06, 0.3, 8), { pos: V(0, 0.12, 0.1), rot: [0.6, 0, 0] });
	b.add('arms', leather, new THREE.CylinderGeometry(0.06, 0.07, 0.3, 8), { pos: V(0, 0.12, -0.1), rot: [-0.6, 0, 0] });
	b.add('hands', skin, new THREE.SphereGeometry(0.07, 8, 6), { pos: V(0, 0.27, 0), scale: [1, 1.1, 1.2] });
	return b.build();
}

export const models = { chopper_moped: buildChopperMoped, heavy_bike: buildHeavyBike, arm_table: buildArmTable, arm_lock: buildArmLock };

export const views = {
	chopper_moped: {
		items: [{ name: 'chopper_moped', pos: [0, 0, 0] }, { name: 'npc_cromado', pos: [0, 0.32, -0.2], scale: 1.3 }],
		cam: { pos: [2.6, 1.6, 2.6], target: [0, 0.8, 0], fov: 45 },
	},
	chopper_moped_alone: {
		items: [{ name: 'chopper_moped', pos: [0, 0, 0] }],
		cam: { pos: [2.0, 1.2, 2.0], target: [0, 0.6, 0], fov: 45 },
	},
	patio: {
		items: [{ name: 'heavy_bike', pos: [-0.8, 0, 0] }, { name: 'arm_table', pos: [1.2, 0, 0] },
			{ name: 'arm_lock', pos: [1.2, 1.06, 0] }],
		cam: { pos: [2.5, 2.0, 3.5], target: [0.2, 0.7, 0], fov: 45 },
	},
};
