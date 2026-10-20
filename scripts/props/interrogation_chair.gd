class_name InterrogationChair
extends Grabbable

## One of the cops' steel chairs in the interrogation room (interrogatorio.md, "Las acciones"): loose, so a cop can
## grab it and throw it. Landing hard near the suspect, it's the bad cop's chair (+15 nerves, +12 lawyer). E sits a cop
## on it, and near him that's the good cop sitting by his side (InterrogationCase.sat_down_by); E again stands up.

## How hard it has to land, in m/s, and how close to him (propuesta).
const THROW_SPEED := 3.0
const REACH := 4.0
## A cop who let go of it this recently threw it.
const THROWN_SECONDS := 2.0

## Where a sitting cop stands up: behind the chair, away from the table.
const STAND_BEHIND := 0.8

var _impacts := ImpactTracker.new()
var sitter: Cop


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var speed := _impacts.hardest(state)
	if speed > THROW_SPEED and holders.is_empty() and not handling_cops(THROWN_SECONDS).is_empty():
		_landed.call_deferred()


func _landed() -> void:
	var case := InterrogationCase.active(get_tree())
	if case and case.chair_thrown(self):
		# One throw counts once, however many times it bounces.
		let_go_at = -1


func prompt_key(cop: Cop) -> String:
	if sitter == cop:
		return "PROMPT_CHAIR_STAND"
	return "" if sitter or is_held() else "PROMPT_CHAIR_SIT"


func use(cop: Cop) -> void:
	if sitter == cop:
		stand_up()
		return
	if sitter or is_held():
		return
	sitter = cop
	cop.seated_in = self
	cop.add_collision_exception_with(self)
	freeze = true
	rotation = Vector3(0, rotation.y, 0)
	# Facing the way the chair faces: toward the table.
	cop.global_rotation.y = global_rotation.y + PI
	var case := InterrogationCase.active(get_tree())
	if case:
		case.sat_down_by(self, cop)


func stand_up() -> void:
	if not sitter:
		return
	var cop := sitter
	sitter = null
	cop.seated_in = null
	cop.remove_collision_exception_with(self)
	freeze = false
	cop.global_position = global_position + global_basis.z * STAND_BEHIND + Vector3.UP * 0.1


func _physics_process(_delta: float) -> void:
	if not sitter:
		return
	sitter.global_position = global_position + Vector3.UP * 0.05
	sitter.velocity = Vector3.ZERO
