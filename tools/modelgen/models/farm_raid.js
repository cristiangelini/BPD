// The farm raid (allanamiento-granja.md, decision 380): the animals (a hen, the goat Tota, a pig, the cow Margarita), the
// tractor, the scarecrow and the farm's small things (a hay bale, the hen house, the well, the feeding bell and a basket
// of eggs). Animals face +Z with their feet at y = 0, like the cat. Placeholder, not final art.
import { Builder, ellipsoid, mat, V, THREE } from '../lib.js';
import { M, eyes } from './pear.js';

const C = (name, color, opts) => mat(name, color, opts);
const white = M.white, black = M.black;
const pink = C('farm_pink', 0xf4a0a8);

// Four short legs at (±x, z0) and (±x, z1), `h` tall, ending in hooves.
function legs(b, coat, hoof, x, z0, z1, h, r) {
	for (const s of [-1, 1]) {
		for (const z of [z0, z1]) {
			b.add('legs', coat, new THREE.CylinderGeometry(r, r * 0.9, h, 6), { pos: V(s * x, h / 2 + 0.02, z) });
			b.add('legs', hoof, new THREE.CylinderGeometry(r * 1.05, r * 1.05, 0.04, 6), { pos: V(s * x, 0.02, z) });
		}
	}
}

export const models = {
	// A hen: a round white body, a red comb and wattle, a yellow beak, short legs and a tail of feathers up behind.
	// About 0.4 m tall.
	farm_chicken() {
		const b = new Builder('farm_chicken');
		const feathers = C('hen_white', 0xf4f0e6), red = C('hen_red', 0xe0262e), yellow = C('hen_yellow', 0xf2b02a);
		b.add('body', feathers, ellipsoid(0.13, 0.12, 0.16, 10, 7), { pos: V(0, 0.2, 0) });
		b.add('body', feathers, ellipsoid(0.07, 0.1, 0.06, 8, 5), { pos: V(0, 0.27, -0.15), rot: [-0.5, 0, 0] });
		for (const s of [-1, 1]) b.add('body', C('hen_wing', 0xe0d8c8), ellipsoid(0.03, 0.08, 0.11, 6, 4), { pos: V(s * 0.12, 0.21, -0.01) });
		b.add('head', feathers, ellipsoid(0.07, 0.08, 0.07, 8, 6), { pos: V(0, 0.34, 0.12) });
		b.add('head', red, ellipsoid(0.015, 0.04, 0.04, 5, 4), { pos: V(0, 0.42, 0.12) });
		b.add('head', red, ellipsoid(0.015, 0.025, 0.015, 5, 4), { pos: V(0, 0.29, 0.18) });
		b.add('head', yellow, new THREE.ConeGeometry(0.02, 0.05, 5), { pos: V(0, 0.33, 0.2), rot: [Math.PI / 2, 0, 0] });
		eyes(b, 0.36, 0.175, 0.035, 0.014);
		for (const s of [-1, 1]) {
			b.add('legs', yellow, new THREE.CylinderGeometry(0.01, 0.01, 0.1, 4), { pos: V(s * 0.05, 0.06, 0) });
			b.add('legs', yellow, new THREE.BoxGeometry(0.05, 0.01, 0.06), { pos: V(s * 0.05, 0.01, 0.02) });
		}
		return b.build();
	},
	// The goat Tota: grey-brown with a white beard, short curved horns, floppy ears and a stub of a tail. About 0.9 m
	// tall at the head.
	farm_goat() {
		const b = new Builder('farm_goat');
		const coat = C('goat_coat', 0xa08a70), hoof = C('goat_hoof', 0x3a2e24);
		b.add('body', coat, ellipsoid(0.2, 0.18, 0.36, 10, 7), { pos: V(0, 0.55, 0) });
		legs(b, coat, hoof, 0.11, -0.22, 0.22, 0.42, 0.035);
		b.add('head', coat, ellipsoid(0.1, 0.11, 0.15, 8, 6), { pos: V(0, 0.8, 0.38), rot: [0.4, 0, 0] });
		b.add('head', white, ellipsoid(0.04, 0.08, 0.04, 6, 4), { pos: V(0, 0.66, 0.46) });
		for (const s of [-1, 1]) {
			b.add('head', C('goat_horn', 0xd8ccb0), new THREE.ConeGeometry(0.025, 0.14, 5), { pos: V(s * 0.05, 0.94, 0.32), rot: [-0.7, 0, s * 0.2] });
			b.add('head', coat, ellipsoid(0.06, 0.02, 0.03, 5, 3), { pos: V(s * 0.11, 0.84, 0.34), rot: [0, 0, s * 0.5] });
		}
		eyes(b, 0.86, 0.49, 0.06, 0.022);
		b.add('body', coat, ellipsoid(0.03, 0.06, 0.03, 5, 4), { pos: V(0, 0.68, -0.36), rot: [-0.6, 0, 0] });
		return b.build();
	},
	// A pig: a fat pink barrel with a snout, little ears, a curly tail and some mud on its sides. About 0.6 m tall.
	farm_pig() {
		const b = new Builder('farm_pig');
		const hoof = C('pig_hoof', 0x6a4a3a), mud = C('pig_mud', 0x6a4a2a);
		b.add('body', pink, ellipsoid(0.26, 0.24, 0.42, 10, 7), { pos: V(0, 0.36, 0) });
		legs(b, pink, hoof, 0.14, -0.24, 0.24, 0.18, 0.05);
		b.add('head', pink, ellipsoid(0.17, 0.16, 0.14, 8, 6), { pos: V(0, 0.42, 0.42) });
		b.add('head', C('pig_snout', 0xe88890), new THREE.CylinderGeometry(0.07, 0.07, 0.06, 10), { pos: V(0, 0.4, 0.56), rot: [Math.PI / 2, 0, 0] });
		for (const s of [-1, 1]) {
			b.add('head', black, ellipsoid(0.012, 0.018, 0.005, 4, 3), { pos: V(s * 0.025, 0.4, 0.592) });
			b.add('head', pink, new THREE.ConeGeometry(0.05, 0.09, 4), { pos: V(s * 0.1, 0.57, 0.38), rot: [0.3, 0, -s * 0.4] });
			b.add('mud', mud, ellipsoid(0.03, 0.09, 0.14, 6, 4), { pos: V(s * 0.24, 0.26, -0.1) });
		}
		eyes(b, 0.5, 0.55, 0.07, 0.022);
		b.add('tail', pink, new THREE.TorusGeometry(0.04, 0.012, 4, 8, Math.PI * 1.6), { pos: V(0, 0.46, -0.43), rot: [0, Math.PI / 2, 0] });
		return b.build();
	},
	// The cow Margarita: white with black patches, a pink nose, short horns, a pink udder and a bell on her neck.
	// About 1.4 m tall.
	farm_cow() {
		const b = new Builder('farm_cow');
		const coat = C('cow_white', 0xf4f2ec), patch = C('cow_patch', 0x2a2a2a), hoof = C('cow_hoof', 0x3a2e24);
		b.add('body', coat, ellipsoid(0.36, 0.34, 0.7, 12, 8), { pos: V(0, 0.95, 0) });
		for (const [x, y, z, r] of [[0.3, 1.05, 0.2, 0.16], [-0.32, 0.9, -0.25, 0.18], [0.25, 1.15, -0.35, 0.12], [-0.1, 1.27, 0.3, 0.13]]) {
			b.add('patches', patch, ellipsoid(r, r * 0.7, r, 6, 4), { pos: V(x, y, z) });
		}
		legs(b, coat, hoof, 0.22, -0.45, 0.45, 0.62, 0.07);
		b.add('head', coat, ellipsoid(0.17, 0.2, 0.24, 8, 6), { pos: V(0, 1.22, 0.78), rot: [0.3, 0, 0] });
		b.add('head', C('cow_nose', 0xf0a0a8), ellipsoid(0.15, 0.1, 0.1, 8, 5), { pos: V(0, 1.1, 0.96) });
		for (const s of [-1, 1]) {
			b.add('head', C('cow_horn', 0xe8dcc0), new THREE.ConeGeometry(0.03, 0.12, 5), { pos: V(s * 0.12, 1.43, 0.72), rot: [0, 0, -s * 0.8] });
			b.add('head', coat, ellipsoid(0.09, 0.03, 0.05, 5, 3), { pos: V(s * 0.2, 1.33, 0.7), rot: [0, 0, s * 0.3] });
		}
		eyes(b, 1.32, 0.97, 0.09, 0.03);
		b.add('udder', pink, ellipsoid(0.13, 0.1, 0.14, 8, 5), { pos: V(0, 0.62, -0.25) });
		b.add('bell', C('cow_bell', 0xd8a83a, { metalness: 0.5 }), new THREE.ConeGeometry(0.06, 0.1, 8), { pos: V(0, 0.92, 0.8) });
		b.add('tail', coat, new THREE.CylinderGeometry(0.015, 0.015, 0.6, 4), { pos: V(0, 0.95, -0.72), rot: [0.2, 0, 0] });
		return b.build();
	},
	// The tractor: a red body with a long hood, a seat and steering wheel, two big rear wheels and two small front ones,
	// an exhaust pipe and a "TURBO" sticker. About 2.6 x 1.6 x 2.2 m, facing +Z.
	farm_tractor() {
		const b = new Builder('farm_tractor');
		const red = C('tractor_red', 0xd8262e), tire = C('tractor_tire', 0x2a2a2e), hub = C('tractor_hub', 0xf2c230);
		b.add('body', red, new THREE.BoxGeometry(0.9, 0.7, 1.2), { pos: V(0, 0.95, 0.5) });
		b.add('body', red, new THREE.BoxGeometry(1.0, 0.5, 0.9), { pos: V(0, 0.85, -0.45) });
		b.add('grille', C('tractor_grille', 0x3a3a3e), new THREE.BoxGeometry(0.7, 0.5, 0.02), { pos: V(0, 0.95, 1.11) });
		b.add('seat', C('tractor_seat', 0x2a2a2e), new THREE.BoxGeometry(0.5, 0.12, 0.45), { pos: V(0, 1.18, -0.55) });
		b.add('seat', C('tractor_seat', 0x2a2a2e), new THREE.BoxGeometry(0.5, 0.45, 0.1), { pos: V(0, 1.42, -0.78) });
		b.add('wheel', black, new THREE.TorusGeometry(0.18, 0.025, 4, 12), { pos: V(0, 1.45, -0.15), rot: [-1.0, 0, 0] });
		b.add('pipe', C('tractor_pipe', 0x8a8a90, { metalness: 0.6 }), new THREE.CylinderGeometry(0.05, 0.05, 0.9, 8), { pos: V(0.3, 1.6, 0.85) });
		b.add('sticker', C('turbo_sticker', 0xf2c230), new THREE.BoxGeometry(0.02, 0.15, 0.5), { pos: V(0.46, 1.0, 0.5) });
		for (const s of [-1, 1]) {
			b.add('tires', tire, new THREE.CylinderGeometry(0.7, 0.7, 0.35, 14), { pos: V(s * 0.72, 0.7, -0.45), rot: [0, 0, Math.PI / 2] });
			b.add('hubs', hub, new THREE.CylinderGeometry(0.3, 0.3, 0.37, 10), { pos: V(s * 0.72, 0.7, -0.45), rot: [0, 0, Math.PI / 2] });
			b.add('tires', tire, new THREE.CylinderGeometry(0.38, 0.38, 0.25, 12), { pos: V(s * 0.6, 0.38, 0.85), rot: [0, 0, Math.PI / 2] });
			b.add('hubs', hub, new THREE.CylinderGeometry(0.16, 0.16, 0.27, 10), { pos: V(s * 0.6, 0.38, 0.85), rot: [0, 0, Math.PI / 2] });
		}
		return b.build();
	},
	// The scarecrow: a pole and a cross-bar with a checked shirt stuffed with straw, a sack head with a stitched smile
	// and a battered straw hat. About 1.9 m tall.
	scarecrow() {
		const b = new Builder('scarecrow');
		const wood = C('scarecrow_pole', 0x8a6a48), straw = C('scarecrow_straw', 0xe8c868), sack = C('scarecrow_sack', 0xd8c09a);
		b.add('pole', wood, new THREE.CylinderGeometry(0.04, 0.04, 1.9, 6), { pos: V(0, 0.95, 0) });
		b.add('pole', wood, new THREE.CylinderGeometry(0.03, 0.03, 1.2, 6), { pos: V(0, 1.35, 0), rot: [0, 0, Math.PI / 2] });
		b.add('shirt', C('scarecrow_shirt', 0x3a6ab8), new THREE.CylinderGeometry(0.22, 0.26, 0.6, 8), { pos: V(0, 1.15, 0) });
		for (const s of [-1, 1]) {
			b.add('shirt', C('scarecrow_shirt', 0x3a6ab8), new THREE.CylinderGeometry(0.08, 0.08, 0.4, 6), { pos: V(s * 0.38, 1.35, 0), rot: [0, 0, Math.PI / 2] });
			b.add('straw', straw, new THREE.ConeGeometry(0.06, 0.14, 5), { pos: V(s * 0.62, 1.35, 0), rot: [0, 0, s * Math.PI / 2] });
		}
		b.add('straw', straw, new THREE.ConeGeometry(0.2, 0.2, 6), { pos: V(0, 0.78, 0), rot: [Math.PI, 0, 0] });
		b.add('head', sack, ellipsoid(0.16, 0.18, 0.15, 8, 6), { pos: V(0, 1.6, 0) });
		b.add('face', black, new THREE.TorusGeometry(0.07, 0.008, 4, 10, Math.PI), { pos: V(0, 1.56, 0.14), rot: [0, 0, Math.PI] });
		for (const s of [-1, 1]) b.add('face', black, new THREE.BoxGeometry(0.04, 0.04, 0.01), { pos: V(s * 0.06, 1.64, 0.145), rot: [0, 0, Math.PI / 4] });
		const hat = C('scarecrow_hat', 0xc8a050);
		b.add('hat', hat, new THREE.CylinderGeometry(0.28, 0.28, 0.02, 12), { pos: V(0, 1.75, 0), rot: [0.15, 0, 0.1] });
		b.add('hat', hat, new THREE.CylinderGeometry(0.12, 0.15, 0.14, 10), { pos: V(0, 1.82, 0), rot: [0.15, 0, 0.1] });
		return b.build();
	},
	// A hay bale: a straw block with two strings round it. 1.0 x 0.5 x 0.5 m.
	hay_bale() {
		const b = new Builder('hay_bale');
		b.add('bale', C('hay', 0xe0c060), new THREE.BoxGeometry(1.0, 0.5, 0.5), { pos: V(0, 0.25, 0) });
		for (const x of [-0.25, 0.25]) b.add('strings', C('hay_string', 0xc83a3a), new THREE.BoxGeometry(0.02, 0.51, 0.51), { pos: V(x, 0.25, 0) });
		return b.build();
	},
	// The hen house: a small wooden shed on stilts with a sloped roof, a round door with a ramp, and a nest box on the
	// side. 2.0 x 1.8 x 1.6 m, the door facing +Z.
	chicken_coop() {
		const b = new Builder('chicken_coop');
		const plank = C('coop_wood', 0xb07a48), roof = C('coop_roof', 0x8a3a2a), dark = C('coop_dark', 0x3a2a1a);
		for (const [x, z] of [[-0.9, -0.7], [0.9, -0.7], [-0.9, 0.7], [0.9, 0.7]]) b.add('stilts', plank, new THREE.BoxGeometry(0.1, 0.5, 0.1), { pos: V(x, 0.25, z) });
		b.add('house', plank, new THREE.BoxGeometry(2.0, 0.9, 1.6), { pos: V(0, 0.95, 0) });
		b.add('roof', roof, new THREE.BoxGeometry(2.2, 0.08, 1.9), { pos: V(0, 1.55, 0), rot: [0.3, 0, 0] });
		b.add('roof', plank, new THREE.BoxGeometry(2.0, 0.5, 0.02), { pos: V(0, 1.38, -0.8) });
		b.add('door', dark, new THREE.CylinderGeometry(0.22, 0.22, 0.02, 12), { pos: V(0, 0.85, 0.81), rot: [Math.PI / 2, 0, 0] });
		b.add('ramp', plank, new THREE.BoxGeometry(0.4, 0.04, 0.9), { pos: V(0, 0.32, 1.15), rot: [0.65, 0, 0] });
		b.add('nest', plank, new THREE.BoxGeometry(0.5, 0.4, 0.8), { pos: V(1.2, 0.85, 0) });
		b.add('nest', C('coop_straw', 0xe0c060), new THREE.BoxGeometry(0.44, 0.04, 0.74), { pos: V(1.2, 1.06, 0) });
		return b.build();
	},
	// The well: a round stone wall, two posts with a little roof, a crank and a bucket on its rope. 1.2 m wide, 2.0 m
	// tall.
	farm_well() {
		const b = new Builder('farm_well');
		const stone = C('well_stone', 0x9a9a94), wood = C('well_wood', 0x8a6a48);
		b.add('wall', stone, new THREE.CylinderGeometry(0.6, 0.62, 0.8, 14, 1, true), { pos: V(0, 0.4, 0) });
		b.add('wall', stone, new THREE.TorusGeometry(0.6, 0.06, 4, 14), { pos: V(0, 0.8, 0), rot: [Math.PI / 2, 0, 0] });
		b.add('water', C('well_water', 0x2a4a6a), new THREE.CylinderGeometry(0.56, 0.56, 0.02, 14), { pos: V(0, 0.3, 0) });
		for (const s of [-1, 1]) b.add('posts', wood, new THREE.BoxGeometry(0.08, 1.3, 0.08), { pos: V(s * 0.6, 1.25, 0) });
		b.add('roof', C('well_roof', 0x8a3a2a), new THREE.ConeGeometry(0.9, 0.4, 4), { pos: V(0, 2.05, 0), rot: [0, Math.PI / 4, 0] });
		b.add('crank', wood, new THREE.CylinderGeometry(0.05, 0.05, 1.2, 6), { pos: V(0, 1.6, 0), rot: [0, 0, Math.PI / 2] });
		b.add('rope', C('well_rope', 0xd8c8a0), new THREE.CylinderGeometry(0.01, 0.01, 0.5, 4), { pos: V(0, 1.33, 0) });
		b.add('bucket', C('well_bucket', 0x8a8a90, { metalness: 0.4 }), new THREE.CylinderGeometry(0.12, 0.1, 0.2, 10), { pos: V(0, 0.98, 0) });
		return b.build();
	},
	// The feeding bell: a brass bell hanging from a wooden bracket on a post, with its pull cord. 0.6 m tall, mounted
	// at the top of the post.
	feed_bell() {
		const b = new Builder('feed_bell');
		const wood = C('bell_wood', 0x8a6a48);
		b.add('bracket', wood, new THREE.BoxGeometry(0.08, 0.6, 0.08), { pos: V(0, 0.3, 0) });
		b.add('bracket', wood, new THREE.BoxGeometry(0.08, 0.08, 0.4), { pos: V(0, 0.56, 0.16) });
		b.add('bell', C('bell_brass', 0xd8a83a, { metalness: 0.6, roughness: 0.3 }), new THREE.CylinderGeometry(0.06, 0.14, 0.2, 12, 1, true), { pos: V(0, 0.42, 0.3) });
		b.add('bell', C('bell_brass', 0xd8a83a, { metalness: 0.6, roughness: 0.3 }), ellipsoid(0.06, 0.04, 0.06, 8, 4), { pos: V(0, 0.52, 0.3) });
		b.add('cord', C('bell_cord', 0xc83a3a), new THREE.CylinderGeometry(0.008, 0.008, 0.3, 4), { pos: V(0, 0.18, 0.3) });
		return b.build();
	},
	// A basket of eggs for the market stall: a wicker basket with a handle and a dozen eggs, two of them brown.
	egg_basket() {
		const b = new Builder('egg_basket');
		const wicker = C('egg_wicker', 0xb88a48);
		b.add('basket', wicker, new THREE.CylinderGeometry(0.18, 0.14, 0.14, 12), { pos: V(0, 0.07, 0) });
		b.add('handle', wicker, new THREE.TorusGeometry(0.17, 0.014, 4, 12, Math.PI), { pos: V(0, 0.14, 0) });
		for (let i = 0; i < 12; i++) {
			const a = (i / 12) * Math.PI * 2, r = i % 2 ? 0.1 : 0.04;
			b.add('eggs', C(i % 5 ? 'egg_white' : 'egg_brown', i % 5 ? 0xf6f0e0 : 0xc89060), ellipsoid(0.03, 0.04, 0.03, 6, 4), { pos: V(Math.cos(a) * r, 0.16, Math.sin(a) * r) });
		}
		return b.build();
	},
};

export const views = {
	farm_people: {
		items: [{ name: 'npc_florencio', pos: [-0.7, 0, 0], rotY: 0.3, scale: 1.05 }, { name: 'npc_pancho', pos: [0.5, 0, 0.2], rotY: -0.2, scale: 0.75 }],
		cam: { pos: [0, 1.3, 5.0], target: [0, 0.85, 0], fov: 34 },
	},
	farm_animals: {
		items: [{ name: 'farm_chicken', pos: [-1.6, 0, 0.6], rotY: 0.6 }, { name: 'farm_goat', pos: [-0.9, 0, 0.2], rotY: 0.8 },
			{ name: 'farm_pig', pos: [0.1, 0, 0.4], rotY: 0.5 }, { name: 'farm_cow', pos: [1.5, 0, -0.3], rotY: 0.9 }],
		cam: { pos: [0, 1.6, 5.2], target: [0, 0.6, 0], fov: 38 },
	},
	farm_things: {
		items: [{ name: 'farm_tractor', pos: [-2.6, 0, -0.5], rotY: 0.6 }, { name: 'scarecrow', pos: [-0.6, 0, 0] },
			{ name: 'chicken_coop', pos: [1.4, 0, -0.6], rotY: -0.3 }, { name: 'farm_well', pos: [3.4, 0, -0.2] },
			{ name: 'hay_bale', pos: [0.4, 0, 1.4], rotY: 0.3 }, { name: 'feed_bell', pos: [-1.4, 0, 1.6] },
			{ name: 'egg_basket', pos: [1.6, 0, 1.6] }],
		cam: { pos: [0.3, 3.0, 9.5], target: [0.3, 0.8, 0], fov: 40 },
	},
};
