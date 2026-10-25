extends GutTest

## Wedding breathalyzer check step 4 (control-boda.md, "Cómo es", steps 4 and 5): the plan seats the wedding's convoy.
## The newlyweds' white car comes up front, a few city cars come along, El Colado drives a guest's car and blows 0.0,
## and so do 2 or 3 designated drivers; the guests toast the couple with the license and El Colado gets their names
## wrong. His clues can be his bow tie.


func test_el_colado_blows_zero_like_the_designated_drivers() -> void:
	for case_seed in 40:
		var plan := WantedPlan.draw(case_seed, false, false, false, false, true)
		assert_true(plan.wedding)
		var wanted: Dictionary = plan.cars[plan.wanted_index]
		assert_true(wanted.guest, "a guest's car")
		assert_eq(wanted.alcohol, 0.0)
		assert_between(plan.designated().size(), WantedPlan.DESIGNATED.x, WantedPlan.DESIGNATED.y)
		var drunk := 0
		for car: Dictionary in plan.cars:
			if car.alcohol > WeddingCar.DRUNK_ABOVE:
				drunk += 1
		assert_gt(drunk, 0, "some to take the keys from (seed %d)" % case_seed)


func test_he_toasts_the_wrong_couple() -> void:
	for case_seed in 40:
		var plan := WantedPlan.draw(case_seed, false, false, false, false, true)
		for i in plan.total:
			if i == plan.wanted_index:
				assert_ne(plan.cars[i].couple, plan.couple)
			else:
				assert_eq(plan.cars[i].couple, plan.couple)


func test_the_newlyweds_come_up_front_in_white_and_some_cars_are_the_city_s() -> void:
	var city := 0
	for case_seed in 40:
		var plan := WantedPlan.draw(case_seed, false, false, false, false, true)
		assert_lt(plan.newlyweds_index, WeddingCar.NEWLYWEDS_AT + WantedPlan.LOOKALIKES.y + 1, "up front")
		assert_ne(plan.newlyweds_index, plan.wanted_index)
		var newlyweds: Dictionary = plan.cars[plan.newlyweds_index]
		assert_true(newlyweds.newlyweds)
		assert_eq(newlyweds.look, WeddingCar.NEWLYWEDS_LOOK)
		assert_lt(plan.fits(newlyweds), WantedPlan.CLUES, "never fits every clue")
		for i in plan.total:
			if i != plan.wanted_index:
				assert_lt(plan.fits(plan.cars[i]), WantedPlan.CLUES)
			if not plan.cars[i].guest:
				city += 1
				assert_eq(plan.cars[i].alcohol, 0.0)
	assert_gt(city, 40)


func test_the_bow_tie_can_be_a_clue() -> void:
	var seen := false
	for case_seed in 60:
		var plan := WantedPlan.draw(case_seed, false, false, false, false, true)
		for i in plan.clues.size():
			if plan.clues[i].kind == "tie":
				seen = true
				assert_eq(plan.clue_text(i), tr("CLUE_WEDDING_TIE") % tr(WantedPlan.SHIRTS[plan.clues[i].value]))
	assert_true(seen)


func test_the_queue_seats_the_plan_s_cars_and_their_toasts() -> void:
	var plan := WantedPlan.draw(7, false, false, false, false, true)
	var checkpoint := TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.set_physics_process(false)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "wedding"
	queue.plan = plan
	add_child_autofree(queue)
	queue.set_physics_process(false)
	for i in plan.total:
		var car := queue.spawn()
		car.set_physics_process(false)
		assert_eq(car.guest, plan.cars[i].guest)
		assert_eq(car.alcohol, plan.cars[i].alcohol)
		assert_eq(car.newlyweds, i == plan.newlyweds_index)
		if i == plan.wanted_index:
			car.state = "waiting"
			car.use(null)
			var wrong := WeddingCar.names(car.couple)
			assert_string_contains(car.saying(), wrong[0])
			assert_false(car.saying().contains(WeddingCar.names(plan.couple)[0]) and car.saying().contains(
				WeddingCar.names(plan.couple)[1]), "not the right couple")
		elif car.guest and not car.newlyweds:
			car.state = "waiting"
			car.use(null)
			assert_string_contains(car.saying(), WeddingCar.names(plan.couple)[0])


func test_the_comisario_names_the_couple() -> void:
	var plan := WantedPlan.draw(3, false, false, false, false, true)
	var names := WeddingCar.names(plan.couple)
	assert_string_contains(tr("BRIEF_WEDDING_CHECK_A") % names, names[1])
	# Its own keys: the bakery's wedding cake case already has BRIEF_WEDDING_B to D.
	assert_ne(tr("BRIEF_WEDDING_CHECK_C"), tr("BRIEF_WEDDING_C"))
	var case := TrafficCase.new()
	case.plan = plan
	assert_eq(case.campaign_key(), "traffic_wedding")
	case.free()
