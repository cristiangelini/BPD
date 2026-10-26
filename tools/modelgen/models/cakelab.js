// Props of the cake lab "Dulce Ciencia" (docs/diseno/laboratorio.md): the industrial oven, the giant mixer and the
// flavor lab's microscope, with origins at the floor in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// An industrial oven 1.2 m wide, 1.6 m tall and 0.9 m deep, its front to +Z: steel body, a dark glass door with a
// handle, a red knob and a little orange light.
export function buildLabOven() {
	const b = new Builder('lab_oven');
	const steel = mat('oven_steel', 0xb8bcc4);
	b.add('body', steel, new THREE.BoxGeometry(1.2, 1.6, 0.9), { pos: V(0, 0.8, 0) });
	b.add('door', mat('oven_glass', 0x2a2e36), new THREE.BoxGeometry(0.9, 0.7, 0.02), { pos: V(0, 0.75, 0.455) });
	b.add('glow', mat('oven_glow', 0xe88a3a), new THREE.BoxGeometry(0.8, 0.05, 0.01), { pos: V(0, 0.5, 0.466) });
	b.add('handle', mat('oven_handle', 0x2a2a2e), new THREE.BoxGeometry(0.7, 0.04, 0.05), { pos: V(0, 1.15, 0.48) });
	b.add('panel', mat('oven_panel', 0x5a5e66), new THREE.BoxGeometry(1.1, 0.25, 0.02), { pos: V(0, 1.4, 0.455) });
	b.add('knob', mat('oven_knob', 0xd23a3a), new THREE.CylinderGeometry(0.05, 0.05, 0.04, 10), { pos: V(0.4, 1.4, 0.48), rot: [Math.PI / 2, 0, 0] });
	b.add('light', mat('oven_light', 0xf2a03a), ellipsoid(0.02, 0.02, 0.01, 6, 3), { pos: V(-0.4, 1.4, 0.47) });
	for (const s of [-1, 1]) b.add('feet', mat('oven_feet', 0x2a2a2e), new THREE.BoxGeometry(0.08, 0.06, 0.8), { pos: V(s * 0.5, 0.03, 0) });
	return b.build();
}

// A giant stand mixer 1.5 m tall: a pastel base, an arched arm over a steel bowl 0.7 m across, and a whisk inside.
export function buildGiantMixer() {
	const b = new Builder('giant_mixer');
	const mint = mat('mixer_mint', 0x9ad8c0), steel = mat('bowl_steel', 0xc8ccd2);
	b.add('base', mint, new THREE.BoxGeometry(0.9, 0.2, 0.9), { pos: V(0, 0.1, 0) });
	b.add('column', mint, new THREE.BoxGeometry(0.3, 1.2, 0.3), { pos: V(0, 0.8, -0.35) });
	b.add('head', mint, new THREE.BoxGeometry(0.35, 0.3, 0.8), { pos: V(0, 1.35, -0.05) });
	b.add('bowl', steel, new THREE.CylinderGeometry(0.35, 0.25, 0.5, 14, 1, true), { pos: V(0, 0.55, 0.05) });
	b.add('bowl', steel, new THREE.CylinderGeometry(0.25, 0.25, 0.02, 14), { pos: V(0, 0.3, 0.05) });
	b.add('dough', mat('dough', 0xf2e2b8), ellipsoid(0.28, 0.08, 0.28, 10, 4), { pos: V(0, 0.45, 0.05) });
	for (let i = 0; i < 4; i++) b.add('whisk', steel, new THREE.TorusGeometry(0.12, 0.008, 4, 10, Math.PI), { pos: V(0, 0.75, 0.05), rot: [0, (i / 4) * Math.PI, Math.PI] });
	b.add('shaft', steel, new THREE.CylinderGeometry(0.02, 0.02, 0.3, 6), { pos: V(0, 1.05, 0.05) });
	b.add('switch', mat('oven_knob', 0xd23a3a), new THREE.BoxGeometry(0.06, 0.06, 0.04), { pos: V(0.18, 1.35, 0.2) });
	return b.build();
}

// The flavor lab's microscope, 0.45 m tall, white with a black eyepiece.
export function buildMicroscope() {
	const b = new Builder('microscope');
	const white = mat('scope_white', 0xf2f2ee), black = mat('scope_black', 0x26262b);
	b.add('base', white, new THREE.BoxGeometry(0.2, 0.04, 0.25), { pos: V(0, 0.02, 0) });
	b.add('arm', white, new THREE.BoxGeometry(0.05, 0.3, 0.06), { pos: V(0, 0.19, -0.08) });
	b.add('stage', black, new THREE.BoxGeometry(0.14, 0.015, 0.12), { pos: V(0, 0.15, 0.02) });
	b.add('tube', white, new THREE.CylinderGeometry(0.025, 0.025, 0.2, 8), { pos: V(0, 0.3, 0.0), rot: [-0.4, 0, 0] });
	b.add('eyepiece', black, new THREE.CylinderGeometry(0.02, 0.02, 0.06, 8), { pos: V(0, 0.42, -0.05), rot: [-0.4, 0, 0] });
	return b.build();
}

// A rack of 6 test tubes 0.3 m wide with coloured syrups.
export function buildTestTubes() {
	const b = new Builder('test_tubes');
	b.add('rack', mat('rack_wood', 0x8a5a3a), new THREE.BoxGeometry(0.3, 0.04, 0.08), { pos: V(0, 0.08, 0) });
	b.add('rack', mat('rack_wood', 0x8a5a3a), new THREE.BoxGeometry(0.3, 0.02, 0.08), { pos: V(0, 0.01, 0) });
	const colors = [0xe84a8a, 0x4ad8a0, 0xf2d24a, 0x8a4ae8, 0xe88a3a, 0x4a8ae8];
	for (let i = 0; i < 6; i++) {
		b.add('glass', mat('tube_glass', 0xdfeef2), new THREE.CylinderGeometry(0.014, 0.014, 0.16, 6), { pos: V(-0.125 + i * 0.05, 0.1, 0) });
		b.add('syrup', mat('syrup_' + i, colors[i]), new THREE.CylinderGeometry(0.012, 0.012, 0.08, 6), { pos: V(-0.125 + i * 0.05, 0.065, 0) });
	}
	return b.build();
}

// The silver-filled cake (laboratorio.md, "El pastel relleno de plata"): three pink tiers 0.5 m across and 0.6 m tall on
// a board, with the corners of green banknotes sticking out between the tiers.
export function buildSilverCake() {
	const b = new Builder('silver_cake');
	const pink = mat('cake_pink', 0xf2a6c0), cream = mat('cake_cream', 0xfaf2e4), bill = mat('bill_green', 0x6ab06a);
	b.add('board', mat('cake_board', 0xd8d8dc), new THREE.CylinderGeometry(0.27, 0.27, 0.02, 18), { pos: V(0, 0.01, 0) });
	const tiers = [[0.25, 0.22, 0.02], [0.19, 0.18, 0.24], [0.13, 0.16, 0.42]];
	for (const [r, h, y] of tiers) {
		b.add('tier', pink, new THREE.CylinderGeometry(r, r, h, 18), { pos: V(0, y + h / 2, 0) });
		b.add('cream', cream, new THREE.TorusGeometry(r, 0.02, 4, 18), { pos: V(0, y + h, 0), rot: [Math.PI / 2, 0, 0] });
	}
	for (let i = 0; i < 7; i++) {
		const a = (i / 7) * Math.PI * 2, r = i % 2 ? 0.2 : 0.25, y = i % 2 ? 0.42 : 0.24;
		b.add('bills', bill, new THREE.BoxGeometry(0.08, 0.004, 0.05), { pos: V(Math.cos(a) * r, y, Math.sin(a) * r), rot: [0.3, -a, 0.2] });
	}
	b.add('cherry', mat('cherry', 0xd23a3a), ellipsoid(0.03, 0.03, 0.03, 8, 6), { pos: V(0, 0.6, 0) });
	return b.build();
}

// A silicone mold shaped like a banknote, 0.3 x 0.16 m: the sweet bills come out of it.
export function buildBillMold() {
	const b = new Builder('bill_mold');
	const silicone = mat('mold_red', 0xd84a4a);
	b.add('base', silicone, new THREE.BoxGeometry(0.3, 0.015, 0.16), { pos: V(0, 0.0075, 0) });
	for (const [x, z, w, d] of [[0, 0.075, 0.3, 0.01], [0, -0.075, 0.3, 0.01], [0.145, 0, 0.01, 0.16], [-0.145, 0, 0.01, 0.16]]) b.add('rim', silicone, new THREE.BoxGeometry(w, 0.035, d), { pos: V(x, 0.0175, z) });
	b.add('relief', mat('mold_relief', 0xb83a3a), new THREE.CylinderGeometry(0.035, 0.035, 0.01, 12), { pos: V(0, 0.02, 0) });
	b.add('relief', mat('mold_relief', 0xb83a3a), new THREE.BoxGeometry(0.05, 0.01, 0.02), { pos: V(-0.09, 0.02, 0.03) });
	return b.build();
}

// The "special orders" notebook: a pink spiral notebook with a gold dollar-ish sign of a cake on the cover.
export function buildOrdersNotebook() {
	const b = new Builder('orders_notebook');
	b.add('cover', mat('notebook_pink', 0xe86a9a), new THREE.BoxGeometry(0.15, 0.02, 0.21), { pos: V(0, 0.01, 0) });
	b.add('pages', mat('notebook_pages', 0xfaf6ea), new THREE.BoxGeometry(0.14, 0.016, 0.2), { pos: V(0.004, 0.01, 0) });
	for (let i = 0; i < 7; i++) b.add('spiral', mat('spiral', 0x9a9aa2), new THREE.TorusGeometry(0.008, 0.002, 4, 8), { pos: V(-0.075, 0.01, -0.09 + i * 0.03), rot: [0, Math.PI / 2, 0] });
	b.add('label', mat('label_gold', 0xe0b84a), new THREE.CylinderGeometry(0.03, 0.03, 0.002, 12), { pos: V(0.01, 0.021, 0) });
	return b.build();
}

export function buildRecipeBook() {
	const b = new Builder('recipe_book');
	b.add('cover', mat('recipe_blue', 0x3f6fb5), new THREE.BoxGeometry(0.18, 0.035, 0.24), { pos: V(0, 0.0175, 0) });
	b.add('pages', mat('notebook_pages', 0xfaf6ea), new THREE.BoxGeometry(0.17, 0.028, 0.23), { pos: V(0.006, 0.0175, 0) });
	b.add('logo', mat('logo_yellow', 0xf2d24a), new THREE.CylinderGeometry(0.045, 0.045, 0.003, 5), { pos: V(0, 0.036, 0.02) });
	b.add('logo_dot', mat('logo_red', 0xd94a3a), new THREE.CylinderGeometry(0.018, 0.018, 0.004, 10), { pos: V(0, 0.037, 0.02) });
	b.add('frosting', mat('frosting_pink', 0xf4b6c8), new THREE.BoxGeometry(0.06, 0.01, 0.04), { pos: V(0.06, 0.036, -0.09) });
	return b.build();
}

export function buildDisguisePhoto() {
	const b = new Builder('disguise_photo');
	b.add('paper', mat('photo_white', 0xf4f1ea), new THREE.BoxGeometry(0.1, 0.004, 0.14), { pos: V(0, 0.002, 0) });
	b.add('picture', mat('photo_sky', 0x8fb7d6), new THREE.BoxGeometry(0.086, 0.002, 0.1), { pos: V(0, 0.005, 0.01) });
	b.add('body', mat('uniform_brown', 0x8a5a2b), new THREE.BoxGeometry(0.03, 0.001, 0.045), { pos: V(0, 0.0065, 0.0) });
	b.add('face', mat('skin', 0xe8b48f), new THREE.CylinderGeometry(0.012, 0.012, 0.001, 10), { pos: V(0, 0.0065, -0.035) });
	b.add('mustache', mat('mustache', 0x2a1d14), new THREE.BoxGeometry(0.016, 0.001, 0.003), { pos: V(0, 0.0072, -0.031) });
	return b.build();
}

export function buildDeliveryCap() {
	const b = new Builder('delivery_cap');
	b.add('crown', mat('cap_brown', 0x8a5a2b), new THREE.SphereGeometry(0.1, 10, 6, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(0, 0.0, 0), scale: [1, 0.7, 1] });
	b.add('visor', mat('cap_brown_dark', 0x6b431f), new THREE.BoxGeometry(0.12, 0.01, 0.08), { pos: V(0, 0.005, 0.12) });
	b.add('badge', mat('logo_yellow', 0xf2d24a), new THREE.BoxGeometry(0.04, 0.025, 0.004), { pos: V(0, 0.04, 0.09), rot: [-0.4, 0, 0] });
	return b.build();
}

export function buildSleepPowderJar() {
	const b = new Builder('sleep_powder_jar');
	b.add('glass', mat('jar_glass', 0xbfd8e8), new THREE.CylinderGeometry(0.07, 0.07, 0.16, 12), { pos: V(0, 0.08, 0) });
	b.add('powder', mat('powder_lilac', 0xc9a8e6), new THREE.CylinderGeometry(0.064, 0.064, 0.11, 12), { pos: V(0, 0.06, 0) });
	b.add('lid', mat('lid_purple', 0x6a3f9a), new THREE.CylinderGeometry(0.075, 0.075, 0.025, 12), { pos: V(0, 0.172, 0) });
	b.add('label', mat('photo_white', 0xf4f1ea), new THREE.BoxGeometry(0.07, 0.05, 0.004), { pos: V(0, 0.09, 0.071) });
	for (let i = 0; i < 3; i++) b.add('z', mat('lid_purple', 0x6a3f9a), new THREE.BoxGeometry(0.014 + i * 0.004, 0.003, 0.002), { pos: V(-0.015 + i * 0.015, 0.08 + i * 0.012, 0.074) });
	return b.build();
}

export function buildSleepersList() {
	const b = new Builder('sleepers_list');
	b.add('paper', mat('photo_white', 0xf4f1ea), new THREE.BoxGeometry(0.15, 0.004, 0.21), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 6; i++) b.add('line', mat('ink_blue', 0x34408f), new THREE.BoxGeometry(0.09, 0.001, 0.008), { pos: V(-0.02, 0.0045, -0.08 + i * 0.03) });
	for (let i = 0; i < 6; i++) b.add('tick', mat('logo_red', 0xd94a3a), new THREE.BoxGeometry(0.015, 0.001, 0.015), { pos: V(0.05, 0.0045, -0.08 + i * 0.03) });
	return b.build();
}

export function buildMeasuringSpoon() {
	const b = new Builder('measuring_spoon');
	b.add('bowl', mat('steel_spoon', 0xc8ccd2), new THREE.SphereGeometry(0.09, 10, 6, 0, Math.PI * 2, Math.PI / 2, Math.PI / 2), { pos: V(0, 0.09, 0) });
	b.add('handle', mat('steel_spoon', 0xc8ccd2), new THREE.BoxGeometry(0.04, 0.02, 0.4), { pos: V(0, 0.08, 0.27) });
	b.add('mark', mat('lid_purple', 0x6a3f9a), new THREE.BoxGeometry(0.03, 0.004, 0.06), { pos: V(0, 0.092, 0.35) });
	return b.build();
}

export function buildCakeSlices() {
	const b = new Builder('cake_slices');
	b.add('plate', mat('plate_white', 0xf6f6f2), new THREE.CylinderGeometry(0.2, 0.18, 0.02, 16), { pos: V(0, 0.01, 0) });
	for (let i = 0; i < 5; i++) {
		const a = i * Math.PI * 2 / 5;
		b.add('slice', mat('sponge', 0xf1d9a0), new THREE.CylinderGeometry(0.06, 0.06, 0.06, 3), { pos: V(Math.cos(a) * 0.1, 0.05, Math.sin(a) * 0.1), rot: [0, a, 0] });
		b.add('cream', mat('frosting_lilac', 0xd8b8ee), new THREE.CylinderGeometry(0.06, 0.06, 0.012, 3), { pos: V(Math.cos(a) * 0.1, 0.086, Math.sin(a) * 0.1), rot: [0, a, 0] });
	}
	return b.build();
}

export const models = {
	lab_oven: buildLabOven, giant_mixer: buildGiantMixer, microscope: buildMicroscope, test_tubes: buildTestTubes,
	silver_cake: buildSilverCake, bill_mold: buildBillMold, orders_notebook: buildOrdersNotebook,
	sleep_powder_jar: buildSleepPowderJar, sleepers_list: buildSleepersList, measuring_spoon: buildMeasuringSpoon,
	cake_slices: buildCakeSlices,
	recipe_book: buildRecipeBook, disguise_photo: buildDisguisePhoto, delivery_cap: buildDeliveryCap,
};

export const views = {
	sleepy_cakes: {
		items: [{ name: 'sleep_powder_jar', pos: [-0.25, 0, 0] }, { name: 'sleepers_list', pos: [0.05, 0, 0.15] }, { name: 'measuring_spoon', pos: [0.05, 0, -0.35] }, { name: 'cake_slices', pos: [0.4, 0, 0.1] }],
		cam: { pos: [0, 0.7, 1.1], target: [0.05, 0.05, -0.05], fov: 40 },
	},
	stolen_recipe: {
		items: [{ name: 'recipe_book', pos: [-0.15, 0, 0] }, { name: 'disguise_photo', pos: [0.12, 0, 0.12] }, { name: 'delivery_cap', pos: [0.15, 0, -0.12] }],
		cam: { pos: [0, 0.45, 0.6], target: [0, 0.03, 0], fov: 40 },
	},
	silver_cake: {
		items: [{ name: 'silver_cake', pos: [-0.3, 0, 0] }, { name: 'bill_mold', pos: [0.35, 0, 0.15] }, { name: 'orders_notebook', pos: [0.35, 0, -0.15] }],
		cam: { pos: [0, 0.9, 1.6], target: [0, 0.25, 0], fov: 40 },
	},
	cake_lab: {
		items: [
			{ name: 'lab_oven', pos: [-1.0, 0, 0] }, { name: 'giant_mixer', pos: [0.4, 0, 0.1] },
			{ name: 'microscope', pos: [1.2, 0, 0.3] }, { name: 'test_tubes', pos: [1.25, 0, -0.1] },
		],
		cam: { pos: [0, 1.4, 3.6], target: [0, 0.7, 0], fov: 40 },
	},
};
