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

export const models = { race_spoiler: buildRaceSpoiler, race_exhaust: buildRaceExhaust, race_roundel: buildRaceRoundel };

export const views = {
	race_spoiler: {
		items: [{ name: 'traffic_car_0', pos: [0, 0, 0] }, { name: 'race_spoiler', pos: [0, 1.0, -1.9] },
			{ name: 'race_exhaust', pos: [0, 0.38, -2.3] }, { name: 'race_roundel', pos: [1.09, 0.72, 0.2] }],
		cam: { pos: [4.5, 2.4, -4.2], target: [0, 0.7, -0.5], fov: 40 },
	},
};
