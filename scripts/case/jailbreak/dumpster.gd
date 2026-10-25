class_name Dumpster
extends StaticBody3D

## The dumpster on the station's sidewalk in the garbage truck jailbreak (docs/diseno/fuga-basura.md): the guard throws
## the bags in (`throw_in`), and the garbage truck empties it (step 3).

const MODEL := preload("res://assets/models/dumpster.glb")
const SIZE := Vector3(1.8, 1.1, 1.1)

## How many bags are in it.
var bags := 0


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
	bag.global_transform = Transform3D(Basis(Vector3.UP, bags * 1.3), inside() + Vector3(((bags % 3) - 1) * 0.45, 0, 0))


## Online: how many bags it holds (NpcSync).
func net_state() -> Variant:
	return bags


func apply_net_state(state: Variant) -> void:
	bags = state
