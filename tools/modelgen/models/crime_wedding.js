// The wedding crime scene (docs/diseno/escena-boda.md): the three-tier wedding cake, the flower centerpieces of the
// round tables and the DJ's booth. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

function cylinder(b, part, m, r, h, x, y, z, segments = 16) {
	b.add(part, m, new THREE.CylinderGeometry(r, r, h, segments), { pos: V(x, y, z) });
}

// The three-tier wedding cake on its silver stand, origin at the bottom of the stand: white tiers ('cake'), a pink
// ribbon around each and a row of frosting pearls on each rim. 0.95 m tall; the sugar couple goes on top.
export function buildWeddingCake() {
	const b = new Builder('wedding_cake');
	const cake = mat('wedding_cake_icing', 0xfbf8f0), ribbon = mat('wedding_cake_ribbon', 0xeea8c0);
	const silver = mat('wedding_cake_stand', 0xc8ccd4, { metalness: 0.3, roughness: 0.4 });
	cylinder(b, 'stand', silver, 0.48, 0.03, 0, 0.015, 0, 24);
	cylinder(b, 'stand', silver, 0.08, 0.12, 0, 0.09, 0, 12);
	cylinder(b, 'stand', silver, 0.46, 0.02, 0, 0.16, 0, 24);
	const tiers = [[0.42, 0.28], [0.31, 0.24], [0.2, 0.22]];
	let y = 0.17;
	for (const [r, h] of tiers) {
		cylinder(b, 'cake', cake, r, h, 0, y + h / 2, 0, 24);
		cylinder(b, 'ribbon', ribbon, r + 0.005, 0.04, 0, y + 0.06, 0, 24);
		const pearls = Math.round(r * 40);
		for (let i = 0; i < pearls; i++) {
			const a = (i / pearls) * Math.PI * 2;
			b.add('cake', cake, ellipsoid(0.022, 0.022, 0.022, 6, 4), { pos: V(Math.sin(a) * r, y + h, Math.cos(a) * r) });
		}
		y += h;
	}
	return b.build();
}

// A round table's centerpiece, origin at its base: a low glass vase and a ball of roses (red, pink and white) with
// leaves. 0.4 m tall.
export function buildFlowerCenterpiece() {
	const b = new Builder('flower_centerpiece');
	const glass = mat('centerpiece_glass', 0xd8eef0, { transparent: true, opacity: 0.6 });
	const leaf = mat('centerpiece_leaf', 0x3f8a3a);
	const roses = [mat('centerpiece_red', 0xd02840), mat('centerpiece_pink', 0xf0a0b8), mat('centerpiece_white', 0xfaf6ee)];
	b.add('vase', glass, new THREE.CylinderGeometry(0.09, 0.07, 0.14, 12), { pos: V(0, 0.07, 0) });
	for (let i = 0; i < 6; i++) {
		const a = (i / 6) * Math.PI * 2;
		b.add('flowers', leaf, ellipsoid(0.08, 0.025, 0.04, 6, 4), { pos: V(Math.sin(a) * 0.12, 0.17, Math.cos(a) * 0.12), rot: [0, a, 0.3] });
	}
	const spots = [[0, 0.3, 0], [0.09, 0.24, 0.05], [-0.08, 0.25, 0.06], [0.05, 0.25, -0.09], [-0.07, 0.23, -0.06],
		[0.12, 0.19, -0.02], [-0.12, 0.19, 0.01], [0.0, 0.2, 0.12], [0.02, 0.2, -0.13]];
	spots.forEach(([x, yy, z], i) => {
		b.add('flowers', roses[i % 3], ellipsoid(0.055, 0.05, 0.055, 8, 6), { pos: V(x, yy, z) });
	});
	return b.build();
}

// The DJ's booth, faces +Z (the dance floor), origin on the floor at its middle: a black desk with a lit "DJ" panel
// ('panel', the game writes over it), two turntables and the mixer on top, and a tall speaker on each side.
export function buildDjBooth() {
	const b = new Builder('dj_booth');
	const black = mat('dj_black', 0x1c1c22), panel = mat('dj_panel', 0x8040c0), grey = mat('dj_grey', 0x50545c);
	const vinyl = mat('dj_vinyl', 0x101012), cone = mat('dj_cone', 0x30323a);
	box(b, 'desk', black, 1.6, 1.0, 0.6, 0, 0.5, 0);
	box(b, 'panel', panel, 1.0, 0.4, 0.01, 0, 0.6, 0.305);
	for (const x of [-0.5, 0.5]) {
		box(b, 'deck', grey, 0.4, 0.04, 0.4, x, 1.02, 0);
		cylinder(b, 'deck', vinyl, 0.16, 0.01, x, 1.045, 0, 20);
	}
	box(b, 'deck', grey, 0.3, 0.06, 0.3, 0, 1.03, 0);
	for (const x of [-1.05, 1.05]) {
		box(b, 'speaker', black, 0.45, 1.4, 0.45, x, 0.7, 0);
		for (const [y, r] of [[1.1, 0.1], [0.55, 0.17]]) {
			b.add('speaker', cone, new THREE.CylinderGeometry(r, r, 0.02, 16), { pos: V(x, y, 0.23), rot: [Math.PI / 2, 0, 0] });
		}
	}
	return b.build();
}

export const models = { wedding_cake: buildWeddingCake, flower_centerpiece: buildFlowerCenterpiece, dj_booth: buildDjBooth };

export const views = {
	wedding_cake: {
		items: [{ name: 'wedding_cake', pos: [0, 0, 0] }, { name: 'flower_centerpiece', pos: [0.75, 0, 0.2] }],
		cam: { pos: [1.4, 1.1, 1.8], target: [0.3, 0.45, 0], fov: 40 },
	},
	dj_booth: {
		items: [{ name: 'dj_booth', pos: [0, 0, 0] }],
		cam: { pos: [1.8, 1.8, 3.0], target: [0, 0.7, 0], fov: 40 },
	},
};
