// Small props of the hardware store "El Tornillo Flojo" (docs/diseno/ferreteria.md): the fragile paint cans of its
// display and the glass screw jars on its counter, with origins at the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// The colors of the paint cans: the lid and the label stripe match the paint inside.
const PAINTS = [0xe8473c, 0x3c7be8, 0xf2c230, 0x4cb860, 0xf4f1ea, 0x8a4cc8];

// A paint can: 0.17 m across, 0.19 m tall, tin with a colored lid, label and a wire handle.
export function buildPaintCan(i) {
	const b = new Builder(`paint_can_${i}`);
	const tin = mat('tin', 0xc8ccd2), paint = mat(`paint_${i}`, PAINTS[i]), label = mat('paint_label', 0xfaf6ee);
	b.add('can', tin, new THREE.CylinderGeometry(0.085, 0.085, 0.18, 10), { pos: V(0, -0.005, 0) });
	b.add('lid', paint, new THREE.CylinderGeometry(0.08, 0.08, 0.012, 10), { pos: V(0, 0.09, 0) });
	b.add('label', label, new THREE.CylinderGeometry(0.0865, 0.0865, 0.1, 10, 1, true, -1.1, 2.2), { pos: V(0, -0.01, 0) });
	b.add('label', paint, new THREE.CylinderGeometry(0.087, 0.087, 0.03, 10, 1, true, -1.1, 2.2), { pos: V(0, -0.01, 0) });
	b.add('handle', tin, new THREE.TorusGeometry(0.08, 0.004, 3, 10, Math.PI), { pos: V(0, 0.098, 0), rot: [-Math.PI / 2, 0, 0] });
	return b.build();
}

// A glass jar of screws: 0.1 m across, 0.15 m tall, with a red lid and screws inside.
export function buildScrewJar() {
	const b = new Builder('screw_jar');
	const glass = mat('jar_glass', 0xbfe4f2, { transparent: true, opacity: 0.45 });
	b.add('jar', glass, new THREE.CylinderGeometry(0.05, 0.05, 0.13, 8), { pos: V(0, -0.01, 0) });
	b.add('lid', mat('jar_lid', 0xd23a3a), new THREE.CylinderGeometry(0.045, 0.045, 0.02, 8), { pos: V(0, 0.065, 0) });
	const steel = mat('screw_steel', 0x9aa0a8);
	for (let i = 0; i < 9; i++) {
		const a = i * 2.4;
		b.add('screws', steel, new THREE.CylinderGeometry(0.005, 0.005, 0.04, 4),
			{ pos: V(Math.cos(a) * 0.025, -0.055 + (i % 3) * 0.012, Math.sin(a) * 0.025), rot: [i * 0.7, 0, 1.2] });
	}
	return b.build();
}

// The tools for sale on the gondolas, lying flat with their length along X and a little orange price tag.
function priceTag(b, at) {
	b.add('tag', mat('price_tag', 0xff9a2a), new THREE.BoxGeometry(0.03, 0.002, 0.02), { pos: at });
}

// A hammer: 0.3 m long, wooden handle and a steel head.
export function buildHammer() {
	const b = new Builder('tool_hammer');
	b.add('handle', mat('tool_wood', 0xc8945a), new THREE.BoxGeometry(0.28, 0.025, 0.03), { pos: V(-0.02, 0, 0) });
	b.add('head', mat('tool_steel', 0x7a8088), new THREE.BoxGeometry(0.04, 0.035, 0.11), { pos: V(0.12, 0.003, 0) });
	priceTag(b, V(-0.08, 0.014, 0));
	return b.build();
}

// An adjustable wrench: 0.25 m long, all steel, with an open jaw.
export function buildWrench() {
	const b = new Builder('tool_wrench');
	const steel = mat('tool_chrome', 0xb8bcc4);
	b.add('handle', steel, new THREE.BoxGeometry(0.2, 0.015, 0.03), { pos: V(-0.02, 0, 0) });
	for (const s of [-1, 1]) b.add('jaw', steel, new THREE.BoxGeometry(0.05, 0.02, 0.018), { pos: V(0.1, 0, s * 0.025) });
	priceTag(b, V(-0.06, 0.009, 0));
	return b.build();
}

// A hand saw: 0.45 m long, a wide blade and a red handle.
export function buildSaw() {
	const b = new Builder('tool_saw');
	b.add('blade', mat('saw_blade', 0xd8dce2), new THREE.BoxGeometry(0.34, 0.006, 0.1), { pos: V(0.06, 0, 0) });
	b.add('handle', mat('saw_handle', 0xd23a3a), new THREE.BoxGeometry(0.1, 0.03, 0.12), { pos: V(-0.17, 0.006, 0) });
	priceTag(b, V(0.0, 0.004, 0.02));
	return b.build();
}

// A screwdriver: 0.22 m long, yellow handle and a thin steel shaft.
export function buildScrewdriver() {
	const b = new Builder('tool_screwdriver');
	b.add('handle', mat('handle_yellow_tool', 0xf2c230), new THREE.CylinderGeometry(0.016, 0.016, 0.09, 6), { pos: V(-0.065, 0, 0), rot: [0, 0, Math.PI / 2] });
	b.add('shaft', mat('tool_chrome', 0xb8bcc4), new THREE.CylinderGeometry(0.004, 0.004, 0.13, 4), { pos: V(0.045, 0, 0), rot: [0, 0, Math.PI / 2] });
	priceTag(b, V(-0.065, 0.017, 0));
	return b.build();
}

// Don Cosme's new key, fresh from the machine: 0.07 m long, shiny brass, lying flat.
export function buildKeyCopy() {
	const b = new Builder('key_copy');
	const brass = mat('key_brass', 0xf2c84a, { metalness: 0.5, roughness: 0.4 });
	b.add('bow', brass, new THREE.CylinderGeometry(0.018, 0.018, 0.006, 8), { pos: V(-0.025, 0, 0) });
	b.add('blade', brass, new THREE.BoxGeometry(0.05, 0.006, 0.012), { pos: V(0.02, 0, 0) });
	for (const x of [0.02, 0.035]) b.add('teeth', brass, new THREE.BoxGeometry(0.006, 0.006, 0.008), { pos: V(x, 0, -0.009) });
	return b.build();
}

// The master key ring (las llaves maestras): a fat steel ring with a brass key for every house on the block and a
// paper tag. 0.22 m across.
export function buildKeyRing() {
	const b = new Builder('master_key_ring');
	b.add('ring', mat('ring_steel', 0xb8bcc4, { metalness: 0.5, roughness: 0.4 }), new THREE.TorusGeometry(0.06, 0.008, 4, 14), { rot: [Math.PI / 2, 0, 0] });
	const brass = mat('key_brass', 0xf2c84a, { metalness: 0.5, roughness: 0.4 });
	for (let i = 0; i < 14; i++) {
		const a = (i / 14) * Math.PI * 2;
		const out = V(Math.cos(a), 0, Math.sin(a));
		b.add('keys', brass, new THREE.BoxGeometry(0.06, 0.006, 0.014), { pos: out.clone().multiplyScalar(0.095), rot: [0, -a, 0] });
		b.add('keys', brass, new THREE.CylinderGeometry(0.012, 0.012, 0.006, 6), { pos: out.clone().multiplyScalar(0.065) });
	}
	b.add('tag', mat('tag_paper', 0xfaf6ee), new THREE.BoxGeometry(0.04, 0.004, 0.06), { pos: V(0, 0.006, 0.02) });
	return b.build();
}

// The wax molds: a tin tray with three soft wax blocks, each with a key pressed in. 0.15 m long.
export function buildWaxMolds() {
	const b = new Builder('wax_molds');
	b.add('tray', mat('tin', 0xc8ccd2), new THREE.BoxGeometry(0.15, 0.015, 0.08), { pos: V(0, -0.005, 0) });
	const wax = mat('wax', 0xe8c060);
	for (const x of [-0.045, 0, 0.045]) {
		b.add('wax', wax, new THREE.BoxGeometry(0.04, 0.02, 0.06), { pos: V(x, 0.012, 0) });
		b.add('print', mat('wax_print', 0xa8823a), new THREE.BoxGeometry(0.008, 0.002, 0.04), { pos: V(x, 0.023, 0) });
	}
	return b.build();
}

// The list of addresses: a sheet with columns of house numbers and ticks. 0.21 x 0.15 m.
export function buildAddressList() {
	const b = new Builder('address_list');
	b.add('paper', mat('paper', 0xfaf6ee), new THREE.BoxGeometry(0.21, 0.004, 0.15));
	const ink = mat('ink', 0x2a3a6a);
	for (let i = 0; i < 7; i++) b.add('lines', ink, new THREE.BoxGeometry(0.14, 0.001, 0.006), { pos: V(-0.02, 0.0025, -0.055 + i * 0.018) });
	const tick = mat('tick_red', 0xd23a3a);
	for (let i = 0; i < 7; i += 2) b.add('ticks', tick, new THREE.BoxGeometry(0.012, 0.001, 0.012), { pos: V(0.075, 0.0025, -0.055 + i * 0.018) });
	return b.build();
}

// Fresh metal filings: a little grey heap of shavings. 0.12 m across.
export function buildFilings() {
	const b = new Builder('metal_filings');
	const steel = mat('filings', 0x9aa0a8, { metalness: 0.4 });
	for (let i = 0; i < 18; i++) {
		const a = i * 2.39, r = 0.012 + (i % 6) * 0.008;
		b.add('filings', steel, new THREE.BoxGeometry(0.012, 0.003, 0.003), { pos: V(Math.cos(a) * r, 0.002 + (i % 3) * 0.002, Math.sin(a) * r), rot: [0, a * 1.7, 0] });
	}
	return b.build();
}

// The hats of the garden gnomes for sale; the boss gnome wears the first one, like a third of the others.
const GNOME_HATS = [0xd23a3a, 0x3c7be8, 0x4cb860];

// A ceramic garden gnome: 0.5 m tall, a round blue coat, a white beard, a pointy hat and a little shovel.
export function buildGnome(i) {
	const b = new Builder(`garden_gnome_${i}`);
	b.add('body', mat('gnome_coat', 0x3a5ab0), ellipsoid(0.13, 0.15, 0.12, 8, 5), { pos: V(0, 0.15, 0) });
	b.add('belt', mat('gnome_belt', 0x2a2420), new THREE.CylinderGeometry(0.125, 0.125, 0.025, 8), { pos: V(0, 0.17, 0) });
	b.add('head', mat('gnome_skin', 0xf3c8a0), ellipsoid(0.08, 0.08, 0.08, 8, 5), { pos: V(0, 0.32, 0.01) });
	b.add('nose', mat('gnome_nose', 0xe89a80), ellipsoid(0.025, 0.025, 0.025, 5, 3), { pos: V(0, 0.32, 0.09) });
	b.add('beard', mat('gnome_beard', 0xf6f2ea), new THREE.ConeGeometry(0.07, 0.14, 7), { pos: V(0, 0.24, 0.07), rot: [Math.PI, 0, 0] });
	b.add('hat', mat(`gnome_hat_${i}`, GNOME_HATS[i]), new THREE.ConeGeometry(0.085, 0.2, 8), { pos: V(0, 0.46, 0), rot: [-0.15, 0, 0] });
	b.add('boots', mat('gnome_boots', 0x2a2420), new THREE.BoxGeometry(0.2, 0.04, 0.1), { pos: V(0, 0.02, 0.03) });
	return b.build();
}

// The list of watches: a crumpled sheet with brand names and a drawing of a clock. 0.21 x 0.15 m.
export function buildWatchList() {
	const b = new Builder('watch_list');
	b.add('paper', mat('paper', 0xfaf6ee), new THREE.BoxGeometry(0.21, 0.004, 0.15), { rot: [0, 0, 0.03] });
	const ink = mat('ink', 0x2a3a6a);
	for (let i = 0; i < 6; i++) b.add('lines', ink, new THREE.BoxGeometry(0.12, 0.001, 0.006), { pos: V(-0.03, 0.0025, -0.05 + i * 0.02) });
	b.add('clock', mat('ink_red', 0xd23a3a), new THREE.TorusGeometry(0.025, 0.003, 3, 12), { pos: V(0.065, 0.003, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// A tube of ceramic glue, half squeezed. 0.15 m long.
export function buildGlueTube() {
	const b = new Builder('glue_tube');
	b.add('tube', mat('glue_tube', 0xf0f0f0), new THREE.CylinderGeometry(0.02, 0.015, 0.12, 6), { rot: [0, 0, Math.PI / 2] });
	b.add('band', mat('glue_band', 0xf2c230), new THREE.CylinderGeometry(0.0205, 0.0205, 0.04, 6), { pos: V(-0.01, 0, 0), rot: [0, 0, Math.PI / 2] });
	b.add('cap', mat('glue_cap', 0xd23a3a), new THREE.ConeGeometry(0.012, 0.03, 6), { pos: V(0.075, 0, 0), rot: [0, 0, -Math.PI / 2] });
	return b.build();
}

// The little drawer of golden screws: a cardboard drawer front like the 60 on the wall, full of shiny gold screws.
// 0.3 x 0.12 x 0.3 m.
export function buildGoldDrawer() {
	const b = new Builder('gold_screw_drawer');
	const card = mat('drawer_card', 0xd8c09a);
	b.add('bottom', card, new THREE.BoxGeometry(0.3, 0.01, 0.3), { pos: V(0, -0.055, 0) });
	b.add('side', card, new THREE.BoxGeometry(0.01, 0.12, 0.3), { pos: V(-0.145, 0, 0) });
	b.add('side', card, new THREE.BoxGeometry(0.01, 0.12, 0.3), { pos: V(0.145, 0, 0) });
	b.add('side', card, new THREE.BoxGeometry(0.3, 0.12, 0.01), { pos: V(0, 0, -0.145) });
	b.add('front', mat('drawer_front', 0xe8d4b0), new THREE.BoxGeometry(0.3, 0.12, 0.01), { pos: V(0, 0, 0.145) });
	b.add('pull', mat('drawer_pull', 0x2a2420), new THREE.BoxGeometry(0.08, 0.02, 0.02), { pos: V(0, 0.01, 0.16) });
	const gold = mat('gold', 0xf2c230, { metalness: 0.8, roughness: 0.25 });
	for (let i = 0; i < 30; i++) {
		const a = i * 2.39, r = 0.02 + (i % 6) * 0.02;
		b.add('screws', gold, new THREE.CylinderGeometry(0.008, 0.008, 0.05, 5),
			{ pos: V(Math.cos(a) * r, -0.03 + (i % 3) * 0.012, Math.sin(a) * r * 0.9), rot: [i * 0.7, a, 1.3] });
	}
	return b.build();
}

// The screw mold: a grey steel block with screw-shaped grooves. 0.2 x 0.06 x 0.12 m.
export function buildScrewMold() {
	const b = new Builder('screw_mold');
	b.add('block', mat('mold_steel', 0x7a8088), new THREE.BoxGeometry(0.2, 0.06, 0.12));
	const groove = mat('mold_groove', 0x3a3e44);
	for (let i = 0; i < 5; i++) b.add('grooves', groove, new THREE.BoxGeometry(0.012, 0.004, 0.08), { pos: V(-0.07 + i * 0.035, 0.03, 0) });
	b.add('drip', mat('gold', 0xf2c230, { metalness: 0.8, roughness: 0.25 }), new THREE.BoxGeometry(0.03, 0.005, 0.03), { pos: V(0.07, 0.031, 0.03) });
	return b.build();
}

export const models = {
	...Object.fromEntries(PAINTS.map((_, i) => [`paint_can_${i}`, () => buildPaintCan(i)])),
	screw_jar: buildScrewJar,
	key_copy: buildKeyCopy, master_key_ring: buildKeyRing, wax_molds: buildWaxMolds, address_list: buildAddressList,
	metal_filings: buildFilings, watch_list: buildWatchList, glue_tube: buildGlueTube,
	gold_screw_drawer: buildGoldDrawer, screw_mold: buildScrewMold,
	...Object.fromEntries(GNOME_HATS.map((_, i) => [`garden_gnome_${i}`, () => buildGnome(i)])),
	tool_hammer: buildHammer, tool_wrench: buildWrench, tool_saw: buildSaw, tool_screwdriver: buildScrewdriver,
};

export const views = {
	hardware: {
		items: [
			{ name: 'paint_can_0', pos: [-0.2, 0.095, 0] }, { name: 'paint_can_1', pos: [0, 0.095, -0.05] },
			{ name: 'paint_can_2', pos: [0.2, 0.095, 0] }, { name: 'screw_jar', pos: [0.05, 0.075, 0.2] },
		],
		cam: { pos: [0, 0.4, 0.9], target: [0, 0.08, 0], fov: 36 },
	},
	master_keys_goods: {
		items: [
			{ name: 'master_key_ring', pos: [-0.15, 0.01, 0] }, { name: 'wax_molds', pos: [0.15, 0.015, -0.05] },
			{ name: 'address_list', pos: [0.1, 0.002, 0.15], rotY: 0.3 }, { name: 'metal_filings', pos: [-0.2, 0, 0.2] },
		],
		cam: { pos: [0, 0.5, 0.6], target: [0, 0, 0.05], fov: 40 },
	},
	gnome_goods: {
		items: [
			{ name: 'garden_gnome_0', pos: [-0.35, 0, 0] }, { name: 'garden_gnome_1', pos: [0, 0, -0.1] },
			{ name: 'garden_gnome_2', pos: [0.35, 0, 0] }, { name: 'watch_list', pos: [-0.15, 0.002, 0.35] },
			{ name: 'glue_tube', pos: [0.2, 0.02, 0.35] },
		],
		cam: { pos: [0, 0.6, 1.3], target: [0, 0.2, 0.1], fov: 40 },
	},
	gold_goods: {
		items: [
			{ name: 'gold_screw_drawer', pos: [-0.2, 0.06, 0] }, { name: 'screw_mold', pos: [0.18, 0.03, -0.05] },
			{ name: 'jewelry_bag', pos: [0.15, 0.05, 0.2] },
		],
		cam: { pos: [0, 0.55, 0.8], target: [0, 0.04, 0.05], fov: 40 },
	},
	hardware_tools: {
		items: [
			{ name: 'tool_hammer', pos: [-0.25, 0.02, -0.1] }, { name: 'tool_wrench', pos: [0.2, 0.01, -0.12] },
			{ name: 'tool_saw', pos: [-0.1, 0.01, 0.15] }, { name: 'tool_screwdriver', pos: [0.28, 0.02, 0.12] },
		],
		cam: { pos: [0, 0.6, 0.8], target: [0, 0, 0], fov: 40 },
	},
};
