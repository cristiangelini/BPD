// The gym raid (allanamiento-gimnasio.md, decision 250): el profe Fito, Lula the receptionist, the reception's stereo,
// the record wall with its bar and a shop mannequin that "trains" for a ghost member. Placeholder, not final art.
import { Builder, loft, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, pearBody, eyes, limb } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);
const white = M.white, black = M.black;

function mouth(b, smile = true) {
	b.add('face', C('mouth', 0x7a2a2a), ellipsoid(0.05, smile ? 0.02 : 0.03, 0.02, 6, 4), { pos: V(0, 1.22, 0.2) });
}

// Stripes around the pear body's bottom (pants) or top (shirt), at the heights in `ys`.
function stripes(b, m, ys) {
	for (const y of ys) {
		const r = y < 0.5 ? 0.36 + Math.min(y - 0.1, 0.2) * 0.6 - Math.max(y - 0.3, 0) * 0.1 : y < 0.8 ? 0.46 - (y - 0.5) * 0.33 : 0.36 - (y - 0.8) * 0.48;
		b.add('body', m, loft([{ y: y - 0.02, rx: r + 0.012, rz: r * 0.89 + 0.012 }, { y: y + 0.02, rx: r + 0.012, rz: r * 0.89 + 0.012 }], 10));
	}
}

function wristbands(b, m) {
	for (const s of [-1, 1]) b.add('arms', m, new THREE.CylinderGeometry(0.07, 0.07, 0.07, 8), { pos: V(s * 0.43, 0.71, 0.07), lookAt: V(s * 0.16, -0.17, 0.08) });
}

// A whistle hanging from a cord on the chest.
function whistle(b) {
	const cord = C('whistle_cord', 0xe23a3a);
	b.add('body', cord, new THREE.TorusGeometry(0.17, 0.008, 4, 16, Math.PI), { pos: V(0, 1.08, 0.08), rot: [0.5, 0, Math.PI] });
	b.add('body', C('whistle_steel', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 }), new THREE.CylinderGeometry(0.025, 0.025, 0.07, 8), { pos: V(0, 0.92, 0.27), rot: [0, 0, Math.PI / 2] });
}

const models = {
	// El profe Fito, the aerobics teacher: neon headband over huge curls, a pink tank top, striped tights, wristbands and
	// his whistle. The game scales him thin (x 0.85).
	npc_profe_fito() {
		const b = new Builder('npc_profe_fito');
		const tank = C('fito_tank', 0xff4fa8), tights = C('fito_tights', 0x2a2a8a), stripe = C('fito_stripe', 0x3fe0ff);
		pearBody(b, C('skin_arena', 0xd9a06b), { shirt: tank, pants: tights, shoes: white, belted: false });
		stripes(b, stripe, [0.2, 0.32, 0.44]);
		eyes(b, 1.34, 0.17, 0.08, 0.05);
		mouth(b);
		const hair = C('fito_hair', 0x3a2414);
		for (let i = 0; i < 14; i++) {
			const a = (i / 14) * Math.PI * 2, up = i % 2 ? 1.5 : 1.42;
			b.add('hair', hair, ellipsoid(0.09, 0.09, 0.09, 6, 4), { pos: V(Math.cos(a) * 0.17, up, 0.02 + Math.sin(a) * 0.16 - (Math.sin(a) > 0.6 ? 0.06 : 0)) });
		}
		b.add('hair', hair, ellipsoid(0.17, 0.1, 0.16, 8, 5), { pos: V(0, 1.53, -0.01) });
		b.add('hair', C('fito_headband', 0xc8ff2a, { emissive: 0x2a3a00 }), new THREE.CylinderGeometry(0.205, 0.205, 0.05, 12, 1, true), { pos: V(0, 1.42, 0.02) });
		wristbands(b, stripe);
		whistle(b);
		return b.build();
	},
	// Lula, the receptionist: a purple tracksuit with white stripes on the sleeves, a high ponytail and a headset.
	npc_lula() {
		const b = new Builder('npc_lula');
		const suit = C('lula_suit', 0x7a3fc8), stripe = C('lula_stripe', 0xf6f4ee);
		pearBody(b, C('skin_crema', 0xf3d2b0), { shirt: suit, pants: suit, shoes: C('lula_shoes', 0xff9d3f), belted: false, onePiece: true });
		for (const s of [-1, 1]) limb(b, 'arms', stripe, V(s * 0.31, 0.88, 0.01), V(s * 0.45, 0.72, 0.08), 0.03);
		eyes(b, 1.34, 0.17, 0.08, 0.05);
		mouth(b);
		const hair = C('lula_hair', 0xd89a3a);
		b.add('hair', hair, ellipsoid(0.21, 0.13, 0.2, 10, 6), { pos: V(0, 1.43, 0.0) });
		b.add('hair', hair, ellipsoid(0.06, 0.06, 0.06, 6, 4), { pos: V(0, 1.58, -0.12) });
		b.add('hair', hair, ellipsoid(0.07, 0.2, 0.07, 6, 5), { pos: V(0, 1.44, -0.25), rot: [0.5, 0, 0] });
		b.add('headset', black, new THREE.TorusGeometry(0.24, 0.014, 4, 14, Math.PI), { pos: V(0, 1.32, 0.0) });
		b.add('headset', black, ellipsoid(0.03, 0.05, 0.04, 6, 4), { pos: V(0.22, 1.3, 0.0) });
		limb(b, 'headset', black, V(0.22, 1.27, 0.03), V(0.08, 1.2, 0.2), 0.008, 4);
		return b.build();
	},
	// The reception's stereo: a big silver boombox with two speakers, a cassette door and a handle.
	gym_stereo() {
		const b = new Builder('gym_stereo');
		const body = C('stereo_silver', 0xb8bcc4, { metalness: 0.4, roughness: 0.4 });
		b.add('box', body, new THREE.BoxGeometry(0.8, 0.4, 0.22), { pos: V(0, 0.2, 0) });
		for (const s of [-1, 1]) {
			b.add('speakers', black, new THREE.CylinderGeometry(0.14, 0.14, 0.03, 12), { pos: V(s * 0.24, 0.19, 0.115), rot: [Math.PI / 2, 0, 0] });
			b.add('speakers', C('stereo_cone', 0x3a3a44), new THREE.CylinderGeometry(0.05, 0.05, 0.035, 8), { pos: V(s * 0.24, 0.19, 0.12), rot: [Math.PI / 2, 0, 0] });
		}
		b.add('box', C('stereo_tape', 0x2a2a30), new THREE.BoxGeometry(0.18, 0.1, 0.01), { pos: V(0, 0.22, 0.115) });
		for (let i = 0; i < 4; i++) b.add('buttons', i === 0 ? C('stereo_play', 0x3fd06a, { emissive: 0x0a3a14 }) : black, new THREE.BoxGeometry(0.035, 0.025, 0.04), { pos: V(-0.06 + i * 0.04, 0.41, 0.05) });
		b.add('handle', black, new THREE.TorusGeometry(0.2, 0.02, 4, 12, Math.PI), { pos: V(0, 0.4, -0.04) });
		return b.build();
	},
	// The record wall's frame: el profe "lifting 300 kg" (a stick picture), a gold plaque and the hooks for the bar.
	gym_record_wall() {
		const b = new Builder('gym_record_wall');
		b.add('frame', C('record_frame', 0xd8a83a, { metalness: 0.5, roughness: 0.4 }), new THREE.BoxGeometry(1.4, 1.0, 0.04), { pos: V(0, 0.5, 0) });
		b.add('photo', C('record_photo', 0xfff4d8), new THREE.BoxGeometry(1.24, 0.84, 0.01), { pos: V(0, 0.5, 0.025) });
		const ink = C('record_ink', 0xff4fa8);
		b.add('photo', ink, ellipsoid(0.07, 0.08, 0.01, 8, 4), { pos: V(0, 0.66, 0.032) });
		b.add('photo', ink, new THREE.BoxGeometry(0.06, 0.24, 0.01), { pos: V(0, 0.48, 0.032) });
		b.add('photo', black, new THREE.BoxGeometry(0.9, 0.025, 0.01), { pos: V(0, 0.78, 0.034) });
		for (const s of [-1, 1]) {
			b.add('photo', black, new THREE.BoxGeometry(0.05, 0.22, 0.01), { pos: V(s * 0.42, 0.78, 0.034) });
			b.add('photo', ink, new THREE.BoxGeometry(0.03, 0.18, 0.01), { pos: V(s * 0.08, 0.68, 0.032), rot: [0, 0, s * -0.5] });
		}
		b.add('plaque', C('record_plaque', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.BoxGeometry(0.6, 0.12, 0.02), { pos: V(0, -0.12, 0.01) });
		for (const s of [-1, 1]) b.add('hooks', black, new THREE.BoxGeometry(0.04, 0.12, 0.12), { pos: V(s * 0.6, -0.4, 0.06) });
		return b.build();
	},
	// The record bar "300 kg": a long bar with three huge black plates on each end (it's polystyrene, it only looks heavy).
	gym_record_bar() {
		const b = new Builder('gym_record_bar');
		const steel = C('bar_steel', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 }), plate = C('bar_plate', 0x1e1e24);
		b.add('bar', steel, new THREE.CylinderGeometry(0.025, 0.025, 1.8, 8), { pos: V(0, 0, 0), rot: [0, 0, Math.PI / 2] });
		for (const s of [-1, 1]) {
			for (let i = 0; i < 3; i++) b.add('plates', plate, new THREE.CylinderGeometry(0.22 - i * 0.03, 0.22 - i * 0.03, 0.06, 14), { pos: V(s * (0.6 + i * 0.07), 0, 0), rot: [0, 0, Math.PI / 2] });
			b.add('plates', white, new THREE.CylinderGeometry(0.1, 0.1, 0.065, 10), { pos: V(s * 0.6, 0, 0), rot: [0, 0, Math.PI / 2] });
		}
		return b.build();
	},
	// A shop mannequin in a gym tank top: smooth beige pear with no face, the ghost members' stand-in.
	gym_mannequin() {
		const b = new Builder('gym_mannequin');
		const plastic = C('mannequin_plastic', 0xe8d8c0, { roughness: 0.35 });
		pearBody(b, plastic, { shirt: C('mannequin_tank', 0x3fd06a), pants: plastic, shoes: plastic, belted: false });
		b.add('stand', C('mannequin_stand', 0x6a6a70, { metalness: 0.5 }), new THREE.CylinderGeometry(0.25, 0.28, 0.04, 12), { pos: V(0, 0.02, 0.05) });
		return b.build();
	},
};

export { models };
export const views = {
	gym_raid_people: {
		items: [{ name: 'npc_profe_fito', pos: [-0.7, 0, 0], rotY: 0.35, scale: 0.95 }, { name: 'npc_lula', pos: [0.7, 0, 0], rotY: -0.35 }],
		cam: { pos: [0, 1.3, 4.2], target: [0, 0.8, 0], fov: 34 },
	},
	gym_raid_people_back: {
		items: [{ name: 'npc_profe_fito', pos: [-0.7, 0, 0], rotY: Math.PI - 0.5, scale: 0.95 }, { name: 'npc_lula', pos: [0.7, 0, 0], rotY: Math.PI + 0.5 }],
		cam: { pos: [0, 1.3, 4.2], target: [0, 0.8, 0], fov: 34 },
	},
	gym_raid_props: {
		items: [{ name: 'gym_stereo', pos: [-1.3, 0, 0.6], rotY: 0.3 }, { name: 'gym_record_wall', pos: [0, 0.9, -0.3] },
			{ name: 'gym_record_bar', pos: [0, 0.4, 0.1] }, { name: 'gym_mannequin', pos: [1.5, 0, 0.2], rotY: -0.4 }],
		cam: { pos: [0, 1.4, 5.2], target: [0, 0.8, 0], fov: 38 },
	},
};
