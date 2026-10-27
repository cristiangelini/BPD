// Props of "Radio La Antena Loca" (docs/diseno/allanamiento-radio.md): the mixing console with its microphone, the
// record player on its table, the record shelf and the antenna on the roof, with origins at the floor in the middle of
// each piece. Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';
import { M, pearBody, eyes } from './pear.js';

// The studio's mixing console on its desk, 2.0 x 1.4 x 0.8 m, with the microphone on its arm and a pair of
// headphones. The host sits on its -Z side, looking to +Z out of the studio's window.
export function buildRadioConsole() {
	const b = new Builder('radio_console');
	const desk = mat('console_desk', 0x3a3a44), panel = mat('console_panel', 0x24242a), knob = mat('console_knob', 0xe0e0e0);
	b.add('desk', desk, new THREE.BoxGeometry(2.0, 0.76, 0.8), { pos: V(0, 0.38, 0) });
	b.add('panel', panel, new THREE.BoxGeometry(1.4, 0.1, 0.5), { pos: V(0, 0.81, -0.05), rot: [-0.2, 0, 0] });
	for (let i = 0; i < 8; i++) {
		b.add('faders', knob, new THREE.BoxGeometry(0.03, 0.03, 0.1), { pos: V(-0.56 + i * 0.16, 0.88, -0.1), rot: [-0.2, 0, 0] });
		b.add('leds', mat(i % 3 === 0 ? 'led_red' : 'led_green', i % 3 === 0 ? 0xff3030 : 0x40e060, { emissive: i % 3 === 0 ? 0xff3030 : 0x40e060 }), new THREE.BoxGeometry(0.02, 0.01, 0.02), { pos: V(-0.56 + i * 0.16, 0.88, 0.1) });
	}
	const steel = mat('mic_steel', 0x9a9ea6);
	b.add('arm', steel, new THREE.CylinderGeometry(0.015, 0.015, 0.55, 6), { pos: V(0.5, 1.05, -0.15), rot: [-0.6, 0, 0.3] });
	b.add('mic', mat('mic_black', 0x18181c), new THREE.CylinderGeometry(0.045, 0.04, 0.16, 10), { pos: V(0.4, 1.3, -0.32), rot: [-1.1, 0, 0] });
	b.add('mic_grille', steel, new THREE.SphereGeometry(0.05, 8, 6), { pos: V(0.4, 1.33, -0.4) });
	b.add('phones', mat('phones_red', 0xc02828), new THREE.TorusGeometry(0.09, 0.015, 4, 10, Math.PI), { pos: V(-0.6, 0.86, -0.25) });
	return b.build();
}

// The record player on its little table in the control room, 0.6 x 0.95 x 0.5 m: a wooden box with the black disc,
// the silver arm and two big knobs.
export function buildRecordPlayer() {
	const b = new Builder('record_player');
	const wood = mat('player_wood', 0x8a5a30);
	b.add('table', mat('player_table', 0x2a2a30), new THREE.BoxGeometry(0.6, 0.75, 0.5), { pos: V(0, 0.375, 0) });
	b.add('box', wood, new THREE.BoxGeometry(0.56, 0.12, 0.46), { pos: V(0, 0.81, 0) });
	b.add('disc', mat('vinyl', 0x101014), new THREE.CylinderGeometry(0.17, 0.17, 0.01, 18), { pos: V(-0.06, 0.875, 0) });
	b.add('label', mat('disc_label', 0xe04040), new THREE.CylinderGeometry(0.05, 0.05, 0.012, 10), { pos: V(-0.06, 0.876, 0) });
	b.add('arm', mat('player_arm', 0xc0c4cc), new THREE.BoxGeometry(0.02, 0.02, 0.26), { pos: V(0.18, 0.9, -0.02), rot: [0, 0.4, 0] });
	for (const x of [0.16, 0.22]) b.add('knobs', mat('player_knob', 0xe8e0c8), new THREE.CylinderGeometry(0.02, 0.02, 0.03, 8), { pos: V(x, 0.88, 0.18) });
	return b.build();
}

// A shelf of records in the archive, 3.0 x 2.2 x 0.5 m: dark wooden boards with rows of colored sleeves standing up.
export function buildRecordShelf() {
	const b = new Builder('record_shelf');
	const wood = mat('shelf_wood', 0x5a3a22);
	for (const x of [-1.48, 1.48]) b.add('sides', wood, new THREE.BoxGeometry(0.04, 2.2, 0.5), { pos: V(x, 1.1, 0) });
	b.add('back', wood, new THREE.BoxGeometry(3.0, 2.2, 0.02), { pos: V(0, 1.1, -0.24) });
	const sleeves = [0xc03030, 0x3050a0, 0xe0b030, 0x309050, 0x8040a0, 0x202020, 0xe07020];
	for (let s = 0; s < 4; s++) {
		const y = 0.04 + s * 0.54;
		b.add('boards', wood, new THREE.BoxGeometry(2.96, 0.04, 0.48), { pos: V(0, y, 0) });
		for (let i = 0; i < 18; i++) {
			const c = sleeves[(i * 3 + s) % sleeves.length];
			b.add(`sleeves_${(i * 3 + s) % sleeves.length}`, mat(`sleeve_${(i * 3 + s) % sleeves.length}`, c), new THREE.BoxGeometry(0.03, 0.31, 0.31), { pos: V(-1.36 + i * 0.16, y + 0.175, 0.02), rot: [0, 0, (i % 4 === 3) ? 0.15 : 0] });
		}
	}
	b.add('boards', wood, new THREE.BoxGeometry(2.96, 0.04, 0.48), { pos: V(0, 2.18, 0) });
	return b.build();
}

// The antenna on the roof, a red and white lattice mast 6 m high on a concrete foot, with a dish halfway up.
export function buildRadioAntenna() {
	const b = new Builder('radio_antenna');
	const red = mat('antenna_red', 0xd02020), white = mat('antenna_white', 0xf0f0f0);
	b.add('foot', mat('antenna_foot', 0x8a8a8a), new THREE.BoxGeometry(0.8, 0.2, 0.8), { pos: V(0, 0.1, 0) });
	for (let i = 0; i < 6; i++) {
		const w = 0.36 - i * 0.04;
		b.add(i % 2 === 0 ? 'red' : 'white', i % 2 === 0 ? red : white, new THREE.CylinderGeometry(w * 0.8, w, 1.0, 3), { pos: V(0, 0.7 + i, 0) });
	}
	b.add('dish', white, new THREE.CylinderGeometry(0.4, 0.15, 0.12, 12), { pos: V(0.3, 3.2, 0), rot: [0, 0, Math.PI / 2] });
	b.add('tip', red, new THREE.CylinderGeometry(0.02, 0.03, 0.6, 6), { pos: V(0, 6.5, 0) });
	return b.build();
}

// Don Volumen, the owner and announcer: big, a shiny gold jacket over a black shirt, a thin black mustache, slicked
// black hair and big red headphones always on. The game scales him tall and wide.
export function buildDonVolumen() {
	const b = new Builder('npc_don_volumen');
	const jacket = mat('volumen_jacket', 0xe0b030, { emissive: 0x2a1e04 });
	pearBody(b, mat('skin_volumen', 0xd9a07a), { shirt: jacket, pants: M.black, shoes: M.black, belted: false });
	b.add('shirt', M.black, new THREE.BoxGeometry(0.16, 0.36, 0.02), { pos: V(0, 0.88, 0.33), rot: [-0.2, 0, 0] });
	eyes(b, 1.34, 0.18, 0.08, 0.05);
	b.add('mustache', M.black, new THREE.BoxGeometry(0.16, 0.015, 0.02), { pos: V(0, 1.25, 0.2) });
	b.add('hair', mat('volumen_hair', 0x1a1410), ellipsoid(0.205, 0.1, 0.2, 10, 5), { pos: V(0, 1.44, -0.01) });
	const phones = mat('volumen_headphones', 0xd83020);
	b.add('headphones', phones, new THREE.TorusGeometry(0.21, 0.02, 4, 14, Math.PI), { pos: V(0, 1.36, 0) });
	for (const s of [-1, 1]) {
		b.add('headphones', phones, new THREE.CylinderGeometry(0.07, 0.07, 0.06, 10), { pos: V(s * 0.21, 1.34, 0), rot: [0, 0, Math.PI / 2] });
	}
	return b.build();
}

export const models = {
	radio_console: buildRadioConsole, record_player: buildRecordPlayer, record_shelf: buildRecordShelf,
	radio_antenna: buildRadioAntenna, npc_don_volumen: buildDonVolumen,
};

export const views = {
	radio_station: {
		items: [
			{ name: 'radio_console', pos: [-1.2, 0, 0.6] }, { name: 'record_player', pos: [0.6, 0, 1.0], rotY: -0.4 },
			{ name: 'record_shelf', pos: [0, 0, -0.8] }, { name: 'radio_antenna', pos: [2.4, 0, -1.4] },
			{ name: 'npc_don_volumen', pos: [1.2, 0, 1.6], rotY: -0.3 },
		],
		cam: { pos: [0, 2.6, 6.5], target: [0.3, 1.4, 0], fov: 50 },
	},
};
