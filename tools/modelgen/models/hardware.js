// Small props of the hardware store "El Tornillo Flojo" (docs/diseno/ferreteria.md): the fragile paint cans of its
// display and the glass screw jars on its counter, with origins at the middle of each piece. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The colors of the paint cans: the lid and the label stripe match the paint inside.
const PAINTS = [0xe8473c, 0x3c7be8, 0xf2c230, 0x4cb860, 0xf4f1ea, 0x8a4cc8];

// A paint can: 0.17 m across, 0.19 m tall, tin with a colored lid, label and a wire handle.
export function buildPaintCan(i) {
	const b = new Builder(`paint_can_${i}`);
	const tin = mat('tin', 0xc8ccd2), paint = mat(`paint_${i}`, PAINTS[i]), label = mat('paint_label', 0xfaf6ee);
	b.add('can', tin, new THREE.CylinderGeometry(0.085, 0.085, 0.18, 10), { pos: V(0, -0.005, 0) });
	b.add('lid', paint, new THREE.CylinderGeometry(0.08, 0.08, 0.012, 10), { pos: V(0, 0.09, 0) });
	b.add('label', label, new THREE.CylinderGeometry(0.0865, 0.0865, 0.1, 10, 1, true, -1.1, 2.2), { pos: V(0, -0.01, 0) });
	b.add('label', paint, new THREE.CylinderGeometry(0.087, 0.087, 0.03, 10, 1, true, -1.1, 2.2), { pos: V(0, -0.01, 0) });
	b.add('handle', tin, new THREE.TorusGeometry(0.08, 0.004, 3, 10, Math.PI), { pos: V(0, 0.098, 0), rot: [-Math.PI / 2, 0, 0] });
	return b.build();
}

// A glass jar of screws: 0.1 m across, 0.15 m tall, with a red lid and screws inside.
export function buildScrewJar() {
	const b = new Builder('screw_jar');
	const glass = mat('jar_glass', 0xbfe4f2, { transparent: true, opacity: 0.45 });
	b.add('jar', glass, new THREE.CylinderGeometry(0.05, 0.05, 0.13, 8), { pos: V(0, -0.01, 0) });
	b.add('lid', mat('jar_lid', 0xd23a3a), new THREE.CylinderGeometry(0.045, 0.045, 0.02, 8), { pos: V(0, 0.065, 0) });
	const steel = mat('screw_steel', 0x9aa0a8);
	for (let i = 0; i < 9; i++) {
		const a = i * 2.4;
		b.add('screws', steel, new THREE.CylinderGeometry(0.005, 0.005, 0.04, 4),
			{ pos: V(Math.cos(a) * 0.025, -0.055 + (i % 3) * 0.012, Math.sin(a) * 0.025), rot: [i * 0.7, 0, 1.2] });
	}
	return b.build();
}

export const models = {
	...Object.fromEntries(PAINTS.map((_, i) => [`paint_can_${i}`, () => buildPaintCan(i)])),
	screw_jar: buildScrewJar,
};

export const views = {
	hardware: {
		items: [
			{ name: 'paint_can_0', pos: [-0.2, 0.095, 0] }, { name: 'paint_can_1', pos: [0, 0.095, -0.05] },
			{ name: 'paint_can_2', pos: [0.2, 0.095, 0] }, { name: 'screw_jar', pos: [0.05, 0.075, 0.2] },
		],
		cam: { pos: [0, 0.4, 0.9], target: [0, 0.08, 0], fov: 36 },
	},
};
