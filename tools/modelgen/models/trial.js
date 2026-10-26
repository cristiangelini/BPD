// The fast trial jailbreak (fuga-juicio.md): the lost and found's lawyer jacket with its tie, and the lost and found
// box it lies on. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// A dark grey suit jacket with lapels, a white shirt and a red tie, worn on the chest: 0.5 x 0.7 x 0.16 m, origin
// in its middle, its front +Z.
export function buildLawyerJacket() {
	const b = new Builder('disguise_lawyer_jacket');
	const suit = mat('suit_grey', 0x3a3e48), lapel = mat('suit_lapel', 0x2c3038), shirt = mat('shirt_white', 0xeeeeea);
	b.add('back', suit, new THREE.BoxGeometry(0.5, 0.7, 0.12));
	b.add('shirt', shirt, new THREE.BoxGeometry(0.14, 0.4, 0.02), { pos: V(0, 0.13, 0.065) });
	b.add('tie', mat('tie_red', 0xb8282a), new THREE.BoxGeometry(0.05, 0.32, 0.02), { pos: V(0, 0.1, 0.078) });
	for (const s of [-1, 1]) {
		b.add('lapel', lapel, new THREE.BoxGeometry(0.1, 0.36, 0.02), { pos: V(s * 0.09, 0.14, 0.07), rot: [0, 0, s * 0.25] });
		b.add('sleeve', suit, new THREE.BoxGeometry(0.1, 0.6, 0.12), { pos: V(s * 0.3, 0.02, 0) });
	}
	b.add('button', lapel, new THREE.BoxGeometry(0.03, 0.03, 0.02), { pos: V(0, -0.12, 0.07) });
	return b.build();
}

// The lost and found: an open cardboard box full of odd things, 0.6 x 0.4 x 0.45 m, origin on the floor.
export function buildLostFoundBox() {
	const b = new Builder('lost_found_box');
	const card = mat('box_card', 0xb08a58), dark = mat('box_inside', 0x6a5236);
	b.add('bottom', dark, new THREE.BoxGeometry(0.6, 0.02, 0.45), { pos: V(0, 0.01, 0) });
	for (const s of [-1, 1]) {
		b.add('side', card, new THREE.BoxGeometry(0.6, 0.4, 0.02), { pos: V(0, 0.2, s * 0.215) });
		b.add('end', card, new THREE.BoxGeometry(0.02, 0.4, 0.45), { pos: V(s * 0.29, 0.2, 0) });
		b.add('flap', card, new THREE.BoxGeometry(0.6, 0.02, 0.18), { pos: V(0, 0.42, s * 0.3), rot: [s * 0.5, 0, 0] });
	}
	b.add('umbrella', mat('lost_umbrella', 0x2a5a8a), new THREE.CylinderGeometry(0.03, 0.03, 0.6, 6), { pos: V(0.15, 0.4, -0.08), rot: [0.3, 0, 0.2] });
	b.add('shoe', mat('lost_shoe', 0x4a2a1a), new THREE.BoxGeometry(0.1, 0.08, 0.24), { pos: V(-0.15, 0.36, 0.05) });
	b.add('scarf', mat('lost_scarf', 0x8a3a6a), new THREE.BoxGeometry(0.3, 0.05, 0.1), { pos: V(0, 0.38, 0.1) });
	return b.build();
}

export const models = { disguise_lawyer_jacket: buildLawyerJacket, lost_found_box: buildLostFoundBox };

export const views = {
	trial: {
		items: [
			{ name: 'lost_found_box', pos: [-0.4, 0, 0] },
			{ name: 'disguise_lawyer_jacket', pos: [0.45, 0.6, 0] },
		],
		cam: { pos: [0, 0.8, 2.0], target: [0, 0.4, 0], fov: 45 },
	},
};
