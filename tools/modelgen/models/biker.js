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

export const models = { chopper_moped: buildChopperMoped };

export const views = {
	chopper_moped: {
		items: [{ name: 'chopper_moped', pos: [0, 0, 0] }, { name: 'npc_cromado', pos: [0, 0.32, -0.2], scale: 1.3 }],
		cam: { pos: [2.6, 1.6, 2.6], target: [0, 0.8, 0], fov: 45 },
	},
	chopper_moped_alone: {
		items: [{ name: 'chopper_moped', pos: [0, 0, 0] }],
		cam: { pos: [2.0, 1.2, 2.0], target: [0, 0.6, 0], fov: 45 },
	},
};
