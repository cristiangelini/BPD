extends GutTest

## The flooding bank's case (robo-banco-inundado.md, step 4, decision 125): the radio warns about the water, loose
## things float, the gang wades out with the sacks before they get away, and the valve shut before the water gets to
## the top pays 100 more.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _bank() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "flood":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	bank.front_door.open_from_inside()


func _texts(rows: Array[Dictionary]) -> Array[String]:
	var texts: Array[String] = []
	for row in rows:
		texts.append(row.text)
	return texts


func test_the_radio_warns_about_the_water() -> void:
	await _bank()
	assert_eq(bank.case.brief(), PackedStringArray(["BRIEF_BANK_FLOOD_A", "BRIEF_BANK_FLOOD_B", "BRIEF_BANK_FLOOD_C"]))


func test_the_planilla_asks_for_the_valve_and_shows_the_water() -> void:
	await _bank()
	bank.water.level = 0.42
	var texts := _texts(bank.case.rows())
	assert_has(texts, "OBJ_BANK_VALVE")
	assert_has(texts, tr("OBJ_BANK_WATER") % 42)
	assert_has(texts, "OBJ_BANK_CUFF_OSO", "El Oso is still the one to cuff")


func test_shutting_it_early_pays_100_more() -> void:
	await _bank()
	bank.case.boss_jailed = true
	bank.hostages_freed = bank.hostages.size()
	var base: int = bank.case.report().salary
	bank.water.level = 0.5
	bank.water.shut_off()
	assert_eq(bank.case.report().salary, base + BankCase.EARLY_VALVE)


func test_shut_at_the_top_pays_nothing_more() -> void:
	await _bank()
	bank.case.boss_jailed = true
	bank.hostages_freed = bank.hostages.size()
	var base: int = bank.case.report().salary
	bank.water.level = BankWater.MAX_LEVEL
	bank.water.shut_off()
	assert_eq(bank.case.report().salary, base)


func test_loose_things_float() -> void:
	await _bank()
	bank.water.level = 0.8
	var box := RigidBody3D.new()
	box.mass = 2.0
	var shape := CollisionShape3D.new()
	var cube := BoxShape3D.new()
	cube.size = Vector3(0.3, 0.3, 0.3)
	shape.shape = cube
	box.add_child(shape)
	bank.add_child(box)
	box.global_position = bank.to_global(Vector3(-6.0, 0.3, 7.0))
	await wait_seconds(1.5)
	assert_gt(box.global_position.y, bank.to_global(Vector3(0, BankLevel.FLOOR_TOP + 0.5, 0)).y, "up to the surface")
	assert_lt(box.global_position.y, bank.to_global(Vector3(0, BankLevel.FLOOR_TOP + 1.3, 0)).y, "but not flying")


func test_things_in_hand_dont_float() -> void:
	var held := Grabbable.new()
	held.holders[1] = Vector3.ZERO
	assert_false(BankWater.floats(held))
	held.holders.clear()
	assert_true(BankWater.floats(held))
	held.free()


func test_deep_water_the_gang_wades_out_before_the_getaway() -> void:
	await _bank()
	bank.water.level = BankWater.MAX_LEVEL
	assert_almost_eq(bank.wade_out_time(), BankLevel.WADE_OUT, 0.01)
	bank.drill.drilled = bank.drill.drill_time
	await wait_physics_frames(3)
	assert_null(bank.chase, "still wading")
	await wait_seconds(BankLevel.WADE_OUT + 0.5)
	assert_not_null(bank.chase)
	assert_true(bank.chase.ended.is_connected(bank.case._on_getaway_ended), "the case watches the getaway")


func test_shallow_water_they_go_at_once() -> void:
	await _bank()
	bank.water.level = BankLevel.WADE_FROM - 0.05
	assert_eq(bank.wade_out_time(), 0.0)
	bank.drill.drilled = bank.drill.drill_time
	await wait_physics_frames(3)
	assert_not_null(bank.chase)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_BANK_FLOOD_A", "BRIEF_BANK_FLOOD_C", "OBJ_BANK_VALVE", "OBJ_BANK_WATER",
			"HINT_FLOOD_WADING"]:
		assert_ne(tr(key), key, key)
