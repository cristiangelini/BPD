// Props of the fun fair "La Vuelta Loca" (docs/diseno/allanamiento-parque.md): the carousel and its horses, the
// Ferris wheel (stand, wheel and cabins apart, so the wheel can turn), the bumper car, the entrance arch, the strength
// tester and its mallet, the cotton candy cart, the cans booth, the ticket booth, the ghost train's face, its cart, a
// skeleton and the giant teddy bear. Origins at the floor in the middle of each piece, facing +Z. Placeholder, not
// final art.
import { Builder, mat, V, THREE } from '../lib.js';

const RED = 0xd23a3a, WHITE = 0xf4f0e6, GOLD = 0xe2b84a, BLUE = 0x3a6ad2, PINK = 0xf29ac2, DARK = 0x26262a;
const BULB = { emissive: 0xffe08a, emissiveIntensity: 1.5 };

const box = (b, part, m, w, h, d, x, y, z, rot) => b.add(part, m, new THREE.BoxGeometry(w, h, d), { pos: V(x, y, z), rot });
const bulbs = (b, m, points) => points.forEach((p) => b.add('bulbs', m, new THREE.SphereGeometry(0.06, 6, 4), { pos: p }));

// The carousel without its horses, 11 m across: a round deck 0.4 m up with a step, the middle drum with mirrors, the
// striped roof on twelve gold poles at 4.2 m and bulbs round its edge.
export function buildCarousel() {
	const b = new Builder('fair_carousel');
	const red = mat('fair_red', RED), white = mat('fair_white', WHITE), gold = mat('fair_gold', GOLD);
	const bulb = mat('fair_bulb', 0xfff2c0, BULB);
	b.add('deck', mat('fair_deck', 0x8a5a34), new THREE.CylinderGeometry(5.5, 5.5, 0.3, 24), { pos: V(0, 0.25, 0) });
	b.add('deck', gold, new THREE.CylinderGeometry(5.6, 5.6, 0.1, 24), { pos: V(0, 0.05, 0) });
	b.add('drum', red, new THREE.CylinderGeometry(1.4, 1.4, 3.8, 12), { pos: V(0, 2.3, 0) });
	for (let i = 0; i < 12; i++) {
		const a = (i / 12) * Math.PI * 2;
		b.add('drum', mat('fair_mirror', 0xc8d4e0, { metalness: 0.6, roughness: 0.2 }), new THREE.BoxGeometry(0.5, 1.2, 0.02),
			{ pos: V(Math.sin(a) * 1.41, 2.2, Math.cos(a) * 1.41), rot: [0, a, 0] });
		b.add('poles', gold, new THREE.CylinderGeometry(0.06, 0.06, 3.8, 6), { pos: V(Math.sin(a) * 5.3, 2.3, Math.cos(a) * 5.3) });
	}
	for (let i = 0; i < 16; i++) {
		b.add('roof', i % 2 ? white : red, new THREE.CylinderGeometry(0.3, 6.0, 1.6, 16, 1, false, (i / 16) * Math.PI * 2, Math.PI / 8), { pos: V(0, 5.0, 0) });
		const a = ((i + 0.5) / 16) * Math.PI * 2;
		box(b, 'roof', i % 2 ? red : white, 2.3, 0.5, 0.05, Math.sin(a) * 5.95, 4.0, Math.cos(a) * 5.95, [0, a, 0]);
	}
	b.add('roof', gold, new THREE.SphereGeometry(0.35, 8, 6), { pos: V(0, 5.9, 0) });
	bulbs(b, bulb, [...Array(32).keys()].map((i) => V(Math.sin((i / 32) * Math.PI * 2) * 6.0, 4.25, Math.cos((i / 32) * Math.PI * 2) * 6.0)));
	return b.build();
}

// One of the carousel's horses, 1.1 m long, on its gold pole up to the roof (2.0 m up from its feet); faces +Z.
export function buildFairHorse() {
	const b = new Builder('fair_horse');
	const white = mat('fair_white', WHITE), gold = mat('fair_gold', GOLD), red = mat('fair_red', RED), mane = mat('horse_mane', 0x7a4a2a);
	b.add('pole', gold, new THREE.CylinderGeometry(0.035, 0.035, 3.4, 8), { pos: V(0, 1.7, 0.1) });
	box(b, 'body', white, 0.36, 0.36, 0.9, 0, 0.95, 0);
	for (const [x, z, r] of [[-0.11, 0.36, -0.9], [0.11, 0.36, -0.6], [-0.11, -0.36, 0.9], [0.11, -0.36, 0.6]]) {
		box(b, 'legs', white, 0.08, 0.4, 0.08, x, 0.75, z + Math.sign(z) * 0.08, [r, 0, 0]);
		box(b, 'legs', gold, 0.09, 0.06, 0.09, x, 0.58, z + Math.sign(z) * 0.24, [r, 0, 0]);
	}
	box(b, 'saddle', red, 0.4, 0.06, 0.38, 0, 1.15, -0.05);
	box(b, 'saddle', gold, 0.42, 0.02, 0.4, 0, 1.12, -0.05);
	box(b, 'neck', white, 0.26, 0.5, 0.26, 0, 1.28, 0.42, [0.35, 0, 0]);
	box(b, 'head', white, 0.24, 0.24, 0.42, 0, 1.52, 0.6, [0.3, 0, 0]);
	box(b, 'mane', mane, 0.08, 0.55, 0.12, 0, 1.4, 0.32, [0.35, 0, 0]);
	box(b, 'tail', mane, 0.06, 0.4, 0.06, 0, 0.88, -0.52, [-0.4, 0, 0]);
	return b.build();
}

// The Ferris wheel's stand: two A-frames 1.8 m apart (along Z) holding the axle at 6.6 m, on a platform with steps.
export function buildFerrisStand() {
	const b = new Builder('ferris_stand');
	const blue = mat('ferris_blue', BLUE), white = mat('fair_white', WHITE);
	box(b, 'platform', mat('fair_deck', 0x8a5a34), 4.0, 0.3, 3.2, 0, 0.15, 0);
	for (const z of [-0.9, 0.9]) {
		for (const s of [-1, 1]) {
			const leg = new THREE.Vector3(s * 3.0, -6.6, 0);
			b.add('legs', blue, new THREE.CylinderGeometry(0.12, 0.16, leg.length(), 8), { pos: V(s * 1.5, 3.3, z), lookAt: leg.clone().negate() });
		}
		box(b, 'legs', white, 3.0, 0.12, 0.12, 0, 2.2, z);
	}
	b.add('axle', mat('fair_steel', 0x8a8e94), new THREE.CylinderGeometry(0.2, 0.2, 2.2, 10), { pos: V(0, 6.6, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('box', mat('fair_red', RED), new THREE.BoxGeometry(0.6, 1.0, 0.5), { pos: V(2.4, 0.8, 1.2) });
	return b.build();
}

// The wheel itself, 9.6 m across, origin at its hub: two rims 1.4 m apart joined at the eight cabins' hooks, the
// spokes and a bulb on every spoke's end.
export function buildFerrisWheel() {
	const b = new Builder('ferris_wheel');
	const white = mat('fair_white', WHITE), blue = mat('ferris_blue', BLUE), bulb = mat('fair_bulb', 0xfff2c0, BULB);
	for (const z of [-0.7, 0.7]) {
		b.add('rim', white, new THREE.TorusGeometry(4.8, 0.08, 6, 32), { pos: V(0, 0, z) });
		b.add('rim', blue, new THREE.TorusGeometry(2.4, 0.06, 6, 24), { pos: V(0, 0, z) });
		for (let i = 0; i < 16; i++) {
			const a = (i / 16) * Math.PI * 2;
			b.add('spokes', white, new THREE.CylinderGeometry(0.04, 0.04, 4.8, 5), { pos: V(Math.sin(a) * 2.4, Math.cos(a) * 2.4, z), rot: [0, 0, -a] });
			bulbs(b, bulb, [V(Math.sin(a) * 4.8, Math.cos(a) * 4.8, z + Math.sign(z) * 0.1)]);
		}
	}
	for (let i = 0; i < 8; i++) {
		const a = (i / 8) * Math.PI * 2;
		b.add('hooks', blue, new THREE.CylinderGeometry(0.06, 0.06, 1.6, 6), { pos: V(Math.sin(a) * 4.8, Math.cos(a) * 4.8, 0), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('hub', blue, new THREE.CylinderGeometry(0.5, 0.5, 1.6, 12), { rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// A cabin of the wheel, hanging from its hook at the origin: a little open gondola 1.2 m wide with two benches, its
// floor 1.5 m below the hook, and a roof.
export function buildFerrisCabin() {
	const b = new Builder('ferris_cabin');
	const red = mat('fair_red', RED), white = mat('fair_white', WHITE), gold = mat('fair_gold', GOLD);
	b.add('arm', gold, new THREE.CylinderGeometry(0.04, 0.04, 0.5, 6), { pos: V(0, -0.25, 0) });
	b.add('roof', white, new THREE.CylinderGeometry(0.2, 0.8, 0.3, 8), { pos: V(0, -0.6, 0) });
	for (const s of [-1, 1]) for (const z of [-1, 1]) box(b, 'posts', gold, 0.04, 0.8, 0.04, s * 0.55, -1.1, z * 0.45);
	box(b, 'floor', red, 1.2, 0.08, 1.0, 0, -1.5, 0);
	for (const s of [-1, 1]) box(b, 'sides', red, 0.05, 0.45, 1.0, s * 0.6, -1.28, 0);
	for (const z of [-1, 1]) box(b, 'sides', red, 1.2, 0.45, 0.05, 0, -1.28, z * 0.5);
	for (const z of [-1, 1]) box(b, 'benches', white, 1.0, 0.08, 0.3, 0, -1.25, z * 0.3);
	return b.build();
}

// A bumper car, 1.2 × 1.8 m, faces +Z: a round red body in a black rubber ring, a seat and wheel, and the pole that
// touches the net, with its spark.
export function buildBumperCar() {
	const b = new Builder('bumper_car');
	const black = mat('bumper_rubber', 0x1c1c1e);
	b.add('ring', black, new THREE.CylinderGeometry(0.66, 0.66, 0.22, 16), { pos: V(0, 0.18, 0), scale: [1, 1, 1.45] });
	b.add('body', mat('bumper_body', RED), new THREE.CylinderGeometry(0.58, 0.62, 0.35, 16), { pos: V(0, 0.42, 0), scale: [1, 1, 1.45] });
	box(b, 'seat', mat('bumper_seat', DARK), 0.6, 0.45, 0.2, 0, 0.75, -0.4);
	box(b, 'seat', mat('bumper_seat', DARK), 0.6, 0.12, 0.5, 0, 0.62, -0.15);
	b.add('wheel', mat('fair_steel', 0x8a8e94), new THREE.TorusGeometry(0.16, 0.025, 4, 12), { pos: V(0, 0.85, 0.35), rot: [-0.9, 0, 0] });
	b.add('pole', mat('fair_steel', 0x8a8e94), new THREE.CylinderGeometry(0.025, 0.025, 1.6, 6), { pos: V(0, 1.4, -0.65) });
	b.add('spark', mat('fair_spark', 0xfff2a0, BULB), new THREE.SphereGeometry(0.06, 6, 4), { pos: V(0, 2.2, -0.65) });
	return b.build();
}

// The entrance arch, 9 m wide and 6.4 m tall: two striped towers with balls on top, the curved beam where the sign
// goes (in the game, a Label3D) and bulbs along it.
export function buildFairArch() {
	const b = new Builder('fair_arch');
	const red = mat('fair_red', RED), white = mat('fair_white', WHITE), gold = mat('fair_gold', GOLD);
	const bulb = mat('fair_bulb', 0xfff2c0, BULB);
	for (const s of [-1, 1]) {
		for (let i = 0; i < 6; i++) box(b, 'towers', i % 2 ? white : red, 0.8, 0.9, 0.8, s * 4.5, 0.45 + i * 0.9, 0);
		b.add('towers', gold, new THREE.SphereGeometry(0.5, 10, 8), { pos: V(s * 4.5, 5.9, 0) });
	}
	for (let i = 0; i < 9; i++) {
		const x = -4.0 + i;
		box(b, 'beam', i % 2 ? red : white, 1.0, 1.2, 0.3, x, 5.0 + Math.sin(((i + 0.5) / 9) * Math.PI) * 0.6, 0);
	}
	bulbs(b, bulb, [...Array(17).keys()].map((i) => V(-4.0 + i * 0.5, 4.3 + Math.sin((i / 16) * Math.PI) * 0.6, 0.18)));
	return b.build();
}

// The strength tester, 4.4 m tall: the pad you hit on a base, the tall board with its painted scale and the rail
// where the puck runs up, and the bell on top.
export function buildStrengthTester() {
	const b = new Builder('strength_tester');
	const red = mat('fair_red', RED), white = mat('fair_white', WHITE), gold = mat('fair_gold', GOLD);
	box(b, 'base', mat('fair_deck', 0x8a5a34), 1.2, 0.3, 0.9, 0, 0.15, 0);
	b.add('pad', mat('bumper_rubber', 0x1c1c1e), new THREE.CylinderGeometry(0.2, 0.22, 0.15, 12), { pos: V(0, 0.38, 0.15) });
	box(b, 'board', white, 0.7, 3.8, 0.1, 0, 2.2, -0.3);
	for (let i = 0; i < 8; i++) box(b, 'scale', i % 2 ? red : mat('fair_yellow', 0xf2c230), 0.6, 0.12, 0.02, 0, 0.7 + i * 0.45, -0.24);
	box(b, 'rail', mat('fair_steel', 0x8a8e94), 0.05, 3.8, 0.05, 0, 2.2, -0.2);
	b.add('puck', red, new THREE.CylinderGeometry(0.08, 0.08, 0.1, 10), { pos: V(0, 0.55, -0.2) });
	b.add('bell', gold, new THREE.SphereGeometry(0.25, 12, 8, 0, Math.PI * 2, 0, Math.PI / 2), { pos: V(0, 4.15, -0.2), rot: [Math.PI, 0, 0] });
	b.add('bell', gold, new THREE.CylinderGeometry(0.04, 0.04, 0.2, 6), { pos: V(0, 4.25, -0.2) });
	return b.build();
}

// The strength tester's wooden mallet, 1.1 m long, lying along +Z with its head at the far end.
export function buildFairMallet() {
	const b = new Builder('fair_mallet');
	b.add('handle', mat('mallet_wood', 0xc08a50), new THREE.CylinderGeometry(0.03, 0.035, 0.9, 8), { pos: V(0, 0.08, -0.1), rot: [Math.PI / 2, 0, 0] });
	b.add('head', mat('mallet_head', 0x8a5a34), new THREE.CylinderGeometry(0.1, 0.1, 0.32, 10), { pos: V(0, 0.1, 0.42), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// Nube's cotton candy cart, 1.6 m wide: a pink cart on two wheels with the steel bowl, a pink cloud on a stick
// and a striped umbrella.
export function buildCottonCandyCart() {
	const b = new Builder('cotton_candy_cart');
	const pink = mat('candy_pink', PINK), white = mat('fair_white', WHITE);
	box(b, 'cart', pink, 1.6, 0.9, 0.8, 0, 0.6, 0);
	for (const s of [-1, 1]) b.add('wheels', mat('bumper_rubber', 0x1c1c1e), new THREE.CylinderGeometry(0.25, 0.25, 0.08, 12), { pos: V(s * 0.85, 0.25, 0), rot: [0, 0, Math.PI / 2] });
	b.add('bowl', mat('fair_steel', 0x8a8e94), new THREE.CylinderGeometry(0.35, 0.22, 0.25, 14), { pos: V(-0.3, 1.18, 0) });
	b.add('cloud', mat('candy_cloud', 0xffc2dc), new THREE.SphereGeometry(0.22, 10, 8), { pos: V(-0.3, 1.45, 0), scale: [1, 0.8, 1] });
	b.add('pole', white, new THREE.CylinderGeometry(0.03, 0.03, 1.4, 6), { pos: V(0.6, 1.75, 0) });
	for (let i = 0; i < 8; i++) {
		b.add('umbrella', i % 2 ? white : pink, new THREE.CylinderGeometry(0.02, 1.0, 0.35, 8, 1, false, (i / 8) * Math.PI * 2, Math.PI / 4), { pos: V(0.6, 2.55, 0) });
	}
	return b.build();
}

// The cans booth, 3 m wide and 2.8 m tall, open to +Z: the counter, the shelf at the back where the cans stand, the
// prize shelf over it and the striped awning.
export function buildCansBooth() {
	const b = new Builder('cans_booth');
	const red = mat('fair_red', RED), white = mat('fair_white', WHITE), wood = mat('fair_deck', 0x8a5a34);
	box(b, 'counter', red, 3.0, 1.0, 0.4, 0, 0.5, 0.8);
	box(b, 'counter', wood, 3.1, 0.06, 0.5, 0, 1.03, 0.8);
	box(b, 'back', white, 3.0, 2.6, 0.1, 0, 1.3, -1.0);
	for (const s of [-1, 1]) box(b, 'sides', red, 0.1, 2.6, 2.0, s * 1.5, 1.3, 0);
	box(b, 'shelf', wood, 2.6, 0.06, 0.4, 0, 1.0, -0.75);
	box(b, 'shelf', wood, 2.6, 0.06, 0.35, 0, 1.9, -0.78);
	for (let i = 0; i < 10; i++) box(b, 'awning', i % 2 ? white : red, 0.31, 0.06, 1.4, -1.4 + i * 0.31, 2.75, 0.6, [-0.25, 0, 0]);
	return b.build();
}

// The ticket booth, 1.8 × 1.8 m and 3 m tall: a blue kiosk with a little window and counter at the front, a door at
// the back and a pointed roof.
export function buildTicketBooth() {
	const b = new Builder('ticket_booth');
	const blue = mat('ferris_blue', BLUE), white = mat('fair_white', WHITE), gold = mat('fair_gold', GOLD);
	box(b, 'walls', blue, 1.8, 1.0, 1.8, 0, 0.5, 0);
	for (const [x, z] of [[-0.85, -0.85], [0.85, -0.85], [-0.85, 0.85], [0.85, 0.85]]) box(b, 'walls', blue, 0.1, 1.4, 0.1, x, 1.7, z);
	for (const z of [-1, 1]) for (const x of [-1, 1]) box(b, 'walls', blue, z > 0 ? 0.4 : 0.85, 1.4, 0.06, x * (z > 0 ? 0.7 : 0.45), 1.7, z * 0.88);
	for (const s of [-1, 1]) box(b, 'walls', blue, 0.06, 1.4, 1.8, s * 0.88, 1.7, 0);
	box(b, 'glass', mat('booth_glass', 0xbfe0f0, { transparent: true, opacity: 0.4 }), 1.0, 1.0, 0.02, 0, 1.75, 0.9);
	box(b, 'counter', white, 1.2, 0.05, 0.3, 0, 1.0, 1.0);
	box(b, 'top', white, 2.0, 0.2, 2.0, 0, 2.5, 0);
	b.add('top', blue, new THREE.ConeGeometry(1.4, 0.8, 4), { pos: V(0, 3.0, 0), rot: [0, Math.PI / 4, 0] });
	b.add('top', gold, new THREE.SphereGeometry(0.12, 8, 6), { pos: V(0, 3.45, 0) });
	return b.build();
}

// The ghost train's face over its doors, 8 m wide and 3 m tall, its back at z = 0: a big green skull with hollow eyes
// and a jagged grin, and two bats.
export function buildGhostTrainFace() {
	const b = new Builder('ghost_train_face');
	const green = mat('ghost_green', 0x7ac25a), dark = mat('ghost_dark', 0x1a1a22), purple = mat('ghost_purple', 0x5a2a7a);
	box(b, 'board', purple, 8.0, 3.0, 0.1, 0, 1.5, 0.05);
	b.add('skull', green, new THREE.SphereGeometry(1.3, 12, 10), { pos: V(0, 1.7, 0.1), scale: [1, 0.9, 0.3] });
	for (const s of [-1, 1]) b.add('eyes', dark, new THREE.SphereGeometry(0.3, 8, 6), { pos: V(s * 0.45, 1.9, 0.45), scale: [1, 1.2, 0.3] });
	for (let i = 0; i < 6; i++) box(b, 'teeth', mat('fair_white', WHITE), 0.18, 0.3, 0.06, -0.45 + i * 0.18, 1.0, 0.45, [0, 0, i % 2 ? 0.2 : -0.2]);
	for (const s of [-1, 1]) {
		box(b, 'bats', dark, 0.9, 0.08, 0.04, s * 3.0, 2.4, 0.15, [0, 0, s * 0.3]);
		b.add('bats', dark, new THREE.SphereGeometry(0.14, 6, 4), { pos: V(s * 3.0, 2.4, 0.18) });
	}
	return b.build();
}

// A ghost train's cart, 0.9 × 1.4 m, faces +Z: a black tub with a bench and a bat-winged front.
export function buildGhostCart() {
	const b = new Builder('ghost_cart');
	const dark = mat('ghost_dark', 0x1a1a22), purple = mat('ghost_purple', 0x5a2a7a);
	box(b, 'tub', dark, 0.9, 0.5, 1.4, 0, 0.4, 0);
	box(b, 'bench', purple, 0.8, 0.12, 0.4, 0, 0.7, -0.35);
	box(b, 'front', purple, 1.3, 0.5, 0.06, 0, 0.75, 0.68, [0.2, 0, 0]);
	for (const s of [-1, 1]) for (const z of [-0.5, 0.5]) b.add('wheels', mat('fair_steel', 0x8a8e94), new THREE.CylinderGeometry(0.12, 0.12, 0.06, 10), { pos: V(s * 0.46, 0.12, z), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// A ghost train skeleton, 1.8 m tall with its arms up, standing on a little spring.
export function buildFairSkeleton() {
	const b = new Builder('fair_skeleton');
	const bone = mat('fair_bone', 0xeeead8), dark = mat('ghost_dark', 0x1a1a22);
	b.add('spring', mat('fair_steel', 0x8a8e94), new THREE.CylinderGeometry(0.1, 0.1, 0.3, 8), { pos: V(0, 0.15, 0) });
	for (const s of [-1, 1]) box(b, 'legs', bone, 0.06, 0.8, 0.06, s * 0.1, 0.7, 0);
	box(b, 'hips', bone, 0.3, 0.08, 0.1, 0, 1.1, 0);
	box(b, 'spine', bone, 0.05, 0.45, 0.05, 0, 1.35, 0);
	for (let i = 0; i < 4; i++) box(b, 'ribs', bone, 0.34 - i * 0.03, 0.03, 0.14, 0, 1.3 + i * 0.07, 0.02);
	for (const s of [-1, 1]) box(b, 'arms', bone, 0.05, 0.6, 0.05, s * 0.28, 1.75, 0, [0, 0, s * 0.4]);
	b.add('skull', bone, new THREE.SphereGeometry(0.13, 10, 8), { pos: V(0, 1.72, 0) });
	for (const s of [-1, 1]) b.add('eyes', dark, new THREE.SphereGeometry(0.035, 6, 4), { pos: V(s * 0.05, 1.74, 0.11) });
	return b.build();
}

// The big prize: a brown teddy bear 1.2 m tall sitting down, with a red bow.
export function buildGiantTeddy() {
	const b = new Builder('giant_teddy');
	const fur = mat('teddy_fur', 0xa0703e), light = mat('teddy_light', 0xe0b888), dark = mat('ghost_dark', 0x1a1a22);
	b.add('body', fur, new THREE.SphereGeometry(0.4, 12, 10), { pos: V(0, 0.42, 0), scale: [1, 1.1, 0.9] });
	b.add('body', light, new THREE.SphereGeometry(0.26, 10, 8), { pos: V(0, 0.42, 0.22), scale: [1, 1.1, 0.5] });
	b.add('head', fur, new THREE.SphereGeometry(0.3, 12, 10), { pos: V(0, 0.98, 0) });
	b.add('head', light, new THREE.SphereGeometry(0.12, 8, 6), { pos: V(0, 0.92, 0.25) });
	b.add('eyes', dark, new THREE.SphereGeometry(0.035, 6, 4), { pos: V(0, 0.96, 0.36) });
	for (const s of [-1, 1]) {
		b.add('ears', fur, new THREE.SphereGeometry(0.1, 8, 6), { pos: V(s * 0.22, 1.22, 0) });
		b.add('eyes', dark, new THREE.SphereGeometry(0.03, 6, 4), { pos: V(s * 0.1, 1.06, 0.26) });
		b.add('arms', fur, new THREE.SphereGeometry(0.12, 8, 6), { pos: V(s * 0.42, 0.55, 0.1), scale: [1, 1.8, 1] });
		b.add('legs', fur, new THREE.SphereGeometry(0.15, 8, 6), { pos: V(s * 0.22, 0.14, 0.32), scale: [1, 0.9, 1.6] });
		b.add('bow', mat('fair_red', RED), new THREE.ConeGeometry(0.08, 0.16, 6), { pos: V(s * 0.09, 0.74, 0.2), rot: [0, 0, s * Math.PI / 2] });
	}
	return b.build();
}

export const models = {
	fair_carousel: buildCarousel, fair_horse: buildFairHorse, ferris_stand: buildFerrisStand, ferris_wheel: buildFerrisWheel,
	ferris_cabin: buildFerrisCabin, bumper_car: buildBumperCar, fair_arch: buildFairArch, strength_tester: buildStrengthTester,
	fair_mallet: buildFairMallet, cotton_candy_cart: buildCottonCandyCart, cans_booth: buildCansBooth,
	ticket_booth: buildTicketBooth, ghost_train_face: buildGhostTrainFace, ghost_cart: buildGhostCart,
	fair_skeleton: buildFairSkeleton, giant_teddy: buildGiantTeddy,
};

export const views = {
	fair_rides: {
		items: [
			{ name: 'fair_carousel', pos: [-7, 0, 0] }, { name: 'fair_horse', pos: [-7, 0.4, 4.3] }, { name: 'fair_horse', pos: [-4.5, 0.4, 3.0] },
			{ name: 'ferris_stand', pos: [6, 0, 0] }, { name: 'ferris_wheel', pos: [6, 6.6, 0] },
			...[0, 1, 2, 3, 4, 5, 6, 7].map((i) => ({ name: 'ferris_cabin', pos: [6 + Math.sin(i * Math.PI / 4) * 4.8, 6.6 + Math.cos(i * Math.PI / 4) * 4.8, 0] })),
			{ name: 'bumper_car', pos: [0, 0, 5] },
		],
		cam: { pos: [0, 7, 24], target: [0, 4, 0], fov: 50 },
	},
	fair_booths: {
		items: [
			{ name: 'fair_arch', pos: [0, 0, -4] }, { name: 'strength_tester', pos: [-4, 0, 1] }, { name: 'fair_mallet', pos: [-3.2, 0, 2] },
			{ name: 'cotton_candy_cart', pos: [-1.5, 0, 2] }, { name: 'cans_booth', pos: [1.5, 0, 1] }, { name: 'ticket_booth', pos: [4.5, 0, 1] },
			{ name: 'giant_teddy', pos: [1.5, 1.93, 0.25], scale: 0.4 },
		],
		cam: { pos: [0, 3.5, 13], target: [0, 2, 0], fov: 50 },
	},
	fair_ghost: {
		items: [
			{ name: 'ghost_train_face', pos: [0, 2.5, -1] }, { name: 'ghost_cart', pos: [-1.5, 0, 1] }, { name: 'fair_skeleton', pos: [1.5, 0, 0.5] },
			{ name: 'giant_teddy', pos: [3, 0, 1] },
		],
		cam: { pos: [0, 2.5, 9], target: [0, 2, 0], fov: 50 },
	},
};
