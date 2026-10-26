class_name PaperPile
extends Node3D

## A pile of papers on an office desk (docs/diseno/seguros.md, "Las pilas de papeles"): a cop who runs through it or
## something thrown at it sends the sheets flying all over, once. Only a joke, but the floor boss sees it (step 2).
## Every number here is (propuesta).

## `at` is over the pile, where the sheets fly up (what someone nearby sees).
signal scattered(at: Vector3)

const SIZE := Vector3(0.3, 0.2, 0.36)
## A cop this fast, or a thrown thing this fast, scatters it.
const SCATTER_SPEED := 2.5
const SHEETS := 10
const SHEET_SIZE := Vector3(0.21, 0.004, 0.3)
const SHEET_LIFE := 10.0
## How high over the pile the sheets are seen flying.
const FLY_HEIGHT := 0.6
const PAPER := Color(0.97, 0.96, 0.9)

var is_scattered := false
var _pile: MeshInstance3D


func _ready() -> void:
	_pile = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = SIZE
	var material := StandardMaterial3D.new()
	material.albedo_color = PAPER
	mesh.material = material
	_pile.mesh = mesh
	_pile.position.y = SIZE.y / 2
	add_child(_pile)
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 2 | 4
	area.position.y = SIZE.y / 2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE + Vector3(0.1, 0.1, 0.1)
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(_on_body)


func _on_body(body: Node3D) -> void:
	var speed := 0.0
	if body is Cop:
		speed = (body as Cop).velocity.length()
	elif body is RigidBody3D:
		speed = (body as RigidBody3D).linear_velocity.length()
	if speed >= SCATTER_SPEED:
		scatter()


## The sheets fly up and float down all over the place.
func scatter() -> void:
	if is_scattered:
		return
	is_scattered = true
	_pile.hide()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(global_position)
	var material := StandardMaterial3D.new()
	material.albedo_color = PAPER
	for i in SHEETS:
		var sheet := RigidBody3D.new()
		sheet.collision_layer = 0
		sheet.collision_mask = 1
		sheet.mass = 0.01
		sheet.linear_damp = 3.0
		sheet.angular_damp = 1.0
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = SHEET_SIZE
		shape.shape = box
		sheet.add_child(shape)
		var look := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = SHEET_SIZE
		mesh.material = material
		look.mesh = mesh
		sheet.add_child(look)
		sheet.position = Vector3(0, SIZE.y * (i + 0.5) / SHEETS, 0)
		add_child(sheet)
		sheet.linear_velocity = Vector3(rng.randf_range(-2.0, 2.0), rng.randf_range(2.0, 4.0), rng.randf_range(-2.0, 2.0))
		sheet.angular_velocity = Vector3(rng.randf_range(-6.0, 6.0), rng.randf_range(-6.0, 6.0), rng.randf_range(-6.0, 6.0))
		get_tree().create_timer(SHEET_LIFE).timeout.connect(sheet.queue_free)
	scattered.emit(global_position + Vector3.UP * FLY_HEIGHT)
