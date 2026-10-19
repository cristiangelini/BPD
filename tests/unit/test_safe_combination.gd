extends GutTest

## The safe opens with the combination from the calendar or the cookie tin (investigacion.md, "Las pistas").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 11
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_without_the_combination_the_safe_stays_shut() -> void:
	var house := _house()
	await wait_physics_frames(15)
	var cop: Cop = house.get_node("Cop")
	house.safe().use(cop)
	assert_false(house.safe().is_open)
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_SAFE_LOCKED")
	assert_eq(house.safe().prompt_key(cop), "PROMPT_SAFE_LOCKED")


func test_the_calendar_gives_the_combination_and_the_safe_opens() -> void:
	TranslationServer.set_locale("es")
	var house := _house()
	await wait_physics_frames(15)
	var cop: Cop = house.get_node("Cop")
	assert_string_contains(house.calendar.text, house.combination)
	house.calendar.use(cop)
	assert_has(house.clues_found, house.calendar.text)
	house.safe().use(cop)
	assert_true(house.safe().is_open)
	assert_eq(house.safe().value, 0.0, "the empty safe is worth nothing")
	var bundle := house.safe().bundle
	assert_not_null(bundle)
	assert_eq(bundle.full_value, 800.0)
	bundle.global_position = house.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(house.objective_facts().safe_delivered, "the takings count without the safe")


func test_the_cookie_tin_waits_at_the_end_of_the_crumbs_with_the_combination() -> void:
	var house := _house()
	await wait_physics_frames(15)
	var crumbs: Array = house.trails[tr("CLUE_CRUMBS")]
	var last: Node3D = crumbs[crumbs.size() - 1]
	assert_lt(house.cookie_tin.global_position.distance_to(last.global_position), 0.5)
	assert_string_contains(house.cookie_tin.text, house.combination)
	house.cookie_tin.use(house.get_node("Cop"))
	assert_true(house.safe().code_known)
