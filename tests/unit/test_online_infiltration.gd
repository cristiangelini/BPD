extends GutTest

## The infiltration online (infiltracion.md and infiltracion-coro.md, "Online"; docs/diseno/online.md): the host's
## case decides the evidence, the suspicion, the boss cuffed or running off and the end of shift, and every PC sees
## the same, disguises included.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const CLUB_SCENE := preload("res://scenes/levels/grandpa_club.tscn")
const CHOIR_SCENE := preload("res://scenes/levels/church_choir.tscn")
## A seed whose club has Doña Chela's bag among its evidence (ClubEvidence.draw).
const SEED := 2

var _pcs: OnlinePcs
var _scene: PackedScene = CLUB_SCENE


func before_each() -> void:
	Campaign.current = null
	_scene = CLUB_SCENE
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var place: InfiltrationPlace = _scene.instantiate()
		place.case_seed = SEED
		place.get_node("Cop/Grabber").input_enabled = false
		return place)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _place(net: Node) -> InfiltrationPlace:
	return OnlinePcs.level(net) as InfiltrationPlace


func _case(net: Node) -> InfiltrationCase:
	return _place(net).case


## Host and guest with the case given.
func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	_case(pcs[0]).give_tip()
	await wait_until(func() -> bool: return _case(pcs[1]).tip_given, 5.0)
	return pcs


func test_a_guest_searches_the_bag_and_the_host_counts_it() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	assert_true(guest.follower)
	assert_true(_place(pcs[0]).evidence.kinds.has("bag"))
	var bag := _place(pcs[1]).get_node("Evidence_bag") as ClubEvidenceSpot
	assert_false(guest.found("bag"), "a guest's case doesn't count on its own")
	OnlinePcs.own_cop(pcs[1]).act("use", bag)
	await wait_until(func() -> bool: return host.evidence_found.has("bag"), 5.0)
	await wait_until(func() -> bool: return guest.evidence_found.has("bag"), 5.0)
	assert_eq(guest.evidence_found, host.evidence_found, "the guest's planilla shows it")


func test_a_disguise_shows_on_every_pc() -> void:
	var pcs := await _on()
	var cop := OnlinePcs.own_cop(pcs[0])
	var piece: DisguisePiece = DisguisePiece.scene_of("wig").instantiate()
	_place(pcs[0]).add_child(piece)
	piece.global_position = DisguisePiece.slot_on(cop, "wig")
	piece.hold(cop.get_node("Grabber").get_instance_id(), piece.global_position)
	var copy: Cop = pcs[1].cop_syncs[pcs[0].multiplayer.get_unique_id()].cop
	await wait_until(func() -> bool: return copy.disguise.has("wig"), 5.0)
	assert_true(cop.disguise.has("wig"), "the host's cop wears it")
	assert_true(copy.disguise.has("wig"), "and the guest sees it on him")


func test_the_suspicion_and_being_found_out_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _place(pcs[0])
	var guest := _place(pcs[1])
	host.suspicion.raise(host.members[0], 40.0)
	# It calms down on the host as time goes by: the guest's follows it.
	await wait_until(func() -> bool: return guest.members[0].suspicion > 30.0, 5.0)
	assert_almost_eq(guest.suspicion.highest(), host.suspicion.highest(), 2.0, "the guest's meter shows it")
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_true(guest.suspicion.found_out)
	assert_true(guest.case.chase.follower, "the guest's chase only follows")
	assert_false(guest.boss.visible, "Doña Chela is gone from the guest's club")
	assert_eq(guest.case.chase.suspect_id, SuspectCar.WALKER)


func test_cuffing_the_boss_ends_it_on_every_pc() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.found("bag")
	_place(pcs[0]).boss.cuffed_now.emit(OnlinePcs.own_cop(pcs[0]))
	await wait_until(func() -> bool: return guest.boss_cuffed, 5.0)
	await wait_until(func() -> bool: return guest.shift_over, InfiltrationCase.SHIFT_DELAY + 5.0)
	assert_true(host.shift_over)
	assert_eq(guest.shift_screen.get_node("%CaseResult").text, host.shift_screen.get_node("%CaseResult").text,
		"the same end of shift")
	assert_false(guest.shift_screen.get_node("%AgainButton").visible, "only the host starts the next one")


func test_at_the_choir_found_out_ernesto_drives_off_on_every_pc() -> void:
	_scene = CHOIR_SCENE
	var pcs := await _on()
	var host := _place(pcs[0])
	var guest := _place(pcs[1])
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_eq(guest.case.chase.suspect_id, SuspectCar.CHOIR_VAN, "in the choir van")
	host.case.chase.fail("CASE_FAILED_TIME")
	await wait_until(func() -> bool: return guest.case.escaped, 5.0)
	assert_true(guest.case.escaped, "and gets away on the guest too")


func test_a_guest_takes_a_bingo_card_on_every_pc() -> void:
	var pcs := await _on()
	var host_card: ClubBingoCard = (_place(pcs[0]) as GrandpaClub).bingo.cards[0]
	var guest_card: ClubBingoCard = (_place(pcs[1]) as GrandpaClub).bingo.cards[0]
	OnlinePcs.own_cop(pcs[1]).act("use", guest_card)
	await wait_until(func() -> bool: return host_card.claimed, 5.0)
	assert_true(host_card.claimed, "the host's card is taken")
	assert_true(guest_card.claimed)
