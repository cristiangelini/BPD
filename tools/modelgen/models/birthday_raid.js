// The birthday party raid (allanamiento-cumple.md, decision 340): the three-tier cake with its 7 candles, the piñata,
// the bouncy castle, a gift box and Chispita's case of tricks. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);
const white = M.white;
const PASTEL = [0xff7ab8, 0x7ad0ff, 0xfff07a, 0x9ae07a];

export const models = {
	// The cake: three round tiers, pink icing with white drips, sprinkles, and 7 candles on top (flames apart, the game
	// lights them).
	birthday_cake() {
		const b = new Builder('birthday_cake');
		const sponge = C('cake_icing', 0xff9ac8), drip = C('cake_drip', 0xfff6f0), plate = C('cake_plate', 0xf0f0f4);
		b.add('plate', plate, new THREE.CylinderGeometry(0.34, 0.34, 0.02, 20), { pos: V(0, 0.01, 0) });
		let y = 0.02;
		for (const [r, h] of [[0.3, 0.16], [0.22, 0.14], [0.14, 0.12]]) {
			b.add('tiers', sponge, new THREE.CylinderGeometry(r, r, h, 20), { pos: V(0, y + h / 2, 0) });
			b.add('tiers', drip, new THREE.CylinderGeometry(r + 0.008, r + 0.008, 0.03, 20), { pos: V(0, y + h - 0.015, 0) });
			for (let i = 0; i < 8; i++) {
				const a = (i / 8) * Math.PI * 2;
				b.add('tiers', C(`sprinkle_${i % 4}`, PASTEL[i % 4]), new THREE.BoxGeometry(0.03, 0.01, 0.01), { pos: V(Math.cos(a) * (r + 0.005), y + h * 0.4, Math.sin(a) * (r + 0.005)), rot: [0, -a, 0.5] });
			}
			y += h;
		}
		for (let i = 0; i < 7; i++) {
			const a = (i / 7) * Math.PI * 2;
			b.add('candles', C(`candle_${i % 4}`, PASTEL[i % 4]), new THREE.CylinderGeometry(0.008, 0.008, 0.08, 6), { pos: V(Math.cos(a) * 0.08, y + 0.04, Math.sin(a) * 0.08) });
			b.add('flames', C('flame', 0xffb020, { emissive: 0xff8000 }), ellipsoid(0.012, 0.022, 0.012, 5, 4), { pos: V(Math.cos(a) * 0.08, y + 0.1, Math.sin(a) * 0.08) });
		}
		return b.build();
	},
	// The piñata: a fat paper star with five colored points and paper fringes, hanging from its rope.
	birthday_pinata() {
		const b = new Builder('birthday_pinata');
		b.add('body', C('pinata_body', 0xf6d23a), ellipsoid(0.22, 0.22, 0.22, 10, 7), { pos: V(0, 0, 0) });
		const points = [V(0, 1, 0), V(0.95, 0.31, 0), V(0.59, -0.81, 0), V(-0.59, -0.81, 0), V(-0.95, 0.31, 0)];
		points.forEach((d, i) => {
			const cone = new THREE.ConeGeometry(0.08, 0.3, 8);
			b.add('points', C(`pinata_point_${i % 4}`, PASTEL[i % 4]), cone, { pos: V(d.x * 0.3, d.y * 0.3, 0), lookAt: d });
			b.add('fringes', C(`fringe_${i % 4}`, PASTEL[(i + 1) % 4]), new THREE.BoxGeometry(0.02, 0.12, 0.01), { pos: V(d.x * 0.45, d.y * 0.45 - 0.08, 0) });
		});
		b.add('rope', C('pinata_rope', 0xc8a870), new THREE.CylinderGeometry(0.008, 0.008, 0.6, 4), { pos: V(0, 0.55, 0) });
		return b.build();
	},
	// The bouncy castle: a 4 x 4 m inflated floor with puffy walls and four towers with pointed tops.
	bouncy_castle() {
		const b = new Builder('bouncy_castle');
		const red = C('castle_red', 0xe0262e), blue = C('castle_blue', 0x2a6ad8), yellow = C('castle_yellow', 0xf6d23a);
		b.add('floor', blue, new THREE.BoxGeometry(4.0, 0.4, 4.0), { pos: V(0, 0.2, 0) });
		for (const [x, z, w, d] of [[0, -1.85, 4.0, 0.3], [-1.85, 0, 0.3, 4.0], [1.85, 0, 0.3, 4.0]]) {
			b.add('walls', red, new THREE.BoxGeometry(w, 1.2, d), { pos: V(x, 1.0, z) });
			b.add('walls', yellow, new THREE.BoxGeometry(w + 0.04, 0.12, d + 0.04), { pos: V(x, 1.6, z) });
		}
		for (const sx of [-1, 1]) for (const sz of [-1, 1]) {
			b.add('towers', yellow, new THREE.CylinderGeometry(0.3, 0.3, 2.0, 12), { pos: V(sx * 1.85, 1.0, sz * 1.85) });
			b.add('towers', red, new THREE.ConeGeometry(0.34, 0.5, 12), { pos: V(sx * 1.85, 2.25, sz * 1.85) });
		}
		return b.build();
	},
	// A gift box wrapped in colored paper with a ribbon cross and a bow on top.
	gift_box() {
		const b = new Builder('gift_box');
		const paper = C('gift_paper', 0x7ad0ff), ribbon = C('gift_ribbon', 0xe0262e);
		b.add('box', paper, new THREE.BoxGeometry(0.3, 0.22, 0.3), { pos: V(0, 0.11, 0) });
		b.add('ribbon', ribbon, new THREE.BoxGeometry(0.31, 0.225, 0.04), { pos: V(0, 0.11, 0) });
		b.add('ribbon', ribbon, new THREE.BoxGeometry(0.04, 0.225, 0.31), { pos: V(0, 0.11, 0) });
		for (const s of [-1, 1]) b.add('ribbon', ribbon, ellipsoid(0.05, 0.03, 0.025, 6, 4), { pos: V(s * 0.04, 0.24, 0), rot: [0, 0, s * 0.5] });
		return b.build();
	},
	// Chispita's case of tricks: a small striped suitcase with a big star on the lid and a brass clasp (the office key
	// is inside).
	chispita_case() {
		const b = new Builder('chispita_case');
		const purple = C('case_purple', 0x8a3ac8), stripe = C('case_stripe', 0xf6d23a);
		b.add('case', purple, new THREE.BoxGeometry(0.5, 0.3, 0.16), { pos: V(0, 0.15, 0) });
		for (const x of [-0.15, 0, 0.15]) b.add('case', stripe, new THREE.BoxGeometry(0.04, 0.302, 0.162), { pos: V(x, 0.15, 0) });
		b.add('handle', C('case_handle', 0x2a2a30), new THREE.TorusGeometry(0.06, 0.012, 4, 10, Math.PI), { pos: V(0, 0.3, 0) });
		b.add('clasp', C('case_brass', 0xd8a83a, { metalness: 0.5 }), new THREE.BoxGeometry(0.05, 0.04, 0.02), { pos: V(0, 0.27, 0.085) });
		b.add('star', white, new THREE.CylinderGeometry(0.06, 0.06, 0.01, 5), { pos: V(0.17, 0.2, 0.085), rot: [Math.PI / 2, 0, 0] });
		return b.build();
	},
	// The diamond balloons (los globos de diamantes): a bunch of five balloons that hang down from their knot instead of
	// floating, heavy with the stones inside, and a few diamonds showing through the thin rubber.
	diamond_balloons() {
		const b = new Builder('diamond_balloons');
		const knot = C('diamond_knot', 0xd8d8d8), stone = C('diamond_stone', 0xd8f4ff, { emissive: 0x284858, metalness: 0.3 });
		b.add('weight', C('diamond_weight', 0x9a9aa4, { metalness: 0.5 }), new THREE.CylinderGeometry(0.05, 0.06, 0.06, 8), { pos: V(0, 0.03, 0) });
		const ends = [V(0, 0.11, 0.17), V(0.16, 0.12, 0.05), V(0.1, 0.1, -0.15), V(-0.11, 0.11, -0.13), V(-0.16, 0.12, 0.07)];
		ends.forEach((at, i) => {
			const mid = V(at.x / 2, 0.08, at.z / 2);
			b.add('strings', knot, new THREE.CylinderGeometry(0.004, 0.004, mid.length() * 2, 4), { pos: mid, lookAt: V(at.x, at.y - 0.06, at.z) });
			b.add('balloons', C(`diamond_balloon_${i % 4}`, PASTEL[i % 4]), ellipsoid(0.1, 0.12, 0.1, 10, 7), { pos: V(at.x * 1.2, at.y, at.z * 1.2) });
			b.add('stones', stone, new THREE.OctahedronGeometry(0.025), { pos: V(at.x * 1.2 + 0.03, at.y + 0.03, at.z * 1.2 + 0.07) });
		});
		return b.build();
	},
	// The trick pump: a balloon pump on its stand with a double bottom that slides out (the bottom drawer shows).
	trick_pump() {
		const b = new Builder('trick_pump');
		const red = C('pump_red', 0xe0262e), metal = C('pump_metal', 0xb0b0b8, { metalness: 0.5 });
		b.add('base', C('pump_base', 0x2a2a30), new THREE.BoxGeometry(0.32, 0.06, 0.2), { pos: V(0, 0.03, 0) });
		b.add('drawer', C('pump_drawer', 0xf6d23a), new THREE.BoxGeometry(0.26, 0.04, 0.02), { pos: V(0, 0.03, 0.105) });
		b.add('barrel', red, new THREE.CylinderGeometry(0.05, 0.05, 0.4, 12), { pos: V(0, 0.26, 0) });
		b.add('rod', metal, new THREE.CylinderGeometry(0.01, 0.01, 0.16, 6), { pos: V(0, 0.52, 0) });
		b.add('handle', metal, new THREE.CylinderGeometry(0.015, 0.015, 0.2, 6), { pos: V(0, 0.6, 0), rot: [0, 0, Math.PI / 2] });
		b.add('nozzle', C('pump_nozzle', 0x2a2a30), new THREE.CylinderGeometry(0.008, 0.012, 0.1, 6), { pos: V(0.08, 0.1, 0), rot: [0, 0, -1.2] });
		return b.build();
	},
	// The endless birthday's album (el cumpleaños eterno): a fat photo album with a big gold "7" on the cover and photo
	// corners peeking out of its pages.
	birthday_album() {
		const b = new Builder('birthday_album');
		const gold = C('album_gold', 0xe8b83a, { metalness: 0.4 });
		b.add('cover', C('album_cover', 0x2a5ad8), new THREE.BoxGeometry(0.3, 0.08, 0.24), { pos: V(0, 0.04, 0) });
		b.add('pages', white, new THREE.BoxGeometry(0.29, 0.06, 0.225), { pos: V(0.008, 0.04, 0) });
		b.add('seven', gold, new THREE.BoxGeometry(0.08, 0.004, 0.018), { pos: V(0, 0.082, -0.05) });
		b.add('seven', gold, new THREE.BoxGeometry(0.018, 0.004, 0.12), { pos: V(0.025, 0.082, 0.01), rot: [0, -0.4, 0] });
		for (const [x, z] of [[0.15, -0.06], [0.15, 0.05], [0.12, 0.112]]) {
			b.add('photos', C('album_photo', 0xfff07a), new THREE.BoxGeometry(0.04, 0.004, 0.05), { pos: V(x, 0.03 + z * 0.1, z), rot: [0, 0.3, 0] });
		}
		return b.build();
	},
	// A wholesale box of "7" candles: an open cardboard box packed with rows of candles shaped like a seven.
	seven_candles_box() {
		const b = new Builder('seven_candles_box');
		const card = C('candles_card', 0xc89a5a);
		b.add('box', card, new THREE.BoxGeometry(0.34, 0.14, 0.24), { pos: V(0, 0.07, 0) });
		b.add('label', C('candles_label', 0xff7ab8), new THREE.BoxGeometry(0.2, 0.06, 0.004), { pos: V(0, 0.07, 0.122) });
		for (let i = 0; i < 12; i++) {
			const x = -0.13 + (i % 6) * 0.052, z = i < 6 ? -0.05 : 0.05;
			const wax = C(`candles_wax_${i % 4}`, PASTEL[i % 4]);
			b.add('candles', wax, new THREE.BoxGeometry(0.03, 0.012, 0.012), { pos: V(x, 0.2, z) });
			b.add('candles', wax, new THREE.BoxGeometry(0.012, 0.07, 0.012), { pos: V(x + 0.006, 0.16, z), rot: [0, 0, -0.35] });
		}
		return b.build();
	},
	// The kids' actor contracts: a stapled stack of papers with crayon signatures and a gold star sticker.
	actor_contracts() {
		const b = new Builder('actor_contracts');
		b.add('papers', white, new THREE.BoxGeometry(0.21, 0.01, 0.29), { pos: V(0, 0.005, 0) });
		b.add('staple', C('contracts_staple', 0x9a9aa4, { metalness: 0.5 }), new THREE.BoxGeometry(0.03, 0.003, 0.004), { pos: V(-0.08, 0.011, -0.13) });
		for (let i = 0; i < 4; i++) {
			b.add('lines', C('contracts_ink', 0x2a2a30), new THREE.BoxGeometry(0.15, 0.002, 0.006), { pos: V(0, 0.011, -0.09 + i * 0.035) });
		}
		b.add('crayon', C(`contracts_crayon`, 0xe0262e), new THREE.BoxGeometry(0.1, 0.003, 0.012), { pos: V(-0.02, 0.011, 0.08), rot: [0, 0.3, 0] });
		b.add('star', C('contracts_star', 0xe8b83a, { metalness: 0.4 }), new THREE.CylinderGeometry(0.025, 0.025, 0.003, 5), { pos: V(0.06, 0.011, 0.1) });
		return b.build();
	},
	// The cheap blower (el inflador trucho): an electric blower for bouncy castles, a squat drum on four feet with a
	// fat hose, a patched sticker and a switch.
	party_blower() {
		const b = new Builder('party_blower');
		const shell = C('blower_shell', 0x3a8ae0), dark = C('blower_dark', 0x2a2a30);
		b.add('drum', shell, new THREE.CylinderGeometry(0.15, 0.15, 0.24, 14), { pos: V(0, 0.19, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('grille', dark, new THREE.CylinderGeometry(0.11, 0.11, 0.01, 14), { pos: V(0, 0.19, -0.125), rot: [Math.PI / 2, 0, 0] });
		b.add('hose', C('blower_hose', 0xf6d23a), new THREE.CylinderGeometry(0.07, 0.08, 0.16, 10), { pos: V(0, 0.19, 0.19), rot: [Math.PI / 2, 0, 0] });
		for (const [x, z] of [[-0.1, -0.08], [0.1, -0.08], [-0.1, 0.08], [0.1, 0.08]]) {
			b.add('feet', dark, new THREE.BoxGeometry(0.03, 0.06, 0.03), { pos: V(x, 0.03, z) });
		}
		b.add('patch', C('blower_patch', 0xe0e0e0), new THREE.BoxGeometry(0.08, 0.004, 0.06), { pos: V(0.03, 0.342, 0.02), rot: [0, 0.4, 0] });
		b.add('switch', C('blower_switch', 0xe0262e), new THREE.BoxGeometry(0.03, 0.02, 0.02), { pos: V(-0.06, 0.345, -0.05) });
		return b.build();
	},
	// The watch shop's invoice: a sheet with a printed header, a column of lines and a stamped total in red.
	watch_invoice() {
		const b = new Builder('watch_invoice');
		b.add('paper', white, new THREE.BoxGeometry(0.21, 0.004, 0.29), { pos: V(0, 0.002, 0) });
		b.add('header', C('invoice_header', 0x2a5ad8), new THREE.BoxGeometry(0.17, 0.002, 0.03), { pos: V(0, 0.005, -0.11) });
		for (let i = 0; i < 6; i++) {
			b.add('lines', C('invoice_ink', 0x2a2a30), new THREE.BoxGeometry(0.15, 0.002, 0.005), { pos: V(0, 0.005, -0.07 + i * 0.025) });
		}
		b.add('total', C('invoice_total', 0xe0262e), new THREE.BoxGeometry(0.07, 0.002, 0.025), { pos: V(0.05, 0.005, 0.11) });
		return b.build();
	},
	// The cake knife: a long wide blade with a pink plastic handle.
	cake_knife() {
		const b = new Builder('cake_knife');
		b.add('blade', C('knife_blade', 0xd8d8e0, { metalness: 0.7 }), new THREE.BoxGeometry(0.2, 0.004, 0.04), { pos: V(0.06, 0.01, 0) });
		b.add('handle', C('knife_handle', 0xff7ab8), new THREE.BoxGeometry(0.11, 0.02, 0.025), { pos: V(-0.1, 0.01, 0) });
		return b.build();
	},
};

export const views = {
	birthday_party: {
		items: [{ name: 'npc_chispita', pos: [-1.0, 0, 0], rotY: 0.3 }, { name: 'npc_tomasito', pos: [0.1, 0, 0.3], scale: 0.62 },
			{ name: 'npc_nene_fiesta', pos: [0.7, 0, 0.2], rotY: -0.3, scale: 0.62 }, { name: 'npc_nena_fiesta', pos: [1.3, 0, 0], rotY: -0.5, scale: 0.62 }],
		cam: { pos: [0.2, 1.3, 4.2], target: [0.2, 0.75, 0], fov: 34 },
	},
	birthday_props: {
		items: [{ name: 'birthday_cake', pos: [-0.9, 0, 0.3] }, { name: 'birthday_pinata', pos: [0, 1.0, 0.3] },
			{ name: 'gift_box', pos: [0.7, 0, 0.5], rotY: 0.4 }, { name: 'chispita_case', pos: [1.2, 0, 0.3], rotY: -0.3 }],
		cam: { pos: [0.1, 1.2, 3.2], target: [0.1, 0.5, 0], fov: 40 },
	},
	birthday_evidence: {
		items: [{ name: 'diamond_balloons', pos: [-0.5, 0, 0] }, { name: 'trick_pump', pos: [0.15, 0, 0], rotY: 0.3 },
			{ name: 'client_list', pos: [0.65, 0, 0.1], rotY: -0.2 }],
		cam: { pos: [0.05, 0.9, 1.6], target: [0.05, 0.15, 0], fov: 40 },
	},
	birthday_endless: {
		items: [{ name: 'birthday_album', pos: [-0.4, 0, 0], rotY: 0.2 }, { name: 'seven_candles_box', pos: [0.1, 0, 0], rotY: -0.2 },
			{ name: 'actor_contracts', pos: [0.55, 0, 0.1], rotY: -0.3 }],
		cam: { pos: [0.05, 0.8, 1.3], target: [0.05, 0.08, 0], fov: 40 },
	},
	birthday_watches: {
		items: [{ name: 'watch_bag', pos: [-0.45, 0.12, 0], scale: 1.6 }, { name: 'party_blower', pos: [0.05, 0, 0], rotY: 0.5 },
			{ name: 'watch_invoice', pos: [0.45, 0, 0.1], rotY: -0.3 }, { name: 'cake_knife', pos: [0.2, 0, 0.35], rotY: 0.4 }],
		cam: { pos: [0.05, 0.8, 1.4], target: [0.05, 0.12, 0], fov: 40 },
	},
	bouncy_castle: {
		items: [{ name: 'bouncy_castle', pos: [0, 0, 0], rotY: 0.5 }],
		cam: { pos: [4, 3.5, 6], target: [0, 1, 0], fov: 40 },
	},
};
