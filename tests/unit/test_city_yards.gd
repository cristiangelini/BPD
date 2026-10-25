extends GutTest

## The backyards (docs/diseno/ciudad-viva.md, step 4): fences that stay in their blocks, never cross an alley or a
## house, and a cop who jumps against one climbs over it.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_yards_are_only_in_blocks_of_plain_houses() -> void:
	var blocks := CityYards.blocks()
	assert_gt(blocks.size(), 3, "the west side has yards")
	for block in blocks:
		assert_eq(CityLayout.barrio_kind(block), "house")
		for alley: Array in CityLife.ALLEYS:
			assert_ne(block, alley[0], "no alley through the yards of %s" % block)


func test_fences_stay_in_the_block_and_off_the_houses() -> void:
	for block in CityYards.blocks():
		var center := CityLayout.block_center(block)
		var inner := CityLayout.BLOCK - CityLayout.SIDEWALK * 2
		var ground := Rect2(Vector2(center.x, center.z) - Vector2.ONE * inner / 2, Vector2.ONE * inner)
		var houses: Array[Rect2] = []
		for lot: Dictionary in CityLayout.fillers():
			if lot.block == block:
				houses.append(CityLayout.footprint(lot.block, lot.side, lot.along, lot.size).grow(-0.05))
		for line in CityYards.fences(block):
			var a := Vector2(line[0].x, line[0].z)
			var b := Vector2(line[1].x, line[1].z)
			assert_true(ground.has_point(a) and ground.has_point(b), "a fence of %s sticks out" % block)
			for house in houses:
				assert_false(house.has_point(a.lerp(b, 0.5)), "a fence of %s runs through a house" % block)


func _world_with_fence() -> Climbable:
	var floor_body := StaticBody3D.new()
	var floor_shape := CollisionShape3D.new()
	var slab := BoxShape3D.new()
	slab.size = Vector3(40, 1, 40)
	floor_shape.shape = slab
	floor_shape.position.y = -0.5
	floor_body.add_child(floor_shape)
	add_child_autofree(floor_body)
	var fence := Climbable.new()
	fence.position = Vector3(0, CityYards.FENCE_HEIGHT / 2, -2)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(6, CityYards.FENCE_HEIGHT, 0.1)
	shape.shape = box
	fence.add_child(shape)
	add_child_autofree(fence)
	return fence


## Lets the cop land (with input off, nothing else steps it).
func _settle(cop: Cop) -> void:
	for i in 20:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	cop.get_node("Grabber").input_enabled = false
	return cop


func test_a_cop_climbs_over_a_fence() -> void:
	_world_with_fence()
	var cop := _cop()
	cop.global_position = Vector3(0, 0.1, -0.9)
	await _settle(cop)
	cop.step(1.0 / 60.0, Vector2.ZERO, false, false, true)
	assert_gt(cop.climb_left, 0.0, "jumping against the fence starts a climb")
	for i in 30:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_gt(cop.global_position.y, 0.5, "up the fence")
	for i in 40:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_lt(cop.global_position.z, -2.5, "and down on the other side")
	assert_eq(cop.climb_left, 0.0)


func test_away_from_fences_a_jump_is_a_jump() -> void:
	_world_with_fence()
	var cop := _cop()
	cop.global_position = Vector3(0, 0.1, 4)
	await _settle(cop)
	cop.step(1.0 / 60.0, Vector2.ZERO, false, false, true)
	assert_eq(cop.climb_left, 0.0)
	assert_gt(cop.velocity.y, 0.0, "a plain jump")
