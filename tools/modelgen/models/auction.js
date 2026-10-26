// The auction house "El Martillo de Oro" (docs/diseno/infiltracion-subasta.md, step 3): the chairs with their bidding
// paddles, Don Martillo's podium and gavel, the easel of the lots and the lots themselves (an ugly portrait, a vase, a
// marble bust and a chair "de época"). Each faces +Z, its origin at the floor (the paddle and the gavel at their
// handle's end). Placeholder.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

const gold = () => mat('auction_gold', 0xd8b040, { metalness: 0.7, roughness: 0.3 });
const wood = () => mat('auction_wood', 0x5a3420);
const lathe = (points, segs = 12) => new THREE.LatheGeometry(points.map(([r, y]) => new THREE.Vector2(r, y)), segs);

// A gilded chair with a red velvet seat and back; the back on the -Z side (whoever sits faces +Z... the model is
// turned to face the podium in the game). 0.5 x 1.05 x 0.5 m, the seat at 0.45 m.
export function buildAuctionChair() {
	const b = new Builder('auction_chair');
	const velvet = mat('auction_velvet', 0x8a1a24);
	for (const x of [-0.21, 0.21]) for (const z of [-0.21, 0.21]) b.add('legs', gold(), new THREE.CylinderGeometry(0.025, 0.02, 0.4, 6), { pos: V(x, 0.2, z) });
	b.add('seat', gold(), new THREE.BoxGeometry(0.5, 0.05, 0.5), { pos: V(0, 0.42, 0) });
	b.add('seat', velvet, new THREE.BoxGeometry(0.44, 0.04, 0.44), { pos: V(0, 0.46, 0) });
	b.add('back', gold(), new THREE.BoxGeometry(0.5, 0.6, 0.05), { pos: V(0, 0.75, -0.23) });
	b.add('back', velvet, new THREE.BoxGeometry(0.4, 0.48, 0.02), { pos: V(0, 0.75, -0.2) });
	return b.build();
}

// The bidding paddle: a white disc on a wooden handle, raised. 0.26 m across.
export function buildAuctionPaddle() {
	const b = new Builder('auction_paddle');
	b.add('paddle', mat('paddle_white', 0xf4f0e8), new THREE.CylinderGeometry(0.13, 0.13, 0.015, 16), { pos: V(0, 0.38, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('rim', gold(), new THREE.TorusGeometry(0.13, 0.008, 4, 16), { pos: V(0, 0.38, 0) });
	b.add('handle', wood(), new THREE.CylinderGeometry(0.015, 0.018, 0.26, 6), { pos: V(0, 0.13, 0) });
	return b.build();
}

// Don Martillo's podium: a dark wood lectern with a gold plate on the front and a sloped top. 1.2 x 1.1 x 0.5 m.
export function buildAuctionPodium() {
	const b = new Builder('auction_podium');
	b.add('body', wood(), new THREE.BoxGeometry(1.1, 1.0, 0.45), { pos: V(0, 0.5, 0) });
	b.add('top', mat('auction_wood_dark', 0x3a2014), new THREE.BoxGeometry(1.2, 0.06, 0.55), { pos: V(0, 1.05, 0), rot: [-0.15, 0, 0] });
	b.add('plate', gold(), new THREE.BoxGeometry(0.6, 0.25, 0.02), { pos: V(0, 0.7, 0.235) });
	b.add('plate', mat('plate_red', 0x8a1a24), new THREE.BoxGeometry(0.5, 0.15, 0.01), { pos: V(0, 0.7, 0.247) });
	b.add('base', mat('auction_wood_dark', 0x3a2014), new THREE.BoxGeometry(1.2, 0.08, 0.55), { pos: V(0, 0.04, 0) });
	return b.build();
}

// The gavel, lying along X with its handle's end at the origin: a golden head on a wooden handle. 0.35 m long.
export function buildAuctionGavel() {
	const b = new Builder('auction_gavel');
	b.add('handle', wood(), new THREE.CylinderGeometry(0.015, 0.015, 0.28, 6), { pos: V(0.14, 0.04, 0), rot: [0, 0, Math.PI / 2] });
	b.add('head', gold(), new THREE.CylinderGeometry(0.04, 0.04, 0.14, 10), { pos: V(0.3, 0.04, 0), rot: [Math.PI / 2, 0, 0] });
	b.add('block', mat('auction_wood_dark', 0x3a2014), new THREE.CylinderGeometry(0.07, 0.07, 0.03, 12), { pos: V(0.3, -0.005, 0.25) });
	return b.build();
}

// The easel of the lots: three wooden legs and a ledge at 0.9 m that the lot stands on. 0.9 x 1.8 x 0.6 m.
export function buildAuctionEasel() {
	const b = new Builder('auction_easel');
	for (const s of [-1, 1]) b.add('legs', wood(), new THREE.BoxGeometry(0.05, 1.8, 0.04), { pos: V(s * 0.3, 0.9, 0.05), rot: [0.08, 0, -s * 0.12] });
	b.add('legs', wood(), new THREE.BoxGeometry(0.05, 1.75, 0.04), { pos: V(0, 0.85, -0.22), rot: [-0.3, 0, 0] });
	b.add('ledge', wood(), new THREE.BoxGeometry(0.9, 0.05, 0.14), { pos: V(0, 0.88, 0.1) });
	b.add('ledge', gold(), new THREE.BoxGeometry(0.4, 0.08, 0.01), { pos: V(0, 0.88, 0.175) });
	return b.build();
}

// The lots, each standing on the easel's ledge (origin at its bottom):
// an ugly portrait in a heavy gold frame: a green man with a crooked nose, 0.7 x 0.85 m.
export function buildLotPainting() {
	const b = new Builder('lot_painting');
	b.add('frame', gold(), new THREE.BoxGeometry(0.7, 0.85, 0.05), { pos: V(0, 0.425, 0) });
	b.add('canvas', mat('canvas_ochre', 0xc8a050), new THREE.BoxGeometry(0.56, 0.7, 0.02), { pos: V(0, 0.425, 0.022) });
	b.add('face', mat('portrait_green', 0x7ab060), ellipsoid(0.16, 0.2, 0.02, 10, 6), { pos: V(0, 0.5, 0.034) });
	for (const s of [-1, 1]) b.add('eyes', mat('portrait_black', 0x18181c), new THREE.SphereGeometry(0.02, 5, 4), { pos: V(s * 0.06, 0.55 + s * 0.02, 0.05) });
	b.add('nose', mat('portrait_red', 0xc04a3a), new THREE.ConeGeometry(0.03, 0.12, 5), { pos: V(0.02, 0.48, 0.05), rot: [0, 0, 0.5] });
	b.add('body', mat('portrait_purple', 0x5a2a7a), new THREE.BoxGeometry(0.4, 0.16, 0.02), { pos: V(0, 0.18, 0.034) });
	return b.build();
}

// A tall blue vase with a gold band, 0.5 m high.
export function buildLotVase() {
	const b = new Builder('lot_vase');
	b.add('vase', mat('vase_blue', 0x2a5aa0), lathe([[0, 0], [0.1, 0], [0.16, 0.15], [0.12, 0.35], [0.07, 0.42], [0.1, 0.5], [0.08, 0.5]]));
	b.add('band', gold(), new THREE.TorusGeometry(0.155, 0.012, 4, 14), { pos: V(0, 0.17, 0), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// A white marble bust of someone very serious on a little plinth, 0.55 m high.
export function buildLotStatue() {
	const b = new Builder('lot_statue');
	const marble = mat('marble', 0xeeeae2);
	b.add('plinth', mat('marble_grey', 0xb8b4ac), new THREE.BoxGeometry(0.24, 0.1, 0.24), { pos: V(0, 0.05, 0) });
	b.add('bust', marble, ellipsoid(0.17, 0.12, 0.11, 10, 6), { pos: V(0, 0.18, 0) });
	b.add('head', marble, ellipsoid(0.1, 0.13, 0.11, 10, 8), { pos: V(0, 0.4, 0.01) });
	b.add('nose', marble, new THREE.ConeGeometry(0.02, 0.06, 4), { pos: V(0, 0.4, 0.12), rot: [Math.PI / 2, 0, 0] });
	b.add('hair', marble, ellipsoid(0.105, 0.06, 0.11, 10, 5), { pos: V(0, 0.49, -0.01) });
	return b.build();
}

// A small chair "de época": curved gold legs and a pink striped cushion, 0.4 x 0.6 m.
export function buildLotChair() {
	const b = new Builder('lot_chair');
	const pink = mat('cushion_pink', 0xe8a0b0);
	for (const x of [-0.15, 0.15]) for (const z of [-0.12, 0.12]) b.add('legs', gold(), new THREE.CylinderGeometry(0.015, 0.01, 0.28, 5), { pos: V(x, 0.14, z), rot: [0, 0, x > 0 ? -0.15 : 0.15] });
	b.add('seat', pink, new THREE.BoxGeometry(0.36, 0.06, 0.3), { pos: V(0, 0.3, 0) });
	for (let i = 0; i < 3; i++) b.add('stripes', mat('cushion_white', 0xf4eef0), new THREE.BoxGeometry(0.04, 0.062, 0.3), { pos: V(-0.12 + i * 0.12, 0.3, 0) });
	b.add('back', gold(), new THREE.TorusGeometry(0.15, 0.015, 4, 12, Math.PI), { pos: V(0, 0.36, -0.14) });
	b.add('back', pink, new THREE.BoxGeometry(0.24, 0.18, 0.02), { pos: V(0, 0.44, -0.14) });
	return b.build();
}

// The evidence (step 5): the stolen original, a sunny landscape in an ornate frame (1.0 x 0.8 m, lying on its back,
// origin at its bottom), and the forger's half-painted copy of it with his paint tubes (0.7 x 0.55 m canvas).
export function buildOriginalPainting() {
	const b = new Builder('original_painting');
	b.add('frame', gold(), new THREE.BoxGeometry(1.0, 0.06, 0.8), { pos: V(0, 0.03, 0) });
	b.add('sky', mat('sky_blue', 0x7ab8e8), new THREE.BoxGeometry(0.84, 0.01, 0.34), { pos: V(0, 0.065, -0.15) });
	b.add('field', mat('field_green', 0x5a9a3a), new THREE.BoxGeometry(0.84, 0.01, 0.3), { pos: V(0, 0.065, 0.17) });
	b.add('sun', mat('sun_yellow', 0xf8d040), new THREE.CylinderGeometry(0.07, 0.07, 0.012, 12), { pos: V(0.25, 0.07, -0.2) });
	for (const x of [-0.25, -0.05]) b.add('trees', mat('tree_dark', 0x2a5a2a), new THREE.ConeGeometry(0.06, 0.012, 6), { pos: V(x, 0.072, 0.05), rot: [Math.PI / 2, 0, 0], scale: [1, 1, 2] });
	b.add('label', mat('museum_label', 0xf4f0e8), new THREE.BoxGeometry(0.16, 0.012, 0.05), { pos: V(0, 0.065, 0.37) });
	return b.build();
}

export function buildForgery() {
	const b = new Builder('forgery');
	b.add('canvas', mat('canvas_white', 0xf4f0e8), new THREE.BoxGeometry(0.7, 0.55, 0.02), { pos: V(0, 0.275, 0) });
	b.add('sky', mat('sky_blue', 0x7ab8e8), new THREE.BoxGeometry(0.66, 0.22, 0.005), { pos: V(0, 0.4, 0.012) });
	b.add('field', mat('field_green', 0x5a9a3a), new THREE.BoxGeometry(0.33, 0.2, 0.005), { pos: V(-0.165, 0.13, 0.012) });
	b.add('sun', mat('sun_yellow', 0xf8d040), new THREE.CylinderGeometry(0.05, 0.05, 0.006, 10), { pos: V(0.18, 0.43, 0.014), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

export const models = {
	auction_chair: buildAuctionChair, auction_paddle: buildAuctionPaddle, auction_podium: buildAuctionPodium,
	auction_gavel: buildAuctionGavel, auction_easel: buildAuctionEasel, lot_painting: buildLotPainting,
	lot_vase: buildLotVase, lot_statue: buildLotStatue, lot_chair: buildLotChair,
	original_painting: buildOriginalPainting, forgery: buildForgery,
};

export const views = {
	auction_hall: {
		items: [{ name: 'auction_podium', pos: [-1.2, 0, 0] }, { name: 'auction_gavel', pos: [-1.4, 1.08, 0.05] },
			{ name: 'auction_easel', pos: [0.4, 0, 0] }, { name: 'lot_painting', pos: [0.4, 0.905, 0.1] },
			{ name: 'auction_chair', pos: [1.5, 0, 0.4], rotY: Math.PI }, { name: 'auction_paddle', pos: [1.5, 1.1, 0.4] }],
		cam: { pos: [0.6, 1.4, 4.2], target: [0.1, 0.8, 0], fov: 45 },
	},
	auction_lots: {
		items: [{ name: 'lot_painting', pos: [-0.9, 0, 0] }, { name: 'lot_vase', pos: [-0.2, 0, 0] },
			{ name: 'lot_statue', pos: [0.4, 0, 0] }, { name: 'lot_chair', pos: [1.0, 0, 0] }],
		cam: { pos: [0.05, 0.7, 2.6], target: [0.05, 0.35, 0], fov: 40 },
	},
	auction_evidence: {
		items: [{ name: 'original_painting', pos: [-0.5, 0, 0] }, { name: 'auction_easel', pos: [0.7, 0, -0.2] },
			{ name: 'forgery', pos: [0.7, 0.905, -0.1] }],
		cam: { pos: [0.1, 1.5, 2.4], target: [0.1, 0.5, 0], fov: 45 },
	},
};
