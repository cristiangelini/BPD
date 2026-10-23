extends GutTest

## Guarding deputy Lustre (proteccion-politico.md, step 3, decision 103): a cop in the way takes the egg instead of
## him, and one flying near a cop's hands can be caught in the air and thrown again.

const LEVEL := preload("res://scenes/levels/plaza_rally.tscn")

var rally: PlazaRally
var cop: Cop


func before_each() -> void:
	rally = LEVEL.instantiate()
	rally.case_seed = 7
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	cop = rally.get_node("Cop")
	cop.get_node("Grabber").input_enabled = false
	await wait_physics_frames(2)


func test_a_cop_in_the_way_takes_the_stain() -> void:
	var thrown := RallyThrowable.new()
	thrown.kind = "tomato"
	rally.add_child(thrown)
	thrown.burst_on(cop)
	assert_eq(rally.politician.stains, 0, "the deputy is clean")
	assert_eq(cop.stats.get("rally_blocks", 0), 1)
	assert_not_null(cop.get_node_or_null("RallyStain"), "the cop wears it")


func test_one_flying_near_the_hands_is_caught() -> void:
	var thrown := RallyThrowable.new()
	thrown.kind = "egg"
	rally.add_child(thrown)
	var grabber: Grabber = cop.get_node("Grabber")
	thrown.launch(grabber.hold_point() + Vector3(0, 0.2, 0), grabber.hold_point() + Vector3(0, -3, 0), 1.0)
	await wait_physics_frames(1)
	assert_eq(grabber.catchable_near(), thrown)
	watch_signals(thrown)
	assert_true(grabber.try_grab(), "caught without aiming at it exactly")
	assert_eq(grabber.held, thrown)
	assert_false(thrown.flying)
	assert_signal_emitted(thrown, "caught")
	assert_eq(cop.stats.get("rally_catches", 0), 1)
	await wait_physics_frames(20)
	assert_true(is_instance_valid(thrown), "in the hands it doesn't burst")


func test_one_behind_the_cop_is_not_caught() -> void:
	var thrown := RallyThrowable.new()
	rally.add_child(thrown)
	var eye := cop.camera.global_transform
	thrown.launch(eye.origin + eye.basis.z * 0.8, eye.origin + eye.basis.z * 0.8 + Vector3(0, -3, 0), 1.0)
	await wait_physics_frames(1)
	assert_null(cop.get_node("Grabber").catchable_near())


func test_the_awards_count_blocks_and_catches() -> void:
	var awards := ShiftReport.awards([{"rally_blocks": 3}, {"rally_blocks": 1, "rally_catches": 2}])
	var keys := awards.map(func(award: Dictionary) -> String: return award.key)
	assert_has(keys, "AWARD_RALLY_BLOCKS")
	assert_has(keys, "AWARD_RALLY_CATCHES")
	for award in awards:
		if award.key == "AWARD_RALLY_BLOCKS":
			assert_eq(award.cop, 0)
