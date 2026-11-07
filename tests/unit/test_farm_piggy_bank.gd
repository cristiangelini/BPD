extends GutTest

## The piggy bank story (docs/diseno/allanamiento-granja.md, step 6): the piggy bank buried in the mud with its shovel
## and map hidden around, the pigs that dig one buried thing up every 40 s, and the pig with a ring on its snout.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm(case_seed := 5) -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = case_seed
	farm.story_id = "piggy_bank"
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func test_the_piggy_bank_starts_buried_in_the_mud() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	assert_true(farm.rig is PiggyBankRig)
	assert_eq(FarmRaid.SPOTS[farm.hidden_spots[0]].id, "in_mud")
	assert_eq(farm.main.mass, 5.0)
	assert_eq(farm.main.full_value, 1000.0)
	assert_eq(farm.extras.map(func(e: Evidence) -> float: return e.full_value), [300.0, 200.0])
	assert_true(FarmGoat.is_paper(farm.extras[1]), "Tota eats the map if she finds it")
	var rig := farm.rig as PiggyBankRig
	assert_eq(rig.buried.size(), 3, "the piggy bank, a boot and a can")
	assert_has(rig.buried, farm.main)
	assert_false(farm.main.visible)
	assert_eq(farm.main.collision_layer, 0, "out of reach")


func test_the_pigs_dig_everything_up_one_at_a_time() -> void:
	for case_seed: int in [3, 4, 5]:
		var farm := _farm(case_seed)
		await wait_physics_frames(2)
		var rig := farm.rig as PiggyBankRig
		var turn := rig.buried.find(farm.main)
		assert_eq(turn, case_seed % 3, "seed %d: its turn is drawn with the seed" % case_seed)
		for i in turn:
			assert_ne(rig.dig(), farm.main as RigidBody3D)
		assert_eq(rig.dig(), farm.main as RigidBody3D)
		assert_true(farm.main.visible)
		assert_eq(farm.main.collision_layer, 4, "a cop can grab it now")
		assert_false(farm.main.freeze)
		farm.free()
	await wait_physics_frames(1)


func test_the_timer_digs_on_its_own() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as PiggyBankRig
	rig._dig_left = 0.05
	await wait_physics_frames(10)
	assert_eq(rig.dug, 1)
	assert_eq(rig.buried.size(), 2)


func test_a_close_look_at_the_ringed_pig_is_the_clue() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as PiggyBankRig
	var cop: Cop = farm.get_node("Cop")
	assert_not_null(rig.ringed.get_node_or_null("Ring"))
	assert_eq(rig.ringed.prompt_key(cop), "PROMPT_LOOK_PIG")
	for pig in farm.pigs:
		if pig != rig.ringed:
			pig.use(cop)
	assert_false(farm.raid.clues_found.has(tr("CLUE_PIG_RING")), "the other pigs have nothing on their snout")
	rig.ringed.use(cop)
	assert_true(farm.raid.clues_found.has(tr("CLUE_PIG_RING")))


func test_a_guest_digs_what_the_host_dug() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as PiggyBankRig
	rig.apply_net_state(3)
	assert_eq(rig.dug, 3)
	assert_true(rig.buried.is_empty())
	assert_true(farm.main.visible)
