// The retirees' fight club (historias.md): the champion's belt, the gloves, the fight notebook, the photo with the
// neighbors and the ring in the attic. Centered on their collision boxes in scenes/props/*.tscn (the ring sits on the
// floor). Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The champion's belt: 0.6 x 0.03 x 0.12 m of red leather with a big gold plate, lying flat.
export function buildBelt() {
	const b = new Builder('champion_belt');
	const gold = mat('belt_gold', 0xf0c040, { emissive: 0x302408 });
	b.add('strap', mat('belt_leather', 0xb02028), new THREE.BoxGeometry(0.6, 0.012, 0.08));
	b.add('plate', gold, new THREE.CylinderGeometry(0.06, 0.06, 0.02, 12), { pos: V(0, 0.008, 0) });
	b.add('plate', mat('belt_star', 0xd82020), new THREE.CylinderGeometry(0.025, 0.025, 0.006, 5), { pos: V(0, 0.02, 0) });
	for (const x of [-0.12, 0.12]) b.add('side_plates', gold, new THREE.BoxGeometry(0.06, 0.016, 0.06), { pos: V(x, 0.004, 0) });
	return b.build();
}

// A pair of worn boxing gloves tied together: 0.3 x 0.12 x 0.16 m.
export function buildGloves() {
	const b = new Builder('boxing_gloves');
	const red = mat('glove_red', 0xc83030), cuff = mat('glove_cuff', 0xf4efd8);
	for (const x of [-0.075, 0.075]) {
		b.add('gloves', red, new THREE.SphereGeometry(0.07, 8, 6), { pos: V(x, 0, -0.02), scale: [1, 0.85, 1.1] });
		b.add('gloves', cuff, new THREE.CylinderGeometry(0.045, 0.05, 0.05, 8), { pos: V(x, -0.01, 0.06), rot: [Math.PI / 2, 0, 0] });
		b.add('patches', mat('glove_tape', 0xbfb8a0), new THREE.BoxGeometry(0.04, 0.01, 0.03), { pos: V(x + 0.02, 0.055, -0.03) });
	}
	return b.build();
}

// The fight notebook: 0.2 x 0.025 x 0.14 m, black with a red stripe.
export function buildNotebook() {
	const b = new Builder('fight_notebook');
	b.add('cover', mat('notebook_black', 0x222226), new THREE.BoxGeometry(0.2, 0.025, 0.14));
	b.add('pages', mat('notebook_pages', 0xf4efd8), new THREE.BoxGeometry(0.19, 0.02, 0.135), { pos: V(0.006, 0, 0) });
	b.add('stripe', mat('notebook_stripe', 0xd82020), new THREE.BoxGeometry(0.2, 0.026, 0.02), { pos: V(0, 0, -0.04) });
	return b.build();
}

// A framed photo lying flat: 0.2 x 0.012 x 0.15 m, five old faces with black eyes.
export function buildPhoto() {
	const b = new Builder('fight_photo');
	b.add('frame', mat('photo_frame', 0x8a5a2a), new THREE.BoxGeometry(0.2, 0.012, 0.15));
	b.add('picture', mat('photo_sky', 0xa8c8d8), new THREE.BoxGeometry(0.17, 0.002, 0.12), { pos: V(0, 0.007, 0) });
	for (let i = 0; i < 5; i++) {
		const x = -0.064 + i * 0.032;
		b.add('faces', mat('photo_face', 0xf0c8a0), new THREE.CylinderGeometry(0.012, 0.012, 0.002, 8), { pos: V(x, 0.009, -0.01) });
		b.add('bruises', mat('photo_bruise', 0x5a2a70), new THREE.CylinderGeometry(0.005, 0.005, 0.002, 6), { pos: V(x - 0.004, 0.0105, -0.014) });
		b.add('bodies', mat('photo_shirt', [0xd85050, 0x5080d8, 0x50a050, 0xe0a030, 0x9050c0][i]), new THREE.BoxGeometry(0.024, 0.002, 0.03), { pos: V(x, 0.009, 0.022) });
	}
	return b.build();
}

// The ring in the attic: a 2.8 x 2.8 m mat with four corner posts and three ropes on each side. The origin is on the
// floor at its center.
export function buildRing() {
	const b = new Builder('fight_ring');
	const half = 1.4, post = mat('ring_post', 0xd8d8d8), rope = mat('ring_rope', 0xd82020);
	b.add('mat', mat('ring_mat', 0x3a5a9a), new THREE.BoxGeometry(2.8, 0.06, 2.8), { pos: V(0, 0.03, 0) });
	for (const x of [-half, half]) for (const z of [-half, half]) {
		b.add('posts', post, new THREE.CylinderGeometry(0.04, 0.05, 1.2, 8), { pos: V(x, 0.6, z) });
	}
	for (const y of [0.45, 0.75, 1.05]) {
		for (const z of [-half, half]) b.add('ropes', rope, new THREE.BoxGeometry(2.8, 0.025, 0.025), { pos: V(0, y, z) });
		for (const x of [-half, half]) b.add('ropes', rope, new THREE.BoxGeometry(0.025, 0.025, 2.8), { pos: V(x, y, 0) });
	}
	return b.build();
}

export const models = {
	champion_belt: buildBelt, boxing_gloves: buildGloves, fight_notebook: buildNotebook, fight_photo: buildPhoto,
	fight_ring: buildRing,
};

export const views = {
	fight: {
		items: [
			{ name: 'fight_ring', pos: [0, 0, -0.6] },
			{ name: 'champion_belt', pos: [-0.4, 0.07, 1.0], rotY: 0.3 },
			{ name: 'boxing_gloves', pos: [0.15, 0.13, 1.1], rotY: -0.4 },
			{ name: 'fight_notebook', pos: [0.55, 0.07, 1.0], rotY: 0.2 },
			{ name: 'fight_photo', pos: [0.1, 0.07, 1.5], rotY: 0 },
		],
		cam: { pos: [0, 1.6, 3.0], target: [0, 0.3, 0.5], fov: 45 },
	},
};
