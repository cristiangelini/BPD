extends GutTest

## The double's rally online (politico-doble.md, step 3; docs/diseno/online.md): the host's double decides when he
## sneaks up, takes the lectern and gets cuffed, and every PC sees the same.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SCENE := preload("res://scenes/levels/plaza_double.tscn")
const SEED := 4242

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var rally: PlazaRally = SCENE.instantiate()
		rally.case_seed = SEED
		rally.get_node("Cop/Grabber").input_enabled = false
		return rally)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _rally(net: Node) -> PlazaRally:
	return OnlinePcs.level(net) as PlazaRally


func test_the_guests_double_follows_the_hosts() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _rally(pcs[0])
	var guest := _rally(pcs[1])
	assert_false(guest.swap.is_physics_processing(), "only the host's double decides")
	assert_eq(guest.double.fakes, host.double.fakes, "the same tells from the same seed")
	assert_true(guest.double.disguised)
	host.speech.start()
	PoliticianWalks.of(host.politician).walk_off()
	await wait_until(func() -> bool: return host.swap.state == DoubleSwap.State.SPEAKING, 30.0)
	assert_eq(host.swap.state, DoubleSwap.State.SPEAKING)
	await wait_until(func() -> bool: return not guest.double.disguised, 5.0)
	assert_false(guest.double.disguised, "unmasked on the guest too")
	await wait_until(func() -> bool:
		return guest.double.global_position.distance_to(host.double.global_position) < 0.3, 5.0)
	assert_lt(guest.double.global_position.distance_to(host.double.global_position), 0.3, "at the lectern")
	host.double.cuffed(Handcuffs.SECONDS)
	await wait_until(func() -> bool: return guest.double.caught, 5.0)
	assert_true(guest.double.caught)
	assert_false(guest.double.tells.get_node("mustache").visible, "his mustache fell off there too")
	assert_true(guest.double.is_cuffed())
