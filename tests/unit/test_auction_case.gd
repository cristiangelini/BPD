extends GutTest

## The auction's case (infiltracion-subasta.md, step 5, decision 177): the infiltration case with the house's texts, 3
## of its 6 pieces of evidence by the seed (the stolen original behind its copy in the storeroom, the catalogue with the
## real prices, the forger's half-painted copy, two buyers' talk to record, the lot stolen from a museum the cops have
## to buy and the sales book in the locked office, whose key is under the gavel), what the cops bought coming out of
## the pay and Don Martillo to cuff.

const LEVEL := preload("res://scenes/levels/auction_house.tscn")

var house: AuctionHouse
var cop: Cop


## A house whose seed has the evidence `kind`.
func _house_with(kind: String) -> void:
	var case_seed := 1
	while true:
		house = LEVEL.instantiate()
		house.case_seed = case_seed
		house.get_node("Cop").input_enabled = false
		add_child_autofree(house)
		if house.evidence.kinds.has(kind):
			break
		house.free()
		case_seed += 1
	cop = house.get_node("Cop")
	await wait_physics_frames(2)
	house.sale.set_physics_process(false)
	house.suspicion.set_physics_process(false)
	house.case.give_tip()


## Solving it leaves Don Martillo in custody for the next shift's draw (RaidCase): not for the next test's.
func after_each() -> void:
	PlaceDraw.custody = {}


func test_the_auction_case_with_its_own_texts() -> void:
	await _house_with("original")
	assert_eq(house.case.place, house)
	assert_eq(house.case.texts(), InfiltrationCase.VARIANTS["auction"])
	assert_eq(house.case.rows()[0].text, "OBJ_AUCTION_GET_IN")
	assert_eq(house.evidence.kinds.size(), ClubEvidence.COUNT)
	for kind: String in house.evidence.kinds:
		assert_has(AuctionHouse.EVIDENCE_KINDS, kind)


func test_grabbing_the_original_in_the_storeroom() -> void:
	await _house_with("original")
	var original: Grabbable = house.evidence.items["original"]
	assert_true(house.in_storeroom(original.global_position))
	assert_gt(original.mass, 5.0, "big and heavy")
	cop.global_position = original.global_position + Vector3(0, -0.05, 1.0)
	cop.get_node("Grabber").grab(original)
	await wait_physics_frames(2)
	assert_has(house.case.evidence_found, "original")


func test_the_office_key_is_under_the_gavel() -> void:
	await _house_with("original")
	var key: KeyPot = house.get_node("KeyPodium")
	assert_true(house.in_hall(key.global_position))
	assert_lt(Vector2(key.position.x - AuctionHouse.PODIUM_AT.x, key.position.z - AuctionHouse.PODIUM_AT.z).length(),
		1.0, "on the podium")
	assert_eq(key.prompt_key(cop), "PROMPT_AUCTION_PODIUM_KEY")
	assert_true(house.office_door.locked)
	key.use(cop)
	assert_true(cop.has_key)


func test_photographing_the_catalog_and_the_forgery() -> void:
	await _house_with("catalog")
	var catalog: ClubEvidenceSpot = house.get_node("Evidence_catalog")
	assert_true(house.in_hall(catalog.global_position))
	catalog.use(cop)
	assert_false(house.case.evidence_found.has("catalog"), "E isn't a photo")
	catalog.photographed(cop)
	assert_has(house.case.evidence_found, "catalog")
	await _house_with("forgery")
	var forgery: ClubEvidenceSpot = house.get_node("Evidence_forgery")
	assert_true(house.in_storeroom(forgery.global_position), "in the forger's corner")
	forgery.photographed(cop)
	assert_has(house.case.evidence_found, "forgery")


func test_searching_the_office_desk() -> void:
	await _house_with("ledger")
	var desk: ClubEvidenceSpot = house.get_node("Evidence_ledger")
	assert_true(house.in_back_room(desk.global_position), "in Don Martillo's office")
	desk.use(cop)
	assert_has(house.case.evidence_found, "ledger")


func test_the_recording_pair_stands_by_each_other() -> void:
	await _house_with("recording")
	assert_eq(house.evidence.talkers.size(), 2)
	for talker in house.evidence.talkers:
		assert_ne(talker, house.martillo)
		assert_true(talker.distracted, "busy talking")
	var apart := house.evidence.talkers[0].global_position.distance_to(house.evidence.talkers[1].global_position)
	assert_lt(apart, ClubEvidence.RECORD_REACH * 2, "a cop can stand by both")


func test_buying_the_stolen_lot_is_evidence() -> void:
	await _house_with("lot")
	var sale := house.sale
	assert_has(LotEasel.KINDS, sale.stolen)
	while sale.kind != sale.stolen:
		sale._end()
		sale.open()
	var whispered := house.members.any(func(member: ClubMember) -> bool:
		return member.said() == "AUCTION_STOLEN_" + sale.stolen)
	assert_true(whispered, "a buyer whispers it")
	for member in sale.tops.keys():
		sale.tops[member] = 0
	for seat in house.seats:
		if not sale.taken(seat):
			cop.global_position = seat.global_position + Vector3(0.6, 0.1, 0)
			seat.use(cop)
			break
	for i in int(AuctionSale.HAMMER * 10) + 2:
		sale._physics_process(0.1)
	assert_eq(sale.bought, 1)
	assert_has(house.case.evidence_found, "lot")


func test_a_lot_that_is_not_the_stolen_one_is_not_evidence() -> void:
	await _house_with("lot")
	var sale := house.sale
	sale.open()
	while sale.kind == sale.stolen:
		sale._end()
		sale.open()
	sale._sell()
	assert_false(house.case.evidence_found.has("lot"))


func test_without_the_lot_among_the_evidence_nothing_is_stolen() -> void:
	await _house_with("original")
	if house.evidence.kinds.has("lot"):
		pass_test("this seed has it")
		return
	assert_eq(house.sale.stolen, "")


func test_what_they_bought_comes_out_of_the_pay() -> void:
	await _house_with("original")
	for kind: String in house.evidence.kinds:
		house.case.found(kind)
	house.sale.bought = 2
	house.sale.spent = 250
	house.martillo.cuffed(20.0)
	assert_true(house.case.solved())
	var pay: Dictionary = house.case.report()
	assert_eq(pay.salary, InfiltrationCase.SALARY)
	assert_eq(pay.fines, 250)
	assert_eq(pay.total, InfiltrationCase.SALARY - 250)
	assert_eq(pay.approved, pay.total >= InfiltrationCase.QUOTA)
	assert_eq(house.bought(), 2)


func test_cuffing_don_martillo_solves_it() -> void:
	await _house_with("original")
	for kind: String in house.evidence.kinds.slice(0, 2):
		house.case.found(kind)
	house.martillo.cuffed(20.0)
	assert_true(house.case.solved())
	assert_eq(house.case.report().salary, InfiltrationCase.SALARY * 2 / 3)
	assert_eq(house.case.report().fines, 0, "they bought nothing")
	assert_eq(house.case.custody().owner, "martillo")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_martillo"))
	assert_true(ChaseSuspect.MODELS.has("martillo"))


func test_cuffing_a_buyer_gives_them_away() -> void:
	await _house_with("original")
	house.members[0].cuffed(5.0)
	assert_true(house.suspicion.found_out)


func test_the_case_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["HINT_GO_AUCTION", "HINT_AUCTION_IN", "HINT_MARTILLO_CUFFED", "HINT_ESCAPE_martillo",
		"OBJ_AUCTION_GET_IN", "OBJ_AUCTION_EVIDENCE", "OBJ_AUCTION_CUFF_MARTILLO", "OBJ_AUCTION_CATCH_MARTILLO",
		"OBJ_AUCTION_CAREFUL", "OBJ_AUCTION_FOUND_OUT", "PROMPT_AUCTION_PODIUM_KEY", "PROMPT_AUCTION_catalog",
		"PROMPT_AUCTION_forgery", "PROMPT_AUCTION_ledger", "CRIME_owner_martillo", "CONFESS_owner_martillo",
		"SHIFT_FINES_AUCTION"]
	keys.append_array(InfiltrationCase.VARIANTS["auction"].brief)
	for kind: String in AuctionHouse.EVIDENCE_KINDS:
		keys.append("EVIDENCE_AUCTION_" + kind)
	for kind: String in LotEasel.KINDS:
		keys.append("AUCTION_STOLEN_" + kind)
	for i in 4:
		keys.append("AUCTION_TALK_%d" % i)
	for i in 3:
		keys.append("MARTILLO_SLIP_%d" % (i + 1))
		keys.append("CHASE_MARTILLO_LINE_%d" % (i + 1))
	for key in keys:
		assert_ne(tr(key), key)
