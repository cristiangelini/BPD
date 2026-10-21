extends GutTest

## How the crime scene ends (escena-del-crimen.md, step 6): the cooks go home, the pay, the custody and the draw.
## Seed 45: the culprit gives up (test_crime_bike_chase.gd has one who runs off).

const LEVEL := preload("res://scenes/levels/crime_scene.tscn")

var level: CrimeSceneLevel
var case: CrimeSceneCase


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	level = LEVEL.instantiate()
	level.case_seed = 45
	(level.get_node("Cop") as Cop).input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	case = level.case
	case.give_tip()


func after_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}


func test_the_cooks_go_home_one_by_one_from_eight_minutes() -> void:
	case.elapsed = CrimeSceneCase.LEAVE_FROM - 1.0
	await wait_physics_frames(2)
	assert_true(case.gone.is_empty(), "nobody leaves before 8 minutes")
	case.elapsed = CrimeSceneCase.LEAVE_FROM
	await wait_physics_frames(2)
	assert_eq(case.gone.size(), 1)
	var first: PastryCook = level.contest.cooks[case.gone[0]]
	assert_false(first.visible, "he left the tent")
	case.elapsed = CrimeSceneCase.LEAVE_FROM + CrimeSceneCase.LEAVE_EVERY
	await wait_physics_frames(2)
	assert_eq(case.gone.size(), 2, "another one two minutes later")
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, tr("OBJ_CRIME_GONE") % ", ".join(case.gone.map(func(i: int) -> String: return case.cooks[i].name)))


func test_a_right_accusation_pays_the_salary_and_takes_the_culprit() -> void:
	case.accuse(case.plan.culprit)
	assert_eq(case.custody.owner, "cook")
	assert_false(level.contest.cooks[case.plan.culprit].visible, "off to a cell")
	case.finish_shift()
	assert_true(level.get_node("ShiftScreen").visible)
	assert_eq(PlaceDraw.custody.owner, "cook", "next shift is his interrogation")
	assert_eq(PlaceDraw.pick(1, [], 1), "interrogation")


func test_a_wrong_accusation_halves_the_pay() -> void:
	case.accuse((case.plan.culprit + 1) % 6)
	case.accuse(case.plan.culprit)
	var report := ShiftReport.pay(case.accused, [], 0, case.wrong_guesses)
	assert_eq(report.salary, ShiftReport.SALARY / 2)


func test_a_campaign_counts_the_shift() -> void:
	Campaign.save_path = "user://test_crime_campaign.json"
	Campaign.current = Campaign.start_new()
	var shift := Campaign.current.shift
	case.accuse(case.plan.culprit)
	case.finish_shift()
	assert_eq(Campaign.current.shift, shift + 1)
	assert_eq(Campaign.current.custody.owner, "cook")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_crime_campaign.json"))
	Campaign.save_path = Campaign.SAVE_PATH


func test_the_cook_can_be_interrogated() -> void:
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_cook"))
	assert_true(ResourceLoader.exists(InterrogationCase.SUSPECT_MODELS.owner_cook))
	assert_ne(tr("CRIME_owner_cook"), "CRIME_owner_cook")
	assert_ne(tr("CONFESS_owner_cook"), "CONFESS_owner_cook")
