extends GutTest

## The prison's visiting day: the line of visitors, the search table and letting them in (carcel-visitas.md, step 2).

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


func _local(node: Node3D) -> Vector2:
	var at := prison.global_transform.affine_inverse() * node.global_position
	return Vector2(at.x, at.z)


func _items() -> Array[Node]:
	return get_tree().get_nodes_in_group("visit_items").filter(func(item: Node) -> bool:
		return prison.is_ancestor_of(item) and not item.is_queued_for_deletion())


## Walks the head of the line to the table, quickly.
func _head_to_table() -> PrisonVisitor:
	plan.start()
	var head := plan.line[0]
	for i in 600:
		if head.state == PrisonVisitor.State.TABLE:
			break
		await wait_physics_frames(1)
	return head


func test_eight_visitors_in_line_in_the_yard() -> void:
	assert_eq(prison.variant, "visits")
	assert_eq(plan.visitors.size(), VisitPlan.VISITORS)
	for place in plan.visitors.size():
		var spot := VisitPlan.queue_spot(place)
		assert_almost_eq(_local(plan.visitors[place]).distance_to(spot), 0.0, 0.2)
		assert_gt(spot.y, PrisonLevel.BUILDING_FRONT, "in the yard")
		assert_lt(spot.y, PrisonLevel.HALF_Z, "inside the wall")


func test_each_brings_a_different_thing() -> void:
	var kinds := {}
	for visitor in plan.visitors:
		kinds[visitor.item_kind] = true
		assert_true(visitor.is_carrying())
	assert_eq(kinds.size(), VisitPlan.VISITORS)


func test_four_to_six_hide_something() -> void:
	for case_seed in [1, 2, 3, 7, 11, 40]:
		var other := VisitPlan.new()
		var level: PrisonLevel = LEVEL.instantiate()
		level.case_seed = case_seed
		add_child_autofree(level)
		await wait_physics_frames(1)
		other = level.visits
		var hiding := other.visitors.filter(func(visitor: PrisonVisitor) -> bool:
			return visitor.item_hidden or visitor.pocket_hidden).size()
		assert_between(hiding, VisitPlan.HIDDEN_MIN, VisitPlan.HIDDEN_MAX)
		for visitor in other.visitors:
			assert_false(visitor.item_hidden and visitor.pocket_hidden)


func test_the_same_seed_draws_the_same_day() -> void:
	var level: PrisonLevel = LEVEL.instantiate()
	level.case_seed = 7
	add_child_autofree(level)
	await wait_physics_frames(1)
	for i in VisitPlan.VISITORS:
		assert_eq(level.visits.visitors[i].item_kind, plan.visitors[i].item_kind)
		assert_eq(level.visits.visitors[i].look, plan.visitors[i].look)
		assert_eq(level.visits.visitors[i].item_hidden, plan.visitors[i].item_hidden)


func test_nobody_moves_until_a_cop_comes_in() -> void:
	await wait_physics_frames(20)
	assert_false(plan.running)
	cop.global_position = prison.global_transform * Vector3(0, 0.1, 15.0)
	await wait_physics_frames(3)
	assert_true(plan.running)


func test_the_head_leaves_their_thing_on_the_table() -> void:
	var head := await _head_to_table()
	assert_eq(head.state, PrisonVisitor.State.TABLE)
	assert_false(head.is_carrying())
	assert_eq(_items().size(), 1)
	var item: VisitItem = _items()[0]
	assert_eq(item.kind, head.item_kind)
	assert_eq(item.hidden, head.item_hidden)
	assert_eq(head.prompt_key(cop), "PROMPT_LET_VISITOR_IN")
	assert_string_starts_with(head.said(), "VISITOR_HELLO_")


func test_e_lets_them_in_with_their_thing_and_the_line_moves_up() -> void:
	var head := await _head_to_table()
	var second := plan.line[1]
	head.use(cop)
	assert_eq(head.state, PrisonVisitor.State.IN)
	assert_true(head.is_carrying(), "they take it back off the table")
	assert_eq(head.said(), "VISITOR_THANKS")
	assert_eq(plan.line[0], second)
	assert_eq(second.route[-1], VisitPlan.TABLE_SPOT, "the next one walks to the table")
	assert_eq(head.route[-1], head.seat)


func test_a_thing_in_a_cops_hands_stays_with_the_cop() -> void:
	var head := await _head_to_table()
	var item: VisitItem = _items()[0]
	cop.get_node("Grabber").grab(item)
	head.use(cop)
	assert_false(head.is_carrying())
	assert_eq(head.said(), "VISITOR_MY_THING")
	assert_false(item.is_queued_for_deletion())


func test_nobody_at_the_table_and_they_go_in_alone() -> void:
	var head := await _head_to_table()
	head._waited = PrisonVisitor.WAIT_ALONE - 0.01
	await wait_physics_frames(3)
	assert_eq(head.state, PrisonVisitor.State.IN)
	assert_eq(head.said(), "VISITOR_GOES_ALONE")


func test_they_walk_in_and_sit_at_their_seat() -> void:
	var head := await _head_to_table()
	head.use(cop)
	for i in 1500:
		if head.state == PrisonVisitor.State.SEATED:
			break
		await wait_physics_frames(1)
	assert_eq(head.state, PrisonVisitor.State.SEATED)
	assert_almost_eq(_local(head).distance_to(head.seat), 0.0, 0.5)


func test_seats_are_past_the_benches_on_the_tables_front_side() -> void:
	var seats := VisitPlan.seat_spots()
	assert_gte(seats.size(), VisitPlan.VISITORS)
	for seat: Vector2 in seats:
		assert_true(PrisonLevel.TABLE_ZS.any(func(z: float) -> bool:
			return is_equal_approx(seat.y, z + VisitPlan.SEAT_Z)))
