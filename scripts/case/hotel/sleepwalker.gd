class_name Sleepwalker
extends HotelStaff

## The sleepwalking guest (hotel-allanamiento.md, "El sonámbulo"): at night he walks the neighborhood in his sleep and
## brings back whatever he finds; in the raid he walks upstairs, arms stretched out, back and forth along the corridor
## west of the wardrobe, mumbling. A cop who bumps into him (or E) wakes him up: he shouts (woke, the raid adds the
## complaint), stands there for AWAKE_SECONDS and falls asleep again. Every number here is (propuesta).

signal woke(at: Vector3)

const SPEED := 0.5
## His stretch of the corridor, on its north side (doña Escoba's cart takes the south one).
const WEST_X := Hotel.SUITE_X + 1.6
const EAST_X := 2.0
const WALK_Z := -0.45
const BUMP := 1.1
const AWAKE_SECONDS := 6.0
const MUMBLE_EVERY := 7.0
const MUMBLES := 3
const ROBE := Color(0.96, 0.95, 0.93)

var awake := false
var wakes := 0
var _awake_left := 0.0
var _heading := 1.0
var _mumble_left := 2.0
var _mumbles := 0


func _init() -> void:
	who = "guest"


func _ready() -> void:
	super()
	# Eyes shut instead of cucumbers, and both arms stretched out ahead.
	for id: String in ["cucumbers", "glasses"]:
		var own := part(id)
		if own:
			own.visible = false
	for side: float in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.12, 0.12, 0.6)
		arm.mesh = box
		arm.position = Vector3(side * 0.22, 1.0, 0.45)
		var material := StandardMaterial3D.new()
		material.albedo_color = ROBE
		arm.material_override = material
		add_child(arm)


func prompt_key(_cop: Cop) -> String:
	return "" if awake else "PROMPT_SLEEPWALKER"


## E on him: he wakes up.
func use(_cop: Cop) -> void:
	wake()


func wake() -> void:
	if awake:
		return
	awake = true
	wakes += 1
	_awake_left = AWAKE_SECONDS
	say("SLEEPWALKER_SHOUT", AWAKE_SECONDS)
	woke.emit(global_position)


## Online, what the guests' copy takes from the host's (NpcSync): whether he's awake and how many times he was woken.
func net_state() -> Array:
	return [awake, wakes]


func apply_net_state(state: Array) -> void:
	awake = state[0]
	wakes = state[1]


func _physics_process(delta: float) -> void:
	super(delta)
	if awake:
		_awake_left -= delta
		if _awake_left <= 0.0:
			awake = false
			_heading = -_heading
			say("SLEEPWALKER_ASLEEP")
		return
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var to := cop.global_position - global_position
		if Vector2(to.x, to.z).length() < BUMP and absf(to.y) < 1.0:
			wake()
			return
	_mumble_left -= delta
	if _mumble_left <= 0.0:
		_mumble_left = MUMBLE_EVERY
		say("SLEEPWALKER_MUMBLE_%d" % (_mumbles % MUMBLES))
		_mumbles += 1
	var target := WEST_X if _heading < 0.0 else EAST_X
	var step := target - position.x
	if absf(step) < 0.05:
		_heading = -_heading
		return
	position.x += signf(step) * minf(SPEED * delta, absf(step))
	rotation.y = -PI / 2 if _heading < 0.0 else PI / 2
