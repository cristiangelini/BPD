class_name SoilTruckHorn
extends OfficePrinter

## The soil truck at the nursery's back gate (docs/diseno/allanamiento-vivero.md, "Su distracción, el camión de
## tierra"): E on its horn and the truck shows up behind the gate; Doña Hortensia goes to receive the soil bags and
## counts them with her back to everything (the floor boss's fix, on the same body). It works once every REST seconds,
## and the third time she catches on. Built at the gate, its outside to -z. Every number here is (propuesta).

## The horn sounded but this time she knows what's going on.
signal caught_on

const TRUCK_MODEL := preload("res://assets/models/moving_truck.glb")
const BAG_MODEL := preload("res://assets/models/soil_bag.glb")
const REST := 45.0
## The honks that take her away; from the next one on she catches on.
const FOOLS := 2
## Where the horn's button is (on a post by the gate, inside) and where the truck stands (outside).
const BUTTON_AT := Vector3(-3.4, 1.1, 0.4)
const TRUCK_AT := Vector3(0.0, 0.0, -3.2)

## Seconds left before a honk takes her away again.
var rest_left := 0.0
var honks := 0
var distractions := 0
var truck: Node3D
## The bags she counts by the gate while the truck is there.
var bags: Node3D


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.box(Vector3(BUTTON_AT.x, 0.6, BUTTON_AT.z - 0.12), Vector3(0.12, 1.2, 0.12), Color(0.35, 0.35, 0.38))
	button = PushButton.new()
	button.prompt = "PROMPT_NURSERY_HORN"
	button.color = Color(0.95, 0.75, 0.2)
	button.position = BUTTON_AT
	add_child(button)
	button.pressed.connect(press)
	truck = TRUCK_MODEL.instantiate()
	truck.position = TRUCK_AT
	truck.rotation.y = PI / 2
	truck.hide()
	add_child(truck)
	bags = Node3D.new()
	for i in 6:
		var bag: Node3D = BAG_MODEL.instantiate()
		bag.position = Vector3((i % 3) * 0.5 - 0.5, floorf(i / 3.0) * 0.15, 0.9)
		bags.add_child(bag)
	bags.hide()
	add_child(bags)


## A honk: the truck comes and she goes to count the bags, unless she counted some less than REST seconds ago, or it's
## the third time and she catches on.
func press(_cop: Cop = null) -> void:
	honks += 1
	if is_jammed or rest_left > 0.0:
		return
	if distractions >= FOOLS:
		caught_on.emit()
		rest_left = REST
		return
	distractions += 1
	is_jammed = true
	jobs += 1
	rest_left = REST
	truck.show()
	bags.show()
	jammed.emit()


## She's done counting: the truck leaves.
func fix() -> void:
	is_jammed = false
	truck.hide()
	bags.hide()


## Online, what the guests' truck takes from the host's (Nursery.net_state): Doña Hortensia is the host's, so when she's
## done counting there the truck leaves here too.
func net_state() -> Array:
	return [honks, distractions, rest_left, is_jammed]


func apply_net_state(state: Array) -> void:
	honks = state[0]
	distractions = state[1]
	rest_left = state[2]
	if is_jammed and not state[3]:
		fix()
	elif state[3] and not is_jammed:
		is_jammed = true
		truck.show()
		bags.show()


func is_counting() -> bool:
	return is_jammed


func _physics_process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
