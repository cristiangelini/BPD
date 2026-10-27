// The evidence of the radio's stories (docs/diseno/allanamiento-radio.md, "Las historias"), centered on their collision
// boxes in scenes/props/*.tscn. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The contest's raffle urn: a 0.4 x 0.45 x 0.4 m glass cube on a wooden base, full of paper slips, with a slot on top.
export function buildRaffleUrn() {
	const b = new Builder('raffle_urn');
	const wood = mat('urn_wood', 0x7a4a26);
	b.add('base', wood, new THREE.BoxGeometry(0.4, 0.05, 0.4), { pos: V(0, -0.2, 0) });
	b.add('lid', wood, new THREE.BoxGeometry(0.4, 0.04, 0.4), { pos: V(0, 0.205, 0) });
	b.add('slot', mat('black', 0x15151a), new THREE.BoxGeometry(0.16, 0.01, 0.03), { pos: V(0, 0.226, 0) });
	b.add('glass', mat('urn_glass', 0xbfe4f2, { transparent: true, opacity: 0.35 }), new THREE.BoxGeometry(0.38, 0.36, 0.38));
	const paper = mat('slip_paper', 0xf6f0d8);
	for (let i = 0; i < 18; i++) {
		const x = ((i * 37) % 30) / 100 - 0.15, z = ((i * 53) % 30) / 100 - 0.15, y = -0.16 + (i % 4) * 0.025;
		b.add('slips', paper, new THREE.BoxGeometry(0.06, 0.004, 0.035), { pos: V(x, y, z), rot: [0, i * 0.7, 0.2] });
	}
	return b.build();
}

// The prize nobody got: a blender, 0.2 x 0.4 x 0.2 m, red base and a clear jar with a ribbon.
export function buildContestBlender() {
	const b = new Builder('contest_blender');
	b.add('base', mat('blender_red', 0xd83020), new THREE.BoxGeometry(0.2, 0.12, 0.2), { pos: V(0, -0.14, 0) });
	b.add('jar', mat('blender_jar', 0xcfe8f0, { transparent: true, opacity: 0.5 }), new THREE.CylinderGeometry(0.08, 0.06, 0.24, 10), { pos: V(0, 0.04, 0) });
	b.add('lid', mat('black', 0x15151a), new THREE.CylinderGeometry(0.085, 0.085, 0.03, 10), { pos: V(0, 0.18, 0) });
	b.add('ribbon', mat('ribbon_gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.TorusGeometry(0.05, 0.012, 4, 10), { pos: V(0, 0.2, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The winners list: a 0.21 x 0.01 x 0.3 m sheet with the same name in every row.
export function buildWinnersList() {
	const b = new Builder('winners_list');
	b.add('sheet', mat('list_paper', 0xf6f4ee), new THREE.BoxGeometry(0.21, 0.004, 0.3));
	const ink = mat('ink_blue', 0x2a3a9a);
	for (let i = 0; i < 8; i++) b.add('rows', ink, new THREE.BoxGeometry(0.12, 0.001, 0.008), { pos: V(-0.02, 0.0025, -0.12 + i * 0.033) });
	return b.build();
}

export const models = { raffle_urn: buildRaffleUrn, contest_blender: buildContestBlender, winners_list: buildWinnersList };

export const views = {
	radio_stories: {
		items: [
			{ name: 'raffle_urn', pos: [-0.5, 0.225, 0], rotY: 0.3 }, { name: 'contest_blender', pos: [0.1, 0.2, 0.1] },
			{ name: 'winners_list', pos: [0.55, 0.005, 0.15], rotY: -0.3 },
		],
		cam: { pos: [0, 1.0, 1.9], target: [0, 0.2, 0], fov: 38 },
	},
};
