class_name DogFood
extends Grabbable

## Something for Mordisco to eat in the guard dog's jailbreak (docs/diseno/fuga-perro.md, step 2): on the dinner trays
## in the cells, in the break room's fridge and the guard's sandwich on his desk. Thrown or dropped, the dog smells it
## and eats it (GuardDog), and how much he likes it goes to the friendship of the cop who gave it: the last one who
## held it. Every number here is (propuesta).

## Kind -> [friendship, model].
const KINDS := {
	"sausage": [40.0, "res://assets/models/dog_sausage.glb"],
	"ham": [30.0, "res://assets/models/dog_ham.glb"],
	"cheese": [20.0, "res://assets/models/dog_cheese.glb"],
	"donut": [10.0, "res://assets/models/donut.glb"],
	"lettuce": [-10.0, "res://assets/models/dog_lettuce.glb"],
	"sandwich": [50.0, "res://assets/models/dog_sandwich.glb"],
}

@export var kind := "sausage"
var _giver: Cop


func _ready() -> void:
	add_to_group("dog_food")
	mass = 0.15
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.14, 0.05, 0.12)
	shape.shape = box
	add_child(shape)
	add_child((load(KINDS[kind][1]) as PackedScene).instantiate())


func friendship() -> float:
	return KINDS[kind][0]


func hold(holder_id: int, point: Vector3) -> void:
	super(holder_id, point)
	var grabber := instance_from_id(holder_id) as Node
	if grabber and grabber.get_parent() is Cop:
		_giver = grabber.get_parent()


## The cop who gave it: the last one who held it (null if nobody did).
func giver() -> Cop:
	return _giver if is_instance_valid(_giver) else null
