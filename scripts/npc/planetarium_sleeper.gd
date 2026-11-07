class_name PlanetariumSleeper
extends StaticBody3D

## Doña Nebulosa (escena-planetario.md, "Las pistas"): the lady who goes to every show and sleeps in the front row, in
## her long coat, shawl and curlers. She's the witness: she half woke up at 3 in the morning and saw the culprit's
## planet pin. Woken gently, with a coffee from the hall's machine in hand (E), she tells it, if it's one of the case's
## clues. Without coffee, E only gets a snore and a hint; a second E without it shakes her. Shaken, shouted at or with a
## flashlight in her face, she takes offense and goes back to sleep for good. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_nebulosa.glb")
const LINES := 3
## A flashlight in her face from this close (m), within its cone and with nothing in between, offends her; a shout
## from this close too.
const LIGHT_REACH := 6.0
const SHOUT_REACH := 15.0
## Her face, seated.
const FACE_HEIGHT := 1.35

var case: CrimeSceneCase
var awake := false
var offended := false
var _pokes := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("planetarium_sleeper")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	part("eyes_open").visible = false
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.0
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if offended:
		return "PROMPT_SLEEPER_OFFENDED"
	if awake:
		return "PROMPT_SLEEPER_AWAKE"
	if cop and cop.get_node("Grabber").held is CoffeeCup:
		return "PROMPT_SLEEPER_COFFEE"
	return "PROMPT_SLEEPER"


## E on her: with a coffee in hand, she wakes up and tells what she saw; without it, a snore, and then a shake.
func use(cop: Cop) -> void:
	if offended:
		say("SLEEPER_LINE_%d" % (_lines_said % LINES))
		_lines_said += 1
		return
	if awake:
		tell()
		return
	var cup: Node = cop.get_node("Grabber").held if cop else null
	if cup is CoffeeCup:
		cop.get_node("Grabber").release()
		cup.queue_free()
		wake_up()
		return
	_pokes += 1
	if _pokes >= 2:
		offend()
		return
	say("SLEEPER_LINE_%d" % (_lines_said % LINES))
	_lines_said += 1
	if cop:
		cop.show_hint("HINT_SLEEPER_COFFEE")


## The coffee under her nose: her eyes open, and she tells what she saw.
func wake_up() -> void:
	awake = true
	_eyes(true)
	tell()


## What she saw at 3 in the morning: the culprit's planet pin, if she's the case's witness.
func tell() -> void:
	if case and case.plan.clues.has("witness"):
		say("SLEEPER_SAW_" + str(case.culprit().planet), 5.0)
		case.found("witness")
	else:
		say("SLEEPER_SAW_NOTHING", 5.0)


## Shaken, shouted at or blinded: she takes offense and goes back to sleep for good.
func offend() -> void:
	if offended:
		return
	offended = true
	awake = false
	_eyes(false)
	say("SLEEPER_OFFENDED", 4.0)
	if case:
		case.ruin("witness")


## A cop shouted (VoiceChat, through the case): close enough, it wakes her up in a bad mood.
func shouted_by(cop: Cop) -> void:
	if cop and cop.global_position.distance_to(global_position) <= SHOUT_REACH:
		offend()


func is_asleep() -> bool:
	return not part("eyes_open").visible


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	if offended or (case and case.follower):
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		var beam := BankBlood.beam_of(cop)
		if beam and in_beam(beam):
			offend()
			return


## Whether her face is in the beam: near enough, in its cone and with no wall in between.
func in_beam(beam: SpotLight3D) -> bool:
	var from := beam.global_position
	var face := global_position + Vector3.UP * FACE_HEIGHT
	var to := face - from
	if to.length() > LIGHT_REACH or to.length() < 0.01:
		return false
	if (-beam.global_basis.z).angle_to(to) > deg_to_rad(Flashlight.ANGLE):
		return false
	var ray := PhysicsRayQueryParameters3D.create(from, face, 1)
	return beam.get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


func _eyes(open: bool) -> void:
	part("eyes_open").visible = open
	part("eyes_shut").visible = not open
	part("zzz").visible = not open


## A part of her model by name (eyes_open, eyes_shut, zzz, hair).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D
