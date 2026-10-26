// The thieves' school "Academia Manos Ligeras" (docs/diseno/infiltracion-escuela.md, step 4): the evidence's props.
// Placeholder.
import { Builder, mat, V, THREE } from '../lib.js';

const ink = mat('school_ink', 0x2a2a3a), red = mat('school_red', 0xc8202a), wood = mat('school_trunk_wood', 0x6a4022);
const iron = mat('school_iron', 0x3a3a40);

function box(b, part, m, sx, sy, sz, x, y, z, rot) {
	b.add(part, m, new THREE.BoxGeometry(sx, sy, sz), { pos: V(x, y, z), rot });
}

// The Profesora's "homework": a 0.24 x 0.32 m green folder with the list of houses to rob sticking out, a red A+ on
// the cover. Its origin at its middle (it's grabbed).
export function buildHomework() {
	const b = new Builder('school_homework');
	box(b, 'folder', mat('school_folder', 0x2e8a4a), 0.24, 0.02, 0.32, 0, 0, 0);
	box(b, 'sheets', mat('school_paper', 0xf4efd8), 0.22, 0.012, 0.3, 0.03, 0.016, -0.03, [0, 0.12, 0]);
	for (let i = 0; i < 6; i++) box(b, 'ink', ink, 0.12, 0.002, 0.01, 0.06, 0.024, -0.14 + i * 0.035, [0, 0.12, 0]);
	for (let i = 0; i < 6; i += 2) box(b, 'houses', red, 0.03, 0.003, 0.03, -0.03, 0.025, -0.13 + i * 0.035, [0, 0.12, 0]);
	box(b, 'grade', red, 0.06, 0.004, 0.012, -0.06, 0.012, 0.1);
	box(b, 'grade', red, 0.012, 0.004, 0.06, -0.06, 0.012, 0.1);
	return b.build();
}

// The practice trunk in the yard, open, where the "practice" loot is (step 4): 1 x 0.5 x 0.6 m with iron bands and
// its lid up against the back (-Z). Its origin on the floor.
export function buildTrunk() {
	const b = new Builder('school_trunk');
	box(b, 'bottom', wood, 1.0, 0.06, 0.6, 0, 0.03, 0);
	for (const s of [-1, 1]) {
		box(b, 'sides', wood, 1.0, 0.5, 0.05, 0, 0.25, s * 0.275);
		box(b, 'sides', wood, 0.05, 0.5, 0.6, s * 0.475, 0.25, 0);
		box(b, 'bands', iron, 0.06, 0.52, 0.62, s * 0.3, 0.26, 0);
	}
	box(b, 'lid', wood, 1.0, 0.6, 0.05, 0, 0.8, -0.32, [-0.15, 0, 0]);
	box(b, 'lock', mat('school_brass', 0xd0a030), 0.1, 0.12, 0.03, 0, 0.42, 0.31);
	box(b, 'coins', mat('school_gold', 0xe8c040, { emissive: 0x302000 }), 0.88, 0.04, 0.48, 0, 0.36, 0);
	return b.build();
}

export const models = { school_homework: buildHomework, school_trunk: buildTrunk };

export const views = {
	school_evidence: {
		items: [
			{ name: 'school_homework', pos: [-0.8, 0.02, 0.3], rotY: 0.4 },
			{ name: 'school_trunk', pos: [0.5, 0, 0], rotY: -0.3 },
		],
		cam: { pos: [0, 1.4, 2.4], target: [0, 0.3, 0], fov: 45 },
	},
};
