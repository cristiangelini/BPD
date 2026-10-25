extends GutTest

## The city's rain (docs/diseno/ciudad-viva.md, step 6): 1 shift in 4, a while, and while it pours the patrol car
## grips less, cars slow down, people hurry and the street shines.

const CITY_SCENE := preload("res://scenes/levels/city.tscn")


func test_it_rains_about_one_shift_in_four() -> void:
	var rainy := 0
	for seed_value in 400:
		var plan := CityRain.plan(seed_value)
		if plan.length > 0.0:
			rainy += 1
			assert_between(plan.start, CityRain.START_MIN, CityRain.START_MAX)
			assert_between(plan.length, CityRain.LENGTH_MIN, CityRain.LENGTH_MAX)
	assert_between(rainy, 70, 130, "about a quarter of 400 shifts")


func test_the_rain_comes_and_goes() -> void:
	var rain := CityRain.new()
	rain.start = 100.0
	rain.length = 200.0
	add_child_autofree(rain)
	assert_eq(rain.wetness(50.0), 0.0, "dry before")
	assert_between(rain.wetness(105.0), 0.1, 0.9, "it comes little by little")
	assert_eq(rain.wetness(200.0), 1.0, "pouring in the middle")
	assert_eq(rain.wetness(301.0), 0.0, "and dry after")


func test_pouring_changes_the_city() -> void:
	var city: City = add_child_autofree(CITY_SCENE.instantiate())
	city.rain.length = 0.0
	await wait_physics_frames(2)
	var car: PatrolCar = city.get_node("PatrolCar")
	var road := city.rain.streets[0]
	city.rain.set_wet(1.0)
	assert_eq(car.grip, ChaseWeather.RAIN_GRIP, "the patrol car grips like in the rainy chase")
	var traffic: CityCar = get_tree().get_nodes_in_group("city_cars")[0]
	assert_lt(traffic.speed_factor, 1.0, "cars slow down")
	var walker: CityWalker = get_tree().get_nodes_in_group("city_walkers")[0]
	assert_gt(walker.hurry, 1.0, "people hurry")
	assert_lt(road.roughness, 0.5, "the street shines")
	assert_eq(city.clock.overcast, 1.0, "the sky is grey")
	city.rain.set_wet(0.0)
	assert_eq(car.grip, 1.0, "dry again")
	assert_eq(traffic.speed_factor, 1.0)
