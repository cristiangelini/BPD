class_name FlourPrint
extends Node3D

## The footprint in the flour (escena-del-crimen.md, "Las pistas"): a white patch on the tent's floor with the
## culprit's shoe in it. A photo of it (PhotoCamera, "photo_clues") notes the shoe size; a cop who steps on it wipes
## it out. At the circus it's in the ring's sawdust (`dust`). Every number here is (propuesta).

## A cop's feet this close to its middle step on it, in meters.
const FOOT_REACH := 0.5
const FLOUR := Color(0.97, 0.96, 0.92)
const SOLE := Color(0.3, 0.28, 0.26)

var case: CrimeSceneCase
## The culprit's shoe size.
var shoe := 40
## What the step is pressed in: flour at the pastry contest, sawdust at the circus.
var dust := FLOUR
var wiped := false
var _soles: Array[MeshInstance3D] = []


func _ready() -> void:
	add_to_group("photo_clues")
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0.045, 0), Vector3(1.1, 0.01, 0.9), dust)
	# Two steps; longer shoes leave longer soles: about 6.6 mm per size.
	for step: Vector3 in [Vector3(-0.13, 0, 0.12), Vector3(0.13, 0, -0.15)]:
		builder.mesh_box(step + Vector3(0, 0.052, 0), Vector3(0.12, 0.006, shoe * 0.0066), SOLE)
		_soles.append(get_child(get_child_count() - 1) as MeshInstance3D)


## What a photo can catch here: its checklist line and the marks to aim at, while it can still be read.
func photo_clues() -> Dictionary:
	if wiped or not case or case.clues_found.has("footprint"):
		return {}
	return {case.clue_line("footprint"): [self]}


func add_clue(_line: String) -> void:
	if case:
		case.found("footprint")


func _physics_process(_delta: float) -> void:
	if wiped:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		var off := (cop as Node3D).global_position - global_position
		if Vector2(off.x, off.z).length() <= FOOT_REACH:
			wipe()
			return


## Stepped on: the sole is a smear now.
func wipe() -> void:
	wiped = true
	for sole in _soles:
		sole.scale = Vector3(3.0, 1.0, 1.4)
	if case:
		case.ruin("footprint")
