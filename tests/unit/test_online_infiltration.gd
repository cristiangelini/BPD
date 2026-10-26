extends GutTest

## The infiltration online (infiltracion.md, infiltracion-coro.md, infiltracion-mimos.md, infiltracion-fiesta.md, infiltracion-gimnasio.md, infiltracion-escuela.md, infiltracion-restaurante.md, infiltracion-ajedrez.md, infiltracion-motos.md and infiltracion-subasta.md, "Online"; docs/diseno/online.md): the host's
## case decides the evidence, the suspicion, the boss cuffed or running off and the end of shift, and every PC sees
## the same, disguises included.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const CLUB_SCENE := preload("res://scenes/levels/grandpa_club.tscn")
const CHOIR_SCENE := preload("res://scenes/levels/church_choir.tscn")
const MIME_SCENE := preload("res://scenes/levels/mime_theater.tscn")
const PARTY_SCENE := preload("res://scenes/levels/party_hall.tscn")
const GYM_SCENE := preload("res://scenes/levels/gym_hall.tscn")
const SCHOOL_SCENE := preload("res://scenes/levels/school_hall.tscn")
const RESTAURANT_SCENE := preload("res://scenes/levels/restaurant_hall.tscn")
const CHESS_SCENE := preload("res://scenes/levels/chess_club.tscn")
const BIKER_SCENE := preload("res://scenes/levels/biker_bar.tscn")
const AUCTION_SCENE := preload("res://scenes/levels/auction_house.tscn")
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
	# The chase and the meter come in different packets: wait for both.
	await wait_until(func() -> bool: return guest.case.chase != null and guest.suspicion.found_out, 5.0)
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
	# The host does it first and then tells the guest: one more trip.
	await wait_until(func() -> bool: return guest_card.claimed, 5.0)
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


func test_at_the_gym_found_out_el_toro_jogs_off_on_every_pc() -> void:
	_scene = GYM_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as GymHall
	var guest := _place(pcs[1]) as GymHall
	host.routine.set_process(false)
	guest.routine.set_process(false)
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_eq(guest.case.chase.suspect_id, SuspectCar.TORO_JOG, "jogging")
	assert_false(guest.boss.visible, "el Toro is gone from the guest's gym")


func test_the_routine_reaches_the_guest_and_a_guest_slacking_reaches_the_host() -> void:
	_scene = GYM_SCENE
	var pcs := await _on()
	var host := (_place(pcs[0]) as GymHall).routine
	var guest := (_place(pcs[1]) as GymHall).routine
	host.start_routine("weight")
	await wait_until(func() -> bool: return guest.is_routine(), 5.0)
	assert_eq(guest.exercise, "weight", "the same exercise")
	watch_signals(host)
	guest._report(OnlinePcs.own_cop(pcs[1]), GymRoutine.GAVE_UP)
	await wait_until(func() -> bool: return get_signal_emit_count(host, "missed") > 0, 5.0)
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	assert_signal_emitted_with_parameters(host, "missed", [copy, GymRoutine.GAVE_UP])


func test_at_the_school_found_out_the_director_drives_off_on_every_pc() -> void:
	_scene = SCHOOL_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as SchoolHall
	var guest := _place(pcs[1]) as SchoolHall
	host.classes.set_process(false)
	guest.classes.set_process(false)
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_eq(guest.case.chase.suspect_id, SuspectCar.LEARNER_CAR, "in the learner car")


func test_a_guests_grade_reaches_the_host_and_the_graduation_every_pc() -> void:
	_scene = SCHOOL_SCENE
	var pcs := await _on()
	var host := (_place(pcs[0]) as SchoolHall).classes
	var guest_school := _place(pcs[1]) as SchoolHall
	var guest := guest_school.classes
	host.start_class("lockpick")
	await wait_until(func() -> bool: return guest.in_class(), 5.0)
	assert_eq(guest.subject, "lockpick", "the same class")
	guest._graded.rpc_id(guest._net().HOST_ID, "lockpick", 9)
	await wait_until(func() -> bool: return host.average("lockpick") > 0.0, 5.0)
	assert_eq(host.average("lockpick"), 9.0, "the host keeps the guest's grade")
	await wait_until(func() -> bool: return guest.average("lockpick") > 0.0, 5.0)
	assert_eq(guest.average("lockpick"), 9.0, "and the guest's report card shows it")
	host.start_graduation()
	await wait_until(func() -> bool: return guest.graduated, 5.0)
	assert_true(guest_school.director.visible, "the Director came down on the guest's PC too")


func test_at_the_restaurant_found_out_the_chef_rides_off_on_every_pc() -> void:
	_scene = RESTAURANT_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as RestaurantHall
	var guest := _place(pcs[1]) as RestaurantHall
	host.orders.set_process(false)
	guest.orders.set_process(false)
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_eq(guest.case.chase.suspect_id, SuspectCar.PIZZA_SCOOTER, "on the delivery scooter")


func test_the_chefs_orders_and_special_soup_reach_the_guest() -> void:
	_scene = RESTAURANT_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as RestaurantHall
	var guest := _place(pcs[1]) as RestaurantHall
	host.orders.set_process(false)
	guest.orders.set_process(false)
	host.orders.order("soup")
	await wait_until(func() -> bool: return not guest.orders.orders.is_empty(), 5.0)
	assert_eq(guest.orders.orders[0].dish, "soup", "the same order on the guest's rail")
	host.orders.start_special()
	await wait_until(func() -> bool: return guest.orders.special_on, 5.0)
	assert_true(guest.special_soup.visible, "the special soup on the guest's pass")


func test_at_the_chess_club_found_out_alfil_rides_off_on_every_pc() -> void:
	_scene = CHESS_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as ChessClub
	var guest := _place(pcs[1]) as ChessClub
	host.games.set_physics_process(false)
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_eq(guest.case.chase.suspect_id, SuspectCar.CAROUSEL_HORSE, "on the carousel horse")


func test_a_chess_challenge_and_the_clock_reach_the_guest() -> void:
	_scene = CHESS_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as ChessClub
	var guest := _place(pcs[1]) as ChessClub
	host.games.set_physics_process(false)
	assert_true(host.games.challenge(OnlinePcs.own_cop(pcs[1])))
	var who := host.members.find(host.games.challenger)
	await wait_until(func() -> bool: return guest.members[who].said() == "CHESS_CHALLENGE", 5.0)
	assert_eq(guest.members[who].said(), "CHESS_CHALLENGE", "the same member challenges on the guest's PC")
	var table := host.games.table
	host.clocks[table].start(ChessClock.BLACK)
	await wait_until(func() -> bool: return guest.clocks[table].turn == ChessClock.BLACK, 5.0)
	assert_eq(guest.clocks[table].turn, ChessClock.BLACK, "the guest's clock runs the same side")
	OnlinePcs.own_cop(pcs[1]).act("use", guest.clocks[table])
	await wait_until(func() -> bool: return host.clocks[table].turn == ChessClock.WHITE, 5.0)
	assert_eq(host.clocks[table].turn, ChessClock.WHITE, "the guest hit the clock on the host")
	await wait_until(func() -> bool: return guest.clocks[table].turn == ChessClock.WHITE, 5.0)
	assert_eq(guest.clocks[table].turn, ChessClock.WHITE)


func test_at_the_biker_bar_found_out_el_cromado_rides_off_on_every_pc() -> void:
	_scene = BIKER_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as BikerBar
	var guest := _place(pcs[1]) as BikerBar
	host.dares.set_physics_process(false)
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_eq(guest.case.chase.suspect_id, SuspectCar.CHOPPER_MOPED, "on the moped")


func test_a_courage_dare_reaches_the_guest() -> void:
	_scene = BIKER_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as BikerBar
	var guest := _place(pcs[1]) as BikerBar
	host.dares.order.assign(["arm", "lift", "still"])
	var guest_cop_on_host: Cop
	for one: Node in host.get_tree().get_nodes_in_group("cops"):
		if one != OnlinePcs.own_cop(pcs[0]) and host.is_ancestor_of(one):
			guest_cop_on_host = one
	assert_not_null(guest_cop_on_host, "the guest's cop on the host's PC")
	assert_true(host.dares.challenge(guest_cop_on_host))
	var who := host.members.find(host.dares.challenger)
	await wait_until(func() -> bool: return guest.members[who].said() == "BIKER_DARE_arm", 5.0)
	assert_eq(guest.members[who].said(), "BIKER_DARE_arm", "the same biker dares on the guest's PC")
	host.dares.set_physics_process(false)
	host.dares._start()
	await wait_until(func() -> bool: return guest.arm_table.is_wrestling(), 5.0)
	assert_true(guest.arm_table.is_wrestling(), "the arms on the guest's table")
	host.dares.pushes = BikerDares.ARM_PUSHES - 1
	OnlinePcs.own_cop(pcs[1]).act("use", guest.arm_table)
	await wait_until(func() -> bool: return not guest.arm_table.is_wrestling(), 5.0)
	assert_false(guest.arm_table.is_wrestling(), "the guest's push won it on the host")
	assert_eq(guest.members[who].said(), host.dares.tip(), "and the biker's gossip reached the guest")



func test_at_the_auction_found_out_don_martillo_drives_off_on_every_pc() -> void:
	_scene = AUCTION_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as AuctionHouse
	var guest := _place(pcs[1]) as AuctionHouse
	host.sale.set_physics_process(false)
	host.suspicion.raise(host.members[0], 100.0)
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_eq(guest.case.chase.suspect_id, SuspectCar.GALLERY_CART, "in the gallery cart")


func test_a_guests_bid_wins_a_lot_on_every_pc() -> void:
	_scene = AUCTION_SCENE
	var pcs := await _on()
	var host := _place(pcs[0]) as AuctionHouse
	var guest := _place(pcs[1]) as AuctionHouse
	host.sale.set_physics_process(false)
	host.sale.open()
	for member in host.sale.tops.keys():
		host.sale.tops[member] = 0
	await wait_until(func() -> bool: return guest.easel.lot == host.sale.kind, 5.0)
	assert_eq(guest.easel.lot, host.sale.kind, "the lot on the guest's easel")
	assert_eq(guest.martillo.said(), "AUCTION_LOT_" + host.sale.kind, "Don Martillo announces it on the guest's PC")
	var guest_cop_on_host: Cop
	for one: Node in host.get_tree().get_nodes_in_group("cops"):
		if one != OnlinePcs.own_cop(pcs[0]) and host.is_ancestor_of(one):
			guest_cop_on_host = one
	var seat: BidSeat
	for one in host.seats:
		if not host.sale.taken(one):
			seat = one
			break
	var guest_seat := guest.seats[host.seats.find(seat)]
	OnlinePcs.own_cop(pcs[1]).global_position = guest_seat.global_position + Vector3(0.6, 0.1, 0)
	await wait_until(func() -> bool: return guest_cop_on_host.global_position.distance_to(seat.global_position) < 1.0,
		5.0)
	OnlinePcs.own_cop(pcs[1]).act("use", guest_seat)
	await wait_until(func() -> bool: return host.sale.last_bidder == guest_cop_on_host, 5.0)
	assert_eq(host.sale.last_bidder, guest_cop_on_host, "the guest's bid counts on the host")
	await wait_until(func() -> bool: return guest_seat.is_raised(), 5.0)
	assert_true(guest_seat.is_raised(), "his paddle up on the guest's PC")
	assert_eq(guest.podium.price, AuctionSale.START)
	host.sale._sell()
	await wait_until(func() -> bool: return guest.podium.bangs == 1, 5.0)
	assert_eq(guest.podium.bangs, 1, "the gavel on the guest's PC")
	var bought_lot := func() -> BoughtLot:
		for child in guest.get_children():
			if child is BoughtLot:
				return child
		return null
	await wait_until(func() -> bool: return bought_lot.call() != null, 5.0)
	var lot := bought_lot.call() as BoughtLot
	assert_not_null(lot, "the lot by the chair on the guest's PC")
	if lot:
		assert_eq(lot.kind, host.sale.lots[0].kind)
	assert_eq(guest.easel.lot, "", "off the easel")

## Whether the party with `case_seed` has Serpentina among its clues.
func _hostess_seed(case_seed: int) -> bool:
	var hall: PartyHall = PARTY_SCENE.instantiate()
	hall.case_seed = case_seed
	hall.get_node("Cop").input_enabled = false
	add_child(hall)
	var has := hall.evidence.kinds.has("hostess")
	hall.free()
	return has

