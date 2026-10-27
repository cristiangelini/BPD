extends GutTest

## Play draws the mansion among the crime scenes (escena-mansion.md, step 7): a quarter of them, and --place=mansion
## forces it.


func test_some_seeds_land_on_the_mansion_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "mansion")
	var drawn := 0
	for seed_value in range(1, 600):
		if PlaceDraw.pick(seed_value, [], 1) == "mansion":
			drawn += 1
			assert_eq(hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY, 0, "only as a crime scene")
	assert_gt(drawn, 3)


func test_place_mansion_forces_it_and_opens_its_level() -> void:
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=mansion"])), "mansion")
	var scene: PackedScene = load(PlaceDraw.PLACES.mansion)
	var level: MansionLevel = scene.instantiate()
	level.case_seed = 11
	add_child_autofree(level)
	assert_eq(level.case.texts(), CrimeSceneCase.VARIANTS.mansion)
