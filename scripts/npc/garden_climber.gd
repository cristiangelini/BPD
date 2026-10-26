class_name GardenClimber
extends BlackoutInmate

## A gardener off over the wall up a giant magic bean (carcel-huerta.md, step 5): he walks to its foot and climbs it
## for CLIMB_TIME seconds, then drops down the other side (escaped). E while he's climbing pulls him down: he lands on
## his backside, cuffed, to be walked by the arm to a cell (BlackoutEscort). Every number here is (propuesta).

signal pulled_down(climber: GardenClimber)

const CLIMB_TIME := 10.0
const DROP_TIME := 0.8
## Past the wall he drops this far out.
const OUT := 1.5
const FALL_TIME := 0.4

## The giant he climbs, in the prison's space: its foot and its top over the wall.
var foot := Vector3.ZERO
var top := Vector3.ZERO
var climbing := false
var _climb: Tween


func prompt_key(cop: Cop) -> String:
	return "PROMPT_GARDEN_PULL_DOWN" if climbing else super(cop)


## E: while climbing, pulled down; otherwise as any inmate (the escort, once cuffed).
func use(cop: Cop) -> void:
	if climbing:
		pull_down()
		return
	super(cop)


func _physics_process(delta: float) -> void:
	if climbing or follower:
		return
	super(delta)
	if active and route_done() and not is_escaped:
		start_climb()


## Up the giant, from its foot to its top, then down the other side.
func start_climb() -> void:
	active = false
	climbing = true
	say("GARDEN_CLIMBING", CLIMB_TIME)
	var world := prison.global_transform
	var out := (top - foot)
	out.y = 0.0
	var over := top + out.normalized() * OUT
	over.y = PrisonLevel.FLOOR_TOP
	_climb = create_tween()
	_climb.tween_property(self, "global_position", world * foot, 0.3)
	_climb.tween_property(self, "global_position", world * top, CLIMB_TIME)
	_climb.tween_property(self, "global_position", world * over, DROP_TIME)
	_climb.tween_callback(_over)


func _over() -> void:
	climbing = false
	_escape()


## Pulled off the giant: down on his backside at its foot, cuffed.
func pull_down() -> void:
	if not climbing:
		return
	climbing = false
	if _climb:
		_climb.kill()
	var down := create_tween()
	down.tween_property(self, "global_position", prison.global_transform * foot, FALL_TIME).set_ease(Tween.EASE_IN)
	cuffed(Handcuffs.SECONDS)
	say("GARDEN_PULLED_DOWN")
	pulled_down.emit(self)
