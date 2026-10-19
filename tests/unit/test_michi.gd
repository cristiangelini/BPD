extends GutTest

## Michi, the grandpa's cat (investigacion.md, "Más personajes en la casa").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 11
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_michi_sleeps_on_the_betting_book_and_stays_put() -> void:
	var house := _house()
	await wait_physics_frames(60)
	var book: Node3D = house.main_evidence()
	var flat := Vector2(house.michi.global_position.x - book.global_position.x, house.michi.global_position.z - book.global_position.z)
	assert_lt(flat.length(), 0.3, "on top of the book's spot")
	assert_false(house.michi.awake)


func test_picking_michi_up_meows_and_the_grandpa_hears_it() -> void:
	var house := _house()
	await wait_physics_frames(15)
	house.grandpa.global_position = house.michi.global_position + Vector3(3, 0, 0)
	var start := house.grandpa.complaint
	house.michi.hold(1, house.michi.global_position + Vector3.UP)
	assert_true(house.michi.awake)
	assert_almost_eq(house.grandpa.complaint, start + Grandpa.CAT_UPSET, 0.01)
	assert_eq(house.michi.get_node("Bubble").text, "CAT_MEOW")


func test_awake_michi_follows_a_cop_and_running_into_it_trips() -> void:
	var house := _house()
	await wait_physics_frames(15)
	var cop: Cop = house.get_node("Cop")
	var michi := house.michi
	michi.awake = true
	michi.global_position = Vector3(0, 0.1, 6.0)
	cop.global_position = Vector3(0, 0.1, 8.0)
	await wait_seconds(2.0)
	assert_lt(michi.global_position.distance_to(cop.global_position), 1.5, "it comes to the cop's feet")
	cop.velocity = Vector3(4, 0, 0)
	michi.global_position = cop.global_position + Vector3(0.2, 0, 0)
	michi._trip_wait = 0.0
	michi._check_trip()
	assert_true(cop.is_staggered(), "the cop trips")
