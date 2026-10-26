extends GutTest

## The roof jailbreak online (fuga-techo.md, "Online"): the host pushes the skylights and ties the rope; a guest sees
## the same skylight and the same rope on the antenna.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL := preload("res://scenes/levels/jailbreak.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_jail)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_jail() -> Node3D:
	var jail: JailbreakLevel = LEVEL.instantiate()
	jail.case_seed = 4242
	jail.variant = "roof"
	return jail


func test_the_guest_sees_the_skylight_and_the_rope() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	host_level.guard.set_physics_process(false)
	while not host_level.skylights[1].is_open():
		host_level.skylights[1].push()
	await wait_until(func() -> bool: return guest_level.skylights[1].is_open(), 5.0)
	assert_true(guest_level.skylights[1].is_open(), "open on the guest too")
	var rope := SheetRope.new()
	rope.knots = [true, false, true]
	host_level.add_child(rope)
	host_level.antenna.tie(rope)
	await wait_until(func() -> bool: return guest_level.antenna.sheets == 4, 5.0)
	assert_eq(guest_level.antenna.sheets, 4, "the rope on the guest's antenna")
	assert_eq(guest_level.antenna.knots, [true, false, true])
