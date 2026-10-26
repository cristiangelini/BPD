// The street race traffic check (docs/diseno/control-carrera.md): what makes a racer out of a city sedan, the
// spoiler on its trunk, its exhaust pipes and the number roundel on its doors. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// A racing wing on two posts, faces +Z, origin where the posts stand on the trunk lid. Black, so it goes on any paint.
export function buildRaceSpoiler() {
	const b = new Builder('race_spoiler');
	const black = mat('race_wing', 0x1c1c20);
	for (const x of [-0.55, 0.55]) box(b, 'wing', black, 0.06, 0.28, 0.12, x, 0.14, 0);
	box(b, 'wing', black, 1.8, 0.04, 0.38, 0, 0.3, -0.04, [-0.12, 0, 0]);
	for (const x of [-0.9, 0.9]) box(b, 'wing', black, 0.03, 0.16, 0.42, x, 0.3, -0.04);
	return b.build();
}

// Two fat chrome pipes out of the back bumper, trailing -Z, origin at the bumper; 'tip' is where the sparks come out.
export function buildRaceExhaust() {
	const b = new Builder('race_exhaust');
	const chrome = mat('race_chrome', 0xc8ccd2, { metalness: 0.6, roughness: 0.35 });
	const soot = mat('race_soot', 0x202020);
	for (const x of [-0.55, -0.35]) {
		b.add('pipe', chrome, new THREE.CylinderGeometry(0.06, 0.06, 0.25, 10), { pos: V(x, 0, -0.1), rot: [Math.PI / 2, 0, 0] });
		b.add('tip', soot, new THREE.CylinderGeometry(0.045, 0.045, 0.02, 10), { pos: V(x, 0, -0.225), rot: [Math.PI / 2, 0, 0] });
	}
	return b.build();
}

// The number roundel on a door: a white disc with a black ring, faces +X; the game writes the number over it.
export function buildRaceRoundel() {
	const b = new Builder('race_roundel');
	const white = mat('race_roundel', 0xfafafa), black = mat('race_ring', 0x18181c);
	b.add('roundel', black, new THREE.CylinderGeometry(0.34, 0.34, 0.01, 20), { pos: V(0, 0, 0), rot: [0, 0, Math.PI / 2] });
	b.add('roundel', white, new THREE.CylinderGeometry(0.3, 0.3, 0.012, 20), { pos: V(0.001, 0, 0), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// The patrol car's spike strip, deployed (step 3): a dark band 4.5 m long along X with yellow spikes up, its rope
// looped at the +X end (E pulls it back). Origin on the ground, at its middle.
export function buildSpikeStrip() {
	const b = new Builder('spike_strip');
	const band = mat('spike_band', 0x26262a), spike = mat('spike_yellow', 0xf2c81e), rope = mat('spike_rope', 0xd8a040);
	box(b, 'band', band, 4.5, 0.04, 0.35, 0, 0.02, 0);
	for (let i = 0; i < 18; i++) {
		const x = -2.1 + i * (4.2 / 17);
		for (const z of [-0.09, 0.09]) b.add('spikes', spike, new THREE.ConeGeometry(0.035, 0.12, 4), { pos: V(x + (z > 0 ? 0.06 : 0), 0.1, z) });
	}
	b.add('rope', rope, new THREE.TorusGeometry(0.18, 0.025, 5, 12), { pos: V(2.45, 0.03, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The same strip rolled up to carry, 50 cm across: a coil of the band, spikes sticking out, the rope hanging.
export function buildSpikeRoll() {
	const b = new Builder('spike_roll');
	const band = mat('spike_band', 0x26262a), spike = mat('spike_yellow', 0xf2c81e), rope = mat('spike_rope', 0xd8a040);
	b.add('band', band, new THREE.CylinderGeometry(0.2, 0.2, 0.35, 12), { pos: V(0, 0.2, 0), rot: [Math.PI / 2, 0, 0] });
	for (let i = 0; i < 10; i++) {
		const a = (i / 10) * Math.PI * 2;
		b.add('spikes', spike, new THREE.ConeGeometry(0.03, 0.1, 4), { pos: V(Math.cos(a) * 0.23, 0.2 + Math.sin(a) * 0.23, (i % 2 ? 0.08 : -0.08)), rot: [0, 0, a - Math.PI / 2] });
	}
	b.add('rope', rope, new THREE.TorusGeometry(0.12, 0.02, 5, 10), { pos: V(0.25, 0.1, 0), rot: [0, Math.PI / 2, 0] });
	return b.build();
}

// El Turbo's trophy (step 5), upright, faces +Z: a gold cup with two handles on a black base and a checkered flag.
export function buildRaceTrophy() {
	const b = new Builder('race_trophy');
	const gold = mat('trophy_gold', 0xe8c040, { metalness: 0.5, roughness: 0.4 }), base = mat('trophy_base', 0x1c1c20);
	const white = mat('flag_white', 0xf4f4f0), black = mat('flag_black', 0x18181c);
	box(b, 'base', base, 0.16, 0.06, 0.16, 0, 0.03, 0);
	b.add('cup', gold, new THREE.CylinderGeometry(0.02, 0.03, 0.08, 10), { pos: V(0, 0.1, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.09, 0.04, 0.14, 14), { pos: V(0, 0.21, 0) });
	for (const x of [-1, 1]) b.add('cup', gold, new THREE.TorusGeometry(0.035, 0.01, 5, 10), { pos: V(x * 0.1, 0.22, 0) });
	b.add('cup', gold, new THREE.CylinderGeometry(0.004, 0.004, 0.2, 5), { pos: V(0.06, 0.38, 0) });
	for (let i = 0; i < 4; i++) for (let j = 0; j < 3; j++)
		box(b, 'flag', (i + j) % 2 ? black : white, 0.025, 0.025, 0.004, 0.0785 + i * 0.025, 0.455 - j * 0.025, 0);
	return b.build();
}

export const models = { race_trophy: buildRaceTrophy, race_spoiler: buildRaceSpoiler, race_exhaust: buildRaceExhaust, race_roundel: buildRaceRoundel,
	spike_strip: buildSpikeStrip, spike_roll: buildSpikeRoll };

export const views = {
	race_spoiler: {
		items: [{ name: 'traffic_car_0', pos: [0, 0, 0] }, { name: 'race_spoiler', pos: [0, 1.0, -1.9] },
			{ name: 'race_exhaust', pos: [0, 0.38, -2.3] }, { name: 'race_roundel', pos: [1.09, 0.72, 0.2] }],
		cam: { pos: [4.5, 2.4, -4.2], target: [0, 0.7, -0.5], fov: 40 },
	},
	race_trophy: {
		items: [{ name: 'race_trophy', pos: [0, 0, 0] }],
		cam: { pos: [0.35, 0.4, 0.8], target: [0.03, 0.22, 0], fov: 35 },
	},
	spike_strip: {
		items: [{ name: 'spike_strip', pos: [0, 0, 0] }, { name: 'spike_roll', pos: [0, 0, 1.0] }],
		cam: { pos: [2.5, 2.0, 3.5], target: [0.5, 0.1, 0.4], fov: 40 },
	},
};
