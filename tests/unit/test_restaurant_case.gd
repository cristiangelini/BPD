extends GutTest

## The restaurant's case (infiltracion-restaurante.md, step 5, decision 174): the infiltration case with the
## restaurant's texts, 3 of its 6 pieces of evidence by the seed (the ledger under the cash register, the ring in the
## Chef's special soup, the pot with the necklaces in the walk-in fridge, the cooks' video, the menu in carats and the
## jeweller's receipt in the locked office, whose key is in the apron hanging in the fridge) and the Chef to cuff.

const LEVEL := preload("res://scenes/levels/restaurant_hall.tscn")

var hall: RestaurantHall
var cop: Cop


## A restaurant whose seed has the evidence `kind`.
func _restaurant_with(kind: String) -> void:
	var case_seed := 1
	while true:
		hall = LEVEL.instantiate()
		hall.case_seed = case_seed
		hall.get_node("Cop").input_enabled = false
		add_child_autofree(hall)
		if hall.evidence.kinds.has(kind):
			break
		hall.free()
		case_seed += 1
	cop = hall.get_node("Cop")
	await wait_physics_frames(2)
	hall.orders.set_process(false)
	hall.case.give_tip()


func test_the_restaurant_case_with_its_own_texts() -> void:
	await _restaurant_with("ledger")
	assert_eq(hall.case.place, hall)
	assert_eq(hall.case.texts(), InfiltrationCase.VARIANTS["restaurant"])
	assert_eq(hall.case.rows()[0].text, "OBJ_RESTAURANT_GET_IN")
	assert_eq(hall.evidence.kinds.size(), ClubEvidence.COUNT)
	for kind: String in hall.evidence.kinds:
		assert_has(RestaurantHall.EVIDENCE_KINDS, kind)


func test_grabbing_the_ledger_under_the_cash_register() -> void:
	await _restaurant_with("ledger")
	var ledger: Grabbable = hall.evidence.items["ledger"]
	assert_true(hall.in_dining(ledger.global_position))
	cop.global_position = ledger.global_position + Vector3(0, -0.8, 1.0)
	cop.get_node("Grabber").grab(ledger)
	await wait_physics_frames(2)
	assert_has(hall.case.evidence_found, "ledger")


func test_grabbing_the_pot_with_the_necklaces_in_the_fridge() -> void:
	await _restaurant_with("pot")
	var pot: Grabbable = hall.evidence.items["pot"]
	assert_true(hall.in_fridge(pot.global_position))
	cop.global_position = pot.global_position + Vector3(0, -0.2, 1.0)
	cop.get_node("Grabber").grab(pot)
	await wait_physics_frames(2)
	assert_has(hall.case.evidence_found, "pot")


func test_the_office_key_is_in_the_hanging_apron() -> void:
	await _restaurant_with("ledger")
	var apron: KeyPot = hall.get_node("KeyApron")
	assert_true(hall.in_fridge(apron.global_position))
	assert_eq(apron.prompt_key(cop), "PROMPT_RESTAURANT_APRON")
	assert_true(hall.office_door.locked)
	apron.use(cop)
	assert_true(cop.has_key)


func test_photographing_the_menu_and_searching_the_desk() -> void:
	await _restaurant_with("menu")
	var menu: ClubEvidenceSpot = hall.get_node("Evidence_menu")
	assert_true(hall.in_dining(menu.global_position))
	menu.use(cop)
	assert_false(hall.case.evidence_found.has("menu"), "E isn't a photo")
	menu.photographed(cop)
	assert_has(hall.case.evidence_found, "menu")
	await _restaurant_with("receipt")
	var desk: ClubEvidenceSpot = hall.get_node("Evidence_receipt")
	assert_true(hall.in_back_room(desk.global_position), "in the Chef's office")
	desk.use(cop)
	assert_has(hall.case.evidence_found, "receipt")


func test_the_ring_is_only_there_with_the_special_soup() -> void:
	await _restaurant_with("ring")
	var spot: ClubEvidenceSpot = hall.get_node("Evidence_ring")
	assert_true(hall.orders.specials)
	assert_false(hall.special_soup.visible)
	assert_eq(spot.collision_layer, 0, "nothing to photograph yet")
	hall.orders.start_special()
	assert_true(hall.special_soup.visible)
	assert_eq(spot.collision_layer, 1)
	assert_eq(hall.chef.said(), "FLAMBE_SPECIAL")
	spot.photographed(cop)
	assert_has(hall.case.evidence_found, "ring")


func test_every_third_order_is_the_special_soup() -> void:
	await _restaurant_with("ring")
	hall.orders.order()
	hall.orders.order()
	assert_false(hall.orders.special_on)
	hall.orders.order()
	assert_true(hall.orders.special_on, "the third one is the Chef's")
	assert_eq(hall.orders.orders.size(), 2, "not on the rail: the Chef makes it himself")
	hall.orders.set_process(true)
	hall.orders.special_left = 0.01
	await wait_process_frames(2)
	assert_false(hall.orders.special_on, "a waiter took it")
	assert_false(hall.special_soup.visible)
	assert_eq(hall.chef.said(), "FLAMBE_SPECIAL_OUT")


func test_no_special_soup_without_the_ring() -> void:
	await _restaurant_with("menu")
	if hall.evidence.kinds.has("ring"):
		return
	for i in 3:
		hall.orders.order()
	assert_false(hall.orders.special_on)
	assert_eq(hall.orders.orders.size(), 3)


func test_the_recording_cooks_stand_by_each_other() -> void:
	await _restaurant_with("recording")
	assert_eq(hall.evidence.talkers.size(), 2)
	for talker in hall.evidence.talkers:
		assert_true(talker.look.begins_with("cocin"))
	var apart := hall.evidence.talkers[0].global_position.distance_to(hall.evidence.talkers[1].global_position)
	assert_lt(apart, ClubEvidence.RECORD_REACH * 2, "a cop can stand by both")


func test_cuffing_the_chef_solves_it() -> void:
	await _restaurant_with("ledger")
	for kind: String in hall.evidence.kinds.slice(0, 2):
		hall.case.found(kind)
	hall.chef.cuffed(20.0)
	assert_true(hall.case.solved())
	assert_eq(hall.case.report().salary, InfiltrationCase.SALARY * 2 / 3)
	assert_eq(hall.case.custody().owner, "flambe")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_flambe"))
	assert_true(ChaseSuspect.MODELS.has("flambe"))


func test_cuffing_a_cook_gives_them_away() -> void:
	await _restaurant_with("ledger")
	hall.members[0].cuffed(5.0)
	assert_true(hall.suspicion.found_out)


func test_the_case_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["HINT_GO_RESTAURANT", "HINT_RESTAURANT_IN", "HINT_FLAMBE_CUFFED", "HINT_ESCAPE_flambe",
		"OBJ_RESTAURANT_GET_IN", "OBJ_RESTAURANT_EVIDENCE", "OBJ_RESTAURANT_CUFF_FLAMBE", "OBJ_RESTAURANT_CATCH_FLAMBE",
		"OBJ_RESTAURANT_CAREFUL", "OBJ_RESTAURANT_FOUND_OUT", "PROMPT_RESTAURANT_APRON", "PROMPT_RESTAURANT_ring",
		"PROMPT_RESTAURANT_menu", "PROMPT_RESTAURANT_receipt", "CRIME_owner_flambe", "CONFESS_owner_flambe",
		"FLAMBE_SPECIAL", "FLAMBE_SPECIAL_OUT"]
	keys.append_array(InfiltrationCase.VARIANTS["restaurant"].brief)
	for kind: String in RestaurantHall.EVIDENCE_KINDS:
		keys.append("EVIDENCE_RESTAURANT_" + kind)
	for i in 4:
		keys.append("RESTAURANT_TALK_%d" % i)
	for i in 3:
		keys.append("FLAMBE_SLIP_%d" % (i + 1))
		keys.append("CHASE_FLAMBE_LINE_%d" % (i + 1))
	for key in keys:
		assert_ne(tr(key), key)
