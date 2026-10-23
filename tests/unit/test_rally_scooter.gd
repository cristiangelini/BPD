extends GutTest

## The last heckler's getaway (proteccion-politico.md, step 6b, decision 103): when the speech ends, the last one
## still loose runs off on a kick scooter with their own look; caught, they count as detained.

const LEVEL := preload("res://scenes/levels/plaza_rally.tscn")

var rally: PlazaRally


func before_each() -> void:
	rally = LEVEL.instantiate()
	rally.case_seed = 7
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)


func _end_speech() -> void:
	rally.speech.start()
	rally.speech.left = 0.05
	await wait_physics_frames(10)


func test_the_last_loose_one_runs_off_on_a_scooter() -> void:
	var last := rally.crowd.hecklers[RallyCrowd.HECKLERS - 1]
	await _end_speech()
	assert_eq(rally.case.runner, last)
	assert_not_null(rally.case.chase)
	assert_eq(rally.case.chase.suspect_id, SuspectCar.KICK_SCOOTER)
	assert_eq(rally.case.chase.who, ChaseSuspect.HECKLER + last.look)
	assert_false(last.visible, "they left on it")
	assert_false(rally.case.shift_over, "the shift waits for the chase")


func test_with_everyone_cuffed_nobody_runs() -> void:
	for heckler in rally.crowd.hecklers:
		heckler.cuffed(Handcuffs.SECONDS)
	await _end_speech()
	assert_null(rally.case.chase)


func test_caught_they_count_as_detained() -> void:
	await _end_speech()
	rally.case._on_chase_ended(true)
	assert_eq(rally.case.detained(), 1)
	rally.case._on_chase_ended(false)
	assert_eq(rally.case.detained(), 0)
	assert_true(rally.case.solved(), "got away, it's solved all the same")


func test_the_scooter_rides_the_sidewalk_at_15() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.KICK_SCOOTER], 15.0 / 3.6, 0.01)
	assert_eq(SuspectCar.LANES[SuspectCar.KICK_SCOOTER], ChaseRoute.SIDEWALK_LANE)
	assert_has(ChaseCase.ON_FOOT, SuspectCar.KICK_SCOOTER)


func test_off_the_scooter_they_keep_their_look_and_lines() -> void:
	var suspect := ChaseSuspect.new()
	suspect.kind = ChaseSuspect.HECKLER + "abuela"
	add_child_autofree(suspect)
	assert_eq(suspect.lines()[0], "CHASE_HECKLER_LINE_1")
	assert_eq(ChaseSuspect.model_for(suspect.kind).resource_path, "res://assets/models/npc_abuela.glb")
