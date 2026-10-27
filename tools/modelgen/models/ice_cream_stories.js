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

// A 0.5 x 0.4 x 0.4 m block of ice with gold watches frozen inside, what doña Nieve smuggles.
export function buildIceBlockWatches() {
	const b = new Builder('ice_block_watches');
	b.add('ice', mat('block_ice', 0xc8ecff, { transparent: true, opacity: 0.6 }), new THREE.BoxGeometry(0.5, 0.4, 0.4));
	const gold = mat('block_gold', 0xf2c84b, { emissive: 0x3a2a05 }), face = mat('block_face', 0xf6f0e0);
	const at = [[-0.13, -0.08, 0.05], [0.1, 0.05, -0.08], [0.04, -0.1, 0.1], [-0.08, 0.1, -0.05], [0.15, -0.02, 0.06]];
	for (const [x, y, z] of at) {
		b.add('watch', gold, new THREE.CylinderGeometry(0.04, 0.04, 0.015, 10), { pos: V(x, y, z), rot: [Math.PI / 2, 0, x * 3] });
		b.add('face', face, new THREE.CylinderGeometry(0.03, 0.03, 0.017, 10), { pos: V(x, y, z + 0.001), rot: [Math.PI / 2, 0, x * 3] });
	}
	return b.build();
}

// A 0.4 x 0.3 x 0.35 m counter scale with a round dial, a steel plate and a tiny magnet showing under it.
export function buildIceScale() {
	const b = new Builder('ice_scale');
	b.add('base', mat('scale_body', 0xe8e0d0), new THREE.BoxGeometry(0.4, 0.12, 0.35), { pos: V(0, -0.09, 0) });
	b.add('plate', mat('scale_plate', 0xc0c4c8), new THREE.BoxGeometry(0.32, 0.015, 0.26), { pos: V(0, -0.025, 0.02) });
	b.add('tower', mat('scale_body', 0xe8e0d0), new THREE.BoxGeometry(0.16, 0.16, 0.06), { pos: V(0, 0.05, -0.145) });
	b.add('dial', mat('scale_dial', 0xfaf6e8), new THREE.CylinderGeometry(0.06, 0.06, 0.01, 16), { pos: V(0, 0.06, -0.11), rot: [Math.PI / 2, 0, 0] });
	b.add('needle', mat('scale_needle', 0xd83030), new THREE.BoxGeometry(0.006, 0.05, 0.004), { pos: V(0.012, 0.07, -0.103), rot: [0, 0, -0.5] });
	b.add('magnet', mat('scale_magnet', 0xd83030), new THREE.BoxGeometry(0.05, 0.02, 0.03), { pos: V(0.12, -0.155, 0.12) });
	return b.build();
}

// A 0.15 x 0.05 x 0.1 m red horseshoe magnet with silver tips.
export function buildScaleMagnet() {
	const b = new Builder('scale_magnet');
	const red = mat('magnet_red', 0xd83030), tip = mat('magnet_tip', 0xd0d4d8);
	b.add('back', red, new THREE.BoxGeometry(0.03, 0.05, 0.1), { pos: V(-0.06, 0, 0) });
	for (const z of [-0.035, 0.035]) {
		b.add('arm', red, new THREE.BoxGeometry(0.09, 0.05, 0.03), { pos: V(0, 0, z) });
		b.add('tip', tip, new THREE.BoxGeometry(0.03, 0.05, 0.03), { pos: V(0.06, 0, z) });
	}
	return b.build();
}

// A 0.36 x 0.2 x 0.26 m cardboard box full of ice cream sticks, the prize ones with a gold tip.
export function buildPrizeSticks() {
	const b = new Builder('prize_sticks');
	b.add('box', mat('sticks_box', 0xc89a60), new THREE.BoxGeometry(0.36, 0.16, 0.26), { pos: V(0, -0.02, 0) });
	const wood = mat('stick_wood', 0xead2a0), gold = mat('stick_gold', 0xf2c84b, { emissive: 0x3a2a05 });
	for (let i = 0; i < 14; i++) {
		const x = -0.15 + (i % 7) * 0.05, z = i < 7 ? -0.05 : 0.05;
		b.add('stick', wood, new THREE.BoxGeometry(0.02, 0.1, 0.004), { pos: V(x, 0.08, z), rot: [0.15 * ((i % 3) - 1), 0, 0] });
		b.add('tip', gold, new THREE.BoxGeometry(0.022, 0.02, 0.006), { pos: V(x, 0.12, z), rot: [0.15 * ((i % 3) - 1), 0, 0] });
	}
	b.add('label', mat('sticks_label', 0xd83030), new THREE.BoxGeometry(0.2, 0.06, 0.004), { pos: V(0, -0.02, 0.131) });
	return b.build();
}

// A 0.3 x 0.25 x 0.25 m bench machine that burns "PREMIO" into sticks: a grey body, a lever and a hot red head.
export function buildStickEngraver() {
	const b = new Builder('stick_engraver');
	const grey = mat('engraver_body', 0x7a8088);
	b.add('base', grey, new THREE.BoxGeometry(0.3, 0.08, 0.25), { pos: V(0, -0.085, 0) });
	b.add('column', grey, new THREE.BoxGeometry(0.06, 0.17, 0.06), { pos: V(-0.1, 0.04, -0.07) });
	b.add('arm', grey, new THREE.BoxGeometry(0.2, 0.04, 0.06), { pos: V(0, 0.105, -0.07) });
	b.add('head', mat('engraver_hot', 0xe04020, { emissive: 0x601000 }), new THREE.BoxGeometry(0.05, 0.06, 0.05), { pos: V(0.07, 0.06, -0.07) });
	b.add('lever', mat('engraver_lever', 0x202020), new THREE.BoxGeometry(0.02, 0.02, 0.14), { pos: V(0.11, 0.105, 0.03) });
	b.add('tray', mat('stick_wood', 0xead2a0), new THREE.BoxGeometry(0.12, 0.01, 0.03), { pos: V(0.07, -0.04, -0.07) });
	return b.build();
}

// A 0.3 x 0.3 x 0.3 m pink ice cream bucket with frosty green bills bulging out of it under the lid.
export function buildCashBucket() {
	const b = new Builder('cash_bucket');
	b.add('bucket', mat('cash_bucket_pink', 0xf0a0c0), new THREE.CylinderGeometry(0.15, 0.13, 0.26, 14), { pos: V(0, -0.02, 0) });
	b.add('band', mat('cash_bucket_band', 0xfaf6e8), new THREE.CylinderGeometry(0.152, 0.145, 0.06, 14), { pos: V(0, 0.0, 0) });
	const bill = mat('cash_bill', 0x7ac08a), frost = mat('cash_frost', 0xe8f6ff);
	for (let i = 0; i < 8; i++) {
		const a = (i / 8) * Math.PI * 2;
		b.add('bill', bill, new THREE.BoxGeometry(0.12, 0.004, 0.06), { pos: V(Math.cos(a) * 0.06, 0.12 + (i % 2) * 0.01, Math.sin(a) * 0.06), rot: [0.3 * Math.sin(a), a, 0.3 * Math.cos(a)] });
	}
	b.add('frost', frost, new THREE.CylinderGeometry(0.1, 0.12, 0.02, 12), { pos: V(0, 0.115, 0) });
	return b.build();
}

// The ice cream truck's original plate, 0.52 x 0.04 x 0.14 m: white with a black rim and black number blocks.
export function buildTruckPlate() {
	const b = new Builder('truck_plate');
	b.add('rim', mat('plate_rim', 0x202020), new THREE.BoxGeometry(0.52, 0.03, 0.14));
	b.add('plate', mat('plate_white', 0xf4f4f0), new THREE.BoxGeometry(0.49, 0.034, 0.12));
	const ink = mat('plate_ink', 0x202020);
	for (let i = 0; i < 6; i++) b.add('digit', ink, new THREE.BoxGeometry(0.045, 0.036, 0.07), { pos: V(-0.17 + i * 0.068, 0, 0) });
	b.add('bolt', mat('plate_bolt', 0xc0c4c8), new THREE.CylinderGeometry(0.01, 0.01, 0.038, 8), { pos: V(-0.22, 0, 0.045) });
	b.add('bolt', mat('plate_bolt', 0xc0c4c8), new THREE.CylinderGeometry(0.01, 0.01, 0.038, 8), { pos: V(0.22, 0, 0.045) });
	return b.build();
}

// The truck's papers with somebody else's name: a 0.22 x 0.03 x 0.3 m brown folder with sheets and a red seal.
export function buildTruckPapers() {
	const b = new Builder('truck_papers');
	b.add('folder', mat('papers_folder', 0xb08850), new THREE.BoxGeometry(0.22, 0.012, 0.3), { pos: V(0, -0.008, 0) });
	b.add('sheets', mat('papers_sheet', 0xfaf6e8), new THREE.BoxGeometry(0.2, 0.012, 0.28), { pos: V(0.005, 0.004, 0) });
	b.add('seal', mat('papers_seal', 0xd83030), new THREE.CylinderGeometry(0.025, 0.025, 0.014, 10), { pos: V(0.05, 0.008, 0.08) });
	return b.build();
}

export const models = {
	recipe_box: buildRecipeBox, secret_jar: buildSecretJar, rival_photo: buildRivalPhoto,
	ice_block_watches: buildIceBlockWatches, ice_scale: buildIceScale, scale_magnet: buildScaleMagnet,
	prize_sticks: buildPrizeSticks, stick_engraver: buildStickEngraver, cash_bucket: buildCashBucket,
	truck_plate: buildTruckPlate, truck_papers: buildTruckPapers,
};

export const views = {
	ice_cream_stories: {
		items: [
			{ name: 'recipe_box', pos: [-0.35, 0.13, 0] }, { name: 'secret_jar', pos: [0.1, 0.1, 0.05] },
			{ name: 'rival_photo', pos: [0.45, 0.01, 0.05] },
			{ name: 'ice_block_watches', pos: [-0.2, 0.2, -0.6] },
			{ name: 'ice_scale', pos: [0.45, 0.15, -0.6] }, { name: 'scale_magnet', pos: [0.75, 0.025, 0.1] },
			{ name: 'prize_sticks', pos: [-0.8, 0.1, 0.1] }, { name: 'stick_engraver', pos: [-0.8, 0.125, -0.5] },
			{ name: 'cash_bucket', pos: [0.9, 0.15, -0.3] },
			{ name: 'truck_plate', pos: [-0.3, 0.02, 0.45] }, { name: 'truck_papers', pos: [0.3, 0.015, 0.45] },
		],
		cam: { pos: [0, 0.7, 1.3], target: [0, 0.08, 0], fov: 45 },
	},
};
