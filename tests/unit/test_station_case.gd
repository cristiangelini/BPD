extends GutTest

## The station crime scene's case (escena-comisaria.md, step 4a): the level, the six suspects with their files, what
## was stolen and the accusation at the board.

const LEVEL := preload("res://scenes/levels/station_scene.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")
const DONUTS := preload("res://scenes/props/donut_box.tscn")


func _level(seed_value: int) -> StationSceneLevel:
	var level: StationSceneLevel = LEVEL.instantiate()
	level.case_seed = seed_value
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	return level


func test_the_level_gives_the_case_in_the_station_with_six_suspects() -> void:
	TranslationServer.set_locale("es")
	var level := _level(5)
	var case := level.case
	assert_eq(case.place, level.scene)
	assert_eq(case.texts(), CrimeSceneCase.VARIANTS.station)
	assert_eq(case.board, level.board)
	assert_eq(case.cooks.size(), 6)
	assert_eq(case.cooks[1].name, "Cabo Ronquido", "the names as the plates read them")
	assert_eq(case.plan.clues.size(), CrimePlan.CLUES_PER_CASE)
	assert_eq(level.scene.suspect(0), level.get_node("City").armero, "the armero is the first")
	for i in range(1, 6):
		var person := level.scene.suspect(i) as StationStaff
		assert_eq(person.who, StaffTraits.IDS[i])
		assert_eq(person.file.index, i)
	var lines := case.briefing_lines()
	assert_eq(lines[0], "BRIEF_STATION_A_" + level.scene.loot)
	for line in lines:
		assert_ne(tr(line), line, "%s is written" % line)
	var station: Transform3D = level.scene.global_transform
	assert_true(level.scene.at_scene(station * Vector3(11.5, 0, -12.0)), "the evidence room is the scene")
	assert_false(level.scene.at_scene(station * Vector3(0, 0, 6.0)), "the guard room is not")


func test_the_seed_draws_what_was_stolen() -> void:
	var loots := {}
	for seed_value in range(1, 30):
		loots[StationScene.LOOTS[hash(["station loot", seed_value]) % StationScene.LOOTS.size()]] = true
	assert_eq(loots.size(), StationScene.LOOTS.size(), "all three get stolen")


func test_each_coworker_gives_their_file_and_fritanga_knows_the_sugars() -> void:
	TranslationServer.set_locale("es")
	var level := _level(9)
	var case := level.case
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	var donuts: DonutBox = DONUTS.instantiate()
	donuts.donuts = 6
	add_child_autofree(donuts)
	for i in 6:
		var body := level.scene.suspect(i)
		assert_eq(body.prompt_key(cop), "PROMPT_STAFF_ASK", "first, where they were")
		body.use(cop)
		assert_true(case.captured[i].has("left"), "and the signature")
		body.dusted(cop)
		body.photographed(cop)
		cop.get_node("Grabber").held = donuts
		assert_eq(body.prompt_key(cop), "PROMPT_STAFF_FEED")
		body.use(cop)
		cop.get_node("Grabber").held = null
		assert_eq(case.captured[i].teeth, case.cooks[i].teeth)
		assert_eq(case.captured[i].silhouette, case.cooks[i].silhouette, "the photo shows the silhouette")
	assert_eq(case.files.size(), 0, "no sugars yet")
	var fritanga := level.scene.suspect(4) as StationStaff
	fritanga.use(cop)
	assert_string_contains(fritanga.said(), case.cooks[2].name, "she says everyone's")
	assert_eq(case.files.size(), 6, "every file done")
	var text := case.file_text(case.plan.culprit)
	assert_string_contains(text, tr("STAFF_PLACE_" + (case.culprit().where as String).to_upper()), "the alibi on the file")


func test_accused_a_culprit_who_doesnt_run_gives_up() -> void:
	var seed_value := 13
	while hash(["crime runs", seed_value]) % CrimeSceneCase.RUNS_EVERY == 0:
		seed_value += 1
	var level := _level(seed_value)
	var case := level.case
	case.give_tip()
	assert_false(case.runs_off())
	case.accuse(case.plan.culprit)
	assert_true(case.accused)
	assert_true(case.solved())
	assert_eq(case.custody.story, "station")
