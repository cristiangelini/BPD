// The costume party's guests' costume bits (docs/diseno/infiltracion-fiesta.md, step 2b): the four traits that tell
// the guests apart, three of each (the glasses can also be none). Each origin is the NPC model's own (feet on the
// ground, facing +Z), so the game adds them to the guest's model as they are. Placeholder.
import { Builder, mat, V, THREE, ellipsoid } from '../lib.js';

const CAPS = { blue: 0x2a48c8, black: 0x16161a, white: 0xf0f0f0 };
const BADGES = { gold: 0xf2c230, silver: 0xc8ccd4, chocolate: 0x5a3418 };

// A party-store cop cap over the guest's hair, with a little star on its front.
function buildCap(color) {
	const b = new Builder(`party_trait_cap_${color}`);
	const crown = mat(`trait_cap_${color}`, CAPS[color]);
	b.add('cap', crown, new THREE.CylinderGeometry(0.21, 0.18, 0.11, 10), { pos: V(0, 1.53, 0.01) });
	b.add('cap', mat('trait_cap_band', 0x101014), new THREE.CylinderGeometry(0.185, 0.185, 0.03, 10), { pos: V(0, 1.48, 0.01) });
	b.add('cap', mat('trait_visor', 0x0c0c10), new THREE.CylinderGeometry(0.15, 0.15, 0.02, 10, 1, false, -Math.PI / 2, Math.PI), { pos: V(0, 1.46, 0.08) });
	b.add('cap', mat('trait_cap_star', 0xf2c230), new THREE.CylinderGeometry(0.035, 0.035, 0.012, 5), { pos: V(0, 1.53, 0.21), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// A fake mustache under the nose: thin (a pencil line), handlebar (curled tips) or bushy (a big brush).
function buildMustache(kind) {
	const b = new Builder(`party_trait_mustache_${kind}`);
	const black = mat('trait_mustache', 0x0c0c0e);
	if (kind === 'thin') {
		for (const s of [-1, 1]) b.add('mustache', black, new THREE.BoxGeometry(0.08, 0.012, 0.015), { pos: V(s * 0.045, 1.255, 0.205), rot: [0, s * 0.3, s * -0.12] });
	} else if (kind === 'handlebar') {
		b.add('mustache', black, ellipsoid(0.04, 0.02, 0.02, 6, 4), { pos: V(0, 1.25, 0.21) });
		for (const s of [-1, 1]) {
			b.add('mustache', black, ellipsoid(0.05, 0.015, 0.015, 6, 4), { pos: V(s * 0.07, 1.245, 0.2), rot: [0, s * 0.4, s * 0.2] });
			b.add('mustache', black, new THREE.TorusGeometry(0.018, 0.007, 4, 8, Math.PI * 1.5), { pos: V(s * 0.115, 1.265, 0.18), rot: [0, s * 0.5, 0] });
		}
	} else {
		b.add('mustache', black, ellipsoid(0.13, 0.045, 0.04, 8, 5), { pos: V(0, 1.24, 0.2) });
	}
	return b.build();
}

// A plastic badge on the left of the chest: a star of gold, silver or chocolate (in its wrapper).
function buildBadge(kind) {
	const b = new Builder(`party_trait_badge_${kind}`);
	const shape = new THREE.Shape();
	for (let i = 0; i < 10; i++) {
		const r = i % 2 ? 0.035 : 0.075, a = Math.PI / 2 + (i / 10) * Math.PI * 2;
		if (i === 0) shape.moveTo(Math.cos(a) * r, Math.sin(a) * r);
		else shape.lineTo(Math.cos(a) * r, Math.sin(a) * r);
	}
	const star = new THREE.ExtrudeGeometry(shape, { depth: 0.02, bevelEnabled: false });
	b.add('badge', mat(`trait_badge_${kind}`, BADGES[kind]), star, { pos: V(-0.13, 0.95, 0.3), rot: [-0.35, -0.3, 0] });
	if (kind === 'chocolate') b.add('badge', mat('trait_foil', 0xd8c890), new THREE.CylinderGeometry(0.025, 0.025, 0.024, 8), { pos: V(-0.125, 0.95, 0.305), rot: [Math.PI / 2 - 0.35, -0.3, 0] });
	return b.build();
}

// Glasses: dark sunglasses or pink heart-shaped ones.
function buildGlasses(kind) {
	const b = new Builder(`party_trait_glasses_${kind}`);
	if (kind === 'sun') {
		const dark = mat('trait_sunglasses', 0x0a0a0c);
		for (const s of [-1, 1]) b.add('glasses', dark, new THREE.BoxGeometry(0.11, 0.065, 0.02), { pos: V(s * 0.075, 1.33, 0.205) });
		b.add('glasses', dark, new THREE.BoxGeometry(0.36, 0.015, 0.015), { pos: V(0, 1.35, 0.195) });
	} else {
		const pink = mat('trait_heart', 0xf04890);
		const heart = new THREE.Shape();
		heart.moveTo(0, -0.04);
		heart.bezierCurveTo(-0.07, 0.0, -0.05, 0.05, 0, 0.025);
		heart.bezierCurveTo(0.05, 0.05, 0.07, 0.0, 0, -0.04);
		const geo = new THREE.ExtrudeGeometry(heart, { depth: 0.015, bevelEnabled: false });
		for (const s of [-1, 1]) b.add('glasses', pink, geo, { pos: V(s * 0.075, 1.33, 0.2) });
		b.add('glasses', pink, new THREE.BoxGeometry(0.34, 0.012, 0.012), { pos: V(0, 1.345, 0.2) });
	}
	return b.build();
}

export const models = {
	...Object.fromEntries(Object.keys(CAPS).map((c) => [`party_trait_cap_${c}`, () => buildCap(c)])),
	...Object.fromEntries(['thin', 'handlebar', 'bushy'].map((k) => [`party_trait_mustache_${k}`, () => buildMustache(k)])),
	...Object.fromEntries(Object.keys(BADGES).map((k) => [`party_trait_badge_${k}`, () => buildBadge(k)])),
	...Object.fromEntries(['sun', 'heart'].map((k) => [`party_trait_glasses_${k}`, () => buildGlasses(k)])),
};

// Three guests dressed differently, to check the bits sit on the face and chest.
const guest = (name, x, bits) => [{ name, pos: [x, 0, 0], rotY: 0.2, scale: 0.9 }, ...bits.map((bit) => ({ name: `party_trait_${bit}`, pos: [x, 0, 0], rotY: 0.2, scale: 0.9 }))];
export const views = {
	party_guests: {
		items: [
			...guest('npc_invitado', -1.3, ['cap_blue', 'mustache_handlebar', 'badge_gold', 'glasses_sun']),
			...guest('npc_invitado_b', 0, ['cap_white', 'mustache_bushy', 'badge_chocolate', 'glasses_heart']),
			...guest('npc_invitado', 1.3, ['cap_black', 'mustache_thin', 'badge_silver']),
		],
		cam: { pos: [0, 1.3, 4.6], target: [0, 1.0, 0], fov: 34 },
	},
	party_people: {
		items: [
			{ name: 'npc_serpentina', pos: [-0.8, 0, 0], rotY: 0.3, scale: 0.9 },
			{ name: 'npc_patovica', pos: [0.8, 0, 0], rotY: -0.3, scale: 1.25 },
		],
		cam: { pos: [0, 1.3, 4.6], target: [0, 0.95, 0], fov: 34 },
	},
};
