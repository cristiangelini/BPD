// What the pawn shop's stories hide (docs/diseno/allanamiento-empenos.md, "Las historias"): the golf club's gold trophy
// and its painted plastic copy, the painter's receipt, the armor costume full of loot, the oily rag, the map of the
// robbed houses, the dentist's box of gold dentures, his pliers and the patient list, the famous singer's guitar, his
// signed photo and the tour contract, the customs label, the ship's receipt and a pearl. Origins at the floor in the
// middle of each piece. Placeholder, not final art.
import { Builder, mat, ellipsoid, V, THREE } from '../lib.js';

const paper = () => mat('pawn_story_paper', 0xf6f2e2);
const ink = () => mat('pawn_story_ink', 0x3a3a48);
const wood = () => mat('pawn_story_wood', 0x6a4028);

// A golf trophy 0.6 m tall: a black base, a gold cup and a little golfer on a ball on top.
function trophy(name, gold) {
	const b = new Builder(name);
	b.add('base', mat('golf_trophy_base', 0x24242a), new THREE.BoxGeometry(0.26, 0.12, 0.26), { pos: V(0, 0.06, 0) });
	b.add('stem', gold, new THREE.CylinderGeometry(0.03, 0.05, 0.16, 8), { pos: V(0, 0.2, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.16, 0.06, 0.22, 12), { pos: V(0, 0.39, 0) });
	for (const s of [-1, 1]) b.add('handle', gold, new THREE.TorusGeometry(0.06, 0.012, 6, 10), { pos: V(s * 0.17, 0.4, 0) });
	b.add('ball', mat('golf_ball', 0xf6f6f2), new THREE.SphereGeometry(0.04, 8, 6), { pos: V(0, 0.54, 0) });
	b.add('flag', mat('golf_flag', 0xd83a30), new THREE.BoxGeometry(0.06, 0.04, 0.005), { pos: V(0.035, 0.6, 0) });
	return b;
}

export function buildGoldTrophy() {
	return trophy('gold_trophy', mat('golf_gold', 0xf0c030, { metalness: 0.35, roughness: 0.3 })).build();
}

// The copy: the same trophy in shiny yellow plastic, with a drip of paint on the base.
export function buildPlasticTrophy() {
	const b = trophy('plastic_trophy', mat('golf_plastic', 0xf2d040, { roughness: 0.6 }));
	b.add('drip', mat('golf_drip', 0xf2d040), new THREE.BoxGeometry(0.03, 0.06, 0.01), { pos: V(0.06, 0.09, 0.13) });
	return b.build();
}

// The painter's receipt: a sheet 0.15 x 0.2 m with a gold paint smear.
export function buildPainterReceipt() {
	const b = new Builder('painter_receipt');
	b.add('sheet', paper(), new THREE.BoxGeometry(0.15, 0.004, 0.2), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 5; i++) b.add('line', ink(), new THREE.BoxGeometry(0.1, 0.002, 0.006), { pos: V(-0.01, 0.005, -0.07 + i * 0.03) });
	b.add('smear', mat('receipt_gold', 0xe8b830), new THREE.BoxGeometry(0.05, 0.002, 0.03), { pos: V(0.03, 0.005, 0.08) });
	return b.build();
}

// The armor costume with the loot inside: a cloth sack 0.8 x 0.45 x 0.5 m with a helmet, a gauntlet and a necklace
// sticking out.
export function buildArmorCostume() {
	const b = new Builder('armor_costume');
	const steel = mat('costume_steel', 0xb0b4bc, { metalness: 0.7, roughness: 0.35 });
	b.add('sack', mat('costume_sack', 0x8a7a5a), ellipsoid(0.4, 0.22, 0.25), { pos: V(0, 0.22, 0) });
	b.add('helmet', steel, ellipsoid(0.13, 0.15, 0.14), { pos: V(-0.18, 0.42, 0) });
	b.add('visor', mat('costume_dark', 0x24242a), new THREE.BoxGeometry(0.16, 0.025, 0.02), { pos: V(-0.18, 0.44, 0.14) });
	b.add('gauntlet', steel, new THREE.BoxGeometry(0.12, 0.08, 0.16), { pos: V(0.2, 0.42, 0.05), rot: [0, 0.4, 0.3] });
	b.add('necklace', mat('costume_gold', 0xe8b830, { metalness: 0.8, roughness: 0.25 }), new THREE.TorusGeometry(0.07, 0.012, 6, 14), { pos: V(0.05, 0.43, -0.08), rot: [Math.PI / 2, 0, 0] });
	b.add('gem', mat('costume_gem', 0x3a8ad8), new THREE.OctahedronGeometry(0.03), { pos: V(0.05, 0.44, 0) });
	return b.build();
}

// An oily rag, 0.3 x 0.25 m, crumpled on the floor.
export function buildOilRag() {
	const b = new Builder('oil_rag');
	b.add('rag', mat('rag_cloth', 0xc8b890), new THREE.BoxGeometry(0.3, 0.04, 0.25), { pos: V(0, 0.02, 0), rot: [0, 0.3, 0.05] });
	b.add('stain', mat('rag_oil', 0x2a2418), new THREE.BoxGeometry(0.16, 0.006, 0.12), { pos: V(0.03, 0.044, 0.01) });
	return b.build();
}

// The map of the robbed houses: a sheet 0.3 x 0.21 m with blocks and red crosses.
export function buildRobbedHousesMap() {
	const b = new Builder('robbed_houses_map');
	b.add('sheet', mat('map_paper', 0xe8e0c0), new THREE.BoxGeometry(0.3, 0.004, 0.21), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 6; i++) b.add('block', mat('map_block', 0x8aa070), new THREE.BoxGeometry(0.05, 0.002, 0.04), { pos: V(-0.1 + (i % 3) * 0.1, 0.005, -0.04 + Math.floor(i / 3) * 0.08) });
	for (const [x, z] of [[-0.1, -0.04], [0.1, 0.04], [0.0, 0.04]]) {
		for (const r of [0.8, -0.8]) b.add('cross', mat('map_cross', 0xd83a30), new THREE.BoxGeometry(0.04, 0.003, 0.008), { pos: V(x, 0.007, z), rot: [0, r, 0] });
	}
	return b.build();
}

// The dentist's box of gold dentures: a white case 0.5 x 0.3 x 0.35 m, open, with three gold smiles inside.
export function buildDenturesBox() {
	const b = new Builder('dentures_box');
	const white = mat('dentures_case', 0xeef0f2);
	b.add('box', white, new THREE.BoxGeometry(0.5, 0.22, 0.35), { pos: V(0, 0.11, 0) });
	b.add('lid', white, new THREE.BoxGeometry(0.5, 0.02, 0.35), { pos: V(0, 0.32, -0.2), rot: [-1.2, 0, 0] });
	b.add('cross', mat('dentures_cross', 0xd83a30), new THREE.BoxGeometry(0.08, 0.08, 0.005), { pos: V(0, 0.12, 0.177) });
	const gold = mat('dentures_gold', 0xe8b830, { metalness: 0.8, roughness: 0.25 });
	for (let i = 0; i < 3; i++) {
		b.add('gum', mat('dentures_gum', 0xd87a8a), new THREE.TorusGeometry(0.05, 0.015, 6, 10, Math.PI), { pos: V(-0.15 + i * 0.15, 0.23, 0), rot: [-Math.PI / 2, 0, 0] });
		b.add('teeth', gold, new THREE.TorusGeometry(0.05, 0.01, 6, 10, Math.PI), { pos: V(-0.15 + i * 0.15, 0.245, 0), rot: [-Math.PI / 2, 0, 0] });
	}
	return b.build();
}

// The dentist's pliers, 0.18 m long, on the floor.
export function buildDentistPliers() {
	const b = new Builder('dentist_pliers');
	const steel = mat('pliers_steel', 0xc8ccd4, { metalness: 0.8, roughness: 0.3 });
	for (const s of [-1, 1]) b.add('arm', steel, new THREE.BoxGeometry(0.16, 0.012, 0.014), { pos: V(0, 0.008, s * 0.012), rot: [0, s * 0.12, 0] });
	b.add('pin', steel, new THREE.CylinderGeometry(0.01, 0.01, 0.02, 8), { pos: V(0.05, 0.01, 0) });
	return b.build();
}

// The dentist's patient list: a clipboard 0.23 x 0.32 m.
export function buildPatientList() {
	const b = new Builder('patient_list');
	b.add('board', mat('clipboard_brown', 0x8a5a30), new THREE.BoxGeometry(0.23, 0.01, 0.32), { pos: V(0, 0.005, 0) });
	b.add('sheet', paper(), new THREE.BoxGeometry(0.2, 0.004, 0.27), { pos: V(0, 0.012, 0.015) });
	b.add('clip', mat('clipboard_clip', 0xc8ccd4, { metalness: 0.8 }), new THREE.BoxGeometry(0.08, 0.02, 0.03), { pos: V(0, 0.018, -0.14) });
	for (let i = 0; i < 7; i++) b.add('line', ink(), new THREE.BoxGeometry(0.14, 0.002, 0.006), { pos: V(-0.01, 0.015, -0.08 + i * 0.03) });
	return b.build();
}

// The famous singer's guitar, 1 m long lying on its back (neck to +X), red with a white star.
export function buildStarGuitar() {
	const b = new Builder('star_guitar');
	const red = mat('star_guitar_red', 0xc82a2a);
	b.add('lower', red, new THREE.CylinderGeometry(0.2, 0.2, 0.1, 14), { pos: V(-0.28, 0.05, 0) });
	b.add('upper', red, new THREE.CylinderGeometry(0.15, 0.15, 0.1, 14), { pos: V(-0.02, 0.05, 0) });
	b.add('hole', mat('star_guitar_hole', 0x24242a), new THREE.CylinderGeometry(0.05, 0.05, 0.005, 12), { pos: V(-0.1, 0.102, 0) });
	b.add('star', mat('star_guitar_star', 0xf6f2e2), new THREE.OctahedronGeometry(0.05), { pos: V(-0.3, 0.1, 0.08), scale: [1, 0.15, 1] });
	b.add('neck', wood(), new THREE.BoxGeometry(0.45, 0.04, 0.06), { pos: V(0.33, 0.06, 0) });
	b.add('head', wood(), new THREE.BoxGeometry(0.12, 0.04, 0.09), { pos: V(0.61, 0.06, 0) });
	for (let i = 0; i < 4; i++) b.add('string', mat('star_guitar_string', 0xe0e0e0), new THREE.BoxGeometry(0.85, 0.004, 0.003), { pos: V(0.13, 0.106, -0.018 + i * 0.012) });
	return b.build();
}

// The signed photo: a frame 0.2 x 0.25 m flat on the floor, the singer's face and a scribble.
export function buildSignedPhoto() {
	const b = new Builder('signed_photo');
	b.add('frame', mat('photo_frame', 0x2a2a30), new THREE.BoxGeometry(0.2, 0.012, 0.25), { pos: V(0, 0.006, 0) });
	b.add('photo', mat('photo_sky', 0x6aa0d8), new THREE.BoxGeometry(0.17, 0.004, 0.22), { pos: V(0, 0.013, 0) });
	b.add('face', mat('photo_face', 0xe0b090), new THREE.CylinderGeometry(0.04, 0.04, 0.004, 12), { pos: V(0, 0.016, -0.03) });
	b.add('hair', mat('photo_hair', 0x24242a), new THREE.BoxGeometry(0.09, 0.004, 0.03), { pos: V(0, 0.017, -0.07) });
	b.add('scribble', ink(), new THREE.BoxGeometry(0.11, 0.002, 0.008), { pos: V(0.01, 0.018, 0.07), rot: [0, 0.3, 0] });
	return b.build();
}

// The tour contract: two sheets 0.21 x 0.3 m, stapled, with a red seal.
export function buildTourContract() {
	const b = new Builder('tour_contract');
	b.add('sheet', paper(), new THREE.BoxGeometry(0.21, 0.008, 0.3), { pos: V(0, 0.004, 0) });
	for (let i = 0; i < 9; i++) b.add('line', ink(), new THREE.BoxGeometry(0.16, 0.002, 0.006), { pos: V(0, 0.009, -0.12 + i * 0.025) });
	b.add('seal', mat('contract_seal', 0xc82a2a), new THREE.CylinderGeometry(0.025, 0.025, 0.004, 12), { pos: V(0.06, 0.01, 0.12) });
	return b.build();
}

// The customs label: a brown tag 0.15 x 0.08 m with a string.
export function buildCustomsLabel() {
	const b = new Builder('customs_label');
	b.add('tag', mat('customs_brown', 0xc8a060), new THREE.BoxGeometry(0.15, 0.004, 0.08), { pos: V(0, 0.002, 0) });
	b.add('stamp', mat('customs_stamp', 0x3a6ad2), new THREE.BoxGeometry(0.06, 0.002, 0.04), { pos: V(0.02, 0.005, 0) });
	b.add('string', mat('customs_string', 0xf6f2e2), new THREE.BoxGeometry(0.1, 0.004, 0.004), { pos: V(-0.12, 0.002, 0) });
	return b.build();
}

// The ship's receipt: a sheet 0.15 x 0.2 m with a little blue ship.
export function buildShipReceipt() {
	const b = new Builder('ship_receipt');
	b.add('sheet', paper(), new THREE.BoxGeometry(0.15, 0.004, 0.2), { pos: V(0, 0.002, 0) });
	b.add('ship', mat('receipt_ship', 0x3a6ad2), new THREE.BoxGeometry(0.06, 0.002, 0.02), { pos: V(0, 0.005, -0.06) });
	for (let i = 0; i < 4; i++) b.add('line', ink(), new THREE.BoxGeometry(0.1, 0.002, 0.006), { pos: V(0, 0.005, -0.01 + i * 0.03) });
	return b.build();
}

// A pearl, 3 cm.
export function buildPawnPearl() {
	const b = new Builder('pawn_pearl');
	b.add('pearl', mat('pearl_white', 0xf6f2ee, { roughness: 0.15 }), new THREE.SphereGeometry(0.015, 10, 8), { pos: V(0, 0.015, 0) });
	return b.build();
}

export const models = {
	gold_trophy: buildGoldTrophy, plastic_trophy: buildPlasticTrophy, painter_receipt: buildPainterReceipt,
	armor_costume: buildArmorCostume, oil_rag: buildOilRag, robbed_houses_map: buildRobbedHousesMap,
	dentures_box: buildDenturesBox, dentist_pliers: buildDentistPliers, patient_list: buildPatientList,
	star_guitar: buildStarGuitar, signed_photo: buildSignedPhoto, tour_contract: buildTourContract,
	customs_label: buildCustomsLabel, ship_receipt: buildShipReceipt, pawn_pearl: buildPawnPearl,
};

export const views = {
	pawn_stories: {
		items: [
			{ name: 'gold_trophy', pos: [-2.0, 0, 0] }, { name: 'plastic_trophy', pos: [-1.4, 0, 0] },
			{ name: 'painter_receipt', pos: [-0.8, 0, 0] }, { name: 'armor_costume', pos: [0, 0, 0] },
			{ name: 'oil_rag', pos: [0.8, 0, 0] }, { name: 'robbed_houses_map', pos: [1.4, 0, 0] },
			{ name: 'dentures_box', pos: [-1.0, 0, 1.0] }, { name: 'dentist_pliers', pos: [0, 0, 1.0] },
			{ name: 'patient_list', pos: [0.8, 0, 1.0] }, { name: 'star_guitar', pos: [-1.6, 0, -1.0] },
			{ name: 'signed_photo', pos: [-0.6, 0, -1.0] }, { name: 'tour_contract', pos: [-0.2, 0, -1.0] },
			{ name: 'customs_label', pos: [0.3, 0, -1.0] }, { name: 'ship_receipt', pos: [0.7, 0, -1.0] },
			{ name: 'pawn_pearl', pos: [1.1, 0, -1.0] },
		],
		cam: { pos: [0, 2.2, 3.6], target: [0, 0.2, 0.4], fov: 45 },
	},
};
