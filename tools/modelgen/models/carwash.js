// Props of the car wash "La Espuma Loca" (docs/diseno/allanamiento-lavadero.md): the tunnel's spinning brush, the jets
// arch, the blower, the token machine, the vacuum column, the inflatable dancing man and the boiler, with origins at the
// floor in the middle of each piece, Don Chorro, the owner, and Pompita, the rag boy. Placeholder, not final art.
import { Builder, mat, ellipsoid, V, THREE } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

// One of the tunnel's brushes, 1.2 m across and 2.6 m tall, standing: a steel shaft with rings of blue, pink and
// yellow bristles, the top cap and the bottom bearing.
export function buildWashBrush() {
	const b = new Builder('wash_brush');
	const steel = mat('brush_steel', 0xa8aeb6, { metalness: 0.7, roughness: 0.35 });
	const colors = [mat('brush_blue', 0x3a7be0), mat('brush_pink', 0xe85ca8), mat('brush_yellow', 0xf2d040)];
	b.add('shaft', steel, new THREE.CylinderGeometry(0.06, 0.06, 2.7, 10), { pos: V(0, 1.35, 0) });
	for (let i = 0; i < 9; i++) {
		b.add(`ring_${i}`, colors[i % 3], new THREE.CylinderGeometry(0.6, 0.6, 0.24, 14), { pos: V(0, 0.25 + i * 0.27, 0) });
	}
	b.add('cap', steel, new THREE.CylinderGeometry(0.2, 0.2, 0.1, 10), { pos: V(0, 2.65, 0) });
	b.add('bearing', steel, new THREE.CylinderGeometry(0.15, 0.2, 0.12, 10), { pos: V(0, 0.06, 0) });
	return b.build();
}

// The jets arch at the tunnel's mouth, 4.2 m wide and 3.2 m tall: two grey posts and a beam, with a row of blue nozzles
// pointing inward on each and on the beam. The tunnel runs along X, so the arch spans Z.
export function buildWashJets() {
	const b = new Builder('wash_jets');
	const grey = mat('jets_grey', 0x8a9098, { metalness: 0.5, roughness: 0.4 }), blue = mat('jets_nozzle', 0x2f8ae8);
	for (const z of [-2.0, 2.0]) {
		b.add('post', grey, new THREE.BoxGeometry(0.16, 3.2, 0.16), { pos: V(0, 1.6, z) });
		for (let i = 0; i < 5; i++) {
			b.add('nozzle', blue, new THREE.CylinderGeometry(0.04, 0.06, 0.16, 8), { pos: V(0, 0.4 + i * 0.55, z * 0.95), rot: [Math.PI / 2, 0, 0] });
		}
	}
	b.add('beam', grey, new THREE.BoxGeometry(0.16, 0.16, 4.2), { pos: V(0, 3.12, 0) });
	for (let i = 0; i < 6; i++) {
		b.add('nozzle_top', blue, new THREE.CylinderGeometry(0.04, 0.06, 0.16, 8), { pos: V(0, 2.98, -1.5 + i * 0.6) });
	}
	return b.build();
}

// The blower at the tunnel's end, 4.2 m wide and 3.2 m tall: an arch like the jets' with two fat yellow fans on the
// posts and one wide mouth on the beam.
export function buildWashBlower() {
	const b = new Builder('wash_blower');
	const grey = mat('jets_grey', 0x8a9098, { metalness: 0.5, roughness: 0.4 }), yellow = mat('blower_yellow', 0xf0c020);
	const dark = mat('blower_dark', 0x26262a);
	for (const z of [-2.0, 2.0]) {
		b.add('post', grey, new THREE.BoxGeometry(0.16, 3.2, 0.16), { pos: V(0, 1.6, z) });
		b.add('fan', yellow, new THREE.CylinderGeometry(0.4, 0.4, 0.3, 14), { pos: V(0, 1.4, z * 0.88), rot: [Math.PI / 2, 0, 0] });
		b.add('grille', dark, new THREE.CylinderGeometry(0.3, 0.3, 0.32, 14), { pos: V(0, 1.4, z * 0.86), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('beam', grey, new THREE.BoxGeometry(0.16, 0.16, 4.2), { pos: V(0, 3.12, 0) });
	b.add('mouth', yellow, new THREE.BoxGeometry(0.5, 0.35, 2.6), { pos: V(0, 2.85, 0) });
	b.add('slot', dark, new THREE.BoxGeometry(0.3, 0.06, 2.4), { pos: V(0, 2.66, 0) });
	return b.build();
}

// The token machine, 0.7 x 1.6 x 0.5 m: a blue box on a post with a screen, the coin slot, the token tray and the big
// golden "premium" button. Front +Z.
export function buildTokenMachine() {
	const b = new Builder('token_machine');
	const blue = mat('token_blue', 0x2a5fb0), dark = mat('token_dark', 0x1c1c22), gold = mat('token_gold', 0xf2c84b, { metalness: 0.7, roughness: 0.3 });
	b.add('post', dark, new THREE.BoxGeometry(0.2, 0.6, 0.2), { pos: V(0, 0.3, 0) });
	b.add('body', blue, new THREE.BoxGeometry(0.7, 1.0, 0.5), { pos: V(0, 1.1, 0) });
	b.add('screen', mat('token_screen', 0x7fe0ff, { emissive: 0x206070 }), new THREE.BoxGeometry(0.4, 0.22, 0.02), { pos: V(0, 1.4, 0.26) });
	b.add('slot', dark, new THREE.BoxGeometry(0.08, 0.02, 0.02), { pos: V(0.22, 1.18, 0.26) });
	b.add('tray', dark, new THREE.BoxGeometry(0.24, 0.08, 0.1), { pos: V(0, 0.72, 0.27) });
	b.add('premium', gold, new THREE.CylinderGeometry(0.07, 0.07, 0.05, 14), { pos: V(-0.18, 1.1, 0.27), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// A vacuum column, 0.6 x 1.8 x 0.6 m: a red post with a round head, the hose coiled on its hook and a little sign.
export function buildVacuumColumn() {
	const b = new Builder('vacuum_column');
	const red = mat('vacuum_red', 0xc83030), dark = mat('vacuum_hose', 0x22242a);
	b.add('post', red, new THREE.BoxGeometry(0.5, 1.5, 0.5), { pos: V(0, 0.75, 0) });
	b.add('head', red, new THREE.CylinderGeometry(0.32, 0.32, 0.3, 14), { pos: V(0, 1.65, 0) });
	b.add('hose', dark, new THREE.TorusGeometry(0.22, 0.04, 6, 16), { pos: V(0, 1.0, 0.3) });
	b.add('nozzle', dark, new THREE.BoxGeometry(0.06, 0.4, 0.06), { pos: V(0.22, 0.75, 0.32) });
	b.add('sign', mat('vacuum_sign', 0xf2f2ee), new THREE.BoxGeometry(0.3, 0.2, 0.02), { pos: V(0, 1.25, 0.26) });
	return b.build();
}

// The inflatable dancing man, 0.9 x 4.0 x 0.9 m: a fan box at the foot, a long orange tube body with a face, and two
// arms thrown up to the sides.
export function buildInflatableMan() {
	const b = new Builder('inflatable_man');
	const orange = mat('inflatable_orange', 0xf27a1a), dark = mat('inflatable_dark', 0x26262a), white = mat('inflatable_white', 0xffffff);
	b.add('fan', dark, new THREE.BoxGeometry(0.9, 0.5, 0.9), { pos: V(0, 0.25, 0) });
	b.add('body', orange, new THREE.CylinderGeometry(0.3, 0.38, 3.2, 12), { pos: V(0, 2.1, 0), rot: [0, 0, 0.06] });
	b.add('head', orange, new THREE.SphereGeometry(0.34, 12, 10), { pos: V(0.1, 3.8, 0) });
	for (const x of [-0.11, 0.21]) {
		b.add('eye', white, new THREE.SphereGeometry(0.08, 8, 6), { pos: V(x, 3.9, 0.28) });
	}
	b.add('mouth', dark, new THREE.BoxGeometry(0.2, 0.05, 0.05), { pos: V(0.05, 3.68, 0.31) });
	b.add('arm_l', orange, new THREE.CylinderGeometry(0.1, 0.12, 1.3, 8), { pos: V(-0.6, 3.1, 0), rot: [0, 0, 0.9] });
	b.add('arm_r', orange, new THREE.CylinderGeometry(0.1, 0.12, 1.3, 8), { pos: V(0.7, 3.3, 0), rot: [0, 0, -1.2] });
	return b.build();
}

// The boiler, 1.0 x 2.0 x 1.0 m: a white cylinder with a red valve wheel, a gauge and a pipe going up.
export function buildCarwashBoiler() {
	const b = new Builder('carwash_boiler');
	const white = mat('boiler_white', 0xe6e6e0), steel = mat('boiler_steel', 0x9aa0a8, { metalness: 0.7, roughness: 0.35 });
	b.add('tank', white, new THREE.CylinderGeometry(0.5, 0.5, 1.8, 16), { pos: V(0, 0.9, 0) });
	b.add('pipe', steel, new THREE.CylinderGeometry(0.06, 0.06, 0.8, 8), { pos: V(0.2, 2.2, 0) });
	b.add('valve', mat('boiler_valve', 0xc83030), new THREE.TorusGeometry(0.1, 0.02, 6, 12), { pos: V(0, 1.0, 0.53) });
	b.add('gauge', mat('boiler_gauge', 0xf4f4f0), new THREE.CylinderGeometry(0.08, 0.08, 0.03, 12), { pos: V(-0.2, 1.4, 0.51), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// Don Chorro, the owner: bald and shiny, a yellow raincoat, green rubber boots, a thick grey mustache and a red
// cloth always in his hand. The game scales him short and round.
export function buildDonChorro() {
	const b = new Builder('npc_don_chorro');
	const coat = mat('chorro_raincoat', 0xf2d020, { roughness: 0.3 }), boots = mat('chorro_boots', 0x2f8a3a);
	const skin = mat('chorro_skin', 0xe8b890, { metalness: 0.3, roughness: 0.15 });
	pearBody(b, skin, { shirt: coat, pants: coat, shoes: boots, belted: false });
	for (let i = 0; i < 3; i++) {
		b.add('body', mat('chorro_button', 0x26262a), new THREE.CylinderGeometry(0.025, 0.025, 0.02, 8),
			{ pos: V(0, 0.95 - i * 0.18, 0.31 + i * 0.05), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('head', mat('chorro_shine', 0xffffff, { emissive: 0x606060 }), ellipsoid(0.05, 0.03, 0.04, 6, 4),
		{ pos: V(-0.06, 1.5, 0.08) });
	eyes(b, 1.34, 0.19, 0.08, 0.04);
	b.add('face', mat('chorro_mustache', 0x8a8a8e), ellipsoid(0.11, 0.035, 0.04, 8, 4), { pos: V(0, 1.24, 0.19) });
	b.add('cloth', mat('chorro_cloth', 0xd8302a), new THREE.BoxGeometry(0.2, 0.02, 0.24), { pos: V(0.48, 0.64, 0.14), rot: [0, 0, 0.8] });
	return b.build();
}

// Pompita, the rag boy: blue overalls over a striped shirt, a cap on backwards, foam on his shoulder and a soaked grey
// rag dripping from each hand.
export function buildPompita() {
	const b = new Builder('npc_pompita');
	const overalls = mat('pompita_overalls', 0x2f5fb8), shirt = mat('pompita_shirt', 0xf2f2ee), cap = mat('pompita_cap', 0xe04040);
	pearBody(b, mat('skin_trigueña', 0xd8a070), { shirt, pants: overalls, shoes: M.black, belted: false });
	b.add('body', overalls, new THREE.BoxGeometry(0.42, 0.3, 0.06), { pos: V(0, 0.7, 0.36), rot: [-0.25, 0, 0] });
	for (let i = 0; i < 3; i++) {
		b.add('body', mat('pompita_stripe', 0x3aa0e0), new THREE.TorusGeometry(0.3 - i * 0.05, 0.015, 4, 14), { pos: V(0, 0.82 + i * 0.1, 0), rot: [Math.PI / 2, 0, 0] });
	}
	eyes(b, 1.33, 0.18, 0.075, 0.045);
	b.add('face', mat('pompita_freckle', 0xb06040), ellipsoid(0.07, 0.015, 0.01, 6, 3), { pos: V(0, 1.28, 0.2) });
	b.add('hat', cap, ellipsoid(0.2, 0.1, 0.2, 10, 5), { pos: V(0, 1.44, 0.01) });
	b.add('hat', cap, new THREE.BoxGeometry(0.2, 0.02, 0.16), { pos: V(0, 1.42, -0.24) });
	b.add('foam', mat('pompita_foam', 0xf6f8ff), ellipsoid(0.1, 0.06, 0.1, 8, 4), { pos: V(-0.26, 1.08, 0.02) });
	const rag = mat('pompita_rag', 0x707478);
	for (const x of [-1, 1]) {
		b.add('rag', rag, new THREE.BoxGeometry(0.12, 0.26, 0.03), { pos: V(x * 0.47, 0.5, 0.1) });
	}
	return b.build();
}

// The laundered money's bag (0.6 x 0.35 x 0.3 m): a green sports bag, zipper open, with bundles of bills showing.
export function buildCarwashCashBag() {
	const b = new Builder('carwash_cash_bag');
	const bag = mat('cash_bag', 0x2f6a3a), dark = mat('cash_bag_dark', 0x1c2a20), bill = mat('cash_bill', 0x7fc87a);
	b.add('bag', bag, new THREE.CylinderGeometry(0.17, 0.17, 0.6, 12), { pos: V(0, 0.17, 0), rot: [0, 0, Math.PI / 2] });
	b.add('zip', dark, new THREE.BoxGeometry(0.5, 0.01, 0.06), { pos: V(0, 0.345, 0) });
	for (const x of [-0.12, 0.0, 0.12]) {
		b.add('bills', bill, new THREE.BoxGeometry(0.1, 0.05, 0.05), { pos: V(x, 0.34, 0), rot: [0, x, 0] });
	}
	for (const x of [-0.15, 0.15]) {
		b.add('handle', dark, new THREE.TorusGeometry(0.08, 0.012, 4, 10, Math.PI), { pos: V(x, 0.34, 0) });
	}
	return b.build();
}

// The notebook with the two sets of books (0.17 x 0.22 m): a black notebook lying open, one page in blue ink and the
// other in red.
export function buildCarwashLedger() {
	const b = new Builder('carwash_ledger');
	b.add('cover', mat('ledger_cover', 0x1c1c22), new THREE.BoxGeometry(0.34, 0.012, 0.22), { pos: V(0, 0.006, 0) });
	b.add('page', mat('ledger_page', 0xf4f0e2), new THREE.BoxGeometry(0.32, 0.004, 0.2), { pos: V(0, 0.014, 0) });
	for (let i = 0; i < 5; i++) {
		b.add('ink', mat('ledger_blue', 0x2a3a9a), new THREE.BoxGeometry(0.12, 0.002, 0.006), { pos: V(-0.08, 0.017, -0.07 + i * 0.035) });
		b.add('ink', mat('ledger_red', 0xc02a2a), new THREE.BoxGeometry(0.12, 0.002, 0.006), { pos: V(0.08, 0.017, -0.07 + i * 0.035) });
	}
	return b.build();
}

// The iron for flattening the washed bills (0.25 x 0.15 x 0.12 m): a pale blue body on a steel plate, with its handle.
export function buildCarwashIron() {
	const b = new Builder('carwash_iron');
	const body = mat('iron_body', 0x8ac0e8), steel = mat('iron_plate', 0xc0c4cc, { metalness: 0.8, roughness: 0.25 });
	b.add('plate', steel, new THREE.CylinderGeometry(0.06, 0.06, 0.02, 3), { pos: V(0, 0.01, 0), rot: [0, Math.PI / 2, 0], scale: V(2.0, 1, 1) });
	b.add('body', body, new THREE.CylinderGeometry(0.05, 0.06, 0.06, 3), { pos: V(0, 0.05, 0), rot: [0, Math.PI / 2, 0], scale: V(1.8, 1, 1) });
	b.add('handle', mat('iron_handle', 0x26262a), new THREE.BoxGeometry(0.14, 0.025, 0.03), { pos: V(-0.01, 0.13, 0) });
	b.add('handle', mat('iron_handle', 0x26262a), new THREE.BoxGeometry(0.02, 0.05, 0.03), { pos: V(-0.07, 0.1, 0) });
	return b.build();
}

// The real plates of a stolen car (0.52 x 0.06 x 0.13 m): two white license plates with black letters, tied together
// with a string.
export function buildCarwashPlates() {
	const b = new Builder('carwash_plates');
	const white = mat('plate_white', 0xf2f2ee), ink = mat('plate_ink', 0x1c1c22);
	for (let i = 0; i < 2; i++) {
		b.add('plate', white, new THREE.BoxGeometry(0.52, 0.02, 0.13), { pos: V(0, 0.01 + i * 0.025, 0), rot: [0, i * 0.08, 0] });
		for (let j = 0; j < 6; j++) {
			b.add('letters', ink, new THREE.BoxGeometry(0.05, 0.004, 0.07), { pos: V(-0.18 + j * 0.072, 0.022 + i * 0.025, 0), rot: [0, i * 0.08, 0] });
		}
	}
	b.add('string', mat('plate_string', 0xc8a060), new THREE.TorusGeometry(0.07, 0.006, 4, 10), { pos: V(0, 0.03, 0), rot: [0, 0, Math.PI / 2], scale: V(1, 0.5, 1) });
	return b.build();
}

// The fake car papers (0.21 x 0.3 m): a folded sheet with a big official-looking stamp and a smudged signature.
export function buildCarwashCarPapers() {
	const b = new Builder('carwash_car_papers');
	b.add('paper', mat('papers_paper', 0xeae4cc), new THREE.BoxGeometry(0.21, 0.006, 0.3), { pos: V(0, 0.003, 0) });
	b.add('stamp', mat('papers_stamp', 0x6a3ab0), new THREE.CylinderGeometry(0.04, 0.04, 0.002, 12), { pos: V(0.05, 0.007, 0.09) });
	for (let i = 0; i < 4; i++) {
		b.add('ink', mat('papers_ink', 0x2a2a3a), new THREE.BoxGeometry(0.15, 0.002, 0.008), { pos: V(-0.01, 0.007, -0.1 + i * 0.03) });
	}
	b.add('ink', mat('papers_ink', 0x2a2a3a), new THREE.BoxGeometry(0.08, 0.002, 0.02), { pos: V(-0.04, 0.007, 0.1), rot: [0, 0.4, 0] });
	return b.build();
}

export const models = {
	wash_brush: buildWashBrush, wash_jets: buildWashJets, wash_blower: buildWashBlower, token_machine: buildTokenMachine,
	vacuum_column: buildVacuumColumn, inflatable_man: buildInflatableMan, carwash_boiler: buildCarwashBoiler,
	npc_don_chorro: buildDonChorro, npc_pompita: buildPompita, carwash_cash_bag: buildCarwashCashBag,
	carwash_ledger: buildCarwashLedger, carwash_iron: buildCarwashIron, carwash_plates: buildCarwashPlates,
	carwash_car_papers: buildCarwashCarPapers,
};

export const views = {
	carwash: {
		items: [
			{ name: 'wash_jets', pos: [-3.2, 0, 0], rotY: 0.5 }, { name: 'wash_brush', pos: [-1.4, 0, 0.4] },
			{ name: 'wash_blower', pos: [0.6, 0, -0.6], rotY: 0.5 }, { name: 'token_machine', pos: [2.0, 0, 1.2] },
			{ name: 'vacuum_column', pos: [2.9, 0, 0.8] }, { name: 'inflatable_man', pos: [3.9, 0, -0.4] },
			{ name: 'carwash_boiler', pos: [-2.6, 0, 2.2] }, { name: 'npc_don_chorro', pos: [0.9, 0, 2.0], rotY: -0.3 },
			{ name: 'npc_pompita', pos: [-0.6, 0, 2.6], rotY: 0.3 },
			{ name: 'carwash_cash_bag', pos: [-1.8, 0, 3.4] }, { name: 'carwash_ledger', pos: [2.0, 0, 3.4] },
			{ name: 'carwash_iron', pos: [2.6, 0, 3.0] }, { name: 'carwash_plates', pos: [-0.6, 0, 3.6] },
			{ name: 'carwash_car_papers', pos: [0.4, 0, 3.6] },
		],
		cam: { pos: [0, 2.6, 9.0], target: [0, 1.5, 0], fov: 45 },
	},
};
