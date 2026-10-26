class_name FogFlare
extends TrafficCone

## A lit cone for the fog (control-neblina.md, step 2): a traffic cone with an orange lamp on its tip that blinks,
## its glow showing through the fog. Standing up, a car passing close to it is warned and brakes in time (FogCar).
## There are four by the patrol car. Every number here is (propuesta).

const COLOR := Color("ff9a2a")
const TIP := Vector3(0, 0.74, 0)
const BLINK := 0.5
const ENERGY := 2.0
const RANGE := 4.0

var _light: OmniLight3D
var _glow: MeshInstance3D
var _blink_left := BLINK


func _ready() -> void:
	super._ready()
	add_to_group("fog_flares")
	var lamp := MeshInstance3D.new()
	lamp.name = "Lamp"
	var ball := SphereMesh.new()
	ball.radius = 0.06
	ball.height = 0.12
	var glass := StandardMaterial3D.new()
	glass.albedo_color = COLOR
	glass.emission_enabled = true
	glass.emission = COLOR
	glass.emission_energy_multiplier = 4.0
	glass.disable_fog = true
	ball.material = glass
	lamp.mesh = ball
	lamp.position = TIP
	add_child(lamp)
	_glow = FogCar.halo(COLOR)
	lamp.add_child(_glow)
	_light = OmniLight3D.new()
	_light.light_color = COLOR
	_light.light_energy = ENERGY
	_light.omni_range = RANGE
	lamp.add_child(_light)


## Lit while it stands: knocked over, its lamp faces the street and warns nobody.
func lit() -> bool:
	return standing()


func _process(delta: float) -> void:
	_blink_left -= delta
	if _blink_left <= 0.0:
		_blink_left = BLINK
		_glow.visible = not _glow.visible and lit()
		_light.visible = _glow.visible
