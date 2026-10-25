extends GutTest

## The crowd at deputy Lustre's rally and what the hecklers throw (proteccion-politico.md, step 2, decision 103): the
## fans and their hecklers by seed, the eggs and tomatoes on their arc, the stains on his suit and leaving furious.

const LEVEL := preload("res://scenes/levels/plaza_rally.tscn")

var rally: PlazaRally


func before_each() -> void:
	rally = LEVEL.instantiate()
	rally.case_seed = 7
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)


func test_the_crowd_has_its_hecklers() -> void:
	assert_eq(rally.crowd.fans.size(), RallyCrowd.FANS)
	assert_eq(rally.crowd.hecklers.size(), RallyCrowd.HECKLERS)
	for heckler in rally.crowd.hecklers:
		assert_true(heckler.heckler)


func test_the_same_seed_gives_the_same_hecklers() -> void:
	var other: PlazaRally = LEVEL.instantiate()
	other.case_seed = 7
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in RallyCrowd.HECKLERS:
		assert_eq(other.crowd.hecklers[i].name, rally.crowd.hecklers[i].name)


func test_nobody_throws_before_the_speech() -> void:
	await wait_seconds(0.5)
	assert_eq(get_tree().get_nodes_in_group("rally_throwables").size(), 0)


func test_a_throw_on_target_stains_his_suit() -> void:
	watch_signals(rally.politician)
	var heckler := rally.crowd.hecklers[0]
	heckler.throw_at(rally.politician.global_position + Vector3.UP * RallyCrowd.CHEST, "tomato")
	await wait_until(func() -> bool: return rally.politician.stains > 0, RallyFan.FLIGHT + 1.5)
	assert_eq(rally.politician.stains, 1)
	assert_signal_emitted_with_parameters(rally.politician, "stained", [1])
	assert_not_null(rally.politician.get_node_or_null("Stain1"), "the stain shows on him")
	assert_string_starts_with(rally.politician.said(), "POLITICIAN_STAIN_")


func test_a_miss_leaves_a_splat() -> void:
	var heckler := rally.crowd.hecklers[0]
	var thrown := heckler.throw_at(heckler.global_position + Vector3(0, 0, -4), "egg")
	# A weak reference: a lambda holding the egg itself errors once the egg is freed.
	var egg := weakref(thrown)
	thrown = null
	await wait_until(func() -> bool: return egg.get_ref() == null, RallyFan.FLIGHT + 1.5)
	assert_eq(rally.politician.stains, 0)
	assert_not_null(rally.find_child("Splat", false, false), "the egg is on the ground")


func test_ten_stains_and_he_leaves_furious() -> void:
	watch_signals(rally.politician)
	for i in Politician.STAINS_MAX:
		rally.politician.stain("egg", rally.politician.global_position + Vector3(0, 1, 0.4))
	assert_signal_emitted(rally.politician, "furious")
	assert_eq(rally.politician.said(), "POLITICIAN_FURIOUS")
	rally.politician.stain("egg", rally.politician.global_position)
	assert_eq(rally.politician.stains, Politician.STAINS_MAX, "no more after that")


func test_the_hecklers_throw_during_the_speech() -> void:
	rally.speech.start()
	rally.crowd._next_throw[rally.crowd.hecklers[0]] = 0.0
	await wait_physics_frames(2)
	assert_gt(get_tree().get_nodes_in_group("rally_throwables").size(), 0)
