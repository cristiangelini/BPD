// Props of the "Cine Butaca Floja" (docs/diseno/allanamiento-cine.md): the folding velvet seat, the popcorn machine and
// the old film projector, with origins at the floor in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

// A folding theater seat 0.7 m wide: red velvet back and seat between two dark iron sides, the seat folded down.
// Front +Z.
export function buildCinemaSeat() {
	const b = new Builder('cinema_seat');
	const velvet = mat('seat_velvet', 0xa8202c), iron = mat('seat_iron', 0x2a2a2e), wood = mat('seat_wood', 0x6a4426);
	for (const s of [-1, 1]) {
		b.add('side', iron, new THREE.BoxGeometry(0.06, 0.62, 0.56), { pos: V(s * 0.33, 0.31, 0) });
		b.add('arm', wood, new THREE.BoxGeometry(0.08, 0.04, 0.5), { pos: V(s * 0.33, 0.64, 0.02) });
	}
	b.add('seat', velvet, new THREE.BoxGeometry(0.6, 0.1, 0.46), { pos: V(0, 0.42, 0.06), rot: [-0.08, 0, 0] });
	b.add('back', velvet, new THREE.BoxGeometry(0.6, 0.62, 0.1), { pos: V(0, 0.8, -0.22), rot: [-0.12, 0, 0] });
	b.add('back_wood', wood, new THREE.BoxGeometry(0.62, 0.64, 0.02), { pos: V(0, 0.8, -0.28), rot: [-0.12, 0, 0] });
	b.add('number', mat('seat_brass', 0xd8b048), new THREE.BoxGeometry(0.1, 0.05, 0.01), { pos: V(0, 1.06, -0.3) });
	return b.build();
}

// The popcorn machine on the candy counter, 0.6 x 0.9 x 0.5 m: a red cart top with a glass case full of popcorn, the
// kettle hanging inside and the yellow sign on the roof.
export function buildPopcornMachine() {
	const b = new Builder('popcorn_machine');
	const red = mat('popcorn_red', 0xd2302a), glass = mat('popcorn_glass', 0xd8eef8, { transparent: true, opacity: 0.35 });
	const corn = mat('popcorn', 0xfff2c0), steel = mat('popcorn_steel', 0xb0b4ba);
	b.add('base', red, new THREE.BoxGeometry(0.6, 0.16, 0.5), { pos: V(0, 0.08, 0) });
	b.add('pile', corn, new THREE.BoxGeometry(0.56, 0.2, 0.46), { pos: V(0, 0.26, 0) });
	for (let i = 0; i < 10; i++) {
		b.add('pile', corn, new THREE.IcosahedronGeometry(0.04, 0), { pos: V(-0.22 + (i % 5) * 0.11, 0.39, -0.12 + Math.floor(i / 5) * 0.2) });
	}
	b.add('glass', glass, new THREE.BoxGeometry(0.6, 0.56, 0.5), { pos: V(0, 0.44, 0) });
	b.add('kettle', steel, new THREE.CylinderGeometry(0.1, 0.08, 0.12, 12), { pos: V(0, 0.6, 0) });
	b.add('roof', red, new THREE.BoxGeometry(0.64, 0.08, 0.54), { pos: V(0, 0.76, 0) });
	b.add('sign', mat('popcorn_sign', 0xf4d03a), new THREE.BoxGeometry(0.5, 0.14, 0.04), { pos: V(0, 0.87, 0) });
	return b.build();
}

// The old film projector in the booth, 0.5 x 1.4 x 0.9 m on its pedestal: a grey body with the lens to +Z and the two
// big reels on top.
export function buildFilmProjector() {
	const b = new Builder('film_projector');
	const grey = mat('projector_grey', 0x5a6068), dark = mat('projector_dark', 0x222226), reel = mat('reel_steel', 0x9aa0a8);
	b.add('pedestal', dark, new THREE.BoxGeometry(0.4, 0.8, 0.5), { pos: V(0, 0.4, 0) });
	b.add('body', grey, new THREE.BoxGeometry(0.42, 0.4, 0.7), { pos: V(0, 1.0, 0) });
	b.add('lens', dark, new THREE.CylinderGeometry(0.07, 0.08, 0.22, 12), { pos: V(0, 1.0, 0.45), rot: [Math.PI / 2, 0, 0] });
	b.add('glow', mat('projector_light', 0xfff6c8, { emissive: 0xfff6c8 }), new THREE.CircleGeometry(0.06, 12), { pos: V(0, 1.0, 0.565) });
	for (const z of [-0.25, 0.2]) {
		b.add('reel', reel, new THREE.CylinderGeometry(0.24, 0.24, 0.04, 16), { pos: V(0, 1.45, z), rot: [0, 0, Math.PI / 2] });
		b.add('film', dark, new THREE.CylinderGeometry(0.14, 0.14, 0.05, 16), { pos: V(0, 1.45, z), rot: [0, 0, Math.PI / 2] });
	}
	return b.build();
}

// Doña Bobina, the owner and projectionist: short and round, huge round glasses, a grey bun with a pencil through it,
// a green wool vest over a lilac blouse and a reel of film under her right arm. The game scales her short and wide.
export function buildDonaBobina() {
	const b = new Builder('npc_dona_bobina');
	const blouse = mat('bobina_blouse', 0xb89ad0), vest = mat('bobina_vest', 0x3f6a46), skirt = mat('bobina_skirt', 0x5a3a52);
	pearBody(b, mat('skin_bobina', 0xe8b48c), { shirt: blouse, pants: skirt, shoes: M.black, belted: false });
	b.add('vest', vest, new THREE.CylinderGeometry(0.33, 0.43, 0.42, 10, 1, true), { pos: V(0, 0.76, 0) });
	eyes(b, 1.33, 0.18, 0.08, 0.05);
	const frame = mat('bobina_glasses', 0x2a1e18);
	for (const s of [-1, 1]) {
		b.add('glasses', frame, new THREE.TorusGeometry(0.075, 0.012, 4, 12), { pos: V(s * 0.085, 1.33, 0.205) });
	}
	b.add('glasses', frame, new THREE.BoxGeometry(0.03, 0.012, 0.012), { pos: V(0, 1.34, 0.21) });
	const hair = mat('bobina_hair', 0xc8c4c0);
	b.add('hair', hair, ellipsoid(0.205, 0.12, 0.2, 10, 5), { pos: V(0, 1.42, 0.0) });
	b.add('hair', hair, ellipsoid(0.11, 0.1, 0.11, 8, 5), { pos: V(0, 1.55, -0.1) });
	b.add('pencil', mat('pencil_yellow', 0xf2c230), new THREE.CylinderGeometry(0.012, 0.012, 0.3, 6), { pos: V(0.02, 1.57, -0.1), rot: [0, 0, 1.2] });
	const reel = mat('bobina_reel', 0x9aa0a8);
	b.add('reel', reel, new THREE.CylinderGeometry(0.17, 0.17, 0.04, 14), { pos: V(0.5, 0.72, 0.05), rot: [0, 0, Math.PI / 2] });
	b.add('reel', M.black, new THREE.CylinderGeometry(0.1, 0.1, 0.05, 14), { pos: V(0.5, 0.72, 0.05), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// Chicho, the usher: thin and young, a burgundy usher's jacket with two rows of gold buttons, a little round cap with a
// strap, a bow tie and a flashlight in his right hand. Sitting, the game lowers him into a seat.
export function buildChicho() {
	const b = new Builder('npc_chicho');
	const jacket = mat('usher_jacket', 0x7a1a2a), gold = mat('usher_gold', 0xe8c050, { emissive: 0x3a2a05 });
	pearBody(b, mat('skin_chicho', 0xc98f62), { shirt: jacket, pants: mat('usher_pants', 0x1a1a22), shoes: M.black, belted: false });
	eyes(b, 1.33, 0.18, 0.08, 0.055);
	for (const s of [-1, 1]) {
		for (const y of [0.62, 0.78, 0.94]) b.add('buttons', gold, new THREE.SphereGeometry(0.022, 6, 4), { pos: V(s * 0.09, y, 0.4 - (y - 0.6) * 0.35) });
	}
	b.add('bow', M.black, new THREE.BoxGeometry(0.14, 0.05, 0.03), { pos: V(0, 1.1, 0.17) });
	b.add('cap', jacket, new THREE.CylinderGeometry(0.13, 0.13, 0.1, 10), { pos: V(0.04, 1.5, 0.0), rot: [0, 0, 0.2] });
	b.add('cap', gold, new THREE.CylinderGeometry(0.135, 0.135, 0.02, 10), { pos: V(0.04, 1.46, 0.0), rot: [0, 0, 0.2] });
	b.add('flashlight', M.black, new THREE.CylinderGeometry(0.035, 0.03, 0.22, 8), { pos: V(0.5, 0.64, 0.2), rot: [Math.PI / 2, 0, 0] });
	b.add('flashlight', mat('usher_light', 0xfff2b0, { emissive: 0xfff2b0 }), new THREE.CircleGeometry(0.035, 8), { pos: V(0.5, 0.64, 0.311) });
	return b.build();
}

// The box with 200 pirate copies, 0.6 x 0.42 x 0.45 m: a taped cardboard box, open on top, full of plastic cases with
// hand-written titles, a few sticking out.
export function buildPirateBox() {
	const b = new Builder('pirate_copies_box');
	const card = mat('box_card', 0xb08850), tape = mat('box_tape', 0xd8c890);
	b.add('box', card, new THREE.BoxGeometry(0.6, 0.36, 0.45), { pos: V(0, 0.18, 0) });
	b.add('tape', tape, new THREE.BoxGeometry(0.62, 0.04, 0.08), { pos: V(0, 0.2, 0) });
	const cases = [0x1a1a22, 0x2a3a6a, 0x6a1a2a, 0x1a4a2a];
	for (let i = 0; i < 9; i++) {
		const c = mat(`case_${i % 4}`, cases[i % 4]);
		b.add('cases', c, new THREE.BoxGeometry(0.014, 0.19, 0.135), { pos: V(-0.24 + i * 0.06, 0.38 + (i % 3) * 0.02, -0.06 + (i % 2) * 0.12), rot: [0, 0, (i % 3 - 1) * 0.15] });
		b.add('labels', M.white, new THREE.BoxGeometry(0.016, 0.06, 0.1), { pos: V(-0.24 + i * 0.06, 0.4 + (i % 3) * 0.02, -0.06 + (i % 2) * 0.12), rot: [0, 0, (i % 3 - 1) * 0.15] });
	}
	return b.build();
}

// The camcorder on its folded tripod, 0.2 x 0.8 x 0.2 m lying down along Z: the black camera with its red light and
// the three legs together.
export function buildCamcorder() {
	const b = new Builder('cinema_camcorder');
	const black = mat('cam_black', 0x1c1c20), grey = mat('cam_grey', 0x70747a);
	b.add('camera', black, new THREE.BoxGeometry(0.12, 0.12, 0.24), { pos: V(0, 0.08, 0.26) });
	b.add('lens', grey, new THREE.CylinderGeometry(0.045, 0.05, 0.08, 10), { pos: V(0, 0.08, 0.41), rot: [Math.PI / 2, 0, 0] });
	b.add('light', mat('cam_red', 0xff2020, { emissive: 0xff2020 }), new THREE.SphereGeometry(0.012, 6, 4), { pos: V(0.04, 0.145, 0.36) });
	for (const x of [-0.03, 0, 0.03]) b.add('legs', grey, new THREE.CylinderGeometry(0.012, 0.012, 0.6, 6), { pos: V(x, 0.03, -0.12), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// A stack of printed covers for the copies, 0.19 x 0.06 x 0.27 m, the top one with a blurry title and a crooked star.
export function buildCovers() {
	const b = new Builder('cinema_covers');
	b.add('stack', M.white, new THREE.BoxGeometry(0.19, 0.05, 0.27), { pos: V(0, 0.025, 0) });
	b.add('print', mat('cover_print', 0x3050a0), new THREE.BoxGeometry(0.17, 0.004, 0.18), { pos: V(0, 0.052, 0.03) });
	b.add('title', mat('cover_title', 0xf0c030), new THREE.BoxGeometry(0.15, 0.005, 0.04), { pos: V(0, 0.053, -0.09), rot: [0, 0.08, 0] });
	return b.build();
}

// The sack of popcorn swept off the theater's floor, 0.5 x 0.56 x 0.4 m: a white sack tied at the top, popcorn spilling
// over with grey fluff and a pink gum stuck on it.
export function buildFloorPopcornBag() {
	const b = new Builder('floor_popcorn_bag');
	const sack = mat('sack_white', 0xe8e4d8), corn = mat('popcorn', 0xf6e7a8), fluff = mat('fluff', 0x8a8a90);
	b.add('sack', sack, new THREE.CylinderGeometry(0.2, 0.24, 0.46, 8), { pos: V(0, 0.23, 0) });
	b.add('tie', mat('sack_tie', 0xc04030), new THREE.CylinderGeometry(0.1, 0.12, 0.05, 8), { pos: V(0, 0.47, 0) });
	for (let i = 0; i < 9; i++) {
		const turn = i * 2.1;
		b.add('corn', i % 4 === 0 ? fluff : corn, new THREE.IcosahedronGeometry(0.035, 0), { pos: V(Math.cos(turn) * 0.07, 0.51 + (i % 3) * 0.015, Math.sin(turn) * 0.07) });
	}
	b.add('gum', mat('gum_pink', 0xf080b0), new THREE.SphereGeometry(0.03, 6, 4), { pos: V(0.04, 0.54, -0.03) });
	return b.build();
}

// The broom with its "reciclaje" sign taped on, 1.2 m lying down along Z: the stick, the bristles and a green card.
export function buildRecycleBroom() {
	const b = new Builder('recycle_broom');
	b.add('stick', mat('broom_stick', 0xa07040), new THREE.CylinderGeometry(0.015, 0.015, 0.95, 6), { pos: V(0, 0.04, -0.12), rot: [Math.PI / 2, 0, 0] });
	b.add('head', mat('broom_head', 0x3050a0), new THREE.BoxGeometry(0.28, 0.06, 0.06), { pos: V(0, 0.04, 0.38) });
	b.add('bristles', mat('broom_bristles', 0xd8c070), new THREE.BoxGeometry(0.28, 0.05, 0.14), { pos: V(0, 0.03, 0.48) });
	b.add('sign', mat('recycle_green', 0x30a050), new THREE.BoxGeometry(0.16, 0.01, 0.12), { pos: V(0, 0.06, -0.1) });
	b.add('arrows', M.white, new THREE.TorusGeometry(0.035, 0.008, 4, 8), { pos: V(0, 0.068, -0.1), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The "recién hechas" sign, 0.5 x 0.04 x 0.35 m lying flat: a yellow board with a red frame and a steaming bucket.
export function buildFreshSign() {
	const b = new Builder('fresh_sign');
	const red = mat('sign_red', 0xc02020);
	b.add('board', mat('sign_yellow', 0xf0d030), new THREE.BoxGeometry(0.5, 0.03, 0.35), { pos: V(0, 0.015, 0) });
	for (const z of [-0.165, 0.165]) b.add('frame', red, new THREE.BoxGeometry(0.5, 0.035, 0.02), { pos: V(0, 0.018, z) });
	for (const x of [-0.24, 0.24]) b.add('frame', red, new THREE.BoxGeometry(0.02, 0.035, 0.35), { pos: V(x, 0.018, 0) });
	b.add('bucket', red, new THREE.CylinderGeometry(0.05, 0.035, 0.008, 8), { pos: V(-0.12, 0.034, 0.03) });
	b.add('letters', mat('sign_letters', 0x202020), new THREE.BoxGeometry(0.22, 0.006, 0.04), { pos: V(0.08, 0.034, -0.06) });
	b.add('letters', mat('sign_letters', 0x202020), new THREE.BoxGeometry(0.16, 0.006, 0.04), { pos: V(0.08, 0.034, 0.04) });
	return b.build();
}

// The ghost projector, 0.3 x 0.3 x 0.45 m: a small grey box with a big lens, a glass slide with a white ghost stuck in
// front and a crank on its side.
export function buildGhostProjector() {
	const b = new Builder('ghost_projector');
	const grey = mat('ghost_proj_grey', 0x50545c);
	b.add('body', grey, new THREE.BoxGeometry(0.26, 0.22, 0.34), { pos: V(0, 0.11, -0.03) });
	b.add('lens', mat('ghost_lens', 0x202028), new THREE.CylinderGeometry(0.07, 0.08, 0.1, 10), { pos: V(0, 0.13, 0.18), rot: [Math.PI / 2, 0, 0] });
	b.add('slide', mat('ghost_slide', 0xc8e0f0), new THREE.BoxGeometry(0.16, 0.16, 0.01), { pos: V(0, 0.15, 0.235) });
	b.add('ghost', M.white, new THREE.SphereGeometry(0.035, 6, 4), { pos: V(0, 0.17, 0.242), scale: [1, 1.3, 0.3] });
	b.add('crank', grey, new THREE.BoxGeometry(0.02, 0.1, 0.02), { pos: V(0.14, 0.13, -0.05) });
	b.add('knob', mat('ghost_knob', 0xc02020), new THREE.SphereGeometry(0.02, 6, 4), { pos: V(0.16, 0.18, -0.05) });
	return b.build();
}

// The sheet with eye holes, folded, 0.4 x 0.08 x 0.3 m: a white pile with two black holes on top.
export function buildHoleySheet() {
	const b = new Builder('holey_sheet');
	const sheet = mat('sheet_white', 0xf0f0ea), hole = mat('sheet_hole', 0x101010);
	b.add('pile', sheet, new THREE.BoxGeometry(0.4, 0.06, 0.3), { pos: V(0, 0.03, 0) });
	b.add('fold', sheet, new THREE.BoxGeometry(0.36, 0.02, 0.26), { pos: V(0.01, 0.07, -0.01), rot: [0, 0.06, 0] });
	for (const x of [-0.06, 0.06]) b.add('holes', hole, new THREE.CylinderGeometry(0.025, 0.025, 0.004, 8), { pos: V(x, 0.082, -0.03) });
	return b.build();
}

// The record of screams in its sleeve, 0.31 x 0.02 x 0.31 m: a purple sleeve with a yelling mouth and the black disc
// sliding out.
export function buildScreamDisc() {
	const b = new Builder('scream_disc');
	b.add('disc', mat('vinyl', 0x101014), new THREE.CylinderGeometry(0.15, 0.15, 0.006, 16), { pos: V(0.06, 0.006, 0) });
	b.add('sleeve', mat('sleeve_purple', 0x6030a0), new THREE.BoxGeometry(0.31, 0.012, 0.31), { pos: V(-0.02, 0.012, 0) });
	b.add('mouth', mat('mouth_black', 0x200808), new THREE.CylinderGeometry(0.05, 0.05, 0.004, 10), { pos: V(-0.02, 0.02, 0.02), scale: [0.8, 1, 1.4] });
	return b.build();
}

// The ticket press, 0.7 x 0.5 x 0.5 m: a heavy green iron press with its wheel on the side, a roll of tickets feeding in
// and a strip of pink tickets coming out the front.
export function buildTicketPress() {
	const b = new Builder('ticket_press');
	const iron = mat('press_iron', 0x2f5a40), dark = mat('press_dark', 0x202420), pink = mat('ticket_pink', 0xf0a0b8);
	b.add('base', dark, new THREE.BoxGeometry(0.7, 0.08, 0.5), { pos: V(0, 0.04, 0) });
	b.add('body', iron, new THREE.BoxGeometry(0.5, 0.3, 0.4), { pos: V(-0.03, 0.23, 0) });
	b.add('top', iron, new THREE.BoxGeometry(0.4, 0.1, 0.3), { pos: V(-0.03, 0.43, 0) });
	b.add('wheel', dark, new THREE.TorusGeometry(0.14, 0.02, 4, 12), { pos: V(0.27, 0.26, 0), rot: [0, Math.PI / 2, 0] });
	b.add('roll', pink, new THREE.CylinderGeometry(0.07, 0.07, 0.2, 10), { pos: V(-0.03, 0.5, -0.12), rot: [0, 0, Math.PI / 2] });
	b.add('strip', pink, new THREE.BoxGeometry(0.12, 0.01, 0.2), { pos: V(-0.03, 0.12, 0.3) });
	return b.build();
}

// The "función agotada" stamp, 0.1 x 0.14 x 0.1 m: a wooden knob on a red rubber block.
export function buildSoldOutStamp() {
	const b = new Builder('sold_out_stamp');
	b.add('rubber', mat('stamp_red', 0xc02020), new THREE.BoxGeometry(0.1, 0.03, 0.07), { pos: V(0, 0.015, 0) });
	b.add('neck', mat('stamp_wood', 0x9a6a3a), new THREE.CylinderGeometry(0.015, 0.02, 0.06, 8), { pos: V(0, 0.06, 0) });
	b.add('knob', mat('stamp_wood', 0x9a6a3a), new THREE.SphereGeometry(0.035, 8, 6), { pos: V(0, 0.11, 0) });
	return b.build();
}

// The fake ticket book, 0.16 x 0.03 x 0.08 m: a pad of pink tickets with a grey cardboard back.
export function buildTicketBook() {
	const b = new Builder('ticket_book');
	b.add('back', mat('book_grey', 0x707070), new THREE.BoxGeometry(0.16, 0.005, 0.08), { pos: V(0, 0.0025, 0) });
	b.add('pad', mat('ticket_pink', 0xf0a0b8), new THREE.BoxGeometry(0.15, 0.025, 0.075), { pos: V(0, 0.017, 0) });
	b.add('stub', mat('stub_line', 0x903050), new THREE.BoxGeometry(0.004, 0.026, 0.075), { pos: V(-0.04, 0.018, 0) });
	return b.build();
}

export const models = {
	cinema_seat: buildCinemaSeat, popcorn_machine: buildPopcornMachine, film_projector: buildFilmProjector,
	npc_dona_bobina: buildDonaBobina, npc_chicho: buildChicho, pirate_copies_box: buildPirateBox,
	cinema_camcorder: buildCamcorder, cinema_covers: buildCovers, floor_popcorn_bag: buildFloorPopcornBag,
	recycle_broom: buildRecycleBroom, fresh_sign: buildFreshSign, ghost_projector: buildGhostProjector,
	holey_sheet: buildHoleySheet, scream_disc: buildScreamDisc, ticket_press: buildTicketPress, sold_out_stamp: buildSoldOutStamp,
	ticket_book: buildTicketBook,
};

export const views = {
	cinema: {
		items: [
			{ name: 'cinema_seat', pos: [-1.2, 0, 0] }, { name: 'cinema_seat', pos: [-0.5, 0, 0] },
			{ name: 'popcorn_machine', pos: [0.5, 0, 0.3] }, { name: 'film_projector', pos: [1.5, 0, 0], rotY: -0.6 },
			{ name: 'npc_dona_bobina', pos: [0.6, 0, 1.0], rotY: -0.2 }, { name: 'npc_chicho', pos: [-0.5, 0, 1.1], rotY: 0.3 },
			{ name: 'pirate_copies_box', pos: [-1.4, 0, 1.4] }, { name: 'cinema_camcorder', pos: [1.6, 0, 1.4], rotY: -0.8 }, { name: 'cinema_covers', pos: [1.0, 0, 1.8] },
		],
		cam: { pos: [0, 1.6, 4.5], target: [0.1, 0.7, 0], fov: 40 },
	},
	cinema_stories: {
		items: [
			{ name: 'floor_popcorn_bag', pos: [-1.0, 0, 0] }, { name: 'recycle_broom', pos: [-0.3, 0, 0], rotY: 0.4 },
			{ name: 'fresh_sign', pos: [0.4, 0, 0] }, { name: 'ghost_projector', pos: [-0.9, 0, 0.8], rotY: 0.5 },
			{ name: 'holey_sheet', pos: [0, 0, 0.8] }, { name: 'scream_disc', pos: [0.8, 0, 0.8] },
			{ name: 'ticket_press', pos: [1.2, 0, -0.1], rotY: -0.4 }, { name: 'sold_out_stamp', pos: [-0.5, 0, 1.3] }, { name: 'ticket_book', pos: [-0.2, 0, 1.35] },
		],
		cam: { pos: [0, 1.4, 2.6], target: [0, 0.1, 0.4], fov: 40 },
	},
};
