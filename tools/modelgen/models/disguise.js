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

export const models = {
	disguise_wig: buildDisguiseWig, disguise_mustache: buildDisguiseMustache, disguise_glasses: buildDisguiseGlasses,
	disguise_robe: buildDisguiseRobe, folded_robe: buildFoldedRobe, songbook: buildSongbook,
	disguise_cleaner_cap: buildCleanerCap, disguise_face_mask: buildFaceMask, disguise_cleaner_vest: buildCleanerVest,
	folded_vest: buildFoldedVest,
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
};
