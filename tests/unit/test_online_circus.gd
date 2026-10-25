extends GutTest

## The circus online (escena-circo.md, step 8; docs/diseno/online.md): the host's circus decides the trick and every
## PC sees the clowns end up in the same spots, the same signs on their backs, the same disguises, the loot found and
## the files on the board.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/circus.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: CircusLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 21
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _circus(net: Node) -> Circus:
	return (OnlinePcs.level(net) as CircusLevel).circus


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as CircusLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as CircusLevel).case.tip_given, 5.0)
	return pcs


func test_the_guest_follows_the_hosts_trick() -> void:
	var pcs := await _on()
	var host := _circus(pcs[0])
	var guest := _circus(pcs[1])
	assert_true(guest.case.follower)
	guest.trick._physics_process(ClownTrick.TRICK_EVERY + 1.0)
	assert_eq(guest.trick.rounds, 0, "a guest's clowns don't start it on their own")
	host.trick.perform()
	await wait_until(func() -> bool: return guest.trick.rounds == 1, 5.0)
	assert_eq(guest.trick.spots, host.trick.spots, "same spots on both")


func test_signs_and_disguises_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _circus(pcs[0])
	var guest := _circus(pcs[1])
	var clown := host.clowns[2]
	host.stick_sign(4, clown)
	clown.stubborn = false
	clown.ask_wig()
	await wait_until(func() -> bool: return guest.sign_of(2) == 4, 5.0)
	await wait_until(func() -> bool: return not guest.clowns[2].wig_on, 5.0)
	assert_true(guest.clowns[2].has_sign())
	assert_false(guest.clowns[2].part("wig").visible, "his wig is off on the guest too")
	assert_eq(guest.case.file_traits(4).hair, clown.traits.hair, "and the board's file knows his hair")
	host.drop_sign(clown)
	await wait_until(func() -> bool: return guest.sign_of(2) < 0, 5.0)
	assert_false(guest.clowns[2].has_sign())


func test_the_loot_found_on_the_host_shows_on_the_guest() -> void:
	var pcs := await _on()
	var host := _circus(pcs[0])
	var guest := _circus(pcs[1])
	host.search(host.loot_spot, null)
	await wait_until(func() -> bool: return guest.loot_found, 5.0)
	assert_not_null(guest.get_node_or_null("Loot"))
	assert_true(guest.case.loot_found)


func test_a_deleted_recording_is_deleted_on_the_guest() -> void:
	var pcs := await _on()
	var host := _circus(pcs[0])
	var guest := _circus(pcs[1])
	host.camera.delete(null)
	await wait_until(func() -> bool: return guest.camera.deleted, 5.0)
	assert_true(guest.camera.deleted)
