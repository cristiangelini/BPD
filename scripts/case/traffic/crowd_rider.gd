class_name CrowdRider
extends ConvoyClown

## Someone out of a packed car at the traffic control (control-auto-lleno.md, "Cómo es", steps 3 and 5): opening its
## door pops them out one after the other, like a champagne cork, and they stand around chatting by the car. It won't
## go until they're all back in, as with the clown convoy's clowns (ConvoyClown, whose walking and boarding this
## keeps). Each one wears a city neighbor's model; some are kids, smaller. The driver hands the license; the others
## say they just came along. Every number here is (propuesta).

const MODELS: Array[PackedScene] = [preload("res://assets/models/npc_cliente.glb"),
	preload("res://assets/models/npc_clienta.glb"), preload("res://assets/models/npc_abuelo.glb"),
	preload("res://assets/models/npc_abuela.glb"), preload("res://assets/models/npc_senora.glb"),
	preload("res://assets/models/npc_vecina.glb")]
const KID_SCALE := 0.7
## One in this many is a kid (never the driver).
const KID_ONE_IN := 4
const RIDER_LINES := 8
## Popped out of the car, they fly this long before they walk.
const FLY := 0.8


## Who rides in seat `i` of the car with `plate`: from both, so every PC agrees.
static func look_of(plate: String, i: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["crowd rider", plate, i])
	return {"model": rng.randi() % MODELS.size(), "kid": i > 0 and rng.randi() % KID_ONE_IN == 0}


func _build_look() -> void:
	_model = MODELS[int(traits.get("model", 0)) % MODELS.size()].instantiate()
	_model.name = "Model"
	if traits.get("kid", false):
		_model.scale = Vector3.ONE * KID_SCALE
	add_child(_model)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PAPERS" if is_driver else "PROMPT_CROWD_RIDER"


## E on them: the driver hands the license; the others say they just came along.
func use(_cop: Cop) -> void:
	if is_driver and is_instance_valid(car):
		car.papers_checked = true
		say(DriverTraits.license_text(car.driver))
	else:
		say(tr(_not_driver_key()))


func _grab_line_key(n: int) -> String:
	return "CROWD_RIDER_LINE_%d" % (n % RIDER_LINES)


func _not_driver_key() -> String:
	return "CROWD_NOT_DRIVER"


func _walks_after() -> float:
	return FLY
