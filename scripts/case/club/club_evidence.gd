class_name ClubEvidence
extends Node3D

## The club case's evidence (infiltracion.md, step 6b): the seed picks 3 of the 6 kinds and only those are in the
## club. Fotos of the card printing press in the storeroom (the camera), Doña Chela's earnings notebook on the office
## desk (the office opens with the key in a kitchen pot), the pre-marked cards in her bag on the stage (E), the
## recording of two grandparents talking business (stand by them RECORD_TIME with the camera in hand; while they talk
## they notice nothing), the loaded bingo cage (grab it) and the envelope of cash by the stage (grab it). The host
## decides what was found (`found`). The chapel (infiltracion-coro.md, step 5) has its own kinds: it sets which are
## found by holding them (`held_kinds`) and what its talkers say. Every number here is (propuesta).

signal found(kind: String)

const KINDS: Array[String] = ["press", "notebook", "bag", "recording", "cage", "envelope"]
const COUNT := 3
const RECORD_TIME := 5.0
const RECORD_REACH := 2.2
const TALK_EVERY := 4.0
const TALK_LINES := 4
const NOTEBOOK_MODEL := preload("res://assets/models/fight_notebook.glb")
const ENVELOPE_MODEL := preload("res://assets/models/cash_bundle.glb")

## The kinds in this place.
var kinds: Array[String] = []
## The kinds that count as soon as a cop holds them, and the talkers' lines (with the line's number).
var held_kinds: Array[String] = ["notebook", "envelope", "cage"]
var talk_key := "CLUB_TALK_%d"
## What each kind is in the club: a grabbable to hold, a spot to use or photograph, or the bingo cage.
var items := {}
## The two grandparents talking business, for the recording.
var talkers: Array[ClubMember] = []
## Kinds already found here.
var done: Array[String] = []
var recorded := 0.0
var _talk_left := 0.0
var _talk_line := 0


## 3 of the kinds in `available`, drawn with the seed.
static func draw(case_seed: int, available: Array[String]) -> Array[String]:
	var pool := available.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["club evidence", case_seed])
	var picked: Array[String] = []
	while picked.size() < COUNT and not pool.is_empty():
		picked.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))
	return picked


## A grabbable piece of evidence with `model`, `size` for its box.
static func make_item(item_name: String, model: PackedScene, size: Vector3, kg: float) -> Grabbable:
	var item := Grabbable.new()
	item.name = item_name
	item.collision_layer = 4
	item.collision_mask = 15
	item.mass = kg
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	item.add_child(shape)
	item.add_child(model.instantiate())
	return item


func _physics_process(delta: float) -> void:
	if talkers.size() == 2:
		_talk(delta)
	if not multiplayer.is_server():
		return
	for kind: String in held_kinds:
		var item: Node = items.get(kind)
		if item and is_instance_valid(item) and item.is_held():
			mark(kind)
	if talkers.size() == 2 and not done.has("recording"):
		if _recording_cop():
			recorded += delta
			if recorded >= RECORD_TIME:
				mark("recording")
		else:
			recorded = 0.0


## A cop with the camera in hand by both talkers.
func _recording_cop() -> Cop:
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if not cop.belt or not cop.belt.held_tool() is PhotoCamera:
			continue
		if talkers.all(func(member: ClubMember) -> bool:
				return member.global_position.distance_to(cop.global_position) <= RECORD_REACH):
			return cop
	return null


## The two talk business in turns (they don't move, so every PC says the same).
func _talk(delta: float) -> void:
	_talk_left -= delta
	if _talk_left > 0.0:
		return
	_talk_left = TALK_EVERY
	talkers[_talk_line % 2].say(talk_key % (_talk_line % TALK_LINES))
	_talk_line += 1


## The cops found `kind` (once each).
func mark(kind: String) -> void:
	if not kinds.has(kind) or done.has(kind):
		return
	done.append(kind)
	found.emit(kind)
