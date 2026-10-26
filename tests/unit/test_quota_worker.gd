extends GutTest

## Nilda, the doll factory's gossip (fabrica.md, step 4): dolls keep dropping onto the belt, the ones at the end are
## packed in the cart, and five dolls in her box get her to tell what she saw.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")
const DOLL_SCENE := preload("res://scenes/props/factory_doll.tscn")


func _factory() -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.get_node("Cop").input_enabled = false
	add_child_autofree(factory)
	return factory


func _box_top(factory: DollFactory) -> Vector3:
	return factory.nilda.to_global(QuotaWorker.BOX_AT + Vector3(0, QuotaWorker.BOX_SIZE.y + 0.3, 0))


func test_dolls_drop_onto_the_belt_while_it_moves() -> void:
	var factory := _factory()
	await wait_seconds(DollFactory.FEED_EVERY + 0.5)
	var dolls := get_tree().get_nodes_in_group("factory_dolls")
	assert_eq(dolls.size(), 2, "one right away and one more after FEED_EVERY")
	factory.belt.stop()
	await wait_seconds(DollFactory.FEED_EVERY + 0.5)
	assert_eq(get_tree().get_nodes_in_group("factory_dolls").size(), 2, "none while it's stopped")


func test_dolls_at_the_end_are_packed() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var doll: Node3D = DOLL_SCENE.instantiate()
	doll.position = Vector3(-2.0, DollFactory.BELT_TOP + 0.2, 4.0)
	factory.add_child(doll)
	await wait_seconds(2.5)
	assert_eq(factory.shipped, 1)
	await wait_seconds(DollFactory.PACK_DELAY)
	assert_false(is_instance_valid(doll), "packed away")


func test_five_dolls_in_her_box_and_she_tells() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	factory.nilda.clue = "the clue"
	watch_signals(factory.nilda)
	factory.nilda.use(factory.get_node("Cop"))
	assert_signal_emitted(factory.nilda, "asked")
	assert_eq(factory.nilda.get_node("Bubble").text, "NILDA_ASK")
	for i in QuotaWorker.QUOTA:
		var doll: Node3D = DOLL_SCENE.instantiate()
		factory.add_child(doll)
		doll.global_position = _box_top(factory)
		await wait_seconds(0.6)
	assert_eq(factory.nilda.packed, QuotaWorker.QUOTA)
	assert_true(factory.nilda.served)
	assert_signal_emitted_with_parameters(factory.nilda, "told", ["the clue"])


func test_other_things_in_her_box_dont_count() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var mold: Ornament = factory.molds[0]
	mold.global_position = _box_top(factory)
	await wait_seconds(0.8)
	assert_eq(factory.nilda.packed, 0)
