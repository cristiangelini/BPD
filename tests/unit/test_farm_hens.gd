extends GutTest

## The hens and Pancho at the farm raid (docs/diseno/allanamiento-granja.md, step 4): eight hens peck around the yard,
## a cop who runs close scares one and Don Florencio counts it, one who runs into it trips, and Pancho only talks once
## three of them are back in the hen house's run.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm(case_seed := 7) -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = case_seed
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func test_eight_hens_peck_in_the_yard_drawn_by_the_seed() -> void:
	var a := _farm(7)
	var starts: Array[Vector3] = []
	for hen: FarmHen in a.hens:
		starts.append(hen.position)
	a.free()
	var b := _farm(7)
	assert_eq(b.hens.size(), FarmRaid.HENS)
	for i in b.hens.size():
		var at := b.hens[i].position
		assert_true(FarmRaid.YARD.has_point(Vector2(at.x, at.z)), "hen %d starts in the yard" % i)
		assert_eq(at, starts[i], "same seed, same spot")
	await wait_physics_frames(2)
	assert_eq(b.cooped_hens(), 0, "none of them is in the run yet")
	assert_eq(b.hens[0].mass, FarmHen.KG)


func test_a_running_cop_scares_a_hen_and_florencio_sees_it() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var hen := farm.hens[0]
	var owner_npc := farm.owner_npc
	owner_npc.set_physics_process(false)
	owner_npc.global_position = hen.global_position + Vector3(-3, 0, 0)
	owner_npc.look_at(hen.global_position, Vector3.UP, true)
	# The ray he looks with sees bodies where the last physics step left them.
	await wait_physics_frames(1)
	var cop: Cop = farm.get_node("Cop")
	cop.global_position = hen.global_position + Vector3(1.4, 0.05, 0)
	cop.is_running = true
	cop.velocity = Vector3(GameScale.RUN_SPEED, 0, 0)
	watch_signals(hen)
	hen._watch_cops()
	assert_signal_emitted(hen, "scared")
	assert_eq(owner_npc.complaint, FarmRaid.SAW_SCARED, "he saw it run")
	cop.global_position = hen.global_position + Vector3(0.3, 0.05, 0)
	hen._watch_cops()
	assert_true(cop.is_staggered(), "the cop tripped over it")


func test_pancho_talks_once_three_hens_are_back_in_the_run() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var cop: Cop = farm.get_node("Cop")
	farm.pancho.clue = "CLUE"
	farm.pancho.clue_speech = "SPEECH"
	watch_signals(farm.pancho)
	farm.pancho.use(cop)
	assert_signal_not_emitted(farm.pancho, "told", "no hens, no talk")
	var run := FarmRaid.COOP_RUN
	for i in FarmNephew.HENS:
		farm.hens[i].global_position = farm.to_global(Vector3(run.position.x + 0.6 + i * 0.8, FarmRaid.GROUND + 0.05,
			run.get_center().y))
		farm.hens[i].linear_velocity = Vector3.ZERO
	await wait_physics_frames(2)
	assert_eq(farm.cooped_hens(), FarmNephew.HENS)
	assert_eq(farm.pancho.cooped, FarmNephew.HENS)
	farm.pancho.use(cop)
	assert_signal_emitted_with_parameters(farm.pancho, "told", ["CLUE"])
	farm.pancho.use(cop)
	assert_signal_emit_count(farm.pancho, "told", 1, "once per case")
