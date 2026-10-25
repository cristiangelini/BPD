class_name BankBlood
extends Node3D

## The blood bank (robo-banco-sangre.md, step 1, decision 128): the gang cut the power, so it's night in a dark bank
## with its ceiling lamps off and candles burning on the counter and the floor; the vault is a big white fridge with a
## red drop over its door, its shelves full of blood bags, and the hostages came to give blood (a band-aid on the arm).
## The robbers wear their vampire capes and fangs (BankRobber.vampire). Step 2: a vampire in a cop's flashlight beam
## (within LIGHT_REACH, in its cone and with nothing in between) hides behind his cape (BankRobber.lit). The fuse box by
## the back door (BankFuseBox) brings the bank's light back for LIGHTS_TIME: every vampire hides once and puts his
## sunglasses on; then El Conde has the light cut again. Online the host's decide (`follower`). Every number here is
## (propuesta).

signal lights_changed(on: bool)

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
## The flashlight scares a vampire this close (m), within its cone; it looks every LIGHT_EVERY seconds.
const LIGHT_REACH := 10.0
const LIGHT_EVERY := 0.1
## The light the fuse box brings back lasts this long (s).
const LIGHTS_TIME := 60.0
## The fuse box, on the corridor's back wall by the back door.
const FUSE_BOX_AT := Vector3(-2.0, 1.4, -9.98)

var bank: BankLevel
var candles: Array[OmniLight3D] = []
var fuse_box: BankFuseBox
## Seconds of light left (0: the power is cut).
var lights_left := 0.0
var follower := false
var _look_left := 0.0


func setup(the_bank: BankLevel) -> void:
	bank = the_bank
	name = "Blood"
	_night()
	bank.set_lights(false)
	for i in CANDLES.size():
		_candle(CANDLES[i], i)
	_drop()
	fuse_box = BankFuseBox.new()
	fuse_box.name = "FuseBox"
	fuse_box.position = FUSE_BOX_AT
	fuse_box.lights_on = lights_on
	fuse_box.switched.connect(func(_cop: Cop) -> void: turn_lights(true))
	bank.add_child(fuse_box)
	for hostage in bank.hostages:
		var band := MeshInstance3D.new()
		band.name = "BandAid"
		var strip := BoxMesh.new()
		strip.size = Vector3(0.03, 0.06, 0.12)
		band.mesh = strip
		band.material_override = _paint(BAND_AID)
		band.position = BAND_AID_AT
		hostage.add_child(band)


func lights_on() -> bool:
	return lights_left > 0.0


## The fuse box: the light back for LIGHTS_TIME, and every vampire hides from it once; or cut again.
func turn_lights(on: bool) -> void:
	lights_left = LIGHTS_TIME if on else 0.0
	bank.set_lights(on)
	fuse_box.show_on(on)
	if on:
		for robber in bank.robbers:
			robber.lit(true)
	lights_changed.emit(on)


func _physics_process(delta: float) -> void:
	if follower:
		return
	if lights_on():
		lights_left = maxf(lights_left - delta, 0.0)
		if not lights_on():
			# El Conde had someone cut it again.
			turn_lights(false)
			if bank.boss and not bank.boss.is_cuffed():
				bank.boss.say("ROBBER_CONDE_CUT")
	_look_left -= delta
	if _look_left > 0.0:
		return
	_look_left = LIGHT_EVERY
	for cop: Node in get_tree().get_nodes_in_group("cops"):
		var beam := beam_of(cop)
		if not beam:
			continue
		for robber in bank.robbers:
			if robber.visible and in_beam(beam, robber):
				robber.lit()


## A cop's flashlight beam if it's on, or null.
static func beam_of(cop: Node) -> SpotLight3D:
	if not cop is Cop or not (cop as Cop).belt:
		return null
	var flashlight := (cop as Cop).belt.flashlight
	if not flashlight or not flashlight.is_on or not flashlight.light or not flashlight.light.is_inside_tree():
		return null
	return flashlight.light


## Whether the robber's face is in the beam: near enough, in its cone and with no wall in between.
static func in_beam(beam: SpotLight3D, robber: BankRobber) -> bool:
	var from := beam.global_position
	var face := robber.global_position + Vector3.UP * BankRobber.EYE_HEIGHT
	var to := face - from
	if to.length() > LIGHT_REACH or to.length() < 0.01:
		return false
	if (-beam.global_basis.z).angle_to(to) > deg_to_rad(Flashlight.ANGLE):
		return false
	var ray := PhysicsRayQueryParameters3D.create(from, face, 1)
	return beam.get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


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
