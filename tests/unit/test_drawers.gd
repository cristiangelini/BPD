extends GutTest

## Drawers open by pulling them slowly; yanked, they come off and spill (investigacion.md, decision 76).

const FIGURINE := preload("res://scenes/props/ornament_figurine.tscn")


func before_each() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(30, 0.2, 30)
	shape.shape = box
	shape.position.y = -0.1
	floor_body.add_child(shape)
	add_child_autofree(floor_body)


func _dresser(contents: Array = []) -> Dresser:
	var dresser := Dresser.new()
	dresser.contents = contents
	add_child_autofree(dresser)
	return dresser


## Holds the drawer and moves the hold point straight out of the front at `speed` m/s for `seconds`.
func _pull(drawer: Drawer, speed: float, seconds: float) -> void:
	var point := drawer.global_position
	for frame in int(seconds * 60):
		point += drawer.out_dir * speed / 60.0
		drawer.hold(1, point)
		await wait_physics_frames(1)
	drawer.let_go(1)


func test_it_starts_closed_and_stays_closed() -> void:
	var dresser := _dresser()
	await wait_physics_frames(30)
	assert_eq(dresser.drawers.size(), Dresser.DRAWERS)
	for drawer in dresser.drawers:
		assert_almost_eq(drawer.opening(), 0.0, 0.02)


func test_pulling_slowly_opens_it_to_the_end_of_its_rails() -> void:
	var dresser := _dresser()
	await wait_physics_frames(10)
	var drawer: Drawer = dresser.drawers[1]
	await _pull(drawer, 0.8, 1.5)
	assert_false(drawer.is_ripped, "slow is fine")
	assert_almost_eq(drawer.opening(), Drawer.TRAVEL, 0.05, "fully open")
	assert_almost_eq(drawer.global_position.x, dresser.global_position.x, 0.02, "it only slides out")


func test_yanking_it_rips_it_out_and_the_contents_fly() -> void:
	var dresser := _dresser([[], [FIGURINE, FIGURINE], []])
	await wait_physics_frames(30)
	var drawer: Drawer = dresser.drawers[1]
	assert_false(drawer.is_ripped, "still closed before pulling (%.2f m)" % drawer.opening())
	var rips := [0]
	drawer.ripped.connect(func(_at: Vector3) -> void: rips[0] += 1)
	var inside := drawer.contents.duplicate()
	await _pull(drawer, GameScale.WALK_SPEED, 0.6)
	assert_true(drawer.is_ripped, "walking back pulls too hard")
	assert_eq(rips[0], 1)
	assert_gt(drawer.opening(), Drawer.TRAVEL + 0.2, "it left its rails")
	for item in inside:
		# A figurine that flew out either broke on landing or lies out in front of the dresser.
		assert_true(not is_instance_valid(item) or item.global_position.z > 0.3, "the contents spilled out")


func test_pulling_on_after_it_is_open_is_fine_when_crouching() -> void:
	var dresser := _dresser()
	await wait_physics_frames(10)
	var drawer: Drawer = dresser.drawers[0]
	await _pull(drawer, GameScale.CROUCH_SPEED, 1.0)
	assert_false(drawer.is_ripped, "crouching back is slow enough")
	assert_almost_eq(drawer.opening(), Drawer.TRAVEL, 0.05)


func test_a_cop_grabs_the_drawer_and_opens_it_crouching_back() -> void:
	var dresser := _dresser()
	var cop: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(cop)
	cop.global_position = Vector3(0, 0.05, 1.2)
	await wait_physics_frames(10)
	var drawer: Drawer = dresser.drawers[1]
	cop.look(Vector2(0, deg_to_rad(36)))
	assert_eq(cop.current_prompt(), "PROMPT_DRAWER")
	assert_true(cop.get_node("Grabber").try_grab(), "the cop's hand is on the drawer")
	for i in 60:
		cop.step(1.0 / 60.0, Vector2(0, 1), false, true, false)
		await wait_physics_frames(1)
	assert_false(drawer.is_ripped)
	assert_gt(drawer.opening(), Drawer.TRAVEL - 0.05, "pulled open")


func test_the_house_has_dressers_with_things_inside() -> void:
	var house: GrandpaHouse = preload("res://scenes/levels/grandpa_house.tscn").instantiate()
	house.case_seed = 7
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(5)
	assert_eq(house.dressers.size(), GrandpaHouse.DRESSERS.size())
	for dresser in house.dressers:
		for drawer in dresser.drawers:
			assert_eq(drawer.contents.size(), 2)
			assert_almost_eq(drawer.opening(), 0.0, 0.02, "closed when the case starts")
