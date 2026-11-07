extends GutTest

## The giant carrots story (docs/diseno/allanamiento-granja.md, step 6): the stolen fertilizer jugs, the growth diary
## and the 2 m ruler, and the carrot taller than a cop that only comes out with two cops pulling together.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _farm(case_seed := 5) -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = case_seed
	farm.story_id = "giant_carrots"
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func test_the_story_hides_the_jugs_the_diary_and_the_ruler() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	assert_true(farm.rig is GiantCarrotsRig)
	assert_eq(farm.main.mass, 8.0)
	assert_eq(farm.main.full_value, 1000.0)
	assert_eq(farm.extras.map(func(e: Evidence) -> float: return e.full_value), [300.0, 200.0])
	assert_has(farm.raid.suspicions, "giant_carrots")
	var carrot := (farm.rig as GiantCarrotsRig).carrot
	var cop: Cop = farm.get_node("Cop")
	assert_eq(carrot.prompt_key(cop), "PROMPT_PULL_CARROT")
	var top := carrot.global_position.y + GiantCarrotsRig.HEIGHT / 2 - farm.global_position.y - FarmRaid.GROUND
	assert_gt(top, GameScale.COP_HEIGHT, "it's taller than a cop")


func test_one_cop_alone_cant_pull_it_out() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as GiantCarrotsRig
	var cop: Cop = farm.get_node("Cop")
	watch_signals(rig.carrot)
	for i in 3:
		rig.carrot.use(cop)
	assert_signal_emit_count(rig.carrot, "tugged", 3)
	assert_signal_not_emitted(rig.carrot, "pulled_out")
	assert_false(farm.raid.clues_found.has(tr("CLUE_GIANT_CARROT")))


func test_two_cops_pull_it_out_with_the_lab_label() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as GiantCarrotsRig
	var other: Cop = COP_SCENE.instantiate()
	other.input_enabled = false
	farm.add_child(other)
	other.global_position = farm.to_global(GiantCarrotsRig.CARROT_AT + Vector3(-1.5, 0.2, 0))
	rig.carrot.use(farm.get_node("Cop"))
	rig.carrot.use(other)
	assert_true(farm.raid.clues_found.has(tr("CLUE_GIANT_CARROT")))
	assert_true(rig.loose.visible, "it lies beside its hole")
	assert_eq(rig.loose.collision_layer, 4, "a cop can grab it")
	assert_eq(rig.loose.mass, GiantCarrotsRig.MASS, "heavy: a carry for two")
	assert_true(rig.net_state())
	await wait_physics_frames(30)
	assert_false(is_instance_valid(rig.carrot), "nothing stuck in the soil any more")
	assert_lt(rig.loose.global_position.distance_to(farm.to_global(GiantCarrotsRig.CARROT_AT)), 3.0)
	assert_gt(rig.loose.global_position.y, farm.global_position.y, "it doesn't sink into the ground")


func test_a_guest_pulls_it_out_when_the_host_did() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as GiantCarrotsRig
	assert_false(rig.net_state())
	assert_false(rig.loose.visible, "made with the farm, hidden until it's pulled")
	rig.apply_net_state(true)
	assert_true(rig.loose.visible)
	assert_eq(rig.carrot.prompt_key(farm.get_node("Cop")), "")
