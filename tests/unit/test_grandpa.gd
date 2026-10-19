extends GutTest

## The grandpa and his complaint meter (docs/diseno/allanamiento.md, "El abuelo").

const GRANDPA_SCENE := preload("res://scenes/npc/grandpa.tscn")
const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _grandpa() -> Grandpa:
	var grandpa: Grandpa = GRANDPA_SCENE.instantiate()
	add_child_autofree(grandpa)
	return grandpa


func _wall(at: Vector3) -> void:
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4, 3, 0.2)
	shape.shape = box
	wall.add_child(shape)
	wall.position = at
	add_child_autofree(wall)


func test_seeing_a_break_up_close_complains() -> void:
	var grandpa := _grandpa()
	await wait_physics_frames(2)
	assert_true(grandpa.saw_break(Vector3(0, 1, -3)))
	assert_eq(grandpa.complaint, Grandpa.SAW_BREAK)
	assert_false(grandpa.saw_break(Vector3(0, 1, -20)), "too far to see")
	assert_eq(grandpa.complaint, Grandpa.SAW_BREAK)


func test_breaks_behind_a_wall_go_unseen() -> void:
	var grandpa := _grandpa()
	_wall(Vector3(0, 1.5, -1.5))
	await wait_physics_frames(2)
	assert_false(grandpa.saw_break(Vector3(0, 1, -3)))
	assert_eq(grandpa.complaint, 0.0)


func test_struck_and_door_points() -> void:
	var grandpa := _grandpa()
	assert_true(grandpa.struck())
	assert_false(grandpa.struck(), "one shove, one complaint")
	grandpa.door_broken(Vector3(0, 0, -4))
	assert_eq(grandpa.complaint, Grandpa.STRUCK + Grandpa.DOOR_BROKEN)


func test_meter_drops_while_nothing_happens() -> void:
	var grandpa := _grandpa()
	grandpa.door_broken(Vector3.ZERO)
	await wait_seconds(Grandpa.DECAY_EVERY + 0.3)
	assert_eq(grandpa.complaint, Grandpa.DOOR_BROKEN - 1.0)


func test_at_100_he_calls_the_lawyer_once() -> void:
	var grandpa := _grandpa()
	watch_signals(grandpa)
	for i in 7:
		grandpa.door_broken(Vector3.ZERO)
		grandpa.struck()
		grandpa._since_struck = Grandpa.STRUCK_COOLDOWN
	assert_eq(grandpa.complaint, Grandpa.MAX_COMPLAINT)
	assert_signal_emit_count(grandpa, "lawyer_called", 1)


func test_house_loses_the_case_at_100() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 3
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	house.grandpa._set_complaint(Grandpa.MAX_COMPLAINT)
	assert_true(house.case_failed)
	assert_true(house.get_node("%CaseFailed").visible)


func test_grandpa_follows_the_nearest_cop() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 3
	var cop: Cop = house.get_node("Cop")
	cop.input_enabled = false
	cop.position = Vector3(0.0, 0.1, 6.5)
	add_child_autofree(house)
	await wait_physics_frames(5)
	var start := house.grandpa.global_position.distance_to(cop.global_position)
	await wait_seconds(3.0)
	var now := house.grandpa.global_position.distance_to(cop.global_position)
	assert_lt(now, start - 1.0, "he walks toward the cop (from %.1f to %.1f m)" % [start, now])


func _cop() -> Cop:
	var cop: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	cop.input_enabled = false
	cop.position = Vector3(0, 0, 3)
	add_child_autofree(cop)
	return cop


func test_story_holds_him_and_the_listener() -> void:
	var grandpa := _grandpa()
	var cop := _cop()
	assert_true(grandpa.start_story(cop))
	assert_true(cop.is_busy(), "the cop listening can't do anything else")
	var start := grandpa.global_position
	await wait_seconds(1.0)
	var moved := Vector2(grandpa.global_position.x - start.x, grandpa.global_position.z - start.z).length()
	assert_almost_eq(moved, 0.0, 0.01, "he stands still while telling it (falling is fine, there is no floor here)")
	grandpa.end_story()
	assert_false(cop.is_busy())


func test_story_ends_by_itself_and_needs_a_rest() -> void:
	var grandpa := _grandpa()
	var cop := _cop()
	grandpa.start_story(cop)
	grandpa._story_left = 0.1
	await wait_seconds(0.3)
	assert_false(grandpa.is_telling_story(), "at most STORY_MAX seconds")
	assert_false(grandpa.start_story(cop), "he needs STORY_COOLDOWN before another one")
	grandpa._story_wait = 0.0
	assert_true(grandpa.start_story(cop))


func test_every_room_door_is_open() -> void:
	# Walls with two doors used to cover the first one (the living and the upstairs west rooms were sealed).
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(2)
	var space := house.get_world_3d().direct_space_state
	for w: Array in GrandpaHouse.WALLS:
		for d: float in w[5]:
			var query := PhysicsPointQueryParameters3D.new()
			var y: float = w[4] * GameScale.FLOOR_HEIGHT + 1.0
			query.position = Vector3(w[1], y, d) if w[0] == "z" else Vector3(d, y, w[1])
			query.collision_mask = 1
			var walls := space.intersect_point(query).filter(func(h: Dictionary) -> bool:
				return (h.collider as Node).get_parent() == house.get_node("Built"))
			assert_eq(walls.size(), 0, "door at %s on wall %s" % [d, w[0]])


func test_the_grandpa_walks_out_of_the_living_room() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 7
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(5)
	var cop: Cop = house.get_node("Cop")
	cop.global_position = Vector3(1.0, 0.1, 6.5)
	await wait_seconds(6.0)
	assert_gt(house.grandpa.global_position.x, -1.0, "came through the living room door into the hall")
