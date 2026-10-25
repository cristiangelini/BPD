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

export const models = {
	disguise_wig: buildDisguiseWig, disguise_mustache: buildDisguiseMustache, disguise_glasses: buildDisguiseGlasses,
	disguise_robe: buildDisguiseRobe, folded_robe: buildFoldedRobe, songbook: buildSongbook,
	disguise_cleaner_cap: buildCleanerCap, disguise_face_mask: buildFaceMask, disguise_cleaner_vest: buildCleanerVest,
	folded_vest: buildFoldedVest,
	disguise_mime_beret: buildMimeBeret, disguise_mime_face: buildMimeFace, disguise_mime_shirt: buildMimeShirt,
	folded_mime_shirt: buildFoldedMimeShirt,
	disguise_party_cap: buildPartyCap, disguise_party_mustache: buildPartyMustache, disguise_party_badge: buildPartyBadge,
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
};
