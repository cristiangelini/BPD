extends GutTest

## The cinema raid online (allanamiento-cine.md, step 8): doña Bobina, Chicho and the spectators are run by the host
## and followed by the guests, the projector works from any PC and the film, the screen and the glass follow the
## host's, and a guest sitting beside Chicho hears him and gets his clue on the checklist.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const CINEMA := preload("res://scenes/levels/cinema.tscn")
const SEED := 5

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_cinema)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_cinema() -> Node3D:
	var cinema: Cinema = CINEMA.instantiate()
	cinema.case_seed = SEED
	cinema.story_id = "pirate_copies"
	return cinema


func test_bobina_chicho_and_the_spectators_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Cinema = OnlinePcs.level(pcs[0])
	var guest: Cinema = OnlinePcs.level(pcs[1])
	assert_false(guest.bobina.is_physics_processing(), "the guest's doña Bobina only follows")
	assert_false(guest.chicho.is_physics_processing(), "and so does Chicho")
	assert_eq(guest.spectators.size(), host.spectators.size(), "the same neighbors, the taper too")
	for spectator in guest.spectators:
		assert_false(spectator.is_physics_processing(), "and every spectator")
	host.bobina.complaint = 30.0
	host.spectators[0].say("CINEMA_SHUSH")
	await wait_until(func() -> bool: return absf(guest.bobina.complaint - 30.0) < 0.5 \
		and guest.spectators[0].said() == "CINEMA_SHUSH", 5.0)
	assert_almost_eq(guest.bobina.complaint, 30.0, 0.5)
	assert_eq(guest.spectators[0].said(), "CINEMA_SHUSH", "what they say too")


func test_a_guest_cuts_the_film_and_the_host_splices_it_for_everyone() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Cinema = OnlinePcs.level(pcs[0])
	var guest: Cinema = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.projector.button)
	await wait_until(func() -> bool: return host.projector.is_jammed, 5.0)
	assert_false(host.film_running, "the guest's cut reached the host")
	assert_false(guest.film_running)
	host.projector.fix()
	await wait_until(func() -> bool: return guest.film_running, 5.0)
	assert_true(guest.film_running, "spliced on the host, running on the guest")
	assert_false(guest.projector.is_jammed)
	assert_gt(guest.projector.rest_left, 0.0, "and resting there too")


func test_the_screen_and_the_glass_broken_on_the_host_break_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Cinema = OnlinePcs.level(pcs[0])
	var guest: Cinema = OnlinePcs.level(pcs[1])
	host.rip_screen()
	host.break_glass()
	await wait_until(func() -> bool: return guest.screen_torn and guest.glass_cracked, 5.0)
	assert_true(guest.screen_torn)
	assert_true(guest.glass_cracked)
	await wait_until(func() -> bool: return guest.raid.objective_facts().fines == host.raid.fines, 5.0)
	assert_eq(guest.raid.objective_facts().fines, Cinema.SCREEN_FINE + Cinema.GLASS_FINE, "fined once, by the host")


func test_a_guest_sits_beside_chicho_and_gets_his_clue() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Cinema = OnlinePcs.level(pcs[0])
	var guest: Cinema = OnlinePcs.level(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.act("use", guest.side_seat)
	await wait_until(func() -> bool: return host.side_seat.sitter != null, 5.0)
	assert_eq(guest_cop.seated_in, guest.side_seat, "seated on the guest's PC")
	await wait_until(func() -> bool: return host.chicho.has_told, CinemaUsher.SIT_SECONDS + 3.0)
	assert_true(host.chicho.has_told, "the host's Chicho tells")
	await wait_until(func() -> bool: return guest.raid.objective_facts().clues.has(host.chicho.clue), 5.0)
	assert_has(guest.raid.objective_facts().clues, host.chicho.clue, "and his clue is on the guest's checklist")
