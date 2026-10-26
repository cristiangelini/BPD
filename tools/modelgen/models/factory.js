// Small props of the doll factory "Sonrisas" (docs/diseno/fabrica.md): the fragile porcelain dolls of the showcase and
// the plaster molds of the factory floor, with origins at the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// The dresses of the porcelain dolls, one per doll in the showcase.
const DRESSES = [0xe86a9a, 0x7aa8e8, 0xf2d26a, 0x9ad48a, 0xc89ae8, 0xf29a6a];

// A porcelain doll sitting up straight: 0.3 m tall, white face with pink cheeks, curls and a wide dress.
export function buildPorcelainDoll(i) {
	const b = new Builder(`porcelain_doll_${i}`);
	const skin = mat('porcelain', 0xfbf3ec), dress = mat(`doll_dress_${i}`, DRESSES[i]);
	b.add('dress', dress, new THREE.ConeGeometry(0.09, 0.18, 8), { pos: V(0, -0.06, 0) });
	b.add('collar', mat('doll_lace', 0xffffff), new THREE.CylinderGeometry(0.04, 0.05, 0.02, 8), { pos: V(0, 0.035, 0) });
	b.add('head', skin, ellipsoid(0.055, 0.06, 0.055, 8, 6), { pos: V(0, 0.09, 0) });
	b.add('hair', mat('doll_curls', 0xa86a30), ellipsoid(0.062, 0.045, 0.06, 8, 4), { pos: V(0, 0.12, -0.01) });
	for (const s of [-1, 1]) {
		b.add('eyes', mat('doll_eyes', 0x2a5ab0), ellipsoid(0.01, 0.012, 0.006, 5, 3), { pos: V(s * 0.02, 0.095, 0.05) });
		b.add('cheeks', mat('doll_cheeks', 0xf2a0a8), ellipsoid(0.012, 0.008, 0.004, 5, 3), { pos: V(s * 0.03, 0.075, 0.048) });
		b.add('arms', skin, new THREE.CylinderGeometry(0.012, 0.012, 0.09, 5), { pos: V(s * 0.055, -0.0, 0.01), rot: [0, 0, s * 0.35] });
	}
	return b.build();
}

// A plaster mold of half a doll: a white block 0.3 x 0.12 x 0.2 m with the doll's shape sunk in its top.
export function buildPlasterMold() {
	const b = new Builder('plaster_mold');
	const plaster = mat('plaster', 0xeee8dc), inside = mat('plaster_inside', 0xc8c0b0);
	b.add('block', plaster, new THREE.BoxGeometry(0.3, 0.1, 0.2), { pos: V(0, -0.01, 0) });
	b.add('shape', inside, ellipsoid(0.05, 0.012, 0.05, 8, 3), { pos: V(-0.08, 0.04, 0) });
	b.add('shape', inside, ellipsoid(0.1, 0.012, 0.06, 8, 3), { pos: V(0.04, 0.04, 0) });
	b.add('strap', mat('mold_strap', 0xd23a3a), new THREE.BoxGeometry(0.02, 0.105, 0.205), { pos: V(0.12, -0.01, 0) });
	return b.build();
}

// A doll as it rides the belt, before the machines: bare pink plastic, 0.3 m tall, arms out, no face and no hair.
export function buildFactoryDoll() {
	const b = new Builder('factory_doll');
	const plastic = mat('doll_plastic', 0xf6c6b4);
	b.add('body', plastic, ellipsoid(0.055, 0.08, 0.04, 8, 5), { pos: V(0, -0.02, 0) });
	b.add('head', plastic, ellipsoid(0.05, 0.055, 0.05, 8, 5), { pos: V(0, 0.095, 0) });
	for (const s of [-1, 1]) {
		b.add('legs', plastic, new THREE.CylinderGeometry(0.018, 0.016, 0.07, 6), { pos: V(s * 0.025, -0.115, 0) });
		b.add('arms', plastic, new THREE.CylinderGeometry(0.014, 0.012, 0.08, 6), { pos: V(s * 0.075, 0.0, 0), rot: [0, 0, s * 1.0] });
	}
	return b.build();
}

// The jeweler's loupe: a black eyepiece 0.05 m across with its lens. Extra of the diamond doll.
export function buildJewelerLoupe() {
	const b = new Builder('jeweler_loupe');
	b.add('body', mat('loupe_black', 0x1e1e22), new THREE.CylinderGeometry(0.025, 0.02, 0.035, 10), { pos: V(0, 0, 0) });
	b.add('lens', mat('loupe_lens', 0xbfe4f2, { transparent: true, opacity: 0.6 }), new THREE.CylinderGeometry(0.019, 0.019, 0.004, 10), { pos: V(0, 0.018, 0) });
	return b.build();
}

// The delivery list: a typed sheet 0.21 x 0.3 m with a circled line. Extra of the diamond doll.
export function buildDeliveryList() {
	const b = new Builder('delivery_list');
	b.add('sheet', mat('paper', 0xf6f2e6), new THREE.BoxGeometry(0.21, 0.004, 0.3), { pos: V(0, 0, 0) });
	for (let i = 0; i < 8; i++) {
		b.add('lines', mat('ink', 0x3a3a44), new THREE.BoxGeometry(0.15, 0.001, 0.008), { pos: V(-0.01, 0.0025, -0.11 + i * 0.03) });
	}
	b.add('circle', mat('ink_red', 0xd23a3a), new THREE.TorusGeometry(0.03, 0.003, 3, 12), { pos: V(0.06, 0.003, 0.04), rot: [Math.PI / 2, 0, 0], scale: [2.2, 1, 1] });
	return b.build();
}

// The quality control sheet on a clipboard, 0.23 x 0.32 m, with a big "2 kg" in red. The diamond doll's clue.
export function buildQualitySheet() {
	const b = new Builder('quality_sheet');
	b.add('board', mat('clipboard', 0x8a5a30), new THREE.BoxGeometry(0.23, 0.01, 0.32), { pos: V(0, 0, 0) });
	b.add('sheet', mat('paper', 0xf6f2e6), new THREE.BoxGeometry(0.2, 0.002, 0.27), { pos: V(0, 0.006, 0.01) });
	b.add('clip', mat('clip_steel', 0xb8bcc4), new THREE.BoxGeometry(0.08, 0.012, 0.03), { pos: V(0, 0.008, -0.14) });
	for (let i = 0; i < 6; i++) {
		b.add('lines', mat('ink', 0x3a3a44), new THREE.BoxGeometry(0.14, 0.001, 0.008), { pos: V(-0.02, 0.0075, -0.08 + i * 0.03) });
	}
	b.add('mark', mat('ink_red', 0xd23a3a), new THREE.BoxGeometry(0.06, 0.001, 0.04), { pos: V(0.05, 0.0078, 0.1) });
	return b.build();
}

// The tape recorder with the spy dolls' tapes: a grey reel-to-reel case 0.42 x 0.16 x 0.3 m. Main evidence of the spy dolls.
export function buildTapeRecorder() {
	const b = new Builder('tape_recorder');
	b.add('case', mat('recorder_grey', 0x6a6e76), new THREE.BoxGeometry(0.42, 0.12, 0.3), { pos: V(0, -0.02, 0) });
	b.add('panel', mat('recorder_panel', 0x2a2c30), new THREE.BoxGeometry(0.4, 0.01, 0.28), { pos: V(0, 0.045, 0) });
	for (const s of [-1, 1]) {
		b.add('reels', mat('reel_tape', 0x3a2a20), new THREE.CylinderGeometry(0.07, 0.07, 0.02, 14), { pos: V(s * 0.1, 0.06, -0.03) });
		b.add('hubs', mat('reel_hub', 0xd8d8dc), new THREE.CylinderGeometry(0.02, 0.02, 0.025, 8), { pos: V(s * 0.1, 0.062, -0.03) });
	}
	for (let i = 0; i < 4; i++) {
		b.add('keys', mat('recorder_keys', i === 0 ? 0xd23a3a : 0xc8c8cc), new THREE.BoxGeometry(0.05, 0.02, 0.03), { pos: V(-0.09 + i * 0.06, 0.055, 0.1) });
	}
	return b.build();
}

// The box of tiny microphones: a small black box 0.2 x 0.08 x 0.14 m, open, with mics sticking out. Extra of the spy dolls.
export function buildMicBox() {
	const b = new Builder('mic_box');
	b.add('box', mat('mic_box', 0x1e1e22), new THREE.BoxGeometry(0.2, 0.06, 0.14), { pos: V(0, -0.01, 0) });
	for (let i = 0; i < 6; i++) {
		const x = -0.06 + (i % 3) * 0.06, z = -0.03 + Math.floor(i / 3) * 0.06;
		b.add('mics', mat('mic_steel', 0xb8bcc4), new THREE.SphereGeometry(0.012, 6, 4), { pos: V(x, 0.03, z) });
	}
	return b.build();
}

// The client list: a sheet 0.21 x 0.3 m with a "CONFIDENCIAL" red band. Extra of the spy dolls.
export function buildClientList() {
	const b = new Builder('client_list');
	b.add('sheet', mat('paper', 0xf6f2e6), new THREE.BoxGeometry(0.21, 0.004, 0.3), { pos: V(0, 0, 0) });
	b.add('band', mat('ink_red', 0xd23a3a), new THREE.BoxGeometry(0.17, 0.001, 0.03), { pos: V(0, 0.0025, -0.12) });
	for (let i = 0; i < 7; i++) {
		b.add('lines', mat('ink', 0x3a3a44), new THREE.BoxGeometry(0.15, 0.001, 0.008), { pos: V(0, 0.0025, -0.07 + i * 0.03) });
	}
	return b.build();
}

// The astronaut helmet the fake Captain Galaxy dolls wear: a white bubble 0.13 m across with a blue visor, centered
// on the doll's head (origin at the head's middle).
export function buildCaptainHelmet() {
	const b = new Builder('captain_helmet');
	b.add('bubble', mat('helmet_white', 0xf2f2f6), ellipsoid(0.065, 0.068, 0.065, 10, 6), { pos: V(0, 0.005, 0) });
	b.add('visor', mat('helmet_visor', 0x3a6ab8), ellipsoid(0.045, 0.035, 0.02, 8, 4), { pos: V(0, 0.0, 0.055) });
	b.add('antenna', mat('helmet_antenna', 0xd23a3a), new THREE.CylinderGeometry(0.004, 0.004, 0.05, 5), { pos: V(0.035, 0.075, 0) });
	return b.build();
}

// A reject fake Captain Galaxy: the belt doll with the helmet and its face painted crooked (one eye high, the mouth
// slanted). The story's clue, in the reject dumpster.
export function buildRejectCaptain() {
	const b = new Builder('reject_captain');
	const plastic = mat('doll_plastic', 0xf6c6b4);
	b.add('body', mat('captain_suit', 0x8a9ab0), ellipsoid(0.055, 0.08, 0.04, 8, 5), { pos: V(0, -0.02, 0) });
	b.add('head', plastic, ellipsoid(0.05, 0.055, 0.05, 8, 5), { pos: V(0, 0.095, 0) });
	b.add('bubble', mat('helmet_white', 0xf2f2f6, { transparent: true, opacity: 0.45 }), ellipsoid(0.065, 0.068, 0.065, 10, 6), { pos: V(0, 0.1, 0) });
	b.add('eyes', mat('doll_eyes_paint', 0x1e1e22), ellipsoid(0.01, 0.01, 0.005, 5, 3), { pos: V(-0.02, 0.1, 0.047) });
	b.add('eyes', mat('doll_eyes_paint', 0x1e1e22), ellipsoid(0.012, 0.007, 0.005, 5, 3), { pos: V(0.022, 0.125, 0.044) });
	b.add('mouth', mat('doll_mouth_paint', 0xd23a3a), new THREE.BoxGeometry(0.035, 0.006, 0.004), { pos: V(0.005, 0.072, 0.048), rot: [0, 0, 0.45] });
	for (const s of [-1, 1]) {
		b.add('legs', plastic, new THREE.CylinderGeometry(0.018, 0.016, 0.07, 6), { pos: V(s * 0.025, -0.115, 0) });
		b.add('arms', plastic, new THREE.CylinderGeometry(0.014, 0.012, 0.08, 6), { pos: V(s * 0.075, 0.0, 0), rot: [0, 0, s * 1.0] });
	}
	return b.build();
}

// The competitor's stolen mold of Captain Galaxy: a heavy steel mold 0.6 x 0.3 x 0.4 m in two halves bolted shut, with
// the captain's star on top. Main evidence of the fake captain (15 kg).
export function buildStolenMold() {
	const b = new Builder('stolen_mold');
	const steel = mat('mold_steel', 0x8a9098);
	b.add('halves', steel, new THREE.BoxGeometry(0.6, 0.14, 0.4), { pos: V(0, -0.075, 0) });
	b.add('halves', mat('mold_steel_dark', 0x6a7078), new THREE.BoxGeometry(0.6, 0.14, 0.4), { pos: V(0, 0.075, 0) });
	for (const x of [-0.26, 0.26]) for (const z of [-0.16, 0.16]) {
		b.add('bolts', mat('bolt', 0xd8c050), new THREE.CylinderGeometry(0.02, 0.02, 0.03, 6), { pos: V(x, 0.155, z) });
	}
	const star = new THREE.Shape();
	for (let i = 0; i < 10; i++) {
		const r = i % 2 ? 0.045 : 0.1, a = Math.PI / 2 + i * Math.PI / 5;
		if (i === 0) star.moveTo(Math.cos(a) * r, Math.sin(a) * r); else star.lineTo(Math.cos(a) * r, Math.sin(a) * r);
	}
	b.add('star', mat('captain_star', 0xf2c230), new THREE.ExtrudeGeometry(star, { depth: 0.01, bevelEnabled: false }), { pos: V(0, 0.15, 0), rot: [-Math.PI / 2, 0, 0] });
	return b.build();
}

// A roll of fake "Capitán Galaxia" labels: a stack of yellow labels 0.15 x 0.1 x 0.1 m tied with a rubber band.
export function buildFakeLabels() {
	const b = new Builder('fake_labels');
	b.add('stack', mat('label_yellow', 0xf2d040), new THREE.BoxGeometry(0.15, 0.1, 0.1), { pos: V(0, 0, 0) });
	b.add('print', mat('label_blue', 0x3a6ab8), new THREE.BoxGeometry(0.1, 0.06, 0.002), { pos: V(0, 0, 0.051) });
	b.add('band', mat('rubber_band', 0xd23a3a), new THREE.BoxGeometry(0.152, 0.012, 0.102), { pos: V(0, 0, 0) });
	return b.build();
}

// The prototype photos: three snapshots 0.1 x 0.15 m fanned out, of a doll in a helmet.
export function buildPrototypePhotos() {
	const b = new Builder('prototype_photos');
	for (let i = 0; i < 3; i++) {
		b.add('photo', mat('photo_border', 0xf6f6f2), new THREE.BoxGeometry(0.1, 0.002, 0.15), { pos: V(-0.03 + i * 0.03, i * 0.002, 0), rot: [0, -0.3 + i * 0.3, 0] });
		b.add('picture', mat('photo_picture', 0x4a6a9a), new THREE.BoxGeometry(0.08, 0.001, 0.1), { pos: V(-0.03 + i * 0.03, i * 0.002 + 0.0015, -0.01), rot: [0, -0.3 + i * 0.3, 0] });
	}
	return b.build();
}

// The payroll book: a thick green ledger 0.22 x 0.05 x 0.3 m. Main evidence of the ghost workers.
export function buildPayrollBook() {
	const b = new Builder('payroll_book');
	b.add('cover', mat('ledger_green', 0x2a6a4a), new THREE.BoxGeometry(0.22, 0.05, 0.3), { pos: V(0, 0, 0) });
	b.add('pages', mat('paper', 0xf6f2e6), new THREE.BoxGeometry(0.2, 0.04, 0.29), { pos: V(0.012, 0, 0) });
	b.add('label', mat('ledger_label', 0xf2d040), new THREE.BoxGeometry(0.1, 0.002, 0.05), { pos: V(0, 0.026, -0.06) });
	return b.build();
}

// The ten time cards of the ghost workers, held with a clip: a stack 0.08 x 0.03 x 0.18 m.
export function buildTimeCards() {
	const b = new Builder('time_cards');
	b.add('stack', mat('card_cream', 0xf6ecd0), new THREE.BoxGeometry(0.08, 0.025, 0.18), { pos: V(0, 0, 0) });
	b.add('stripe', mat('card_red', 0xd23a3a), new THREE.BoxGeometry(0.082, 0.026, 0.01), { pos: V(0, 0, -0.07) });
	b.add('clip', mat('clip_steel', 0xb8bcc4), new THREE.BoxGeometry(0.03, 0.03, 0.02), { pos: V(0, 0.005, 0.085) });
	return b.build();
}

// Fermín's wig: a black curly mop 0.24 x 0.1 x 0.26 m, to pass for one more worker on the night shift.
export function buildForemanWig() {
	const b = new Builder('foreman_wig');
	const hair = mat('wig_black', 0x1e1a18);
	b.add('mop', hair, ellipsoid(0.12, 0.05, 0.13, 10, 5), { pos: V(0, 0, 0) });
	for (let i = 0; i < 8; i++) {
		const a = i * Math.PI / 4;
		b.add('curls', hair, ellipsoid(0.03, 0.03, 0.03, 5, 3), { pos: V(Math.cos(a) * 0.1, 0.01, Math.sin(a) * 0.11) });
	}
	return b.build();
}

// The giant parade doll: 3 m tall, a porcelain-like doll in a wide sky blue dress, its back open where the zipper is
// (the flap is its own model, giant_doll_flap). Origin on the floor at its middle; it faces +z.
export function buildGiantDoll() {
	const b = new Builder('giant_doll');
	const dress = mat('giant_dress', 0x7ab8e8, { side: THREE.DoubleSide }), skin = mat('porcelain', 0xfbf3ec);
	b.add('dress', dress, new THREE.CylinderGeometry(0.4, 0.85, 1.6, 12, 1, true, Math.PI * 1.25, Math.PI * 1.5), { pos: V(0, 0.8, 0) });
	b.add('hem', mat('doll_lace', 0xffffff), new THREE.TorusGeometry(0.85, 0.04, 4, 16, Math.PI * 1.5), { pos: V(0, 0.04, 0), rot: [Math.PI / 2, 0, Math.PI * 0.75] });
	b.add('torso', dress, ellipsoid(0.42, 0.5, 0.34, 10, 6), { pos: V(0, 1.85, 0) });
	b.add('collar', mat('doll_lace', 0xffffff), new THREE.CylinderGeometry(0.2, 0.26, 0.1, 10), { pos: V(0, 2.32, 0) });
	b.add('head', skin, ellipsoid(0.36, 0.38, 0.36, 10, 7), { pos: V(0, 2.6, 0) });
	b.add('hair', mat('doll_curls', 0xa86a30), ellipsoid(0.4, 0.26, 0.38, 10, 5), { pos: V(0, 2.82, -0.06) });
	for (const s of [-1, 1]) {
		b.add('eyes', mat('doll_eyes', 0x2a5ab0), ellipsoid(0.06, 0.07, 0.03, 6, 4), { pos: V(s * 0.13, 2.65, 0.32) });
		b.add('cheeks', mat('doll_cheeks', 0xf2a0a8), ellipsoid(0.07, 0.045, 0.02, 6, 4), { pos: V(s * 0.2, 2.5, 0.3) });
		b.add('arms', skin, new THREE.CylinderGeometry(0.08, 0.07, 0.8, 8), { pos: V(s * 0.55, 1.7, 0.05), rot: [0, 0, s * 0.45] });
		b.add('curls', mat('doll_curls', 0xa86a30), ellipsoid(0.1, 0.18, 0.1, 6, 4), { pos: V(s * 0.38, 2.5, -0.05) });
	}
	b.add('mouth', mat('doll_mouth_paint', 0xd23a3a), ellipsoid(0.06, 0.03, 0.02, 6, 3), { pos: V(0, 2.42, 0.33) });
	return b.build();
}

// The back flap of the giant doll's dress, with the zipper down its middle: it closes the open quarter of the dress.
export function buildGiantDollFlap() {
	const b = new Builder('giant_doll_flap');
	b.add('flap', mat('giant_dress', 0x7ab8e8, { side: THREE.DoubleSide }), new THREE.CylinderGeometry(0.4, 0.85, 1.6, 4, 1, true, Math.PI * 0.75, Math.PI * 0.5), { pos: V(0, 0.8, 0) });
	b.add('zipper', mat('zipper_steel', 0xc8ccd2), new THREE.BoxGeometry(0.03, 1.6, 0.03), { pos: V(0, 0.8, -0.635), rot: [0.27, 0, 0] });
	b.add('zipper', mat('zipper_pull', 0xd8c050), new THREE.BoxGeometry(0.06, 0.1, 0.03), { pos: V(0, 1.45, -0.45), rot: [0.27, 0, 0] });
	return b.build();
}

// The parade plan: a street map 0.3 x 0.21 m with a dotted route in red. Extra of the giant doll.
export function buildParadePlan() {
	const b = new Builder('parade_plan');
	b.add('sheet', mat('map_paper', 0xe8eee0), new THREE.BoxGeometry(0.3, 0.004, 0.21), { pos: V(0, 0, 0) });
	for (let i = 0; i < 4; i++) b.add('streets', mat('map_street', 0xb8bcc4), new THREE.BoxGeometry(0.28, 0.001, 0.01), { pos: V(0, 0.0025, -0.08 + i * 0.05) });
	for (let i = 0; i < 6; i++) b.add('route', mat('ink_red', 0xd23a3a), new THREE.BoxGeometry(0.025, 0.001, 0.008), { pos: V(-0.12 + i * 0.045, 0.003, -0.03 + (i % 2) * 0.05) });
	return b.build();
}

// The safe's key: a long brass key 0.12 m with a red tag. Extra of the giant doll.
export function buildSafeKey() {
	const b = new Builder('safe_key');
	const brass = mat('brass', 0xd8b040);
	b.add('bow', brass, new THREE.TorusGeometry(0.02, 0.006, 4, 10), { pos: V(-0.05, 0, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('shaft', brass, new THREE.BoxGeometry(0.09, 0.008, 0.008), { pos: V(0.015, 0, 0) });
	b.add('bit', brass, new THREE.BoxGeometry(0.015, 0.008, 0.025), { pos: V(0.05, 0, 0.012) });
	b.add('tag', mat('tag_red', 0xd23a3a), new THREE.BoxGeometry(0.03, 0.003, 0.045), { pos: V(-0.085, 0, 0.01) });
	return b.build();
}

// The bag of stolen poodle hair: a clear sack 0.4 x 0.35 x 0.3 m stuffed with pink curls. Main evidence of the poodle
// hair (3 kg).
export function buildPoodleHairBag() {
	const b = new Builder('poodle_hair_bag');
	const pink = mat('poodle_pink', 0xf2a0c8);
	b.add('sack', mat('sack_clear', 0xe8f0f6, { transparent: true, opacity: 0.45 }), ellipsoid(0.2, 0.17, 0.15, 10, 6), { pos: V(0, 0, 0) });
	for (let i = 0; i < 9; i++) {
		const a = i * 2.4, r = 0.08 + (i % 3) * 0.03;
		b.add('curls', pink, ellipsoid(0.06, 0.05, 0.06, 6, 4), { pos: V(Math.cos(a) * r, -0.06 + (i % 4) * 0.04, Math.sin(a) * r * 0.7) });
	}
	b.add('knot', mat('sack_tie', 0xd8c050), new THREE.CylinderGeometry(0.02, 0.03, 0.05, 6), { pos: V(0, 0.18, 0) });
	return b.build();
}

// The groomer's golden comb: 0.18 m long with its teeth. Extra of the poodle hair.
export function buildGoldComb() {
	const b = new Builder('gold_comb');
	const gold = mat('comb_gold', 0xe8c040, { metalness: 0.6, roughness: 0.4 });
	b.add('spine', gold, new THREE.BoxGeometry(0.18, 0.008, 0.03), { pos: V(0, 0, -0.02) });
	for (let i = 0; i < 12; i++) b.add('teeth', gold, new THREE.BoxGeometry(0.006, 0.006, 0.03), { pos: V(-0.08 + i * 0.0145, 0, 0.01) });
	return b.build();
}

// The fake invoice: "100 kg de pelo sintético", a sheet 0.15 x 0.21 m with a stamp. Extra of the poodle hair.
export function buildFakeInvoice() {
	const b = new Builder('fake_invoice');
	b.add('sheet', mat('paper', 0xf6f2e6), new THREE.BoxGeometry(0.15, 0.003, 0.21), { pos: V(0, 0, 0) });
	for (let i = 0; i < 5; i++) b.add('lines', mat('ink', 0x3a3a44), new THREE.BoxGeometry(0.11, 0.001, 0.007), { pos: V(-0.01, 0.002, -0.07 + i * 0.025) });
	b.add('stamp', mat('stamp_blue', 0x3a6ab8), new THREE.CylinderGeometry(0.025, 0.025, 0.001, 10), { pos: V(0.035, 0.002, 0.07) });
	return b.build();
}

export const models = {
	poodle_hair_bag: buildPoodleHairBag, gold_comb: buildGoldComb, fake_invoice: buildFakeInvoice,
	giant_doll: buildGiantDoll, giant_doll_flap: buildGiantDollFlap, parade_plan: buildParadePlan, safe_key: buildSafeKey,
	payroll_book: buildPayrollBook, time_cards: buildTimeCards, foreman_wig: buildForemanWig,
	captain_helmet: buildCaptainHelmet, reject_captain: buildRejectCaptain, stolen_mold: buildStolenMold,
	fake_labels: buildFakeLabels, prototype_photos: buildPrototypePhotos,
	tape_recorder: buildTapeRecorder, mic_box: buildMicBox, client_list: buildClientList,
	jeweler_loupe: buildJewelerLoupe, delivery_list: buildDeliveryList, quality_sheet: buildQualitySheet,
	factory_doll: buildFactoryDoll,
	...Object.fromEntries(DRESSES.map((_, i) => [`porcelain_doll_${i}`, () => buildPorcelainDoll(i)])),
	plaster_mold: buildPlasterMold,
};

export const views = {
	poodle_goods: {
		items: [
			{ name: 'poodle_hair_bag', pos: [-0.2, 0.17, 0] }, { name: 'gold_comb', pos: [0.2, 0.004, 0.1] },
			{ name: 'fake_invoice', pos: [0.05, 0.002, 0.3], rotY: 0.3 },
		],
		cam: { pos: [0, 0.6, 0.9], target: [0, 0.08, 0.1], fov: 40 },
	},
	giant_doll: {
		items: [
			{ name: 'giant_doll', pos: [-1.0, 0, 0], rotY: 3.6 }, { name: 'giant_doll_flap', pos: [-1.0, 0, 0], rotY: 3.6 },
			{ name: 'giant_doll', pos: [1.0, 0, 0], rotY: 2.8 },
			{ name: 'parade_plan', pos: [0.1, 0.002, 1.0] }, { name: 'safe_key', pos: [0.5, 0.004, 1.0] },
		],
		cam: { pos: [0, 2.2, 5.5], target: [0, 1.3, 0], fov: 40 },
	},
	ghost_goods: {
		items: [
			{ name: 'payroll_book', pos: [-0.2, 0.025, 0] }, { name: 'time_cards', pos: [0.15, 0.013, 0.05] },
			{ name: 'foreman_wig', pos: [0.05, 0.05, 0.3] },
		],
		cam: { pos: [0, 0.6, 0.9], target: [0, 0.03, 0.1], fov: 40 },
	},
	captain_goods: {
		items: [
			{ name: 'stolen_mold', pos: [-0.25, 0.15, -0.1] }, { name: 'reject_captain', pos: [0.2, 0.15, 0.1] },
			{ name: 'fake_labels', pos: [0.35, 0.05, -0.15] }, { name: 'prototype_photos', pos: [0.0, 0.002, 0.35] },
			{ name: 'captain_helmet', pos: [0.4, 0.07, 0.3] },
		],
		cam: { pos: [0, 0.8, 1.2], target: [0, 0.05, 0.05], fov: 40 },
	},
	spy_goods: {
		items: [
			{ name: 'tape_recorder', pos: [-0.15, 0.08, 0] }, { name: 'mic_box', pos: [0.22, 0.04, 0.05] },
			{ name: 'client_list', pos: [0.05, 0.002, 0.3], rotY: 0.3 },
		],
		cam: { pos: [0, 0.7, 1.0], target: [0, 0.05, 0.1], fov: 40 },
	},
	diamond_goods: {
		items: [
			{ name: 'factory_doll', pos: [-0.2, 0.15, 0] }, { name: 'jeweler_loupe', pos: [0.05, 0.02, 0.1] },
			{ name: 'delivery_list', pos: [0.25, 0.002, 0], rotY: 0.3 }, { name: 'quality_sheet', pos: [0, 0.005, 0.3], rotY: -0.2 },
		],
		cam: { pos: [0, 0.6, 0.9], target: [0, 0.05, 0.1], fov: 40 },
	},
	factory: {
		items: [
			{ name: 'porcelain_doll_0', pos: [-0.25, 0.15, 0] }, { name: 'porcelain_doll_1', pos: [0, 0.15, -0.1] },
			{ name: 'porcelain_doll_2', pos: [0.25, 0.15, 0] }, { name: 'plaster_mold', pos: [0, 0.06, 0.25] }, { name: 'factory_doll', pos: [0.35, 0.15, 0.2] },
		],
		cam: { pos: [0, 0.45, 1.0], target: [0, 0.1, 0.05], fov: 36 },
	},
};
