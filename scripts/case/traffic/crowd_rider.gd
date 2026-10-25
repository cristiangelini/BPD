class_name CrowdRider
extends ConvoyClown

## Someone out of a packed car at the traffic control (control-auto-lleno.md, "Cómo es", steps 3 and 5): opening its
## door pops them out one after the other, like a champagne cork, and they stand around chatting by the car. It won't
## go until they're all back in, as with the clown convoy's clowns (ConvoyClown, whose walking and boarding this
## keeps). Each one wears a city neighbor's model; some are kids, smaller. The driver hands the license; the others
## say they just came along. E on one not counted yet counts them (control-auto-lleno.md, step 4): a sticker with their
## number in the car's count goes on their chest and back, so no cop counts them twice. Every number here is (propuesta).

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
const STICKER := Color(0.98, 0.85, 0.15)

## Their number in the car's count, on a sticker; 0 while not counted.
var sticker := 0


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
	if sticker == 0:
		return "PROMPT_COUNT_RIDER"
	return "PROMPT_PAPERS" if is_driver else "PROMPT_CROWD_RIDER"


## E on them: counted, if they weren't yet; then the driver hands the license and the others say they came along.
func use(_cop: Cop) -> void:
	if sticker == 0 and is_instance_valid(car):
		car.count_rider(self)
	elif is_driver and is_instance_valid(car):
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


## The sticker with their number, on their chest and on their back.
func stick(number: int) -> void:
	sticker = number
	var height := 1.0 * (KID_SCALE if traits.get("kid", false) else 1.0)
	for back in [false, true]:
		var label := Label3D.new()
		label.name = "StickerBack" if back else "Sticker"
		label.text = str(number)
		label.font_size = 96
		label.pixel_size = 0.003
		label.modulate = Color(0.1, 0.1, 0.12)
		label.outline_modulate = STICKER
		label.outline_size = 40
		label.position = Vector3(0, height, -0.42 if back else 0.42)
		label.rotation.y = PI if back else 0.0
		add_child(label)
