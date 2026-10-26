extends GutTest

## Fog check step 4 (control-neblina.md, "Cómo es" 4 and 5): the plan seats La Bruma among the cars in the fog, the
## lighthouse lamp in his trunk; his clues are his paint, his headlights' color, his horn and his broken headlight,
## only he fits all three and a few cars fit two. The comisario tells the lighthouse's story.

func _plan(case_seed: int) -> WantedPlan:
	return WantedPlan.draw(case_seed, false, false, false, false, false, false, true)


func test_la_bruma_carries_the_lighthouse_lamp() -> void:
	for case_seed in 30:
		var plan := _plan(case_seed)
		assert_true(plan.fog)
		assert_between(plan.total, WantedPlan.FOG_TOTAL.x, WantedPlan.FOG_TOTAL.y)
		assert_between(plan.wanted_index, WantedPlan.FOG_WANTED_AT.x, WantedPlan.FOG_WANTED_AT.y)
		assert_eq(plan.cars[plan.wanted_index].driver.trunk, "lamp")
		for car: Dictionary in plan.cars:
			assert_true(car.has("fog"), "every car's headlights and horn")


func test_only_la_bruma_fits_every_clue_and_a_few_fit_two() -> void:
	var kinds := {}
	for case_seed in 30:
		var plan := _plan(case_seed)
		for clue in plan.clues:
			assert_has(WantedPlan.FOG_KINDS, clue.kind)
			kinds[clue.kind] = true
		assert_eq(plan.fits(plan.cars[plan.wanted_index]), WantedPlan.CLUES)
		var twos := 0
		for i in plan.total:
			if i == plan.wanted_index:
				continue
			var fit := plan.fits(plan.cars[i])
			assert_lt(fit, WantedPlan.CLUES)
			if fit == WantedPlan.CLUES - 1:
				twos += 1
		assert_between(twos, WantedPlan.LOOKALIKES.x, WantedPlan.LOOKALIKES.y)
	assert_eq(kinds.size(), WantedPlan.FOG_KINDS.size(), "every kind of clue comes up")


func test_the_clues_read_about_his_car() -> void:
	var plan := WantedPlan.new()
	plan.clues.assign([{"kind": "lights", "value": 1}, {"kind": "honk", "value": 4}, {"kind": "broken", "value": 2}])
	assert_string_contains(plan.clue_text(0), tr(FogCar.LIGHT_NAMES[1]))
	assert_string_contains(plan.clue_text(1), tr("FOG_HORN_4"))
	assert_string_contains(plan.clue_text(2), tr("BROKEN_RIGHT"))


func test_the_queue_brings_the_plan_s_cars() -> void:
	var checkpoint := TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.set_physics_process(false)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "fog"
	queue.plan = _plan(9)
	add_child_autofree(queue)
	queue.set_physics_process(false)
	queue.spawned = queue.plan.wanted_index
	var car := queue.spawn()
	car.set_physics_process(false)
	assert_true(car.wanted)
	assert_eq(car.fog, queue.plan.cars[queue.plan.wanted_index].fog)
	car.lid.set_angle(TrunkLid.MAX_ANGLE)
	car._on_trunk_opened()
	assert_eq(car.saying(), tr("TRUNK_LAMP"))
	assert_gt(car.get_node("Trunk").get_child_count(), 0)


func test_the_comisario_tells_the_lighthouse_s_story() -> void:
	var case := TrafficCase.new()
	case.plan = _plan(4)
	assert_eq(case.campaign_key(), "traffic_fog")
	case.free()


func test_texts_are_translated() -> void:
	for key in ["CLUE_FOG_LIGHTS", "CLUE_FOG_HONK", "CLUE_FOG_BROKEN", "TRUNK_LAMP", "BRIEF_FOG_A", "BRIEF_FOG_C"]:
		assert_ne(tr(key), key)
