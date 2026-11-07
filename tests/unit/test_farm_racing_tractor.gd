extends GutTest

## The racing tractor story (docs/diseno/allanamiento-granja.md, step 6): the racing engine hidden in the barn, its
## trophy and helmet, and the tractor that starts with E, shoots off in a straight line and stops at what's in the way.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm(case_seed := 5, story := "racing_tractor") -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = case_seed
	farm.story_id = story
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func test_the_engine_hides_in_the_barn_with_its_trophy_and_helmet() -> void:
	for case_seed: int in [1, 2, 5, 8]:
		var farm := _farm(case_seed)
		assert_true(["between_bales", "in_loft"].has(FarmRaid.SPOTS[farm.hidden_spots[0]].id),
			"seed %d: the engine is in the barn" % case_seed)
		assert_eq(farm.main.mass, 25.0)
		assert_eq(farm.main.full_value, 1000.0)
		assert_eq(farm.extras.map(func(e: Evidence) -> float: return e.full_value), [300.0, 200.0])
		farm.free()
	await wait_physics_frames(1)


func test_the_tractor_only_starts_in_this_story() -> void:
	var other := _farm(5, "golden_eggs")
	var cop: Cop = other.get_node("Cop")
	assert_eq(other.tractor.prompt_key(cop), "", "Don Florencio's tractor doesn't start")
	other.free()
	var farm := _farm()
	await wait_physics_frames(2)
	assert_eq(farm.tractor.prompt_key(farm.get_node("Cop")), "PROMPT_START_TRACTOR")
	assert_not_null((farm.rig as RacingTractorRig).sticker, "it wears its Turbo sticker")


func test_starting_it_shoots_it_off_and_gives_the_clue() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var cop: Cop = farm.get_node("Cop")
	cop.global_position = farm.to_global(Vector3(-15, FarmRaid.GROUND + 0.1, -2))
	await wait_physics_frames(1)
	var rig := farm.rig as RacingTractorRig
	var start := farm.tractor.position
	watch_signals(rig)
	farm.tractor.use(cop)
	assert_signal_emitted(rig, "launched")
	assert_true(farm.raid.clues_found.has(tr("CLUE_TRACTOR_TURBO")))
	assert_gt(rig.ran, 1.0, "it goes")
	assert_lt(rig.ran, RacingTractorRig.RUN + 0.01, "no further than its run")
	await wait_seconds(rig.ran / RacingTractorRig.SPEED + 0.3)
	assert_almost_eq(farm.tractor.position.z, start.z + rig.ran, 0.05)
	assert_almost_eq(farm.tractor_model.position.z - farm.tractor.position.z, FarmRaid.TRACTOR_AT.z - start.z, 0.05,
		"its look goes with it")
	var ran := rig.ran
	farm.tractor.use(cop)
	assert_eq(rig.ran, ran, "one tank of fuel")


func test_it_stops_at_what_is_in_the_way() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4, 2, 0.5)
	shape.shape = box
	wall.add_child(shape)
	wall.position = FarmRaid.TRACTOR_AT + Vector3(0, 1.0, 6.0)
	farm.add_child(wall)
	await wait_physics_frames(2)
	var ran := (farm.rig as RacingTractorRig).launch()
	assert_lt(ran, 6.0, "it hits the wall")
	assert_gt(ran, 3.0)
