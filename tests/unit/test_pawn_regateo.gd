extends GutTest

## Don Regateo at the pawn shop (allanamiento-empenos.md, step 3): he walks behind his counter, something to pawn sends
## him to the appraisal mat with his back to the shop, appraisals rest and the third one gives the cops away, and the
## customers' complaints, what's taken unpaid and what breaks reach his complaint.

const SCENE := preload("res://scenes/levels/pawn_shop.tscn")
const BALL := preload("res://assets/models/pawn_radio.glb")


func _shop() -> PawnShop:
	var place: PawnShop = SCENE.instantiate()
	place.case_seed = 5
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func _thing(place: PawnShop) -> Grabbable:
	var item := ClubEvidence.make_item("Outside", BALL, Vector3(0.3, 0.2, 0.2), 1.0)
	place.add_child(item)
	item.global_position = place.to_global(PawnShop.COUNTER_AT + Vector3(-1.5, PawnShop.COUNTER_SIZE.y + 0.15, 0))
	return item


func test_he_walks_behind_his_counter() -> void:
	var place := _shop()
	assert_not_null(place.owner_boss)
	assert_eq(place.owner_boss.voice, "REGATEO")
	var start := place.owner_boss.global_position
	await wait_seconds(1.5)
	assert_gt(place.owner_boss.global_position.distance_to(start), 0.8, "on his way")
	assert_gt(place.to_local(place.owner_boss.global_position).z, PawnShop.COUNTER_AT.z, "behind the counter")
	assert_eq(place.owner_boss.complaint, 0.0)


func test_something_to_pawn_turns_him_away_and_then_he_pays() -> void:
	var place := _shop()
	var boss := place.owner_boss
	boss.fix_time = 3.0
	await wait_physics_frames(5)
	var item := _thing(place)
	await wait_seconds(PawnCounter.TAKE_AFTER + 0.3)
	assert_true(place.appraisal.is_jammed, "appraising")
	assert_eq(boss.errand(), "printer")
	assert_eq(place.counter.cash_out, 0, "not paid yet")
	await wait_until(func() -> bool: return boss.is_fixing(), 8.0)
	assert_true(boss.is_fixing(), "crouched over the mat")
	assert_false(boss.can_see(place.to_global(PawnShop.CASES[1] + Vector3.UP)), "his back to the shop")
	await wait_seconds(3.5)
	assert_false(boss.is_fixing(), "back to his round")
	assert_eq(place.counter.cash_out, PawnCounter.LEAST, "paid when done")
	assert_true(place.counter.for_sale.has(item))


func test_appraisals_rest_and_the_third_gives_the_cops_away() -> void:
	var place := _shop()
	var appraisal := place.appraisal
	watch_signals(appraisal)
	assert_eq(appraisal.bring(), "slow")
	assert_eq(appraisal.bring(), "busy")
	appraisal.fix()
	assert_eq(appraisal.bring(), "quick", "resting: priced at a glance")
	appraisal.rest_left = 0.0
	assert_eq(appraisal.bring(), "slow")
	appraisal.fix()
	appraisal.rest_left = 0.0
	assert_eq(appraisal.bring(), "refused")
	assert_signal_emitted(appraisal, "caught_on")
	assert_eq(place.owner_boss.complaint, PawnShop.CAUGHT_ON)


func test_what_he_refuses_stays_on_the_counter() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	place.appraisal.count = Appraisal.CATCH_ON - 1
	var item := _thing(place)
	await wait_seconds(PawnCounter.TAKE_AFTER * 2 + 0.3)
	assert_false(place.counter.for_sale.has(item), "not bought")
	assert_eq(place.counter.cash_out, 0)
	assert_eq(place.owner_boss.complaint, PawnShop.CAUGHT_ON, "once")


func test_complaints_reach_him() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	place.customers[0].complain("PAWN_CUSTOMER_CRASH")
	assert_eq(place.owner_boss.complaint, PawnShop.CUSTOMER_COMPLAINT)
	place.customers[0].complain("PAWN_CUSTOMER_CRASH")
	assert_eq(place.owner_boss.complaint, PawnShop.CUSTOMER_COMPLAINT, "each one's cooldown")
	place.goods[0].global_position = place.to_global(Vector3(0, 0.5, PawnShop.HALF_Z + 2.0))
	await wait_physics_frames(3)
	assert_eq(place.owner_boss.complaint, PawnShop.CUSTOMER_COMPLAINT + PawnShop.TAKEN_COMPLAINT, "taken unpaid")
	for key: String in ["REGATEO_LINE_1", "REGATEO_PRINTER", "REGATEO_FIX_3", "REGATEO_FIX_DONE", "REGATEO_HURT",
			"REGATEO_DOOR", "REGATEO_SAW", "REGATEO_NOTHING", "REGATEO_OFFENDED", "REGATEO_LAWYER", "REGATEO_CAUGHT_ON",
			"REGATEO_CUSTOMER", "REGATEO_TAKEN", "REGATEO_CASE", "REGATEO_ARMOR"]:
		assert_ne(tr(key), key, key)
