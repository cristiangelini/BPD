extends GutTest

## The grandpa's fragile ornaments and their fines (docs/diseno/allanamiento.md, "La casa del abuelo").

const FIGURINE := preload("res://scenes/props/ornament_figurine.tscn")
const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _floor() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(20, 0.2, 20)
	shape.shape = box
	shape.position.y = -0.1
	floor_body.add_child(shape)
	add_child_autofree(floor_body)


func _figurine(at: Vector3) -> Ornament:
	var ornament: Ornament = FIGURINE.instantiate()
	ornament.position = at
	add_child_autofree(ornament)
	return ornament


func test_gentle_touch_does_not_break_it() -> void:
	var ornament := _figurine(Vector3.ZERO)
	assert_false(ornament.hit(Ornament.BREAK_SPEED))
	assert_false(ornament.is_broken)


func test_real_hit_breaks_it() -> void:
	var ornament := _figurine(Vector3.ZERO)
	watch_signals(ornament)
	assert_true(ornament.hit(2.0))
	assert_true(ornament.is_broken)
	assert_signal_emitted(ornament, "broken")
	assert_false(ornament.hit(5.0), "it only breaks once")


func test_resting_on_a_shelf_keeps_it_whole() -> void:
	_floor()
	var ornament := _figurine(Vector3(0, 0.09, 0))
	await wait_physics_frames(60)
	assert_false(ornament.is_broken)


func test_falling_off_a_table_breaks_it() -> void:
	_floor()
	var ornament: Ornament = FIGURINE.instantiate()
	ornament.position = Vector3(0, 0.8, 0)
	var breaks := [0]
	ornament.broken.connect(func(_at: Vector3) -> void: breaks[0] += 1)
	add_child(ornament)
	await wait_physics_frames(60)
	assert_eq(breaks[0], 1)
	assert_false(is_instance_valid(ornament), "the broken ornament is gone, only shards stay")


func test_layout_is_about_150_and_follows_the_seed() -> void:
	var places := OrnamentLayout.places(7)
	assert_between(places.size(), 140, 160)
	assert_eq(places, OrnamentLayout.places(7))
	assert_ne(places.map(func(p: Dictionary) -> int: return p.kind), OrnamentLayout.places(8).map(func(p: Dictionary) -> int: return p.kind))


func test_house_ornaments_settle_whole_and_cost_fines() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 21
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(120)
	assert_eq(house.ornaments_total, OrnamentLayout.places(21).size())
	assert_eq(house.broken_ornaments, 0, "nothing breaks while the house settles")
	var ornament: Ornament = house.get_node("Ornaments").get_child(0)
	ornament.hit(4.0)
	assert_eq(house.broken_ornaments, 1)
	assert_eq(house.fines, Ornament.FINE)
