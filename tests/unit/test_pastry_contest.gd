extends GutTest

## The pastry contest's tent and its six cooks (escena-del-crimen.md, step 1).

const LEVEL := preload("res://scenes/levels/crime_scene.tscn")


func test_six_different_cooks_drawn_by_the_seed() -> void:
	var cooks := CookTraits.draw(12)
	assert_eq(cooks.size(), CookTraits.COUNT)
	var seen := {}
	for cook in cooks:
		seen[CookTraits.signature(cook)] = true
		assert_between(cook.shoe as int, CookTraits.SHOE_MIN, CookTraits.SHOE_MAX)
	assert_eq(seen.size(), CookTraits.COUNT, "no two cooks should be the same in everything")
	assert_eq(CookTraits.draw(12), cooks, "same seed, same cooks")
	assert_ne(CookTraits.draw(13), cooks, "another seed, other cooks")


func test_the_cooks_wear_their_traits() -> void:
	var contest := PastryContest.new()
	contest.case_seed = 7
	add_child_autofree(contest)
	assert_eq(contest.cooks.size(), CookTraits.COUNT)
	for cook in contest.cooks:
		assert_eq(cook.part("glasses").visible, cook.traits.glasses as bool)
		assert_eq(cook.part("whisk").scale.x, -1.0 if cook.traits.left else 1.0, "a lefty holds the whisk in the other hand")
		var apron := cook.part("apron").find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
		var material := apron.material_override as StandardMaterial3D
		assert_eq(material.albedo_color, CookTraits.APRONS[cook.traits.apron])
	assert_not_null(contest.display_case, "the jury's table has the empty display case")


func test_the_level_puts_the_tent_in_the_plaza_clear_of_the_fountain() -> void:
	var level: CrimeSceneLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	var plaza: Vector3 = level.get_node("City").transform * CityLayout.block_center(CityLayout.PLAZA)
	var inner := CityLayout.BLOCK / 2 - CityLayout.SIDEWALK
	assert_true(level.contest.under_roof(level.contest.global_position))
	assert_false(level.contest.under_roof(plaza), "the fountain stays outside the tent")
	for cook in level.contest.cooks:
		var off := cook.global_position - plaza
		assert_gt(Vector2(off.x, off.z).length(), 4.2 + 1.0, "clear of the fountain")
		assert_lt(absf(off.x), inner)
		assert_lt(absf(off.z), inner)
	var tent_south := level.contest.global_position.z + PastryContest.SIZE.y / 2 - plaza.z
	assert_lt(tent_south, inner, "the tent fits in the plaza")
	assert_true(PlaceDraw.PLACES.has("crime_scene"))
