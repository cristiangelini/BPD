// The museum figurine (historias.md): the porcelain ballerina stolen from the museum, the souvenir copies that look
// just like it, and the newspaper clipping. Centered on their collision boxes in scenes/props/*.tscn. Placeholder,
// not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

// A porcelain ballerina on tiptoe: 0.12 m wide, 0.2 m tall, on a round base. The original has the museum's gold
// seal under the base, only seen when it's turned over.
function buildBallerina(name, seal) {
	const porcelain = mat('porcelain', 0xf4f1ea), pink = mat('porcelain_pink', 0xff8fb1), blue = mat('porcelain_blue', 0x3a6fd8);
	const b = new Builder(name);
	b.add('base', blue, new THREE.CylinderGeometry(0.05, 0.055, 0.02, 12), { pos: V(0, -0.09, 0) });
	b.add('body', porcelain, new THREE.CylinderGeometry(0.008, 0.008, 0.07, 6), { pos: V(0, -0.045, 0) });
	b.add('body', pink, new THREE.ConeGeometry(0.06, 0.035, 12, 1, true), { pos: V(0, 0.0, 0), rot: [Math.PI, 0, 0] });
	b.add('body', pink, new THREE.CylinderGeometry(0.06, 0.06, 0.006, 12), { pos: V(0, -0.017, 0) });
	b.add('body', porcelain, ellipsoid(0.018, 0.035, 0.014, 8, 6), { pos: V(0, 0.03, 0) });
	b.add('body', porcelain, ellipsoid(0.016, 0.018, 0.016, 8, 6), { pos: V(0, 0.08, 0) });
	b.add('body', mat('hair_bun', 0x5a3a22), ellipsoid(0.01, 0.01, 0.01, 6, 4), { pos: V(0, 0.097, -0.006) });
	for (const side of [-1, 1]) b.add('body', porcelain, new THREE.CylinderGeometry(0.004, 0.004, 0.06, 4), { pos: V(side * 0.025, 0.065, 0), rot: [0, 0, side * 0.7] });
	if (seal) b.add('seal', mat('gold', 0xf2c84b, { emissive: 0x3a2a05 }), new THREE.CylinderGeometry(0.025, 0.025, 0.003, 10), { pos: V(0, -0.1015, 0) });
	return b.build();
}

// The newspaper clipping: a 0.14 x 0.18 m piece of newsprint with a headline, columns and the ballerina's photo.
export function buildNewsClipping() {
	const b = new Builder('news_clipping');
	b.add('paper', mat('newsprint', 0xe8e2cc), new THREE.BoxGeometry(0.14, 0.004, 0.18));
	b.add('ink', mat('news_ink', 0x2a2a30), new THREE.BoxGeometry(0.11, 0.002, 0.014), { pos: V(0, 0.003, -0.07) });
	b.add('photo', mat('news_photo', 0x8a8a90), new THREE.BoxGeometry(0.05, 0.002, 0.06), { pos: V(-0.035, 0.003, 0.0) });
	b.add('photo', mat('porcelain_pink', 0xff8fb1), new THREE.CylinderGeometry(0.012, 0.012, 0.002, 8), { pos: V(-0.035, 0.0045, 0.0) });
	for (let i = 0; i < 5; i++) b.add('ink', mat('news_ink', 0x2a2a30), new THREE.BoxGeometry(0.045, 0.002, 0.005), { pos: V(0.035, 0.003, -0.025 + i * 0.013) });
	for (let i = 0; i < 3; i++) b.add('ink', mat('news_ink', 0x2a2a30), new THREE.BoxGeometry(0.11, 0.002, 0.005), { pos: V(0, 0.003, 0.045 + i * 0.013) });
	return b.build();
}

export const models = {
	museum_ballerina: () => buildBallerina('museum_ballerina', true),
	ornament_ballerina: () => buildBallerina('ornament_ballerina', false),
	news_clipping: buildNewsClipping,
};

export const views = {
	museum: {
		items: [
			{ name: 'museum_ballerina', pos: [-0.12, 0.1, 0], rotY: 0.3 }, { name: 'ornament_ballerina', pos: [0.12, 0.1, -0.05], rotY: -0.3 },
			{ name: 'news_clipping', pos: [0.0, 0.01, 0.25], rotY: 0.15 },
		],
		cam: { pos: [0, 0.45, 0.85], target: [0, 0.07, 0.05], fov: 34 },
	},
};
