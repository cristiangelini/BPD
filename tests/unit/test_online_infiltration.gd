extends GutTest

## The infiltration online (infiltracion.md, infiltracion-coro.md, infiltracion-mimos.md and infiltracion-fiesta.md, "Online"; docs/diseno/online.md): the host's
## case decides the evidence, the suspicion, the boss cuffed or running off and the end of shift, and every PC sees
## the same, disguises included.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const CLUB_SCENE := preload("res://scenes/levels/grandpa_club.tscn")
const CHOIR_SCENE := preload("res://scenes/levels/church_choir.tscn")
const MIME_SCENE := preload("res://scenes/levels/mime_theater.tscn")
const PARTY_SCENE := preload("res://scenes/levels/party_hall.tscn")
## A seed whose club has Doña Chela's bag among its evidence (ClubEvidence.draw).
const SEED := 2

var _pcs: OnlinePcs
var _scene: PackedScene = CLUB_SCENE
var _seed := SEED


func before_each() -> void:
	Campaign.current = null
	_scene = CLUB_SCENE
	_seed = SEED
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var place: InfiltrationPlace = _scene.instantiate()
		place.case_seed = _seed
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


func test_at_the_theater_found_out_pausa_runs_off_on_every_pc() -> void:
	_scene = MIME_SCENE
	var pcs := await _on()
	var host := _place(pcs[0])
	var guest := _place(pcs[1])
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_eq(guest.case.chase.suspect_id, SuspectCar.INVISIBLE_CAR, "in the invisible car")
	assert_false(guest.boss.visible, "Pausa is gone from the guest's theater")


func test_the_mime_rehearsal_reaches_the_guest() -> void:
	_scene = MIME_SCENE
	var pcs := await _on()
	var host := (_place(pcs[0]) as MimeTheater).rehearsal
	var guest := (_place(pcs[1]) as MimeTheater).rehearsal
	host.start_rehearsal()
	await wait_until(func() -> bool: return guest.is_rehearsal(), 5.0)
	assert_false(guest.statue, "mime first")
	host._switch(true)
	await wait_until(func() -> bool: return guest.statue, 5.0)
	assert_true(guest.statue, "the statue reaches the guest")
	assert_eq(_place(pcs[1]).members[1].sight_angle, ClubMember.SIGHT_ANGLE * MimeRehearsal.STATUE_SIGHT)


func test_a_guest_who_talks_near_a_mime_raises_the_hosts_suspicion() -> void:
	_scene = MIME_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as MimeTheater
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var mime := host.members[0]
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	guest_cop.global_position = _place(pcs[1]).global_transform * (mime.position + Vector3(0, 0.2, 3.0))
	await wait_until(func() -> bool: return copy.global_position.distance_to(mime.global_position) < 4.0, 5.0)
	pcs[1].voice.spoke(guest_cop)
	await wait_until(func() -> bool: return mime.suspicion > 0.0, 5.0)
	assert_gt(mime.suspicion, 0.0, "the host's mime heard the guest")


func test_at_the_party_found_out_the_trucho_runs_off_on_every_pc() -> void:
	_scene = PARTY_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as PartyHall
	var guest := _place(pcs[1]) as PartyHall
	host.photo.set_process(false)
	guest.photo.set_process(false)
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_eq(guest.case.chase.suspect_id, SuspectCar.PARTY_PATROL, "in the party patrol car")
	assert_false(guest.boss.visible, "the Trucho is gone from the guest's party")


func test_a_guest_talks_to_serpentina_and_seeing_the_boss_reaches_every_planilla() -> void:
	_scene = PARTY_SCENE
	_seed = 1
	while not _hostess_seed(_seed):
		_seed += 1
	var pcs := await _on()
	var host := _place(pcs[0]) as PartyHall
	var guest := _place(pcs[1]) as PartyHall
	for hall: PartyHall in [host, guest]:
		hall.photo.set_process(false)
		for member: ClubMember in hall.members:
			member.position = Vector3(6.0, PartyHall.FLOOR_TOP, 0)
	OnlinePcs.own_cop(pcs[1]).act("use", guest.serpentina)
	await wait_until(func() -> bool: return guest.case.evidence_found.has("hostess"), 5.0)
	assert_has(host.case.evidence_found, "hostess", "the host counted it")
	host.photo.boss_seen.emit(OnlinePcs.own_cop(pcs[0]))
	await wait_until(func() -> bool: return guest.case.bonus_clue, 5.0)
	assert_true(guest.case.bonus_clue, "the extra clue reaches the guest's planilla")


## Whether the party with `case_seed` has Serpentina among its clues.
func _hostess_seed(case_seed: int) -> bool:
	var hall: PartyHall = PARTY_SCENE.instantiate()
	hall.case_seed = case_seed
	hall.get_node("Cop").input_enabled = false
	add_child(hall)
	var has := hall.evidence.kinds.has("hostess")
	hall.free()
	return has

