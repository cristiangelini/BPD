// The crowded car traffic control (docs/diseno/control-auto-lleno.md): a face squashed against a car window and a hand
// pressed flat beside it, what you see from the sidewalk in a packed car. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';

// Faces +Z (out of the window), origin where it touches the glass. The 'skin' part is white so the game tints it per
// passenger; the 'features' (eyes, squashed nose, open mouth) stay dark. Hand: part 'hand', also tinted.
export function buildCrowdFace() {
	const b = new Builder('crowd_face');
	const skin = mat('crowd_skin', 0xf2f2ee), dark = mat('crowd_features', 0x2a1a18), mouth = mat('crowd_mouth', 0x8a2a2a);
	const hair = mat('crowd_hair', 0x3a2a1e);
	b.add('skin', skin, ellipsoid(0.13, 0.15, 0.06), { pos: V(0, 0, -0.06) });
	// Cheeks bulging out sideways and the nose flattened on the glass.
	for (const x of [-1, 1]) b.add('skin', skin, ellipsoid(0.06, 0.05, 0.02, 8, 5), { pos: V(x * 0.08, -0.04, -0.01) });
	b.add('skin', skin, ellipsoid(0.05, 0.03, 0.012, 8, 5), { pos: V(0, -0.005, -0.005) });
	for (const x of [-1, 1]) b.add('features', dark, new THREE.BoxGeometry(0.045, 0.012, 0.01), { pos: V(x * 0.05, 0.05, -0.01), rot: [0, 0, x * 0.25] });
	b.add('features', mouth, ellipsoid(0.04, 0.025, 0.01, 8, 5), { pos: V(0, -0.075, -0.008) });
	b.add('hair', hair, ellipsoid(0.14, 0.07, 0.07, 10, 5), { pos: V(0, 0.12, -0.08) });
	// The hand pressed flat on the glass, up and to the side: palm and four fingers.
	b.add('hand', skin, ellipsoid(0.055, 0.06, 0.012, 8, 5), { pos: V(0.2, 0.05, -0.012) });
	for (let i = 0; i < 4; i++) {
		const finger = new THREE.CapsuleGeometry(0.012, 0.05, 2, 5);
		b.add('hand', skin, finger, { pos: V(0.17 + i * 0.022, 0.14, -0.012), rot: [0, 0, (1.5 - i) * 0.12] });
	}
	return b.build();
}

export const models = { crowd_face: buildCrowdFace };

export const views = {
	crowd_face: {
		items: [{ name: 'crowd_face', pos: [0, 0, 0] }],
		cam: { pos: [0.3, 0.1, 1.0], target: [0.05, 0, 0], fov: 35 },
	},
};
