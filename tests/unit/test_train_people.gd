extends GutTest

## The train's people (escena-tren.md, step 2; MagicianTraits, TrainMagician, TrainStaff).


func test_six_magicians_alike_but_not_the_same() -> void:
	var magicians := MagicianTraits.draw(7)
	assert_eq(magicians.size(), 6)
	var seen := {}
	for magician in magicians:
		seen[MagicianTraits.signature(magician)] = true
	assert_eq(seen.size(), 6, "no two the same")
	assert_eq(MagicianTraits.draw(7), magicians, "same seed, same magicians")
	assert_ne(MagicianTraits.draw(8), magicians, "another seed, others")
	for kind: String in MagicianTraits.CLUES:
		assert_true(magicians[0].has(MagicianTraits.CLUES[kind]), "every clue tells a trait they have")
	var plan := CrimePlan.draw(magicians, 7, MagicianTraits.CLUES)
	assert_eq(plan.clues.size(), CrimePlan.CLUES_PER_CASE)
	assert_eq(CrimePlan.suspects_left(magicians, magicians[plan.culprit], plan.clues, MagicianTraits.CLUES).size(), 1,
		"four clues leave only the culprit")


func test_each_magician_in_front_of_his_seat_with_his_traits() -> void:
	var train := Train.new()
	train.case_seed = 7
	add_child_autofree(train)
	await wait_physics_frames(1)
	assert_eq(train.magicians.size(), 6)
	var traits := MagicianTraits.draw(7)
	for i in 6:
		var magician := train.magicians[i]
		assert_eq(train.suspect(i), magician)
		assert_eq(magician.traits, traits[i])
		assert_eq(train.car_of(magician.global_position + Vector3.UP), Train.CAR_NAMES.find("first"))
		assert_almost_eq(magician.position.x, Train.SEATS[i].x + Train.IN_FRONT_OF_SEAT.x, 0.01, "by his seat")
		assert_eq(magician.part("glasses").visible, traits[i].glasses)
		assert_true(magician.part("hat").visible, "the hat hides the hair")
		assert_false(magician.part("teeth").visible)


func test_a_trick_each_time_and_his_name() -> void:
	var train := Train.new()
	train.case_seed = 7
	add_child_autofree(train)
	var magician := train.magicians[2]
	assert_eq(magician.showing(), "")
	magician.use(null)
	assert_eq(magician.showing(), "dove")
	assert_true(magician.said().contains(magician.traits.name))
	magician.use(null)
	assert_eq(magician.showing(), "hanky", "another trick")
	await wait_seconds(TrainMagician.TRICK_SECONDS + 0.2)
	assert_eq(magician.showing(), "", "the prop goes away")


func test_the_staff_at_their_posts() -> void:
	var train := Train.new()
	add_child_autofree(train)
	await wait_physics_frames(1)
	assert_eq(train.car_of(train.engineer.global_position + Vector3.UP), Train.CAR_NAMES.find("engine"))
	assert_eq(train.car_of(train.inspector.global_position + Vector3.UP), Train.CAR_NAMES.find("first"))
	assert_eq(train.car_of(train.vendor.global_position + Vector3.UP), Train.CAR_NAMES.find("dining"))
	assert_eq(train.car_of(train.cart.global_position + Vector3.UP), Train.CAR_NAMES.find("dining"))
	train.vendor.use(null)
	assert_eq(train.vendor.said(), "TRAIN_VENDOR_LINE_0")
	train.vendor.use(null)
	assert_eq(train.vendor.said(), "TRAIN_VENDOR_LINE_1")
	assert_eq(train.engineer.prompt_key(null), "PROMPT_TRAIN_ENGINEER")


func test_a_cop_still_walks_the_aisle() -> void:
	var train := Train.new()
	add_child_autofree(train)
	await wait_physics_frames(2)
	var space := train.get_world_3d().direct_space_state
	for z: float in [-GameScale.COP_RADIUS + 0.02, GameScale.COP_RADIUS - 0.02]:
		var knee := Train.FLOOR_Y + 0.6
		var ray := PhysicsRayQueryParameters3D.create(train.to_global(Vector3(-28, knee, z)),
			train.to_global(Vector3(15.5, knee, z)))
		assert_true(space.intersect_ray(ray).is_empty(), "from the luggage car to the locomotive, a cop wide")
