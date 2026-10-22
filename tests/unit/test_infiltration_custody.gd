extends GutTest

## The infiltrations' bosses in custody (decision 93): Doña Chela cuffed or caught, or Maestro Ernesto, is
## interrogated the next shift, like a raid's owner, with what slips out of them and the evidence left behind.

var case: InfiltrationCase


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	case = InfiltrationCase.new()
	add_child_autofree(case)
	case.start()


func after_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}


func test_cuffed_chela_is_in_custody_for_the_next_shift() -> void:
	case.found("press")
	case.found("notebook")
	case.boss_cuffed = true
	case.finish_shift()
	assert_eq(PlaceDraw.custody.owner, "chela")
	assert_eq(PlaceDraw.custody.story, "infiltration_club")
	assert_eq(PlaceDraw.custody.slips, ["CHELA_SLIP_1", "CHELA_SLIP_2", "CHELA_SLIP_3"])
	assert_eq(PlaceDraw.custody.missed, InfiltrationCase.SALARY / 3, "one piece of evidence left behind")
	assert_eq(PlaceDraw.pick(1, [], 1), "interrogation", "next shift is her interrogation")


func test_caught_on_the_walker_counts_too() -> void:
	case.caught = true
	assert_eq(case.custody().owner, "chela")
	assert_eq(case.custody().missed, InfiltrationCase.SALARY, "no evidence at all")


func test_got_away_nobody_is_in_custody() -> void:
	case.escaped = true
	case.finish_shift()
	assert_true(PlaceDraw.custody.is_empty())


func test_a_campaign_keeps_her_in_custody() -> void:
	Campaign.save_path = "user://test_infiltration_custody.json"
	Campaign.current = Campaign.start_new()
	case.boss_cuffed = true
	case.finish_shift()
	assert_eq(Campaign.current.custody.owner, "chela")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_infiltration_custody.json"))
	Campaign.save_path = Campaign.SAVE_PATH


func test_the_choir_brings_in_ernesto() -> void:
	var chapel := InfiltrationPlace.new()
	chapel.variant = "choir"
	case.place = chapel
	case.boss_cuffed = true
	assert_eq(case.custody().owner, "ernesto")
	assert_eq(case.custody().slips[0], "ERNESTO_SLIP_1")
	chapel.free()


func test_both_bosses_can_be_interrogated() -> void:
	for boss: String in ["chela", "ernesto"]:
		var kind := "owner_" + boss
		assert_true(ResourceLoader.exists(InterrogationCase.SUSPECT_MODELS[kind]))
		for key: String in ["CRIME_" + kind, "CONFESS_" + kind, boss.to_upper() + "_SLIP_3"]:
			assert_ne(tr(key), key)
