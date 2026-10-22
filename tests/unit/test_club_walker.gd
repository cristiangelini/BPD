extends GutTest

## Found out at the club (infiltracion.md, step 6c): Doña Chela runs off on her motorized walker and the chase starts
## in the middle of the case; caught, it's solved with the evidence they have; got away, it's lost.

const LEVEL := preload("res://scenes/levels/grandpa_club.tscn")

var club: GrandpaClub
var case: InfiltrationCase


func before_each() -> void:
	club = LEVEL.instantiate()
	club.case_seed = 4242
	club.get_node("Cop").input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)
	club.bingo.set_physics_process(false)
	club.dance.set_process(false)
	case = club.case
	case.give_tip()


func _find_out() -> void:
	club.suspicion.raise(club.members[0], 100.0)
	await wait_physics_frames(1)


func test_found_out_she_runs_off_on_her_walker() -> void:
	await _find_out()
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.WALKER)
	assert_eq(case.chase.truck.kind, SuspectCar.WALKER)
	assert_false(club.chela.visible, "off the stage")
	assert_true(case.chase.on_foot(), "chased on foot, like the wheelchair")


func test_the_walker_is_slow_and_on_the_sidewalk() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.WALKER], 10.0 / 3.6, 0.01)
	assert_eq(SuspectCar.LANES[SuspectCar.WALKER], ChaseRoute.SIDEWALK_LANE)


func test_caught_it_pays_with_the_evidence_they_have() -> void:
	case.found("notebook")
	case.found("envelope")
	await _find_out()
	case.chase.ended.emit(true)
	assert_true(case.solved())
	assert_eq(case.report().salary, InfiltrationCase.SALARY * 2 / 3)


func test_got_away_the_case_is_lost() -> void:
	await _find_out()
	case.chase.ended.emit(false)
	assert_false(case.solved())
	assert_true(case.escaped)
	assert_eq(case.report().salary, 0)


func test_the_planilla_asks_to_catch_her() -> void:
	await _find_out()
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_CLUB_CATCH_CHELA")
