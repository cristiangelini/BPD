extends GutTest

## The cooks' files for the board (escena-del-crimen.md, step 4): photo, prints, teeth and hair.

const LEVEL := preload("res://scenes/levels/crime_scene.tscn")

var level: CrimeSceneLevel
var case: CrimeSceneCase
var cop: Cop


func before_each() -> void:
	level = LEVEL.instantiate()
	level.case_seed = 21
	cop = level.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	case = level.case
	case.give_tip()


func _cook(stubborn: bool) -> PastryCook:
	for cook in level.contest.cooks:
		if cook.stubborn == stubborn:
			return cook
	return null


func test_one_cook_is_stubborn_about_the_hat() -> void:
	var stubborn := level.contest.cooks.filter(func(cook: PastryCook) -> bool: return cook.stubborn)
	assert_eq(stubborn.size(), 1)


func test_a_photo_counts_once_he_stops_covering() -> void:
	var cook := _cook(false)
	cook.photographed(cop)
	assert_true(case.file_parts[cook.index].photo)
	assert_true(cook.covering(), "he covers his face from the flash")
	assert_eq(cook.said(), "COOK_NO_PHOTOS")
	cook.photographed(cop)
	assert_eq(cook.said(), "COOK_COVERED")


func test_floury_prints_need_a_clean_hand() -> void:
	var cook := _cook(false)
	var kit := cop.belt.tools[3] as PrintKit
	assert_eq(cook.dusted(cop), "PRINTS_FLOUR")
	assert_false(case.file_parts.has(cook.index), "a white smudge isn't a print")
	cop.belt.select(3)
	assert_eq(cook.prompt_key(cop), "PROMPT_COOK_CLEAN")
	cook.use(cop)
	assert_true(cook.hand_clean)
	kit.reveal(cook, cook.global_position + Vector3.UP)
	assert_true(case.file_parts[cook.index].prints)


func test_hat_off_shows_the_hair() -> void:
	var cook := _cook(false)
	assert_true(cook.part("cap").visible)
	cook.use(cop)
	assert_false(cook.part("cap").visible)
	assert_true(case.file_parts[cook.index].hair)


func test_the_stubborn_one_takes_it_off_for_a_loaf() -> void:
	var cook := _cook(true)
	cook.use(cop)
	assert_eq(cook.said(), "COOK_HAT_NO")
	assert_true(cook.part("cap").visible)
	var loaf := level.contest.get_node("Loaf0") as Bread
	cook.feed(loaf)
	assert_true(loaf.is_broken, "he ate it")
	assert_true(case.file_parts[cook.index].teeth)
	assert_true(case.file_parts[cook.index].hair, "and took off the hat for it")


func test_four_parts_make_a_file() -> void:
	var cook := _cook(false)
	cook.photographed(cop)
	cook.use(cop)
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "- " + tr("OBJ_FILE_MISSING") % [cook.traits.name, tr("FILE_PART_prints") + ", " + tr("FILE_PART_teeth")])
	cook.hand_clean = true
	cook.dusted(cop)
	cook.feed(level.contest.get_node("Loaf1"))
	assert_eq(case.files, [cook.index] as Array[int])
	assert_eq(case.rows()[2].text, tr("OBJ_CRIME_FILES") % [1, 6])
