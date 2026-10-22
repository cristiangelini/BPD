class_name HookStick
extends Grabbable

## Something long and absurd to fish with from a cell (fuga.md, step 3): the very long broom or the fishing rod
## without a hook. In hand it points where the camera looks and pokes out between the bars; E on a donut box at its
## tip hooks it, and from then on the box follows the tip (with one cop's strength) until E lets it go or it gets
## stuck more than SLIP from the tip. Only the grip collides, and only when nobody holds it, so in hand it goes through
## the bars. With the night guard asleep, E with the tip at his belt hooks the key off it, and the key (unlike the box)
## comes through the bars on the tip. Every number here is (propuesta).

const KG := 0.8
## How far ahead of the grip the tip is.
@export var length := 2.8
@export var model: PackedScene
## A box this far from the tip slips off the hook.
const SLIP := 1.0
## How close to the tip a box must be to hook it.
const CATCH := 0.6
## In hand it points a little down and to the right of where the cop looks, so the cop sees it along its length
## instead of end on.
const TILT := Vector2(0.06, -0.08)

var hooked: Grabbable
var _holder_cop: Cop


func _ready() -> void:
	add_to_group("hook_sticks")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.08, 0.08, 0.4)
	shape.shape = box
	add_child(shape)
	if model:
		add_child(model.instantiate())


## The end of the stick, in world space.
func tip() -> Vector3:
	return global_position - global_basis.z * length


## The cop holding it, if any.
func holder() -> Cop:
	var cops := handling_cops(0.0)
	return cops[0] if not cops.is_empty() else null


func held_prompt_key(_cop: Cop) -> String:
	if hooked:
		return "PROMPT_UNHOOK_BOX" if hooked is DonutBox else "PROMPT_UNHOOK_KEY"
	if box_at_tip():
		return "PROMPT_HOOK_BOX"
	return "PROMPT_HOOK_KEY" if _sleeping_belt() else "PROMPT_HOLDING_STICK"


## The donut box close enough to the tip to hook, if any.
func box_at_tip() -> DonutBox:
	var near: DonutBox
	var best := CATCH
	for node in get_tree().get_nodes_in_group("donut_boxes"):
		var box := node as DonutBox
		var distance := box.global_position.distance_to(tip())
		if distance <= best:
			near = box
			best = distance
	return near


## E with it in hand: hooks the box at the tip (or the sleeping guard's key), or lets the hooked one go.
func use(_cop: Cop) -> void:
	if not is_held():
		return
	if hooked:
		unhook()
		return
	hooked = box_at_tip()
	var guard := _sleeping_belt()
	if not hooked and guard:
		hooked = guard.key_at(tip())
		# A key on a stick goes between the bars.
		hooked.collision_mask = 0


## The sleeping guard whose belt (with the key) is at the tip, if any.
func _sleeping_belt() -> NightGuard:
	for guard: NightGuard in get_tree().get_nodes_in_group("night_guard"):
		if guard.is_asleep() and guard.key_on_belt and guard.belt().distance_to(tip()) <= NightGuard.BELT_REACH:
			return guard
	return null


func unhook() -> void:
	if hooked:
		hooked.let_go(get_instance_id())
		if hooked is CellKey:
			hooked.collision_mask = 15
	hooked = null


func _physics_process(delta: float) -> void:
	super(delta)
	var cop := holder()
	collision_mask = 0 if is_held() else 15
	if cop and is_held():
		# It points where its cop looks, so the tip goes where the cop aims.
		global_basis = cop.camera.global_basis * Basis.from_euler(Vector3(TILT.y, -TILT.x, 0))
		angular_velocity = Vector3.ZERO
	elif hooked:
		unhook()
	if hooked:
		if hooked.global_position.distance_to(tip()) > SLIP:
			unhook()
			if cop:
				cop.show_hint("HINT_HOOK_SLIPPED")
		else:
			hooked.hold(get_instance_id(), tip())
