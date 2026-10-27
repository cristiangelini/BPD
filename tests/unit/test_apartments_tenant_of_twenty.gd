extends GutTest

## The Las Palomas building with the tenant of twenty's story (docs/diseno/edificio.md, step 7): 30C full of the
## tricked tenants' mattresses and bags behind its locked door, the box with the twenty contracts on a mattress, 30C's
## mailbox with twenty names as the clue, the stamp and the keys hidden with the seed, and the box in the trunk
## solving the case.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")


func _tower(case_seed := 5) -> ApartmentTower:
	var tower: ApartmentTower = TOWER_SCENE.instantiate()
	tower.story_id = "tenant_of_twenty"
	tower.case_seed = case_seed
	tower.get_node("Cop").input_enabled = false
	tower.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(tower)
	return tower


## Whether a point in the building's space is inside 30C.
func _in_30c(at: Vector3) -> bool:
	return at.x < -ApartmentTower.SHAFT_HALF and at.x > -ApartmentTower.HALF_X and at.z < ApartmentTower.CORE_Z \
		and at.z > -ApartmentTower.HALF_Z and ApartmentTower.on_top_floor(at)


func test_30c_full_of_mattresses_with_the_box() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	assert_has(tower.raid.suspicions, "tenant_of_twenty")
	var rig := tower.rig as TenantsRig
	assert_eq(tower.main, rig.box)
	assert_gte(rig.mattresses.size(), 8, "the tricked tenants' mattresses")
	for mattress in rig.mattresses:
		assert_true(_in_30c(tower.to_local(mattress.global_position)))
	assert_true(_in_30c(tower.to_local(rig.box.global_position)), "the box is in 30C")
	assert_true(tower.rental_door.locked, "30C stays locked like always")
	assert_eq(tower.extras.size(), 2, "the stamp and the keys")
	await wait_seconds(1.0)
	var at := tower.to_local(rig.box.global_position)
	assert_gt(at.y, ApartmentTower.TOP_Y + TenantsRig.MATTRESS_SIZE.y, "it rests on its mattress")
	assert_eq(rig.box.value, rig.box.full_value, "it settles without a scratch")


func test_the_mailbox_with_twenty_names_is_the_clue() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var rig := tower.rig as TenantsRig
	var cop: Cop = tower.get_node("Cop")
	assert_lt(tower.to_local(rig.mailbox.global_position).y, ApartmentTower.STOREY, "in the lobby")
	assert_eq(rig.mailbox.prompt_key(cop), "PROMPT_MAILBOX_30C")
	rig.mailbox.use(cop)
	assert_has(tower.raid.clues_found, tr("CLUE_TWENTY_NAMES"))


func test_the_way_in_is_clear() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var space := tower.get_world_3d().direct_space_state
	var door := tower.to_global(Vector3(ApartmentTower.FLAT_C_DOOR_X, ApartmentTower.TOP_Y + 0.5,
		ApartmentTower.CORE_Z - 0.3))
	var query := PhysicsRayQueryParameters3D.create(door, door + Vector3(0, 0, -1.4))
	assert_true(space.intersect_ray(query).is_empty(), "a strip to walk in by the door")


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var tower := _tower()
	await wait_physics_frames(10)
	var box := tower.main
	box.global_position = tower.car.to_global(Vector3(0, 0.8, -1.7))
	await wait_physics_frames(10)
	assert_true(tower.car.is_delivered(box))
	assert_true(tower.raid.mark(tower.raid.suspicions.find("tenant_of_twenty")))
	tower.car.enter(tower.get_node("Cop"))
	assert_true(tower.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_TENANT_OF_TWENTY_B", "BRIEF_TENANT_OF_TWENTY_C", "BRIEF_TENANT_OF_TWENTY_D",
			"OBJ_FIND_TENANT_OF_TWENTY", "OBJ_EXTRA_FAKE_STAMP", "OBJ_EXTRA_KEY_BUNCH", "PEPA_TIP_tenant_of_twenty",
			"PROMPT_MAILBOX_30C", "CLUE_TWENTY_NAMES"]:
		assert_ne(tr(key), key)
