extends GutTest

## The double at the plaza (politico-doble.md, step 1, decision 220): Play draws the double's rally in a third of the
## protections, Rolo Calcado hides in the crowd with a hat and a scarf, both deputies wear the ten tells (the double
## three of his own, drawn by the seed) and the planilla carries the real deputy's file.

const LEVEL := preload("res://scenes/levels/plaza_double.tscn")
const TEST_PATH := "user://test_partidas/politico_doble.json"

var rally: PlazaRally


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	rally = LEVEL.instantiate()
	rally.case_seed = 4242
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _look(who: Politician, tell: String) -> Array:
	var shapes := []
	for part: MeshInstance3D in who.tells.get_node(tell).get_children():
		shapes.append([part.mesh.get_class(), part.position, part.rotation,
			(part.material_override as StandardMaterial3D).albedo_color])
	return shapes


func test_play_can_open_it_and_draws_it_among_the_protections() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=double"])), "double")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["double"]))
	assert_has(PlaceDraw.RALLIES, "double")
	assert_eq(rally.variant, "double")


func test_three_tells_drawn_by_the_seed() -> void:
	var seen := {}
	for case_seed in range(1, 80):
		var drawn := DoubleTells.draw(case_seed)
		assert_eq(drawn.size(), DoubleTells.COUNT)
		var unique := {}
		for tell in drawn:
			assert_has(DoubleTells.TELLS, tell)
			unique[tell] = true
			seen[tell] = true
		assert_eq(unique.size(), DoubleTells.COUNT, "three different ones")
		assert_eq(DoubleTells.draw(case_seed), drawn, "same seed, same tells")
	assert_eq(seen.size(), DoubleTells.TELLS.size(), "every tell comes up")


func test_the_double_hides_in_the_crowd() -> void:
	var double := rally.double
	assert_not_null(double)
	assert_true(double.impostor)
	assert_false(rally.politician.impostor)
	assert_true(double.disguised)
	assert_false(double.tells.visible, "the hat and the scarf hide his tells")
	var plaza: Vector3 = (rally.get_node("City") as Node3D).transform * CityLayout.block_center(CityLayout.PLAZA)
	assert_lt(double.global_position.distance_to(plaza), 15.0, "on the plaza, with the crowd")
	var cop: Cop = rally.get_node("Cop")
	assert_eq(double.prompt_key(cop), "PROMPT_TALK_FAN", "he looks like one more neighbor")
	double.use(cop)
	assert_true(double.said().begins_with("DOUBLE_HIDDEN_"))
	double.disguise(false)
	assert_true(double.tells.visible)


func test_the_double_gets_his_three_tells_wrong() -> void:
	var fakes := DoubleTells.draw(rally.case_seed)
	assert_eq(rally.double.fakes, fakes)
	assert_eq(rally.politician.fakes, [] as Array[String])
	for tell in DoubleTells.TELLS:
		if fakes.has(tell):
			assert_ne(_look(rally.double, tell), _look(rally.politician, tell), "%s tells them apart" % tell)
		else:
			assert_eq(_look(rally.double, tell), _look(rally.politician, tell), "%s is the same on both" % tell)


func test_every_tell_looks_different_on_the_double() -> void:
	var real := Node3D.new()
	var fake := Node3D.new()
	add_child_autofree(real)
	add_child_autofree(fake)
	DoubleTells.dress(real, [])
	DoubleTells.dress(fake, DoubleTells.TELLS)
	for tell in DoubleTells.TELLS:
		var a := real.get_node("Tells/" + tell).get_children().map(func(m: MeshInstance3D) -> Array:
			return [m.position, m.rotation, (m.material_override as StandardMaterial3D).albedo_color])
		var b := fake.get_node("Tells/" + tell).get_children().map(func(m: MeshInstance3D) -> Array:
			return [m.position, m.rotation, (m.material_override as StandardMaterial3D).albedo_color])
		assert_ne(a, b, tell)


func test_the_planilla_carries_the_real_deputys_file() -> void:
	var texts: Array = rally.case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_DOUBLE_FILE")
	for tell in DoubleTells.TELLS:
		assert_has(texts, DoubleTells.file_key(tell))
		assert_ne(tr(DoubleTells.file_key(tell)), DoubleTells.file_key(tell), "%s has its text" % tell)


func test_the_plain_rally_has_no_double() -> void:
	var plain: PlazaRally = preload("res://scenes/levels/plaza_rally.tscn").instantiate()
	plain.case_seed = 4242
	plain.get_node("Cop").input_enabled = false
	add_child_autofree(plain)
	await wait_physics_frames(2)
	assert_null(plain.double)
	assert_null(plain.politician.tells)
	var texts: Array = plain.case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_does_not_have(texts, "OBJ_DOUBLE_FILE")
