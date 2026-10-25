extends GutTest

## The visiting day's visit: the inmates across the tables, the pass under the table and the bell
## (carcel-visitas.md, step 5).

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


## `visitor` seated at once, still hiding something in a pocket, with the visit on and no cop around.
func _seated(visitor: PrisonVisitor) -> void:
	plan.running = true
	plan.visit_left = VisitPlan.VISIT_TIME
	visitor.pocket_hidden = true
	visitor.state = PrisonVisitor.State.SEATED
	visitor.global_position = prison.global_transform * Vector3(visitor.seat.x, PrisonLevel.FLOOR_TOP, visitor.seat.y)
	cop.global_position = prison.global_transform * Vector3(10.0, 0.1, 15.0)


func test_an_inmate_across_each_visitors_seat() -> void:
	assert_eq(plan.inmates.size(), VisitPlan.VISITORS)
	for visitor in plan.visitors:
		assert_not_null(visitor.inmate)
		assert_almost_eq(_local(visitor.inmate).distance_to(visitor.seat), VisitPlan.SEAT_Z * 2, 0.1)
		assert_lt(_local(visitor.inmate).y, visitor.seat.y, "on the other side of the table")


func test_the_visit_starts_when_the_last_one_goes_in() -> void:
	assert_lt(plan.visit_left, 0.0)
	plan.start()
	for visitor in plan.visitors.duplicate():
		visitor.state = PrisonVisitor.State.TABLE
		visitor.go_in("VISITOR_THANKS")
	assert_eq(plan.visit_left, VisitPlan.VISIT_TIME)


func test_unwatched_they_slip_it_under_the_table() -> void:
	var visitor := plan.visitors[0]
	_seated(visitor)
	var kind := visitor.hidden_kind()
	visitor._pass_left = 0.01
	visitor.visit_tick(0.02, false)
	assert_true(visitor.passing)
	assert_eq(visitor.prompt_key(cop), "PROMPT_STOP_PASS")
	visitor.visit_tick(PrisonVisitor.PASS_TIME + 0.01, false)
	assert_false(visitor.passing)
	assert_false(visitor.has_contraband())
	assert_eq(visitor.inmate.received, [kind])
	assert_eq(plan.passed, 1)


func test_watched_they_wait() -> void:
	var visitor := plan.visitors[0]
	_seated(visitor)
	visitor._pass_left = 0.01
	visitor.visit_tick(0.02, true)
	assert_false(visitor.passing)
	assert_almost_eq(visitor._pass_left, PrisonVisitor.PASS_RETRY, 0.01)


func test_a_cop_looking_at_the_table_watches_it() -> void:
	var visitor := plan.visitors[0]
	_seated(visitor)
	var table := prison.global_transform * Vector3(visitor.seat.x, 1.0, visitor.seat.y - VisitPlan.SEAT_Z)
	cop.global_position = table + prison.global_basis * Vector3(0, -0.5, 5.0)
	cop.look_at(Vector3(table.x, cop.global_position.y, table.z), Vector3.UP)
	cop.camera.rotation = Vector3.ZERO
	assert_true(plan.watched(visitor.seat))
	cop.rotate_y(PI)
	assert_false(plan.watched(visitor.seat), "with their back to it")


func test_e_stops_the_pass() -> void:
	var visitor := plan.visitors[0]
	_seated(visitor)
	visitor._pass_left = 0.01
	visitor.visit_tick(0.02, false)
	visitor.use(cop)
	assert_false(visitor.passing)
	assert_false(visitor.has_contraband())
	assert_eq(visitor.inmate.received, [])
	assert_eq(plan.stopped, 1)
	assert_eq(plan.confiscated, 1)
	assert_eq(visitor.said(), "VISITOR_STOPPED")


func test_the_bell_sends_everyone_off() -> void:
	var visitor := plan.visitors[0]
	_seated(visitor)
	visitor.inmate.receive(Contraband.Kind.FILE)
	plan.visit_left = 0.01
	await wait_physics_frames(2)
	assert_true(plan.is_over)
	assert_eq(visitor.state, PrisonVisitor.State.LEAVING)
	assert_eq(visitor.route[-1], VisitPlan.GATE)
	assert_eq(visitor.inmate.route[-1], VisitPlan.GATE, "the one who got something walks out too")
	assert_true(plan.inmates[1].route.is_empty(), "the others stay seated")


func test_the_day_ends_when_the_last_visitor_is_gone() -> void:
	watch_signals(plan)
	plan.running = true
	plan.end_visit()
	for visitor in plan.visitors:
		visitor.state = PrisonVisitor.State.GONE
	await wait_physics_frames(2)
	assert_signal_emitted(plan, "ended")
