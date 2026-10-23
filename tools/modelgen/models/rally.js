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

export const models = {
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
};
