// Props of the karaoke "Karaoke El Desafine" (docs/diseno/allanamiento-karaoke.md): a stage speaker, the lyrics
// screen, the sound guy's console, the bar, the ice machine, a round table with its chairs, the disco ball, a booth's
// sofa, the owner's rack of sequin dresses, a stack of chairs and the neon note of the sign, with origins at the floor
// in the middle of each piece (the screen and the disco ball at their middle). Placeholder, not final art.
import { Builder, mat, V, THREE } from '../lib.js';

// A speaker 1.0 m wide, 1.8 m tall and 0.8 m deep, its front to +Z: black box, two woofers and a tweeter.
export function buildStageSpeaker() {
	const b = new Builder('stage_speaker');
	b.add('box', mat('speaker_black', 0x1c1d22), new THREE.BoxGeometry(1.0, 1.8, 0.8), { pos: V(0, 0.9, 0) });
	const cone = mat('speaker_cone', 0x3a3c44), rim = mat('speaker_rim', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 });
	for (const y of [0.5, 1.1]) {
		b.add('rim', rim, new THREE.CylinderGeometry(0.36, 0.36, 0.03, 16), { pos: V(0, y, 0.41), rot: [Math.PI / 2, 0, 0] });
		b.add('cone', cone, new THREE.CylinderGeometry(0.32, 0.1, 0.06, 16), { pos: V(0, y, 0.42), rot: [Math.PI / 2, 0, 0] });
	}
	b.add('tweeter', rim, new THREE.CylinderGeometry(0.1, 0.1, 0.04, 12), { pos: V(0, 1.55, 0.41), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// The lyrics screen, 5 m wide and 2.4 m tall: dark frame, blue screen and three lines of white "words".
export function buildLyricsScreen() {
	const b = new Builder('lyrics_screen');
	b.add('frame', mat('lyrics_frame', 0x202228), new THREE.BoxGeometry(5.0, 2.4, 0.1), { pos: V(0, 0, 0) });
	b.add('screen', mat('lyrics_blue', 0x2a3ad2, { emissive: 0x141a7a }), new THREE.BoxGeometry(4.8, 2.2, 0.01), { pos: V(0, 0, 0.055) });
	const word = mat('lyrics_word', 0xf6f4ee, { emissive: 0x909090 }), sung = mat('lyrics_sung', 0xf2c230, { emissive: 0x806010 });
	[[-1.2, 0.5, 7], [-1.6, 0, 8], [-1.0, -0.5, 6]].forEach(([x0, y, n], row) => {
		for (let i = 0; i < n; i++) b.add('word', row === 0 && i < 3 ? sung : word, new THREE.BoxGeometry(0.34, 0.16, 0.005), { pos: V(x0 + i * 0.42, y, 0.062) });
	});
	return b.build();
}

// The sound guy's console, 2.4 m wide (along X), 1.0 m tall, its front to +Z and its sloped panel full of knobs facing
// the back (-Z), where the sound guy stands.
export function buildSoundConsole() {
	const b = new Builder('sound_console');
	const body = mat('console_body', 0x2a2c34);
	b.add('desk', body, new THREE.BoxGeometry(2.4, 0.85, 0.8), { pos: V(0, 0.425, 0) });
	b.add('panel', mat('console_panel', 0x3a3e48), new THREE.BoxGeometry(2.3, 0.05, 0.7), { pos: V(0, 0.9, 0), rot: [-0.25, 0, 0] });
	const knob = mat('console_knob', 0xf6f4ee), red = mat('console_red', 0xd83a30, { emissive: 0x601010 });
	for (let i = 0; i < 10; i++) {
		for (const z of [-0.2, 0.05]) b.add('knob', knob, new THREE.CylinderGeometry(0.025, 0.025, 0.04, 8), { pos: V(-1.0 + i * 0.22, 0.92 + z * 0.25, z) });
		b.add('fader', red, new THREE.BoxGeometry(0.04, 0.03, 0.08), { pos: V(-1.0 + i * 0.22, 0.95, -0.25) });
	}
	b.add('volume', mat('console_volume', 0xf2c230), new THREE.CylinderGeometry(0.07, 0.07, 0.06, 12), { pos: V(1.0, 0.97, 0.2) });
	return b.build();
}

// The bar, 3.6 m wide (along X), its front to +Z, purple with a neon edge and four stools in front.
export function buildKaraokeBar() {
	const b = new Builder('karaoke_bar');
	b.add('bar', mat('kbar_purple', 0x5a2a8a), new THREE.BoxGeometry(3.6, 1.05, 0.7), { pos: V(0, 0.525, 0) });
	b.add('top', mat('kbar_top', 0x1c1d22), new THREE.BoxGeometry(3.7, 0.05, 0.8), { pos: V(0, 1.075, 0) });
	b.add('neon', mat('kbar_neon', 0xff5ad2, { emissive: 0xc02aa0 }), new THREE.BoxGeometry(3.6, 0.04, 0.02), { pos: V(0, 0.95, 0.36) });
	for (const x of [-1.35, -0.45, 0.45, 1.35]) {
		b.add('stool', mat('stool_chrome', 0xc8ccd2), new THREE.CylinderGeometry(0.03, 0.03, 0.7, 6), { pos: V(x, 0.35, 0.75) });
		b.add('seat', mat('kstool_seat', 0xff5ad2), new THREE.CylinderGeometry(0.18, 0.18, 0.08, 10), { pos: V(x, 0.74, 0.75) });
	}
	return b.build();
}

// The ice machine, 0.9 m wide, 1.0 m tall and 0.7 m deep, steel with a blue door, its front to +Z.
export function buildIceMachine() {
	const b = new Builder('ice_machine');
	b.add('box', mat('ice_steel', 0xb8bcc4, { metalness: 0.5, roughness: 0.35 }), new THREE.BoxGeometry(0.9, 1.0, 0.7), { pos: V(0, 0.5, 0) });
	b.add('door', mat('ice_door', 0x5aa0e0), new THREE.BoxGeometry(0.7, 0.4, 0.02), { pos: V(0, 0.7, 0.36) });
	b.add('handle', mat('ice_handle', 0x2a2c34), new THREE.BoxGeometry(0.4, 0.04, 0.04), { pos: V(0, 0.95, 0.38) });
	return b.build();
}

// A round table 0.9 m across and 0.75 m tall, with three chairs around it.
export function buildKaraokeTable() {
	const b = new Builder('karaoke_table');
	const dark = mat('ktable_dark', 0x1c1d22), seat = mat('kchair_seat', 0xd83a5a);
	b.add('top', mat('ktable_top', 0x6a4a8a), new THREE.CylinderGeometry(0.45, 0.45, 0.04, 16), { pos: V(0, 0.75, 0) });
	b.add('leg', dark, new THREE.CylinderGeometry(0.04, 0.04, 0.73, 8), { pos: V(0, 0.365, 0) });
	b.add('foot', dark, new THREE.CylinderGeometry(0.25, 0.25, 0.03, 12), { pos: V(0, 0.015, 0) });
	for (let i = 0; i < 3; i++) {
		const a = i * Math.PI * 2 / 3;
		const x = Math.sin(a) * 0.7, z = Math.cos(a) * 0.7;
		b.add('chair_seat', seat, new THREE.BoxGeometry(0.4, 0.05, 0.4), { pos: V(x, 0.45, z), rot: [0, a, 0] });
		b.add('chair_back', seat, new THREE.BoxGeometry(0.4, 0.4, 0.05), { pos: V(Math.sin(a) * 0.88, 0.67, Math.cos(a) * 0.88), rot: [0, a, 0] });
		b.add('chair_leg', dark, new THREE.CylinderGeometry(0.025, 0.025, 0.43, 6), { pos: V(x, 0.215, z) });
	}
	return b.build();
}

// The disco ball, 0.6 m across (its middle at the origin), mirror tiles and the chain it hangs from.
export function buildDiscoBall() {
	const b = new Builder('disco_ball');
	const mirror = mat('disco_mirror', 0xe8ecf2, { metalness: 0.3, roughness: 0.3, emissive: 0x404448 });
	b.add('ball', mirror, new THREE.IcosahedronGeometry(0.3, 1), { pos: V(0, 0, 0) });
	b.add('cap', mat('disco_cap', 0x8a8e94), new THREE.CylinderGeometry(0.05, 0.05, 0.06, 8), { pos: V(0, 0.31, 0) });
	b.add('chain', mat('disco_chain', 0x8a8e94), new THREE.CylinderGeometry(0.012, 0.012, 0.5, 6), { pos: V(0, 0.59, 0) });
	return b.build();
}

// A booth's sofa, 2.4 m wide (along X), its front to +Z: red velvet, with a little screen on the wall behind it.
export function buildBoothSofa() {
	const b = new Builder('booth_sofa');
	const velvet = mat('sofa_velvet', 0xa82a3a);
	b.add('seat', velvet, new THREE.BoxGeometry(2.4, 0.45, 0.7), { pos: V(0, 0.225, 0) });
	b.add('back', velvet, new THREE.BoxGeometry(2.4, 0.6, 0.2), { pos: V(0, 0.75, -0.25) });
	for (const x of [-1.15, 1.15]) b.add('arm', velvet, new THREE.BoxGeometry(0.15, 0.3, 0.7), { pos: V(x, 0.6, 0) });
	b.add('screen', mat('booth_screen', 0x2a3ad2, { emissive: 0x141a7a }), new THREE.BoxGeometry(0.9, 0.5, 0.04), { pos: V(0, 1.6, -0.33) });
	return b.build();
}

// The owner's rack of dresses, 1.2 m wide (along X) and 1.8 m tall: a chrome bar with three sequin dresses and a pink
// feather boa.
export function buildDressRack() {
	const b = new Builder('dress_rack');
	const chrome = mat('rack_chrome', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 });
	b.add('bar', chrome, new THREE.CylinderGeometry(0.02, 0.02, 1.2, 6), { pos: V(0, 1.75, 0), rot: [0, 0, Math.PI / 2] });
	for (const x of [-0.58, 0.58]) {
		b.add('pole', chrome, new THREE.CylinderGeometry(0.02, 0.02, 1.75, 6), { pos: V(x, 0.875, 0) });
		b.add('foot', chrome, new THREE.BoxGeometry(0.05, 0.03, 0.5), { pos: V(x, 0.015, 0) });
	}
	[0xd0d4dc, 0xf2c230, 0xff5ad2].forEach((color, i) => {
		b.add('dress', mat('dress_' + i, color, { metalness: 0.6, roughness: 0.25 }), new THREE.CylinderGeometry(0.1, 0.28, 1.1, 8), { pos: V(-0.36 + i * 0.36, 1.12, 0) });
	});
	b.add('boa', mat('boa_pink', 0xff8ad2), new THREE.TorusGeometry(0.16, 0.05, 6, 12), { pos: V(0.5, 1.6, 0.1), rot: [Math.PI / 2, 0, 0] });
	return b.build();
}

// A stack of six folding chairs, 0.5 m square and 1.5 m tall.
export function buildChairStack() {
	const b = new Builder('chair_stack');
	const seat = mat('kchair_seat', 0xd83a5a), dark = mat('ktable_dark', 0x1c1d22);
	for (let i = 0; i < 6; i++) {
		b.add('seat', seat, new THREE.BoxGeometry(0.45, 0.05, 0.45), { pos: V(0, 0.45 + i * 0.12, 0) });
		b.add('back', seat, new THREE.BoxGeometry(0.45, 0.35, 0.04), { pos: V(0, 0.65 + i * 0.12, -0.22) });
	}
	for (const [x, z] of [[-0.2, -0.2], [0.2, -0.2], [-0.2, 0.2], [0.2, 0.2]]) b.add('leg', dark, new THREE.BoxGeometry(0.03, 0.45, 0.03), { pos: V(x, 0.225, z) });
	return b.build();
}

// The neon note of the sign, 2.5 m tall: a pink eighth note glowing on the roof.
export function buildNeonNote() {
	const b = new Builder('neon_note');
	const neon = mat('note_neon', 0xff5ad2, { emissive: 0xd02ab0 });
	b.add('head', neon, new THREE.SphereGeometry(0.45, 12, 8), { pos: V(-0.3, 0.45, 0), scale: [1.3, 0.9, 0.5] });
	b.add('stem', neon, new THREE.BoxGeometry(0.14, 2.0, 0.14), { pos: V(0.22, 1.4, 0) });
	b.add('flag', neon, new THREE.BoxGeometry(0.7, 0.14, 0.14), { pos: V(0.5, 2.25, 0), rot: [0, 0, -0.6] });
	return b.build();
}

// A microphone stand 1.45 m tall up to its clip: round base, chrome pole and the clip on top.
export function buildMicStand() {
	const b = new Builder('mic_stand');
	const chrome = mat('mic_chrome', 0xc8ccd2, { metalness: 0.6, roughness: 0.3 }), black = mat('mic_black', 0x1c1d22);
	b.add('base', black, new THREE.CylinderGeometry(0.2, 0.22, 0.04, 12), { pos: V(0, 0.02, 0) });
	b.add('pole', chrome, new THREE.CylinderGeometry(0.015, 0.015, 1.4, 6), { pos: V(0, 0.72, 0) });
	b.add('clip', black, new THREE.CylinderGeometry(0.035, 0.03, 0.06, 8), { pos: V(0, 1.43, 0) });
	return b.build();
}

// A handheld microphone 0.22 m long, upright: black handle and a silver mesh head.
export function buildKaraokeMic() {
	const b = new Builder('karaoke_mic');
	b.add('handle', mat('mic_black', 0x1c1d22), new THREE.CylinderGeometry(0.022, 0.016, 0.16, 8), { pos: V(0, 0.08, 0) });
	b.add('ring', mat('mic_pink', 0xff5ad2), new THREE.CylinderGeometry(0.024, 0.024, 0.015, 8), { pos: V(0, 0.16, 0) });
	b.add('head', mat('mic_mesh', 0xd0d4dc, { metalness: 0.5, roughness: 0.4 }), new THREE.SphereGeometry(0.032, 10, 8), { pos: V(0, 0.19, 0) });
	return b.build();
}

export const models = {
	stage_speaker: buildStageSpeaker, lyrics_screen: buildLyricsScreen, sound_console: buildSoundConsole,
	karaoke_bar: buildKaraokeBar, ice_machine: buildIceMachine, karaoke_table: buildKaraokeTable,
	disco_ball: buildDiscoBall, booth_sofa: buildBoothSofa, dress_rack: buildDressRack, chair_stack: buildChairStack,
	neon_note: buildNeonNote, mic_stand: buildMicStand, karaoke_mic: buildKaraokeMic,
};

export const views = {
	karaoke: {
		items: [
			{ name: 'stage_speaker', pos: [-3.2, 0, -1.6] }, { name: 'lyrics_screen', pos: [-1.0, 1.6, -2.2] },
			{ name: 'stage_speaker', pos: [1.2, 0, -1.6] }, { name: 'sound_console', pos: [3.4, 0, -1.4] },
			{ name: 'karaoke_bar', pos: [3.2, 0, 1.4] }, { name: 'ice_machine', pos: [5.4, 0, 0.6] },
			{ name: 'karaoke_table', pos: [-1.0, 0, 0.8] }, { name: 'disco_ball', pos: [-1.0, 2.6, 0.8] },
			{ name: 'booth_sofa', pos: [-4.0, 0, 1.4], rotY: Math.PI / 2 }, { name: 'dress_rack', pos: [0.8, 0, 2.6] },
			{ name: 'chair_stack', pos: [-2.6, 0, 2.6] }, { name: 'mic_stand', pos: [-1.8, 0, -0.6] },
			{ name: 'karaoke_mic', pos: [-0.4, 0, -0.4] }, { name: 'neon_note', pos: [5.6, 0, -1.8] },
		],
		cam: { pos: [0.6, 4.0, 9.5], target: [0.6, 1.0, 0], fov: 50 },
	},
};
