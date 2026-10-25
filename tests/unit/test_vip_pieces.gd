extends GutTest

## The VIP inmate's hidden pieces and his lawyer, step 4 (carcel-vip.md): the cake, the guitar and the flowers always
## come up and hide the file, the rope and the key; opened, the piece is confiscated; given unopened, it's his. His mood
## at 0 brings his lawyer.

const LEVEL := preload("res://scenes/levels/prison_vip.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: VipPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 8
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.vip


func _gift(kind: VipRequests.Kind) -> VisitItem:
	for item in plan.gifts:
		if VipRequests.kind_of(item) == kind:
			return item
	return null


func _give(item: Grabbable) -> void:
	plan.requests.started = true
	plan.requests.open.append({"kind": VipRequests.kind_of(item), "left": 60.0})
	plan.requests.offered(item)


func test_the_three_hiding_things_are_always_asked_for() -> void:
	for kind in VipRequests.HIDING:
		assert_has(plan.requests.order, kind)
		var item := _gift(kind)
		assert_true(item.hidden)
		assert_eq(item.inside(), VipPlan.PIECES[kind])


func test_opening_the_cake_finds_the_file() -> void:
	var cake := _gift(VipRequests.Kind.CAKE)
	cop.handed(cake)
	cake.use(cop)
	var held: Grabbable = cop.get_node("Grabber").held
	assert_true(held is Contraband)
	assert_eq((held as Contraband).kind, Contraband.Kind.FILE)
	assert_eq(plan.seized, 1)
	assert_false(cake.hidden)
	_give(cake)
	assert_has(plan.received, cake, "opened, he still takes it")
	assert_eq(plan.pieces.size(), 0)


func test_unopened_he_keeps_the_piece() -> void:
	watch_signals(plan)
	var guitar := _gift(VipRequests.Kind.GUITAR)
	_give(guitar)
	assert_eq(plan.pieces, [Contraband.Kind.ROPE] as Array[int])
	assert_signal_emitted_with_parameters(plan, "got_piece", [1])
	assert_false(guitar.hidden)


func test_his_mood_at_zero_brings_his_lawyer() -> void:
	plan.requests.set_mood(0)
	assert_eq(plan.lawyers, 1)
	var lawyer := plan.lawyer
	assert_not_null(lawyer)
	assert_false(prison.inside_walls(prison.global_transform * lawyer.path[0]), "he comes in from the gate")
	assert_lt(lawyer.path[-1].distance_to(plan.cell_point(0.0)), 1.0, "to the bars")
	assert_true(prison.in_block(prison.global_transform * lawyer.path[-1]))
	lawyer._walk.custom_step(100.0)
	assert_true(lawyer.talking)
	assert_almost_eq(lawyer.position.distance_to(lawyer.path[-1]), 0.0, 0.01)
	plan.requests.set_mood(0)
	assert_eq(plan.lawyers, 1, "one lawyer at a time")
	lawyer.talk_left = 0.0
	await wait_seconds(0.1)
	assert_false(lawyer.talking)
	assert_eq(lawyer.said(), "VIP_LAWYER_BYE")
	lawyer._walk.custom_step(100.0)
	await wait_physics_frames(1)
	assert_null(plan.lawyer)
	assert_eq(plan.requests.mood, VipPlan.MOOD_AFTER_LAWYER)
