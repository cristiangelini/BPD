extends GutTest

## The bakery's third story, the stolen sourdough (docs/diseno/panaderia.md, "La masa madre robada").

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")
const JAR_SCENE := preload("res://scenes/props/sourdough_jar.tscn")


func _bakery(case_seed := 5) -> Bakery:
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.story_id = "sourdough"
	bakery.case_seed = case_seed
	bakery.get_node("Cop").input_enabled = false
	bakery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(bakery)
	bakery._customer_wait = 999.0
	return bakery


func test_gertrudis_and_the_medal_wait_in_two_spots() -> void:
	var bakery := _bakery()
	await wait_physics_frames(30)
	assert_true(bakery.main is SourdoughJar)
	assert_eq(bakery.hidden.size(), 2)
	assert_eq(bakery.extras.size(), 1, "the medal is the only extra")
	assert_ne(bakery.hidden_spots[0], bakery.hidden_spots[1])
	for i in bakery.hidden.size():
		var spot: Vector3 = Bakery.SPOTS[bakery.hidden_spots[i]].at
		assert_lt(bakery.hidden[i].global_position.distance_to(spot), 0.4, "still on its spot")
	assert_false(bakery.main.is_broken, "setting her down doesn't break the jar")
	assert_has(bakery.raid.suspicions, "sourdough")
	assert_eq(bakery.baker.slips.size(), 2, "Marta can let slip where Gertrudis is too")


func test_she_grows_heavier_every_minute_up_to_a_limit() -> void:
	var jar: SourdoughJar = JAR_SCENE.instantiate()
	add_child_autofree(jar)
	var start := jar.mass
	jar.grow()
	assert_almost_eq(jar.mass, start + SourdoughJar.GROW_KG, 0.001)
	for i in 50:
		jar.grow()
	assert_eq(jar.mass, SourdoughJar.MAX_KG)


func test_a_soft_bump_is_fine_but_a_drop_breaks_the_jar() -> void:
	var jar: SourdoughJar = JAR_SCENE.instantiate()
	add_child_autofree(jar)
	assert_eq(jar.hit(2.5), 0.0, "a soft bump does nothing")
	jar.hit(SourdoughJar.SHATTER_SPEED + 0.5)
	assert_true(jar.is_broken, "a drop from a cop's hands is enough")


func test_breaking_gertrudis_fails_the_case() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	bakery.main.hit(10.0)
	assert_true(bakery.raid.case_failed)


func test_she_gurgles_and_shows_it_only_to_cops_nearby() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var jar: SourdoughJar = bakery.main
	var cop: Cop = bakery.get_node("Cop")
	cop.global_position = jar.global_position + Vector3(SourdoughJar.HEAR_RANGE + 3, 0, 0)
	jar._bubble()
	assert_false(jar._blub.visible, "too far to hear")
	cop.global_position = jar.global_position + Vector3(1.5, 0, 0)
	jar._bubble()
	assert_true(jar._blub.visible)
	assert_not_null(jar._gurgle.stream)


func test_gertrudis_in_the_trunk_solves_the_case() -> void:
	var bakery := _bakery()
	await wait_physics_frames(10)
	var jar := bakery.main
	jar.global_position = bakery.car.to_global(Vector3(0, 0.6, -1.7))
	jar.linear_velocity = Vector3.ZERO
	await wait_physics_frames(20)
	assert_false(jar.is_broken, "set down gently in the trunk")
	assert_true(bakery.car.is_delivered(jar))
	assert_true(bakery.raid.mark(bakery.raid.suspicions.find("sourdough")))
	bakery.car.enter(bakery.get_node("Cop"))
	assert_true(bakery.raid.case_solved)
