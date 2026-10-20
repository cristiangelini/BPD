// Small props of the pet salon "Pelito Feliz" (docs/diseno/peluqueria.md): the fragile shampoo bottles on its shelves
// and the collars in the reception display. Origins at the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// A shampoo bottle: 0.07 m across, 0.22 m tall, with a pump. Pastel plastic, it shatters like porcelain in the game.
export function buildShampoo() {
	const b = new Builder('shampoo_bottle');
	const plastic = mat('shampoo', 0x8fd3f0), label = mat('shampoo_label', 0xfff2f8), pump = mat('shampoo_pump', 0xffffff);
	b.add('bottle', plastic, new THREE.CylinderGeometry(0.035, 0.038, 0.17, 8), { pos: V(0, -0.025, 0) });
	b.add('bottle', plastic, new THREE.CylinderGeometry(0.018, 0.033, 0.03, 8), { pos: V(0, 0.075, 0) });
	b.add('bottle', label, new THREE.CylinderGeometry(0.0385, 0.0385, 0.07, 8, 1, true, -0.9, 1.8), { pos: V(0, -0.03, 0) });
	b.add('pump', pump, new THREE.CylinderGeometry(0.008, 0.008, 0.03, 5), { pos: V(0, 0.1, 0) });
	b.add('pump', pump, new THREE.BoxGeometry(0.045, 0.012, 0.015), { pos: V(0.012, 0.11, 0) });
	return b.build();
}

// A dog collar on a little stand: red leather with studs and a bone tag. 0.14 m across, 0.13 m tall.
export function buildCollar() {
	const b = new Builder('dog_collar');
	b.add('stand', mat('collar_stand', 0xf4ead8), new THREE.CylinderGeometry(0.03, 0.05, 0.05, 8), { pos: V(0, -0.04, 0) });
	b.add('collar', mat('collar_leather', 0xd23a4a), new THREE.TorusGeometry(0.055, 0.012, 4, 14), { pos: V(0, 0.02, 0) });
	const gold = mat('gold', 0xffd24a);
	for (let i = 0; i < 6; i++) {
		const a = (i / 6) * Math.PI * 2;
		b.add('collar', gold, new THREE.OctahedronGeometry(0.009), { pos: V(Math.cos(a) * 0.055, 0.02 + Math.sin(a) * 0.055, 0.012) });
	}
	b.add('collar', gold, new THREE.BoxGeometry(0.03, 0.012, 0.004), { pos: V(0, -0.045, 0.012) });
	return b.build();
}

export const models = { shampoo_bottle: buildShampoo, dog_collar: buildCollar };

export const views = {
	groomer: {
		items: [{ name: 'shampoo_bottle', pos: [-0.08, 0.11, 0] }, { name: 'dog_collar', pos: [0.1, 0.065, 0] }],
		cam: { pos: [0, 0.2, 0.55], target: [0, 0.08, 0], fov: 40 },
	},
};
