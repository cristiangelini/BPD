class_name TriedGlasses
extends Node3D

## A pair of glasses a cop tried on at the optician's (docs/diseno/allanamiento-optica.md, "Probarse anteojos"): it
## sits on the cop's face for SECONDS, where everyone sees it, and on the PC of the player who wears it the whole
## screen looks wrong: blurry, double, zoomed in or green. Trying another pair on swaps the look and starts the time
## again. Every number here is (propuesta).

const LOOKS: Array[String] = ["blurry", "double", "zoom", "green"]
const SECONDS := 8.0
const MODEL := preload("res://assets/models/loose_glasses.glb")
## Where the pair sits in the head's space: on the big round face, over the eyes, lenses forward, and how much bigger
## than a pair on the shelf it is so it fits that face.
const ON_FACE := Vector3(0, 0.0, -0.36)
const ON_FACE_SCALE := 2.2
const SHADER := """
shader_type canvas_item;

uniform sampler2D screen: hint_screen_texture, filter_linear;
uniform int mode = 0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 c = vec3(0.0);
	if (mode == 0) {
		for (int x = -3; x <= 3; x++) {
			for (int y = -3; y <= 3; y++) {
				c += texture(screen, uv + vec2(float(x), float(y)) * 0.006).rgb;
			}
		}
		c /= 49.0;
	} else if (mode == 1) {
		c = mix(texture(screen, uv + vec2(0.04, 0.01)).rgb, texture(screen, uv - vec2(0.04, 0.01)).rgb, 0.5);
	} else if (mode == 2) {
		c = texture(screen, vec2(0.5) + (uv - vec2(0.5)) / 3.0).rgb;
	} else {
		c = texture(screen, uv).rgb * vec3(0.3, 1.0, 0.35);
	}
	COLOR = vec4(c, 1.0);
}
"""

## "blurry", "double", "zoom" or "green".
var look := "blurry"
var left := SECONDS
## Only on the wearer's own PC: the layer over the screen that bends it.
var overlay: CanvasLayer
var _material: ShaderMaterial


## Puts a pair with `new_look` on `cop`'s face, or swaps the pair already there. `local`: this PC is the wearer's, so
## its screen changes too.
static func put_on(cop: Cop, new_look: String, local: bool) -> TriedGlasses:
	var glasses: TriedGlasses = cop.get_node("Head").get_node_or_null("TriedGlasses")
	if not glasses:
		glasses = TriedGlasses.new()
		glasses.name = "TriedGlasses"
		cop.get_node("Head").add_child(glasses)
		var pair: Node3D = MODEL.instantiate()
		pair.position = ON_FACE
		pair.rotation.y = PI
		pair.scale = Vector3.ONE * ON_FACE_SCALE
		glasses.add_child(pair)
		if local:
			# The wearer's own camera doesn't draw the frame right in front of it, like the rest of its own body.
			for mesh in pair.find_children("*", "VisualInstance3D", true, false):
				(mesh as VisualInstance3D).layers = 1 << (Cop.OWN_BODY_LAYER - 1)
			glasses._add_overlay()
	glasses.look = new_look
	glasses.left = SECONDS
	if glasses._material:
		glasses._material.set_shader_parameter("mode", LOOKS.find(new_look))
	return glasses


func _process(delta: float) -> void:
	left -= delta
	if left <= 0.0:
		queue_free()


func _add_overlay() -> void:
	overlay = CanvasLayer.new()
	# Under the HUD, so the hints and the prompts stay readable.
	overlay.layer = -1
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = SHADER
	_material = ShaderMaterial.new()
	_material.shader = shader
	rect.material = _material
	overlay.add_child(rect)
	add_child(overlay)
