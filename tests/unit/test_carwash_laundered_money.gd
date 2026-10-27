extends GutTest

## The car wash raid with the laundered money (allanamiento-lavadero.md, step 5): the same case as every raid, the bag
## of bills in the patrol car's trunk, the bills drying on the line near a cop, the blower throwing bills while the
## tunnel runs, Don Chorro's slips and Pompita's clue.

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash(case_seed := 5) -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.story_id = "laundered_money"
	car_wash.case_seed = case_seed
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


func test_the_bag_of_bills_solves_the_case() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(10)
	assert_has(car_wash.raid.suspicions, "laundered_money")
	assert_eq(car_wash.raid.suspicions.size(), 3)
	assert_eq(car_wash.main.scene_file_path, "res://scenes/props/carwash_cash_bag.tscn")
	assert_true(CarWash.SPOTS[car_wash.hidden_spots[0]].heavy, "it's in a spot for heavy things")
	assert_eq(car_wash.extras.size(), 2, "the notebook and the iron")
	assert_eq(car_wash.raid.owner_npc, car_wash.owner_npc)
	car_wash.main.global_position = car_wash.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(car_wash.car.is_delivered(car_wash.main))
	assert_true(car_wash.raid.mark(car_wash.raid.suspicions.find("laundered_money")))
	car_wash.car.enter(car_wash.get_node("Cop"))
	assert_true(car_wash.raid.case_solved)


func test_the_bills_on_the_line_are_a_clue_near_a_cop_and_the_blower_throws_bills() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as LaunderedMoneyRig
	assert_eq(rig.line_bills.size(), LaunderedMoneyRig.LINE_BILLS)
	assert_false(rig.noticed, "nobody near the line")
	car_wash.get_node("Cop").global_position = car_wash.to_global(Vector3(13.0, 0.1, CarWash.LINE_Z + 2.0))
	await wait_seconds(LaunderedMoneyRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(car_wash.raid.clues_found.count(tr("CLUE_BILLS_DRYING")), 1, "one clue")
	assert_eq(rig.bills_blown, 0, "the tunnel is off")
	car_wash.tunnel.start()
	await wait_seconds(LaunderedMoneyRig.BLOW_EVERY * 2.5)
	assert_gt(rig.bills_blown, LaunderedMoneyRig.BLOWN_EACH, "the blower throws bills")


func test_don_chorro_slips_and_pompita_tells_where_he_hid_something() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	assert_eq(car_wash.owner_npc.slips.size(), 3)
	assert_string_contains(car_wash.pompita.clue_speech, tr("LOC_" + CarWash.SPOTS[car_wash.hidden_spots[5 % 3]].id))
	var cop: Cop = car_wash.get_node("Cop")
	var cloth := car_wash.take_chamois()
	cop.global_position = car_wash.to_global(CarWash.POMPITA_AT + Vector3(-1.2, 0.1, 0))
	await wait_physics_frames(2)
	cloth.global_position = (cop.get_node("Grabber") as Node).hold_point()
	(cop.get_node("Grabber") as Node).grab(cloth)
	await wait_physics_frames(5)
	car_wash.pompita.use(cop)
	assert_has(car_wash.raid.clues_found, car_wash.pompita.clue)


func test_the_lawyer_loses_the_case_and_fines_count() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	car_wash.break_wax()
	assert_eq(car_wash.raid.fines, CarWash.WAX_FINE * CarWash.WAX_BOTTLES)
	car_wash.owner_npc.scold(FloorBoss.MAX_COMPLAINT, "CHORRO_LAWYER")
	assert_true(car_wash.raid.case_failed)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_CARWASH_TIP_B", "BRIEF_CARWASH_TIP_D", "BRIEF_CARWASH_TIP_E", "BRIEF_LAUNDERED_MONEY_B",
			"BRIEF_LAUNDERED_MONEY_C", "BRIEF_LAUNDERED_MONEY_D", "OBJ_FIND_CASH_BAG", "OBJ_EXTRA_TWO_BOOKS",
			"OBJ_EXTRA_IRON", "OBJ_ENTER_CARWASH", "OBJ_GUESS_CARWASH", "OBJ_BROKEN_CARWASH", "OBJ_COMPLAINT_CARWASH",
			"CHORRO_SLIP", "CLUE_POMPITA", "POMPITA_CLUE_laundered_money", "CLUE_BILLS_DRYING", "CARWASH_BILLS",
			"CASE_FAILED_LAWYER_CARWASH", "CRIME_owner_carwash", "CONFESS_owner_carwash"]:
		assert_ne(tr(key), key, key)
	for id: String in CarWash.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id, id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id, id)
	assert_true(ResourceLoader.exists(InterrogationCase.SUSPECT_MODELS["owner_carwash"]))
