// The pizzeria raid (allanamiento-pizzeria.md, decision 490): the pizzeria's own things. The clay oven with its fire,
// the dough table with its marble top and flour, a dough ball and a slice of pizza for Tito. Plates, pizza boxes, flour
// sacks, the phone and the delivery scooter come from the restaurant, the bakery and the insurance office. Bottoms at
// y = 0, fronts toward +Z. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

const C = (name, color, opts) => mat(name, color, opts);
const clay = C('oven_clay', 0xc87850, { roughness: 0.95 });
const brick = C('oven_brick', 0x9a4a32, { roughness: 0.9 });
const dough = C('dough', 0xf0d8a8, { roughness: 0.9 });
const wood = C('table_wood', 0xa07848, { roughness: 0.85 });

export const models = {
	// The clay oven: a dome on a brick base, its arched mouth toward +Z with the fire glowing inside, a chimney and a
	// stack of firewood beside it. About 1.6 x 1.9 x 1.6 m; the mouth's floor at 0.9 m.
	clay_oven() {
		const b = new Builder('clay_oven');
		b.add('base', brick, new THREE.BoxGeometry(1.6, 0.9, 1.6), { pos: V(0, 0.45, 0) });
		b.add('dome', clay, ellipsoid(0.75, 0.6, 0.75, 14, 8), { pos: V(0, 0.9, 0) });
		b.add('mouth', C('oven_dark', 0x1a1210), new THREE.BoxGeometry(0.5, 0.32, 0.12), { pos: V(0, 1.06, 0.7) });
		b.add('mouth', brick, new THREE.TorusGeometry(0.27, 0.05, 4, 10, Math.PI), { pos: V(0, 1.06, 0.74) });
		b.add('fire', C('oven_fire', 0xff8a20, { emissive: 0xd84000, emissiveIntensity: 0.9 }), new THREE.ConeGeometry(0.1, 0.2, 6), { pos: V(0, 1.0, 0.77) });
		b.add('fire', C('oven_ember', 0xff4020, { emissive: 0xc02000, emissiveIntensity: 0.8 }), new THREE.BoxGeometry(0.3, 0.04, 0.06), { pos: V(0, 0.92, 0.77) });
		b.add('chimney', brick, new THREE.CylinderGeometry(0.1, 0.12, 0.5, 8), { pos: V(0, 1.65, -0.25) });
		for (let i = 0; i < 6; i++) {
			b.add('wood', C('firewood', 0x6a4a2a), new THREE.CylinderGeometry(0.05, 0.05, 0.5, 6), { pos: V(0.95, 0.05 + Math.floor(i / 3) * 0.09, 0.3 - (i % 3) * 0.11 - (i >= 3 ? 0.05 : 0)), rot: [0, 0, Math.PI / 2] });
		}
		return b.build();
	},
	// The dough table: a wooden table with a marble top dusted with flour, a rolling pin and a jar of tomato sauce.
	// About 2 x 0.9 x 0.9 m.
	dough_table() {
		const b = new Builder('dough_table');
		b.add('top', C('marble', 0xe8e4dc, { roughness: 0.3 }), new THREE.BoxGeometry(2.0, 0.06, 0.9), { pos: V(0, 0.87, 0) });
		for (const x of [-0.9, 0.9]) for (const z of [-0.38, 0.38]) b.add('legs', wood, new THREE.BoxGeometry(0.08, 0.84, 0.08), { pos: V(x, 0.42, z) });
		b.add('shelf', wood, new THREE.BoxGeometry(1.9, 0.04, 0.8), { pos: V(0, 0.2, 0) });
		b.add('flour', C('flour_dust', 0xfaf8f0), new THREE.BoxGeometry(0.7, 0.006, 0.5), { pos: V(-0.4, 0.903, 0.05) });
		b.add('pin', wood, new THREE.CylinderGeometry(0.035, 0.035, 0.45, 8), { pos: V(0.5, 0.94, 0.15), rot: [0, 0.3, Math.PI / 2] });
		b.add('jar', C('sauce_red', 0xc02818), new THREE.CylinderGeometry(0.07, 0.07, 0.16, 10), { pos: V(0.75, 0.98, -0.25) });
		return b.build();
	},
	// A ball of pizza dough, 0.2 m wide. Its origin at its bottom (it sits on the table and grows).
	dough_ball() {
		const b = new Builder('dough_ball');
		b.add('dough', dough, ellipsoid(0.1, 0.07, 0.1, 10, 6), { pos: V(0, 0.07, 0) });
		return b.build();
	},
	// A slice of pizza with melted cheese and two pepperoni, 0.25 m long, flat. Its origin at its middle.
	pizza_slice() {
		const b = new Builder('pizza_slice');
		b.add('crust', dough, new THREE.CylinderGeometry(0.25, 0.25, 0.02, 3, 1, false, -Math.PI / 6, Math.PI / 3), { pos: V(0, 0, -0.12) });
		b.add('cheese', C('pizza_cheese', 0xf0c040), new THREE.CylinderGeometry(0.22, 0.22, 0.022, 3, 1, false, -Math.PI / 6, Math.PI / 3), { pos: V(0, 0.002, -0.11) });
		b.add('crust', dough, new THREE.CylinderGeometry(0.025, 0.025, 0.24, 6), { pos: V(0, 0.01, 0.1), rot: [0, 0, Math.PI / 2] });
		for (const z of [-0.03, 0.04]) b.add('pepperoni', C('pepperoni', 0xb02820), new THREE.CylinderGeometry(0.03, 0.03, 0.026, 8), { pos: V(z * 0.4, 0.003, z) });
		return b.build();
	},
	// The jewels in the muzza story's main evidence: a frosty box of frozen pizzas, its lid lifted, with a gold necklace
	// and a ring spilling out of the cheese. 0.42 x 0.14 x 0.42 m.
	frozen_pizza_jewels() {
		const b = new Builder('frozen_pizza_jewels');
		const card = C('frozen_card', 0xe8eef4, { roughness: 0.7 });
		const gold = C('jewel_gold', 0xf8c828, { metalness: 0.6, roughness: 0.25 });
		b.add('box', card, new THREE.BoxGeometry(0.42, 0.1, 0.42), { pos: V(0, 0.05, 0) });
		b.add('frost', C('frost', 0xcfe8ff, { roughness: 0.4 }), new THREE.BoxGeometry(0.43, 0.012, 0.43), { pos: V(0, 0.1, 0) });
		b.add('lid', card, new THREE.BoxGeometry(0.42, 0.012, 0.42), { pos: V(0, 0.2, -0.2), rot: [-1.0, 0, 0] });
		b.add('label', C('frozen_label', 0x2a6ad0), new THREE.BoxGeometry(0.2, 0.004, 0.1), { pos: V(0, 0.108, 0.12) });
		b.add('cheese', C('pizza_cheese', 0xf0c040), new THREE.CylinderGeometry(0.17, 0.17, 0.02, 14), { pos: V(0, 0.115, -0.03) });
		b.add('necklace', gold, new THREE.TorusGeometry(0.08, 0.008, 4, 16), { pos: V(-0.05, 0.13, -0.05), rot: [Math.PI / 2, 0, 0] });
		b.add('ring', gold, new THREE.TorusGeometry(0.025, 0.007, 4, 10), { pos: V(0.09, 0.135, 0.02), rot: [Math.PI / 2, 0, 0] });
		b.add('gem', C('jewel_gem', 0xd02050, { roughness: 0.2 }), new THREE.OctahedronGeometry(0.018), { pos: V(0.09, 0.15, 0.045) });
		return b.build();
	},
	// The "clientes especiales" list: a sheet with a red heading and handwritten lines. 0.21 x 0.006 x 0.29 m, flat.
	special_clients_list() {
		const b = new Builder('special_clients_list');
		b.add('sheet', C('list_sheet', 0xfaf6ea), new THREE.BoxGeometry(0.21, 0.004, 0.29), { pos: V(0, 0.002, 0) });
		b.add('heading', C('list_red', 0xc02818), new THREE.BoxGeometry(0.17, 0.002, 0.03), { pos: V(0, 0.005, -0.11) });
		for (let i = 0; i < 6; i++) {
			b.add('lines', C('list_ink', 0x303060), new THREE.BoxGeometry(0.13 + (i % 2) * 0.03, 0.002, 0.008), { pos: V(0, 0.005, -0.06 + i * 0.03) });
		}
		return b.build();
	},
	// A half-eaten slice of pizza with a gold ring stuck in the cheese: the jewels story's clue in the yard's bin. 0.25 m.
	bitten_slice_ring() {
		const b = new Builder('bitten_slice_ring');
		b.add('crust', dough, new THREE.CylinderGeometry(0.25, 0.25, 0.02, 3, 1, false, -Math.PI / 6, Math.PI / 3), { pos: V(0, 0, -0.12) });
		b.add('cheese', C('pizza_cheese', 0xf0c040), new THREE.CylinderGeometry(0.22, 0.22, 0.022, 3, 1, false, -Math.PI / 6, Math.PI / 3), { pos: V(0, 0.002, -0.11) });
		b.add('ring', C('jewel_gold', 0xf8c828, { metalness: 0.6, roughness: 0.25 }), new THREE.TorusGeometry(0.022, 0.006, 4, 10), { pos: V(0.01, 0.02, -0.05) });
		return b.build();
	},
	// The crazy yeast story's main evidence: a 20-liter blue drum of contraband super yeast, foam spilling from the cap.
	// 0.32 x 0.5 x 0.32 m.
	yeast_drum() {
		const b = new Builder('yeast_drum');
		b.add('drum', C('drum_blue', 0x2a5ab8, { roughness: 0.6 }), new THREE.CylinderGeometry(0.16, 0.16, 0.44, 14), { pos: V(0, 0.22, 0) });
		b.add('band', C('drum_band', 0x1a3a80), new THREE.CylinderGeometry(0.163, 0.163, 0.03, 14), { pos: V(0, 0.15, 0) });
		b.add('label', C('drum_label', 0xf8e060), new THREE.BoxGeometry(0.16, 0.12, 0.01), { pos: V(0, 0.27, 0.158) });
		b.add('cap', C('drum_cap', 0xd02020), new THREE.CylinderGeometry(0.04, 0.04, 0.03, 10), { pos: V(0.06, 0.455, 0) });
		b.add('foam', dough, ellipsoid(0.07, 0.04, 0.06, 8, 5), { pos: V(0.06, 0.48, 0) });
		return b.build();
	},
	// A jar of yeast pills with a yellow lid. 0.1 x 0.14 x 0.1 m.
	yeast_pills() {
		const b = new Builder('yeast_pills');
		b.add('jar', C('pill_jar', 0xe8f0f0, { roughness: 0.3 }), new THREE.CylinderGeometry(0.05, 0.05, 0.11, 10), { pos: V(0, 0.055, 0) });
		b.add('lid', C('pill_lid', 0xf0c020), new THREE.CylinderGeometry(0.052, 0.052, 0.03, 10), { pos: V(0, 0.125, 0) });
		b.add('label', C('pill_label', 0xc03030), new THREE.CylinderGeometry(0.051, 0.051, 0.04, 10), { pos: V(0, 0.055, 0) });
		return b.build();
	},
	// The invoice from "Panaderías Infladas": a sheet with a round puffy logo. 0.21 x 0.006 x 0.29 m, flat.
	inflated_invoice() {
		const b = new Builder('inflated_invoice');
		b.add('sheet', C('invoice_sheet', 0xfaf6ea), new THREE.BoxGeometry(0.21, 0.004, 0.29), { pos: V(0, 0.002, 0) });
		b.add('logo', C('invoice_logo', 0xe08030), new THREE.CylinderGeometry(0.03, 0.03, 0.004, 10), { pos: V(-0.06, 0.005, -0.1) });
		for (let i = 0; i < 5; i++) {
			b.add('lines', C('invoice_ink', 0x303030), new THREE.BoxGeometry(0.15, 0.002, 0.008), { pos: V(0, 0.005, -0.03 + i * 0.03) });
		}
		return b.build();
	},
	// A flat puddle of risen dough, as if it oozed under a door. 0.6 x 0.05 x 0.4 m.
	dough_puddle() {
		const b = new Builder('dough_puddle');
		b.add('dough', dough, ellipsoid(0.3, 0.025, 0.2, 12, 4), { pos: V(0, 0.0, 0) });
		b.add('dough', dough, ellipsoid(0.12, 0.03, 0.1, 8, 4), { pos: V(0.12, 0.01, 0.05) });
		return b.build();
	},
	// The oven with a tunnel story's main evidence: a canvas bank sack full of silver coins, tied at the neck, with a
	// silver coin on the floor beside it. 0.36 x 0.4 x 0.3 m.
	silver_bag() {
		const b = new Builder('silver_bag');
		const canvas = C('bank_canvas', 0xb8a888, { roughness: 0.95 });
		const silver = C('silver', 0xd8dce4, { metalness: 0.7, roughness: 0.25 });
		b.add('sack', canvas, ellipsoid(0.17, 0.16, 0.14, 10, 7), { pos: V(0, 0.16, 0) });
		b.add('neck', canvas, new THREE.CylinderGeometry(0.04, 0.07, 0.1, 8), { pos: V(0, 0.33, 0) });
		b.add('tie', C('bank_rope', 0x6a4a2a), new THREE.TorusGeometry(0.045, 0.01, 4, 10), { pos: V(0, 0.32, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('mark', C('bank_mark', 0x30508a), new THREE.BoxGeometry(0.1, 0.1, 0.01), { pos: V(0, 0.17, 0.14) });
		for (let i = 0; i < 3; i++) {
			b.add('coins', silver, new THREE.CylinderGeometry(0.025, 0.025, 0.006, 10), { pos: V(0.2 + i * 0.01, 0.003 + i * 0.006, 0.05) });
		}
		return b.build();
	},
	// A red fire extinguisher hanging on the wall, its hose curled. Its back toward -Z, 0.5 m tall.
	fire_extinguisher() {
		const b = new Builder('fire_extinguisher');
		const red = C('ext_red', 0xd02018, { roughness: 0.4 });
		b.add('body', red, new THREE.CylinderGeometry(0.08, 0.08, 0.42, 12), { pos: V(0, 0.21, 0.09) });
		b.add('head', C('ext_black', 0x202020), new THREE.CylinderGeometry(0.03, 0.04, 0.06, 8), { pos: V(0, 0.45, 0.09) });
		b.add('handle', C('ext_steel', 0xb0b4b8, { metalness: 0.6 }), new THREE.BoxGeometry(0.12, 0.015, 0.03), { pos: V(0.03, 0.49, 0.09) });
		b.add('hose', C('ext_black', 0x202020), new THREE.TorusGeometry(0.07, 0.012, 4, 10, Math.PI), { pos: V(0.09, 0.3, 0.09), rot: [0, Math.PI / 2, 0] });
		b.add('label', C('ext_label', 0xf8f0e0), new THREE.BoxGeometry(0.08, 0.1, 0.01), { pos: V(0, 0.22, 0.17) });
		b.add('bracket', C('ext_steel', 0xb0b4b8, { metalness: 0.6 }), new THREE.BoxGeometry(0.1, 0.04, 0.02), { pos: V(0, 0.3, 0.01) });
		return b.build();
	},
	// A sooty boot print, flat on the floor. 0.12 x 0.004 x 0.28 m, its toe toward -Z.
	soot_print() {
		const b = new Builder('soot_print');
		const soot = C('soot', 0x1a1818, { roughness: 1.0 });
		b.add('sole', soot, new THREE.BoxGeometry(0.11, 0.004, 0.17), { pos: V(0, 0.002, -0.04) });
		b.add('heel', soot, new THREE.BoxGeometry(0.09, 0.004, 0.08), { pos: V(0, 0.002, 0.1) });
		return b.build();
	},
	// The phones in the backpack story's main evidence: a red thermal delivery backpack, its lid half open, full of
	// stolen phones. 0.42 x 0.45 x 0.3 m.
	thermal_backpack() {
		const b = new Builder('thermal_backpack');
		const red = C('thermal_red', 0xc82820, { roughness: 0.7 });
		b.add('box', red, new THREE.BoxGeometry(0.42, 0.4, 0.3), { pos: V(0, 0.2, 0) });
		b.add('lid', red, new THREE.BoxGeometry(0.42, 0.03, 0.3), { pos: V(0, 0.44, -0.08), rot: [-0.6, 0, 0] });
		b.add('logo', C('thermal_logo', 0xf8e040), new THREE.BoxGeometry(0.2, 0.12, 0.01), { pos: V(0, 0.22, 0.155) });
		b.add('strap', C('thermal_strap', 0x202020), new THREE.BoxGeometry(0.05, 0.34, 0.02), { pos: V(-0.12, 0.2, -0.16) });
		b.add('strap', C('thermal_strap', 0x202020), new THREE.BoxGeometry(0.05, 0.34, 0.02), { pos: V(0.12, 0.2, -0.16) });
		const colors = [0x202428, 0x3050a0, 0xe0e0e0, 0x208040, 0xd06090];
		for (let i = 0; i < 5; i++) {
			b.add('phones', C('phone_' + i, colors[i], { roughness: 0.3 }), new THREE.BoxGeometry(0.07, 0.14, 0.012),
				{ pos: V(-0.14 + i * 0.07, 0.43, 0.02 - (i % 2) * 0.05), rot: [-0.3, 0, (i - 2) * 0.12] });
		}
		return b.build();
	},
	// A cardboard box of tangled phone chargers. 0.3 x 0.18 x 0.22 m.
	chargers_box() {
		const b = new Builder('chargers_box');
		b.add('box', C('cardboard', 0xb08a58, { roughness: 0.95 }), new THREE.BoxGeometry(0.3, 0.16, 0.22), { pos: V(0, 0.08, 0) });
		const white = C('charger_white', 0xf0f0f0);
		for (let i = 0; i < 4; i++) {
			b.add('chargers', white, new THREE.BoxGeometry(0.04, 0.04, 0.03), { pos: V(-0.09 + i * 0.06, 0.17, (i % 2) * 0.05 - 0.02) });
			b.add('cables', white, new THREE.TorusGeometry(0.04, 0.005, 4, 10), { pos: V(-0.08 + i * 0.05, 0.165, 0.03), rot: [Math.PI / 2, 0, i] });
		}
		return b.build();
	},
	// A pink spiral notebook of fake orders. 0.2 x 0.02 x 0.15 m.
	fake_orders_notebook() {
		const b = new Builder('fake_orders_notebook');
		b.add('cover', C('fake_pink', 0xe070a0, { roughness: 0.8 }), new THREE.BoxGeometry(0.2, 0.016, 0.15), { pos: V(0, 0.008, 0) });
		b.add('page', C('fake_page', 0xf8f4e8), new THREE.BoxGeometry(0.18, 0.004, 0.13), { pos: V(0.005, 0.018, 0) });
		b.add('spiral', C('fake_wire', 0x909090, { metalness: 0.6 }), new THREE.CylinderGeometry(0.006, 0.006, 0.15, 6), { pos: V(-0.1, 0.012, 0), rot: [Math.PI / 2, 0, 0] });
		return b.build();
	},
	// The plastic cheese story's main evidence: a steel mold in the shape of a block of muzzarella, its lid open,
	// with a yellow plastic block inside. 0.5 x 0.3 x 0.36 m.
	plastic_cheese_mold() {
		const b = new Builder('plastic_cheese_mold');
		const steel = C('mold_steel', 0x9aa0a8, { metalness: 0.6, roughness: 0.4 });
		b.add('base', steel, new THREE.BoxGeometry(0.5, 0.04, 0.36), { pos: V(0, 0.02, 0) });
		for (const x of [-0.235, 0.235]) b.add('side', steel, new THREE.BoxGeometry(0.03, 0.2, 0.36), { pos: V(x, 0.12, 0) });
		for (const z of [-0.165, 0.165]) b.add('side', steel, new THREE.BoxGeometry(0.5, 0.2, 0.03), { pos: V(0, 0.12, z) });
		b.add('block', C('plastic_cheese', 0xf8d830, { roughness: 0.2 }), new THREE.BoxGeometry(0.42, 0.16, 0.28), { pos: V(0, 0.12, 0) });
		b.add('lid', steel, new THREE.BoxGeometry(0.5, 0.03, 0.36), { pos: V(0, 0.27, -0.2), rot: [-1.2, 0, 0] });
		b.add('crank', C('mold_handle', 0x202020), new THREE.CylinderGeometry(0.015, 0.015, 0.14, 6), { pos: V(0.3, 0.12, 0), rot: [0, 0, Math.PI / 2] });
		return b.build();
	},
	// A clear bag of yellow plastic pellets, tied at the top. 0.3 x 0.32 x 0.2 m.
	plastic_pellets() {
		const b = new Builder('plastic_pellets');
		b.add('bag', C('pellet_bag', 0xe8f0f4, { roughness: 0.3, transparent: true, opacity: 0.6 }), ellipsoid(0.15, 0.14, 0.1, 10, 7), { pos: V(0, 0.14, 0) });
		const yellow = C('pellet', 0xf8d830);
		for (let i = 0; i < 14; i++) {
			b.add('pellets', yellow, new THREE.SphereGeometry(0.03, 5, 4), { pos: V(-0.08 + (i % 5) * 0.04, 0.05 + Math.floor(i / 5) * 0.05, ((i * 7) % 5) * 0.025 - 0.05) });
		}
		b.add('tie', C('pellet_tie', 0xd02020), new THREE.CylinderGeometry(0.03, 0.03, 0.04, 6), { pos: V(0, 0.29, 0) });
		return b.build();
	},
	// A roll of sticker labels that say "100 % muzzarella". 0.14 x 0.06 x 0.14 m.
	muzzarella_labels() {
		const b = new Builder('muzzarella_labels');
		b.add('roll', C('label_white', 0xf8f8f0), new THREE.CylinderGeometry(0.07, 0.07, 0.06, 12), { pos: V(0, 0.03, 0) });
		b.add('core', C('label_core', 0xa08060), new THREE.CylinderGeometry(0.025, 0.025, 0.062, 8), { pos: V(0, 0.03, 0) });
		b.add('print', C('label_print', 0x30a040), new THREE.BoxGeometry(0.05, 0.002, 0.03), { pos: V(0.035, 0.062, 0) });
		b.add('tail', C('label_white', 0xf8f8f0), new THREE.BoxGeometry(0.05, 0.002, 0.12), { pos: V(0.07, 0.001, 0.07), rot: [0, 0.4, 0] });
		return b.build();
	},
	// The sample pizza on the counter: a whole muzzarella on its wooden board. 0.36 x 0.04 x 0.36 m.
	sample_pizza() {
		const b = new Builder('sample_pizza');
		b.add('board', wood, new THREE.CylinderGeometry(0.18, 0.18, 0.015, 16), { pos: V(0, 0.0075, 0) });
		b.add('crust', dough, new THREE.CylinderGeometry(0.16, 0.16, 0.02, 16), { pos: V(0, 0.025, 0) });
		b.add('cheese', C('pizza_cheese', 0xf0c040), new THREE.CylinderGeometry(0.14, 0.14, 0.01, 16), { pos: V(0, 0.037, 0) });
		for (const [x, z] of [[0.06, 0.02], [-0.05, 0.06], [-0.02, -0.07], [0.07, -0.06]]) {
			b.add('olives', C('olive', 0x203020), new THREE.SphereGeometry(0.012, 6, 4), { pos: V(x, 0.045, z) });
		}
		return b.build();
	},
	// The giant pizza story's main evidence: a stack of banded bundles of fake bills from the safe. 0.4 x 0.2 x 0.26 m.
	fake_bills_stack() {
		const b = new Builder('fake_bills_stack');
		const green = C('bill_green', 0x6a9a60, { roughness: 0.8 });
		const band = C('bill_band', 0xe8d8a0);
		for (let i = 0; i < 6; i++) {
			const x = (i % 2) * 0.2 - 0.1, y = Math.floor(i / 2) * 0.065 + 0.0325;
			b.add('bundles', green, new THREE.BoxGeometry(0.18, 0.06, 0.24), { pos: V(x, y, 0), rot: [0, (i % 3) * 0.05, 0] });
			b.add('bands', band, new THREE.BoxGeometry(0.04, 0.062, 0.242), { pos: V(x, y, 0), rot: [0, (i % 3) * 0.05, 0] });
		}
		return b.build();
	},
	// A paper napkin with the safe's combination written on it in pen. 0.2 x 0.004 x 0.2 m.
	combo_napkin() {
		const b = new Builder('combo_napkin');
		b.add('napkin', C('napkin', 0xf8f8f4, { roughness: 1.0 }), new THREE.BoxGeometry(0.2, 0.003, 0.2), { pos: V(0, 0.0015, 0), rot: [0, 0.2, 0] });
		const ink = C('pen_ink', 0x2030a0);
		for (let i = 0; i < 3; i++) b.add('numbers', ink, new THREE.BoxGeometry(0.035, 0.001, 0.012), { pos: V(-0.05 + i * 0.05, 0.0035, 0) });
		return b.build();
	},
	// The giant pizza "Récord del barrio" hanging on the dining room's wall, 1.5 m across, its back toward -Z and its
	// hinge on the left edge (x = 0, the center at x = 0.75): one of its pepperoni slices has a keyhole.
	giant_pizza_door() {
		const b = new Builder('giant_pizza_door');
		const turn = { rot: [Math.PI / 2, 0, 0] };
		b.add('crust', dough, new THREE.CylinderGeometry(0.75, 0.75, 0.05, 24), { pos: V(0.75, 0, 0.025), ...turn });
		b.add('sauce', C('pizza_sauce', 0xc03020), new THREE.CylinderGeometry(0.68, 0.68, 0.01, 24), { pos: V(0.75, 0, 0.052), ...turn });
		b.add('cheese', C('pizza_cheese', 0xf0c040), new THREE.CylinderGeometry(0.64, 0.64, 0.012, 24), { pos: V(0.75, 0, 0.058), ...turn });
		const pepperoni = C('pepperoni', 0xb02820);
		for (const [x, y] of [[0.4, 0.3], [-0.3, 0.35], [0.1, -0.4], [-0.4, -0.15], [0.35, -0.2], [0, 0.05], [-0.1, 0.5], [0.5, 0.05]]) {
			b.add('pepperoni', pepperoni, new THREE.CylinderGeometry(0.07, 0.07, 0.012, 10), { pos: V(0.75 + x, y, 0.066), ...turn });
		}
		b.add('keyhole', C('keyhole_steel', 0xc0c4c8, { metalness: 0.7 }), new THREE.CylinderGeometry(0.035, 0.035, 0.014, 10), { pos: V(1.15, 0.3, 0.072), ...turn });
		b.add('keyhole', C('keyhole_dark', 0x101010), new THREE.BoxGeometry(0.012, 0.03, 0.004), { pos: V(1.15, 0.29, 0.08) });
		return b.build();
	},
};

export const views = {
	pizza_story_giant: {
		items: [{ name: 'giant_pizza_door', pos: [-1.2, 0.8, -0.6] }, { name: 'fake_bills_stack', pos: [-0.2, 0, 0.3] },
			{ name: 'printing_plate', pos: [0.5, 0, 0.2] }, { name: 'combo_napkin', pos: [0.2, 0, 0.6] }],
		cam: { pos: [0.0, 1.2, 3.2], target: [0.0, 0.5, 0], fov: 40 },
	},
	pizza_story_cheese: {
		items: [{ name: 'plastic_cheese_mold', pos: [-0.35, 0, 0] }, { name: 'plastic_pellets', pos: [0.15, 0, 0.1] },
			{ name: 'muzzarella_labels', pos: [0.45, 0, 0.15] }, { name: 'sample_pizza', pos: [0.2, 0, -0.35] }],
		cam: { pos: [0.1, 0.8, 1.5], target: [0.1, 0.15, 0], fov: 40 },
	},
	pizza_story_phones: {
		items: [{ name: 'thermal_backpack', pos: [-0.35, 0, 0] }, { name: 'chargers_box', pos: [0.15, 0, 0.1] },
			{ name: 'fake_orders_notebook', pos: [0.5, 0, 0.15], rotY: -0.3 }, { name: 'orders_notebook', pos: [0.2, 0, -0.3] }],
		cam: { pos: [0.1, 0.8, 1.5], target: [0.1, 0.15, 0], fov: 40 },
	},
	pizza_story_tunnel: {
		items: [{ name: 'silver_bag', pos: [-0.35, 0, 0] }, { name: 'miner_helmet', pos: [0.1, 0, 0.1] },
			{ name: 'floor_plan', pos: [0.45, 0.03, 0.1], rotY: -0.3 }, { name: 'fire_extinguisher', pos: [0.75, 0, -0.2] },
			{ name: 'soot_print', pos: [0.15, 0, -0.3] }],
		cam: { pos: [0.2, 0.8, 1.5], target: [0.2, 0.15, 0], fov: 40 },
	},
	pizza_story_yeast: {
		items: [{ name: 'yeast_drum', pos: [-0.35, 0, 0] }, { name: 'yeast_pills', pos: [0.05, 0, 0.1] },
			{ name: 'inflated_invoice', pos: [0.35, 0, 0.1], rotY: -0.3 }, { name: 'dough_puddle', pos: [0.1, 0, -0.35] }],
		cam: { pos: [0.0, 0.8, 1.4], target: [0.0, 0.15, 0], fov: 40 },
	},
	pizza_story_jewels: {
		items: [{ name: 'frozen_pizza_jewels', pos: [-0.3, 0, 0] }, { name: 'jeweler_loupe', pos: [0.1, 0, 0.1] },
			{ name: 'special_clients_list', pos: [0.4, 0, 0.1], rotY: -0.3 }, { name: 'bitten_slice_ring', pos: [0.15, 0, -0.2], rotY: 0.6 }],
		cam: { pos: [0.05, 0.6, 1.1], target: [0.05, 0.05, 0], fov: 40 },
	},
	pizza_raid: {
		items: [{ name: 'clay_oven', pos: [-1.2, 0, -0.5] }, { name: 'dough_table', pos: [1.2, 0, -0.3] },
			{ name: 'dough_ball', pos: [0.8, 0.9, -0.2] }, { name: 'dough_ball', pos: [1.1, 0.9, -0.35] },
			{ name: 'pizza_slice', pos: [1.6, 0.92, 0.0], rotY: 0.5 }, { name: 'kitchen_plate', pos: [0.2, 0.02, 0.8] },
			{ name: 'pizza_box', pos: [0.6, 0, 0.9] }, { name: 'flour_sack', pos: [-0.2, 0, 1.0] }],
		cam: { pos: [0.0, 2.2, 5.0], target: [0.0, 0.8, 0], fov: 40 },
	},
	pizza_npcs: {
		items: [{ name: 'npc_muzza', pos: [-0.6, 0, 0], rotY: 0.3 }, { name: 'npc_tito', pos: [0.6, 0, 0], rotY: -0.3 }],
		cam: { pos: [0.0, 1.3, 4.0], target: [0.0, 0.85, 0], fov: 36 },
	},
};
