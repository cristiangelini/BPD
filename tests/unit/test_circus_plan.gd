extends GutTest

## Circus move step 4 (control-circo.md, "Cómo es" 1 and 5): the plan seats El Peludo among the circus's trucks, in
## one of the costumes a person fits, his sneakers showing; his clues are the animal he looks like, his sneakers, his
## truck's stripes and its plate. Only he fits all three, a few real animals fit two, and a few city cars come too.

func _plan(case_seed: int) -> WantedPlan:
	return WantedPlan.draw(case_seed, false, false, false, false, false, false, false, true)


func test_el_peludo_rides_in_a_costume_among_the_circus_trucks() -> void:
	for case_seed in 30:
		var plan := _plan(case_seed)
		assert_true(plan.circus)
		assert_between(plan.total, WantedPlan.CIRCUS_TOTAL.x, WantedPlan.CIRCUS_TOTAL.y)
		assert_between(plan.wanted_index, WantedPlan.CIRCUS_WANTED_AT.x, WantedPlan.CIRCUS_WANTED_AT.y)
		var peludo: Dictionary = plan.cars[plan.wanted_index].circus
		assert_true(peludo.costume)
		assert_has(CircusTruck.COSTUMES, peludo.animal)
		var trucks := 0
		for i in plan.total:
			var circus: Dictionary = plan.cars[i].circus
			if not circus.is_empty():
				trucks += 1
			if i != plan.wanted_index:
				assert_false(circus.get("costume", false), "only one costume")
				assert_false(circus.has("sneakers"), "real animals wear no sneakers")
		assert_between(trucks, plan.total / 2, plan.total)


func test_only_el_peludo_fits_every_clue_and_a_few_real_animals_fit_two() -> void:
	var kinds := {}
	for case_seed in 40:
		var plan := _plan(case_seed)
		for clue in plan.clues:
			assert_has(WantedPlan.CIRCUS_KINDS, clue.kind)
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
				assert_false(plan.cars[i].circus.is_empty(), "a lookalike is a circus truck")
		assert_between(twos, WantedPlan.LOOKALIKES.x, WantedPlan.LOOKALIKES.y)
	assert_eq(kinds.size(), WantedPlan.CIRCUS_KINDS.size(), "every kind of clue comes up")


func test_the_clues_read_about_him() -> void:
	var plan := WantedPlan.new()
	plan.clues.assign([{"kind": "animal", "value": "gorilla"}, {"kind": "sneakers", "value": 3},
		{"kind": "stripes", "value": 1}])
	assert_string_contains(plan.clue_text(0), tr("ANIMAL_GORILLA"))
	assert_string_contains(plan.clue_text(1), tr(CircusTruck.SNEAKER_NAMES[3]))
	assert_string_contains(plan.clue_text(2), tr(CircusTruck.STRIPE_NAMES[1]))


func test_the_queue_brings_el_peludo_in_his_sneakers() -> void:
	var checkpoint := TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.set_physics_process(false)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "circus_move"
	queue.plan = _plan(9)
	add_child_autofree(queue)
	queue.set_physics_process(false)
	queue.spawned = queue.plan.wanted_index
	var car := queue.spawn()
	car.set_physics_process(false)
	assert_true(car.wanted)
	assert_eq(car.circus, queue.plan.cars[queue.plan.wanted_index].circus)
	var shoe := CircusTruck.animal_of(car).get_node("Sneaker") as MeshInstance3D
	assert_eq((shoe.mesh.surface_get_material(0) as StandardMaterial3D).albedo_color,
		CircusTruck.SNEAKERS[car.circus.sneakers])
	assert_eq(car.feed(CircusTruck.food_of(car.circus.animal)), "refused", "the plan's costume")
	queue.spawned = (queue.plan.wanted_index + 1) % queue.plan.total
	var other := queue.spawn()
	other.set_physics_process(false)
	if not other.circus.is_empty():
		assert_null(CircusTruck.animal_of(other).get_node_or_null("Sneaker"))


func test_the_comisario_tells_the_jewelry_s_story() -> void:
	var case := TrafficCase.new()
	case.plan = _plan(4)
	assert_eq(case.campaign_key(), "traffic_circus_move")
	case.free()


func test_texts_are_translated() -> void:
	for key in ["CLUE_CIRCUS_ANIMAL", "CLUE_CIRCUS_SNEAKERS", "CLUE_CIRCUS_STRIPES", "BRIEF_CIRCUS_MOVE_A",
			"BRIEF_CIRCUS_MOVE_C"]:
		assert_ne(tr(key), key)
