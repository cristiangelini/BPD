extends GutTest

## The Las Palomas building with the floor 31 story (docs/diseno/edificio.md, step 7): the key on the study's desk,
## the taped "31" button in the elevator as the clue, the key turned in the keyhole opening the button, the ride up to
## the machine room on the roof with the box of paintings, the plan hidden with the seed, and the key in the trunk
## solving the case.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")


func after_each() -> void:
	Engine.time_scale = 1.0


func _tower(case_seed := 5) -> ApartmentTower:
	var tower: ApartmentTower = TOWER_SCENE.instantiate()
	tower.story_id = "floor_31"
	tower.case_seed = case_seed
	tower.get_node("Cop").input_enabled = false
	tower.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(tower)
	return tower


func test_the_key_on_the_desk_and_the_box_on_the_roof() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	assert_has(tower.raid.suspicions, "floor_31")
	var rig := tower.rig as Floor31Rig
	assert_eq(tower.main, rig.key)
	assert_true(ApartmentTower.on_top_floor(tower.to_local(rig.key.global_position)))
	assert_eq(tower.extras.size(), 2, "the plan and the box")
	assert_eq(tower.extras[1], rig.box)
	assert_gt(tower.to_local(rig.box.global_position).y, ApartmentTower.ROOF_Y, "the box is up in the machine room")
	await wait_seconds(1.0)
	assert_eq(rig.key.value, rig.key.full_value, "the key stays on the desk")
	assert_eq(rig.box.value, rig.box.full_value, "the box settles without a scratch")


func test_the_taped_button_is_the_clue_and_does_nothing() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var rig := tower.rig as Floor31Rig
	var cop: Cop = tower.get_node("Cop")
	assert_eq(rig.button.prompt_key(cop), "PROMPT_TAPED_BUTTON")
	rig.button.use(cop)
	assert_has(tower.raid.clues_found, tr("CLUE_TAPED_BUTTON"))
	assert_false(tower.elevator.moving, "taped, it doesn't work")
	assert_eq(rig.keyhole.prompt_key(cop), "PROMPT_KEYHOLE", "without the key it's just a keyhole")
	rig.keyhole.use(cop)
	assert_false(rig.opened)


func test_the_key_opens_the_way_to_31() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var rig := tower.rig as Floor31Rig
	var cop: Cop = tower.get_node("Cop")
	cop.get_node("Grabber").grab(rig.key)
	assert_eq(rig.keyhole.prompt_key(cop), "PROMPT_TURN_FLOOR_KEY")
	rig.keyhole.use(cop)
	assert_true(rig.opened)
	assert_has(tower.raid.clues_found, tr("CLUE_FLOOR_31_OPEN"))
	assert_eq(rig.button.prompt_key(cop), "PROMPT_ELEVATOR_31")
	Engine.time_scale = 4.0
	rig.button.use(cop)
	assert_true(tower.elevator.moving)
	await wait_seconds(16.0)
	assert_false(tower.elevator.moving)
	assert_eq(tower.elevator.at_stop, Floor31Rig.SECRET_STOP)
	assert_eq(tower.elevator.current_floor(), ApartmentTower.FLOORS + 1, "the display says 31")
	assert_eq(rig.button.prompt_key(cop), "", "already there")
	assert_eq(tower.elevator.prompt_key(cop), "PROMPT_ELEVATOR_DOWN")


func test_the_machine_room_has_a_roof_and_walls() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var space := tower.get_world_3d().direct_space_state
	var inside := tower.to_global(Vector3(0, ApartmentTower.ROOF_Y + 1.5, -2.5))
	for to: Vector3 in [Vector3(0, 3, 0), Vector3(5, 0, 0), Vector3(-5, 0, 0), Vector3(0, 0, 4)]:
		var query := PhysicsRayQueryParameters3D.create(inside, inside + to)
		query.collision_mask = 1
		assert_false(space.intersect_ray(query).is_empty(), "closed toward %s" % to)


func test_the_key_in_the_trunk_solves_the_case() -> void:
	var tower := _tower()
	await wait_physics_frames(10)
	var key := tower.main
	key.global_position = tower.car.to_global(Vector3(0, 0.8, -1.7))
	await wait_physics_frames(10)
	assert_true(tower.car.is_delivered(key))
	assert_true(tower.raid.mark(tower.raid.suspicions.find("floor_31")))
	tower.car.enter(tower.get_node("Cop"))
	assert_true(tower.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_FLOOR_31_B", "BRIEF_FLOOR_31_C", "BRIEF_FLOOR_31_D", "OBJ_FIND_FLOOR_31",
			"OBJ_EXTRA_FLOOR_PLAN", "OBJ_EXTRA_PAINTINGS_BOX", "PEPA_TIP_floor_31", "PROMPT_TAPED_BUTTON",
			"CLUE_TAPED_BUTTON", "PROMPT_KEYHOLE", "HINT_KEYHOLE_EMPTY", "PROMPT_TURN_FLOOR_KEY", "HINT_FLOOR_31_OPEN",
			"CLUE_FLOOR_31_OPEN", "PROMPT_ELEVATOR_31"]:
		assert_ne(tr(key), key)
