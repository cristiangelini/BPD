extends GutTest

## Don Florencio at the farm raid (docs/diseno/allanamiento-granja.md, step 3): he walks his round and fills the
## complaint, the feeding bell sends him to the corral with his back to the farm, the bell rests before it rings again,
## and while he feeds the animals a cop takes the shed's key from his apron.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm() -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func _wait_feeding(farm: FarmRaid) -> void:
	for i in 600:
		if farm.in_feeding():
			return
		await wait_physics_frames(1)


func test_he_walks_his_round() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var start := farm.owner_npc.global_position
	await wait_physics_frames(60)
	assert_gt(farm.owner_npc.global_position.distance_to(start), 0.5, "he walks")
	assert_eq(farm.owner_npc.voice, "FARMER")
	assert_false(farm.in_feeding())


func test_the_bell_sends_him_to_feed_the_animals_blind() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	farm.owner_npc.fix_time = 2.0
	farm.bell.print_copies()
	assert_true(farm.bell.is_ringing())
	await _wait_feeding(farm)
	assert_true(farm.in_feeding(), "he got to the corral")
	assert_lt(farm.owner_npc.global_position.distance_to(farm.to_global(FarmRaid.FEED_SPOT)), 0.6)
	assert_false(farm.owner_npc.can_see(farm.to_global(Vector3(0, 1, 3))), "his back is to the farm")
	await wait_seconds(2.2)
	assert_false(farm.in_feeding(), "the bucket is empty")
	assert_false(farm.bell.is_ringing())
	assert_gt(farm.bell.rest_left, 0.0, "the animals aren't hungry again so soon")
	farm.bell.print_copies()
	assert_false(farm.bell.is_ringing())


func test_a_cop_takes_the_key_from_his_apron_only_while_he_feeds() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var cop: Cop = farm.get_node("Cop")
	assert_eq(farm.owner_npc.prompt_key(cop), "")
	farm.owner_npc.use(cop)
	assert_false(cop.has_key)
	farm.bell.print_copies()
	await _wait_feeding(farm)
	assert_eq(farm.owner_npc.prompt_key(cop), "PROMPT_APRON_KEY")
	farm.owner_npc.use(cop)
	assert_true(cop.has_key)
	assert_false(farm.owner_npc.has_key)
	assert_eq(farm.owner_npc.prompt_key(cop), "")


func test_a_broken_door_fills_the_complaint_bar() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	farm.shed_door.broken.emit()
	assert_eq(farm.owner_npc.complaint, FloorBoss.DOOR_BROKEN)
	assert_eq(farm.complaint_bar.value, FloorBoss.DOOR_BROKEN)
