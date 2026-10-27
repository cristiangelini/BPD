extends GutTest

## The fun fair raid with the bronze horse (allanamiento-parque.md, step 6): the stolen statue painted as one of the
## carousel's horses, which doesn't go up and down, goes "¡CLANG!" and slows the carousel down.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair(case_seed := 5) -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.story_id = "bronze_horse"
	fair.case_seed = case_seed
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


func test_the_bronze_horse_stands_on_the_carousel_and_solves_the_case() -> void:
	var fair := _fair()
	await wait_physics_frames(10)
	var rig := fair.rig as BronzeHorseRig
	assert_has(fair.raid.suspicions, "bronze_horse")
	assert_eq(fair.main, rig.statue)
	assert_eq(fair.horses.size(), 12, "still twelve horses")
	assert_eq(rig.statue.get_parent(), fair.carousel)
	assert_eq(fair.extras.size(), 2, "the paint and the clipping")
	rig.statue.reparent(fair)
	rig.statue.freeze = false
	fair.main.global_position = fair.car.to_global(Vector3(0, 1.0, -1.7))
	await wait_physics_frames(15)
	assert_true(fair.car.is_delivered(fair.main))
	assert_true(fair.raid.mark(fair.raid.suspicions.find("bronze_horse")))
	fair.car.enter(fair.get_node("Cop"))
	assert_true(fair.raid.case_solved)


func test_it_does_not_bob_and_the_carousel_is_slow_until_it_comes_off_with_a_clang() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var rig := fair.rig as BronzeHorseRig
	assert_almost_eq(fair.rides.spin_rpm, FairRides.SPIN_RPM * BronzeHorseRig.SLOW, 0.01, "slower")
	fair.rides.press("carousel")
	var other := fair.horses[(rig.index + 1) % 8]
	var heights := {}
	var statue_y := rig.statue.position.y
	for i in 30:
		await wait_physics_frames(2)
		heights[snappedf(other.position.y, 0.01)] = true
		assert_almost_eq(rig.statue.position.y, statue_y, 0.001, "the bronze one stays put")
	assert_gt(heights.size(), 3, "the others go up and down")
	var cop: Cop = fair.get_node("Cop")
	fair.rides.press("carousel")
	cop.global_position = rig.statue.global_position + Vector3(0, -0.9, 0) + rig.statue.global_basis.x * 0.9
	await wait_physics_frames(2)
	(cop.get_node("Grabber") as Node).grab(rig.statue)
	await wait_physics_frames(2)
	assert_true(rig.clanged)
	assert_eq(rig.statue.get_parent(), fair, "off the carousel")
	assert_almost_eq(fair.rides.spin_rpm, FairRides.SPIN_RPM, 0.01, "back to its speed")
	assert_has(fair.raid.clues_found, tr("CLUE_BRONZE_CLANG"))


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_BRONZE_HORSE_B", "BRIEF_BRONZE_HORSE_C", "BRIEF_BRONZE_HORSE_D", "OBJ_FIND_BRONZE_HORSE",
			"OBJ_EXTRA_PAINT_CANS", "OBJ_EXTRA_HORSE_PHOTO", "NUBE_CLUE_bronze_horse", "CLUE_BRONZE_CLANG",
			"FAIR_CLANG", "FAIR_CAROUSEL_SQUEAK"]:
		assert_ne(tr(key), key, key)
