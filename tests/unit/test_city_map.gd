extends GutTest

## The city map on the radio (docs/diseno/ciudad.md, step 3).

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func test_the_whole_city_fits_on_the_map_north_up() -> void:
	var half := CityLayout.SIZE / 2
	for corner: Vector3 in [Vector3(-half.x, 0, -half.y), Vector3(half.x, 0, half.y)]:
		var at := CityMap.to_map(corner)
		assert_between(at.x, 0.0, CityMap.SIZE)
		assert_between(at.y, 0.0, CityMap.SIZE)
	assert_lt(CityMap.to_map(Vector3(0, 0, -10)).y, CityMap.to_map(Vector3.ZERO).y, "north is up")


func test_m_opens_and_closes_the_map() -> void:
	InputSetup.ensure_actions()
	var map: CityMap = add_child_autofree(CityMap.new())
	assert_false(map.is_open())
	var press := InputEventAction.new()
	press.action = "map"
	press.pressed = true
	map._unhandled_input(press)
	assert_true(map.is_open())
	map._unhandled_input(press)
	assert_false(map.is_open())


func test_the_case_map_puts_the_cop_at_the_station_and_marks_the_house() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(3)
	var map := house.city_map
	assert_eq(map.target, "grandpa")
	var station := CityMap.to_map(CityLayout.door_of("station"))
	assert_lt(map.world_to_map(house.get_node("Cop").global_position).distance_to(station), 12.0,
		"the cop's arrow starts by the station")
	var home := CityLayout.place("grandpa")
	var lot := CityMap.to_map(CityLayout.lot_center(home.block, home.side, home.along, home.size.z))
	assert_lt(map.world_to_map(Vector3.ZERO).distance_to(lot), 1.0, "the house at the origin is the marked lot")
