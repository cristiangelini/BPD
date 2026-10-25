class_name ChemicalToilet
extends Node3D

## The chemical toilet at the back of the market (politico-mercado.md, step 4, decision 120): a blue booth, its door to
## +Z. Whoever steps inside alone gets locked in: the door shuts for CURE_TIME and a cop's cramps are gone when it
## opens again. The deputy uses it too (MarketToiletRun: `occupy` with his own time). Only one at a time; the door
## opens outward. Online the host's decides who's in and for how long, and a guest's only shows it (MarketCase
## snapshot, `follower`). Every number here is (propuesta).

signal freed(who: Node3D)

const MODEL := preload("res://assets/models/chemical_toilet.glb")
const DOOR_MODEL := preload("res://assets/models/chemical_toilet_door.glb")
const CURE_TIME := 8.0
## Inside the booth, in its own space.
const INSIDE := AABB(Vector3(-0.5, 0, -0.55), Vector3(1.0, 2.2, 1.05))
const DOOR_OPEN := -1.6
const DOOR_SPEED := 4.0
## Where to stand in front of it, in its own space.
const FRONT := Vector3(0, 0, 1.3)

## Who's locked in, if anyone.
var occupant: Node3D
## Seconds until the door opens again.
var left := 0.0
## Online, a guest's toilet: it locks nobody in by itself (step 7).
var follower := false
var _door: Node3D
var _door_shape: CollisionShape3D
var _sign: MeshInstance3D
var _label: Label3D


func _ready() -> void:
	add_child(MODEL.instantiate())
	var booth := StaticBody3D.new()
	add_child(booth)
	for part: Array in [[Vector3(0, 1.2, -0.62), Vector3(1.2, 2.4, 0.08)],
			[Vector3(-0.57, 1.2, 0), Vector3(0.08, 2.4, 1.3)], [Vector3(0.57, 1.2, 0), Vector3(0.08, 2.4, 1.3)],
			[Vector3(0, 2.35, 0), Vector3(1.3, 0.1, 1.4)]]:
		booth.add_child(_box(part[0], part[1]))
	_door = Node3D.new()
	_door.name = "Door"
	_door.position = Vector3(-0.4, 0, 0.62)
	_door.rotation.y = DOOR_OPEN
	add_child(_door)
	var door_model: Node3D = DOOR_MODEL.instantiate()
	_door.add_child(door_model)
	_sign = door_model.find_child("sign", true, false).find_children("*", "MeshInstance3D", true, false)[0]
	var door_body := StaticBody3D.new()
	_door.add_child(door_body)
	_door_shape = _box(Vector3(0.4, 1.05, 0), Vector3(0.8, 2.1, 0.06))
	_door_shape.disabled = true
	door_body.add_child(_door_shape)
	_label = Label3D.new()
	_label.position = Vector3(0, 2.7, 0.7)
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.font_size = 40
	_label.outline_size = 10
	_label.pixel_size = 0.006
	_label.hide()
	add_child(_label)
	_show_sign()


func is_free() -> bool:
	return occupant == null


## Whether a world position is inside the booth.
func has_inside(at: Vector3) -> bool:
	return INSIDE.has_point(to_local(at))


## Locks `who` in for `seconds` (the door shuts).
func occupy(who: Node3D, seconds: float) -> void:
	occupant = who
	left = seconds
	_door_shape.disabled = false
	_show_sign()


func _physics_process(delta: float) -> void:
	var target := 0.0 if occupant else DOOR_OPEN
	_door.rotation.y = move_toward(_door.rotation.y, target, DOOR_SPEED * delta)
	if occupant:
		left = maxf(left - delta, 0.0)
		_label.text = tr("TOILET_BUSY") % ceili(left)
		if left <= 0.0 and not follower:
			_release()
		return
	if follower:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if has_inside(cop.global_position):
			occupy(cop, CURE_TIME)
			cop.show_hint("HINT_TOILET_IN")
			return


func _release() -> void:
	var who := occupant
	occupant = null
	_door_shape.disabled = true
	_show_sign()
	if who is Cop:
		let_out(who as Cop)
	freed.emit(who)


## The door opens for `cop`: cramps cured. A guest's toilet does it when the host's says so.
func let_out(cop: Cop) -> void:
	var had := Cramps.of(cop) != null
	Cramps.cure(cop)
	cop.show_hint("HINT_TOILET_RELIEF" if had else "HINT_TOILET_OUT")


## A guest's toilet: `who` is in (null: nobody) with `seconds` to go, as the host's says; a cop let out is cured.
func follow(who: Node3D, seconds: float) -> void:
	if who == occupant:
		left = seconds
		return
	var was := occupant
	occupant = null
	if was is Cop and is_instance_valid(was):
		let_out(was as Cop)
	if who:
		occupy(who, seconds)
		if who is Cop:
			(who as Cop).show_hint("HINT_TOILET_IN")
	else:
		_door_shape.disabled = true
		_show_sign()


func _show_sign() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.85, 0.2, 0.15) if occupant else Color(0.25, 0.85, 0.25)
	_sign.material_override = material
	_label.visible = occupant != null


func _box(at: Vector3, size: Vector3) -> CollisionShape3D:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	return shape
