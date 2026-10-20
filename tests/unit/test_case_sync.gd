extends GutTest

## The case online (docs/diseno/online.md, step 5): the host's case decides and every guest shows the same checklist,
## story, result and end of shift screen.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const HOUSE := preload("res://scenes/levels/grandpa_house.tscn")
const SEED := 4242

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_house)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


## The same grandpa's house, with the same case, on every PC.
func _make_house() -> Node3D:
	var house: Node3D = HOUSE.instantiate()
	house.case_seed = SEED
	return house


func _raid(net: Node) -> RaidCase:
	return OnlinePcs.level(net).raid


func _suspicion_states(net: Node) -> Array:
	return _raid(net).objective_facts().suspicions.map(func(row: Dictionary) -> String: return row.state)


func test_only_the_host_case_decides() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	assert_false(_raid(pcs[0]).follower)
	assert_true(_raid(pcs[1]).follower)


func test_a_wrong_mark_on_the_host_shows_on_the_guest_checklist() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_raid := _raid(pcs[0])
	var wrong := 0 if host_raid.suspicions[0] != host_raid.story_id else 1
	host_raid.mark(wrong)
	await wait_until(func() -> bool: return _suspicion_states(pcs[1])[wrong] == "wrong", 5.0)
	assert_eq(_suspicion_states(pcs[1]), _suspicion_states(pcs[0]))


func test_the_guest_guesses_the_story_through_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest_raid := _raid(pcs[1])
	assert_false(guest_raid.mark(guest_raid.suspicions.find(guest_raid.story_id)), "the guest only asks")
	await wait_until(func() -> bool: return guest_raid.story_known, 5.0)
	assert_true(_raid(pcs[0]).story_known, "the host marked it")
	assert_true(guest_raid.story_known, "and the guest knows the story too")


func test_a_failed_case_ends_the_shift_for_everyone() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	_raid(pcs[1]).fail("CASE_FAILED_LAWYER")
	await wait_process_frames(10)
	assert_false(_raid(pcs[1]).case_failed, "a guest's case doesn't fail on its own")
	_raid(pcs[0]).fail("CASE_FAILED_LAWYER")
	await wait_until(func() -> bool: return _raid(pcs[1]).shift_over, RaidCase.SHIFT_DELAY + 5.0)
	var guest_screen: ShiftScreen = _raid(pcs[1]).shift_screen
	assert_true(guest_screen.visible, "the guest sees the end of shift screen")
	assert_eq(guest_screen.get_node("%CaseResult").text, "SHIFT_CASE_FAILED")
	assert_false(guest_screen.get_node("%AgainButton").visible, "only the host plays the next case")
	assert_true(_raid(pcs[0]).shift_screen.get_node("%AgainButton").visible)
