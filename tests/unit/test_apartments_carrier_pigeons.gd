extends GutTest

## The Las Palomas building with the carrier pigeons' story (docs/diseno/edificio.md, step 7): the loft on 30B's
## balcony, a pigeon flying in every so often with the pearl necklace until a cop takes it, a running cop scaring it
## off, feathers and birdseed from the elevator to 30B as the clue, the whistle hidden with the seed, and the loft in
## the trunk solving the case.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")


func after_each() -> void:
	Engine.time_scale = 1.0


func _tower(case_seed := 5) -> ApartmentTower:
	var tower: ApartmentTower = TOWER_SCENE.instantiate()
	tower.story_id = "carrier_pigeons"
	tower.case_seed = case_seed
	tower.get_node("Cop").input_enabled = false
	tower.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(tower)
	return tower


func test_the_loft_on_the_balcony() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	assert_has(tower.raid.suspicions, "carrier_pigeons")
	var rig := tower.rig as CarrierPigeonsRig
	assert_eq(tower.main, rig.loft)
	assert_almost_eq(rig.loft.mass, 25.0, 0.01)
	assert_true(rig.loft_on_balcony())
	var size := ((rig.loft.get_node("Shape") as CollisionShape3D).shape as BoxShape3D).size
	assert_lt(maxf(size.x, size.z), TowerElevator.INSIDE.x, "it fits in the elevator")
	assert_eq(tower.extras.size(), 2, "the whistle and the necklace")
	assert_eq(tower.extras[1], rig.necklace)
	assert_false(rig.necklace.visible, "the necklace is still on a pigeon's leg")
	await wait_seconds(1.0)
	assert_eq(rig.loft.value, rig.loft.full_value, "it settles without a scratch")


func test_a_pigeon_brings_the_necklace() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var rig := tower.rig as CarrierPigeonsRig
	var cop: Cop = tower.get_node("Cop")
	rig.send_pigeon()
	assert_true(rig.pigeon.carries)
	assert_eq(rig.pigeon.prompt_key(cop), "", "not while it flies")
	await wait_seconds(MessengerPigeon.FLY_TIME + 0.3)
	assert_eq(rig.pigeon.state, MessengerPigeon.State.LANDED)
	assert_lt(rig.pigeon.global_position.distance_to(rig.loft.to_global(CarrierPigeonsRig.BOARD)), 0.05, "on the board")
	assert_eq(rig.pigeon.prompt_key(cop), "PROMPT_PIGEON_TAKE")
	rig.pigeon.use(cop)
	assert_true(rig.necklace.visible)
	assert_false(rig.necklace.freeze)
	assert_lt(rig.necklace.global_position.distance_to(rig.loft.global_position), 1.0, "by the loft")
	assert_eq(rig.pigeon.state, MessengerPigeon.State.LEAVING, "and off it goes")
	await wait_seconds(MessengerPigeon.FLY_TIME + 0.3)
	rig.send_pigeon()
	assert_false(rig.pigeon.carries, "the necklace came only once")


func test_a_running_cop_scares_it_off() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var rig := tower.rig as CarrierPigeonsRig
	var cop: Cop = tower.get_node("Cop")
	rig.send_pigeon()
	await wait_seconds(MessengerPigeon.FLY_TIME + 0.3)
	cop.global_position = rig.pigeon.global_position + Vector3(-2.0, 0.0, -1.0)
	cop.velocity = Vector3(GameScale.WALK_SPEED, 0, 0)
	assert_false(rig.hears_noise(), "walking is fine")
	cop.velocity = Vector3(GameScale.RUN_SPEED, 0, 0)
	assert_true(rig.hears_noise())
	rig.pigeon.leave()
	await wait_seconds(MessengerPigeon.FLY_TIME + 0.3)
	assert_eq(rig.pigeon.state, MessengerPigeon.State.AWAY)
	assert_false(rig.necklace.visible, "it took the necklace with it")
	rig.send_pigeon()
	assert_true(rig.pigeon.carries, "the next one brings it again")


func test_pigeons_come_on_their_own_while_the_loft_is_out() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var rig := tower.rig as CarrierPigeonsRig
	Engine.time_scale = 8.0
	await wait_seconds(CarrierPigeonsRig.ARRIVE_EVERY + MessengerPigeon.FLY_TIME + 1.0)
	assert_eq(rig.arrivals, 1)
	rig.loft.global_position = tower.to_global(Vector3(3.0, ApartmentTower.TOP_Y + 0.5, 4.0))
	assert_false(rig.loft_on_balcony())


func test_feathers_from_the_elevator_to_30b() -> void:
	var tower := _tower()
	await wait_physics_frames(2)
	var rig := tower.rig as CarrierPigeonsRig
	assert_eq(rig.trail[0].get_parent(), tower.elevator, "some in the elevator")
	for spot: ClueSpot in rig.trail.slice(1):
		assert_true(ApartmentTower.on_top_floor(tower.to_local(spot.global_position)))
	rig.trail[2].use(tower.get_node("Cop"))
	assert_has(tower.raid.clues_found, tr("CLUE_FEATHERS"))


func test_the_loft_in_the_trunk_solves_the_case() -> void:
	var tower := _tower()
	await wait_physics_frames(10)
	var loft := tower.main
	loft.global_position = tower.car.to_global(Vector3(0, 0.9, -1.7))
	await wait_physics_frames(10)
	assert_true(tower.car.is_delivered(loft))
	assert_true(tower.raid.mark(tower.raid.suspicions.find("carrier_pigeons")))
	tower.car.enter(tower.get_node("Cop"))
	assert_true(tower.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_CARRIER_PIGEONS_B", "BRIEF_CARRIER_PIGEONS_C", "BRIEF_CARRIER_PIGEONS_D",
			"OBJ_FIND_CARRIER_PIGEONS", "OBJ_EXTRA_TRAINER_WHISTLE", "OBJ_EXTRA_PEARL_NECKLACE",
			"PEPA_TIP_carrier_pigeons", "PROMPT_PIGEON_TAKE", "PROMPT_FEATHERS", "CLUE_FEATHERS"]:
		assert_ne(tr(key), key)
