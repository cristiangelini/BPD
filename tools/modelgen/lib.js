// Shared helpers for procedural placeholder models (1 unit = 1 meter, Y up, models face +Z).
import * as THREE from 'three';
import { mergeGeometries } from 'three/addons/utils/BufferGeometryUtils.js';

export { THREE };

export function rng(seed) {
	let a = seed >>> 0;
	return () => {
		a = (a + 0x6d2b79f5) >>> 0;
		let t = a;
		t = Math.imul(t ^ (t >>> 15), t | 1);
		t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
		return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
	};
}

export function mat(name, color, opts = {}) {
	return new THREE.MeshStandardMaterial({ name, color, roughness: 0.85, metalness: 0, flatShading: true, ...opts });
}

// Flip triangles when the first triangle's face normal points toward `inside`.
function orient(geo, inside) {
	const p = geo.attributes.position;
	const idx = geo.index.array;
	const a = new THREE.Vector3().fromBufferAttribute(p, idx[0]);
	const b = new THREE.Vector3().fromBufferAttribute(p, idx[1]);
	const c = new THREE.Vector3().fromBufferAttribute(p, idx[2]);
	const n = new THREE.Vector3().crossVectors(b.clone().sub(a), c.clone().sub(a));
	const out = a.clone().add(b).add(c).divideScalar(3).sub(inside);
	if (n.dot(out) < 0) {
		for (let i = 0; i < idx.length; i += 3) {
			const t = idx[i + 1];
			idx[i + 1] = idx[i + 2];
			idx[i + 2] = t;
		}
	}
}

// Average normals of vertices that share a position (closes seams on lofts and tubes).
export function weldNormals(geo) {
	geo.computeVertexNormals();
	const p = geo.attributes.position, n = geo.attributes.normal;
	const map = new Map();
	for (let i = 0; i < p.count; i++) {
		const k = `${p.getX(i).toFixed(4)},${p.getY(i).toFixed(4)},${p.getZ(i).toFixed(4)}`;
		if (!map.has(k)) map.set(k, []);
		map.get(k).push(i);
	}
	const v = new THREE.Vector3();
	for (const ids of map.values()) {
		if (ids.length < 2) continue;
		v.set(0, 0, 0);
		for (const i of ids) v.x += n.getX(i), v.y += n.getY(i), v.z += n.getZ(i);
		v.normalize();
		for (const i of ids) n.setXYZ(i, v.x, v.y, v.z);
	}
	return geo;
}

// Stack of horizontal ellipses, bottom to top. Ring: {y, rx, rz, cx, cz, fn(theta, ring) -> {r, y}}.
// theta = 0 points to +Z (front).
export function loft(rings, segs = 24, { capBottom = false, capTop = false } = {}) {
	const pos = [], uv = [], idx = [];
	rings.forEach((r, i) => {
		for (let j = 0; j <= segs; j++) {
			const th = (j / segs) * Math.PI * 2;
			const f = r.fn ? r.fn(th, r) : {};
			const m = f.r ?? 1;
			pos.push((r.cx ?? 0) + r.rx * m * Math.sin(th), r.y + (f.y ?? 0), (r.cz ?? 0) + r.rz * m * Math.cos(th));
			uv.push(j / segs, i / (rings.length - 1));
		}
	});
	const W = segs + 1;
	for (let i = 0; i < rings.length - 1; i++)
		for (let j = 0; j < segs; j++) {
			const a = i * W + j, b = (i + 1) * W + j, c = b + 1, d = a + 1;
			idx.push(a, d, b, d, c, b);
		}
	const cap = (ri, up) => {
		const r = rings[ri];
		const center = pos.length / 3;
		pos.push(r.cx ?? 0, r.y, r.cz ?? 0);
		uv.push(0.5, 0.5);
		for (let j = 0; j < segs; j++) {
			const a = ri * W + j, d = a + 1;
			if (up) idx.push(center, a, d);
			else idx.push(center, d, a);
		}
	};
	if (capBottom) cap(0, false);
	if (capTop) cap(rings.length - 1, true);
	const geo = new THREE.BufferGeometry();
	geo.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
	geo.setAttribute('uv', new THREE.Float32BufferAttribute(uv, 2));
	geo.setIndex(idx);
	return weldNormals(geo);
}

// Tube along points with radius(t). Optional up(t) fixes the frame's normal; shape(t, cosAngleFromUp) scales the radius. Optional classify(t, radialDir, seg) -> material key; returns {key: geometry}.
export function tube(points, radius, { radial = 12, segs = 48, classify = null, closed = false, up = null, shape = null } = {}) {
	const curve = new THREE.CatmullRomCurve3(points, false, 'centripetal');
	const P = [], T = [];
	for (let i = 0; i <= segs; i++) {
		P.push(curve.getPointAt(i / segs));
		T.push(curve.getTangentAt(i / segs).normalize());
	}
	let N = new THREE.Vector3(0, 1, 0);
	if (Math.abs(N.dot(T[0])) > 0.9) N.set(1, 0, 0);
	N.sub(T[0].clone().multiplyScalar(N.dot(T[0]))).normalize();
	const pos = [], uv = [], dirs = [], axis = [];
	for (let i = 0; i <= segs; i++) {
		if (up) N.copy(up(i / segs)); // frame follows a given direction instead of parallel transport
		if (i > 0 || up) N.sub(T[i].clone().multiplyScalar(N.dot(T[i]))).normalize();
		const B = new THREE.Vector3().crossVectors(T[i], N);
		const r = radius(i / segs);
		for (let j = 0; j <= radial; j++) {
			const ph = (j / radial) * Math.PI * 2;
			const d = N.clone().multiplyScalar(Math.cos(ph)).add(B.clone().multiplyScalar(Math.sin(ph)));
			const rr = shape ? r * shape(i / segs, Math.cos(ph)) : r;
			pos.push(P[i].x + d.x * rr, P[i].y + d.y * rr, P[i].z + d.z * rr);
			axis.push(P[i].x, P[i].y, P[i].z);
			uv.push(j / radial, i / segs);
			dirs.push(d);
		}
	}
	const W = radial + 1;
	const groups = {};
	for (let i = 0; i < segs; i++)
		for (let j = 0; j < radial; j++) {
			const a = i * W + j, b = (i + 1) * W + j, c = b + 1, d = a + 1;
			const key = classify ? classify(i / segs, dirs[a].clone().add(dirs[c]).normalize(), i, j) : 'main';
			(groups[key] ??= []).push(a, b, d, d, b, c);
		}
	if (closed) {
		// Cap both ends with fans.
		for (const [ri, flip] of [[0, true], [segs, false]]) {
			const center = pos.length / 3;
			pos.push(P[ri].x, P[ri].y, P[ri].z);
			axis.push(P[ri].x, P[ri].y, P[ri].z);
			uv.push(0.5, 0.5);
			const key = classify ? classify(ri / segs, T[ri], ri) : 'main';
			for (let j = 0; j < radial; j++) {
				const a = ri * W + j, d = a + 1;
				(groups[key] ??= []).push(...(flip ? [center, d, a] : [center, a, d]));
			}
		}
	}
	const base = new THREE.BufferGeometry();
	base.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
	base.setAttribute('uv', new THREE.Float32BufferAttribute(uv, 2));
	// Point on the tube's axis for each vertex: skinning uses it, so a vertex follows its own stretch of tube.
	base.setAttribute('center', new THREE.Float32BufferAttribute(axis, 3));
	// Fix winding once using the first segment's center.
	const all = Object.values(groups).flat();
	base.setIndex(all);
	const before = all.slice(0, 3).join();
	orient(base, P[Math.min(1, segs)]);
	weldNormals(base);
	const flipped = base.index.array.slice(0, 3).join() !== before;
	const out = {};
	for (const [k, ids] of Object.entries(groups)) {
		const g = base.clone();
		const arr = flipped ? ids.slice() : ids;
		if (flipped) for (let i = 0; i < arr.length; i += 3) [arr[i + 1], arr[i + 2]] = [arr[i + 2], arr[i + 1]];
		g.setIndex(arr);
		out[k] = g;
	}
	return classify ? out : out.main;
}

export function ellipsoid(rx, ry, rz, ws = 16, hs = 10) {
	const g = new THREE.SphereGeometry(1, ws, hs);
	g.scale(rx, ry, rz);
	return g;
}

// Collects geometries per material and per named part, then builds merged meshes (static, no rig: ragdolls are Godot physics).
export class Builder {
	constructor(name) {
		this.name = name;
		this.parts = new Map(); // part -> Map(material -> geometries)
		this.flat = true; // faceted normals (BPD low poly style)
	}
	add(part, material, geo, { pos, rot, scale, lookAt } = {}) {
		const g = geo.clone();
		const q = new THREE.Quaternion();
		if (rot) q.setFromEuler(new THREE.Euler(...rot));
		if (lookAt) q.setFromUnitVectors(new THREE.Vector3(0, 1, 0), lookAt.clone().normalize());
		g.applyMatrix4(new THREE.Matrix4().compose(pos ?? new THREE.Vector3(), q, scale ? new THREE.Vector3(...scale) : new THREE.Vector3(1, 1, 1)));
		if (!this.parts.has(part)) this.parts.set(part, new Map());
		const byMat = this.parts.get(part);
		if (!byMat.has(material)) byMat.set(material, []);
		byMat.get(material).push(g);
		return g;
	}
	build() {
		const root = new THREE.Group();
		root.name = this.name;
		let tris = 0;
		for (const [part, byMat] of this.parts) {
			const node = new THREE.Group();
			node.name = part;
			for (const [material, geos] of byMat) {
				const clean = geos.map((c) => {
					for (const k of Object.keys(c.attributes)) if (!['position', 'normal', 'uv'].includes(k)) c.deleteAttribute(k);
					if (!c.attributes.normal) c.computeVertexNormals();
					if (!c.attributes.uv) c.setAttribute('uv', new THREE.Float32BufferAttribute(new Float32Array(c.attributes.position.count * 2), 2));
					return c.index ? c : c.setIndex([...Array(c.attributes.position.count).keys()]);
				});
				let merged = mergeGeometries(clean, false);
				// Low poly look (decision 12): every triangle gets its own face normal, so facets read as flat planes.
				if (this.flat) {
					merged = merged.toNonIndexed();
					merged.deleteAttribute('normal');
					merged.computeVertexNormals();
					merged.setIndex([...Array(merged.attributes.position.count).keys()]);
				}
				const mesh = new THREE.Mesh(merged, material);
				mesh.name = `${part}_${material.name}`;
				tris += merged.index.count / 3;
				node.add(mesh);
			}
			root.add(node);
		}
		root.userData.triangles = tris;
		return root;
	}
}

export const V = (x, y, z) => new THREE.Vector3(x, y, z);
