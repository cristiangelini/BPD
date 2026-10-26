extends GutTest

## The prison's talent show, step 5 (carcel-talentos.md): the magician's box, the sawyer under the choir and the
## crawlers in the smoke; foiled with E or off running for the gate.

const LEVEL := preload("res://scenes/levels/prison_talent.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: TalentPlan
var tricks: TalentTricks


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.talent
	tricks = plan.tricks


func after_each() -> void:
	Engine.time_scale = 1.0


## Straight into `act`, with the curtain open and the clock at `at` seconds.
func _into(act: String, at := 0.0) -> void:
	plan.start()
	plan.act_now = plan.acts.find(act) - 1
	plan._enter(TalentPlan.Phase.ANNOUNCE)
	plan._enter(TalentPlan.Phase.ACT)
	await wait_physics_frames(2)
	# What happens along the way: the volunteer into the box first.
	if act == "magician" and at > TalentTricks.MAGIC_IN:
		tricks._act_time = TalentTricks.MAGIC_IN - 0.01
		await wait_physics_frames(2)
	tricks._act_time = at
	await wait_physics_frames(2)


func test_the_seed_picks_who_does_what() -> void:
	var picked := [tricks.volunteer, tricks.sawyer] + tricks.crawlers
	for i in picked.size():
		assert_eq(picked.count(picked[i]), 1, "a different one for each")
	assert_eq(tricks.windows.size(), TalentTricks.WINDOW_ZS.size())


func test_the_volunteer_goes_into_the_box() -> void:
	await _into("magician", TalentTricks.MAGIC_IN - 0.01)
	assert_true(tricks.box.visible)
	assert_true(tricks.box.closed)
	assert_true(tricks.box.occupied)
	assert_false(plan.inmates[tricks.volunteer].visible)
	assert_eq(tricks.box.prompt_key(cop), "PROMPT_OPEN_MAGIC_BOX")


func test_opening_the_box_foils_the_magician() -> void:
	await _into("magician", TalentTricks.MAGIC_IN - 0.01)
	watch_signals(tricks)
	tricks.box.use(cop)
	assert_false(tricks.box.occupied)
	assert_true(plan.inmates[tricks.volunteer].visible, "out, red-faced")
	assert_signal_emitted_with_parameters(tricks, "foiled_one", ["magician"])
	assert_true(tricks.runners.is_empty())


func test_not_opening_it_lets_one_out_in_the_kitchen() -> void:
	await _into("magician", TalentTricks.MAGIC_VANISH - 0.01)
	assert_eq(tricks.runners.size(), 1)
	var local := prison.global_transform.affine_inverse() * tricks.runners[0].global_position
	assert_gt(local.x, PrisonLevel.KITCHEN_X, "in the kitchen")


func test_the_sawyer_is_heard_close_by_and_grabbed() -> void:
	await _into("choir", TalentTricks.SAW_START - 0.01)
	var sawyer := tricks.sawing
	assert_not_null(sawyer)
	assert_eq(sawyer, plan.inmates[tricks.sawyer])
	cop.global_position = sawyer.global_position + Vector3(1.5, 0.1, 0)
	tricks._saw_noise = 0.0
	await wait_physics_frames(2)
	assert_eq(sawyer.said(), "TALENT_SAW")
	assert_eq(sawyer.prompt_key(cop), "PROMPT_GRAB_SAWYER")
	sawyer.use(cop)
	assert_null(tricks.sawing)
	assert_eq(tricks.caught, 1)
	assert_true(prison.in_punishment(sawyer.global_position))


func test_a_sawn_window_lets_one_out() -> void:
	await _into("choir", TalentTricks.SAW_START - 0.01)
	tricks.saw_left = 0.01
	await wait_physics_frames(2)
	assert_eq(tricks.runners.size(), 1)
	assert_false(tricks.windows[tricks.window].get_node("Bars").visible)
	var local := prison.global_transform.affine_inverse() * tricks.runners[0].global_position
	assert_lt(local.x, -PrisonLevel.BUILDING_X, "outside the canteen's west wall")


func test_the_smoke_hides_the_crawlers_and_turning_it_off_sends_them_back() -> void:
	await _into("smoke", TalentTricks.SMOKE_CRAWL - 0.01)
	assert_true(tricks.machine.running)
	assert_eq(tricks.crawling.size(), TalentTricks.CRAWLERS)
	var crawler := tricks.crawling[0]
	var seat := crawler.global_position
	await wait_seconds(0.5)
	assert_gt(crawler.global_position.distance_to(seat), 0.1, "on the way to the door")
	watch_signals(tricks)
	tricks.machine.use(cop)
	assert_false(tricks.machine.running)
	assert_signal_emitted_with_parameters(tricks, "foiled_one", ["smoke"])
	await wait_seconds(1.7)
	assert_true(crawler.seated, "back on the bench")


func test_a_crawler_at_the_door_runs_for_the_gate() -> void:
	await _into("smoke", TalentTricks.SMOKE_CRAWL - 0.01)
	var crawler := tricks.crawling[0]
	crawler.global_position = prison.global_transform * Vector3(TalentTricks.YARD_DOOR.x, PrisonLevel.FLOOR_TOP,
		TalentTricks.YARD_DOOR.y - 0.01)
	await wait_physics_frames(2)
	assert_false(tricks.crawling.has(crawler))
	assert_eq(tricks.runners.size(), 1)
	watch_signals(tricks)
	tricks._on_runner_escaped()
	assert_eq(tricks.escaped, 1)
	assert_signal_emitted(tricks, "escaped_one")


func test_a_runner_walked_to_the_cell_counts_once() -> void:
	await _into("magician", TalentTricks.MAGIC_VANISH - 0.01)
	var runner := tricks.runners[0]
	tricks._on_caught(runner)
	tricks._on_caught(runner)
	assert_eq(tricks.caught, 1)
