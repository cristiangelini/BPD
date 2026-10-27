// Props of the bowling alley "Bolos Chuza Feliz" (docs/diseno/allanamiento-bolera.md): a pin, a ball, the pin machine
// over each lane's end, the ball return with its rack, a score screen, the shoe counter with its shelf, the bar, the
// popcorn machine, the trophy case, a bench and the giant pin of the sign, with origins at the floor in the middle of
// each piece, the two looks of the Thursday league's players and Don Chuza, the owner, and Pipo, the shoe boy. Placeholder, not final art.
import { Builder, mat, ellipsoid, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const BALLS = [0x3a6ad2, 0xe8473a, 0x46b45a, 0xb05ad2, 0xf2c230, 0x202428];

// A pin 0.38 m tall: white, wide belly, thin neck, two red stripes.
function pinParts(b, scale = 1, white = mat('pin_white', 0xf6f4ee), red = mat('pin_red', 0xd83a30)) {
	const points = [[0, 0], [0.026, 0], [0.05, 0.06], [0.06, 0.13], [0.045, 0.21], [0.022, 0.26], [0.024, 0.3], [0.032, 0.34], [0.026, 0.37], [0, 0.38]]
		.map(([r, y]) => new THREE.Vector2(r * scale, y * scale));
	b.add('pin', white, new THREE.LatheGeometry(points, 10));
	for (const y of [0.255, 0.285]) b.add('stripe', red, new THREE.CylinderGeometry(0.024 * scale, 0.023 * scale, 0.012 * scale, 10), { pos: V(0, y * scale, 0) });
}

export function buildBowlingPin() {
	const b = new Builder('bowling_pin');
	pinParts(b);
	return b.build();
}

// A ball 0.22 m across, its middle at 0.11 m, with three finger holes on top.
export function buildBowlingBall() {
	const b = new Builder('bowling_ball');
	b.add('ball', mat('ball_blue', BALLS[0], { roughness: 0.25 }), new THREE.IcosahedronGeometry(0.11, 2), { pos: V(0, 0.11, 0) });
	const hole = mat('ball_hole', 0x101010);
	for (const [x, z] of [[-0.025, -0.02], [0.025, -0.02], [0, 0.035]]) b.add('hole', hole, new THREE.CylinderGeometry(0.012, 0.012, 0.01, 8), { pos: V(x, 0.218, z) });
	return b.build();
}

// The pin machine over the end of a lane, 1.5 m wide (along X), 1.0 m deep and 2.2 m tall, open underneath where the
// pins stand: dark box with the alley's orange stripe and a pin painted on the front.
export function buildPinSetter() {
	const b = new Builder('pin_setter');
	const dark = mat('setter_dark', 0x2a2c34), orange = mat('setter_orange', 0xf08a2a);
	b.add('hood', dark, new THREE.BoxGeometry(1.5, 1.3, 1.0), { pos: V(0, 1.55, 0) });
	b.add('stripe', orange, new THREE.BoxGeometry(1.5, 0.12, 0.02), { pos: V(0, 1.3, 0.51) });
	for (const x of [-0.72, 0.72]) b.add('side', dark, new THREE.BoxGeometry(0.06, 0.9, 1.0), { pos: V(x, 0.45, 0) });
	b.add('mark', mat('setter_pin', 0xf6f4ee), new THREE.BoxGeometry(0.12, 0.5, 0.02), { pos: V(0, 1.75, 0.51) });
	return b.build();
}

// The ball return between two lanes, 0.6 m wide and 1.0 m long (along Z): the hood where balls come up and the rack
// the game's balls rest on.
export function buildBallReturn() {
	const b = new Builder('ball_return');
	const body = mat('return_body', 0x3a3e48), chrome = mat('return_chrome', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 });
	b.add('hood', body, new THREE.BoxGeometry(0.6, 0.8, 0.4), { pos: V(0, 0.4, -0.3) });
	b.add('top', mat('return_orange', 0xf08a2a), new THREE.BoxGeometry(0.62, 0.06, 0.42), { pos: V(0, 0.83, -0.3) });
	for (const x of [-0.12, 0.12]) b.add('rail', chrome, new THREE.BoxGeometry(0.03, 0.03, 0.7), { pos: V(x, 0.5, 0.15) });
	b.add('legs', body, new THREE.BoxGeometry(0.4, 0.48, 0.5), { pos: V(0, 0.24, 0.2) });
	return b.build();
}

// A score screen 1.2 m wide, hanging from the ceiling by two bars: the frame, the blue screen and a row of squares.
export function buildScoreScreen() {
	const b = new Builder('score_screen');
	b.add('frame', mat('screen_frame', 0x202228), new THREE.BoxGeometry(1.2, 0.7, 0.08), { pos: V(0, 0, 0) });
	b.add('screen', mat('screen_blue', 0x2a5ad2, { emissive: 0x10308a }), new THREE.BoxGeometry(1.1, 0.6, 0.01), { pos: V(0, 0, 0.045) });
	for (let i = 0; i < 5; i++) b.add('cells', mat('screen_cell', 0xf2f2ea, { emissive: 0x606060 }), new THREE.BoxGeometry(0.16, 0.14, 0.005), { pos: V(-0.42 + i * 0.21, 0.1, 0.052) });
	for (const x of [-0.45, 0.45]) b.add('bars', mat('screen_bar', 0x8a8e94), new THREE.CylinderGeometry(0.015, 0.015, 1.0, 6), { pos: V(x, 0.85, 0) });
	return b.build();
}

// The shoe counter, 4 m wide (along X), 1.1 m tall, its front to +Z, and the shelf of two-colored shoes behind it.
export function buildShoeCounter() {
	const b = new Builder('shoe_counter');
	b.add('counter', mat('counter_orange', 0xf08a2a), new THREE.BoxGeometry(4.0, 1.05, 0.7), { pos: V(0, 0.525, 0) });
	b.add('top', mat('counter_top', 0xf2f2ea), new THREE.BoxGeometry(4.1, 0.05, 0.8), { pos: V(0, 1.075, 0) });
	const wood = mat('shelf_wood', 0x8a5a30);
	b.add('shelf_back', wood, new THREE.BoxGeometry(4.0, 2.2, 0.05), { pos: V(0, 1.1, -1.45) });
	const red = mat('shoe_red', 0xd83a30), blue = mat('shoe_blue', 0x3a6ad2), white = mat('shoe_white', 0xf6f4ee);
	for (const y of [0.4, 0.9, 1.4, 1.9]) {
		b.add('shelf', wood, new THREE.BoxGeometry(4.0, 0.03, 0.35), { pos: V(0, y, -1.27) });
		for (let i = 0; i < 10; i++) {
			b.add('shoe', (i + y * 2) % 2 < 1 ? red : blue, new THREE.BoxGeometry(0.12, 0.08, 0.26), { pos: V(-1.8 + i * 0.4, y + 0.055, -1.27) });
			b.add('toe', white, new THREE.BoxGeometry(0.12, 0.05, 0.08), { pos: V(-1.8 + i * 0.4, y + 0.04, -1.16) });
		}
	}
	return b.build();
}

// The bar, 3 m wide (along X), its front to +Z, with three stools in front.
export function buildBowlingBar() {
	const b = new Builder('bowling_bar');
	b.add('bar', mat('bar_red', 0xa83a30), new THREE.BoxGeometry(3.0, 1.05, 0.7), { pos: V(0, 0.525, 0) });
	b.add('top', mat('bar_top', 0x2a2c34), new THREE.BoxGeometry(3.1, 0.05, 0.8), { pos: V(0, 1.075, 0) });
	for (const x of [-1, 0, 1]) {
		b.add('stool', mat('stool_chrome', 0xc8ccd2), new THREE.CylinderGeometry(0.03, 0.03, 0.7, 6), { pos: V(x, 0.35, 0.75) });
		b.add('seat', mat('stool_seat', 0xd83a30), new THREE.CylinderGeometry(0.18, 0.18, 0.08, 10), { pos: V(x, 0.74, 0.75) });
	}
	return b.build();
}

// The popcorn machine, 0.6 m wide and 0.9 m tall: red cart, glass box full of yellow popcorn.
export function buildPopcornMachine() {
	const b = new Builder('popcorn_machine');
	b.add('cart', mat('popcorn_red', 0xd83a30), new THREE.BoxGeometry(0.6, 0.35, 0.5), { pos: V(0, 0.175, 0) });
	b.add('glass', mat('popcorn_glass', 0xa8d8f0, { opacity: 0.35, transparent: true }), new THREE.BoxGeometry(0.56, 0.45, 0.46), { pos: V(0, 0.575, 0) });
	b.add('popcorn', mat('popcorn_yellow', 0xf6e08a), new THREE.BoxGeometry(0.52, 0.2, 0.42), { pos: V(0, 0.46, 0) });
	b.add('roof', mat('popcorn_red', 0xd83a30), new THREE.ConeGeometry(0.42, 0.12, 4), { pos: V(0, 0.86, 0), rot: [0, Math.PI / 4, 0] });
	return b.build();
}

// The trophy case, 2 m wide (along X), 0.6 m deep and 2 m tall, its glass to +Z, with gold cups on three shelves.
export function buildTrophyCase() {
	const b = new Builder('trophy_case');
	const wood = mat('case_wood', 0x5a3a20), gold = mat('trophy_gold', 0xf0c040, { metalness: 0.7, roughness: 0.3 });
	b.add('back', wood, new THREE.BoxGeometry(2.0, 2.0, 0.05), { pos: V(0, 1.0, -0.28) });
	for (const x of [-0.98, 0.98]) b.add('side', wood, new THREE.BoxGeometry(0.05, 2.0, 0.6), { pos: V(x, 1.0, 0) });
	b.add('glass', mat('case_glass', 0xa8d8f0, { opacity: 0.3, transparent: true }), new THREE.BoxGeometry(1.92, 1.9, 0.02), { pos: V(0, 1.0, 0.29) });
	for (const y of [0.1, 0.75, 1.4]) {
		b.add('shelf', wood, new THREE.BoxGeometry(1.92, 0.04, 0.55), { pos: V(0, y, 0) });
		for (let i = 0; i < 4; i++) {
			b.add('cup', gold, new THREE.CylinderGeometry(0.07, 0.03, 0.14, 8), { pos: V(-0.66 + i * 0.44, y + 0.2, 0) });
			b.add('foot', gold, new THREE.BoxGeometry(0.1, 0.06, 0.1), { pos: V(-0.66 + i * 0.44, y + 0.05, 0) });
		}
	}
	return b.build();
}

// A bench for the players, 2.4 m long (along X), orange plastic seats.
export function buildBowlingBench() {
	const b = new Builder('bowling_bench');
	b.add('frame', mat('bench_frame', 0x3a3e48), new THREE.BoxGeometry(2.4, 0.08, 0.5), { pos: V(0, 0.4, 0) });
	for (const x of [-1.1, 1.1]) b.add('leg', mat('bench_frame', 0x3a3e48), new THREE.BoxGeometry(0.08, 0.4, 0.4), { pos: V(x, 0.2, 0) });
	for (let i = 0; i < 4; i++) {
		b.add('seat', mat('bench_seat', 0xf08a2a), new THREE.BoxGeometry(0.5, 0.06, 0.45), { pos: V(-0.9 + i * 0.6, 0.47, 0) });
		b.add('back', mat('bench_seat', 0xf08a2a), new THREE.BoxGeometry(0.5, 0.45, 0.05), { pos: V(-0.9 + i * 0.6, 0.72, -0.22) });
	}
	return b.build();
}

// The giant pin of the sign, 2.5 m tall.
export function buildGiantPin() {
	const b = new Builder('giant_pin');
	pinParts(b, 6.5);
	return b.build();
}

// The same ball in the other colors, for the racks.
function coloredBall(i) {
	return () => {
		const b = new Builder('bowling_ball_' + i);
		b.add('ball', mat('ball_' + i, BALLS[i], { roughness: 0.25 }), new THREE.IcosahedronGeometry(0.11, 2), { pos: V(0, 0.11, 0) });
		const hole = mat('ball_hole', 0x101010);
		for (const [x, z] of [[-0.025, -0.02], [0.025, -0.02], [0, 0.035]]) b.add('hole', hole, new THREE.CylinderGeometry(0.012, 0.012, 0.01, 8), { pos: V(x, 0.218, z) });
		return b.build();
	};
}

// A player of the Thursday league: the team's shiny shirt (purple with a yellow stripe and "LOS CHUZA" on the back), a
// sweatband and a towel over the shoulder; the other look wears glasses, a mustache and a wrist brace.
function bowler(name, skin, shirtColor, b2) {
	return () => {
		const b = new Builder(name);
		const shirt = mat(name + '_shirt', shirtColor, { roughness: 0.3 }), stripe = mat('league_stripe', 0xf2c230);
		pearBody(b, mat(name + '_skin', skin), { shirt, pants: mat('league_pants', 0x2a2a34), shoes: mat('rental_shoes', 0xd23a3a), belted: false });
		for (const y of [0.78, 0.86]) b.add('stripe', stripe, new THREE.TorusGeometry(0.36 - (y - 0.78) * 0.6, 0.018, 4, 16), { pos: V(0, y, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('stripe', stripe, new THREE.BoxGeometry(0.3, 0.07, 0.01), { pos: V(0, 0.9, -0.33), rot: [0.3, 0, 0] });
		eyes(b, 1.34, 0.17, 0.08, 0.05);
		b.add('face', mat('mouth', 0x7a2a2a), ellipsoid(0.06, 0.02, 0.02, 6, 4), { pos: V(0, 1.22, 0.2) });
		const hair = mat(name + '_hair', b2 ? 0x8a8a8a : 0x4a2a1a);
		b.add('hair', hair, ellipsoid(0.2, 0.09, 0.2, 10, 5), { pos: V(0, 1.45, -0.02) });
		if (b2) {
			for (const s of [-1, 1]) b.add('glasses', M.black, new THREE.TorusGeometry(0.045, 0.008, 4, 10), { pos: V(s * 0.08, 1.34, 0.2) });
			b.add('face', hair, new THREE.BoxGeometry(0.16, 0.03, 0.03), { pos: V(0, 1.26, 0.2) });
			limb(b, 'brace', M.black, V(0.49, 0.6, 0.06), V(0.5, 0.7, 0.1), 0.05);
		} else {
			b.add('band', mat('sweatband', 0xf6f4ee), new THREE.TorusGeometry(0.2, 0.025, 4, 16), { pos: V(0, 1.42, 0), rot: [Math.PI / 2, 0, 0] });
			b.add('towel', mat('towel', 0x46b45a), new THREE.BoxGeometry(0.16, 0.03, 0.34), { pos: V(-0.22, 1.08, 0), rot: [0, 0, 0.5] });
		}
		return b.build();
	};
}

// Don Chuza, the owner: a shiny black bowling shirt with orange and red flames up from the hem, a bowling glove on
// his right hand, a wide mustache and gelled hair with a curl at the front. The game scales him short and round.
export function buildDonChuza() {
	const b = new Builder('npc_don_chuza');
	const shirt = mat('chuza_shirt', 0x18181c, { roughness: 0.25 });
	pearBody(b, mat('skin_trigo', 0xe0b48a), { shirt, pants: mat('chuza_slacks', 0x6a4a2a), shoes: mat('chuza_shoes', 0xd23a3a), belted: false });
	const flames = [mat('flame_orange', 0xf08a2a), mat('flame_red', 0xd83a30), mat('flame_yellow', 0xf2c230)];
	for (let i = 0; i < 14; i++) {
		const a = (i / 14) * Math.PI * 2;
		const tall = 0.2 + (i % 3) * 0.07;
		b.add('flames', flames[i % 3], new THREE.ConeGeometry(0.1, tall, 4), { pos: V(Math.sin(a) * 0.42, 0.58 + tall / 2, Math.cos(a) * 0.39), rot: [Math.cos(a) * -0.25, 0, Math.sin(a) * 0.25] });
	}
	b.add('collar', mat('chuza_collar', 0xf6f4ee), new THREE.TorusGeometry(0.2, 0.03, 4, 12), { pos: V(0, 1.06, 0.02), rot: [Math.PI / 2, 0, 0] });
	eyes(b, 1.34, 0.17, 0.08, 0.05);
	const hair = mat('chuza_hair', 0x141418, { roughness: 0.15 });
	b.add('hair', hair, ellipsoid(0.21, 0.09, 0.21, 10, 5), { pos: V(0, 1.46, -0.02) });
	b.add('hair', hair, ellipsoid(0.07, 0.05, 0.08, 6, 4), { pos: V(0, 1.53, 0.14), rot: [0.6, 0, 0] });
	b.add('face', hair, new THREE.BoxGeometry(0.26, 0.04, 0.04), { pos: V(0, 1.26, 0.2) });
	for (const s of [-1, 1]) b.add('face', hair, ellipsoid(0.04, 0.025, 0.025, 6, 4), { pos: V(s * 0.14, 1.24, 0.19) });
	b.add('glove', mat('bowling_glove', 0xf6f4ee), new THREE.BoxGeometry(0.13, 0.12, 0.12), { pos: V(0.5, 0.62, 0.1) });
	b.add('glove', mat('glove_strap', 0x3a6ad2), new THREE.BoxGeometry(0.14, 0.03, 0.13), { pos: V(0.5, 0.67, 0.1) });
	return b.build();
}

// Pipo, the shoe boy: a skinny kid in the alley's red polo with a pin on the chest, a cap on backwards, big ears and a
// can of shoe deodorant always in his right hand. The game scales him short.
export function buildPipo() {
	const b = new Builder('npc_pipo');
	const polo = mat('pipo_polo', 0xd23a3a), cap = mat('pipo_cap', 0x3a6ad2), skin = mat('skin_crema', 0xf3d2b0);
	pearBody(b, skin, { shirt: polo, pants: mat('pipo_jeans', 0x3a5a9a), shoes: mat('pipo_shoes', 0x46b45a), belted: false });
	b.add('logo', mat('pin_white', 0xf6f4ee), new THREE.CylinderGeometry(0.03, 0.045, 0.14, 8), { pos: V(0.16, 0.86, 0.36), rot: [-0.35, 0, 0] });
	eyes(b, 1.34, 0.17, 0.08, 0.055);
	b.add('face', mat('mouth', 0x7a2a2a), ellipsoid(0.07, 0.03, 0.02, 6, 4), { pos: V(0, 1.22, 0.2) });
	for (const s of [-1, 1]) b.add('ears', skin, ellipsoid(0.03, 0.07, 0.05, 6, 4), { pos: V(s * 0.24, 1.32, 0) });
	b.add('cap', cap, ellipsoid(0.21, 0.11, 0.2, 10, 5), { pos: V(0, 1.45, 0.0) });
	b.add('cap', cap, new THREE.BoxGeometry(0.2, 0.02, 0.16), { pos: V(0, 1.42, -0.24), rot: [0.25, 0, 0] });
	b.add('spray', mat('spray_can', 0x46b45a, { metalness: 0.4 }), new THREE.CylinderGeometry(0.035, 0.035, 0.18, 8), { pos: V(0.5, 0.72, 0.14) });
	b.add('spray', M.white, new THREE.CylinderGeometry(0.02, 0.025, 0.04, 6), { pos: V(0.5, 0.83, 0.14) });
	return b.build();
}

// The magnet ball's story: the golden ball with a horseshoe magnet showing through a crack, the remote that knocks the
// pins down by itself (a red button and an antenna), the list of bets on Don Chuza's team and the alley's metal bin.
export function buildMagnetBall() {
	const b = new Builder('bowl_magnet_ball');
	b.add('ball', mat('ball_gold', 0xe8b830, { metalness: 0.7, roughness: 0.25 }), new THREE.IcosahedronGeometry(0.12, 2), { pos: V(0, 0.12, 0) });
	const red = mat('magnet_red', 0xd83a30), steel = mat('magnet_steel', 0xc8ccd4, { metalness: 0.6 });
	b.add('magnet', red, new THREE.TorusGeometry(0.04, 0.014, 6, 10, Math.PI), { pos: V(0, 0.2, 0.09), rot: [0, 0, Math.PI] });
	for (const s of [-1, 1]) b.add('magnet', steel, new THREE.BoxGeometry(0.028, 0.02, 0.028), { pos: V(s * 0.04, 0.2, 0.09) });
	const hole = mat('ball_hole', 0x101010);
	for (const [x, z] of [[-0.025, -0.02], [0.025, -0.02], [0, 0.035]]) b.add('hole', hole, new THREE.CylinderGeometry(0.012, 0.012, 0.01, 8), { pos: V(x, 0.238, z) });
	return b.build();
}

export function buildPinRemote() {
	const b = new Builder('bowl_pin_remote');
	b.add('body', mat('remote_black', 0x24242a), new THREE.BoxGeometry(0.07, 0.03, 0.16), { pos: V(0, 0.015, 0) });
	b.add('button', mat('remote_red', 0xd83a30), new THREE.CylinderGeometry(0.02, 0.02, 0.012, 10), { pos: V(0, 0.036, 0.03) });
	b.add('antenna', mat('remote_steel', 0xc8ccd4, { metalness: 0.6 }), new THREE.CylinderGeometry(0.004, 0.004, 0.14, 5), { pos: V(0.025, 0.08, -0.07) });
	b.add('pin', mat('pin_white', 0xf6f4ee), new THREE.BoxGeometry(0.02, 0.006, 0.04), { pos: V(0, 0.033, -0.04) });
	return b.build();
}

export function buildBetList() {
	const b = new Builder('bowl_bet_list');
	b.add('paper', mat('bet_paper', 0xf6f2e2), new THREE.BoxGeometry(0.21, 0.006, 0.28), { pos: V(0, 0.003, 0) });
	for (let i = 0; i < 6; i++) b.add('lines', mat('bet_ink', 0x2a2a40), new THREE.BoxGeometry(0.15 - (i % 2) * 0.04, 0.002, 0.008), { pos: V(-0.01, 0.007, -0.1 + i * 0.04) });
	b.add('stamp', mat('bet_stamp', 0xd83a30), new THREE.BoxGeometry(0.05, 0.002, 0.05), { pos: V(0.06, 0.007, 0.1), rot: [0, 0.3, 0] });
	return b.build();
}

export function buildMetalBin() {
	const b = new Builder('metal_bin');
	const steel = mat('bin_steel', 0xa8acb4, { metalness: 0.7, roughness: 0.35 });
	b.add('bin', steel, new THREE.CylinderGeometry(0.2, 0.17, 0.6, 12, 1, true), { pos: V(0, 0.3, 0) });
	b.add('bin', mat('bin_dark', 0x2a2a30), new THREE.CylinderGeometry(0.17, 0.17, 0.02, 12), { pos: V(0, 0.01, 0) });
	b.add('rim', steel, new THREE.TorusGeometry(0.2, 0.015, 4, 14), { pos: V(0, 0.6, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The lead pins' story: the mold that casts pins out of lead (two halves held by clamps, a funnel on top and a lead pin
// half out of it), a lead pin (the same pin, dull grey with blue stripes) and the lead works' invoice.
export function buildLeadMold() {
	const b = new Builder('bowl_lead_mold');
	const iron = mat('mold_iron', 0x6a6e78, { metalness: 0.2, roughness: 0.6 }), clamp = mat('mold_clamp', 0xd83a30);
	for (const s of [-1, 1]) b.add('half', iron, new THREE.BoxGeometry(0.24, 0.5, 0.36), { pos: V(s * 0.125, 0.25, 0) });
	for (const y of [0.12, 0.38]) b.add('clamp', clamp, new THREE.BoxGeometry(0.56, 0.05, 0.06), { pos: V(0, y, 0.19) });
	b.add('funnel', iron, new THREE.CylinderGeometry(0.1, 0.03, 0.12, 10, 1, true), { pos: V(0, 0.56, 0) });
	b.add('drip', mat('lead_grey', 0x8a8e96, { metalness: 0.5 }), new THREE.BoxGeometry(0.02, 0.2, 0.02), { pos: V(0.25, 0.4, 0.19) });
	return b.build();
}

export function buildLeadPin() {
	const b = new Builder('bowl_lead_pin');
	pinParts(b, 1, mat('lead_grey', 0x8a8e96, { metalness: 0.5 }), mat('lead_stripe', 0x3a6ad2));
	return b.build();
}

export function buildLeadInvoice() {
	const b = new Builder('bowl_lead_invoice');
	b.add('paper', mat('invoice_paper', 0xf2eedc), new THREE.BoxGeometry(0.21, 0.006, 0.28), { pos: V(0, 0.003, 0) });
	b.add('logo', mat('lead_grey', 0x8a8e96, { metalness: 0.5 }), new THREE.BoxGeometry(0.06, 0.003, 0.04), { pos: V(-0.06, 0.007, -0.1) });
	for (let i = 0; i < 4; i++) b.add('lines', mat('bet_ink', 0x2a2a40), new THREE.BoxGeometry(0.14, 0.002, 0.008), { pos: V(0, 0.007, -0.03 + i * 0.04) });
	b.add('total', mat('invoice_total', 0xd83a30), new THREE.BoxGeometry(0.07, 0.002, 0.014), { pos: V(0.05, 0.007, 0.12) });
	return b.build();
}

// The shoes on wheels: a shoe box with a red-and-blue bowling shoe sticking out, tiny wheels under its sole, a skate
// taken apart (the plate, four wheels and a wrench) and the booklet "Cómo patinar sin que se note".
function wheels(b, y, z, gap, r = 0.025) {
	const wheel = mat('skate_wheel', 0xf2c230);
	for (const x of [-gap, gap]) for (const dz of [-0.06, 0.06]) b.add('wheels', wheel, new THREE.CylinderGeometry(r, r, 0.02, 10), { pos: V(x, y, z + dz), rot: [0, 0, Math.PI / 2] });
}
export function buildSkateBox() {
	const b = new Builder('bowl_skate_box');
	const card = mat('shoe_box', 0xe8e0c8), lid = mat('shoe_box_lid', 0xd83a30);
	b.add('box', card, new THREE.BoxGeometry(0.36, 0.14, 0.24), { pos: V(0, 0.07, 0) });
	b.add('lid', lid, new THREE.BoxGeometry(0.37, 0.03, 0.25), { pos: V(0.02, 0.17, -0.02), rot: [0.25, 0, 0] });
	b.add('shoe', mat('shoe_red', 0xd83a30), new THREE.BoxGeometry(0.12, 0.07, 0.26), { pos: V(-0.06, 0.19, 0.05), rot: [0.3, 0.3, 0] });
	b.add('shoe', mat('shoe_blue', 0x3a6ad2), new THREE.BoxGeometry(0.12, 0.04, 0.12), { pos: V(-0.06, 0.24, 0.1), rot: [0.3, 0.3, 0] });
	wheels(b, 0.17, 0.12, 0.05, 0.02);
	return b.build();
}

export function buildSkateParts() {
	const b = new Builder('bowl_skate_parts');
	b.add('plate', mat('skate_plate', 0x9aa0aa, { metalness: 0.4 }), new THREE.BoxGeometry(0.1, 0.02, 0.26), { pos: V(0, 0.05, 0) });
	wheels(b, 0.025, 0, 0.06);
	b.add('wrench', mat('wrench', 0x6a6e78, { metalness: 0.5 }), new THREE.BoxGeometry(0.2, 0.012, 0.03), { pos: V(0.16, 0.006, 0.05), rot: [0, 0.6, 0] });
	return b.build();
}

export function buildSkateManual() {
	const b = new Builder('bowl_skate_manual');
	b.add('cover', mat('manual_cover', 0x46b45a), new THREE.BoxGeometry(0.15, 0.015, 0.21), { pos: V(0, 0.008, 0) });
	b.add('title', mat('manual_title', 0xf6f4ee), new THREE.BoxGeometry(0.11, 0.002, 0.03), { pos: V(0, 0.017, -0.06) });
	wheels(b, 0.02, 0.04, 0.03, 0.012);
	return b.build();
}

// The fixed tournament: this year's cup with the winner already engraved on its plate, the fake score sheet (a grid
// of cells, all of them crossed out and written over) and a fat envelope for the judge.
export function buildRiggedCup() {
	const b = new Builder('bowl_rigged_cup');
	const gold = mat('trophy_gold', 0xf0c040, { metalness: 0.7, roughness: 0.3 });
	b.add('base', mat('cup_base', 0x2a2a30), new THREE.BoxGeometry(0.2, 0.08, 0.2), { pos: V(0, 0.04, 0) });
	b.add('plate', mat('cup_plate', 0xd8dce4, { metalness: 0.5 }), new THREE.BoxGeometry(0.14, 0.04, 0.005), { pos: V(0, 0.04, 0.102) });
	b.add('stem', gold, new THREE.CylinderGeometry(0.025, 0.04, 0.14, 8), { pos: V(0, 0.15, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.12, 0.05, 0.18, 10), { pos: V(0, 0.31, 0) });
	for (const x of [-0.13, 0.13]) b.add('handles', gold, new THREE.TorusGeometry(0.045, 0.012, 6, 10), { pos: V(x, 0.32, 0), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

export function buildFakeScores() {
	const b = new Builder('bowl_fake_scores');
	b.add('sheet', mat('paper', 0xf6f4ee), new THREE.BoxGeometry(0.21, 0.006, 0.3), { pos: V(0, 0.003, 0) });
	const ink = mat('ink_red', 0xd83a30);
	for (let r = 0; r < 5; r++) b.add('rows', mat('ink_blue', 0x3a4a8a), new THREE.BoxGeometry(0.18, 0.002, 0.004), { pos: V(0, 0.007, -0.11 + r * 0.055) });
	for (let r = 0; r < 4; r++) b.add('crossed', ink, new THREE.BoxGeometry(0.05, 0.002, 0.006), { pos: V(0.05, 0.008, -0.08 + r * 0.055), rot: [0, 0.6, 0] });
	return b.build();
}

export function buildJudgeEnvelope() {
	const b = new Builder('bowl_judge_envelope');
	b.add('envelope', mat('envelope', 0xd8c08a), new THREE.BoxGeometry(0.22, 0.035, 0.12), { pos: V(0, 0.018, 0) });
	b.add('bills', mat('bills', 0x6aa85a), new THREE.BoxGeometry(0.16, 0.02, 0.08), { pos: V(0.05, 0.03, 0.01), rot: [0, 0.15, 0] });
	b.add('seal', mat('seal', 0xd83a30), new THREE.CylinderGeometry(0.015, 0.015, 0.004, 8), { pos: V(-0.06, 0.037, 0) });
	return b.build();
}

// The magic popcorn: a sack of "popcorn corn" that is really painted pebbles, the can of yellow paint, the receipt for
// "premium popcorn" and one of the pebbles the machine spits out, yellow on top and grey where the paint chipped.
export function buildPebbleSack() {
	const b = new Builder('bowl_pebble_sack');
	const sack = mat('sack', 0xc8a870);
	b.add('sack', sack, new THREE.CylinderGeometry(0.17, 0.2, 0.42, 8), { pos: V(0, 0.21, 0) });
	b.add('tie', sack, new THREE.CylinderGeometry(0.06, 0.15, 0.08, 8), { pos: V(0, 0.46, 0) });
	b.add('label', mat('sack_label', 0xd83a30), new THREE.BoxGeometry(0.2, 0.12, 0.01), { pos: V(0, 0.24, 0.19) });
	for (const [x, z] of [[0.08, 0.2], [-0.12, 0.17], [0.2, 0.05]]) b.add('pebbles', mat('popcorn_yellow', 0xf6e08a), new THREE.IcosahedronGeometry(0.025, 0), { pos: V(x, 0.02, z) });
	return b.build();
}

export function buildPaintCan() {
	const b = new Builder('bowl_paint_can');
	b.add('can', mat('can_metal', 0xb8bcc4, { metalness: 0.5 }), new THREE.CylinderGeometry(0.1, 0.1, 0.2, 12), { pos: V(0, 0.1, 0) });
	b.add('paint', mat('paint_yellow', 0xf2d23a), new THREE.CylinderGeometry(0.101, 0.101, 0.1, 12), { pos: V(0, 0.09, 0) });
	b.add('drip', mat('paint_yellow', 0xf2d23a), new THREE.BoxGeometry(0.03, 0.06, 0.01), { pos: V(0.04, 0.17, 0.1) });
	b.add('handle', mat('can_metal', 0xb8bcc4, { metalness: 0.5 }), new THREE.TorusGeometry(0.1, 0.006, 4, 12, Math.PI), { pos: V(0, 0.2, 0) });
	return b.build();
}

export function buildPopcornReceipt() {
	const b = new Builder('bowl_popcorn_receipt');
	b.add('paper', mat('paper', 0xf6f4ee), new THREE.BoxGeometry(0.08, 0.004, 0.2), { pos: V(0, 0.002, 0) });
	for (let r = 0; r < 6; r++) b.add('lines', mat('ink_blue', 0x3a4a8a), new THREE.BoxGeometry(0.06, 0.001, 0.004), { pos: V(0, 0.005, -0.08 + r * 0.025) });
	b.add('logo', mat('popcorn_yellow', 0xf6e08a), new THREE.CylinderGeometry(0.015, 0.015, 0.001, 8), { pos: V(0, 0.005, 0.08) });
	return b.build();
}

export function buildPopcornPebble() {
	const b = new Builder('popcorn_pebble');
	b.add('pebble', mat('popcorn_yellow', 0xf6e08a), new THREE.IcosahedronGeometry(0.03, 0), { pos: V(0, 0.03, 0) });
	b.add('chip', mat('pebble_grey', 0x8a8e94), new THREE.IcosahedronGeometry(0.018, 0), { pos: V(0.015, 0.02, 0.012) });
	return b.build();
}

export const models = {
	bowl_pebble_sack: buildPebbleSack, bowl_paint_can: buildPaintCan, bowl_popcorn_receipt: buildPopcornReceipt, popcorn_pebble: buildPopcornPebble,
	bowl_rigged_cup: buildRiggedCup, bowl_fake_scores: buildFakeScores, bowl_judge_envelope: buildJudgeEnvelope,
	bowl_skate_box: buildSkateBox, bowl_skate_parts: buildSkateParts, bowl_skate_manual: buildSkateManual,
	bowl_lead_mold: buildLeadMold, bowl_lead_pin: buildLeadPin, bowl_lead_invoice: buildLeadInvoice,
	bowl_magnet_ball: buildMagnetBall, bowl_pin_remote: buildPinRemote, bowl_bet_list: buildBetList, metal_bin: buildMetalBin,
	npc_pipo: buildPipo,
	npc_don_chuza: buildDonChuza,
	npc_bowler: bowler('npc_bowler', 0xe0b48a, 0x7a3ab0, false), npc_bowler_b: bowler('npc_bowler_b', 0x9a6440, 0x3a3ab0, true),
	bowling_ball_1: coloredBall(1), bowling_ball_2: coloredBall(2), bowling_ball_3: coloredBall(3),
	bowling_ball_4: coloredBall(4), bowling_ball_5: coloredBall(5),
	bowling_pin: buildBowlingPin, bowling_ball: buildBowlingBall, pin_setter: buildPinSetter, ball_return: buildBallReturn,
	score_screen: buildScoreScreen, shoe_counter: buildShoeCounter, bowling_bar: buildBowlingBar,
	popcorn_machine: buildPopcornMachine, trophy_case: buildTrophyCase, bowling_bench: buildBowlingBench,
	giant_pin: buildGiantPin,
};

export const views = {
	bowling: {
		items: [
			{ name: 'pin_setter', pos: [-2.4, 0, -1.0] }, { name: 'bowling_pin', pos: [-2.4, 0, -0.2] },
			{ name: 'bowling_pin', pos: [-2.55, 0, -0.45] }, { name: 'bowling_pin', pos: [-2.25, 0, -0.45] },
			{ name: 'bowling_ball', pos: [-1.6, 0, 0.6] }, { name: 'ball_return', pos: [-0.8, 0, 0.8] },
			{ name: 'score_screen', pos: [-0.8, 2.2, -1.2] }, { name: 'shoe_counter', pos: [1.6, 0, 1.0] },
			{ name: 'bowling_bar', pos: [1.6, 0, -1.6] }, { name: 'popcorn_machine', pos: [3.4, 0, -1.4] },
			{ name: 'trophy_case', pos: [4.2, 0, 0.6], rotY: -Math.PI / 2 }, { name: 'bowling_bench', pos: [-1.4, 0, 2.2] },
			{ name: 'giant_pin', pos: [5.6, 0, -1.6] },
		],
		cam: { pos: [0.6, 4.0, 9.0], target: [0.6, 0.9, 0], fov: 50 },
	},
	bowl_magnet: {
		items: [{ name: 'bowl_magnet_ball', pos: [-0.5, 0, 0] }, { name: 'bowl_pin_remote', pos: [-0.1, 0, 0.1] }, { name: 'bowl_bet_list', pos: [0.3, 0, 0.1], rotY: 0.3 }, { name: 'metal_bin', pos: [0.9, 0, -0.1] }],
		cam: { pos: [0.2, 0.9, 1.9], target: [0.2, 0.2, 0], fov: 40 },
	},
	bowl_lead_pins: {
		items: [{ name: 'bowl_lead_mold', pos: [-0.5, 0, 0] }, { name: 'bowl_lead_pin', pos: [0.15, 0, 0.1] }, { name: 'bowling_pin', pos: [0.35, 0, 0.1] }, { name: 'bowl_lead_invoice', pos: [0.7, 0, 0.1], rotY: 0.3 }],
		cam: { pos: [0.1, 0.9, 1.9], target: [0.1, 0.2, 0], fov: 40 },
	},
	bowl_popcorn: {
		items: [{ name: 'bowl_pebble_sack', pos: [-0.35, 0, 0] }, { name: 'bowl_paint_can', pos: [0.1, 0, 0.05] }, { name: 'bowl_popcorn_receipt', pos: [0.4, 0, 0.15], rotY: 0.4 }, { name: 'popcorn_pebble', pos: [0.15, 0, 0.3] }],
		cam: { pos: [0.05, 0.7, 1.4], target: [0.05, 0.15, 0], fov: 40 },
	},
	bowl_tournament: {
		items: [{ name: 'bowl_rigged_cup', pos: [-0.3, 0, 0] }, { name: 'bowl_fake_scores', pos: [0.1, 0, 0.1], rotY: 0.2 }, { name: 'bowl_judge_envelope', pos: [0.45, 0, 0.1], rotY: -0.3 }],
		cam: { pos: [0.05, 0.7, 1.4], target: [0.05, 0.15, 0], fov: 40 },
	},
	bowl_skates: {
		items: [{ name: 'bowl_skate_box', pos: [-0.4, 0, 0] }, { name: 'bowl_skate_parts', pos: [0.1, 0, 0.1] }, { name: 'bowl_skate_manual', pos: [0.5, 0, 0.1], rotY: 0.3 }],
		cam: { pos: [0.05, 0.8, 1.4], target: [0.05, 0.1, 0], fov: 40 },
	},
	bowlers: {
		items: [{ name: 'npc_bowler', pos: [-1.0, 0, 0], rotY: 0.4 }, { name: 'npc_don_chuza', pos: [0, 0, 0.2], rotY: 0.2, scale: 0.85 }, { name: 'npc_bowler_b', pos: [1.0, 0, 0], rotY: Math.PI - 0.5 }, { name: 'npc_pipo', pos: [1.9, 0, 0.3], rotY: -0.3, scale: 0.75 }],
		cam: { pos: [0.4, 1.3, 5.0], target: [0.4, 0.8, 0], fov: 38 },
	},
};
