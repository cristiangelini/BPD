extends GutTest

## The parade online (politico-descapotable.md, step 3; docs/diseno/online.md): the host's speech clock moves every
## PC's car the same way, the host decides the huggers, and a guest sees who's up on the car.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SCENE := preload("res://scenes/levels/plaza_convertible.tscn")
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


func test_the_guests_parade_follows_the_hosts() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _rally(pcs[0])
	var guest := _rally(pcs[1])
	assert_false(guest.huggers.is_physics_processing(), "only the host's huggers decide")
	host.speech.start()
	host.speech.left = PoliticianSpeech.SPEECH_TIME / 2
	await wait_until(func() -> bool: return absf(guest.parade_car.progress() - host.parade_car.progress()) < 0.01, 5.0)
	assert_almost_eq(guest.parade_car.progress(), host.parade_car.progress(), 0.01, "the same way round")
	assert_lt(guest.parade_car.global_position.distance_to(host.parade_car.global_position), 0.5)
	host.huggers._wait_left = 0.0
	await wait_until(func() -> bool: return host.huggers.state == ParadeHuggers.State.HUGGING, 30.0)
	assert_eq(host.huggers.state, ParadeHuggers.State.HUGGING)
	var index := host.crowd.fans.find(host.huggers.hugger)
	await wait_until(func() -> bool: return guest.crowd.fans[index].hugging, 5.0)
	assert_true(guest.crowd.fans[index].hugging, "up on the car on the guest too")
	assert_eq(guest.crowd.fans[index].prompt_key(guest.get_node("Cop")), "PROMPT_PULL_OFF_FAN")
