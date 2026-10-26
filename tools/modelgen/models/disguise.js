// The disguises in the station's lockers (docs/diseno/infiltracion.md, step 1): a grey grandparent wig, a white
// mustache and thick glasses. Each origin is where it sits on a cop (DisguisePiece.SLOTS), facing +Z. Placeholder.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// A grey curly wig that covers the top of a cop's head and cap: 0.46 x 0.2 x 0.44 m, origin at its bottom middle.
export function buildDisguiseWig() {
	const b = new Builder('disguise_wig');
	const hair = mat('grey_hair', 0xc8c4bc);
	b.add('cap', hair, ellipsoid(0.22, 0.12, 0.21, 10, 6), { pos: V(0, 0.06, 0) });
	for (let i = 0; i < 12; i++) {
		const a = (i / 12) * Math.PI * 2;
		b.add('curls', hair, ellipsoid(0.05, 0.05, 0.05, 6, 4), { pos: V(Math.cos(a) * 0.2, 0.03 + (i % 2) * 0.03, Math.sin(a) * 0.19) });
	}
	return b.build();
}

// A white walrus mustache: 0.28 x 0.08 x 0.06 m, origin at its middle.
export function buildDisguiseMustache() {
	const b = new Builder('disguise_mustache');
	const hair = mat('white_hair', 0xeeeae2);
	b.add('mustache', hair, ellipsoid(0.07, 0.035, 0.03, 8, 5));
	for (const s of [-1, 1]) b.add('mustache', hair, ellipsoid(0.07, 0.03, 0.025, 8, 5), { pos: V(s * 0.08, -0.015, -0.01), rot: [0, 0, s * 0.4] });
	return b.build();
}

// Thick round glasses: two lenses and a bridge, 0.3 x 0.1 x 0.04 m, origin at the bridge.
export function buildDisguiseGlasses() {
	const b = new Builder('disguise_glasses');
	const frame = mat('glasses_frame', 0x3a2a1a), lens = mat('glasses_lens', 0xd8eef8, { emissive: 0x101820 });
	for (const s of [-1, 1]) {
		b.add('frame', frame, new THREE.TorusGeometry(0.055, 0.012, 6, 14), { pos: V(s * 0.08, 0, 0) });
		b.add('lens', lens, new THREE.CircleGeometry(0.05, 14), { pos: V(s * 0.08, 0, 0.002) });
		b.add('frame', frame, new THREE.BoxGeometry(0.06, 0.012, 0.012), { pos: V(s * 0.16, 0.01, -0.03), rot: [0, s * 1.2, 0] });
	}
	b.add('frame', frame, new THREE.BoxGeometry(0.05, 0.012, 0.012), { pos: V(0, 0.01, 0) });
	return b.build();
}

// The choir robe (infiltracion-coro.md, step 2), worn: a burgundy robe from under the face to the floor with a white
// collar, around a cop. Origin at the chest's front (DisguisePiece.SLOTS.robe), the cop's middle 0.3 m behind (-Z).
export function buildDisguiseRobe() {
	const b = new Builder('disguise_robe');
	const cloth = mat('robe_cloth', 0x7a1f2e), collar = mat('robe_collar', 0xf2eee4);
	b.add('robe', cloth, new THREE.CylinderGeometry(0.33, 0.6, 0.97, 14, 1, true), { pos: V(0, -0.385, -0.3) });
	b.add('collar', collar, new THREE.TorusGeometry(0.32, 0.05, 6, 16), { pos: V(0, 0.1, -0.3), rot: [Math.PI / 2, 0, 0] });
	b.add('sleeves', cloth, new THREE.CylinderGeometry(0.11, 0.16, 0.5, 8), { pos: V(-0.46, -0.2, -0.3), rot: [0, 0, -0.35] });
	b.add('sleeves', cloth, new THREE.CylinderGeometry(0.11, 0.16, 0.5, 8), { pos: V(0.46, -0.2, -0.3), rot: [0, 0, 0.35] });
	return b.build();
}

// The robe folded, as it lies in front of the lockers: 0.45 x 0.12 x 0.35 m with the collar on top, origin in its middle.
export function buildFoldedRobe() {
	const b = new Builder('folded_robe');
	const cloth = mat('robe_cloth', 0x7a1f2e), collar = mat('robe_collar', 0xf2eee4);
	b.add('robe', cloth, new THREE.BoxGeometry(0.45, 0.12, 0.35));
	b.add('collar', collar, new THREE.TorusGeometry(0.08, 0.02, 6, 12), { pos: V(0, 0.065, -0.08), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The choir's songbook: a black book with a gold note on the cover, 0.2 x 0.04 x 0.28 m, origin in its middle.
export function buildSongbook() {
	const b = new Builder('songbook');
	const cover = mat('songbook_cover', 0x1d1a22), pages = mat('songbook_pages', 0xf4eedc);
	const gold = mat('songbook_gold', 0xd8b040, { emissive: 0x302008 });
	b.add('cover', cover, new THREE.BoxGeometry(0.2, 0.04, 0.28));
	b.add('pages', pages, new THREE.BoxGeometry(0.19, 0.03, 0.265), { pos: V(0.006, 0, 0) });
	b.add('note', gold, new THREE.CylinderGeometry(0.025, 0.025, 0.004, 10), { pos: V(-0.02, 0.021, 0.04) });
	b.add('note', gold, new THREE.BoxGeometry(0.008, 0.004, 0.08), { pos: V(0.002, 0.021, 0.0) });
	return b.build();
}

// The cleaning crew's disguises (fuga-limpieza.md, step 3), each origin where it sits on a cop (DisguisePiece.SLOTS):
// a blue cap with a visor, a white face mask and a yellow vest with grey reflective stripes. Placeholder.
export function buildCleanerCap() {
	const b = new Builder('disguise_cleaner_cap');
	const blue = mat('cleaner_blue', 0x2a6ad0);
	b.add('cap', blue, ellipsoid(0.21, 0.11, 0.2, 10, 6), { pos: V(0, 0.05, 0) });
	b.add('visor', blue, new THREE.CylinderGeometry(0.13, 0.13, 0.02, 12, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 0.02, 0.17), scale: [1, 1, 0.9] });
	b.add('badge', mat('cleaner_badge', 0xf2eee4), new THREE.BoxGeometry(0.08, 0.04, 0.01), { pos: V(0, 0.09, 0.2) });
	return b.build();
}

// A white face mask with its straps, 0.24 x 0.12 x 0.06 m, origin in its middle.
export function buildFaceMask() {
	const b = new Builder('disguise_face_mask');
	const white = mat('mask_white', 0xf4f6f8), strap = mat('mask_strap', 0xd8dadc);
	b.add('mask', white, ellipsoid(0.11, 0.06, 0.035, 10, 5));
	for (const s of [-1, 1]) b.add('straps', strap, new THREE.BoxGeometry(0.1, 0.008, 0.008), { pos: V(s * 0.15, 0.01, -0.04), rot: [0, s * 0.9, 0] });
	return b.build();
}

// The vest worn: around the cop's chest and belly, origin at the chest's front, the cop's middle 0.3 m behind (-Z).
export function buildCleanerVest() {
	const b = new Builder('disguise_cleaner_vest');
	const vest = mat('vest_yellow', 0xf2d020), stripe = mat('vest_stripe', 0xb8bcc4, { emissive: 0x202224 });
	b.add('vest', vest, new THREE.CylinderGeometry(0.3, 0.47, 0.55, 14, 1, true), { pos: V(0, -0.15, -0.3) });
	for (const y of [-0.3, -0.12]) b.add('stripes', stripe, new THREE.CylinderGeometry(0.45 - (y + 0.3) * 0.25, 0.46 - (y + 0.3) * 0.25, 0.04, 14, 1, true), { pos: V(0, y, -0.3) });
	return b.build();
}

// The vest folded, as it lies in the cleaning closet: 0.4 x 0.08 x 0.3 m, origin in its middle.
export function buildFoldedVest() {
	const b = new Builder('folded_vest');
	b.add('vest', mat('vest_yellow', 0xf2d020), new THREE.BoxGeometry(0.4, 0.08, 0.3));
	b.add('stripes', mat('vest_stripe', 0xb8bcc4, { emissive: 0x202224 }), new THREE.BoxGeometry(0.41, 0.02, 0.05), { pos: V(0, 0.03, 0) });
	return b.build();
}

// The mime troupe's disguises (infiltracion-mimos.md, step 1), each origin where it sits on a cop (DisguisePiece.SLOTS):
// a black beret, a white painted face with black brows and a teardrop, and a striped shirt. Placeholder.
export function buildMimeBeret() {
	const b = new Builder('disguise_mime_beret');
	const black = mat('beret_black', 0x18181c);
	b.add('beret', black, ellipsoid(0.24, 0.06, 0.23, 12, 6), { pos: V(0.03, 0.07, 0), rot: [0, 0, -0.15] });
	b.add('stalk', black, new THREE.CylinderGeometry(0.01, 0.012, 0.04, 6), { pos: V(0.03, 0.14, 0) });
	return b.build();
}

// The white face, 0.26 x 0.3 x 0.06 m, origin in its middle (over the cop's nose).
export function buildMimeFace() {
	const b = new Builder('disguise_mime_face');
	const white = mat('mime_white', 0xfafafa), black = mat('mime_black', 0x101012);
	b.add('face', white, ellipsoid(0.13, 0.15, 0.03, 12, 6));
	for (const s of [-1, 1]) b.add('brows', black, new THREE.BoxGeometry(0.06, 0.012, 0.01), { pos: V(s * 0.05, 0.07, 0.03), rot: [0, 0, s * 0.3] });
	b.add('tear', black, ellipsoid(0.01, 0.02, 0.006, 6, 4), { pos: V(0.05, -0.02, 0.03) });
	b.add('lips', mat('mime_red', 0xc0182a), ellipsoid(0.03, 0.012, 0.008, 8, 4), { pos: V(0, -0.08, 0.028) });
	return b.build();
}

// The striped shirt worn: black and white rings around the cop's chest and belly, origin at the chest's front, the
// cop's middle 0.3 m behind (-Z).
export function buildMimeShirt() {
	const b = new Builder('disguise_mime_shirt');
	const white = mat('shirt_white', 0xf2f2f2), black = mat('shirt_black', 0x1a1a1e);
	for (let i = 0; i < 6; i++) {
		const t = i / 6, h = 0.55 / 6;
		const top = 0.3 + t * 0.17, bottom = 0.3 + (t + 1 / 6) * 0.17;
		b.add(i % 2 ? 'black' : 'white', i % 2 ? black : white, new THREE.CylinderGeometry(top, bottom, h, 14, 1, true), { pos: V(0, 0.12 - (i + 0.5) * h, -0.3) });
	}
	return b.build();
}

// The shirt folded, as it lies in front of the lockers: 0.4 x 0.08 x 0.3 m, origin in its middle.
export function buildFoldedMimeShirt() {
	const b = new Builder('folded_mime_shirt');
	b.add('shirt', mat('shirt_white', 0xf2f2f2), new THREE.BoxGeometry(0.4, 0.08, 0.3));
	for (const z of [-0.1, 0, 0.1]) b.add('stripes', mat('shirt_black', 0x1a1a1e), new THREE.BoxGeometry(0.41, 0.082, 0.04), { pos: V(0, 0, z) });
	return b.build();
}

// The costume party's disguises (infiltracion-fiesta.md, step 1), each origin where it sits on a cop
// (DisguisePiece.SLOTS): a party-store cop cap with a light on top, a fake black handlebar mustache and a giant plastic
// badge. Placeholder.
export function buildPartyCap() {
	const b = new Builder('disguise_party_cap');
	const blue = mat('party_blue', 0x2a48c8), shiny = mat('party_visor', 0x101018);
	b.add('crown', blue, new THREE.CylinderGeometry(0.2, 0.17, 0.1, 14), { pos: V(0, 0.07, 0) });
	b.add('visor', shiny, new THREE.CylinderGeometry(0.13, 0.13, 0.015, 12, 1, false, 0, Math.PI), { pos: V(0, 0.02, -0.15), rot: [0, Math.PI / 2, 0] });
	b.add('band', mat('party_gold', 0xf0c020), new THREE.CylinderGeometry(0.175, 0.175, 0.02, 14), { pos: V(0, 0.03, 0) });
	b.add('light', mat('party_light_red', 0xff2030, { emissive: 0xa00010 }), ellipsoid(0.03, 0.035, 0.03, 8, 5), { pos: V(-0.03, 0.14, 0) });
	b.add('light', mat('party_light_blue', 0x2060ff, { emissive: 0x0020a0 }), ellipsoid(0.03, 0.035, 0.03, 8, 5), { pos: V(0.03, 0.14, 0) });
	return b.build();
}

// The fake handlebar mustache: 0.3 x 0.08 x 0.05 m, glossy black, curled up at the tips, origin at its middle.
export function buildPartyMustache() {
	const b = new Builder('disguise_party_mustache');
	const black = mat('fake_black', 0x0c0c0e);
	b.add('mustache', black, ellipsoid(0.06, 0.025, 0.025, 8, 5));
	for (const s of [-1, 1]) {
		b.add('mustache', black, ellipsoid(0.06, 0.018, 0.02, 8, 5), { pos: V(s * 0.08, -0.005, -0.005), rot: [0, 0, s * 0.25] });
		b.add('curl', black, new THREE.TorusGeometry(0.02, 0.008, 5, 10, Math.PI * 1.5), { pos: V(s * 0.135, 0.015, -0.01) });
	}
	return b.build();
}

// The giant plastic badge: a gold star 0.24 m across and 0.03 m thick with a round blue middle, origin at its middle.
export function buildPartyBadge() {
	const b = new Builder('disguise_party_badge');
	const shape = new THREE.Shape();
	for (let i = 0; i < 10; i++) {
		const r = i % 2 ? 0.055 : 0.12, a = Math.PI / 2 + (i / 10) * Math.PI * 2;
		if (i === 0) shape.moveTo(Math.cos(a) * r, Math.sin(a) * r);
		else shape.lineTo(Math.cos(a) * r, Math.sin(a) * r);
	}
	const star = new THREE.ExtrudeGeometry(shape, { depth: 0.03, bevelEnabled: false });
	star.translate(0, 0, -0.015);
	b.add('star', mat('plastic_gold', 0xf2c230), star);
	b.add('middle', mat('party_blue', 0x2a48c8), new THREE.CylinderGeometry(0.04, 0.04, 0.034, 12), { rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The gym's disguises (infiltracion-gimnasio.md, step 1), each origin where it sits on a cop (DisguisePiece.SLOTS): a
// red terry headband, a pair of white wristbands and a red tank top with a white stripe. Placeholder.
const GYM_RED = 0xd8282e, GYM_WHITE = 0xf4f4f0;
export function buildGymHeadband() {
	const b = new Builder('disguise_gym_headband');
	const band = new THREE.TorusGeometry(0.205, 0.03, 6, 18);
	band.rotateX(Math.PI / 2);
	b.add('band', mat('gym_red', GYM_RED), band);
	const stripe = new THREE.TorusGeometry(0.205, 0.032, 4, 18);
	stripe.rotateX(Math.PI / 2);
	stripe.scale(1, 0.3, 1);
	b.add('stripe', mat('gym_white', GYM_WHITE), stripe);
	return b.build();
}

// Worn, one on each wrist (the pear's arms end at about x 0.47, 0.02 m below and 0.165 m behind the slot).
export function buildGymWristbands() {
	const b = new Builder('disguise_gym_wristbands');
	for (const s of [-1, 1]) b.add('bands', mat('gym_white', GYM_WHITE), new THREE.CylinderGeometry(0.068, 0.068, 0.07, 10), { pos: V(s * 0.45, 0.0, -0.165), rot: [0, 0, s * 0.75] });
	return b.build();
}

// The pair lying side by side in front of the lockers: 0.2 x 0.07 x 0.14 m, origin in its middle.
export function buildFoldedGymWristbands() {
	const b = new Builder('folded_gym_wristbands');
	for (const s of [-1, 1]) b.add('bands', mat('gym_white', GYM_WHITE), new THREE.CylinderGeometry(0.065, 0.065, 0.07, 10), { pos: V(s * 0.07, 0, 0) });
	return b.build();
}

export function buildGymTank() {
	const b = new Builder('disguise_gym_tank');
	const red = mat('gym_red', GYM_RED), white = mat('gym_white', GYM_WHITE);
	for (let i = 0; i < 5; i++) {
		const t = i / 5, h = 0.5 / 5;
		const top = 0.3 + t * 0.16, bottom = 0.3 + (t + 1 / 5) * 0.16;
		b.add(i === 2 ? 'stripe' : 'tank', i === 2 ? white : red, new THREE.CylinderGeometry(top, bottom, h, 14, 1, true), { pos: V(0, 0.1 - (i + 0.5) * h, -0.3) });
	}
	return b.build();
}

// The tank top folded: 0.38 x 0.06 x 0.3 m, origin in its middle.
export function buildFoldedGymTank() {
	const b = new Builder('folded_gym_tank');
	b.add('tank', mat('gym_red', GYM_RED), new THREE.BoxGeometry(0.38, 0.06, 0.3));
	b.add('stripe', mat('gym_white', GYM_WHITE), new THREE.BoxGeometry(0.39, 0.062, 0.05));
	return b.build();
}

// The thieves' school disguises (infiltracion-escuela.md, step 1), each origin where it sits on a cop
// (DisguisePiece.SLOTS): the cartoon burglar's black eye mask, a black beanie and a grey and black striped shirt.
// Placeholder.
const THIEF_BLACK = 0x141418, THIEF_GREY = 0x9aa0a8;
export function buildThiefMask() {
	const b = new Builder('disguise_thief_mask');
	const black = mat('thief_black', THIEF_BLACK);
	b.add('mask', black, new THREE.BoxGeometry(0.3, 0.07, 0.03));
	for (const s of [-1, 1]) b.add('mask', black, ellipsoid(0.055, 0.045, 0.02, 8, 4), { pos: V(s * 0.08, 0, 0.005) });
	for (const s of [-1, 1]) b.add('holes', mat('thief_hole', 0xf0f0ea), ellipsoid(0.025, 0.018, 0.01, 6, 3), { pos: V(s * 0.08, 0, 0.022) });
	for (const s of [-1, 1]) b.add('strings', black, new THREE.BoxGeometry(0.01, 0.015, 0.16), { pos: V(s * 0.155, 0, 0.07) });
	return b.build();
}

export function buildThiefBeanie() {
	const b = new Builder('disguise_thief_beanie');
	const black = mat('thief_black', THIEF_BLACK);
	b.add('beanie', black, ellipsoid(0.215, 0.15, 0.205, 12, 6), { pos: V(0, 0.02, 0.01) });
	b.add('cuff', mat('thief_cuff', 0x26262c), new THREE.CylinderGeometry(0.218, 0.218, 0.06, 14), { pos: V(0, -0.0, 0.01) });
	return b.build();
}

export function buildThiefShirt() {
	const b = new Builder('disguise_thief_shirt');
	const grey = mat('thief_grey', THIEF_GREY), black = mat('thief_black', THIEF_BLACK);
	for (let i = 0; i < 8; i++) {
		const t = i / 8, h = 0.55 / 8;
		const top = 0.3 + t * 0.17, bottom = 0.3 + (t + 1 / 8) * 0.17;
		b.add(i % 2 ? 'grey' : 'black', i % 2 ? grey : black, new THREE.CylinderGeometry(top, bottom, h, 14, 1, true), { pos: V(0, 0.12 - (i + 0.5) * h, -0.3) });
	}
	return b.build();
}

// The shirt folded: 0.4 x 0.08 x 0.3 m, origin in its middle.
export function buildFoldedThiefShirt() {
	const b = new Builder('folded_thief_shirt');
	b.add('shirt', mat('thief_black', THIEF_BLACK), new THREE.BoxGeometry(0.4, 0.08, 0.3));
	for (const z of [-0.105, -0.035, 0.035, 0.105]) b.add('stripes', mat('thief_grey', THIEF_GREY), new THREE.BoxGeometry(0.41, 0.082, 0.035), { pos: V(0, 0, z) });
	return b.build();
}

// The restaurant's disguises (infiltracion-restaurante.md, step 1), each origin where it sits on a cop
// (DisguisePiece.SLOTS): a tall white chef's hat, a big curly brown mustache and a white apron over a white jacket.
// Placeholder.
const CHEF_WHITE = 0xf6f6f2;
export function buildChefHat() {
	const b = new Builder('disguise_chef_hat');
	const white = mat('chef_white', CHEF_WHITE);
	b.add('band', white, new THREE.CylinderGeometry(0.215, 0.215, 0.1, 14), { pos: V(0, 0.0, 0.01) });
	b.add('puff', white, new THREE.CylinderGeometry(0.25, 0.21, 0.26, 14), { pos: V(0, 0.17, 0.01) });
	for (const [x, z] of [[-0.12, 0], [0.12, 0], [0, -0.12], [0, 0.12], [0, 0]]) {
		b.add('puff', white, ellipsoid(0.15, 0.1, 0.15, 10, 5), { pos: V(x, 0.31, z + 0.01) });
	}
	return b.build();
}

export function buildChefMustache() {
	const b = new Builder('disguise_chef_mustache');
	const brown = mat('chef_brown', 0x4a2a14);
	b.add('mustache', brown, ellipsoid(0.07, 0.03, 0.03, 8, 5));
	for (const s of [-1, 1]) {
		b.add('mustache', brown, ellipsoid(0.07, 0.022, 0.022, 8, 5), { pos: V(s * 0.09, 0.0, -0.005), rot: [0, 0, s * 0.15] });
		b.add('curl', brown, new THREE.TorusGeometry(0.035, 0.011, 5, 12, Math.PI * 1.7), { pos: V(s * 0.17, 0.03, -0.01), rot: [0, 0, s > 0 ? 0 : Math.PI] });
	}
	return b.build();
}

export function buildChefApron() {
	const b = new Builder('disguise_chef_apron');
	const white = mat('chef_white', CHEF_WHITE), apron = mat('chef_apron', 0xe2e2dc), black = mat('chef_button', 0x202024);
	b.add('jacket', white, new THREE.CylinderGeometry(0.31, 0.45, 0.55, 14, 1, true), { pos: V(0, -0.155, -0.3) });
	b.add('apron', apron, new THREE.BoxGeometry(0.46, 0.38, 0.02), { pos: V(0, -0.26, 0.115), rot: [-0.29, 0, 0] });
	b.add('strings', apron, new THREE.TorusGeometry(0.33, 0.012, 4, 16), { pos: V(0, -0.02, -0.3), rot: [Math.PI / 2, 0, 0] });
	for (const s of [-1, 1]) for (let i = 0; i < 2; i++) {
		b.add('buttons', black, new THREE.SphereGeometry(0.014, 6, 4), { pos: V(s * 0.07, 0.06 - i * 0.06, 0.03 + i * 0.012) });
	}
	return b.build();
}

// The apron folded: 0.4 x 0.08 x 0.3 m, origin in its middle.
export function buildFoldedChefApron() {
	const b = new Builder('folded_chef_apron');
	b.add('apron', mat('chef_white', CHEF_WHITE), new THREE.BoxGeometry(0.4, 0.08, 0.3));
	b.add('strings', mat('chef_apron', 0xe2e2dc), new THREE.BoxGeometry(0.41, 0.082, 0.04));
	return b.build();
}

// The chess club's disguises (infiltracion-ajedrez.md, step 1), each origin where it sits on a cop
// (DisguisePiece.SLOTS): thick black glasses with bottle-bottom lenses, a green argyle vest over a white shirt with a
// brown tie, and a brown thinker's beret. Placeholder.
export function buildChessGlasses() {
	const b = new Builder('disguise_chess_glasses');
	const frame = mat('chess_frame', 0x141418), lens = mat('chess_lens', 0xe8f4fa, { emissive: 0x18242c });
	for (const s of [-1, 1]) {
		b.add('frame', frame, new THREE.BoxGeometry(0.12, 0.09, 0.025), { pos: V(s * 0.075, 0, 0) });
		b.add('lens', lens, new THREE.CylinderGeometry(0.038, 0.038, 0.03, 12), { pos: V(s * 0.075, 0, 0.012), rot: [Math.PI / 2, 0, 0] });
		for (let i = 1; i < 3; i++) b.add('rings', frame, new THREE.TorusGeometry(0.038 - i * 0.011, 0.002, 4, 12), { pos: V(s * 0.075, 0, 0.028) });
		b.add('frame', frame, new THREE.BoxGeometry(0.018, 0.018, 0.2), { pos: V(s * 0.14, 0.02, -0.1) });
	}
	return b.build();
}

export function buildChessVest() {
	const b = new Builder('disguise_chess_vest');
	const green = mat('chess_green', 0x3a6a4a), cream = mat('chess_cream', 0xe8dcb0), white = mat('chess_shirt', 0xf4f4ef);
	const tie = mat('chess_tie', 0x6a4022);
	b.add('vest', green, new THREE.CylinderGeometry(0.31, 0.45, 0.55, 14, 1, true), { pos: V(0, -0.155, -0.3) });
	b.add('shirt', white, new THREE.CylinderGeometry(0.2, 0.3, 0.12, 12, 1, true), { pos: V(0, 0.1, -0.28) });
	b.add('tie', tie, new THREE.BoxGeometry(0.05, 0.22, 0.01), { pos: V(0, 0.0, 0.035), rot: [-0.25, 0, 0] });
	for (let row = 0; row < 3; row++) for (let col = -1; col <= 1; col++) {
		if (col === 0 && row === 0) continue;
		const y = -0.05 - row * 0.12;
		const r = 0.31 + (0.12 - y) * 0.2545;
		const a = col * 0.32;
		b.add('argyle', cream, new THREE.BoxGeometry(0.07, 0.07, 0.01), { pos: V(Math.sin(a) * r, y, -0.3 + Math.cos(a) * r + 0.004), rot: [-0.25, a, Math.PI / 4] });
	}
	return b.build();
}

export function buildChessBeret() {
	const b = new Builder('disguise_chess_beret');
	const brown = mat('chess_brown', 0x7a5232);
	b.add('beret', brown, ellipsoid(0.23, 0.07, 0.22, 12, 6), { pos: V(-0.03, 0.07, 0.01), rot: [0, 0, 0.18] });
	b.add('band', mat('chess_band', 0x4a3020), new THREE.TorusGeometry(0.18, 0.012, 4, 16), { pos: V(0, 0.03, 0.01), rot: [Math.PI / 2, 0, 0] });
	b.add('stalk', brown, new THREE.CylinderGeometry(0.01, 0.012, 0.04, 6), { pos: V(-0.03, 0.15, 0.01) });
	return b.build();
}

// The vest folded: 0.4 x 0.08 x 0.3 m, origin in its middle.
export function buildFoldedChessVest() {
	const b = new Builder('folded_chess_vest');
	b.add('vest', mat('chess_green', 0x3a6a4a), new THREE.BoxGeometry(0.4, 0.08, 0.3));
	for (const x of [-0.1, 0.1]) b.add('argyle', mat('chess_cream', 0xe8dcb0), new THREE.BoxGeometry(0.08, 0.01, 0.08), { pos: V(x, 0.041, 0), rot: [0, Math.PI / 4, 0] });
	return b.build();
}

// The biker gang's disguises (infiltracion-motos.md, step 1), each origin where it sits on a cop
// (DisguisePiece.SLOTS): a red bandana with white dots tied at the back, a long grey fake beard down to the chest and
// a black leather jacket with patches and silver zips. Placeholder.
export function buildBikerBandana() {
	const b = new Builder('disguise_biker_bandana');
	const red = mat('biker_red', 0xb02424), dot = mat('biker_dot', 0xf4f0e8);
	b.add('bandana', red, ellipsoid(0.235, 0.09, 0.235, 12, 6), { pos: V(0, 0.04, 0.0) });
	b.add('bandana', red, new THREE.CylinderGeometry(0.235, 0.235, 0.05, 14, 1, true), { pos: V(0, 0.02, 0) });
	for (let i = 0; i < 8; i++) {
		const a = (i / 8) * Math.PI * 2;
		b.add('dots', dot, new THREE.SphereGeometry(0.014, 5, 4), { pos: V(Math.sin(a) * 0.2, 0.07, Math.cos(a) * 0.2) });
	}
	b.add('knot', red, new THREE.SphereGeometry(0.04, 6, 5), { pos: V(0, 0.02, -0.24) });
	for (const s of [-1, 1]) b.add('knot', red, new THREE.BoxGeometry(0.05, 0.14, 0.012), { pos: V(s * 0.03, -0.05, -0.25), rot: [-0.2, 0, s * 0.25] });
	return b.build();
}

export function buildBikerBeard() {
	const b = new Builder('disguise_biker_beard');
	const grey = mat('biker_beard', 0x9a9690);
	b.add('beard', grey, ellipsoid(0.13, 0.06, 0.05, 10, 6), { pos: V(0, 0.0, 0.0) });
	b.add('beard', grey, ellipsoid(0.13, 0.08, 0.07, 10, 6), { pos: V(0, -0.06, 0.05) });
	b.add('beard', grey, new THREE.ConeGeometry(0.13, 0.36, 8), { pos: V(0, -0.22, 0.13), rot: [Math.PI + 0.45, 0, 0], scale: [1, 1, 0.45] });
	for (const s of [-1, 1]) b.add('beard', grey, new THREE.BoxGeometry(0.04, 0.14, 0.03), { pos: V(s * 0.12, 0.06, -0.04), rot: [0, 0, s * 0.1] });
	b.add('mustache', mat('biker_mustache', 0x7a7672), ellipsoid(0.1, 0.025, 0.03, 8, 5), { pos: V(0, 0.05, 0.02) });
	return b.build();
}

export function buildBikerJacket() {
	const b = new Builder('disguise_biker_jacket');
	const leather = mat('biker_leather', 0x1a1a1e), silver = mat('biker_silver', 0xc8ccd4);
	b.add('jacket', leather, new THREE.CylinderGeometry(0.32, 0.46, 0.58, 14, 1, true), { pos: V(0, -0.155, -0.3) });
	b.add('collar', leather, new THREE.CylinderGeometry(0.22, 0.3, 0.1, 12, 1, true), { pos: V(0, 0.13, -0.28) });
	b.add('zip', silver, new THREE.BoxGeometry(0.015, 0.5, 0.012), { pos: V(0.06, -0.15, 0.08), rot: [-0.25, 0, 0] });
	const patches = [[0xd8b040, -0.22, -0.05], [0x2a6ab0, 0.24, -0.18], [0xc03a2a, -0.18, -0.3]];
	for (const [c, a, y] of patches) {
		const r = 0.32 + (0.135 - y) * 0.24;
		b.add('patches', mat(`biker_patch_${c.toString(16)}`, c), new THREE.CylinderGeometry(0.045, 0.045, 0.01, 8), { pos: V(Math.sin(a * 2) * r, y, -0.3 + Math.cos(a * 2) * r + 0.004), rot: [Math.PI / 2 - 0.25, a * 2, 0] });
	}
	return b.build();
}

// The jacket folded: 0.4 x 0.1 x 0.32 m, origin in its middle.
export function buildFoldedBikerJacket() {
	const b = new Builder('folded_biker_jacket');
	b.add('jacket', mat('biker_leather', 0x1a1a1e), new THREE.BoxGeometry(0.4, 0.1, 0.32));
	b.add('zip', mat('biker_silver', 0xc8ccd4), new THREE.BoxGeometry(0.015, 0.01, 0.3), { pos: V(0.05, 0.051, 0) });
	b.add('patches', mat('biker_patch_d8b040', 0xd8b040), new THREE.CylinderGeometry(0.05, 0.05, 0.01, 8), { pos: V(-0.1, 0.051, 0) });
	return b.build();
}

export const models = {
	disguise_wig: buildDisguiseWig, disguise_mustache: buildDisguiseMustache, disguise_glasses: buildDisguiseGlasses,
	disguise_robe: buildDisguiseRobe, folded_robe: buildFoldedRobe, songbook: buildSongbook,
	disguise_cleaner_cap: buildCleanerCap, disguise_face_mask: buildFaceMask, disguise_cleaner_vest: buildCleanerVest,
	folded_vest: buildFoldedVest,
	disguise_mime_beret: buildMimeBeret, disguise_mime_face: buildMimeFace, disguise_mime_shirt: buildMimeShirt,
	folded_mime_shirt: buildFoldedMimeShirt,
	disguise_party_cap: buildPartyCap, disguise_party_mustache: buildPartyMustache, disguise_party_badge: buildPartyBadge,
	disguise_gym_headband: buildGymHeadband, disguise_gym_wristbands: buildGymWristbands, folded_gym_wristbands: buildFoldedGymWristbands,
	disguise_gym_tank: buildGymTank, folded_gym_tank: buildFoldedGymTank,
	disguise_thief_mask: buildThiefMask, disguise_thief_beanie: buildThiefBeanie, disguise_thief_shirt: buildThiefShirt,
	folded_thief_shirt: buildFoldedThiefShirt,
	disguise_chef_hat: buildChefHat, disguise_chef_mustache: buildChefMustache, disguise_chef_apron: buildChefApron,
	folded_chef_apron: buildFoldedChefApron,
	disguise_chess_glasses: buildChessGlasses, disguise_chess_vest: buildChessVest, disguise_chess_beret: buildChessBeret,
	folded_chess_vest: buildFoldedChessVest,
	disguise_biker_bandana: buildBikerBandana, disguise_biker_beard: buildBikerBeard, disguise_biker_jacket: buildBikerJacket,
	folded_biker_jacket: buildFoldedBikerJacket,
};

export const views = {
	disguise: {
		items: [
			{ name: 'disguise_wig', pos: [-0.35, 0, 0], rotY: 0.4 },
			{ name: 'disguise_mustache', pos: [0.15, 0.06, 0.1] },
			{ name: 'disguise_glasses', pos: [0.45, 0.06, 0] },
		],
		cam: { pos: [0, 0.5, 1.2], target: [0, 0.05, 0], fov: 40 },
	},
	choir_disguise: {
		items: [
			{ name: 'disguise_robe', pos: [-0.4, 0.95, 0.3] },
			{ name: 'folded_robe', pos: [0.55, 0.06, 0.2], rotY: 0.3 },
			{ name: 'songbook', pos: [0.6, 0.02, 0.7], rotY: -0.4 },
		],
		cam: { pos: [0.3, 1.2, 3.0], target: [0.1, 0.5, 0], fov: 40 },
	},
	mime_disguise: {
		items: [
			{ name: 'disguise_mime_shirt', pos: [-0.4, 0.95, 0.3] },
			{ name: 'disguise_mime_face', pos: [-0.4, 1.3, 0.09] },
			{ name: 'disguise_mime_beret', pos: [-0.4, 1.42, 0.3] },
			{ name: 'folded_mime_shirt', pos: [0.55, 0.04, 0.2], rotY: 0.3 },
		],
		cam: { pos: [0.3, 1.2, 3.0], target: [0.1, 0.7, 0], fov: 40 },
	},
	party_disguise: {
		items: [
			{ name: 'disguise_party_badge', pos: [-0.4, 1.05, 0.3] },
			{ name: 'disguise_party_mustache', pos: [-0.4, 1.22, 0.1] },
			{ name: 'disguise_party_cap', pos: [-0.4, 1.42, 0.3] },
		],
		cam: { pos: [0.3, 1.2, 3.0], target: [0.1, 0.7, 0], fov: 40 },
	},
	gym_disguise: {
		items: [
			{ name: 'cop_0', pos: [-0.4, 0, 0] },
			{ name: 'disguise_gym_tank', pos: [-0.4, 0.95, 0.3] },
			{ name: 'disguise_gym_wristbands', pos: [-0.4, 0.68, 0.25] },
			{ name: 'disguise_gym_headband', pos: [-0.4, 1.45, 0] },
			{ name: 'folded_gym_tank', pos: [0.6, 0.03, 0.2], rotY: 0.3 },
			{ name: 'folded_gym_wristbands', pos: [0.6, 0.035, 0.6] },
		],
		cam: { pos: [0.3, 1.2, 3.0], target: [0.1, 0.7, 0], fov: 40 },
	},
	thief_disguise: {
		items: [
			{ name: 'cop_0', pos: [-0.4, 0, 0] },
			{ name: 'disguise_thief_shirt', pos: [-0.4, 0.95, 0.3] },
			{ name: 'disguise_thief_mask', pos: [-0.4, 1.33, 0.21] },
			{ name: 'disguise_thief_beanie', pos: [-0.4, 1.42, 0] },
			{ name: 'disguise_thief_mask', pos: [0.45, 0.04, 0.2] },
			{ name: 'disguise_thief_beanie', pos: [0.75, 0.08, -0.2] },
			{ name: 'folded_thief_shirt', pos: [0.5, 0.04, -0.35] },
		],
		cam: { pos: [0.3, 1.2, 3.0], target: [0.1, 0.7, 0], fov: 40 },
	},
	chef_disguise: {
		items: [
			{ name: 'cop_0', pos: [-0.4, 0, 0] },
			{ name: 'disguise_chef_apron', pos: [-0.4, 0.95, 0.3] },
			{ name: 'disguise_chef_mustache', pos: [-0.4, 1.22, 0.2] },
			{ name: 'disguise_chef_hat', pos: [-0.4, 1.42, 0] },
			{ name: 'disguise_chef_mustache', pos: [0.45, 0.03, 0.2] },
			{ name: 'disguise_chef_hat', pos: [0.75, 0.06, -0.2] },
			{ name: 'folded_chef_apron', pos: [0.5, 0.04, -0.35] },
		],
		cam: { pos: [0.3, 1.2, 3.0], target: [0.1, 0.8, 0], fov: 40 },
	},
	chess_disguise: {
		items: [
			{ name: 'cop_0', pos: [-0.4, 0, 0] },
			{ name: 'disguise_chess_vest', pos: [-0.4, 0.95, 0.3] },
			{ name: 'disguise_chess_glasses', pos: [-0.4, 1.33, 0.21] },
			{ name: 'disguise_chess_beret', pos: [-0.4, 1.42, 0] },
			{ name: 'disguise_chess_glasses', pos: [0.45, 0.05, 0.2] },
			{ name: 'disguise_chess_beret', pos: [0.75, 0.0, -0.2] },
			{ name: 'folded_chess_vest', pos: [0.5, 0.04, -0.35] },
		],
		cam: { pos: [0.3, 1.2, 3.0], target: [0.1, 0.8, 0], fov: 40 },
	},
	biker_disguise: {
		items: [
			{ name: 'cop_0', pos: [-0.4, 0, 0] },
			{ name: 'disguise_biker_jacket', pos: [-0.4, 0.95, 0.3] },
			{ name: 'disguise_biker_beard', pos: [-0.4, 1.17, 0.2] },
			{ name: 'disguise_biker_bandana', pos: [-0.4, 1.42, 0] },
			{ name: 'disguise_biker_beard', pos: [0.45, 0.4, 0.2] },
			{ name: 'disguise_biker_bandana', pos: [0.75, 0.0, -0.2] },
			{ name: 'folded_biker_jacket', pos: [0.5, 0.05, -0.35] },
		],
		cam: { pos: [0.3, 1.2, 3.0], target: [0.1, 0.8, 0], fov: 40 },
	},
};
