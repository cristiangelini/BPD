// The Municipal Planetarium's people (escena-planetario.md, step 2): the guide (six alike in the planetarium's white
// astronaut suit with a rocket patch, the helmet with its visor down, gloves and moon boots), Doctor Órbita the director
// (lab coat, huge glasses and wild grey hair) and Doña Nebulosa, asleep in her coat with a shawl and curlers. Faces +Z,
// feet at y = 0. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);

// The guide. The parts the game changes per guide have their own nodes: helmet (taken off) and visor (part of it),
// hair (recolored, under the helmet), teeth (shown when they bite), legs (the moon boots, stretched to their size),
// glove_left and glove_right, glow_left and glow_right (the glow paint on each glove, shown in the dark), and pin (the
// planet pin on the chest, recolored to their planet).
function guia(b) {
	const suit = C('astro_suit', 0xeef0f4), grey = C('astro_grey', 0x9aa0aa), patch = C('astro_patch', 0x2f5fd8);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: suit, pants: suit, belted: false, shoes: grey });
	// The rocket patch on the chest and the pin under it.
	b.add('body', patch, ellipsoid(0.08, 0.08, 0.02, 8, 4), { pos: V(-0.12, 0.88, 0.31) });
	b.add('body', C('rocket_red', 0xd83a3a), new THREE.ConeGeometry(0.025, 0.08, 4), { pos: V(-0.12, 0.89, 0.325) });
	b.add('pin', C('pin', 0xffffff), ellipsoid(0.04, 0.04, 0.015, 8, 4), { pos: V(0.12, 0.85, 0.32) });
	// The life-support pack on the back and the moon boots, big and grey.
	b.add('body', grey, new THREE.BoxGeometry(0.42, 0.42, 0.16), { pos: V(0, 0.82, -0.36) });
	for (const s of [-1, 1]) b.add('legs', grey, new THREE.BoxGeometry(0.24, 0.16, 0.34), { pos: V(s * 0.2, 0.08, 0.1) });
	eyes(b, 1.31, 0.17, 0.08, 0.05);
	b.add('face', M.black, new THREE.BoxGeometry(0.07, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	b.add('teeth', M.white, new THREE.BoxGeometry(0.08, 0.025, 0.02), { pos: V(0, 1.205, 0.2) });
	b.add('hair', C('hair', 0xffffff), ellipsoid(0.2, 0.12, 0.18, 10, 5), { pos: V(0, 1.43, -0.04) });
	// The helmet: a big white bowl around the head with a gold visor down over the face.
	b.add('helmet', suit, ellipsoid(0.29, 0.29, 0.28, 12, 8), { pos: V(0, 1.33, -0.02) });
	b.add('helmet', C('visor', 0xe0b040, { metalness: 0.6, roughness: 0.25 }), ellipsoid(0.22, 0.16, 0.08, 10, 6), { pos: V(0, 1.33, 0.22) });
	b.add('helmet', grey, new THREE.TorusGeometry(0.22, 0.03, 6, 14), { pos: V(0, 1.08, 0), rot: [Math.PI / 2, 0, 0] });
	// The gloves, and the glow paint on each one.
	const glow = C('glow_paint', 0x7dff6a, { emissive: 0x5aff40, emissiveIntensity: 1.5 });
	for (const [s, side] of [[-1, 'left'], [1, 'right']]) {
		b.add(`glove_${side}`, grey, ellipsoid(0.09, 0.09, 0.09, 6, 4), { pos: V(s * 0.49, 0.64, 0.09) });
		for (let i = 0; i < 3; i++) {
			b.add(`glow_${side}`, glow, ellipsoid(0.025, 0.025, 0.012, 6, 3), { pos: V(s * (0.49 + (i - 1) * 0.035), 0.66 - (i % 2) * 0.03, 0.18) });
		}
	}
}

// Doctor Órbita, the director: a white lab coat over a purple sweater, huge round glasses, wild grey hair sticking out on
// both sides and a pointer in his hand.
function orbita(b) {
	const coat = C('lab_coat', 0xf4f4f0), sweater = C('orbita_sweater', 0x6a3a9a);
	pearBody(b, mat('skin_rosada', 0xf0c4a8), { shirt: coat, pants: C('orbita_pants', 0x3a3a46), belted: false });
	b.add('body', sweater, new THREE.BoxGeometry(0.2, 0.3, 0.05), { pos: V(0, 0.92, 0.3), rot: [-0.25, 0, 0] });
	eyes(b, 1.33, 0.17, 0.08, 0.045);
	for (const s of [-1, 1]) {
		b.add('face', M.black, new THREE.TorusGeometry(0.07, 0.012, 4, 12), { pos: V(s * 0.08, 1.33, 0.21) });
		b.add('hair', C('hair_grey', 0xd8d8dc), ellipsoid(0.12, 0.1, 0.12, 8, 5), { pos: V(s * 0.2, 1.4, -0.02) });
	}
	b.add('face', M.black, new THREE.BoxGeometry(0.05, 0.012, 0.012), { pos: V(0, 1.33, 0.22) });
	b.add('face', M.black, new THREE.BoxGeometry(0.08, 0.015, 0.02), { pos: V(0, 1.2, 0.195) });
	b.add('props', C('pointer', 0x8a6a3a), new THREE.CylinderGeometry(0.01, 0.01, 0.6, 5), { pos: V(0.55, 0.85, 0.2), rot: [0.6, 0, 0] });
	b.add('props', C('pointer_tip', 0xff4040, { emissive: 0xff2020 }), ellipsoid(0.02, 0.02, 0.02, 5, 3), { pos: V(0.55, 1.1, 0.45) });
}

// Doña Nebulosa, asleep: a long brown coat with a knitted shawl, curlers in her grey hair, her eyes shut ('eyes_shut')
// with the open ones hidden ('eyes_open', for when she wakes up), and a little "Zzz" of her own above her head.
function nebulosa(b) {
	const coat = C('nebulosa_coat', 0x7a4a30), shawl = C('nebulosa_shawl', 0xc86aa8);
	pearBody(b, mat('skin_crema', 0xf3d2b0), { shirt: coat, pants: coat, belted: false, onePiece: true, shoes: C('slippers', 0x9a5aa0) });
	b.add('body', shawl, ellipsoid(0.32, 0.12, 0.28, 10, 5), { pos: V(0, 1.02, 0.0) });
	b.add('hair', C('hair_grey', 0xd8d8dc), ellipsoid(0.21, 0.13, 0.2, 10, 5), { pos: V(0, 1.42, -0.03) });
	const curler = C('curler', 0x6ac8f0);
	for (const [x, z] of [[-0.1, 0.08], [0.1, 0.08], [0, -0.08], [-0.15, -0.05], [0.15, -0.05]]) {
		b.add('hair', curler, new THREE.CylinderGeometry(0.03, 0.03, 0.09, 6), { pos: V(x, 1.53, z), rot: [0, 0, Math.PI / 2] });
	}
	for (const s of [-1, 1]) {
		b.add('eyes_shut', M.black, new THREE.BoxGeometry(0.06, 0.012, 0.01), { pos: V(s * 0.08, 1.32, 0.205) });
	}
	for (const s of [-1, 1]) {
		b.add('eyes_open', M.white, ellipsoid(0.045, 0.052, 0.02, 8, 6), { pos: V(s * 0.08, 1.33, 0.17) });
		b.add('eyes_open', M.black, ellipsoid(0.02, 0.025, 0.011, 6, 4), { pos: V(s * 0.08, 1.33, 0.186) });
	}
	b.add('face', C('lips', 0xc84a5a), ellipsoid(0.04, 0.025, 0.02, 6, 3), { pos: V(0, 1.2, 0.195) });
	b.add('zzz', C('zzz', 0xbfd8ff, { emissive: 0x405070 }), new THREE.BoxGeometry(0.08, 0.08, 0.01), { pos: V(0.22, 1.7, 0.05), rot: [0, 0, 0.3] });
}

const PEOPLE = { npc_guia: guia, npc_orbita: orbita, npc_nebulosa: nebulosa };

export const models = Object.fromEntries(Object.entries(PEOPLE).map(([n, f]) => [n, () => {
	const b = new Builder(n);
	f(b);
	return b.build();
}]));

export const views = {
	planetarium_people: {
		items: [{ name: 'npc_orbita', pos: [-1.3, 0, 0], rotY: 0.3 }, { name: 'npc_guia', pos: [0, 0, 0], rotY: 0.2 },
			{ name: 'npc_nebulosa', pos: [1.3, 0, 0], rotY: -0.3 }],
		cam: { pos: [0, 1.4, 6.0], target: [0, 0.85, 0], fov: 38 },
	},
};
