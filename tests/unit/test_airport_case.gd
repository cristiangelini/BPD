extends GutTest

## The trip as a case (politico-aeropuerto.md, step 5, decision 231): the porter's clues and his arrest on the
## planilla, the honest staff cuffed and his own suitcases opened costing, the scandal and the missed plane losing the
## case, and the pay.

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


func test_the_porter_s_clues_and_tricks_reach_the_planilla() -> void:
	porter.use(cop)
	assert_eq(case.clues, ["keychain"])
	_put(airport.odd, Vector3(-3, 0.2, 18))
	_put(cop, Vector3(10, 0, 18))
	porter.try_trick()
	assert_eq(case.tricks, 1)
	OwnerEscort.of(porter).board()
	assert_true(case.porter_detained())
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_PORTER_IN_CAR")


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
