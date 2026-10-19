class_name Neighbor
extends Node3D

## The vecina chismosa (investigacion.md, "Más personajes en la casa"): she watches from the window of the house next
## door. E on her: she wants back the tupperware the grandpa never returned. Bring it to her window and she tells what
## she saw (`clue`, set by the house). Built in code: a small house whose front (+Z) has the window.

## She asked for her tupperware (the checklist shows the errand).
signal asked
## She got it back and told what she saw: the checklist line, already translated.
signal told(text: String)

const WIDTH := 5.0
const DEPTH := 4.0
const HEIGHT := 3.0
const WALL := 0.2
const WINDOW_WIDTH := 1.4
const SILL := 1.0
const WINDOW_TOP := 2.1
## She calls cops closer than this, every PSST_EVERY seconds, until someone talks to her (propuesta).
const PSST_RANGE := 9.0
const PSST_EVERY := 8.0
const BRICK := Color(0.85, 0.62, 0.55)
const ROOF := Color(0.55, 0.3, 0.28)
const FRAME := Color(0.96, 0.95, 0.9)
const LADY_SCENE := preload("res://assets/models/npc_vecina.glb")

## The checklist line for what she saw, and the longer thing she says (both translated, set by the house).
var clue := ""
var clue_speech := ""
var was_asked := false
var returned := false
var _since_psst := PSST_EVERY

var lady: StaticBody3D
var _bubble: Label3D


func _ready() -> void:
	# The walls hang from a plain node, so aiming at them doesn't talk to her (Cop._usable_target checks the parent).
	var shell := Node3D.new()
	add_child(shell)
	var walls := StaticBody3D.new()
	shell.add_child(walls)
	var side := (WIDTH - WINDOW_WIDTH) / 2.0
	var front := 0.0
	_box(walls, Vector3(-(WINDOW_WIDTH + side) / 2.0, HEIGHT / 2.0, front), Vector3(side, HEIGHT, WALL), BRICK)
	_box(walls, Vector3((WINDOW_WIDTH + side) / 2.0, HEIGHT / 2.0, front), Vector3(side, HEIGHT, WALL), BRICK)
	_box(walls, Vector3(0, SILL / 2.0, front), Vector3(WINDOW_WIDTH, SILL, WALL), BRICK)
	_box(walls, Vector3(0, (WINDOW_TOP + HEIGHT) / 2.0, front), Vector3(WINDOW_WIDTH, HEIGHT - WINDOW_TOP, WALL), BRICK)
	_box(walls, Vector3(0, SILL + 0.02, front + 0.12), Vector3(WINDOW_WIDTH + 0.2, 0.05, 0.25), FRAME)
	_box(walls, Vector3(0, HEIGHT / 2.0, -DEPTH), Vector3(WIDTH, HEIGHT, WALL), BRICK)
	for x in [-WIDTH / 2.0, WIDTH / 2.0]:
		_box(walls, Vector3(x, HEIGHT / 2.0, -DEPTH / 2.0), Vector3(WALL, HEIGHT, DEPTH), BRICK)
	_box(walls, Vector3(0, HEIGHT + 0.1, -DEPTH / 2.0), Vector3(WIDTH + 0.4, 0.2, DEPTH + 0.4), ROOF)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.4, -1.5)
	lamp.omni_range = 5.0
	add_child(lamp)

	lady = StaticBody3D.new()
	# On a stool, so she leans out over the sill.
	lady.position = Vector3(0, 0.45, -0.6)
	# A box filling the window, so aiming anywhere through it reaches her.
	var shape := CollisionShape3D.new()
	var body := BoxShape3D.new()
	body.size = Vector3(WINDOW_WIDTH, WINDOW_TOP, 0.6)
	shape.shape = body
	shape.position.y = WINDOW_TOP / 2.0 - lady.position.y
	lady.add_child(shape)
	lady.add_child(LADY_SCENE.instantiate())
	add_child(lady)

	# Anything dropped or thrown onto the sill or through the window reaches her.
	var window := Area3D.new()
	window.name = "Window"
	window.collision_layer = 0
	window.collision_mask = 4
	var hole := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(WINDOW_WIDTH + 0.4, WINDOW_TOP - SILL + 0.4, 1.6)
	hole.shape = box
	hole.position = Vector3(0, (SILL + WINDOW_TOP) / 2.0, 0.1)
	window.add_child(hole)
	window.body_entered.connect(_on_window_entered)
	add_child(window)

	_bubble = Label3D.new()
	_bubble.position = Vector3(0, WINDOW_TOP + 0.35, 0.8)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## E on her: the first time she asks for her tupperware; once she has it, she repeats what she saw.
func prompt_key(_cop: Cop) -> String:
	return "PROMPT_NEIGHBOR"


func use(_cop: Cop) -> void:
	if returned:
		_say(clue_speech, 6.0)
		return
	_say("NEIGHBOR_WAITING" if was_asked else "NEIGHBOR_ASK", 5.0)
	if not was_asked:
		was_asked = true
		asked.emit()


## The tupperware reaches her window: whoever holds it lets go, she takes it in and tells.
func take(item: RigidBody3D) -> void:
	if returned:
		return
	returned = true
	was_asked = true
	for cop in get_tree().get_nodes_in_group("cops"):
		var grabber := cop.get_node_or_null("Grabber")
		if grabber and grabber.held == item:
			grabber.release()
	item.queue_free()
	_say(clue_speech, 8.0)
	told.emit(clue)


func _physics_process(delta: float) -> void:
	if was_asked:
		return
	_since_psst += delta
	if _since_psst < PSST_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= PSST_RANGE:
			_since_psst = 0.0
			_say("NEIGHBOR_PSST")
			return


func _on_window_entered(body: Node3D) -> void:
	if body.is_in_group("tupperware"):
		take(body as RigidBody3D)


func _say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	var said := text
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())


func _box(body: StaticBody3D, center: Vector3, size: Vector3, color: Color) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = center
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	cube.material = material
	mesh.mesh = cube
	mesh.position = center
	body.add_child(mesh)
