extends GutTest

## The prison's visiting day online (carcel-visitas.md, step 7; docs/diseno/online.md): the host's visitors, search
## and case decide, and every PC sees the same line, things on the table, finds and passes.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const VISITS_SCENE := preload("res://scenes/levels/prison_visits.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = VISITS_SCENE.instantiate()
		prison.case_seed = SEED
		prison.get_node("Cop/Grabber").input_enabled = false
		return prison)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> PrisonLevel:
	return OnlinePcs.level(net) as PrisonLevel


func _items(level: PrisonLevel) -> Array[Node]:
	return level.find_children("*", "VisitItem", true, false).filter(func(item: Node) -> bool:
		return not item.is_queued_for_deletion())


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _level(pcs[1])
	assert_true(guest.visit_case.follower)
	assert_true(guest.visits.follower)
	assert_true(guest.visits.visitors[0].follower, "only the host's visitors walk")
	for i in VisitPlan.VISITORS:
		assert_eq(guest.visits.visitors[i].item_kind, _level(pcs[0]).visits.visitors[i].item_kind)


func test_the_line_moves_and_the_thing_lands_on_the_guests_table() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.visits.start()
	var head := host.visits.line[0]
	await wait_until(func() -> bool: return head.state == PrisonVisitor.State.TABLE, 15.0)
	await wait_until(func() -> bool: return _items(guest).size() == 1, 5.0)
	var copy: VisitItem = _items(guest)[0]
	assert_eq(copy.kind, head.item_kind)
	var there := guest.visits.visitors[head.get_index()]
	await wait_until(func() -> bool: return not there.is_carrying(), 5.0)
	assert_eq(there.state, PrisonVisitor.State.TABLE)


func test_a_pass_and_the_counts_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.visits.start()
	host.visits._on_cried(host.visits.visitors[0])
	host.visits._on_passed(host.visits.visitors[1])
	await wait_until(func() -> bool: return guest.visits.passed == 1, 5.0)
	assert_eq(guest.visits.broken, 1)
	assert_string_contains(guest.visit_case.rows()[4].text, "1")


func test_the_end_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.visits.start()
	host.visits.end_visit()
	for visitor in host.visits.visitors:
		visitor.state = PrisonVisitor.State.GONE
	await wait_until(func() -> bool: return guest.visit_case.solved_it, 5.0)
	await wait_until(func() -> bool: return not guest.visits.visitors[0].visible, 5.0)
	assert_true(guest.visits.is_over)


func test_opening_a_thing_opens_the_guests_copy_and_the_host_counts() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.visits.start()
	var head := host.visits.line[0]
	await wait_until(func() -> bool: return head.state == PrisonVisitor.State.TABLE, 15.0)
	await wait_until(func() -> bool: return _items(guest).size() == 1, 5.0)
	var cop: Cop = host.get_node("Cop")
	cop.get_node("Grabber").grab(head.item)
	cop.use()
	await wait_until(func() -> bool: return (_items(guest)[0] as VisitItem).opened, 5.0)
	assert_eq(host.visits.broken + host.visits.confiscated, 1)
	await wait_until(func() -> bool: return guest.visits.broken + guest.visits.confiscated == 1, 5.0)
