// Props of the bowling alley "Bolos Chuza Feliz" (docs/diseno/allanamiento-bolera.md): a pin, a ball, the pin machine
// over each lane's end, the ball return with its rack, a score screen, the shoe counter with its shelf, the bar, the
// popcorn machine, the trophy case, a bench and the giant pin of the sign, with origins at the floor in the middle of
// each piece, the two looks of the Thursday league's players and Don Chuza, the owner. Placeholder, not final art.
import { Builder, mat, ellipsoid, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const BALLS = [0x3a6ad2, 0xe8473a, 0x46b45a, 0xb05ad2, 0xf2c230, 0x202428];

// A pin 0.38 m tall: white, wide belly, thin neck, two red stripes.
function pinParts(b, scale = 1) {
	const white = mat('pin_white', 0xf6f4ee), red = mat('pin_red', 0xd83a30);
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

export const models = {
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
	bowlers: {
		items: [{ name: 'npc_bowler', pos: [-1.0, 0, 0], rotY: 0.4 }, { name: 'npc_don_chuza', pos: [0, 0, 0.2], rotY: 0.2, scale: 0.85 }, { name: 'npc_bowler_b', pos: [1.0, 0, 0], rotY: Math.PI - 0.5 }],
		cam: { pos: [0, 1.3, 4.2], target: [0, 0.8, 0], fov: 34 },
	},
};
