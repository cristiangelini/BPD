extends GutTest

## The loose dogs of the pet salon (docs/diseno/peluqueria.md, step 3).

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer() -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.get_node("Cop").input_enabled = false
	add_child_autofree(groomer)
	return groomer


func _near(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func test_six_dogs_loose_and_light_enough_to_pick_up() -> void:
	var groomer := _groomer()
	await wait_physics_frames(5)
	assert_eq(groomer.dogs.size(), 6)
	for dog in groomer.dogs:
		assert_true(dog.is_in_group("dogs"))
		assert_lt(dog.mass, GameScale.COP_CARRY_KG, "one cop carries it")


func test_dogs_never_walk_into_the_locked_storeroom() -> void:
	var groomer := _groomer()
	await wait_physics_frames(10)
	var map := groomer.get_world_3d().navigation_map
	# From the grooming room to the doghouse the way goes through the cages, not the locked storeroom.
	var path := NavigationServer3D.map_get_path(map, Vector3(5.0, Groomer.FLOOR_TOP, 4.0), Groomer.DOGHOUSE_AT, true)
	assert_false(path.is_empty(), "there is a way to the doghouse")
	if path.is_empty():
		return
	assert_lt(_near(path[path.size() - 1], Groomer.DOGHOUSE_AT), 0.6, "it reaches the doghouse")
	for point in path:
		var in_store := point.x > Groomer.CAGES_EAST and point.z < Groomer.SPLIT_Z - 0.3 and point.z > Groomer.BACK_Z + 0.3
		assert_false(in_store, "%s is not in the storeroom" % point)


func test_a_dog_follows_the_cop_with_something_in_hand() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	cop.global_position = Vector3(-3.0, 0.1, 5.5)
	await wait_physics_frames(10)
	var dog := groomer.dogs[0]
	var bottle: Grabbable = groomer.shampoos[0]
	cop.get_node("Grabber").grab(bottle)
	var start := _near(dog.global_position, cop.global_position)
	await wait_seconds(2.0)
	assert_eq(dog.state, Dog.State.FOLLOW)
	var now := _near(dog.global_position, cop.global_position)
	assert_lt(now, Dog.KEEP + 0.8, "it comes up to the cop (from %.1f to %.1f m)" % [start, now])


func test_a_dog_takes_something_left_on_the_floor_to_the_doghouse() -> void:
	var groomer := _groomer()
	await wait_physics_frames(10)
	var dog := groomer.dogs[3]
	var collar: Grabbable = groomer.collars[0]
	collar.global_position = dog.global_position + Vector3(1.0, 0.1, 0.5)
	collar.rotation = Vector3.ZERO
	collar.was_held = true
	for other in groomer.dogs:
		other._fetch_wait = 999.0
	dog._fetch_wait = 0.0
	await wait_physics_frames(30)
	assert_true(dog.state in [Dog.State.FETCH, Dog.State.CARRY], "it goes for the collar")
	for i in 30:
		if dog.thefts > 0:
			break
		await wait_seconds(0.5)
	assert_eq(dog.thefts, 1, "it got to the doghouse")
	assert_true(is_instance_valid(collar) and not collar.is_broken, "set down, not dropped")
	if is_instance_valid(collar):
		assert_lt(_near(collar.global_position, Groomer.DOGHOUSE_AT), 1.0, "and left the collar there")


func test_grabbing_the_thing_back_makes_it_let_go() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(10)
	var dog := groomer.dogs[3]
	var collar: Grabbable = groomer.collars[0]
	dog._pick_up(collar)
	dog.state = Dog.State.CARRY
	await wait_physics_frames(3)
	assert_true(collar.freeze, "in its mouth")
	cop.get_node("Grabber").grab(collar)
	await wait_physics_frames(3)
	assert_null(dog.carried)
	assert_false(collar.freeze)


func test_bumping_or_throwing_a_dog_makes_ramiro_complain() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var dog := groomer.dogs[0]
	cop.velocity = Vector3(GameScale.RUN_SPEED, 0, 0)
	dog._on_body_entered(cop)
	assert_eq(groomer.ramiro.complaint, DogGroomer.DOG_BARKED)
	dog._on_body_entered(cop)
	assert_eq(groomer.ramiro.complaint, DogGroomer.DOG_BARKED, "one bark per BARK_COOLDOWN")
	dog._since_bark = Dog.BARK_COOLDOWN
	cop.velocity = Vector3(1.0, 0, 0)
	dog._on_body_entered(cop)
	assert_eq(groomer.ramiro.complaint, DogGroomer.DOG_BARKED, "brushing past it slowly is fine")
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.grab(dog)
	grabber.throw()
	assert_eq(groomer.ramiro.complaint, DogGroomer.DOG_BARKED * 2, "a thrown dog barks")


func test_a_real_dog_works_in_the_armchair() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	cop.global_position = Groomer.ARMCHAIR_AT + Vector3(0, 0.1, -1.2)
	await wait_physics_frames(5)
	cop.get_node("Grabber").grab(groomer.dogs[0])
	groomer.armchair.use(cop)
	assert_eq(cop.seated_in, groomer.armchair)
	assert_true(groomer.ramiro.is_telling_story())
