extends GutTest

## The jailbreak, step 1 (fuga.md): the first missed quota locks the cops up in their own cells at night.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga.json"


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	DirAccess.remove_absolute(TEST_PATH)


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _report(total: int) -> Dictionary:
	return {"total": total, "approved": false}


func test_the_first_missed_quota_jails_the_cops_and_adds_no_money() -> void:
	var campaign := Campaign.start_new()
	campaign.finish_shift("bingo", false, _report(300))
	assert_true(campaign.jailed)
	assert_false(campaign.suspended)
	assert_false(campaign.is_over(), "the campaign goes on through the jailbreak")
	assert_eq(campaign.money, 0, "the failed shift adds nothing to the money")
	assert_eq(campaign.shift, 2)


func test_escaping_goes_on_and_the_second_miss_ends_the_campaign() -> void:
	var campaign := Campaign.start_new()
	campaign.finish_shift("bingo", false, _report(300))
	campaign.finish_jailbreak(true)
	assert_false(campaign.jailed)
	assert_false(campaign.is_over())
	campaign.finish_shift("museum", false, _report(300))
	assert_false(campaign.jailed, "only one jailbreak per campaign")
	assert_true(campaign.suspended)
	assert_true(campaign.is_over())


func test_getting_caught_loses_the_campaign() -> void:
	var campaign := Campaign.start_new()
	campaign.finish_shift("bingo", false, _report(300))
	campaign.finish_jailbreak(false)
	assert_true(campaign.suspended)
	assert_true(campaign.is_over())


func test_missing_the_last_quota_still_jails_before_anything_else() -> void:
	var campaign := Campaign.start_new()
	campaign.shift = Campaign.SHIFTS
	campaign.finish_shift("bingo", false, _report(300))
	assert_true(campaign.jailed)
	assert_false(campaign.is_over())
	assert_false(campaign.is_promoted(), "not promoted from a cell")


func test_a_saved_jail_comes_back() -> void:
	var campaign := Campaign.start_new()
	campaign.finish_shift("bingo", false, _report(300))
	campaign.save()
	var back := Campaign.load_saved()
	assert_true(back.jailed)
	assert_true(back.jailbreak_used)
	assert_true(Campaign.can_continue(), "a jailed campaign can be continued: back in the cells")


func test_a_jailed_campaign_draws_the_jailbreak() -> void:
	var campaign := Campaign.start_new()
	campaign.finish_shift("bingo", false, _report(300))
	assert_eq(PlaceDraw.pick(campaign.case_seed(), PackedStringArray(), campaign.shift), "jailbreak")
	campaign.finish_jailbreak(true)
	assert_ne(PlaceDraw.pick(campaign.case_seed(), PackedStringArray(), campaign.shift), "jailbreak")


func test_each_cell_has_a_door_gap_in_its_bars() -> void:
	for post: Array in StationRooms.bars():
		if not is_equal_approx(post[0].z, StationRooms.CELL_FRONT_Z) or post[0].y < GameScale.DOOR_HEIGHT / 2:
			continue
		if post[0].y > GameScale.DOOR_HEIGHT:
			continue
		for door in StationRooms.CELL_DOORS:
			assert_false(post[0].x > door.x and post[0].x < door.y, "no bar in the door at x %.2f" % post[0].x)
	for door in StationRooms.CELL_DOORS:
		assert_gte(door.y - door.x, GameScale.DOOR_WIDTH - 0.01, "a cop fits through")


func test_a_locked_door_rattles_and_an_unlocked_one_opens() -> void:
	var door := CellDoor.new()
	add_child_autofree(door)
	door.lock()
	assert_eq(door.prompt_key(null), "PROMPT_CELL_LOCKED")
	door.use(null)
	assert_false(door.is_open, "locked, it stays shut")
	door.unlock()
	door.use(null)
	assert_true(door.is_open)
	assert_eq(door.prompt_key(null), "PROMPT_CELL_CLOSE")


func test_the_cops_wake_up_two_in_each_locked_cell_at_night() -> void:
	var level: Node3D = LEVEL.instantiate()
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_process_frames(2)
	var city: City = level.city
	assert_true(city.night)
	assert_eq(city.cell_doors.size(), 2)
	for door in city.cell_doors:
		assert_true(door.locked, "both cells locked")
	assert_false(is_instance_valid(city.comisario), "the comisario went home")
	var lot := city.transform * CityLayout.lot("station")
	var cells := [0, 0]
	for slot in 4:
		var at: Vector3 = lot.affine_inverse() * level.cop_spawn(slot).origin
		assert_lt(at.z, StationRooms.CELL_FRONT_Z, "slot %d behind the bars" % slot)
		assert_gt(at.x, StationRooms.FRONT_X)
		cells[0 if at.x < StationRooms.CELL_SPLIT_X else 1] += 1
	assert_eq(cells, [2, 2], "two in each cell")
	var cop: Cop = level.get_node("Cop")
	assert_eq(cop._hint.text, "HINT_JAILED", "the cop is told where it woke up")
	var start := lot.affine_inverse() * cop.global_position
	assert_lt(start.z, StationRooms.CELL_FRONT_Z, "the player's cop starts in a cell")
	# Walking at the bars for a while doesn't get it out.
	var forward := -cop.global_transform.basis.z
	for i in 120:
		cop.step(1.0 / 60, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	var now := lot.affine_inverse() * cop.global_position
	assert_lt(now.z, StationRooms.CELL_FRONT_Z, "still behind the bars (facing %s)" % forward)
