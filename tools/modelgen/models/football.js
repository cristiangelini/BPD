// The charity football match (docs/diseno/politico-futbol.md): the goals, the team benches, the stretcher and the cup.
// Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// A 7-a-side goal (step 1): 6 m wide (x), 2 m high, 1.5 m deep toward -Z, white posts and crossbar, a sagging net
// with a few strings showing and a patch sewn on. Its origin on the goal line, in the middle, on the ground.
export function buildGoal() {
	const b = new Builder('football_goal');
	const white = mat('goal_white', 0xf4f4f0), net = mat('goal_net', 0xdfe6ea, { transparent: true, opacity: 0.55 });
	const string = mat('goal_string', 0xc8d0d6), patch = mat('goal_patch', 0xd8343c);
	const W = 6, H = 2, D = 1.5, R = 0.06;
	for (const x of [-1, 1]) b.add('posts', white, new THREE.CylinderGeometry(R, R, H, 8), { pos: V(x * W / 2, H / 2, 0) });
	b.add('posts', white, new THREE.CylinderGeometry(R, R, W + R * 2, 8), { pos: V(0, H, 0), rot: [0, 0, Math.PI / 2] });
	for (const x of [-1, 1]) box(b, 'frame', white, 0.04, 0.04, D, x * W / 2, 0.02, -D / 2);
	box(b, 'frame', white, W, 0.04, 0.04, 0, 0.02, -D);
	box(b, 'net', net, W, 0.02, D, 0, H - 0.15, -D / 2, [-0.12, 0, 0]);
	box(b, 'net', net, W, H - 0.1, 0.02, 0, (H - 0.1) / 2, -D);
	for (const x of [-1, 1]) box(b, 'net', net, 0.02, H - 0.1, D, x * W / 2, (H - 0.1) / 2, -D / 2);
	for (let i = 1; i < 6; i++) box(b, 'strings', string, 0.015, H - 0.1, 0.015, -W / 2 + i, (H - 0.1) / 2, -D + 0.02);
	for (let i = 1; i < 3; i++) box(b, 'strings', string, W, 0.015, 0.015, 0, i * 0.65, -D + 0.02);
	box(b, 'patch', patch, 0.5, 0.4, 0.025, 1.4, 0.7, -D + 0.01, [0, 0, 0.2]);
	return b.build();
}

// A team's bench (step 1): a long wooden bench under a curved clear roof on a green frame, 4 m long (x), facing +Z.
// Its origin on the ground in the middle.
export function buildBench() {
	const b = new Builder('team_bench');
	const wood = mat('bench_wood', 0xb07a45), frame = mat('bench_frame', 0x2f7a3e), roof = mat('bench_roof', 0xbfe3f0, { transparent: true, opacity: 0.6 });
	box(b, 'seat', wood, 4.0, 0.06, 0.45, 0, 0.45, 0);
	box(b, 'seat', wood, 4.0, 0.4, 0.05, 0, 0.7, -0.22);
	for (const x of [-1.8, 0, 1.8]) box(b, 'seat', frame, 0.06, 0.45, 0.4, x, 0.22, 0);
	for (const x of [-2, 2]) {
		box(b, 'frame', frame, 0.08, 2.0, 0.08, x, 1.0, -0.5);
		box(b, 'frame', frame, 0.08, 0.08, 1.4, x, 2.0, 0.15);
		box(b, 'frame', frame, 0.06, 0.06, 1.2, x, 1.0, 0.0, [0, 0, 0]);
	}
	box(b, 'roof', roof, 4.1, 0.03, 1.5, 0, 2.05, 0.2, [-0.12, 0, 0]);
	box(b, 'roof', roof, 4.1, 1.5, 0.03, 0, 1.25, -0.52);
	return b.build();
}

// The stretcher (step 1, carried in step 4): green canvas between two poles with handles, 2.2 m long (z), on short legs.
// Its origin in the middle, on the ground.
export function buildStretcher() {
	const b = new Builder('stretcher');
	const canvas = mat('stretcher_canvas', 0x3f8a5a), pole = mat('stretcher_pole', 0xb8bcc2), grip = mat('stretcher_grip', 0x23252b);
	const cross = mat('stretcher_cross', 0xe23a3a), white = mat('goal_white', 0xf4f4f0);
	box(b, 'canvas', canvas, 0.6, 0.03, 1.8, 0, 0.25, 0);
	for (const x of [-1, 1]) {
		b.add('poles', pole, new THREE.CylinderGeometry(0.025, 0.025, 2.2, 6), { pos: V(x * 0.32, 0.27, 0), rot: [Math.PI / 2, 0, 0] });
		for (const z of [-1, 1]) {
			b.add('grips', grip, new THREE.CylinderGeometry(0.035, 0.035, 0.18, 6), { pos: V(x * 0.32, 0.27, z * 1.05), rot: [Math.PI / 2, 0, 0] });
			box(b, 'legs', pole, 0.03, 0.25, 0.03, x * 0.32, 0.125, z * 0.75);
		}
	}
	box(b, 'cross', white, 0.32, 0.005, 0.32, 0, 0.27, 0.55);
	box(b, 'cross', cross, 0.24, 0.006, 0.07, 0, 0.272, 0.55);
	box(b, 'cross', cross, 0.07, 0.006, 0.24, 0, 0.272, 0.55);
	return b.build();
}

// The charity cup (step 1): a big golden cup with two handles on a black base with a plate, about 70 cm tall. Its
// origin at the bottom.
export function buildCup() {
	const b = new Builder('football_cup');
	const gold = mat('cup_gold', 0xe8c040, { metalness: 0.4, roughness: 0.4 }), base = mat('cup_base', 0x23252b), plate = mat('cup_plate', 0xd8d8d0);
	box(b, 'base', base, 0.3, 0.12, 0.3, 0, 0.06, 0);
	box(b, 'base', plate, 0.16, 0.06, 0.005, 0, 0.06, 0.153);
	b.add('cup', gold, new THREE.CylinderGeometry(0.04, 0.1, 0.18, 10), { pos: V(0, 0.21, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.2, 0.06, 0.32, 12, 1, true), { pos: V(0, 0.46, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.06, 0.06, 0.01, 12), { pos: V(0, 0.31, 0) });
	for (const x of [-1, 1]) b.add('handles', gold, new THREE.TorusGeometry(0.08, 0.018, 6, 12), { pos: V(x * 0.22, 0.5, 0), rot: [0, 0, 0] });
	return b.build();
}

// The match ball (step 2): white with black patches, 22 cm across, a bit scuffed. Its origin in its middle.
export function buildBall() {
	const b = new Builder('football_ball');
	const white = mat('ball_white', 0xf6f6f2), black = mat('ball_black', 0x1e1f24), scuff = mat('ball_scuff', 0xc9c3b4);
	const R = 0.11;
	b.add('ball', white, new THREE.IcosahedronGeometry(R, 1), { pos: V(0, 0, 0) });
	const ico = new THREE.IcosahedronGeometry(1, 0).attributes.position;
	const seen = [];
	for (let i = 0; i < ico.count; i++) {
		const v = new THREE.Vector3().fromBufferAttribute(ico, i).normalize();
		if (seen.some((s) => s.distanceTo(v) < 0.01)) continue;
		seen.push(v);
		const at = v.clone().multiplyScalar(R * 0.93);
		b.add('patches', black, new THREE.CylinderGeometry(0.035, 0.035, 0.02, 5), { pos: at, lookAt: v.clone().multiplyScalar(2) });
	}
	b.add('scuff', scuff, new THREE.SphereGeometry(0.03, 6, 4), { pos: V(0.07, 0.07, 0.04), scale: [1, 0.3, 1] });
	return b.build();
}

// Concejal Barullo's scooter (step 6), the referee's getaway: a green scooter with chrome mirrors, a campaign flag on
// a pole at the back and a white plate with a green rosette. 1.9 m long (z), 0.7 m wide, facing +Z; its wheels are
// part of it. Its origin on the ground in the middle.
export function buildBarulloScooter() {
	const b = new Builder('barullo_scooter');
	const green = mat('barullo_green', 0x2a9a4a), tire = mat('tire', 0x1a1a1e), rim = mat('rim', 0xc8ccd2);
	const seat = mat('barullo_seat', 0x23252b), white = mat('goal_white', 0xf4f4f0), pole = mat('stretcher_pole', 0xb8bcc2);
	for (const z of [0.68, -0.68]) {
		b.add('wheels', tire, new THREE.CylinderGeometry(0.26, 0.26, 0.12, 10), { pos: V(0, 0.26, z), rot: [0, 0, Math.PI / 2] });
		b.add('wheels', rim, new THREE.CylinderGeometry(0.12, 0.12, 0.13, 8), { pos: V(0, 0.26, z), rot: [0, 0, Math.PI / 2] });
	}
	box(b, 'body', green, 0.36, 0.1, 0.8, 0, 0.32, 0.05);
	box(b, 'body', green, 0.42, 0.36, 0.6, 0, 0.5, -0.45);
	box(b, 'body', seat, 0.36, 0.08, 0.5, 0, 0.72, -0.4);
	box(b, 'body', green, 0.38, 0.75, 0.1, 0, 0.7, 0.55, [-0.25, 0, 0]);
	box(b, 'body', seat, 0.6, 0.04, 0.04, 0, 1.12, 0.62);
	for (const x of [-1, 1]) {
		box(b, 'mirrors', pole, 0.02, 0.18, 0.02, x * 0.28, 1.22, 0.62);
		b.add('mirrors', rim, new THREE.CylinderGeometry(0.05, 0.05, 0.02, 8), { pos: V(x * 0.28, 1.32, 0.62), rot: [Math.PI / 2, 0, 0] });
	}
	box(b, 'plate', white, 0.26, 0.16, 0.02, 0, 0.5, -0.76);
	b.add('plate', green, new THREE.CylinderGeometry(0.05, 0.05, 0.01, 10), { pos: V(0, 0.5, -0.775), rot: [Math.PI / 2, 0, 0] });
	b.add('flag', pole, new THREE.CylinderGeometry(0.012, 0.012, 1.2, 6), { pos: V(-0.18, 1.2, -0.7) });
	box(b, 'flag', green, 0.02, 0.3, 0.45, -0.18, 1.62, -0.92);
	box(b, 'flag', white, 0.025, 0.1, 0.3, -0.18, 1.62, -0.92);
	return b.build();
}

export const models = { football_goal: buildGoal, team_bench: buildBench, stretcher: buildStretcher, football_cup: buildCup,
	football_ball: buildBall, barullo_scooter: buildBarulloScooter };

export const views = {
	football_pitch_props: {
		items: [{ name: 'football_goal', pos: [0, 0, 0], rotY: 0.5 }, { name: 'team_bench', pos: [5.5, 0, 1.5], rotY: -0.6 },
			{ name: 'stretcher', pos: [-3.5, 0, 2.5], rotY: 0.3 }, { name: 'football_cup', pos: [2.0, 0, 3.5] },
			{ name: 'football_ball', pos: [0.8, 0.11, 4.5] }],
		cam: { pos: [3.0, 4.0, 10.0], target: [1.0, 0.8, 0.5], fov: 50 },
	},
};
