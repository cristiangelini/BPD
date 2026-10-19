extends GutTest

## Clues that lead to the hidden evidence (investigacion.md, "Las pistas").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house(case_seed: int) -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = case_seed
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_every_item_gets_two_clues() -> void:
	for case_seed in range(1, 50):
		var plan := CluePlan.draw(case_seed, GrandpaHouse.NOTE_PLACES.size())
		var count := [0, 0, 0]
		var places := {}
		for note: Dictionary in plan.notes:
			count[note.item] += 1
			places[note.place] = true
		count[plan.footprints] += 1
		count[plan.crumbs] += 1
		assert_eq(count, [2, 2, 2], "seed %d" % case_seed)
		assert_eq(places.size(), plan.notes.size(), "one note per place")
		assert_eq(plan.crumbs, CluePlan.SAFE, "the crumbs lead to the safe")


func test_note_texts_name_the_item_and_the_spot() -> void:
	TranslationServer.set_locale("es")
	assert_eq(CluePlan.note_text(0, "in_oven", true), "«La libreta, en el horno. ¡NO PRENDERLO!»")
	assert_eq(CluePlan.note_text(2, "in_washer", false), "«La plata del bingo, donde se lava la ropa.»")


func test_reading_a_note_adds_it_to_the_checklist() -> void:
	TranslationServer.set_locale("es")
	var house := _house(11)
	await wait_physics_frames(5)
	assert_eq(house.notes.size(), 4)
	var cop: Cop = house.get_node("Cop")
	house.notes[0].use(cop)
	assert_eq(cop.get_node("Hud/Hint").text, house.notes[0].text)
	assert_has(house.objective_facts().clues, house.notes[0].text)
	house.notes[0].use(cop)
	assert_eq(house.clues_found.size(), 1, "reading it twice counts once")


func test_trails_lead_from_their_start_to_the_item() -> void:
	TranslationServer.set_locale("es")
	var house := _house(11)
	await wait_physics_frames(15)
	var mud: Array = house.trails[tr("CLUE_FOOTPRINTS")]
	var crumbs: Array = house.trails[tr("CLUE_CRUMBS")]
	assert_gt(mud.size(), 5)
	assert_gt(crumbs.size(), 5)
	var book_or_cage: Node3D = house.evidence[house.clue_plan.footprints]
	var last: Node3D = mud[mud.size() - 1]
	assert_lt(Vector2(last.global_position.x - book_or_cage.global_position.x,
		last.global_position.z - book_or_cage.global_position.z).length(), 2.0, "the footprints end by the item")
	assert_lt((mud[0] as Node3D).global_position.distance_to(GrandpaHouse.FOOTPRINTS_FROM), 1.0)


func test_walking_by_a_trail_finds_it() -> void:
	TranslationServer.set_locale("es")
	var house := _house(11)
	await wait_physics_frames(15)
	var crumbs: Array = house.trails[tr("CLUE_CRUMBS")]
	house.get_node("Cop").global_position = (crumbs[2] as Node3D).global_position + Vector3(0, 0.1, 0.5)
	await wait_process_frames(3)
	assert_has(house.clues_found, tr("CLUE_CRUMBS"))
	assert_does_not_have(house.clues_found, tr("CLUE_FOOTPRINTS"))
