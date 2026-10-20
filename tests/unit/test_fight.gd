extends GutTest

## The retirees' fight club story (historias.md, "Club de lucha de jubilados").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 21
	house.story = GrandpaHouse.FIGHT
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_the_belt_gloves_and_notebook_are_hidden_with_the_ring_upstairs() -> void:
	var house := _house()
	await wait_physics_frames(5)
	assert_eq(house.evidence.size(), 3)
	assert_eq(house.main_evidence().full_value, 1000.0)
	assert_has(house.suspicions, "fight")
	var rig: FightRig = house.rig
	assert_gt(rig.ring.global_position.y, 2.0, "the ring is in the attic, upstairs")


func test_the_photo_with_black_eyes_is_a_clue() -> void:
	TranslationServer.set_locale("es")
	var house := _house()
	await wait_physics_frames(40)
	var rig: FightRig = house.rig
	assert_not_null(rig.photo, "the photo is placed once the clues are")
	rig.photo.use(house.get_node("Cop"))
	assert_has(house.raid.clues_found, house.tr("CLUE_FIGHT_PHOTO"))


func test_the_champion_pushes_back_and_skips_stories() -> void:
	var house := _house()
	await wait_physics_frames(2)
	var grandpa := house.grandpa
	var cop: Cop = house.get_node("Cop")
	assert_true(grandpa.champion)
	assert_false(grandpa.start_story(cop), "a champion doesn't get distracted")
	cop.global_position = grandpa.global_position + Vector3(1.0, 0.1, 0)
	await wait_physics_frames(2)
	var before := cop.global_position
	grandpa.push_back(cop, 3.0)
	assert_true(cop.is_staggered())
	for i in 10:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
	assert_gt(cop.global_position.x - before.x, 0.3, "shoved away from him")


func test_an_ordinary_grandpa_still_tells_stories() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 21
	house.story = GrandpaHouse.BINGO
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(2)
	assert_false(house.grandpa.champion)
	assert_true(house.grandpa.start_story(house.get_node("Cop")))


func test_the_belt_in_the_trunk_solves_the_case() -> void:
	var house := _house()
	await wait_physics_frames(10)
	var belt := house.main_evidence()
	belt.global_position = house.car.to_global(Vector3(0, 0.8, -1.7))
	belt.linear_velocity = Vector3.ZERO
	await wait_physics_frames(20)
	assert_true(house.car.is_delivered(belt))
	assert_true(house.mark(house.suspicions.find("fight")))
	house.car.enter(house.get_node("Cop"))
	assert_true(house.raid.case_solved)
