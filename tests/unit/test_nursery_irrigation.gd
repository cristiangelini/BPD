extends GutTest

## The nursery's watering (docs/diseno/allanamiento-vivero.md, step 2): the sprinklers come on every 40 s for 15 s or
## with the valve, their jets turn and push light things and cops and wet them, and afterwards the yard is mud for a
## while, where a running cop slips.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery() -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.case_seed = 5
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func _box(nursery: Nursery, at: Vector3, mass: float) -> Grabbable:
	var box := ClubEvidence.make_item("Box", Nursery.CERAMIC_MODEL, Vector3(0.3, 0.3, 0.3), mass)
	nursery.add_child(box)
	box.global_position = at
	return box


## Points sprinkler `index`'s jet at `at` (global).
func _aim(nursery: Nursery, index: int, at: Vector3) -> void:
	var head := nursery.sprinkler_heads[index]
	var off := at - head.global_position
	head.rotation.y = atan2(-off.z, off.x)


func test_it_comes_on_every_forty_seconds_and_leaves_mud() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var irrigation := nursery.irrigation
	irrigation.set_physics_process(false)
	assert_false(irrigation.is_running())
	irrigation.tick(NurseryIrrigation.EVERY + 0.1)
	assert_true(irrigation.is_running())
	assert_true(nursery.jets[0].visible, "the jets show")
	irrigation.tick(NurseryIrrigation.RUN_SECONDS)
	assert_false(irrigation.is_running())
	assert_true(irrigation.is_muddy())
	assert_false(nursery.jets[0].visible)
	irrigation.tick(NurseryIrrigation.MUD_SECONDS + 0.1)
	assert_false(irrigation.is_muddy(), "the mud dries")
	assert_eq(irrigation.runs, 1)


func test_the_valve_starts_it_at_once() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	nursery.valve.use(nursery.get_node("Cop"))
	assert_true(nursery.irrigation.is_running())
	assert_ne(tr("PROMPT_NURSERY_VALVE"), "PROMPT_NURSERY_VALVE")


func test_the_jet_turns() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	nursery.irrigation.start()
	var before := nursery.sprinkler_heads[0].rotation.y
	await wait_physics_frames(10)
	assert_ne(nursery.sprinkler_heads[0].rotation.y, before)


func test_the_jet_throws_a_light_thing_but_not_a_heavy_one() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var irrigation := nursery.irrigation
	irrigation.set_physics_process(false)
	var head := nursery.sprinkler_heads[0]
	var light := _box(nursery, head.global_position + Vector3(2.0, 0.2, 0), 1.0)
	var heavy := _box(nursery, head.global_position + Vector3(-2.0, 0.2, 0), 10.0)
	await wait_physics_frames(20)
	irrigation.start()
	_aim(nursery, 0, light.global_position)
	irrigation.tick(0.01)
	_aim(nursery, 0, heavy.global_position)
	irrigation.tick(0.01)
	await wait_physics_frames(1)
	assert_gt(light.linear_velocity.length(), 2.0, "the light one flies off")
	assert_lt(heavy.linear_velocity.length(), 0.5, "the heavy one stays")
	assert_true(irrigation.wet.has(light.get_instance_id()))
	assert_true(irrigation.wet.has(heavy.get_instance_id()), "both get wet")


func test_the_jet_pushes_and_soaks_a_cop() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var irrigation := nursery.irrigation
	irrigation.set_physics_process(false)
	var cop: Cop = nursery.get_node("Cop")
	var head := nursery.sprinkler_heads[1]
	cop.global_position = head.global_position + Vector3(0, 0.1, 2.0)
	await wait_physics_frames(5)
	watch_signals(irrigation)
	irrigation.start()
	_aim(nursery, 1, cop.global_position)
	irrigation.tick(0.01)
	assert_true(cop.is_staggered(), "a little push")
	assert_signal_emitted_with_parameters(irrigation, "soaked", [cop])


func test_a_running_cop_slips_in_the_mud_once_in_a_while() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var irrigation := nursery.irrigation
	irrigation.set_physics_process(false)
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = nursery.to_global(Vector3(-10.5, 0.2, 2.0))
	await wait_physics_frames(5)
	irrigation.start()
	irrigation.tick(NurseryIrrigation.RUN_SECONDS)
	assert_true(irrigation.is_muddy())
	cop.is_running = false
	cop.velocity = Vector3(2.0, 0, 0)
	irrigation.tick(0.01)
	assert_eq(irrigation.slips, 0, "walking is fine")
	cop.is_running = true
	cop.velocity = Vector3(6.0, 0, 0)
	watch_signals(irrigation)
	irrigation.tick(0.01)
	assert_eq(irrigation.slips, 1)
	assert_signal_emitted(irrigation, "slipped")
	assert_true(cop.is_staggered())
	irrigation.tick(0.01)
	assert_eq(irrigation.slips, 1, "not again at once")
