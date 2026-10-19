extends GutTest

## Ending case 1.1 (docs/diseno/allanamiento.md, "Entrega" and "Cómo se gana y cómo se pierde").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 7
	house.get_node("Cop").input_enabled = false
	house.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(house)
	return house


func test_the_book_in_the_trunk_and_everyone_aboard_solves_the_case() -> void:
	var house := _house()
	await wait_physics_frames(30)
	var car := house.car
	var book := house.main_evidence()
	book.global_position = car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(car.is_delivered(book))
	assert_false(house.case_solved, "the cop is still outside")
	car.enter(house.get_node("Cop"))
	assert_true(house.case_solved)


func test_everyone_aboard_without_the_book_is_not_solved() -> void:
	var house := _house()
	await wait_physics_frames(30)
	house.car.enter(house.get_node("Cop"))
	assert_false(house.case_solved)


func test_a_broken_book_fails_the_case() -> void:
	var house := _house()
	await wait_physics_frames(5)
	house.main_evidence().hit(100.0)
	assert_true(house.case_failed)
	assert_eq(house.get_node("%CaseFailed").text, "CASE_FAILED_BROKEN")
