// The guard dog's jailbreak (fuga-perro.md): Mordisco, the station's bulldog, with the origin at his feet, facing +Z.
// Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// Mordisco: a huge, chubby bulldog (decision 72, pear body), 0.75 m tall at the head and 1 m long, with a wide jaw,
// drool, a spiked red collar and the cells' key hanging from it (part 'key', hidden once a cop takes it). His part
// 'tail' wags in the game.
export function buildGuardDog() {
	const b = new Builder('guard_dog');
	const fur = mat('bulldog_fur', 0xc89a62), light = mat('bulldog_light', 0xf2e6d0), dark = mat('bulldog_dark', 0x6a4a2c);
	const black = mat('dog_black', 0x141010), white = mat('dog_eye', 0xffffff), pink = mat('dog_tongue', 0xe8708a);
	b.add('body', fur, ellipsoid(0.3, 0.26, 0.4, 14, 10), { pos: V(0, 0.4, -0.05) });
	b.add('body', fur, ellipsoid(0.32, 0.28, 0.24, 12, 8), { pos: V(0, 0.46, 0.2) });
	b.add('body', light, ellipsoid(0.22, 0.2, 0.2, 10, 6), { pos: V(0, 0.36, 0.28) });
	for (const [x, z] of [[-0.18, 0.26], [0.18, 0.26], [-0.17, -0.28], [0.17, -0.28]]) {
		b.add('legs', fur, new THREE.CylinderGeometry(0.07, 0.08, 0.22, 8), { pos: V(x, 0.11, z) });
		b.add('legs', light, ellipsoid(0.08, 0.04, 0.1, 6, 3), { pos: V(x, 0.03, z + 0.03) });
	}
	const head = new THREE.Vector3(0, 0.6, 0.36);
	const at = (x, y, z) => V(head.x + x, head.y + y, head.z + z);
	b.add('head', fur, ellipsoid(0.22, 0.19, 0.18, 12, 8), { pos: at(0, 0.02, 0.06) });
	b.add('head', light, ellipsoid(0.2, 0.11, 0.12, 10, 6), { pos: at(0, -0.08, 0.16) });
	b.add('head', dark, ellipsoid(0.12, 0.07, 0.07, 8, 5), { pos: at(0, 0.0, 0.2) });
	b.add('head', black, ellipsoid(0.05, 0.035, 0.03, 6, 4), { pos: at(0, 0.03, 0.26) });
	b.add('head', pink, ellipsoid(0.05, 0.02, 0.05, 6, 3), { pos: at(0, -0.15, 0.22), rot: [0.3, 0, 0] });
	b.add('head', white, ellipsoid(0.08, 0.05, 0.05, 6, 3), { pos: at(0, -0.12, 0.24) });
	b.add('head', white, new THREE.ConeGeometry(0.018, 0.05, 4), { pos: at(-0.09, -0.08, 0.25), rot: [0, 0, Math.PI] });
	b.add('head', white, new THREE.ConeGeometry(0.018, 0.05, 4), { pos: at(0.09, -0.08, 0.25), rot: [0, 0, Math.PI] });
	b.add('head', mat('drool', 0xbfe4ff), new THREE.CylinderGeometry(0.01, 0.006, 0.12, 4), { pos: at(0.13, -0.22, 0.2) });
	for (const s of [-1, 1]) {
		b.add('head', white, ellipsoid(0.035, 0.035, 0.02, 6, 4), { pos: at(s * 0.09, 0.08, 0.2) });
		b.add('head', black, ellipsoid(0.02, 0.022, 0.012, 6, 4), { pos: at(s * 0.09, 0.08, 0.215) });
		b.add('head', dark, ellipsoid(0.05, 0.015, 0.02, 6, 3), { pos: at(s * 0.09, 0.13, 0.2), rot: [0, 0, s * -0.3] });
		b.add('head', dark, ellipsoid(0.07, 0.05, 0.03, 6, 4), { pos: at(s * 0.19, 0.15, 0.0), rot: [0, 0, s * 0.6] });
	}
	const red = mat('collar_leather', 0xd23a4a), steel = mat('collar_steel', 0xc8ccd2);
	b.add('collar', red, new THREE.TorusGeometry(0.21, 0.03, 5, 16), { pos: V(0, 0.52, 0.32), rot: [Math.PI / 2 - 0.5, 0, 0] });
	for (let i = 0; i < 8; i++) {
		const a = (i / 8) * Math.PI * 2;
		b.add('collar', steel, new THREE.ConeGeometry(0.015, 0.04, 4), {
			pos: V(Math.cos(a) * 0.23, 0.52 + Math.sin(a) * 0.23 * Math.sin(0.5), 0.32 + Math.sin(a) * 0.23 * Math.cos(0.5)),
			rot: [Math.PI / 2 - 0.5, 0, a - Math.PI / 2],
		});
	}
	const gold = mat('key_gold', 0xf2c84a);
	b.add('key', steel, new THREE.TorusGeometry(0.03, 0.006, 4, 10), { pos: V(0, 0.38, 0.47) });
	b.add('key', gold, new THREE.TorusGeometry(0.025, 0.01, 4, 10), { pos: V(0, 0.33, 0.48) });
	b.add('key', gold, new THREE.BoxGeometry(0.016, 0.1, 0.01), { pos: V(0, 0.26, 0.48) });
	b.add('key', gold, new THREE.BoxGeometry(0.03, 0.015, 0.01), { pos: V(0.012, 0.22, 0.48) });
	b.add('tail', fur, new THREE.CylinderGeometry(0.025, 0.04, 0.12, 6), { pos: V(0, 0.5, -0.46), rot: [-0.9, 0, 0] });
	return b.build();
}

export const models = { guard_dog: buildGuardDog };

export const views = {
	guard_dog: {
		items: [{ name: 'guard_dog', pos: [0, 0, 0], rotY: 0.6 }, { name: 'cop_1', pos: [1.0, 0, -0.3], rotY: -0.4 }],
		cam: { pos: [0.6, 1.2, 2.8], target: [0.4, 0.5, 0], fov: 40 },
	},
};
