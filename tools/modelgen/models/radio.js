// The grandpa's pirate radio (historias.md): the transmitter and the radio soap opera tapes. Centered on their
// collision boxes in scenes/props/*.tscn. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The transmitter: a 0.7 x 0.5 x 0.45 m metal cabinet with dials, a needle gauge, a red light and an antenna.
export function buildTransmitter() {
	const b = new Builder('radio_transmitter');
	const metal = mat('transmitter', 0x5a6a5a), dark = mat('transmitter_dark', 0x2a2e2a), brass = mat('brass', 0xd8b048, { emissive: 0x2a2005 });
	b.add('cabinet', metal, new THREE.BoxGeometry(0.7, 0.5, 0.45));
	b.add('cabinet', dark, new THREE.BoxGeometry(0.62, 0.3, 0.01), { pos: V(0, 0.03, 0.226) });
	for (const x of [-0.2, -0.05, 0.1]) b.add('dials', brass, new THREE.CylinderGeometry(0.035, 0.035, 0.03, 10), { pos: V(x, -0.03, 0.24), rot: [Math.PI / 2, 0, 0] });
	b.add('gauge', mat('gauge', 0xf4efd8), new THREE.BoxGeometry(0.14, 0.08, 0.01), { pos: V(0.2, 0.08, 0.232) });
	b.add('gauge', mat('needle', 0xd82020), new THREE.BoxGeometry(0.004, 0.06, 0.004), { pos: V(0.2, 0.08, 0.238), rot: [0, 0, 0.5] });
	b.add('light', mat('on_air', 0xff3020, { emissive: 0x801008 }), new THREE.SphereGeometry(0.02, 6, 4), { pos: V(-0.25, 0.14, 0.23) });
	b.add('antenna', dark, new THREE.CylinderGeometry(0.006, 0.008, 0.5, 6), { pos: V(0.28, 0.5, -0.1) });
	b.add('antenna', mat('on_air', 0xff3020, { emissive: 0x801008 }), new THREE.SphereGeometry(0.015, 6, 4), { pos: V(0.28, 0.75, -0.1) });
	return b.build();
}

// A cassette tape of a radio soap opera: 0.1 x 0.017 x 0.065 m, lying flat, with a pink label.
export function buildTape() {
	const b = new Builder('radio_tape');
	b.add('tape', mat('tape_shell', 0x2a2a30), new THREE.BoxGeometry(0.1, 0.017, 0.065));
	b.add('label', mat('tape_label', 0xff8fb1), new THREE.BoxGeometry(0.08, 0.002, 0.035), { pos: V(0, 0.0095, -0.008) });
	for (const x of [-0.022, 0.022]) b.add('reels', mat('tape_reel', 0xf4efd8), new THREE.CylinderGeometry(0.009, 0.009, 0.003, 8), { pos: V(x, 0.0105, -0.008) });
	return b.build();
}

export const models = { radio_transmitter: buildTransmitter, radio_tape: buildTape };

export const views = {
	radio: {
		items: [{ name: 'radio_transmitter', pos: [-0.15, 0.25, 0], rotY: 0.3 }, { name: 'radio_tape', pos: [0.4, 0.01, 0.3], rotY: -0.3 }],
		cam: { pos: [0, 1.0, 1.7], target: [0, 0.25, 0.05], fov: 38 },
	},
};
