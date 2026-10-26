class_name DoubleSwap
extends Node

## The double's swaps at the lectern (politico-doble.md, step 2, decision 220). Each time the real deputy walks off the
## stage to greet the crowd (PoliticianWalks.walked_off), Rolo Calcado sneaks round the east side of the stage to its
## back (SNEAKING), drops his hat and scarf there the first time, climbs up behind the banner and takes the lectern
## (SPEAKING). There the speech is his (PoliticianSpeech.impostor): an outrage every line instead of the deputy's
## words, each one a stain on the real deputy's image. When the cops lead the real one back to the lectern, the double
## gives way: he goes down the ramp and mingles with the crowd like the deputy does (his own PoliticianWalks, which never
## walks off by itself), until the real one walks off again. Led by the hand to the lectern himself, he takes it.
## Step 3: cuffed, he's CAUGHT for good: off the lectern, and no more sneaking. It runs on the host. Every number here
## is (propuesta).

enum State { LURKING, SNEAKING, SPEAKING, MINGLING, CAUGHT }

const SPEED := 2.2
const ARRIVED := 0.5
## The way round the stage to its back, from the stage's middle (ground level): in front of the ramp's foot, past
## the stage's east end and behind the banner.
const ROUTE: Array[Vector3] = [Vector3(6.5, 0, 7.0), Vector3(6.5, 0, -3.5), Vector3(0, 0, -3.3)]

var real: Politician
var double: Politician
var speech: PoliticianSpeech
var real_walks: PoliticianWalks
var double_walks: PoliticianWalks
## The stage's middle at ground level, in world space.
var stage := Vector3.ZERO
var state := State.LURKING
## How many times he took the lectern.
var swaps := 0
var _path: Array[Vector3] = []


func setup(the_real: Politician, the_double: Politician, the_speech: PoliticianSpeech, stage_middle: Vector3) -> void:
	real = the_real
	double = the_double
	speech = the_speech
	stage = stage_middle
	real_walks = PoliticianWalks.of(real)
	double_walks = PoliticianWalks.of(double)
	double_walks.auto_walks = false
	double_walks.set_physics_process(false)
	real_walks.walked_off.connect(_on_real_walked_off)
	double.cuffed_now.connect(_on_caught)


## At the lectern now (the speech is his).
func double_speaking() -> bool:
	return state == State.SPEAKING


func _on_caught() -> void:
	state = State.CAUGHT
	if speech.impostor == double:
		speech.impostor = null
	double_walks.set_physics_process(false)
	double.velocity = Vector3.ZERO


func _on_real_walked_off() -> void:
	if state != State.LURKING and state != State.MINGLING:
		return
	# Being led by the hand somewhere, he doesn't get away.
	if double_walks.state == PoliticianWalks.State.LED:
		return
	sneak()


## Off round the back of the stage, to take the lectern.
func sneak() -> void:
	state = State.SNEAKING
	double_walks.set_physics_process(false)
	_path.clear()
	for step in ROUTE:
		_path.append(stage + step)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	match state:
		State.SNEAKING:
			if _walk(delta):
				_take_lectern()
		State.SPEAKING:
			# The cops are bringing the real one back: make way.
			if real_walks.state == PoliticianWalks.State.RETURNING:
				_give_way()
		State.MINGLING:
			# Led onto the stage to the lectern by a cop who took him for the real one.
			if double_walks.state == PoliticianWalks.State.SPEAKING:
				_at_lectern()
				# The real one makes way, as if he'd walked off to greet.
				if real_walks.state == PoliticianWalks.State.SPEAKING:
					real_walks.walk_off()


func _take_lectern() -> void:
	if double.disguised:
		double.disguise(false)
	double.global_position = double_walks.podium
	double.velocity = Vector3.ZERO
	double_walks.state = PoliticianWalks.State.SPEAKING
	double_walks.set_physics_process(true)
	_at_lectern()


func _at_lectern() -> void:
	state = State.SPEAKING
	swaps += 1
	double.rotation.y = PI
	speech.impostor = double
	double.say("DOUBLE_TAKES_LECTERN")


func _give_way() -> void:
	state = State.MINGLING
	speech.impostor = null
	double_walks.walk_off()
	double.say("DOUBLE_GIVES_WAY")


## Along _path; true once at its end.
func _walk(delta: float) -> bool:
	var to := _path[0] - double.global_position
	to.y = 0.0
	if to.length() < ARRIVED:
		_path.remove_at(0)
		if _path.is_empty():
			return true
	var wish := to.normalized() * SPEED if not _path.is_empty() else Vector3.ZERO
	if wish.length() > 0.05:
		double.look_at(double.global_position + wish, Vector3.UP)
	double.velocity.x = wish.x
	double.velocity.z = wish.z
	double.velocity.y = 0.0 if double.is_on_floor() else double.velocity.y - GameScale.GRAVITY * delta
	double.move_and_slide()
	return false
