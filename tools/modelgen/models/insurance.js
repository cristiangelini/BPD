// Props of the insurance office "Seguros Todo Tranquilo" (docs/diseno/seguros.md): the rolling chairs, the fragile
// monitors and glass trophies, the coffee machine and the water cooler, with origins at the middle of each piece (the
// chair's and the machine's at the floor). Placeholder, not final art.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

// A rolling office chair: five legs on wheels, a gas column, a padded seat and a tall back, 1 m tall.
export function buildOfficeChair() {
	const b = new Builder('office_chair');
	const black = mat('chair_black', 0x26262b), fabric = mat('chair_fabric', 0x3a5a8a), chrome = mat('chair_chrome', 0xb8bcc4);
	for (let i = 0; i < 5; i++) {
		const a = (i / 5) * Math.PI * 2;
		b.add('legs', black, new THREE.BoxGeometry(0.3, 0.03, 0.04), { pos: V(Math.cos(a) * 0.15, 0.07, Math.sin(a) * 0.15), rot: [0, -a, 0] });
		b.add('wheels', black, ellipsoid(0.03, 0.03, 0.03, 6, 4), { pos: V(Math.cos(a) * 0.29, 0.03, Math.sin(a) * 0.29) });
	}
	b.add('column', chrome, new THREE.CylinderGeometry(0.025, 0.025, 0.35, 8), { pos: V(0, 0.25, 0) });
	b.add('seat', fabric, new THREE.BoxGeometry(0.46, 0.08, 0.44), { pos: V(0, 0.46, 0) });
	b.add('back', fabric, new THREE.BoxGeometry(0.44, 0.5, 0.07), { pos: V(0, 0.78, -0.2), rot: [-0.08, 0, 0] });
	for (const s of [-1, 1]) {
		b.add('arms', black, new THREE.BoxGeometry(0.05, 0.03, 0.3), { pos: V(s * 0.24, 0.62, 0) });
		b.add('arms', black, new THREE.BoxGeometry(0.03, 0.14, 0.03), { pos: V(s * 0.24, 0.55, 0.05) });
	}
	return b.build();
}

// A boxy office monitor: a grey case 0.42 x 0.3 m on its foot, its screen showing a blue spreadsheet.
export function buildOfficeMonitor() {
	const b = new Builder('office_monitor');
	const grey = mat('monitor_grey', 0xd2cec4);
	b.add('case', grey, new THREE.BoxGeometry(0.42, 0.3, 0.12), { pos: V(0, 0.04, 0) });
	b.add('screen', mat('monitor_screen', 0x4a7ac8), new THREE.BoxGeometry(0.36, 0.24, 0.01), { pos: V(0, 0.045, 0.061) });
	for (let i = 0; i < 4; i++) {
		b.add('cells', mat('monitor_cells', 0xe6eef8), new THREE.BoxGeometry(0.32, 0.008, 0.012), { pos: V(0, 0.12 - i * 0.05, 0.062) });
	}
	b.add('foot', grey, new THREE.BoxGeometry(0.2, 0.03, 0.14), { pos: V(0, -0.135, 0) });
	b.add('neck', grey, new THREE.BoxGeometry(0.06, 0.05, 0.05), { pos: V(0, -0.1, 0) });
	return b.build();
}

// A glass trophy for "best floor boss": a clear star on a black base, 0.25 m tall.
export function buildGlassTrophy() {
	const b = new Builder('glass_trophy');
	const glass = mat('trophy_glass', 0xbfe8f6, { transparent: true, opacity: 0.6 });
	b.add('base', mat('trophy_base', 0x1e1e22), new THREE.BoxGeometry(0.1, 0.04, 0.08), { pos: V(0, -0.105, 0) });
	b.add('plate', mat('trophy_plate', 0xd8b04a), new THREE.BoxGeometry(0.06, 0.02, 0.002), { pos: V(0, -0.105, 0.041) });
	b.add('stem', glass, new THREE.CylinderGeometry(0.015, 0.025, 0.1, 8), { pos: V(0, -0.035, 0) });
	b.add('star', glass, new THREE.OctahedronGeometry(0.07, 0), { pos: V(0, 0.06, 0), scale: [1, 1, 0.4] });
	return b.build();
}

// The office's huge coffee machine: a brown and steel cabinet 0.7 x 1.6 x 0.6 m with buttons, a slot and a cup.
export function buildCoffeeMachine() {
	const b = new Builder('coffee_machine');
	const steel = mat('coffee_steel', 0xa8acb4), brown = mat('coffee_brown', 0x6a3e24);
	b.add('cabinet', steel, new THREE.BoxGeometry(0.7, 1.6, 0.6), { pos: V(0, 0.8, 0) });
	b.add('front', brown, new THREE.BoxGeometry(0.6, 0.9, 0.02), { pos: V(0, 1.05, 0.305) });
	b.add('sign', mat('coffee_sign', 0xf2e6c8), new THREE.BoxGeometry(0.5, 0.2, 0.01), { pos: V(0, 1.38, 0.32) });
	for (let i = 0; i < 6; i++) {
		b.add('buttons', mat('coffee_buttons', 0xe8c040), new THREE.BoxGeometry(0.06, 0.04, 0.02), { pos: V(-0.1 + (i % 2) * 0.2, 1.15 - Math.floor(i / 2) * 0.1, 0.32) });
	}
	b.add('slot', mat('coffee_slot', 0x1e1e22), new THREE.BoxGeometry(0.3, 0.3, 0.1), { pos: V(0, 0.45, 0.26) });
	b.add('cup', mat('coffee_cup', 0xffffff), new THREE.CylinderGeometry(0.035, 0.03, 0.08, 8), { pos: V(0, 0.36, 0.26) });
	return b.build();
}

// A water cooler: a white stand 1 m tall with a big blue bottle upside down on top.
export function buildWaterCooler() {
	const b = new Builder('water_cooler');
	const white = mat('cooler_white', 0xf0f0ec);
	b.add('stand', white, new THREE.BoxGeometry(0.32, 0.95, 0.32), { pos: V(0, 0.475, 0) });
	b.add('taps', mat('cooler_taps', 0x3a6ad0), new THREE.BoxGeometry(0.06, 0.04, 0.04), { pos: V(-0.06, 0.8, 0.17) });
	b.add('taps', mat('cooler_hot', 0xd03a3a), new THREE.BoxGeometry(0.06, 0.04, 0.04), { pos: V(0.06, 0.8, 0.17) });
	b.add('bottle', mat('cooler_bottle', 0x8ac8f0, { transparent: true, opacity: 0.7 }), new THREE.CylinderGeometry(0.14, 0.14, 0.4, 12), { pos: V(0, 1.18, 0) });
	b.add('neck', mat('cooler_bottle', 0x8ac8f0, { transparent: true, opacity: 0.7 }), new THREE.CylinderGeometry(0.05, 0.14, 0.06, 12), { pos: V(0, 0.98, 0) });
	return b.build();
}

export const models = {
	office_chair: buildOfficeChair, office_monitor: buildOfficeMonitor, glass_trophy: buildGlassTrophy,
	coffee_machine: buildCoffeeMachine, water_cooler: buildWaterCooler,
};

export const views = {
	insurance: {
		items: [
			{ name: 'office_chair', pos: [-0.6, 0, 0] }, { name: 'office_monitor', pos: [0.05, 0.15, 0.2] },
			{ name: 'glass_trophy', pos: [0.35, 0.12, 0.3] }, { name: 'coffee_machine', pos: [0.9, 0, -0.3] },
			{ name: 'water_cooler', pos: [-1.3, 0, -0.3] },
		],
		cam: { pos: [0, 1.3, 3.0], target: [0, 0.6, 0], fov: 40 },
	},
};
