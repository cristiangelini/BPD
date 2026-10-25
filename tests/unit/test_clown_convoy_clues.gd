extends GutTest

## Clown convoy step 3 (control-payasos.md, "Cómo es", step 2): every clown car looks the same, so the plan's clues
## are on the driver (wig, nose, gloves and horn), which show on the clown at the wheel and on him once he's out;
## only the wanted driver fits all 3, and the cars honk their own horn.


func test_the_convoy_s_clues_are_on_the_driver() -> void:
	var kinds := {}
	for case_seed in range(1, 40):
		var plan := WantedPlan.draw(case_seed, true)
		assert_true(plan.convoy)
		for i in plan.clues.size():
			assert_true(plan.clues[i].kind in WantedPlan.CONVOY_KINDS)
			kinds[plan.clues[i].kind] = true
			var text := plan.clue_text(i)
			assert_false(text.contains("CLUE_") or text.contains("COLOR_") or text.contains("CONVOY_"), text)
	assert_eq(kinds.size(), WantedPlan.CONVOY_KINDS.size())


func test_only_the_wanted_driver_fits_every_clue() -> void:
	for case_seed in range(1, 60):
		var plan := WantedPlan.draw(case_seed, true)
		for i in plan.total:
			assert_true(plan.cars[i].has("clown"))
			var fit := plan.fits(plan.cars[i])
			if i == plan.wanted_index:
				assert_eq(fit, WantedPlan.CLUES, "seed %d: the wanted driver fits all" % case_seed)
			elif i in plan.lookalikes:
				assert_eq(fit, WantedPlan.CLUES - 1, "seed %d: a lookalike fits all but one" % case_seed)
			else:
				assert_lte(fit, 1, "seed %d: car %d fits at most one" % [case_seed, i])


func test_the_rush_hour_plan_stays_as_it_was() -> void:
	var plan := WantedPlan.draw(31)
	assert_false(plan.convoy)
	assert_false(plan.cars[0].has("clown"))
	assert_eq(plan.cars, WantedPlan.draw(31, false).cars)


func test_the_driver_at_the_wheel_and_out_shows_his_traits() -> void:
	var traits := {"wig": "COLOR_PINK", "nose": "COLOR_BLUE", "gloves": "COLOR_LIME", "horn": 2}
	var car := QueueCar.new()
	car.clown = true
	car.plate = "BCD 123"
	car.clown_traits = traits
	add_child_autofree(car)
	var seat := car.get_node("Driver") as Node3D
	assert_eq(ConvoyTraits.tint_of(seat, "wig"), ConvoyTraits.WIGS.COLOR_PINK)
	assert_eq(ConvoyTraits.tint_of(seat, "nose"), ConvoyTraits.NOSES.COLOR_BLUE)
	assert_eq(ConvoyTraits.tint_of(seat, "gloves"), ConvoyTraits.GLOVES.COLOR_LIME)
	car.spill()
	var out: ConvoyClown = car.clowns_out[0]
	assert_true(out.is_driver)
	assert_eq(out.traits, traits)
	assert_eq(ConvoyTraits.tint_of(out.get_node("Model"), "wig"), ConvoyTraits.WIGS.COLOR_PINK)
	for clown in car.clowns_out:
		autofree(clown)


func test_riders_are_dressed_alike_on_every_pc() -> void:
	var a := QueueCar.new()
	a.plate = "XYZ 001"
	var b := QueueCar.new()
	b.plate = "XYZ 001"
	assert_eq(a._rider_traits(2), b._rider_traits(2))
	a.free()
	b.free()


func test_a_clown_car_honks_its_own_horn() -> void:
	var car := QueueCar.new()
	car.clown = true
	car.clown_traits = {"wig": "COLOR_PINK", "nose": "COLOR_RED", "gloves": "COLOR_WHITE", "horn": 1}
	add_child_autofree(car)
	car.honk()
	assert_eq(car.saying(), tr("CONVOY_HORN_1"))


func test_the_queue_gives_its_cars_the_plan_s_drivers() -> void:
	var checkpoint := TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "clown_convoy"
	queue.plan = WantedPlan.draw(5, true)
	add_child_autofree(queue)
	queue.set_physics_process(false)
	var car := queue.spawn()
	car.set_physics_process(false)
	assert_eq(car.clown_traits, queue.plan.cars[0].clown)
	assert_eq(car.net_setup().clown_traits, car.clown_traits)


func test_texts_are_translated() -> void:
	for key in ["COLOR_RED", "CLUE_CONVOY_WIG", "CLUE_CONVOY_NOSE", "CLUE_CONVOY_GLOVES", "CLUE_CONVOY_HORN",
			"BRIEF_CONVOY_A", "BRIEF_CONVOY_C"]:
		assert_ne(tr(key), key)
	for i in ConvoyTraits.HORNS:
		assert_ne(tr("CONVOY_HORN_%d" % i), "CONVOY_HORN_%d" % i)
