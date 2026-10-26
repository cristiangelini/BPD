class_name HornBubble
extends Node3D

## A horn's sound over a car in the fog (control-neblina.md, step 3): drawn on the screen over where the car is, not
## in the world, so the fog doesn't swallow it (a Label3D fades into the fog like the car). It shows SECONDS, and only
## while the car is in front of the camera and within REACH. Every number here is (propuesta).

const SECONDS := 3.0
const REACH := 80.0
const FONT_SIZE := 26
const COLOR := Color(1, 0.95, 0.6)

## What it says, and seconds it still shows.
var text := ""
var left := 0.0
var _layer: CanvasLayer
var _label: Label


func _ready() -> void:
	_layer = CanvasLayer.new()
	add_child(_layer)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", FONT_SIZE)
	_label.add_theme_color_override("font_color", COLOR)
	_label.add_theme_constant_override("outline_size", 8)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.hide()
	_layer.add_child(_label)


func say(value: String) -> void:
	text = value
	left = SECONDS
	_label.text = value
	_place()


func showing() -> bool:
	return left > 0.0


func _process(delta: float) -> void:
	if left <= 0.0:
		return
	left -= delta
	_place()


func _place() -> void:
	var camera := get_viewport().get_camera_3d() if is_inside_tree() else null
	var on := left > 0.0 and camera != null and not camera.is_position_behind(global_position) \
		and camera.global_position.distance_to(global_position) <= REACH
	_label.visible = on
	if on:
		_label.reset_size()
		_label.position = camera.unproject_position(global_position) - Vector2(_label.size.x / 2, _label.size.y)
