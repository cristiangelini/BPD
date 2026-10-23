extends GutTest

## The politician's rally online (proteccion-politico.md; docs/diseno/online.md): the host's rally decides the speech,
## the throws, the stains, the hecklers and the deputy's walks, and every PC sees the same.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const RALLY_SCENE := preload("res://scenes/levels/plaza_rally.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var rally: PlazaRally = RALLY_SCENE.instantiate()
		rally.case_seed = SEED
		rally.get_node("Cop/Grabber").input_enabled = false
		return rally)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _rally(net: Node) -> PlazaRally:
	return OnlinePcs.level(net) as PlazaRally


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _rally(pcs[1])
	assert_true(guest.case.follower)
	assert_true(guest.speech.follower, "the guest's speech only shows the host's")
	assert_false(guest.crowd.is_physics_processing(), "only the host's hecklers throw")


func test_the_speech_runs_on_the_host_clock() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _rally(pcs[0])
	var guest := _rally(pcs[1])
	host.speech.start()
	host.speech.left = 200.0
	await wait_until(func() -> bool: return guest.speech.speaking, 5.0)
	assert_almost_eq(guest.speech.left, host.speech.left, 2.0)


func test_a_stain_shows_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _rally(pcs[0])
	var guest := _rally(pcs[1])
	host.politician.stain("tomato", host.politician.global_position + Vector3(0.2, 1.2, 0.4))
	await wait_until(func() -> bool: return guest.politician.stains == 1, 5.0)
	assert_not_null(guest.politician.get_node_or_null("Stain1"), "in the same place on the guest")


func test_a_throw_flies_and_splats_on_the_guest_too() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _rally(pcs[0])
	var guest := _rally(pcs[1])
	var heckler := host.crowd.hecklers[0]
	heckler.throw_at(heckler.global_position + Vector3(0, 0, -4), "egg")
	await wait_until(func() -> bool: return guest.get_tree().get_nodes_in_group("rally_throwables").size() > 1, 5.0)
	await wait_until(func() -> bool: return guest.find_child("Splat", false, false) != null, 5.0)
	assert_not_null(guest.find_child("Splat", false, false), "the guest sees where it landed")


func test_a_marked_and_cuffed_heckler_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _rally(pcs[0])
	var guest := _rally(pcs[1])
	host.crowd.hecklers[0].mark()
	host.crowd.hecklers[0].cuffed(Handcuffs.SECONDS)
	await wait_until(func() -> bool: return guest.crowd.hecklers[0].marked, 5.0)
	assert_true(guest.crowd.hecklers[0].is_cuffed())


func test_the_deputy_walks_off_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _rally(pcs[0])
	var guest := _rally(pcs[1])
	PoliticianWalks.of(host.politician).walk_off()
	await wait_until(func() -> bool: return guest.politician.off_stage(), 5.0)
	assert_eq(guest.politician.prompt_key(OnlinePcs.own_cop(pcs[1])), "PROMPT_LEAD_POLITICIAN")


func test_the_end_of_shift_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _rally(pcs[0])
	var guest := _rally(pcs[1])
	for heckler in host.crowd.hecklers:
		heckler.cuffed(Handcuffs.SECONDS)
	host.speech.start()
	host.speech.left = 0.05
	await wait_until(func() -> bool: return guest.case.shift_over, PoliticianCase.SHIFT_DELAY + 5.0)
	assert_true(guest.case.solved())
