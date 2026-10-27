class_name TvSabotage
extends Node

## The bought technician's sabotage (politico-debate.md, step 4, decision 230): during the blocks, every EVERY seconds
## he pulls one of 4 tricks on Lustre. A yellow light on the console and a click give it away WARN seconds before; then
## the cops have FIX seconds to undo it, or it's a blunder on air (TvDebate.blunder) and the control room undoes it.
## - "teleprompter": nonsense on his teleprompter. A cue card with a good answer held near him (CARD_REACH), or the
##   teleprompter unplugged, fixes it.
## - "camera": his camera turns off him. It's fixed when it frames him again (E on it, or pushed back).
## - "light": his spot goes out. A cop's flashlight on him, or the switch on the console, fixes it.
## - "mic": a duck, a horn or worse every time he speaks. The spare mic from the makeup room brought to him
##   (MIC_REACH) fixes it, and goes back to its table.
## Step 5 says who the technician is and stops him. Every number here is (propuesta).

signal warned(kind: String)
signal started(kind: String)
signal fixed(kind: String)
signal aired(kind: String)

enum Phase { NONE, WARN, ON }

const KINDS: Array[String] = ["teleprompter", "camera", "light", "mic"]
const EVERY := 15.0
const WARN := 3.0
const FIX := 6.0
const CARD_REACH := 2.5
const MIC_REACH := 1.5
## How far his camera turns away, in radians.
const TURN := 0.7
const BAD_LINES := 4
const NOISES := 3
const LUSTRE_CAMERA := 2
const LUSTRE_SPOT := 1

var studio: TvStudio
var debate: TvDebate
var phase := Phase.NONE
var kind := ""
var left := EVERY
## False once the technician can't touch the console any more (step 5).
var active := true
## Online, a guest's: the host's pulls the tricks.
var follower := false
var _last := ""
var _rng := RandomNumberGenerator.new()


func setup(the_studio: TvStudio, the_debate: TvDebate, seed_value: int) -> void:
	studio = the_studio
	debate = the_debate
	_rng.seed = hash(["tv sabotage", seed_value])
	studio.light_switch.pressed.connect(func() -> void: studio.set_spot(LUSTRE_SPOT, true))


func _physics_process(delta: float) -> void:
	if follower or debate.state != TvDebate.State.BLOCK:
		return
	match phase:
		Phase.NONE:
			if not active:
				return
			left -= delta
			if left <= 0.0:
				warn(_pick())
		Phase.WARN:
			left -= delta
			if left <= 0.0:
				pull()
		Phase.ON:
			if is_fixed():
				_end(true)
				return
			left -= delta
			if left <= 0.0:
				debate.blunder(kind)
				aired.emit(kind)
				_end(false)


## Another trick than the last one; never the teleprompter once it's unplugged.
func _pick() -> String:
	var choices := KINDS.filter(func(k: String) -> bool:
		return k != _last and (k != "teleprompter" or studio.prompter.plugged))
	return choices[_rng.randi() % choices.size()]


## The yellow light: `what` comes in WARN seconds.
func warn(what: String) -> void:
	kind = what
	phase = Phase.WARN
	left = WARN
	studio.set_warning(true)
	warned.emit(what)


## The trick itself.
func pull() -> void:
	phase = Phase.ON
	left = FIX
	_last = kind
	match kind:
		"teleprompter":
			studio.prompter.show_text("TV_PROMPTER_BAD_%d" % (_rng.randi() % BAD_LINES + 1))
			if debate.speaker == "lustre":
				studio.politician.say(studio.prompter.text(), FIX)
		"camera":
			var camera := studio.cameras[LUSTRE_CAMERA]
			camera.turn_to(camera.global_rotation.y + TURN * (1.0 if _rng.randf() < 0.5 else -1.0))
		"light":
			studio.set_spot(LUSTRE_SPOT, false)
		"mic":
			studio.politician.say("TV_MIC_NOISE_%d" % (_rng.randi() % NOISES + 1), FIX)
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_SABOTAGE_%s" % kind.to_upper())
	started.emit(kind)


## Whether the cops undid the trick on now.
func is_fixed() -> bool:
	var deputy := studio.politician
	var head := deputy.global_position + Vector3.UP * 1.3
	match kind:
		"teleprompter":
			if not studio.prompter.plugged:
				return true
			for prop: DebateProp in studio.props:
				if prop.kind == "card" and prop.is_held() and prop.global_position.distance_to(head) < CARD_REACH:
					return true
		"camera":
			return studio.cameras[LUSTRE_CAMERA].frames(head)
		"light":
			if studio.spot_on(LUSTRE_SPOT):
				return true
			for cop: Cop in get_tree().get_nodes_in_group("cops"):
				var belt: ToolBelt = cop.get("belt")
				if belt and belt.flashlight and belt.flashlight.reaches(head, deputy):
					return true
		"mic":
			var mic := studio.spare_mic
			if mic.global_position.distance_to(head) < MIC_REACH:
				studio.put_back_mic()
				return true
	return false


## The trick is over, fixed by the cops or after the blunder: everything back as it was.
func _end(by_cops: bool) -> void:
	match kind:
		"teleprompter":
			studio.prompter.show_text("TV_PROMPTER_OK")
		"camera":
			studio.cameras[LUSTRE_CAMERA].aim_at(studio.to_global(TvStudio.SHOTS[LUSTRE_CAMERA]))
		"light":
			studio.set_spot(LUSTRE_SPOT, true)
	if by_cops:
		fixed.emit(kind)
		for cop in get_tree().get_nodes_in_group("cops"):
			(cop as Cop).show_hint("HINT_SABOTAGE_FIXED")
	studio.set_warning(false)
	phase = Phase.NONE
	kind = ""
	left = EVERY
