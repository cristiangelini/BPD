class_name BankBlood
extends Node3D

## The blood bank (robo-banco-sangre.md, step 1, decision 128): the gang cut the power, so it's night in a dark bank
## with its ceiling lamps off and candles burning on the counter and the floor; the vault is a big white fridge with a
## red drop over its door, its shelves full of blood bags, and the hostages came to give blood (a band-aid on the arm).
## The robbers wear their vampire capes and fangs (BankRobber.vampire). Every number here is (propuesta).

## The candles (level positions): on the counter, by the hostages, by the entrance and in the corridor.
const CANDLES: Array[Vector3] = [
	Vector3(-8.0, 1.16, -1.0), Vector3(-4.0, 1.16, -1.0), Vector3(0.0, 1.16, -1.0), Vector3(4.0, 1.16, -1.0),
	Vector3(-5.0, 0.06, 3.6), Vector3(1.0, 0.06, 3.6), Vector3(-1.5, 0.06, 9.0), Vector3(1.5, 0.06, 9.0),
	Vector3(1.6, 0.06, -6.0), Vector3(1.6, 0.06, -9.0),
]
const WAX := Color(0.95, 0.93, 0.85)
const FLAME := Color(1.0, 0.7, 0.35)
const RED := Color(0.75, 0.08, 0.1)
const BAND_AID := Color(0.9, 0.72, 0.55)
## Where the band-aid sits on a crouched hostage (his root, which faces -Z).
const BAND_AID_AT := Vector3(0.27, 0.86, 0.0)
const NIGHT_AMBIENT := 0.25
const MOON := 0.08

var bank: BankLevel
var candles: Array[OmniLight3D] = []


func setup(the_bank: BankLevel) -> void:
	bank = the_bank
	name = "Blood"
	_night()
	bank.set_lights(false)
	for i in CANDLES.size():
		_candle(CANDLES[i], i)
	_drop()
	for hostage in bank.hostages:
		var band := MeshInstance3D.new()
		band.name = "BandAid"
		var strip := BoxMesh.new()
		strip.size = Vector3(0.03, 0.06, 0.12)
		band.mesh = strip
		band.material_override = _paint(BAND_AID)
		band.position = BAND_AID_AT
		hostage.add_child(band)


## The power is cut at night: a dark sky, a faint blue moon and little ambient light.
func _night() -> void:
	var world := bank.get_node_or_null("Environment") as WorldEnvironment
	if world and world.environment:
		var env := world.environment.duplicate(true) as Environment
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.02, 0.03, 0.07)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.3, 0.36, 0.6)
		env.ambient_light_energy = NIGHT_AMBIENT
		world.environment = env
	var sun := bank.get_node_or_null("Sun") as DirectionalLight3D
	if sun:
		sun.light_energy = MOON
		sun.light_color = Color(0.6, 0.7, 1.0)


## A lit candle on the floor or the counter, its flame flickering.
func _candle(at: Vector3, i: int) -> void:
	var candle := MeshInstance3D.new()
	candle.name = "Candle%d" % i
	var wax := CylinderMesh.new()
	wax.top_radius = 0.03
	wax.bottom_radius = 0.03
	wax.height = 0.2
	candle.mesh = wax
	candle.material_override = _paint(WAX)
	candle.position = at + Vector3.UP * 0.1
	add_child(candle)
	var flame := OmniLight3D.new()
	flame.light_color = FLAME
	flame.light_energy = 0.9
	flame.omni_range = 3.5
	flame.position = Vector3(0, 0.16, 0)
	candle.add_child(flame)
	candles.append(flame)
	var flicker := create_tween().set_loops()
	flicker.tween_property(flame, "light_energy", 0.55, 0.15 + 0.03 * i)
	flicker.tween_property(flame, "light_energy", 1.0, 0.2)


## The fridge's red drop, over its door on the corridor side.
func _drop() -> void:
	var drop := MeshInstance3D.new()
	drop.name = "Drop"
	var ball := SphereMesh.new()
	ball.radius = 0.22
	ball.height = 0.44
	drop.mesh = ball
	drop.material_override = _paint(RED)
	drop.position = Vector3(BankLevel.VAULT_X - 0.25, 2.9, BankLevel.VAULT_DOOR_Z)
	add_child(drop)
	var tip := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.19
	cone.height = 0.3
	tip.mesh = cone
	tip.material_override = drop.material_override
	tip.position = Vector3(0, 0.25, 0)
	drop.add_child(tip)


func _paint(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
