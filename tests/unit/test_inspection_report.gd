extends GutTest

## The inspector's report (inspeccion.md, step 3, decision 107): it starts at 50, and what she sees with nothing in
## between goes up or down; the planilla shows it.

const LEVEL := preload("res://scenes/levels/grandpa_house.tscn")

var level: Node3D
var cop: Cop
var inspector: CityInspector


func before_each() -> void:
	level = LEVEL.instantiate()
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	cop = level.get_node("Cop")
	await wait_physics_frames(10)
	Campaign.start_new().shift = Campaign.SHIFTS
	inspector = CityInspector.join(cop)
	await wait_physics_frames(2)


func after_each() -> void:
	Campaign.current = null


## Puts the cop where she sees it, out in the open by the patrol car.
func _in_sight() -> void:
	var car: PatrolCar = level.get_node("PatrolCar")
	cop.global_position = car.to_global(Vector3(3.5, 0, 0))
	inspector.global_position = car.to_global(Vector3(3.5, 0, -2.5))
	await wait_physics_frames(1)


func test_it_starts_at_fifty_and_shows_in_the_planilla() -> void:
	assert_eq(inspector.report.score, InspectionReport.START)
	var checklist: CaseChecklist = get_tree().get_first_node_in_group("checklist")
	assert_string_contains(checklist.report_text(), "50")


func test_what_she_sees_goes_in() -> void:
	await _in_sight()
	inspector.saw_donut(cop)
	assert_eq(inspector.report.score, InspectionReport.START + InspectionReport.DONUT)
	assert_eq(inspector.said(), "INSPECTOR_SAW_DONUT")
	inspector.saw_cuffed(cop, cop)
	assert_eq(inspector.report.count("partner"), 1, "cuffing a partner")
	inspector.saw_bribe(cop)
	assert_eq(inspector.report.count("bribe"), 1)


func test_what_she_doesnt_see_stays_out() -> void:
	await _in_sight()
	cop.global_position += Vector3(0, 0, CityInspector.SEEN_REACH + 5.0)
	await wait_physics_frames(1)
	inspector.saw_donut(cop)
	assert_eq(inspector.report.score, InspectionReport.START)


func test_left_behind_costs() -> void:
	cop.global_position += Vector3(0, 0, CityInspector.LOST + 20.0)
	await wait_physics_frames(3)
	assert_eq(inspector.report.count("behind"), 1)


func test_the_score_stays_between_0_and_100() -> void:
	for i in 10:
		inspector.report.note("bribe")
	assert_eq(inspector.report.score, 0)
	for i in 10:
		inspector.report.note("solved")
	assert_eq(inspector.report.score, 100)
