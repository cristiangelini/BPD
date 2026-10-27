extends GutTest

## The bought technician's getaway (politico-debate.md, step 7, decision 230): the TV van waits on the street; a
## technician still loose when the debate ends drives off in it, and caught he counts as detained. Play draws the TV
## debate among the politician's protections.

const LEVEL := preload("res://scenes/levels/tv_studio.tscn")

var studio: TvStudio
var case: DebateCase


func before_each() -> void:
	studio = LEVEL.instantiate()
	studio.case_seed = 7
	var cop: Cop = studio.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(studio)
	await wait_physics_frames(3)
	case = studio.case


func test_the_van_waits_parked_on_the_street() -> void:
	var van := studio.van
	assert_eq(van.kind, SuspectCar.TV_VAN)
	assert_false(van.driving)
	assert_false(van.get_node("Rider").visible, "the technician is still at the console")
	var at := studio.to_local(van.global_position)
	assert_gt(at.z, TvStudio.HALF_Z + CityLayout.SIDEWALK, "on the street, past the sidewalk")
	await wait_physics_frames(20)
	assert_almost_eq(studio.to_local(van.global_position).x, at.x, 0.1, "parked, it stays")


func test_a_loose_technician_drives_off_when_the_debate_ends() -> void:
	studio.debate.finished.emit()
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.TV_VAN)
	assert_eq(case.chase.truck, studio.van, "the parked van is the one fleeing")
	assert_eq(case.chase.who, ChaseSuspect.TECHNICIAN + studio.technician.look())
	assert_false(studio.technician.visible, "he left in it")
	assert_true(studio.van.get_node("Rider").visible)
	assert_eq(case.rows().size(), 6, "and the planilla asks to catch it")


func test_caught_he_counts_as_detained() -> void:
	studio.debate.state = TvDebate.State.OVER
	studio.debate.finished.emit()
	case.chase.ended.emit(true)
	assert_true(case.technician_detained())
	assert_eq(case.report().salary, DebateCase.SALARY + DebateCase.TECHNICIAN)
	await wait_seconds(DebateCase.SHIFT_DELAY + 0.3)
	assert_true(case.shift_over)


func test_a_jailed_technician_doesn_t_drive_off() -> void:
	studio.technician.cuffed(Handcuffs.SECONDS)
	OwnerEscort.of(studio.technician).board()
	studio.debate.finished.emit()
	assert_null(case.chase)


func test_his_own_model_and_lines() -> void:
	var who := ChaseSuspect.TECHNICIAN + studio.technician.look()
	assert_not_null(ChaseSuspect.model_for(who))
	var suspect := ChaseSuspect.new()
	suspect.kind = who
	assert_eq(suspect.lines()[0], "CHASE_TECHNICIAN_LINE_1")
	suspect.free()


func test_play_draws_it() -> void:
	assert_has(PlaceDraw.RALLIES, "debate")
	var found := false
	for i in 900:
		if PlaceDraw.pick(i + 1, [], 1) == "debate":
			found = true
			break
	assert_true(found)


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["HINT_ESCAPE_TECHNICIAN", "OBJ_DEBATE_CATCH_VAN", "CHASE_TECHNICIAN_LINE_1",
			"CHASE_TECHNICIAN_LINE_2", "CHASE_TECHNICIAN_LINE_3"]:
		assert_ne(tr(key), key, key)
