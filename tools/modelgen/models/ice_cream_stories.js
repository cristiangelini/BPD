// The evidence of the ice cream shop's stories (docs/diseno/allanamiento-heladeria.md, "Las historias"), centered on
// their collision boxes in scenes/props/*.tscn. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The rival shop's recipes: a 0.36 x 0.24 x 0.26 m wooden box with index cards sticking out and a red "ENFRENTE" tab.
export function buildRecipeBox() {
	const b = new Builder('recipe_box');
	const wood = mat('recipe_wood', 0x9a6a3a);
	b.add('box', wood, new THREE.BoxGeometry(0.36, 0.18, 0.26), { pos: V(0, -0.03, 0) });
	const card = mat('recipe_card', 0xfaf6e8);
	for (let i = 0; i < 9; i++) {
		b.add('cards', card, new THREE.BoxGeometry(0.3, 0.14, 0.005), { pos: V(0, 0.05, -0.1 + i * 0.025), rot: [0.1 * ((i % 3) - 1), 0, 0] });
	}
	b.add('tab', mat('recipe_tab', 0xd83030), new THREE.BoxGeometry(0.08, 0.04, 0.006), { pos: V(-0.1, 0.11, 0.02) });
	return b.build();
}

// The "secret ingredient": a 0.14 x 0.2 x 0.14 m jar of green glowing powder with a big question mark label.
export function buildSecretJar() {
	const b = new Builder('secret_jar');
	b.add('jar', mat('jar_glass', 0xd0f0e0, { transparent: true, opacity: 0.55 }), new THREE.CylinderGeometry(0.065, 0.065, 0.16, 12), { pos: V(0, -0.02, 0) });
	b.add('powder', mat('jar_powder', 0x7ae07a, { emissive: 0x1a5a1a }), new THREE.CylinderGeometry(0.058, 0.058, 0.1, 12), { pos: V(0, -0.045, 0) });
	b.add('lid', mat('jar_lid', 0xd8a030), new THREE.CylinderGeometry(0.07, 0.07, 0.04, 12), { pos: V(0, 0.08, 0) });
	b.add('label', mat('jar_label', 0xfaf6e8), new THREE.BoxGeometry(0.08, 0.06, 0.005), { pos: V(0, -0.01, 0.066) });
	b.add('mark', mat('jar_mark', 0xd83030), new THREE.BoxGeometry(0.015, 0.04, 0.006), { pos: V(0, -0.005, 0.068) });
	return b.build();
}

// A 0.22 x 0.02 x 0.16 m photo of the shop across the street, in a frame, with a big red cross over it.
export function buildRivalPhoto() {
	const b = new Builder('rival_photo');
	b.add('frame', mat('photo_frame', 0x2a2a30), new THREE.BoxGeometry(0.22, 0.02, 0.16));
	b.add('photo', mat('photo_shop', 0x8ac0e8), new THREE.BoxGeometry(0.19, 0.022, 0.13));
	b.add('shop', mat('photo_awning', 0xf0e070), new THREE.BoxGeometry(0.12, 0.024, 0.04), { pos: V(0, 0, 0.02) });
	const red = mat('photo_cross', 0xe02020);
	for (const r of [0.6, -0.6]) b.add('cross', red, new THREE.BoxGeometry(0.22, 0.026, 0.015), { rot: [0, r, 0] });
	return b.build();
}

export const models = {
	recipe_box: buildRecipeBox, secret_jar: buildSecretJar, rival_photo: buildRivalPhoto,
};

export const views = {
	ice_cream_stories: {
		items: [
			{ name: 'recipe_box', pos: [-0.35, 0.13, 0] }, { name: 'secret_jar', pos: [0.1, 0.1, 0.05] },
			{ name: 'rival_photo', pos: [0.45, 0.01, 0.05] },
		],
		cam: { pos: [0, 0.7, 1.3], target: [0, 0.08, 0], fov: 45 },
	},
};
