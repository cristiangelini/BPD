// First person hands of the cops: blue sleeves and mitten hands, one GLB per player skin (Cristian picked the mittens,
// variant B, on 19/10). Built in eye space: origin at the eye, looking +Z (scripts/player/cop_hands.gd turns it to the
// camera's -Z). Placeholder, not final art.
import { Builder, ellipsoid, mat, V } from '../lib.js';
import { SKINS, M, limb } from './pear.js';

// Hand center and elbow for side s (-1 left, 1 right), relative to the eye.
const hand = (s) => V(s * 0.24, -0.26, 0.48);
const elbow = (s) => V(s * 0.32, -0.6, 0.1);

export function buildCopHands(skinIndex) {
	const skin = mat(`skin_${SKINS[skinIndex].name}`, SKINS[skinIndex].color);
	const b = new Builder(`cop_hands_${skinIndex}`);
	for (const s of [-1, 1]) {
		const h = hand(s);
		limb(b, 'arms', M.shirt, elbow(s), h.clone().add(V(0, -0.02, -0.11)), 0.05);
		b.add('hand', skin, ellipsoid(0.105, 0.068, 0.15, 8, 6), { pos: h });
		b.add('hand', skin, ellipsoid(0.045, 0.042, 0.075, 6, 4), { pos: h.clone().add(V(-s * 0.105, 0.015, -0.015)), rot: [0, s * 0.9, 0] });
	}
	return b.build();
}

export const models = Object.fromEntries([0, 1, 2, 3].map((s) => [`cop_hands_${s}`, () => buildCopHands(s)]));

const EYE = 1.35;
export const views = {
	cop_hands: {
		items: [{ name: 'cop_hands_2', pos: [0, EYE, 0] }, { name: 'cookie_tin', pos: [0.05, 0, 1.4] }],
		cam: { pos: [0, EYE, 0], target: [0, EYE - 0.05, 1], fov: 80 },
	},
};
