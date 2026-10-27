// The station's evidence room (docs/diseno/escena-comisaria.md, step 1): the metal shelves with the boxes of old
// cases, the shelf with the empty spot where the stolen evidence was, the lectern with the sign-out book and the
// table with the VCR that the ceiling camera records on. Origins on the floor at the middle of each piece, front to
// +Z. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

const steel = mat('evidence_steel', 0x5a5f68), cardboard = mat('evidence_box', 0xb8925a);
const label = mat('evidence_label', 0xf4efd8), red = mat('evidence_red', 0xc83020);
const wood = mat('lectern_wood', 0x7a4a28), black = mat('vcr_black', 0x222226);

// A shelf: 2.4 x 2.2 x 0.6 m, four levels of cardboard boxes with a label each; `gap` leaves the middle of the second
// level empty, with the clean square in the dust where the stolen evidence stood and a red "EVIDENCIA" tape.
function shelf(name, gap) {
	const b = new Builder(name);
	for (const x of [-1.17, 1.17]) for (const z of [-0.27, 0.27]) b.add('frame', steel, new THREE.BoxGeometry(0.05, 2.2, 0.05), { pos: V(x, 1.1, z) });
	const levels = [0.15, 0.7, 1.25, 1.8];
	for (const y of levels) b.add('shelves', steel, new THREE.BoxGeometry(2.36, 0.04, 0.58), { pos: V(0, y, 0) });
	levels.forEach((y, row) => {
		for (let i = 0; i < 4; i++) {
			if (gap && row === 1 && (i === 1 || i === 2)) continue;
			const x = -0.84 + i * 0.56, h = 0.32 + ((row * 3 + i) % 3) * 0.06;
			b.add('boxes', cardboard, new THREE.BoxGeometry(0.48, h, 0.46), { pos: V(x, y + 0.02 + h / 2, 0.02), rot: [0, ((row + i) % 2) * 0.06, 0] });
			b.add('labels', label, new THREE.BoxGeometry(0.2, 0.08, 0.01), { pos: V(x, y + 0.02 + h / 2, 0.255) });
		}
	});
	if (gap) {
		b.add('dust', mat('evidence_dust', 0x8a8478), new THREE.BoxGeometry(1.0, 0.004, 0.5), { pos: V(0, 0.722, 0) });
		b.add('clean', mat('evidence_clean', 0x8e949e), new THREE.BoxGeometry(0.5, 0.006, 0.34), { pos: V(0, 0.724, 0) });
		b.add('tape', red, new THREE.BoxGeometry(1.1, 0.06, 0.01), { pos: V(0, 0.95, 0.3), rot: [0, 0, 0.08] });
	}
	return b.build();
}

export function buildEvidenceShelf() {
	return shelf('evidence_shelf', false);
}

export function buildEvidenceShelfGap() {
	return shelf('evidence_shelf_gap', true);
}

// The lectern with the sign-out book: 0.6 x 1.2 x 0.5 m, the book open on the slanted top with a pen on a string.
export function buildSignOutLectern() {
	const b = new Builder('sign_out_lectern');
	b.add('stand', wood, new THREE.BoxGeometry(0.5, 1.05, 0.36), { pos: V(0, 0.525, 0) });
	b.add('stand', wood, new THREE.BoxGeometry(0.6, 0.04, 0.5), { pos: V(0, 1.1, 0.02), rot: [0.3, 0, 0] });
	b.add('book', label, new THREE.BoxGeometry(0.46, 0.03, 0.34), { pos: V(0, 1.14, 0.03), rot: [0.3, 0, 0] });
	b.add('book', mat('book_spine', 0x2a4a8a), new THREE.BoxGeometry(0.02, 0.035, 0.34), { pos: V(0, 1.145, 0.03), rot: [0.3, 0, 0] });
	for (let i = 0; i < 6; i++) b.add('lines', mat('book_ink', 0x3a3a48), new THREE.BoxGeometry(0.18, 0.002, 0.008), { pos: V(-0.12, 1.158 - i * 0.012, -0.08 + i * 0.04), rot: [0.3, 0, 0] });
	b.add('pen', black, new THREE.CylinderGeometry(0.008, 0.008, 0.14, 6), { pos: V(0.15, 1.17, 0.06), rot: [0, 0, Math.PI / 2] });
	return b.build();
}

// The VCR table: 0.8 x 0.9 x 0.5 m, a VCR with a tape half in and a blinking red "REC" light, under a small monitor.
export function buildVcrTable() {
	const b = new Builder('vcr_table');
	b.add('table', steel, new THREE.BoxGeometry(0.8, 0.04, 0.5), { pos: V(0, 0.7, 0) });
	for (const x of [-0.36, 0.36]) for (const z of [-0.21, 0.21]) b.add('legs', steel, new THREE.BoxGeometry(0.04, 0.7, 0.04), { pos: V(x, 0.35, z) });
	b.add('vcr', black, new THREE.BoxGeometry(0.44, 0.1, 0.32), { pos: V(0, 0.77, 0.04) });
	b.add('tape', mat('vhs_tape', 0x111114), new THREE.BoxGeometry(0.19, 0.025, 0.06), { pos: V(-0.06, 0.78, 0.21) });
	b.add('rec', mat('vcr_rec', 0xff2010, { emissive: 0xc01008 }), new THREE.SphereGeometry(0.012, 6, 4), { pos: V(0.16, 0.79, 0.205) });
	b.add('monitor', mat('monitor_case', 0xc8c4b8), new THREE.BoxGeometry(0.36, 0.3, 0.3), { pos: V(0, 0.97, -0.04) });
	b.add('screen', mat('monitor_glass', 0x2a3a34, { emissive: 0x0a1a12 }), new THREE.BoxGeometry(0.28, 0.22, 0.01), { pos: V(0, 0.97, 0.115) });
	return b.build();
}

export const models = {
	evidence_shelf: buildEvidenceShelf, evidence_shelf_gap: buildEvidenceShelfGap, sign_out_lectern: buildSignOutLectern,
	vcr_table: buildVcrTable,
};

export const views = {
	evidence_room: {
		items: [
			{ name: 'evidence_shelf', pos: [-1.3, 0, -1.2] },
			{ name: 'evidence_shelf_gap', pos: [1.3, 0, -1.2] },
			{ name: 'sign_out_lectern', pos: [-1.0, 0, 1.0], rotY: 0.5 },
			{ name: 'vcr_table', pos: [1.2, 0, 1.0], rotY: -0.4 },
		],
		cam: { pos: [0, 2.4, 5.0], target: [0, 0.9, -0.4], fov: 50 },
	},
};
