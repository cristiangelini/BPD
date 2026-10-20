// Small props of the pet salon "Pelito Feliz" (docs/diseno/peluqueria.md): the fragile shampoo bottles on its shelves
// and the collars in the reception display, with origins at the middle of each piece; and the dogs, with the origin at
// their feet, facing +Z. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

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

// The coats of the salon's dogs: body, ears and tail color, and spots (if any).
const COATS = [
	{ fur: 0xf4efe6, ears: 0xe0d6c4 },
	{ fur: 0x9a6a3a, ears: 0x6a4424 },
	{ fur: 0x2a2420, ears: 0x1a1612 },
	{ fur: 0xd8a848, ears: 0xb8862c },
	{ fur: 0x8a8e94, ears: 0x5e6268 },
	{ fur: 0xf4efe6, ears: 0x2a2420, spots: 0x2a2420 },
];

// A small dog with a pear body (decision 72): round belly, big head, floppy ears, stubby legs and a tail up.
// About 0.5 m tall and 0.6 m long.
export function buildDog(i) {
	const coat = COATS[i];
	const b = new Builder(`dog_${i}`);
	const fur = mat(`dog_fur_${i}`, coat.fur), ears = mat(`dog_ears_${i}`, coat.ears);
	const black = mat('dog_black', 0x141010), white = mat('dog_eye', 0xffffff), pink = mat('dog_tongue', 0xe8708a);
	b.add('body', fur, ellipsoid(0.17, 0.15, 0.24, 12, 8), { pos: V(0, 0.24, -0.02) });
	b.add('body', fur, ellipsoid(0.13, 0.13, 0.13, 10, 6), { pos: V(0, 0.3, 0.14) });
	for (const [x, z] of [[-0.09, 0.12], [0.09, 0.12], [-0.09, -0.15], [0.09, -0.15]]) {
		b.add('legs', fur, new THREE.CylinderGeometry(0.035, 0.04, 0.14, 6), { pos: V(x, 0.07, z) });
		b.add('legs', ears, ellipsoid(0.045, 0.025, 0.06, 6, 3), { pos: V(x, 0.015, z + 0.015) });
	}
	if (coat.spots) {
		const spots = mat(`dog_spots_${i}`, coat.spots);
		for (const [x, y, z] of [[0.12, 0.3, -0.05], [-0.1, 0.33, -0.12], [0.06, 0.37, 0.05]]) b.add('body', spots, ellipsoid(0.06, 0.05, 0.06, 6, 4), { pos: V(x, y, z) });
	}
	b.add('head', fur, ellipsoid(0.13, 0.12, 0.12, 12, 8), { pos: V(0, 0.44, 0.22) });
	b.add('head', fur, ellipsoid(0.07, 0.055, 0.07, 8, 5), { pos: V(0, 0.4, 0.33) });
	b.add('head', black, ellipsoid(0.028, 0.022, 0.02, 6, 4), { pos: V(0, 0.42, 0.395) });
	b.add('head', pink, ellipsoid(0.025, 0.012, 0.03, 6, 3), { pos: V(0.015, 0.365, 0.37), rot: [0.4, 0, 0] });
	for (const s of [-1, 1]) {
		b.add('head', white, ellipsoid(0.028, 0.03, 0.015, 6, 4), { pos: V(s * 0.05, 0.47, 0.32) });
		b.add('head', black, ellipsoid(0.016, 0.018, 0.01, 6, 4), { pos: V(s * 0.05, 0.47, 0.334) });
		b.add('ears', ears, ellipsoid(0.04, 0.09, 0.025, 6, 4), { pos: V(s * 0.12, 0.42, 0.2), rot: [0, 0, s * 0.35] });
	}
	b.add('tail', ears, new THREE.CylinderGeometry(0.02, 0.03, 0.16, 6), { pos: V(0, 0.36, -0.27), rot: [-0.7, 0, 0] });
	return b.build();
}

export const DOG_COATS = COATS.length;

// Fifí, the poodle the lady waits for: white, with pompoms on the head, the tail and the paws, and a pink bow.
export function buildPoodle() {
	const b = new Builder('dog_poodle');
	const fur = mat('poodle_fur', 0xfaf6f0), skin = mat('poodle_skin', 0xf0d8d0), bow = mat('poodle_bow', 0xf060a0);
	const black = mat('dog_black', 0x141010), white = mat('dog_eye', 0xffffff);
	b.add('body', fur, ellipsoid(0.14, 0.13, 0.2, 10, 8), { pos: V(0, 0.27, -0.02) });
	b.add('body', fur, ellipsoid(0.15, 0.15, 0.13, 10, 8), { pos: V(0, 0.33, 0.12) });
	for (const [x, z] of [[-0.08, 0.1], [0.08, 0.1], [-0.08, -0.13], [0.08, -0.13]]) {
		b.add('legs', skin, new THREE.CylinderGeometry(0.025, 0.025, 0.18, 6), { pos: V(x, 0.11, z) });
		b.add('legs', fur, ellipsoid(0.05, 0.05, 0.05, 6, 4), { pos: V(x, 0.04, z) });
	}
	b.add('head', skin, ellipsoid(0.09, 0.09, 0.1, 10, 6), { pos: V(0, 0.48, 0.22) });
	b.add('head', skin, ellipsoid(0.045, 0.04, 0.07, 8, 5), { pos: V(0, 0.45, 0.31) });
	b.add('head', black, ellipsoid(0.022, 0.018, 0.016, 6, 4), { pos: V(0, 0.46, 0.375) });
	b.add('head', fur, ellipsoid(0.1, 0.09, 0.09, 10, 6), { pos: V(0, 0.58, 0.2) });
	b.add('head', bow, ellipsoid(0.05, 0.03, 0.02, 6, 3), { pos: V(0.04, 0.65, 0.25), rot: [0, 0, 0.3] });
	for (const s of [-1, 1]) {
		b.add('head', white, ellipsoid(0.024, 0.026, 0.012, 6, 4), { pos: V(s * 0.04, 0.5, 0.3) });
		b.add('head', black, ellipsoid(0.014, 0.016, 0.008, 6, 4), { pos: V(s * 0.04, 0.5, 0.31) });
		b.add('ears', fur, ellipsoid(0.05, 0.08, 0.05, 6, 4), { pos: V(s * 0.1, 0.45, 0.2) });
	}
	b.add('tail', skin, new THREE.CylinderGeometry(0.015, 0.02, 0.14, 6), { pos: V(0, 0.38, -0.24), rot: [-0.6, 0, 0] });
	b.add('tail', fur, ellipsoid(0.05, 0.05, 0.05, 6, 4), { pos: V(0, 0.44, -0.29) });
	return b.build();
}

// The rigged contest (peluqueria.md, "El concurso arreglado"): the dog show cup, 0.26 m wide and 0.4 m tall, gold on a
// wooden base with a little dog on top; origin at its middle.
export function buildDogTrophy() {
	const b = new Builder('dog_trophy');
	const gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), wood = mat('trophy_base', 0x5a3a24);
	b.add('base', wood, new THREE.BoxGeometry(0.16, 0.06, 0.16), { pos: V(0, -0.17, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.02, 0.05, 0.08, 10), { pos: V(0, -0.1, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.09, 0.04, 0.16, 12, 1, true), { pos: V(0, 0.02, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.04, 0.04, 0.01, 12), { pos: V(0, -0.055, 0) });
	for (const s of [-1, 1]) b.add('cup', gold, new THREE.TorusGeometry(0.035, 0.008, 4, 10, Math.PI), { pos: V(s * 0.072, 0.03, 0), rot: [0, 0, -s * Math.PI / 2] });
	b.add('cup', gold, new THREE.CylinderGeometry(0.09, 0.09, 0.008, 12), { pos: V(0, 0.1, 0) });
	b.add('dog', gold, ellipsoid(0.03, 0.025, 0.045, 8, 5), { pos: V(0, 0.125, 0) });
	b.add('dog', gold, ellipsoid(0.025, 0.025, 0.025, 8, 5), { pos: V(0, 0.15, 0.045) });
	b.add('plate', mat('trophy_plate', 0xd8d8d0), new THREE.BoxGeometry(0.1, 0.03, 0.004), { pos: V(0, -0.17, 0.082) });
	return b.build();
}

// The judges' score cards, all with a 10 for the same dog: a stack of white cards with a rubber band, 0.15 x 0.02 x 0.1.
export function buildJudgeCards() {
	const b = new Builder('judge_cards');
	const card = mat('card_white', 0xf8f6ee), ten = mat('card_ten', 0x2a5ac8);
	for (let i = 0; i < 4; i++) b.add('cards', card, new THREE.BoxGeometry(0.15, 0.004, 0.1), { pos: V(i * 0.004 - 0.006, -0.008 + i * 0.005, i * 0.003), rot: [0, i * 0.06, 0] });
	b.add('ten', ten, new THREE.BoxGeometry(0.06, 0.002, 0.05), { pos: V(0.004, 0.0125, 0.009), rot: [0, 0.18, 0] });
	b.add('band', mat('rubber_band', 0xd23a4a), new THREE.BoxGeometry(0.008, 0.024, 0.104), { pos: V(-0.03, 0, 0.005) });
	return b.build();
}

// The golden comb the judges got as a present: 0.2 x 0.015 x 0.05 m, lying flat, teeth toward -Z.
export function buildGoldenComb() {
	const b = new Builder('golden_comb');
	const gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	b.add('spine', gold, new THREE.BoxGeometry(0.2, 0.015, 0.018), { pos: V(0, 0, 0.016) });
	for (let i = 0; i < 16; i++) b.add('teeth', gold, new THREE.BoxGeometry(0.006, 0.008, 0.032), { pos: V(-0.09 + i * 0.012, -0.003, -0.009) });
	return b.build();
}

// A framed photo of a happy customer standing on its foot: the champion dog with the cup (contest story clue).
// 0.18 x 0.14 x 0.06 m, origin at its middle, the picture toward +Z.
export function buildContestPhoto() {
	const b = new Builder('contest_photo');
	const frame = mat('photo_frame', 0xf2c860), sky = mat('photo_sky', 0x9ad0f0), fur = mat('dog_fur_1', 0x9a6a3a);
	const gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	b.add('frame', frame, new THREE.BoxGeometry(0.18, 0.14, 0.012));
	b.add('picture', sky, new THREE.BoxGeometry(0.15, 0.11, 0.002), { pos: V(0, 0, 0.007) });
	b.add('picture', fur, ellipsoid(0.03, 0.025, 0.002, 8, 4), { pos: V(-0.025, -0.02, 0.009) });
	b.add('picture', fur, ellipsoid(0.02, 0.02, 0.002, 8, 4), { pos: V(-0.005, 0.01, 0.009) });
	b.add('picture', gold, new THREE.BoxGeometry(0.03, 0.04, 0.002), { pos: V(0.04, -0.015, 0.009) });
	b.add('foot', frame, new THREE.BoxGeometry(0.03, 0.12, 0.008), { pos: V(0, -0.005, -0.025), rot: [-0.45, 0, 0] });
	return b.build();
}

// The diamond necklace (peluqueria.md, "El collar de diamantes"): a silver chain ring with diamonds and a big drop
// stone, lying flat, 0.16 m across; on a dog it goes around the neck. Origin at its middle.
export function buildDiamondNecklace() {
	const b = new Builder('diamond_necklace');
	const silver = mat('silver', 0xd8dce4), diamond = mat('diamond', 0xe8fbff, { emissive: 0x4a6a78 });
	b.add('chain', silver, new THREE.TorusGeometry(0.07, 0.006, 4, 18), { rot: [Math.PI / 2, 0, 0] });
	for (let i = 0; i < 10; i++) {
		const a = (i / 10) * Math.PI * 2;
		b.add('stones', diamond, new THREE.OctahedronGeometry(0.012), { pos: V(Math.cos(a) * 0.07, 0.004, Math.sin(a) * 0.07) });
	}
	b.add('stones', diamond, new THREE.OctahedronGeometry(0.022), { pos: V(0, 0.004, 0.085), rot: [0, 0, 0] });
	return b.build();
}

// Its velvet case: a dark blue box with the lid open, 0.16 x 0.06 x 0.12 m (lid not counted), origin at its middle.
export function buildNecklaceCase() {
	const b = new Builder('necklace_case');
	const velvet = mat('case_velvet', 0x1e2a6a), satin = mat('case_satin', 0xf0e8f0), gold = mat('gold', 0xf2c84b, { emissive: 0x3a2a05 });
	b.add('box', velvet, new THREE.BoxGeometry(0.16, 0.05, 0.12), { pos: V(0, -0.005, 0) });
	b.add('box', satin, new THREE.BoxGeometry(0.14, 0.004, 0.1), { pos: V(0, 0.021, 0) });
	b.add('lid', velvet, new THREE.BoxGeometry(0.16, 0.12, 0.012), { pos: V(0, 0.08, -0.064), rot: [-0.25, 0, 0] });
	b.add('clasp', gold, new THREE.BoxGeometry(0.02, 0.012, 0.004), { pos: V(0, 0.005, 0.061) });
	return b.build();
}

// The millionaire's dog (peluqueria.md, "El perro del millonario"): a greyhound dyed brown, pear body on long thin legs,
// about 0.75 m tall and 0.8 m long, origin at its feet, facing +Z. Duque is the same dog with his white roots showing at
// the paws, the chest and the ear tips; the three decoys are just brown.
export function buildGreyhound(roots) {
	const b = new Builder(roots ? 'dog_greyhound_roots' : 'dog_greyhound');
	const fur = mat('greyhound_dye', 0x7a4a2a), dark = mat('greyhound_dark', 0x4a2a16), white = mat('greyhound_root', 0xf8f6f0);
	const black = mat('dog_black', 0x141010), eye = mat('dog_eye', 0xffffff);
	b.add('body', fur, ellipsoid(0.15, 0.17, 0.3, 12, 8), { pos: V(0, 0.46, -0.04) });
	b.add('body', fur, ellipsoid(0.12, 0.14, 0.12, 10, 6), { pos: V(0, 0.52, 0.2) });
	for (const [x, z] of [[-0.08, 0.17], [0.08, 0.17], [-0.08, -0.22], [0.08, -0.22]]) {
		b.add('legs', fur, new THREE.CylinderGeometry(0.025, 0.03, 0.36, 6), { pos: V(x, 0.18, z) });
		b.add('legs', roots ? white : fur, ellipsoid(0.035, 0.025, 0.05, 6, 3), { pos: V(x, 0.015, z + 0.015) });
	}
	if (roots) b.add('body', white, ellipsoid(0.04, 0.035, 0.02, 8, 4), { pos: V(0, 0.46, 0.31) });
	b.add('head', fur, new THREE.CylinderGeometry(0.045, 0.06, 0.2, 8), { pos: V(0, 0.66, 0.3), rot: [0.5, 0, 0] });
	b.add('head', fur, ellipsoid(0.08, 0.075, 0.1, 10, 6), { pos: V(0, 0.75, 0.37) });
	b.add('head', fur, ellipsoid(0.04, 0.035, 0.1, 8, 5), { pos: V(0, 0.72, 0.48) });
	b.add('head', black, ellipsoid(0.018, 0.015, 0.014, 6, 4), { pos: V(0, 0.73, 0.575) });
	for (const s of [-1, 1]) {
		b.add('head', eye, ellipsoid(0.02, 0.022, 0.012, 6, 4), { pos: V(s * 0.04, 0.78, 0.44) });
		b.add('head', black, ellipsoid(0.011, 0.013, 0.008, 6, 4), { pos: V(s * 0.04, 0.78, 0.452) });
		b.add('ears', dark, ellipsoid(0.03, 0.05, 0.015, 6, 4), { pos: V(s * 0.06, 0.82, 0.32), rot: [0.6, 0, s * 0.5] });
		if (roots) b.add('ears', white, ellipsoid(0.016, 0.02, 0.012, 5, 3), { pos: V(s * 0.065, 0.835, 0.31) });
	}
	b.add('tail', dark, new THREE.CylinderGeometry(0.012, 0.02, 0.3, 6), { pos: V(0, 0.4, -0.42), rot: [-1.0, 0, 0] });
	return b.build();
}

// The brown dye: a 0.08 m wide, 0.2 m tall plastic bottle with a brown label and a dog on it. Origin at its middle.
export function buildDogDye() {
	const b = new Builder('dog_dye');
	b.add('bottle', mat('dye_plastic', 0xf4f0e8), new THREE.CylinderGeometry(0.04, 0.04, 0.16, 8), { pos: V(0, -0.02, 0) });
	b.add('bottle', mat('dye_cap', 0x5a3018), new THREE.CylinderGeometry(0.02, 0.025, 0.04, 8), { pos: V(0, 0.08, 0) });
	b.add('label', mat('greyhound_dye', 0x7a4a2a), new THREE.CylinderGeometry(0.0405, 0.0405, 0.08, 8, 1, true, -0.9, 1.8), { pos: V(0, -0.02, 0) });
	return b.build();
}

// The ransom letter: a folded sheet with letters cut out of magazines, 0.16 x 0.01 x 0.12 m, lying flat.
export function buildRansomLetter() {
	const b = new Builder('ransom_letter');
	b.add('paper', mat('letter_paper', 0xf8f4e6), new THREE.BoxGeometry(0.16, 0.006, 0.12));
	const colors = [0xd23a4a, 0x2a5ac8, 0x2a2420, 0xf2c84b, 0x3a9a4a];
	for (let i = 0; i < 12; i++) {
		const c = mat(`letter_cut_${i % colors.length}`, colors[i % colors.length]);
		b.add('letters', c, new THREE.BoxGeometry(0.018, 0.002, 0.022), { pos: V(-0.06 + (i % 6) * 0.024, 0.004, -0.025 + Math.floor(i / 6) * 0.04), rot: [0, (i % 3 - 1) * 0.2, 0] });
	}
	return b.build();
}

// The hair-growth shampoo (peluqueria.md, "El champú crecepelo"): an 8 kg jug of green shampoo with a handle and a
// skull-and-hair label, 0.28 x 0.46 x 0.22 m, origin at its middle.
export function buildShampooJug() {
	const b = new Builder('shampoo_jug');
	const plastic = mat('jug_plastic', 0x58c878), cap = mat('jug_cap', 0xf4f0e8), label = mat('jug_label', 0xfff2a0);
	b.add('jug', plastic, new THREE.BoxGeometry(0.28, 0.38, 0.22), { pos: V(0, -0.04, 0) });
	b.add('jug', plastic, new THREE.CylinderGeometry(0.05, 0.1, 0.06, 8), { pos: V(-0.05, 0.18, 0) });
	b.add('cap', cap, new THREE.CylinderGeometry(0.045, 0.045, 0.04, 8), { pos: V(-0.05, 0.21, 0) });
	b.add('handle', plastic, new THREE.TorusGeometry(0.05, 0.015, 4, 10, Math.PI), { pos: V(0.07, 0.15, 0) });
	b.add('label', label, new THREE.BoxGeometry(0.18, 0.16, 0.004), { pos: V(0, -0.04, 0.112) });
	b.add('label', mat('label_hair', 0x6a3a1a), ellipsoid(0.05, 0.035, 0.003, 8, 4), { pos: V(0, 0.0, 0.115) });
	return b.build();
}

// The secret formula: a sheet with a green stain and a big X, 0.16 x 0.006 x 0.12 m, lying flat.
export function buildFormulaSheet() {
	const b = new Builder('formula_sheet');
	b.add('paper', mat('letter_paper', 0xf8f4e6), new THREE.BoxGeometry(0.16, 0.006, 0.12));
	b.add('stain', mat('jug_plastic', 0x58c878), ellipsoid(0.03, 0.002, 0.025, 8, 3), { pos: V(0.04, 0.003, 0.02) });
	for (const r of [0.6, -0.6]) b.add('mark', mat('ink_red', 0xd23a4a), new THREE.BoxGeometry(0.07, 0.002, 0.008), { pos: V(-0.035, 0.004, -0.015), rot: [0, r, 0] });
	return b.build();
}

// A sample jar of it: 0.07 m across, 0.1 m tall, green, with a white lid. Origin at its middle.
export function buildSampleJar() {
	const b = new Builder('sample_jar');
	b.add('jar', mat('jar_glass', 0x9ae8b0), new THREE.CylinderGeometry(0.035, 0.035, 0.08, 10), { pos: V(0, -0.01, 0) });
	b.add('lid', mat('jug_cap', 0xf4f0e8), new THREE.CylinderGeometry(0.037, 0.037, 0.02, 10), { pos: V(0, 0.04, 0) });
	return b.build();
}

// The caged dog that tried the shampoo: a small dog buried in fur that reaches the floor (the story's clue).
export function buildLongHairDog() {
	const b = new Builder('dog_long_hair');
	const fur = mat('long_fur', 0xe8d8b0), dark = mat('long_fur_dark', 0xc8b088), black = mat('dog_black', 0x141010), eye = mat('dog_eye', 0xffffff);
	b.add('fur', fur, new THREE.CylinderGeometry(0.17, 0.3, 0.32, 10), { pos: V(0, 0.16, 0) });
	b.add('fur', fur, ellipsoid(0.17, 0.12, 0.24, 10, 6), { pos: V(0, 0.32, 0) });
	b.add('fur', dark, new THREE.ConeGeometry(0.1, 0.28, 8), { pos: V(0, 0.2, 0.26), rot: [Math.PI, 0, 0] });
	b.add('head', fur, ellipsoid(0.12, 0.11, 0.11, 10, 6), { pos: V(0, 0.46, 0.24) });
	b.add('head', black, ellipsoid(0.025, 0.02, 0.018, 6, 4), { pos: V(0, 0.44, 0.35) });
	for (const s of [-1, 1]) {
		b.add('head', eye, ellipsoid(0.02, 0.022, 0.01, 6, 4), { pos: V(s * 0.045, 0.49, 0.335) });
		b.add('head', black, ellipsoid(0.011, 0.013, 0.007, 6, 4), { pos: V(s * 0.045, 0.49, 0.343) });
	}
	return b.build();
}

// The mustache the shampoo grows on a cop: a big brown handlebar, 0.6 m wide, origin at its middle, facing +Z.
export function buildMustache() {
	const b = new Builder('cop_mustache');
	const hair = mat('mustache_hair', 0x5a3418);
	b.add('mustache', hair, ellipsoid(0.12, 0.06, 0.05, 10, 6));
	for (const s of [-1, 1]) {
		b.add('mustache', hair, ellipsoid(0.12, 0.05, 0.04, 8, 5), { pos: V(s * 0.17, -0.02, 0), rot: [0, 0, s * 0.3] });
		b.add('mustache', hair, ellipsoid(0.05, 0.04, 0.03, 6, 4), { pos: V(s * 0.28, 0.04, 0), rot: [0, 0, s * 1.0] });
	}
	return b.build();
}

// Bone smuggling (peluqueria.md, "Contrabando de huesos"): the museum's dinosaur bones in a burlap sack, bones sticking
// out, 0.5 x 0.4 x 0.35 m, origin at its middle.
export function buildBoneBag() {
	const b = new Builder('bone_bag');
	const sack = mat('burlap', 0xb89a62), bone = mat('fossil', 0xe8dcc0), rope = mat('rope', 0x8a6a3a);
	b.add('sack', sack, ellipsoid(0.25, 0.18, 0.17, 12, 8), { pos: V(0, -0.02, 0) });
	b.add('sack', rope, new THREE.TorusGeometry(0.08, 0.012, 4, 10), { pos: V(0.12, 0.14, 0), rot: [Math.PI / 2, 0, 0.6] });
	for (const [x, z, r] of [[0.12, 0.02, 0.6], [0.18, -0.05, 0.9], [0.08, 0.06, 0.3]]) {
		b.add('bones', bone, new THREE.CylinderGeometry(0.018, 0.018, 0.22, 6), { pos: V(x, 0.2, z), rot: [0.2, 0, -r] });
		b.add('bones', bone, ellipsoid(0.03, 0.03, 0.03, 6, 4), { pos: V(x + Math.sin(r) * 0.11, 0.2 + Math.cos(r) * 0.11, z) });
	}
	return b.build();
}

// The dig map: a brown sheet with a dotted path and a red X, 0.16 x 0.006 x 0.12 m, lying flat.
export function buildDigMap() {
	const b = new Builder('dig_map');
	b.add('paper', mat('map_paper', 0xe8d4a0), new THREE.BoxGeometry(0.16, 0.006, 0.12));
	for (let i = 0; i < 5; i++) b.add('path', mat('ink_dark', 0x3a2a1a), new THREE.BoxGeometry(0.012, 0.002, 0.004), { pos: V(-0.06 + i * 0.022, 0.004, -0.03 + i * 0.012) });
	for (const r of [0.7, -0.7]) b.add('mark', mat('ink_red', 0xd23a4a), new THREE.BoxGeometry(0.04, 0.002, 0.008), { pos: V(0.05, 0.004, 0.03), rot: [0, r, 0] });
	return b.build();
}

// The yard's shovel: a wooden handle and a steel blade, 1.1 m long along Y, origin at its middle.
export function buildShovel() {
	const b = new Builder('shovel');
	const wood = mat('handle_wood', 0xa07040), steel = mat('blade_steel', 0x8a8e94);
	b.add('handle', wood, new THREE.CylinderGeometry(0.018, 0.018, 0.85, 6), { pos: V(0, 0.1, 0) });
	b.add('handle', wood, new THREE.BoxGeometry(0.12, 0.03, 0.03), { pos: V(0, 0.53, 0) });
	b.add('blade', steel, new THREE.BoxGeometry(0.22, 0.26, 0.02), { pos: V(0, -0.42, 0) });
	return b.build();
}

// Human salon (peluqueria.md, "Peluquería de humanos clandestina"): the appointment book for human customers, a purple
// cover with gold scissors, 0.22 x 0.05 x 0.3 m, lying flat, origin at its middle.
export function buildAppointmentBook() {
	const b = new Builder('appointment_book');
	const cover = mat('book_purple', 0x6a3a8a), page = mat('pages', 0xf2ead8), gold = mat('gold', 0xe8c040);
	b.add('cover', cover, new THREE.BoxGeometry(0.22, 0.05, 0.3));
	b.add('pages', page, new THREE.BoxGeometry(0.205, 0.04, 0.29), { pos: V(0.01, 0, 0) });
	for (const r of [0.5, -0.5]) b.add('scissors', gold, new THREE.BoxGeometry(0.012, 0.003, 0.12), { pos: V(0, 0.026, 0), rot: [0, r, 0] });
	for (const x of [-0.035, 0.035]) b.add('scissors', gold, new THREE.TorusGeometry(0.018, 0.004, 4, 10), { pos: V(x, 0.026, 0.065), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// A brown wig: a cap of hair with a fringe and curls, 0.24 x 0.14 x 0.26 m, origin at its bottom.
export function buildWig() {
	const b = new Builder('wig');
	const hair = mat('wig_hair', 0x6a4022);
	b.add('cap', hair, ellipsoid(0.12, 0.1, 0.13, 10, 6), { pos: V(0, 0.04, 0) });
	for (let i = 0; i < 7; i++) {
		const a = Math.PI * 0.15 + (i / 6) * Math.PI * 0.7;
		b.add('curls', hair, ellipsoid(0.03, 0.03, 0.03, 6, 4), { pos: V(Math.cos(a) * 0.11, 0.02, -Math.sin(a) * 0.1 + 0.02) });
	}
	b.add('fringe', hair, new THREE.BoxGeometry(0.16, 0.04, 0.03), { pos: V(0, 0.07, 0.12) });
	return b.build();
}

// A tall salon mirror for people (not dogs): a gilt frame and the glass, 0.5 x 0.8 x 0.04 m, origin at its middle.
export function buildSalonMirror() {
	const b = new Builder('salon_mirror');
	const frame = mat('gilt', 0xc8a040), glass = mat('mirror_glass', 0xc8dce8);
	b.add('glass', glass, new THREE.BoxGeometry(0.42, 0.72, 0.01), { pos: V(0, 0, 0.012) });
	for (const y of [-0.38, 0.38]) b.add('frame', frame, new THREE.BoxGeometry(0.5, 0.04, 0.04), { pos: V(0, y, 0) });
	for (const x of [-0.23, 0.23]) b.add('frame', frame, new THREE.BoxGeometry(0.04, 0.8, 0.04), { pos: V(x, 0, 0) });
	b.add('frame', frame, new THREE.BoxGeometry(0.46, 0.76, 0.01), { pos: V(0, 0, -0.012) });
	return b.build();
}

// A tuft of cut hair on the floor, 0.12 m across, origin at the floor. Its color is set in Godot (dog or human).
export function buildHairTuft() {
	const b = new Builder('hair_tuft');
	const hair = mat('tuft', 0xd8c8a8);
	for (let i = 0; i < 9; i++) {
		const a = i * 0.7, r = 0.02 + (i % 3) * 0.015;
		b.add('strands', hair, new THREE.BoxGeometry(0.07, 0.004, 0.006), { pos: V(Math.cos(a) * r, 0.003 + (i % 2) * 0.002, Math.sin(a) * r), rot: [0, a * 1.3, 0] });
	}
	return b.build();
}

// The striped towel Ramiro throws over a human customer's head: a drape from the head to the shoulders, 0.6 x 0.5 x
// 0.5 m, origin at its top.
export function buildCustomerTowel() {
	const b = new Builder('customer_towel');
	const towel = mat('towel_white', 0xf4f0e8), stripe = mat('towel_stripe', 0x4a8ac8);
	b.add('drape', towel, new THREE.ConeGeometry(0.32, 0.5, 9, 1, true), { pos: V(0, -0.25, 0) });
	b.add('drape', towel, ellipsoid(0.14, 0.08, 0.14, 8, 5), { pos: V(0, -0.02, 0) });
	for (const y of [-0.38, -0.44]) b.add('stripes', stripe, new THREE.CylinderGeometry(0.25 + (-y - 0.38) * 0.6, 0.26 + (-y - 0.38) * 0.6, 0.025, 9, 1, true), { pos: V(0, y, 0) });
	return b.build();
}

export const models = {
	shampoo_bottle: buildShampoo,
	dog_collar: buildCollar,
	...Object.fromEntries(COATS.map((_, i) => [`dog_${i}`, () => buildDog(i)])),
	dog_poodle: buildPoodle,
	dog_trophy: buildDogTrophy, judge_cards: buildJudgeCards, golden_comb: buildGoldenComb,
	contest_photo: buildContestPhoto, diamond_necklace: buildDiamondNecklace, necklace_case: buildNecklaceCase,
	dog_greyhound: () => buildGreyhound(false), dog_greyhound_roots: () => buildGreyhound(true), dog_dye: buildDogDye,
	ransom_letter: buildRansomLetter, shampoo_jug: buildShampooJug, formula_sheet: buildFormulaSheet,
	sample_jar: buildSampleJar, dog_long_hair: buildLongHairDog, cop_mustache: buildMustache,
	bone_bag: buildBoneBag, dig_map: buildDigMap, shovel: buildShovel,
	appointment_book: buildAppointmentBook, wig: buildWig, salon_mirror: buildSalonMirror, hair_tuft: buildHairTuft,
	customer_towel: buildCustomerTowel,
};

export const views = {
	groomer: {
		items: [{ name: 'shampoo_bottle', pos: [-0.08, 0.11, 0] }, { name: 'dog_collar', pos: [0.1, 0.065, 0] }],
		cam: { pos: [0, 0.2, 0.55], target: [0, 0.08, 0], fov: 40 },
	},
	dogs: {
		items: [...COATS.map((_, i) => ({ name: `dog_${i}`, pos: [(i - 3) * 0.7, 0, 0], rotY: 0.6 })), { name: 'dog_poodle', pos: [2.1, 0, 0], rotY: 0.6 }],
		cam: { pos: [0, 1.0, 4.6], target: [0, 0.3, 0], fov: 34 },
	},
	contest_goods: {
		items: [
			{ name: 'dog_trophy', pos: [-0.2, 0.2, 0], rotY: 0.3 }, { name: 'judge_cards', pos: [0.15, 0.01, 0.15], rotY: -0.3 },
			{ name: 'golden_comb', pos: [0.2, 0.008, -0.1], rotY: 0.4 }, { name: 'contest_photo', pos: [0.05, 0.07, 0.35], rotY: -0.2 },
		],
		cam: { pos: [0, 0.6, 1.2], target: [0, 0.1, 0.1], fov: 36 },
	},
	diamond_goods: {
		items: [{ name: 'diamond_necklace', pos: [-0.12, 0.01, 0], rotY: 0.3 }, { name: 'necklace_case', pos: [0.15, 0.03, -0.02], rotY: -0.3 }],
		cam: { pos: [0, 0.35, 0.6], target: [0, 0.03, 0], fov: 36 },
	},
	millionaire_goods: {
		items: [
			{ name: 'dog_greyhound', pos: [-0.55, 0, 0], rotY: 0.6 }, { name: 'dog_greyhound_roots', pos: [0.35, 0, 0], rotY: 0.6 },
			{ name: 'dog_dye', pos: [0.9, 0.1, 0.3], rotY: 0 }, { name: 'ransom_letter', pos: [-0.1, 0.005, 0.6], rotY: 0.3 },
		],
		cam: { pos: [0, 1.0, 2.4], target: [0, 0.35, 0.1], fov: 38 },
	},
	hair_goods: {
		items: [
			{ name: 'shampoo_jug', pos: [-0.45, 0.23, 0], rotY: 0.3 }, { name: 'formula_sheet', pos: [-0.05, 0.003, 0.25], rotY: -0.2 },
			{ name: 'sample_jar', pos: [0.15, 0.05, 0.2], rotY: 0 }, { name: 'dog_long_hair', pos: [0.5, 0, -0.1], rotY: -0.5 },
			{ name: 'cop_mustache', pos: [0.05, 0.45, -0.2], rotY: 0 },
		],
		cam: { pos: [0, 0.8, 1.7], target: [0, 0.22, 0], fov: 38 },
	},
	bone_goods: {
		items: [
			{ name: 'bone_bag', pos: [-0.3, 0.2, 0], rotY: 0.3 }, { name: 'dig_map', pos: [0.25, 0.003, 0.25], rotY: -0.2 },
			{ name: 'shovel', pos: [0.45, 0.55, -0.1], rotY: 0.4 },
		],
		cam: { pos: [0, 0.9, 1.9], target: [0, 0.3, 0], fov: 38 },
	},
	human_salon_goods: {
		items: [
			{ name: 'appointment_book', pos: [-0.4, 0.025, 0.2], rotY: 0.3 }, { name: 'wig', pos: [-0.05, 0, 0.3], rotY: -0.2 },
			{ name: 'salon_mirror', pos: [0.4, 0.4, -0.1], rotY: -0.3 }, { name: 'hair_tuft', pos: [0.05, 0, 0.6], rotY: 0 },
			{ name: 'customer_towel', pos: [-0.35, 0.6, -0.3], rotY: 0 },
		],
		cam: { pos: [0, 0.9, 2.0], target: [0, 0.3, 0], fov: 38 },
	},
};
