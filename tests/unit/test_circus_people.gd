extends GutTest

## The six clowns alike, the ringmaster and Zulema the tamer (escena-circo.md, step 3; ClownTraits, CircusClown,
## Ringmaster, CircusTamer).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_six_different_clowns_drawn_by_the_seed() -> void:
	var clowns := ClownTraits.draw(12)
	assert_eq(clowns.size(), ClownTraits.COUNT)
	var seen := {}
	for clown in clowns:
		seen[ClownTraits.signature(clown)] = true
		assert_between(clown.shoe as int, ClownTraits.SHOE_MIN, ClownTraits.SHOE_MAX)
		assert_has(ClownTraits.HONKS, clown.honk)
	assert_eq(seen.size(), ClownTraits.COUNT, "no two clowns should be the same in everything")
	assert_eq(ClownTraits.draw(12), clowns, "same seed, same clowns")
	assert_ne(ClownTraits.draw(13), clowns, "another seed, other clowns")


func test_the_clowns_look_alike_until_their_disguise_comes_off() -> void:
	var circus := Circus.new()
	circus.case_seed = 7
	add_child_autofree(circus)
	assert_eq(circus.clowns.size(), ClownTraits.COUNT)
	for clown in circus.clowns:
		assert_true(clown.disguised())
		assert_true(clown.part("wig").visible, "all with the same wig")
		assert_false(clown.part("hair").visible, "their own hair hidden under it")
		assert_false(clown.part("glasses").visible, "glasses hidden by the makeup")
		var hair := clown.part("hair").find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
		assert_eq((hair.material_override as StandardMaterial3D).albedo_color, ClownTraits.HAIRS[clown.traits.hair])
		assert_true(circus.in_tent(clown.global_position), "practicing in the ring")
	var glasses: Array = circus.clowns.filter(func(c: CircusClown) -> bool: return c.traits.glasses)
	if not glasses.is_empty():
		var clown: CircusClown = glasses[0]
		clown.makeup_on = false
		clown.wig_on = false
		clown._show_disguise()
		assert_true(clown.part("glasses").visible, "without makeup his glasses show")
		assert_true(clown.part("hair").visible)
		assert_false(clown.disguised())
	assert_eq(circus.suspect(3), circus.clowns[3])


func test_the_clowns_tell_jokes_and_the_ringmaster_talks() -> void:
	var circus := Circus.new()
	add_child_autofree(circus)
	var cop: Cop = COP_SCENE.instantiate()
	var clown := circus.clowns[0]
	clown.use(cop)
	var first := clown.said()
	clown.use(cop)
	assert_ne(clown.said(), first, "another joke each time")
	circus.ringmaster.use(cop)
	assert_eq(circus.ringmaster.said(), "RINGMASTER_LINE_0")
	assert_true(circus.in_tent(circus.ringmaster.global_position))
	cop.free()


func test_zulema_takes_offense_like_the_jury_lady() -> void:
	var circus := Circus.new()
	add_child_autofree(circus)
	var cop: Cop = COP_SCENE.instantiate()
	circus.tamer.use(cop)
	assert_eq(circus.tamer.said(), "TAMER_NOTHING", "without a case she saw nothing")
	assert_false(circus.witness_offended())
	circus.tamer.cuffed(5.0)
	assert_true(circus.witness_offended())
	circus.tamer.use(cop)
	assert_eq(circus.tamer.said(), "TAMER_OFFENDED")
	assert_false(circus.in_tent(circus.tamer.global_position), "she's by the pool, out of the tent")
	cop.free()
