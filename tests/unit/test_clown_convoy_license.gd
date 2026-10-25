extends GutTest

## Clown convoy step 4 (control-payasos.md, "Cómo es", step 5): a clown's license has his photo without makeup, so
## it only helps once the sponge scrubs his face clean; the wanted clown carries someone else's license and the
## ringmaster's safe, and the other trunks have balloons, cream pies or a cardboard safe.


## A spilled clown car with this driver.
func _car(driver_glasses: bool, license_glasses: bool) -> QueueCar:
	var car := QueueCar.new()
	car.clown = true
	car.plate = "BCD 123"
	car.driver = {"name": "Aurelio", "surname": "Pomelo", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "pies",
		"license_glasses": license_glasses}
	car.clown_traits = {"wig": "COLOR_PINK", "nose": "COLOR_RED", "gloves": "COLOR_WHITE", "horn": 0,
		"glasses": driver_glasses}
	add_child_autofree(car)
	car.spill()
	for out in car.clowns_out:
		autofree(out)
	return car


func _cop_with_sponge() -> Cop:
	var cop: Cop = load("res://scenes/player/cop.tscn").instantiate()
	add_child_autofree(cop)
	var sponge := ClownSponge.new()
	add_child_autofree(sponge)
	cop.get_node("Grabber").held = sponge
	return cop


func test_the_wanted_clown_has_the_safe_and_someone_else_s_license() -> void:
	for case_seed in range(1, 30):
		var plan := WantedPlan.draw(case_seed, true)
		for i in plan.total:
			var car: Dictionary = plan.cars[i]
			if i == plan.wanted_index:
				assert_eq(car.driver.trunk, "safe")
				assert_ne(car.driver.license_glasses, car.clown.glasses, "seed %d: not his photo" % case_seed)
			else:
				assert_true(car.driver.trunk in ConvoyTraits.TRUNKS, "seed %d" % case_seed)
				assert_eq(car.driver.license_glasses, car.clown.glasses, "seed %d: his own photo" % case_seed)


func test_the_rush_hour_license_says_nothing_of_a_photo() -> void:
	var driver := {"name": "Dalia", "surname": "Tetera", "year": 1970}
	assert_eq(DriverTraits.license_text(driver), tr("LICENSE_TEXT") % ["Dalia", "Tetera", 1970])


func test_the_driver_hands_his_license_with_the_photo() -> void:
	var car := _car(true, false)
	var driver := car.clowns_out[0]
	assert_eq(driver.prompt_key(null), "PROMPT_PAPERS")
	driver.use(null)
	assert_true(car.papers_checked)
	assert_true(driver.saying().contains(tr("LICENSE_PHOTO_NO_GLASSES")))
	var rider := car.clowns_out[1]
	rider.use(null)
	assert_eq(rider.saying(), tr("CONVOY_NOT_DRIVER"))


func test_made_up_his_glasses_don_t_show() -> void:
	var car := _car(true, true)
	var model := car.clowns_out[0].get_node("Model")
	assert_false((model.find_child("glasses", true, false) as Node3D).visible)
	assert_true((model.find_child("makeup", true, false) as Node3D).visible)


func test_the_sponge_scrubs_his_face_clean_and_his_glasses_show() -> void:
	var car := _car(true, true)
	var driver := car.clowns_out[0]
	var cop := _cop_with_sponge()
	assert_eq(driver.prompt_key(cop), "PROMPT_CLOWN_SCRUB")
	for i in ConvoyClown.SCRUBS - 1:
		driver.use(cop)
		assert_true(driver.makeup_on)
	driver.use(cop)
	assert_false(driver.makeup_on)
	assert_eq(driver.saying(), tr("CLOWN_FACE_CLEAN"))
	var model := driver.get_node("Model")
	assert_true((model.find_child("glasses", true, false) as Node3D).visible)
	assert_false((model.find_child("makeup", true, false) as Node3D).visible)
	assert_eq(driver.prompt_key(cop), "PROMPT_PAPERS", "clean, the sponge does nothing more")


func test_a_clean_face_without_glasses_shows_none() -> void:
	var car := _car(false, true)
	var driver := car.clowns_out[0]
	for i in ConvoyClown.SCRUBS:
		driver.scrub()
	assert_false((driver.get_node("Model").find_child("glasses", true, false) as Node3D).visible)


func test_the_trunks_say_what_they_carry() -> void:
	for kind: String in {"pies": "TRUNK_PIES", "prop_safe": "TRUNK_PROP_SAFE", "safe": "TRUNK_SAFE"}:
		var car := QueueCar.new()
		car.clown = true
		car.driver = {"trunk": kind}
		add_child_autofree(car)
		car.open_trunk()
		assert_true(car.trunk_checked)
		assert_eq(car.saying(), tr({"pies": "TRUNK_PIES", "prop_safe": "TRUNK_PROP_SAFE", "safe": "TRUNK_SAFE"}[kind]))


func test_the_convoy_level_has_a_sponge() -> void:
	var level: TrafficControlLevel = load("res://scenes/levels/traffic_control.tscn").instantiate()
	level.case_seed = 3
	level.variant = "clown_convoy"
	add_child_autofree(level)
	assert_not_null(level.sponge)
	assert_true(level.plan.convoy)


func test_texts_are_translated() -> void:
	for key in ["LICENSE_PHOTO_GLASSES", "LICENSE_PHOTO_NO_GLASSES", "CONVOY_NOT_DRIVER", "TRUNK_PIES",
			"TRUNK_PROP_SAFE", "TRUNK_SAFE"]:
		assert_ne(tr(key), key)
