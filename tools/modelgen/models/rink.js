// Props of the ice rink "Patinódromo Resbalón" (docs/diseno/allanamiento-pista.md): the ice resurfacer, the big
// skating penguin the kids hold on to, the hot chocolate machine, the DJ booth and the scoreboard, with origins at the
// floor in the middle of each piece, and Doña Pirueta, the owner. Placeholder, not final art.
import { Builder, mat, ellipsoid, V, THREE } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

// The ice resurfacer, 1.6 x 1.7 x 3.0 m: a blue box on four small wheels with the driver's seat up front (+Z), the
// big water tank behind it with its lid, and the wide scraper at the back.
export function buildIceResurfacer() {
	const b = new Builder('ice_resurfacer');
	const blue = mat('resurfacer_blue', 0x2f6fc0), white = mat('resurfacer_white', 0xeef2f6);
	const dark = mat('resurfacer_dark', 0x26262a), steel = mat('resurfacer_steel', 0xa8aeb6);
	b.add('body', blue, new THREE.BoxGeometry(1.5, 0.7, 2.8), { pos: V(0, 0.55, 0) });
	b.add('stripe', white, new THREE.BoxGeometry(1.52, 0.12, 2.82), { pos: V(0, 0.7, 0) });
	b.add('tank', blue, new THREE.BoxGeometry(1.4, 0.6, 1.5), { pos: V(0, 1.2, -0.55) });
	b.add('lid', steel, new THREE.BoxGeometry(1.0, 0.06, 1.0), { pos: V(0, 1.53, -0.55) });
	b.add('seat', dark, new THREE.BoxGeometry(0.5, 0.1, 0.45), { pos: V(0, 1.0, 0.85) });
	b.add('seat_back', dark, new THREE.BoxGeometry(0.5, 0.5, 0.08), { pos: V(0, 1.25, 0.6) });
	b.add('wheel_post', steel, new THREE.CylinderGeometry(0.03, 0.03, 0.4, 8), { pos: V(0, 1.1, 1.2), rot: [-0.5, 0, 0] });
	b.add('wheel', dark, new THREE.TorusGeometry(0.16, 0.03, 6, 14), { pos: V(0, 1.3, 1.1), rot: [-1.0, 0, 0] });
	b.add('scraper', steel, new THREE.BoxGeometry(1.6, 0.25, 0.3), { pos: V(0, 0.15, -1.45) });
	for (const x of [-0.65, 0.65]) {
		for (const z of [-0.95, 0.95]) {
			b.add('tire', dark, new THREE.CylinderGeometry(0.2, 0.2, 0.18, 12), { pos: V(x, 0.2, z), rot: [0, 0, Math.PI / 2] });
		}
	}
	b.add('light', mat('resurfacer_light', 0xffc040, { emissive: 0xffa020 }), new THREE.SphereGeometry(0.08, 8, 6), { pos: V(0, 1.62, -0.1) });
	return b.build();
}

// The penguin the kids push around to learn, 0.8 x 1.2 x 0.6 m: a fat black and white body on a red sled with a
// handle bar over its head. Front +Z.
export function buildSkatingPenguin() {
	const b = new Builder('skating_penguin');
	const black = mat('penguin_black', 0x24262c), white = mat('penguin_white', 0xf4f4f0);
	const orange = mat('penguin_orange', 0xf08a24), red = mat('penguin_sled', 0xc8302c);
	b.add('sled', red, new THREE.BoxGeometry(0.8, 0.08, 0.6), { pos: V(0, 0.04, 0) });
	b.add('body', black, new THREE.SphereGeometry(0.34, 12, 10), { pos: V(0, 0.45, 0), scale: [1, 1.15, 0.9] });
	b.add('belly', white, new THREE.SphereGeometry(0.28, 12, 10), { pos: V(0, 0.42, 0.1), scale: [1, 1.1, 0.8] });
	b.add('head', black, new THREE.SphereGeometry(0.2, 12, 10), { pos: V(0, 0.92, 0) });
	b.add('face', white, new THREE.SphereGeometry(0.14, 10, 8), { pos: V(0, 0.92, 0.09), scale: [1, 0.9, 0.7] });
	b.add('beak', orange, new THREE.ConeGeometry(0.05, 0.14, 8), { pos: V(0, 0.9, 0.24), rot: [Math.PI / 2, 0, 0] });
	for (const x of [-0.07, 0.07]) {
		b.add('eye', black, new THREE.SphereGeometry(0.025, 6, 6), { pos: V(x, 0.97, 0.2) });
		b.add('foot', orange, new THREE.BoxGeometry(0.12, 0.04, 0.16), { pos: V(x * 2, 0.1, 0.2) });
	}
	for (const x of [-0.3, 0.3]) {
		b.add('bar_post', red, new THREE.CylinderGeometry(0.025, 0.025, 1.1, 8), { pos: V(x, 0.6, -0.25) });
	}
	b.add('bar', red, new THREE.CylinderGeometry(0.03, 0.03, 0.64, 8), { pos: V(0, 1.15, -0.25), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// The hot chocolate machine on the bar, 0.5 x 0.8 x 0.45 m: a brown box with a steaming cup picture, the tap and the
// drip tray at the front (+Z).
export function buildCocoaMachine() {
	const b = new Builder('cocoa_machine');
	const brown = mat('cocoa_brown', 0x6a3a22), cream = mat('cocoa_cream', 0xf2e2c4), steel = mat('cocoa_steel', 0xb0b4ba);
	b.add('body', brown, new THREE.BoxGeometry(0.5, 0.8, 0.45), { pos: V(0, 0.4, 0) });
	b.add('panel', cream, new THREE.BoxGeometry(0.36, 0.3, 0.02), { pos: V(0, 0.58, 0.23) });
	b.add('cup', brown, new THREE.CylinderGeometry(0.07, 0.05, 0.12, 10), { pos: V(0, 0.56, 0.245), rot: [Math.PI / 2, 0, 0], scale: [1, 0.15, 1] });
	b.add('tap', steel, new THREE.CylinderGeometry(0.02, 0.02, 0.1, 8), { pos: V(0, 0.3, 0.26) });
	b.add('tray', steel, new THREE.BoxGeometry(0.3, 0.03, 0.14), { pos: V(0, 0.06, 0.28) });
	b.add('button', mat('cocoa_button', 0xd83a2a), new THREE.CylinderGeometry(0.03, 0.03, 0.02, 10), { pos: V(0.17, 0.38, 0.235), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The DJ booth by the rink, 1.6 x 1.2 x 0.8 m: a black desk with two turntables, a mixer with the big red "her song"
// button and a speaker at each end. Front (the DJ's side) -Z, the crowd's side +Z.
export function buildDjBooth() {
	const b = new Builder('dj_booth');
	const black = mat('dj_black', 0x1c1c22), grey = mat('dj_grey', 0x4a4c54), vinyl = mat('dj_vinyl', 0x101012);
	b.add('desk', black, new THREE.BoxGeometry(1.6, 0.95, 0.8), { pos: V(0, 0.475, 0) });
	b.add('front', mat('dj_stripe', 0x8a3ad0, { emissive: 0x5a1a90 }), new THREE.BoxGeometry(1.5, 0.08, 0.02), { pos: V(0, 0.7, 0.41) });
	for (const x of [-0.5, 0.5]) {
		b.add('deck', grey, new THREE.BoxGeometry(0.45, 0.05, 0.4), { pos: V(x, 0.975, 0) });
		b.add('vinyl', vinyl, new THREE.CylinderGeometry(0.16, 0.16, 0.02, 16), { pos: V(x, 1.01, 0) });
	}
	b.add('mixer', grey, new THREE.BoxGeometry(0.4, 0.06, 0.35), { pos: V(0, 0.98, 0) });
	b.add('song', mat('dj_song', 0xe02a2a), new THREE.CylinderGeometry(0.06, 0.06, 0.04, 12), { pos: V(0, 1.03, -0.05) });
	for (const x of [-0.95, 0.95]) {
		b.add('speaker', black, new THREE.BoxGeometry(0.3, 1.2, 0.35), { pos: V(x, 0.6, 0) });
		b.add('cone', grey, new THREE.CylinderGeometry(0.1, 0.1, 0.02, 12), { pos: V(x, 0.85, 0.18), rot: [Math.PI / 2, 0, 0] });
	}
	return b.build();
}

// The scoreboard hanging over the rink, 3.0 x 1.4 x 0.3 m: a black board with two red digit panels, "LOCAL" and
// "VISITA" plates and a yellow frame. Faces +Z.
export function buildRinkScoreboard() {
	const b = new Builder('rink_scoreboard');
	const black = mat('score_black', 0x18181c), yellow = mat('score_frame', 0xf0c030);
	const digit = mat('score_digit', 0xff3a2a, { emissive: 0xd02010 });
	b.add('board', black, new THREE.BoxGeometry(3.0, 1.4, 0.3), { pos: V(0, 0.7, 0) });
	b.add('frame', yellow, new THREE.BoxGeometry(3.1, 0.08, 0.32), { pos: V(0, 1.42, 0) });
	b.add('frame', yellow, new THREE.BoxGeometry(3.1, 0.08, 0.32), { pos: V(0, -0.02, 0) });
	for (const x of [-0.8, 0.8]) {
		b.add('digits', digit, new THREE.BoxGeometry(0.9, 0.6, 0.02), { pos: V(x, 0.6, 0.16) });
		b.add('plate', mat('score_plate', 0xeeeeee), new THREE.BoxGeometry(0.9, 0.2, 0.02), { pos: V(x, 1.15, 0.16) });
	}
	b.add('clock', digit, new THREE.BoxGeometry(0.4, 0.3, 0.02), { pos: V(0, 1.0, 0.16) });
	return b.build();
}

// Doña Pirueta, the owner, a former champion skater: a sparkly pink leotard with a tutu, a high grey bun with a bow,
// white skates with silver blades and her arms out as if mid-turn. The game scales her short and round.
export function buildDonaPirueta() {
	const b = new Builder('npc_dona_pirueta');
	const pink = mat('pirueta_leotard', 0xe0469a, { emissive: 0x401028, metalness: 0.4, roughness: 0.3 });
	const tights = mat('pirueta_tights', 0x3a2a34), tutu = mat('pirueta_tutu', 0xf6c4dc);
	const skate = mat('pirueta_skate', 0xf6f4ee), blade = mat('pirueta_blade', 0xc8ccd4, { metalness: 0.8, roughness: 0.2 });
	pearBody(b, mat('skin_clara', 0xf2c8a8), { shirt: pink, pants: tights, shoes: skate, belted: false });
	b.add('body', tutu, new THREE.CylinderGeometry(0.62, 0.5, 0.1, 14), { pos: V(0, 0.55, 0) });
	for (let i = 0; i < 6; i++) {
		const a = i / 6 * Math.PI * 2;
		b.add('body', mat('pirueta_sequin', 0xfff0a0, { emissive: 0xc0a040 }), new THREE.OctahedronGeometry(0.03),
			{ pos: V(Math.sin(a) * 0.3, 0.85, Math.cos(a) * 0.27) });
	}
	for (const s of [-1, 1]) {
		b.add('legs', blade, new THREE.BoxGeometry(0.02, 0.03, 0.34), { pos: V(s * 0.2, 0.0, 0.12) });
	}
	eyes(b, 1.33, 0.18, 0.08, 0.045);
	b.add('face', mat('pirueta_lips', 0xc02040), ellipsoid(0.04, 0.015, 0.015, 6, 4), { pos: V(0, 1.22, 0.19) });
	const grey = mat('pirueta_hair', 0xc8c8cc);
	b.add('hair', grey, ellipsoid(0.21, 0.12, 0.2, 10, 6), { pos: V(0, 1.43, 0.0) });
	b.add('hair', grey, ellipsoid(0.11, 0.13, 0.11, 8, 6), { pos: V(0, 1.6, -0.03) });
	b.add('hair', pink, new THREE.TorusGeometry(0.05, 0.02, 4, 8), { pos: V(0, 1.6, 0.08) });
	return b.build();
}

// Copito, the boy who drives the resurfacer and is always cold: a puffy light blue jacket, a striped scarf, a beanie
// with a pompom, a red nose and mittens.
export function buildCopito() {
	const b = new Builder('npc_copito');
	const jacket = mat('copito_jacket', 0x8ac8f0), scarf = mat('copito_scarf', 0xd83a3a), white = M.white;
	pearBody(b, mat('skin_morena', 0xc89070), { shirt: jacket, pants: mat('copito_pants', 0x2a3a5a), shoes: M.black, belted: false });
	for (let i = 0; i < 3; i++) {
		b.add('body', mat('copito_puff', 0x9ad4f8), new THREE.TorusGeometry(0.4 - i * 0.07, 0.04, 6, 14), { pos: V(0, 0.45 + i * 0.22, 0), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('scarf', scarf, new THREE.TorusGeometry(0.16, 0.05, 6, 12), { pos: V(0, 1.12, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('scarf', white, new THREE.BoxGeometry(0.1, 0.3, 0.04), { pos: V(0.08, 0.95, 0.2), rot: [0.2, 0, 0] });
	eyes(b, 1.33, 0.18, 0.075, 0.045);
	b.add('face', mat('copito_nose', 0xe0403a), ellipsoid(0.04, 0.035, 0.035, 6, 4), { pos: V(0, 1.27, 0.21) });
	b.add('hat', mat('copito_beanie', 0x3a6ad2), ellipsoid(0.21, 0.15, 0.2, 10, 6), { pos: V(0, 1.42, 0.01) });
	b.add('hat', white, new THREE.CylinderGeometry(0.21, 0.21, 0.06, 10), { pos: V(0, 1.38, 0.01) });
	b.add('hat', white, new THREE.SphereGeometry(0.07, 8, 6), { pos: V(0, 1.6, 0.01) });
	for (const x of [-1, 1]) b.add('arms', scarf, ellipsoid(0.085, 0.085, 0.085, 6, 4), { pos: V(x * 0.49, 0.64, 0.09) });
	return b.build();
}

// The ice surprise's block of ice (0.6 x 0.5 x 0.5 m) with the stolen jewels frozen inside: a necklace, rings and
// gems seen through the ice.
export function buildRinkIceBlock() {
	const b = new Builder('rink_ice_block');
	const ice = mat('block_ice', 0xc8e8ff, { transparent: true, opacity: 0.55, roughness: 0.1 });
	const gold = mat('jewel_gold', 0xf2c84b, { emissive: 0x3a2a05, metalness: 0.7, roughness: 0.25 });
	const gem = mat('jewel_gem', 0xe0306a, { emissive: 0x501020 }), green = mat('jewel_green', 0x30c070, { emissive: 0x104020 });
	b.add('necklace', gold, new THREE.TorusGeometry(0.12, 0.012, 6, 18), { pos: V(-0.08, 0.25, 0), rot: [1.2, 0.3, 0] });
	for (const [x, y, z] of [[0.12, 0.18, 0.08], [0.15, 0.3, -0.06], [0.02, 0.12, -0.1]]) {
		b.add('ring', gold, new THREE.TorusGeometry(0.03, 0.008, 6, 10), { pos: V(x, y, z), rot: [x * 6, y * 4, 0] });
	}
	b.add('gem', gem, new THREE.OctahedronGeometry(0.04), { pos: V(0.05, 0.32, 0.1) });
	b.add('gem', green, new THREE.OctahedronGeometry(0.035), { pos: V(-0.15, 0.14, 0.08) });
	b.add('block', ice, new THREE.BoxGeometry(0.6, 0.5, 0.5), { pos: V(0, 0.25, 0) });
	return b.build();
}

// The list of jewelers: a sheet of paper (0.21 x 0.3 m) with a crossed-out list and a ring drawn on it.
export function buildRinkJewelerList() {
	const b = new Builder('rink_jeweler_list');
	b.add('paper', mat('list_paper', 0xf6f2e6), new THREE.BoxGeometry(0.21, 0.004, 0.3), { pos: V(0, 0.002, 0) });
	for (let i = 0; i < 6; i++) {
		b.add('line', mat('list_ink', 0x2a2a6a), new THREE.BoxGeometry(0.15, 0.002, 0.008), { pos: V(-0.01, 0.005, -0.11 + i * 0.035) });
	}
	b.add('ring', mat('list_red', 0xd03030), new THREE.TorusGeometry(0.025, 0.004, 4, 10), { pos: V(0.06, 0.005, 0.11), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The ice chisel, 0.35 m long lying down: a wooden handle and a wide steel blade toward +Z.
export function buildIceChisel() {
	const b = new Builder('ice_chisel');
	b.add('handle', mat('chisel_wood', 0x8a5a30), new THREE.CylinderGeometry(0.022, 0.025, 0.2, 8), { pos: V(0, 0.025, -0.07), rot: [Math.PI / 2, 0, 0] });
	b.add('blade', mat('chisel_steel', 0xb8bec6, { metalness: 0.8, roughness: 0.25 }), new THREE.BoxGeometry(0.05, 0.012, 0.15), { pos: V(0, 0.02, 0.1) });
	return b.build();
}

// The smuggling resurfacer's box of stolen perfumes, 0.5 x 0.35 x 0.4 m: a cardboard box with its flaps open and pink
// and purple bottles peeking out.
export function buildRinkPerfumeBox() {
	const b = new Builder('rink_perfume_box');
	const card = mat('box_card', 0xb8925a);
	b.add('box', card, new THREE.BoxGeometry(0.5, 0.3, 0.4), { pos: V(0, 0.15, 0) });
	for (const s of [-1, 1]) b.add('flap', card, new THREE.BoxGeometry(0.5, 0.01, 0.16), { pos: V(0, 0.33, s * 0.26), rot: [s * 0.6, 0, 0] });
	const colors = [0xf07ab0, 0xa060e0, 0xf0a0d0];
	for (let i = 0; i < 6; i++) {
		const glass = mat('perfume_' + (i % 3), colors[i % 3], { transparent: true, opacity: 0.85, roughness: 0.15 });
		b.add('bottle', glass, new THREE.BoxGeometry(0.07, 0.12, 0.05), { pos: V(-0.17 + (i % 3) * 0.17, 0.32, -0.08 + Math.floor(i / 3) * 0.16) });
	}
	return b.build();
}

// One bottle of perfume, 0.07 x 0.14 x 0.05 m: pink glass with a gold cap.
export function buildPerfumeBottle() {
	const b = new Builder('perfume_bottle');
	b.add('glass', mat('perfume_0', 0xf07ab0, { transparent: true, opacity: 0.85, roughness: 0.15 }), new THREE.BoxGeometry(0.07, 0.1, 0.05), { pos: V(0, 0.05, 0) });
	b.add('cap', mat('perfume_cap', 0xf2c84b, { metalness: 0.7, roughness: 0.3 }), new THREE.CylinderGeometry(0.015, 0.015, 0.04, 8), { pos: V(0, 0.12, 0) });
	return b.build();
}

// The funnel to fill the resurfacer's tank, 0.25 m wide: a tin cone on a spout.
export function buildRinkFunnel() {
	const b = new Builder('rink_funnel');
	const tin = mat('funnel_tin', 0xc0c6cc, { metalness: 0.6, roughness: 0.35 });
	b.add('cone', tin, new THREE.CylinderGeometry(0.12, 0.025, 0.16, 12, 1, true), { pos: V(0, 0.16, 0) });
	b.add('spout', tin, new THREE.CylinderGeometry(0.02, 0.015, 0.08, 8), { pos: V(0, 0.04, 0) });
	return b.build();
}

// The fixed match's scoreboard remote, 0.07 x 0.03 x 0.2 m: a black remote with an antenna and two big buttons, red for
// the home team and blue for the visitors.
export function buildRinkScoreRemote() {
	const b = new Builder('rink_score_remote');
	b.add('body', mat('remote_black', 0x202024), new THREE.BoxGeometry(0.07, 0.03, 0.2), { pos: V(0, 0.015, 0) });
	b.add('antenna', mat('remote_steel', 0xa8aeb6, { metalness: 0.7 }), new THREE.CylinderGeometry(0.004, 0.004, 0.12, 6), { pos: V(0.025, 0.03, -0.14), rot: [-1.2, 0, 0] });
	b.add('home', mat('remote_red', 0xe03a2a), new THREE.CylinderGeometry(0.018, 0.018, 0.012, 10), { pos: V(-0.017, 0.035, 0.03) });
	b.add('away', mat('remote_blue', 0x2a6ae0), new THREE.CylinderGeometry(0.018, 0.018, 0.012, 10), { pos: V(0.017, 0.035, 0.03) });
	b.add('screen', mat('remote_screen', 0x9fe0a0, { emissive: 0x206020 }), new THREE.BoxGeometry(0.05, 0.002, 0.04), { pos: V(0, 0.031, -0.04) });
	return b.build();
}

// The betting notebook, 0.15 x 0.03 x 0.21 m: a green notebook with an elastic band and a pencil.
export function buildRinkBetNotebook() {
	const b = new Builder('rink_bet_notebook');
	b.add('cover', mat('bet_cover', 0x2f7a3c), new THREE.BoxGeometry(0.15, 0.03, 0.21), { pos: V(0, 0.015, 0) });
	b.add('band', mat('bet_band', 0x18181c), new THREE.BoxGeometry(0.152, 0.032, 0.012), { pos: V(0, 0.015, 0.07) });
	b.add('pencil', mat('bet_pencil', 0xf0c030), new THREE.CylinderGeometry(0.004, 0.004, 0.17, 6), { pos: V(0.05, 0.034, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The envelope with money, 0.22 x 0.03 x 0.12 m: a fat brown envelope with green bills peeking out.
export function buildRinkMoneyEnvelope() {
	const b = new Builder('rink_money_envelope');
	b.add('envelope', mat('envelope_brown', 0xc8a060), new THREE.BoxGeometry(0.22, 0.03, 0.12), { pos: V(0, 0.015, 0) });
	b.add('bills', mat('bills_green', 0x6ab04c), new THREE.BoxGeometry(0.16, 0.02, 0.06), { pos: V(0.05, 0.016, 0), rot: [0, 0.15, 0] });
	return b.build();
}

export const models = {
	ice_resurfacer: buildIceResurfacer, skating_penguin: buildSkatingPenguin, cocoa_machine: buildCocoaMachine,
	dj_booth: buildDjBooth, rink_scoreboard: buildRinkScoreboard, npc_dona_pirueta: buildDonaPirueta,
	npc_copito: buildCopito, rink_ice_block: buildRinkIceBlock, rink_jeweler_list: buildRinkJewelerList,
	ice_chisel: buildIceChisel, rink_perfume_box: buildRinkPerfumeBox, perfume_bottle: buildPerfumeBottle,
	rink_funnel: buildRinkFunnel, rink_score_remote: buildRinkScoreRemote, rink_bet_notebook: buildRinkBetNotebook,
	rink_money_envelope: buildRinkMoneyEnvelope,
};

export const views = {
	rink: {
		items: [
			{ name: 'ice_resurfacer', pos: [-2.2, 0, 0], rotY: 0.6 }, { name: 'skating_penguin', pos: [-0.4, 0, 0.6] },
			{ name: 'cocoa_machine', pos: [0.6, 0, 0.8] }, { name: 'dj_booth', pos: [1.8, 0, 0], rotY: Math.PI },
			{ name: 'rink_scoreboard', pos: [0, 2.0, -1.5] }, { name: 'npc_dona_pirueta', pos: [0.9, 0, 1.6], rotY: -0.3 },
			{ name: 'npc_copito', pos: [2.4, 0, 1.4], rotY: -0.5 }, { name: 'rink_ice_block', pos: [-1.2, 0, 2.2] },
			{ name: 'rink_jeweler_list', pos: [-0.3, 0, 2.6] }, { name: 'ice_chisel', pos: [0.2, 0, 2.6] },
			{ name: 'rink_perfume_box', pos: [0.8, 0, 2.6] }, { name: 'perfume_bottle', pos: [1.3, 0, 2.8] }, { name: 'rink_funnel', pos: [1.6, 0, 2.8] },
			{ name: 'rink_score_remote', pos: [2.0, 0, 2.8] }, { name: 'rink_bet_notebook', pos: [2.3, 0, 2.8] }, { name: 'rink_money_envelope', pos: [2.6, 0, 2.8] },
		],
		cam: { pos: [0, 2.2, 6.5], target: [0, 1.0, 0], fov: 45 },
	},
};
