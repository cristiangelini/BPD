// Props of the plant nursery "La Maceta Feliz" (docs/diseno/allanamiento-vivero.md): the yard's sprinkler, the Dentuda
// and its huge pot, three potted plants, the glazed ceramic pot, a bag of soil, the water tank, the tap and the smiling
// pot of the sign, with origins at the floor in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

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

export const models = {
	nursery_sprinkler: buildSprinkler, dentuda_pot: buildDentudaPot, dentuda: buildDentuda,
	potted_plant_0: buildPottedFern, potted_plant_1: buildPottedFlowers, potted_plant_2: buildPottedCactus,
	ceramic_pot: buildCeramicPot, soil_bag: buildSoilBag, water_tank: buildWaterTank, nursery_tap: buildNurseryTap,
	smiling_pot: buildSmilingPot,
};

export const views = {
	nursery: {
		items: [
			{ name: 'dentuda_pot', pos: [-2.4, 0, 0] }, { name: 'dentuda', pos: [-2.4, 0.82, 0], rotY: 0.3 },
			{ name: 'water_tank', pos: [0.3, 0, -1.4] }, { name: 'smiling_pot', pos: [1.9, 0, 0.6], rotY: -0.2 },
			{ name: 'potted_plant_0', pos: [-0.4, 0, 1.6] }, { name: 'potted_plant_1', pos: [0.3, 0, 1.8] },
			{ name: 'potted_plant_2', pos: [1.0, 0, 1.9] }, { name: 'ceramic_pot', pos: [2.9, 0, 1.6] },
			{ name: 'soil_bag', pos: [3.2, 0, 0.3], rotY: 0.4 }, { name: 'nursery_tap', pos: [3.4, 0, -0.9] },
			{ name: 'nursery_sprinkler', pos: [-0.2, 0, 0.6] },
		],
		cam: { pos: [0, 2.4, 8.0], target: [0.3, 1.0, 0], fov: 45 },
	},
};
