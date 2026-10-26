// The hotel raid (hotel-allanamiento.md, step 1): the bedside lamp that breaks, 0.3 m wide and 0.42 m tall with its
// origin in the middle, like the ornaments. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

export function buildHotelLamp() {
	const brass = mat('lamp_brass', 0xc9a04a), shade = mat('lamp_shade', 0xf3e2b8, { emissive: 0x3a2a10 });
	const fringe = mat('lamp_fringe', 0xb0283a);
	const b = new Builder('hotel_lamp');
	b.add('base', brass, new THREE.CylinderGeometry(0.07, 0.09, 0.04, 12), { pos: V(0, -0.19, 0) });
	b.add('base', brass, new THREE.SphereGeometry(0.06, 10, 7), { pos: V(0, -0.13, 0) });
	b.add('base', brass, new THREE.CylinderGeometry(0.012, 0.012, 0.18, 6), { pos: V(0, -0.02, 0) });
	b.add('shade', shade, new THREE.CylinderGeometry(0.08, 0.15, 0.16, 12, 1, true), { pos: V(0, 0.13, 0) });
	b.add('shade', fringe, new THREE.CylinderGeometry(0.152, 0.152, 0.02, 12, 1, true), { pos: V(0, 0.05, 0) });
	return b.build();
}

export const models = { hotel_lamp: buildHotelLamp };

export const views = {
	hotel_lamp: { items: [{ name: 'hotel_lamp', pos: [0, 0.21, 0] }, { name: 'ornament_vase', pos: [0.35, 0.13, 0] }],
		cam: { pos: [0.2, 0.5, 1.4], target: [0.15, 0.2, 0], fov: 35 } },
};
