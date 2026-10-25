extends GutTest

## The crash (docs/diseno/ciudad-viva.md, "El choque"): the cars behind wait for the wrecks, calming both drivers
## clears the street and pays, and nobody coming means it clears itself for nothing.

const AT := Vector3.ZERO
const PATIENCE_PLUS := CityCar.PATIENCE + 1.5


func test_both_drivers_calmed_clears_the_street_and_pays() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	assert_true(events.start_crash(AT))
	var crash := events.active as CityCrash
	assert_eq(crash.wrecks.size(), 2)
	assert_eq(crash.drivers.size(), 2)
	crash.drivers[0].use(null)
	assert_not_null(events.active, "one calm driver isn't enough")
	crash.drivers[1].use(null)
	assert_eq(events.earned, CityCrash.MONEY, "both calm: the street clears and it pays")
	assert_false(crash.wrecks[0].is_in_group("city_cars"), "the wrecks stop blocking")


func test_cars_behind_wait_for_the_wreck() -> void:
	var crash := CityCrash.new()
	add_child_autofree(crash)
	crash.begin(AT)
	var wreck := crash.wrecks[0]
	var car := CityCar.new()
	# Behind the eastbound wreck, in its lane, heading east.
	var behind := wreck.global_position - Vector3(7, 0, 0)
	car.path = PackedVector3Array([behind, behind + Vector3(100, 0, 0)])
	add_child_autofree(car)
	car.place_along(0.0)
	await wait_seconds(PATIENCE_PLUS)
	assert_lt(car.global_position.x, wreck.global_position.x - 3.0, "it waits, it doesn't drive through")


func test_nobody_comes_and_it_clears_for_nothing() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	events.start_crash(AT)
	var crash := events.active as CityCrash
	crash._physics_process(CityCrash.GIVE_UP + 1.0)
	assert_null(events.active)
	assert_eq(events.earned, 0)


func test_arguing_and_calm_lines_have_texts() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["PROMPT_CRASH_CALM"]
	for k in CrashDriver.ARGUE_LINES:
		keys.append("CRASH_ARGUE_%d" % k)
	for k in 3:
		keys.append("CRASH_CALM_%d" % k)
	for key in keys:
		assert_ne(tr(key), key, "%s needs a text" % key)
