class_name HumanSalonRig
extends GroomerRig

## The secret human salon (peluqueria.md, "Peluquería de humanos clandestina"): Ramiro cuts people's hair too, without
## a license. The appointment book is the main evidence (hidden), the wig and the mirror are extras. Among the dog hair
## on the grooming room floor there are tufts of human hair: they look the same until a flashlight lights them (the
## story's own clue). Every ARRIVE_EVERY seconds a human customer walks in and waits under a dryer with a towel over the
## head; lifting it is a clue too, and Ramiro doesn't like it. Every number here is (propuesta).

const TUFT_MODEL := preload("res://assets/models/hair_tuft.glb")
const CUSTOMER_SCRIPT := preload("res://scripts/npc/human_customer.gd")
## Cut hair on the grooming room floor; the first HUMAN_TUFTS of them (drawn with the seed) are human.
const TUFTS_AT: Array[Vector3] = [
	Vector3(1.6, Groomer.FLOOR_TOP, 3.4), Vector3(3.3, Groomer.FLOOR_TOP, 3.6), Vector3(2.0, Groomer.FLOOR_TOP, 5.2),
	Vector3(4.2, Groomer.FLOOR_TOP, 3.2), Vector3(5.8, Groomer.FLOOR_TOP, 3.9), Vector3(3.8, Groomer.FLOOR_TOP, 5.3),
	Vector3(0.8, Groomer.FLOOR_TOP, 4.2), Vector3(6.2, Groomer.FLOOR_TOP, 5.0),
]
const HUMAN_TUFTS := 3
## Light hair, like the dogs'; under the flashlight a human tuft shows black and straight.
const DOG_HAIR := Color(0.85, 0.78, 0.64)
const HUMAN_HAIR := Color(0.1, 0.08, 0.07)
## From the sidewalk through the front door and the grooming room door to the second dryer.
const ROUTE: Array[Vector3] = [
	Vector3(Groomer.ENTRANCE_X, Groomer.FLOOR_TOP, Groomer.HALF_Z + 1.5), Vector3(Groomer.ENTRANCE_X, Groomer.FLOOR_TOP, 5.5),
	Vector3(-1.0, Groomer.FLOOR_TOP, Groomer.GROOMING_DOOR_Z), Vector3(1.0, Groomer.FLOOR_TOP, Groomer.GROOMING_DOOR_Z),
	Vector3(5.0, Groomer.FLOOR_TOP, 5.15),
]
const FIRST_ARRIVAL := 10.0
const ARRIVE_EVERY := 40.0

var tufts: Array[Node3D] = []
var human_tufts: Array[Node3D] = []
var customer: HumanCustomer
var _arrive_wait := FIRST_ARRIVAL


func setup(place: Groomer) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = place.case_seed * 13 + 1
	var order: Array = range(TUFTS_AT.size())
	for i in order.size():
		var j := rng.randi_range(i, order.size() - 1)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for i in TUFTS_AT.size():
		tufts.append(_tuft(TUFTS_AT[i], i * 1.1))
	for k in HUMAN_TUFTS:
		human_tufts.append(tufts[order[k]])


func _tuft(at: Vector3, turn: float) -> Node3D:
	var model: Node3D = TUFT_MODEL.instantiate()
	model.position = at + Vector3.UP * 0.002
	model.rotation.y = turn
	groomer.add_child(model)
	var hair := StandardMaterial3D.new()
	hair.albedo_color = DOG_HAIR
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = hair
	model.set_meta("hair", hair)
	return model


## Whether a human tuft has been seen under the light (it stays black after).
func is_revealed(tuft: Node3D) -> bool:
	return (tuft.get_meta("hair") as StandardMaterial3D).albedo_color == HUMAN_HAIR


## A customer walks in.
func send_customer() -> HumanCustomer:
	customer = CUSTOMER_SCRIPT.new()
	customer.route.assign(ROUTE)
	customer.position = ROUTE[0]
	groomer.add_child(customer)
	customer.seated.connect(func() -> void:
		customer.cover()
		groomer.ramiro.cover_customer())
	customer.unmasked.connect(func(_who: HumanCustomer) -> void:
		groomer.raid.add_clue(tr("CLUE_HUMAN_CUSTOMER"))
		groomer.ramiro.customer_unmasked())
	customer.gone.connect(func() -> void: customer = null)
	return customer


func _physics_process(delta: float) -> void:
	_look_for_hair()
	if customer:
		return
	_arrive_wait -= delta
	if _arrive_wait <= 0.0:
		_arrive_wait = ARRIVE_EVERY
		send_customer()


func _look_for_hair() -> void:
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if not cop.belt or not cop.belt.flashlight.is_on:
			continue
		for tuft in human_tufts:
			if not is_revealed(tuft) and cop.belt.flashlight.lights(tuft.global_position):
				(tuft.get_meta("hair") as StandardMaterial3D).albedo_color = HUMAN_HAIR
				groomer.raid.add_clue(tr("CLUE_HUMAN_HAIR"))
