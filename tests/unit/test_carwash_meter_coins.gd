extends GutTest

## The car wash raid with the parking meter coins (allanamiento-lavadero.md, step 6): the sack of coins (for two cops)
## solves the case, the token machine spitting a token near a cop is the clue, and the vacuums go "clinc, clinc".

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash(case_seed := 5) -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.story_id = "meter_coins"
	car_wash.case_seed = case_seed
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


func test_the_sack_of_coins_solves_the_case() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(10)
	assert_has(car_wash.raid.suspicions, "meter_coins")
	assert_eq(car_wash.main.scene_file_path, "res://scenes/props/carwash_coin_sack.tscn")
	assert_gt(car_wash.main.mass, GameScale.COP_CARRY_KG, "one cop can't carry it")
	assert_eq(car_wash.extras.size(), 2, "the key and the fake tokens")
	car_wash.main.global_position = car_wash.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(car_wash.car.is_delivered(car_wash.main))
	assert_true(car_wash.raid.mark(car_wash.raid.suspicions.find("meter_coins")))
	car_wash.car.enter(car_wash.get_node("Cop"))
	assert_true(car_wash.raid.case_solved)


func test_a_token_spat_near_a_cop_is_a_clue_and_the_floor_keeps_only_a_few() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as MeterCoinsRig
	rig.spit()
	assert_false(rig.noticed, "nobody near the machine")
	car_wash.get_node("Cop").global_position = car_wash.to_global(CarWash.TOKEN_AT + Vector3(0, 0.1, 2.0))
	await wait_physics_frames(2)
	rig.spit()
	assert_true(rig.noticed)
	assert_eq(car_wash.raid.clues_found.count(tr("CLUE_TOKEN_SPIT")), 1, "one clue")
	for i in MeterCoinsRig.MAX_TOKENS + 2:
		rig.spit()
	assert_eq(rig.tokens.size(), MeterCoinsRig.MAX_TOKENS)
	rig._since_spit = MeterCoinsRig.SPIT_EVERY
	await wait_physics_frames(2)
	assert_eq(rig.spits, MeterCoinsRig.MAX_TOKENS + 5, "on its own too")


func test_the_vacuums_clink_to_a_cop_nearby() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as MeterCoinsRig
	rig._since_clink = MeterCoinsRig.CLINK_EVERY
	await wait_physics_frames(2)
	assert_eq(rig.clinks, 0, "nobody near them")
	car_wash.get_node("Cop").global_position = car_wash.to_global(CarWash.VACUUMS[0] + Vector3(1.5, 0.1, 0))
	await wait_physics_frames(2)
	assert_eq(rig.clinks, 1)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_METER_COINS_B", "BRIEF_METER_COINS_C", "BRIEF_METER_COINS_D", "OBJ_FIND_COIN_SACK",
			"OBJ_EXTRA_METER_KEY", "OBJ_EXTRA_FAKE_TOKENS", "POMPITA_CLUE_meter_coins", "CLUE_TOKEN_SPIT",
			"CARWASH_CLINK", "CARWASH_VACUUM_CLINK"]:
		assert_ne(tr(key), key, key)
