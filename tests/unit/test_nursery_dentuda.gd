extends GutTest

## The Dentuda (docs/diseno/allanamiento-vivero.md, step 3): she bites what comes close to her mouth once every 3 s,
## swallows things and spits them far 5 s later, takes what a cop holds or pushes it back, leaves alone what lies
## still, and calms down 10 s after eating a fertilizer bag.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery() -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.case_seed = 5
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func _box(nursery: Nursery, at: Vector3) -> Grabbable:
	var box := ClubEvidence.make_item("Box", Nursery.CERAMIC_MODEL, Vector3(0.3, 0.3, 0.3), 1.0)
	nursery.add_child(box)
	box.global_position = at
	return box


## A spot by her mouth (global), at the floor.
func _by_mouth(nursery: Nursery) -> Vector3:
	return nursery.to_global(Vector3(Nursery.DENTUDA_MOUTH.x - 1.0, Nursery.FLOOR_TOP, 0.0))


func _stopped(nursery: Nursery) -> NurseryDentuda:
	var dentuda := nursery.dentuda
	dentuda.set_physics_process(false)
	return dentuda


func test_she_swallows_a_thrown_thing_and_spits_it_far() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var dentuda := _stopped(nursery)
	var box := _box(nursery, dentuda.mouth + Vector3(-0.8, -0.5, 0))
	box.linear_velocity = Vector3(2, 0, 0)
	watch_signals(dentuda)
	dentuda.tick(0.1)
	assert_signal_emitted(dentuda, "bitten")
	assert_false(box.visible, "she swallowed it")
	assert_eq(box.collision_layer, 0)
	dentuda.tick(NurseryDentuda.HOLD_SECONDS)
	assert_true(box.visible, "she spat it out")
	assert_eq(box.collision_layer, 4)
	assert_gt(box.linear_velocity.length(), NurseryDentuda.SPIT_SPEED - 0.1, "far")
	assert_lt(box.linear_velocity.x, 0.0, "toward the door she faces")


func test_she_leaves_alone_what_lies_still() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var dentuda := _stopped(nursery)
	var box := _box(nursery, dentuda.mouth + Vector3(-0.8, -0.5, 0))
	box.freeze = true
	box.freeze = false
	box.linear_velocity = Vector3.ZERO
	dentuda.tick(0.1)
	assert_eq(dentuda.bites, 0)
	assert_true(box.visible)


func test_she_takes_what_a_cop_holds_or_pushes_it_back() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var dentuda := _stopped(nursery)
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = _by_mouth(nursery)
	var box := _box(nursery, cop.global_position + Vector3(0, 1.2, 0))
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.grab(box)
	dentuda.tick(0.1)
	assert_null(grabber.held, "she took it from the hands")
	assert_false(box.visible)
	assert_false(cop.is_staggered(), "a cop with something in hand loses it, not its footing")
	dentuda.tick(1.0)
	assert_eq(dentuda.bites, 1, "only once every three seconds")
	dentuda.tick(NurseryDentuda.BITE_EVERY)
	assert_eq(dentuda.bites, 2)
	assert_true(cop.is_staggered(), "empty hands: pushed back")
	assert_ne(tr("HINT_NURSERY_DENTUDA_TOOK"), "HINT_NURSERY_DENTUDA_TOOK")
	assert_ne(tr("HINT_NURSERY_DENTUDA_PUSH"), "HINT_NURSERY_DENTUDA_PUSH")


func test_a_cop_far_away_is_safe() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var dentuda := _stopped(nursery)
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = nursery.to_global(Vector3(3.5, Nursery.FLOOR_TOP, 0.0))
	dentuda.tick(0.1)
	assert_eq(dentuda.bites, 0)


func test_fertilizer_calms_her_down() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var dentuda := _stopped(nursery)
	assert_eq(nursery.food.size(), 3, "three fertilizer bags")
	var bag := nursery.food[0]
	bag.global_position = dentuda.mouth + Vector3(-0.8, -0.5, 0)
	bag.linear_velocity = Vector3(2, 0, 0)
	watch_signals(dentuda)
	dentuda.tick(0.1)
	assert_signal_emitted(dentuda, "fed")
	assert_true(dentuda.is_calm())
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = _by_mouth(nursery)
	dentuda.tick(NurseryDentuda.BITE_EVERY)
	assert_eq(dentuda.bites, 1, "calm: she doesn't bite")
	dentuda.tick(NurseryDentuda.CALM_SECONDS)
	assert_false(dentuda.is_calm())
	assert_eq(dentuda.bites, 2, "and then she does again")
