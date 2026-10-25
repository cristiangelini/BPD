extends GutTest

## The visiting day's search: frisking at the table and opening what they bring (carcel-visitas.md, step 3).

const LEVEL := preload("res://scenes/levels/prison_visits.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: VisitPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.visits


func _contraband() -> Array[Node]:
	return get_tree().get_nodes_in_group("contraband").filter(func(item: Node) -> bool:
		return prison.is_ancestor_of(item) and not item.is_queued_for_deletion())


## The head of the line at the table, with `item_hidden` and `pocket_hidden` set as asked, and the cop beside them.
func _at_table(in_item: bool, in_pocket: bool) -> PrisonVisitor:
	var head := plan.line[0]
	head.item_hidden = in_item
	head.pocket_hidden = in_pocket
	plan.start()
	for i in 600:
		if head.state == PrisonVisitor.State.TABLE:
			break
		await wait_physics_frames(1)
	cop.global_position = prison.global_transform * Vector3(-4.2, 0.1, VisitPlan.TABLE_AT.y)
	return head


func _frisk(head: PrisonVisitor) -> void:
	assert_true(head.ask(cop))
	for i in int(PrisonVisitor.FRISK_TIME * 60) + 20:
		if head.frisked:
			break
		await wait_physics_frames(1)


func test_frisking_finds_whats_in_a_pocket() -> void:
	var head := await _at_table(false, true)
	assert_eq(head.prompt_key(cop), "PROMPT_VISITOR_AT_TABLE")
	await _frisk(head)
	assert_true(head.frisked)
	assert_false(head.pocket_hidden)
	assert_eq(_contraband().size(), 1)
	assert_eq((_contraband()[0] as Contraband).kind, Contraband.IN_POCKET[head.pocket_kind])
	assert_eq(plan.confiscated, 1)
	assert_string_starts_with(head.said(), "VISITOR_CAUGHT_")
	assert_eq(head.prompt_key(cop), "PROMPT_LET_VISITOR_IN")


func test_frisking_a_clean_one_finds_nothing() -> void:
	var head := await _at_table(false, false)
	await _frisk(head)
	assert_true(head.frisked)
	assert_eq(_contraband().size(), 0)
	assert_eq(plan.confiscated, 0)
	assert_eq(head.said(), "VISITOR_FRISK_CLEAN")


func test_walking_away_stops_the_frisk() -> void:
	var head := await _at_table(false, true)
	assert_true(head.ask(cop))
	cop.global_position = prison.global_transform * Vector3(-8.0, 0.1, 14.0)
	await wait_physics_frames(int(PrisonVisitor.FRISK_TIME * 60) + 10)
	assert_false(head.frisked)
	assert_true(head.pocket_hidden)


func test_opening_finds_whats_inside() -> void:
	var head := await _at_table(true, false)
	head.item.hidden = true
	cop.get_node("Grabber").grab(head.item)
	var item := head.item
	assert_true(cop.use())
	assert_true(item.opened)
	assert_false(item.hidden)
	var found: Contraband = cop.get_node("Grabber").held
	assert_not_null(found)
	assert_eq(found.kind, Contraband.IN_ITEM[item.kind])
	assert_eq(plan.confiscated, 1)
	assert_false(head.item_hidden)
	assert_false(head.has_contraband())


func test_opening_an_innocent_thing_breaks_it_and_they_cry() -> void:
	var head := await _at_table(false, false)
	var item := head.item
	cop.get_node("Grabber").grab(item)
	cop.use()
	assert_true(item.opened)
	assert_eq(plan.broken, 1)
	assert_eq(plan.confiscated, 0)
	assert_string_starts_with(head.said(), "VISITOR_CRY_")
	assert_eq(item.held_prompt_key(cop), "PROMPT_VISIT_ITEM_OPENED")
	cop.use()
	assert_eq(plan.broken, 1, "opening it twice doesn't count twice")


func test_an_opened_thing_stays_on_the_table() -> void:
	var head := await _at_table(false, false)
	var item := head.item
	cop.get_node("Grabber").grab(item)
	cop.use()
	cop.get_node("Grabber").release()
	head.use(cop)
	assert_false(head.is_carrying())
	assert_false(item.is_queued_for_deletion())


func test_what_isnt_found_goes_in_with_them() -> void:
	var head := await _at_table(true, true)
	head.use(cop)
	assert_true(head.is_carrying())
	assert_true(head.has_contraband())
	assert_true(plan.carrying_contraband().has(head))


func test_every_visit_item_hides_its_own_thing() -> void:
	assert_eq(Contraband.IN_ITEM.size(), VisitItem.Kind.size())
	var kinds := {}
	for kind in Contraband.IN_ITEM:
		kinds[kind] = true
	assert_eq(kinds.size(), Contraband.Kind.size(), "12 different hidden things")
