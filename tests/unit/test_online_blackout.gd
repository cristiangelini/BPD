extends GutTest

## The prison's blackout online (carcel-corte-de-luz.md, step 7; docs/diseno/online.md): the host's inmates, fuse
## board and case decide, and every PC sees the same frozen, hidden and escaped inmates, fuses and light.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const BLACKOUT_SCENE := preload("res://scenes/levels/prison_blackout.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = BLACKOUT_SCENE.instantiate()
		prison.case_seed = SEED
		prison.get_node("Cop/Grabber").input_enabled = false
		return prison)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> PrisonLevel:
	return OnlinePcs.level(net) as PrisonLevel


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _level(pcs[1])
	assert_true(guest.blackout_case.follower)
	assert_true(guest.blackout.follower, "only the host's inmates walk")
	assert_true(guest.blackout.inmates[0].follower)
	assert_eq(guest.blackout.chispa.name, _level(pcs[0]).blackout.chispa.name, "the same Chispa everywhere")


func test_the_host_inmates_walk_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.blackout.start()
	var inmate := host.blackout.inmates[0]
	inmate.delay = 0.0
	var from := inmate.global_position
	await wait_seconds(1.5)
	assert_gt(inmate.global_position.distance_to(from), 1.0, "the host's walks")
	# Stopped where it got to: a slow frame can leave the guest's copy a few steps behind a walking one.
	inmate.set_physics_process(false)
	var there := guest.blackout.inmates[0]
	await wait_until(func() -> bool: return there.global_position.distance_to(inmate.global_position) < 0.1, 5.0)
	assert_almost_eq(there.global_position.distance_to(inmate.global_position), 0.0, 0.1, "the guest's walks there too")


func test_an_escape_and_a_frozen_one_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.blackout.start()
	host.blackout.inmates[1]._escape()
	host.blackout.inmates[2].set_lit(true)
	await wait_until(func() -> bool: return guest.blackout_case.escaped() == 1, 5.0)
	await wait_until(func() -> bool: return guest.blackout.inmates[1].is_escaped, 5.0)
	assert_false(guest.blackout.inmates[1].visible)
	assert_true(guest.blackout.inmates[2].frozen)


func test_the_fuses_and_the_light_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.blackout.start()
	host.fuse_board.put_in()
	await wait_until(func() -> bool: return guest.fuse_board.filled == 1, 5.0)
	host.fuse_board.put_in()
	host.fuse_board.put_in()
	await wait_until(func() -> bool: return guest.blackout.lights_on, 5.0)
	assert_true(guest.lights_on)
	assert_true(guest.blackout.inmates[0].surrendered)
	await wait_until(func() -> bool: return guest.blackout_case.solved_it, 5.0)


func test_a_dropped_fuse_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.blackout.start()
	var before := guest.find_children("*", "Fuse", true, false).size()
	host.blackout.chispa.cuffed(Handcuffs.SECONDS)
	await wait_until(func() -> bool: return guest.find_children("*", "Fuse", true, false).size() == before + 1, 5.0)
	assert_eq(guest.find_children("*", "Fuse", true, false).size(), before + 1)
	await wait_until(func() -> bool: return not guest.blackout.chispa.has_fuse, 5.0)
