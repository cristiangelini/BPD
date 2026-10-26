extends GutTest

## The prison count online (carcel-recuento.md, step 7; docs/diseno/online.md): the host's plan and case decide, and
## every PC sees the same inmates, crosses, list, hideouts, runners and counts.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const COUNT_SCENE := preload("res://scenes/levels/prison_count.tscn")
const SEED := 4

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = COUNT_SCENE.instantiate()
		prison.case_seed = SEED
		prison.get_node("Cop/Grabber").input_enabled = false
		return prison)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> PrisonLevel:
	return OnlinePcs.level(net) as PrisonLevel


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	assert_true(guest.count_case.follower)
	assert_true(guest.count.follower)
	assert_true(guest.count.hideouts[0].follower)
	assert_true(guest.count.inmates[0].follower, "only the host's inmates decide")
	assert_eq(guest.count.hidden, host.count.hidden, "the same count from the same seed")
	assert_eq(guest.count.inmates[0].number, host.count.inmates[0].number)


func test_a_cross_and_the_list_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	var inmate := host.count.inmates[0]
	inmate.use(host.get_node("Cop"))
	var copy := guest.count.inmates[0]
	await wait_until(func() -> bool: return copy.marked, 5.0)
	assert_true(copy.get_node("Cross").visible)
	await wait_until(func() -> bool: return guest.count.board.is_marked(inmate.number), 5.0)
	assert_eq(guest.count_case.rows()[1].text, tr("OBJ_COUNT_LIST") % [1, CountPlan.LIST])


func test_the_guest_cannot_chalk_by_itself() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _level(pcs[1])
	guest.count.inmates[0].use(guest.get_node("Cop"))
	assert_false(guest.count.inmates[0].marked, "the host decides")
	assert_eq(guest.count.board.counted(), 0)
	guest.count.hidden_in[guest.count.hidden[0]].use(guest.get_node("Cop"))
	assert_eq(guest.count.found, 0)


func test_one_found_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	var number: int = host.count.hidden[0]
	host.count.hidden_in[number].use(host.get_node("Cop"))
	await wait_until(func() -> bool: return guest.count.inmate_with(number) != null, 5.0)
	var copy := guest.count.inmate_with(number)
	assert_eq((copy.get_node("Number") as Label3D).text, "%02d" % number, "with his number")
	await wait_until(func() -> bool: return guest.count.found == 1 and guest.count.board.is_marked(number), 5.0)
	assert_eq(guest.count.hidden_in[number].occupant, 0, "his hideout is empty there too")


func test_a_runner_and_the_gate_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	var number: int = host.count.hidden[1]
	var runner := host.count.run(number)
	await wait_until(func() -> bool: return guest.count.runners.size() == 1, 5.0)
	await wait_physics_frames(2)
	var copy := guest.count.runners[0]
	assert_eq(copy.get_meta("number"), number)
	assert_not_null(copy.get_node_or_null("Number"), "with his number")
	assert_not_null(OwnerEscort.of(copy), "the guest's cops can walk him to a cell")
	runner._escape()
	await wait_until(func() -> bool: return guest.count.escaped == 1 and guest.count.board.is_escaped(number), 5.0)


func test_the_end_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.count.start()
	host.count.time = CountPlan.TIME - 0.01
	await wait_until(func() -> bool: return guest.count.over and guest.count_case.failed_reason != "", 5.0)
	assert_eq(guest.count_case.failed_reason, "CASE_FAILED_COUNT_TIME")
