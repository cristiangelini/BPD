class_name BusInmate
extends PrisonInmate

## An inmate on the transfer bus (traslado-presos.md, step 2, decision 105): sitting in their seat with their cuffs
## chained to the ring by the window, a child of the bus so they go along with it. Each one has an escape `plan` from
## 0 to FULL that TransferPlan fills while no cop watches them; at HINT_AT "..." shows over their head and at
## WARN_AT a red "!", and full, they say they're about to try something (their trick comes in step 3). Every number
## here is (propuesta).

const FULL := 100.0
const HINT_AT := 50.0
const WARN_AT := 80.0
## Where the chest is, for a cop's look (TransferPlan.watched), above the inmate's origin on the seat.
const SEATED_CHEST := 0.9
const READY_LINES := 3

## The bus they ride and the seat (0 to 7, PrisonBus.seat_spot). Set before they're added.
var bus: PrisonBus
var seat := 0
var plan := 0.0
## In their seat with the cuffs on the ring.
var seated := true
var _mark: Label3D


func _ready() -> void:
	super()
	add_to_group("bus_inmates")
	# A child of the bus: its own body would push the bus from inside.
	if bus:
		add_collision_exception_with(bus)
	_mark = Label3D.new()
	_mark.name = "Plan"
	_mark.font_size = 110
	_mark.pixel_size = 0.004
	_mark.outline_size = 14
	_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_mark.position = Vector3(0, 1.45, 0)
	_mark.hide()
	add_child(_mark)
	_update()


## Sits them in their seat of the bus, facing forward.
func sit() -> void:
	seated = true
	transform = Transform3D(Basis(Vector3.UP, PI), PrisonBus.seat_spot(seat))
	_update()


func set_plan(value: float) -> void:
	var was_full := plan >= FULL
	plan = clampf(value, 0.0, FULL)
	_mark.visible = plan >= HINT_AT
	_mark.text = "!" if plan >= WARN_AT else "..."
	_mark.modulate = Color(1, 0.25, 0.2) if plan >= WARN_AT else Color(1, 0.85, 0.3)
	if plan >= FULL and not was_full:
		say("TRANSFER_PLAN_READY_%d" % (seat % READY_LINES + 1))


func chest() -> Vector3:
	return global_position + global_basis.y * SEATED_CHEST


## Nothing to talk down on the bus (step 3 gives E its uses).
func prompt_key(_cop: Cop) -> String:
	return ""


func use(_cop: Cop) -> void:
	pass


func _update() -> void:
	super()
	if is_node_ready() and seated:
		_model.position.y = -SIT_DROP
