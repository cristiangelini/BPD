extends GutTest

## Parar y revisar (docs/diseno/ciudad-viva.md): E stops a walker, E again searches their bag; cuffed with something
## forbidden they pay the shift, an innocent one only complains, and some run off when stopped.


func _walker(contraband: int) -> CityWalker:
	var walker := CityWalker.new()
	walker.contraband = contraband
	walker.path = CityTraffic.ring(Vector2i(3, 3))
	add_child_autofree(walker)
	# Ready rolls the dice for a bag with something in it: -1 has to stay an innocent one.
	walker.contraband = contraband
	walker.place_along(0.2)
	return walker


func test_every_line_and_find_has_a_text() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["PROMPT_STREET_HALT", "PROMPT_STREET_SEARCH", "STREET_BUSTED", "EVENT_PAID",
		"EVENT_PURSE_HELP", "EVENT_PURSE_THANKS"]
	for k in CityWalker.HALT_LINES:
		keys.append("STREET_HALTED_%d" % k)
	for k in CityWalker.CONTRABAND_KINDS:
		keys.append("STREET_FOUND_%d" % k)
	for k in CityWalker.INNOCENT_LINES:
		keys.append("STREET_NOTHING_%d" % k)
	for key in keys:
		assert_ne(tr(key), key, "%s needs a text" % key)


func test_stop_search_and_bust_pays() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	var walker := _walker(2)
	events.watch(walker)
	walker.halt(null, 0)
	assert_true(walker.halted, "stopped")
	assert_true(walker.is_stopped(), "and standing still")
	assert_eq(walker.prompt_key(null), "PROMPT_STREET_SEARCH", "next E searches")
	walker.search()
	assert_true(walker.searched)
	walker.cuffed(Handcuffs.SECONDS)
	assert_eq(events.earned, CityEvents.BUSTED_MONEY, "a parrot with no papers pays")
	walker.cuffed(Handcuffs.SECONDS)
	assert_eq(events.earned, CityEvents.BUSTED_MONEY, "only once")


func test_an_innocent_one_only_complains() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	var walker := _walker(-1)
	events.watch(walker)
	walker.halt(null, 0)
	walker.search()
	walker.cuffed(Handcuffs.SECONDS)
	assert_eq(events.earned, 0, "nothing in the bag, nothing to pay")


func test_one_who_runs_off_becomes_a_runaway_and_pays_when_caught() -> void:
	var events := CityEvents.new()
	add_child_autofree(events)
	var walker := _walker(5)
	events.watch(walker)
	walker.halt(null, 1)
	assert_not_null(walker.runaway, "off they go")
	assert_false(walker.visible)
	assert_false(walker.is_in_group("city_walkers"), "no longer one of the walkers")
	walker.runaway.cuffed(Handcuffs.SECONDS)
	assert_eq(events.earned, CityEvents.BUSTED_MONEY)
	walker.runaway.free()


func test_about_one_in_five_carries_something() -> void:
	var carrying := 0
	for i in 200:
		var walker := CityWalker.new()
		add_child(walker)
		if walker.contraband >= 0:
			carrying += 1
		walker.free()
	assert_between(carrying, 20, 65, "about 40 of 200")
