// Props of the ice rink "Patinódromo Resbalón" (docs/diseno/allanamiento-pista.md): the ice resurfacer, the big
// skating penguin the kids hold on to, the hot chocolate machine, the DJ booth and the scoreboard, with origins at the
// floor in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

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

export const models = {
	ice_resurfacer: buildIceResurfacer, skating_penguin: buildSkatingPenguin, cocoa_machine: buildCocoaMachine,
	dj_booth: buildDjBooth, rink_scoreboard: buildRinkScoreboard,
};

export const views = {
	rink: {
		items: [
			{ name: 'ice_resurfacer', pos: [-2.2, 0, 0], rotY: 0.6 }, { name: 'skating_penguin', pos: [-0.4, 0, 0.6] },
			{ name: 'cocoa_machine', pos: [0.6, 0, 0.8] }, { name: 'dj_booth', pos: [1.8, 0, 0], rotY: Math.PI },
			{ name: 'rink_scoreboard', pos: [0, 2.0, -1.5] },
		],
		cam: { pos: [0, 2.2, 6.5], target: [0, 1.0, 0], fov: 45 },
	},
};
