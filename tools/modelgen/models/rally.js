// The politician's rally (docs/diseno/proteccion-politico.md): what the hecklers throw and the splats it leaves.
// Placeholder.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// An egg (step 2): a white oval a bit pointier on top, 6 cm across.
export function buildEgg() {
	const shell = mat('egg_shell', 0xf4ecd8);
	const b = new Builder('rally_egg');
	b.add('egg', shell, ellipsoid(0.028, 0.034, 0.028, 9, 7), { pos: V(0, 0, 0) });
	b.add('egg', shell, ellipsoid(0.022, 0.02, 0.022, 9, 5), { pos: V(0, 0.022, 0) });
	return b.build();
}

// A tomato (step 2): a squashed red ball with a green star of leaves on top, 7 cm across.
export function buildTomato() {
	const red = mat('tomato_red', 0xd8302a), green = mat('tomato_leaf', 0x3f8a32);
	const b = new Builder('rally_tomato');
	b.add('tomato', red, ellipsoid(0.036, 0.03, 0.036, 10, 7), { pos: V(0, 0, 0) });
	for (let i = 0; i < 5; i++) {
		const a = (i / 5) * Math.PI * 2;
		b.add('tomato', green, new THREE.BoxGeometry(0.022, 0.004, 0.008),
			{ pos: V(Math.cos(a) * 0.01, 0.029, Math.sin(a) * 0.01), rot: [0, -a, 0] });
	}
	b.add('tomato', green, new THREE.CylinderGeometry(0.003, 0.003, 0.012, 5), { pos: V(0, 0.035, 0) });
	return b.build();
}

// A splat (step 2): a flat blob with drops around it, lying on +Y; `yolk` adds the egg's yellow middle.
function buildSplat(name, color, yolk) {
	const goo = mat(`${name}_goo`, color);
	const b = new Builder(name);
	b.add('splat', goo, new THREE.CylinderGeometry(0.09, 0.1, 0.006, 9), { pos: V(0, 0.003, 0) });
	for (let i = 0; i < 6; i++) {
		const a = (i / 6) * Math.PI * 2 + 0.4, r = 0.13 + 0.03 * (i % 2);
		b.add('splat', goo, new THREE.CylinderGeometry(0.02 + 0.01 * (i % 3), 0.025, 0.005, 6),
			{ pos: V(Math.cos(a) * r, 0.003, Math.sin(a) * r) });
	}
	if (yolk) {
		b.add('splat', mat('egg_yolk', 0xf2b81e), new THREE.CylinderGeometry(0.035, 0.035, 0.01, 9), { pos: V(0.01, 0.006, -0.01) });
	}
	return b.build();
}

// A market bag (step 4): a striped woven bag with two handles, hung from the hand by its origin (the handles' top).
// `eggs` fills it with an egg carton and tomatoes (a heckler's); without it, bread and a leek (an innocent's).
// Both bags look the same from afar: only what pokes out gives the heckler away.
function buildMarketBag(name, eggs) {
	const weave = mat('bag_weave', 0x3f7f5a), stripe = mat('bag_stripe', 0xf0e6cc);
	const b = new Builder(name);
	b.add('bag', weave, new THREE.CylinderGeometry(0.13, 0.11, 0.26, 8), { pos: V(0, -0.27, 0) });
	b.add('bag', stripe, new THREE.CylinderGeometry(0.132, 0.128, 0.04, 8), { pos: V(0, -0.2, 0) });
	for (const s of [-1, 1]) {
		b.add('bag', weave, new THREE.TorusGeometry(0.055, 0.008, 4, 8, Math.PI), { pos: V(s * 0.05, -0.14, 0), rot: [0, Math.PI / 2, 0] });
	}
	if (eggs) {
		b.add('bag', mat('egg_carton', 0xb8a888), new THREE.BoxGeometry(0.16, 0.05, 0.1), { pos: V(-0.02, -0.13, 0.02), rot: [0, 0, 0.3] });
		for (const [x, z] of [[0.06, -0.04], [-0.05, -0.05]]) {
			b.add('bag', mat('tomato_red', 0xd8302a), ellipsoid(0.036, 0.03, 0.036, 8, 5), { pos: V(x, -0.14, z) });
		}
	} else {
		b.add('bag', mat('bread', 0xd9a05b), new THREE.CylinderGeometry(0.03, 0.03, 0.24, 6), { pos: V(-0.04, -0.1, 0), rot: [0, 0, 0.35] });
		b.add('bag', mat('leek', 0x6fae4a), new THREE.CylinderGeometry(0.018, 0.02, 0.3, 5), { pos: V(0.05, -0.06, 0.02), rot: [0.2, 0, -0.2] });
	}
	return b.build();
}

// Goo on a hand (step 4): egg yolk and tomato over a fist, what gives a heckler away after a throw.
export function buildDirtyHand() {
	const yolk = mat('egg_yolk', 0xf2b81e), red = mat('tomato_goo', 0xc8221c);
	const b = new Builder('rally_dirty_hand');
	b.add('goo', yolk, ellipsoid(0.085, 0.05, 0.085, 7, 4), { pos: V(0, 0.03, 0) });
	b.add('goo', red, ellipsoid(0.05, 0.04, 0.05, 6, 4), { pos: V(0.03, 0.05, 0.03) });
	b.add('goo', yolk, ellipsoid(0.02, 0.05, 0.02, 5, 3), { pos: V(-0.03, -0.04, 0.02) });
	return b.build();
}

export const models = {
	rally_market_bag: () => buildMarketBag('rally_market_bag', true),
	rally_shopping_bag: () => buildMarketBag('rally_shopping_bag', false),
	rally_dirty_hand: buildDirtyHand,
	rally_egg: buildEgg,
	rally_tomato: buildTomato,
	splat_egg: () => buildSplat('splat_egg', 0xf6f0dc, true),
	splat_tomato: () => buildSplat('splat_tomato', 0xc8221c, false),
};

export const views = {
	rally_throwables: {
		items: [{ name: 'rally_egg', pos: [-0.1, 0.04, 0] }, { name: 'rally_tomato', pos: [0.1, 0.035, 0] },
			{ name: 'splat_egg', pos: [-0.2, 0, 0.3] }, { name: 'splat_tomato', pos: [0.2, 0, 0.3] }],
		cam: { pos: [0, 0.45, 0.75], target: [0, 0.02, 0.15], fov: 40 },
	},
	rally_bags: {
		items: [{ name: 'rally_market_bag', pos: [-0.2, 0.45, 0] }, { name: 'rally_shopping_bag', pos: [0.2, 0.45, 0] },
			{ name: 'rally_dirty_hand', pos: [0, 0.05, 0.2] }],
		cam: { pos: [0, 0.4, 1.1], target: [0, 0.2, 0], fov: 40 },
	},
};
