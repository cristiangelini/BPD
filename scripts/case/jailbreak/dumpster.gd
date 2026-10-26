class_name Dumpster
extends StaticBody3D

## The dumpster on the station's sidewalk in the garbage truck jailbreak (docs/diseno/fuga-basura.md): the guard throws
## the bags in (`throw_in`), and the garbage truck empties it (step 3). A cop climbs in or out with E.

const MODEL := preload("res://assets/models/dumpster.glb")
const SIZE := Vector3(1.8, 1.1, 1.1)

## How many bags are in it, and which.
var bags := 0
var contents: Array[GarbageBag] = []


func _ready() -> void:
	add_to_group("dumpsters")
	var model := MODEL.instantiate()
	add_child(model)
	# The walls and the bottom: open on top, so things (and cops) go in.
	for piece: Array in [[Vector3(0, 0.2, 0), Vector3(SIZE.x, 0.08, SIZE.z)],
			[Vector3(0, 0.7, -0.52), Vector3(SIZE.x, SIZE.y, 0.06)], [Vector3(0, 0.7, 0.52), Vector3(SIZE.x, SIZE.y, 0.06)],
			[Vector3(-0.87, 0.7, 0), Vector3(0.06, SIZE.y, SIZE.z)], [Vector3(0.87, 0.7, 0), Vector3(0.06, SIZE.y, SIZE.z)]]:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = piece[1]
		shape.shape = box
		shape.position = piece[0]
		add_child(shape)


## Where a bag lands inside it, in the world.
func inside() -> Vector3:
	return global_transform * Vector3(0, 0.25, 0)


## A bag thrown in: it sits inside, on top of the others.
func throw_in(bag: GarbageBag) -> void:
	bags += 1
	contents.append(bag)
	bag.global_transform = Transform3D(Basis(Vector3.UP, bags * 1.3), inside() + Vector3(((bags % 3) - 1) * 0.45, 0, 0))


## Whether a point in the world is inside it.
func contains(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.z / 2 and local.y > -0.1 and local.y < SIZE.y + 0.6


## The truck took everything.
func empty() -> void:
	bags = 0
	contents.clear()


func prompt_key(cop: Cop) -> String:
	return "PROMPT_DUMPSTER_OUT" if contains(cop.global_position) else "PROMPT_DUMPSTER_IN"


## In over the edge, or out onto the sidewalk in front.
func use(cop: Cop) -> void:
	if contains(cop.global_position):
		cop.global_position = global_transform * Vector3(0, 0.1, SIZE.z / 2 + 0.7)
	else:
		cop.global_position = inside() + Vector3.UP * 0.1


## Online: how many bags it holds (NpcSync).
func net_state() -> Variant:
	return bags


func apply_net_state(state: Variant) -> void:
	bags = state
