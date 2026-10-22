extends GutTest

## The crime scene online (escena-del-crimen.md; docs/diseno/online.md): the host's case counts what every cop finds,
## and every PC sees the same planilla, files on the board, verdict, culprit's bike chase and end of shift.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/crime_scene.tscn")

var _pcs: OnlinePcs
var _seed := 33


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_seed = 33
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: CrimeSceneLevel = LEVEL_SCENE.instantiate()
		level.case_seed = _seed
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _case(net: Node) -> CrimeSceneCase:
	return (OnlinePcs.level(net) as CrimeSceneLevel).case


## The first seed from `from` whose culprit runs off when accused (or doesn't).
static func _seed_that_runs(runs: bool, from := 1) -> int:
	var seed_value := from
	while (hash(["crime runs", seed_value]) % CrimeSceneCase.RUNS_EVERY == 0) != runs:
		seed_value += 1
	return seed_value


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	_case(pcs[0]).give_tip()
	await wait_until(func() -> bool: return _case(pcs[1]).tip_given, 5.0)
	return pcs


func test_a_guest_takes_a_hat_off_and_the_file_shows_on_both_boards() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	assert_true(guest.follower)
	var stubborn := hash("stubborn cook %d" % _seed) % host.cooks.size()
	var index := (stubborn + 1) % host.cooks.size()
	var cook: PastryCook = (OnlinePcs.level(pcs[1]) as CrimeSceneLevel).contest.cooks[index]
	OnlinePcs.own_cop(pcs[1]).act("use", cook)
	await wait_until(func() -> bool: return guest.file_parts.has(index), 5.0)
	assert_true(host.file_parts[index].hair, "the guest's E counted on the host")
	assert_true(guest.file_parts[index].hair, "and shows on the guest's planilla")
	assert_true(cook.hat_off, "his hat is off on the guest too")
	guest.found("witness")
	guest.accuse(0)
	assert_false(guest.accused or guest.wrong_guesses > 0, "a guest's case doesn't decide on its own")


func test_the_verdict_and_the_end_of_shift_reach_the_guest() -> void:
	_seed = _seed_that_runs(false)
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.accuse((host.plan.culprit + 1) % host.cooks.size())
	await wait_until(func() -> bool: return guest.wrong_guesses == 1, 5.0)
	host.accuse(host.plan.culprit)
	await wait_until(func() -> bool: return guest.accused, 5.0)
	assert_false((OnlinePcs.level(pcs[1]) as CrimeSceneLevel).contest.cooks[host.plan.culprit].visible,
		"the culprit goes to a cell on the guest too")
	await wait_until(func() -> bool: return guest.shift_over, CrimeSceneCase.SHIFT_DELAY + 5.0)
	assert_true(guest.shift_screen.visible)
	assert_false(guest.shift_screen.get_node("%AgainButton").visible, "only the host starts the next one")


func test_the_culprit_runs_off_on_every_pc() -> void:
	_seed = _seed_that_runs(true)
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.accuse(host.plan.culprit)
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_true(guest.chase.follower, "the guest's chase follows the host's")
	assert_eq(guest.chase.suspect_id, SuspectCar.BIKE)
	await wait_physics_frames(20)
	var bikes := OnlinePcs.level(pcs[1]).find_children("*", "SuspectCar", false, false)
	assert_eq(bikes.size(), 1, "one bike on the guest, the host's")
	host.chase.fail("CASE_FAILED_TIME")
	await wait_until(func() -> bool: return guest.escaped, 5.0)
	assert_true(guest.chase.case_failed, "he got away on the guest too")
