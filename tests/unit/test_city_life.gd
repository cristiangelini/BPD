extends GutTest

## The living city's streets (docs/diseno/ciudad-viva.md, step 2): raised sidewalks a cop walks up onto, and dead-end
## alleys that fit their blocks without touching any lot.

const CITY_SCENE := preload("res://scenes/levels/city.tscn")


func _lots() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for p: Dictionary in CityLayout.PLACES:
		rects.append(CityLayout.footprint(p.block, p.side, p.along, p.size))
	for lot: Dictionary in CityLayout.fillers():
		rects.append(CityLayout.footprint(lot.block, lot.side, lot.along, lot.size))
	return rects


func test_alleys_fit_their_blocks_without_touching_a_lot() -> void:
	var lots := _lots()
	for alley: Array in CityLife.ALLEYS:
		var block: Vector2i = alley[0]
		assert_ne(block, CityLayout.PLAZA, "no alley in the plaza")
		var rect := CityLife.alley_rect(block, alley[1])
		var center := CityLayout.block_center(block)
		var inner := CityLayout.BLOCK - CityLayout.SIDEWALK * 2
		var ground := Rect2(Vector2(center.x, center.z) - Vector2.ONE * inner / 2, Vector2.ONE * inner)
		assert_true(ground.grow(0.01).encloses(rect), "the alley in %s sticks out of its block" % block)
		for lot in lots:
			assert_false(rect.intersects(lot), "the alley in %s runs into a lot" % block)


func test_every_city_is_alive_but_night_cases_keep_their_own_sky() -> void:
	var city: City = add_child_autofree(CITY_SCENE.instantiate())
	assert_not_null(city.get_node_or_null("Built/Life"), "the test city has its sidewalks, lamps and alleys")
	assert_not_null(city.clock, "and its clock")
	var case_city := City.new()
	case_city.live_place = "grandpa"
	add_child_autofree(case_city)
	assert_not_null(case_city.get_node_or_null("Built/Life"), "on the way to a case the city is alive too")
	assert_not_null(case_city.events, "and things happen in its streets")
	var night_city := City.new()
	night_city.night = true
	add_child_autofree(night_city)
	assert_null(night_city.clock, "the jailbreak's night stays night")
	assert_null(night_city.rain)


func test_a_chase_with_its_own_weather_holds_the_city_clock() -> void:
	var city: City = add_child_autofree(CITY_SCENE.instantiate())
	city.clock.hour = 23.0
	city.clock.apply()
	city.hold_weather()
	assert_null(city.clock, "no clock")
	assert_null(city.rain, "no rain")
	var sun: DirectionalLight3D = city.get_node("Sun")
	assert_gt(sun.light_energy, 1.0, "back to noon's light for the chase to dress")


func test_a_cop_walks_up_onto_the_sidewalk() -> void:
	var city: City = add_child_autofree(CITY_SCENE.instantiate())
	var cop: Cop = city.get_node("Cop")
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	# On the street north of the station's block (2, 2), walking south into its sidewalk.
	var edge := CityLayout.block_center(Vector2i(2, 2)).z - CityLayout.BLOCK / 2
	cop.global_position = Vector3(CityLayout.block_center(Vector2i(2, 2)).x + 20.0, 0.1, edge - 2.0)
	cop.rotation.y = 0.0
	await wait_physics_frames(10)
	for i in 90:
		cop.step(1.0 / 60.0, Vector2(0, 1), false, false, false)
		await wait_physics_frames(1)
	assert_gt(cop.global_position.z, edge + 1.0, "the curb doesn't stop a walking cop")
	assert_gt(cop.global_position.y, CityLife.CURB - 0.05, "and they stand on top of the sidewalk")
