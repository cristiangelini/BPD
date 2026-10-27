// Props of the "Cine Butaca Floja" (docs/diseno/allanamiento-cine.md): the folding velvet seat, the popcorn machine and
// the old film projector, with origins at the floor in the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

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

export const models = {
	cinema_seat: buildCinemaSeat, popcorn_machine: buildPopcornMachine, film_projector: buildFilmProjector,
};

export const views = {
	cinema: {
		items: [
			{ name: 'cinema_seat', pos: [-1.2, 0, 0] }, { name: 'cinema_seat', pos: [-0.5, 0, 0] },
			{ name: 'popcorn_machine', pos: [0.5, 0, 0.3] }, { name: 'film_projector', pos: [1.5, 0, 0], rotY: -0.6 },
		],
		cam: { pos: [0, 1.6, 4.5], target: [0.1, 0.7, 0], fov: 40 },
	},
};
