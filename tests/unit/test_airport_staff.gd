extends GutTest

## The airport's staff and the bought porter (politico-aeropuerto.md, step 5, decision 231): his three clues, his trick
## with the odd suitcase when nobody's looking, the cuffs on him and the honest staff protesting them.

const LEVEL := preload("res://scenes/levels/airport.tscn")

var airport: Airport
var porter: AirportStaff
var cop: Cop


func before_each() -> void:
	airport = LEVEL.instantiate()
	airport.case_seed = 7
	cop = airport.get_node("Cop") as Cop
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(airport)
	await wait_physics_frames(3)
	porter = airport.porter


func _put(body: Node3D, local: Vector3) -> void:
	body.global_position = airport.to_global(local + Vector3.UP * Airport.FLOOR_TOP)


func test_the_staff_and_who_is_bought() -> void:
	assert_eq(airport.staff.size(), 3)
	assert_eq(porter.role, "porter")
	assert_true(porter.bought)
	assert_false(airport.staff[1].bought)
	assert_false(airport.staff[2].bought)
	assert_not_null(porter.get_node("Model/Keychain"))
	assert_not_null(porter.get_node("Cart/Ribbon0"))
	assert_null(airport.staff[1].get_node_or_null("Model/Keychain"))


func test_his_three_clues() -> void:
	watch_signals(porter)
	assert_eq(porter.prompt_key(cop), "PROMPT_TALK_STAFF")
	porter.use(cop)
	assert_string_starts_with(porter.said(), "AIRPORT_PORTER_TALK_")
	assert_eq(porter.clues, ["keychain"])
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_PORTER_KEYCHAIN")
	cop.global_position = porter.global_position + Vector3(3, 0.1, 0)
	porter.whisper()
	assert_eq(porter.said(), "AIRPORT_PORTER_PHONE")
	assert_eq(porter.clues, ["keychain", "phone"])
	airport.belt.start()
	cop.global_position = porter.get_node("Cart").global_position + Vector3(1, 0.1, 0)
	await wait_physics_frames(3)
	assert_eq(porter.clues, ["keychain", "phone", "ribbon"])
	assert_signal_emit_count(porter, "found_clue", 3)


func test_honest_staff_have_no_clues() -> void:
	var clerk := airport.staff[1]
	clerk.use(cop)
	assert_string_starts_with(clerk.said(), "AIRPORT_CLERK_TALK_")
	assert_eq(clerk.clues, [])


func test_nobody_looking_he_puts_the_odd_one_back_on_the_belt() -> void:
	watch_signals(porter)
	_put(airport.odd, Vector3(-3, 0.2, 18))
	_put(cop, Vector3(-16, 0, 9))
	assert_true(porter.watched())
	assert_false(porter.try_trick(), "not with a cop right there")
	_put(cop, Vector3(10, 0, 18))
	assert_true(porter.try_trick())
	assert_eq(porter.said(), "AIRPORT_PORTER_WHISTLE")
	assert_signal_emit_count(porter, "tricked", 1)
	await wait_physics_frames(3)
	assert_true(airport.belt.on_belt(airport.odd))
	assert_false(porter.try_trick(), "it's already on the belt")


func test_he_tries_by_himself_once_the_belt_runs() -> void:
	_put(airport.odd, Vector3(-3, 0.2, 18))
	_put(cop, Vector3(10, 0, 18))
	airport.belt.start()
	porter._trick_left = 0.05
	await wait_physics_frames(5)
	assert_true(airport.odd.has_meta("sent"))


func test_cuffed_and_in_the_car_he_stops() -> void:
	watch_signals(porter)
	porter.cuffed(Handcuffs.SECONDS)
	assert_signal_emitted(porter, "cuffed_now")
	assert_false(porter.loose())
	assert_eq(porter.said(), "AIRPORT_PORTER_CUFFED")
	assert_eq(porter.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	_put(airport.odd, Vector3(-3, 0.2, 18))
	_put(cop, Vector3(10, 0, 18))
	airport.belt.start()
	porter._trick_left = 0.05
	await wait_physics_frames(5)
	assert_false(airport.odd.has_meta("sent"), "cuffed, no more tricks")


func test_an_honest_employee_protests() -> void:
	var clerk := airport.staff[1]
	watch_signals(clerk)
	clerk.cuffed(Handcuffs.SECONDS)
	assert_false(clerk.is_cuffed())
	assert_eq(clerk.said(), "AIRPORT_STAFF_WRONG_CUFF")
	assert_signal_emitted(clerk, "wrongly_cuffed")
