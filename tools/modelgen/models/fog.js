// The fog traffic check (docs/diseno/control-neblina.md): the patrol car's foghorn. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// A hand foghorn, lying on its side: a red gas can (along Z) with a black grip on top, a brass valve at its back and
// a white trumpet whose mouth faces +Z. Origin on the ground, at the can's middle.
export function buildFogHorn() {
	const b = new Builder('fog_horn');
	const red = mat('horn_can', 0xd2342a), white = mat('horn_trumpet', 0xf2f0ea), black = mat('horn_grip', 0x1c1c20);
	const brass = mat('horn_brass', 0xc9a040, { metalness: 0.5, roughness: 0.4 });
	b.add('can', red, new THREE.CylinderGeometry(0.07, 0.07, 0.24, 14), { pos: V(0, 0.12, -0.05), rot: [Math.PI / 2, 0, 0] });
	b.add('can', brass, new THREE.CylinderGeometry(0.03, 0.03, 0.04, 10), { pos: V(0, 0.12, -0.19), rot: [Math.PI / 2, 0, 0] });
	b.add('trumpet', white, new THREE.CylinderGeometry(0.11, 0.025, 0.2, 14, 1, true), { pos: V(0, 0.12, 0.17), rot: [Math.PI / 2, 0, 0] });
	b.add('trumpet', black, new THREE.TorusGeometry(0.11, 0.008, 5, 16), { pos: V(0, 0.12, 0.27) });
	b.add('grip', black, new THREE.BoxGeometry(0.03, 0.07, 0.12), { pos: V(0, 0.22, -0.05) });
	return b.build();
}

export const models = { fog_horn: buildFogHorn };

export const views = {
	fog_horn: {
		items: [{ name: 'fog_horn', pos: [0, 0, 0] }],
		cam: { pos: [0.55, 0.4, 0.55], target: [0, 0.08, 0.02], fov: 35 },
	},
};
