extends GutTest

## Finding and cuffing the hecklers at deputy Lustre's rally (proteccion-politico.md, step 4, decision 103): their
## market bag and dirty hands, the mark when a cop sees them throw, the cuffs, the walk to the patrol car and the ones
## left throwing sooner.

const LEVEL := preload("res://scenes/levels/plaza_rally.tscn")

var rally: PlazaRally
var cop: Cop


func before_each() -> void:
	rally = LEVEL.instantiate()
	rally.case_seed = 7
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	cop = rally.get_node("Cop")
	await wait_physics_frames(2)


func test_hecklers_carry_eggs_and_some_innocents_a_lookalike_bag() -> void:
	var shoppers := 0
	for fan in rally.crowd.fans:
		if fan.heckler:
			assert_eq(fan.bag, "market")
		elif fan.bag == "shopping":
			shoppers += 1
		assert_eq(fan.bag.is_empty(), fan.get_node_or_null("Bag") == null)
	assert_eq(shoppers, RallyCrowd.SHOPPERS)


func test_a_throw_dirties_the_hands() -> void:
	var heckler := rally.crowd.hecklers[0]
	assert_false(heckler.dirty)
	heckler.throw_at(rally.politician.global_position, "egg")
	assert_true(heckler.dirty)
	assert_not_null(heckler.get_node_or_null("DirtyHand0"))


func test_a_cop_looking_at_the_throw_marks_them() -> void:
	var heckler := rally.crowd.hecklers[0]
	var other := rally.crowd.hecklers[1]
	cop.global_position = heckler.global_position + Vector3(0, 0, 6)
	cop.camera.look_at(heckler.global_position + Vector3.UP * 1.2)
	rally.crowd.throw_from(heckler)
	assert_true(heckler.marked)
	assert_not_null(heckler.get_node_or_null("Mark"))
	cop.camera.look_at(cop.camera.global_position + Vector3(0, 0, 10))
	rally.crowd.throw_from(other)
	assert_false(other.marked, "the cop looked the other way")


func test_a_cuffed_heckler_stops_throwing() -> void:
	var heckler := rally.crowd.hecklers[0]
	heckler.cuffed(Handcuffs.SECONDS)
	assert_string_starts_with(heckler.said(), "HECKLER_CUFFED_")
	assert_false(heckler.free_to_throw())
	rally.speech.start()
	rally.crowd._next_throw[heckler] = 0.0
	for other in rally.crowd.hecklers:
		if other != heckler:
			rally.crowd._next_throw[other] = 999.0
	await wait_physics_frames(3)
	assert_eq(get_tree().get_nodes_in_group("rally_throwables").size(), 0)


func test_an_innocent_protests() -> void:
	var innocent: RallyFan
	for fan in rally.crowd.fans:
		if not fan.heckler:
			innocent = fan
	innocent.cuffed(Handcuffs.SECONDS)
	assert_string_starts_with(innocent.said(), "FAN_WRONG_CUFF_")
	assert_null(OwnerEscort.of(innocent), "nobody walks them anywhere")


func test_walked_to_the_patrol_car_they_count_as_detained() -> void:
	var heckler := rally.crowd.hecklers[0]
	var before := rally.crowd.throw_every()
	watch_signals(rally.crowd)
	heckler.cuffed(Handcuffs.SECONDS)
	OwnerEscort.of(heckler).board()
	assert_true(heckler.in_car())
	assert_eq(rally.crowd.detained, 1)
	assert_signal_emitted_with_parameters(rally.crowd, "jailed", [heckler])
	assert_lt(rally.crowd.throw_every(), before, "the ones left throw sooner")


func test_talking_gives_no_one_away() -> void:
	var heckler := rally.crowd.hecklers[0]
	heckler.use(cop)
	assert_string_starts_with(heckler.said(), "FAN_TALK_")
	assert_eq(heckler.prompt_key(cop), "PROMPT_TALK_FAN")
