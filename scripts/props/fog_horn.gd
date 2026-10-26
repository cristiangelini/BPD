class_name FogHorn
extends Grabbable

## The patrol car's foghorn (control-neblina.md, step 3): E with it in hand and it goes "¡BUUUUH!", and every car in
## the fog answers with its own horn (QueueCar.honk_back), each bubble over its car seen through the fog; the further
## the car, the later it answers. Then it needs COOLDOWN seconds. Every PC blows it (ActionSync), and each one's cars
## answer there. Every number here is (propuesta).

const MODEL := preload("res://assets/models/fog_horn.glb")
const KG := 1.2
const COOLDOWN := 10.0
## The cars this close answer, each after a moment for every ANSWER_RATE m away (at most ANSWER_MAX s).
const REACH := 80.0
const ANSWER_RATE := 40.0
const ANSWER_MAX := 1.5

var cooldown_left := 0.0
var bubble: HornBubble


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.24, 0.25, 0.49)
	shape.shape = box
	shape.position = Vector3(0, 0.125, 0.03)
	add_child(shape)
	add_child(MODEL.instantiate())
	bubble = HornBubble.new()
	bubble.name = "Bubble"
	bubble.position = Vector3(0, 0.5, 0)
	add_child(bubble)


func _ready() -> void:
	add_to_group("fog_horns")


## Online (PropSync): a guest makes its copy from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_FOGHORN" if cooldown_left <= 0.0 else "PROMPT_FOGHORN_WAIT"


func use(_cop: Cop = null) -> void:
	blow()


## "¡BUUUUH!": the cars in the fog answer. Not again for COOLDOWN seconds.
func blow() -> bool:
	if cooldown_left > 0.0:
		return false
	cooldown_left = COOLDOWN
	bubble.say(tr("FOGHORN_SOUND"))
	for car: QueueCar in get_tree().get_nodes_in_group("queue_cars"):
		if not car.fog_mode or car.state == "gone":
			continue
		var away := car.global_position.distance_to(global_position)
		if away <= REACH:
			car.honk_back(minf(away / ANSWER_RATE, ANSWER_MAX))
	return true


## In _process: a guest's copy has no physics of its own (PropSync), and its cooldown runs too.
func _process(delta: float) -> void:
	cooldown_left = maxf(cooldown_left - delta, 0.0)
