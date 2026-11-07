extends GutTest

## The station crime scene's clues (escena-comisaria.md, step 4b): the empty shelf's prints, the camera's tape, the
## sign-out book, the mug and the donut, el Chancho and don Mopa who cleans.

const LEVEL := preload("res://scenes/levels/station_scene.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")
const DONUTS := preload("res://scenes/props/donut_box.tscn")


func _level(seed_value: int) -> StationSceneLevel:
	var level: StationSceneLevel = LEVEL.instantiate()
	level.case_seed = seed_value
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	return level


## A seed whose four clues include `kind` (or leave it out).
func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 200):
		var staff := StaffTraits.draw(seed_value)
		var plan := CrimePlan.draw(staff, seed_value, CrimeSceneCase.VARIANTS.station.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	return cop


func test_the_shelf_gives_the_prints_unless_a_cop_touched_it_first() -> void:
	var level := _level(_seed_with("prints"))
	var cop := _cop()
	assert_eq(level.scene.shelf.dusted(cop), "PRINTS_DUST")
	assert_has(level.case.clues_found, "prints")
	level = _level(_seed_with("prints"))
	level.scene.shelf.use(cop)
	assert_has(level.case.ruined, "prints", "touched first: the cop's prints on top")


func test_the_tape_shows_the_silhouette_until_it_records_over_it() -> void:
	var seed_value := _seed_with("tape")
	var level := _level(seed_value)
	var cop := _cop()
	level.case.give_tip()
	level.scene.vcr.use(cop)
	assert_has(level.case.clues_found, "tape")
	assert_string_contains(level.case.clue_line("tape"), tr("SILHOUETTE_" + (level.case.culprit().silhouette as String).replace(" ", "_")))
	level = _level(seed_value)
	level.case.give_tip()
	level.scene.vcr._recording = VcrDeck.OVERWRITE - 0.05
	await wait_physics_frames(6)
	assert_has(level.case.ruined, "tape", "it loops over last night")
	level.scene.vcr.use(cop)
	assert_does_not_have(level.case.clues_found, "tape")
	level = _level(_seed_with("tape", false))
	level.scene.vcr.use(cop)
	assert_eq(level.case.clues_found.size(), 0, "without the clue the tape shows nothing")


func test_the_book_is_photographed_or_spoiled_by_signing_it() -> void:
	var seed_value := _seed_with("book")
	var level := _level(seed_value)
	var book := level.scene.book
	assert_eq(book.photo_clues().size(), 1, "the photo can catch it")
	book.add_clue("")
	assert_has(level.case.clues_found, "book")
	level = _level(seed_value)
	level.scene.book.use(_cop())
	assert_has(level.case.ruined, "book")


func test_the_mug_and_the_donut_go_in_bags_or_get_eaten_and_mopa_washes_the_mug() -> void:
	var seed_value := _seed_with("cup")
	var level := _level(seed_value)
	var cop := _cop()
	var cup: CrimeClueItem = level.scene.clue_items.cup
	assert_true(level.scene.at_scene(cup.global_position), "on the cage's floor")
	cup.bag(cop)
	assert_has(level.case.clues_found, "cup")
	level = _level(seed_value)
	(level.scene.clue_items.cup as CrimeClueItem).eat(cop)
	assert_has(level.case.ruined, "cup", "drunk")
	level = _level(seed_value)
	level.case.give_tip()
	level.scene._since_tip = StationScene.MOPA_WASH - 0.05
	await wait_physics_frames(6)
	assert_true(level.scene.mopa_cleaned)
	assert_has(level.case.ruined, "cup", "don Mopa washed it")
	var bite_seed := _seed_with("bite")
	level = _level(bite_seed)
	(level.scene.clue_items.bite as CrimeClueItem).bag(cop)
	assert_has(level.case.clues_found, "bite")


func test_el_chancho_tells_the_boots_for_a_donut_and_takes_offense_if_his_cell_opens() -> void:
	TranslationServer.set_locale("es")
	var seed_value := _seed_with("witness")
	var level := _level(seed_value)
	var cop := _cop()
	var chancho := level.scene.chancho
	chancho.use(cop)
	assert_does_not_have(level.case.clues_found, "witness", "not for free")
	var donuts: DonutBox = DONUTS.instantiate()
	add_child_autofree(donuts)
	cop.get_node("Grabber").held = donuts
	assert_eq(chancho.prompt_key(cop), "PROMPT_STAFF_FEED")
	chancho.use(cop)
	cop.get_node("Grabber").held = null
	assert_has(level.case.clues_found, "witness")
	assert_string_contains(chancho.said(), str(level.case.culprit().shoe))
	level = _level(seed_value)
	level.case.give_tip()
	var city: City = level.get_node("City")
	city.cell_doors[0].use(cop)
	await wait_physics_frames(3)
	assert_true(level.scene.witness_offended())
	assert_has(level.case.ruined, "witness")
