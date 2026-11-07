// Props of the plant nursery "La Maceta Feliz" (docs/diseno/allanamiento-vivero.md): the yard's sprinkler, the Dentuda
// and its huge pot, three potted plants, the glazed ceramic pot, a bag of soil, the water tank, the tap and the smiling
// pot of the sign, with origins at the floor in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';
import { pearBody, eyes } from './pear.js';

const terracotta = () => mat('pot_terracotta', 0xc8683a);
const soil = () => mat('pot_soil', 0x4a3424);
const leaf = () => mat('plant_leaf', 0x3f9a3a);

// A pop-up sprinkler, 0.3 m across and 0.45 m tall: a green base in the ground, the riser and the head with its arm
// and nozzle pointing out along +X.
export function buildSprinkler() {
	const b = new Builder('nursery_sprinkler');
	const green = mat('sprinkler_green', 0x2f7a3a), grey = mat('sprinkler_grey', 0x9aa0a8, { metalness: 0.6, roughness: 0.4 });
	const yellow = mat('sprinkler_yellow', 0xf2c84b);
	b.add('base', green, new THREE.CylinderGeometry(0.15, 0.17, 0.08, 14), { pos: V(0, 0.04, 0) });
	b.add('riser', grey, new THREE.CylinderGeometry(0.03, 0.03, 0.3, 8), { pos: V(0, 0.23, 0) });
	b.add('head', yellow, new THREE.CylinderGeometry(0.06, 0.06, 0.08, 10), { pos: V(0, 0.4, 0) });
	b.add('arm', grey, new THREE.CylinderGeometry(0.02, 0.02, 0.26, 6), { pos: V(0.13, 0.42, 0), rot: [0, 0, Math.PI / 2] });
	b.add('nozzle', yellow, new THREE.CylinderGeometry(0.025, 0.04, 0.06, 8), { pos: V(0.27, 0.42, 0), rot: [0, 0, -Math.PI / 2] });
	return b.build();
}

// The Dentuda's pot, 2.4 m across and 0.9 m tall: a fat terracotta pot with a rim and a band of painted daisies,
// full of soil up to 0.8 m.
export function buildDentudaPot() {
	const b = new Builder('dentuda_pot');
	const white = mat('daisy_white', 0xf6f2e8), yellow = mat('daisy_yellow', 0xf2c84b);
	b.add('pot', terracotta(), new THREE.CylinderGeometry(1.1, 0.85, 0.82, 20), { pos: V(0, 0.41, 0) });
	b.add('rim', terracotta(), new THREE.TorusGeometry(1.1, 0.09, 8, 24), { pos: V(0, 0.84, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('soil', soil(), new THREE.CylinderGeometry(1.05, 1.05, 0.04, 20), { pos: V(0, 0.8, 0) });
	for (let i = 0; i < 8; i++) {
		const a = (i / 8) * Math.PI * 2, r = 1.0;
		b.add('daisy', white, new THREE.CylinderGeometry(0.11, 0.11, 0.02, 10), { pos: V(Math.sin(a) * r, 0.45, Math.cos(a) * r), rot: [Math.PI / 2 - 0.25, a, 0] });
		b.add('daisy_eye', yellow, new THREE.CylinderGeometry(0.04, 0.04, 0.03, 8), { pos: V(Math.sin(a) * (r + 0.01), 0.45, Math.cos(a) * (r + 0.01)), rot: [Math.PI / 2 - 0.25, a, 0] });
	}
	return b.build();
}

// The Dentuda, a giant carnivorous plant 2.3 m tall from its base (it stands on the pot's soil): a thick stem, four
// big leaves at the foot and the head, two pink jaws with white teeth, open toward +Z, and two little eyes on top.
export function buildDentuda() {
	const b = new Builder('dentuda');
	const stem = mat('dentuda_stem', 0x3c8a34), pink = mat('dentuda_pink', 0xe0557a), teeth = mat('dentuda_teeth', 0xfaf6ea);
	const dark = mat('dentuda_dark', 0x6a1830), white = mat('dentuda_eye', 0xffffff), black = mat('dentuda_pupil', 0x1a1a1a);
	b.add('stem', stem, new THREE.CylinderGeometry(0.12, 0.2, 1.6, 10), { pos: V(0, 0.8, 0), rot: [0.12, 0, 0] });
	for (let i = 0; i < 4; i++) {
		const a = (i / 4) * Math.PI * 2 + 0.4;
		b.add('leaf', leaf(), ellipsoid(0.55, 0.06, 0.22), { pos: V(Math.sin(a) * 0.5, 0.12, Math.cos(a) * 0.5), rot: [0, a + Math.PI / 2, 0.3] });
	}
	b.add('throat', dark, ellipsoid(0.42, 0.3, 0.42), { pos: V(0, 1.8, 0.12) });
	b.add('jaw_top', pink, ellipsoid(0.55, 0.2, 0.55), { pos: V(0, 2.02, 0.22), rot: [-0.45, 0, 0] });
	b.add('jaw_bottom', pink, ellipsoid(0.55, 0.18, 0.55), { pos: V(0, 1.6, 0.22), rot: [0.35, 0, 0] });
	for (let i = 0; i < 7; i++) {
		const a = -1.1 + i * (2.2 / 6), x = Math.sin(a) * 0.48, z = 0.22 + Math.cos(a) * 0.48;
		b.add('tooth_top', teeth, new THREE.ConeGeometry(0.05, 0.16, 6), { pos: V(x, 1.84 + Math.cos(a) * 0.12, z), rot: [Math.PI, 0, 0] });
		b.add('tooth_bottom', teeth, new THREE.ConeGeometry(0.045, 0.14, 6), { pos: V(x, 1.72 + Math.cos(a) * 0.1, z) });
	}
	for (const x of [-0.18, 0.18]) {
		b.add('eye', white, new THREE.SphereGeometry(0.1, 10, 8), { pos: V(x, 2.26, 0.1) });
		b.add('pupil', black, new THREE.SphereGeometry(0.045, 8, 6), { pos: V(x, 2.28, 0.19) });
	}
	return b.build();
}

// A potted fern, 0.5 m across and 0.7 m tall: a terracotta pot with a fan of long leaves.
export function buildPottedFern() {
	const b = new Builder('potted_plant_0');
	b.add('pot', terracotta(), new THREE.CylinderGeometry(0.2, 0.15, 0.3, 12), { pos: V(0, 0.15, 0) });
	b.add('soil', soil(), new THREE.CylinderGeometry(0.18, 0.18, 0.02, 12), { pos: V(0, 0.29, 0) });
	for (let i = 0; i < 7; i++) {
		const a = (i / 7) * Math.PI * 2;
		b.add('frond', leaf(), ellipsoid(0.26, 0.03, 0.07), { pos: V(Math.sin(a) * 0.14, 0.45, Math.cos(a) * 0.14), rot: [0, a + Math.PI / 2, 0.7] });
	}
	return b.build();
}

// A potted daisy bush, 0.5 m across and 0.6 m tall: a green ball dotted with pink and yellow flowers.
export function buildPottedFlowers() {
	const b = new Builder('potted_plant_1');
	const pink = mat('flower_pink', 0xf07aa8), yellow = mat('flower_yellow', 0xf2d040);
	b.add('pot', terracotta(), new THREE.CylinderGeometry(0.2, 0.15, 0.3, 12), { pos: V(0, 0.15, 0) });
	b.add('bush', leaf(), new THREE.SphereGeometry(0.24, 12, 8), { pos: V(0, 0.46, 0) });
	for (let i = 0; i < 10; i++) {
		const a = i * 2.4, h = 0.4 + (i % 3) * 0.08;
		b.add('flower', i % 2 ? pink : yellow, new THREE.SphereGeometry(0.05, 8, 6), { pos: V(Math.sin(a) * 0.22, h, Math.cos(a) * 0.22) });
	}
	return b.build();
}

// A potted cactus, 0.4 m across and 0.75 m tall: a ribbed column with two arms and a red flower on top.
export function buildPottedCactus() {
	const b = new Builder('potted_plant_2');
	const cactus = mat('cactus', 0x4f9a50), red = mat('cactus_flower', 0xe04040);
	b.add('pot', terracotta(), new THREE.CylinderGeometry(0.17, 0.13, 0.26, 12), { pos: V(0, 0.13, 0) });
	b.add('body', cactus, new THREE.CylinderGeometry(0.09, 0.1, 0.45, 8), { pos: V(0, 0.48, 0) });
	b.add('top', cactus, new THREE.SphereGeometry(0.09, 8, 6), { pos: V(0, 0.7, 0) });
	b.add('arm_l', cactus, new THREE.CylinderGeometry(0.045, 0.045, 0.16, 6), { pos: V(-0.12, 0.5, 0) });
	b.add('arm_r', cactus, new THREE.CylinderGeometry(0.045, 0.045, 0.12, 6), { pos: V(0.12, 0.56, 0) });
	b.add('flower', red, new THREE.SphereGeometry(0.04, 8, 6), { pos: V(0, 0.78, 0) });
	return b.build();
}

// A glazed ceramic pot for sale, 0.36 m across and 0.4 m tall: blue with a white band and a little smiling face.
export function buildCeramicPot() {
	const b = new Builder('ceramic_pot');
	const blue = mat('ceramic_blue', 0x3a6fd0, { roughness: 0.25 }), white = mat('ceramic_white', 0xf6f4ee, { roughness: 0.25 });
	const dark = mat('ceramic_dark', 0x1a2240);
	b.add('pot', blue, new THREE.CylinderGeometry(0.18, 0.12, 0.36, 14), { pos: V(0, 0.18, 0) });
	b.add('rim', blue, new THREE.TorusGeometry(0.18, 0.025, 6, 16), { pos: V(0, 0.36, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('band', white, new THREE.CylinderGeometry(0.165, 0.155, 0.05, 14), { pos: V(0, 0.27, 0) });
	for (const x of [-0.05, 0.05]) {
		b.add('eye', dark, new THREE.SphereGeometry(0.015, 6, 4), { pos: V(x, 0.2, 0.15) });
	}
	b.add('smile', dark, new THREE.TorusGeometry(0.04, 0.008, 4, 10, Math.PI), { pos: V(0, 0.16, 0.148), rot: [0, 0, Math.PI] });
	return b.build();
}

// A bag of soil lying flat, 0.4 x 0.14 x 0.62 m: a brown sack with a green label and a leaf.
export function buildSoilBag() {
	const b = new Builder('soil_bag');
	const sack = mat('soil_sack', 0x8a5a34), label = mat('soil_label', 0x58b04a);
	b.add('sack', sack, new THREE.BoxGeometry(0.4, 0.12, 0.6), { pos: V(0, 0.06, 0) });
	b.add('pillow', sack, ellipsoid(0.19, 0.03, 0.28), { pos: V(0, 0.12, 0) });
	b.add('label', label, new THREE.BoxGeometry(0.24, 0.01, 0.2), { pos: V(0, 0.145, 0.05) });
	b.add('leaf', leaf(), ellipsoid(0.06, 0.008, 0.03), { pos: V(0, 0.152, 0.05), rot: [0, 0.6, 0] });
	return b.build();
}

// The water tank on its stand, 1.4 m across and 2.6 m tall: four steel legs 1.2 m high and the black tank with its lid
// and the pipe going down. The space under it is open.
export function buildWaterTank() {
	const b = new Builder('water_tank');
	const black = mat('tank_black', 0x26282c), steel = mat('tank_steel', 0x9aa0a8, { metalness: 0.6, roughness: 0.4 });
	for (const x of [-0.55, 0.55]) {
		for (const z of [-0.55, 0.55]) {
			b.add('leg', steel, new THREE.BoxGeometry(0.08, 1.2, 0.08), { pos: V(x, 0.6, z) });
		}
	}
	b.add('deck', steel, new THREE.BoxGeometry(1.3, 0.06, 1.3), { pos: V(0, 1.23, 0) });
	b.add('tank', black, new THREE.CylinderGeometry(0.65, 0.65, 1.2, 18), { pos: V(0, 1.86, 0) });
	b.add('lid', black, new THREE.CylinderGeometry(0.25, 0.25, 0.1, 12), { pos: V(0, 2.51, 0) });
	b.add('pipe', steel, new THREE.CylinderGeometry(0.04, 0.04, 1.2, 8), { pos: V(0.6, 0.6, 0.6) });
	return b.build();
}

// The tap on its post, 0.2 x 0.9 x 0.3 m: a wooden post, the brass tap pointing +Z and its red handle.
export function buildNurseryTap() {
	const b = new Builder('nursery_tap');
	const wood = mat('tap_post', 0x8a6040), brass = mat('tap_brass', 0xd8b048, { metalness: 0.7, roughness: 0.3 });
	b.add('post', wood, new THREE.BoxGeometry(0.12, 0.9, 0.12), { pos: V(0, 0.45, 0) });
	b.add('pipe', brass, new THREE.CylinderGeometry(0.025, 0.025, 0.14, 8), { pos: V(0, 0.7, 0.12), rot: [Math.PI / 2, 0, 0] });
	b.add('spout', brass, new THREE.CylinderGeometry(0.022, 0.022, 0.1, 8), { pos: V(0, 0.66, 0.19) });
	b.add('handle', mat('tap_handle', 0xd03030), new THREE.CylinderGeometry(0.05, 0.05, 0.02, 4), { pos: V(0, 0.77, 0.14) });
	return b.build();
}

// The sign's smiling pot, 1.0 m across and 1.1 m tall: a big terracotta pot with eyes and a smile, and a flower
// sticking out of it.
export function buildSmilingPot() {
	const b = new Builder('smiling_pot');
	const dark = mat('smile_dark', 0x2a1a12), white = mat('smile_white', 0xffffff), pink = mat('flower_pink', 0xf07aa8);
	b.add('pot', terracotta(), new THREE.CylinderGeometry(0.5, 0.38, 0.7, 16), { pos: V(0, 0.35, 0) });
	b.add('rim', terracotta(), new THREE.TorusGeometry(0.5, 0.05, 6, 20), { pos: V(0, 0.7, 0), rot: [Math.PI / 2, 0, 0] });
	for (const x of [-0.15, 0.15]) {
		b.add('eye', white, new THREE.SphereGeometry(0.08, 8, 6), { pos: V(x, 0.45, 0.42) });
		b.add('pupil', dark, new THREE.SphereGeometry(0.04, 8, 6), { pos: V(x, 0.46, 0.49) });
	}
	b.add('smile', dark, new THREE.TorusGeometry(0.14, 0.02, 4, 12, Math.PI), { pos: V(0, 0.28, 0.44), rot: [0, 0, Math.PI] });
	b.add('stalk', leaf(), new THREE.CylinderGeometry(0.02, 0.02, 0.35, 6), { pos: V(0, 0.85, 0) });
	b.add('flower', pink, new THREE.SphereGeometry(0.1, 10, 8), { pos: V(0, 1.05, 0) });
	return b.build();
}

// Doña Hortensia, the owner (decision 72, short and round): a green apron full of pockets over a flowery dress, garden
// gloves, a huge straw hat and the pruning shears in her right hand. Faces +Z, about 1.6 m to the hat's crown.
export function buildDonaHortensia() {
	const b = new Builder('npc_dona_hortensia');
	const dress = mat('hortensia_dress', 0xd88ac0), apron = mat('hortensia_apron', 0x3f8a46);
	const skin = mat('hortensia_skin', 0xf0c4a0), straw = mat('hortensia_straw', 0xe8cf7a);
	const gloves = mat('hortensia_gloves', 0xf2a03a), band = mat('hortensia_band', 0xd8302a);
	pearBody(b, skin, { shirt: dress, pants: dress, shoes: mat('hortensia_boots', 0x2a5a30), belted: false });
	b.add('body', apron, new THREE.BoxGeometry(0.6, 0.62, 0.04), { pos: V(0, 0.55, 0.43), rot: [-0.12, 0, 0] });
	for (let i = 0; i < 3; i++) {
		b.add('body', apron, new THREE.BoxGeometry(0.16, 0.12, 0.05), { pos: V(-0.19 + i * 0.19, 0.42, 0.47), rot: [-0.12, 0, 0] });
	}
	for (const s of [-1, 1]) {
		b.add('arms', gloves, ellipsoid(0.085, 0.085, 0.085, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
	}
	eyes(b, 1.33, 0.19, 0.08, 0.045);
	b.add('face', mat('hortensia_cheeks', 0xf08a8a), ellipsoid(0.04, 0.03, 0.01, 6, 4), { pos: V(-0.12, 1.25, 0.19) });
	b.add('face', mat('hortensia_cheeks', 0xf08a8a), ellipsoid(0.04, 0.03, 0.01, 6, 4), { pos: V(0.12, 1.25, 0.19) });
	b.add('hat', straw, new THREE.CylinderGeometry(0.52, 0.55, 0.03, 18), { pos: V(0, 1.47, 0.02) });
	b.add('hat', straw, new THREE.CylinderGeometry(0.17, 0.2, 0.16, 12), { pos: V(0, 1.56, 0.02) });
	b.add('hat', band, new THREE.CylinderGeometry(0.205, 0.205, 0.04, 12), { pos: V(0, 1.5, 0.02) });
	const steel = mat('hortensia_shears', 0xb8bec6, { metalness: 0.7, roughness: 0.3 });
	b.add('tool', steel, new THREE.BoxGeometry(0.03, 0.02, 0.22), { pos: V(0.5, 0.62, 0.24), rot: [0, 0.15, 0] });
	b.add('tool', steel, new THREE.BoxGeometry(0.03, 0.02, 0.22), { pos: V(0.52, 0.62, 0.24), rot: [0, -0.15, 0] });
	b.add('tool', band, new THREE.BoxGeometry(0.05, 0.04, 0.1), { pos: V(0.5, 0.62, 0.08) });
	return b.build();
}

// Brotecito, the watering kid: a small pear in green overalls with a cap and a little sprout growing out of it. Faces
// +Z, about 1.6 m before the game scales him down.
export function buildBrotecito() {
	const b = new Builder('npc_brotecito');
	const overalls = mat('brotecito_overalls', 0x4caf50), shirt = mat('brotecito_shirt', 0xf2d040);
	const skin = mat('brotecito_skin', 0xf0c4a0), cap = mat('brotecito_cap', 0x2e7d32);
	pearBody(b, skin, { shirt, pants: overalls, shoes: mat('brotecito_boots', 0xf2c84b), belted: false });
	b.add('body', overalls, new THREE.BoxGeometry(0.36, 0.3, 0.04), { pos: V(0, 0.68, 0.36), rot: [-0.25, 0, 0] });
	eyes(b, 1.33, 0.19, 0.08, 0.055);
	b.add('face', mat('brotecito_freckles', 0xc8783a), ellipsoid(0.03, 0.02, 0.01, 6, 4), { pos: V(-0.1, 1.24, 0.19) });
	b.add('face', mat('brotecito_freckles', 0xc8783a), ellipsoid(0.03, 0.02, 0.01, 6, 4), { pos: V(0.1, 1.24, 0.19) });
	b.add('hat', cap, new THREE.CylinderGeometry(0.19, 0.2, 0.12, 12), { pos: V(0, 1.47, 0.02) });
	b.add('hat', cap, new THREE.CylinderGeometry(0.15, 0.15, 0.02, 12, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 1.42, 0.12) });
	b.add('hat', mat('brotecito_stem', 0x3f9a3a), new THREE.CylinderGeometry(0.015, 0.015, 0.16, 6), { pos: V(0, 1.6, 0.02) });
	for (const s of [-1, 1]) {
		b.add('hat', leaf(), ellipsoid(0.08, 0.015, 0.04), { pos: V(s * 0.07, 1.68, 0.02), rot: [0, 0, s * 0.4] });
	}
	return b.build();
}

// The watering can, 0.55 m long and 0.35 m tall: a green tank, a handle over it and a long spout toward +X with its
// rose. Origin at the floor in the middle of the tank.
export function buildWateringCan() {
	const b = new Builder('watering_can');
	const green = mat('can_green', 0x3fa04a, { metalness: 0.4, roughness: 0.4 }), grey = mat('can_rose', 0xb8bec6, { metalness: 0.6 });
	b.add('tank', green, new THREE.CylinderGeometry(0.13, 0.14, 0.26, 14), { pos: V(0, 0.13, 0) });
	b.add('handle', green, new THREE.TorusGeometry(0.11, 0.02, 6, 12, Math.PI), { pos: V(0, 0.26, 0), rot: [0, 0, 0] });
	b.add('spout', green, new THREE.CylinderGeometry(0.02, 0.03, 0.34, 8), { pos: V(0.24, 0.2, 0), rot: [0, 0, -1.0] });
	b.add('rose', grey, new THREE.CylinderGeometry(0.05, 0.03, 0.04, 10), { pos: V(0.39, 0.3, 0), rot: [0, 0, -1.0] });
	return b.build();
}

// The botanic garden's blue orchid (0.35 m across, 0.6 m tall): a white ceramic pot with a curved stake and a spray of
// big blue flowers.
export function buildNurseryOrchid() {
	const b = new Builder('nursery_orchid');
	const pot = mat('orchid_pot', 0xf4f2ec), blue = mat('orchid_blue', 0x3a5ae8, { emissive: 0x0a1040 });
	const eye = mat('orchid_eye', 0xf2e060);
	b.add('pot', pot, new THREE.CylinderGeometry(0.13, 0.1, 0.18, 14), { pos: V(0, 0.09, 0) });
	b.add('soil', soil(), new THREE.CylinderGeometry(0.12, 0.12, 0.02, 12), { pos: V(0, 0.17, 0) });
	for (const a of [0.3, 2.4, 4.4]) {
		b.add('leaf', leaf(), ellipsoid(0.15, 0.02, 0.06), { pos: V(Math.sin(a) * 0.1, 0.2, Math.cos(a) * 0.1), rot: [0, a + Math.PI / 2, 0.2] });
	}
	b.add('stem', mat('orchid_stem', 0x5a7a3a), new THREE.CylinderGeometry(0.008, 0.01, 0.4, 6), { pos: V(0, 0.38, 0) });
	for (let i = 0; i < 5; i++) {
		const y = 0.42 + i * 0.04, x = 0.03 + i * 0.03;
		b.add('flower', blue, ellipsoid(0.06, 0.05, 0.015, 8, 4), { pos: V(x, y, 0.02) });
		b.add('flower', eye, ellipsoid(0.015, 0.015, 0.01, 6, 4), { pos: V(x, y, 0.035) });
	}
	return b.build();
}

// The botanic garden's catalog (0.24 x 0.3 m): a green cover with a white flower and the gold title band.
export function buildBotanicCatalog() {
	const b = new Builder('botanic_catalog');
	b.add('cover', mat('catalog_cover', 0x2f7a4a), new THREE.BoxGeometry(0.24, 0.03, 0.3), { pos: V(0, 0.015, 0) });
	b.add('pages', mat('catalog_pages', 0xf4f0e2), new THREE.BoxGeometry(0.22, 0.026, 0.29), { pos: V(0.012, 0.015, 0) });
	b.add('flower', mat('catalog_flower', 0xf6f2e8), new THREE.CylinderGeometry(0.05, 0.05, 0.004, 8), { pos: V(0, 0.032, 0.03) });
	b.add('band', mat('catalog_gold', 0xf2c84b), new THREE.BoxGeometry(0.2, 0.004, 0.03), { pos: V(0, 0.032, -0.09) });
	return b.build();
}

// Doña Hortensia's other pruning shears (0.25 m long): two steel blades and red handles, lying open.
export function buildNurseryShears() {
	const b = new Builder('nursery_shears');
	const steel = mat('shears_steel', 0xb8bec6, { metalness: 0.7, roughness: 0.3 }), red = mat('shears_red', 0xd8302a);
	for (const s of [-1, 1]) {
		b.add('blade', steel, new THREE.BoxGeometry(0.03, 0.015, 0.12), { pos: V(s * 0.012, 0.012, 0.07), rot: [0, s * 0.15, 0] });
		b.add('handle', red, new THREE.BoxGeometry(0.03, 0.025, 0.12), { pos: V(s * 0.03, 0.013, -0.05), rot: [0, -s * 0.3, 0] });
	}
	b.add('pin', steel, new THREE.CylinderGeometry(0.012, 0.012, 0.03, 8), { pos: V(0, 0.015, 0.01) });
	return b.build();
}

// The mayor's golden garden gnome (0.8 m tall, solid gold): a fat gnome, all gold but the white beard, with a red hat.
export function buildGoldGnome() {
	const b = new Builder('gold_gnome');
	const gold = mat('gnome_gold', 0xf2c84b, { metalness: 0.8, roughness: 0.25, emissive: 0x3a2a05 });
	b.add('body', gold, ellipsoid(0.22, 0.25, 0.2, 10, 6), { pos: V(0, 0.25, 0) });
	b.add('belt', mat('gold_gnome_belt', 0x8a5a14, { metalness: 0.6 }), new THREE.CylinderGeometry(0.21, 0.21, 0.04, 10), { pos: V(0, 0.28, 0) });
	b.add('head', gold, ellipsoid(0.13, 0.13, 0.13, 10, 6), { pos: V(0, 0.53, 0.02) });
	b.add('nose', gold, ellipsoid(0.04, 0.04, 0.04, 6, 4), { pos: V(0, 0.53, 0.15) });
	b.add('beard', mat('gold_gnome_beard', 0xf6f2ea), new THREE.ConeGeometry(0.12, 0.24, 8), { pos: V(0, 0.4, 0.12), rot: [Math.PI, 0, 0] });
	b.add('hat', mat('gold_gnome_hat', 0xd23a3a), new THREE.ConeGeometry(0.14, 0.32, 10), { pos: V(0, 0.76, 0), rot: [-0.15, 0, 0] });
	b.add('boots', gold, new THREE.BoxGeometry(0.34, 0.06, 0.16), { pos: V(0, 0.03, 0.05) });
	return b.build();
}

// The photo of the mayor's garden (0.15 x 0.1 m): a white-framed print of a lawn with a golden dot in the middle.
export function buildMayorPhoto() {
	const b = new Builder('mayor_photo');
	b.add('frame', mat('photo_white', 0xf6f4ee), new THREE.BoxGeometry(0.15, 0.006, 0.1), { pos: V(0, 0.003, 0) });
	b.add('lawn', mat('photo_lawn', 0x5ab04a), new THREE.BoxGeometry(0.13, 0.002, 0.08), { pos: V(0, 0.007, 0) });
	b.add('gnome', mat('photo_gold', 0xf2c84b), new THREE.BoxGeometry(0.02, 0.002, 0.03), { pos: V(0, 0.009, 0) });
	return b.build();
}

// The tin of gnome paint (0.16 m across, 0.16 m tall): a tin with a green label and green paint dripping down.
export function buildGnomePaint() {
	const b = new Builder('gnome_paint');
	const tin = mat('paint_tin', 0xb8bec6, { metalness: 0.6, roughness: 0.4 }), green = mat('paint_green', 0x3a5ab0);
	b.add('tin', tin, new THREE.CylinderGeometry(0.08, 0.08, 0.16, 14), { pos: V(0, 0.08, 0) });
	b.add('label', green, new THREE.CylinderGeometry(0.082, 0.082, 0.08, 14), { pos: V(0, 0.08, 0) });
	b.add('lid', green, new THREE.CylinderGeometry(0.075, 0.075, 0.005, 14), { pos: V(0, 0.162, 0) });
	b.add('drip', green, new THREE.BoxGeometry(0.02, 0.06, 0.005), { pos: V(0.03, 0.13, 0.081) });
	return b.build();
}

// The stadium's roll of grass (1.0 m long, 0.45 m across): a fat roll of turf, green outside, with the brown soil
// spiral at the ends and a white line painted across it.
export function buildGrassRoll() {
	const b = new Builder('grass_roll');
	const turf = mat('roll_turf', 0x4caf50), dirt = mat('roll_dirt', 0x6a4424), white = mat('roll_line', 0xf6f4ee);
	b.add('roll', turf, new THREE.CylinderGeometry(0.22, 0.22, 1.0, 16), { pos: V(0, 0.22, 0), rot: [0, 0, Math.PI / 2] });
	for (const x of [-0.505, 0.505]) {
		b.add('end', dirt, new THREE.CylinderGeometry(0.2, 0.2, 0.01, 16), { pos: V(x, 0.22, 0), rot: [0, 0, Math.PI / 2] });
		b.add('spiral', turf, new THREE.TorusGeometry(0.11, 0.015, 4, 16), { pos: V(x * 1.01, 0.22, 0), rot: [0, Math.PI / 2, 0] });
	}
	b.add('line', white, new THREE.CylinderGeometry(0.222, 0.222, 0.06, 16), { pos: V(0.2, 0.22, 0), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// A stadium ticket (0.15 x 0.07 m): a pink stub with a black stripe and a torn edge.
export function buildStadiumTicket() {
	const b = new Builder('stadium_ticket');
	b.add('paper', mat('ticket_pink', 0xf07aa8), new THREE.BoxGeometry(0.15, 0.003, 0.07), { pos: V(0, 0.0015, 0) });
	b.add('stripe', mat('ticket_ink', 0x1a1a1a), new THREE.BoxGeometry(0.15, 0.001, 0.012), { pos: V(0, 0.0035, 0.015) });
	b.add('stub', mat('ticket_white', 0xf6f4ee), new THREE.BoxGeometry(0.03, 0.001, 0.06), { pos: V(-0.055, 0.0035, 0) });
	return b.build();
}

// A push reel mower (0.5 m wide, 1.0 m tall with its handle): a green reel between two wheels and a long T handle.
export function buildHandMower() {
	const b = new Builder('hand_mower');
	const green = mat('mower_green', 0x2f8a3a), steel = mat('mower_steel', 0xb8bec6, { metalness: 0.7 }), black = mat('mower_black', 0x1a1a1a);
	b.add('reel', green, new THREE.CylinderGeometry(0.08, 0.08, 0.4, 10), { pos: V(0, 0.1, 0), rot: [0, 0, Math.PI / 2] });
	for (const x of [-0.23, 0.23]) {
		b.add('wheel', black, new THREE.CylinderGeometry(0.1, 0.1, 0.04, 12), { pos: V(x, 0.1, 0), rot: [0, 0, Math.PI / 2] });
		b.add('arm', steel, new THREE.CylinderGeometry(0.012, 0.012, 0.9, 6), { pos: V(x * 0.6, 0.5, -0.32), rot: [-0.8, 0, 0] });
	}
	b.add('grip', black, new THREE.CylinderGeometry(0.02, 0.02, 0.32, 8), { pos: V(0, 0.86, -0.64), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// The pot with diamonds buried in it (0.4 m across, 0.5 m tall): a terracotta pot, a small fern on top and three
// diamonds peeking out of the soil.
export function buildDiamondPot() {
	const b = new Builder('diamond_pot');
	const gem = mat('diamond_gem', 0xcff4ff, { metalness: 0.2, roughness: 0.05, emissive: 0x204050 });
	b.add('pot', terracotta(), new THREE.CylinderGeometry(0.2, 0.15, 0.32, 14), { pos: V(0, 0.16, 0) });
	b.add('soil', soil(), new THREE.CylinderGeometry(0.19, 0.19, 0.02, 14), { pos: V(0, 0.31, 0) });
	for (let i = 0; i < 5; i++) {
		const a = (i / 5) * Math.PI * 2;
		b.add('frond', leaf(), ellipsoid(0.16, 0.02, 0.05), { pos: V(Math.sin(a) * 0.08, 0.42, Math.cos(a) * 0.08), rot: [0, a + Math.PI / 2, 0.6] });
	}
	for (const [x, z] of [[0.1, 0.05], [-0.08, 0.1], [0.02, -0.12]]) {
		b.add('gem', gem, new THREE.OctahedronGeometry(0.035), { pos: V(x, 0.33, z) });
	}
	return b.build();
}

// A jeweler's loupe (0.05 m across): a small black eyepiece with its glass.
export function buildJewelerLoupe() {
	const b = new Builder('jeweler_loupe');
	b.add('body', mat('loupe_black', 0x1a1a1a), new THREE.CylinderGeometry(0.025, 0.02, 0.04, 12), { pos: V(0, 0.02, 0) });
	b.add('glass', mat('loupe_glass', 0xbfe8ff, { roughness: 0.05, emissive: 0x102030 }), new THREE.CylinderGeometry(0.02, 0.02, 0.005, 12), { pos: V(0, 0.042, 0) });
	return b.build();
}

// An empty soil bag (0.45 x 0.6 m): the soil sack, flat and crumpled, with its green label.
export function buildEmptySoilBag() {
	const b = new Builder('empty_soil_bag');
	const sack = mat('soil_sack', 0x8a5a34);
	b.add('sack', sack, new THREE.BoxGeometry(0.42, 0.02, 0.6), { pos: V(0, 0.01, 0), rot: [0, 0.1, 0.03] });
	b.add('fold', sack, new THREE.BoxGeometry(0.42, 0.02, 0.15), { pos: V(0, 0.03, -0.22), rot: [0.3, 0.1, 0] });
	b.add('label', mat('soil_label', 0x58b04a), new THREE.BoxGeometry(0.24, 0.005, 0.2), { pos: V(0, 0.023, 0.05), rot: [0, 0.1, 0] });
	return b.build();
}

// The box of the champion tomato's seeds (0.25 x 0.08 x 0.18 m): a red box with a big tomato drawn on the lid.
export function buildSeedBox() {
	const b = new Builder('seed_box');
	b.add('box', mat('seedbox_red', 0xd23a3a), new THREE.BoxGeometry(0.25, 0.08, 0.18), { pos: V(0, 0.04, 0) });
	b.add('lid', mat('seedbox_white', 0xf6f4ee), new THREE.BoxGeometry(0.2, 0.004, 0.13), { pos: V(0, 0.082, 0) });
	b.add('tomato', mat('seedbox_tomato', 0xe8402a), new THREE.CylinderGeometry(0.04, 0.04, 0.004, 12), { pos: V(0, 0.086, 0) });
	b.add('leaf', leaf(), ellipsoid(0.02, 0.003, 0.01), { pos: V(0, 0.089, -0.035) });
	return b.build();
}

// The first prize ribbon (0.12 x 0.25 m): a blue rosette with two tails and a gold center.
export function buildPrizeRibbon() {
	const b = new Builder('prize_ribbon');
	const blue = mat('ribbon_blue', 0x2f5ae8);
	b.add('rosette', blue, new THREE.CylinderGeometry(0.06, 0.06, 0.01, 12), { pos: V(0, 0.005, 0) });
	b.add('center', mat('ribbon_gold', 0xf2c84b), new THREE.CylinderGeometry(0.03, 0.03, 0.012, 12), { pos: V(0, 0.008, 0) });
	for (const s of [-1, 1]) {
		b.add('tail', blue, new THREE.BoxGeometry(0.035, 0.004, 0.13), { pos: V(s * 0.025, 0.002, 0.1), rot: [0, s * 0.25, 0] });
	}
	return b.build();
}

// The jar of "SuperBrote" fertilizer (0.1 m across, 0.16 m tall): a glass jar of bright green powder with a lid.
export function buildSuperbroteJar() {
	const b = new Builder('superbrote_jar');
	b.add('powder', mat('superbrote_green', 0x7cff4a, { emissive: 0x1a4a0a }), new THREE.CylinderGeometry(0.045, 0.045, 0.12, 12), { pos: V(0, 0.065, 0) });
	b.add('lid', mat('superbrote_lid', 0xd23a3a), new THREE.CylinderGeometry(0.05, 0.05, 0.03, 12), { pos: V(0, 0.145, 0) });
	b.add('label', mat('superbrote_label', 0xf2d040), new THREE.CylinderGeometry(0.048, 0.048, 0.05, 12), { pos: V(0, 0.07, 0) });
	return b.build();
}

// A tomato plant with ball-sized tomatoes (0.7 m tall): a pot, a stake and three huge red tomatoes.
export function buildGiantTomatoPlant() {
	const b = new Builder('giant_tomato_plant');
	const red = mat('giant_tomato', 0xe8402a, { roughness: 0.3 });
	b.add('pot', terracotta(), new THREE.CylinderGeometry(0.2, 0.15, 0.3, 12), { pos: V(0, 0.15, 0) });
	b.add('stake', mat('tomato_stake', 0x8a5a34), new THREE.CylinderGeometry(0.012, 0.012, 0.7, 6), { pos: V(0, 0.55, 0) });
	b.add('bush', leaf(), new THREE.SphereGeometry(0.16, 10, 6), { pos: V(0, 0.55, 0) });
	for (const [x, y, z] of [[0.16, 0.55, 0.1], [-0.14, 0.62, 0.08], [0.02, 0.45, -0.18]]) {
		b.add('tomato', red, new THREE.SphereGeometry(0.11, 12, 8), { pos: V(x, y, z) });
	}
	return b.build();
}

// A giant pumpkin (1.0 m across): a ribbed orange ball with a green stalk.
export function buildGiantPumpkin() {
	const b = new Builder('giant_pumpkin');
	const orange = mat('pumpkin_orange', 0xf08a2a);
	for (let i = 0; i < 6; i++) {
		b.add('rib', orange, ellipsoid(0.3, 0.45, 0.5, 10, 8), { pos: V(0, 0.45, 0), rot: [0, (i / 6) * Math.PI, 0] });
	}
	b.add('stalk', mat('pumpkin_stalk', 0x3f7a2a), new THREE.CylinderGeometry(0.04, 0.06, 0.15, 6), { pos: V(0, 0.95, 0) });
	return b.build();
}

export const models = {
	nursery_sprinkler: buildSprinkler, dentuda_pot: buildDentudaPot, dentuda: buildDentuda,
	potted_plant_0: buildPottedFern, potted_plant_1: buildPottedFlowers, potted_plant_2: buildPottedCactus,
	ceramic_pot: buildCeramicPot, soil_bag: buildSoilBag, water_tank: buildWaterTank, nursery_tap: buildNurseryTap,
	smiling_pot: buildSmilingPot, npc_dona_hortensia: buildDonaHortensia,
	npc_brotecito: buildBrotecito, watering_can: buildWateringCan, nursery_orchid: buildNurseryOrchid,
	botanic_catalog: buildBotanicCatalog, nursery_shears: buildNurseryShears, gold_gnome: buildGoldGnome,
	mayor_photo: buildMayorPhoto, gnome_paint: buildGnomePaint, grass_roll: buildGrassRoll,
	stadium_ticket: buildStadiumTicket, hand_mower: buildHandMower, diamond_pot: buildDiamondPot,
	jeweler_loupe: buildJewelerLoupe, empty_soil_bag: buildEmptySoilBag, seed_box: buildSeedBox,
	prize_ribbon: buildPrizeRibbon, superbrote_jar: buildSuperbroteJar, giant_tomato_plant: buildGiantTomatoPlant,
	giant_pumpkin: buildGiantPumpkin,
};

export const views = {
	nursery: {
		items: [
			{ name: 'dentuda_pot', pos: [-2.4, 0, 0] }, { name: 'dentuda', pos: [-2.4, 0.82, 0], rotY: 0.3 },
			{ name: 'water_tank', pos: [0.3, 0, -1.4] }, { name: 'smiling_pot', pos: [1.9, 0, 0.6], rotY: -0.2 },
			{ name: 'potted_plant_0', pos: [-0.4, 0, 1.6] }, { name: 'potted_plant_1', pos: [0.3, 0, 1.8] },
			{ name: 'potted_plant_2', pos: [1.0, 0, 1.9] }, { name: 'ceramic_pot', pos: [2.9, 0, 1.6] },
			{ name: 'soil_bag', pos: [3.2, 0, 0.3], rotY: 0.4 }, { name: 'nursery_tap', pos: [3.4, 0, -0.9] },
			{ name: 'nursery_sprinkler', pos: [-0.2, 0, 0.6] }, { name: 'npc_dona_hortensia', pos: [1.6, 0, 2.6], rotY: -0.2 },
			{ name: 'npc_brotecito', pos: [-1.6, 0, 2.6], rotY: 0.2 }, { name: 'watering_can', pos: [-0.9, 0, 3.1], rotY: 0.5 },
			{ name: 'nursery_orchid', pos: [-0.2, 0, 3.4] }, { name: 'botanic_catalog', pos: [0.4, 0, 3.6], rotY: 0.3 },
			{ name: 'nursery_shears', pos: [0.9, 0, 3.6], rotY: -0.4 },
			{ name: 'gold_gnome', pos: [-2.6, 0, 3.2] }, { name: 'mayor_photo', pos: [-2.0, 0, 3.7] },
			{ name: 'gnome_paint', pos: [-1.6, 0, 3.6] }, { name: 'grass_roll', pos: [2.6, 0, 2.8], rotY: 0.4 },
			{ name: 'stadium_ticket', pos: [2.2, 0, 3.8] }, { name: 'hand_mower', pos: [3.6, 0, 2.2], rotY: -0.6 },
			{ name: 'diamond_pot', pos: [-3.2, 0, 1.8] }, { name: 'jeweler_loupe', pos: [-2.9, 0, 2.4] },
			{ name: 'empty_soil_bag', pos: [-3.6, 0, 2.6], rotY: 0.3 }, { name: 'seed_box', pos: [4.2, 0, 3.6] },
			{ name: 'prize_ribbon', pos: [4.6, 0, 3.9] }, { name: 'superbrote_jar', pos: [4.9, 0, 3.4] },
			{ name: 'giant_tomato_plant', pos: [4.4, 0, 1.6] }, { name: 'giant_pumpkin', pos: [-4.4, 0, 0.4] },
		],
		cam: { pos: [0, 2.4, 8.0], target: [0.3, 1.0, 0], fov: 45 },
	},
};
