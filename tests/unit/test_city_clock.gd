extends GutTest

## The city's clock (docs/diseno/ciudad-viva.md, step 5): a game hour per real minute, the sun up in the day and down
## at night, lamps and windows lit at night and half the walkers gone home.

const CITY_SCENE := preload("res://scenes/levels/city.tscn")


func test_day_and_night_by_the_hour() -> void:
	assert_eq(CityClock.daylight(12.0), 1.0, "noon is day")
	assert_eq(CityClock.daylight(0.0), 0.0, "midnight is night")
	assert_eq(CityClock.daylight(22.0), 0.0)
	assert_between(CityClock.daylight(CityClock.SUNRISE), 0.1, 0.9, "the light comes little by little")
	assert_gt(CityClock.elevation(12.5), 55.0, "the sun is high at noon")
	assert_lt(CityClock.elevation(23.0), 0.0, "and under the horizon at night")
	assert_eq(CityClock.text(14.0 + 5.0 / 60.0), "14:05")


func test_a_shift_starts_in_the_day() -> void:
	for seed_value in 30:
		assert_between(CityClock.start_hour(seed_value), float(CityClock.START_MIN), float(CityClock.START_MAX))


func test_an_hour_lasts_a_minute_and_wraps_at_midnight() -> void:
	var clock := CityClock.new()
	clock.hour = 23.5
	add_child_autofree(clock)
	clock._process(CityClock.SECONDS_PER_HOUR)
	assert_almost_eq(clock.hour, 0.5, 0.001, "a real minute later it's half past midnight")


func test_night_lights_the_lamps_and_sends_half_the_walkers_home() -> void:
	var city: City = add_child_autofree(CITY_SCENE.instantiate())
	var clock := city.clock
	assert_not_null(clock, "the test city has a clock")
	clock.running = false
	clock.hour = 12.0
	clock.apply()
	assert_false(clock.night)
	var walkers := get_tree().get_nodes_in_group("city_walkers").size()
	assert_eq(clock.lamps[0].emission_energy_multiplier, 0.0, "lamps off in the day")
	clock.hour = 23.0
	clock.apply()
	assert_true(clock.night)
	assert_gt(clock.lamps[0].emission_energy_multiplier, 1.0, "lamps on at night")
	assert_true(clock.windows[0].emission_enabled, "windows lit")
	assert_lt(clock.sun.light_energy, 0.5, "only the moon")
	assert_almost_eq(get_tree().get_nodes_in_group("city_walkers").size(), walkers / 2, 1, "half went home")
	clock.hour = 9.0
	clock.apply()
	assert_eq(get_tree().get_nodes_in_group("city_walkers").size(), walkers, "and they're back in the morning")
