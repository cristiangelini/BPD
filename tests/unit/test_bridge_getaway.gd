extends GutTest

## Remache's getaway (politico-puente.md, step 6, decision 178): a loose Remache drives off in the cement mixer parked
## in front of the park when the ribbon is cut, it drops cement blobs in the curves that slow the patrol car, caught he
## counts as detained, and Play draws the bridge a third of the politician's protections.

const LEVEL := preload("res://scenes/levels/bridge_park.tscn")

var park: BridgePark
var case: BridgeCase


func before_each() -> void:
	park = LEVEL.instantiate()
	park.case_seed = 7
	park.get_node("Cop").input_enabled = false
	add_child_autofree(park)
	await wait_physics_frames(2)
	case = park.case


func test_the_mixer_waits_parked_on_the_street() -> void:
	var mixer := park.mixer
	assert_eq(mixer.kind, SuspectCar.CEMENT_MIXER)
	assert_false(mixer.driving)
	assert_false(mixer.get_node("Rider").visible, "Remache is still in the crowd")
	var at := park.to_local(mixer.global_position)
	assert_gt(at.z, BridgePark.HALF + CityLayout.SIDEWALK, "on the street, past the sidewalk")
	await wait_physics_frames(20)
	assert_almost_eq(park.to_local(mixer.global_position).x, at.x, 0.1, "parked, it stays")


func test_a_loose_remache_runs_off_in_the_mixer() -> void:
	park.ceremony.finished.emit()
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.CEMENT_MIXER)
	assert_eq(case.chase.truck, park.mixer, "the parked mixer is the one fleeing")
	assert_eq(case.chase.who, "engineer")
	assert_false(park.remache.engineer.visible, "he left in it")
	assert_true(park.mixer.get_node("Rider").visible)
	assert_false(case.shift_over, "the shift waits for the chase")
	assert_has(case.rows().map(func(row: Dictionary) -> String: return row.text), "OBJ_BRIDGE_CATCH_MIXER")
	case._on_chase_ended(true)
	assert_true(case.engineer_detained(), "caught, he counts as detained")
	assert_eq(case.report().salary, BridgeCase.SALARY + BridgeCase.ENGINEER)
	case._on_chase_ended(false)
	assert_false(case.engineer_detained())
	assert_true(case.solved(), "got away, it's solved all the same")


func test_cement_blobs_slow_the_patrol_car() -> void:
	park.ceremony.finished.emit()
	var drops := case.chase.drops
	var blob := drops.drop_blob()
	assert_true(drops.on_blob(blob.global_position))
	assert_false(drops.on_blob(blob.global_position + Vector3(6, 0, 0)))
	var car := park.car
	car.global_position = blob.global_position + Vector3.UP * 0.6
	car.linear_velocity = car.global_basis.z * 15.0
	drops._physics_process(0.1)
	assert_lt(car.linear_velocity.length(), 15.0 * 0.7, "the cement holds it back")
	for i in ChaseDrops.MAX_BLOBS + 2:
		drops.drop_blob()
	assert_eq(drops.blobs.size(), ChaseDrops.MAX_BLOBS)


func test_the_mixer_is_slow_and_brakes_in_the_curves() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.CEMENT_MIXER], 28.0 / 3.6, 0.01)
	assert_lt(SuspectCar.TURN_SPEEDS[SuspectCar.CEMENT_MIXER], SuspectCar.TURN_SPEED)
	assert_true(ChaseSuspect.MODELS.has("engineer"))


func test_play_draws_it() -> void:
	assert_has(PlaceDraw.RALLIES, "bridge")
	var found := false
	for i in 900:
		if PlaceDraw.pick(i + 1, [], 1) == "bridge":
			found = true
			break
	assert_true(found)


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["HINT_ESCAPE_ENGINEER", "OBJ_BRIDGE_CATCH_MIXER", "CHASE_ENGINEER_LINE_3"]:
		assert_ne(tr(key), key)
