extends GutTest

## The police station inside (comisaria.md, "Cómo es por dentro"; StationRooms).

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")
const COP_RADIUS := 0.5


func _blocks(at: Vector3, piece: Array, margin: float) -> bool:
	var center: Vector3 = piece[0]
	var half: Vector3 = piece[1] / 2
	return absf(at.x - center.x) < half.x + margin and absf(at.z - center.z) < half.z + margin \
		and center.y - half.y < 1.5


func test_the_doorways_are_open() -> void:
	var walls := StationRooms.walls() + StationRooms.front_wall(9.0)
	var doors := [
		Vector3(0, 0, StationRooms.HALF_Z), Vector3(0, 0, StationRooms.SPLIT_Z),
		Vector3((StationRooms.BREAK_DOOR.x + StationRooms.BREAK_DOOR.y) / 2, 0, StationRooms.SPLIT_Z),
		Vector3(StationRooms.FRONT_X, 0, (StationRooms.CELLS_DOOR.x + StationRooms.CELLS_DOOR.y) / 2),
	]
	for door: Vector3 in doors:
		for piece: Array in walls:
			assert_false(_blocks(door, piece, 0.0), "nothing low stands in the doorway at %s" % door)


func test_the_cops_appear_in_the_clear() -> void:
	var solid := StationRooms.walls() + StationRooms.counter()
	for item: Array in StationRooms.FURNITURE:
		solid.append([item[1], StationRooms.SOLID[item[0]].rotated(Vector3.UP, item[2]).abs()])
	for spawn: Vector3 in StationRooms.SPAWNS:
		assert_lt(absf(spawn.x), StationRooms.FRONT_X, "in the guard room")
		assert_gt(spawn.z, StationRooms.SPLIT_Z)
		for piece: Array in solid:
			assert_false(_blocks(spawn, piece, COP_RADIUS), "nothing on top of the cop at %s" % spawn)


func test_the_armory_counter_has_bars_and_the_cells_too() -> void:
	var bars := StationRooms.bars()
	assert_gt(bars.filter(func(b: Array) -> bool: return is_equal_approx(b[0].x, -StationRooms.FRONT_X)).size(), 10)
	assert_gt(bars.filter(func(b: Array) -> bool: return is_equal_approx(b[0].z, StationRooms.CELL_FRONT_Z)).size(), 10)


func test_the_shift_starts_inside_the_station_with_the_comisario_in_his_office() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 21
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(3)
	var city: Node3D = house.get_node("City")
	var p := CityLayout.place("station")
	var lot := city.transform * Transform3D(Basis(Vector3.UP, CityLayout.side_turn(p.side)),
		CityLayout.lot_center(p.block, p.side, p.along, p.size.z))
	var inside := lot.affine_inverse() * (house.get_node("Cop") as Node3D).global_position
	assert_lt(absf(inside.x), StationRooms.FRONT_X, "the cop is in the guard room")
	assert_between(inside.z, StationRooms.SPLIT_Z, StationRooms.HALF_Z)
	var comisario: Node3D = city.find_child("Comisario", true, false)
	assert_not_null(comisario)
	assert_lt((lot.affine_inverse() * comisario.global_position).z, StationRooms.SPLIT_Z, "in the back row, his office")
