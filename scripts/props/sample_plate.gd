class_name SamplePlate
extends Grabbable

## A sample on a paper plate (politico-mercado.md, step 3, decision 120): the vendor hands one to the deputy at each
## stall (MarketSamples). Some carry laxative; nobody can tell by looking. E with it in hand takes a bite to try it:
## a cop who bites a bad one finds out the hard way and gets cramps (Cramps, step 4). Bitten, it stays on the plate,
## smaller, so it can go back to the deputy. Online the host hands them out and the guests copy them (PropSync,
## net_setup); a bite happens on every PC with each one's copy of the cop (ActionSync), cramps included.

## A cop took a bite: `laxative` says what they found.
signal bitten(cop: Cop, laxative: bool)

const MODEL := preload("res://assets/models/sample_plate.glb")
## The bite's color for each stall's goods (MarketLevel.KINDS).
const COLORS := {
	"fruit": Color(0.85, 0.2, 0.15), "cheese": Color(0.95, 0.78, 0.3), "empanadas": Color(0.85, 0.63, 0.31),
	"fish": Color(0.55, 0.65, 0.72), "pickles": Color(0.3, 0.55, 0.17), "olives": Color(0.3, 0.33, 0.12),
	"bread": Color(0.78, 0.52, 0.23), "sweets": Color(0.95, 0.6, 0.72), "juice": Color(0.95, 0.63, 0.16),
	"meat": Color(0.72, 0.23, 0.23), "spices": Color(0.78, 0.23, 0.12), "ice_cream": Color(0.66, 0.91, 0.78),
}
## Shown bigger than it is, so it reads from across the aisle (like the rally's eggs).
const SHOWN := 1.5
## What's left of the bite after a cop tries it.
const BITTEN_SCALE := 0.6

var kind := "fruit"
var laxative := false
## A cop already tried it.
var tasted := false
var _bite: Node3D


func _ready() -> void:
	add_to_group("sample_plates")
	mass = 0.1
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.1 * SHOWN
	cylinder.height = 0.06 * SHOWN
	shape.shape = cylinder
	shape.position.y = 0.03 * SHOWN
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * SHOWN
	add_child(model)
	_bite = model.find_child("bite", true, false)
	var material := StandardMaterial3D.new()
	material.albedo_color = COLORS.get(kind, Color.WHITE)
	for mesh in _bite.find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
	if tasted:
		_set_tasted()


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_SAMPLE_TRIED" if tasted else "PROMPT_TASTE_SAMPLE"


## A bite: a cop tries it first, keeping the plate in hand.
func use(cop: Cop) -> void:
	if tasted:
		cop.show_hint("HINT_SAMPLE_TRIED")
		return
	_set_tasted()
	cop.show_hint("HINT_SAMPLE_BAD" if laxative else "HINT_SAMPLE_OK")
	if laxative:
		Cramps.give(cop)
	bitten.emit(cop, laxative)


func _set_tasted() -> void:
	tasted = true
	if _bite:
		_bite.scale = Vector3.ONE * BITTEN_SCALE


## Online (PropSync): what a guest's copy needs before it's added, its name included so a bite finds it.
func net_setup() -> Dictionary:
	return {"name": name, "kind": kind, "laxative": laxative, "tasted": tasted}
