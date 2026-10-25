class_name CityWalker
extends Node3D

## Someone walking the city's sidewalks (ciudad-viva.md, step 3): round and round their block, with a little bob and
## sway, at their own pace. The street events pick them later. Every number here is (propuesta).

const MODELS_DIR := "res://assets/models/npc_%s.glb"
const PACE_MIN := 1.0
const PACE_MAX := 1.5
const REACH := 0.4

@export var look := "cliente"
## Their loop of points on the sidewalk, in walking order.
var path := PackedVector3Array()
var next := 0
var pace := 1.2
var _model: Node3D
var _time := 0.0


func _ready() -> void:
	add_to_group("city_walkers")
	pace = randf_range(PACE_MIN, PACE_MAX)
	_time = randf() * 10.0
	var scene: PackedScene = load(MODELS_DIR % look)
	_model = scene.instantiate()
	add_child(_model)


## Puts them `along` (0 to 1) their loop, facing the way they walk.
func place_along(along: float) -> void:
	var i := int(fposmod(along, 1.0) * path.size()) % path.size()
	var b := path[(i + 1) % path.size()]
	position = path[i].lerp(b, fposmod(along * path.size(), 1.0))
	next = (i + 1) % path.size()
	var ahead := b - path[i]
	rotation.y = atan2(ahead.x, ahead.z)


func _process(delta: float) -> void:
	if path.is_empty():
		return
	_time += delta
	var to := path[next] - position
	to.y = 0.0
	if to.length() < REACH:
		next = (next + 1) % path.size()
		return
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), minf(1.0, 6.0 * delta))
	position += to.normalized() * pace * delta
	_model.position.y = absf(sin(_time * pace * 5.0)) * 0.06
	_model.rotation.z = sin(_time * pace * 5.0) * 0.05
