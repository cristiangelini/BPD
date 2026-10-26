extends GutTest

## The bridge's opening online (politico-puente.md, step 7; docs/diseno/online.md): the host's park decides the
## ceremony, what breaks, the dips and Remache, and every PC sees the same bridge.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const PARK_SCENE := preload("res://scenes/levels/bridge_park.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var park: BridgePark = PARK_SCENE.instantiate()
		park.case_seed = SEED
		park.get_node("Cop/Grabber").input_enabled = false
		return park)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _park(net: Node) -> BridgePark:
	return OnlinePcs.level(net) as BridgePark


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _park(pcs[1])
	assert_true(guest.case.follower)
	assert_true(guest.ceremony.follower, "the guest's ceremony only shows the host's")
	assert_false(_park(pcs[0]).case.follower)


func test_the_ceremony_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _park(pcs[0])
	var guest := _park(pcs[1])
	host.ceremony.start()
	await wait_until(func() -> bool: return guest.ceremony.state == BridgeCeremony.State.WALKING, 5.0)
	assert_eq(guest.ceremony.state, BridgeCeremony.State.WALKING)


func test_a_broken_span_and_a_sunk_pillar_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _park(pcs[0])
	var guest := _park(pcs[1])
	host.breaks._break("span", 3)
	host.breaks._break("pillar", 0)
	await wait_until(func() -> bool: return guest.plank(3, 0) == null and guest.breaks.sagging.has(0), 5.0)
	assert_null(guest.plank(3, 1), "both planks gone there too")
	assert_lt(guest.pillars[0].position.y, host.breaks._pillar_y[0], "the pillar sank there too")
	host.breaks.straighten(0)
	host.restore_plank(3, 0)
	await wait_until(func() -> bool: return guest.plank(3, 0) != null and not guest.breaks.sagging.has(0), 5.0)
	assert_not_null(guest.plank(3, 0), "a plank fitted on the host is back on the guest")
	assert_almost_eq(guest.pillars[0].position.y, guest.breaks._pillar_y[0], 0.01, "and the pillar stands again")


func test_a_creak_shakes_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _park(pcs[0])
	var guest := _park(pcs[1])
	host.breaks.warn("rail", 4)
	await wait_until(func() -> bool: return not guest.breaks.warnings.is_empty(), 5.0)
	assert_eq(guest.breaks.warnings[0][0], "rail")
	assert_eq(guest.breaks.warnings[0][1], 4)


func test_a_clue_and_the_dips_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _park(pcs[0])
	var guest := _park(pcs[1])
	host.remache.beams.show_found()
	host.case._on_clue("beams")
	host.dip.dipped.emit(1)
	await wait_until(func() -> bool: return guest.case.dips == 1 and guest.remache.beams.found, 5.0)
	assert_true(guest.remache.beams.found, "the tarp is off there too")
	assert_eq(guest.case.rows()[-1].text, "OBJ_BRIDGE_WET")


func test_a_cuffed_remache_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _park(pcs[0])
	var guest := _park(pcs[1])
	host.remache.engineer.cuffed(Handcuffs.SECONDS)
	await wait_until(func() -> bool: return guest.remache.engineer.is_cuffed(), 5.0)
	assert_true(guest.remache.engineer.is_cuffed())


func test_the_end_of_shift_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _park(pcs[0])
	var guest := _park(pcs[1])
	host.remache.engineer.cuffed(Handcuffs.SECONDS)
	host.ceremony.finished.emit()
	await wait_until(func() -> bool: return guest.case.shift_over, BridgeCase.SHIFT_DELAY + 5.0)
	assert_true(guest.case.solved())
