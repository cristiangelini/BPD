extends GutTest

## The bought porter and the trip as a case (politico-aeropuerto.md, step 5, decision 231): his three clues, his trick
## with the odd suitcase when nobody's looking, the honest staff protesting the cuffs, the scandal and the missed plane
## losing the case, and the pay.

const LEVEL := preload("res://scenes/levels/airport.tscn")

var airport: Airport
var case: AirportCase
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
	case = airport.case
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
	assert_eq(porter.prompt_key(cop), "PROMPT_TALK_STAFF")
	porter.use(cop)
	assert_string_starts_with(porter.said(), "AIRPORT_PORTER_TALK_")
	assert_eq(case.clues, ["keychain"])
	cop.global_position = porter.global_position + Vector3(3, 0.1, 0)
	porter.whisper()
	assert_eq(porter.said(), "AIRPORT_PORTER_PHONE")
	assert_eq(case.clues, ["keychain", "phone"])
	airport.belt.start()
	cop.global_position = porter.get_node("Cart").global_position + Vector3(1, 0.1, 0)
	await wait_physics_frames(3)
	assert_eq(case.clues, ["keychain", "phone", "ribbon"])


func test_nobody_looking_he_puts_the_odd_one_back_on_the_belt() -> void:
	_put(airport.odd, Vector3(-3, 0.2, 18))
	_put(cop, Vector3(-16, 0, 9))
	assert_true(porter.watched())
	assert_false(porter.try_trick(), "not with a cop right there")
	_put(cop, Vector3(10, 0, 18))
	assert_true(porter.try_trick())
	assert_true(airport.belt.on_belt(airport.odd) or airport.odd.has_meta("sent"))
	assert_eq(porter.said(), "AIRPORT_PORTER_WHISTLE")
	assert_eq(case.tricks, 1)
	await wait_physics_frames(3)
	assert_true(airport.belt.on_belt(airport.odd))
	assert_false(porter.try_trick(), "it's already on the belt")


func test_cuffed_and_in_the_car_he_stops() -> void:
	porter.cuffed(Handcuffs.SECONDS)
	assert_false(porter.loose())
	assert_eq(porter.said(), "AIRPORT_PORTER_CUFFED")
	assert_eq(porter.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	OwnerEscort.of(porter).board()
	assert_true(case.porter_detained())


func test_an_honest_employee_protests_and_it_costs() -> void:
	var clerk := airport.staff[1]
	clerk.cuffed(Handcuffs.SECONDS)
	assert_false(clerk.is_cuffed())
	assert_eq(clerk.said(), "AIRPORT_STAFF_WRONG_CUFF")
	assert_eq(case.wrong_cuffs, 1)
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_AIRPORT_WRONG_CUFF")


func test_opening_his_own_costs_and_the_odd_one_is_found() -> void:
	var his := airport.suitcases[0] if airport.suitcases[0] != airport.odd else airport.suitcases[1]
	his.set_opened(true)
	his.set_opened(false)
	his.set_opened(true)
	assert_eq(case.opened, [his.number], "once per suitcase")
	assert_eq(airport.politician.said(), "AIRPORT_DEPUTY_OPENED")
	airport.odd.set_opened(true)
	assert_true(case.odd_found)
	assert_eq(case.opened.size(), 1)


func test_the_scandal_loses_the_case() -> void:
	airport.xray.scan(airport.odd)
	assert_true(case.scandal)
	assert_false(case.solved())
	assert_eq(case.report().total, 0)
	_put(airport.politician, Vector3(14, 0, 4))
	airport.boarding.close()
	assert_false(case.boarded, "too late, the press saw it")


func test_missing_the_plane_loses_it() -> void:
	airport.boarding.close()
	assert_true(case.missed)
	assert_false(case.solved())
	assert_eq(case.report().total, 0)


func test_boarding_on_time_pays() -> void:
	var his := airport.suitcases[0] if airport.suitcases[0] != airport.odd else airport.suitcases[1]
	his.set_opened(true)
	airport.staff[2].cuffed(Handcuffs.SECONDS)
	OwnerEscort.of(porter).board()
	_put(airport.politician, Vector3(14, 0, 4))
	airport.boarding.close()
	assert_true(case.solved())
	var pay := case.report()
	assert_eq(pay.total, AirportCase.SALARY - AirportCase.OPENED - AirportCase.WRONG_CUFF + AirportCase.PORTER)
	assert_eq(pay.quota, AirportCase.QUOTA)
	assert_true(pay.approved)
