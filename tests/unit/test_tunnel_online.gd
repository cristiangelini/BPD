extends GutTest

## The spoon tunnel jailbreak online (fuga-tunel.md, "Online"): the host decides how far each hole is dug, whether a
## mattress covers it, the guard's walk and the spoons he takes; the guests see the same.

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
	jail.case_seed = 6262
	jail.variant = "tunnel"
	return jail


func test_the_guest_sees_the_hole_dug_and_covered() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	assert_eq(guest_level.holes.size(), 2, "the guest has the holes")
	assert_eq(guest_level.mattresses.size(), 2, "and the mattresses")
	var hole := host_level.holes[0]
	host_level.guard.fall_asleep()
	for i in 5:
		hole.scoop()
	await wait_until(func() -> bool: return guest_level.holes[0].scoops == 5, 5.0)
	assert_eq(guest_level.holes[0].scoops, 5, "dug on the guest too")
	var mattress := host_level.mattresses[0]
	mattress.freeze = true
	mattress.global_transform = Transform3D(Basis.IDENTITY, hole.global_position + Vector3(0, 0.07, 0))
	await wait_until(func() -> bool: return guest_level.holes[0].covered, 5.0)
	assert_true(guest_level.holes[0].covered, "covered on the guest")


func test_the_guest_sees_the_guard_walk_to_the_bars() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	var start := guest_level.guard.global_position
	(host_level.guard as ListeningGuard).go_look(host_level.holes[0])
	await wait_until(func() -> bool: return guest_level.guard.global_position.distance_to(start) > 1.0, 5.0)
	assert_gt(guest_level.guard.global_position.distance_to(start), 1.0, "he walks on the guest too")
