// The pizzeria raid (allanamiento-pizzeria.md, decision 490): the pizzeria's own things. The clay oven with its fire,
// the dough table with its marble top and flour, a dough ball and a slice of pizza for Tito. Plates, pizza boxes, flour
// sacks, the phone and the delivery scooter come from the restaurant, the bakery and the insurance office. Bottoms at
// y = 0, fronts toward +Z. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

const C = (name, color, opts) => mat(name, color, opts);
const clay = C('oven_clay', 0xc87850, { roughness: 0.95 });
const brick = C('oven_brick', 0x9a4a32, { roughness: 0.9 });
const dough = C('dough', 0xf0d8a8, { roughness: 0.9 });
const wood = C('table_wood', 0xa07848, { roughness: 0.85 });

export const models = {
	// The clay oven: a dome on a brick base, its arched mouth toward +Z with the fire glowing inside, a chimney and a
	// stack of firewood beside it. About 1.6 x 1.9 x 1.6 m; the mouth's floor at 0.9 m.
	clay_oven() {
		const b = new Builder('clay_oven');
		b.add('base', brick, new THREE.BoxGeometry(1.6, 0.9, 1.6), { pos: V(0, 0.45, 0) });
		b.add('dome', clay, ellipsoid(0.75, 0.6, 0.75, 14, 8), { pos: V(0, 0.9, 0) });
		b.add('mouth', C('oven_dark', 0x1a1210), new THREE.BoxGeometry(0.5, 0.32, 0.12), { pos: V(0, 1.06, 0.7) });
		b.add('mouth', brick, new THREE.TorusGeometry(0.27, 0.05, 4, 10, Math.PI), { pos: V(0, 1.06, 0.74) });
		b.add('fire', C('oven_fire', 0xff8a20, { emissive: 0xd84000, emissiveIntensity: 0.9 }), new THREE.ConeGeometry(0.1, 0.2, 6), { pos: V(0, 1.0, 0.77) });
		b.add('fire', C('oven_ember', 0xff4020, { emissive: 0xc02000, emissiveIntensity: 0.8 }), new THREE.BoxGeometry(0.3, 0.04, 0.06), { pos: V(0, 0.92, 0.77) });
		b.add('chimney', brick, new THREE.CylinderGeometry(0.1, 0.12, 0.5, 8), { pos: V(0, 1.65, -0.25) });
		for (let i = 0; i < 6; i++) {
			b.add('wood', C('firewood', 0x6a4a2a), new THREE.CylinderGeometry(0.05, 0.05, 0.5, 6), { pos: V(0.95, 0.05 + Math.floor(i / 3) * 0.09, 0.3 - (i % 3) * 0.11 - (i >= 3 ? 0.05 : 0)), rot: [0, 0, Math.PI / 2] });
		}
		return b.build();
	},
	// The dough table: a wooden table with a marble top dusted with flour, a rolling pin and a jar of tomato sauce.
	// About 2 x 0.9 x 0.9 m.
	dough_table() {
		const b = new Builder('dough_table');
		b.add('top', C('marble', 0xe8e4dc, { roughness: 0.3 }), new THREE.BoxGeometry(2.0, 0.06, 0.9), { pos: V(0, 0.87, 0) });
		for (const x of [-0.9, 0.9]) for (const z of [-0.38, 0.38]) b.add('legs', wood, new THREE.BoxGeometry(0.08, 0.84, 0.08), { pos: V(x, 0.42, z) });
		b.add('shelf', wood, new THREE.BoxGeometry(1.9, 0.04, 0.8), { pos: V(0, 0.2, 0) });
		b.add('flour', C('flour_dust', 0xfaf8f0), new THREE.BoxGeometry(0.7, 0.006, 0.5), { pos: V(-0.4, 0.903, 0.05) });
		b.add('pin', wood, new THREE.CylinderGeometry(0.035, 0.035, 0.45, 8), { pos: V(0.5, 0.94, 0.15), rot: [0, 0.3, Math.PI / 2] });
		b.add('jar', C('sauce_red', 0xc02818), new THREE.CylinderGeometry(0.07, 0.07, 0.16, 10), { pos: V(0.75, 0.98, -0.25) });
		return b.build();
	},
	// A ball of pizza dough, 0.2 m wide. Its origin at its bottom (it sits on the table and grows).
	dough_ball() {
		const b = new Builder('dough_ball');
		b.add('dough', dough, ellipsoid(0.1, 0.07, 0.1, 10, 6), { pos: V(0, 0.07, 0) });
		return b.build();
	},
	// A slice of pizza with melted cheese and two pepperoni, 0.25 m long, flat. Its origin at its middle.
	pizza_slice() {
		const b = new Builder('pizza_slice');
		b.add('crust', dough, new THREE.CylinderGeometry(0.25, 0.25, 0.02, 3, 1, false, -Math.PI / 6, Math.PI / 3), { pos: V(0, 0, -0.12) });
		b.add('cheese', C('pizza_cheese', 0xf0c040), new THREE.CylinderGeometry(0.22, 0.22, 0.022, 3, 1, false, -Math.PI / 6, Math.PI / 3), { pos: V(0, 0.002, -0.11) });
		b.add('crust', dough, new THREE.CylinderGeometry(0.025, 0.025, 0.24, 6), { pos: V(0, 0.01, 0.1), rot: [0, 0, Math.PI / 2] });
		for (const z of [-0.03, 0.04]) b.add('pepperoni', C('pepperoni', 0xb02820), new THREE.CylinderGeometry(0.03, 0.03, 0.026, 8), { pos: V(z * 0.4, 0.003, z) });
		return b.build();
	},
};

export const views = {
	pizza_raid: {
		items: [{ name: 'clay_oven', pos: [-1.2, 0, -0.5] }, { name: 'dough_table', pos: [1.2, 0, -0.3] },
			{ name: 'dough_ball', pos: [0.8, 0.9, -0.2] }, { name: 'dough_ball', pos: [1.1, 0.9, -0.35] },
			{ name: 'pizza_slice', pos: [1.6, 0.92, 0.0], rotY: 0.5 }, { name: 'kitchen_plate', pos: [0.2, 0.02, 0.8] },
			{ name: 'pizza_box', pos: [0.6, 0, 0.9] }, { name: 'flour_sack', pos: [-0.2, 0, 1.0] }],
		cam: { pos: [0.0, 2.2, 5.0], target: [0.0, 0.8, 0], fov: 40 },
	},
	pizza_npcs: {
		items: [{ name: 'npc_muzza', pos: [-0.6, 0, 0], rotY: 0.3 }, { name: 'npc_tito', pos: [0.6, 0, 0], rotY: -0.3 }],
		cam: { pos: [0.0, 1.3, 4.0], target: [0.0, 0.85, 0], fov: 36 },
	},
};
