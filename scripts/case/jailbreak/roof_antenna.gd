class_name RoofAntenna
extends StaticBody3D

## The TV antenna on the roof in the roof jailbreak (docs/diseno/fuga-techo.md, step 3), on the edge the seed chose:
## a rope of sheets in hand, E ties it there and it hangs down the wall (`knots` keeps its knots); then E climbs down
## it (`climbed`, the level does the rest). A loose knot gives with two on it at once (`cut`).
## Every number here is (propuesta).

signal climbed(antenna: RoofAntenna, cop: Cop)

const MODEL := preload("res://assets/models/roof_antenna.glb")
## How many sheets reach the alley from the roof.
const FULL_ROPE := 4

## The sheets tied here (0: none) and their knots.
var sheets := 0
var knots: Array = []
## Which way is out, over the parapet (in the world).
var outward := Vector3.BACK
var _hanging: MeshInstance3D


func _ready() -> void:
	add_to_group("roof_antennas")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.4, 1.6, 0.4)
	shape.shape = box
	shape.position.y = 0.8
	add_child(shape)
	add_child(MODEL.instantiate())
	_hanging = MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.05
	cylinder.bottom_radius = 0.05
	var cloth := StandardMaterial3D.new()
	cloth.albedo_color = Color(0.93, 0.93, 0.9)
	# White sheets stand out in the dark.
	cloth.emission_enabled = true
	cloth.emission = Color(0.35, 0.35, 0.33)
	cylinder.material = cloth
	_hanging.mesh = cylinder
	add_child(_hanging)
	_refresh()


func is_tied() -> bool:
	return sheets > 0


func reaches_down() -> bool:
	return sheets >= FULL_ROPE


func prompt_key(cop: Cop) -> String:
	if cop.get_node("Grabber").held is SheetRope:
		return "PROMPT_TIE_ANTENNA"
	return "PROMPT_CLIMB_DOWN" if is_tied() else "PROMPT_ANTENNA"


func use(cop: Cop) -> void:
	var rope := cop.get_node("Grabber").held as SheetRope
	if rope:
		if multiplayer.is_server():
			tie(rope)
			cop.show_hint("HINT_ROPE_TIED" if reaches_down() else "HINT_ROPE_SHORT", true)
		return
	if is_tied():
		climbed.emit(self, cop)


## The host: `rope` (out of every hand) now hangs from here, a rope already here or not.
func tie(rope: SheetRope) -> void:
	for holder: Cop in rope.handling_cops(0.0):
		holder.get_node("Grabber").release()
	if is_tied():
		knots.append(false)
	knots.append_array(rope.knots)
	sheets += rope.sheets()
	rope.queue_free()
	_refresh()


## The first loose knot gives: the rope keeps the sheets above it.
func cut() -> void:
	var knot := knots.find(false)
	if knot < 0:
		return
	knots.resize(knot)
	sheets = knot + 1
	_refresh()


## Untied, after a catch.
func untie() -> void:
	sheets = 0
	knots.clear()
	_refresh()


func _refresh() -> void:
	_hanging.visible = is_tied()
	var length := sheets * SheetRope.SHEET_LENGTH
	(_hanging.mesh as CylinderMesh).height = maxf(length, 0.1)
	# Over the parapet, hanging down the wall from the parapet's top.
	_hanging.global_position = global_position + outward * 0.8 + Vector3.UP * (1.1 - length / 2)


## Online (NpcSync): the rope tied here.
func net_state() -> Variant:
	return [sheets, knots]


func apply_net_state(state: Variant) -> void:
	if sheets != int(state[0]) or knots != Array(state[1]):
		sheets = state[0]
		knots = (state[1] as Array).duplicate()
		_refresh()
