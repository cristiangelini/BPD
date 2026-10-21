extends GutTest

## The clues in the tent and how they get spoiled (escena-del-crimen.md, step 3): the footprint in the flour, the
## merengue print on the display case and the jury's lady.

const LEVEL := preload("res://scenes/levels/crime_scene.tscn")

var level: CrimeSceneLevel
var case: CrimeSceneCase
var cop: Cop


## Opens the level with the first seed whose clues include all of `kinds`.
func _open_with(kinds: Array) -> void:
	var seed_value := 1
	while not kinds.all(func(kind: String) -> bool:
			return CrimePlan.draw(CookTraits.draw(seed_value), seed_value).clues.has(kind)):
		seed_value += 1
	level = LEVEL.instantiate()
	level.case_seed = seed_value
	cop = level.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	case = level.case
	case.give_tip()


func test_a_photo_of_the_footprint_notes_the_shoe_size() -> void:
	await _open_with(["footprint"])
	var print := case.flour_print
	assert_not_null(print, "the footprint is in the tent")
	assert_true(level.contest.under_roof(print.global_position))
	var lines := print.photo_clues()
	assert_eq(lines.keys(), [tr("CLUE_CRIME_footprint") % case.culprit().shoe])
	print.add_clue(lines.keys()[0])
	assert_eq(case.clues_found, ["footprint"] as Array[String])
	assert_true(print.photo_clues().is_empty(), "already on the checklist")
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "- " + tr("CLUE_CRIME_footprint") % case.culprit().shoe)


func test_stepping_on_the_footprint_wipes_it() -> void:
	await _open_with(["footprint"])
	cop.global_position = case.flour_print.global_position + Vector3(0.2, 0.1, 0)
	await wait_physics_frames(3)
	assert_true(case.flour_print.wiped)
	assert_eq(case.ruined, ["footprint"] as Array[String])
	assert_true(case.flour_print.photo_clues().is_empty(), "nothing left to photograph")
	assert_false(case.found("footprint"), "a wiped clue can't be found")


func test_the_print_kit_finds_the_merengue_print() -> void:
	await _open_with(["prints"])
	var display := level.contest.display_case
	var kit := cop.belt.tools[3] as PrintKit
	kit.reveal(display, display.global_position + Vector3.UP)
	assert_eq(case.clues_found, ["prints"] as Array[String])


func test_touching_the_display_case_first_spoils_the_print() -> void:
	await _open_with(["prints"])
	var display := level.contest.display_case
	display.use(cop)
	assert_eq(case.ruined, ["prints"] as Array[String])
	assert_eq(display.dusted(cop), "PRINTS_SMUDGED")
	assert_true(case.clues_found.is_empty())


func test_the_jury_lady_tells_the_apron() -> void:
	await _open_with(["witness"])
	var lady := level.contest.lady
	lady.use(cop)
	assert_eq(case.clues_found, ["witness"] as Array[String])
	assert_string_contains(lady.said(), tr("APRON_" + str(case.culprit().apron)))


func test_shouting_at_the_jury_lady_offends_her() -> void:
	await _open_with(["witness"])
	var lady := level.contest.lady
	cop.global_position = lady.global_position + Vector3(0, 0, 12)
	get_tree().call_group("crime_scene", "shouted_by", cop)
	assert_false(lady.offended, "too far to hear")
	cop.global_position = lady.global_position + Vector3(0, 0, 2)
	get_tree().call_group("crime_scene", "shouted_by", cop)
	assert_true(lady.offended)
	lady.use(cop)
	assert_eq(lady.said(), "WITNESS_OFFENDED")
	assert_eq(case.ruined, ["witness"] as Array[String])


func test_cuffing_her_offends_her_too() -> void:
	await _open_with(["witness"])
	level.contest.lady.cuffed(5.0)
	assert_true(level.contest.lady.offended)


func test_only_the_drawn_clues_count() -> void:
	await _open_with([])
	for kind: String in CrimePlan.CLUES:
		if not case.plan.clues.has(kind):
			assert_false(case.found(kind), "%s isn't one of this case's clues" % kind)
	assert_eq(case.flour_print != null, case.plan.clues.has("footprint"))


func test_a_bagged_clue_is_found_and_safe() -> void:
	await _open_with(["hair"])
	var plate: CrimeClueItem = case.items.hair
	assert_true(level.contest.under_roof(plate.global_position), "on a cook's table")
	cop.use_clue_in_hand(plate, level.contest.bags)
	assert_true(plate.bagged)
	assert_eq(case.clues_found, ["hair"] as Array[String])
	cop.use_clue_in_hand(plate, null)
	assert_false(plate.spoiled, "in its bag it can't be eaten")


func test_eating_the_cream_loses_the_hair() -> void:
	await _open_with(["hair"])
	var plate: CrimeClueItem = case.items.hair
	cop.use_clue_in_hand(plate, null)
	assert_true(plate.spoiled)
	assert_eq(case.ruined, ["hair"] as Array[String])
	cop.use_clue_in_hand(plate, level.contest.bags)
	assert_true(case.clues_found.is_empty(), "bagged after eating, it says nothing")


func test_biting_the_slice_again_spoils_the_bite() -> void:
	await _open_with(["bite"])
	cop.use_clue_in_hand(case.items.bite, null)
	assert_eq(case.ruined, ["bite"] as Array[String])
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "- " + tr("CLUE_CRIME_RUINED_bite"))


func test_coffee_on_the_recipe_runs_the_ink() -> void:
	await _open_with(["recipe"])
	var recipe: CrimeClueItem = case.items.recipe
	cop.use_clue_in_hand(recipe, null)
	assert_false(recipe.spoiled, "nobody eats paper")
	var cup := get_tree().get_nodes_in_group("coffee_cups")[0] as Node3D
	assert_gt(cup.global_position.distance_to(recipe.global_position), CrimeClueItem.WET_REACH, "dry at first")
	cup.global_position = recipe.global_position + Vector3(0, 0.1, 0)
	await wait_physics_frames(2)
	assert_true(recipe.spoiled)
	assert_eq(case.ruined, ["recipe"] as Array[String])


func test_the_recipe_tells_the_hand() -> void:
	await _open_with(["recipe"])
	cop.use_clue_in_hand(case.items.recipe, level.contest.bags)
	var key := "CLUE_CRIME_recipe_left" if case.culprit().left else "CLUE_CRIME_recipe_right"
	assert_eq(case.clue_line("recipe"), tr(key))
	assert_eq(case.clues_found, ["recipe"] as Array[String])
