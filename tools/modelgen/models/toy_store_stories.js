// The evidence of the toy store's stories (docs/diseno/allanamiento-jugueteria.md, "Las historias"), centered on their
// collision boxes in scenes/props/*.tscn. Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// The box of fake "Barbi" dolls: a 0.5 x 0.36 x 0.34 m pink carton with a clear window, six dolls inside and a crooked
// yellow label.
export function buildFakeDollBox() {
	const b = new Builder('fake_doll_box');
	const pink = mat('box_pink', 0xf070b0);
	b.add('box', pink, new THREE.BoxGeometry(0.5, 0.36, 0.3));
	b.add('window', mat('box_window', 0xd8eef8, { transparent: true, opacity: 0.3 }), new THREE.BoxGeometry(0.4, 0.22, 0.01), { pos: V(0, -0.02, 0.19) });
	for (let i = 0; i < 6; i++) {
		const x = -0.16 + i * 0.065;
		b.add('dolls', mat('doll_skin', 0xf0c8a0), new THREE.CylinderGeometry(0.018, 0.022, 0.13, 6), { pos: V(x, -0.05, 0.17) });
		b.add('hair', mat('doll_hair', 0xf2d030), new THREE.SphereGeometry(0.024, 6, 4), { pos: V(x, 0.03, 0.17) });
	}
	b.add('label', mat('label_yellow', 0xf2e040), new THREE.BoxGeometry(0.3, 0.06, 0.01), { pos: V(0, 0.14, 0.152), rot: [0, 0, 0.08] });
	return b.build();
}

// The "ORIGINAL" rubber stamp: a 0.1 x 0.12 x 0.08 m wooden handle on a red rubber base.
export function buildOriginalStamp() {
	const b = new Builder('original_stamp');
	b.add('base', mat('stamp_wood', 0x8a6040), new THREE.BoxGeometry(0.1, 0.03, 0.08), { pos: V(0, -0.035, 0) });
	b.add('rubber', mat('stamp_red', 0xe02020), new THREE.BoxGeometry(0.09, 0.012, 0.07), { pos: V(0, -0.055, 0) });
	b.add('handle', mat('stamp_handle', 0x5a3a20), new THREE.CylinderGeometry(0.018, 0.024, 0.07, 8), { pos: V(0, 0.01, 0) });
	b.add('knob', mat('stamp_knob', 0x2a2a30), new THREE.SphereGeometry(0.028, 8, 6), { pos: V(0, 0.05, 0) });
	return b.build();
}

// The doll factory's invoice: a 0.22 x 0.02 x 0.3 m folded sheet with lines and a red stamp.
export function buildDollInvoice() {
	const b = new Builder('doll_invoice');
	b.add('paper', mat('invoice_paper', 0xf6f2e6), new THREE.BoxGeometry(0.22, 0.02, 0.3));
	for (let i = 0; i < 6; i++) b.add('lines', mat('invoice_ink', 0x3a3a48), new THREE.BoxGeometry(0.16, 0.022, 0.008), { pos: V(-0.01, 0, -0.1 + i * 0.03) });
	b.add('stamp', mat('invoice_stamp', 0xe02020), new THREE.CylinderGeometry(0.03, 0.03, 0.023, 10), { pos: V(0.06, 0, 0.1) });
	return b.build();
}

export const models = {
	fake_doll_box: buildFakeDollBox, original_stamp: buildOriginalStamp, doll_invoice: buildDollInvoice,
};

export const views = {
	toy_store_stories: {
		items: [
			{ name: 'fake_doll_box', pos: [-0.4, 0.18, 0] }, { name: 'original_stamp', pos: [0.15, 0.06, 0.05] },
			{ name: 'doll_invoice', pos: [0.5, 0.01, 0.05] },
		],
		cam: { pos: [0, 0.8, 1.5], target: [0, 0.1, 0], fov: 45 },
	},
};
