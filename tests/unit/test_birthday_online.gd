extends GutTest

## The birthday party online (politico-cumple.md, step 3; docs/diseno/online.md): the host's party decides when he
## blows each cake and whether the rigged one springs, and every PC sees the same cakes and the same courier.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SCENE := preload("res://scenes/levels/plaza_birthday.tscn")
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


func test_the_guests_cakes_follow_the_hosts() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _rally(pcs[0])
	var guest := _rally(pcs[1])
	assert_false(guest.party.is_physics_processing(), "only the host's party decides")
	for i in 3:
		assert_eq(guest.cakes[i].rigged, host.cakes[i].rigged, "the same rigged cake from the same seed")
		assert_eq(guest.cakes[i].card, host.cakes[i].card)
	assert_not_null(guest.courier)
	var rigged: BirthdayCake
	for cake in host.cakes:
		if cake.rigged:
			rigged = cake
	var index := host.cakes.find(rigged)
	rigged.blow()
	rigged.spring()
	await wait_until(func() -> bool: return guest.cakes[index].sprung, 5.0)
	assert_true(guest.cakes[index].blown, "blown on the guest too")
	assert_true(guest.cakes[index].sprung, "and its spring out")
